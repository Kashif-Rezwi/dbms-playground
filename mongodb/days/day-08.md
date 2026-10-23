# Day 08 — Projection, Sort, Limit, Skip

**Track:** MongoDB · **Stage:** 2 — CRUD Mastery · **Difficulty:** Beginner → Intermediate · **Milestone:** Project 2

## Goal

Choose returned fields, sort, paginate — and understand why skipping deep is slow here too (the OFFSET story returns).

## Fundamentals

**Projection** — the second argument of find — 1 = include, 0 = exclude:

```javascript
db.users.find({}, { name: 1, email: 1 })            // ONLY these (+_id by default)
db.users.find({}, { name: 1, email: 1, _id: 0 })    // and hide _id
db.users.find({}, { bio: 0 })                        // everything EXCEPT bio
// rule: don't mix 1s and 0s (except _id)
```

Why it matters: same reason as SQL — send only what the app needs (network, decode, memory).

**Sort** — 1 ascending, -1 descending; multiple keys in order of priority:

```javascript
db.products.find().sort({ price: -1, name: 1 })
```

**Limit & skip** — top-N and paging:

```javascript
db.products.find().sort({ price: -1 }).limit(3)
db.products.find().sort({ price: 1 }).skip(6).limit(3)   // page 3
```

**Chain order is flexible** (the driver reorganizes) — but sort+limit is the "top N" pattern, and **skip costs**: MongoDB walks and discards skipped docs — deep pages get slow, same disease as SQL OFFSET. The cursor-based fix: `find({ _id: { $lt: lastSeenId } }).sort({_id: -1}).limit(10)`.

**One special projection power** — dot notation into nesting:

```javascript
db.orders.find({}, { 'items.product_id': 1, status: 1 })
```

## Why It Matters

Every list page (products, feeds, chats) is projection + sort + limit. And deep-pagination is *the* MongoDB performance question in interviews.

## Mental Model

> Projection is the **photocopy setting**: light/dark per field, not the whole page. Sort+limit+skip is the same **conveyor belt** as SQL: arrange, keep the top, discard the skipped. Deep skip = paying the mailman to walk past a thousand houses before delivering.

## Examples

```javascript
db.products.find({ category_id: 3 }, { name: 1, price: 1, _id: 0 })
db.users.find({}, { name: 1 }).sort({ joined_at: -1 }).limit(3)
db.products.find({}, { name: 1, price: 1 }).sort({ price: -1 }).skip(2).limit(2)

// projection into arrays (keeps array elements, trimmed fields!)
db.orders.find({}, { status: 1, 'items.quantity': 1 })
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Names + emails only, all users (hide _id).

[Beginner] **W2.** Top 3 most expensive products (name + price only).

### 🔵 Core

[Intermediate] **C1.** `[Predict]` `db.users.find({}, { name: 1, city: 0 })` — error or result? What's the mixing rule?

[Intermediate] **C2.** `[From Memory]` top 3 most recent products with name + created_at only.

[Intermediate] **C3.** Page 2 of 3-per-page products by price ascending. Which products are on it?

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```javascript
// Bug 1: db.products.find({}, 'name price') — works? Projection wants an
// OBJECT (some shells accept strings — check yours; write the portable form).
// Bug 2: sort gives "wrong" order — you sorted by a field stored as STRING
// on some docs and NUMBER on others. What does mixed-type sorting do?
// (MongoDB has type-ordering rules — strings sort after numbers. The fix:
// consistent types — a Day 12 discipline!)
// Bug 3: page 999 of a feed takes 4 seconds. Name the disease and the two
// cures (cursor-based pagination; limit/anchor queries).
```

[Advanced] **H2.** Everything so far, one query: **products under 3000, sorted by price ascending then name, showing name+price only, page 2 of 2-per-page** — filter (Day 7) + projection + sort + skip + limit. Then rewrite it cursor-style. Two ways to the same page — you now own both.

[Advanced] **H3.** Deep pagination, the cursor way: fetch "page 1" (3 products by price desc, take note of the last `_id`/price shown), then fetch the next 3 *without skip* using `{ price: { $lt: lastPrice } }` (what breaks with ties? — say the fix: sort by (price, _id) and filter on both. Then implement it!). Compare with skip(3).limit(3) results — same page, zero discarded docs.

## Interview Questions

1. "How do you paginate results in MongoDB?" *(skip/limit + the deep-page problem + cursor pattern.)*
2. "What does projection buy you, and what's the syntax rule?"
3. "Why can sorting surprise you with mixed types?" *(BSON type ordering.)*

## Mini Project — Stage 2 complete!

Build **[P2: Book Catalog](../projects/02-book-catalog.md)** — your own catalog collection with querying, projection, sorting, and pagination drills. Attempt before solutions.

## Completion Checklist

- [ ] Understand projection, sort, limit/skip, cursor pagination
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Started Project 2
