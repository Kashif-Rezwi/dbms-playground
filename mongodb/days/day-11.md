# Day 11 — $exists, $type, $elemMatch

**Track:** MongoDB · **Stage:** 3 — Arrays & Nesting · **Difficulty:** 🟡 · **Milestone:** 🏗️ Project 3

## 🎯 Goal

Master the three operators that pin down *shape*: field existence, field type, and same-element matching — then finish the CRUD-and-structure stage with Project 3.

## 🧠 Fundamentals

**$exists** — does the field exist *at all* (different from having a value!):

```javascript
db.users.find({ bio: { $exists: true } })    // has the field (even if null!)
db.users.find({ bio: { $exists: false } })   // field absent
db.users.find({ bio: { $exists: true, $ne: null } })  // exists AND has a value
```

**$type** — BSON type checks (the shape-discipline enforcer):

```javascript
db.products.find({ price: { $type: 'decimal' } })
db.products.find({ price: { $type: ['double', 'int'] } })
db.products.find({ stock: { $type: 'string' } })   // the mixed-type smell detector!
```

**$elemMatch** — the any-item trap's cure. Conditions must hold on the **SAME element**:

```javascript
// ❌ wrong: product 12 in SOME item AND quantity 2 in MAYBE ANOTHER item
db.orders.find({ 'items.product_id': 12, 'items.quantity': 2 })

// ✅ right: ONE item that has both
db.orders.find({ items: { $elemMatch: { product_id: 12, quantity: 2 } } })

// and on array-of-objects-of-scalars:
db.jobs.find({ skills: { $elemMatch: { skill: 'SQL', level: 'advanced' } } })
```

**How the three team up:** "fields exist where they should, hold the right types, and array conditions bind to single elements" — that's *shape discipline* in MongoDB, where nothing else enforces it.

## 🔍 Why It Matters

These three are the diagnostic toolkit for the #1 MongoDB data problem: **inconsistent shapes** ("some prices are strings?!"). $elemMatch is a top-5 interview question for document databases.

## 💡 Mental Model

> $exists asks "**is the field even on the card?**" (a null is still ON the card!). $type is the **stamp collector verifying the stamp's kind**. $elemMatch is a **bouncer checking ONE guest's whole ID** — not "someone here is 18" AND "someone here has a ticket", but "one single guest satisfies both".

## 💻 Examples

```javascript
use jobs

db.candidates.find({ skills: { $elemMatch: { skill: 'PostgreSQL', level: 'advanced' } } })
db.jobs.find({ skills: { $elemMatch: { skill: 'SQL', required: true } } })

use social
db.users.find({ bio: { $exists: true, $ne: null } })
db.messages.find({ body: { $type: 'string' } })
```

## 🛠️ Practice

🟢 **P1.** Users WITH a bio field (`$exists: true`) — count them; then with a *non-null* bio — different count? (Our data has exactly one null bio — feel the distinction.)
🟢 **P2.** $elemMatch on jobs: skills entries with skill 'PostgreSQL' AND required true. Which jobs?
🟡 **P3.** Orders with ONE item having product_id 12 AND quantity 1 — both versions (wrong: two dotted conditions; right: $elemMatch). Same results on our data? When would they differ? *(Write a 2-doc thought experiment where they differ!)*
🟡 **P4. ⭐ Predict first:** `db.orders.find({ items: { $elemMatch: { product_id: 9, quantity: 3 } } })` — which orders match? Verify.
🟡 **P5.** The mixed-type audit: run `$type: 'string'` on `products.price`... all decimals in our data — so create the disease: update one product's price to `'999'` (a string!); now find all string-priced products. Then FIX them ($set with the number... via one update). The audit query goes in your notes forever.
🔴 **P6. From memory:** $elemMatch query — candidates with advanced PostgreSQL. Then verify against the SQL version's answer (candidate 3 and 5).
🔴 **P7.** Shape-audit report on `ecommerce` (portfolio artifact): for each collection, spot-check the 5 critical fields with $exists + $type counts; write the "shape contract" you'd enforce (which fields required, which types). This is Day 12's opening act.

## 🐛 Debugging

```javascript
// Bug 1: find({ bio: { $ne: null } }) returns users with NO bio at all.
// Wait — does it? Test it! (Actually $ne DOES match missing fields too —
// but find({bio: null}) matches missing AND null. Sort out the 4-way
// matrix: missing/null/$exists/$ne — write it in your notes.)
// Bug 2: db.orders.find({ items: { $elemMatch: 12 } }) — what shape does
// $elemMatch need? Fix it.
// Bug 3: "some ratings are stored as '5' and some as 5" — one query to
// find the strings; one update to fix them. (You built this in P5.)
```

## 🧩 Combine Concepts

**[P3: Social Feed Queries](../projects/03-social-feed.md)** — everything from Stage 3 over the social dataset: nested reads, $elemMatch correctness, array operators, shape audits. Attempt before solutions.

## 🔁 Previous Knowledge

1. Positional `$` — what does it refer to?
2. The any-item trap — restate it.
3. What does $set do to a missing path?
4. $push vs $addToSet?

## 🧠 Recall

1. $exists vs null — the 4-way matrix, from memory.
2. What's $type for, and what does it catch?
3. What does $elemMatch guarantee that dotted conditions don't?
4. When did you *feel* shape discipline today (the string-price disease)?

## 🎤 Interview Questions

1. "Explain $elemMatch and when plain dotted queries lie." *(Same-element binding.)*
2. "How do you find documents where a field is missing vs null?" *(The matrix.)*
3. "Your collection has inconsistent field types — how do you audit and fix?" *( $type scans + $set repairs + validators.)*

## ✅ Completion Checklist

- [ ] Understand $exists/$type/$elemMatch + the shape matrix
- [ ] Completed P1–P7 (P4 predicted first)
- [ ] Fixed all three bugs (matrix written!)
- [ ] Wrote the shape-audit report
- [ ] Started Project 3
