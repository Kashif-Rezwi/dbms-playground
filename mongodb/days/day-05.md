# Day 05 — Update Operators ($set, $inc, and friends)

**Track:** MongoDB · **Stage:** 2 — CRUD Mastery · **Difficulty:** 🟢→🟡 · **Milestone:** 🏗️ Project 1

## 🎯 Goal

Update *precisely* — operators, upserts, and the classic disaster that `updateOne` without a filter prevents only if YOU prevent it.

## 🧠 Fundamentals

**The #1 rule before anything:** updates take a *filter* + an *update document*:

```javascript
db.tasks.updateOne({ _id: 1 }, { $set: { status: 'done' } })
db.tasks.updateMany({ status: 'todo' }, { $set: { status: 'archived' } })
```

**⚠️ The footgun:** an update *without operators* **REPLACES the whole document** (except `_id`):

```javascript
db.tasks.updateOne({ _id: 1 }, { status: 'done' })
// task 1 now has EXACTLY { _id: 1, status: 'done' } — title GONE.
// (Modern drivers error without replace intent — replaceOne() is the
//  explicit form. But KNOW the trap.)
```

**The operator toolbox:**

```javascript
{ $set: { city: 'Lahore' } }              // set fields
{ $unset: { nickname: '' } }              // remove a field
{ $inc: { login_count: 1, points: -5 } } // atomic increment/decrement
{ $rename: { 'created': 'created_at' } }  // rename a field
{ $mul: { price: 1.05 } }                 // multiply
{ $push: { tags: 'new' } }                // append to array (Day 9 deep-dive)
{ $currentDate: { updated_at: true } }    // timestamp discipline
```

**Upsert** — update-or-insert in one call:

```javascript
db.stats.updateOne({ user_id: 1 },
                   { $inc: { login_count: 1 } },
                   { upsert: true })   // no doc? create it, then inc runs
```

**Always verify** with a find after — and **read the return values**: `matchedCount` / `modifiedCount`.

## 🔍 Why It Matters

U of CRUD — and `$inc` is *atomic* (no read-then-write races). The no-operator replace trap and the empty-filter updateMany are the two accidents that delete real data weekly, worldwide.

## 💡 Mental Model

> The update document is a **set of instructions**, not a document: `$set` = "paint this", `$inc` = "turn this dial" (safely — nobody can interleave with your turn), `$push` = "staple this to the list". An update without operators is a **document swap**: you hand over a new card, the old one is shredded.

## 💻 Examples

```javascript
use ecommerce

db.users.updateOne({ _id: 4 }, { $set: { is_active: true } })
db.users.findOne({ _id: 4 })                       // verify!

db.products.updateOne({ _id: 1 }, { $inc: { stock: -1 } })

db.orders.updateOne({ _id: 8 }, { $set: { status: 'shipped' },
                                 $currentDate: { updated_at: true } })

db.view_counts.updateOne({ product_id: 1 },
                         { $inc: { count: 1 } }, { upsert: true })
```

## 🛠️ Practice

🟢 **P1.** Reactivate users 4 and 8 with ONE updateMany. Verify.
🟢 **P2.** Sell 2 units of product 9 — `$inc: { stock: -2 }`. Verify before/after.
🟢 **P3.** The replace trap, safely: scratch collection, one doc, `updateOne(filter, {only_one_field})` — record what your mongosh does (error or replace?).
🟡 **P4.** `$mul: { stock: 1.10 }` on Sports products — then look at the values. Integer problem! Discuss the honest fix (avoid $mul on integer fields; compute per-doc, or accept and round). Which fields are *never* ok to $mul?
🟡 **P5. ⭐ Predict first:** upsert on `stats` twice in a row (user_id 1, `$inc: {count: 1}`) — count = 0, 1, or 2 after?
🟡 **P6. From memory:** the "record a view" upsert for product 3 — run twice, verify count = 2.
🔴 **P7.** The safe-update rules, written (5 lines): preview the filter with a find first; always use operators; read matchedCount/modifiedCount; upsert only with a business-key filter; verify after. Which two are identical to SQL Day 6's habits?

## 🐛 Debugging

```javascript
// Bug 1: updateMany with an EMPTY filter {} — MongoDB blocks it for safety.
// Verify your version's error; note the SQL equivalent disaster.
// Bug 2: db.tasks.updateOne({_id:1}, {title:'New', $set:{a:1}}) — "unknown
// top level operator" mixed with a bare field. What's the rule?
// Bug 3: "the counter keeps resetting to 1" — an upsert colliding with a
// plain insert elsewhere. The invariant fix? (unique index on the
// business key + upsert everywhere.)
```

## 🧩 Combine Concepts

Full CRUD cycle in one workflow: **insert** a review (product 3, rating 5, nested `helpful_votes: { up: 0, down: 0 }`), **update** with `$inc` twice (an up-vote), **find** it with dot notation (`'helpful_votes.up': 1`). Project 1 puts the whole cycle together.

## 🔁 Previous Knowledge

1. Dot-notation query for a nested field — from memory.
2. Array matching rule?
3. What BSON type for money (and why is $mul on money risky)?
4. What creates a collection?

## 🧠 Recall

1. What does an operator-less update document do?
2. $set vs $inc — and what makes $inc special?
3. What is an upsert and when is it *the* pattern?
4. The return values every update gives that you must read?

## 🎤 Interview Questions

1. "How do you atomically increment a counter in MongoDB?" *($inc — atomic.)*
2. "What's the difference between updateOne with $set and replaceOne?"
3. "How do you implement 'increment or create' in one call?" *(Upsert.)*

## 🏗️ Mini Project — Stage 1 + today = consolidation!

Build **[P1: Task Manager (Mongo CRUD)](../projects/01-task-manager.md)** — full CRUD over your own task documents. Attempt before solutions.

## ✅ Completion Checklist

- [ ] Understand operators, replace trap, upsert, return values
- [ ] Completed P1–P7 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Started Project 1
- [ ] Answered recall without notes

