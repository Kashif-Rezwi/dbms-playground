# Day 14 — Composite, Partial, Unique & Expression Indexes

**Track:** PostgreSQL · **Stage:** 4 — Indexes & Planner · **Difficulty:** Intermediate → Advanced

## Goal

Master the four index *shapes* that answer real queries — and the ordering rule everyone gets wrong.

## Fundamentals

**1. Composite indexes — the rule: order = equality columns first, then range/sort column.**

```sql
-- query: WHERE user_id = ? AND ordered_at > ? ORDER BY ordered_at DESC
CREATE INDEX idx_orders_user_date ON big_orders (user_id, ordered_at DESC);
```

Why: the tree sorts by (user_id, then ordered_at). Equality on the *first* column navigates to one subtree; the second column there is already ordered → range + ORDER BY for free. **The reverse order** `(ordered_at, user_id)` can't serve "this user's orders" — date subtrees contain *all* users.

Leftmost-prefix: `(a, b)` also serves queries filtering only `a`. It does NOT serve `b` alone.

**2. Partial indexes — index only the interesting slice:**

```sql
CREATE INDEX idx_pending ON orders (created_at) WHERE status = 'pending';
-- 200M-row table, 2k pending rows → tiny, hot index for the support queue
```

**3. Unique indexes = constraints** (Day 7's ground) — `lower(email)`, partial one-active-per-user.

**4. Expression indexes — index the *computed* value:**

```sql
CREATE INDEX idx_users_email_lower ON big_users (lower(email));
-- now lower(email) = 'x' seeks instead of scanning
```

**5. Included columns (covering indexes):**

```sql
CREATE INDEX idx_orders_user_inc ON big_orders (user_id) INCLUDE (status);
-- queries selecting user_id+status become Index Only Scan — heap untouched
```

**Strategy beats reflex:** write down the app's top 5 queries → design the fewest indexes that serve them → measure. Every index is a write tax; composite/partial/include are how you get *multiple queries per index*.

## Mental Model

> Composite index = a **phone book sorted by (last, first)**: "all Khans" = one subtree; "Khans named Ali, in order" = walk that subtree. Sorting by (first, last) makes "all Khans" a wild goose chase. Partial = **only the VIPS get a card in the rolodex**. Include = the rolodex card *also* has the phone number — you never open the main file.

## Practice

[Beginner] **P1.** Build `(user_id, ordered_at DESC)` on perf_lab; EXPLAIN user+date-range+ORDER BY — seek with no sort. Then drop, add `(ordered_at, user_id)`, re-run. Write the two plans side by side and the one-line verdict.
[Beginner] **P2.** Leftmost prefix proof: with `(user_id, ordered_at)`, EXPLAIN `WHERE ordered_at = ...` alone — used or not? (Predict first!)
[Intermediate] **P3.** Partial: in `ecommerce`, index only 'pending' orders, EXPLAIN the support query, compare index size to a full index (`pg_relation_size`).
[Intermediate] **P4.** Expression: create `lower(email)` index on big_users; EXPLAIN `WHERE lower(email) = ...` before/after. (Day 13 Bug 1, resolved.)
[Intermediate] **P5. Predict first:** `WHERE user_id = 417 AND status = 'pending'` — what does `(user_id, ordered_at)` buy, what's still done after the seek (filter on status), and would `(user_id, status)` serve *this* query better? Reason, then check both plans.
[Advanced] **P6. From memory:** the partial index for "active users by email" (Day 7's design).
[Advanced] **P7.** Covering: `INCLUDE (status)`; EXPLAIN (ANALYZE, BUFFERS) `SELECT user_id, status FROM big_orders WHERE user_id = 417` — find "Index Only Scan" + Heap Fetches ≈ 0. Now update one of those rows and re-run: heap fetches return. Explain (visibility map — Day 25 hook).
[Advanced] **P8.** The design memo: given top-5 queries (user lookup by email; a user's recent orders; pending queue by age; monthly revenue by city; product by id) — write the *minimum* index set (≤4) and map each query to its serving index. Defend every exclusion.

## Debugging

```sql
-- Bug 1: "I indexed (created_at, user_id) but the user's-orders query
-- doesn't use it." Diagnose + fix (swap the composite).
-- Bug 2: partial index on (created_at) WHERE status='pending' — the
-- query WHERE status='pending' AND user_id=417 runs. Does it use the
-- index? Should it? (Narrowness vs missing user column.)
-- Bug 3: unique index on lower(email) exists, but dupes "A@x.com" and
-- "a@x.com" got in *before* the index. Remediation sequence?
```

## Combine Concepts

Audit + fix `ecommerce` end to end: list its hot queries (from SQL-track days); check which FK columns lack indexes (Day 6's trap); design the minimal index set; apply; re-run your SQL-track analytics battery and record before/after timings. That's Project 3's warm-up.

## Previous Knowledge

1. Why does a B-tree serve ORDER BY?
2. Heap fetches — why does an index scan touch the heap?
3. `ON CONFLICT` needs what?
4. SQL: keyset pagination — the fix for deep OFFSET.

## Recall

1. The composite-order rule?
2. Leftmost prefix — what does `(a,b)` serve besides both?
3. Partial index — when does it shine?
4. What does INCLUDE buy, and what breaks it?

## Interview Questions

1. "You have `WHERE a = ? AND b > ? ORDER BY b` — design the index." *(a, b — and explain the order rule.)*
2. "What's a partial index good for?"
3. "Case-insensitive lookups keep scanning — what do you do?"

## Completion Checklist

- [ ] Understand composite ordering, prefixes, partial, INCLUDE, expression indexes
- [ ] Completed P1–P8 (P5 reasoned first)
- [ ] Fixed all three bugs
- [ ] Completed the ecommerce index audit
- [ ] Answered recall without notes

