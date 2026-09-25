# Day 23 — Multi-Document Transactions

**Track:** MongoDB · **Stage:** 7 — Transactions → Production · **Difficulty:** 🔴

## 🎯 Goal

Understand MongoDB's transactional story — much newer and more conditional than SQL databases' — and run real multi-document transactions.

## 🧠 Fundamentals

**The history that matters:** single-document operations have ALWAYS been atomic (an update with multiple operators is all-or-nothing — you've relied on this all along!). **Multi-document transactions arrived in 4.0** — and require a **replica set** (even locally: a single-node replica set).

**Setup (local dev):**

```bash
mongosh --eval "rs.initiate()"   # converts the single node into a 1-node replica set
```

**The transaction pattern:**

```javascript
const session = db.getMongo().startSession()
session.startTransaction()

try {
  const tdb = session.getDatabase('bank')       // ALL ops through the session!
  tdb.accounts.updateOne({ _id: 1 }, { $inc: { balance: -500 } })
  tdb.accounts.updateOne({ _id: 2 }, { $inc: { balance: 500 } })
  session.commitTransaction()
} catch (e) {
  session.abortTransaction()
  print('rolled back:', e)
} finally {
  session.endSession()
}
```

**The three rules that bite everyone:**

1. **Every operation must go through the session object** — a stray `db.` call isn't in the transaction.
2. **Transactions have a time limit (default 60s)** — they're for *short, critical* multi-doc invariants.
3. **Touched docs are locked** — long transactions stall others (same lesson as PG Day 20).

**The design truth:** **embedding avoids transactions.** Money moved inside ONE document needs none. Transactions exist for invariants modeling can't co-locate — transfers, order+inventory across documents.

## 🔍 Why It Matters

"MongoDB doesn't have transactions" is *outdated interview folklore* — and "MongoDB has transactions so model like SQL" is *the opposite mistake*. The senior answer: single-doc atomicity by design first, transactions where invariants genuinely span documents.

## 💡 Mental Model

> Single-document atomicity = **one card is updated all-at-once, always**. A transaction = a **briefcase with a special lock**: multiple cards go in; the lock opens once for all (commit) or never (abort). Briefcases are SHORT (the 60s limit) and rare.

## 💻 Examples

```javascript
// feel single-doc atomicity FIRST — no transaction needed:
db.stats.updateOne({ _id: 1 }, { $inc: { count: 1 }, $set: { last_at: new Date() } })
// both operators or neither — one document, one atomic step.
```

## 🛠️ Practice

🟢 **P1.** Single-doc atomicity observed: an update with $inc AND $set — why no transaction needed? Then name one case where two ops on the same doc still want a transaction (two sequential updates — reads see the middle state!).
🟢 **P2.** `rs.initiate()` setup; `rs.status()` — one member, PRIMARY. (Try a transaction BEFORE initiating and read the error first!)
🟢 **P3.** Run the transfer transaction (pattern above) on a scratch `bank` DB — balances move together.
🟡 **P4.** The abort demo: debit, then `throw new Error('boom')` — catch, abort, verify BOTH balances unchanged.
🟡 **P5. ⭐ Predict first:** a stray `db.accounts.updateOne(...)` (NOT through `session`) during an open transaction — inside or outside? Verify: the change appears immediately even after abort. Write the lesson.
🟡 **P6.** Two mongosh tabs: S1's open transaction debited account 1; S2 tries updating account 1 — blocked? Verify; abort S1; watch S2 complete.
🔴 **P7.** The retry-shaped truth: transactions fail with TransientTransactionError and must be RETRIED. Write the 3-attempt retry wrapper around the transfer (PG Day 19's discipline, different database).
🔴 **P8.** The design memo: for (a) counter increment, (b) transfer between accounts, (c) order + inventory decrement, (d) status + history append — transaction or design-around? One line each, single-doc option first when it exists.

## 🐛 Debugging

```javascript
// Bug 1: "Illegal operation... session" — an operation in the
// transaction didn't go through the session. One-line fix.
// Bug 2: "TransactionExceededLifetimeLimitSeconds" — ran past 60s.
// Why the limit exists, and the correct redesign?
// Bug 3: weird errors right after rs.initiate() — the session predates
// the replica set. Fix: reconnect / new session. Checklist step: after
// rs.initiate(), RECONNECT.
```

## 🧩 Combine Concepts

The modeling ↔ transactions bridge, as your track synthesis: take Day 15's e-commerce design; list which operations need transactions (order + stock across collections) vs which embedding already made atomic (items inside the order). Two paragraphs, concrete operations — the document-model payoff speech.

## 🔁 Previous Knowledge

1. $lookup's four fields + the array rule?
2. $unwind's two behaviors?
3. WHERE vs HAVING, pipeline terms?
4. Day 13's no-FK reality — what does today add for multi-doc invariants?

## 🧠 Recall

1. What has ALWAYS been atomic in MongoDB — before transactions existed?
2. What setup does a multi-doc transaction require (even locally)?
3. The three rules that bite everyone?
4. The senior order of consideration: transaction vs design-around?

## 🎤 Interview Questions

1. "Does MongoDB support transactions?" *(Yes — multi-doc since 4.0, replica set required; single-doc always atomic; use sparingly.)*
2. "How would you make a bank transfer safe in MongoDB?" *(Session transaction — or single-doc pair modeling; discuss both.)*
3. "When do you NOT need a transaction in MongoDB?" *(Single-document updates — embedded design pays off.)*

## ✅ Completion Checklist

- [ ] Understand single-doc atomicity, session transactions, limits, retries
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Wrote the modeling↔transactions synthesis
- [ ] Answered recall without notes

