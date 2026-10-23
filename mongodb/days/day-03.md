# Day 03 — insertOne, insertMany & Schema Flexibility

**Track:** MongoDB · **Stage:** 1 — Foundation · **Difficulty:** Beginner
**Prerequisites:** Day 02 — Databases, Collections, Documents, BSON, ObjectId (completed)

## Goal

Create documents confidently — single, many, with your own ids — and use schema flexibility *deliberately*, not accidentally.

## Fundamentals

```javascript
// one document
db.tasks.insertOne({ title: 'Learn MongoDB', status: 'todo',
                     tags: ['db', 'nosql'], created_at: new Date() })

// many at once (one round trip — the efficient habit)
db.tasks.insertMany([
  { title: 'Ship project', status: 'doing', points: 3 },
  { title: 'Write tests',  status: 'todo',  points: 1 },
  { title: 'Review PR',    status: 'doing', points: 2 }
])
```

**Two insert habits that matter forever:**

1. **`insertMany` for batches** — one network round trip beats N. (Remember: each insert also updates any indexes — Day 16 connects this.)
2. **Verification after writing** — `find()` what you inserted. (If you did the SQL track: same discipline as SQL Day 5.)

**Schema flexibility, used well and badly:**

```javascript
// WELL: optional fields that mean something
{ name: 'Ayesha', nickname: 'Ayu' }      // nickname absent on most users:
                                        // "she doesn't have one" — honest absence
// BADLY: same fact, two names
{ name: 'Bilal', fullName: 'Sara' }      // which field is real? chaos.
// BADLY: silent typos
{ email: 'a@x.com' }, { emial: 'b@x.com' }
```

MongoDB won't stop any of this — **your discipline is the schema**. Real teams add *validation rules* at the collection level (the safety net you *choose*):

```javascript
db.createCollection('users_v', {
  validator: { $jsonSchema: { required: ['name', 'email'],
    properties: { email: { bsonType: 'string' } } } }
})
db.users_v.insertOne({ name: 'X' })   // rejected: email missing!
```

## Why It Matters

Insert is the C of CRUD — and the "MongoDB has no schema!" misunderstanding starts here. The truth: **the schema lives in your discipline and your validators**, and knowing when to use both is the skill.

## Mental Model

> `insertMany` is a **mailbag** (one trip, many letters — vs walking to the mailbox per letter). Schema flexibility is a **fill-in-any-fields form**: freedom to add "middle name" tomorrow without reprinting a million forms — and freedom to misspell it too. Validators are the **prefilled form template** you print when the team keeps misspelling.

## Examples

```javascript
use playground

// 1. Single document insert
db.tasks.insertOne({
  title: 'Learn MongoDB',
  status: 'todo',
  tags: ['db', 'nosql'],
  created_at: new Date()
})

// 2. Batch insert (one network round trip)
db.tasks.insertMany([
  { title: 'Ship project', status: 'doing', points: 3 },
  { title: 'Write tests',  status: 'todo',  points: 1 },
  { title: 'Review PR',    status: 'doing', points: 2 }
])

// 3. Collection with schema validation
db.createCollection('users_v', {
  validator: {
    $jsonSchema: {
      required: ['name', 'email'],
      properties: { email: { bsonType: 'string' } }
    }
  }
})
db.users_v.insertOne({ name: 'X' })   // rejected: email missing!
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Create a `playground` collection `tasks` (using Day 2's collection concepts); `insertOne` with a nested `meta: { created_by: 'you' }`; verify with `findOne()`.

[Beginner] **W2.** `insertMany` of 4 tasks with mixed-but-intentional shapes (some with `due_date`, some without — explain what field absence represents in document design).

### 🔵 Core

[Intermediate] **C1.** Batch habit, measured: insert 1,000 docs via `insertMany` in one call; then 1,000 one-by-one in a JS loop. Time both (`const t0 = Date.now() ...` around them). Report the ratio — that's the round-trip cost, felt.

[Intermediate] **C2.** `[Predict]` What does `insertMany([{ _id: 1 }, { _id: 1 }, { _id: 2 }])` do — all fail? Partial insert? Which documents exist after? Verify in mongosh. Then test what `{ ordered: false }` changes when handling batch errors.

[Intermediate] **C3.** `[From Memory]` The validator collection — `users_v`-style with required `name` + `email`, string types. Prove a bad insert fails.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix this broken batch insert:

```javascript
db.tasks.insertMany({ title: 'Task 1' }, { title: 'Task 2' })
```

Explain what error occurs and why, provide the corrected call, and describe two strategies to prevent duplicate records if a batch partially fails during a network retry.

[Advanced] **H2.** Combine Day 2's ObjectId with today's inserts: create an `events` collection (no explicit `_id`) and insert 3 events with a delay or distinct timestamps. Compare sorting by `_id` vs sorting by an explicit `created_at: new Date()`. In two sentences: when is natural `_id`-order sufficient, and when is an explicit timestamp necessary?

## Interview Questions

1. "MongoDB is schemaless — what does that actually mean, and what are the risks?" *(Docs vary by choice; discipline + validators are the schema.)*
2. "How do you prevent duplicate inserts when a batch partially fails?" *(Unique index / deterministic id / ordered:false handling.)*
3. "When would you add collection validation rules?"

## Completion Checklist

- [x] Understand insertOne / insertMany, ordered: false, validators, schema discipline
- [x] Completed Warm Up, Core, and Challenge exercises
