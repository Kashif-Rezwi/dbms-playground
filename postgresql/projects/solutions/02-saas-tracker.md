# ✅ Solutions — P2: SaaS Task Tracker

## 1. updated_at discipline

```sql
ALTER TABLE tasks ADD COLUMN updated_at TIMESTAMPTZ;
UPDATE tasks SET updated_at = now();   -- backfill

CREATE FUNCTION touch_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END $$;

CREATE TRIGGER tasks_touch BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

UPDATE tasks SET priority='low' WHERE id = 1;
SELECT updated_at FROM tasks WHERE id = 1;   -- bumped
```

## 2. Audit trail

```sql
CREATE TABLE task_audit (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id BIGINT, action TEXT NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    old_data JSONB, new_data JSONB
);

CREATE FUNCTION audit_task() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO task_audit (task_id, action, old_data, new_data)
    VALUES (coalesce(NEW.id, OLD.id), TG_OP,
            CASE WHEN TG_OP IN ('UPDATE','DELETE') THEN to_jsonb(OLD) END,
            CASE WHEN TG_OP IN ('INSERT','UPDATE') THEN to_jsonb(NEW) END);
    RETURN coalesce(NEW, OLD);
END $$;

CREATE TRIGGER tasks_audit AFTER INSERT OR UPDATE OR DELETE ON tasks
    FOR EACH ROW EXECUTE FUNCTION audit_task();
-- the DELETE case captures OLD (NEW is unassigned there) — the coalesce
-- pattern keeps both branches safe.
```

## 3. Drift-proof counter

```sql
ALTER TABLE projects ADD COLUMN open_task_count INT NOT NULL DEFAULT 0;

CREATE FUNCTION sync_task_count() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    old_project BIGINT := coalesce(OLD.project_id, NEW.project_id);
BEGIN
    UPDATE projects p
       SET open_task_count = (SELECT count(*) FROM tasks t
                               WHERE t.project_id = p.id
                                 AND t.status IN ('todo','doing'))
     WHERE p.id = old_project;
    RETURN coalesce(NEW, OLD);
END $$;

CREATE TRIGGER tasks_count AFTER INSERT OR UPDATE OR DELETE ON tasks
    FOR EACH ROW EXECUTE FUNCTION sync_task_count();
```

**The sabotage lesson:** a trigger maintains the counter *when tasks change* — nothing stops a direct `UPDATE projects SET open_task_count = 99`. A CHECK can't reference other tables, so the honest answer is a **reconciliation query** (below) run on a schedule + alerts on drift. Triggers reduce drift; only *checking* detects it:

```sql
-- 5. reconciliation — must be zero rows until sabotage
SELECT p.id, p.name, p.open_task_count,
       (SELECT count(*) FROM tasks t WHERE t.project_id = p.id
          AND t.status IN ('todo','doing')) AS live_count
FROM projects p
WHERE p.open_task_count <>
      (SELECT count(*) FROM tasks t WHERE t.project_id = p.id
          AND t.status IN ('todo','doing'));
```

## 4. Audit report

```sql
SELECT task_id, action, changed_at,
       old_data->>'status' AS old_status, new_data->>'status' AS new_status
FROM task_audit ORDER BY changed_at DESC LIMIT 10;
```

## 7. Conditional audit

```sql
CREATE OR REPLACE FUNCTION audit_task() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.status IS NOT DISTINCT FROM NEW.status THEN
        RETURN NEW;         -- status unchanged → skip
    END IF;
    INSERT INTO task_audit (task_id, action, old_data, new_data)
    VALUES (coalesce(NEW.id, OLD.id), TG_OP,
            CASE WHEN TG_OP IN ('UPDATE','DELETE') THEN to_jsonb(OLD) END,
            CASE WHEN TG_OP IN ('INSERT','UPDATE') THEN to_jsonb(NEW) END);
    RETURN coalesce(NEW, OLD);
END $$;
```

## 8. Trigger-cost honesty

10k-row insert with triggers vs without: typically 2–5× slower — the counter function runs per row (an indexed `WHERE t.project_id = ...` helps enormously). Verdict: justified when every writer must respect the counter and reads are ultra-hot; not justified for write-heavy bulk paths (ETL) — those can bulk-sync and reconcile after.

## Self-review answers (short)

- DELETE was hardest: OLD/NEW availability + `coalesce(NEW, OLD)` returns — the classic plpgsql footgun.
- Sabotage teaches: triggers *maintain*, they don't *protect*; reconciliation detects.
- Rule: triggers for cross-writer invariants; app code for workflows; reconciliation for anything denormalized.
