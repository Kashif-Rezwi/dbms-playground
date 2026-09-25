# P5 — Index Performance Lab

**Milestone:** Mongo Days 16–18 · **Time:** ~90 min · **Dataset:** `perf_lab` — `./scripts/utilities/load-large-mongo.sh`

## Objective

The before/after lab, MongoDB edition: profile the battery, index by ESR, prove with ratios, write the report.

## The Four Slow Queries

```javascript
// Q1 user lookup
db.orders.find({ user_id: 417 })

// Q2 user's recent orders
db.orders.find({ user_id: 417 }).sort({ ordered_at: -1 }).limit(20)

// Q3 status range report
db.orders.find({ status: 'delivered', ordered_at: { $gte: ISODate('2025-01-01') } })

// Q4 the deep page
db.orders.find().sort({ ordered_at: -1 }).skip(199990).limit(10)
```

## Deliverables (report file: query | before stats | fix | after stats)

1. Baselines with `explain('executionStats')` — record nReturned / totalKeysExamined / totalDocsExamined / executionTimeMillis
2. The index set (≤3), each with a one-line ESR justification
3. Re-measure — the ratios
4. Q4's special treatment: rewrite cursor-style (`ordered_at + _id` keyset) and compare timings
5. The write-tax audit: bulk-insert 10k scratch docs with and without your indexes — the ratio

## Challenge

6. The covered query: for "names of in-stock products in category 3" — build the index that makes `totalDocsExamined: 0`
7. The ignored-index mystery: index on `status`; query `find({ status: 'delivered' })` on perf_lab (~50% delivered) — scan or IXSCAN, and WHY is that correct? (The selectivity answer, MongoDB edition.)

## Bonus

8. Profiler integration: slowms 100 → manufacture a slow query → find it in `db.system.profile` → fix → gone. The full loop, logged.

## Self-Review

- Which fix gave the biggest ratio win — in what terms (docsExamined)?
- Which query couldn't be helped by indexes — and what does that mean (Q3-style range reports → pre-aggregation/cursors)?
- Your 5-sentence "how I'd index a new MongoDB system."

> [solutions/05-index-lab.md](solutions/05-index-lab.md)
