# 🗣️ SQL Track — The Query Language

> **SQL is a language, not a database.** You speak SQL *to* a database system. In this track you learn the language and the relational thinking behind it; in the `postgresql/` track you learn the engine itself.

## What You'll Learn

```text
Days 1–5     Foundation: tables, SELECT, WHERE, ORDER BY, INSERT
Days 6–10    CRUD + querying: UPDATE, DELETE, NULL, filtering, aggregation
Days 11–15   Relationships: joins, subqueries, CTEs
Days 16–20   Intermediate: window functions, dates, set ops, keys, normalization
Days 21–24   Transactions, ACID, indexes, EXPLAIN, optimization
Days 25–30   Views, design decisions, anti-patterns, CAPSTONE
```

Full day-by-day plan: [30-DAY-ROADMAP.md](./30-DAY-ROADMAP.md)

## How to Run the Lessons

SQL is database-agnostic, but you need *a* database to execute it. We use **PostgreSQL** (installed in the PostgreSQL track, or see `../postgresql/setup/install.md`).

```bash
# One-time setup
./scripts/setup/setup-postgres.sh

# Load a dataset (any day's lesson says which one it needs)
./scripts/seed/seed-postgres.sh ecommerce

# Start working
psql -d ecommerce

# Broke something? Reset any time:
./scripts/reset/reset-postgres.sh ecommerce
```

> The SQL in these lessons sticks to the widely-supported core (works in PostgreSQL, MySQL, SQLite, SQL Server with tiny variations). When PostgreSQL differs from the standard, lessons call it out.

## Datasets

Lessons reuse the four shared datasets — see `../shared/datasets/` and the ER diagrams in `../shared/diagrams/`:

| Dataset | Used heavily in |
|---|---|
| 🛒 ecommerce | Days 1–5, 19, 22–24, capstone |
| 💬 social | Days 11–16, project P3 |
| 🏢 saas | Day 19, project P4 |
| 💼 jobs | Days 11–18, project P3 |

## Structure

```text
sql/
├── days/day-01.md … day-30.md   ← one lesson per day (45–90 min)
├── projects/                    ← consolidation milestones (attempt before solutions/)
├── reviews/                     ← stage reviews + mock interview
├── exercises/                   ← extra drill packs (predict / debug / from-memory)
└── cheat-sheet.md               ← quick syntax reference
```

## Rules of This Track

1. **Type every query yourself** — no copy-paste.
2. **Predict before you run** — ⭐ exercises require a written prediction first.
3. **Write-from-memory means no notes.** Failing is data, not defeat — reread, retry.
4. **Attempt projects before opening `solutions/`.**

**Start → [days/day-01.md](./days/day-01.md)**
