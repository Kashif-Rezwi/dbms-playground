# SQL Track — The Query Language

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

| Dataset | Used in |
|---|---|
| ecommerce | Days 1–6, 9–10, 12, 14, 17, 19, 21, 25, 27–28, project P4, capstone |
| social | Days 11, 13 (+ Day 15 combine), drill packs |
| saas | Days 7, 15–16, Stage Review 2 |
| jobs | Days 8, 18 |
| your own | Day 20, projects P1–P3 and P5 |
| perf_lab (generated, ~500k rows) | Days 22–24, Day 28 drill, project P6 — load with `./scripts/utilities/load-large-postgres.sh` |

## Structure

```text
sql/
├── days/day-01.md … day-30.md   ← one lesson per day (45–90 min)
├── projects/                    ← consolidation milestones (attempt before solutions/)
├── reviews/                     ← stage reviews
├── exercises/                   ← drill packs: predict-the-result + write-from-memory
└── cheat-sheet.md               ← quick syntax reference
```

**Drill packs** (`exercises/`): extra spaced-repetition sets. Do [predict-the-result](exercises/predict-the-result.md) after Day 12 and [write-from-memory](exercises/write-from-memory.md) around Days 17–24 — and revisit both during Day 28's review.

## Rules of This Track

1. **Type every query yourself** — no copy-paste.
2. **Predict before you run** — exercises marked **Predict first** require a written prediction before executing.
3. **Write-from-memory means no notes.** Failing is data, not defeat — reread, retry.
4. **Attempt projects before opening `solutions/`.**

**Start → [days/day-01.md](./days/day-01.md)**
