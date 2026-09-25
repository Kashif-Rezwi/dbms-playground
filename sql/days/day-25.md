# Day 25 — Views

**Track:** SQL · **Stage:** 6 — Advanced Application · **Difficulty:** Intermediate
**Prerequisites:** Days 01–24 · **Dataset:** `ecommerce`

## Goal

Save queries as reusable "virtual tables", know when a view helps, and understand materialized views.

## Fundamentals

A **view** is a *saved query* that behaves like a table:

```sql
CREATE VIEW delivered_orders AS
SELECT u.name, o.id AS order_id, o.total_amount
FROM orders o
JOIN users u ON u.id = o.user_id
WHERE o.status = 'delivered';

SELECT * FROM delivered_orders;         -- runs the underlying query
SELECT SUM(total_amount) FROM delivered_orders;  -- like any table
```

**Views store the query, not the data.** Every SELECT on a view re-runs it — always fresh, zero staleness risk.

**What views are for:**

- **Simplify** — hide a 6-join monster behind `customer_revenue`
- **Stability** — apps depend on `SELECT * FROM monthly_report` while you fix the internals
- **Access control** — expose a filtered view instead of the raw table (proper security comes in the PG track)

**Materialized views** — the opposite trade: the *results* are physically stored, and go **stale** until refreshed:

```sql
CREATE MATERIALIZED VIEW product_stats AS
SELECT product_id, AVG(rating) AS avg_rating, COUNT(*) AS review_count
FROM reviews GROUP BY product_id;

REFRESH MATERIALIZED VIEW product_stats;   -- bring it up to date
```

Use when the query is expensive and slightly-stale data is acceptable (dashboards). That's a denormalization decision (Day 20 instinct!).

## Why It Matters

Real reporting codebases are full of views: they give clean names to complex logic and decouple apps from schema churn. Knowing view-vs-materialized-view is a classic design question.

## Mental Model

> A view is a **saved recipe** ("the house special") — cooked fresh every time someone orders it. A materialized view is a **pre-cooked batch** in the fridge: instant, but someone must refresh it when the recipe's ingredients change.

## Examples

```sql
CREATE VIEW product_reviews AS
SELECT p.name AS product, r.rating, r.comment
FROM reviews r JOIN products p ON p.id = r.product_id;

SELECT * FROM product_reviews ORDER BY rating DESC LIMIT 5;

CREATE VIEW user_spending AS
SELECT u.name, SUM(o.total_amount) AS total, COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id AND o.status <> 'cancelled'
GROUP BY u.name;

SELECT * FROM user_spending WHERE total > 5000;
```

## Practice

[Beginner] **P1.** Create the `delivered_orders` view. SELECT from it. Then `\dv` (list views).
[Beginner] **P2.** Create `product_reviews` and find the top-rated products through it.
[Intermediate] **P3.** Create `user_spending` (above — type it yourself). Find all users with total IS NULL — what does the NULL mean here? (Day 7 + Day 12 reunion!)
[Intermediate] **P4.** Prove views are live: INSERT a new review via the *base* table, SELECT from `product_reviews` — is it there?
[Intermediate] **P5.** Create materialized view `product_stats` (avg rating per product). Insert a new review into the base table. Is `product_stats` fresh? REFRESH it. Now?
[Intermediate] **P6. Predict first:** does this work — and why?

```sql
UPDATE delivered_orders SET total_amount = 1 WHERE order_id = 1;
```

(Some views are updatable; multi-table ones aren't. Check the error, then explain the rule.)
[Advanced] **P7. From memory:** create a view `inactive_users` (name, email of `is_active = FALSE` users) and query it for cities.
[Advanced] **P8.** Design decision: monthly revenue — view or materialized view? Argue in 3 lines: staleness tolerance, query cost, refresh cost.

## Debugging

```sql
-- Bug 1 (stale data mystery): dashboard shows old average rating.
-- The team built product_stats as MATERIALIZED and never refreshes it.
-- Diagnose: what are the two possible fixes (REFRESH vs convert to plain view)
-- and their trade-offs?

-- Bug 2: DROP the view then SELECT from it — read the error. Views are
-- objects with dependencies; what happens to queries that used it?

-- Bug 3 (naming): a view named the same as a table? Try
CREATE TABLE test_x (a INT);
CREATE VIEW test_x AS SELECT 1 AS a;   -- what happens and why?
```

## Combine Concepts

Build the analytics layer: create **three views** over the shared dataset — `order_summary` (order, user name, item count, total), `monthly_revenue` (month, revenue — Day 17 pattern), `product_popularity` (product, times ordered, revenue) — then answer three business questions *through the views only*. This is exactly what a real reporting layer looks like.

## Previous Knowledge

1. Keyset pagination — why is deep OFFSET slow?
2. EXPLAIN ANALYZE caveat on writes?
3. The 5-step diagnostic method — from memory.
4. Window vs GROUP BY — output rows?

## Recall

1. What does a view store — query or data? What follows for freshness?
2. View vs materialized view — the trade in one line.
3. Two real reasons to use views?
4. What does REFRESH MATERIALIZED VIEW do?

## Interview Questions

1. "What is a database view and why use one?"
2. "View vs materialized view — when would you pick each?"
3. "Can you UPDATE through a view?" *(Single-table simple ones: often yes; multi-table joins: no — explain the rule of thumb.)*

## Completion Checklist

- [ ] Understand views, materialized views, refresh semantics
- [ ] Completed P1–P8 (P6 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the analytics-layer combine task
- [ ] Answered recall without notes
- [ ] Can explain view vs materialized view out loud
