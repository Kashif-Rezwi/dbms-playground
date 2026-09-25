# 🏗️ P1 — Task Manager, the PostgreSQL Way

**Milestone:** PG Stage 2 (after Day 7) · **Time:** ~60 min

## Objective

Rebuild the SQL-track Task Manager with engine-native foundations: identity, real types, constraint-driven design.

## Scenario

Same app as before — but this time you're doing it *properly*, as if it will live for years.

## Requirements

1. **Schema** (one file, `project1.sql`):
   - `tasks`: identity PK (`GENERATED ALWAYS`), title TEXT NOT NULL, status TEXT + CHECK (todo/doing/done), priority TEXT + CHECK, `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`, `completed_at TIMESTAMPTZ` (NULL = not done)
   - `task_notes`: identity PK, FK to tasks (choose the ON DELETE behavior — defend it in a comment), note TEXT NOT NULL, created_at
2. **Constraint design questions (write answers in the file as comments):**
   - Can a task be `done` with a NULL `completed_at`? Enforce your answer with a CHECK — write it!
   - Can a task be `todo` with a non-NULL `completed_at`? Enforce too.
3. **Seed** 10 tasks + 6 notes with honest timestamps (`now() - interval '...'`).

## Required Operations

4. Insert a task *without* an id and get the id back — one statement.
5. Complete a task: UPDATE status + completed_at in one statement — then prove a CHECK violation: set `done` with NULL completed_at (must fail).
6. Add the same note twice to a task — decide whether that's legal, enforce your decision (partial UNIQUE or nothing — defend it).

## Required Queries

7. All tasks newest-first **by created_at** (not id — say why, Day 5).
8. Tasks per status — one row summary using FILTER.
9. Each task with its note count (including zero-note tasks).
10. Overdue report: `doing` tasks older than 14 days, with a `days_stuck` computed column.

## Challenge Tasks ⭐

11. A `stale` view (todo/doing + older than 30 days) — then a query on the view, not the table.
12. Delete a task with notes; observe your ON DELETE choice; explain what a real product should do instead (soft delete).

## Bonus Challenge 🔴

13. `updated_at` maintenance: add the column + trigger (peek at Day 10's first example — you'll formally learn it soon) and prove it works.

## Expected Outcome

A schema where "bad data" is *structurally impossible* — with the comments showing you can defend every rule.

## Self-Review

- Which CHECK would your SQL-track self have forgotten?
- What does identity ALWAYS protect you from that Day 5's manual ids didn't?
- One sentence per constraint: what bug does it kill?

> ✅ [solutions/01-task-manager-pg.md](solutions/01-task-manager-pg.md)
