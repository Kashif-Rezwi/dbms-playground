# Day 10 — Stored Procedures & Triggers

**Track:** PostgreSQL · **Stage:** 3 — PG Features · **Difficulty:** 🟡→🔴 · **Milestone:** 🏗️ Project 2

## 🎯 Goal

Run multi-step logic *inside* the database on a schedule of events: procedures you call, triggers that fire on writes.

## 🧠 Fundamentals

**Stored procedures** (plpgsql) are like functions but can manage their own transactions:

```sql
CREATE PROCEDURE transfer(from_id int, to_id int, amount numeric)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE accounts SET balance = balance - amount WHERE id = from_id;
    UPDATE accounts SET balance = balance + amount WHERE id = to_id;
    IF (SELECT balance FROM accounts WHERE id = from_id) < 0 THEN
        ROLLBACK;   -- procedures CAN commit/rollback!
        RAISE EXCEPTION 'insufficient funds';
    END IF;
    COMMIT;
END $$;

CALL transfer(1, 2, 500);
```

**Triggers** = "when X happens to this table, run this function."

```sql
-- 1. updated_at maintenance
CREATE FUNCTION touch_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END $$;

CREATE TRIGGER tasks_touch BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

-- 2. audit log
CREATE TABLE audit_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    table_name text, action text, row_data jsonb, at timestamptz default now()
);
CREATE FUNCTION audit_row() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO audit_log (table_name, action, row_data)
    VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(NEW));
    RETURN NEW;
END $$;

CREATE TRIGGER reviews_audit AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW EXECUTE FUNCTION audit_row();

-- 3. enforcing consistency that CHECK can't (Day 7 P8's answer!)
CREATE FUNCTION keep_totals_honest() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    UPDATE orders o SET total_amount = (
        SELECT sum(quantity * unit_price) FROM order_items WHERE order_id = NEW.order_id)
    WHERE o.id = NEW.order_id;
    RETURN NEW;
END $$;

CREATE TRIGGER sync_order_total AFTER INSERT OR UPDATE OR DELETE ON order_items
    FOR EACH ROW EXECUTE FUNCTION keep_totals_honest();
```

**BEFORE vs AFTER:** BEFORE can *change* the row (NEW) or veto it; AFTER reacts (audit, propagate).

**The trade, honestly stated:** triggers guarantee consistency *for every writer* — but hide logic, add write cost, and make debugging harder. Legitimate jobs: invariants, audit, denormalized counters. Avoid: business workflows and "sometimes-off" logic.

## 🛠️ Practice

🟢 **P1.** Add `updated_at` to a scratch table; create the touch trigger; UPDATE; verify.
🟢 **P2.** Build the audit trigger on `reviews`; insert/update/delete; read the log — and what does `to_jsonb(NEW)` miss on DELETE? (Should it be OLD there?)
🟡 **P3.** Build the order-total sync on real `ecommerce` (reset after): update an item's quantity; verify the order's total follows automatically.
🟡 **P4. ⭐ Predict first:** with that trigger active, insert an order_item for a *nonexistent* order. What fires first — FK or trigger? What does that teach about AFTER triggers vs constraints?
🟡 **P5.** Procedure drill: `CALL transfer` with sufficient funds, then insufficient — read the error; verify balances unchanged.
🟡 **P6. From memory:** the touch pair (function + trigger) for a new table `products_t`.
🔴 **P7.** The veto: a BEFORE trigger returning NULL silently drops the write. Build `block_price_hikes` (veto price rises > 2×). Try 1.5× (works) and 3× (silently vanishes). Is silent veto good design? What's responsible instead? (`RAISE EXCEPTION`.)
🔴 **P8.** Recursive trigger danger: trigger A on X updates Y; trigger B on Y updates X. What happens (loop → depth-limit error)? Two lines on why trigger graphs need rules.

## 🐛 Debugging

```sql
-- Bug 1: "trigger returned null value" — writes vanish without errors.
-- Which trigger type does this, and what's the responsible pattern?
-- Bug 2: audit_log grows 10× faster than the real table. What did someone
-- attach, and the options? (narrow events, log deltas, sample)
-- Bug 3: CALL fails with "there is no transaction in progress" —
-- mixing COMMIT semantics; when must a procedure NOT call COMMIT?
```

## 🧩 Combine Concepts

Everything into **[P2: SaaS Task Tracker (triggers)](../projects/02-saas-tracker.md)** — the saas schema rebuilt with triggers for updated_at, audit, and a drift-proof denormalized counter. Attempt before solutions.

## 🔁 Previous Knowledge

1. IMMUTABLE vs VOLATILE — one line each.
2. What does a SETOF function enable?
3. SQL: denormalization costs — name all three.
4. SQL: when is a likes_count counter justified?

## 🧠 Recall

1. Procedure vs function — the transaction difference.
2. BEFORE vs AFTER triggers — one line each.
3. Triggers' 3 legitimate jobs? What are they NOT for?
4. What does `RETURN NULL` in BEFORE do — and the responsible alternative?

## 🎤 Interview Questions

1. "When would you use a trigger instead of application code?" *(Invariants for all writers: audit, counters, timestamps.)*
2. "What are the risks of triggers?" *(Hidden logic, write cost, debuggability, recursion.)*
3. "How do you keep a denormalized counter from drifting?" *(Trigger — automatic for every writer.)*

## ✅ Completion Checklist

- [ ] Understand procedures, BEFORE/AFTER triggers, trade-offs
- [ ] Completed P1–P8 (P4 predicted first)
- [ ] Fixed all three bugs
- [ ] Started Project 2
- [ ] Answered recall without notes
```
