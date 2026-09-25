# Day 16 — Single & Compound Indexes

**Track:** MongoDB · **Stage:** 5 — Indexes & Performance · **Difficulty:** Intermediate

## Goal

Create indexes that queries actually use, understand the compound-order rule (again — it's universal!), and meet MongoDB's index machinery.

## Fundamentals

The same B-tree concept relational databases use (if you did the SQL track: Day 22) — here it indexes **documents' fields**, including array fields via **multikey**, Day 9's preview:

```javascript
db.users.createIndex({ email: 1 })                        // 1 = ascending
db.orders.createIndex({ user_id: 1, ordered_at: -1 })     // compound
db.orders.find({ user_id: 417 }).sort({ ordered_at: -1 }) // served by ONE seek, no sort!
```

**The same rule you know:** equality fields first, range/sort field after; leftmost-prefix applies (`(a,b)` serves `a`; not `b` alone).

**Two MongoDB-specific facts:**

1. **`_id` gets an index automatically** — everything else is your choice (unlike PostgreSQL's automatic PK index and FK index gap... here *you* build all reading paths).
2. **The ESR rule** — a refinement of ordering: **E**quality fields → **S**ort fields → **R**ange fields last. (Sorting on a *later* compound position can force an in-memory SORT stage — see explain output.)

**Seeing the index machinery:**

```javascript
db.orders.getIndexes()
db.orders.dropIndex('user_id_1_ordered_at_-1')
db.orders.find({ user_id: 1 }).explain()   // today: look for IXSCAN vs COLLSCAN
```

**Costs, same as ever:** every insert/update maintains every index. Index the *access patterns*, not the fields.

## Why It Matters

COLLSCAN (collection scan) at 10k docs is fine; at 10M it's the outage. The ESR rule is the compound-order rule refined for MongoDB's planner, and it's asked in interviews.

## Mental Model

> Same library catalog as PostgreSQL — one card per author for array fields (multikey). The ESR rule is the **packing order for a moving box**: exact-address items first (equality), then items you'll want *in order* (sort), then "anything in this range" thrown on top (range). Wrong order = unpacking the whole box to find one thing.

## Examples

```javascript
use ecommerce

db.orders.createIndex({ user_id: 1, ordered_at: -1 })
db.orders.find({ user_id: 1 }).sort({ ordered_at: -1 }).limit(5)
// one seek + already-sorted walk: no SORT stage

db.orders.createIndex({ status: 1, user_id: 1 })
db.orders.find({ status: 'pending', user_id: 2 })   // both equality: order between them matters less
```

## Practice

[Beginner] **P1.** `db.orders.getIndexes()` — the automatic `_id_` index. Then create `{ user_id: 1 }`; find user 1's orders with explain() — COLLSCAN before (drop it first to see), IXSCAN after.
[Beginner] **P2.** Compound `{ user_id: 1, ordered_at: -1 }`; explain the "user's orders newest-first" query — confirm no SORT stage. Then explain the *reverse* compound `{ ordered_at: -1, user_id: 1 }` — SORT stage appears. Write the verdict (the leftmost rule, felt).
[Intermediate] **P3.** ESR drill: query `{ status: 'pending', user_id: 2 }` sorted by `ordered_at` — design the index (E: status+user_id, S: ordered_at): `{ status: 1, user_id: 1, ordered_at: -1 }`. Explain-check: SORT stage gone?
[Intermediate] **P4. Predict first:** with `{ user_id: 1, ordered_at: -1 }` — will `find({ ordered_at: { $gte: ISODate('2025-03-01') } })` use it? (Leftmost prefix: user_id missing — no.) Verify in explain.
[Intermediate] **P5.** Multikey in action: `db.products.createIndex({ tags: 1 })`; explain `find({ tags: 'usb' })` — IXSCAN on the multikey index. What's indexed per array element?
[Advanced] **P6.** The write-cost measurement: insert 10k scratch docs with and without 3 indexes (time both in JS with Date.now()). Report the ratio and the "index what you query" verdict.
[Advanced] **P7. From memory:** ESR rule + when a SORT stage survives a compound index.

## Debugging

```javascript
// Bug 1: explain shows COLLSCAN on a field with a 100k-doc collection
// and an index EXISTS. Three checks: (wrong field shape? type mismatch?
// the query wraps the field in a function/regex without prefix?)
// Bug 2: the query uses an index but got SLOWER on tiny data. What's
// the honest verdict? (Index overhead > scan cost at small n — fine.)
// Bug 3: someone created { user_id: 1 } AND { user_id: 1, ordered_at: -1 }.
// Which is redundant, and why? (Leftmost prefix covers it — drop the
// narrower one; measure inserts before/after to feel the reclaim.)
```

## Combine Concepts

The modeling + index tie-in: take Day 13's access-pattern contract and design the **index plan** for its top-5 reads (one line per read: the index + the ESR reasoning). Then create them and explain-verify each. You've just done the professional modeling → indexing pipeline end to end.

## Previous Knowledge

1. The three one-to-many tiers?
2. The seven patterns — name them.
3. What does the hybrid cost?
4. What's a multikey index (Day 9 preview)?

## Recall

1. Which index do you get for free? What's always yours to build?
2. The compound-order rule — and the ESR refinement?
3. What two explain signatures tell you index health? (IXSCAN vs COLLSCAN; SORT stage presence)
4. What's the leftmost-prefix consequence for redundant indexes?

## Interview Questions

1. "How do indexes work in MongoDB — and how do compound indexes' field order matter?" *(ESR.)*
2. "How do you check whether a query uses an index?" *(explain: IXSCAN vs COLLSCAN.)*
3. "What's the multikey index?" *(Automatic per-element indexing of array fields.)*

## Completion Checklist

- [ ] Understand index types, ESR, leftmost prefix, index costs
- [ ] Completed P1–P7 (P4 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the modeling→index plan pipeline
- [ ] Answered recall without notes
