# Day 21 — Transactions & ACID

**Track:** SQL · **Stage:** 5 — Transactions + Performance · **Difficulty:** 🟡 Intermediate
**Prerequisites:** Days 01–20 · **Dataset:** `ecommerce` · **Milestone:** 🏗️ Project 5

## 🎯 Goal

Group multiple operations into all-or-nothing units, and explain ACID from experience.

## 🧠 Fundamentals

A **transaction** wraps several operations so they happen **all together or not at all**:

```sql
BEGIN;
UPDATE accounts SET balance = balance - 500 WHERE id = 1;
UPDATE accounts SET balance = balance + 500 WHERE id = 2;
COMMIT;      -- both happened, permanently
-- or: ROLLBACK; -- neither happened, as if you never typed
```

The classic motivation — a bank transfer. If the app crashes after "minus 500" but before "plus 500", money is *destroyed*. Transactions make that impossible: either the money moved, or nothing changed.

**ACID** — the four guarantees a transaction gives you:

- **A — Atomicity**: all or nothing. Crash mid-way? Rolled back automatically.
- **C — Consistency**: constraints can't be violated by a transaction — a bad write aborts the whole thing.
- **I — Isolation**: concurrent transactions don't stomp on each other (much more in the PG track).
- **D — Durability**: once COMMIT returns, the change survives power loss.

**Everyday facts:**

- Autocommit: a single statement outside BEGIN/COMMIT is its own tiny transaction.
- `ROLLBACK` undoes *everything since BEGIN* — a superpower for experimentation:

```sql
BEGIN;
DELETE FROM orders;           -- scary!
SELECT COUNT(*) FROM orders; -- 0. Shocking!
ROLLBACK;                    -- ...and it's all back
```

## 🔍 Why It Matters

Any data that must stay *consistent across multiple rows/tables* needs transactions: transfers, order+payment creation, signup+profile. Without them, every crash is corruption.

## 💡 Mental Model

> A transaction is a **contract signing in a room**: everything is staged on the table (BEGIN), no one outside can see it yet, and either everyone signs (COMMIT) or the whole contract is shredded (ROLLBACK). Even if the building collapses mid-signing (crash), no partial contract exists.

## 💻 Examples

```sql
-- a safe experiment (delete everything, then undo it)
BEGIN;
DELETE FROM reviews;
SELECT COUNT(*) FROM reviews;
ROLLBACK;
SELECT COUNT(*) FROM reviews;    -- all 12 back

-- a real multi-step write
BEGIN;
INSERT INTO orders (id, user_id, status, total_amount, ordered_at)
VALUES (50, 1, 'pending', 2499.00, CURRENT_DATE);
INSERT INTO order_items (id, order_id, product_id, quantity, unit_price)
VALUES (50, 50, 1, 1, 2499.00);
UPDATE products SET stock = stock - 1 WHERE id = 1;
COMMIT;

-- constraint + transaction: this whole thing fails, BOTH rows vanish
BEGIN;
INSERT INTO orders (id, user_id, status) VALUES (51, 1, 'pending');
INSERT INTO order_items (id, order_id, product_id, quantity, unit_price)
VALUES (51, 51, 99999, 1, 100);      -- product 99999 doesn't exist → FK error
COMMIT;      -- observe: order 51 is NOT in the table
```

## 🛠️ Practice

🟢 **P1.** Run the safe-experiment block. Say out loud what just happened.
🟢 **P2.** Run the multi-step write. Verify: order 50 exists, its item exists, stock dropped by 1.
🟢 **P3.** Run the FK-failure example. Check `SELECT * FROM orders WHERE id = 51;` — is the half-written order there? Which ACID letter saved you?
🟡 **P4.** Atomicity drill: BEGIN, update two users' `is_active`, ROLLBACK. Verify both reverted.
🟡 **P5.** Write the transaction for: order 51 — insert order AND item AND decrement stock — *successfully* (product 1). Verify all three effects.
🟡 **P6. ⭐ Predict first:** inside a transaction you UPDATE a price; another psql session (new terminal tab) SELECTs that price *before your COMMIT*. What does session 2 see? Test with two tabs.
🟡 **P7. From memory:** the safe-experiment pattern — delete all payments and bring them back.
🔴 **P8.** Build `CREATE TABLE accounts (id INT PRIMARY KEY, name TEXT, balance NUMERIC(12,2) CHECK (balance >= 0));` + two rows. Attempt a transfer that would overdraw it inside a transaction. What fires? What state is the transaction in? What must you do next? (Foreshadows PG Days 18–20.)

## 🐛 Debugging

```sql
-- Bug 1 (logical): why is this NOT a transaction?
UPDATE accounts SET balance = balance - 500 WHERE id = 1;
UPDATE accounts SET balance = balance + 500 WHERE id = 2;
-- (What happens between the two lines if the app crashes?)

-- Bug 2: ROLLBACK after COMMIT
BEGIN;
DELETE FROM reviews;
COMMIT;
ROLLBACK;      -- what happens? What does this teach about COMMIT's finality?

-- Bug 3 (isolation intuition): you typed BEGIN, did stuff, got distracted.
-- Your psql has been open 10 minutes. What problems can that cause others?
```

## 🧩 Combine Concepts

The full checkout: one transaction that (1) inserts an order, (2) inserts its items, (3) decrements stock, (4) inserts a payment, (5) sets order to paid — and add a *deliberate failure* at step 4 (UNIQUE violation: insert a second payment for order 1). Verify nothing survived. Then fix and rerun clean.

## 🔁 Previous Knowledge

1. The three anomalies of bad normalization — one line each.
2. Write from memory: revenue per month pattern.
3. What does a FK enforce?
4. Window vs GROUP BY — output rows?

## 🧠 Recall

1. The four ACID letters, one line each — from your own experience today.
2. What does ROLLBACK undo, exactly? What *can't* it undo?
3. What's autocommit?
4. Which ACID letter stopped the half-written order?

## 🎤 Interview Questions

1. "What is a transaction and why do we need one?" *(Transfer story.)*
2. "Explain ACID." *(Tell it with stories, not definitions.)*
3. "Give a real example where you'd use a transaction."

## 🏗️ Mini Project

Build **[P5: Bank Transfer Simulation](../projects/05-bank-transfer.md)** — accounts, transfers, failure scenarios. Attempt before solutions.

## ✅ Completion Checklist

- [ ] Understand BEGIN/COMMIT/ROLLBACK + ACID
- [ ] Completed P1–P8 (P6 tested with two sessions)
- [ ] Fixed all three bugs
- [ ] Completed the full-checkout combine task
- [ ] Answered recall without notes
- [ ] Started Project 5

