# Day 07 — Comparison & Logical Operators

**Track:** MongoDB · **Stage:** 2 — CRUD Mastery · **Difficulty:** Beginner → Intermediate

## Goal

Filter beyond equality: ranges, membership, and AND/OR logic — MongoDB's WHERE-clause equivalents.

## Fundamentals

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

## Why It Matters

Ranges, multi-city filters, price brackets — every product filter UI is these operators. And the null/missing quirk is MongoDB's #1 silent bug.

## Mental Model

> Comparison operators are the **same stencils as SQL** ($gte = ≥, $in = the guest list). $or is a **union of guest lists**; implicit AND is "the AND you get for free"; explicit $and is the **AND you must spell out** when one field wears two conditions at once.

## Examples

```javascript
use ecommerce

db.products.find({ price: { $gte: 2000, $lte: 6000 } })
db.users.find({ city: { $in: ['Karachi', 'Lahore', 'Multan'] } })
db.products.find({ $or: [ { category_id: 1 }, { stock: 0 } ] })
db.orders.find({ status: { $in: ['pending', 'shipped'] }, total_amount: { $gt: 5000 } })

use jobs
db.jobs.find({ salary_max: { $gte: 100000 }, is_remote: true })
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Products priced 1000–2500 (inclusive). Predict the count first.

[Beginner] **W2.** Users NOT from Karachi (either $ne or $nin — try both; do the results differ? Why?).

### 🔵 Core

[Intermediate] **C1.** `[Predict]` ```javascript
db.users.find({ bio: { $ne: 'hello' } })
```

How many users match — and *which user surprises you*? (One user has no bio field at all. What happened?) This is the missing-field quirk, live.

[Intermediate] **C2.** `[From Memory]` price between 500 and 1500 AND (category 3 OR tag 'book') — one query, mixing implicit AND, range, and $or.

[Intermediate] **C3.** Products in category 2 OR with stock 0.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```javascript
// Bug 1: db.products.find({ price: $gt: 100 }) — syntax error. Operators
// live inside a nested object: the fix in one line.
// Bug 2: "city != Karachi" returns users who have NO city field — user
// 8 if you cleared it. Is that desired? What's the precise fix?
// Bug 3: db.users.find({ $or: { city: 'Karachi' }, { is_active: true } })
// — $or needs an ARRAY of objects. Fix the shape.
```

[Advanced] **H2.** The shop filter, full form: products matching **(price 500–3000) AND (category in [1,5]) AND (stock > 0) AND NOT tag 'toys'**... tags are arrays — `$nin` on arrays works how? Predict, test, and write the one-sentence rule for negation on array fields (matches docs where NO element equals the value).

[Advanced] **H3.** The $and necessity drill: find products with price > 1000 AND price < 3000 — write it with implicit syntax `{ price: { $gt: 1000, $lt: 3000 } }` (works! operators stack) vs explicit $and. When does implicit FAIL and $and become required? (Duplicate keys in a JS object: `{ price: {...}, price: {...} }` — impossible — say why that forces $and.)

## Interview Questions

1. "How do you express a range query in MongoDB?" *( $gte/$lte stacked on one field.)*
2. "How does MongoDB's null matching surprise people?" *(Matches null AND missing.)*
3. "When do you need explicit $and?" *(Same field, multiple operator objects.)*

## Completion Checklist

- [ ] Understand all comparison + logical operators, null/missing quirks
- [ ] Completed Warm Up, Core, and Challenge exercises
