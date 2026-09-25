# P6 — Ops Runbook

**Milestone:** PG Stage 6 (after Day 26, finished Day 28) · **Time:** ~2–3 hours total · **No solutions file — this IS the deliverable**

## Objective

Write the operations runbook for a production PostgreSQL system — your own document, built from 26+ days of skills. You'll hand it to a teammate; a teammate must survive a bad night with it.

## Your System (pick one)

- **Option A:** the LocalEvents capstone (SQL/PG capstone schema)
- **Option B:** the shared `ecommerce` dataset treated as production

## The Runbook — required sections (a file: `postgresql/projects/your-runbook.md`)

**1. System facts** — databases/schemas, sizes, users, the top-5 queries (with their EXPLAIN summaries).

**2. Backup & restore** (Day 23): dump commands, retention policy (7/4/12), where backups live (NOT this machine), the *rehearsed* restore steps with your actual verification queries, and RPO/RTO estimates — measured, not guessed (time your rehearsal!).

**3. Access control** (Days 21–22): the roles table (who, what, why), least-privilege notes, and the superuser policy (who has it, break-glass procedure).

**4. Monitoring vitals** (Day 26): the queries that produce your vitals report (connections, bloat, slow queries, disk) + the alert thresholds you'd set on each (with the reasoning: what value means what).

**5. Maintenance** (Day 25): autovacuum expectations per table (which tables need per-table thresholds?), the monthly VACUUM/ANALYZE ritual, dead_pct thresholds.

**6. Migrations** (Day 26): the discipline rules, the DDL instant-vs-rewrite cheat table, and the lock_timeout pattern.

**7. Incident response** (Days 20, 24, 26): the first-10-minutes script (exact commands), the blocked-session drill, the postmortem template, and THREE concrete incident scenarios *pre-written* (connection exhaustion; slow query after deploy; disk full) with detection + stabilize + diagnose + fix for each.

**8. Replication & scaling** (Days 27–28): your topology recommendation (draw it), RPO choice with reasoning, and the system's *current position* on the scaling ladder + the next two rungs.

## Verification (the only "test" that matters)

Swap runbooks with a future teammate (or your future self in a week): can each section be followed *without asking questions*? Every "hmm, unclear" is a rewrite.

## Self-Review

- Which section took longest because the skill was shakiest? (That's next week's revision topic.)
- Which thresholds did you *measure* vs guess? (Be honest — measured ones only count.)
- If the database vanished right now: what would you lose? (RPO, tested.)

> This project has no solutions file — **your runbook is the solution.** Sections map 1:1 to Days 23–28; if a section feels thin, that day's recall is your gap list.
