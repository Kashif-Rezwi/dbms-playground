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
- No schema is enforced; **you** are the schema (Day 12 is about deserving that freedom)
- Databases and collections **create themselves on first write** — no CREATE step, and empty ones don't appear in `show dbs` / `show collections`

**BSON** — the storage format: JSON-like but **binary and typed**. What JSON can't do, BSON can:

```javascript
{ date: ISODate('2025-01-15'),        // real dates, sortable
  price: NumberDecimal('2499.00'),    // exact decimals (money!)
  id: ObjectId('68abc123...') }       // native 12-byte ids
```

> Money note (the same rule as SQL-land): plain JS numbers are floats. For money use `NumberDecimal` or store integer cents. Same disease, same cure.

**ObjectId** — the auto-generated `_id` when you don't provide one. **12 bytes (24 hex chars)**, built from four parts:

```text
68 5d 2f a1 | 9c 3b 2f | d4 7a | 91 b2 c3
timestamp     machine    pid     counter
```

| Part | Bytes | What it holds |
|---|---|---|
| **Timestamp** | 4 | Unix epoch **seconds** when the id was created |
| **Machine** | 3 | Which machine/client generated it |
| **PID** | 2 | Which process generated it |
| **Counter** | 3 | Increments per id — two ids in the same second can't collide |

Machine + PID exist so **uniqueness needs no coordination** between servers. *(Newer MongoDB versions store those middle 5 bytes as one random value — same idea.)*

**The free benefit:** the timestamp comes *first*, so ObjectIds are **roughly creation-ordered** — `sort({ _id: 1 })` ≈ oldest → newest — and `oid.getTimestamp()` answers *"when was this created?"* **without a `created_at` field**. Trade-off: custom ids (`42`, `'sku-001'`) give that up — no timestamp, and uniqueness becomes *your* job (P7).

- Every document MUST have an `_id` — unique per collection

## Why It Matters

You'll decode ObjectIds ("when was this created?") and choose `NumberDecimal` for money in real code within weeks. And knowing *you are the schema* is the responsibility that comes with MongoDB's freedom.

## Mental Model

> Server → database → collection → document is a **building → floor → room → filing box** hierarchy. BSON is a **typed envelope**: looks like a letter (JSON), but has special stamps (dates, decimals, ids) machines read instantly. ObjectId is a **timestamped serial number**: order leaks into the id itself — you can sort by it without a created_at field.

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

[Intermediate] **P5. Predict first:** `db.x.insertMany([{n:1},{n:2}])`, then insert one more, then sort by `_id` ascending — is that creation order? Why *roughly* (hint: same-second inserts — the counter)?

[Intermediate] **P6.** The money demo: `db.t.insertOne({a: 0.1, b: NumberDecimal('0.1')})` — then `db.t.findOne()`. What does `a` print as? Then in JS run `0.1 + 0.2` (and check `0.1 + 0.2 === 0.3`) — the classic float surprise, live.

[Advanced] **P7.** From scratch: insert a document with `_id: 'sku-001'` (a string id!) and another with `_id: 42`. What does this teach about `_id`'s flexibility — and what's the trade-off vs ObjectId (no timestamp, your uniqueness duty)?

## Debugging

```javascript
// Bug 1: db.users.insertOne({_id: 1, name: 'A'}) twice → E11000. Read the
// error: which index is named? What's the "duplicate key" concept here?
// Bug 2: someone "created a collection" but show collections shows nothing.
// What must have happened instead (no inserts yet)? What creates it?
// Bug 3: prices stored as plain numbers; totals off by a paisa here and
// there. Which BSON type fixes it, and what does the insert look like?
```

**Answers:**

- **Bug 1 — `_id` uniqueness is enforced by an index, not by hope.** The error itself names it: `index: _id_`. Every collection automatically gets a **unique index** on `_id` the moment it's created — that's the machinery behind "an `_id` must be unique per collection." **Duplicate key** means: "this insert would store an indexed value that already exists." **Verify:** `db.dupes.getIndexes()` lists `_id_`; re-trying with `_id: 2` succeeds. **Trap:** run the same insert in `ecommerce` and it fails on the *first* try — the seeds own explicit `_id: 1`, so you collided with existing data, not with yourself.
- **Bug 2 — naming isn't creating; writes are.** Typing `db.ghost` just evaluates to a collection *handle* in the shell — nothing is sent that creates anything, and `show collections` (correctly) lists only what exists server-side. The one thing that creates a collection: **a first write** (`insertOne` / `insertMany` / update / delete) — or the explicit escape hatch `db.createCollection('ghost')`. **Check (the wrong-database suspect):** `db` prints your current database and `show collections` what's inside it — a "missing" collection often means it was created under a *different* database (`db` sticks to your last `use`). **Fix:** `db.ghost.insertOne({ born: true })`. **Why this bug hides:** reads against a missing collection return an *empty cursor* — no error — so only `show collections` tells the truth.
- **Bug 3 — plain numbers are floats; money needs Decimal128.** A BSON/JS plain number is an IEEE-754 **float**: `0.1 + 0.2` → `0.30000000000000004`, and adding `0.1` ten times gives `0.9999999999999999` — tiny per-calculation rounding errors that compound into totals "off by a paisa." **Fix:** store money as **`NumberDecimal`** (BSON **Decimal128** — exact base-10 arithmetic): `db.prices.insertOne({ item: 'Cable', price: NumberDecimal('899.00') })`. Always pass a **string** — `NumberDecimal(899.00)` converts the *float* as-is (whatever drift it already carries), while `'899.00'` records exactly the digits you meant. **Alternative cure:** store integer **cents/paisa** (`price_cents: 89900`) and format on display — same rule as SQL-land. **Verify:** `db.prices.findOne()` prints `NumberDecimal("899.00")` — a visibly different type from a plain `899`.

## Combine Concepts

Yesterday's shoebox, today's hierarchy: write (in your notes) the 4-line address of a review comment — from server to the exact nested field — for `db.reviews.findOne({ _id: 12 })`'s `comment` value. You've built the mental path every query will walk.

## Previous Knowledge

1. What is a document? Name three types a field can hold (make one exotic).
2. What is BSON in one line — and one thing it does that JSON can't?
3. What did `db.products.find({ tags: 'usb' })` prove about matching against an array?
4. "Each document decides its own fields" — what does that make *you* responsible for?

## Recall

1. The 4-level hierarchy — from memory.
2. What can BSON do that JSON can't? (Three things.)
3. What are the parts of an ObjectId, and what does the first one give you for free?
4. What creates a collection? What happens to a query against a nonexistent one?

## Interview Questions

1. "What is the role of `_id` and what is an ObjectId?"
2. "Can a MongoDB collection contain documents with different fields? Should it?" *(Can: yes. Should: rarely — say why that's a design smell.)*
3. "How would you store money in MongoDB?" *(NumberDecimal / integer cents.)*

## Completion Checklist

- [x] Know the hierarchy cold: server → database → collection → document
- [x] Can decode an ObjectId's four parts — and name its free benefit
- [x] Completed P1–P7 (P5 predicted first)
- [x] Diagnosed all three bugs
- [ ] Answered recall without notes
