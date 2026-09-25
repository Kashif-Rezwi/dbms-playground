# Day 23 — Backup & Recovery

**Track:** PostgreSQL · **Stage:** 6 — Security & Ops · **Difficulty:** Intermediate

## Goal

Back up and restore a database three ways, know what each protects against, and rehearse the recovery you'll one day need at 3 AM.

## Fundamentals

**The three tools:**

```bash
# 1. Logical backup — SQL text, human-readable, portable, SLOW on big data
pg_dump -d ecommerce -f backup.sql
psql -d ecommerce_restore -f backup.sql

# 2. Custom format — compressed, supports selective/parallel restore
pg_dump -d ecommerce -Fc -f ecommerce.dump          # -F c
pg_restore -d ecommerce --clean --if-exists ecommerce.dump
pg_restore -l ecommerce.dump                        # list contents (TOC!)
pg_restore -d ecommerce --table=users ecommerce.dump # single table

# 3. Whole-instance — every database, roles, the works (disaster recovery)
pg_dumpall > instance.sql
```

**Restore is the only backup that exists.** An untested backup is a hope, not a plan. The professional habit:

```bash
pg_dump -d ecommerce -Fc -f test.dump
createdb ecommerce_rehearsal
pg_restore -d ecommerce_rehearsal test.dump
psql -d ecommerce_rehearsal -c "SELECT count(*) FROM orders;"   -- verified.
```

**The limitations of pg_dump** (be honest about them):

- **Logical + at-a-point-in-time**: changes since the dump are GONE unless you also have WAL archiving (PITR — point-in-time recovery; production setups archive WAL continuously and can restore to *any moment*)
- Slow on hundreds of GB — physical backup tools (`pg_basebackup`) take over there
- Runs as a *consistent* snapshot — safe while the database is live (MVCC!)

**Scheduling reality:** nightly `pg_dump` + retention (7 daily / 4 weekly / 12 monthly) + **a restore rehearsal each month**. Storage lives OFF the server (a backup on the same disk is a decoration).

## Why It Matters

Data loss is the one unrecoverable failure. Every ops interview asks "what's your backup strategy?" — and the *correct* first word is "tested."

## Mental Model

> pg_dump is a **photocopy of the ledger**: portable, readable, restorable elsewhere — but only of the moment you copied it. PITR/WAL archiving is a **continuously-recording camera**: restore to any second. An untested backup is a fire extinguisher still in its box — you don't know if it works until the fire.

## Practice

[Beginner] **P1.** `pg_dump` the ecommerce DB in plain SQL; *read* the file — find the CREATE TABLEs, COPY data block, and the ALTER ... OWNER statements. What's the exact restore order and why? (types → tables → data → constraints/indexes → owners.)
[Beginner] **P2.** Restore rehearsal: full restore into `ecommerce_rehearsal`; verify all table counts against the sanity numbers.
[Beginner] **P3.** Custom format + selective restore: dump, list contents (`-l`), restore ONLY the `users` table into a scratch DB.
[Intermediate] **P4.** Break it and prove the backup matters: `DROP TABLE reviews;` on the live DB. Restore just reviews from your dump. Then reflect in one sentence why you needed P3's skill at this exact moment.
[Intermediate] **P5. Predict first:** dump with `-t orders -t order_items` (two tables). Does the restore succeed *without* users? (FK pointing at a missing table!) Try it — read the error. What's the minimum table set for orders to live?
[Intermediate] **P6.** `pg_dumpall` — run it, grep the top of the file for `CREATE ROLE`. What does pg_dump cover that pg_dumpall adds? Two lines.
[Advanced] **P7.** Compression + size audit: dump ecommerce in plain vs custom format; compare file sizes. Then dump `perf_lab` — time it, and estimate (write the arithmetic) how a 500GB production database changes your strategy (answer sketch: nightly logical becomes untenable → pg_basebackup + WAL archiving + monthly rehearsal on staging).
[Advanced] **P8.** Write your personal **restore runbook** — data-loss incident, five steps, exact commands, verification queries, and the "when did we last rehearse" check. Keep it in your notes; Project 6 builds on it.

## Debugging

```sql
-- Bug 1: restore fails with "role X does not exist" — dumped from a
-- server where X exists, restoring where it doesn't. Two fixes
-- (create the role first; or dump with --no-owner).
-- Bug 2: restore fails halfway on a unique constraint — restoring INTO
-- an existing non-empty database. What flag was missing? (--clean, or
-- restore into a fresh DB)
-- Bug 3: "we have nightly backups" — but nobody has restored one in a
-- year and the app switched to a new schema last month. What are the
-- two separate disasters hiding here?
```

## Combine Concepts

Disaster timeline drill: (1) dump the DB, (2) make 3 data changes, (3) "crash" (drop a table), (4) restore, (5) identify exactly what was lost (the 3 changes) — 6) name the production mechanism that would have saved them (WAL archiving/PITR). Write the timeline as a 6-line story. You just derived, from experience, why production backup = dump + WAL archiving.

## Previous Knowledge

1. RLS USING vs WITH CHECK?
2. The three RLS bypasses + fixes?
3. What does FORCE RLS close?
4. The three core grants for a role?

## Recall

1. pg_dump plain vs custom — one line each + when custom wins.
2. What does pg_dumpall add?
3. What does a dump NOT protect? Name the mechanism that does.
4. The one-word answer to "what makes a backup real"? (Tested/restored.)

## Interview Questions

1. "What's your backup strategy for PostgreSQL?" *(Dumps + retention + WAL archiving for PITR + monthly restore rehearsal — say "tested".)*
2. "What's the difference between pg_dump and pg_dumpall?"
3. "A table was accidentally dropped — walk me through recovery." *(Selective pg_restore from the latest dump + accept data loss since dump, or PITR.)*

## Completion Checklist

- [ ] Understand dump formats, selective restore, pg_dumpall, PITR's role
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Wrote your restore runbook
- [ ] Answered recall without notes
