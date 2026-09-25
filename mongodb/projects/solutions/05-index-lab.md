# ✅ Solutions — P5: Index Performance Lab

## The index plan (≤3, ESR-reasoned)

```javascript
// Q1+Q2: equality (user_id) then sort (ordered_at desc) — the ESR composite
db.orders.createIndex({ user_id: 1, ordered_at: -1 })

// Q3: equality (status) then range (ordered_at)
db.orders.createIndex({ status: 1, ordered_at: 1 })

// Q4: the keyset needs (ordered_at, _id)
db.orders.createIndex({ ordered_at: -1, _id: -1 })
```

## Expected report shape

```text
Q1 before: COLLSCAN, docsExamined 200000, ~35-60ms
   after: IXSCAN, keysExamined ~1, docsExamined ~1, <1ms
Q2 before: COLLSCAN + in-memory SORT, ~60ms
   after: IXSCAN, NO sort stage (index pre-sorts), <1ms
Q3 before: COLLSCAN + filter, ~45ms
   after: IXSCAN range, docsExamined ≈ delivered-ish slice, ~3-8ms
Q4 before: sort+skip walks 199,990 discarded docs, ~50-120ms
   after (keyset): find({ordered_at:{$lt: anchor}, _id:{$lt: idAnchor}})
                  .sort(...).limit(10) — <1ms, zero discarded
```

## Q4's cursor rewrite (the actual deliverable)

```javascript
// page 1:
const p1 = db.orders.find().sort({ ordered_at: -1, _id: -1 }).limit(10).toArray()
const last = p1[p1.length - 1]
// page 2:
db.orders.find({ $or: [
    { ordered_at: { $lt: last.ordered_at } },
    { ordered_at: last.ordered_at, _id: { $lt: last._id } } ] })
        .sort({ ordered_at: -1, _id: -1 }).limit(10)
```

## The write-tax audit

```javascript
const t0 = Date.now()
const batch = []
for (let i = 1000000; i < 1010000; i++)
  batch.push({ _id: i, user_id: i % 50000, status: 'pending',
               ordered_at: new Date(), total_amount: 100 })
db.orders.insertMany(batch)
print('with indexes:', Date.now() - t0, 'ms')
// DROP the three indexes → repeat → typically 2-4× faster.
// Verdict: each index costs ~Xms/10k docs written; justified by the
// query Q1-Q4 wins, unjustified on write-heavy bulk paths.
```

## Challenge 6 — the covered query

```javascript
db.products.createIndex({ category_id: 1, name: 1, stock: 1 })
db.products.find({ category_id: 3, stock: { $gt: 0 } }, { name: 1, _id: 0 })
  .explain('executionStats').executionStats
// totalDocsExamined: 0 — the index alone answered (stock lives IN the index).
```

## Challenge 7 — the ignored index (selectivity again)

`find({ status: 'delivered' })` on perf_lab matches ~50% of 200k — the planner chooses a COLLSCAN *correctly*: an index would examine ~100k keys then fetch ~100k scattered docs (random-ish I/O), worse than one sequential sweep. **Indexes win when they reject most of the collection.** Same answer as PG Day 17 Bonus — the concept is universal.

## Self-review answers (short)

- Biggest win: Q1/Q2 composite (docsExamined 200000 → ~1) — equality+sort in one structure.
- Q3-style range reports over most of the data can't be index-fixed — the real tools are pre-aggregation/materialized results (the pipeline stage covers Day 20+).
- Interview answer: "top queries → ESR-shaped composites → ratio-verified → write-tax-checked → reviewed when the mix changes."
