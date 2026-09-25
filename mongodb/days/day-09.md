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

[Beginner] **P1.** Add tag 'eco' to product 5 (push), verify; add it again (push) — duplicate! Then make the same story with $addToSet — no duplicate. You've *felt* the difference.
[Beginner] **P2.** Remove the duplicate 'eco' — one $pull removes BOTH. Verify.
[Intermediate] **P3.** Batch add: $push with $each of two tags to product 7.
[Intermediate] **P4.** Capped log drill: run the $slice activity example 7 times with different `what` values; count the array — forever 5. Explain $slice: -5 in one line.
[Intermediate] **P5. Predict first:** `db.orders.updateOne({ _id: 1 }, { $addToSet: { items: { product_id: 3, quantity: 1, unit_price: 899 } } })` — items already contains that object. What happens? And if you $addToSet a *slightly different* object (quantity: 2)? Whole-object equality — say the rule.
[Intermediate] **P6.** Create the multikey index on products.tags; `explain()` (the lightweight `db.products.find({tags:'usb'}).explain()`) — spot IXscan? (Full explain comes Day 17 — just find the index-scan mention today.)
[Advanced] **P7. From memory:** the "toggle tag" workflow — $addToSet it, verify, $pull it, verify.
[Advanced] **P8.** The race-condition reasoning, written: two users simultaneously $push to the same array — what's possible in MongoDB that ISN'T in the SQL "read array, change it in the app, write it back" version? (Concurrent appends both land — $push is atomic. The app-side version loses one. This is the array-operators' killer argument.)

## Debugging

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

## Combine Concepts

The mini-cart: create a `carts` collection (user_id, items array of {product_id, quantity}); $push an item; $inc an existing item's quantity (`'items.$.quantity'`... that's positional — preview! Simpler path: $set on the matched item via filter on `items.product_id`... genuinely tricky — attempt, then note: *this exact pain is why Day 21's $unwind and aggregation exist, and why carts are often normalized*. Write the one-sentence honest verdict.)

## Previous Knowledge

1. Projection include/exclude mixing rule?
2. Skip's cost and the cursor fix?
3. `{ field: null }` matches what?
4. The delete ritual?

## Recall

1. $push vs $addToSet vs $pull — one line each.
2. What does $slice: -5 do, and which operator carries it?
3. What is a multikey index?
4. Why are array operators safer than read-modify-write in the app? (Atomicity.)

## Interview Questions

1. "How do you add an element to an array without duplicates?" *($addToSet.)*
2. "How do you index a field that contains an array?" *(Multikey index.)*
3. "Why are $push/$pull safer than updating arrays in application code?" *(Atomic server-side mutation.)*

## Completion Checklist

- [ ] Understand push/addToSet/pull/pop, $each/$slice, multikey indexes
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the mini-cart combine (and the honest verdict)
- [ ] Answered recall without notes
