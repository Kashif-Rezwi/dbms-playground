# Day 30 — PostgreSQL Capstone: Production-Grade Schema + Ops

**Milestone:** PG track finale · **Difficulty:** Advanced · Full spec: **[../projects/07-capstone.md](../projects/07-capstone.md)**

## The Assignment (short version)

Take the **SQL-track capstone (LocalEvents)** — or a comparable system of your design — and rebuild it **production-grade**:

1. **Schema, PG-native:** identity keys, TIMESTAMPTZ, NUMERIC money, constraints earning their keep (partial unique for the double-sell defense, CHECKs, FKs + their indexes)
2. **Triggers & functions where they belong:** updated_at, an audit trail on bookings, and one volatility-tagged helper — with the "should this live in the DB?" argument written down
3. **Concurrency-proven booking flow:** atomic arithmetic + FOR UPDATE ordering; a *reproduced* lost-update and deadlock, then fixed; SERIALIZABLE+retry path for one operation
4. **Security:** roles for app/analytics/admin (no superuser), RLS isolation if multi-tenant, the bypass audit
5. **Ops:** EXPLAIN-ANALYZE-verified index plan (≤5 indexes, each with a report line), pg_dump backup + restore rehearsal, and a maintenance plan (autovacuum expectations)
6. **The runbook:** extend your Project 6 runbook to this system — backup/restore, vitals, incidents, scaling position
7. **Defense:** the recorded interview from Day 29, plus "what's the weakest part and what would you do with one more day?"

## Rules

- The design decisions are yours; the *reasoning* is the deliverable.
- Every "before" needs a number; every fix needs an "after."
- Reuse everything: Days 1–29 + your SQL track instincts.

## Completion = the whole PG track

When this is done, tick Day 30 in `PROGRESS.md` — you have gone from "SQL is a language I typed" to "I understand the engine, can secure it, scale it, and defend my decisions." Next: the **MongoDB track** — a different modeling paradigm entirely.
