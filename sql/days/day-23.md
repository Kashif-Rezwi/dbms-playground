# Day 23 — EXPLAIN & Query Plans

**Track:** SQL · **Stage:** 5 — Transactions + Performance · **Difficulty:** Advanced
**Prerequisites:** Day 22 · **Dataset:** `perf_lab`

## Goal

Read query plans — see *how* the database executes a query — and use them to diagnose fast vs slow.

## Fundamentals

Every query gets compiled into a **plan** by the **query planner**: which tables, in which order, using which indexes, which algorithm. `EXPLAIN` shows the plan; `EXPLAIN ANALYZE` *actually runs* it and reports real times:

```sql
EXPLAIN SELECT * FROM big_orders WHERE user_id = 417;
EXPLAIN ANALYZE SELECT * FROM big_orders WHERE user_id = 417;
```

**The nodes you'll see most:**

- **Seq Scan on big_orders** — reading the whole table. Fine for small tables; suspect for big ones.
- **Index Scan using idx_... on big_orders** — the index was used.
- **Bitmap Index Scan** — index finds candidate pages, then table rows fetched.
- **Nested Loop / Hash Join** — join strategies (PG track digs deeper).

**How to read a plan:** it's a tree, innermost first. Numbers that matter:

- **cost=0.00..5000.00** — planner's *estimate* (arbitrary units)
- **rows=1** — estimated result rows (wildly wrong rows = stale statistics!)
- **actual time=0.4..2.1 rows=1** *(ANALYZE only)* — the truth
- **loops=N** — this node ran N times

**Your diagnostic method, always the same:**

```text
1. EXPLAIN ANALYZE the slow query
2. Find the expensive node (highest actual time)
3. Ask: is it scanning everything (Seq Scan) when it should seek?
4. Check: is my WHERE column indexed? Are estimates ≈ actual rows?
5. Fix (index / rewrite) → re-run EXPLAIN ANALYZE → compare
```

**One warning:** `EXPLAIN ANALYZE` executes the query — never on a write you don't want (an UPDATE ANALYZEd is a real update).

## Why It Matters

"Slow query" complaints are the #1 database issue in real jobs. Reading plans is the difference between guessing and diagnosing — and it's exactly what interviewers probe when you say "performance tuning".

## Mental Model

> The planner is a **trip planner**: given "visit these tables under these conditions", it picks routes — highway (index) vs side streets (seq scan) — based on its *traffic estimates* (statistics). EXPLAIN shows the planned route; EXPLAIN ANALYZE shows the route *and* how the traffic actually was.

## Examples

```sql
-- plan only
EXPLAIN SELECT * FROM big_orders WHERE user_id = 417;

-- plan + execution (real numbers)
EXPLAIN ANALYZE SELECT * FROM big_orders WHERE user_id = 417;

-- watch the estimate quality
EXPLAIN ANALYZE SELECT * FROM big_orders WHERE status = 'delivered';

-- a join, with its two-sided tree
EXPLAIN ANALYZE
SELECT u.name, COUNT(*) FROM big_users u
JOIN big_orders o ON o.user_id = u.id
GROUP BY u.name;
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** EXPLAIN (plain) the `user_id = 417` query. Which node appears? What is the estimated `rows=`?

[Beginner] **W2.** Drop yesterday's index (`DROP INDEX idx_big_orders_user;`), EXPLAIN again. What changed? Recreate the index.

### 🔵 Core

[Intermediate] **C1.** `[Predict]` for `WHERE user_id = 417 AND status = 'pending'` — which node will appear and roughly why? Then check.

[Intermediate] **C2.** `[From Memory]` the 5-step diagnostic method, out loud.

[Intermediate] **C3.** EXPLAIN ANALYZE the same query. Write down: estimated rows vs actual rows — equal?

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Bug 1: EXPLAIN ANALYZE on a write — what danger?
EXPLAIN ANALYZE DELETE FROM big_orders WHERE user_id = 417;

-- Bug 2 (reading): plan says "Seq Scan" but your index on user_id exists.
-- Two hypotheses why. (Dropped? Or planner estimated seq cheaper —
-- what fixes bad estimates?)

-- Bug 3 (syntax):
EXPLAIN SELECT FROM big_orders WHERE user_id = 417;
```

[Advanced] **H2.** Full diagnostic loop on a slow query: "revenue per city" on the big dataset (join big_users to big_orders, group by city, excluding cancelled). EXPLAIN ANALYZE it, find the expensive node, add the index that helps most, re-EXPLAIN, and write a 2-sentence before/after report with numbers.

[Advanced] **H3.** Find a query where estimated rows differ *hugely* from actual rows (try date ranges or LIKE patterns). Then run `ANALYZE big_orders;` and re-EXPLAIN. What changed?

## Interview Questions

1. "A query is slow in production. Walk me through your process." *(The 5 steps — say the tool by name.)*
2. "What does EXPLAIN ANALYZE do that EXPLAIN doesn't — and what's the caveat?"
3. "The planner ignores your index. What are your next checks?"

## Completion Checklist

- [ ] Understand plans, nodes, estimates vs actuals
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Can run the 5-step method from memory
