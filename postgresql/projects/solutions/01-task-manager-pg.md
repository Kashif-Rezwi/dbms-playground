# ✅ Solutions — P1: Task Manager, the PG Way

## Reference schema

```sql
CREATE TABLE tasks (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title        TEXT NOT NULL,
    status       TEXT NOT NULL DEFAULT 'todo'
                 CHECK (status IN ('todo', 'doing', 'done')),
    priority     TEXT NOT NULL DEFAULT 'medium'
                 CHECK (priority IN ('low', 'medium', 'high')),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ,
    -- design answers, enforced:
    CHECK (status <> 'done' OR completed_at IS NOT NULL),      -- done ⟹ has timestamp
    CHECK (status = 'done' OR completed_at IS NULL)            -- not done ⟹ no timestamp
);

-- defense: CASCADE — notes have no life without their task (RESTRICT would make
-- deletes fail until someone clears children by hand; products usually prefer
-- soft-delete anyway — see the challenge note.)
CREATE TABLE task_notes (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id    BIGINT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    note       TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

## The operations

```sql
-- 4. insert + get id back
INSERT INTO tasks (title) VALUES ('Write capstone') RETURNING id;

-- 5. complete (both columns, one statement)
UPDATE tasks SET status='done', completed_at=now()
WHERE id = 1;
-- and the CHECK proof:
UPDATE tasks SET status='done', completed_at=NULL WHERE id = 1;  -- rejected!

-- 6. duplicate notes: usually LEGAL (notes are time-stamped thoughts), so no
-- constraint. If you decided illegal: UNIQUE (task_id, note).
```

## The queries

```sql
-- 7. newest first by created_at (NOT id: commit order ≠ allocation order — Day 5)
SELECT * FROM tasks ORDER BY created_at DESC;

-- 8. one-row summary
SELECT count(*) AS total,
       count(*) FILTER (WHERE status='done')   AS done,
       count(*) FILTER (WHERE status='todo')   AS todo,
       count(*) FILTER (WHERE status='doing')  AS doing
FROM tasks;

-- 9. tasks with note counts, zeros included
SELECT t.title, count(n.id) AS notes
FROM tasks t LEFT JOIN task_notes n ON n.task_id = t.id
GROUP BY t.title;

-- 10. stuck tasks
SELECT title, now()::date - created_at::date AS days_stuck
FROM tasks
WHERE status='doing' AND created_at < now() - interval '14 days';
```

## Challenges

```sql
-- 11. the stale view
CREATE VIEW stale_tasks AS
SELECT * FROM tasks WHERE status IN ('todo','doing')
  AND created_at < now() - interval '30 days';
SELECT title FROM stale_tasks;

-- 12. real products soft-delete: add deleted_at; delete = set it; queries filter it.
-- CASCADE is for genuinely disposable children; notes are usually worth keeping.
```

## Self-review answers (short)

- The forgotten CHECK is almost always `done ⟹ completed_at NOT NULL` — app code assumes it forever, nothing enforces it.
- ALWAYS protects against human id collisions and keeps ids the system's property.
- Each constraint kills: duplicate identity (PK), lying states (CHECKs), orphan notes (FK), invisible rules (comments for the next human).
