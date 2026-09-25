# ✅ Solutions — P4: Bank Transfer, Concurrency Edition

## Reference schema

```sql
CREATE TABLE accounts (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    holder TEXT NOT NULL,
    balance NUMERIC(12,2) NOT NULL CHECK (balance >= 0)
);

CREATE TABLE transfers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    from_account BIGINT NOT NULL REFERENCES accounts(id),
    to_account   BIGINT NOT NULL REFERENCES accounts(id),
    amount       NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (from_account <> to_account)
);

INSERT INTO accounts (holder, balance) VALUES
('Ayesha', 1000), ('Bilal', 500), ('Chen', 300), ('Dua', 200), ('Emre', 750);
```

## 2. The naive lost update (reproduced)

```text
S1: BEGIN; SELECT balance FROM accounts WHERE id=1;        -- 1000
S2: BEGIN; SELECT balance FROM accounts WHERE id=1;       -- 1000 (S1 uncommitted)
S1: UPDATE accounts SET balance = 1000 - 700 WHERE id=1;  -- writes 300
S2: UPDATE accounts SET balance = 1000 - 700 WHERE id=1;  -- also writes 300!
COMMIT both → 300 — one withdrawal lost entirely.
```

## 3. Fix 1 — atomic arithmetic (the default answer)

```sql
UPDATE accounts SET balance = balance - 700
WHERE id = 1 AND balance >= 700
RETURNING balance;
-- S1 → returns 300 (winner). S2 → returns nothing (row didn't satisfy the
-- guard) — the loser knows from RETURNING. No isolation change, no retry:
-- the read-modify-write is one atomic step.
```

## 4. Fix 2 — FOR UPDATE with ordering

```sql
BEGIN;
SELECT * FROM accounts WHERE id IN (1,2) ORDER BY id FOR UPDATE;  -- claim both, sorted
UPDATE accounts SET balance = balance - 700 WHERE id = 1;
UPDATE accounts SET balance = balance + 700 WHERE id = 2;
COMMIT;
-- Deadlock demo WITHOUT ORDER BY: S1 locks 1→wants 2; S2 locks 2→wants 1 →
-- one session gets "deadlock detected" and must retry.
-- With consistent ORDER BY, no cycle can form → no deadlock, ever.
```

## 5. Fix 3 — SERIALIZABLE + retry

```sql
BEGIN ISOLATION LEVEL SERIALIZABLE;
UPDATE accounts SET balance = balance - 700 WHERE id = 1;
UPDATE accounts SET balance = balance + 700 WHERE id = 2;
COMMIT;
-- one session: ERROR: could not serialize access due to read/write
-- dependencies among transactions → the app RETRIES the whole transaction.
```

Pseudo-code: `for attempt in 1..5: try tx; on serialization_error: continue; break`.

## 7. The analytics

```sql
SELECT a.holder,
  COALESCE((SELECT sum(amount) FROM transfers t WHERE t.to_account=a.id),0)   AS total_in,
  COALESCE((SELECT sum(amount) FROM transfers t WHERE t.from_account=a.id),0) AS total_out,
  COALESCE((SELECT sum(amount) FROM transfers t WHERE t.to_account=a.id),0)
  - COALESCE((SELECT sum(amount) FROM transfers t WHERE t.from_account=a.id),0) AS net_flow
FROM accounts a ORDER BY holder;

-- 8. the invariant: transfers conserve → SUM(balance) = 2750 (seed total), always.
SELECT sum(balance) FROM accounts;
```

## 10. Idempotency

```sql
ALTER TABLE transfers ADD COLUMN client_ref TEXT UNIQUE;
INSERT INTO transfers (from_account, to_account, amount, client_ref)
VALUES (1, 2, 700, 'web-abc-123') ON CONFLICT DO NOTHING
RETURNING id;    -- first call: an id; replay: empty — idempotent by structure.
```

## 11. Gapless numbering (why sequences can't)

```sql
CREATE TABLE counters (year INT, last_no INT, PRIMARY KEY (year));
INSERT INTO counters VALUES (2025, 0);

-- inside the transfer transaction:
UPDATE counters SET last_no = last_no + 1 WHERE year = 2025
RETURNING last_no;   -- row lock serializes allocators; ROLLBACK restores it
-- A sequence NEVER returns numbers (Day 5) — a counter row participates in
-- the transaction: rollback gives the number back → truly gapless.
```

## Self-review answers (short)

- Default: **atomic arithmetic with RETURNING** — one statement, no retry machinery; escalate to FOR UPDATE for multi-row invariants; SERIALIZABLE only for genuine multi-object invariants.
- The DB guarantees *no lost update*; the app must still read the result (RETURNING), handle "no row updated", and retry serialization errors.
- Almost everyone is surprised the naive version *silently* lost money — no error, just gone. That's the danger of read-modify-write.
