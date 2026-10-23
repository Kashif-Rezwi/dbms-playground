# Day 13 — Embedding vs Referencing

**Track:** MongoDB · **Stage:** 4 — Data Modeling · **Difficulty:** Intermediate → Advanced

## Goal

Make the embed/reference decision with a real framework — and feel the failure modes of each choice.

## Fundamentals

**Embed** — related data lives inside the document:

```javascript
{ name: 'Wireless Mouse', price: 2499,
  reviews_cache: { avg: 4.7, count: 3, top: [ { rating: 5, comment: 'Smooth' } ] } }
```

+ One read gets everything · updates are single-document
− Unbounded growth kills it (16MB!) · big arrays = write amplification · pieces can't be queried/updated standalone cheaply

**Reference** — store ids, join at read time:

```javascript
{ user_id: 1, status: 'delivered', items: [ { product_id: 1, quantity: 1 } ] }
```

+ Unbounded-safe · independently queryable · shared data has one home
− Re-reads need $lookup or app-side joins · referential integrity is YOUR job (no FK checks!)

**The decision framework** (Day 12's forces, procedural):

```text
1. Is the data UNBOUNDED?                     → reference (or bucket)
2. Is it read with the parent ~always?        → embed candidate
3. Is it queried/updated STANDALONE often?   → reference candidate
4. Does it change INDEPENDENTLY of parent?   → reference (embed = drift)
5. Small + bounded + read-together won all?  → embed
Tie? Optimize the TOP access pattern.
```

**The missing-FK reality:** MongoDB has **no foreign key enforcement**. Referencing means *your code* guarantees the target exists — or documents point at ghosts.

**The hybrid (the professional default):** embed the *summary*, reference the *detail*:

```javascript
{ name: 'Ayesha', company: { id: 42, name: 'Acme' } }   // denormalized name = a cache
// drift risk lives here — name changes must update both. Say it. Own it.
```

## Why It Matters

Every collection design is this decision, repeated. The hybrid pattern is what real production schemas look like — and the no-FK reality is what bites every SQL-trained developer their first month.

## Mental Model

> Embed = **taping the receipt to the fridge** (instant to see, but you can't tape 4 years of groceries). Reference = **the receipt lives in a filing cabinet** — findable, unbounded, but you must walk to the cabinet (join). The hybrid = **a fridge note with the cabinet's shelf number and the total** — fast reads, with a standing chore: update the note when the cabinet changes (drift).

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Classify with the framework (5-line verdict each): (a) user's shipping address; (b) ALL of a user's orders; (c) a course's 10 lessons; (d) an author's 50,000 articles; (e) a post's first 3 comments + count.

[Beginner] **W2.** On `ecommerce`: fetch 3 orders, then their user names app-side (findOne per order — an N+1, felt). Then add `user_name` (hybrid) to one order copy and feel the read simplify. Write the drift chore that comes with it.

### 🔵 Core

[Intermediate] **C1.** Write-amp demo: `docs` with a 100-element array — `$push` 5 times; `refs` version (100 small docs + parent). Which update pattern moves more data and why?

[Intermediate] **C2.** `[Predict]` you embed the customer's full address in every order. The customer moves. How many documents must update — and the drift bug when the app forgets? Then the twist: for ORDER HISTORY, keeping the old address is *correct* (a snapshot!). Which semantics apply where? (If you did the SQL track: Day 26's history-vs-copy debate, document edition.)

[Intermediate] **C3.** `[From Memory]` the 5-question framework + the hybrid's exact trade.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```javascript
// Bug 1: "product docs keep getting huge and slow" — reviews embedded,
// 3 years in, 8k per product. Diagnose + fix (reference reviews; keep
// top-3 + avg cache; history stays intact).
// Bug 2: referenced users deleted; orders show null names. Three fixes
// (cleanup job; eternal soft-delete; hybrid name snapshot) — pick one for
// order-history and justify.
// Bug 3: team embedded a 500-item array and updates by replacing the
// WHOLE document. Which operator family fixes the write pattern
// (positional $ / array operators), and what still caps this design?
```

[Advanced] **H2.** Extend the access-pattern contract (Day 12): for each top-5 ecommerce read, mark embed/reference/hybrid AND write the drift chore or join cost each choice adds. One page = your modeling manifesto for Project 4.

[Advanced] **H3.** The ghost-document experiment: insert an order with `user_id: 999` — no error! Find it. Write the integrity check (collect used user_ids, diff against real ids). One-line lesson on referential integrity here.

## Interview Questions

1. "When do you embed vs reference in MongoDB?" *(The framework.)*
2. "MongoDB has no foreign keys — how do you keep references valid?"
3. "What is the denormalized-summary hybrid and what does it cost?"

## Completion Checklist

- [ ] Understand embed/reference trade-offs, framework, no-FK reality
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Extended the modeling manifesto
