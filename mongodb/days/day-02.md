# Day 02 — Databases, Collections, Documents, BSON, ObjectId

**Track:** MongoDB · **Stage:** 1 — Foundation · **Difficulty:** Beginner
**Prerequisites:** Day 01 — What Is a Document Database? + mongosh (completed)

## Goal

Know the storage hierarchy cold, understand BSON vs JSON, and decode an ObjectId like a pro.

## Fundamentals

**The hierarchy:**

```text
MongoDB server (one process, port 27017)
 └── databases                (use ecommerce)
      └── collections         (users, products — loose analog of "table")
           └── documents       (the records — the star of the show)
```

**Collections vs tables** — the differences that matter:

- Documents in one collection can have **different shapes** (usually they *shouldn't* — that's a design smell — but the DB won't stop you)
- No fixed schema is enforced; **you** are responsible for schema discipline (Day 12 is about deserving that freedom)
- A database becomes visible after data is written, and a collection is normally created by an insert, an upsert that writes a document, or an explicit `createCollection()` call. Merely naming a collection, reading it, or deleting from a missing collection does not create useful stored data. Empty explicitly-created collections appear in `show collections`.

**BSON** — the storage format: JSON-like but **binary and typed**. What JSON can't do, BSON can:

```javascript
{ date: ISODate('2025-01-15'),        // real dates, sortable
  price: NumberDecimal('2499.00'),    // exact decimals (money!)
  id: ObjectId('68abc123...') }       // native 12-byte ids
```

> Money note (the same rule as SQL-land): JavaScript numbers are usually IEEE-754 doubles. For money use `NumberDecimal`/Decimal128 constructed from a string, or store integer minor units such as cents. Pick one currency scale and rounding policy for the application.

**ObjectId** — the auto-generated `_id` when you don't provide one. **12 bytes (24 hex chars)**, built from three parts:

```text
68 5d 2f a1 | 9c 3b 2f d4 7a | 91 b2 c3
timestamp     random value       counter
```

| Part | Bytes | What it holds |
|---|---|---|
| **Timestamp** | 4 | Unix epoch **seconds** when the id was created |
| **Random value** | 5 | Per-process random value used to reduce collisions |
| **Counter** | 3 | Increments per id — two ids in the same second can't collide |

The random value and counter make collisions extremely unlikely without coordination. This is practical collision resistance, not an absolute global uniqueness guarantee.

**The free benefit:** the timestamp comes *first*, so ObjectIds are **roughly creation-ordered** — `sort({ _id: 1 })` often resembles oldest → newest — and `oid.getTimestamp()` answers *"what second was this id generated?"* **without a `created_at` field**. This is not a guaranteed event-ordering mechanism: timestamps have one-second resolution, client clocks can differ, and custom ids (`42`, `'sku-001'`) have no embedded timestamp. Uniqueness for custom ids is your job (P7).

- Every document MUST have an `_id` — unique per collection

## Why It Matters

You'll decode ObjectIds ("when was this created?") and choose `NumberDecimal` for money in real code within weeks. And knowing *you are the schema* is the responsibility that comes with MongoDB's freedom.

## Mental Model

> Server → database → collection → document is a **building → floor → room → filing box** hierarchy. BSON is a **typed envelope**: looks like a letter (JSON), but has special stamps (dates, decimals, ids) machines read instantly. ObjectId is a **timestamped serial number**: it gives an approximate generation time, not a guaranteed global event order.

## Examples

```javascript
use ecommerce   // after ./scripts/seed/seed-mongo.sh ecommerce

// BSON types in action
db.products.findOne({ _id: 9 })   // created_at: ISODate — that's BSON

// ObjectId — the seed docs use explicit integer _ids, so make your own:
const { insertedId } = db.users.insertOne({ name: 'Auto Id' })
insertedId                        // an ObjectId the server generated for you
insertedId.getTimestamp()         // decode creation time from the id!

// _id rules
db.users.insertOne({ _id: 42, name: 'Explicit' })   // you choose _id → allowed
db.users.insertOne({ _id: 42, name: 'Duplicate' })  // E11000 duplicate key
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** In mongosh: create db `playground` (`use playground`), insert a document into a brand-new collection — confirm it appears in `show collections` without any explicit `CREATE` step.

[Beginner] **W2.** Insert three documents into one collection with intentionally different shapes. Find all three and explain in one sentence why MongoDB permits this shape variation.

### 🔵 Core

[Intermediate] **C1.** `ObjectId().getTimestamp()` — run it, decode the creation timestamp, and run it again 2 seconds later. What changed in the timestamp portion? Next, insert a document with no explicit `_id` (`db.mycollection.insertOne({ a: 1 })`), read back the generated `_id`, and decode its timestamp with `getTimestamp()`.

[Intermediate] **C2.** `[Predict]` What does sorting by `_id` ascending after multiple inserts do? Explain the 4-byte timestamp, the per-process random bytes, the incrementing counter, and why client clock skew means `_id` ordering is only approximately chronological.

[Intermediate] **C3.** `[From Memory]` The money demonstration: insert `{ a: 0.1, b: NumberDecimal('0.1') }` into a test collection and inspect the output with `findOne()`. In mongosh JavaScript, evaluate `0.1 + 0.2 === 0.3` to witness the binary float surprise, and explain why `NumberDecimal` requires passing a string.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix these two common schema and index issues:
1. `db.users.insertOne({ _id: 1, name: 'A' })` executed twice throws an `E11000` duplicate key error. What underlying index enforces this constraint, and why does this fail even if the collection had no explicit schema?
2. A developer stores product prices as plain numbers and finds totals drifting by cents across transactions. Write the exact insert statement using `NumberDecimal` that guarantees exact precision.

[Advanced] **H2.** The 4-level hierarchy in practice: write the exact 4-line conceptual address of a review comment — from the running `mongod` process down to the nested field — for `db.reviews.findOne({ _id: 12 })`'s `comment` property.

## Interview Questions

1. "What is the role of `_id` and what is an ObjectId?"

   **A:** `_id` is every document's **primary key**: mandatory, **unique within its collection**, and **immutable** (cannot be updated). The uniqueness is enforced by MongoDB's automatic unique **`_id_` index**, so repeating an `_id` fails with **E11000 duplicate key**. You may supply your own `_id` of any supported BSON type; if you do not, the driver typically supplies an **ObjectId** — 12 bytes: **4-byte timestamp**, **5-byte random value**, and **3-byte counter**. ObjectIds provide an approximate generation time and practical collision resistance, not guaranteed global ordering or mathematical uniqueness. A business key such as email or SKU needs its own unique index; `_id` uniqueness is only per collection. Custom ids (`'sku-001'`, `42`) may be readable, but they give up the embedded timestamp and make collision policy your responsibility.

2. "Can a MongoDB collection contain documents with different fields? Should it?" *(Can: yes. Should: rarely — say why that's a design smell.)*

   **A:** **Can — yes; should — deliberately.** MongoDB enforces no fixed shape by default — **schemaless** means *no enforced fixed shape*, not *no schema* — so documents can evolve without relational-style **DDL**. Variation is legitimate for optional fields, intentional polymorphism, or versioned documents. It becomes a design smell when documents representing the same concept use inconsistent names or types. Query behavior also depends on the operator: a predicate may exclude documents with missing fields, while other operators treat missing and `null` differently. Keep a stable core shape, document the contract, and use validators (Day 3), indexes, and application checks where needed.

3. "How would you store money in MongoDB?" *(NumberDecimal / integer cents.)*

   **A:** **Do not use an unexamined floating-point convention for money.** Two sound answers are: **(1) `NumberDecimal`** — BSON **Decimal128**, exact base-10 for the chosen scale: `price: NumberDecimal('19.99')`, constructed from a **string** so no float error sneaks in (`NumberDecimal(19.99)` starts from a binary float); or **(2) integer minor units** — `price_cents: 1999` (or paisa), formatted on display. Define the currency, scale, rounding policy, and one representation app-wide. The why: binary floating point can produce `0.1 + 0.2 → 0.30000000000000004`, and small errors can compound across totals and aggregations.

## Interview Traps

- **ObjectId is not an event log.** Its leading timestamp is second-resolution metadata. It does not prove exact insertion order, and it should not replace an explicit event timestamp when ordering matters.
- **Schemaless is not schema-free.** MongoDB allows shape variation, but production applications still need a documented contract, consistent types, validation, and indexes.
- **Collection creation depends on the operation.** Inserts, writing upserts, and explicit `createCollection()` are reliable creation paths. A read, a collection handle, a no-op update, or a delete against a missing collection should not be treated as one.
- **`_id` is collection-scoped.** The same `_id` value can exist in two different collections. A business identifier needs its own uniqueness rule, usually a unique index.

## Completion Checklist

- [x] Know the hierarchy cold: server → database → collection → document
- [x] Can decode an ObjectId's three parts — and name its free benefit
- [x] Completed Warm Up, Core, and Challenge exercises
