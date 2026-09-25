# 🗺️ ROADMAP — The Complete 30-Day Progression

Three independent tracks, each a complete 30-day program. Work one track start-to-finish, or interleave (suggested order for total beginners: **SQL first**, then PostgreSQL, then MongoDB — but MongoDB is fully standalone if you prefer).

Stages are progressive — never start a stage before finishing the previous one.

## SQL Track — the query language

| Stage | Days | Topic | Milestone |
|---|---|---|---|
| **1 — Foundation** | 01 | What is a database? Tables, rows, columns | |
| | 02 | SELECT — reading columns and rows | |
| | 03 | WHERE — filtering data | |
| | 04 | ORDER BY, LIMIT, DISTINCT | |
| | 05 | INSERT — adding data | 🏗️ **P1: Task Manager (CRUD)** |
| **2 — CRUD + Querying** | 06 | UPDATE & DELETE | |
| | 07 | NULL, CASE, COALESCE | |
| | 08 | LIKE, IN, BETWEEN, EXISTS | |
| | 09 | COUNT, SUM, AVG, MIN, MAX | |
| | 10 | GROUP BY & HAVING | 🏗️ **P2: Library Analytics** |
| **3 — Relationships** | 11 | INNER JOIN | |
| | 12 | LEFT / RIGHT / FULL JOIN | |
| | 13 | SELF JOIN + multi-table joins | |
| | 14 | Subqueries & correlated subqueries | 🏗️ **P3: Student Course System** |
| | 15 | CTEs (WITH) + recursive intro | |
| **4 — Intermediate** | 16 | Window functions | |
| | 17 | Date/time + string operations | |
| | 18 | Set operations (UNION, INTERSECT, EXCEPT) | |
| | 19 | Keys, constraints & schema design | 🏗️ **P4: E-commerce Analytics** |
| | 20 | Normalization (1NF→3NF) + denormalization | |
| **5 — Tx + Performance** | 21 | Transactions & ACID | 🏗️ **P5: Bank Transfer Simulation** |
| | 22 | Indexes — concept, cost & trade-offs | |
| | 23 | EXPLAIN & query plans | |
| | 24 | Optimization patterns | 🏗️ **P6: Query Performance Lab** |
| **6 — Application** | 25 | Views | |
| | 26 | Design decisions: normalize vs denormalize | |
| | 27 | SQL anti-patterns & common mistakes | |
| | 28 | Stage review + mock interview | |
| | 29–30 | **CAPSTONE: real-world system design + build** | 🏗️ **Final Capstone** |

## PostgreSQL Track — the database system

| Stage | Days | Topic | Milestone |
|---|---|---|---|
| **1 — Setup** | 01 | Install PostgreSQL + psql survival guide | |
| | 02 | Databases, schemas, the catalog | |
| | 03 | Tables + PostgreSQL data types | |
| | 04 | Server architecture + loading datasets | |
| **2 — Modeling in PG** | 05 | Primary keys, identity, sequences | |
| | 06 | Foreign keys & relationships | |
| | 07 | UNIQUE, CHECK, NOT NULL, defaults | 🏗️ **P1: Task Manager the PostgreSQL Way** |
| **3 — PG Features** | 08 | Views + materialized views | |
| | 09 | Functions | |
| | 10 | Stored procedures + triggers | 🏗️ **P2: SaaS Task Tracker (triggers)** |
| | 11 | JSON, arrays, special types | |
| | 12 | Practical PG patterns round-up | |
| **4 — Indexes + Planner** | 13 | B-tree indexes | |
| | 14 | Composite, partial & unique indexes | |
| | 15 | The query planner + EXPLAIN | |
| | 16 | EXPLAIN ANALYZE + statistics | |
| | 17 | Index strategy review | 🏗️ **P3: Query Performance Lab (100k rows)** |
| **5 — Tx + Concurrency** | 18 | Transactions in depth | |
| | 19 | Isolation levels & anomalies | |
| | 20 | Locks & deadlocks | 🏗️ **P4: Bank Transfer (concurrency edition)** |
| **6 — Security + Ops** | 21 | Roles & permissions | |
| | 22 | Row-level security basics | 🏗️ **P5: Secure a Multi-Tenant Schema** |
| | 23 | Backup & recovery (pg_dump) | |
| | 24 | Performance tuning checklist | |
| | 25 | Server config + maintenance (VACUUM) | |
| | 26 | Production considerations | 🏗️ **P6: Ops Runbook** |
| **7 — Production** | 27 | Replication concepts | |
| | 28 | Connection pooling + scaling | |
| | 29 | Full review + mock interview | |
| | 30 | **CAPSTONE: production-grade schema + ops** | 🏗️ **Final Capstone** |

## MongoDB Track — the document database

| Stage | Days | Topic | Milestone |
|---|---|---|---|
| **1 — Foundation** | 01 | What is a document database? + mongosh | |
| | 02 | Databases, collections, documents, BSON, ObjectId | |
| | 03 | insertOne / insertMany + schema flexibility | |
| | 04 | find / findOne basics | |
| **2 — CRUD Mastery** | 05 | Update operators ($set, $inc, …) | 🏗️ **P1: Task Manager (Mongo CRUD)** |
| | 06 | deleteOne / deleteMany + CRUD review | |
| | 07 | Comparison & logical query operators | |
| | 08 | Projection, sort, limit, skip | 🏗️ **P2: Book Catalog** |
| **3 — Arrays + Nested** | 09 | Array operators ($push, $pull, $addToSet) | |
| | 10 | Nested documents & dot notation | |
| | 11 | $exists, $type, $elemMatch | 🏗️ **P3: Social Feed Queries** |
| **4 — Data Modeling** | 12 | Schema design thinking | |
| | 13 | Embedding vs referencing | |
| | 14 | One-to-one, one-to-many | |
| | 15 | Many-to-many + modeling patterns | 🏗️ **P4: Model an E-Commerce Store** |
| **5 — Indexes + Perf** | 16 | Single-field + compound indexes | |
| | 17 | Unique, TTL indexes + explain() | |
| | 18 | Performance patterns | 🏗️ **P5: Index Performance Lab** |
| **6 — Aggregation** | 19 | $match, $project, $sort | |
| | 20 | $group + accumulators | |
| | 21 | $unwind + arrays in pipelines | |
| | 22 | $lookup | 🏗️ **P6: E-Commerce Analytics (pipeline)** |
| **7 — Tx → Production** | 23 | Multi-document transactions | |
| | 24 | Transactions in practice | 🏗️ **P7: Bank Transfer (Mongo)** |
| | 25 | Replication concepts | |
| | 26 | Sharding + scaling fundamentals | |
| | 27 | Performance + production considerations | |
| | 28 | Full review + mock interview | |
| | 29–30 | **CAPSTONE: design + build a real system** | 🏗️ **Final Capstone** |

## Project Cadence

Projects are **consolidation milestones**, not daily filler. Each lands only after its concepts have been taught and practiced:

- Small consolidation mini-tasks appear daily (🧩 Combine Concepts).
- Formal projects (above) take 30 min–2 hrs and have `project.md` (spec) + `solutions/` (attempt first!).
- Capstones (multi-day) require real design decisions — no step-by-step solution exists for the design itself.


