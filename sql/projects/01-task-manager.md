# Project 1 — Task Manager Database

**Milestone:** SQL Stage 1 (after Day 5) · **Time:** ~45 min · **Dataset:** your own (`taskmanager` scratch DB or the `saas` DB)

## Objective

Build a small task-management database from scratch: create, insert, read, filter, and sort — the entire Stage 1 toolkit applied to your own data.

## Scenario

You're building the persistence layer for a personal to-do app. Right now it only needs: tasks with a title, a status, a priority, and dates.

## Requirements

Create a database (or a scratch table) with this table — *design it yourself*, but it must support:

- a task has: a title, a status (`todo`/`doing`/`done`), a priority (`low`/`medium`/`high`), a created date, an optional completed date
- every task must have a unique id

**You choose:** column names, data types (defend your choices!), which columns allow NULL.

## Required Operations

1. Create the table
2. Insert 8 tasks (make them realistic: mix of statuses/priorities; two tasks with no completed date even though done... no wait — make the data honest: done tasks have completed dates, others NULL)
3. Insert 3 more tasks in a single statement

## Required Queries

Write and run:

4. All tasks, newest first
5. Only `todo` tasks
6. `high` priority tasks that aren't done
7. The 3 oldest tasks
8. Unique priority values (sorted)
9. Tasks created in a specific month of your data (WHERE + date comparison)
10. A "summary" query: one row — total tasks, how many done, how many not done (three COUNT... aggregates — Day 9 preview: use `COUNT(*) FILTER` or CASE if you know it; otherwise 3 separate queries are acceptable today)

## Constraints

- All SQL typed by hand, no copy-paste
- Predict each query's result before running

## Performance Requirement

None yet — this dataset is tiny. (Deliberate: performance stages come later with big data.)

## Challenge Tasks

11. A query that returns tasks where `completed_at` is set but status is *not* `done` — then UPDATE the data to fix those inconsistencies
12. Add a computed column to output: `days_open` = completed_at − created_at (NULL if not done)

## Bonus Challenge

13. Duplicate your table as `tasks_backup` (CREATE TABLE ... AS), DELETE everything from the original, and verify the backup still works. When would this be a *terrible* backup strategy? (Day 23 of the PG track will make you shudder.)

## Expected Outcome

A working table with 11 rows, ten queries you wrote yourself, and opinions about data types.

## Self-Review Questions

- Why did you choose your id column type? What happens if someone inserts a duplicate id?
- Which columns did you make nullable — and what does NULL *mean* for each?
- Which query was hardest to write? Why?

> Attempted fully first? Compare with [solutions/01-task-manager.md](solutions/01-task-manager.md) — and grade yourself: does your version work, even if different?
