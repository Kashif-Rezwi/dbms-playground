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

### 🟢 Warm Up

[Beginner] **W1.** Connect to mongosh, run `show dbs`, switch to `use ecommerce`, and inspect the available collections with `show collections`.

[Beginner] **W2.** Inspect one user, one product, and one order document with `.pretty()`. For each, identify which fields are scalars (string, number, boolean, date) versus exotic types (arrays, nested objects).

### 🔵 Core

[Intermediate] **C1.** Compare a `products` document with an `orders` document in `ecommerce`, then inspect a post document in `social` (noting `likes_count`). What do these different shapes in the same engine prove about MongoDB document modeling?

[Intermediate] **C2.** `[Predict]` Predict what `db.products.find({ tags: 'usb' })` returns before executing it, and explain why querying an array with a scalar value works in MongoDB. Verify the count.

[Intermediate] **C3.** `[From Memory]` Write down the two fundamental ways MongoDB handles data that a relational database would normalize into multiple tables: when do you embed, and when do you reference?

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and resolve these two common beginner mongosh traps:
1. Running `db.user.find()` returns nothing without throwing an error, even though users exist in the database. What causes this silent empty cursor, how do collections behave on read vs write, and how do you fix it?
2. You run `db.products.find()` and receive a "collection not found in db social" error. What is the root cause, what check command confirms your context, and how do you switch back?

[Advanced] **H2.** The Document vs Relational contrast: look at one order document in `db.orders.findOne()`. In 3 sentences, explain how this single document captures data that a normalized relational database stores across `orders` and `order_items` joined together.

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
- [x] Completed Warm Up, Core, and Challenge exercises
