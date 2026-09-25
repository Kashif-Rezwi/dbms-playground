# Day 17 — Date/Time & String Operations

**Track:** SQL · **Stage:** 4 — Intermediate Querying · **Difficulty:** Intermediate
**Prerequisites:** Days 01–16 · **Dataset:** `ecommerce` (reset first)

## Goal

Slice data by time, build labels from text — the two "shape the data" toolkits every real query needs. (PostgreSQL syntax; concepts are universal.)

## Fundamentals

**Dates:** comparisons, arithmetic, and extraction:

```sql
WHERE ordered_at >= DATE '2025-01-01'                -- date literals
DATE '2025-01-10' + 7                                -- date arithmetic (days)
ordered_at + INTERVAL '30 days'                       -- typed intervals
EXTRACT(YEAR FROM ordered_at)                        -- 2025 (a number!)
EXTRACT(MONTH FROM ordered_at)                       -- 1..12
ordered_at > CURRENT_DATE - 30                       -- "last 30 days"
```

**Strings:**

```sql
UPPER(name) / LOWER(name)
LENGTH(name)
name || ' (' || city || ')'                          -- concatenation with ||
SUBSTRING(name, 1, 3)                                -- slice
TRIM('  padded  ')
REPLACE(name, 'Wireless', 'W')
```

**Why dates matter:** time-series questions ("orders in January", "growth month by month") are the most common analytics questions. The pattern is always the same: **EXTRACT the unit, GROUP BY it, aggregate.**

## Why It Matters

"Revenue by month", "signups this quarter", "churn in the last 90 days" — dashboards are 90% dates + GROUP BY. String ops turn data into display-ready labels and power search normalization (`LOWER(email)`).

## Mental Model

> Dates are **measuring tapes**: you can compare them, add lengths, and cut them at unit marks (EXTRACT YEAR is zooming out to the year mark). Strings are **text in a word processor**: trim, uppercase, slice, stitch — the result is still text, never a number.

## Examples

```sql
-- orders in January 2025
SELECT id, total_amount FROM orders
WHERE ordered_at >= '2025-01-01' AND ordered_at < '2025-02-01';

-- revenue per month (THE pattern)
SELECT EXTRACT(YEAR  FROM ordered_at) AS yr,
       EXTRACT(MONTH FROM ordered_at) AS mo,
       SUM(total_amount) AS revenue
FROM orders
WHERE status <> 'cancelled'
GROUP BY 1, 2
ORDER BY 1, 2;

-- labels from text
SELECT UPPER(name) || ' — ' || city AS badge FROM users;
SELECT name, SUBSTRING(name, 1, 5) AS short_name FROM products;
```

## Practice

[Beginner] **P1.** Orders ordered between 2025-02-01 and 2025-04-30 (inclusive) — id, total, date.
[Beginner] **P2.** Users who joined more than a year before today... (data is 2024 — use `WHERE joined_at < CURRENT_DATE - 400`). Adjust and explain why you adjusted.
[Beginner] **P3.** Product names in all-caps (just name).
[Intermediate] **P4.** Revenue per month for **delivered** orders (the pattern above — type it yourself).
[Intermediate] **P5.** Orders in the last 90 days of the data's range: use `SELECT MAX(ordered_at) FROM orders` as a scalar subquery in your WHERE — "recent relative to the data, not the clock".
[Intermediate] **P6. Predict first:** output of

```sql
SELECT UPPER(SUBSTRING('database', 1, 4)) || '!';
```

Then run it. Also predict `SELECT DATE '2025-01-10' + 25;`
[Intermediate] **P7. From memory:** user emails that end with `'@example.com'` — then the same but with the domain stripped (`REPLACE` or `SPLIT_PART`... stick to what you know: `REPLACE(email, '@example.com', '')`).
[Advanced] **P8.** "Users joined per year" — GROUP BY EXTRACT(YEAR FROM joined_at), ordered chronologically. Predict counts first.
[Advanced] **P9.** Review activity by weekday hint: `EXTRACT(DOW FROM created_at)` (0=Sunday). Which weekday had the most reviews in this data?

## Debugging

```sql
-- Bug 1: what type error, and why?
SELECT name FROM users WHERE joined_at > '2024';

-- Bug 2 (logical): meant "2025 orders" — what does this catch instead?
SELECT id FROM orders WHERE ordered_at = '2025-01-10';

-- Bug 3 (string vs number): what's wrong?
SELECT name FROM products WHERE LENGTH(price) > 4;
```

## Combine Concepts

The monthly retention report: **month, users who ordered that month, revenue** — GROUP BY month with COUNT(DISTINCT user_id) + SUM, excluding cancelled, ordered chronologically. Dates + GROUP BY + join-free multi-aggregate. Predict January's numbers before running.

## Previous Knowledge

1. Window vs GROUP BY — output rows?
2. Write from memory: top 3 tasks per project (the CTE + row_number pattern).
3. What does PARTITION BY do?
4. Correlated subquery — what makes it correlated?

## Recall

1. What's the pattern for "revenue per month"? (The three steps.)
2. What does EXTRACT return — a date or a number?
3. `||` does what? In what don't you use `+` for strings?
4. Why is `WHERE date = '2025-01-10'` usually a bug?

## Interview Questions

1. "How would you compute monthly revenue in SQL?"
2. "How do you filter 'last 30 days'?"
3. "Case sensitivity in searches — how do you handle it?" *(UPPER/LOWER or ILIKE.)*

## Completion Checklist

- [ ] Understand date comparisons, EXTRACT, intervals, string functions
- [ ] Completed P1–P9 (P6 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Can write the monthly-revenue pattern from memory
