# Project 6 — Query Performance Lab

**Milestone:** SQL Stage 5 (after Day 24) · **Time:** ~90 min · **Dataset:** `perf_lab` (`./scripts/utilities/load-large-postgres.sh`)

## Objective

Take a set of slow queries from bad to good — measured, explained, and documented. This is a real performance-investigation workflow.

## Scenario

You're the new database person. An app "feels slow" around these four queries. Management wants answers with numbers.

## The Four Slow Queries

```sql
-- Q1: "user's orders" lookup
SELECT * FROM big_orders WHERE user_id = 417;

-- Q2: the revenue report
SELECT u.city, SUM(o.total_amount)
FROM big_users u JOIN big_orders o ON o.user_id = u.id
WHERE o.status <> 'cancelled'
GROUP BY u.city;

-- Q3: the deep page
SELECT * FROM big_orders ORDER BY ordered_at DESC LIMIT 10 OFFSET 199990;

-- Q4: the product page check
SELECT COUNT(*) FROM big_order_items WHERE product_id = 1234;
```

## Your Deliverables

For **each query**: (a) baseline `EXPLAIN ANALYZE` + wall-clock time, (b) diagnosis in one sentence, (c) the fix (index / rewrite), (d) after-timing + plan, (e) one-line trade-off note.

Write it as a small report file (`sql/projects/perf-lab-report.md`) — like a mini PR write-up.

## Required Steps

1. Load `perf_lab`; `\timing on`
2. Baseline all four (write numbers down!)
3. Fix Q1 and Q4 with indexes; *explain why those indexes and not others*
4. Fix Q2: choose between an index and a rewrite (filter early) — try both, keep the better, justify
5. Fix Q3 with **keyset pagination** (rewrite; show the OFFSET vs keyset timing pair)
6. Re-run the full battery; produce a before/after table

## Constraints

- No fix without a measurement. Numbers or it didn't happen.
- Every index creation must be justified by the query it serves (Day 22's discipline).

## Performance Requirement

The whole point — targets to aim for (hardware varies; the *ratio* matters):

- Q1: >50× faster with index
- Q4: similar
- Q3: OFFSET 199990 should take noticeably longer than keyset at the same depth — measure the gap
- Q2: a measurable improvement either way

## Challenge Tasks

1. Add a fifth query of your own: something you predict is slow, prove it, fix it, document it
2. The write-tax audit: with all your indexes in place, time a bulk `INSERT INTO big_orders` of 1000 rows (use generate_series), then DROP the indexes and time it again. Report the tax.

## Bonus Challenge

3. The "planner won't use my index" mystery: create an index on `big_orders.status` and EXPLAIN `WHERE status = 'delivered'`. Why is Seq Scan *correct* here? (Selectivity!) Document the explanation — this is the answer that separates juniors from mids.

## Expected Outcome

A performance report with real numbers, four (or six) fixed queries, and the reflex: **measure → diagnose → fix → re-measure.**

## Self-Review Questions

- Which fix gave the biggest win, and why (in index terms)?
- Which "fix" didn't help much — and what does that teach you about guessing?
- What would you check *first* next time someone says "the database is slow"? (Your honest one-sentence method.)

> Done? [solutions/06-performance-lab.md](solutions/06-performance-lab.md)
