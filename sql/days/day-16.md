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

[Beginner] **P1.** Every task with its project's task count (COUNT OVER PARTITION).
[Beginner] **P2.** Every task with `ROW_NUMBER()` by `created_at` (whole-table ordering).
[Intermediate] **P3.** Tasks numbered **within each project** by created date: `task_row` = ROW_NUMBER() OVER (PARTITION BY project_id ORDER BY created_at).
[Intermediate] **P4. Predict first:** RANK vs DENSE_RANK vs ROW_NUMBER on invoices ordered by `amount DESC` — write all three columns' values for the first 4 rows *before running*. Which invoice amounts tie?
[Intermediate] **P5.** Running total of invoice amounts by issue date (whole table).
[Intermediate] **P6.** `top 3 tasks per project by created_at` — the classic:

```sql
WITH numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY project_id ORDER BY created_at) AS rn
    FROM tasks
)
SELECT * FROM numbered WHERE rn <= 3;
```

Explain why you *needed* the CTE (hint: WHERE can't see window results — they compute after WHERE).

[Intermediate] **P7. From memory:** every user task count per assignee (COUNT OVER PARTITION by assignee_id, keep NULLs visible).
[Advanced] **P8.** `AVG(amount) OVER (PARTITION BY org_id)` next to each invoice's amount, filtered... wait — no filter! Keep all rows, and explain what the average column means for each row.
[Advanced] **P9.** Combine Day 14's correlated subquery instinct: redo P1 with a correlated subquery instead of a window function. Which is clearer? Which keeps all rows more naturally?

## Debugging

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

## Combine Concepts

The workload report, full pipeline: CTE `numbered` (row_number per project) → CTE `top3` (rn <= 3) → join to `projects` for names → only active projects → order by project name, created_at. Window + CTE + join + filter + sort in one query.

## Previous Knowledge

1. GROUP BY vs HAVING — one line each.
2. Write from memory: org name + overdue invoice total (CTE + join).
3. What's the difference between LEFT and INNER when the right side has no match?
4. What are a recursive CTE's two parts?

## Recall

1. Window function vs GROUP BY — input rows vs output rows?
2. What does PARTITION BY do? What if you omit it?
3. ROW_NUMBER vs RANK vs DENSE_RANK — ties, and gaps?
4. Why can't WHERE filter on a window result — what do you use instead?

## Interview Questions

1. "How would you get the top 3 rows per group?" *(The #1 window-function interview question — say "row_number + CTE + filter".)*
2. "Difference between RANK and DENSE_RANK?"
3. "Running total in one query — how?" *(SUM OVER ORDER BY.)*

## Completion Checklist

- [ ] Understand OVER, PARTITION BY, rankings, running totals
- [ ] Completed P1–P9 (P4 all three columns predicted first)
- [ ] Fixed all three bugs
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Can explain window vs GROUP BY out loud
