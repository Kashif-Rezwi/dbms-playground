# 🏗️ PG Capstone — Production-Grade Schema + Ops (Day 30)

**Difficulty:** 🔴 · Full two-day effort (Day 30 + rehearsal time)

## Objective

Take your **LocalEvents** system (SQL-track capstone) — or a comparable design of your choosing — and rebuild it production-grade, then *prove* every claim with numbers.

## Part 1 — Schema, PG-native

1. Identity keys, TIMESTAMPTZ everywhere, NUMERIC money, TEXT + CHECK states
2. The double-sell defense: **partial unique index** (one 'booked' row per seat) — Day 7's tool, applied
3. FKs with chosen behaviors + **all FK columns indexed** (Day 6's trap)
4. Audit trail trigger on bookings (Day 10) + updated_at discipline

## Part 2 — Concurrency-proven booking flow

5. The transaction: check seats FOR UPDATE (ordered!), insert booking + items, mark seats, compute payment
6. **Evidence file:** a reproduced lost update, a reproduced deadlock (then the ordering fix), and the SERIALIZABLE+retry path for the audit-critical booking
7. Idempotent booking (client_ref + ON CONFLICT DO NOTHING) — prove the double-click does nothing

## Part 3 — Security

8. Roles: app / analytics / admin (no superuser) + default privileges
9. Multi-tenant? → RLS on the sensitive tables with the full Day 22 sequence; otherwise → the views-only reporting role (PII-free analytics)
10. The bypass audit, run and documented

## Part 4 — Performance

11. Scale to 1M+ bookings (generate_series; document the generator)
12. The index plan: ≤ 5 indexes, each mapped to a query, each with EXPLAIN (ANALYZE, BUFFERS) before/after — Day 17's strategy, executed
13. The write-tax audit + one honest "indexes can't fix this" query + the pre-aggregation you'd build instead

## Part 5 — Ops

14. Backup + **rehearsed restore** with timing (RTO measured)
15. Vitals report queries + thresholds; autovacuum expectations for the hot tables
16. The mini-runbook: backup, incidents (2 scenarios pre-written), migration discipline for this schema

## Part 6 — Defense (recorded)

17. 10 minutes, out loud:
    - "Walk me through the schema."
    - "How does a booking stay safe under concurrency?" *(Your evidence file is the answer.)*
    - "Show me a performance decision with numbers."
    - "What's the weakest part, and what would you do with one more day?"

## Rules

- Every claim gets a number. Every number gets a command that produced it.
- Design decisions have one-line justifications — in the schema file as comments.
- No solutions exist for the design — only defensible choices.

**Done = the PostgreSQL track is complete.** Update `PROGRESS.md` honestly, then: the **MongoDB track** — a completely different modeling world.
