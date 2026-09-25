# SQL Cheat Sheet

Quick reference — for *revision after practice*, not a substitute for it.

## Reading (CRUD: R)

```sql
SELECT col1, col2 FROM table;             -- choose columns
SELECT * FROM table;                      -- all columns (avoid in code)
SELECT price * 2 AS double_price FROM t;  -- expressions + alias
SELECT DISTINCT city FROM users;          -- remove duplicates
```

## Filtering

```sql
WHERE age > 25 AND city = 'Karachi'
WHERE status = 'active' OR vip = TRUE
WHERE NOT deleted
WHERE name LIKE 'A%'                     -- % any chars, _ one char
WHERE city IN ('Lahore', 'Multan')
WHERE price BETWEEN 100 AND 500
WHERE col IS NULL / IS NOT NULL          -- never = NULL
```

## Sorting & paging

```sql
ORDER BY created_at DESC, name ASC
LIMIT 10
LIMIT 10 OFFSET 20                        -- page 3 of 10
```

## Writing (CRUD: C/U/D)

```sql
INSERT INTO users (name, email) VALUES ('Ali', 'ali@x.com');
INSERT INTO users (name, email) VALUES ('A','a@x'), ('B','b@x');   -- multi-row

UPDATE users SET status = 'inactive' WHERE joined_at < '2020-01-01';

DELETE FROM users WHERE id = 42;
TRUNCATE TABLE logs;                      -- fast wipe, no WHERE
```

## Aggregation

```sql
SELECT COUNT(*) FROM orders;                         -- all rows
SELECT COUNT(discount_code) FROM orders;             -- non-NULL only
SELECT SUM(total), AVG(rating), MIN(price), MAX(price) ...
SELECT city, COUNT(*) FROM users GROUP BY city;
SELECT city, COUNT(*) AS n FROM users GROUP BY city HAVING COUNT(*) > 2;
```

> WHERE filters rows *before* grouping; HAVING filters groups *after*.

## Joins

```sql
SELECT u.name, o.total_amount
FROM users u
INNER JOIN orders o ON o.user_id = u.id;

SELECT u.name, o.id AS order_id          -- keep users with no orders
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.id IS NULL;                      -- …that HAVE no orders

-- self join
SELECT e.name, m.name AS manager
FROM employees e
JOIN employees m ON e.manager_id = m.id;
```

## Subqueries & CTEs

```sql
SELECT name FROM users
WHERE id IN (SELECT user_id FROM orders WHERE total_amount > 5000);

WITH big_orders AS (
    SELECT * FROM orders WHERE total_amount > 5000
)
SELECT u.name, b.total_amount
FROM big_orders b JOIN users u ON u.id = b.user_id;

-- recursive CTE
WITH RECURSIVE t AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM t WHERE n < 5
)
SELECT * FROM t;
```

## Window functions

```sql
SELECT name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC),
       RANK()       OVER (ORDER BY salary DESC),
       SUM(salary)  OVER (PARTITION BY dept)
FROM employees;
```

## Transactions

```sql
BEGIN;
UPDATE accounts SET balance = balance - 500 WHERE id = 1;
UPDATE accounts SET balance = balance + 500 WHERE id = 2;
COMMIT;      -- or ROLLBACK;
```

## Dates & strings (PostgreSQL flavor)

```sql
SELECT NOW(), CURRENT_DATE;
SELECT EXTRACT(YEAR FROM ordered_at);
SELECT ordered_at + INTERVAL '7 days';
SELECT UPPER(name), LENGTH(name), SUBSTRING(name, 1, 3);
SELECT first_name || ' ' || last_name;
```

## Constraints & keys

```sql
CREATE TABLE users (
    id      INT PRIMARY KEY,
    email   TEXT NOT NULL UNIQUE,
    age     INT CHECK (age >= 0),
    role    TEXT DEFAULT 'member',
    org_id  INT REFERENCES organizations(id)
);
```

## Indexes & plans

```sql
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_user_date ON orders(user_id, ordered_at DESC);
DROP INDEX idx_orders_user;
EXPLAIN ANALYZE SELECT ...;
```
