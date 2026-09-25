# Day 05 — INSERT: Creating Data

**Track:** SQL · **Stage:** 1 — Foundation · **Difficulty:** 🟢 Beginner
**Prerequisites:** Days 01–04 · **Dataset:** `ecommerce` · **Milestone:** 🏗️ Project 1

## 🎯 Goal

Add rows to tables — single, multiple, with explicit columns — and understand why listing columns is non-negotiable.

## 🧠 Fundamentals

`INSERT` creates rows:

```sql
INSERT INTO users (name, email, city, is_active, joined_at)
VALUES ('Kamran Iqbal', 'kamran@example.com', 'Faisalabad', TRUE, '2025-01-10');
```

Read it as: *"into these columns, put these values, in this order."*

**Two rules that matter forever:**

1. **Always list your columns.** `INSERT INTO users VALUES (...)` works but shatters the moment the table gains a column. It's a landmine.
2. **Unlisted columns get their DEFAULT** (or NULL if none). The `id` was auto-filled? No — in this dataset you *must* supply it (real auto-numbering arrives in the PostgreSQL track Day 5).

**Multi-row insert** — one statement, many tuples:

```sql
INSERT INTO products (id, name, category_id, price, stock, created_at) VALUES
    (17, 'Desk Lamp',        1, 3200.00, 40, '2025-01-02'),
    (18, 'Notebook Pack',    3,  899.00, 90, '2025-01-03');
```

**Verification habit:** after every INSERT, `SELECT` the rows back. Trust, but verify.

## 🔍 Why It Matters

INSERT is the C of CRUD. Every signup, every order, every message lands in a database via an INSERT.

## 💡 Mental Model

> INSERT fills out a blank form (a new row). Listing columns is labeling each blank. If you skip a blank, the database writes its default answer — or leaves it NULL.

## 💻 Examples

```sql
-- one row
INSERT INTO categories (id, name) VALUES (9, 'Pet Supplies');

-- multiple rows
INSERT INTO categories (id, name) VALUES
    (10, 'Automotive'),
    (11, 'Garden');

-- verify
SELECT * FROM categories ORDER BY id;
```

## 🛠️ Practice

🟢 **P1.** Insert yourself as a user (invent an id — pick 101 so future answers line up; email must be unique).
🟢 **P2.** Insert two more users of your choosing.
🟢 **P3.** Insert a product into category 9 (Pet Supplies) — your choice of name/price/stock/id.
🟢 **P4.** Verify all three inserts with SELECTs.
🟡 **P5. ⭐ Predict first:** what exactly happens?

```sql
INSERT INTO users (name, email, city) VALUES ('NoID Person', 'noid@example.com', 'Quetta');
```

Write your prediction, run it, read the *whole* error message, explain what rule fired.

🟡 **P6.** Insert an order for your user (status `'pending'`, ordered today — use `CURRENT_DATE`). Now *update your prediction skills*: before verifying, what columns did you not provide, and what are they now?

🟡 **P7. From memory:** insert a review for the product you created in P3, written by your user, rating 4.
🔴 **P8.** Insert a product that violates a constraint on purpose (e.g., negative price). Read the error. Which constraint name appears? Now write one sentence explaining what a CHECK constraint does.

## 🐛 Debugging

```sql
-- Bug 1 (syntax: wrong keyword order)
INSERT INTO users (name, email) VALUES ('A', 'a@x.com') INTO users;

-- Bug 2 (logical: works... until it corrupts meaning)
INSERT INTO users VALUES (200, 'Mixed Up', 'mixed@example.com', 'Peshawar', TRUE, '2025-02-02');
-- The intent: the person's name is 'Mixed Up', city 'Peshawar'.
-- Check \d users. Are the values in the right columns?

-- Bug 3 (constraint violation)
INSERT INTO users (id, name, email, city, is_active, joined_at)
VALUES (1, 'Duplicate ID', 'dupe@example.com', 'Sialkot', TRUE, '2025-02-02');
```

## 🧩 Combine Concepts

Full mini-flow: **insert** a new user, **verify** with a filtered SELECT (WHERE email = yours), then show **only** the users who joined in 2025, **sorted** newest first, **top 3**. (INSERT + SELECT + WHERE + ORDER BY + LIMIT in one chain.)

## 🔁 Previous Knowledge

1. Predict-before-run: what does `SELECT DISTINCT status FROM orders` return?
2. Write from memory: top 2 priciest in-stock products.
3. What's the NULL trap in WHERE?
4. Does ORDER BY change the table? Does INSERT?

## 🧠 Recall

1. Why must you always list columns in an INSERT?
2. What happens to columns you don't list?
3. How do you insert 5 rows in one statement?
4. What did you do after every insert, and why?

## 🎤 Interview Questions

1. "What's the difference between listing columns and not listing them in an INSERT?"
2. "How do you insert multiple rows efficiently?" *(One statement, many VALUES tuples.)*
3. "What happens if an INSERT violates a primary key or unique constraint?"

## 🏗️ Mini Project — 🎉 You've finished Stage 1!

Build **[P1: Task Manager Database](../projects/01-task-manager.md)** — create a task table, insert tasks, and read them back with filters and sorting. Attempt it before opening `solutions/`.

## ✅ Completion Checklist

- [ ] Understand INSERT, column lists, defaults, multi-row
- [ ] Completed P1–P8
- [ ] Fixed all three bugs
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Started Project 1
