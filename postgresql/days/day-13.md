# Day 13 — B-tree Indexes, Properly

**Track:** PostgreSQL · **Stage:** 4 — Indexes & Planner · **Difficulty:** Intermediate
**Prerequisites:** SQL Day 22 (concept) — today goes deeper: what the structure *is*, what PostgreSQL does with it.

## Goal

Understand B-trees concretely (pages, tree depth, ordering), the index types PostgreSQL offers, and when each applies.

## Fundamentals

**B-tree in concrete terms:** a balanced tree of **pages** (8KB blocks). Root → internal nodes → **leaf pages**, each holding sorted (key, row-pointer) pairs. Lookup = root-to-leaf walk — a 10-million-row index is ~3–4 levels deep; *every* lookup costs ~4 page reads, not 10,000,000 comparisons.

**Sortedness is the superpower.** A B-tree index isn't just for `=`:
- `WHERE x > 5` — seek to 5, read rightward
- `ORDER BY x` — walk leaves in order (no sort node!)
- `MIN/MAX(x)` — leftmost/rightmost leaf
- `LIKE 'abc%'` — prefix is a range... `LIKE '%abc'` is **not** (Day 22's lesson, now structural)

**PostgreSQL's index types** (the ones that matter):

| Type | Serves | Classic use |
|---|---|---|
| **B-tree** (default) | `=, <, >, BETWEEN, ORDER BY, prefix LIKE` | almost everything |
| **GIN** | containment in jsonb/arrays/full-text | JSONB `@>`, tag search |
| **BRIN** | ranges over huge, physically-ordered tables | append-only time series |
| **GiST/SP-GiST** | geometry, ranges, nearest-neighbor | geo, scheduling |
| **Hash** | only `=` (rarely worth it) | niche |

**Index vs heap, the detail that explains EXPLAIN:** an index scan finds the *pointers*, then fetches each row from the **heap** (the table) — two lookups per row. A **bitmap index scan** softens that (fetch pages in bulk).

## Why It Matters

You used indexes blind (SQL Day 22). From here, every EXPLAIN you read is interpretable: *why* 4 page reads, why sorts vanish, why `%prefix` patterns die.

## Mental Model

> A B-tree is a **library's call-number system**: root = floor directory, internal = shelf aisles, leaves = shelves of *sorted* books, each with a slip telling you the exact storage room + box (heap fetch). Sortedness means range queries are "walk one shelf from here", and ORDER BY is "read the shelves in order" — the sort never happens.

## Practice

### 🟢 Warm Up

[Beginner] **W1.** On `perf_lab`: create `idx_big_orders_ordered ON big_orders(ordered_at)`; EXPLAIN `WHERE ordered_at = DATE '2025-03-01'` — Index Scan. Now EXPLAIN `ORDER BY ordered_at LIMIT 5` — look: **no Sort node**. Explain why in one line.

[Beginner] **W2.** `SELECT MIN(ordered_at) FROM big_orders;` with and without the index — compare plans (look for "Result ... InitPlan" — the index answers MIN instantly from the leftmost leaf).

### 🔵 Core

[Intermediate] **C1.** `[Predict]` which uses the index — `LIKE '2025%'` vs `LIKE '%2025'` on a TEXT date column? Both plans before running.

[Intermediate] **C2.** `[From Memory]` create a B-tree on `big_users(email)`; find user by exact email; time it.

[Intermediate] **C3.** Tree depth, estimated: `SELECT pg_relation_size('idx_big_orders_ordered') / 8192 AS pages;` — a few hundred pages ≈ depth 2–3. Compute pages for a hypothetical 10× table; depth barely moves. State the O(log n) consequence in your notes.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Bug 1: Index exists on email; this query scans the whole table. Why?
SELECT * FROM big_users WHERE lower(email) = 'user417@example.com';
-- (Two fixes: expression index — Day 14; or store normalized.)

-- Bug 2: "Index Only Scan" disappeared after you updated rows. What
-- happened to the visibility map? (vacuum interplay — Day 25 preview)

-- Bug 3: a Hash index on status "because status is never ranged".
-- Works... but rebuild it as B-tree on general principle: what three
-- things does B-tree do that Hash never will? (ORDER BY, ranges, NULLs)
```

[Advanced] **H2.** The composite report: query "orders for user 417 in March 2025, newest first" — no index, then single `user_id`, then `(user_id, ordered_at)`. Three plans, three timings, one paragraph: what did each index buy, and why does the composite answer the ORDER BY too? (Day 14 is literally this — you're arriving early.)

[Advanced] **H3.** BRIN experiment: create `big_logs` (5M rows, id, ts, message) with generate_series where ts increases monotonically. Compare index size: B-tree on ts vs `USING BRIN (ts)`. Query a 1-hour window with each. Report the size difference and when BRIN's assumption (physical order ≈ key order) breaks (bulk-deleted/updated data).

## Interview Questions

1. "How does a B-tree index actually work?" *(Pages, sorted leaves, log-depth, heap fetch.)*
2. "Why can an index serve ORDER BY?" 
3. "When would you use BRIN instead of B-tree?" *(Huge append-only physically-sorted tables.)*

## Completion Checklist

- [ ] Understand B-tree structure, heap fetches, index types
- [ ] Completed Warm Up, Core, and Challenge exercises
