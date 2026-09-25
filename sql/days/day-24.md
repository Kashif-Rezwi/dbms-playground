# Day 24 — Optimization Patterns

**Track:** SQL · **Stage:** 5 — Transactions + Performance · **Difficulty:** Advanced
**Prerequisites:** Days 01–23 · **Dataset:** `perf_lab` · **Milestone:** Project 6

## Goal

Learn the recurring causes of slow queries and their fixes — and prove several with measurements.

## Fundamentals

**Pattern 1 — Filter early.** The less data flows through joins/aggregates, the faster everything after. Push conditions as close to the source tables as possible (a WHERE inside a subquery beats a WHERE outside a join of everything).

**Pattern 2 — Don't ask for data you don't use.**

```sql
SELECT * FROM big_orders;                        -- 200k rows, all columns, over the wire
SELECT id, status FROM big_orders WHERE ...      -- only what's needed
```
Especially fatal: `COUNT(*)` for "does it exist" — use `EXISTS` / `LIMIT 1`.

**Pattern 3 — `SELECT *` + JOIN = multiplied data.** Select only the columns you output.

**Pattern 4 — OFFSET pagination degrades.** `LIMIT 10 OFFSET 190000` still *reads* 190,010 rows to skip them. For deep pages, **keyset pagination**:

```sql
WHERE (created_at, id) < (last_seen_created_at, last_seen_id)
ORDER BY created_at DESC, id DESC LIMIT 10
```

**Pattern 5 — functions on indexed columns kill indexes** (you saw it Day 23):

```sql
WHERE LOWER(email) = 'a@x.com'                    -- index on email: ignored
WHERE created_at + INTERVAL '1 day' < ...         -- index on created_at: ignored
```
Fix: transform the *constant* instead of the column, or make the index match the expression.

**Pattern 6 — correlated subqueries in SELECT over many rows.** Sometimes the planner fixes it; sometimes it re-runs per row. Compare plans against a window-function rewrite.

**The workflow for ANY slow query:** measure (Day 23) → identify expensive node → match a pattern → fix → re-measure.

## Why It Matters

These five or six patterns cover most real-world "why is this slow" cases. Knowing them turns optimization from luck into method.

## Mental Model

> A query is a **factory conveyor**: rows enter, get filtered, joined, sorted, packed. Optimization = removing work from the belt — reject defective items at the door (filter early), carry fewer boxes (fewer columns), don't walk the belt to slot 190000 (keyset), don't put items in disguise machines at check-in (functions on columns).

## Examples

```sql
-- EXISTS instead of COUNT for existence
SELECT EXISTS (SELECT 1 FROM big_orders WHERE user_id = 417);

-- filter early: subquery pre-narrows the join input
SELECT u.name, sub.total
FROM big_users u
JOIN (
    SELECT user_id, SUM(total_amount) AS total
    FROM big_orders
    WHERE status <> 'cancelled'          -- filter INSIDE
    GROUP BY user_id
) sub ON sub.user_id = u.id
WHERE sub.total > 5000;

-- keyset pagination (remember the last row you showed!)
SELECT id, name, created_at FROM big_products
WHERE (created_at, id) < ('2024-05-01', 3000)
ORDER BY created_at DESC, id DESC
LIMIT 10;
```

## Practice

[Beginner] **P1.** Time `SELECT * FROM big_orders LIMIT 100000` vs `SELECT id FROM big_orders LIMIT 100000`. Explain the gap.
[Beginner] **P2.** `SELECT EXISTS (SELECT 1 FROM big_orders WHERE user_id = 417);` vs `SELECT COUNT(*) ... WHERE user_id = 417;` — compare plans. Which can stop early?
[Intermediate] **P3.** Measure OFFSET degradation: time `LIMIT 10 OFFSET 1000`, `OFFSET 100000`, `OFFSET 190000` on big_orders ordered by id. Plot ms vs offset in your notes.
[Intermediate] **P4.** Convert to keyset: "next 10 orders after id 150000". Compare timing with OFFSET at the same depth.
[Intermediate] **P5. Predict first:** which is faster and why —

```sql
SELECT COUNT(*) FROM big_orders WHERE ordered_at >= DATE '2025-06-01';
SELECT COUNT(*) FROM big_orders WHERE ordered_at - DATE '2025-01-01' > 150;
```

Then measure. Which can use an index on `ordered_at`?
[Intermediate] **P6. From memory:** rewrite `WHERE UPPER(city) = 'KARACHI'` so it can use an index.
[Advanced] **P7.** Correlated-vs-window showdown: "each order with the average total of its user's orders." Write both versions (correlated subquery in SELECT; `AVG() OVER (PARTITION BY user_id)`). EXPLAIN ANALYZE both. Which wins? Why?
[Advanced] **P8.** Over-fetch audit: for "top 5 products by revenue", check the plan for how much data flows *before* the LIMIT. Would a CTE-with-limit rewrite be equivalent? (Careful: LIMIT before GROUP BY changes semantics — when is it safe?)

## Debugging

```sql
-- Bug 1 (performance): why will app page 20,000 be slow?
SELECT * FROM big_orders ORDER BY id LIMIT 10 OFFSET 200000;

-- Bug 2 (performance): why can't an index on user_id ever be used here?
SELECT * FROM big_orders WHERE user_id * 2 = 834;

-- Bug 3 (logical + performance): "does user 417 have delivered orders?"
SELECT * FROM big_orders WHERE user_id = 417 AND status = 'delivered';
-- Correct but wasteful for a yes/no question. Rewrite it.
```

## Combine Concepts

The report that uses everything: "each user's total delivered revenue, top 10, with rank" — write the naive version, EXPLAIN ANALYZE, optimize with CTE pre-aggregation, re-measure, and write a before/after report. This is exactly Project 6's workflow.

## Previous Knowledge

1. EXPLAIN vs EXPLAIN ANALYZE — one line + the write caveat.
2. What is selectivity?
3. Two costs of any index?
4. The 5-step diagnostic method — from memory.

## Recall

1. Name four optimization patterns with one line each.
2. Why does deep OFFSET get slow, and what's the fix?
3. Why do functions on columns break index use?
4. When is `SELECT *` actually fine?

## Interview Questions

1. "How would you speed up a slow query?" *(Measure, then patterns — name two.)*
2. "How does keyset pagination work and when do you need it?"
3. "Why is `WHERE YEAR(created_at) = 2025` slower than a range query, and how do you fix it?"

## Mini Project — Stage 5 complete!

Build **[P6: Query Performance Lab](../projects/06-performance-lab.md)** — a slow-query investigation from start to finish, with a written report. Attempt before solutions.

## Completion Checklist

- [ ] Understand the optimization patterns
- [ ] Measured every before/after (numbers in notes)
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed combine task with a written report
- [ ] Answered recall without notes
- [ ] Started Project 6

