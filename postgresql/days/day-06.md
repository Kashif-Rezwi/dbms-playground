# Day 06 — Foreign Keys & Relationships in PostgreSQL

**Track:** PostgreSQL · **Stage:** 2 — Modeling in PG · **Difficulty:** Beginner → Intermediate

## Goal

Use PostgreSQL's FK machinery precisely — including the DELETE/UPDATE behaviors — and feel referential integrity *enforced by the engine*.

## Fundamentals

You know FKs from SQL Day 19. Today: the full grammar and its consequences:

```sql
CREATE TABLE orders_pg (
    id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id  INT NOT NULL REFERENCES users(id)
                     ON DELETE RESTRICT ON UPDATE CASCADE,
    status   TEXT NOT NULL DEFAULT 'pending'
);
```

**The four ON DELETE behaviors:**

- `RESTRICT` (default) — refuses to delete a parent with children
- `NO ACTION` — same effect, checked at statement end (deferred check possible)
- `CASCADE` — children deleted with the parent (a user dies → orders vanish)
- `SET NULL` — children orphaned (FK column must be nullable)

**Also today — validation before creation:** a FK onto a column *without* an index makes every parent-delete check the whole child table. PostgreSQL does **not** auto-index FK columns (unlike the PK it indexes). The classic performance trap:

```sql
-- no index on orders_pg(user_id)? every DELETE FROM users scans orders_pg.
CREATE INDEX idx_orders_pg_user ON orders_pg(user_id);
```

**Naming:** PostgreSQL auto-names constraints (`orders_user_id_fkey`); name them yourself (`CONSTRAINT orders_user_fk FOREIGN KEY ...`) — error messages and migrations get much nicer.

## Why It Matters

FK behaviors are *data-loss decisions* encoded once, honored forever. The missing-FK-index trap is one of the most common real-world performance bugs (and a great interview story).

## Mental Model

> FK behaviors are **custody rules for orphans**: RESTRICT = "no parent leaves while children exist"; CASCADE = "children go with the parent"; SET NULL = "children stay, marked as abandoned." And the missing index = the orphanage checking *every single bed* every time anyone leaves.

## Practice

[Beginner] **P1.** Create `users` + two child tables in a scratch DB: `orders_c` (CASCADE) and `notes_n` (SET NULL, nullable user_id). Insert a user + matching children.
[Beginner] **P2.** DELETE the user. Observe both children: one gone, one orphaned (NULL). Say what happened in each table, out loud.
[Beginner] **P3.** Build a RESTRICT child and attempt the same delete — read the error. Name the constraint in the message (auto-name it).
[Intermediate] **P4.** Deferred check (advanced taste): `CREATE TABLE ... CONSTRAINT ... DEFERRABLE INITIALLY DEFERRED;` then inside a transaction delete parent + child in either order — the check happens at COMMIT. Explain when this matters (data reloads).
[Intermediate] **P5. Predict first:** `INSERT INTO orders_pg (user_id) VALUES (999);` — error type? Then: insert a row *then* update its user_id to 999 with ON UPDATE CASCADE present — what does the *update* side do?
[Intermediate] **P6. From memory:** a `reviews` DDL referencing users and products, RESTRICT on products, CASCADE on users — defend each choice in one line.
[Advanced] **P7.** The trap, measured: build `parent` (10k rows) and `child` (100k rows) with generate_series, FK **without** index. Time `DELETE FROM parent WHERE id = 1;`. Add the FK index, re-time (reset data between runs). Report the delta and the rule: "every FK column gets ____".

## Debugging

```sql
-- Bug 1: "update or delete on table "users" violates foreign key
-- constraint" — is this an error to FIX or the system WORKING? When is each?
-- Bug 2 (perf): deleting from a small lookup table takes seconds.
-- What's missing, and what's the fix command?
-- Bug 3 (design): ON DELETE CASCADE on orders → order_items is right.
-- ON DELETE CASCADE on users → orders is... debate: what's the standard
-- e-commerce answer, and why does the repo's shared dataset use RESTRICT?
```

## Combine Concepts

Audit the shared `ecommerce` schema (SQL Day 19's combine, deeper): for each FK, is the child column indexed? (`\d orders` — look at the Indexes section.) Predict the deletion blast radius of `DELETE FROM products WHERE id = 1;` before running it in a scratch copy (`CREATE TABLE x AS ...` won't carry FKs — restore a fresh DB copy with seed script instead). Verify your prediction.

## Previous Knowledge

1. Identity ALWAYS vs BY DEFAULT?
2. Why do sequence gaps exist?
3. SQL: three anomalies, one line each.
4. SQL: what's the "no match" LEFT JOIN pattern?

## Recall

1. The four ON DELETE behaviors — one line each.
2. Which FK-side index does PostgreSQL NOT create automatically?
3. What's the blast-radius question you ask before any CASCADE delete?
4. Why name your constraints?

## Interview Questions

1. "Walk me through ON DELETE CASCADE vs RESTRICT — when would you use each?"
2. "What's a common foreign-key performance bug?" *(Unindexed FK column, delete-parent scans.)*
3. "What does referential integrity actually protect against?"

## Completion Checklist

- [ ] Understand all FK behaviors + the index trap
- [ ] Completed P1–P7 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the ecommerce FK audit
- [ ] Answered recall without notes
