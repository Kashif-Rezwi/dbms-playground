# Day 21 — Roles & Permissions

**Track:** PostgreSQL · **Stage:** 6 — Security & Ops · **Difficulty:** 🟡

## 🎯 Goal

Model people and services as roles, grant exactly what each needs, and verify access the way a real auditor would.

## 🧠 Fundamentals

PostgreSQL has **roles**, not users — a role can *be* a login (with password) and/or *group* other roles. "Users" are just login-roles.

```sql
-- the reader (app's main DB user — least privilege)
CREATE ROLE app_read LOGIN PASSWORD 'dev-only';
GRANT CONNECT ON DATABASE ecommerce TO app_read;
GRANT USAGE ON SCHEMA public TO app_read;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO app_read;      -- auto-grant future tables

-- the writer (specific writes, no DDL)
CREATE ROLE app_write LOGIN PASSWORD 'dev-only';
GRANT app_read TO app_write;                 -- inheritance: gets SELECT too
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_write;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT INSERT, UPDATE, DELETE ON TABLES TO app_write;

-- the human (admin), NO superuser
CREATE ROLE dev_admin LOGIN PASSWORD 'dev-only';
GRANT app_read TO dev_admin;
-- + targeted grants, e.g.:
GRANT SELECT, INSERT ON users TO dev_admin;
```

**The privilege ladder** (least → most): CONNECT < USAGE(schema) < SELECT < INSERT/UPDATE/DELETE < TRUNCATE/REFERENCES/TRIGGER < CREATE < TEMP < ... < **SUPERUSER** (never for apps!).

**Ownership matters:** tables are owned by their creator; owners can always touch them; `REVOKE ALL ON users FROM app_read` — but the *owner* still can. To fully lock down: `ALTER TABLE users OWNER TO a_boring_owner_role`.

**Verification is part of security** — test as the role:

```sql
SET ROLE app_read;          -- become it (you, the superuser, can)
SELECT * FROM users LIMIT 1;    -- ✅
INSERT INTO users ... ;        -- ❌ permission denied — PROVE IT
RESET ROLE;
```

Or truly: `psql -d ecommerce -U app_read` (needs `pg_hba.conf` auth configured — taste it).

## 🔍 Why It Matters

Every breached app database was one over-privileged connection away from catastrophe. Least privilege isn't paranoia; it's the difference between "attacker read some reviews" and "attacker dropped the users table."

## 💡 Mental Model

> Roles are **badges**: groups are departments (reader-department, writer-department), logins are people carrying them. GRANT = printing a badge with named doors. INHERIT = wearing all your departments' badges at once. Least privilege = nobody carries the master key — not even you.

## 🛠️ Practice

🟢 **P1.** Create `app_read` + grants; `SET ROLE app_read`; prove: SELECT works, INSERT fails with "permission denied". Reset.
🟢 **P2.** Create `app_write` inheriting app_read; prove SELECT (inherited) + INSERT (direct) both work, and `CREATE TABLE` fails.
🟡 **P3.** The audit query: list every grant in the database (`information_schema.role_table_grants` filtered to public schema) — read it like an auditor: who can touch what?
🟡 **P4.** Default privileges proof: as superuser, create a NEW table after setting defaults; as `app_read`, select from it — works with zero new grants? (If not, you missed P1's ALTER DEFAULT PRIVILEGES.)
🟡 **P5. ⭐ Predict first:** app_read has SELECT on all tables. You run `REVOKE SELECT ON users FROM app_read;` — then `SET ROLE app_read; SELECT count(*) FROM users;` — allowed? Predict, verify, explain (per-table revoke beats schema-wide grant).
🟡 **P6. From memory:** the three-GRANT starter set for a read-only role (CONNECT, USAGE, SELECT + the default-privileges line).
🔴 **P7.** Design the badge map for a real app: `analytics_bot` (SELECT on orders+payments only, NOT users), `api_service` (CRUD on orders/reviews, none on payments), `migration_tool` (DDL during deploys only). Write grants + one REVOKE line per role that surprises people.
🔴 **P8.** The superuser audit: run `\du` on your dev instance; write down why each superuser exists, and the one-line policy for production ("two humans, break-glass procedure, no services").

## 🐛 Debugging

```sql
-- Bug 1: "permission denied for schema public" — but table grants exist.
-- What layer was missed? (USAGE on the schema)
-- Bug 2: app can SELECT but its INSERTs fail only on ONE table. Where do
-- you look first? (role_table_grants for that table; per-table REVOKE?)
-- Bug 3: new tables are always invisible to the app until someone
-- manually grants. What was never set? (ALTER DEFAULT PRIVILEGES)
```

## 🧩 Combine Concepts

Roles + views (Day 8): create `app_read` with SELECT on *views only* (not base tables) — a reporting role that can never see raw PII columns. Prove: view SELECT works, base-table SELECT fails. This is the standard production reporting pattern and tomorrow's RLS builds directly on it.

## 🔁 Previous Knowledge

1. What does a retryable serialization error demand from app code?
2. The deadlock-prevention habit.
3. Row locks — who takes them, who never does?
4. security_invoker views (Day 8) — what do they change about permissions?

## 🧠 Recall

1. Role vs user in PostgreSQL — the actual model?
2. The three core grants for any role? (+ default privileges)
3. What does role inheritance (GRANT role TO role) do?
4. Why does per-table REVOKE beat schema-wide GRANT, and where do you check?

## 🎤 Interview Questions

1. "How would you set up database access for a web app?" *(Distinct roles per job, least privilege, defaults, no superuser.)*
2. "What's the difference between GRANT on schema vs on table vs DEFAULT PRIVILEGES?"
3. "Why should apps never connect as the database owner/superuser?"

## ✅ Completion Checklist

- [ ] Understand roles, inheritance, privilege ladder, defaults, verification
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Built the views-only reporting role
- [ ] Answered recall without notes
