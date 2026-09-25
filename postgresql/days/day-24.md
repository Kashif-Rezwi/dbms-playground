# Day 24 — Performance Tuning Checklist

**Track:** PostgreSQL · **Stage:** 6 — Security & Ops · **Difficulty:** 🔴

## 🎯 Goal

Turn Days 13–16 into an operator's tuning checklist: find the slow queries first, fix the biggest, re-measure — with the tools that make it repeatable.

## 🧠 Fundamentals

**The finding tool: `pg_stat_statements`** — every query's total time, calls, and averages:

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;   -- needs shared_preload_libraries
-- (if unavailable in your setup, note it and use the rest of the checklist)

SELECT calls, round(total_exec_time::numeric, 0) AS total_ms,
       round(mean_exec_time::numeric, 1) AS avg_ms,
       left(query, 60) AS query
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;
-- sort by TOTAL for system load; by MEAN for user pain
```

**The table X-ray: `pg_stat_user_tables`** — sequential vs index scan counts:

```sql
SELECT relname, seq_scan, seq_tup_read, idx_scan,
       n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_user_tables
ORDER BY seq_tup_read DESC;
-- high seq_tup_read on a big table = missing index (or stale stats!)
```

**The operator's checklist (in order — always this order):**

```text
1. FIND    — pg_stat_statements by total time → top 3 offenders
2. EXPLAIN — (ANALYZE, BUFFERS) each → name the expensive node (Day 16)
3. STATS   — estimates ≈ actuals? if not: ANALYZE / SET STATISTICS (Days 15–16)
4. INDEX   — match the query shape → composite/partial/expression (Days 14, 17)
5. WORK    — spills? SET LOCAL work_mem for the query only
6. REWRITE — filter early, fewer columns, EXISTS-vs-COUNT, keyset (SQL Day 24)
7. RECHECK — re-measure. <10× improvement? revisit step 2 — wrong thing fixed
```

**Settings you may actually touch (session-level first, always):**

- `work_mem` — per-op sort/hash memory (temp spills vanish)
- `random_page_cost` — model SSDs vs spinning disks honestly
- `max_parallel_workers_per_gather` — parallel scans on big reads
- **never** `shared_buffers`/`max_connections` blindly — measure first (Days 25–28)

## 🔍 Why It Matters

Tuning isn't folklore — it's a loop: measure, name the cost, apply the matching fix, re-measure. This checklist is what "performance engineer" means, procedure-ized.

## 💡 Mental Model

> The checklist is a **triage flow in an ER**: the monitor (pg_stat_statements) shows who's in pain; the X-ray (EXPLAIN BUFFERS) shows *where it hurts*; then you prescribe by diagnosis — glasses (indexes), working memory (work_mem), or lifestyle change (rewrite). Nobody prescribes before X-raying.

## 🛠️ Practice

🟢 **P1.** Enable pg_stat_statements (shared_preload_libraries + restart; skip gracefully if you can't). Run your perf_lab battery; write the top-10 report.
🟢 **P2.** `pg_stat_user_tables` on perf_lab: rank by seq_tup_read. Name the table the database reads sequentially most, and the query causing it.
🟡 **P3.** Run the full checklist on the worst query from P1 — document each step's finding, including steps that correctly say "no action needed".
🟡 **P4. ⭐ Predict first:** which checklist steps will be no-ops on perf_lab's uniform generated data? (Statistics on uniform columns are already good.) Why does production hit those steps far more often?
🟡 **P5.** SET LOCAL discipline: inside a transaction, `SET LOCAL work_mem = '256MB';` — why does SET LOCAL (auto-reverts) beat SET for one report query in a pooled app?
🔴 **P6.** Parallelism taste: EXPLAIN (ANALYZE) a huge aggregate; then `SET max_parallel_workers_per_gather = 4;` re-run — find Gather nodes. Two lines: what parallelism bought, and why the planner doesn't always use it.
🔴 **P7. From memory:** recite the 7-step checklist, naming the tools for steps 1, 2, and 5.
🔴 **P8.** The anti-tuning audit: three folklore "tweaks" you now distrust, and the measurement-first reason for each (shared_buffers without cache-hit data; indexing everything; max_connections=1000 because "users").

## 🐛 Debugging

```sql
-- Bug 1: pg_stat_statements shows mean_ms=80 with calls=1,000,000; a dev
-- wants to optimize a different 8000ms query that runs once nightly.
-- Your response, in numbers?
-- Bug 2: seq_scan is high on a small lookup table — problem? (No — scans
-- are CORRECT for small/low-selectivity. Which day taught size-first?)
-- Bug 3: after adding the "right" index, the stats still show the same
-- avg. Three hypotheses: index unused (EXPLAIN), data too small, or
-- you're reading cached history — verify each.
```

## 🧩 Combine Concepts

The monthly tuning ritual (Project 6 material): run the top-10 report → pick ONE offender → full checklist → write the 5-line report (symptom / diagnosis / fix / before / after). This *is* the ops habit.

## 🔁 Previous Knowledge

1. What does pg_dump NOT protect, and what does?
2. RLS — what does FORCE close?
3. The composite-order rule.
4. shared hit vs read vs temp?

## 🧠 Recall

1. The 7-step checklist — which tools own steps 1, 2, 5?
2. pg_stat_statements: sort by total vs mean — which purpose each?
3. Why SET LOCAL work_mem beats SET in pooled apps?
4. What does seq_tup_read tell you — and when is a high value *fine*?

## 🎤 Interview Questions

1. "A PostgreSQL server is slow — your diagnostic process?" *(The checklist — tools and order.)*
2. "How do you find the slowest queries in production?" *(pg_stat_statements: total vs mean — both uses.)*
3. "What tuning settings have you actually changed, and why?" *(Session-level first; measured; honest answer includes "I reverted most".)*

## ✅ Completion Checklist

- [ ] Understand pg_stat_statements, pg_stat_user_tables, the checklist
- [ ] Completed P1–P8 (P4 predicted first)
- [ ] Fixed all three bugs
- [ ] Wrote one full tuning-ritual report
- [ ] Answered recall without notes

