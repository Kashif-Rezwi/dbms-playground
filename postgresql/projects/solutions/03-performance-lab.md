# ✅ Solutions — P3: Performance Lab

## The index plan (≤ 4, on paper first — Day 17 shapes)

```sql
-- Q1 + Q2 (and Q3's first leg): composite — equality, then sort column
CREATE INDEX idx_orders_user_date ON big_orders (user_id, ordered_at DESC);

-- Q3 fully: equality+equality — (user_id, status) also serves Q1... but note:
-- with (user_id, ordered_at) alone, Q3 still seeks user 417 then filters status —
-- usually good enough. Keep TWO composites only if Q3 is ultra-hot.

-- Q5: the join column
CREATE INDEX idx_orders_user_plain ON big_orders (user_id);
-- (overlaps with the composite's prefix — if you created both, discuss: the
-- plain one is redundant! leftmost-prefix serves Q5's join probe. DROP it.)

-- Q4: NOTHING helps — see verdict below.
```

## Expected report shape

```text
Q1  before: Seq Scan ~40ms, 200k rows read   → after: Index Scan ~0.3ms  (100×+)
Q2  before: Seq Scan + Sort ~60ms            → after: Index Scan, NO Sort node (~0.3ms)
Q3  before: Seq Scan + Filter ~45ms          → after: Index Scan + Filter on status ~0.5ms
    (or (user_id, status) composite → no filter at all — measure both, decide by Q3's hotness)
Q5  before: Hash Join over 2 Seq Scans ~120ms→ after: ~70ms (index side cheaper; scan of orders remains)
Q4  before: Seq Scan ~60ms → after: SAME (aggregating everything is scan-shaped)
```

## Q4's verdict (the honest finding)

`GROUP BY month over ALL rows` must visit every row — no index helps. Real fixes, in preference order: (1) a **materialized view** refreshed nightly/hourly (Day 8), (2) a pre-aggregated `monthly_revenue` table maintained by triggers (Day 10 — write cost), (3) a BRIN index on `ordered_at` *if* the table is huge and time-correlated — helps range scans, not full aggregation. This is the strategy page's limit: **indexes serve selective queries; full aggregation needs pre-aggregation.**

## 2. Stats check

Uniform generated data → estimates should be close. The check still matters: `EXPLAIN` showing `rows≈actual` proves you CAN verify, and the skill pays off on real (skewed) data — where `ANALYZE` + `SET STATISTICS` are the fix (Day 15 P7's sabotage story).

## 7. The ignored index

```sql
CREATE INDEX idx_orders_status ON big_orders (status);
EXPLAIN SELECT * FROM big_orders WHERE status = 'delivered';
-- Seq Scan — CORRECTLY: 'delivered' ≈ 50% of rows; the index would do ~100k
-- scattered heap fetches (random_page_cost×4) vs one sequential sweep.
```

## 8. Dead-index detection

```sql
SELECT relname, indexrelname, idx_scan FROM pg_stat_user_indexes
WHERE schemaname='public' AND idx_scan = 0
ORDER BY 1;
-- fresh indexes show 0 until you query them; on a live system, months of
-- idx_scan=0 = tax with no passenger → DROP (and reclaim write cost).
```

## 9. Covering bonus

```sql
CREATE INDEX idx_orders_user_cover ON big_orders (user_id, ordered_at DESC)
    INCLUDE (status, total_amount);
VACUUM big_orders;    -- visibility map (Day 25!)
EXPLAIN (ANALYZE, BUFFERS)
SELECT ordered_at, status, total_amount FROM big_orders
WHERE user_id = 417 ORDER BY ordered_at DESC LIMIT 20;
-- Index Only Scan, Heap Fetches ≈ 0 — the heap is never touched.
```

## Self-review answers (short)

- The `(user_id, ordered_at)` composite served three queries — equality + sort in one structure is the most leverage per index.
- Q4 teaches the boundary: indexes are selective-access tools, not aggregation tools.
- Interview answer: queries first, shapes mapped, fewest indexes, measured pair (query + write tax), reviewed when data or mix changes.
