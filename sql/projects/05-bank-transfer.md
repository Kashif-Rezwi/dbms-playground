# 🏗️ Project 5 — Bank Transfer Simulation

**Milestone:** SQL Stage 5 (after Day 21) · **Time:** ~60–90 min · **Dataset:** your own

## Objective

Build a safe money-transfer system: accounts, a transfer operation, failure scenarios — and prove atomicity with experiments.

## Scenario

A payments team needs the transfer feature: move money between accounts. The one rule that cannot break: **money is never created or destroyed**.

## Requirements — Design

- `accounts`: id, holder name, balance (with a CHECK: balance >= 0 — an account can be empty, never negative)
- `transfers`: id, from_account, to_account, amount (CHECK > 0), created_at — the transfer **log**

**Design questions:** Why keep a transfers log instead of just updating balances? (Two reasons: audit/history + debugging. Say them.)

Insert 5 accounts with realistic balances.

## Required Operations

Write each as an explicit transaction:

1. A successful transfer of 500 from account 1 to 2 — both balances change + a transfers row exists
2. A transfer that **overdrafts** account 3 (its balance is 200; transfer 1000) — the CHECK fires; **prove nothing changed** (balances AND no transfers row)
3. A transfer to a **nonexistent account** (id 999) — FK fires; prove nothing changed
4. A transfer that **crashes mid-way** (simulate: BEGIN, debit successfully, then type an error or Ctrl-C... use an INSERT with a bad value as the "crash" — then ROLLBACK and verify both balances are untouched)

## Required Queries

5. Final balances, sorted by holder name, with each account's **net transfer flow** (total in − total out, from the transfers log — two joins or a CTE with UNION)
6. Every account that received a transfer today
7. The busiest account (most transfers in or out — any single query you like; explain it)
8. Verify the invariant: `SUM(balance)` equals the original total you seeded — after all your successful transfers (write the number you expect *before* running)

## Constraints

- Every transaction verified with SELECTs *after* commit/rollback
- The overdraft attempt must show the whole-transaction abort (not a partial debit)

## Performance Requirement

None — but predict: which table grows fastest over years, and which query (5) gets slowest first? Why? (Answer in the memo.)

## Challenge Tasks ⭐

9. **Idempotency**: run the same transfer twice "by accident" — what happens to money? Design a way to prevent double-execution (a unique key? a status column? argue your choice)
10. **Concurrent transfer preview**: open two psql tabs; in tab 1 BEGIN and debit account 1 (don't commit); in tab 2 try to debit the same account — what happens? (Don't force it — observe, ROLLBACK, and note it as a PG-track teaser)

## Bonus Challenge 🔴

11. Write the transfer as ONE statement: `UPDATE accounts SET balance = balance - X WHERE id = A` ... no — the real challenge: a single UPDATE affecting both accounts using a CASE. Then discuss: is this *more* atomic, or just fewer keystrokes?

## Expected Outcome

A transfer system where money mathematically cannot vanish — with the experiment logs to prove it.

## Self-Review Questions

- Explain to a friend why two UPDATEs without a transaction are dangerous (the crash-window story).
- What's the difference between the CHECK firing (query 2) and the FK firing (query 3)? Which ACID letter is on display in each?
- Why does the transfers log exist? What business question does it answer that balances can't?

> ✅ Done? [solutions/05-bank-transfer.md](solutions/05-bank-transfer.md)
