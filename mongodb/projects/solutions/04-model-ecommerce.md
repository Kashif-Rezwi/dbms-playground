# Solutions — P4: Model an E-Commerce Store

> A *reference* design — yours may differ and still be right if every choice is defended. Compare reasoning, not shapes.

## 1–2. Access patterns → design (the reasoning you should mirror)

```text
1. Product page (HOT): product + rating summary + top review
2. Cart page (HOT): active cart + product names
3. Order history (warm): user's orders, newest first
4. Search (HOT): by name/tag
5. Checkout (CRITICAL): create order, clear cart — atomicity matters
6. Submit review (warm)  7. Admin analytics (cold)  8. Order detail (warm)
```

**The reference schema:**

```text
users        — standalone identity; referenced by others
products     — { _id, name, category, price, stock, tags: [],
                reviews_cache: { avg, count, top: [ ≤3 embedded ] } }
             — embedded rating summary (computed+subset patterns) because
               the product page is THE hot read; drift duty: review writes
               must maintain the cache
carts        — { user_id, items: [ { product_id, name, price_at_add, qty } ] }
             — EMBEDDED items (1:few, bounded, read-together) + denormalized
               name/price snapshots (a cart shows what you thought you were buying)
orders       — { user_id, status, items: [ same snapshot shape ], total,
                ordered_at } — embedded items (bounded), snapshots = history
reviews      — own collection (1:many UNBOUNDED; queried standalone)
```

**Patterns used, labeled:** Embedded (cart items, order items), Subset (top-3 reviews on the product), Computed (avg/count cache), Extended reference/snapshot (price_at_add, item names in orders = history semantics).

**The integrity list:** orders.user_id and carts' product_ids → app-side checks; the maintenance jobs: review-writes → reviews_cache update; price changes → carts show stale *by design* (snapshot), products are the source of truth at checkout.

## 6. Validators (the shape contract)

```javascript
db.createCollection('products', { validator: { $jsonSchema: {
  required: ['name', 'price', 'stock'],
  properties: {
    name: { bsonType: 'string' }, price: { bsonType: 'decimal' },
    stock: { bsonType: 'int', minimum: 0 },
    tags: { bsonType: 'array' } } } } })
```

## 7. Top reads as flows

```javascript
// product page — ONE read (the embed payoff)
db.products.findOne({ _id: 9 })

// cart + names — ONE read (snapshots denormalized)
db.carts.findOne({ user_id: 1, status: 'active' })

// order history — one read per page + an index
db.orders.find({ user_id: 1 }, { status: 1, ordered_at: 1, total: 1 })
        .sort({ ordered_at: -1 }).limit(10)
```

## 8. The write flows

```javascript
// add-to-cart — the positional-$ 2-step (Day 10's canonical solution)
const r = db.carts.updateOne(
  { user_id: 1, status: 'active', 'items.product_id': 5 },
  { $inc: { 'items.$.qty': 1 } })
if (r.modifiedCount === 0)
  db.carts.updateOne(
    { user_id: 1, status: 'active' },
    { $push: { items: { product_id: 5, name: 'Cotton T-Shirt',
                       price_at_add: NumberDecimal('1299'), qty: 1 } } },
    { upsert: true })

// submit-review + cache maintenance (the computed pattern's drift duty)
db.reviews.insertOne({ product_id: 9, user_id: 3, rating: 5, comment: '...' })
db.products.updateOne({ _id: 9 }, [
  { $set: {
    'reviews_cache.count': { $add: ['$reviews_cache.count', 1] },
    'reviews_cache.avg': {
      $divide: [
        { $add: [ { $multiply: ['$reviews_cache.avg', '$reviews_cache.count'] }, 5 ] },
        { $add: ['$reviews_cache.count', 1] } ] } } } ])
```

**Checkout** (transaction argument): under THIS design, checkout = read cart (one doc) + insert order (one doc, items embedded) + clear cart (one doc). Three documents, one user, no cross-user invariant → a transaction is *optional* (retry-style error handling may suffice); teams with billing-critical paths wrap it in the Day 24 session transaction anyway. **The argument in the file is the graded part.**

## 9. The index plan

```text
find({ user_id }) orders          → { user_id: 1, ordered_at: -1 }  (history)
find({ 'tags': x }) products     → { tags: 1 }                      (multikey search)
find({ name: /^Prefix/ })         → { name: 1 }                      (prefix search only!)
carts: { user_id: 1, status: 1 }                                     (the active-cart seek)
```

## 10. The drift audit (a reference answer)

Price changes touch: products (truth), NOT carts/orders (snapshots by design — history semantics). Review changes touch: reviews + the product's cache (duty assigned above). Category renames: products only (category embedded as data — the "ghost collection" warning from Day 15).

## 11. The SQL comparison (a reference answer)

The SQL P3 needed junction/child tables for order_items + reviews; my design embeds order items (bounded, read-together) and keeps reviews referenced (unbounded) — the split IS the modeling lesson: the SQL default is uniform (always normalize); the MongoDB default is tiered by access pattern and growth.
