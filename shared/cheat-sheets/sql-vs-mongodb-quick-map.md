# SQL ↔ MongoDB Quick Map (for the bilingual brain)

> A translation card, not an equivalence claim. "Roughly" is the honest word — read the caveat column.

| You want to… | SQL | MongoDB | Caveat |
|---|---|---|---|
| Read rows/docs | `SELECT` | `find()` / `findOne()` | find returns a cursor |
| Filter | `WHERE col = 5` | `{ col: 5 }` | implicit AND between fields |
| Range | `BETWEEN a AND b` | `{ col: { $gte: a, $lte: b } }` | same inclusive ends |
| Membership | `col IN (...)` | `{ col: { $in: [...] } }` | |
| OR | `col = a OR col = b` | `{ $or: [...] }` | needs array form |
| Sort | `ORDER BY col DESC` | `.sort({ col: -1 })` | |
| Top-N | `LIMIT n` | `.limit(n)` | |
| Page | `LIMIT n OFFSET m` | `.skip(m).limit(n)` | both degrade deep — keyset/cursor |
| Chosen fields | `SELECT a, b` | find(q, { a: 1, b: 1 }) | + `_id` unless excluded |
| Deduplicate | `DISTINCT col` | `.distinct('col')` | |
| Count | `COUNT(*)` | `countDocuments(q)` | |
| Insert | `INSERT` | `insertOne/insertMany` | batches = one round trip |
| Update | `UPDATE SET a=1 WHERE q` | `updateOne(q, { $set: { a: 1 } })` | **$set or you replace!** |
| Atomic increment | `SET n = n + 1` | `{ $inc: { n: 1 } }` | both atomic |
| Upsert | `INSERT ... ON CONFLICT` | `{ upsert: true }` | needs a unique key story |
| Delete | `DELETE WHERE q` | `deleteOne/Many(q)` | same preview ritual |
| Group | `GROUP BY + SUM/AVG/COUNT` | `$group` with `$sum/$avg/$sum:1` | `_id` is the key |
| Filter groups | `HAVING` | post-`$group` `$match` | |
| Join | `JOIN ... ON` | `$lookup` (+ `$unwind`) | result is always an array |
| If/else in output | `CASE WHEN` | `$cond` / `$switch` (in $project) | |
| View | `CREATE VIEW` | `createView()` / named pipelines | |
| Speed up lookups | `CREATE INDEX` | `createIndex()` | same B-trees, same costs |
| Show the plan | `EXPLAIN ANALYZE` | `.explain('executionStats')` | learn both's key numbers |
| Transactions | `BEGIN/COMMIT` | sessions + replica set | single-doc atomic by default |
| Money | `NUMERIC(10,2)` | `NumberDecimal` | never floats, either world |

## The three "not really equivalent" warnings

1. **NULL vs missing:** SQL has one "absent" (NULL); MongoDB has TWO (null value vs field-not-there) — and `$ne`/`null` matching mixes them. (Mongo D7/D11's matrix.)
2. **FK vs nothing:** SQL guarantees references; MongoDB makes them your app's job — a "JOIN" in Mongo can succeed against a ghost.
3. **Normal form vs read shape:** the same business need produces different schemas by design; don't grade one with the other's values.

**Use:** keep this open during the cross-database exercises — then close it and write it from memory (that's the real test).
