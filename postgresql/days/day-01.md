# Day 01 — Installing PostgreSQL + psql Survival

**Track:** PostgreSQL · **Stage:** 1 — Setup · **Difficulty:** 🟢 Beginner
**Prerequisites:** SQL track (concepts will be reused, not re-taught)

## 🎯 Goal

A working PostgreSQL server, a confident psql session, and the mental model of client/server databases.

## 🧠 Fundamentals

**PostgreSQL is a client–server system.** The **server** (postgres daemon) runs constantly, owns the data files, and speaks one language: SQL over a protocol. The **client** (psql, your app, pgAdmin) connects over TCP (default port **5432**) and sends queries. You never touch the data files — only the server does.

One server manages a **cluster**: a set of **databases**. Inside each database, multiple **schemas** (namespaces) group tables — `public` is the default.

Full install steps: [`../setup/install.md`](../setup/install.md) — then come back here.

## 🔍 Why It Matters

Everything else in this track happens inside a running server. And understanding client/server early kills the classic beginner confusion: "is the database running when I close psql?" — **yes, always.**

## 💡 Mental Model

> The server is a **restaurant kitchen** (always open, holds the ingredients). Clients are **waiters** (psql is one waiter). Orders go in (SQL), dishes come out (results). The kitchen doesn't close when a waiter takes a break.

## 💻 Examples

```bash
brew services start postgresql@16
psql -V
psql -d postgres        # the maintenance database
```

```sql
SELECT version();
SELECT now();
SELECT current_user, current_database();
```

Then the survival commands (also in [`../setup/psql-survival-guide.md`](../setup/psql-survival-guide.md)):

```text
\l     -- databases        \c ecommerce   -- switch
\dt    -- tables           \d orders      -- describe
\timing on  \x auto        \q             -- quit
```

## 🛠️ Practice

🟢 **P1.** Install, start, connect, and run the four SQL examples above. Record the version string.
🟢 **P2.** Run `./scripts/setup/setup-postgres.sh`, then `\l` — find your four practice databases.
🟢 **P3.** `\c ecommerce` → seed if needed → `\dt` → `\d orders`. Read the describe output: what are the "Indexes" section and "Foreign-key constraints" section telling you?
🟢 **P4.** Turn on `\timing`, run a SELECT, note the ms. Turn on `\pset null '∅'` and select a nullable column — why is this display setting gold?
🟡 **P5. ⭐ Predict first:** what does `\dt` show after `psql -d saas`? Then `\c social` and predict again. Why does it change?
🟡 **P6.** Open a **second** psql terminal to the same database. Run `SELECT pg_backend_pid();` in both — different numbers? Explain what a backend is.
🔴 **P7.** Server processes: run `ps aux | grep postgres` (terminal, not psql). Find the *postmaster*, *checkpointer*, *walwriter* — one line each in your notes on what these names hint at (Day 4 confirms your guesses).

## 🐛 Debugging

```sql
-- Bug 1: "connection refused" when running psql. What are the three
--         likely causes, in the order you'd check them?
-- Bug 2: \dt says "No relations found" — but you KNOW there are tables.
--         Two likely explanations (wrong database? wrong schema? check \c and \dn)
-- Bug 3: your query "hangs" forever. What does \watch, Ctrl-C, and a
--         second session's pg_locks query (Day 20) have to do with it?
```

## 🧩 Combine Concepts

SQL Day 1 revisited *through the engine*: run `SELECT * FROM users;` — then, using `\d users` and `SELECT pg_size_pretty(pg_total_relation_size('users'));`, explain the difference between what a *query* sees and what a *server* stores.

## 🔁 Previous Knowledge (SQL track)

1. What does the ON clause do in a JOIN?
2. Write from memory: top 3 cheapest in-stock products.
3. What is referential integrity?
4. What does EXPLAIN ANALYZE do (one line)?

## 🧠 Recall

1. Client vs server — who holds the data files?
2. What is a cluster? A database? A schema (both meanings)?
3. What port does PostgreSQL listen on by default?
4. Which three psql commands will you use most this track?

## 🎤 Interview Questions

1. "Is SQL the same as PostgreSQL?" *(Language vs system — answer like Day 1 taught you.)*
2. "What happens when my psql session ends — does the data stop?" *(Server persists.)*
3. "Describe the client/server architecture of PostgreSQL."

## ✅ Completion Checklist

- [ ] Server running; connected; version noted
- [ ] Survival commands tried (all of them)
- [ ] Completed P1–P7 (P5 predicted first)
- [ ] Fixed/diagnosed all three bugs
- [ ] Answered recall without notes
- [ ] Can explain client/server out loud
