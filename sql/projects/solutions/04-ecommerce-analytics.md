# ✅ Solutions — Project 4: E-Commerce Analytics

> The dataset is the shared `ecommerce` — so these answers are *checkable*. Predictions first!

## Foundation

```sql
-- 1. the 4-table chain
SELECT o.id AS order_id, u.name, u.city, p.name AS product,
       oi.quantity, oi.quantity * oi.unit_price AS line_total
FROM orders o
JOIN users u        ON u.id = o.user_id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p     ON p.id = oi.product_id;

-- 2. revenue per customer including zeros
SELECT u.name, COALESCE(SUM(o.total_amount), 0) AS revenue
FROM users u
LEFT JOIN orders o ON o.user_id = u.id AND o.status <> 'cancelled'
GROUP BY u.name
ORDER BY revenue DESC;
-- Note the conditions in the ON clause — putting them in WHERE would
-- silently turn this into an INNER JOIN (Day 27 trap!). COALESCE for the
-- still-zero NULL (Day 7).

-- 3a. never reviewed NOR ordered (two-way LEFT JOIN — safe, NULL-proof)
SELECT p.id, p.name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN reviews r       ON r.product_id  = p.id
WHERE oi.id IS NULL AND r.id IS NULL;
-- 3b. NOT IN version (safe here: both source columns are NOT NULL — say why!)
SELECT * FROM products
WHERE id NOT IN (SELECT product_id FROM order_items)
  AND id NOT IN (SELECT product_id FROM reviews);
```

## Analytics

```sql
-- 4. monthly revenue by status
SELECT EXTRACT(YEAR FROM ordered_at) AS yr, EXTRACT(MONTH FROM ordered_at) AS mo,
       status, SUM(total_amount) AS revenue
FROM orders
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;

-- 5. category performance
SELECT c.name, COUNT(p.id) AS products,
       ROUND(AVG(p.price), 2) AS avg_price,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS revenue
FROM categories c
LEFT JOIN products p      ON p.category_id = c.id
LEFT JOIN order_items oi  ON oi.product_id = p.id
GROUP BY c.name;

-- 6. top 3 by revenue + running total
SELECT name, revenue,
       ROUND(SUM(revenue) OVER (ORDER BY revenue DESC), 2) AS running_total
FROM (
    SELECT u.name, SUM(o.total_amount) AS revenue
    FROM users u JOIN orders o ON o.user_id = u.id
    WHERE o.status <> 'cancelled'
    GROUP BY u.name
) t
ORDER BY revenue DESC
LIMIT 3;

-- 7. order share of customer spend
SELECT o.id, u.name, o.total_amount,
       ROUND(100.0 * o.total_amount / SUM(o.total_amount)
             OVER (PARTITION BY u.id), 1) AS pct_of_spend
FROM orders o JOIN users u ON u.id = o.user_id
WHERE o.status <> 'cancelled';

-- 8. top 2 products by revenue per category
WITH product_revenue AS (
    SELECT p.category_id, p.name,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p JOIN order_items oi ON oi.product_id = p.id
    GROUP BY p.category_id, p.name
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY revenue DESC) AS rn
    FROM product_revenue
)
SELECT * FROM ranked WHERE rn <= 2 ORDER BY category_id, revenue DESC;
```

## Deep cuts

```sql
-- 9. Q1-first-order customers who ordered again
WITH first_orders AS (
    SELECT user_id, MIN(ordered_at) AS first_order
    FROM orders GROUP BY user_id
)
SELECT COUNT(DISTINCT o.user_id) AS repeat_customers
FROM orders o
JOIN first_orders f ON f.user_id = o.user_id
WHERE f.first_order < DATE '2025-04-01'    -- first order in Q1 2025
  AND o.ordered_at > f.first_order        -- a later order exists
  AND o.status <> 'cancelled';

-- 10. cohort: joined month, members, how many ever ordered
WITH cohorts AS (
    SELECT u.id, EXTRACT(YEAR FROM u.joined_at) || '-' ||
           LPAD(EXTRACT(MONTH FROM u.joined_at)::text, 2, '0') AS cohort
    FROM users u
),
orders_per_user AS (
    SELECT DISTINCT user_id FROM orders WHERE status <> 'cancelled'
)
SELECT cohort, COUNT(*) AS members,
       COUNT(o.user_id) AS ordered,      -- COUNT skips NULLs (Day 9!)
       ROUND(100.0 * COUNT(o.user_id) / COUNT(*), 0) AS pct
FROM cohorts c
LEFT JOIN orders_per_user o ON o.user_id = c.id
GROUP BY cohort ORDER BY cohort;

-- 11. payment method per month (join orders for the date + exclude unpaid)
SELECT EXTRACT(YEAR FROM o.ordered_at) AS yr, EXTRACT(MONTH FROM o.ordered_at) AS mo,
       pay.method, COUNT(*) AS payments, SUM(pay.amount) AS total
FROM payments pay
JOIN orders o ON o.id = pay.order_id
GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;
-- Cancelled order 5 has no payment row anyway (payments only exist for paid
-- orders in this data) — but SAY that assumption out loud.
```

## Challenges

```sql
-- 12. dashboard view
CREATE VIEW monthly_dashboard AS
SELECT EXTRACT(YEAR FROM ordered_at) AS yr, EXTRACT(MONTH FROM ordered_at) AS mo,
       COUNT(*) AS orders,
       SUM(total_amount) AS revenue,
       COUNT(DISTINCT user_id) AS active_customers
FROM orders WHERE status <> 'cancelled'
GROUP BY 1, 2;

-- 13. integrity audit — expect 0 rows
SELECT o.id, o.total_amount, SUM(oi.quantity * oi.unit_price) AS computed
FROM orders o JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, o.total_amount
HAVING o.total_amount <> SUM(oi.quantity * oi.unit_price);
-- Nothing but discipline enforces this in the SQL track. (In the PG track:
-- a trigger. That's the honest answer to "what WOULD enforce this".)

-- 14. month-over-month with LAG
WITH monthly AS (
    SELECT EXTRACT(YEAR FROM ordered_at) AS yr, EXTRACT(MONTH FROM ordered_at) AS mo,
           SUM(total_amount) AS revenue
    FROM orders WHERE status <> 'cancelled'
    GROUP BY 1, 2
)
SELECT yr, mo, revenue,
       LAG(revenue) OVER (ORDER BY yr, mo) AS prev_month,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY yr, mo))
             / NULLIF(LAG(revenue) OVER (ORDER BY yr, mo), 0), 1) AS pct_change
FROM monthly;
```
