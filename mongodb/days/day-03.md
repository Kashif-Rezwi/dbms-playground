# Day 03 — insertOne, insertMany & Schema Flexibility

**Track:** MongoDB · **Stage:** 1 · **Difficulty:** 🟢 Beginner

## 🎯 Goal

Create documents confidently — single, many, with your own ids — and use schema flexibility *deliberately*, not accidentally.

## 🧠 Fundamentals

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
2. **Verification after writing** — `find()` what you inserted. Same discipline as SQL Day 5.

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

## 🔍 Why It Matters

Insert is the C of CRUD — and the "MongoDB has no schema!" misunderstanding starts here. The truth: **the schema lives in your discipline and your validators**, and knowing when to use both is the skill.

## 💡 Mental Model

> insertMany is a **mailbag** (one trip, many letters — vs walking to the mailbox per letter). Schema flexibility is a **fill-in-any-fields form**: freedom to add "middle name" tomorrow without reprinting a million forms — and freedom to misspell it too. Validators are the **prefilled form template** you print when the team keeps misspelling.

## 🛠️ Practice

🟢 **P1.** Create a `playground` collection `tasks`; insertOne with a nested `meta: { created_by: 'you' }`; verify with findOne.
🟢 **P2.** insertMany of 4 tasks with mixed-but-intentional shapes (some with `due_date`, some without — say what the absence means!).
🟢 **P3.** Insert with an explicit `_id` (your choice), verify; attempt a duplicate → read the E11000 error out loud.
🟡 **P4.** Batch habit, measured: insert 1000 docs via insertMany in one call; then 1000 one-by-one in a JS loop. Time both (`const t0=Date.now() ...` around them). Report the ratio — that's the round-trip cost, felt.
🟡 **P5. ⭐ Predict first:** what does `insertMany([{_id:1},{_id:1},{_id:2}])` do — all fail? Partial insert? Which documents exist after? Verify. (And: what does `{ ordered: false }` change?)
🟡 **P6. From memory:** the validator collection — users_v-style with required name+email, string types. Prove a bad insert fails.
🔴 **P7.** The schema-freedom debate, written: 4 sentences — "when is flexible schema a superpower vs a footgun?" (Superpower: evolving app, optional facts, prototypes. Footgun: same-fact-different-names, typos, missing invariants that validators should catch.)

## 🐛 Debugging

```javascript
// Bug 1: db.tasks.insertMany({a:1},{b:2})  — what error? (insertMany needs
// an ARRAY. One pair of brackets, whole different meaning.)
// Bug 2: insertMany partially succeeded and the app "retried" — now
// duplicates. What two tools fix this (unique index on business key;
// ordered:false + handling, or a deterministic _id!)
// Bug 3: a "required" field keeps going missing and different teams write
// different checks. What collection-level tool centralizes it?
```

## 🧩 Combine Concepts

Yesterday's ObjectId + today's inserts: create `events` (no explicit _id) — insert 3 events 1 second apart; sort by `_id` — creation order? Now add `created_at: new Date()` to your insert habit and compare sorting by both. Two lines: when is _id-order good enough, and when is created_at the honest choice?

## 🔁 Previous Knowledge

1. The 4-level hierarchy — from memory.
2. What are ObjectId's parts? What's the free benefit?
3. Which BSON type for money?
4. What creates a collection?

## 🧠 Recall

1. insertOne vs insertMany — and why batching matters (the cost you measured).
2. What does `{ ordered: false }` change on partial failure?
3. Validator collections — what do they enforce, and what do they NOT (answer: shape rules, not cross-document logic)?
4. Good vs bad schema flexibility — one example each.

## 🎤 Interview Questions

1. "MongoDB is schemaless — what does that actually mean, and what are the risks?" *(Docs vary by choice; discipline + validators are the schema.)*
2. "How do you prevent duplicate inserts when a batch partially fails?" *(Unique index / deterministic id / ordered:false handling.)*
3. "When would you add collection validation rules?"

## ✅ Completion Checklist

- [ ] Understand insertOne/Many, ordered:false, validators, schema discipline
- [ ] Completed P1–P7 (P5 predicted first; P4's numbers recorded)
- [ ] Fixed all three bugs
- [ ] Answered recall without notes
