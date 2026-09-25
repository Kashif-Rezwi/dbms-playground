# PostgreSQL Track — The Database System

> **PostgreSQL is not "SQL again."** SQL (previous track) was the *language*. This track is the *engine*: how the server is organized, how it models and enforces data, how it plans and executes queries, and how it behaves under concurrency, security, and production pressure.

## What You'll Learn

```text
Days 1–4     Setup: psql, databases/schemas, data types, architecture
Days 5–7     Data modeling the PG way: identity, sequences, constraints
Days 8–12    Features: views, functions, procedures, triggers, JSON/arrays
Days 13–17   Indexes & the planner: B-trees, partial/unique, EXPLAIN, statistics
Days 18–20   Transactions & concurrency: isolation levels, locks, deadlocks
Days 21–26   Security & ops: roles, RLS, backups, tuning, VACUUM, production
Days 27–30   Production thinking: replication, pooling, CAPSTONE
```

**Prerequisites:** the SQL track (Days 1–24 minimum). Each day has a recall section that keeps SQL alive; new *system* concepts are taught from zero.

## How to Run the Lessons

```bash
brew install postgresql@16 && brew services start postgresql@16   # if not done
./scripts/setup/setup-postgres.sh
psql -d ecommerce        # most days tell you which database to use
```

Full setup help: [setup/install.md](./setup/install.md) · [setup/psql-survival-guide.md](./setup/psql-survival-guide.md)

## Structure

```text
postgresql/
├── setup/                       ← install + psql survival guide
├── days/day-01.md … day-30.md    ← one lesson per day
├── projects/                     ← consolidation milestones
├── reviews/                      ← stage reviews
└── cheat-sheet.md                ← PG-specific quick reference
```

## What Makes This Track Different

You will *watch the engine work*: query plans, lock waits, isolation anomalies, bloat after deletes, role-based access denied. SQL taught you to *speak*; PostgreSQL teaches you what happens when the *machine* listens.

**Start → [days/day-01.md](./days/day-01.md)**
