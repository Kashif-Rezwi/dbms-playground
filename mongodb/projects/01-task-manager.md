# 🏗️ P1 — Task Manager (Mongo CRUD)

**Milestone:** Mongo Days 1–5 · **Time:** ~60 min

## Objective

Full CRUD over your own task collection — the whole Stage 1–2 foundation, MongoDB edition.

## Requirements

Design your own task document shape, but it must support:

- title, status (`todo`/`doing`/`done`), priority, created_at (real Date), optional completed_at
- tags (array of strings) — at least on some docs
- a nested `meta: { created_by, source }` on at least two docs

**Write the shape contract in a comment**: which fields are required, which types, what absence means (optional vs "not applicable").

## Required Operations

1. insertOne + verify; insertMany (5 tasks, one batch)
2. Update: mark a task done ($set status + completed_at together)
3. $inc drill: a `points` field incremented/decremented
4. Array ops: $push a tag, $addToSet the same tag (observe), $pull a tag
5. The upsert: a `task_stats` doc per user — `{ user_id: 1, done_count }` incremented as tasks complete (run the whole flow twice)

## Required Queries

6. All tasks, newest first (by created_at — not _id; say why)
7. todo tasks only; then todo AND high priority (implicit AND)
8. Tasks WITH a `tags` field ( $exists) — then with a specific tag
9. The nested read: find tasks by `'meta.source'`
10. deleteOne with the preview ritual; soft-delete one task via `hidden: true` and list visible ones

## Challenge ⭐

11. A one-doc "summary" query: count of tasks by status — three countDocuments calls is fine today (aggregation comes Day 20 — note what's coming)
12. Design: should `done_count` be stored (denormalized) or computed? Argue 3 lines with the computed-pattern trade.

## Bonus 🔴

13. Add a validator to your collection (required title + status enum) — prove a bad insert fails.

> ✅ [solutions/01-task-manager.md](solutions/01-task-manager.md)
