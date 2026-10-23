# Day 01 — What Is a Database? Tables, Rows, Columns

**Track:** SQL · **Stage:** 1 — Foundation · **Difficulty:** Beginner
**Prerequisites:** None · **Dataset:** `ecommerce` (load it: `./scripts/seed/seed-postgres.sh ecommerce`)

## Goal

Understand what a database *is*, what a DBMS does, and what tables/rows/columns are — by looking at real ones.

## Fundamentals

**A database is an organized, persistent collection of data.** A program (like your editor) loses its data when it stops; a database keeps it. *Organized* means the data has structure the database can enforce and query efficiently.

**A DBMS (Database Management System)** is the software managing that data — PostgreSQL, MySQL, MongoDB. It gives you three things plain files can't:

1. **Safe simultaneous access** — hundreds of readers/writers at once, without corrupting data
2. **Fast querying** — find 3 rows out of 50,000,000 quickly
3. **Enforced rules** — "every order must belong to a real user" is *guaranteed*, not hoped for

**A table** is a grid of rows and columns — like a spreadsheet tab, but strict: every row has the *same columns*, and each column has a *type* and *rules* that the DBMS enforces.

```text
Table: users
┌────┬──────────────┬────────────────────┬──────────┐
│ id │ name         │ email              │ city     │  ← columns (properties)
├────┼──────────────┼────────────────────┼──────────┤
│ 1  │ Ayesha Khan  │ ayesha@example.com │ Karachi  │  ← row (one user)
│ 2  │ Bilal Ahmed  │ bilal@example.com  │ Lahore   │  ← row
└────┴──────────────┴────────────────────┴──────────┘
```

## Why It Matters

Why not just use a file (JSON/CSV)? Because the moment two things read/write the same data at once, files break. A DBMS exists to make shared, durable, structured data *safe and fast*. Nearly every real app you build will have a database behind it.

## Mental Model

> A database is a **library** (organized, persistent, has rules); a DBMS is the **librarian** (finds things fast, enforces the rules, lets many people in at once). SQL is the *language you use to talk to the librarian*.

## Core Concepts

- **Database** — organized, persistent data
- **DBMS** — software managing the data (PostgreSQL)
- **Table** — grid of rows + columns
- **Row** — one item (one user, one order)
- **Column** — one property of every row, with a type
- **Query** — a request for data, written in SQL

## Examples

Connect and look around. In your terminal:

```bash
psql -d ecommerce
```

Inside `psql`, run each of these and *observe*:

```sql
\dt                        -- list tables (meta-command: backslash, not SQL)
\d users                   -- describe the users table: columns + types + rules
SELECT * FROM users;       -- your very first query: show every row and column
SELECT name, city FROM users;  -- show only these two columns
```

Notice: `users` has a rule (`email` is UNIQUE) and a type on every column. The DBMS *enforces* these — you'll test that soon.

## Practice

### 🟢 Warm Up

[Beginner] **W1.** List all tables. Then describe `orders`, `products`, and `reviews` (`\d orders`). For each, write down: how many columns, and what types you see (`int`, `text`, `numeric`, `date`, `bool`).

[Beginner] **W2.** Look at `shared/datasets/ecommerce.sql` (the seed file). Match each `CREATE TABLE` to what `\d` showed you.

### 🔵 Core

[Intermediate] **C1.** Open `shared/diagrams/ecommerce-er.md` and find the arrows. Each arrow reads "*one* → *many*": one user has many orders. Say out loud what these mean: users→orders, orders→order_items, products→order_items.

[Intermediate] **C2.** `[Predict]` (write your answer, *then* run it):

```sql
SELECT * FROM categories;
```

How many rows? What columns? (Hint: check the seed file.)

[Intermediate] **C3.** Compare `SELECT * FROM users;` with `SELECT name, city FROM users;`. In one sentence: what did `*` do?

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` This query fails. Run it and read the error carefully:

```sql
SELECT * FROM user;
```

**Questions:** What exactly does the error say? What is wrong? What are the two ways to fix it? *(Check `\dt` — is there a table called `user`?)*

[Advanced] **H2.** Not much to combine yet — instead, do this: using `\d` and the ER diagram, trace the path from an `order` to a `user` to a `city`. Which column connects `orders` to `users`? Write your answer as a sentence.

## Interview Questions

1. "What is a DBMS and why do we need one?" *(Expect follow-up: why not files?)*
2. "Explain tables, rows, and columns like I've never seen a database."
3. "What does it mean that a schema is *enforced* by the database?"

## Completion Checklist

- [ ] Understand concept: database, DBMS, table, row, column
- [ ] Ran all examples, described 3+ tables with `\d`
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Can explain "database vs DBMS vs SQL" out loud
