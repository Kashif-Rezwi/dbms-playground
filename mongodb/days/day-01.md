# Day 01 — What Is a Document Database? + mongosh

**Track:** MongoDB · **Stage:** 1 — Foundation · **Difficulty:** Beginner
**Prerequisites:** None (fully standalone!)

## Goal

Understand what MongoDB *is* — and what it deliberately *isn't* — by exploring a real database in mongosh.

## Fundamentals

**MongoDB is a document-oriented database.** It stores **documents** — self-contained records that look like JSON (stored as **BSON**, a binary version):

```javascript
{ name: 'Ayesha Khan', email: 'ayesha@example.com',
  city: 'Karachi', is_active: true, joined_at: ISODate('2024-01-15') }
```

Notice what's *inside*: values can be numbers, strings, booleans, dates, **arrays**, and **nested objects**:

```javascript
{ name: 'Wireless Mouse', price: 2499,
  tags: ['wireless', 'mouse'],
  specs: { color: 'black', warranty_months: 12 } }
```

No tables-with-fixed-columns. No "every row has the same shape." **Each document decides its own fields.**

**MongoDB is part of the NoSQL family** — a label meaning "not the relational table model" (document, key-value, graph, column). **NoSQL is a category, not a language.** You talk to MongoDB with its own API (here, JavaScript via mongosh) — not SQL.

**The honest framing:** relational databases often organize data around *what it IS* by separating important facts into **normalized entities** (for example, customers, orders, and products stored in separate tables to reduce repeated data). MongoDB often organizes data around *how it's USED* by shaping documents around the data an application reads together. Both approaches are legitimate — for different problems.

## Why It Matters

Document databases power real products everywhere (event logging, catalogs, CMS, user profiles, fast-changing app schemas). Understanding *when* this model wins is a genuinely different skill from knowing SQL.

## Mental Model

> A relational table is a **grid**: strict, uniform, every cell typed. A MongoDB collection is a **shoebox of index cards**: each card is self-contained, cards can have different fields, and a card can hold a photo taped on (nested object) or a stapled list (array). Flexibility is the design, not an accident.

## Examples

```bash
mongosh ecommerce        # after ./scripts/seed/seed-mongo.sh ecommerce
```

```javascript
show collections
db.users.find().limit(3).pretty()        // documents!
db.products.find({ _id: 7 }).pretty()   // look: tags is an ARRAY
db.orders.findOne({ _id: 4 })           // look: items is an array of OBJECTS
```

## Practice

[Beginner] **P1.** Connect; `show dbs`; `use ecommerce`; `show collections`.

[Beginner] **P2.** Inspect one user, one product, one order (`.pretty()`). For each, write down: which fields are strings, numbers, booleans, dates? Which are arrays/objects?

[Beginner] **P3.** Compare a product document with an order document — *different shapes, same database, no complaint from the DB*. That's the headline.

[Beginner] **P4.** In `use social`: find a post, and note the `likes_count` — a field the `ecommerce` documents don't have. Who decided that field exists? (The insert. Nothing else.)

[Intermediate] **P5. Predict first:** what does `db.products.find({ tags: 'usb' })` return — and *why* does that work on an array? (Predict count too; there is 1 product with 'usb'.)

[Intermediate] **P6.** The 2-minute reflection, written: name one thing a spreadsheet can do that this can't, and one thing this can do that a spreadsheet can't.

## Debugging

```javascript
// Bug 1: db.users.find() printed a wall of unreadable text.
// What's the display fix (two options)?
// Bug 2: "collection products not found in db social" — you're in the WRONG
// DATABASE. What's the check, and the fix command?
// Bug 3: db.user.find() — silent "no results"-ish behavior. What's wrong,
// and what does MongoDB do about nonexistent collections? (auto-created on
// first write — queries on missing collections just return nothing!)
```

**Answers:**

- **Bug 1 — display problem, not a data problem.** `find()` returns a *cursor* — a result object that can provide matching documents one at a time — and the shell prints it dense by default. Verify the data is fine first (`findOne()` reads one doc cleanly), then use the right control for the problem: **(1)** chain `.pretty()` to format documents, or **(2)** set the session-wide `config.set("displayBatchSize", 20)` and use `.limit(n)` to control how many results are shown. The batch-size and limit settings reduce output; they do not replace formatting.
- **Bug 2 — context problem.** Collections live inside a database, and `db` is bound to the last database you used (you just did `use social` in P4). **Check:** `db` (prints the current database) plus `show collections` (what actually exists here). **Fix:** `use ecommerce`, then re-run `db.products.find()`.
- **Bug 3 — typo, silent by design.** The collection is `users` (plural); `user` doesn't exist — and MongoDB **never errors on reads against a missing collection**: `find()` just returns an empty cursor, which looks identical to "query ran, matched nothing." Writes behave the opposite way: collections are auto-created on **first write**, so a typo'd *insert* would silently create a junk `user` collection and split your data. **Fix:** `db.users.find()` — catch the typo with `show collections` or mongosh Tab-completion, and clean up any junk with `db.user.drop()`.

## Combine Concepts

First day — instead of combining, build the **compare habit**: look at one order document and describe, in 3 sentences, how this single document can capture data that a normalized relational design might store across *multiple tables* (for example, `orders` and `order_items`, queried together with a join). You've just met the whole track's thesis: **embed what you read together**.

## Recall

1. What is a document? Name three types a field can hold (make one exotic — array or nested object).

   **A:** A **document** is a self-contained record — MongoDB's unit of storage, JSON-*looking*, stored as **BSON**. Example: `{ name: 'Wireless Mouse', price: 2499, tags: ['wireless', 'mouse'], specs: { color: 'black' } }`. Types: **string** (`'Karachi'`), **number** (`2499`), **date** (`ISODate('2024-01-15')`) — exotic: **array** (`tags`) and **nested object** (`specs`).

2. What is BSON in one line?

   **A:** **BSON (Binary JSON)** is MongoDB's binary, *typed* serialization format for JSON-like data. It supports values JSON does not represent natively, such as real dates, `ObjectId`, binary data, regular expressions, and distinct numeric types such as int32, double, and decimal128.

3. Is NoSQL a language? What is it?

   **A:** **No — NoSQL is a category, not a language.** It labels databases that aren't the relational table model (document, key-value, graph, column). Each system brings its own API; here it's MongoDB's query language driven from JavaScript in mongosh.

4. What happens when two documents in one collection have different fields?

   **A:** **MongoDB permits it by default.** There is no required fixed shape for every document: each insert can provide different fields. However, collection validators can enforce selected rules when you configure them. *Can* ≠ *should* — divergent shapes make queries silently miss data, so keep a consistent core shape and add fields deliberately; validators (Day 3) and `$exists` shape audits (Day 11) are the discipline tools.

## Interview Questions

1. "What is a document database, and how does it differ from a relational one?"

   **A:** A **document database stores self-contained documents** (JSON-looking, stored as BSON) in collections, instead of fixed-schema rows in tables. Three useful differences are: **(1) the schema is per-document** — the fields in one document can differ from another. This can happen without **DDL** (*Data Definition Language*: SQL commands such as `ALTER TABLE` that change a table's structure), but it means the application team must provide **schema discipline** — consistent field names and value types. Validators can provide extra protection. **(2) The model can embed bounded data that is commonly read together** — for example, putting an order's small `items` array inside the order. **Bounded** means it has a reasonable size limit. MongoDB also supports **references** (storing another document's `_id`), `$lookup` (MongoDB's join-like aggregation stage), and application-side joins when embedding is a poor fit. **(3) MongoDB supports replica sets for redundancy and high availability, and sharding for horizontal distribution of data and workload**. In plain language, replica sets keep copies available if a server fails, while sharding spreads large datasets or traffic across servers. Relational systems can also replicate and scale out depending on the product and workload, so this is not a universal “MongoDB scales, SQL does not” distinction. The honest framing: relational design often starts from **normalized entities** (separate tables for separate facts), while document design often starts from **application access patterns** (the data the application usually reads together). Both are legitimate, for different problems.

2. "What kinds of values can a document field hold?"

   **A:** Scalars first — **strings, numbers, booleans, dates, `null`, `ObjectId`** — plus BSON extras like binary and regex. The document-model answer is the exotic pair: **arrays** and **nested documents**, e.g. `{ tags: ['wireless', 'mouse'], specs: { color: 'black' } }`. Types live in the *value* (BSON), not the field name — `age: '25'` is a string no matter what you meant, so validate on the way in.

3. "When would you reach for MongoDB over PostgreSQL?" *(First-pass answer means a useful beginner answer for now; Days 12–15 deepen it.)*

   **A:** For now, choose MongoDB when the data is **naturally document-shaped, commonly read together, and likely to evolve** — for example, a product catalog where different products have different specifications, an event feed, user profiles, or CMS content. **Embedding** means placing related data inside the same document, such as an order's small `items` array. It can make a common, bounded read simple and can let an application add optional fields without a table migration. A **migration** is a planned change that updates an existing database structure or its data. However, embedding has trade-offs: **duplication** means storing the same fact in more than one place; **write amplification** means one logical change requires updating several stored copies; **validation** means checking that documents have the required shape and types; and **unbounded growth** means an array or document can keep growing without a safe limit. MongoDB also has a 16 MB maximum document size. Use references and `$lookup` when related data is shared, independently updated, or too large to embed. Reach for **PostgreSQL** when the data is deeply relational and **invariants** (rules that must always remain true, such as an order referring to a real customer) span multiple rows — for example, multi-table joins, strict referential integrity, or **ad-hoc reporting** (new, one-off questions across several related datasets). Best practice: **choose per workload, not ideology** — choose based on how the application reads, writes, and validates the data. Days 12–15 deepen this with real trade-offs.

## Completion Checklist

- [x] Connected, explored 3+ collections
- [x] Can name field types on sight, including arrays/objects
- [x] Completed P1–P6 (P5 predicted first)
- [x] Diagnosed all three bugs
- [x] Answered recall without notes
