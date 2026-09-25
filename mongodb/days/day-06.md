# Day 06 — deleteOne, deleteMany + CRUD Review

**Track:** MongoDB · **Stage:** 2 — CRUD Mastery · **Difficulty:** Beginner

## Goal

Remove documents safely, prove MongoDB's soft-delete-shaped tools, and review the full CRUD cycle end to end.

## Fundamentals

```javascript
db.reviews.deleteOne({ _id: 13 })
db.reviews.deleteMany({ rating: { $lte: 2 } })   // operators in delete filters too!
db.reviews.deleteMany({})                        // WIPES THE COLLECTION (allowed!)
```

**Safety habits** (if you did the SQL track: identical philosophy to SQL Day 6):

1. **Preview the filter**: `find()` with the same filter *before* deleting
2. **Read the return**: `deletedCount` — did it match your expectation?
3. **Prefer soft delete** in real products: `deleted_at: new Date()` + a query filter — MongoDB makes this *especially* natural since an extra field on some documents is free

**Dropping vs deleting:** `deleteMany({})` removes documents (collection + indexes survive, empty); `db.c.drop()` removes the collection itself (indexes gone too). `db.dropDatabase()` is the nuke.

## Why It Matters

D of CRUD — plus the CRUD review that consolidates Stage 2's foundations before operators get fancy.

## Mental Model

> deleteOne/deleteMany is a **paper shredder with a scope dial** — the filter IS the scope. Preview = hold the stack up to the light first. Soft delete = the **archive box**: it leaves the room, but it's still in the building if you must retrieve it.

## Examples

```javascript
use ecommerce

// preview → delete → verify (the ritual)
db.reviews.find({ rating: { $lte: 2 } })          // 1 doc (the Blender 2-star)
db.reviews.deleteMany({ rating: { $lte: 2 } })
db.reviews.countDocuments({})                    // 11 now

// soft-delete shape
db.reviews.updateOne({ _id: 12 }, { $set: { hidden: true } })
db.reviews.find({ hidden: { $ne: true } })        // queries that "just skip" archived
```

## Practice

[Beginner] **P1.** Preview → delete → verify: remove the review of product 12 (id 4, rating 2). Use the ritual exactly.
[Beginner] **P2.** Soft-delete reviews with rating 3 (`hidden: true`) — then list only visible reviews. Which shape is "hidden" here, and where does the filter live? (Every read. Your call.)
[Beginner] **P3.** Restore one hidden review (`$unset` the field).
[Intermediate] **P4.** In a scratch collection: deleteMany with an empty filter — observe it's *allowed* in mongosh (unlike updateMany!) — on scratch data only. Note the asymmetry: MongoDB protects you from *updating* everything but not from *deleting* everything. One-line lesson.
[Intermediate] **P5. Predict first:** `deleteMany({ 'items.quantity': 2 })` on orders — how many orders die? (Quantity 2 appears in orders 3? no wait — predict with the seed data, then verify... and reset after!)
[Intermediate] **P6. From memory:** the full CRUD liturgy: insert one + verify, find with a filter, $inc something, delete with preview.
[Advanced] **P7.** The CRUD review — one workflow, all four verbs: create a `watchlist` (product ids you want), add 3; mark one as "bought" ($set); remove one (deleteOne with preview); list what remains + a count. Write the 5 calls from memory, then verify.

## Debugging

```javascript
// Bug 1: db.reviews.deleteMany({ rating: $lte }) — syntax error. What is
// missing around the $lte clause? (Operators need { } — a value can't be
// a bare operator.)
// Bug 2: "deletedCount: 0" but you SWEAR the doc exists. Two checks:
// (wrong database — `db`? wrong filter — find() it first!)
// Bug 3: after a soft-delete rollout, some legacy reads still show hidden
// reviews. What was forgotten? (The reads — every query needs the filter.
// Discuss: what tool makes "every query" automatic? — Day 19's $match...
// or Day 12's design discipline.)
```

## Combine Concepts

The inventory mini-flow (CRUD + arrays): insert a product with `tags: []`; `$push` a tag; `$addToSet` the same tag again (observe: no duplicate — preview of Day 9!); find by that tag; then soft-delete the product. One workflow, five concepts — and one deliberate preview.

## Previous Knowledge

1. Operator-less update does what?
2. Upsert — the "record a stat" pattern, from memory.
3. Array matching rule (any element)?
4. What does `matchedCount` tell you that `modifiedCount` doesn't?

## Recall

1. The three-step delete ritual?
2. deleteMany({}) vs drop() vs dropDatabase() — one line each.
3. Why does MongoDB allow empty-filter deleteMany but block empty-filter updateMany? What lesson does that asymmetry teach?
4. Soft delete's shape in a document database — why is it extra-natural here?

## Interview Questions

1. "How do you safely delete documents in MongoDB?"
2. "When would you soft-delete instead?" *(Recoverability, audit, free-form documents.)*
3. "deleteMany vs drop — what's the difference?" *(Docs vs the whole collection+indexes.)*

## Completion Checklist

- [ ] Understand deleteOne/Many, the ritual, soft delete, drop levels
- [ ] Completed P1–P7 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the watchlist CRUD review
- [ ] Answered recall without notes
