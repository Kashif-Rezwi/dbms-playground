# Day 02 — Databases, Schemas & the System Catalog

**Track:** PostgreSQL · **Stage:** 1 — Setup · **Difficulty:** Beginner → Intermediate

## Goal

Organize objects with databases and schemas, and read the system catalog — PostgreSQL describing *itself* in SQL.

## Fundamentals

**Databases** are isolation walls: no query crosses database boundaries (you disconnect and reconnect). Use one database per app/environment:

```sql
CREATE DATABASE bookstore;
DROP DATABASE bookstore;              -- nukes everything in it
ALTER DATABASE ecommerce RENAME TO shop;
```

**Schemas** are namespaces *inside* a database:

```sql
CREATE SCHEMA analytics;
CREATE TABLE analytics.daily_sales (day date, revenue numeric);
SELECT * FROM analytics.daily_sales;   -- schema-qualified name
SET search_path TO public, analytics; -- resolution order for unqualified names
```

Why schemas? Organization (`sales.orders` vs `analytics.orders`), **permissions** (grant on a schema, not 40 tables), and extensions. Real apps commonly do: `public` (app tables), `analytics` (reporting), `archive`.

**The system catalog** — PostgreSQL stores its own metadata in schemas you can query:

- `pg_database`, `pg_tables`, `pg_columns`-ish via `information_schema.columns`
- `information_schema.*` — the SQL-standard, portable views
- `pg_catalog` / `pg_*` — PostgreSQL's rich, native views

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' ORDER BY 1;

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'orders';

SELECT * FROM pg_stat_user_tables;      -- activity stats (Day 24-25 loves this)
```

**Naming with `psql`:** `public.orders` = the full name. `\dt` shows only `search_path` schemas — a "missing" table is usually a schema mix-up.

## Why It Matters

The catalog turns "how do I find out X about my database?" from a GUI question into a *query*. DBA tooling, migrations, and security work all read/write the catalog.

## Mental Model

> Databases are **buildings** (can't see one building's rooms from inside another). Schemas are **floors**. Tables are rooms. The catalog is the **building's own blueprint archive** — written in the same SQL you speak, so you can ask the building about itself.

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Create database `bookstore`; connect; create a `books` table; one insert; select. Now `\c ecommerce` and try selecting `books` — what error? Say why.

[Beginner] **W2.** Back in `bookstore`: `CREATE SCHEMA archive;` and move your books table there (`ALTER TABLE books SET SCHEMA archive;`). Where is it now? (Check `\dt` vs `\dt archive.*`.)

### 🔵 Core

[Intermediate] **C1.** `[Predict]` `\dt` output before vs after `SET search_path`. What changes and what doesn't?

[Intermediate] **C2.** `[From Memory]` the information_schema query to find all columns named `status` in the current database.

[Intermediate] **C3.** Catalog questions: (a) all tables with a `user_id` column across the `ecommerce` database; (b) all columns of `order_items` with types; (c) all NOT NULL columns of `orders`.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Bug 1: this works from the app but not psql. 
SELECT * FROM orders;   -- ERROR: relation "orders" does not exist
-- (search_path mystery: app sets its schema; psql defaults to public.)

-- Bug 2 (danger): DROP DATABASE ecommerce;  fails while connected. Why
-- would PostgreSQL refuse — and what's the correct sequence?

-- Bug 3 (design): someone put 200 reporting tables in public, next to the
-- app tables. What goes wrong over time, and what's the migration plan?
```

[Advanced] **H2.** Catalog + SQL: write "the FK report" — for every foreign key in `ecommerce` (use `information_schema.table_constraints` + `key_column_usage`... or simpler: `pg_constraint` via `SELECT conname, conrelid::regclass, confrelid::regclass FROM pg_constraint WHERE contype='f';`), produce child-table, parent-table pairs. Cross-check against `shared/diagrams/ecommerce-er.md`.

[Advanced] **H3.** One-line report per schema question, all via catalog: which table in `ecommerce` has the most columns? Which indexes exist on `orders` (hint: `pg_indexes`)? Which tables have zero rows (`pg_stat_user_tables.n_live_tup`)?

## Interview Questions

1. "When would you split work into schemas vs separate databases?"
2. "How can you discover a database's structure using only SQL?" *(The catalog — name views.)*
3. "What happens if two tables in different schemas have the same name?"

## Completion Checklist

- [ ] Understand databases, schemas, search_path, catalog
- [ ] Completed Warm Up, Core, and Challenge exercises
