# Day 04 — find & findOne

**Track:** MongoDB · **Stage:** 1 · **Difficulty:** 🟢 Beginner

## 🎯 Goal

Read documents: exact-match queries, multi-field queries, and querying into arrays and nested fields — MongoDB's home turf.

## 🧠 Fundamentals

**findOne** returns a document; **find** returns a cursor (usually auto-printed, first 20):

```javascript
db.users.findOne({ email: 'ayesha@example.com' })
db.users.find({ city: 'Karachi' })
db.users.find({ city: 'Karachi', is_active: true })   // multiple fields = AND
```

**Equality is just the beginning — three query shapes to own today:**

```javascript
// 1. into arrays: array field "contains" this value
db.products.find({ tags: 'usb' })

// 2. into nested objects: DOT NOTATION
db.users.find({ 'address.city': 'Karachi' })

// 3. into arrays of objects: still dot notation, match inside elements
db.jobs.find({ 'skills.skill': 'SQL' })
```

**Reading the result:** `find()` without arguments returns everything; in mongosh the cursor prints the first batch — `.limit()`, `.count()`... you'll also see `.toArray()`. **countDocuments(query)** is the count habit (`.count()` is deprecated).

**The matching rule for arrays** (met yesterday, now official): a query matches a document if *any element* of the array matches. That single rule powers most array querying — Day 9 builds operators on top of it.

## 🔍 Why It Matters

find is the R of CRUD and 80% of daily MongoDB work. The three query shapes above are what makes MongoDB feel native for nested data — SQL needs joins for the same reads.

## 💡 Mental Model

> `find` is a **filter funnel**: pour all documents in, a query keeps those whose fields pass the tests. Dot notation is a **laser pointer**: shine through `address.` and hit `city` inside the nested box. Array matching is the **bouncer scanning a list**: if *any one* name on your guest list matches, you're in.

## 💻 Examples

```javascript
use ecommerce

db.users.find({ city: 'Karachi' }).pretty()
db.users.find({ city: 'Karachi', is_active: true })

db.products.find({ tags: 'book' })               // array contains 'book'
db.products.find({ 'category_id': 3 })           // plain field

use jobs
db.jobs.find({ 'skills.skill': 'SQL' })          // array-of-objects
db.jobs.find({ is_remote: true, 'skills.skill': 'Docker' })
```

## 🛠️ Practice

🟢 **P1.** All users from Karachi. Then active users from Karachi (one query).
🟢 **P2.** All products with the 'skincare' tag. Predict the count first (2).
🟢 **P3.** `use jobs` — all jobs where a required skill is 'PostgreSQL'. Then remote jobs with 'System Design' anywhere in skills.
🟢 **P4.** In `social`: posts by user_id 10; then posts with likes_count of 0.
🟡 **P5. ⭐ Predict first:** exact output count of

```javascript
db.products.find({ category_id: 1, stock: 0 })
```

🟡 **P6.** From `ecommerce.orders`: orders with status 'delivered' AND any item having quantity 2 — using dot notation (`'items.quantity': 2`). Predict which orders (4? 6? 7? 12?) before running.
🟡 **P7. From memory:** array-contains query for products with tag 'wireless'; then the count.
🔴 **P8.** The shape-comparison drill: write the MongoDB query for "jobs requiring SQL that are remote" — then, in one sentence, describe what a relational database would need for the same answer (a join table or LIKE-in-CVS — you've *seen* both; say which and why it's clunkier).

## 🐛 Debugging

```javascript
// Bug 1: db.users.find({ 'karachi' }) — returns EVERYTHING. Why?
// (A string, not an object — find() with a truthy non-query... actually:
// what does find("karachi") really do? Run it; then fix: { city: 'Karachi' })
// Bug 2: db.users.find({ address.city: 'x' }) — syntax error. What's missing
// around 'address.city'? Why does the dot form need quotes?
// Bug 3: findOne returns a document but find "returns nothing" — check
// whether you're printing a CURSOR. What converts it (toArray/pretty/loop)?
```

## 🧩 Combine Concepts

Insert + find (the loop closes): insert a product with tags `['practice','new']` into a scratch collection, verify by tag-query AND by a dot-notation query into a nested `specs` object you design. You've now *designed a shape and read it back* — the full micro-cycle.

## 🔁 Previous Knowledge

1. insertMany + `{ordered:false}` — what does the flag change?
2. What do validators enforce (and not)?
3. What's the array-matching rule (any element)?
4. ObjectId's free benefit?

## 🧠 Recall

1. find vs findOne — return types?
2. How do you query a nested field? An array field? An array-of-objects field?
3. Multiple fields in one query = which logical connector?
4. What's the counting method you should reach for?

## 🎤 Interview Questions

1. "How do you query fields inside nested documents or arrays in MongoDB?"
2. "What does find() return — a document or something else?" *(A cursor.)*
3. "How does MongoDB match array fields?" *(Document matches if any element matches.)*

## ✅ Completion Checklist

- [ ] Understand find/findOne, dot notation, array matching
- [ ] Completed P1–P8 (P5 and P6 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the shape-design combine task
- [ ] Answered recall without notes
