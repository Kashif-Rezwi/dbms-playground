# Day 22 — Row-Level Security (RLS)

**Track:** PostgreSQL · **Stage:** 6 — Security & Ops · **Difficulty:** Advanced · **Milestone:** Project 5

## Goal

Make the database itself enforce "every tenant sees only their rows" — the multi-tenant pattern — and know its sharp edges.

## Fundamentals

**RLS = a WHERE clause the database adds automatically**, per role, per table:

```sql
-- context: the app sets which org is making this request
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY org_select ON projects FOR SELECT
    USING (org_id = current_setting('app.current_org')::int);

-- the app flow:
SET app.current_org = '3';
SELECT * FROM projects;    -- ONLY org 3's rows. For every query. Forever.
```

- `USING` — which rows the policy allows to be *seen*
- `WITH CHECK` — for INSERT/UPDATE: what new rows must satisfy
- **FORCE RLS** — applies to table owners too (otherwise owners bypass! classic trap)

```sql
ALTER TABLE projects FORCE ROW LEVEL SECURITY;
CREATE POLICY org_write ON projects FOR ALL
    USING (org_id = current_setting('app.current_org')::int)
    WITH CHECK (org_id = current_setting('app.current_org')::int);
```

**Where `app.current_org` comes from:** a custom GUC set per request (`SET app.current_org = '3'` or `set_config(..., true)`); real apps do this via the connection pooler.

**When RLS vs WHERE in the app:** RLS when one forgotten WHERE is data leakage *by design* (B2B SaaS). The app's WHERE is one bug away from exposing another company's data; RLS cannot be forgotten.

**Sharp edges:** policies compose with AND; `current_setting` errors if unset (use a fail-closed fallback); the policy is a predicate — index the org column.

## Why It Matters

Multi-tenant SaaS is the most common modern data architecture, and RLS is the *native* answer to "how do we guarantee isolation even when a dev forgets a WHERE?" A genuinely differentiating interview topic.

## Mental Model

> RLS is **tinted glasses welded to the role's face**: whatever query it writes, it *cannot perceive* rows outside its policy. The app used to be "asked nicely" (WHERE org_id=?); now the physics of the database refuses to let other rows exist in any result.

## Practice

### 🟢 Warm Up

[Beginner] **W1.** On `saas`: enable RLS on `projects` + the org_select policy. `SET app.current_org='1'` → SELECT all projects: only org 1's. Switch to '3': different rows, no code change.

[Beginner] **W2.** Unset context (new session): select — read the error. Then the fail-closed pattern: `coalesce(current_setting('app.current_org', true), '0')::int` → zero rows. Why is "fail to zero rows" the safe default?

### 🔵 Core

[Intermediate] **C1.** `[Predict]` the table OWNER inserts a project for org 4 while context='1' — blocked or allowed? Verify, then apply FORCE and re-test. Explain the trap you just witnessed.

[Intermediate] **C2.** `[From Memory]` ** the full RLS sequence for one table: enable → force → select policy → write policy → set context.

[Intermediate] **C3.** INSERT under RLS: context '1', insert a project with org_id=4 — read the error (WITH CHECK). Add the write policy (USING + WITH CHECK); legit inserts pass, cross-tenant fail.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Bug 1: "new RLS table returns ALL rows for the app role". The policy is
-- missing... or the app connects as the OWNER? Two checks.
-- Bug 2: RLS table suddenly returns zero rows for everyone. Most likely
-- unset variable? (the context GUC + your fallback)
-- Bug 3: a JOIN across two RLS tables returns fewer rows than expected.
-- Why? (policies compose with AND — rows must pass BOTH tinted glasses)
```

[Advanced] **H2.** **[P5: Secure a Multi-Tenant Schema](../projects/05-multi-tenant.md)** — the saas schema with roles (Day 21) + RLS isolation (today) + the views-only reporting pattern (Day 8) + the bypass audit. Attempt before solutions.

[Advanced] **H3.** Performance: with RLS on a big generated projects table (org_id random 1–100), EXPLAIN with `app.current_org='42'` — is the policy indexable? Add the org_id index; re-measure. One line: "RLS cost = ____ when org_id is indexed."

## Interview Questions

1. "How do you enforce tenant isolation in PostgreSQL?" *(RLS: policies + context + FORCE; index the tenant column.)*
2. "What happens if the app connects as the table owner?" *(No RLS without FORCE — the classic trap.)*
3. "What are RLS's performance implications?" *(A predicate per query — index tenant columns.)*

## Completion Checklist

- [ ] Understand policies, USING/WITH CHECK, FORCE, context GUCs
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Started Project 5
