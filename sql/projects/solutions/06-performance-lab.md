# ✅ Solutions — Project 6: Query Performance Lab

> Your numbers depend on hardware — expect the *shapes* below. Times shown are typical laptop-scale.

## Q1 — user's orders lookup

```sql
EXPLAIN ANALYZE SELECT * FROM big_orders WHERE user_id = 417;
-- BEFORE: Seq Scan on big_orders  (rows=200000)   ~35–60 ms
CREATE INDEX idx_big_orders_user ON big_orders(user_id);
-- AFTER:  Index Scan using idx_big_orders_user  (rows=1)   ~0.1–0.5 ms
```

**Diagnosis:** full table scan to find 1 row of 200k. **Fix:** B-tree on the filter column. **Trade-off:** every order write now maintains one more index.

## Q2 — the revenue report

```sql
EXPLAIN ANALYZE
SELECT u.city, SUM(o.total_amount)
FROM big_users u JOIN big_orders o ON o.user_id = u.id
WHERE o.status <> 'cancelled'
GROUP BY u.city;
-- BEFORE: Hash Join over full scans of both tables  ~80–150 ms
```

Two candidate fixes — try both:

```sql
-- Fix A: index the join column
CREATE INDEX idx_big_orders_user ON big_orders(user_id);   -- (may already exist from Q1)
-- Fix B: filter early + let small side drive
-- (usually marginal here: the join must still read all non-cancelled rows)
```

**Honest finding:** for *aggregate-everything* queries, indexes help the join step but a big scan of orders is unavoidable — the real fix is a materialized view or a smaller summary table. **That conclusion is worth more than a fake 10× claim.**

## Q3 — the deep page

```sql
-- BEFORE (OFFSET): must walk 199,990 dead rows  ~60–120 ms
SELECT * FROM big_orders ORDER BY ordered_at DESC LIMIT 10 OFFSET 199990;

-- AFTER (keyset): the index lands directly at the cursor  ~0.1–0.5 ms
SELECT * FROM big_orders
WHERE (ordered_at, id) < ('2024-06-01', 200000)   -- your last shown row
ORDER BY ordered_at DESC, id DESC
LIMIT 10;
```

(Plus an index on `(ordered_at DESC, id DESC)` for the seek.) **Trade-off:** keyset can't jump to arbitrary page N — needs a cursor; UI changes accordingly.

## Q4 — the product page check

```sql
-- BEFORE: Seq Scan on big_order_items (340k rows)   ~25–50 ms
CREATE INDEX idx_big_items_product ON big_order_items(product_id);
-- AFTER: Index Scan  ~0.1–0.3 ms
```

## The write-tax audit (Challenge 2)

```sql
\timing on
INSERT INTO big_orders (id, user_id, status, total_amount, ordered_at)
SELECT 1000000 + g, (g % 50000) + 1, 'pending', 100,
       DATE '2025-01-01' + (g % 500)
FROM generate_series(1, 1000) g;      -- with indexes: ~40–90 ms
-- DROP indexes, repeat: typically 2–5× faster.
-- Report: "each index costs ~X ms per 1000 rows written — justified for
-- read frequency, unacceptable for write-heavy tables."
```

## Bonus 3 — the selectivity mystery

```sql
CREATE INDEX idx_big_orders_status ON big_orders(status);
EXPLAIN SELECT * FROM big_orders WHERE status = 'delivered';
-- Still Seq Scan — CORRECTLY.
```

`'delivered'` matches ~50% of rows. The index would visit ~100,000 index entries *and then fetch 100,000 scattered table rows* — more work than reading the table once, sequentially. **Indexes win when they reject most of the table** (high selectivity). "The planner ignored my index" is sometimes the planner being smarter than you.

## Report template (what your `perf-lab-report.md` should look like)

```text
Query | Before (plan, ms) | Diagnosis | Fix | After (plan, ms) | Trade-off
Q1    | Seq Scan, 48ms   | no index  | idx(user_id) | Index Scan, 0.3ms | write tax
Q2    | Hash Join, 120ms | big scan  | idx + summary-table idea | 60ms | staleness if cached
...
```

## Self-review answers (short)

- Biggest win: Q1/Q4-style lookups (50×+); least: Q2 — aggregation over everything is scan-shaped no matter what, unless you cache/pre-aggregate.
- Method, one sentence: "EXPLAIN ANALYZE first, find the expensive node, fix that node, re-measure."
