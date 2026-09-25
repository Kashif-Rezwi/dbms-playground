# Day 07 — Comparison & Logical Operators

**Track:** MongoDB · **Stage:** 2 — CRUD Mastery · **Difficulty:** 🟢→🟡

## 🎯 Goal

Filter beyond equality: ranges, membership, and AND/OR logic — MongoDB's WHERE-clause equivalents.

## 🧠 Fundamentals

**Comparison operators** — always wrapped in `{ field: { $op: value } }`:

```javascript
db.products.find({ price: { $gt: 3000 } })               // greater than
db.products.find({ price: { $gte: 1000, $lte: 5000 } })   // range (BETWEEN!)
db.products.find({ city: { $in: ['Karachi', 'Lahore'] } }) // membership (IN!)
db.products.find({ city: { $nin: ['Karachi'] } })          // not-in
// $eq $ne $gt $gte $lt $lte $in $nin
```

**Logical operators** — the explicit forms:

```javascript
db.users.find({ $or: [ { city: 'Karachi' }, { is_active: false } ] })
db.users.find({ $and: [ { price: { $gt: 100 } }, { price: { $lt: 500 } } ] })
db.users.find({ city: { $ne: 'Karachi' } })   // implicit NOT for single fields
```

**The rule you already guessed:** multiple fields in one object = implicit AND. Use explicit `$and` only when the *same field* needs two conditions (or with operators that can't share an object key).

**$ne's trap** (same as SQL's story): `$ne: 'x'` also matches documents where the field **doesn't exist** — and **`null` behaves specially**: `find({ field: null })` matches *both* nulls and missing fields. The precise tool for "field exists" arrives tomorrow-preview / Day 11 ($exists).

## 🔍 Why It Matters

Ranges, multi-city filters, price brackets — every product filter UI is these operators. And the null/missing quirk is MongoDB's #1 silent bug.

## 💡 Mental Model

> Comparison operators are the **same stencils as SQL** ($gte = ≥, $in = the guest list). $or is a **union of guest lists**; implicit AND is "the AND you get for free"; explicit $and is the **AND you must spell out** when one field wears two conditions at once.

## 💻 Examples

```javascript
use ecommerce

db.products.find({ price: { $gte: 2000, $lte: 6000 } })
db.users.find({ city: { $in: ['Karachi', 'Lahore', 'Multan'] } })
db.products.find({ $or: [ { category_id: 1 }, { stock: 0 } ] })
db.orders.find({ status: { $in: ['pending', 'shipped'] }, total_amount: { $gt: 5000 } })

use jobs
db.jobs.find({ salary_max: { $gte: 100000 }, is_remote: true })
```

## 🛠️ Practice

🟢 **P1.** Products priced 1000–2500 (inclusive). Predict the count first.
🟢 **P2.** Users NOT from Karachi (either $ne or $nin — try both; do the results differ? Why?).
🟡 **P3.** Products in category 2 OR with stock 0.
🟡 **P4.** Orders that are pending OR shipped, with total over 3000. (Implicit AND + $or + $gt.)
🟡 **P5. ⭐ Predict first:**

```javascript
db.users.find({ bio: { $ne: 'hello' } })
```

How many users match — and *which user surprises you*? (One user has no bio field at all. What happened?) This is the missing-field quirk, live.
🟡 **P6.** In jobs: remote roles with max salary ≥ 120000 OR any role requiring PostgreSQL. One query.
🔴 **P7. From memory:** price between 500 and 1500 AND (category 3 OR tag 'book') — one query, mixing implicit AND, range, and $or.
🔴 **P8.** The $and necessity drill: find products with price > 1000 AND price < 3000 — write it with implicit syntax `{ price: { $gt: 1000, $lt: 3000 } }` (works! operators stack) vs explicit $and. When does implicit FAIL and $and become required? (Duplicate keys in a JS object: `{ price: {...}, price: {...} }` — impossible — say why that forces $and.)

## 🐛 Debugging

```javascript
// Bug 1: db.products.find({ price: $gt: 100 }) — syntax error. Operators
// live inside a nested object: the fix in one line.
// Bug 2: "city != Karachi" returns users who have NO city field — user
// 8 if you cleared it. Is that desired? What's the precise fix?
// Bug 3: db.users.find({ $or: { city: 'Karachi' }, { is_active: true } })
// — $or needs an ARRAY of objects. Fix the shape.
```

## 🧩 Combine Concepts

The shop filter, full form: products matching **(price 500–3000) AND (category in [1,5]) AND (stock > 0) AND NOT tag 'toys'**... tags are arrays — `$nin` on arrays works how? Predict, test, and write the one-sentence rule for negation on array fields (matches docs where NO element equals the value).

## 🔁 Previous Knowledge

1. The delete ritual's three steps?
2. Soft delete shape — and its cost on reads?
3. What does an operator-less update do?
4. matchedCount vs modifiedCount?

## 🧠 Recall

1. Name all eight comparison operators.
2. Implicit AND vs explicit $and — when is explicit required?
3. The `$ne`/missing-field quirk — one sentence + the fix's name ($exists — tomorrow).
4. What does `find({ field: null })` match (two things!)?

## 🎤 Interview Questions

1. "How do you express a range query in MongoDB?" *( $gte/$lte stacked on one field.)*
2. "How does MongoDB's null matching surprise people?" *(Matches null AND missing.)*
3. "When do you need explicit $and?" *(Same field, multiple operator objects.)*

## ✅ Completion Checklist

- [ ] Understand all comparison + logical operators, null/missing quirks
- [ ] Completed P1–P8 (P5 predicted first!)
- [ ] Fixed all three bugs
- [ ] Completed the shop-filter combine task
- [ ] Answered recall without notes
