# 📋 PostgreSQL Stage Review — Security & Ops (Days 21–28)

Run after Day 28, before the Day 29 full review.

## Part A — Concept Check

1. Roles vs users; the three starter grants + default privileges (Day 21)
2. RLS: USING vs WITH CHECK; FORCE; context GUC; fail-closed (Day 22)
3. Backups: pg_dump formats; pg_dumpall; what dumps don't protect; PITR (Day 23)
4. The 7-step tuning checklist + its tools (Day 24)
5. VACUUM vs VACUUM FULL; autovacuum triggers/blocks; visibility map (Day 25)
6. Migrations: lock_timeout, instant-vs-rewrite DDL, discipline (Day 26)
7. The four monitoring dials + incident shape (Day 26)
8. Replication: reasons, sync/async, RPO, ≠ backup (Day 27)
9. Pooling: why, modes and their breakage, the scaling ladder (Day 28)

## Part B — Hands-On Drills

🟢 **D1.** Create role `reporter` with SELECT on views only; prove base-table access is denied.
🟢 **D2.** Full RLS sequence on a table of your choice; context switch proves isolation; FORCE trap demonstrated.
🟡 **D3.** Backup → sabotage (drop a table) → selective restore → verify counts. Time it; that's your RTO draft.
🟡 **D4.** Run the vitals report (connections, bloat, slow queries, disk) on your machine; interpret each line in one sentence.
🟡 **D5.** Classify five DDL statements as instant or rewrite; verify by timing.
🔴 **D6.** The 10-minute incident script, written from memory for "checkout timing out" — exact commands.
🔴 **D7.** The scaling-ladder drill: assign first two rungs to (a) slow dashboard on 40M rows (b) 5k req/s read API (c) 20k rows/s ingest.

## Part C — Mock Interview (recorded)

1. "How do you secure database access for a web app?" → *follow-up: what if it's multi-tenant?* → *follow-up: what breaks RLS?*
2. "Walk me through your backup strategy." → *follow-up: what does pg_dump NOT give you?* → *follow-up: how do you make backups real?*
3. "The database server is slow — diagnose." → *follow-up: which tool first, and why?* → *follow-up: what if it's only slow during migrations?*
4. "Should we shard?" → *follow-up: what do you try first, in order?*

**Pass bar:** follow-ups without notes. Then Day 29 → capstone.
