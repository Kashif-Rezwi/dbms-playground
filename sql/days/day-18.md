# Day 18 — Set Operations: UNION, INTERSECT, EXCEPT

**Track:** SQL · **Stage:** 4 — Intermediate Querying · **Difficulty:** Intermediate
**Prerequisites:** Days 01–17 · **Dataset:** `jobs` (reset first)

## Goal

Combine query *results* vertically (stacking rows) and know when that beats a join.

## Fundamentals

Joins combine tables **horizontally** (wider rows). Set operations stack results **vertically** (more rows):

```sql
-- UNION: everything from both (duplicates removed)
SELECT city FROM candidates
UNION
SELECT city FROM companies;

-- UNION ALL: everything, duplicates KEPT (faster — no dedup work)
SELECT city FROM candidates
UNION ALL
SELECT city FROM companies;

-- INTERSECT: cities in BOTH
SELECT city FROM candidates
INTERSECT
SELECT city FROM companies;

-- EXCEPT: in the first, not in the second
SELECT city FROM candidates
EXCEPT
SELECT city FROM companies;
```

**Two rules:** the queries must have the **same number of columns**, with **compatible types**; column names come from the first query.

**UNION vs UNION ALL** matters: UNION deduplicates (sorts/hashes the whole result); UNION ALL just glues. If you *know* there are no duplicates (or want them), UNION ALL is faster — a real optimization habit.

## Why It Matters

"Products never ordered *nor* reviewed", "all users from two tables into one report", "cities where we have candidates but no companies" — set thinking expresses these naturally. Also the backbone of data stitching in ETL/reporting.

## Mental Model

> Set operations are **card decks**: UNION = shuffle both decks together (drop duplicate cards); UNION ALL = just put one deck on top of the other; INTERSECT = cards in *both* decks; EXCEPT = deck 1's cards that deck 2 doesn't have. Each SELECT is a deck; the columns are card face layout — they must match.

## Examples

```sql
-- all cities in the platform (either side of the market)
SELECT city FROM candidates
UNION
SELECT city FROM companies
ORDER BY city;

-- cities with BOTH candidates and companies
SELECT city FROM candidates
INTERSECT
SELECT city FROM companies;

-- cities with candidates but no company
SELECT city FROM candidates
EXCEPT
SELECT city FROM companies;

-- combining differently-shaped queries into one report
SELECT title AS label, salary_min AS amount, 'min' AS kind FROM jobs
UNION ALL
SELECT title, salary_max, 'max' FROM jobs;
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** All cities in the platform (deduplicated), sorted.

[Beginner] **W2.** Cities with candidates but no companies.

### 🔵 Core

[Intermediate] **C1.** `[Predict]` — row count of each *before* running:

```sql
SELECT experience_years FROM candidates;   -- count: ?
... UNION vs UNION ALL with itself:
SELECT experience_years FROM candidates UNION SELECT experience_years FROM candidates;      -- ?
SELECT experience_years FROM candidates UNION ALL SELECT experience_years FROM candidates; -- ?
```

Explain the difference in one sentence.

[Intermediate] **C2.** `[From Memory]` companies founded before 2015 EXCEPT companies in Karachi.

[Intermediate] **C3.** Cities with companies but no candidates.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Bug 1: column count mismatch
SELECT name, city FROM candidates
UNION
SELECT city FROM companies;

-- Bug 2 (logical): meant "cities with both" — got what instead?
SELECT city FROM candidates
UNION
SELECT city FROM companies;

-- Bug 3 (logical): the analyst wanted duplicates kept for a per-row count.
SELECT city FROM candidates
UNION
SELECT city FROM companies
WHERE city = 'Karachi';
-- Also: what does the WHERE apply to — both sides or one? Verify with counts.
```

[Advanced] **H2.** Market coverage report with CTEs + sets:

```sql
WITH candidate_cities AS (SELECT DISTINCT city FROM candidates),
     company_cities  AS (SELECT DISTINCT city FROM companies)
SELECT ...
```

— compute: cities with both, candidates-only, companies-only, using INTERSECT and two EXCEPTs. Wrap each in its own CTE and produce three labeled result sets (or one UNION'd report with a `bucket` label column).

[Advanced] **H3.** "Companies whose jobs all pay 100k+" — pure set thinking: companies EXCEPT (companies with any job under 100k). Write both sides.

## Interview Questions

1. "UNION vs UNION ALL — what's the difference, and which is faster?"
2. "How would you find values present in one table but missing from another?" *(EXCEPT, NOT IN, or LEFT JOIN+IS NULL — name all three and their NULL caveat.)*
3. "When would you choose a set operation over a JOIN?"

## Completion Checklist

- [ ] Understand UNION/UNION ALL/INTERSECT/EXCEPT
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Can explain UNION vs UNION ALL out loud
