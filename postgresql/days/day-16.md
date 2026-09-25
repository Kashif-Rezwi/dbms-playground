# Day 16 — EXPLAIN ANALYZE, BUFFERS & Statistics Management

**Track:** PostgreSQL · **Stage:** 4 — Indexes & Planner · **Difficulty:** Advanced

## Goal

Read *measured* plans at depth — BUFFERS, loops, the JIT — and manage statistics like an operator.

## Fundamentals

`EXPLAIN (ANALYZE, BUFFERS)` is the professional format:

```sql
EXPLAIN (ANALYZE, BUFFERS, SETTINGS)
SELECT * FROM big_orders WHERE user_id = 417;
```

**Reading order (method):** innermost nodes first → find the highest `actual time` → ask why → fix → re-run. **Nodes add overhead**; loops multiply everything inside them.

**What BUFFERS adds** — the memory truth:

- `shared read=N` — pages fetched from disk/OS cache
- `shared hit=N` — served from shared_buffers (fast!)
- `temp read/written=N` — spilled to disk (the *real* cost of big sorts/hashes)

**`loops=N`** — the silent multiplier: a node showing `actual time=0.2` with `loops=10000` costs 2 seconds total. The classic "why is my plan slow" answer.

**Statistics management:**

- `ANALYZE table;` — sample and refresh (autovacuum does this automatically in production — usually you just wait, or run it after bulk loads)
- `ALTER TABLE t ALTER COLUMN c SET STATISTICS 1000;` — *deeper* sampling (default 100) for skewed columns
- **Extended statistics** (PG 10+) — teach the planner about *column relationships*:

```sql
CREATE STATISTICS st_city_active (dependencies) ON city, is_active FROM users;
ANALYZE users;   -- now "city='K' AND is_active" estimates use the correlation
```

**Settings to know exist:** `track_io_timing = on` (I/O per-node timings), JIT (compile-time trade-off — `cost > jit_threshold` triggers it; usually noise for small queries).

## Why It Matters

"This query reads 4 GB of temp" is invisible without BUFFERS. "loops=10000 × 0.3ms" is invisible without reading loops. This day turns EXPLAIN ANALYZE from a black box into an instrument panel.

## Mental Model

> Buffers are the **fuel gauge** (hit = free, read = paid at the pump, temp = borrowed a tanker). Loops are the **×N sticker on the invoice**. Statistics depth is the **sample size of the traffic survey** — 100 samples miss a road that matters; 1000 sees it.

## Practice

[Beginner] **P1.** Run the professional format on a user lookup. Report: hit vs read pages, actual vs estimate, and one line on JIT presence.
[Beginner] **P2.** Run it twice — the second run should show more hits (cache warm). Explain why "cold run" is the honest benchmark for disk-bound queries.
[Intermediate] **P3.** Temp spill experiment: `SET work_mem='64kB';` then EXPLAIN (ANALYZE, BUFFERS) a big `ORDER BY` — find `temp read/written`. Bump work_mem, re-run, watch temp vanish. Report both.
[Intermediate] **P4.** Loops: EXPLAIN ANALYZE `SELECT u.id, (SELECT count(*) FROM big_orders o WHERE o.user_id = u.id) FROM big_users u WHERE u.id <= 100;` — find `loops=100` on the subplan. Time it. Rewrite with a LEFT JOIN + GROUP BY and compare. (Day 24 P7's rematch, now with visible evidence.)
[Intermediate] **P5. Predict first:** a skewed column (`city` with 50% Karachi from Day 15's sabotage): default statistics — does the planner estimate 25k correctly? Then `SET STATISTICS 1000`, ANALYZE, re-EXPLAIN. Did depth change the estimate?
[Advanced] **P6. From memory:** the full diagnostic loop with BUFFERS, in five steps.
[Advanced] **P7.** Extended statistics demo: create a table where two columns correlate (`SELECT i, i % 2 AS even FROM generate_series(1, 50000) i` → t(a, b) with b = a % 2)... simpler: `CREATE TABLE t AS SELECT g AS a, g % 7 AS b FROM generate_series(1,200000) g;` — query `WHERE a = 100 AND b = 2`: plan estimate assumes independence. Create extended stats on (a, b), ANALYZE, re-EXPLAIN — the estimate tightens. Explain what "functional dependency" taught the planner.
[Advanced] **P8.** Write the one-page "reading plan" cheat card for future-you: node types you've met, loops, buffers, temp, estimate-vs-actual. You'll use it on Day 17's project.

## Debugging

```sql
-- Bug 1: query feels slow but every node's actual time looks tiny.
-- What two multipliers are hiding the cost? (loops; temp spills)
-- Bug 2: "estimates are always fine but the query is still slow" —
-- the plan is honest but the *work* is heavy (temp written=GBs).
-- What are the levers? (work_mem, less data, different strategy)
-- Bug 3: autovacuum disabled by someone "for performance". What
-- silently rots over weeks? (stats staleness + bloat — Day 25 links)
```

## Combine Concepts

Full instrumentation of the top-5 report from Day 14's P8: rerun each query with (ANALYZE, BUFFERS, SETTINGS); annotate each with hit/read/temp totals and a loops-warning if any; end with a 3-sentence executive summary ("the two heaviest are..., both spill temp at current work_mem, recommended levers are..."). This IS the project-ready report format.

## Previous Knowledge

1. The three join strategies + "wins when".
2. What does correlation tell the planner?
3. Composite ordering rule.
4. SQL: functions on indexed columns — why fatal?

## Recall

1. shared hit vs read vs temp — one line each.
2. Why do loops multiply, and where do you check them?
3. When do YOU run ANALYZE manually (vs autovacuum)?
4. What do extended statistics teach the planner?

## Interview Questions

1. "How do you find out whether a query is I/O-bound or CPU-bound?" *(BUFFERS, track_io_timing.)*
2. "A subquery-in-SELECT plan shows fast nodes but a slow query — what do you check?" *(loops.)*
3. "What does raising STATISTICS do, and when do you need extended statistics?"

## Completion Checklist

- [ ] Understand BUFFERS, loops, temp, statistics depth, extended stats
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Wrote your plan-reading cheat card
- [ ] Answered recall without notes
