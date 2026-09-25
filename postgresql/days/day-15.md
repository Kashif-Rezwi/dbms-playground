# Day 15 — The Query Planner + EXPLAIN Deep Read

**Track:** PostgreSQL · **Stage:** 4 — Indexes & Planner · **Difficulty:** 🔴
**Prerequisites:** SQL Day 23 (the method) — today: the planner's *model*.

## 🎯 Goal

Understand *how* the planner decides — statistics, cost model, join strategies — and read plans like a native.

## 🧠 Fundamentals

**The planner's world:** given a query, it enumerates plans (index vs scan, join order, join algorithm) and picks the **lowest estimated cost**. Cost is a *model*, not a measurement:

- **Seq Page Cost = 1.0, Random Page Cost = 4.0** — reading a page *in order* is modeled 4× cheaper than a random fetch. This ratio is why "index for 50% of rows" loses to a scan.
- **CPU tuple cost**, **cpu_operator_cost** — per-row processing.

**Statistics (`SELECT * FROM pg_stats WHERE tablename='big_orders';`)**: per-column row counts, **distinct values (n_distinct)**, **most common values + frequencies**, **histogram bounds**, **correlation** (physical vs logical order).

**Join strategies you'll read:**

- **Nested Loop** — outer rows × index seeks on inner; wins when outer is *small* and inner is *indexed*
- **Hash Join** — build a hash table of the smaller side, probe with the other; wins on larger unsorted sides (memory = work_mem)
- **Merge Join** — both sides sorted (often via index); wins on huge sorted inputs

**Row estimates drive everything**: bad n_distinct → bad join-size estimate → wrong strategy → slow query. Fix: `ANALYZE` (Day 16 deeper).

## 🔍 Why It Matters

"The query is slow" almost always decomposes into: *the plan is bad* → *the estimate was bad* → *the statistics are missing/stale/skewed*. That chain is the professional debugging story.

## 💡 Mental Model

> The planner is a **travel agent with a map of average traffic** (statistics) and a pricing table (costs). EXPLAIN is the itinerary it priced; EXPLAIN ANALYZE is the trip *with a stopwatch*. When the itinerary says 10 minutes but the trip took 10 hours, the traffic map is wrong — you don't fix the car, you fix the map (ANALYZE).

## 🛠️ Practice

🟢 **P1.** `SELECT * FROM pg_stats WHERE tablename = 'big_orders' AND attname = 'status';` — read n_distinct, MCV frequencies. One line: why does the planner know 'delivered' ≈ 50%?
🟢 **P2.** EXPLAIN the "small outer" join (`WHERE u.id = 417`, users→orders) vs the "big both" join — one Nested Loop, one Hash. Explain each choice from cardinality.
🟡 **P3.** Cost sanity: a Seq Scan shows cost `0.00..3400.00`, `rows=200000` — check the arithmetic (pages + cpu costs) in your notes.
🟡 **P4.** Correlation reality: `SELECT correlation FROM pg_stats WHERE tablename='big_orders' AND attname='ordered_at';` — near 1.0 for generated data? Explain what correlation ≈ 0 would do to range-scan costs.
🟡 **P5. ⭐ Predict first:** join users→orders WHERE `u.id IN (1,2,3)` — Nested Loop or Hash? Then WHERE `u.city = 'Karachi'` (≈5k users)? Predict, check, explain both.
🟡 **P6. From memory:** the three join strategies + one-sentence "wins when".
🔴 **P7.** Estimate sabotage (safe experiment): `UPDATE big_users SET city='Karachi' WHERE id <= 25000;` WITHOUT re-ANALYZING — pg_stats still believes old n_distinct. EXPLAIN a city query (estimates ~5k, actual ~25k), then ANALYZE and watch the plan flip. Write the before/after story — this *exact* thing happens after production bulk loads.
🔴 **P8.** Cost-model playground: `SET random_page_cost = 1.1;` (SSD-ish), EXPLAIN a moderately-selective query that scanned — did it switch to an index? Reset. One line: what hardware reality does that knob model?

## 🐛 Debugging

```sql
-- Bug 1: plan shows "rows=1" but actual=25000, and the join above it
-- picked Nested Loop for a huge inner. Name the chain of causes and
-- the two-line fix.
-- Bug 2: EXPLAIN says Index Scan; EXPLAIN ANALYZE shows it's actually
-- SLOWER than the old Seq Scan. Estimates vs measurements — when do
-- you trust which?
-- Bug 3: two identical queries, different plans, minutes apart, no DDL.
-- What changed? (Stats refresh / autovacuum / data-growth thresholds.)
```

## 🧩 Combine Concepts

Upgrade your SQL Day 23 method with today's vocabulary: re-run Day 14's P8 audit report, annotating each plan with: strategy choice (NL/HJ/MJ), the estimate that drove it, and the statistic backing it. That annotated report is a portfolio artifact.

## 🔁 Previous Knowledge

1. Composite ordering rule — and why.
2. What does INCLUDE buy?
3. Heap fetches — what are they?
4. SQL: five-step slow-query method.

## 🧠 Recall

1. What three statistic ingredients does the planner use per column?
2. Nested Loop vs Hash Join — "wins when" for each.
3. Why do random page costs make index scans lose on low selectivity?
4. What does `correlation` tell the planner?

## 🎤 Interview Questions

1. "How does the PostgreSQL planner choose between plans?" *(Cost model + statistics.)*
2. "A query's plan changed overnight with no code changes. Hypotheses?" *(Stats refresh, data growth, autovacuum.)*
3. "When does a hash join beat a nested loop?"

## ✅ Completion Checklist

- [ ] Understand cost model, statistics, join strategies
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the annotated audit report
- [ ] Answered recall without notes

