# Day 27 — Replication Concepts

**Track:** PostgreSQL · **Stage:** 7 — Production Thinking · **Difficulty:** 🟡

## 🎯 Goal

Understand replication — *why* it exists, how streaming replication works, and what problems it does and doesn't solve.

## 🧠 Fundamentals

**Replication = keeping a copy of the database on another server, continuously.** Three reasons, in order of importance:

1. **High availability** — the primary dies → a replica is promoted → minutes of downtime, not days
2. **Read scaling** — send analytics/read-heavy traffic to replicas
3. **Geography** — serve reads closer to users; survive a region problem

**How PostgreSQL does it — streaming replication, in one story:**

- The primary writes every change to **WAL** (you know this from Day 4!)
- Replicas connect and **receive the WAL stream**, replaying it — they keep a *physical* copy that's a replay of the primary's log
- A **replication slot** guarantees the primary retains WAL until the replica has consumed it (else: data gaps)
- **Synchronous vs asynchronous**: sync = primary *waits* for a replica confirmation before committing (no data loss, higher latency); async = fire and forget (fast, seconds of loss window on crash). Most systems: async + documented RPO.

**The honest truths:**

- **Replication is not a backup** — it replicates `DROP TABLE` instantly to every copy. Accidental deletions need backups/PITR (Day 23)
- **Failover is a decision**, not a switch: someone/something must detect, promote, and repoint clients — that's what tools like Patroni do
- **Replica lag** is a fact of life — "read your writes" needs sticky routing to the primary (or a sync replica)
- **Writes scale up, not out**: all writes still hit one primary (PostgreSQL's model) — read scaling is what replicas buy

## 🔍 Why It Matters

Every production PostgreSQL runs with replication; every "what if the server dies" interview question ends with it. And the "replication ≠ backup" confusion causes real data loss in real teams every year.

## 💡 Mental Model

> Replicas are **simultaneous interpreters**: they repeat everything the primary says, a syllable behind (lag). Async interpreters might miss the last syllable if the speaker collapses (crash); sync interpreters wait for the interpreter to nod before continuing. An interpreter will faithfully repeat "DROP TABLE" — which is why you still need the tape recorder (backup + PITR).

## 🛠️ Practice

🟢 **P1.** Draw the topology from today's text: primary → 2 replicas → which node takes writes? reads? What happens if the primary dies? What if *one* replica dies?
🟢 **P2.** The three reasons for replication — one line each, with a real product example (WhatsApp availability; an analytics dashboard on a replica; a regional read endpoint).
🟡 **P3.** RPO/RTO in your own words, then assign to each: sync replication (RPO?), async replication (RPO?), nightly dump only (RPO?). Which is acceptable for (a) a blog (b) a bank ledger?
🟡 **P4. ⭐ Predict first:** the app reads its own write from a replica right after committing to the primary. What does the user experience, and what are the two standard fixes?
🟡 **P5.** The failure catalog: primary dies / replica dies / network split (replica falls behind) / disk full on the primary — one line each on detection + response. Which does your Day 26 vitals report already cover?
🔴 **P6.** Design on paper: a small SaaS needs 99.9% uptime, analytics queries that don't burden the app, and no more than ~5s of data loss. Write the topology (how many replicas, sync or async, where reads go), and name what you *didn't* solve with replication alone (backups, failover automation).
🔴 **P7.** From memory: "Why is replication not a backup?" — 90 seconds, out loud, with the DROP TABLE story.

## 🐛 Debugging

```sql
-- Scenario A: replicas are 20 minutes behind during the nightly ETL.
-- Is this "lag" or capacity? What would you check (network? replica IO?
-- primary WAL volume?) and what's the user-facing consequence?
-- Scenario B: failover happened; the new primary is missing the last
-- 4 minutes of orders. The team is confused — "we had replicas!"
-- Explain what async RPO means, in plain words, and the decision they
-- must now make explicitly (accept / go sync for critical writes).
-- Scenario C: an intern restored "a backup" by promoting a stale
-- replica... What guarantees did that violate, and what's the correct
-- runbook phrase for that situation?
```

## 🧩 Combine Concepts

Add the **replication section** to your Project 6 runbook: topology diagram (even ASCII), RPO/RTO targets, the failover decision checklist, and the "what replication doesn't protect" list. The runbook is now nearly complete — pooling and scaling finish it tomorrow.

## 🔁 Previous Knowledge

1. Instant vs table-rewrite DDL — one each.
2. The incident shape — the five stages?
3. What does autovacuum do? What blocks it?
4. WAL — what does it stand for and guarantee? (Today it *became a stream*.)

## 🧠 Recall

1. The three reasons for replication — one line each.
2. Sync vs async — the trade in one line each way.
3. Why is replication NOT a backup?
4. What is replica lag, and what does "read your writes" require?

## 🎤 Interview Questions

1. "Why does a production database need replication?" *(HA, read scale, geography.)*
2. "Synchronous vs asynchronous replication?" *(Latency vs durability trade.)*
3. "A team says 'we have replicas, so we don't need backups.' What's wrong?" *(Human-error and DROP propagate. Say it firmly.)*

## ✅ Completion Checklist

- [ ] Understand streaming replication, sync/async, RPO/RTO, failover
- [ ] Completed P1–P7 (P4 predicted first)
- [ ] Worked all three scenarios
- [ ] Added the replication section to the runbook
- [ ] Answered recall without notes
