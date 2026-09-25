# Day 08 — Views & Materialized Views in PostgreSQL

**Track:** PostgreSQL · **Stage:** 3 — PG Features · **Difficulty:** Intermediate

## Goal

Use views as an API layer, know PostgreSQL's extra powers (security-barrier views, updatable views, refresh options), and pick view vs materialized deliberately.

## Fundamentals

You know the SQL-track basics. PostgreSQL adds:

**Updatable views** — simple single-table views are automatically UPDATE/DELETE-able:

```sql
CREATE VIEW active_users AS SELECT id, name, email FROM users WHERE is_active;
UPDATE active_users SET email = 'x@y.com' WHERE id = 1;   -- works!
```

Multi-table/aggregate views are not (the SQL Day 25 lesson).

**security_invoker / security_barrier** — views normally run with the *owner's* permissions (`security definer` — the old default). `security_invoker = true` (PG 15+) runs with the querying user's permissions:

```sql
CREATE VIEW my_orders WITH (security_invoker = true) AS
    SELECT * FROM orders WHERE user_id = current_setting('app.user_id')::int;
```

**Materialized views** — stored results + `REFRESH`. PostgreSQL extra: **CONCURRENTLY** (refresh without blocking readers; requires a unique index) and **refresh via pg_cron-style scheduling** (mention).

```sql
CREATE MATERIALIZED VIEW product_stats AS
SELECT product_id, avg(rating) AS avg_rating, count(*) AS n
FROM reviews GROUP BY product_id;
CREATE UNIQUE INDEX ON product_stats (product_id);       -- needed for CONCURRENTLY
REFRESH MATERIALIZED VIEW CONCURRENTLY product_stats;
```

**When materialized?** Expensive aggregation + tolerated staleness (dashboards, leaderboards). The stale-read trade-off is *yours to own* — write the freshness requirement down.

## Why It Matters

Views are how databases present stable APIs while schemas evolve underneath. Materialized views are the cheapest "pre-compute" tool before reaching for separate reporting databases.

## Mental Model

> A view is a **stored procedure disguised as a table** — you query it, the engine expands it. Materialized view = a **photo** of the query result (instant to show, needs retaking); regular view = a **window** (always live, always the cost of looking through it).

## Practice

[Beginner] **P1.** Create `active_users` (above, over ecommerce `users`), UPDATE through it, verify the base table changed.
[Beginner] **P2.** Prove non-updatable: create an aggregate view; attempt UPDATE; read the error and name the rule.
[Intermediate] **P3.** Materialize `product_stats`; insert a new review; show the view is stale; `REFRESH`; show it's fresh. Time the refresh — write the ms.
[Intermediate] **P4.** Add the unique index, `REFRESH ... CONCURRENTLY` — note the difference in blocking (two sessions: one reading while refreshing).
[Intermediate] **P5. Predict first:** create a view with `ORDER BY` inside it. Does `SELECT * FROM view` guarantee order? Does `SELECT count(*) FROM view` return rows in that order? What's the rule?
[Intermediate] **P6. From memory:** the view for "monthly revenue" (SQL Day 17 pattern) over `orders`, then a query on top of it for the best month.
[Advanced] **P7.** Design decision, written: analytics page, 400ms budget, GROUP BY over 50M rows takes 9s. Options in order: (a) plain view (b) materialized + 5-min staleness (c) denormalized summary table + triggers (d) separate analytics DB. One line each on cost/complexity. Pick one and defend for a "internal dashboard" use case.
[Advanced] **P8.** `security_invoker` demo: create role `ro` with SELECT on *orders only* (Day 21 preview — commands in cheat-sheet), grant SELECT on a view joining orders+users to `ro`, test which permission model lets the query through. Two-sentence conclusion.

## Debugging

```sql
-- Bug 1: the dashboard shows yesterday's numbers. Name the two designs that
-- cause this (materialized + never refreshed; trigger-maintained summary
-- with a bug) and the diagnostic for each.
-- Bug 2: ERROR: "cannot refresh materialized view concurrently" — what's
-- missing, and why does CONCURRENTLY need it?
-- Bug 3 (SQL-injection-shaped): a view filters WHERE name = current_user.
-- Someone "optimizes" it to WHERE name = 'postgres'::text. What did they
-- just break, and what does current_user actually return?
```

## Combine Concepts

Build a mini reporting layer on `saas`: (1) `v_org_revenue` (org name, total invoices), (2) `v_overdue` (only overdue, live view), (3) `mv_monthly` (materialized monthly totals), then answer: which orgs have overdue > revenue... — wait, think about what question actually makes sense — answer "orgs whose overdue amount exceeds 20% of total invoiced" using a mix of live views and the materialized view. Note which parts can be stale.

## Previous Knowledge

1. Partial unique constraints — the problem they solve.
2. What can a CHECK never reference?
3. SQL: view vs materialized view trade.
4. SQL: why CASE in aggregates?

## Recall

1. What makes a view updatable? (The simple-shape rule.)
2. What does CONCURRENTLY need, and what does it prevent?
3. security_invoker vs default permission model — one line.
4. When is staleness an acceptable trade? When never?

## Interview Questions

1. "When would you use a materialized view vs a summary table maintained by triggers?"
2. "Views for API stability — how does that work when the schema changes?"
3. "What's the staleness risk of materialized views, and how do you manage it?"

## Completion Checklist

- [ ] Understand updatable views, security options, CONCURRENTLY
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the reporting-layer combine task
- [ ] Answered recall without notes
