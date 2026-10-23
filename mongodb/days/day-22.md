# Day 22 — $lookup: The Join → Project 6

**Track:** MongoDB · **Stage:** 6 — Aggregation · **Difficulty:** Advanced · **Milestone:** Project 6

## Goal

Join two collections inside the pipeline — with $unwind making it practical — and consolidate the aggregation stage in a full analytics project.

## Fundamentals

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

## Why It Matters

Referenced designs (Days 13–14) become *queryable* with $lookup — it's the price of referencing, paid here. It's also MongoDB's most-asked advanced interview stage.

## Mental Model

> $lookup is the **annex trip**: for each document, walk to the other collection, gather matches into your arms (an array!), and staple them on as the `as` field. $unwind-after is opening your arms to hold ONE item properly. No index on the annex's shelf → you search the whole annex per trip (performance).

## Examples

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

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Reviews + product names — verify the join shape first WITHOUT $unwind (look at `product: [...]`), then with.

[Beginner] **W2.** Per-city revenue — predict the top city first (compute from the seed data, then verify!).

### 🔵 Core

[Intermediate] **C1.** `[Predict]` the $lookup output *before* $unwind for order 1: what's the shape of `user`? And for an order referencing user 999 (a ghost)? (An EMPTY array — the doc survives: the left-outer behavior!)

[Intermediate] **C2.** `[From Memory]` the $lookup 4 fields + the always-an-array rule + the unwind-after habit.

[Intermediate] **C3.** The index law, felt: generate 20k scratch orders (loop) referencing users; build the $lookup pipeline on `email` (unindexed as join field) vs `_id` (indexed) — time both versions. Report the ratio and the rule: "the ______ field needs an index."

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

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

[Advanced] **H2.** Capstone Preview (leading into Project 6):

Build **[P6: E-Commerce Analytics (pipeline)](../projects/06-ecommerce-analytics.md)** — the full analytics battery via pipelines: joins, grouping, unwinds, business questions with predictions. The SQL P4 project, MongoDB edition. Attempt before solutions.

[Advanced] **H3.** The full analytics pipeline (Project 6's core): "top products by revenue with names and units" — orders → $match → $unwind items → $lookup products → $unwind → $group by product name → $sort → $limit 5. Predict the top product first. Comment every stage's job.

## Interview Questions

1. "How do you join collections in MongoDB?" *( $lookup + $unwind; index the foreign field.)*
2. "Is $lookup like an INNER or LEFT join?" *(LEFT OUTER — unmatched pass with empty array.)*
3. "When would you avoid $lookup?" *(Small sets: app-side $in; huge joins: precomputed.)*

## Completion Checklist

- [ ] Understand $lookup, the array rule, $unwind-after, indexing the join
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Started Project 6
