# Day 25 — Server Configuration & Maintenance (VACUUM)

**Track:** PostgreSQL · **Stage:** 6 — Security & Ops · **Difficulty:** Intermediate → Advanced

## Goal

Understand VACUUM as MVCC's cleanup crew, meet the autovacuum system honestly, and know which server settings a developer (not a DBA) actually touches.

## Fundamentals

**VACUUM closes the MVCC loop** (Day 18's promise): dead row versions must eventually be *reclaimed*. Without vacuum, tables bloat forever — every UPDATE leaves a corpse behind.

```sql
VACUUM users;             -- reclaim space for REUSE (fast, no meaningful locks)
VACUUM FULL users;        -- rewrite entire table (recovers disk; ACCESS EXCLUSIVE lock — careful!)
VACUUM ANALYZE users;     -- reclaim + refresh statistics
```

**Autovacuum** — the built-in daemon: watches `n_dead_tup` thresholds per table and vacuums when crossed. Usually right; classic tuning moments:

- **Write-heavy tables** need it *more often* (lower per-table thresholds)
- **Huge tables with low churn** — threshold scaling makes it rare; fine
- **Long transactions** block cleanup regardless (Day 18 P8 — the root cause of most "autovacuum isn't working" reports)

**The visibility map** — tracks "all-visible" pages; what makes **Index Only Scans** actually index-only (Day 14 P7's mystery resolved!). Vacuum maintains it.

**The settings a developer touches (in real life):**

| Setting | Default | Touch when |
|---|---|---|
| `work_mem` | 4MB | per-session heavy sorts (SET LOCAL — Day 24) |
| `effective_cache_size` | 4GB | a *hint* to the planner about OS cache — not an allocation |
| `autovacuum_vacuum_scale_factor` | 0.2 | write-heavy big tables (per-table overrides) |
| `shared_buffers` | 128MB | server sizing (DBA territory — measure first) |

**Your maintenance health check:**

```sql
SELECT relname, n_dead_tup, n_live_tup,
       round(100.0 * n_dead_tup / nullif(n_live_tup + n_dead_tup, 0), 1) AS dead_pct,
       last_autovacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;
-- double-digit dead_pct on a big table + old last_autovacuum = investigate
```

## Why It Matters

PostgreSQL databases that "just get slower over months" are almost always bloat stories. Knowing vacuum/autovacuum/visibility lets you diagnose the #1 chronic performance disease.

## Mental Model

> VACUUM is **hotel housekeeping**: it doesn't demolish rooms (VACUUM FULL does, with the hotel closed) — it declares corpse-furniture rooms *available for reuse*. The visibility map is the "this floor is clean" sign — Index Only Scans trust it. Long transactions are guests who won't leave, so housekeeping skips their floors; dirt accumulates.

## Practice

[Beginner] **P1.** Make corpses: `UPDATE big_users SET name = name WHERE id <= 50000;` → check `n_dead_tup`. `VACUUM big_users;` → re-check. Where did they go? (Space is *reusable*, not returned to the OS — check `pg_relation_size` before/after: same!)
[Beginner] **P2.** `\h VACUUM` — read the honest description of VACUUM vs VACUUM ANALYZE; one line each.
[Intermediate] **P3.** Bloat generator + FULL: update a big chunk 3×, VACUUM (size unchanged), then VACUUM FULL (size drops!) — but from a second session, watch it block a concurrent SELECT. Two lessons, one experiment.
[Intermediate] **P4.** Visibility map, verified: Day 14 P7's repeat — Index Only Scan with Heap Fetches, VACUUM, re-run → Heap Fetches ≈ 0. Write the two-line explanation.
[Intermediate] **P5. Predict first:** after updating 50k rows with NO vacuum, what does `SELECT count(*) FROM big_users;` read — and what does a "dead" count read? (MVCC: counts read *visible* versions — unchanged. Bloat is invisible to queries; it only costs time and space.)
[Intermediate] **P6.** `SHOW autovacuum;` — generate churn on a small table; watch `last_autovacuum` update (patience, or force VACUUM to see the effect manually).
[Advanced] **P7.** Run the health-check query on all your databases; interpret each table's dead_pct in one line; name the table you'd investigate first and why.
[Advanced] **P8.** The "autovacuum isn't keeping up" diagnosis tree, written: three root causes (long transactions; threshold scaling on huge tables; anti-wraparound vacuum pressure) + the tell-tale + fix for each. A genuine on-call skill.

## Debugging

```sql
-- Bug 1: "disk usage only grows, never shrinks, but queries work."
-- Diagnose (bloat: corpses + reuse-not-return) and two fixes
-- (VACUUM FULL in a window; pg_repack online).
-- Bug 2: autovacuum "never runs" on a 300GB mostly-updated table.
-- What does scale_factor 0.2 mean at that size? Fix: per-table thresholds.
-- Bug 3: Index Only Scans show Heap Fetches = huge. What maintenance is
-- lagging, and who maintains the visibility map?
```

## Combine Concepts

The full-circle write: redo Day 18's write-path memo — now with vacuum's role and the visibility map added. Seven sentences: WAL → new row version → old version dead → autovacuum → space reuse + visibility map → honest Index Only Scans → VACUUM FULL as the nuclear option. If this reads clearly, you own the engine's write path.

## Previous Knowledge

1. The 7-step tuning checklist — tools for steps 1, 2, 5?
2. What does seq_tup_read tell you?
3. pg_stat_statements — sort by total vs mean, when?
4. MVCC — why do long transactions cause bloat?

## Recall

1. VACUUM vs VACUUM FULL — one line each (locks included).
2. What does autovacuum do, and what blocks it?
3. What is the visibility map and who maintains it?
4. Which settings does a *developer* touch vs a DBA? (Which is only a *hint*?)

## Interview Questions

1. "What is table bloat in PostgreSQL and how do you fix it?" *(MVCC corpses + vacuum reuse-not-return; autovacuum tuning; VACUUM FULL/pg_repack.)*
2. "What does autovacuum do, and what are its failure modes?" *(Thresholds, long transactions, huge tables.)*
3. "Why did my Index Only Scan stop being index-only?" *(Stale visibility map — vacuum.)*

## Completion Checklist

- [ ] Understand vacuum/autovacuum/visibility, settings ownership
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Wrote the upgraded write-path memo
- [ ] Answered recall without notes

