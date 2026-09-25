# Day 01 — What Is a Document Database? + mongosh

**Track:** MongoDB · **Stage:** 1 — Foundation · **Difficulty:** Beginner
**Prerequisites:** None (fully standalone!)

## Goal

Understand what MongoDB *is* — and what it deliberately *isn't* — by exploring a real database in mongosh.

## Fundamentals

**MongoDB is a document-oriented database.** It stores **documents** — self-contained records that look like JSON (stored as **BSON**, a binary version):

```javascript
{ name: 'Ayesha Khan', email: 'ayesha@example.com',
  city: 'Karachi', is_active: true, joined_at: ISODate('2024-01-15') }
```

Notice what's *inside*: values can be numbers, strings, booleans, dates, **arrays**, and **nested objects**:

```javascript
{ name: 'Wireless Mouse', price: 2499,
  tags: ['wireless', 'mouse'],
  specs: { color: 'black', warranty_months: 12 } }
```

No tables-with-fixed-columns. No "every row has the same shape." **Each document decides its own fields.**

**MongoDB is part of the NoSQL family** — a label meaning "not the relational table model" (document, key-value, graph, column). **NoSQL is a category, not a language.** You talk to MongoDB with its own API (here, JavaScript via mongosh) — not SQL.

**The honest framing:** relational databases organize data around *what it IS* (normalized entities); MongoDB organizes data around *how it's USED* (documents shaped like your app's reads). Both are legitimate — for different problems.

## Why It Matters

Document databases power real products everywhere (event logging, catalogs, CMS, user profiles, fast-changing app schemas). Understanding *when* this model wins is a genuinely different skill from knowing SQL.

## Mental Model

> A relational table is a **grid**: strict, uniform, every cell typed. A MongoDB collection is a **shoebox of index cards**: each card is self-contained, cards can have different fields, and a card can hold a photo taped on (nested object) or a stapled list (array). Flexibility is the design, not an accident.

## Examples

```bash
mongosh ecommerce        # after ./scripts/seed/seed-mongo.sh ecommerce
```

```javascript
show collections
db.users.find().limit(3).pretty()        // documents!
db.products.find({ _id: 7 }).pretty()   // look: tags is an ARRAY
db.orders.findOne({ _id: 4 })           // look: items is an array of OBJECTS
```

## Practice

[Beginner] **P1.** Connect; `show dbs`; `use ecommerce`; `show collections`.
[Beginner] **P2.** Inspect one user, one product, one order (`.pretty()`). For each, write down: which fields are strings, numbers, booleans, dates? Which are arrays/objects?
[Beginner] **P3.** Compare a product document with an order document — *different shapes, same database, no complaint from the DB*. That's the headline.
[Beginner] **P4.** In `use social`: find a post, and note the `likes_count` — a field the `ecommerce` documents don't have. Who decided that field exists? (The insert. Nothing else.)
[Intermediate] **P5. Predict first:** what does `db.products.find({ tags: 'usb' })` return — and *why* does that work on an array? (Predict count too; there are 2 products with 'usb'.)
[Intermediate] **P6.** The 2-minute reflection, written: name one thing a spreadsheet can do that this can't, and one thing this can do that a spreadsheet can't.

## Debugging

```javascript
// Bug 1: db.users.find() printed a wall of unreadable text.
// What's the display fix (two options)?
// Bug 2: "collection products not found in db social" — you're in the WRONG
// DATABASE. What's the check, and the fix command?
// Bug 3: db.user.find() — silent "no results"-ish behavior. What's wrong,
// and what does MongoDB do about nonexistent collections? (auto-created on
// first write — queries on missing collections just return nothing!)
```

## Combine Concepts

First day — instead of combining, build the **compare habit**: look at one order document and describe, in 3 sentences, how this single document captures what a relational database would need *three tables* to represent (order, order_items, and the join). You've just met the whole track's thesis: **embed what you read together**.

## Recall

1. What is a document? Name three types a field can hold (make one exotic — array or nested object).
2. What is BSON in one line?
3. Is NoSQL a language? What is it?
4. What happens when two documents in one collection have different fields?

## Interview Questions

1. "What is a document database, and how does it differ from a relational one?"
2. "What kinds of values can a document field hold?"
3. "When would you reach for MongoDB over PostgreSQL?" *(First-pass answer: flexible/evolving schema, embedded reads, document-shaped data — Days 12–15 deepen this.)*

## Completion Checklist

- [ ] Connected, explored 3+ collections
- [ ] Can name field types on sight, including arrays/objects
- [ ] Completed P1–P6 (P5 predicted first)
- [ ] Diagnosed all three bugs
- [ ] Answered recall without notes
