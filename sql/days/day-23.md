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

[Beginner] **P1.** EXPLAIN (plain) the `user_id = 417` query. Which node appears? What is the estimated `rows=`?
[Beginner] **P2.** Drop yesterday's index (`DROP INDEX idx_big_orders_user;`), EXPLAIN again. What changed? Recreate the index.
[Beginner] **P3.** EXPLAIN ANALYZE the same query. Write down: estimated rows vs actual rows — equal?
[Intermediate] **P4.** EXPLAIN ANALYZE `WHERE status = 'delivered'`. Did the planner choose a Seq Scan *on purpose*? Explain why that's correct.
[Intermediate] **P5. Predict first:** for `WHERE user_id = 417 AND status = 'pending'` — which node will appear and roughly why? Then check.
[Intermediate] **P6.** Run the join example. Identify the two child nodes of the join node.
[Advanced] **P7. From memory:** the 5-step diagnostic method, out loud.
[Advanced] **P8.** Find a query where estimated rows differ *hugely* from actual rows (try date ranges or LIKE patterns). Then run `ANALYZE big_orders;` and re-EXPLAIN. What changed?
[Advanced] **P9.** Explain why `WHERE user_id = 417` and `WHERE user_id + 0 = 417` give different plans. (Indexes die at functions.)

## Debugging

```sql
-- Bug 1: EXPLAIN ANALYZE on a write — what danger?
EXPLAIN ANALYZE DELETE FROM big_orders WHERE user_id = 417;

-- Bug 2 (reading): plan says "Seq Scan" but your index on user_id exists.
-- Two hypotheses why. (Dropped? Or planner estimated seq cheaper —
-- what fixes bad estimates?)

-- Bug 3 (syntax):
EXPLAIN SELECT FROM big_orders WHERE user_id = 417;
```

## Combine Concepts

Full diagnostic loop on a slow query: "revenue per city" on the big dataset (join big_users to big_orders, group by city, excluding cancelled). EXPLAIN ANALYZE it, find the expensive node, add the index that helps most, re-EXPLAIN, and write a 2-sentence before/after report with numbers.

## Previous Knowledge

1. Two costs of an index?
2. What's selectivity, and why does an index on a mostly-TRUE column fail?
3. ACID — four letters, one line each.
4. What does ROLLBACK undo?

## Recall

1. What does EXPLAIN show vs EXPLAIN ANALYZE?
2. Seq Scan — when is it a problem, and when is it *correct*?
3. What does a bad rows-estimate suggest, and how do you fix it?
4. The 5-step diagnostic method?

## Interview Questions

1. "A query is slow in production. Walk me through your process." *(The 5 steps — say the tool by name.)*
2. "What does EXPLAIN ANALYZE do that EXPLAIN doesn't — and what's the caveat?"
3. "The planner ignores your index. What are your next checks?"

## Completion Checklist

- [ ] Understand plans, nodes, estimates vs actuals
- [ ] Completed P1–P9 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the diagnostic-loop combine task with numbers
- [ ] Answered recall without notes
- [ ] Can run the 5-step method from memory

