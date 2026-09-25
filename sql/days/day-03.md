# Day 03 — WHERE: Filtering Rows

**Track:** SQL · **Stage:** 1 — Foundation · **Difficulty:** 🟢 Beginner
**Prerequisites:** Days 01–02 · **Dataset:** `ecommerce`

## 🎯 Goal

Filter rows with comparison and logical operators, and understand how NULL behaves in conditions.

## 🧠 Fundamentals

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
SELECT * FROM users WHERE bio IS NULL;   -- ✅
SELECT * FROM users WHERE bio = NULL;    -- ❌ returns zero rows, silently!
```

## 🔍 Why It Matters

Real queries are almost never "give me everything". They're "give me *these* rows": this user's orders, in-stock products, active accounts. WHERE is the most-used clause in SQL.

## 💡 Mental Model

> WHERE is a **bouncer with a clipboard**: every row lines up, the bouncer checks the condition, only rows that pass get into the result. NULL means the row *forgot its ID* — it can't pass even the "let everyone named NULL in" check. There's a special door: `IS NULL`.

## 💻 Examples

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

## 🛠️ Practice

🟢 **P1.** Products with `stock = 0` (name and stock only).
🟢 **P2.** Orders with status `'pending'` — all columns.
🟢 **P3.** Products priced **under 1000** (name, price).
🟢 **P4.** Users who are **inactive** (name).
🟡 **P5.** Products that cost more than 2000 **and** are in category 5 (Sports). Columns: name, price, category_id.
🟡 **P6.** Users from Karachi **or** Islamabad, who are active. (Two ways: OR and IN — IN arrives tomorrow, OR is enough today.)
🟡 **P7. ⭐ Predict first**: write down exactly how many rows this returns *before* running:

```sql
SELECT name FROM users WHERE is_active = TRUE AND city = 'Karachi';
```

🟡 **P8. From memory:** products in category 3 (Books) with stock greater than 10. No notes.
🔴 **P9.** Write a single query returning users whose city is Karachi, Lahore, **or** Multan, and who are inactive. Now write its opposite (same cities, active). Compare row counts.

## 🐛 Debugging

Each of these is broken. For each: what's wrong, why, fix, verify.

```sql
-- Bug 1 (syntax)
SELECT name FROM products WHERE price > 2000 AND;

-- Bug 2 (logical: runs fine, wrong meaning)
SELECT name FROM users WHERE city = 'Karachi' AND city = 'Lahore';

-- Bug 3 (silent zero rows)
SELECT name FROM users WHERE bio = NULL;
```

*(Bug 2 is the classic: a row can never have two values for one column — `OR` was meant.)*

## 🧩 Combine Concepts

Yesterday you computed `stock_value = price * stock`. Now write: **products whose stock value exceeds 50,000**, showing name, price, stock, and the computed stock value. (Filter on a computed column — WHERE can use expressions too.)

## 🔁 Previous Knowledge

1. What does `AS` do?
2. What are the two questions SELECT answers? Which clause answers "which rows"?
3. What does the ER diagram say about orders and users — one-to-what?
4. Write from memory: select name and email from users.

## 🧠 Recall

1. Which rows survive a WHERE clause?
2. Why does `= NULL` return nothing — even if NULLs exist?
3. Difference between `AND` and `OR` — with a one-row example.
4. What happens if you write `WHERE` twice in one query?

## 🎤 Interview Questions

1. "How would you filter rows matching multiple conditions?"
2. "How do you check for NULL values, and why doesn't `= NULL` work?" *(A top-5 beginner interview trap.)*
3. "What's the logical difference between these two: `A AND B` vs `A OR B`?"

## ✅ Completion Checklist

- [ ] Understand WHERE, operators, NULL behavior
- [ ] Completed P1–P9 (prediction written first for P7)
- [ ] Fixed and explained all three bugs
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Can explain the NULL trap out loud
