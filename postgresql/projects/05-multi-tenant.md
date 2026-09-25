# 🏗️ P5 — Secure a Multi-Tenant Schema

**Milestone:** PG Stage 6 (after Day 22) · **Time:** ~90 min · **Dataset:** `saas`

## Objective

Turn the shared saas schema into a properly secured multi-tenant system: roles, RLS isolation, a reporting path that can't see PII, and a bypass audit.

## Scenario

Three consumers need access: the **app** (CRUD, per-org), an **analytics bot** (read-only on business tables, NEVER on raw user emails), and **you** (admin, but not superuser). Tenant = organization.

## Requirements

1. **Roles** (Day 21): `app_user` (SELECT/INSERT/UPDATE/DELETE on all tables), `analytics_ro` (SELECT on views only), `db_admin` (manage roles + DDL — but NOT superuser). All with LOGIN, dev passwords, and ALTER DEFAULT PRIVILEGES so future tables inherit.
2. **RLS on `organizations`, `users`, `projects`, `tasks`** (Day 22):
   - `org_id` exists on orgs/users; projects and tasks reach the org via joins — implement **both** designs for tasks (denormalized org_id vs subquery policy), compare their EXPLAIN costs with a big generated copy, choose one, defend in a comment.
   - Context via `app.current_org`; fail-closed fallback; FORCED (the owner trap!).
3. **The reporting layer** (Day 8): create views `v_org_revenue` and `v_task_summary` (WITH security_invoker) — grant analytics_ro SELECT on views **only**. Prove: view query works, `SELECT * FROM users` fails for analytics_ro.
4. **The bypass audit** (written, in the report): the three accidental defeats (owner-without-FORCE, superuser, SECURITY DEFINER owned by owner) — for each: the test you ran, the result, the mitigation.

## Required Verifications (the "prove it" list)

5. `SET ROLE app_user; SET app.current_org='1';` → sees ONLY org 1's rows across all four tables.
6. Same role, context '3' → different rows, zero leakage.
7. Cross-tenant INSERT (context 1, org_id 4) → WITH CHECK rejection.
8. Unset context → zero rows (fail-closed), not an error — and explain why zero-rows beats an error here (hint: errors leak *that* a policy exists and complicate apps).
9. analytics_ro: business answers work, PII impossible (list what you verified as impossible — emails, user names...).

## Challenge ⭐

10. The connection-pool note (Day 28 preview): write the app's per-request pattern (`set_config('app.current_org', ..., true)` inside the transaction) and explain in 3 sentences why session-level SET would leak tenants under pooling.

## Bonus 🔴

11. A `SECURITY DEFINER` function that *legitimately* crosses tenants (e.g., a super-admin report owned by a role with BYPASSRLS), with the trade-offs stated. When is this the right escape hatch?

## Self-Review

- Which bypass surprised you the most? (Almost everyone: the owner trap.)
- Index + RLS: which column did you index, and what did the EXPLAIN comparison say?
- "Our app filters by org anyway — why RLS?" — your 3-sentence answer.

> ✅ [solutions/05-multi-tenant.md](solutions/05-multi-tenant.md)
