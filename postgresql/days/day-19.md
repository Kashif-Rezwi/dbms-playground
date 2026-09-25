# Day 19 — Isolation Levels & Anomalies (Live Experiments)

**Track:** PostgreSQL · **Stage:** 5 — Transactions & Concurrency · **Difficulty:** 🔴

## 🎯 Goal

*Reproduce* every isolation anomaly with your own two sessions — then never be confused by them again.

## 🧠 Fundamentals

Isolation levels answer: **how much of other transactions' work do I see mid-transaction?** PostgreSQL's four levels (SQL standard names):

**READ COMMITTED (default)** — each statement gets a fresh snapshot:
- **Non-repeatable read**: same row read twice → different values
- **Phantom read**: same query twice → new rows appear
- ✅ No dirty reads — ever, in any level (MVCC)

**REPEATABLE READ** — one snapshot per transaction (from first statement):
- Kills non-repeatable + phantom reads... in PostgreSQL, in practice also serialization anomalies are prevented? Honest version: PostgreSQL's RR is *snapshot isolation* — it kills NR and phantoms, leaving **write skew** possible
- ✅ But you can get `ERROR: could not serialize access due to concurrent update` when your UPDATE hits a row someone else changed — then you RETRY the transaction

**SERIALIZABLE** — behaves as if transactions ran one-at-a-time; anomalies → **retryable errors**. Cost: more restarts; use when correctness beats throughput (money math, scheduling).

The **anomaly table** you'll build today:

| Anomaly | READ COMMITTED | REPEATABLE READ | SERIALIZABLE |
|---|---|---|---|
| Dirty read | never (MVCC) | never | never |
| Non-repeatable read | ✅ reproduced | blocked | blocked |
| Phantom read | ✅ reproduced | blocked | blocked |
| Lost update / write skew | ✅ reproduced | partially | blocked (retries) |

## 🔍 Why It Matters

"Two requests sold the same seat" and "two admins changed the balance" are *isolation bugs* — invisible in single-user testing, guaranteed in production. You'll reproduce them today, which means you'll *recognize* them forever.

## 💡 Mental Model

> Isolation level = **how often the room takes new photos**: after every sentence (RC), once per visit (RR), or the doorman only lets one visitor in at a time and re-shoots if someone bumped the furniture (S). Retryable errors = the doorman saying "too many people bumped things; please start your visit again."

## 🛠️ Practice (two sessions each!)

🟢 **P1. Non-repeatable read:** S1: `BEGIN; SELECT balance FROM accounts WHERE id=1;` — S2: `UPDATE accounts SET balance = balance + 100 WHERE id=1; COMMIT;` — S1 re-selects: **different value** → commit. Reproduced. ✅
🟢 **P2. Phantom read:** S1: `BEGIN; SELECT count(*) FROM accounts WHERE balance > 0;` — S2 inserts a positive-balance row, commits — S1 re-counts: **grew**. Reproduced. ✅
🟡 **P3. REPEATABLE READ kills both:** redo P1 and P2 with S1 in `BEGIN ISOLATION LEVEL REPEATABLE READ;` — S1 sees the *old* world consistently. Then: S1 tries `UPDATE accounts SET balance = balance - 50 WHERE id = 1;` (the row S2 changed) — read the error; what must S1's code do? (Retry loop!)
🟡 **P4. ⭐ Predict first:** RC level, classic **lost update**: two sessions both read balance=1000, both compute +500, both write 1500 (one deposit vanishes). Sequence it exactly, verify 1500 (not 2000). Then repeat with SERIALIZABLE — which session retries?
🟡 **P5. The real fixes, ranked:** for the lost-update problem, three solutions: (a) `SELECT ... FOR UPDATE` (S1 locks first, S2 waits), (b) `UPDATE ... SET balance = balance + 500` (atomic read-modify-write — often enough!), (c) SERIALIZABLE + retry. Write one line per solution on when it's best.
🔴 **P6. Write skew (the subtle one):** on-call rule "at least one doctor must be on call" — S1 and S2 both check (count=2), both set their own on_call=false, both commit. Reproduce at RR level. Why didn't RR stop it? What level would (S), and what would the app need? (Retry loop.)
🔴 **P7. From memory:** the anomaly table — fill it blank, then verify.
🔴 **P8. Choose a level, defend it:** for (a) analytics dashboards (b) bank transfers (c) seat-booking (d) "increment view count" — pick a level + fix and write one line each.

## 🐛 Debugging

```sql
-- Bug 1: "ERROR: could not serialize access due to concurrent update"
-- appearing rarely in logs. What is it, is it a bug, and what must the
-- application do?
-- Bug 2: RC-level transaction computes: read balance, check >= 1000,
-- then withdraw 900 — two sessions pass the check simultaneously.
-- Name the anomaly and pick TWO fixes.
-- Bug 3: someone "upgraded to SERIALIZABLE for safety" and throughput
-- collapsed with retry storms. What was wrong, and when is SERIALIZABLE
-- genuinely the right call?
```

## 🧩 Combine Concepts

Tie to Project 4 (tomorrow): your bank transfer procedure (Day 10) currently assumes no concurrency. Write the three upgrades it needs — atomic balance arithmetic, `FOR UPDATE` on the debit row, SERIALIZABLE-with-retry for the audit-critical path — and note which anomalies each upgrade kills.

## 🔁 Previous Knowledge

1. MVCC two-liner.
2. What does a snapshot fix in RR?
3. What are xmin/xmax?
4. What does SELECT FOR UPDATE do to plain readers? (Nothing — MVCC!)

## 🧠 Recall

1. The four anomalies + which levels block which.
2. What does "retryable error" mean and whose job is the retry?
3. Why does `UPDATE ... SET x = x + n` fix most lost updates without isolation changes?
4. Default level of PostgreSQL? When would you move up?

## 🎤 Interview Questions

1. "Explain isolation levels and the anomalies they prevent." *(You have a reproduced-experiment story. Use it.)*
2. "How do you prevent a lost update?" *(Atomic arithmetic, FOR UPDATE, or SERIALIZABLE + retry.)*
3. "What isolation level does PostgreSQL default to, and why is that usually fine?"

## ✅ Completion Checklist

- [ ] Reproduced NR, phantom, lost update (two sessions)
- [ ] Understood RR's error-and-retry, write skew, SERIALIZABLE
- [ ] Completed P1–P8 (P4 predicted first)
- [ ] Fixed all three bugs
- [ ] Wrote the transfer-upgrade plan
- [ ] Answered recall without notes
