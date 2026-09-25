# 📖 GLOSSARY — Database Terminology, Defined Simply

One or two lines per term — enough to *understand*, not memorize. Cross-linked with the day that teaches it (see `ROADMAP.md`).

## The Basics

- **Database** — an organized, persistent collection of data that a program can query and update. The *organized + persistent* part is what separates it from a variable or a file.
- **DBMS (Database Management System)** — the software that manages databases: stores data safely, executes queries, enforces rules, handles many simultaneous users. PostgreSQL and MongoDB are DBMSs. SQL is not.
- **Schema** — two meanings: (1) the *structure* of your data (tables, columns, relationships); (2) in PostgreSQL, a named *namespace* inside a database that groups tables (`public` is the default).
- **Table** — a grid of rows and columns in a relational database. Like one spreadsheet tab, but with enforced rules.
- **Row (record/tuple)** — one single item in a table: one user, one order. Rows are horizontal.
- **Column (field/attribute)** — one property of every row: `email`, `price`. Columns are vertical and have a data type.
- **Data type** — what kind of value a column holds (number, text, date, boolean) and what operations make sense on it.
- **Query** — a request sent to a database: "give me this data" or "change this data."
- **SQL** — the standard *query language* for relational databases. A language, not a product.
- **NoSQL** — a broad label for databases that *don't* use the relational table model (document, key-value, graph, column-family).
- **Client–server** — the database runs as a *server process*; your app (the *client*) connects over the network and sends queries.
- **CRUD** — Create, Read, Update, Delete — the four fundamental data operations (in SQL: `INSERT`, `SELECT`, `UPDATE`, `DELETE`).

## Keys & Constraints

- **Primary key (PK)** — the column (or columns) that uniquely identifies each row. A table's "fingerprint." Never NULL, never duplicated.
- **Composite key** — a primary key made of two or more columns together.
- **Surrogate key** — an artificial identifier (`id = 1023`) with no real-world meaning. The usual modern choice.
- **Natural key** — a real-world value used as a key (email, national ID). Risky: real data changes and contains surprises.
- **Foreign key (FK)** — a column that references the primary key of another table: `orders.user_id` → `users.id`. Enforces that relationships point at real data.
- **Referential integrity** — the guarantee enforced by foreign keys: no order can reference a user that doesn't exist.
- **`UNIQUE`** — constraint: no duplicate values in this column (NULLs usually allowed).
- **`NOT NULL`** — constraint: the value must exist. A missing value is not allowed.
- **`CHECK`** — constraint: the value must satisfy a condition (`rating BETWEEN 1 AND 5`).
- **`DEFAULT`** — value used when you insert without specifying one.
- **`ON DELETE CASCADE`** — when the referenced row is deleted, dependent rows are deleted too. Powerful and dangerous.

## Querying (SQL)

- **`SELECT`** — read data; specify *which columns* and *which rows*.
- **`WHERE`** — the row filter: only rows where the condition is true.
- **`ORDER BY`** — sort results by one or more columns, ascending or descending.
- **`LIMIT`** — return only the first N rows. With `OFFSET`, used for pagination.
- **`DISTINCT`** — remove duplicates from the result.
- **Alias (`AS`)** — a temporary rename for a column or table, for readability.
- **`NULL`** — "value unknown or absent." Not zero, not empty string. `NULL = NULL` is not even true — use `IS NULL`.
- **`CASE`** — an if/then/else expression inside SQL.
- **`COALESCE`** — return the first non-NULL of a list. A "default value" helper.
- **`LIKE`** — pattern matching on text: `%` = any characters, `_` = one character.
- **`IN` / `BETWEEN` / `EXISTS`** — membership, range, and existence tests; often clearer alternatives to `=` chains, ranges, and joins.
- **Aggregate function** — collapses many rows into one value: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`.
- **`GROUP BY`** — partition rows into groups (one per category, per user) and aggregate each group separately.
- **`HAVING`** — a filter applied *after* grouping (WHERE filters before). "Show only categories with 5+ products."
- **Join** — combine rows from two tables where a relationship exists.
- **`INNER JOIN`** — only rows that match in both tables.
- **`LEFT JOIN`** — all rows from the left table; unmatched right side becomes NULL. Answers "which users have *no* orders?"
- **`RIGHT` / `FULL JOIN`** — the mirror images of LEFT; FULL keeps unmatched rows from both sides.
- **Self join** — a table joined to itself (employees ↔ managers) using two aliases.
- **Subquery** — a query nested inside another query.
- **Correlated subquery** — a subquery that references the outer query's current row; runs once per row.
- **CTE (`WITH`)** — a named temporary result that makes complex queries readable; can be chained and recursive.
- **Window function** — computes a value *per row* while looking across a window of related rows: running totals, rankings (`ROW_NUMBER`, `RANK`), moving averages.
- **View** — a saved query that behaves like a virtual table.
- **Materialized view** — a view whose *results* are physically stored and must be refreshed.
- **Set operations** — `UNION` (all rows, deduped), `INTERSECT` (rows in both), `EXCEPT` (rows in first only).

## Documents (MongoDB)

- **Document** — a self-contained data record, stored as BSON: `{name: "Ayesha", age: 25}`. The unit of data in MongoDB.
- **Collection** — a group of documents; the loose analog of a table. Documents in one collection can have different shapes.
- **BSON** — binary JSON: like JSON but typed, compact, and fast to traverse. MongoDB's storage format.
- **`_id`** — every document's primary key. Always present, always unique, automatically an `ObjectId` if you don't provide one.
- **ObjectId** — a 12-byte value: timestamp + random + counter. Sortable by creation time.
- **Field** — a key–value pair inside a document; the analog of a column, but per-document.
- **Embedding** — storing related data *inside* the document (an order with its items). Mongo's answer to joins.
- **Referencing** — storing related data in another collection and linking by `_id`; the analog of a foreign key.
- **Dot notation** — reaching into nested fields: `"address.city"`.
- **Projection** — choosing which fields a query returns.
- **Aggregation pipeline** — a chain of stages (`$match` → `$group` → `$sort`) that transforms documents step by step; Mongo's most powerful query tool.
- **`$lookup`** — the pipeline stage that joins another collection; the analog of `LEFT JOIN`.
- **`$unwind`** — explodes an array into one document per element so you can group/count array items.
- **TTL index** — an index that auto-deletes documents after a time; used for sessions and logs.

## Performance

- **Index** — a sorted lookup structure that lets the database find rows *without* scanning the whole table. Speeds reads, slows writes, costs disk.
- **B-tree** — the balanced tree structure behind most database indexes: ordered, so lookups are O(log n).
- **Composite index** — an index over multiple columns; order matters: `(user_id, created_at) ≠ (created_at, user_id)`.
- **Covering index** — an index that contains *all* columns a query needs, so the table is never touched.
- **Query planner** — the DBMS component that decides *how* to execute a query (which index, which join order).
- **`EXPLAIN`** — show the plan *without running* the query. `EXPLAIN ANALYZE` runs it and shows real timings.
- **Sequential scan** — reading the whole table; what happens without a usable index.
- **Statistics** — the planner's sample data about tables and columns (row counts, value distributions). `ANALYZE` refreshes them.
- **Selectivity** — how few rows a filter matches. High selectivity → index wins. Low selectivity → scan wins.
- **VACUUM** — PostgreSQL's cleanup of dead rows left behind by its MVCC design.
- **Connection pool** — reusing open connections, because opening one is expensive.

## Transactions & Concurrency

- **Transaction** — a group of operations that must happen *all together or not at all*. Money out + money in.
- **ACID** — Atomicity, Consistency, Isolation, Durability: the four guarantees of a reliable transaction.
- **Commit / Rollback** — make the transaction permanent / undo everything it did.
- **Isolation level** — how much a transaction "sees" of others' in-flight work. Lower = faster but weirder; higher = safer but slower.
- **Dirty read** — reading data another transaction hasn't committed yet (it might still roll back).
- **Non-repeatable read** — the same row read twice returns different values because someone updated it in between.
- **Phantom read** — the same query returns *new rows* on the second run because someone inserted in between.
- **Lock** — a claim on a row/table that blocks conflicting operations.
- **Deadlock** — two transactions each waiting for the other. The DB detects it and kills one.
- **MVCC** — multiversion concurrency control: readers never block writers, writers never block readers, via old row versions.

## Design & Scale

- **Normalization** — structuring tables to remove duplicated data (1NF → 3NF). One fact, one place.
- **Denormalization** — deliberately duplicating data to make reads faster. A trade, not a sin.
- **Anomaly** — a bug caused by bad structure: duplicated data drifting apart, or a fact dying with its row (insert/update/delete anomalies).
- **ER diagram** — a picture of tables, columns, and relationships.
- **Cardinality** — relationship shape: one-to-one, one-to-many, many-to-many.
- **OLTP** — transactional workloads: many small reads/writes (orders, payments).
- **OLAP** — analytical workloads: huge reads, aggregations (dashboards, reporting).
- **Replication** — keeping copies of data on multiple servers for safety and read scale.
- **Sharding / horizontal scaling** — splitting data across servers by a key. MongoDB's main scaling story.
- **Partitioning** — splitting one table into pieces (by date, region) inside one server.
- **Role** — a named identity with permissions; users connect *as* a role.
- **GRANT / REVOKE** — give/take away specific privileges (`SELECT`, `INSERT`, …).
- **Row-level security (RLS)** — policies that filter rows per user/tenant automatically. Multi-tenant staple.
- **Backup / PITR** — copying data safely offline; point-in-time recovery replays logs to any moment.

