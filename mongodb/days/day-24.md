# Day 24 — Transactions in Practice → Project 7

**Track:** MongoDB · **Stage:** 7 — Transactions → Production · **Difficulty:** Advanced · **Milestone:** Project 7

## Goal

Make transactions a real safety net: retry wrappers, session-scoped reads, the upsert-in-transaction dance — then the bank project.

## Fundamentals

**The production-grade transaction template** (retries + cleanup + logging):

```javascript
async function safeTransfer(db, fromId, toId, amount) {
  const session = db.getMongo().startSession()
  for (let attempt = 1; attempt <= 3; attempt++) {
    session.startTransaction()
    try {
      const tdb = session.getDatabase(db.getName())

      // guard FIRST — read the balance inside the transaction
      const from = tdb.accounts.findOne({ _id: fromId })
      if (!from || from.balance < amount) throw new Error('insufficient funds')

      tdb.accounts.updateOne({ _id: fromId }, { $inc: { balance: -amount } })
      tdb.accounts.updateOne({ _id: toId },   { $inc: { balance:  amount } })
      tdb.transfers.insertOne({ from: fromId, to: toId, amount, at: new Date() })

      session.commitTransaction()
      session.endSession()
      return true
    } catch (e) {
      session.abortTransaction()
      if (attempt === 3) { session.endSession(); throw e }
      print(`retry ${attempt}: ${e.message}`)   // TransientTransactionError → retry
    }
  }
}
```

**Three production facts:**

1. **Retryable errors are normal** — concurrent writes cause write conflicts; the app retries the whole transaction (if you did the PostgreSQL track: the same pattern Day 19 drilled).
2. **The read-inside-the-transaction guard** (`findOne` first) is part of the invariant — but note the *better* MongoDB habit: put the guard IN the update filter (`updateOne({_id, balance: {$gte: amount}}, ...)`) and check `modifiedCount` — atomic guard + write in one op, no race window.
3. **Unique-in-transaction gotcha:** upserts against collections with unique indexes can throw inside transactions — plan errors as control flow, not surprises.

## Why It Matters

A transaction template without retries is production theater. The atomic-guard pattern (`filter carries the condition`) is the strongest single habit in this track — it eliminates an entire class of race conditions.

## Mental Model

> The template is a **courier with three attempts**: signature required (guard), delivery + pickup in one run (both $incs), the log entry rides along, and a busy doorstep (write conflict) means "come back later", not "give up". The filter-carried guard is the **lock built into the key**: the door only opens if the condition is already true.

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Type and run the safeTransfer template (mongosh) — successful transfer, then insufficient funds (read the abort path).

[Beginner] **W2.** The atomic-guard upgrade: transfer with the guard INSIDE the update filter; verify `modifiedCount` distinguishes success from "guard blocked". One line: why is this race-free where the separate findOne guard wasn't quite?

### 🔵 Core

[Intermediate] **C1.** `[Predict]` the transfers log insert inside the transaction, then abort — is the log row there? (No — the whole briefcase rolled back, log included.) Verify.

[Intermediate] **C2.** `[From Memory]` the five beats of the production template (start session → startTransaction → session-ops → commit → end, with abort+retry in the catch).

[Intermediate] **C3.** Manufacture a retry: two mongosh tabs, both start transactions that update the SAME account; commit both — one gets a write conflict (or blocks). Read the error; feel why retries exist.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```javascript
// Bug 1: safeTransfer "works" but the log shows transfers that never
// happened (balances unchanged). What was outside the transaction?
// Bug 2: retries never trigger — the catch swallows errors and returns
// undefined. What must the retry loop do on the final attempt?
// Bug 3: "insufficient funds" sometimes false-positives under load —
// the guard read a stale balance. Which pattern upgrade fixes it, and
// how does modifiedCount disambiguate?
```

[Advanced] **H2.** Capstone Preview (leading into Project 7):

Build **[P7: Bank Transfer (Mongo)](../projects/07-bank-transfer.md)** — the full bank: schema decisions (account-pair modeling vs transactions — you argue!), the retry-wrapped transfer, failure theater, conservation audit. Attempt before solutions.

[Advanced] **H3.** The full audit pattern: safeTransfer + a post-transaction verification (re-read both balances + assert conservation: SUM unchanged) — money mathematically cannot vanish, proven by code you wrote.

## Interview Questions

1. "How do you handle write conflicts in MongoDB transactions?" *(Retry loop around the whole transaction.)*
2. "How do you prevent an overdraw without a race condition?" *(Condition in the update filter + modifiedCount check.)*
3. "What's the strongest atomicity MongoDB gives you, and how do you design for it?" *(Single-document; embed co-changed data.)*

## Completion Checklist

- [ ] Own the production template (retries, guards, verification)
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Started Project 7
