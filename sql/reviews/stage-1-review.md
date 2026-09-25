# Stage Review 1 — Foundations & Querying (SQL Days 1–10)

Do this *after* Day 10, before starting Day 11. No notes until the answers are written.

## Part A — Concept Check (write, then verify)

1. Table vs row vs column — with an example from `users`.
2. What's the NULL trap, and the two operators that never fall into it?
3. WHERE vs HAVING — what does each filter, in what order?
4. COUNT(*) vs COUNT(col) — and what does AVG do with NULLs?
5. What's the execution order of: FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY, LIMIT?
6. What's the "users with no orders" pattern — and why is `NOT IN` riskier?

## Part B — Query Drills (dataset: `ecommerce`, reset first)

[Beginner] 1. Name and price of the 5 cheapest in-stock products.
[Beginner] 2. Insert a user (id 102) and verify by email.
[Beginner] 3. Unique cities among active users, alphabetical.
[Beginner] 4. Count of delivered orders and their total revenue — one query.
[Intermediate] 5. Products priced between 1000 and 5000, in Books or Sports (IN), sorted by price.
[Intermediate] 6. Users with no reviews (two ways — LEFT JOIN and NOT IN).
[Intermediate] 7. Reviews per rating value (1–5), with the count of *comments* too — notice which count skips NULLs.
[Intermediate] 8. Each inactive user's name with COALESCE'd city (`'Unknown'` when NULL).
[Intermediate] 9. Orders in the last 3 months of data (scalar-subquery trick: `MAX(ordered_at) - 90`).
[Advanced] 10. Categories whose delivered revenue exceeds the overall average category revenue (CTE + HAVING + subquery).
[Advanced] 11. The "predict-first" finale — write your prediction for the row count, then run:

```sql
SELECT city, COUNT(*) FROM users
WHERE is_active AND id IN (SELECT user_id FROM orders WHERE status <> 'cancelled')
GROUP BY city
HAVING COUNT(*) > 0
ORDER BY 2 DESC;
```

## Part C — Debugging Gauntlet

```sql
-- A: silent emptiness
SELECT * FROM products WHERE stock = NULL;
-- B: wrong count, off by one user
SELECT u.name, COUNT(*) AS reviews
FROM users u LEFT JOIN reviews r ON r.user_id = u.id
GROUP BY u.name;
-- C: works, but why does the update miss rows?
UPDATE users SET is_active = FALSE WHERE joined_at < '2024-06-01' AND is_active = TRUE;
```

## Part D — Mini Interview (out loud)

1. "Explain WHERE vs HAVING."
2. "How do you find rows with no match in another table?"
3. "What does DISTINCT actually deduplicate — the whole row or one column?"

**Shaky on anything?** Re-do that day's recall tomorrow morning before Day 11. That's the spaced-repetition system working, not a setback.
