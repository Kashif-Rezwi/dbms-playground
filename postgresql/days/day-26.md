# Day 26 — Production Considerations → 🏗️ Ops Runbook

**Track:** PostgreSQL · **Stage:** 6 — Security & Ops · **Difficulty:** 🔴 · **Milestone:** Project 6

## 🎯 Goal

Assemble the production checklist — migrations, monitoring, incident response — and turn it into a runbook you could hand to a teammate.

## 🧠 Fundamentals — The Production Reality Checklist

**1. Migrations under load.** `ALTER TABLE` takes locks that can freeze a busy system (Day 20 P8). The rules:

- Never run table-rewriting DDL during traffic
- `SET lock_timeout = '5s';` before DDL — fail fast instead of queueing everything behind you
- Know your DDL classes: some are instant (add a nullable column), some rewrite the whole table (type changes, NOT NULL with default on old versions)

**2. Migration discipline:** version every change (`001_create_users.sql`...), forward-only, rehearse on a *copy of production data* (Day 23's restore skill!), never edit an applied migration.

**3. Monitoring — the four dials that matter:**

```text
availability  — is it up? (connection success rate)
latency       — p95/p99, not averages (outliers hide in averages)
saturation    — connections in use, disk, bloat %, replication lag
errors        — failed queries, deadlocks, serialization retries
```

**4. Incident response — the shape that never changes:** *detect → stabilize (not fix!) → diagnose (Days 20/24 tools) → fix → postmortem*. Stabilize = roll back, shed load, scale up, or restore — NOT "try a fix and see."

**5. Environments:** dev → staging (production-sized, restored) → production. Never test a migration the first time on production.

## 🔍 Why It Matters

Everything before Day 26 was *skills*; this day is *responsibility*. The difference between junior and mid isn't SQL — it's whether production is safe while you work.

## 💡 Mental Model

> Production is a **live hospital**: migrations are surgeries (some keyhole, some open-heart — know before you cut; lock_timeout is the tourniquet). Monitoring is the vitals monitor. Incidents follow triage: *stabilize first* — no experimental surgery on a crashing patient. The runbook is the protocol on the wall.

## 🛠️ Practice

🟢 **P1.** Lock-timeout taste: S1 holds a row lock; S2 `SET lock_timeout='2s'; ALTER TABLE ...` → clean error. Without the timeout, S2 blocks — and *every session behind S2* queues too. Write the two-line lesson.
🟢 **P2.** Classify these DDLs (instant vs table-rewrite) by timing them on perf_lab: add nullable column; add a column with DEFAULT; add NOT NULL to an existing nullable column; change TEXT→INT; CREATE INDEX vs CREATE INDEX CONCURRENTLY.
🟡 **P3.** Write your migration discipline as 5 one-line rules; skeleton a migrations folder for a hypothetical app (001_add_users.sql...).
🟡 **P4.** Build your one-query **vitals report** (connection count + bloat top-1 + your slowest query + disk usage). This is your own little Grafana.
🟡 **P5. ⭐ Predict first:** a migration adds NOT NULL to a column holding NULLs — what error, and what's the correct three-step sequence? (backfill → set NOT NULL → drop helper). Rehearse it.
🔴 **P6.** Incident tabletop: as *first responder* for "Friday 3 PM: checkout page timing out" — write your first 10 minutes with exact commands (pg_stat_activity? lock waits? deploy log?), and where stabilize ends and diagnose begins. No code changes in the first 10 minutes!
🔴 **P7. From memory:** the four monitoring dials + the incident shape (detect/stabilize/diagnose/fix/postmortem).

## 🐛 Debugging — Postmortem Practice

```sql
-- Diagnose each; name root cause + one-line prevention (all from days you've lived):
-- A: "DB CPU 100%, app slow, started after deploy" — the deploy added an
--    N+1: a loop of single-row queries. (Root: ___. Prevention: ___.)
-- B: "Everything froze during Tuesday's migration" — a long ALTER behind
--    a held lock, no lock_timeout. (Root: ___.)
-- C: "Disk filled at 2 AM; write errors everywhere" — unbounded log
--    table, never purged. (Root: ___. Prevention: ___.)
```

## 🧩 Combine Concepts

**[P6: Ops Runbook](../projects/06-ops-runbook.md)** — a complete runbook for a hypothetical production PostgreSQL: backup/restore, monitoring vitals, migration discipline, incident response, maintenance, access control. Written by you, for a teammate, from 25 days of experience.

## 🔁 Previous Knowledge

1. VACUUM vs VACUUM FULL — locks?
2. What blocks autovacuum?
3. The 7-step tuning checklist.
4. Day 23's restore runbook — its five steps?

## 🧠 Recall

1. Why lock_timeout before DDL? What queues behind a blocked DDL?
2. Instant vs rewrite DDL — name one of each.
3. The four monitoring dials? The incident shape?
4. What does "stabilize" mean, and why not "fix" first?

## 🎤 Interview Questions

1. "How do you run schema migrations on a large production database?" *(Classify DDL, lock_timeout, rehearse on a copy, traffic windows.)*
2. "A production incident starts — your first 10 minutes?" *(Vitals first; stabilize before diagnose; no code changes.)*
3. "What would you monitor on a PostgreSQL instance?" *(Availability, latency percentiles, saturation incl. bloat/lag, errors.)*

## ✅ Completion Checklist

- [ ] Understand migrations, monitoring, incidents, environments
- [ ] Completed P1–P7 (P5 predicted first)
- [ ] Diagnosed all three postmortems
- [ ] Started Project 6 (the runbook)
- [ ] Answered recall without notes

