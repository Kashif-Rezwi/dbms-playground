# Day 10 — Nested Documents & Dot Notation, Deep

**Track:** MongoDB · **Stage:** 3 — Arrays & Nesting · **Difficulty:** Intermediate

## Goal

Query and update *multi-level* structures confidently — nested objects, arrays of objects, and the positional operator.

## Fundamentals

**The shapes you'll meet** (and today, master):

```javascript
{ address: { city: 'Karachi', geo: { lat: 24.86, lng: 67.0 } } }   // object in object
{ items: [ { product_id: 1, quantity: 2 }, { product_id: 3, quantity: 1 } ] } // array of objects
{ orders: [ { id: 5, items: [...] } ] }                             // object in array in object
```

**Querying — dot notation all the way down:**

```javascript
db.users.find({ 'address.geo.lat': 24.86 })
db.orders.find({ 'items.quantity': 2 })           // ANY item with quantity 2
db.orders.find({ 'items.product_id': 1, 'items.quantity': 2 })
// TRAP: these can match DIFFERENT items! The doc matches if some item has
// product 1 AND some (maybe other) item has quantity 2. The "SAME item"
// tool is $elemMatch — tomorrow!
```

**Updating — two moves:**

```javascript
// 1. set a nested field (dot notation) — also CREATES the path if absent
db.users.updateOne({ _id: 1 }, { $set: { 'address.city': 'Islamabad' } })

// 2. update the element the query matched — the positional operator $
db.orders.updateOne(
  { _id: 1, 'items.product_id': 3 },       // find the doc AND the element
  { $inc: { 'items.$.quantity': 1 } }      // $ = the matched element!
)
```

`$` = "the array element my filter matched" — the single most important array-update move, and the answer to yesterday's mini-cart pain.

## Why It Matters

Real documents are nested 2–4 levels deep (addresses, carts, scores, permissions). Dot notation + `$` are how you read and write them *surgically* — without rewriting the document.

## Mental Model

> Dot notation is a **postal address**: country.city.street — each dot zooms in. The positional `$` is "**the one I pointed at**": the query finds the document *and* puts a finger on the element; the update touches only what's under the finger.

## Examples

```javascript
use ecommerce

db.orders.find({ 'items.product_id': 12 })

db.orders.updateOne({ _id: 6, 'items.product_id': 9 },
                    { $inc: { 'items.$.quantity': 1 } })

db.users.updateOne({ _id: 2 }, { $set: { 'preferences.theme': 'dark' } })
db.users.findOne({ _id: 2 })    // preferences created, whole path!
```

## Practice

[Beginner] **P1.** Orders containing product 12 in any item. Predict the order ids first, then verify.
[Beginner] **P2.** Set user 3's `preferences.notifications` to `{ email: true, sms: false }` — the path gets created. Verify.
[Beginner] **P3.** The `$` drill: increase the quantity of product 13's item inside order 7 by 1. Verify only THAT item changed.
[Intermediate] **P4.** Deep-read trap: `db.jobs.find({ 'skills.skill': 'SQL', 'skills.level': 'advanced' })` — does this match "SQL at advanced" or "any SQL + any advanced skill"? Check candidate 1 (SQL intermediate, JS beginner) — matched or not? Say the rule.
[Intermediate] **P5. Predict first:** `db.users.find({ 'address.geo.lat': 24.86 })` — our users have NO address field. Zero results, error, or something else? Verify. (Missing paths just don't match.)
[Intermediate] **P6. From memory:** the `$` update: product 5's item in order 9 — set quantity to 4.
[Advanced] **P7.** Multi-level build: insert a `profiles` doc with `education: [{ degree, school, years: { from, to } }]`; query `'education.years.to': 2020`; update one school via positional. A genuine 3-level document, built and queried.
[Advanced] **P8.** The P4 fix, previewed: `db.jobs.find({ skills: { $elemMatch: { skill: 'SQL', level: 'advanced' } } })` — run both versions; one sentence on the difference. (Tomorrow formalizes it.)

## Debugging

```javascript
// Bug 1: updateOne({ _id: 1 }, { $set: { 'items.$.quantity': 5 } }) — error.
// The positional operator needs a matching element in the FILTER.
// What's missing? ('items.product_id': X)
// Bug 2: find({ 'items.product_id': 1, 'items.quantity': 2 }) matched more
// documents than expected — the any-item trap. Name it and the fix.
// Bug 3: sort({ 'address.city': 1 }) — docs with no address land where?
// (Missing fields sort as null — direction decides. Lesson: shape discipline.)
```

## Combine Concepts

Yesterday's mini-cart, properly solved: recreate `carts`; do it *right* — positional `$` update for "increment quantity of product X in user Y's cart", with the push-if-absent fallback (updateOne with `$` → if modifiedCount 0, `$push`). Write the 2-step upsert-the-element pattern + the honest note: this is THE canonical Mongo cart problem — and why some teams keep carts normalized (Day 13 preview).

## Previous Knowledge

1. $push vs $addToSet vs $pull?
2. What's a multikey index?
3. Deep-pagination fix?
4. Projection into arrays does what?

## Recall

1. The any-item trap — one sentence + the fixing tool's name.
2. What does the positional `$` refer to?
3. What does $set do to a *missing* nested path?
4. Where do documents missing a sorted field land?

## Interview Questions

1. "How do you update a specific element inside an array?" *(Filter on the element + positional $.)*
2. "What's the difference between two dotted conditions and $elemMatch?"
3. "How deep can nesting usefully go?" *(2–4 levels; deeper = harder queries/updates + the 16MB doc limit.)*

## Completion Checklist

- [ ] Understand deep dot queries, positional $, path creation, the any-item trap
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the solved mini-cart
- [ ] Answered recall without notes

