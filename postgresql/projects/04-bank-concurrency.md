# 🏗️ P4 — Bank Transfer, Concurrency Edition

**Milestone:** PG Stage 5 (after Day 20) · **Time:** ~90 min · **Two psql sessions required**

## Objective

Rebuild the SQL-track bank with concurrency-proofed transfers — and *reproduce* every anomaly before fixing it. The deliverable is a written incident log.

## Requirements

1. **Schema** (yours, PG-grade): `accounts` (identity, NUMERIC(12,2) balance, CHECK >= 0), `transfers` (identity, from/to FKs, amount CHECK > 0, created_at TIMESTAMPTZ, CHECK from <> to). Seed 5 accounts.

## The Experiment Log — run each, capture the evidence

2. **Naive lost update, reproduced:** S1 and S2 both `BEGIN; SELECT balance...` then both write `balance - 700` (balance starts 1000). Predict the final balance; verify. This is the Day 19 P4 reproduction — evidence this time.
3. **Fix 1 — atomic arithmetic:** `UPDATE accounts SET balance = balance - 700 WHERE id = 1 AND balance >= 700;` — both sessions run it. Explain (in the log) why `RETURNING` tells the loser they lost, and why no isolation level change was needed.
4. **Fix 2 — FOR UPDATE with ordering:** `SELECT * FROM accounts WHERE id IN (1,2) ORDER BY id FOR UPDATE;` then transfer. Reproduce a *deadlock* when sessions skip the ordering; then prove the ordering prevents it.
5. **Fix 3 — SERIALIZABLE + retry:** both sessions `BEGIN ISOLATION LEVEL SERIALIZABLE;` with a multi-statement transfer. One gets the serialization error — write the retry loop (pseudo-code in the log is fine; a DO-loop bonus).
6. **The incident runbook, applied:** while S1 holds a FOR UPDATE lock, run the Day 20 diagnostic (pg_stat_activity → blocking pids) from a third session; terminate the blocker; note what the victim sees.

## Required Queries

7. Transfer log analytics: per account — total in, total out, net flow (two-join or CTE-with-UNION, from the SQL track — your choice).
8. The invariant check: SUM(balances) equals seed total minus... nothing (transfers conserve!) — write the expected number *first*, verify.
9. "Suspicious accounts": any account whose live balance ≠ seed ± net flow (must be zero rows — until you sabotage one balance by hand and show the check catching it).

## Challenge ⭐

10. **Idempotency, PG-grade:** add `client_ref TEXT UNIQUE` to transfers; run the same transfer twice with the same ref (`ON CONFLICT DO NOTHING`) — prove the second call is a no-op (RETURNING empty).

## Bonus 🔴

11. **The two-counter problem:** transfer logs must be *gapless* for auditors. Implement with a `counters` table (per-year row) + `SELECT ... FOR UPDATE` inside the transfer transaction. Explain why a sequence (Day 5) was forbidden here.

## Self-Review

- Which fix is your default for a payment flow, and why (one paragraph — there IS a defensible favorite)?
- What's the difference between what the DB guarantees (no lost update) and what the *app* must still do (retry, read RETURNING)?
- Which experiment surprised you, and what would you tell the team?

> ✅ [solutions/04-bank-concurrency.md](solutions/04-bank-concurrency.md)
