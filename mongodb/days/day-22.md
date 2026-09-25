# Day 22 — $lookup: The Join → 🏗️ Project 6

**Track:** MongoDB · **Stage:** 6 — Aggregation · **Difficulty:** 🔴 · **Milestone:** Project 6

## 🎯 Goal

Join two collections inside the pipeline — with $unwind making it practical — and consolidate the aggregation stage in a full analytics project.

## 🧠 Fundamentals

**$lookup** performs a **left outer join** against another collection:

```javascript
{ $lookup: {
    from: 'products',            // the other collection
    localField: 'product_id',    // field on OUR documents
    foreignField: '_id',         // field on THEIR documents
    as: 'product'                // output array field
} }
```

Every input doc gains `product: [ matched docs ]` — **always an array**, even for one match.

**The canonical two-step that makes it useful:**

```javascript
db.order_items.aggregate([
  { $lookup: { from: 'products', localField: 'product_id',
               foreignField: '_id', as: 'product' } },
  { $unwind: '$product' },        // array-of-one → the doc itself
  { $project: { name: '$product.name', price: '$product.price', qty: '$quantity' } }
])
```

**The performance truth** (Day 18's pattern #5): $lookup is a real join — the foreign collection needs an index on `foreignField` or every lookup scans it.

**When $lookup vs app-side $in:** small result sets → app-side `$in` batch (fetch orders, collect ids, one `find({_id: {$in}})`) is simple; $lookup wins for true analytics (one round trip, composable).

## 🔍 Why It Matters

Referenced designs (Days 13–14) become *queryable* with $lookup — it's the price of referencing, paid here. It's also MongoDB's most-asked advanced interview stage.

## 💡 Mental Model

> $lookup is the **annex trip**: for each document, walk to the other collection, gather matches into your arms (an array!), and staple them on as the `as` field. $unwind-after is opening your arms to hold ONE item properly. No index on the annex's shelf → you search the whole annex per trip (performance).

## 💻 Examples

```javascript
// reviews with product names
db.reviews.aggregate([
  { $lookup: { from: 'products', localField: 'product_id',
               foreignField: '_id', as: 'product' } },
  { $unwind: '$product' },
  { $project: { _id: 0, product: '$product.name', rating: 1, comment: 1 } },
  { $sort: { rating: -1 } }
])

// per-city revenue: orders → users, grouped by city
db.orders.aggregate([
  { $match: { status: { $ne: 'cancelled' } } },
  { $lookup: { from: 'users', localField: 'user_id',
               foreignField: '_id', as: 'user' } },
  { $unwind: '$user' },
  { $group: { _id: '$user.city', revenue: { $sum: '$total_amount' },
              orders: { $sum: 1 } } },
  { $sort: { revenue: -1 } }
])
```

## 🛠️ Practice

🟢 **P1.** Reviews + product names — verify the join shape first WITHOUT $unwind (look at `product: [...]`), then with.
🟢 **P2.** Per-city revenue — predict the top city first (compute from the seed data, then verify!).
🟡 **P3.** The index law, felt: generate 20k scratch orders (loop) referencing users; build the $lookup pipeline on `email` (unindexed as join field) vs `_id` (indexed) — time both versions. Report the ratio and the rule: "the ______ field needs an index."
🟡 **P4. ⭐ Predict first:** the $lookup output *before* $unwind for order 1: what's the shape of `user`? And for an order referencing user 999 (a ghost)? (An EMPTY array — the doc survives: the left-outer behavior!)
🟡 **P5.** Ghost detection via pipeline: $lookup + `$match: { user: { $size: 0 } }` — find orders pointing at missing users (insert one first). Your Day 13 P5 integrity check, automated!
🔴 **P6.** The full analytics pipeline (Project 6's core): "top products by revenue with names and units" — orders → $match → $unwind items → $lookup products → $unwind → $group by product name → $sort → $limit 5. Predict the top product first. Comment every stage's job.
🔴 **P7. From memory:** the $lookup 4 fields + the always-an-array rule + the unwind-after habit.

## 🐛 Debugging

```javascript
// Bug 1: after $lookup, code reads result.product.name — undefined!
// (product is an ARRAY. Two fixes: $unwind, or $project the $first
// element — say both.)
// Bug 2: $lookup from: 'product' (singular) — silent empty arrays
// everywhere. The tell-tale? ($size: 0 on everything — a typo'd
// collection name matched nobody.)
// Bug 3: the $lookup pipeline is slow on 100k docs. Two fixes (index
// foreignField; reduce input docs with an earlier $match) — try which
// first, and why?
```

## 🧩 Combine Concepts → Project 6

Build **[P6: E-Commerce Analytics (pipeline)](../projects/06-ecommerce-analytics.md)** — the full analytics battery via pipelines: joins, grouping, unwinds, business questions with predictions. The SQL P4 project, MongoDB edition. Attempt before solutions.

## 🔁 Previous Knowledge

1. $unwind's two behaviors?
2. What does $lookup output pre-unwind?
3. Pipeline rule #1?
4. The modeling rule (Day 12)?

## 🧠 Recall

1. The four $lookup fields — from memory.
2. Why is the result always an array — and the two consequences (unwind-after; empty = no match)?
3. What makes $lookup fast or slow?
4. $lookup vs app-side $in — when each?

## 🎤 Interview Questions

1. "How do you join collections in MongoDB?" *( $lookup + $unwind; index the foreign field.)*
2. "Is $lookup like an INNER or LEFT join?" *(LEFT OUTER — unmatched pass with empty array.)*
3. "When would you avoid $lookup?" *(Small sets: app-side $in; huge joins: precomputed.)*

## ✅ Completion Checklist

- [ ] Understand $lookup, the array rule, $unwind-after, indexing the join
- [ ] Completed P1–P7 (P4 predicted first)
- [ ] Fixed all three bugs
- [ ] Started Project 6
- [ ] Answered recall without notes

