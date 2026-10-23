# Day 16 — Window Functions

**Track:** SQL · **Stage:** 4 — Intermediate Querying · **Difficulty:** Advanced
**Prerequisites:** Days 01–15 · **Dataset:** `saas`

## Goal

Compute values "per row, looking across related rows" — rankings and running totals — and clearly separate window functions from GROUP BY. This is the one SQL feature that feels like a superpower once it clicks.

## Fundamentals

**The difference from GROUP BY** — the crux:

- **GROUP BY** collapses rows: 20 tasks → 5 rows (one per project)
- **Window functions** keep ALL rows and *add* a computed column that looks across a "window" of related rows

```sql
-- GROUP BY: 20 rows in, ~8 rows out (one per project)
SELECT project_id, COUNT(*) FROM tasks GROUP BY project_id;

-- Window: 20 rows in, 20 rows out, each stamped with its project's count
SELECT title, project_id,
       COUNT(*) OVER (PARTITION BY project_id) AS tasks_in_my_project
FROM tasks;
```

**Anatomy:** `function() OVER (PARTITION BY ... ORDER BY ...)`

- `PARTITION BY` — which rows form the "window" (the group it looks across)
- `ORDER BY` (inside OVER) — makes the window *cumulative* (running totals)
- No PARTITION BY — one window: the whole table

**The big three rankings:**

```sql
ROW_NUMBER() OVER (ORDER BY created_at)              -- 1,2,3,4 — ties get different numbers
RANK()       OVER (ORDER BY created_at)             -- 1,2,2,4 — ties share, gaps after
DENSE_RANK() OVER (ORDER BY created_at)             -- 1,2,2,3 — ties share, no gaps
```

**The running-total pattern:**

```sql
SUM(amount) OVER (ORDER BY issued_at)              -- cumulative sum down the rows
```

## Why It Matters

"Top 3 per group" (top 3 tasks per project), running revenue, "rank products by sales within category", previous/current row comparisons — window functions do what previously required ugly subqueries. A favorite mid-level interview topic.

## Mental Model

> GROUP BY is a **trash compactor** (many rows → one). A window function is a **stamping machine**: every row passes through unchanged, but each gets stamped with an answer computed from its neighborhood — "you're #2 in your project", "your project has 7 tasks", "everything so far totals 490".

## Examples

```sql
-- every task + how many tasks its project has
SELECT title, project_id, assignee_id,
       COUNT(*) OVER (PARTITION BY project_id) AS project_task_count
FROM tasks;

-- every invoice + running total over time
SELECT id, amount, status,
       SUM(amount) OVER (ORDER BY issued_at) AS running_total
FROM invoices;

-- rank invoices by amount within each organization
SELECT org_id, amount,
       RANK() OVER (PARTITION BY org_id ORDER BY amount DESC) AS amount_rank
FROM invoices;
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Every task with its project's task count (COUNT OVER PARTITION).

[Beginner] **W2.** Every task with `ROW_NUMBER()` by `created_at` (whole-table ordering).

### 🔵 Core

[Intermediate] **C1.** `[Predict]` RANK vs DENSE_RANK vs ROW_NUMBER on invoices ordered by `amount DESC` — write all three columns' values for the first 4 rows *before running*. Which invoice amounts tie?

[Intermediate] **C2.** `[From Memory]` every user task count per assignee (COUNT OVER PARTITION by assignee_id, keep NULLs visible).

[Intermediate] **C3.** Tasks numbered **within each project** by created date: `task_row` = ROW_NUMBER() OVER (PARTITION BY project_id ORDER BY created_at).

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Bug 1: WHERE can't use window results — what error?
SELECT title, ROW_NUMBER() OVER (ORDER BY created_at) AS rn
FROM tasks
WHERE rn <= 3;

-- Bug 2 (logical): meant "count per project" — what does THIS count?
SELECT title, COUNT(*) OVER (ORDER BY project_id) AS n
FROM tasks;

-- Bug 3: GROUP BY version collapsed the rows — why is this NOT the same as P1?
SELECT project_id, COUNT(*) FROM tasks GROUP BY project_id;
```

[Advanced] **H2.** The workload report, full pipeline: CTE `numbered` (row_number per project) → CTE `top3` (rn <= 3) → join to `projects` for names → only active projects → order by project name, created_at. Window + CTE + join + filter + sort in one query.

[Advanced] **H3.** `AVG(amount) OVER (PARTITION BY org_id)` next to each invoice's amount, filtered... wait — no filter! Keep all rows, and explain what the average column means for each row.

## Interview Questions

1. "How would you get the top 3 rows per group?" *(The #1 window-function interview question — say "row_number + CTE + filter".)*
2. "Difference between RANK and DENSE_RANK?"
3. "Running total in one query — how?" *(SUM OVER ORDER BY.)*

## Completion Checklist

- [ ] Understand OVER, PARTITION BY, rankings, running totals
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Can explain window vs GROUP BY out loud
