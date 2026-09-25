# Day 17 — Index Strategy Review → Performance Lab

**Track:** PostgreSQL · **Stage:** 4 — Indexes & Planner · **Difficulty:** Advanced · **Milestone:** Project 3

## Goal

Turn five days of engine knowledge into a repeatable **index strategy** — then prove it in the lab.

## Fundamentals — The Strategy, As One Page

**1. Start from queries, never from tables.** An index without a query it serves is a pure write tax. Write the app's top queries down — with their shapes:

```text
Q1  WHERE email = ?                        (point lookup)
Q2  WHERE user_id = ? ORDER BY created_at   (per-parent timeline)
Q3  WHERE status = 'pending' ORDER BY age   (small hot slice)
Q4  WHERE created_at BETWEEN ? AND ?        (range report)
Q5  WHERE a = ? AND b = ? AND c > ?          (compound)
```

**2. Map each shape to its index shape:**

| Query shape | Index shape |
|---|---|
| point lookup | single-column (or expression if wrapped) |
| parent + timeline | composite (parent, time DESC) |
| hot small slice | partial (WHERE the slice) |
| range report | single-column on the range key (correlation helps) |
| compound equality + range | (equalities..., range) |

**3. Cover when reads are ultra-hot:** add INCLUDE for Index Only Scans; remember vacuum keeps it honest (Day 25).

**4. Measure the pair:** every index must show a query whose plan + timing improved. Also measure the write tax on the tables it touches (insert timing before/after — SQL P6 discipline).

**5. Review when:** data volume ×10, query mix changes, or a new slow query appears. Indexes are maintenance items, not furniture.

## Why It Matters

This page is the difference between "I know about indexes" and "I can index a system." Interviews ask precisely this: "how do you decide which indexes to add?"

## Mental Model

> Index strategy = **bus route planning**: routes exist for *known trips* (queries), not "in case someone someday goes from A to B" (speculative indexes). Every route costs fuel even when empty (write tax). The timetable (plan) proves each route is worth it.

## Practice — Strategy Sprint (30 min)

[Beginner] **P1.** From the five shapes above, write the five CREATE INDEX statements (on paper, from memory of Days 13–14). No running yet.
[Beginner] **P2.** Check your answers against the table. Correct, *then* build them on the appropriate perf_lab columns.
[Intermediate] **P3.** For each, EXPLAIN ANALYZE one representative query — with numbers, in a table (query / before / index / after).
[Intermediate] **P4. Predict first:** which of the five indexes will autovacuum/the planner *ignore* for the representative query? (The partial on a slice that's actually 60% of the table — selectivity!) Verify.
[Intermediate] **P5.** The write-tax audit: bulk-insert 100k rows into big_orders with all today's indexes; drop them; re-insert. Report ms delta and the verdict sentence.
[Advanced] **P6.** The anti-portfolio: write three *bad* indexes (redundant `(a)` when `(a,b)` exists; dead index nothing uses; wrong-order composite) — and for each, one line on how you'd *detect* it in a real system. (Preview: `pg_stat_user_indexes.idx_scan = 0`.)
[Advanced] **P7.** Explain in 5 sentences, from memory, "how I decide which indexes to add" — record yourself. This is THE interview answer.

## Debugging — Strategy Failures

```sql
-- Failure 1: index created on a column that's always queried inside
-- a function (upper(name)). What's the fix, and why does the "obvious"
-- fix (indexing name) never work?
-- Failure 2: composite (status, user_id) for the query "this user's
-- pending orders" — works, but... what does it do to Q2's (user, time)
-- query? When do two indexes overlap dangerously?
-- Failure 3: after a big data migration, everything got slow even
-- though "indexes were all recreated." What was skipped? (ANALYZE)
```

## Combine Concepts → Project 3

Build **[P3: Query Performance Lab (100k rows)](../projects/03-performance-lab.md)** — a full performance investigation: profile the battery, apply the strategy page, measure, report. This project is a genuine portfolio artifact.

## Previous Knowledge

1. shared hit vs read vs temp?
2. What do extended statistics teach?
3. When do YOU run ANALYZE manually?
4. The composite-order rule.

## Recall

1. The strategy page's five steps — from memory.
2. The five query-shape → index-shape mappings?
3. How do you *prove* an index earns its write tax?
4. How do you detect a dead index in production?

## Interview Questions

1. "How do you decide which indexes to add to a system?" *(Queries first → shape mapping → measure the pair → review.)*
2. "How do you find indexes that aren't being used?" *(pg_stat_user_indexes.)*
3. "When is an index the WRONG solution?" *(Low selectivity, function-wrapped columns, write-heavy tables, covering views/materializations being cheaper.)*

## Completion Checklist

- [ ] Can recite the strategy page
- [ ] Completed P1–P7 (P4 predicted first)
- [ ] Fixed all three strategy failures
- [ ] Started Project 3
- [ ] Recorded your "how I decide indexes" answer
