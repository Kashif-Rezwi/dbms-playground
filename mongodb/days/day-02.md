# Day 02 — Databases, Collections, Documents, BSON, ObjectId

**Track:** MongoDB · **Stage:** 1 · **Difficulty:** 🟢 Beginner

## 🎯 Goal

Know the storage hierarchy cold, understand BSON vs JSON, and decode an ObjectId like a pro.

## 🧠 Fundamentals

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
- Collections auto-create on first insert

**BSON** — the storage format: JSON-like but **binary and typed**. What JSON can't do, BSON can:

```javascript
{ date: ISODate('2025-01-15'),        // real dates, sortable
  price: NumberDecimal('2499.00'),    // exact decimals (money!)
  id: ObjectId('68abc123...') }       // native 12-byte ids
```

> Money note (the same rule as SQL-land): plain JS numbers are floats. For money use `NumberDecimal` or store integer cents. Same disease, same cure.

**ObjectId** — the auto-generated `_id` when you don't provide one:

```text
68 5d 2f a1 | 9c 3b | 2f | d4 7a 91 b2
timestamp    machine  pid  counter
```

- 4-byte **timestamp** → ObjectIds are *roughly sorted by creation time*!
- The rest → uniqueness without coordination between servers
- Every document MUST have an `_id` — unique per collection

## 🔍 Why It Matters

You'll decode ObjectIds ("when was this created?") and choose `NumberDecimal` for money in real code within weeks. And knowing *you are the schema* is the responsibility that comes with MongoDB's freedom.

## 💡 Mental Model

> Server → database → collection → document is a **building → floor → room → filing box** hierarchy. BSON is a **typed envelope**: looks like a letter (JSON), but has special stamps (dates, decimals, ids) machines read instantly. ObjectId is a **timestamped serial number**: order leaks into the id itself — you can sort by it without a created_at field.

## 💻 Examples

```javascript
use ecommerce

// BSON types in action
db.products.findOne({ _id: 9 })   // created_at: ISODate — that's BSON
const oid = db.users.findOne()._id
oid.getTimestamp()                // decode creation time from the id!

// _id rules
db.users.insertOne({ _id: 42, name: 'Explicit' })   // you choose _id → allowed
db.users.insertOne({ _id: 42, name: 'Duplicate' })  // E11000 duplicate key
```

## 🛠️ Practice

🟢 **P1.** In mongosh: create db `playground` (`use playground`), insert into a brand-new collection — confirm it appeared (`show collections`) without any CREATE step.
🟢 **P2.** Insert three docs in one collection with *different shapes*. Find all three. No errors — explain in one line why that's allowed.
🟢 **P3.** `ObjectId().getTimestamp()` — run it, decode it, run again 2 seconds later. What changed in the timestamp part?
🟡 **P4.** Decode real data: take a document seeded *without* explicit _id... (ours use explicit _ids!) — so instead: `db.mycollection.insertOne({a:1})` and read back `_id`; getTimestamp it.
🟡 **P5. ⭐ Predict first:** `db.x.insertMany([{n:1},{n:2}])`, then insert one more, then sort by `_id` ascending — is that creation order? Why *roughly* (hint: same-second inserts — the counter)?
🟡 **P6.** The money demo: `db.t.insertOne({a: 0.1, b: NumberDecimal('0.1')})` — then `db.t.findOne()`. What does `a` print as? Sum `a + a` in JS — the classic float surprise, live.
🔴 **P7.** From scratch: insert a document with `_id: 'sku-001'` (a string id!) and another with `_id: 42`. What does this teach about `_id`'s flexibility — and what's the trade-off vs ObjectId (no timestamp, your uniqueness duty)?

## 🐛 Debugging

```javascript
// Bug 1: db.users.insertOne({_id: 1, name: 'A'}) twice → E11000. Read the
// error: which index is named? What's the "duplicate key" concept here?
// Bug 2: someone "created a collection" but show collections shows nothing.
// What must have happened instead (no inserts yet)? What creates it?
// Bug 3: prices stored as plain numbers; totals off by a paisa here and
// there. Which BSON type fixes it, and what does the insert look like?
```

## 🧩 Combine Concepts

Yesterday's shoebox, today's hierarchy: write (in your notes) the 4-line address of a review comment — from server to the exact nested field — for `db.reviews.findOne({ _id: 12 })`'s `comment` value. You've built the mental path every query will walk.

## 🧠 Recall

1. The 4-level hierarchy — from memory.
2. What can BSON do that JSON can't? (Three things.)
3. What are the parts of an ObjectId, and what does the first one give you for free?
4. What creates a collection? What happens to a query against a nonexistent one?

## 🎤 Interview Questions

1. "What is the role of `_id` and what is an ObjectId?"
2. "Can a MongoDB collection contain documents with different fields? Should it?" *(Can: yes. Should: rarely — say why that's a design smell.)*
3. "How would you store money in MongoDB?" *(NumberDecimal / integer cents.)*

## ✅ Completion Checklist

- [ ] Understand hierarchy, BSON, ObjectId, _id rules
- [ ] Completed P1–P7 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Answered recall without notes
