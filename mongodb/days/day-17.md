# Day 17 — Unique, TTL Indexes & explain() Deep Read

**Track:** MongoDB · **Stage:** 5 — Indexes & Performance · **Difficulty:** 🟡→🔴

## 🎯 Goal

Master the two index superpowers (uniqueness, auto-expiry), and read explain() output like a professional: executionStats over guessing.

## 🧠 Fundamentals

**Unique indexes** — MongoDB's constraint mechanism:

```javascript
db.users.createIndex({ email: 1 }, { unique: true })       // no duplicate emails
db.subs.createIndex({ user_id: 1 }, { unique: true,
    partialFilterExpression: { status: 'active' } })        // partial unique!
```

> Insert violating it → E11000 duplicate key error — the same protection class as a relational UNIQUE. (Building one on existing dirty data fails — clean first, then constrain.)

**TTL indexes** — documents that delete themselves:

```javascript
db.sessions.createIndex({ created_at: 1 }, { expireAfterSeconds: 3600 })
// docs with created_at older than 1h → mongod removes them (a background
// sweep runs ~every 60s — timing is APPROXIMATE!)
```

The pattern: sessions, cache entries, logs, rate-limit windows. Caveats: approximate timing; needs a *BSON date* field; not for billing-critical expiry.

**explain() — the two useful levels:**

```javascript
db.orders.find({ user_id: 1 }).explain()                 // queryPlanner: which index?
db.orders.find({ user_id: 1 }).explain('executionStats') // + RAN it: real numbers
```

**The numbers that matter** (executionStats):

- `totalKeysExamined` — index entries touched (want: ≈ nReturned)
- `totalDocsExamined` — documents fetched (want: ≈ nReturned)
- `nReturned` — results
- `executionTimeMillis` — wall clock

**The health ratio:** `totalDocsExamined / nReturned ≈ 1` is the goal. 100k examined for 3 returned = your index isn't serving.

## 🔍 Why It Matters

Unique indexes are how document databases get *invariants*; TTL keeps them *small* without cron jobs; explain-ratios prove index health — same discipline as EXPLAIN ANALYZE, different syntax.

## 💡 Mental Model

> Unique index = the **one-name-per-mailbox rule**; partial unique = "...only for active mailboxes". TTL index = **milk with an expiry date** — the fridge (mongod) periodically throws out expired milk; don't schedule your life around the exact minute. explain ratios = the **receipt**: "3 items, 3 scanned" is a good checkout; "3 items, 100k scanned" means the clerk emptied the shelves to find them.

## 💻 Examples

```javascript
db.users.createIndex({ email: 1 }, { unique: true })
db.users.insertOne({ email: 'ayesha@example.com' })   // E11000 — live proof

db.sessions.insertMany([{ created_at: new Date() }, { created_at: new Date() }])
db.sessions.createIndex({ created_at: 1 }, { expireAfterSeconds: 3600 })
// (use expireAfterSeconds: 10 to WATCH deletion happen!)

db.orders.find({ user_id: 1 }).explain('executionStats')
// read: totalKeysExamined vs totalDocsExamined vs nReturned
```

## 🛠️ Practice

🟢 **P1.** Unique email index on a scratch users copy; prove the duplicate rejection. Then discuss case-insensitivity: MongoDB has no expression indexes like PG's `lower(email)` — the standard solutions are a stored normalized field (`email_lower`) or a **collation** with strength 2 on the index. Write the honest trade.
🟢 **P2.** TTL watched: sessions with `expireAfterSeconds: 10` — insert, watch them vanish (~a minute of countDocuments checks). Feel the sweep timing.
🟡 **P3.** Partial unique: one active subscription per user (`partialFilterExpression: { status: 'active' }`) — two actives rejected; active→cancelled→active allowed.
🟡 **P4. ⭐ Predict first:** with `{ user_id: 1, ordered_at: -1 }` on orders — the three explain numbers for `find({ user_id: 1 })`? Then run. Now `find({ status: 'pending' })` — what do the ratios look like there?
🟡 **P5.** Ratio audit: for each top-5 query from Day 16's index plan — record the three numbers. Anything docsExamined ≫ nReturned? Fix, re-measure.
🔴 **P6. From memory:** the TTL contract (field type, timing, sweep) + two uses and one anti-use.
🔴 **P7.** The case-sensitivity design: design a signup flow's uniqueness under YOUR chosen solution from P1 — write the insert, the index, and what the login query must now match.

## 🐛 Debugging

```javascript
// Bug 1: createIndex unique fails with "duplicate key" — ON EXISTING DATA.
// Sequence? (find the dupes → decide fix → then index)
// Bug 2: sessions "never expire". Check: is created_at a real Date
// (ISODate) or a string? (TTL needs BSON dates.) Verify and fix.
// Bug 3: explain shows IXSCAN but totalDocsExamined = whole collection.
// Diagnosis? (Index found keys, but a filter on unindexed fields fetched
// every candidate doc — the ratio told you before you felt it.)
```

## 🧩 Combine Concepts

The auth mini-system: `users` (unique normalized email — your P7 choice), `sessions` (TTL 1h), `tokens` (TTL + partial unique on user for active tokens). Write the three createIndex calls + the two E11000 proofs + the expiry demo. A production-shaped auth schema in ~10 lines.

## 🔁 Previous Knowledge

1. ESR rule — from memory.
2. Leftmost-prefix consequence?
3. What's a multikey index?
4. The modeling rule?

## 🧠 Recall

1. Unique index — what it enforces, what error proves it?
2. Partial unique — the "one active X per user" pattern, from memory.
3. TTL contract — field type, timing, sweep, anti-use?
4. The three explain numbers + the health ratio?

## 🎤 Interview Questions

1. "How do you enforce uniqueness in MongoDB?" *(Unique + partial unique indexes.)*
2. "How would you auto-expire sessions?" *(TTL + the timing caveats.)*
3. "What explain() stats tell you an index isn't really helping?"

## ✅ Completion Checklist

- [ ] Understand unique/partial/TTL indexes + explain ratios
- [ ] Completed P1–P7 (P4 predicted first)
- [ ] Fixed all three bugs
- [ ] Built the auth mini-system
- [ ] Answered recall without notes

