# Day 12 — LEFT / RIGHT / FULL JOIN: Keeping the Unmatched

**Track:** SQL · **Stage:** 3 — Relationships · **Difficulty:** Intermediate
**Prerequisites:** Day 11 · **Dataset:** `ecommerce` (reset first)

## Goal

Use outer joins to keep rows that have no match — and unlock the classic "find rows that DON'T have X" pattern.

## Fundamentals

INNER JOIN keeps only matches. **Outer joins keep the unmatched side too**, filling missing columns with NULL:

- **LEFT JOIN** — *every* row from the left table; missing right side → NULLs
- **RIGHT JOIN** — mirror image (every right row kept)
- **FULL JOIN** — every row from both sides; unmatched on either side → NULLs

```sql
SELECT u.name, o.id AS order_id
FROM users u
LEFT JOIN orders o ON o.user_id = u.id;
```

Users with no orders still appear — with `order_id = NULL`.

** The most important pattern of the day** — "users with no orders":

```sql
SELECT u.name
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.id IS NULL;               -- the join found NOTHING for this user
```

How it works: the LEFT JOIN kept everyone; those with no order got NULL; `WHERE o.id IS NULL` keeps exactly the unmatched. (This pattern replaces the `NOT IN` NULL-trap from Day 8 — it's the safe, idiomatic way.)

**RIGHT/FULL in practice:** RIGHT JOIN is rare (rewritable as LEFT by swapping tables); FULL is mostly for data-repair jobs ("show everything from both copies").

## Why It Matters

"Which customers never bought?", "products never ordered", "users without a profile" — the "missing relationship" question is everywhere, in interviews and in real apps.

## Mental Model

> INNER JOIN is a **strict matchmaker** (only couples leave together). LEFT JOIN is a **kind matchmaker**: everyone on the left gets a partner *or* a "no partner" (NULL) tag. The `IS NULL` check finds the lonely hearts.

## Examples

```sql
-- all users and their orders (users may appear many times, or with NULL)
SELECT u.name, o.id AS order_id, o.status
FROM users u LEFT JOIN orders o ON o.user_id = u.id
ORDER BY u.name, o.id;

-- users who have NEVER ordered
SELECT u.name
FROM users u LEFT JOIN orders o ON o.user_id = u.id
WHERE o.id IS NULL;

-- products never bought
SELECT p.name
FROM products p LEFT JOIN order_items oi ON oi.product_id = p.id
WHERE oi.id IS NULL;

-- FULL: everything from payments and orders, matched or not
SELECT o.id AS order_id, pay.id AS payment_id
FROM orders o FULL JOIN payments pay ON pay.order_id = o.id;
```

## Practice

[Beginner] **P1.** Every user with their order count — **including users with zero orders**. (`COUNT(o.id)`, not `COUNT(*)` — why?)
[Beginner] **P2.** Every user with order ids; users without orders appear once. (This is P1's little sibling.)
[Beginner] **P3.** Users who have never written a review. LEFT JOIN pattern.
[Intermediate] **P4.** Products never ordered — with their category_id and price.
[Intermediate] **P5.** Categories that have **no products** in them. (Careful: which side is categories?)
[Intermediate] **P6. Predict first** — exact rows:

```sql
SELECT u.name, o.id AS order_id
FROM users u LEFT JOIN orders o ON o.user_id = u.id AND o.status = 'delivered'
ORDER BY u.name;
```

*(Tricky! A join condition can carry extra terms. Which users' rows have NULL? Note: users 5 and 9 have delivered orders... check the data first, predict, run.)*
[Intermediate] **P7. From memory:** reviews with product names (every review, even if... there's a subtlety — which join type and why?).
[Advanced] **P8.** Orders with **no payment** (pending or cancelled but unpaid — but be careful: one delivered order also has no payment? Check with data). Show order id + status.
[Advanced] **P9.** Users whose **only** orders are cancelled (they ordered, but nothing ever shipped/delivered). Hard! Hint: LEFT JOIN with condition `status <> 'cancelled'`, then `IS NULL`... on what?

## Debugging

```sql
-- Bug 1: meant "users without orders" — why does this return nobody... ever?
SELECT u.name
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.id IS NOT NULL;

-- Bug 2 (the COUNT trap): user 4 has no orders. Does this list show them?
SELECT u.name, COUNT(*) AS n
FROM users u LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.name ORDER BY n;

-- Bug 3 (wrong side): "categories with no products" attempted. What's wrong?
SELECT c.name
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE c.id IS NULL;
```

## Combine Concepts

The retention report: **users who joined in 2024, have never ordered, and are active** — name, city, joined_at. LEFT JOIN + IS NULL + WHERE (two conditions) + ORDER BY join date. Predict the count first.

## Previous Knowledge

1. What does ON do in a JOIN?
2. What happens to unmatched rows in INNER JOIN?
3. Write from memory: posts per username, top 3 busiest.
4. What was the NOT IN NULL trap?

## Recall

1. LEFT vs INNER: what's the difference in output for a user with no orders?
2. How do you find "rows with no match"? (The full pattern, from memory.)
3. Why must you count `COUNT(o.id)` and not `COUNT(*)` in a LEFT JOIN?
4. When is FULL JOIN actually useful?

## Interview Questions

1. "Explain LEFT JOIN vs INNER JOIN with a concrete example."
2. "How do you find customers who have never placed an order?" *(Memorize the pattern — it's asked constantly.)*
3. "Why might `COUNT(*)` after a LEFT JOIN give a wrong-looking count?"

## Completion Checklist

- [ ] Understand LEFT/RIGHT/FULL joins + IS NULL pattern
- [ ] Completed P1–P9 (P6 predicted first)
- [ ] Fixed all three bugs (Bug 2 is a famous trap)
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Can explain outer joins + the no-match pattern out loud
