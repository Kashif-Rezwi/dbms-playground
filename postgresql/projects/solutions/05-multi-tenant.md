# ✅ Solutions — P5: Secure a Multi-Tenant Schema

## 1. The roles

```sql
CREATE ROLE app_user LOGIN PASSWORD 'dev-only';
GRANT CONNECT ON DATABASE saas TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
-- (for RLS tables the role's grants say WHAT ops; policies say WHICH rows)

CREATE ROLE analytics_ro LOGIN PASSWORD 'dev-only';
GRANT CONNECT ON DATABASE saas TO analytics_ro;
GRANT USAGE ON SCHEMA public TO analytics_ro;
-- NOTE: no table grants at all — view grants only (below).

CREATE ROLE db_admin LOGIN PASSWORD 'dev-only' CREATEROLE CREATEDB;
```

## 2. RLS — the core sequence (orgs as the worked example)

```sql
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations FORCE ROW LEVEL SECURITY;

CREATE POLICY org_isolation ON organizations FOR ALL
    USING (id = coalesce(current_setting('app.current_org', true), '0')::int)
    WITH CHECK (id = coalesce(current_setting('app.current_org', true), '0')::int);
-- fail-closed: no context → compare against 0 → zero rows, no error.

-- users/projects: same shape on their org_id.
-- tasks (the interesting one):

-- Design A: denormalized org_id on tasks (+ index) — fast, one more column to keep honest
-- Design B: policy subquery —
CREATE POLICY task_isolation ON tasks FOR SELECT
    USING (EXISTS (SELECT 1 FROM projects p
                   WHERE p.id = tasks.project_id
                     AND p.org_id = current_setting('app.current_org')::int));
-- honest comparison: Design B costs a correlated subquery per row — at scale
-- it's an index probe per candidate; Design A is one indexed equality.
-- Choose A for hot tables, B when you can't afford the migration.
```

## 3. The reporting layer

```sql
CREATE VIEW v_org_revenue WITH (security_invoker = true) AS
SELECT o.name, sum(i.amount) AS revenue, count(i.id) AS invoices
FROM organizations o JOIN invoices i ON i.org_id = o.id
GROUP BY o.name;

CREATE VIEW v_task_summary WITH (security_invoker = true) AS
SELECT p.org_id, count(t.id) AS tasks,
       count(*) FILTER (WHERE t.status='done') AS done
FROM projects p LEFT JOIN tasks t ON t.project_id = p.id
GROUP BY p.org_id;

GRANT SELECT ON v_org_revenue, v_task_summary TO analytics_ro;
-- analytics_ro has NO base-table grants → SELECT * FROM users → permission denied.
```

## 4. The bypass audit (run these!)

```sql
-- Bypass 1: owner without FORCE — pre-FORCE, the owner sees ALL rows. Test:
-- connect as the table owner with context='1' but query org 2 rows → visible!
-- Mitigation: FORCE ROW LEVEL SECURITY (applied above).
-- Bypass 2: superuser ignores RLS entirely (by design). Mitigation: no
-- superuser logins for apps; break-glass only.
-- Bypass 3: a SECURITY DEFINER function owned by a bypassing role runs
-- WITH the owner's privileges. Mitigation: audit DEFINER functions; prefer
-- invoker rights; document every exception.
```

## 5–9. The "prove it" list

```sql
SET ROLE app_user;
SET app.current_org = '1';
SELECT count(*) FROM projects;      -- only org 1's (2 rows)
SET app.current_org = '3';
SELECT count(*) FROM projects;      -- only org 3's

INSERT INTO organizations (id, name) VALUES (99, 'Rogue');  -- WITH CHECK rejects
RESET app.current_org;  -- or new session:
SELECT count(*) FROM projects;      -- 0 rows, no error (fail-closed)

SET ROLE analytics_ro;
SELECT * FROM v_org_revenue;        -- works
SELECT * FROM users;                -- permission denied — PII impossible
RESET ROLE;
```

## 10. Pooling pattern

`set_config('app.current_org', '3', true)` (the `true` = transaction-scoped) at the start of each request's transaction; never session-level SET under transaction pooling — the next request reusing the connection would inherit the previous tenant. That's Day 22 + Day 28 joined at the hip.

## Self-review answers (short)

- The owner trap surprises most: RLS "silently" doesn't apply to owners until FORCE.
- Index org_id everywhere a policy touches it — the policy is a predicate; unindexed = per-row subqueries.
- "Why RLS when the app filters?" — one forgotten WHERE is a leak; RLS is physics, not discipline.
