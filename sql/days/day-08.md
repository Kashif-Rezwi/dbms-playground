# Day 08 — LIKE, IN, BETWEEN, EXISTS

**Track:** SQL · **Stage:** 2 — CRUD + Querying · **Difficulty:** Beginner
**Prerequisites:** Days 01–07 · **Dataset:** `jobs`

## Goal

Master the four special filtering operators that make WHERE practical for real-world searches.

## Fundamentals

**LIKE — pattern matching on text:**

- `%` = any sequence of characters (including none)
- `_` = exactly one character

```sql
WHERE title LIKE '%Engineer%'    -- contains "Engineer" anywhere
WHERE name LIKE 'Data%'           -- starts with "Data"
WHERE email LIKE '%@mail.dev'     -- ends with @mail.dev
```

`ILIKE` (PostgreSQL) = case-insensitive LIKE.

**IN — membership in a list** (a cleaner OR-chain):

```sql
WHERE city IN ('Karachi', 'Lahore', 'Multan')     -- same as = OR = OR =
WHERE status NOT IN ('rejected', 'withdrawn')
```

**BETWEEN — inclusive range:**

```sql
WHERE salary_min BETWEEN 80000 AND 120000          -- includes both ends!
```

**EXISTS — "is there at least one?"** It takes a *subquery* and answers with a boolean; the database can stop scanning at the first match:

```sql
SELECT name FROM candidates c
WHERE EXISTS (SELECT 1 FROM applications a WHERE a.candidate_id = c.id);
```

The inner query "sees" the outer row (`c.id`) — a first taste of *correlated subqueries* (Day 14 goes deep).

## Why It Matters

Search boxes, salary-range filters, category checkboxes, "show items that have at least one X" — these four operators cover most real-world filter UIs.

## Mental Model

> - **LIKE** = a **stencil**: % and _ are the flexible holes.
> - **IN** = the **guest list** at a door.
> - **BETWEEN** = a **fence with two ends** (both ends *inside* the fence).
> - **EXISTS** = "does the **shelf contain at least one**?" — you stop looking at the first one found.

## Examples

```sql
-- LIKE
SELECT title FROM jobs WHERE title LIKE '%Engineer%';

-- ILIKE (PostgreSQL)
SELECT name FROM companies WHERE name ILIKE '%tech%';

-- IN
SELECT title, city FROM companies WHERE city IN ('Karachi', 'Lahore');

-- BETWEEN
SELECT title, salary_min, salary_max FROM jobs
WHERE salary_min BETWEEN 90000 AND 130000;

-- EXISTS: candidates who have applied to at least one job
SELECT name FROM candidates c
WHERE EXISTS (SELECT 1 FROM applications a WHERE a.candidate_id = c.id);
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Job titles containing the word `'Data'`.

[Beginner] **W2.** Candidates whose email ends with `'@mail.dev'`.

### 🔵 Core

[Intermediate] **C1.** `[Predict]` which candidates match?

```sql
SELECT name FROM candidates
WHERE experience_years BETWEEN 2 AND 6
  AND city LIKE '%o%';
```

[Intermediate] **C2.** `[From Memory]` companies founded between 2012 and 2019, in Software or Analytics.

[Intermediate] **C3.** Remote jobs (`is_remote = TRUE`) with max salary between 100000 and 150000.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Bug 1 (logical: too greedy)
SELECT title FROM jobs WHERE title LIKE '%Data Engineer%';
-- The user wanted "any Data Engineer role" — did this catch 'Data Engineers (Senior)'? What did it miss?

-- Bug 2 (BETWEEN misunderstanding)
SELECT title, salary_min FROM jobs WHERE salary_min > 80000 AND salary_min < 120000;
-- The intent was the same as BETWEEN 80000 AND 120000. Which rows differ? (Check the ends!)

-- Bug 3 (NULL ambush in NOT IN — deep cut)
SELECT name FROM candidates WHERE name NOT IN (SELECT NULL FROM candidates WHERE FALSE);
-- Simplify: run SELECT name FROM candidates WHERE name NOT IN ('Ayesha Khan', NULL);
-- What does NOT IN do when the list contains NULL, and why?
```

[Advanced] **H2.** Yesterday's CASE + today: jobs with a computed column `salary_tier` — max salary ≥ 130000 → `'senior'`, ≥ 100000 → `'mid'`, else `'junior'` — filtered to remote jobs only, sorted by tier then title. (CASE from Day 7 + BETWEEN/IN from today + ORDER BY from Day 4.)

[Advanced] **H3.** Advanced stencil work: emails where the **username part** (before @) is exactly 5 characters long. (Hint: `%` is greedy — think about `_` × 5 followed by `@`.)

## Interview Questions

1. "How do you implement a search box filter in SQL?"
2. "What's the difference between `LIKE 'a%'` and `LIKE '%a'`?"
3. "What subtle danger does `NOT IN` have with NULLs?" *(Bonus points if you remember it from Bug 3.)*

## Completion Checklist

- [ ] Understand LIKE/ILIKE, IN, BETWEEN, EXISTS
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Can explain all four operators out loud
