# Day 26 — Sharding & Scaling Fundamentals

**Track:** MongoDB · **Stage:** 7 — Transactions → Production · **Difficulty:** 🟡→🔴

## 🎯 Goal

Understand sharding — MongoDB's signature horizontal-scaling move — deeply enough to design a shard key and know why it's a one-way door.

## 🧠 Fundamentals

**The scaling problem** (same ladder as PG Day 28): vertical → indexes → caching → read replicas → ... eventually a single primary's write capacity is the bottleneck. MongoDB's answer *built into the product*: **sharding** — splitting data across servers by a key.

```text
mongos (router) ──▶ shard 1: users with city hash ∈ A
              ──▶ shard 2: ... ∈ B       each shard = its own replica set
              ──▶ shard 3: ... ∈ C
```

**The shard key decides everything.** Documents are distributed by `{shard key: value}` ranges (or hashed). The key must exist on every document; it's effectively immutable after insertion.

**Good shard keys** have: **high cardinality** (many values), **even distribution** (no hot shard), **query isolation** (top queries filter on the key → one shard answers; otherwise the router asks *every* shard = **scatter-gather**, slow).

```javascript
sh.shardCollection('ecommerce.orders', { user_id: 1 })             // range
sh.shardCollection('analytics.events', { session_id: 'hashed' })  // hashed
```

**Sharding vs replica sets — the crucial disentangling:**

| | Replica set | Sharding |
|---|---|---|
| Solves | availability (+read scale) | **write** scale + storage beyond one box |
| Complexity | low, automatic failover | high: routers, config servers, rebalancing |
| Default? | yes — always run one | NO — only past single-node limits |

**The one-way door:** a bad shard key (low cardinality, monotonic like timestamps, absent from queries) causes hot shards and scatter-gather that can't be fixed without resharding — a massive migration. **Choose it from the access patterns.**

## 🔍 Why It Matters

MongoDB's scaling story is a genuine differentiator vs PostgreSQL (where sharding is application-side). And "how would you choose a shard key" is a real senior interview question — answerable only from access patterns.

## 💡 Mental Model

> Sharding is **splitting the warehouse into regional warehouses**, and the shard key is the **postal code every package wears permanently**. Good codes spread deliveries evenly and let each order ship from ONE warehouse. Bad codes: everyone ships to one region (hot shard); codes nobody asks about (every order checked everywhere = scatter-gather). Re-labeling every package after the fact (resharding) is a moving-day nightmare — pick the code right the first time.

## 🛠️ Practice

🟢 **P1.** The disentangling drill, written: for (a) 99.9% uptime, (b) 3TB data on one box, (c) 80k writes/sec on one primary, (d) heavy reporting load — replica set, sharding, or both? One line each.
🟢 **P2.** Evaluate as shard keys for `orders`: `status` (8 values), `created_at` (monotonic!), `user_id`, `_id`. Cardinality? Distribution? Query isolation for "this user's orders"? Verdict per key.
🟡 **P3. ⭐ Predict first:** monotonic `_id`/ObjectId as a shard key — where does ALL traffic go? (The newest range — one hot shard. THE classic mistake.) Explain the range structure that causes it.
🟡 **P4.** Design the shard key for `analytics.events` (billions of events; queries: "this session's events", "events by type over time") — argue ranges vs hashed, and the compound key; name the trade each query accepts.
🟡 **P5.** Scatter-gather, reasoned: with shard key `{user_id}`, what does `find({ status: 'pending' })` do across shards? Can any index fix it? (Partial relief only — isolation needs the KEY in the query. Say why.)
🔴 **P6.** The honest sharding memo (5 lines): when you'd shard (write throughput, working set > RAM, storage), the cost (routers, config servers, cross-shard transactions costlier), and the access-pattern-first rule.
🔴 **P7. From memory:** the three properties of a good shard key + the replica-set-vs-sharding table.

## 🐛 Debugging

```javascript
// Scenario 1: after sharding on {created_at}, one shard's disk fills at
// 10× the others. Diagnose (monotonic = hot shard) + the two remediation
// paths and why both hurt.
// Scenario 2: "sharding made everything slower" — every query
// scatter-gathers. The design failure? (Key absent from queries.)
// Scenario 3: a team shards a 40GB database "to be safe". Run the
// numbers with them — what's the recommendation and why?
```

## 🧩 Combine Concepts

The capstone cross-check: your Day 12–15 e-commerce design — would you shard it? Which collection first (orders — unbounded + hot), on what key (user_id — reads are user-centric), with what cross-shard casualty (analytics/$lookup)? Two paragraphs with numbers. This goes in the capstone's design memo.

## 🔁 Previous Knowledge

1. Oplog → election → write concern — the three-sentence story?
2. Why do secondaries break read-your-writes?
3. The production transaction template's beats?
4. Filter-carried guards — the pattern?

## 🧠 Recall

1. What problem does sharding solve that replica sets don't?
2. The three properties of a good shard key?
3. What is scatter-gather and what causes it?
4. Why is the shard key a one-way door?

## 🎤 Interview Questions

1. "Replication vs sharding — what problem does each solve?" *(Availability vs write/storage scale.)*
2. "How would you choose a shard key?" *(Access patterns: cardinality, distribution, isolation.)*
3. "When should a team NOT shard?" *(Before single-node limits — complexity is the cost.)*

## ✅ Completion Checklist

- [ ] Understand sharding, key properties, scatter-gather, the one-way door
- [ ] Completed P1–P7 (P3 reasoned before confirming)
- [ ] Worked all three scenarios
- [ ] Wrote the capstone cross-check
- [ ] Answered recall without notes

