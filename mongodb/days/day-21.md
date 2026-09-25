# Day 21 — $unwind: Arrays into Rows

**Track:** MongoDB · **Stage:** 6 — Aggregation · **Difficulty:** Intermediate

## Goal

Explode arrays into one document-per-element — the stage that unlocks array analytics — and use it with grouping immediately.

## Fundamentals

**$unwind** deconstructs an array field: one output document per element (the element replaces the array):

```javascript
// in:  { _id: 1, items: [ {product_id: 1, qty: 1}, {product_id: 3, qty: 1} ] }
// out: { _id: 1, items: {product_id: 1, qty: 1} }
//      { _id: 1, items: {product_id: 3, qty: 1} }
```

```javascript
db.orders.aggregate([
  { $match: { status: 'delivered' } },
  { $unwind: '$items' },                            // orders become line items!
  { $group: {
      _id: '$items.product_id',
      units_sold: { $sum: '$items.quantity' },
      revenue: { $sum: { $multiply: ['$items.quantity', '$items.unit_price'] } }
  } },
  { $sort: { revenue: -1 } }
])
```

**Why it's the analytics key:** embedded arrays are unreadable as aggregates — you can't $sum inside an array. Unwind flattens them into *rows* your $group can consume. (This is the moment "order with items" becomes "product sales.")

**Two behaviors to know:**

- **Missing/empty array** → the document *disappears* by default. `preserveNullAndEmptyArrays: true` keeps it (with the field absent) — vital for "products with zero sales" reports.
- **The element can keep the original doc's fields** — you can still $group by `user_id` *after* unwinding items ("revenue per user per product").

## Why It Matters

Every "sales by product", "tags by usage", "skills by frequency" question over embedded data is $unwind + $group. It converts document-shape into analytics-shape — the bridge between Days 12–15's modeling and real reporting.

## Mental Model

> $unwind is the **paper-tray unstacker**: a stapled pack (array) enters; individual sheets come out one by one, each stamped with the original document's other fields. Empty packs vanish unless you set preserveNullAndEmptyArrays (a note: "keep blank trays, mark them as blank").

## Examples

```javascript
// units + revenue per product from embedded order items
db.orders.aggregate([
  { $match: { status: { $ne: 'cancelled' } } },
  { $unwind: '$items' },
  { $group: { _id: '$items.product_id',
              units: { $sum: '$items.quantity' },
              revenue: { $sum: { $multiply: ['$items.quantity', '$items.unit_price'] } } } },
  { $sort: { units: -1 } }, { $limit: 5 }
])

// skills frequency (from the jobs dataset's embedded arrays)
use jobs
db.candidates.aggregate([
  { $unwind: '$skills' },
  { $group: { _id: '$skills.skill', n: { $sum: 1 }, advanced: {
      $sum: { $cond: [{ $eq: ['$skills.level', 'advanced'] }, 1, 0] } } } },
  { $sort: { n: -1 } }
])
```

## Practice

[Beginner] **P1.** Units per product (example above) — predict the best-seller first (3× book (product 9)... or 2× shoes (product 7)? The seed knows — reason it out, then run).
[Beginner] **P2.** Skills frequency on candidates — the top skill? Predict, verify.
[Intermediate] **P3.** preserveNullAndEmptyArrays, felt: insert a scratch order with `items: []`; run a units-per-product pipeline — the order vanishes from... wait, grouping is by product. Do this instead: unwind user-side. Insert a user with `tags: []`, unwind with and without preserve — count the difference.
[Intermediate] **P4. Predict first:** the candidates pipeline's `advanced` count for SQL — how many candidates have SQL, and how many have SQL *advanced*? (Seed: 6 with SQL, 2 at advanced. Predict both, verify.)
[Intermediate] **P5.** Per-user per-product revenue: group by `{ user_id: '$user_id', product_id: '$items.product_id' }` after unwinding — composite keys, felt.
[Advanced] **P6.** The zero-sales report: products with NO order items — via $unwind? Via $lookup? Via app-side set difference? Sketch all three (with/without lookup is Day 22's tool — sketch is enough today); implement the app-side one (fetch sold product_ids, diff against all) and the *reason* embedded data needs a different technique than SQL's LEFT JOIN (the shape has no "unmatched row" to filter... discuss!).
[Advanced] **P7. From memory:** the unwind→group→sort skeleton + the two behaviors (empty arrays; retained fields).

## Debugging

```javascript
// Bug 1: $unwind: 'items' (no $) — error: "path must be prefixed with $".
// Fix in one line.
// Bug 2: after $unwind, someone $projects 'items' expecting an array —
// it's now a single object. What mental model slip happened?
// Bug 3: "orders without items vanish from my report" — which option,
// where, fixes it?
```

## Combine Concepts

The modeling insight, earned: compute yesterday's "top-3 users by revenue" again — first WITHOUT unwinding (group on total_amount — orders' stored totals), then by unwinding items and computing revenue from line items. Do they agree? When would they *disagree*, and what stored-vs-computed lesson does that encode? (Day 13's hybrid + Day 15's computed pattern — now with $unwind as the recomputation tool.)

## Previous Knowledge

1. WHERE vs HAVING, pipeline-style?
2. The seven accumulators?
3. What does `_id: null` group?
4. Pipeline rule #1?

## Recall

1. What does $unwind do to one document with a 3-element array?
2. What happens to docs with missing/empty arrays — and the fix?
3. What survives unwinding (which fields)?
4. What question does $unwind unlock that find can't ask?

## Interview Questions

1. "How do you aggregate over data embedded in arrays?" *( $unwind → $group.)*
2. "How do you compute revenue from embedded order items?" *(Unwind + $multiply sum.)*
3. "What happens to empty arrays in $unwind, and why does it matter?" *(Vanish; preserve option; skewed reports.)*

## Completion Checklist

- [ ] Understand $unwind mechanics + the two behaviors
- [ ] Completed P1–P7 (P4 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the stored-vs-computed revenue comparison
- [ ] Answered recall without notes
