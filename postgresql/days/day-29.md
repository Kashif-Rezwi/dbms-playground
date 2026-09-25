# Day 29 — Full Review + Mock Interview

**Track:** PostgreSQL · **Stage:** 7 · No new material — consolidation.

## Part A — Concept Check (write first, verify after)

1. Client/server + process model + WAL — what does WAL guarantee? (Days 1, 4)
2. Databases vs schemas vs search_path; catalog queries for structure. (Day 2)
3. The five type decisions (money, timestamps, text, ints, special). (Day 3)
4. Identity vs SERIAL vs sequences; gaps; RETURNING. (Day 5)
5. FK behaviors + the missing-index trap. (Day 6)
6. Partial unique / expression indexes / EXCLUDE — one use each. (Day 7)
7. View vs materialized; CONCURRENTLY; security_invoker. (Day 8)
8. Function volatility — the three tags and the lie's cost. (Day 9)
9. Triggers: the 3 legitimate jobs + the silent veto problem. (Day 10)
10. JSONB vs columns — the decision rule. (Day 11)
11. Upsert, SKIP LOCKED, IS DISTINCT FROM — one use each. (Day 12)
12. B-tree mechanics + heap fetches + index types (GIN/BRIN). (Day 13)
13. Composite ordering rule + partial + INCLUDE. (Day 14)
14. Planner: statistics, cost model, join strategies. (Day 15)
15. BUFFERS/loops/temp; ANALYZE; extended stats. (Day 16)
16. MVCC: snapshots, xmin/xmax, bloat. (Day 18)
17. Isolation anomalies — what you reproduced at which level. (Day 19)
18. Locks/deadlock detection/runbook. (Day 20)
19. Roles/least privilege/defaults. (Day 21)
20. RLS: USING/WITH CHECK/FORCE/bypasses. (Day 22)
21. Backups: formats, selective restore, PITR's role. (Day 23)
22. Tuning checklist + pg_stat_statements. (Day 24)
23. VACUUM/autovacuum/visibility map. (Day 25)
24. Migrations/monitoring/incidents. (Day 26)
25. Replication: sync/async, RPO, ≠ backup. (Day 27)
26. Pooling modes + scaling ladder. (Day 28)

## Part B — Hands-On Drills

🟡 **D1.** Create a full table from scratch: identity PK, FK with CASCADE, CHECK, partial unique index, expression index, TIMESTAMPTZ default — one statement, no notes.
🟡 **D2.** Diagnose a slow query on perf_lab using the FULL method: pg_stat_statements → EXPLAIN (ANALYZE, BUFFERS) → fix → numbers.
🟡 **D3.** Two-session drill: reproduce a lost update; fix it with atomic arithmetic; then with FOR UPDATE; then observe at SERIALIZABLE.
🟡 **D4.** RLS drill: full sequence on a table, context GUC, FORCE trap demonstrated.
🔴 **D5.** The 5-minute systems story: your Project 6 runbook, summarized out loud — access, monitoring, migrations, incidents, maintenance, backups, replication, pooling.

## Part C — Mock Interview (recorded, out loud)

1. "Explain MVCC and its costs." → follow-up: bloat? → follow-up: what does vacuum do about it?
2. "How do you index for `WHERE a = ? AND b > ? ORDER BY b`?" → follow-up: why that order? → follow-up: what if the column is wrapped in a function?
3. "A query is slow in production — your process." → follow-up: what tool first? → follow-up: estimates vs actuals disagree — what next?
4. "How would you secure a multi-tenant SaaS database?" → follow-up: RLS bypasses? → follow-up: what does FORCE fix?
5. "Explain replication: why, sync vs async, and what it's NOT." → follow-up: RPO for your design?

**Pass bar:** follow-ups, no notes. Shaky topic → that day's recall tomorrow morning, then capstone.

**Then: Day 30 → [07-capstone.md](../projects/07-capstone.md)**
