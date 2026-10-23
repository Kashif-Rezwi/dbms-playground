# Day 04 — Server Architecture & Loading Data

**Track:** PostgreSQL · **Stage:** 1 — Setup · **Difficulty:** Intermediate

## Goal

Know the server's moving parts (processes, memory, WAL) and load/verify datasets like an operator.

## Fundamentals

**The process model** — one process per connection:

- **postmaster** — the supervisor; accepts connections, forks a **backend** per client
- **backends** — your connection's process; runs your queries
- **background workers** — checkpointer, autovacuum, walwriter, stats collector

Why it matters: each connection is a *process* with its own memory — connections aren't free (Day 28: pooling exists for this reason).

**Memory** — two big shared caches:
- **shared_buffers**: PostgreSQL's hot-data cache (RAM)
- **work_mem**: per-sort/hash scratch memory *per operation* — big sorts spill to disk (you'll see this in EXPLAIN: "Sort Method: external merge")

**WAL (Write-Ahead Log)** — the durability engine. Before any change is applied, its description is *written to disk*. Crash? WAL replays to recovery. This is the "D" of ACID, physically.

**The query path** (one line each):
```text
parse → plan → execute → (via shared_buffers → disk) → WAL entry → response
```

**Loading data — your operator skills:**

```bash
psql -d ecommerce -f shared/datasets/ecommerce.sql     # SQL file
pg_restore -d db --clean backup.dump                    # Day 23
psql -d ecommerce -c "SELECT count(*) FROM users;"      # verification habit
```

Bulk load (Day 24-level speed, taste it now):

```sql
COPY big_users FROM '/path/file.csv' WITH (FORMAT csv, HEADER true);
-- and out:
COPY (SELECT * FROM users) TO '/tmp/users.csv' WITH (FORMAT csv, HEADER true);
```

## Why It Matters

Every performance, concurrency, or reliability question in the rest of this track resolves to these parts. Also: `COPY` vs row-by-row INSERT is often 10–100× — the first real "operator" reflex.

## Mental Model

> The postmaster is a **hotel manager** assigning a butler (backend) per guest (connection). The kitchen has a hot-pass (shared_buffers). **WAL is the hotel's incident logbook, written before anything happens** — burn the kitchen down and the logbook rebuilds the last hour exactly.

## Practice

### 🟢 Warm Up

[Beginner] **W1.** `ps aux | grep postgres` — identify postmaster, autovacuum, walwriter, and your own backend (match your `pg_backend_pid()`). Screenshot/notes.

[Beginner] **W2.** Load all four datasets (`./scripts/seed/seed-postgres.sh <name>`) and verify counts against each seed file's sanity-check comment.

### 🔵 Core

[Intermediate] **C1.** `[Predict]` which finishes first — a 1000-row `INSERT ... VALUES` list or `COPY` of the same rows from a CSV? Then build the CSV via `COPY TO` and prove it.

[Intermediate] **C2.** `[From Memory]` the command to run a .sql file into a database from the shell (two forms: psql -f, and \i inside psql).

[Intermediate] **C3.** In two psql sessions, `SELECT pg_backend_pid();` — different PIDs, both visible in ps. One line: what proves each connection is a process?

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Bug 1: "out of memory" on a huge sort. Which setting is the lever, what's
-- the risk of raising it globally (per-connection × per-operation memory)?
-- Bug 2: COPY fails: "could not open file for reading". Two causes
-- (permissions; server-side COPY reads files AS THE SERVER USER — hint at
-- the client-side psql \copy distinction).
-- Bug 3: someone "loaded" a dataset but every table is empty. What
-- verification step was skipped, and what's the habit?
```

[Advanced] **H2.** The verification habit, generalized: write a *single catalog query* that reports every table in the current database with its row count (`pg_stat_user_tables`) — the "did my load work" dashboard. Run it on all four datasets. Keep this query in your notes forever.

[Advanced] **H3.** WAL intuition: insert a row in one session; before you commit... it's already WAL-logged? Research with `\db` no — just explain in two sentences: why can PostgreSQL recover "uncommitted-at-crash" data boundaries exactly, and what would be lost without WAL?

## Interview Questions

1. "How does PostgreSQL achieve durability?" *(WAL — write-ahead, replay on crash.)*
2. "Why can too many connections hurt a database that isn't even busy?" *(Process model, memory per connection.)*
3. "How would you load 10 million rows fastest?" *(COPY / bulk approaches, not row-by-row inserts.)*

## Completion Checklist

- [ ] Understand processes, memory, WAL, COPY
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Built your row-count dashboard query
