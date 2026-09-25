# Stage Review 3 — Performance & Transactions (SQL Days 21–27)

Do this *after* Day 27, before the Day 28 final review.

## Part A — Concept Check

1. ACID — the four letters, each with a story you lived.
2. What does ROLLBACK undo? What does COMMIT finalize?
3. Index: what structure, what benefit, what two costs?
4. When is a Seq Scan *correct*? (Selectivity!)
5. The 5-step slow-query method — from memory.
6. Keyset pagination — why it beats deep OFFSET.
7. Why do functions on columns kill indexes?
8. View vs materialized view — the trade in one line.
9. The 6-question normalize-vs-denormalize framework.

## Part B — Query Drills (dataset: `perf_lab` + `ecommerce`)

[Intermediate] 1. On `perf_lab`: EXPLAIN ANALYZE `WHERE user_id = 417`. Name the node, estimated vs actual rows.
[Intermediate] 2. Drop that index; re-run; recreate; re-run. Write all three timings.
[Intermediate] 3. Write the keyset version of "page 4 of 10" for `big_orders` ordered by `ordered_at`.
[Intermediate] 4. On `ecommerce`: a transaction that inserts an order + item, then deliberately fails on a CHECK (negative quantity), proving nothing survived.
[Advanced] 5. "Top 5 users by delivered revenue on perf_lab" — naive version, EXPLAIN ANALYZE, one index, one rewrite, before/after report.
[Advanced] 6. Design judgment: for each, index it, denormalize it, or leave it — defend in one line each:
   - "Find user by email" on a 50M-row users table
   - "Product's review avg on page view" with 1000s of reviews
   - "Monthly active users" report run once a day

## Part C — Debugging Gauntlet

```sql
-- A: the plan says Seq Scan but the index on user_id exists. Two hypotheses,
--    and the command that fixes the statistics one.
-- B: EXPLAIN ANALYZE UPDATE products SET stock = 0;  -- what happens and
--    why should this sentence scare you?
-- C: this "index" does nothing for the query. Why?
CREATE INDEX idx_upper ON big_users (UPPER(email));
SELECT * FROM big_users WHERE email = 'ayesha@example.com';
```

## Part D — Mini Interview (out loud)

1. "A query got slow in production. Your process?"
2. "Why can indexes hurt write performance — and when do you accept that?"
3. "How do transactions protect data — give me a real example."

**After this: Day 28 (full review) → Days 29–30 (capstone).**
