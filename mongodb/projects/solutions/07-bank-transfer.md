# ✅ Solutions — P7: Bank Transfer (Mongo)

## The design answer (write yours before comparing)

- **Model A** (one doc per account): balances live in separate documents → ANY transfer between different accounts is a multi-doc invariant → **transaction required**. This is the honest model for a real bank (transfers span customers).
- **Model B** (one doc per user, `balances: { checking, savings }`): internal transfers = ONE document = **single-doc atomic** — no transaction, ever. Legitimate for intra-user moves; *it cannot express customer-to-customer transfers* — that's when A is forced.

## The core code

```javascript
// seed
db.accounts.insertMany([
  { _id: 1, holder: 'Ayesha', balance: NumberDecimal('1000') },
  { _id: 2, holder: 'Bilal',  balance: NumberDecimal('500') },
  { _id: 3, holder: 'Chen',   balance: NumberDecimal('300') }])
db.accounts_pair.insertOne({ _id: 1, holder: 'Ayesha',
  balances: { checking: NumberDecimal('1000'), savings: NumberDecimal('2000') } })

// safeTransfer — retries + session ops + log row
function safeTransfer(db, fromId, toId, amount) {
  const session = db.getMongo().startSession()
  for (let attempt = 1; attempt <= 3; attempt++) {
    session.startTransaction()
    try {
      const tdb = session.getDatabase(db.getName())
      const from = tdb.accounts.findOne({ _id: fromId })
      if (!from || Number(from.balance) < amount) throw new Error('insufficient funds')
      tdb.accounts.updateOne({ _id: fromId }, { $inc: { balance: -amount } })
      tdb.accounts.updateOne({ _id: toId },   { $inc: { balance: amount } })
      tdb.transfers.insertOne({ from: fromId, to: toId, amount, at: new Date() })
      session.commitTransaction(); session.endSession(); return true
    } catch (e) {
      session.abortTransaction()
      if (attempt === 3) { session.endSession(); throw e }
      print('retry', attempt, e.message)
    }
  }
}

// the filter-carried guard (the stronger single-op version):
const r = db.accounts.updateOne(
  { _id: 3, balance: { $gte: NumberDecimal('500') } },   // guard IN the filter
  { $inc: { balance: -500 } })
// r.modifiedCount === 0 → guard blocked — race-free by construction
```

## Failure theater — expected evidence

- **Abort mid-transfer:** balances unchanged AND no transfers row (the whole briefcase rolled back)
- **Ghost account (to: 999):** FK? There is none — MongoDB happily debits... unless you *add the guard*: check `modifiedCount` of the credit update (0 = missing target) → throw → abort. **That's the no-FK reality: guards are app/logic-side.** (Or a $lookup-free existence check first.)
- **Stray call:** a `db.transfers.insertOne(...)` outside the session → appears immediately, SURVIVES the abort. Lesson: every op through `session.getDatabase` — the template's fragility is discipline.

## Schema B — the single-doc transfer

```javascript
db.accounts_pair.updateOne({ _id: 1 },
  { $inc: { 'balances.checking': -300, 'balances.savings': 300 } })
// ONE document, ONE atomic update — no transaction exists or is needed.
// This is the embed-payoff at its purest: the invariant is INTRA-document.
```

## The flow report + conservation (predicted first)

```javascript
db.transfers.aggregate([
  { $group: { _id: '$from', out: { $sum: '$amount' } } },
  { $project: { _id: 0, account: '$_id', out: 1 } } ])
// conservation: SUM(accounts.balance) = 1000+500+300 = 1800 — ALWAYS
// (transfers conserve; only a sabotage breaks it, and the check catches it)
```

## Bonus 9 — write concern

`{ w: 'majority' }` on transfer commits = the money movement survives the primary's death (PG-sync-commit analog). `w: 1` defensible for: non-critical logs/notifications, or bulk analytics loads — anything where a lost write's blast radius is a shrug. Money moves get majority.

## Self-review (reference answers)

- A for customer-to-customer (the real bank case); B for intra-user — most banks need BOTH.
- The stray-call demo: the template works only via discipline — code review guards "every op via session".
- Which paradigm made the invariant cheapest? For intra-user moves: MongoDB (one doc). For cross-customer ledgers with rich constraints: the relational track's FK+constraint machinery. The honest answer names both — that's the whole capstone's thesis in one question.
