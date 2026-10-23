# Day 27 — Performance & Production Considerations

**Track:** MongoDB · **Stage:** 7 — Transactions → Production · **Difficulty:** Intermediate → Advanced

## Goal

Assemble MongoDB's production picture: working sets, connection behavior, the ops toolkit, and the honest "when NOT to use it" answer.

## Fundamentals

**The working-set rule** — MongoDB's single most important performance fact: keep the **hot data + indexes in RAM**. When the working set exceeds RAM, disk reads dominate and everything degrades together. The first scaling question is always: "does the working set fit?"

**Connections** — threaded per connection (cheaper than processes, still not free): driver pools (the same pooling law PostgreSQL has), `maxPoolSize` tuned, never "connection per request".

**The ops toolkit:**

```javascript
db.serverStatus()                   // the vitals: connections, opcounters, memory
db.stats()                          // per-database sizes
db.users.stats()                    // per-collection: size, index sizes
db.currentOp()                      // who's running what
db.users.find().explain('executionStats')  // query truth (Days 17–18)
db.setProfilingLevel(1, { slowms: 100 })    // slow-query camera
```

**Production checklist** (MongoDB's Day-26-equivalent):

1. **Replica set always** (3 nodes) — availability + the transaction requirement
2. **Backups** — `mongodump` (logical) vs **disk snapshots** of a replica-set member (the production choice for big data)
3. **Security** — auth on, TLS, least-privilege roles (`readWrite` on ONE database, not root)
4. **Indexes reviewed** by explain ratios, not created "just in case"
5. **Schema contract** (validators) + scheduled shape audits
6. **Monitoring**: opcounters, replication lag, working set vs RAM, slow-query log — with thresholds

**The honest "when NOT MongoDB"** (the maturity marker): strongly-relational data with joins-everywhere and hard multi-entity invariants (bank ledgers, ERP) fits relational engines better. Document wins: flexible/evolving shapes, embedded reads, horizontal-scale needs, JSON-native apps. The professional answer names BOTH.

## Why It Matters

Day 27 is where the track's skills become stewardship. And the "when not to use it" answer is what separates advocates from engineers.

## Mental Model

> The working set is the **kitchen's prep counter**: everything the chef touches constantly must fit on it; overflow to the pantry (disk) slows every dish. The vitals dashboard = the kitchen's gauges (opcounters = orders/minute; replication lag = how far behind the sous-chefs are; working set vs RAM = counter size). And "when not MongoDB" is knowing **a great hammer doesn't make everything a nail**.

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Run `db.serverStatus()`; find: current connections, opcounters, resident memory. One line per metric.

[Beginner] **W2.** `db.users.stats()` + `db.orders.stats()` on ecommerce — dataSize vs indexSizes. Compute your index tax %. When would that ratio worry you?

### 🔵 Core

[Intermediate] **C1.** `[Predict]` `time mongodump --db perf_lab` — how long, and what's the consistency caveat of a dump? Why do disk snapshots of a replica-set member beat it at scale?

[Intermediate] **C2.** `[From Memory]` the six production checklist items + the working-set rule.

[Intermediate] **C3.** Working-set math, written: perf_lab (~25MB data+indexes) vs a hypothetical 8GB data + 12GB indexes on a 16GB RAM box — hot set in RAM? What's the *first* fix and the *fundamental* fix?

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```javascript
// Incident 1: gradual degradation over weeks; no query changed. Top
// hypothesis? (Data grew past RAM — check serverStatus memory + growth.)
// Incident 2: "connection reset" storms at peak — the app opens a
// connection per request. Fix and why?
// Incident 3: a mongodump restored with a few inconsistent collections.
// What's missing (consistent snapshot: rs member + fsync/snapshot)?
```

[Advanced] **H2.** The **grand comparison table** (capstone centerpiece): PostgreSQL vs MongoDB across — data model, integrity, joins, transactions, scaling, backups, and the killer column: "best at". Built from *your* ~56 days of experience, not a textbook.

[Advanced] **H3.** The "when NOT" memo, written: bank ledger, ERP, CMS, IoT event pipeline, social feed — MongoDB, PostgreSQL, or either (what tips it)? One line each. A *killer* interview artifact.

## Interview Questions

1. "How do you keep MongoDB fast as data grows?" *(Working set in RAM; indexes by ratios; schema discipline.)*
2. "How do you back up a large MongoDB deployment?" *(Replica-set snapshots; mongodump for small/logical.)*
3. "When would you NOT choose MongoDB — honestly?" *(Relational/many-join/invariant-heavy domains.)*

## Completion Checklist

- [ ] Understand working sets, ops toolkit, backups, security, the honest "when not"
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Built the grand comparison table
