# Day 19 — Keys, Constraints & Schema Design

**Track:** SQL · **Stage:** 4 — Intermediate Querying · **Difficulty:** 🟡 Intermediate
**Prerequisites:** Days 01–18 · **Dataset:** `ecommerce` (reset first) · **Milestone:** 🏗️ Project 4

## 🎯 Goal

Understand keys and constraints as the database's *rule system*, and design a small schema yourself.

## 🧠 Fundamentals

**Keys:**

- **Primary key (PK)** — the identity of a row: unique, never NULL, one per table. `users.id`.
- **Foreign key (FK)** — a column referencing another table's PK. `orders.user_id → users.id`. The DBMS now *enforces* that every order points at a real user — this is **referential integrity**.
- **Composite key** — identity from 2+ columns together (`likes(user_id, post_id)`).
- **Surrogate vs natural key** — `id=1023` (made-up, stable, meaningless) vs `email` (real-world, but people change emails; real data is dirty). Modern practice: surrogate PKs.

**Constraints** — rules the DBMS enforces on every write:

```sql
CREATE TABLE reviews (
    id         INT PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id),
    user_id    INT NOT NULL REFERENCES users(id),
    rating     INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment    TEXT,
    UNIQUE (product_id, user_id)          -- one review per user per product
);
```

- `NOT NULL` — required
- `UNIQUE` — no duplicates (single column or combination)
- `CHECK` — custom rule; the write *fails* with an error if violated
- `DEFAULT` — auto-fill when omitted

**What a FK gives you** — try it and feel it:

```sql
INSERT INTO orders (id, user_id, status) VALUES (999, 12345, 'pending');
-- ERROR: user 12345 doesn't exist. The database REFUSED bad data.
```

**ON DELETE behavior** — what happens to children when a parent dies:

- `ON DELETE CASCADE` — children die too (delete user → their orders vanish)
- `ON DELETE RESTRICT` (default) — parent can't die while children exist
- `ON DELETE SET NULL` — children survive, orphaned (FK column must be nullable)

## 🔍 Why It Matters

Constraints are the difference between a "database" and "a folder of files someone might mess up". Every bug you *prevent* with a constraint is a bug that never reaches production, at 3 AM, on a Saturday.

## 💡 Mental Model

> A schema is a **form with validation**: PK = the ID stamp (one per form), FK = the "must reference an existing form" field, CHECK = the "must be a valid rating" box, UNIQUE = "you've already filled this in". The DBMS is a **bouncer who reads every form** — invalid forms are rejected, loudly, at the door.

## 💻 Examples

```sql
-- feel the enforcement (each should FAIL — read every error message):
INSERT INTO users (id, name, email) VALUES (1, 'Dupe ID', 'fresh@example.com');     -- PK clash
INSERT INTO users (id, name, email) VALUES (50, 'Dupe Email', 'ayesha@example.com'); -- UNIQUE clash
INSERT INTO products (id, name, category_id, price) VALUES (99, 'Bad Price', 1, -5); -- CHECK clash
INSERT INTO order_items (id, order_id, product_id, quantity, unit_price)
VALUES (99, 12345, 1, 1, 100);                                                       -- FK clash
```

## 🛠️ Practice

🟢 **P1.** Run all four failing examples. For each, name *which constraint* fired (the error message tells you).
🟢 **P2.** `\d orders` — list every constraint on that table and say what each protects.
🟡 **P3.** Try deleting user 1 (who has orders). What happens and why? What are your two options, and which is safer for an e-commerce DB?
🟡 **P4.** Design (write CREATE TABLE, don't run yet): a `wishlist` table — a user saves products. Columns? PK? What must be unique?
🟡 **P5.** Run your `wishlist` DDL. Insert: user 1 wishes products 2 and 3; user 2 wishes product 2. Then try user 1 wishes product 2 *again* — what fires?
🟡 **P6. ⭐ Predict first:** which constraint rejects each?

```sql
INSERT INTO reviews (id, product_id, user_id, rating) VALUES (99, 1, 1, 9);
INSERT INTO reviews (id, product_id, user_id, rating) VALUES (98, 1, 1, 4);
```

🔴 **P7.** `\d products` — there's no CHECK on stock! Add one: `ALTER TABLE products ADD CONSTRAINT positive_stock CHECK (stock >= 0);` then try `UPDATE products SET stock = -5 WHERE id = 1;`. Why do some tables have CHECKs and others not? (Inconsistent design — real life! Now you can spot it.)
🔴 **P8.** Design decision: should `orders.total_amount` have a `CHECK (total_amount >= 0)`? Could a cancelled order legitimately be zero? Argue both sides in two sentences, then implement your choice.

## 🐛 Debugging

```sql
-- Bug 1 (design): why can this table never be joined to orders?
CREATE TABLE orderz (order_id_num INT, total TEXT);

-- Bug 2 (design): what's the problem with email as the only key?
CREATE TABLE people (email TEXT PRIMARY KEY, name TEXT);
-- Hint: UPDATE people SET email = 'new@x.com' WHERE name = 'Ayesha'; -- what breaks, where?

-- Bug 3: what fires and why?
INSERT INTO order_items (id, order_id, product_id, quantity, unit_price)
VALUES (100, 1, 1, 0, 100);
```

## 🧩 Combine Concepts

Schema audit of `ecommerce`: (1) which columns are surrogate vs natural keys? (2) where could data still go wrong (hint: nothing enforces `orders.total_amount` = sum of its items!) (3) write the UPDATE that proves the drift, then describe the CHECK or trigger that would prevent it (triggers arrive in the PG track).

## 🔁 Previous Knowledge

1. Write from memory: cities with candidates but no companies (EXCEPT).
2. UNION vs UNION ALL — one line.
3. Revenue per month — the pattern from memory.
4. Top-3-per-group — the pattern from memory.

## 🧠 Recall

1. PK vs UNIQUE vs FK — one line each.
2. What is referential integrity, and what enforces it?
3. Three ON DELETE behaviors and when you'd choose each.
4. Surrogate vs natural keys — why do modern apps prefer surrogate?

## 🎤 Interview Questions

1. "Why enforce constraints in the database instead of application code?" *(Defense in depth; the DB is the last line — concurrency, multiple apps, human error.)*
2. "What's the point of a foreign key? What breaks without one?"
3. "When would you use ON DELETE CASCADE, and what are its risks?"

## 🏗️ Mini Project — Stage 4 complete!

Build **[P4: E-commerce Analytics](../projects/04-ecommerce-analytics.md)** — joins, aggregation, windows, dates over the shared dataset. Attempt before solutions.

## ✅ Completion Checklist

- [ ] Understand keys, constraints, ON DELETE options
- [ ] Completed P1–P8 (P6 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed combine task (schema audit)
- [ ] Answered recall without notes
- [ ] Started Project 4

