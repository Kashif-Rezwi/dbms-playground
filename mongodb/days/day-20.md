# Day 20 — $group + Accumulators

**Track:** MongoDB · **Stage:** 6 — Aggregation · **Difficulty:** Intermediate

## Goal

Aggregate per group — the GROUP BY of the pipeline — with the accumulator toolbox and the one stage-order trap.

## Fundamentals

**$group** partitions documents by a key expression and runs accumulators per group:

```javascript
db.orders.aggregate([
  { $match: { status: { $ne: 'cancelled' } } },
  { $group: {
      _id: '$user_id',                    // the grouping key (REQUIRED — can be null)
      revenue: { $sum: '$total_amount' },
      n:     { $sum: 1 },
      avg:   { $avg: '$total_amount' },
      max:   { $max: '$total_amount' },
      first_order: { $min: '$ordered_at' },
      statuses: { $push: '$status' }       // collect values into an array
  } },
  { $sort: { revenue: -1 } },
  { $limit: 5 }
])
```

**The accumulators:** `$sum` (field or 1), `$avg`, `$min`/`$max`, `$push` (array of values), `$addToSet` (unique values), `$first`/`$last` (requires a prior $sort!).

**Two rules that save you hours:**

1. **`_id` is the group key.** `null` = one group (the whole collection). `_id: { city: '$city', status: '$status' }` = composite grouping (the SQL GROUP BY a, b).
2. **$match on grouped results needs $match AFTER $group — that's the HAVING:** `{$match: { n: { $gte: 2 } }}` post-group. Filter-on-group ≠ filter-on-doc (and the doc-level $match still goes FIRST).

**$push is a mini-warehouse** — building per-group arrays (e.g., all of a user's order totals) — the pipeline-native way to re-collect what embedding would have pre-joined.

## Why It Matters

"Revenue per user", "average rating per product", "orders per city per month" — every analytics question is $match + $group + $sort. It's the direct GROUP BY analog — but composable with everything else.

## Mental Model

> $group is the **sorting office** — again! Documents arrive, get sorted into labeled boxes (`_id`), each box gets stamped with its totals (accumulators). $push staples receipts into the box. HAVING's analog: quality-check *boxes* after stamping. Rule reminder: throw away bad letters ($match) BEFORE the office, not after.

## Examples

```javascript
// revenue per status
db.orders.aggregate([
  { $group: { _id: '$status', revenue: { $sum: '$total_amount' }, n: { $sum: 1 } } },
  { $sort: { revenue: -1 } }
])

// composite grouping + HAVING
db.reviews.aggregate([
  { $group: { _id: { product_id: '$product_id', rating: '$rating' },
              n: { $sum: 1 } } },
  { $match: { n: { $gte: 1 } } }
])

// users with their order totals collected ($push)
db.orders.aggregate([
  { $match: { status: 'delivered' } },
  { $group: { _id: '$user_id', totals: { $push: '$total_amount' },
              lifetime: { $sum: '$total_amount' } } },
  { $sort: { lifetime: -1 } }, { $limit: 3 }
])
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Revenue per order status (example above — type it yourself). Predict the top status's revenue first.

[Beginner] **W2.** Products per category_id (count) — then the top 2 categories by count.

### 🔵 Core

[Intermediate] **C1.** `[Predict]` what's `_id` in the output of `{$group: {_id: null, total: {$sum: '$total_amount'}}}` on non-cancelled orders? (One group, whole collection: `{ _id: null, total: ... }` — predict the number too: 60595.5+... compute from the seed data first!)

[Intermediate] **C2.** `[From Memory]` $match-before vs $match-after — which is WHERE, which is HAVING, and why must the doc-level one go first?

[Intermediate] **C3.** Average rating per product — top 3 products. (Hint: reviews collection.)

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```javascript
// Bug 1: $group without _id — error: "a group specification must include
// an _id". What if you want no grouping? (_id: null)
// Bug 2: "average is null" — {$avg: 'total_amount'} (no $). Field refs
// need the $. Fix + re-run.
// Bug 3: post-group $match on 'status' — but status vanished (consumed
// by the group key). Two fixes: include it in _id, or $push it through.
// Verify each.
```

[Advanced] **H2.** The full pipeline, everything so far: **"top 3 users by delivered revenue, with their order count and first order date"** — $match (delivered) → $group (sum, count, $min) → $sort → $limit → $project (rename _id → user_id). Predict the top user first (user 1 or 3? — check the seed!). This is Project 6's opening move.

[Advanced] **H3.** $addToSet vs $push, felt: group orders by status with both `statuses: {$push: '$user_id'}` and `uniques: {$addToSet: '$user_id'}`... on orders grouped by status — who differs? (Users appearing multiple times.)

## Interview Questions

1. "How do you write a GROUP BY in MongoDB?" *( $match → $group → $sort; _id is the key.)*
2. "How do you filter on aggregate results?" *(Post-$group $match = HAVING.)*
3. "How would you collect per-group values into arrays?" *( $push / $addToSet.)*

## Completion Checklist

- [ ] Understand $group, _id, accumulators, WHERE vs HAVING positioning
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Completed the top-3-users pipeline
