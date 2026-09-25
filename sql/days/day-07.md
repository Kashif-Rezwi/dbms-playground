# Day 07 — NULL, CASE, COALESCE

**Track:** SQL · **Stage:** 2 — CRUD + Querying · **Difficulty:** Intermediate
**Prerequisites:** Days 01–06 · **Dataset:** `saas`

## Goal

Work with missing data (NULL) correctly, and add if/then/else logic to queries with CASE and COALESCE.

## Fundamentals

**NULL ≠ 0, NULL ≠ '', NULL ≠ NULL.** NULL means *"this value is unknown or absent."* It poisons logic:

- `NULL = NULL` → unknown (not true!) — that's why you must use `IS NULL`
- `5 + NULL` → NULL — arithmetic with unknown is unknown
- `NOT (NULL)` → unknown — negation doesn't rescue it
- `COUNT(col)` counts **non-NULL** values; `COUNT(*)` counts rows

**COALESCE — a default-value helper:** returns its first non-NULL argument:

```sql
SELECT COALESCE(deadline, CURRENT_DATE + 30) FROM projects;  -- no deadline? use today+30
```

**CASE — SQL's if/else:**

```sql
SELECT title,
       CASE WHEN priority = 'high'   THEN ''
            WHEN priority = 'medium' THEN ''
            ELSE '' END AS flag
FROM tasks;
```

**CASE inside aggregates** is a powerhouse pattern ("conditional counting"):

```sql
SELECT project_id,
       COUNT(*) FILTER (WHERE status = 'done') AS done_tasks   -- PostgreSQL shorthand
FROM tasks GROUP BY project_id;

SELECT project_id,
       SUM(CASE WHEN status = 'done' THEN 1 ELSE 0 END) AS done_tasks  -- portable version
FROM tasks GROUP BY project_id;
```

## Why It Matters

Real data is *always* full of holes: unassigned tasks, missing deadlines, empty bios. Misunderstanding NULL is one of the most common real bugs and interview traps. CASE turns raw rows into labeled, bucketed, human-readable output.

## Mental Model

> NULL is a **question mark, not a zero**. "Deadline: ?" isn't a date, so any logic touching it becomes "?" too. COALESCE replaces "?" with a fallback you choose. CASE is a **sorting hat** sending each row's value to a house (label) you define.

## Examples

```sql
SELECT title, assignee_id FROM tasks WHERE assignee_id IS NULL;       -- unassigned tasks
SELECT title FROM projects WHERE deadline IS NULL;                     -- no deadline set

-- give missing deadlines a fake "far future" for sorting purposes
SELECT name, status, COALESCE(deadline, DATE '2099-01-01') AS sort_deadline
FROM projects ORDER BY sort_deadline;

-- bucket tasks by status
SELECT title,
       CASE status WHEN 'todo' THEN '[ ]'
                   WHEN 'doing' THEN '[~]'
                   ELSE '[x]' END AS badge
FROM tasks;
```

## Practice

[Beginner] **P1.** Find all unassigned tasks (`assignee_id IS NULL`). Predict the count first.
[Beginner] **P2.** Find all projects **with** a deadline. Then all projects, with missing deadlines shown as `2099-12-31` (COALESCE).
[Beginner] **P3.** List tasks with a column `is_late` = TRUE when `status <> 'done'` and `completed_at IS NULL` and... actually simpler: `completed_at IS NULL AND status <> 'todo'`. Name the flag `stuck`.
[Intermediate] **P4.** Bucket invoices by status: `'overdue'` → `'URGENT'`, `'open'` → `'waiting'`, else `'settled'`. Sort by the bucket.
[Intermediate] **P5. Predict first:** exact output of both:

```sql
SELECT COUNT(*) FROM tasks;
SELECT COUNT(assignee_id) FROM tasks;
```

Explain the difference in one sentence.
[Intermediate] **P6.** For every task: title, plus `days_taken` = `completed_at - created_at`. Which completed tasks took more than 30 days? (Some rows will be NULL — why?)
[Intermediate] **P7. From memory:** users whose `renews_at` is NULL in subscriptions.
[Advanced] **P8.** For each project (GROUP BY comes tomorrow — use plain SELECT with CASE today): show project tasks with a computed column `urgency` = 'high' priority AND not done → `'urgent'`; deadline passed (before today) → `'late'`; else `'ok'`. Use `CURRENT_DATE`.

## Debugging

```sql
-- Bug 1 (silent wrong answer)
SELECT title FROM tasks WHERE assignee_id = NULL;

-- Bug 2 (logical: runs, wrong meaning)
SELECT title FROM tasks WHERE priority = 'high' OR 'medium';

-- Bug 3 (NULL in comparison chain)
SELECT name FROM projects WHERE deadline <> NULL;
```

For each: what's wrong, why, fix, verify. (Bug 2: 'medium' is a string, not a boolean — PostgreSQL may even error. What did you actually mean, and what operator should you use?)

## Combine Concepts

Yesterday's safety habits + today: write an **UPDATE with CASE** — set every unassigned task's priority to `'medium'` (preview first, verify after). Then filter & sort: all unassigned tasks by priority, top 5.

## Previous Knowledge

1. What does UPDATE without WHERE do? What do you run first, always?
2. Write from memory: top 3 most expensive in-stock products.
3. What's the execution order: WHERE, ORDER BY, LIMIT?
4. What does `price * 1.05` inside a SET clause use — old or new value?

## Recall

1. What is NULL, in one sentence — and what are its two impostors (values beginners confuse it with)?
2. Why does `WHERE col = NULL` return nothing? What's the fix?
3. What does COALESCE do? Give a use case from today.
4. What does `COUNT(col)` skip that `COUNT(*)` doesn't?

## Interview Questions

1. "What is NULL and how is it different from 0 or an empty string?"
2. "How does NULL behave in comparisons and in COUNT?"
3. "How would you categorize rows into buckets in a single query?" *(CASE.)*

## Completion Checklist

- [ ] Understand NULL semantics, IS NULL, COALESCE, CASE
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Can explain NULL + CASE out loud
