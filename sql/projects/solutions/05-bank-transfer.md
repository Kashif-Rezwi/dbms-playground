# ✅ Solutions — Project 5: Bank Transfer Simulation

## Reference schema

```sql
CREATE TABLE accounts (
    id INT PRIMARY KEY,
    holder TEXT NOT NULL,
    balance NUMERIC(12,2) NOT NULL CHECK (balance >= 0)
);

CREATE TABLE transfers (
    id INT PRIMARY KEY,
    from_account INT NOT NULL REFERENCES accounts(id),
    to_account   INT NOT NULL REFERENCES accounts(id),
    amount       NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    created_at   DATE NOT NULL DEFAULT CURRENT_DATE,
    CHECK (from_account <> to_account)
);

INSERT INTO accounts (id, holder, balance) VALUES
    (1, 'Ayesha', 5000.00), (2, 'Bilal', 1200.00),
    (3, 'Chen',   200.00),  (4, 'Dua', 9900.00),
    (5, 'Emre',   750.00);
```

Why keep a transfers log: (1) **audit/history** — balances only show *now*, the log shows *what happened and when*; (2) **debugging** — a mismatch between log and balances exposes a bug precisely.

## 1. A successful transfer

```sql
BEGIN;
UPDATE accounts SET balance = balance - 500 WHERE id = 1;
UPDATE accounts SET balance = balance + 500 WHERE id = 2;
INSERT INTO transfers (id, from_account, to_account, amount)
VALUES (1, 1, 2, 500.00);
COMMIT;

-- verify
SELECT * FROM accounts WHERE id IN (1, 2);
SELECT * FROM transfers;
```

## 2. The overdraft — CHECK fires, NOTHING changes

```sql
BEGIN;
UPDATE accounts SET balance = balance - 1000 WHERE id = 3;   -- balance 200!
COMMIT;   -- ERROR: check constraint violated → the transaction is aborted
-- Prove it:
SELECT * FROM accounts WHERE id = 3;      -- still 200
SELECT COUNT(*) FROM transfers;          -- unchanged
```

Key insight: after the CHECK fires, the transaction is in an *aborted* state — you must `ROLLBACK` to clear it, and **none of the transaction's statements survived**, including any earlier ones.

## 3. The FK failure — same proof

```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
INSERT INTO transfers (id, from_account, to_account, amount)
VALUES (2, 1, 999, 100.00);     -- account 999 doesn't exist
COMMIT;   -- FK error → abort
SELECT * FROM accounts WHERE id = 1;   -- untouched: the debit vanished too!
```

This is atomicity at work: the *earlier* UPDATE was undone by the later failure. Say that sentence out loud.

## 4. The simulated crash

```sql
BEGIN;
UPDATE accounts SET balance = balance - 250 WHERE id = 4;
-- "crash": type something invalid, or just:
ROLLBACK;
SELECT * FROM accounts WHERE id = 4;    -- untouched
```

## 5–8. Queries

```sql
-- 5. balances + net flow (in − out)
SELECT a.holder, a.balance,
       COALESCE(t_in.total, 0)  - COALESCE(t_out.total, 0) AS net_flow
FROM accounts a
LEFT JOIN (SELECT to_account,   SUM(amount) AS total FROM transfers GROUP BY 1) t_in
       ON t_in.to_account = a.id
LEFT JOIN (SELECT from_account, SUM(amount) AS total FROM transfers GROUP BY 1) t_out
       ON t_out.from_account = a.id
ORDER BY a.holder;

-- 6. accounts that received a transfer today
SELECT DISTINCT a.holder
FROM accounts a JOIN transfers t ON t.to_account = a.id
WHERE t.created_at = CURRENT_DATE;

-- 7. busiest account (either direction)
SELECT a.holder,
       (SELECT COUNT(*) FROM transfers t
        WHERE t.from_account = a.id OR t.to_account = a.id) AS activity
FROM accounts a
ORDER BY activity DESC LIMIT 1;

-- 8. the invariant — money conservation
SELECT SUM(balance) FROM accounts;
-- With one successful transfer of 500 and everything else rolled back,
-- the sum MUST equal 5000 + 1200 + 200 + 9900 + 750 = 17050.00.
```

## Challenge 9 — idempotency

The classic fix: a client-supplied **idempotency key**. Add `client_ref TEXT UNIQUE` to transfers — the same retry hits the UNIQUE constraint and is rejected. Alternative: a status column with a partial unique index (`UNIQUE ... WHERE status = 'pending'`) — same idea, more moving parts.

## Challenge 10 — the concurrency preview

Tab 2's UPDATE on the same row **blocks** until tab 1 commits or rolls back. That's a lock — the PG track (Days 18–20) turns this observation into a full model. (If you saw an error instead, you likely had a *failed* statement in tab 1 — the aborted transaction can't hold locks.)

## Bonus 11 — one-statement double update

```sql
UPDATE accounts SET balance = balance +
    CASE id WHEN 1 THEN -300 WHEN 2 THEN 300 END
WHERE id IN (1, 2);
```

More atomic? **No** — a multi-statement transaction was already atomic. It's *fewer round trips* (which is a real win over a network), but it's less readable and can't insert the transfer log row in the same statement. The two-UPDATE transaction is the honest pattern.

## Self-review answers (short)

- Two UPDATEs without a transaction: the crash-window — the app can die between statement 1 and 2, and money genuinely vanishes. With a transaction, the DB's crash recovery discards the partial work (Durability + Atomicity).
- CHECK firing = Consistency (a rule defended). FK firing = Consistency too (referential integrity) — but the *rollback of earlier statements* is Atomicity. Both letters on display.
