# Cross-Database Learning — The Grand Comparison

> Do this after BOTH the PostgreSQL and MongoDB tracks (or SQL + Mongo). The goal is *not* forced equivalence — it's understanding **how two ecosystems solve the same problems differently**. Every row here, you have *lived*.

## The Concept Map (fill from memory first, then verify)

| Concept | PostgreSQL | MongoDB | Your lived proof-day |
|---|---|---|---|
| Unit of data | row in a table | document in a collection | SQL D1 / Mongo D1 |
| Identifier | PK — identity/serial | `_id` — often ObjectId | PG D5 / Mongo D2 |
| One-to-many | child tables + FK + JOIN | embed (bounded) / reference (child holds id) | PG D6 / Mongo D14 |
| Many-to-many | junction table | both-sides arrays OR join collection | SQL P3 / Mongo D15 |
| "Join at read" | `JOIN` | `$lookup` (or app-side $in) | SQL D11 / Mongo D22 |
| "Join at write" (design) | — (normalization default) | **embedding** — the default answer | SQL D20 / Mongo D13 |
| Constraint system | PK/FK/UNIQUE/CHECK enforced | validators + unique indexes; app discipline | PG D7 / Mongo D3, 17 |
| Referential integrity | guaranteed by FKs | **your job** — no FKs | PG D6 / Mongo D13 |
| Aggregation | GROUP BY + HAVING | $match → $group → post-$match | SQL D10 / Mongo D20 |
| Ranked/analytic queries | window functions | $unwind + $group (+ $facet) | SQL D16 / Mongo D21 |
| Index default | B-tree | B-tree (+ multikey on arrays) | PG D13 / Mongo D16 |
| "Show me the plan" | EXPLAIN (ANALYZE, BUFFERS) | explain('executionStats') ratios | PG D16 / Mongo D17 |
| Atomic write unit | row | **document** (multi-operator update) | PG D18 / Mongo D23 |
| Multi-op atomicity | transactions (always existed) | sessions + replica set (since 4.0) | PG D18 / Mongo D23 |
| Lost-update fix | atomic arithmetic / FOR UPDATE / SERIALIZABLE | filter-carried guard / transactions | PG D19 / Mongo D24 |
| Isolation machinery | MVCC + snapshots + xmin/xmax | snapshot reads in transactions | PG D18-19 / Mongo D23 |
| Bloat/cleanup | VACUUM (MVCC corpses) | (no update-in-place corpses — updates replace) | PG D25 |
| Replication unit | WAL stream | oplog | PG D27 / Mongo D25 |
| Failover | external tooling (Patroni et al.) | **built-in elections** | PG D27 / Mongo D25 |
| Durability dial | synchronous_commit | w: 1 vs w: 'majority' | PG D27 / Mongo D25 |
| Horizontal scaling | app-side sharding (ladder, last resort) | **built-in sharding** + shard keys | PG D28 / Mongo D26 |
| Read scaling | replicas + "replica lag" caveat | readPreference + the same caveat | PG D27 / Mongo D25 |
| Backup | pg_dump / PITR (WAL archiving) | mongodump / replica-set snapshots | PG D23 / Mongo D27 |
| Access control | roles + GRANT + RLS | roles per database (no RLS analog!) | PG D21-22 / Mongo D27 |

## The Three Big Asymmetries (say them out loud)

1. **Integrity lives in different places.** PostgreSQL: the engine (FKs, constraints, RLS). MongoDB: your discipline (validators, unique indexes, app-side checks). Consequence: the MongoDB team's *review culture* carries what the database used to.
2. **The default write shape differs.** PostgreSQL wants normalized facts; MongoDB wants read-shaped documents. The *same requirement* produces different schemas — both correct for their ecosystem.
3. **Scaling is built-in differently.** MongoDB productized replication-failover and sharding; PostgreSQL gives you MVCC quality and planning depth and leaves distribution to the app. Neither is "better" — the trade-offs differ per product.

## How to Use This Page

1. **Fill the third column from memory** — the "lived proof" column is what makes this *yours*.
2. Compare with your grand comparison table from Mongo D27 — merge the best of both.
3. Then: [exercises.md](./exercises.md) — same business questions, both engines, side by side.
