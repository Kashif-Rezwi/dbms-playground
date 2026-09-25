# Day 15 — CTEs: WITH, and a Recursive Intro

**Track:** SQL · **Stage:** 3 — Relationships · **Difficulty:** 🟡 Intermediate
**Prerequisites:** Days 01–14 · **Dataset:** `saas` (reset first)

## 🎯 Goal

Structure complex queries with CTEs — the readability superpower of SQL — and meet recursive CTEs.

## 🧠 Fundamentals

A **CTE (Common Table Expression)** is a *named temporary result* that exists for one query:

```sql
WITH done_tasks AS (
    SELECT * FROM tasks WHERE status = 'done'
)
SELECT u.name, COUNT(*) AS done_count
FROM done_tasks d
JOIN users u ON u.id = d.assignee_id
GROUP BY u.name;
```

Read it as: *"first compute `done_tasks`, then query it like a table."* It vanishes after the query.

**Why CTEs instead of nested subqueries?** Compare:

```sql
-- nested (works, but read it out loud without dying)
SELECT name FROM users WHERE id IN
    (SELECT assignee_id FROM tasks WHERE project_id IN
        (SELECT id FROM projects WHERE org_id IN
            (SELECT id FROM organizations WHERE plan = 'pro')));

-- CTE version: a readable pipeline, top-down
WITH pro_orgs AS (
    SELECT id FROM organizations WHERE plan = 'pro'
),
pro_projects AS (
    SELECT p.id FROM projects p JOIN pro_orgs o ON p.org_id = o.id
),
pro_tasks AS (
    SELECT t.assignee_id FROM tasks t JOIN pro_projects p ON t.project_id = p.id
)
SELECT u.name FROM users u JOIN pro_tasks t ON u.id = t.assignee_id;
```

**Chain CTEs** — each one can use the ones above it, like a build pipeline: raw → filtered → aggregated → reported.

**Recursive CTE** — a CTE that refers to *itself*: a seed row + a rule that keeps growing:

```sql
WITH RECURSIVE countdown AS (
    SELECT 5 AS n                              -- seed
    UNION ALL
    SELECT n - 1 FROM countdown WHERE n > 1    -- recursive step (with a stop!)
)
SELECT * FROM countdown;
```

## 🔍 Why It Matters

Every long analytical query in real codebases is written with CTEs. They turn a pile of parentheses into a story with named steps — and make debugging possible (test each stage alone).

## 💡 Mental Model

> CTEs are a **recipe's prep steps**: chop the onions (first CTE), make the sauce (second, using the onions), assemble the dish (final SELECT). Recursion is a **domino chain**: the seed tips the first domino; the rule keeps knocking the next until a condition stops it.

## 💻 Examples

```sql
-- readable pipeline: overdue totals per organization
WITH overdue AS (
    SELECT org_id, amount FROM invoices WHERE status = 'overdue'
)
SELECT o.name, SUM(od.amount) AS overdue_total
FROM overdue od
JOIN organizations o ON o.id = od.org_id
GROUP BY o.name;

-- chained CTEs: high-priority open work per org
WITH open_tasks AS (
    SELECT * FROM tasks WHERE status IN ('todo', 'doing')
),
urgent AS (
    SELECT * FROM open_tasks WHERE priority = 'high'
)
SELECT org.name, COUNT(*) AS urgent_count
FROM urgent t
JOIN projects p ON p.id = t.project_id
JOIN organizations org ON org.id = p.org_id
GROUP BY org.name ORDER BY urgent_count DESC;

-- recursion: number series
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 10
)
SELECT n FROM seq;
```

## 🛠️ Practice

🟢 **P1.** CTE `paid` = paid invoices; total per organization (org name, sum).
🟢 **P2.** CTE `busy` = users with at least one `doing` task; list their names.
🟢 **P3.** Type the CTE version of the "pro-plan chain" example yourself, then verify it matches the nested version's result.
🟡 **P4.** Chained: `late_deadlines` (projects past deadline) → `tasks_in_those` → per-project open task count.
🟡 **P5. ⭐ Predict first** — output of the countdown CTE above (exact rows, exact order).
🟡 **P6. From memory:** with a CTE named `big`, select pro-plan organizations having more than 1 project; output org name + project count.
🔴 **P7.** Recursion on the Day 13 `employees` table (recreate it if needed): walk the hierarchy from the CEO — id, name, manager_id, **depth** (CEO = 1, reports = 2, ...):

```sql
WITH RECURSIVE tree AS (
    SELECT id, name, manager_id, 1 AS depth FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.id, e.name, e.manager_id, t.depth + 1
    FROM employees e JOIN tree t ON e.manager_id = t.id
)
SELECT * FROM tree;
```

Type it, run it, then **explain each line out loud** — a famous interview pattern.
🔴 **P8.** A recursive date series: every date from Jan 1 to Jan 7, 2025 (`DATE '2025-01-01' + n`).

## 🐛 Debugging

```sql
-- Bug 1: something is missing before "tree"
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 10
SELECT * FROM seq;

-- Bug 2 (infinite recursion risk): what happens without the WHERE?
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq
)
SELECT * FROM seq;    -- careful! Ctrl-C if it hangs.

-- Bug 3 (logical): CTE defined but never used
WITH done AS (SELECT * FROM tasks WHERE status = 'done')
SELECT COUNT(*) FROM tasks;
```

## 🧩 Combine Concepts

Yesterday's two-queries limitation, solved: **username, post_count, follower_count in ONE query** — two CTEs (posts grouped, followers grouped) + join + COALESCE for zeros. Dataset: `social`. This is the glue you couldn't write yesterday — feel the upgrade.

## 🔁 Previous Knowledge

1. Correlated vs plain subquery — one line each.
2. Write from memory: products above their own category's average price.
3. The "never X" LEFT JOIN pattern — from memory.
4. What does `> ALL` do?

## 🧠 Recall

1. What is a CTE and how long does it live?
2. What makes chaining possible — what can a later CTE see?
3. What are the two required parts of a recursive CTE?
4. When is a CTE better than a subquery in FROM?

## 🎤 Interview Questions

1. "What is a CTE and why use one over a nested subquery?"
2. "How does a recursive CTE work — seed and step?" *(Walk through the employee tree.)*
3. "Do CTEs improve performance?" *(Honest answer: they're about readability; modern planners usually inline them — Day 23 revisits.)*

## ✅ Completion Checklist

- [ ] Understand WITH, chained CTEs, recursion
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed combine task (the two-CTE user report)
- [ ] Answered recall without notes
- [ ] Can explain CTEs + recursion out loud

