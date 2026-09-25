# Day 28 — Connection Pooling & Scaling

**Track:** PostgreSQL · **Stage:** 7 — Production Thinking · **Difficulty:** 🟡

## 🎯 Goal

Understand why connections are expensive, how pooling fixes it, and get the honest big picture on scaling a relational database.

## 🧠 Fundamentals

**The connection problem** (Day 4's fact, now costing money): each connection = a **backend process** with its own memory. 10,000 connections = 10,000 processes — the server spends time *scheduling*, not querying, while most connections idle between requests. `max_connections` is a pressure valve, not a solution.

**A connection pool** — a broker that owns N real connections and lends them out per query:

```text
app (500 potential clients) → pooler (20 real connections) → PostgreSQL
```

- **PgBouncer** — the standard external pooler; **transaction mode** returns the connection after each transaction
- Client-side pools (pgx, SQLAlchemy, Prisma...) — needed anyway
- **Pool-mode warning:** transaction pooling breaks session-level features (persistent SET, advisory locks across transactions, LISTEN/NOTIFY) — know your mode

**The scaling ladder — where do you go when "up" ends?**

```text
1. Vertical        — bigger server. Boring, effective, always first.
2. Index/rewrite   — Day 17/24. The cheapest scaling that exists.
3. Caching         — read-heavy answers in Redis/app memory
4. Read replicas   — Day 27. Reads scale out; writes don't.
5. Partitioning    — split big tables by range/list inside one server
6. Functional split— services own their slice of the database
7. Sharding        — split data across servers by key. LAST resort:
                     app complexity, cross-shard queries, rebalancing pain.
```

**The mature answer to "should we shard?":** almost always "not yet" — steps 1–5 have far more headroom than teams believe, and sharding is a one-way door.

## 🔍 Why It Matters

"Too many connections" is the #1 self-inflicted production failure of growing apps, and "premature sharding" is the #1 self-inflicted complexity disaster. Both are answered by today's model.

## 💡 Mental Model

> Connections are **company cars** (each costs a garage slot and upkeep even parked). A pooler is the **fleet manager** who owns 20 cars and hands keys out per errand — 500 employees still get around; 500 cars would bankrupt the garage. The scaling ladder is a **city's transit plan**: fill the buses you have (indexes), add express lanes (cache), clone the popular route (replicas), zone the city (partition) — and only *then* talk about building a new city (sharding).

## 🛠️ Practice

🟢 **P1.** Prove the cost: hammer local PostgreSQL with 200 concurrent connections running trivial queries (a small script or `pgbench -c 200`). Watch latency. Drop to 20 connections, same query rate. Compare; one-line conclusion.
🟢 **P2.** During P1, check `pg_stat_activity` — what fraction of connections were idle at any instant? That's the pooling thesis, observed.
🟡 **P3.** Pooling modes on paper: session vs transaction vs statement — one line each, plus what breaks in transaction mode (persistent SET, advisory locks across transactions, LISTEN/NOTIFY). Which does a typical web app want?
🟡 **P4. ⭐ Predict first:** with transaction-mode pooling, the app does `SET app.current_org='3'` on one request and queries on the *next*. What does RLS do? What's the correct pattern? (Set inside the same transaction / `set_config(..., true)`.)
🟡 **P5.** pgbench taste: `pgbench` on perf_lab with 10 vs 100 clients; read the TPS numbers. Where's your machine's sweet spot?
🔴 **P6.** The scaling-plan drill: for each, name the *first two ladder steps* and why sharding isn't step one: (a) 40M-row orders table, slow dashboard; (b) read-heavy API at 5k req/s; (c) write-heavy IoT ingest 20k rows/s; (d) multi-region SaaS with EU data residency.
🔴 **P7. From memory:** the scaling ladder in order, one line each on when it applies.
🔴 **P8.** Interview drill, recorded: "How would you scale a PostgreSQL database?" — 3 minutes, ladder + the honest "sharding last" stance.

## 🐛 Debugging

```sql
-- Bug 1: "too many connections" errors at 300 users. Two very different
-- fixes (pool discipline vs raising max_connections) — which is correct,
-- and why does the wrong one make things worse?
-- Bug 2: RLS context "leaks" between users under transaction pooling.
-- Diagnose (session state + pool mode) and fix (set_config in-transaction).
-- Bug 3: a "we should shard" proposal for a 60GB database. Your response,
-- with numbers (fits in RAM; ladder steps remaining; one-way door).
```

## 🧩 Combine Concepts

**Finish the Project 6 runbook**: add the pooling section (client pool + PgBouncer sketch, sizing, the context-GUC pattern) and the scaling ladder with your current product's position marked. The runbook is now complete: access control, monitoring, migrations, incidents, maintenance, backups, replication, pooling, scaling.

## 🔁 Previous Knowledge

1. Sync vs async replication — the trade?
2. Why is replication not a backup?
3. What blocks autovacuum?
4. WAL — what it guarantees? (Today it became a *stream*.)

## 🧠 Recall

1. Why are connections expensive? Two components of the cost?
2. Session vs transaction pooling — what breaks?
3. The scaling ladder — first three rungs?
4. Why is sharding last? (Three costs.)

## 🎤 Interview Questions

1. "Why do applications use connection pools for PostgreSQL?" *(Process per connection; idle waste; pooler math.)*
2. "How would you scale a growing PostgreSQL deployment?" *(The ladder, in order, sharding last.)*
3. "What are the trade-offs of database sharding?" *(App complexity, cross-shard queries, rebalancing.)*

## ✅ Completion Checklist

- [ ] Understand connection costs, pooling modes, the scaling ladder
- [ ] Completed P1–P8 (P4 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the runbook's final sections
- [ ] Recorded your scaling answer

