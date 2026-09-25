# Day 06 — UPDATE & DELETE

**Track:** SQL · **Stage:** 2 — CRUD + Querying · **Difficulty:** 🟢 Beginner
**Prerequisites:** Days 01–05 · **Dataset:** `ecommerce` (reset it first if you mutated it yesterday)

## 🎯 Goal

Modify and remove rows safely — and build the reflex of testing WHERE clauses *before* dangerous writes.

## 🧠 Fundamentals

**UPDATE** changes existing rows:

```sql
UPDATE products SET price = 1999.00 WHERE id = 4;
```

Read as: *"for rows where id = 4, set price to 1999."* You can update several columns at once (`SET a = 1, b = 2`) and use the current value (`SET stock = stock - 1`).

**DELETE** removes rows:

```sql
DELETE FROM reviews WHERE id = 12;
```

**⚠️ The most important habit of this whole track:**

> **An UPDATE or DELETE without WHERE affects EVERY ROW.**

```sql
DELETE FROM reviews;         -- the table is now empty. All of it.
UPDATE users SET is_active = TRUE;   -- every user updated.
```

There is no undo (unless inside a transaction — Day 21). Before running any write, **SELECT with the same WHERE first** to preview the blast radius:

```sql
SELECT id FROM reviews WHERE rating = 5;    -- what will be deleted?
DELETE FROM reviews WHERE rating = 5;       -- now you know
```

**RETURNING** (PostgreSQL) shows what changed: `UPDATE ... WHERE id = 4 RETURNING *;`

## 🔍 Why It Matters

The U and D of CRUD — and the #1 source of real-world "I deleted production" horror stories. Learn the safety habits now, not after an incident.

## 💡 Mental Model

> UPDATE is a **find-and-replace across the table**, and DELETE is a **paper shredder**. WHERE is the *scope selector*. No scope = whole table. Always ask: "what's my WHERE, and what does it match?"

## 💻 Examples

```sql
-- preview first!
SELECT * FROM products WHERE stock = 0;

-- restock all out-of-stock products
UPDATE products SET stock = 10 WHERE stock = 0;

-- price rise on one product, verify with RETURNING
UPDATE products SET price = price * 1.10 WHERE id = 2 RETURNING name, price;

-- delete pending orders older than 90 days (preview first)
SELECT id FROM orders WHERE status = 'pending';
DELETE FROM orders WHERE status = 'pending';
```

## 🛠️ Practice

🟢 **P1.** Set `is_active` to TRUE for user id 8. Verify.
🟢 **P2.** Raise the price of every product in category 1 (Electronics) by 5% (`price * 1.05`). Preview the affected rows *first*, then update, then verify.
🟢 **P3.** Reduce stock of product 7 by 1 (as if one sold). One statement, using the old value.
🟢 **P4.** Delete any user you created on Day 5 — *but preview first*. What happens if that user has orders? Read the error: that's a **foreign key violation**, the DB protecting you.
🟡 **P5. ⭐ Predict first:** exactly how many rows change?

```sql
UPDATE users SET is_active = TRUE WHERE is_active = FALSE;
```

🟡 **P6.** Mark order 8 (pending) as `'shipped'`, setting its `ordered_at` to today — two columns, one statement.
🟡 **P7. From memory:** delete all reviews with rating 1 (none exist — predict the count first).
🔴 **P8.** "Soft delete" pattern: instead of `DELETE`ing reviews with rating ≤ 2, *keep* them but... invent a way to mark them as hidden without adding a column. (Hint: a comment can be changed.) Explain when soft deletes beat hard deletes.

## 🐛 Debugging

```sql
-- Bug 1 (catastrophic-by-design — run in a scratch table you create for safety)
CREATE TABLE practice_users AS SELECT * FROM users;   -- your sandbox copy
UPDATE practice_users SET is_active = FALSE;
SELECT COUNT(*) FILTER (WHERE is_active) FROM practice_users;  -- ?
```

What did the missing WHERE do? Say it out loud. (This is why we practiced on a *copy*.)

```sql
-- Bug 2 (logical): meant to update product 4, touched what instead?
UPDATE products SET stock = 0 WHERE category_id = 4;

-- Bug 3 (syntax)
UPDATE products SET price = 100 WHERE id = 1 AND;
```

## 🧩 Combine Concepts

The Day 5 mini-flow, reversed: **update** all inactive users to active (preview → update → verify), then **list** active Karachi users sorted by join date, **top 3**. One workflow, four concepts.

## 🔁 Previous Knowledge

1. What happens to unlisted columns in an INSERT?
2. Write from memory: insert a category `(99, 'Testing')`. Then delete it. Safely.
3. What does `SELECT DISTINCT status FROM orders` return?
4. Why is `SELECT *` risky in code?

## 🧠 Recall

1. What does an UPDATE without WHERE do? A DELETE without WHERE?
2. What safety check do you run before every write?
3. What does `SET stock = stock - 1` do that `SET stock = 99` doesn't?
4. What stopped you from deleting a user with orders — and what is that mechanism called?

## 🎤 Interview Questions

1. "How do you prevent accidental full-table updates or deletes?"
2. "What's a soft delete and why do products prefer it to DELETE?"
3. "You ran `UPDATE` on the wrong rows in production. What do you wish you had done?" *(Transactions — or a backup + preview SELECT.)*

## ✅ Completion Checklist

- [ ] Understand UPDATE, DELETE, WHERE scoping
- [ ] Previewed before EVERY write
- [ ] Completed P1–P8
- [ ] Fixed all three bugs (on the sandbox copy!)
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Can explain the no-WHERE danger out loud
