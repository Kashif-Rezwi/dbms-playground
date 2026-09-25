# Stage Review 2 — Modeling & Advanced Queries (SQL Days 11–20)

Do this *after* Day 20. (Days 11–15 got their warm-up check at the top of Day 16 — this review covers 16–20 plus integration of everything.)

## Part A — Concept Check

1. INNER vs LEFT JOIN — and the LEFT JOIN + WHERE trap in one sentence.
2. Correlated subquery — definition + cost. When does it beat a JOIN?
3. CTE vs nested subquery — why do working developers prefer CTEs?
4. Window function vs GROUP BY — input rows vs output rows.
5. ROW_NUMBER vs RANK vs DENSE_RANK — ties and gaps.
6. The three anomalies — with one-line examples.
7. 1NF, 2NF, 3NF — one line each, and the working rule.
8. What does EXPLAIN ANALYZE do that EXPLAIN doesn't — and the write caveat?

## Part B — Query Drills (dataset: `saas`, reset first)

[Beginner] 1. Every task with its project name and assignee name (3-table join).
[Intermediate] 2. Projects with zero tasks.
[Intermediate] 3. Organizations and their open (non-overdue... pick: status <> 'paid') invoice totals, including orgs with none.
[Intermediate] 4. Per-organization: task count, done count, done % (FILTER + ROUND).
[Intermediate] 5. The top-2 tasks per project by priority... by `created_at` (row_number pattern).
[Intermediate] 6. A CTE `late` (projects past deadline), chained into a CTE `late_tasks`, final output: project name + count of *unassigned* late tasks.
[Advanced] 7. Organizations whose average invoice amount is above the overall average — CTE + correlated subquery.
[Advanced] 8. A window report: every invoice with its running total *per organization* (SUM OVER PARTITION BY org_id ORDER BY issued_at).
[Advanced] 9. Design: this table violates which NF levels?

```text
timesheets(emp_id, emp_name, dept, dept_head, week, hours_json_text)
```

Write the normalized version (tables + keys, prose is fine).

## Part C — Debugging Gauntlet

```sql
-- A: returns nothing but should return 2 orgs
SELECT o.name FROM organizations o
LEFT JOIN invoices i ON i.org_id = o.id
WHERE i.amount > 500;

-- B: this "per-project count" is wrong. Two bugs.
SELECT p.name, COUNT(*) FROM projects p
JOIN tasks t ON t.project_id = p.id;

-- C: window filter that can't work
SELECT title, ROW_NUMBER() OVER (ORDER BY created_at) AS rn
FROM tasks WHERE rn = 1;
```

## Part D — Mini Interview (out loud)

1. "Explain the LEFT JOIN + WHERE trap."
2. "How would you get the top N per group?"
3. "Normalize this: `orders(id, customer_name, items_csv)` — walk me through it."

**Shaky anywhere?** Re-do that day's recall tomorrow morning. Then: Transactions await (Day 21).
