# Day 14 — Subqueries & Correlated Subqueries

**Track:** SQL · **Stage:** 3 — Relationships · **Difficulty:** Intermediate → Advanced
**Prerequisites:** Days 01–13 · **Dataset:** `ecommerce` · **Milestone:** Project 3

## Goal

Run queries inside queries: scalar subqueries, `IN (subquery)`, and correlated subqueries — and know when a subquery beats a join.

## Fundamentals

A **subquery** is a query nested inside another. Three flavors by *what it returns*:

**1. Scalar** (one value) — usable anywhere a value fits:

```sql
SELECT name, price,
       price - (SELECT AVG(price) FROM products) AS vs_average
FROM products;
```

**2. List** (one column, many rows) — feeds `IN` / `NOT IN`:

```sql
SELECT name FROM users
WHERE id IN (SELECT user_id FROM orders WHERE status = 'delivered');
```

**3. Table** (rows & columns) — feeds FROM (Day 15 does this properly).

**Correlated subquery** — the inner query *references the outer row*, so it logically re-runs per row:

```sql
SELECT p.name, p.price
FROM products p
WHERE p.price > (SELECT AVG(p2.price) FROM products p2
                 WHERE p2.category_id = p.category_id);   -- avg of MY category
```

`> ALL (subquery)` = "greater than every value in the list"; `> ANY` = "greater than at least one".

**Subquery vs join:** "users who ordered" works both ways:

```sql
-- join + DISTINCT, or:
SELECT DISTINCT u.name FROM users u JOIN orders o ON o.user_id = u.id;
-- subquery:
SELECT name FROM users WHERE id IN (SELECT user_id FROM orders);
```

Rule of thumb: need *columns* from the other table → JOIN. Only need a *test* ("has ordered" / "costs more than average") → subquery is often clearer.

## Why It Matters

Some questions are naturally nested: "above average", "more than the company-wide max", "in the set of X". Subqueries keep complex logic readable without flattening it into a mega-join.

## Mental Model

> A subquery is a **question inside a question**. An uncorrelated one answers first, once, and hands the answer up. A correlated one is asked *fresh for every row* — "compared to *your* department, how are you doing?"
>
> The cost version: a correlated subquery is a **librarian running to the shelves once per row** — powerful, but notice the running.

## Examples

```sql
-- scalar: products vs the catalog average
SELECT name, price,
       ROUND(price - (SELECT AVG(price) FROM products), 2) AS vs_avg
FROM products ORDER BY price DESC;

-- list: users who have written a review
SELECT name FROM users
WHERE id IN (SELECT user_id FROM reviews);

-- correlated: products priced above their own category's average
SELECT p.name, p.price, p.category_id
FROM products p
WHERE p.price > (SELECT AVG(p2.price) FROM products p2
                 WHERE p2.category_id = p.category_id);
```

## Practice

[Beginner] **P1.** Products priced above the overall average (scalar subquery).
[Beginner] **P2.** Users who have cancelled at least one order (list subquery).
[Beginner] **P3.** Categories whose average price is above the overall average — grouped query *inside* a comparison. Predict which categories before running.
[Intermediate] **P4.** Products whose stock is above the average stock **of their own category** (correlated).
[Intermediate] **P5.** Orders whose total is greater than **every** cancelled order's total (`> ALL`).
[Intermediate] **P6. Predict first** — exact rows:

```sql
SELECT name FROM users
WHERE id IN (SELECT user_id FROM orders WHERE status = 'pending');
```

[Intermediate] **P7. From memory:** products cheaper than the Sports category's average price.
[Advanced] **P8.** Reviews whose rating is above the **average rating of the same product** (correlated, two tables). Predict roughly which reviews these would be.
[Advanced] **P9.** Rewrite Day 12's "users with no orders" using `NOT IN` instead of LEFT JOIN. Is `NOT IN` safe here? (`\d orders` — `user_id` is NOT NULL, so yes *here*. Say why it's safe, and when it wouldn't be.)

## Debugging

```sql
-- Bug 1: IN needs a column, the subquery returns a table
SELECT name FROM products
WHERE category_id IN (SELECT * FROM categories);

-- Bug 2 (logical): "products pricier than average" — average of WHAT exactly?
SELECT name FROM products
WHERE price > (SELECT AVG(price) FROM products WHERE category_id = 1);

-- Bug 3: what error and why? (What does the subquery return?)
SELECT name FROM users
WHERE joined_at > (SELECT ordered_at FROM orders);
```

## Combine Concepts

The pricing report: **name, price, category average, overall average** in one row — via a correlated subquery *in the SELECT list* (yes, subqueries can live there!). Then filter to products above their category average.

## Previous Knowledge

1. Write from memory: users who never wrote a review (LEFT JOIN way).
2. What's the NULL trap in NOT IN?
3. When do you need aliases in a join? (Two cases now.)
4. LEFT vs INNER JOIN — one sentence.

## Recall

1. What are the three subquery flavors by return type?
2. What makes a subquery *correlated* — and what does that cost?
3. `IN` vs JOIN: when would you prefer each?
4. What does `> ALL` mean? `> ANY`?

## Interview Questions

1. "What is a correlated subquery and how does it differ from a normal one?"
2. "When would you use a subquery instead of a JOIN?"
3. "Find employees earning above their department average — walk me through it." *(You did exactly this on products today.)*

## Mini Project — Stage 3 complete!

Build **[P3: Student Course System](../projects/03-student-courses.md)** — students, courses, enrollments; relationships + joins + subqueries, with design questions. Attempt before solutions.

## Completion Checklist

- [ ] Understand scalar/list/correlated subqueries
- [ ] Completed P1–P9 (P6 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Started Project 3

