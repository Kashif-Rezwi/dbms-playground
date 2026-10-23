# Day 03 — WHERE: Filtering Rows

**Track:** SQL · **Stage:** 1 — Foundation · **Difficulty:** Beginner
**Prerequisites:** Days 01–02 · **Dataset:** `ecommerce`

## Goal

Filter rows with comparison and logical operators, and understand how NULL behaves in conditions.

## Fundamentals

`WHERE` filters **rows** (SELECT chooses **columns**, WHERE chooses **rows**). For each row, the condition is evaluated: true → the row appears; false or unknown → it's gone.

```sql
SELECT name, price FROM products WHERE price > 3000;
```

**Comparison operators:** `=`, `<>` (or `!=`), `>`, `<`, `>=`, `<=`.

**Logical operators combine conditions:**

```sql
WHERE price > 2000 AND stock > 0      -- both must be true
WHERE city = 'Karachi' OR city = 'Lahore'   -- either
WHERE NOT is_active                    -- negation
```

**The NULL trap — memorize this:** NULL means "unknown". Any comparison with NULL is *unknown*, not true — so `city = NULL` and even `NULL = NULL` are never true. Test NULL with `IS NULL` / `IS NOT NULL`:

```sql
SELECT * FROM users WHERE bio IS NULL;   --
SELECT * FROM users WHERE bio = NULL;    -- returns zero rows, silently!
```

## Why It Matters

Real queries are almost never "give me everything". They're "give me *these* rows": this user's orders, in-stock products, active accounts. WHERE is the most-used clause in SQL.

## Mental Model

> WHERE is a **bouncer with a clipboard**: every row lines up, the bouncer checks the condition, only rows that pass get into the result. NULL means the row *forgot its ID* — it can't pass even the "let everyone named NULL in" check. There's a special door: `IS NULL`.

## Examples

```sql
-- comparison
SELECT name FROM products WHERE price >= 5000;

-- AND
SELECT name, price, stock FROM products WHERE price > 2000 AND stock > 0;

-- OR
SELECT name, city FROM users WHERE city = 'Karachi' OR city = 'Lahore';

-- NOT + boolean column
SELECT name FROM users WHERE NOT is_active;

-- NULL handling
SELECT name FROM users WHERE bio IS NULL;
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Products with `stock = 0` (display `name` and `stock`).

[Beginner] **W2.** Inactive users from the `users` table — display `name` and `city` (revisiting Day 2's column selection).

### 🔵 Core

[Intermediate] **C1.** Products that cost more than 2000 **and** are in category 5 (Sports). Display `name`, `price`, and `category_id`.

[Intermediate] **C2.** `[Predict]` Write down exactly how many rows this returns *before* running:

```sql
SELECT name FROM users WHERE is_active = TRUE AND city = 'Karachi';
```

[Intermediate] **C3.** `[From Memory]` Retrieve products in category 3 (Books) with `stock > 10` without consulting notes.

[Intermediate] **C4.** Users whose city is Karachi, Lahore, **or** Multan, and who are inactive. Then write the opposite query (same cities, active users) and compare row counts.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Each of these queries contains a classic WHERE clause bug. Diagnose what is wrong, explain why, fix it, and verify the result:

```sql
-- Bug A (logical conflict: a single column cannot hold two values simultaneously)
SELECT name FROM users WHERE city = 'Karachi' AND city = 'Lahore';

-- Bug B (the NULL trap: comparisons with NULL evaluate to UNKNOWN)
SELECT name FROM users WHERE bio = NULL;
```

[Advanced] **H2.** Combine Day 2's computed expressions with today's filtering: write a query for products whose computed stock value (`price * stock`) exceeds 50,000. Display `name`, `price`, `stock`, and the computed `stock_value`.

## Interview Questions

1. "How would you filter rows matching multiple conditions?"
2. "How do you check for NULL values, and why doesn't `= NULL` work?" *(A top-5 beginner interview trap.)*
3. "What's the logical difference between these two: `A AND B` vs `A OR B`?"

## Completion Checklist

- [ ] Understand WHERE, operators, NULL behavior
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Can explain the NULL trap out loud
