# Solutions — Project 1: Task Manager

> Compare *approaches*, not exact text — your column names may differ. Grade: does your version work and could you explain every line?

## One solid schema

```sql
CREATE TABLE tasks (
    id            INT PRIMARY KEY,
    title         TEXT NOT NULL,
    status        TEXT NOT NULL DEFAULT 'todo',   -- todo|doing|done
    priority      TEXT NOT NULL DEFAULT 'medium', -- low|medium|high
    created_at    DATE NOT NULL,
    completed_at  DATE                            -- NULL = not done yet
);
```

Notes you should be able to defend: `id INT` as surrogate PK (Day 19); `status/priority` as TEXT with values documented in a comment (real apps add CHECK constraints — Day 19); `completed_at` nullable **because NULL means "not done"** — an honest NULL (Day 7), not a missing fact.

```sql
INSERT INTO tasks (id, title, status, priority, created_at, completed_at) VALUES
    (1, 'Set up dev environment', 'done',   'high',   '2025-09-01', '2025-09-01'),
    (2, 'Finish SQL Day 5',        'done',   'high',   '2025-09-02', '2025-09-02'),
    (3, 'Call the bank',           'todo',   'medium', '2025-09-03', NULL),
    (4, 'Buy groceries',           'todo',   'low',    '2025-09-03', NULL),
    (5, 'Book dentist',            'doing',  'medium', '2025-09-04', NULL),
    (6, 'Write weekly report',    'todo',   'high',   '2025-09-05', NULL),
    (7, 'Water the plants',        'done',   'low',    '2025-09-05', '2025-09-06'),
    (8, 'Plan trip',              'todo',   'low',    '2025-09-06', NULL);

INSERT INTO tasks (id, title, status, priority, created_at) VALUES
    (9,  'Reply to mentor',  'todo', 'high',   '2025-09-07'),
    (10, 'Fix bike tire',    'todo', 'medium', '2025-09-07'),
    (11, 'Read 20 pages',    'doing','low',    '2025-09-07');
```

## Queries 4–10

```sql
-- 4. newest first
SELECT * FROM tasks ORDER BY created_at DESC;

-- 5. only todo
SELECT * FROM tasks WHERE status = 'todo';

-- 6. high priority, not done
SELECT * FROM tasks WHERE priority = 'high' AND status <> 'done';

-- 7. three oldest
SELECT * FROM tasks ORDER BY created_at LIMIT 3;

-- 8. unique priorities
SELECT DISTINCT priority FROM tasks ORDER BY priority;

-- 9. tasks created in September's first week
SELECT * FROM tasks
WHERE created_at BETWEEN '2025-09-01' AND '2025-09-04'
ORDER BY created_at;

-- 10. summary (Day 9 preview — FILTER makes it one row)
SELECT COUNT(*) AS total,
       COUNT(*) FILTER (WHERE status = 'done') AS done,
       COUNT(*) FILTER (WHERE status <> 'done') AS not_done
FROM tasks;
```

## Challenges 11–12

```sql
-- 11. inconsistencies: completed_at set but not done
SELECT * FROM tasks WHERE completed_at IS NOT NULL AND status <> 'done';
-- fix:
UPDATE tasks SET status = 'done' WHERE completed_at IS NOT NULL AND status <> 'done';

-- 12. days open
SELECT title, status,
       completed_at - created_at AS days_open
FROM tasks;
-- NULL for open tasks — that's NULL arithmetic doing its job (Day 7).
```

## Bonus 13 — why CREATE TABLE AS backup is terrible

It copies *data*, not *rules*: no PK, no FKs, no CHECKs, no indexes, no auto-refresh. The moment the original changes, the "backup" silently lies. Real backups (PG Day 23: `pg_dump`) capture structure + constraints + a consistent snapshot.

## Self-review answers (short)

- Duplicate id → PK violation; the DB refuses (Day 19).
- NULL on `completed_at` = "not done" — meaningful. Any other NULL in your design should have a meaning you can say out loud.
- Hardest is usually query 10 — because "summary" forces aggregation thinking before Day 9.
