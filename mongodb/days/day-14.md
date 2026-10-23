# Day 14 — One-to-One & One-to-Many

**Track:** MongoDB · **Stage:** 4 — Data Modeling · **Difficulty:** Intermediate

## Goal

Translate the classic relationship shapes into document terms — with the unbounded-growth question deciding everything.

## Fundamentals

**One-to-One** (a user has one profile) — almost always **embed**:

```javascript
{ name: 'Ayesha', profile: { bio: '...', avatar: 'a.png', theme: 'dark' } }
```

When to split into two collections anyway: the object is *huge* (a 5MB blob dragging on every user read), accessed *separately* (profile page without user data? no...), or *security-partitioned* (SSN in its own locked collection). Otherwise: one doc.

**One-to-Many** — three tiers by the "many" side's size:

```text
FEW (≤ ~100, bounded):   EMBED the many in the one
{ blog post, comments: [ up to a few hundred ] }

MANY (hundreds–thousands): REFERENCE the one in the many (child holds parent_id)
{ order: { user_id: 1, items: [...] } }        // each order knows its user

ZILLIONS (millions):     REFERENCE + parent keeps a subset... or bucket the children
{ user_id in each doc } + indexes; bucket: split messages by 1000-per-doc archive pages
```

**The direction of the reference matters:**

- Child points to parent (`order.user_id`) — scales: one field per child, indexed lookup
- Parent lists children (`user.order_ids: [...]`) — fine for FEW; catastrophic for MANY (the unbounded array!)

**The bucket pattern** (MongoDB's classic answer to unbounded one-to-many): store messages in *page documents* of ~500-1000 each, `{ conversation_id, page: 3, messages: [...] }` — bounded arrays, sequential reads, no million-doc scans.

## Why It Matters

One-to-many is the most common shape in any data model. The embed/reference answer is *size-tiered* here — and the bucket pattern is a genuine interview differentiator.

## Mental Model

> 1:1 = **the card and its photo taped to it** (one doc; peel apart only for huge photos or security). 1:few = **the picnic basket** (everything for the trip, one carry). 1:many = **the delivery fleet** (each package knows its warehouse — not the warehouse listing a million packages!). 1:zillions = **the library's bound volumes** (500 sheets per book — the bucket pattern: never a shelf-mile of loose pages).

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Classify + shape (write the document sketch): (a) user → shipping address; (b) blog post → comments; (c) manufacturer → millions of cars; (d) course → 12 lessons; (e) conversation → years of messages.

[Beginner] **W2.** On `saas`: tasks reference projects (`project_id`) — the child-holds-parent pattern. Query "project 4's tasks" — then add the index that makes it instant (Day 16 preview: `db.tasks.createIndex({ project_id: 1 })`).

### 🔵 Core

[Intermediate] **C1.** `[Predict]` the shared dataset models orders→items how? (Check `ecommerce.orders` — *embedded* items!) Why is embedding right there, but user→orders referenced? (Bounded: orders max out at a few items; a user's lifetime orders are unbounded.) Say the boundary in numbers.

[Intermediate] **C2.** `[From Memory]` the three tiers + which side holds the reference in each.

[Intermediate] **C3.** Feel the bad direction: create a `bad_user` doc with `order_ids: [1..12]` — fine now. Write the one-line reason it dies at 10k orders, and which direction scales instead.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```javascript
// Bug 1: user doc keeps a growing order_ids array; the 5000-order user
// makes every profile read heavy. Diagnose (wrong direction for 1:many)
// and fix (orders hold user_id + index).
// Bug 2: post embeds comments; viral posts hit 20k comments; updates
// slow + 16MB looms. Two fixes (reference; hybrid: keep top-3 embedded
// + total count). Sketch both.
// Bug 3: someone "normalized" courses: one lesson per doc, each with
// course_id — reads for a full course do 12 queries. Is this wrong?
// (Not necessarily! When is it RIGHT? — lessons edited independently,
// shared, or huge. The honest answer is pattern-fit, not ideology.)
```

[Advanced] **H2.** The relationship-shape audit of the whole `ecommerce` dataset: list every relationship (user↔orders, order↔items, product↔reviews, category↔products), name the tier (1:1, 1:few, 1:many), and check how the dataset models each — with the one-line "why". This audit becomes Project 4's opening page.

[Advanced] **H3.** Bucket-build: create `messages_bucketed` from the social `messages` data — group by conversation... our messages lack conversation ids — so bucket by *receiver pair*: `{ pair: [min_id, max_id], page: 1, messages: [...] }` for pairs (1,3) etc. Then query pair (1,3)'s messages — one doc read. Write when this beats one-message-per-doc.

## Interview Questions

1. "How do you model one-to-many in MongoDB?" *(Three tiers — bounded embed, child-holds-parent, buckets.)*
2. "When would you embed a 1:1 instead of splitting collections?"
3. "A conversation can reach millions of messages — design it." *(Bucket pattern.)*

## Completion Checklist

- [ ] Understand tiers, reference direction, 1:1 splits, bucket pattern
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Completed the relationship-shape audit
