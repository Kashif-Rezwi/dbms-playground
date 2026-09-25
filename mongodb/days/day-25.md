# Day 25 — Replication Concepts

**Track:** MongoDB · **Stage:** 7 — Transactions → Production · **Difficulty:** 🟡

## 🎯 Goal

Understand replica sets — MongoDB's native high-availability unit — and why your transaction work already ran on one.

## 🧠 Fundamentals

A **replica set** = one **PRIMARY** (takes all writes) + N **SECONDARIES** (replicate the primary's oplog). If the primary dies, the survivors **elect** a new one automatically (typically seconds).

```text
     writes →  PRIMARY  ──oplog──▶  SECONDARY 1
                └──oplog──▶  SECONDARY 2     (reads → optional)
```

**The oplog** — the primary's changelog; secondaries replay it. MongoDB's analog of PostgreSQL's WAL streaming (PG Day 27) — with automatic elections PostgreSQL lacks by default.

**Facts that matter:**

- **Writes: always the primary.** Reads: primary by default; secondaries optional (`readPreference: 'secondaryPreferred'`) — with **eventual consistency** (a secondary may lag — "read your writes" can break!)
- **Elections need a majority** — hence **3-node minimum** (or 2 + 1 arbiter) in production. Your Day 23 single-node set elected itself instantly.
- **Rollback files**: a crashed ex-primary's unreplicated writes get rolled back on rejoin — the async-replication data-loss window (small but real).
- **Write concern** — `w: 1` (ack from primary alone) vs `w: 'majority'` (wait for the set — the durability dial; critical writes → majority).

**The connection string story:** apps connect to the *set*, not a host: `mongodb://host1,host2,host3/db?replicaSet=rs0` — drivers auto-discover the primary and fail over.

## 🔍 Why It Matters

Replica sets are why MongoDB survives node loss gracefully — and Day 23's `rs.initiate()` was you running one. "How does MongoDB handle failover?" is a standard interview question, and the answer is *built into the product*.

## 💡 Mental Model

> The replica set is a **cover band with a lead singer**: everyone learns the setlist from the leader (oplog); the leader goes down → the band instantly votes in a new lead (election) — the show doesn't stop. Fans keep requesting songs at the lead (writes); the others hum along a bar behind (lag). `w: 'majority'` = "don't start the next song until at least half the band confirms they know it."

## 💻 Examples

```javascript
rs.status()                 // your one-node set: PRIMARY
rs.conf()                   // members, votes
db.hello().isWritablePrimary

db.transfers.insertOne({...}, { writeConcern: { w: 'majority' } })
```

## 🛠️ Practice

🟢 **P1.** `rs.status()` — decode: set name, member state, `self`, uptime. One sentence per field in notes.
🟢 **P2.** `rs.conf()` — members + votes. Why does a one-node set still "elect" (it's the only voter)?
🟡 **P3.** Failover story, drawn: the 3-node timeline for "secondary 2 dies" (nothing changes) vs "primary dies" (election + client reconnect via the multi-host connection string). What's the client-side requirement?
🟡 **P4. ⭐ Predict first:** app writes with `w: 1`; primary ACKS, dies before replication; new primary elected — is the write there? (No — rollback files.) With `w: 'majority'`? (Survives.) Write the two-line durability dial lesson.
🟡 **P5.** Read preference reality: reads from secondaries guarantee which user-facing bug? ("You changed your email but see the old one.") Two fixes (read primary; session-causal consistency — name the concept).
🔴 **P6.** The design memo: chat app, 99.9% uptime, ≤1s data loss, analytics must not slow the app. Write: topology (3 nodes), write concern (critical writes: majority; messages: your call — defend), read preference (app: primary; analytics: secondaryPreferred). Which of your Day 24 transfers get majority?
🔴 **P7. From memory:** oplog → election → write concern — the three-sentence replica-set story.

## 🐛 Debugging

```javascript
// Scenario 1: sudden NotWritablePrimary errors everywhere — an election
// just happened. Client-side fix? Server-side check?
// Scenario 2: "writes are safe — we have 3 secondaries!" with w:1
// everywhere. What is ACTUALLY guaranteed? (Primary-ack only.)
// Scenario 3: transactions stopped after someone "simplified" the
// deployment to standalone mongod. What was removed, and why did
// Day 23's setup exist? (Replica set = the transaction requirement.)
```

## 🧩 Combine Concepts

The ops crossover (portfolio-grade): build the comparison table — PostgreSQL streaming replication (PG Day 27) vs MongoDB replica sets — on: replication unit (WAL vs oplog), failover (external tooling vs built-in elections), durability dial (sync vs w:1/majority), read scaling (lag vs readPreference lag). Your dual-database education is rare — this table is why.

## 🔁 Previous Knowledge

1. The production transaction template's five beats?
2. Filter-carried guards — why race-free?
3. The three transaction rules that bite?
4. When do you NOT need a transaction?

## 🧠 Recall

1. What is the oplog and who consumes it?
2. Primary dies — the sequence?
3. `w: 1` vs `w: 'majority'` — the durability trade?
4. Why does reading from secondaries break read-your-writes?

## 🎤 Interview Questions

1. "Explain MongoDB replica sets and failover." *(Primary/secondaries/oplog/elections.)*
2. "What's write concern and when do you raise it?" *(Durability dial; critical → majority.)*
3. "Why do transactions require a replica set?" *(The coordination machinery — even one node provides it.)*

## ✅ Completion Checklist

- [ ] Understand replica sets, oplog, elections, write/read concerns
- [ ] Completed P1–P7 (P4 predicted first)
- [ ] Worked all three scenarios
- [ ] Built the PG-vs-Mongo replication comparison table
- [ ] Answered recall without notes

