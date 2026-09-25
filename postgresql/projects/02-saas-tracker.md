# 🏗️ P2 — SaaS Task Tracker (Triggers & Consistency)

**Milestone:** PG Stage 3 (after Day 10) · **Time:** ~90 min · **Dataset:** `saas`

## Objective

Add a trigger layer to the shared saas schema: updated_at maintenance, an audit trail, and a drift-proof denormalized counter — the three legitimate trigger jobs from Day 10, in one system.

## Scenario

The team keeps finding: tasks updated without updated_at changing, nobody can answer "who changed this task and when", and `projects` counters that drifted from reality. You fix all three *in the database*.

## Requirements — build in order

1. **`updated_at` discipline:** add `updated_at TIMESTAMPTZ` to `tasks`; BEFORE UPDATE trigger keeps it honest. Prove: update a task, check the timestamp.
2. **Audit trail:** `task_audit (id identity, task_id, action, changed_at, old_data jsonb, new_data jsonb)` + an AFTER INSERT/UPDATE/DELETE trigger capturing `to_jsonb(OLD)` and `to_jsonb(NEW)` (mind the DELETE case — OLD not NEW!). Then: update a task's status, and read the audit row — verify both snapshots.
3. **The drift-proof counter:** add `open_task_count INT NOT NULL DEFAULT 0` to `projects`; maintain it with a trigger on `tasks` (after INSERT/UPDATE/DELETE — every path!). Insert, finish, delete a task — the counter must be right every time. Then break it on purpose: `UPDATE projects SET open_task_count = 99 WHERE id = 1;` — *this is the drift the trigger was supposed to prevent.* Discuss (write 3 sentences): can a trigger fully prevent this? What else would (a CHECK constraint against a subquery is impossible — so what's the honest answer? A reconciliation job.)

## Required Queries

4. The audit report: last 10 task changes — who(action), what(task_id), when, and the status transition (old → new) extracted with `->>'status'`.
5. Counter reconciliation: projects where `open_task_count` ≠ the live count (computed via a subquery) — must return zero rows *until* you sabotage it (see 3).
6. Per-project: stored counter vs live count side by side, with a `drift` column.

## Challenge Tasks ⭐

7. Conditional audit: log only *status* changes (compare OLD.status IS DISTINCT FROM NEW.status — Day 12's tool!). Verify title-only updates don't spam the audit.
8. The trigger-cost memo: insert 10k tasks in one statement with and without triggers; measure (`\timing`). Two sentences: when is this cost justified?

## Bonus Challenge 🔴

9. Cross-table consistency: an `org_last_activity` column on `organizations` bumped by triggers when *any* task in any of its projects changes. (You'll need a lookup from task → project → org in the trigger function. Now count how many queries that costs per write — and write the honest verdict.)

## Self-Review

- Which trigger job was hardest to get right on DELETE, and why?
- What did the sabotage teach you about triggers' limits?
- Your honest rule for "trigger vs application code" — 2 lines.

> ✅ [solutions/02-saas-tracker.md](solutions/02-saas-tracker.md)
