# 🏗️ P3 — Query Performance Lab (100k+ rows)

**Milestone:** PG Stage 4 (after Day 17) · **Time:** ~90 min · **Dataset:** `perf_lab` (`./scripts/utilities/load-large-postgres.sh`)

## Objective

A complete performance investigation with PostgreSQL-grade evidence: plans with BUFFERS, statistics checks, and an index plan that follows the Day 17 strategy page.

## Scenario

You inherit an app with five known queries. Each is "fine on demo data" and questionable at scale. Produce a report a lead engineer would accept.

## The Five Queries

```sql
-- Q1 point lookup
SELECT * FROM big_orders WHERE user_id = 417;

-- Q2 per-parent timeline (the composite case)
SELECT * FROM big_orders WHERE user_id = 417 ORDER BY ordered_at DESC LIMIT 20;

-- Q3 compound equality + range
SELECT * FROM big_orders WHERE user_id = 417 AND status = 'pending' AND ordered_at > DATE '2025-01-01';

-- Q4 range report (grouped)
SELECT EXTRACT(YEAR FROM ordered_at) AS yr, EXTRACT(MONTH FROM ordered_at) AS mo,
       SUM(total_amount) FROM big_orders GROUP BY 1, 2;

-- Q5 join + aggregate
SELECT u.city, SUM(o.total_amount) FROM big_users u
JOIN big_orders o ON o.user_id = u.id GROUP BY u.city;
```

## Deliverables (a report file: query × rows: plan, ms, diagnosis)

1. **Baseline** all five with `EXPLAIN (ANALYZE, BUFFERS)` — including shared read/hit and any loops warning
2. **Stats check** before touching anything: estimates vs actuals per query — is ANALYZE needed?
3. **Design the index set** (≤ 4 indexes) on paper first — Day 17's shapes — then apply
4. **Re-measure** — with the composite/partial/covering decisions justified per query
5. **The write-tax audit** — 100k-row bulk insert with and without your indexes
6. **Verdicts**: for any query your indexes didn't help (Q4 usually!), write *why* and what the real fix would be (pre-aggregation/materialized view — name it)

## Challenge Tasks ⭐

7. The "ignored index" explanation: add an index on `status` and show the planner refusing it for `WHERE status='delivered'` — with the selectivity reasoning in your report.
8. Dead-index detection: query `pg_stat_user_indexes` for zero-scan indexes in your perf_lab — did you create any? Remove them (and note the write tax reclaimed).

## Bonus Challenge 🔴

9. The covering-index experiment: for Q2, build `(user_id, ordered_at DESC) INCLUDE (status, total_amount)` and get an Index Only Scan (after VACUUM — Day 25 preview!). Measure the difference vs the plain composite.

## Self-Review

- Which index helped the most queries at once — and why?
- Which query was *unfixable* by indexes alone, and what does that teach you about the strategy page's limits?
- Your one-paragraph "how I'd index a new system" — the interview answer, written.

> ✅ [solutions/03-performance-lab.md](solutions/03-performance-lab.md)
