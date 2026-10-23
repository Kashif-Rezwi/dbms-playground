# Day 09 — Array Operators ($push, $pull, $addToSet)

**Track:** MongoDB · **Stage:** 3 — Arrays & Nesting · **Difficulty:** Intermediate

## Goal

Treat arrays as first-class data: append, dedupe, remove — and understand the multikey indexes that make them searchable.

## Fundamentals

**The update-side array operators:**

```javascript
// append (duplicates allowed!)
db.products.updateOne({ _id: 1 }, { $push: { tags: 'new' } })

// append without duplicates — the "unique add"
db.products.updateOne({ _id: 1 }, { $addToSet: { tags: 'new' } })

// remove by value (ALL matches)
db.products.updateOne({ _id: 1 }, { $pull: { tags: 'worn' } })

// remove first/last element
db.products.updateOne({ _id: 1 }, { $pop: { tags: 1 } })   // last; -1 = first

// batch push
db.products.updateOne({ _id: 1 }, { $push: { tags: { $each: ['a','b'] } } })
// slice to cap growth:
{ $push: { tags: { $each: [], $slice: -10 } } }   // keep last 10 only
```

**$push vs $addToSet — the decision:** order/duplicates allowed → $push; "tag-like" uniqueness → $addToSet. (It's SET semantics vs LIST semantics — same as any language.)

**Pull with objects** — a taste of its power:

```javascript
db.applications.updateOne({ _id: 1 },
    { $pull: { 'scores': { subject: 'math' } } })   // removes matching elements
```

**Multikey indexes** — why "find products with tag X" is fast:

```javascript
db.products.createIndex({ tags: 1 })   // indexes EVERY element of the array
db.products.find({ tags: 'usb' })     // index-served
```

## Why It Matters

Arrays are the document-model superpower — tags, cart items, comments, scores — and these operators are how apps mutate them atomically, without read-modify-write races.

## Mental Model

> $push is a **stack of mail** (anything appended, duplicates fine); $addToSet is the **stamp collection** (never two of the same stamp); $pull is the **magnet** (sweeps out everything matching). The multikey index is a **library catalog with a card per author** — a book with 3 authors gets 3 catalog cards; find one author, find the book instantly.

## Examples

```javascript
use ecommerce

db.products.updateOne({ _id: 1 }, { $push: { tags: 'bestseller' } })
db.products.updateOne({ _id: 1 }, { $addToSet: { tags: 'bestseller' } })  // no dup!
db.products.updateOne({ _id: 1 }, { $pull: { tags: 'wireless' } })

// $slice discipline: a capped activity log
db.users.updateOne({ _id: 2 },
  { $push: { activity: { $each: [ { at: new Date(), what: 'login' } ], $slice: -5 } } })
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Add tag 'eco' to product 5 (push), verify; add it again (push) — duplicate! Then make the same story with $addToSet — no duplicate. You've *felt* the difference.

[Beginner] **W2.** Remove the duplicate 'eco' — one $pull removes BOTH. Verify.

### 🔵 Core

[Intermediate] **C1.** `[Predict]` `db.orders.updateOne({ _id: 1 }, { $addToSet: { items: { product_id: 3, quantity: 1, unit_price: 899 } } })` — items already contains that object. What happens? And if you $addToSet a *slightly different* object (quantity: 2)? Whole-object equality — say the rule.

[Intermediate] **C2.** `[From Memory]` the "toggle tag" workflow — $addToSet it, verify, $pull it, verify.

[Intermediate] **C3.** Batch add: $push with $each of two tags to product 7.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```javascript
// Bug 1: $push added the same tag 15 times. Which operator was meant?
// Bug 2: db.users.updateOne({_id:1}, { $pull: { activity: { at: ... } } })
// removed MORE elements than expected. Why? ($pull matches ALL elements
// satisfying the condition — partial-field conditions are broad. Fix:
// exact element match, or $elemMatch-shaped condition.)
// Bug 3: "find by tag got slower after we stored tags as one comma
// string: 'a,b,c'" — what design mistake is this? (CSV-in-a-field —
// the comma-list-in-one-field disease, now killing multikey indexes. Fix: real arrays.)
```

[Advanced] **H2.** The mini-cart: create a `carts` collection (user_id, items array of {product_id, quantity}); $push an item; $inc an existing item's quantity (`'items.$.quantity'`... that's positional — preview! Simpler path: $set on the matched item via filter on `items.product_id`... genuinely tricky — attempt, then note: *this exact pain is why Day 21's $unwind and aggregation exist, and why carts are often normalized*. Write the one-sentence honest verdict.)

[Advanced] **H3.** The race-condition reasoning, written: two users simultaneously $push to the same array — what's possible in MongoDB that ISN'T in the SQL "read array, change it in the app, write it back" version? (Concurrent appends both land — $push is atomic. The app-side version loses one. This is the array-operators' killer argument.)

## Interview Questions

1. "How do you add an element to an array without duplicates?" *($addToSet.)*
2. "How do you index a field that contains an array?" *(Multikey index.)*
3. "Why are $push/$pull safer than updating arrays in application code?" *(Atomic server-side mutation.)*

## Completion Checklist

- [ ] Understand push/addToSet/pull/pop, $each/$slice, multikey indexes
- [ ] Completed Warm Up, Core, and Challenge exercises
