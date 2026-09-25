# Day 10 — GROUP BY & HAVING

**Track:** SQL · **Stage:** 2 — CRUD + Querying · **Difficulty:** Intermediate
**Prerequisites:** Days 01–09 · **Dataset:** `ecommerce` · **Milestone:** Project 2

## Goal

Aggregate *per group* — the single most important analytical pattern in SQL — and filter groups with HAVING.

## Fundamentals

Day 9's problem: `SELECT name, MAX(price) FROM products;` fails because 16 names can't fit in one row. **GROUP BY solves it: partition rows into groups, then aggregate each group separately:**

```sql
SELECT category_id, COUNT(*) AS product_count
FROM products
GROUP BY category_id;
```

Read as: *"make one group per category_id; for each group, count its rows."* Output: one row **per group**.

**The rule that makes everything click:**

> Every column in your SELECT must be **either inside an aggregate or listed in GROUP BY.**

```sql
SELECT category_id, AVG(price)          -- grouped col + aggregate
FROM products GROUP BY category_id;

SELECT name, category_id, AVG(price)    -- name is neither grouped nor aggregated
FROM products GROUP BY category_id;
```

**WHERE vs HAVING — the two-stage filter:**

- **WHERE** filters *rows before grouping* ("ignore cancelled orders")
- **HAVING** filters *groups after grouping* ("keep only categories with 5+ products")

```sql
SELECT city, COUNT(*) AS n
FROM users
WHERE is_active                                  -- 1. keep active users
GROUP BY city                                    -- 2. one group per city
HAVING COUNT(*) >= 1                             -- 3. keep busy cities only
ORDER BY n DESC;                                 -- 4. biggest first
```

Full logical order of clauses: **FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT.**

## Why It Matters

"Revenue per month", "users per city", "orders per status", "average rating per product" — GROUP BY is *the* answer-machine for "per ___" questions. HAVING answers "which of those groups are interesting?"

## Mental Model

> GROUP BY is a **sorting office**: rows arrive, get sorted into labeled boxes (one per city/category), and each box gets stamped with its aggregates (COUNT/SUM/AVG...). WHERE happens *at the door* (some rows never get in). HAVING happens *after stamping* — boring boxes are thrown out.

## Examples

```sql
-- orders per status
SELECT status, COUNT(*) AS n FROM orders GROUP BY status;

-- revenue per status
SELECT status, SUM(total_amount) AS revenue FROM orders GROUP BY status;

-- products per category, busiest first
SELECT category_id, COUNT(*) AS n
FROM products GROUP BY category_id ORDER BY n DESC;

-- groups filtered AFTER aggregation
SELECT user_id, SUM(total_amount) AS spent
FROM orders WHERE status <> 'cancelled'
GROUP BY user_id
HAVING SUM(total_amount) > 5000;
```

## Practice

[Beginner] **P1.** Users per city (city, count), alphabetical by city.
[Beginner] **P2.** Products per category, most products first.
[Beginner] **P3.** Orders per status.
[Intermediate] **P4.** Revenue per **payment method** — but only delivered orders. (Two tables! But wait — payments is a separate table... you can do it purely on `payments` with a hint... no: payment.method + orders.status need a join. **Stretch goal** — skip if stuck, revisit Day 12. Instead do: revenue per method using just `payments`.)
[Intermediate] **P5.** Average rating per product (product_id, avg rounded), only products with at least 2 reviews.
[Intermediate] **P6. Predict first** — exactly which groups appear?

```sql
SELECT category_id, MAX(price) AS priciest
FROM products
WHERE stock > 0
GROUP BY category_id
HAVING MAX(price) > 5000;
```

[Intermediate] **P7. From memory:** total quantity sold per product_id from `order_items`, sorted best-seller first, top 5.
[Advanced] **P8.** Customers (user_id) whose **average** order value exceeds 3000, counting non-cancelled orders only. Two filters + one group + one having.
[Advanced] **P9.** Explain in one sentence why this fails, then fix it *two ways* (one fix: GROUP BY more; other fix: aggregate it):

```sql
SELECT status, ordered_at, COUNT(*) FROM orders GROUP BY status;
```

## Debugging

```sql
-- Bug 1
SELECT city, COUNT(*) FROM users;

-- Bug 2 (logical): "cities with more than 1 user" — wrong tool. What happens?
SELECT city, COUNT(*) AS n FROM users WHERE COUNT(*) > 1 GROUP BY city;

-- Bug 3 (logical): meant average price per category; got... what?
SELECT category_id, AVG(name) FROM products GROUP BY category_id;
```

## Combine Concepts

A real analytics sentence: **"Revenue per city, for cities whose total revenue exceeds 5000, excluding cancelled orders, biggest city first."** You need users→orders (two tables — hint: today, run it on `orders` grouped by `user_id` and map ids to cities by eye from a second query; Day 11 automates the join). Write both queries.

## Previous Knowledge

1. Write from memory: count of out-of-stock products.
2. What are `%` and `_` in LIKE? One example each.
3. What does BETWEEN do at its endpoints?
4. What does COALESCE do?

## Recall

1. What does GROUP BY do — describe the boxes.
2. WHERE vs HAVING: what does each filter, and in what order?
3. What's the rule for which columns can appear in SELECT alongside aggregates?
4. Full clause order: list all seven from memory.

## Interview Questions

1. "Explain GROUP BY and HAVING like to a junior dev."
2. "What's the difference between WHERE and HAVING?" *(Asked in nearly every SQL interview.)*
3. "How would you find the top 3 categories by product count?"

## Mini Project — Stage 2 complete!

Build **[P2: Library Analytics](../projects/02-library-analytics.md)** — a small book dataset plus a battery of grouping/revenue questions. Attempt before solutions.

## Completion Checklist

- [ ] Understand GROUP BY, HAVING, clause ordering
- [ ] Completed P1–P9 (P6 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Started Project 2
