# Day 22 — Indexes: The Concept & the Trade-offs

**Track:** SQL · **Stage:** 5 — Transactions + Performance · **Difficulty:** Intermediate
**Prerequisites:** Days 01–21 · **Dataset:** `perf_lab` — load it: `./scripts/utilities/load-large-postgres.sh`

## Goal

Understand what an index *is*, why it makes reads faster, and what it costs — then prove both on ~500k real rows.

## Fundamentals

**What is an index?** A sorted copy of (some of) the data, kept in a searchable structure — usually a **B-tree** (a balanced sorted tree). Think of a book index: instead of reading every page (a **sequential scan**), you jump straight to the right page.

**Without an index:** finding rows with `user_id = 417` means checking **every row** — O(n). On 200k rows, every query pays that.

**With an index:** the tree is walked — O(log n) — roughly 17 steps for 200k rows, then direct fetch.

**The cost (this is the part interviews want you to know):**

- **Writes get slower** — every INSERT/UPDATE/DELETE must also update the index
- **Disk usage** — the index is a real structure
- **The planner can ignore it** — an index on `user_id` does nothing for a query filtering `status`

**Why every table isn't covered in indexes:** because of the write cost. You index the columns your queries actually filter/join/sort on.

## Why It Matters

Indexing is the highest-leverage performance skill in daily database work. The difference between "0.2 ms" and "3 seconds" on one query, multiplied by every user, is the difference between fine and down.

## Mental Model

> A table is a **warehouse of unsorted boxes**. A sequential scan opens every box. An index is the **inventory system**: look up "user 417" → aisle 3, shelf 2. But every new box now also has to be *logged in the inventory system* — that's the write cost.

## Examples

```sql
-- where are we? (timing on!)
\timing on

-- no index exists — watch the cost
SELECT * FROM big_orders WHERE user_id = 417;

-- add the index
CREATE INDEX idx_big_orders_user ON big_orders(user_id);

-- same query, watch it again
SELECT * FROM big_orders WHERE user_id = 417;

-- see what indexes exist
\d big_orders
```

## Practice

[Beginner] **P1.** Load `perf_lab` (`./scripts/utilities/load-large-postgres.sh`), turn on `\timing`, and run the `user_id = 417` query *before* indexing. Record the ms.
[Beginner] **P2.** Create the index. Rerun. Record the ms. Write one sentence: how many times faster?
[Beginner] **P3.** `\d big_orders` — find your index in the listing.
[Intermediate] **P4.** Now time a query that filters on `ordered_at` (a *different* column): `SELECT count(*) FROM big_orders WHERE ordered_at = DATE '2025-01-15';` — slow again? Why didn't the user_id index help?
[Intermediate] **P5.** Create an index on `ordered_at`, rerun P4's query. Compare.
[Intermediate] **P6. Predict first:** will this query use your `user_id` index? Why or why not? Then find out (Day 23 gives the tool, but you can guess by timing):

```sql
SELECT * FROM big_orders WHERE user_id = 417 OR status = 'pending';
```

[Intermediate] **P7. From memory:** create an index on `big_order_items.order_id`. Time the difference on `SELECT * FROM big_order_items WHERE order_id = 100000;`
[Advanced] **P8.** Range query: time `SELECT * FROM big_orders WHERE ordered_at BETWEEN '2025-01-01' AND '2025-01-31'` before and after an index on `ordered_at`. Does an index help ranges, or only equality? Write one sentence.
[Advanced] **P9.** The write cost, measured: time `INSERT INTO big_users ... ` (one row, any values, id 60000) — then DROP both indexes on big tables that reference writes... actually simpler: create 3 more indexes on big_orders, then insert one row and time it. Now drop all 5 indexes, insert, time again. Feel the write tax.

## Debugging

```sql
-- Bug 1 (logical): "my index isn't being used!" 
CREATE INDEX idx_status ON big_orders(status);
SELECT * FROM big_orders WHERE status = 'delivered';
-- Hmm — this is most of the table. Why might scanning be FASTER than using the
-- index here? (Concept: selectivity — an index pays off when it narrows a lot.)

-- Bug 2 (design): indexes on EVERY column. What happens to insert throughput
-- on this table? (You measured it in P9 — extrapolate to 10 indexes.)

-- Bug 3 (functional): 
SELECT * FROM big_users WHERE name LIKE '%User 42%';
-- Index on name wouldn't help. Why? (Pattern starts with % — the tree can't
-- jump. What WOULD use the index: LIKE 'User 42%'. Verify with a timing test.)
```

## Combine Concepts

Everything together: find the top 5 users by **total delivered revenue** on the big dataset (`big_orders` + GROUP BY + ORDER + LIMIT). Before creating any index, time the join+group query. Then add an index on `big_orders(user_id, status)`... rerun. Which index matters for the GROUP BY key? (Composite index order — a taste of tomorrow's PG-track depth.)

## Previous Knowledge

1. ACID — the four letters, one line each.
2. What can't ROLLBACK undo?
3. Write from memory: the safe-experiment pattern (BEGIN/DELETE/ROLLBACK).
4. 1NF violation example — one line.

## Recall

1. What structure does a typical index use, and why is lookup O(log n)?
2. Two costs of an index — name both.
3. When does an index NOT help (two cases: wrong column / low selectivity)?
4. What's a sequential scan?

## Interview Questions

1. "What is an index and why does it speed up queries?" *(B-tree, no full scan.)*
2. "What are the trade-offs of adding an index?" *(Write cost + storage + planner choice.)*
3. "You added an index but the query didn't speed up. What are your hypotheses?" *(Wrong column, OR'd conditions, low selectivity, stale statistics, function on the column...)*

## Completion Checklist

- [ ] Understand index structure, benefits, costs
- [ ] Measured before/after timings (wrote them down!)
- [ ] Completed P1–P9 (P6 predicted first)
- [ ] Fixed all three "bugs" (they're diagnostic thinking exercises)
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Can explain index trade-offs out loud
