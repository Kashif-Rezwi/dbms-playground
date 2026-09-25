# Day 12 — Schema Design Thinking

**Track:** MongoDB · **Stage:** 4 — Data Modeling · **Difficulty:** 🟡→🔴

## 🎯 Goal

Learn THE MongoDB design rule — model around *access patterns* — and the workflow that applies it.

## 🧠 Fundamentals

**The single most important sentence in this track:**

> **In MongoDB, you model around how the application READS and WRITES data — not around what the data "is".**

Relational design normalizes by default (facts get their own tables; anomalies fear-typed). Document design starts from the *questions the app asks most*:

```text
Q: What does the product page need in ONE read?
A: name, price, stock, images, tags, maybe top-3 reviews
→ then the product DOCUMENT should roughly BE that answer.
```

**The workflow** (use it in every exercise this stage):

```text
1. LIST the access patterns (the app's screens/queries, ranked by frequency)
2. GROUP the data each pattern touches
3. DECIDE: embed (read together, bounded size) or reference (large, shared, unbounded)
4. SHAPE documents so top patterns = 1 read
5. WRITE the trade-offs down (what got harder?)
```

**The vocabulary for step 3** (days 13–14 detail each):

- **Embed** — store related data inside the document (arrays/nested objects)
- **Reference** — store `_id`s and follow them ($lookup / app-side joins)

**The four forces on every decision:**

| Force | Pushes toward |
|---|---|
| Data read together, bounded (address, cart, up to ~hundred items) | **embed** |
| Unbounded growth (all comments ever, infinite history) | **reference** (or bucket) |
| Data shared/updated standalone (a user's profile read alone) | **reference** |
| 16MB document cap + write amplification (big arrays rewrite wholesale) | **reference** |

**Schema-less ≠ thought-less:** your *shape discipline* (Day 11) is the schema. Real teams write a shape contract and enforce validators on it.

## 🔍 Why It Matters

This is the whole point of document modeling. Interviews: "how would you model X in MongoDB?" — the winning answer *always* starts with "what are the access patterns?"

## 💡 Mental Model

> Relational design is a **library catalog** — everything has one canonical place (normalization). Document design is a **picnic basket** — pack what the meal needs (the read pattern), in one basket, arranged for eating. You don't carry the whole pantry (unbounded data), and you don't pack table settings for 40 when you'll be 4.

## 🛠️ Practice — the workflow, applied

🟢 **P1.** List the access patterns of a **blog** (rank by frequency): read post with author + top comments; author page; comment creation; tag browsing. Write them as query-shaped lines.
🟢 **P2.** Apply steps 2–4: which pieces embed with the post, which reference? Defend each in one line (bounded? shared? read-together?).
🟡 **P3.** Do the same for a **chat app** (patterns: open conversation = last 50 messages fast; user's conversation list; send message; unread counts). Where do messages live — embedded? Referenced? At what size do you change your mind? (The **bucket pattern** idea — split old messages to archive docs.)
🟡 **P4. ⭐ Predict-and-justify first:** where do product **reviews** belong — inside the product doc or their own collection? Argue BOTH sides in 2 lines each, then pick with the four forces. (Most teams: own collection — unbounded + queried standalone + avg-rating aggregation lives there... but a `reviews_cache: { avg, top3 }` embedded is the hybrid!)
🔴 **P5.** The anti-pattern clinic — name the disease (each is a real repo pattern you've seen in SQL Day 27, now in Mongo form): (a) one doc = one giant `history` array, never pruned; (b) `type: 'string'` prices sneaking in; (c) the same fact stored in two collections, updated by hope; (d) massive **arrays of references** read with N+1 app-side queries.
🔴 **P6.** From memory: the workflow's 5 steps + the four forces table.

## 🐛 Debugging — Design Review

```javascript
// Schema A: { user doc } + every order the user ever made embedded
// (orders: [ ... 4000 orders ... ]) — three problems (16MB; write amp;
// order detail requires loading the whole user). Sketch the fix.

// Schema B: orders reference products by _id; the app reads orders, then
// 50 products one-by-one in a loop. Two fixes (app-side $in batch;
// pipeline $lookup — Day 22). Which is the default and why?

// Schema C: perfectly normalized — 1:1 collections for everything, all
// reads need 4 $lookups. What design question was never asked?
// (The access patterns!) What would the honest re-design do?
```

## 🧩 Combine Concepts

Take Day 11's shape-audit report and add its second half: the **access-pattern contract** — top 5 reads of the ecommerce dataset as literal query sketches, each annotated "embedded ✓ / needs reference". This document is Project 4's foundation and a genuine portfolio artifact.

## 🔁 Previous Knowledge

1. The $exists/null matrix — from memory.
2. What does $elemMatch guarantee?
3. Positional `$` — refers to?
4. The multikey index serves what?

## 🧠 Recall

1. THE rule — one sentence, from memory.
2. The workflow's five steps.
3. The four forces — which direction does each push?
4. What does "shape contract" mean, and what enforces it?

## 🎤 Interview Questions

1. "How do you approach data modeling in MongoDB?" *(Access patterns first — say the rule.)*
2. "What's the equivalent of normalization in document databases?" *(There isn't one — there's read-shaping + discipline; explain the trade honestly.)*
3. "When would you split one document's data into two collections?" *(Unbounded/shared/write-amp forces.)*

## ✅ Completion Checklist

- [ ] Can state the rule + workflow + forces from memory
- [ ] Completed P1–P6 (P4 argued before deciding)
- [ ] Diagnosed all three design reviews
- [ ] Extended the shape-audit into the access-pattern contract
- [ ] Answered recall without notes
