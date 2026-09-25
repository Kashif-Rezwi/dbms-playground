# ⭐ Predict-the-Result Drill Pack

> Rules: write your prediction (rows, order, values) **before** running. Check the seed data files if needed. Dataset: `ecommerce` (reset before use).

## Set 1 — Foundations (Days 2–4)

```sql
-- Q1: how many rows?
SELECT name FROM users WHERE is_active = FALSE;

-- Q2: exact order of the first 3 rows?
SELECT name, price FROM products ORDER BY price DESC LIMIT 3;

-- Q3: which rows survive?
SELECT name FROM products WHERE price > 3000 AND stock = 0;

-- Q4: what does the third column contain?
SELECT name, stock, stock > 0 AS in_stock FROM products;

-- Q5: how many rows? (COUNT trap!)
SELECT COUNT(bio), COUNT(*) FROM users;  -- wait, users has no bio...
-- ...so: reviews! reviews.comment has a NULL? Check the seed. Predict both counts.
SELECT COUNT(comment), COUNT(*) FROM reviews;
```

## Set 2 — Aggregation (Days 9–10)

```sql
-- Q6
SELECT COUNT(*) FROM orders WHERE status = 'cancelled';

-- Q7: one row or several? What's in it?
SELECT COUNT(*) FROM orders;

-- Q8: which groups appear, and in what order?
SELECT status, SUM(total_amount) FROM orders
GROUP BY status ORDER BY SUM(total_amount) DESC;

-- Q9: does HAVING remove any group here?
SELECT user_id, COUNT(*) FROM orders GROUP BY user_id HAVING COUNT(*) > 1;

-- Q10: 12 orders... 10 users... predict this count before running!
SELECT COUNT(DISTINCT user_id) FROM orders;
```

## Set 3 — Joins (Days 11–12)

```sql
-- Q11: 12 orders, 17 items... how many rows?
SELECT o.id, oi.product_id FROM orders o JOIN order_items oi ON oi.order_id = o.id;

-- Q12: how many rows? (Everyone is in users...)
SELECT u.name, o.id FROM users u LEFT JOIN orders o ON o.user_id = u.id;

-- Q13: how many? Which users?
SELECT u.name FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.id IS NULL;

-- Q14: users 8 and 10 exist. Reviews: 12 rows by 7 users... who's missing?
SELECT u.name FROM users u JOIN reviews r ON r.user_id = u.id WHERE r.rating = 5;
```

## Set 4 — NULL & logic (Days 3, 7)

```sql
-- Q15: exact output
SELECT 5 + NULL;

-- Q16: rows returned?
SELECT name FROM users WHERE NULL = NULL;

-- Q17: what appears for user 8/10 (no orders) in this output?
SELECT u.name, COALESCE(SUM(o.total_amount), 0) AS spent
FROM users u LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.name;
```

## Self-scoring

15+ correct: excellent prediction instincts. 10–14: normal — re-read the day for each miss. <10: re-do Days 9–12 recall sections.
