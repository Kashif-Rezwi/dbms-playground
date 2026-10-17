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

[Beginner] **P1.** In mongosh: create db `playground` (`use playground`), insert into a brand-new collection — confirm it appeared (`show collections`) without any CREATE step.

[Beginner] **P2.** Insert three docs in one collection with *different shapes*. Find all three. No errors — explain in one line why that's allowed.

[Beginner] **P3.** `ObjectId().getTimestamp()` — run it, decode it, run again 2 seconds later. What changed in the timestamp part?

[Intermediate] **P4.** Decode real data: insert a doc with no `_id` (`db.mycollection.insertOne({ a: 1 })`), read back `_id`, and `getTimestamp()` it. (Our seed docs all carry explicit integer `_id`s — no timestamp hidden inside — which is exactly why you make your own.)

[Intermediate] **P5. Predict first:** `db.x.insertMany([{n:1},{n:2}])`, then insert one more, then sort by `_id` ascending — is that creation order? Explain the same-second counter, one-second timestamp resolution, and why client clock differences mean this is only approximate.

[Intermediate] **P6.** The money demo: `db.t.insertOne({a: 0.1, b: NumberDecimal('0.1')})` — then `db.t.findOne()`. What does `a` print as? Then in JS run `0.1 + 0.2` (and check `0.1 + 0.2 === 0.3`) — the classic float surprise, live.

[Advanced] **P7.** From scratch: insert a document with `_id: 'sku-001'` (a string id!) and another with `_id: 42`. What does this teach about `_id`'s flexibility — and what's the trade-off vs ObjectId (no timestamp, your uniqueness duty)?

## Debugging

```javascript
// Bug 1: db.users.insertOne({_id: 1, name: 'A'}) twice → E11000. Read the
// error: which index is named? What's the "duplicate key" concept here?
// Bug 2: someone "created a collection" but show collections shows nothing.
// What must have happened instead (only db.ghost or a read was run)? What creates it?
// Bug 3: prices stored as plain numbers; totals off by a paisa here and
// there. Which BSON type fixes it, and what does the insert look like?
```

**Answers:**

- **Bug 1 — `_id` uniqueness is enforced by an index, not by hope.** The error itself names it: `index: _id_`. Every collection automatically gets a **unique index** on `_id` the moment it's created — that's the machinery behind "an `_id` must be unique per collection." **Duplicate key** means: "this insert would store an indexed value that already exists." **Verify:** `db.dupes.getIndexes()` lists `_id_`; re-trying with `_id: 2` succeeds. **Trap:** run the same insert in `ecommerce` and it fails on the *first* try — the seeds own explicit `_id: 1`, so you collided with existing data, not with yourself.
- **Bug 2 — naming isn't creating; writes are.** Typing `db.ghost` just evaluates to a collection *handle* in the shell — nothing is sent that creates anything, and `show collections` (correctly) lists only what exists server-side. A collection is normally created by an insert (`insertOne` / `insertMany`), an update with `upsert: true` that writes a document, or the explicit `db.createCollection('ghost')` call. A no-op update or delete against a missing collection is not a reliable way to create one. **Check (the wrong-database suspect):** `db` prints your current database and `show collections` what's inside it — a "missing" collection often means it was created under a *different* database (`db` sticks to your last `use`). **Fix:** `db.ghost.insertOne({ born: true })`. **Why this bug hides:** reads against a missing collection return an **empty cursor** — no error — so only `show collections` tells the truth.
- **Bug 3 — plain numbers are floats; money needs Decimal128.** A BSON/JS plain number is an IEEE-754 **float**: `0.1 + 0.2` → `0.30000000000000004`, and adding `0.1` ten times gives `0.9999999999999999` — tiny per-calculation rounding errors that compound into totals "off by a paisa." **Fix:** store money as **`NumberDecimal`** (BSON **Decimal128** — exact base-10 arithmetic): `db.prices.insertOne({ item: 'Cable', price: NumberDecimal('899.00') })`. Always pass a **string** — `NumberDecimal(899.00)` converts the *float* as-is (whatever drift it already carries), while `'899.00'` records exactly the digits you meant. **Alternative cure:** store integer **cents/paisa** (`price_cents: 89900`) and format on display — same rule as SQL-land. **Verify:** `db.prices.findOne()` prints `NumberDecimal("899.00")` — a visibly different type from a plain `899`.

## Combine Concepts

Yesterday's shoebox, today's hierarchy: write (in your notes) the 4-line address of a review comment — from server to the exact nested field — for `db.reviews.findOne({ _id: 12 })`'s `comment` value. You've built the mental path every query will walk.

## Previous Knowledge

1. What is a document? Name three types a field can hold (make one exotic).

   **A:** A **document** is the self-contained record MongoDB stores — JSON-*looking*, saved as **BSON** — e.g. `{ name: 'Wireless Mouse', price: 2499, tags: ['wireless', 'mouse'] }`. Three types: **string** (`'Karachi'`), **number** (`2499`), **date** (`ISODate('2024-01-15')`) — exotic: **array** (`tags`) or **nested object** (`specs`).

2. What is BSON in one line — and one thing it does that JSON can't?

   **A:** **BSON (Binary JSON)** is MongoDB's binary, *typed* storage format for JSON-like data. What plain JSON can't hold: real typed values — a **date** (`ISODate`), **ObjectId**, **Decimal128**, binary/regex — JSON only has strings, numbers, booleans.

3. What did `db.products.find({ tags: 'usb' })` prove about matching against an array?

   **A:** That **plain equality on an array field means "array contains the value"** — `'usb'` found the product whose `tags: ['cable', 'usb']` holds it, no special operator needed. One query value can match any single element; the dedicated array operators arrive on Day 9.

4. "Each document decides its own fields" — what does that make *you* responsible for?

   **A:** **Schema discipline** — consistent field *names* and *types* across the collection, because the database does not enforce one fixed shape by default. Without it: the same fact gets spelled two ways, fields disappear unexpectedly, and a query may miss documents depending on the operator and whether a field is missing or `null`. Legitimate variation includes optional fields, intentional polymorphism, and versioned documents. The tools are app-side contracts, collection validators (Day 3), and shape audits.

## Recall

1. The 4-level hierarchy — from memory.

   **A:** **Server → database → collection → document.** One `mongod` process (port 27017) runs many databases (`use ecommerce`); each database holds collections (`users`, `products` — the loose "table" analog); each collection holds the documents themselves. Isolation rules: a query never crosses databases. A database becomes visible after data is written; collections are normally created by an insert, a writing upsert, or explicit `createCollection()`.

2. What can BSON do that JSON can't? (Three things.)

   **A:** Three from today's examples: **(1) real dates** — `ISODate('2025-01-15')` is a typed, sortable date where JSON would only have a string; **(2) Decimal128** — `NumberDecimal('2499.00')`, exact base-10 decimals for money (floats drift); **(3) ObjectId** — a native 12-byte id with a built-in timestamp. (Also: binary data, regex, and a binary encoding the server scans efficiently.)

3. What are the parts of an ObjectId, and what does the first one give you for free?

   **A:** 12 bytes / 24 hex chars, three parts: **timestamp (4B)** — the Unix epoch *second* of generation; **random value (5B)** — per-process randomness that reduces collisions; **counter (3B)** — increments within the same second. The **first part gives an approximate generation time**: `oid.getTimestamp()` answers *"what second was this generated?"* — and because the timestamp leads the id, ObjectIds often sort roughly in generation order (`sort({ _id: 1 })` ≈ oldest first). That is useful metadata, not guaranteed global event ordering; clocks, one-second resolution, and custom ids limit it.

4. What creates a collection? What happens to a query against a nonexistent one?

   **A:** An insert (`insertOne` / `insertMany`), a writing upsert (`updateOne(..., { upsert: true })`), or explicit `db.createCollection('name')` creates it. Merely naming `db.ghost`, reading it, or deleting from it creates nothing useful. A **query** against a missing collection normally returns an **empty cursor** — identical to "ran, matched nothing" — so read-typo bugs hide. Confirm with `show collections`.

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
- [x] Completed P1–P7 (P5 predicted first)
- [x] Diagnosed all three bugs
- [x] Answered recall without notes
