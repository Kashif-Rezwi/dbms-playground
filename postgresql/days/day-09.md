# Day 09 — Functions (SQL & plpgsql)

**Track:** PostgreSQL · **Stage:** 3 — PG Features · **Difficulty:** 🟡→🔴

## 🎯 Goal

Write your own database functions — from one-line SQL helpers to logic in plpgsql — and know when a function is the right call.

## 🧠 Fundamentals

A **function** is named, reusable logic callable *inside* queries:

```sql
-- SQL function: one expression, usable anywhere
CREATE FUNCTION price_with_tax(numeric) RETURNS numeric
AS $$ SELECT round($1 * 1.05, 2) $$
LANGUAGE sql IMMUTABLE;

SELECT name, price, price_with_tax(price) FROM products;
```

**plpgsql** — a real procedural language (IF, LOOP, variables) for multi-step logic:

```sql
CREATE FUNCTION order_status_label(o orders) RETURNS text
LANGUAGE plpgsql STABLE AS $$
BEGIN
    IF o.status = 'delivered' THEN RETURN '✅ done';
    ELSIF o.status = 'cancelled' THEN RETURN '🚫 void';
    ELSIF o.status = 'pending' AND o.ordered_at < now() - interval '7 days'
        THEN RETURN '⏰ stale';
    ELSE RETURN '🚚 moving';
    END IF;
END $$;

SELECT id, order_status_label(o) FROM orders o;   -- pass the whole row!
```

**The volatility tags — the most interview-worthy part:**

- `IMMUTABLE` — same input → same output, *forever* (can be pre-computed, used in indexes)
- `STABLE` — same input → same output *within one statement* (reads tables)
- `VOLATILE` — can change anything, anytime (default; can't be optimized)

**Rule of use:** put logic in a function when it's **shared by many queries/writers** and must be *consistent* (the label must never disagree between two reports). Don't put logic in the DB just to avoid learning app code — debugging and versioning live better in the app.

## 🔍 Why It Matters

Functions give your database a vocabulary: `order_status_label(orders)` in every report, one billing rule everywhere. And volatility tags are how the planner reasons about your logic — mislabeling them causes genuinely confusing bugs.

## 💡 Mental Model

> A function is a **word you teach the database**: once it knows `price_with_tax()`, every query can speak it. IMMUTABLE = "this word means the same thing forever" (the planner can memoize it); VOLATILE = "this word might do anything each time" (the planner trusts nothing).

## 🛠️ Practice

🟢 **P1.** Create `price_with_tax`; select name, price, both prices for products > 2000.
🟢 **P2.** Create the `order_status_label` plpgsql function; label all orders; verify labels match the data by eye.
🟢 **P3.** Break it on purpose: call with a bogus status ('weird') — which branch runs? Add an ELSE if missing.
🟡 **P4.** A computed-column-style function: `line_total(order_items)` → quantity * unit_price; apply to all items of order 4.
🟡 **P5. ⭐ Predict first:** can you use `price_with_tax(price)` in an index? (`CREATE INDEX ON products (price_with_tax(price));`) And in a WHERE clause matching `price_with_tax(price) > 5000` — will a plain price index serve? Explain both before running.
🟡 **P6. From memory:** a `stale_task(tasks)` function: TRUE if status IN ('todo','doing') AND created_at < now() - 60 days (use the saas DB).
🔴 **P7.** Volatility experiment: create two versions of a "current tax rate" function, one tagged IMMUTABLE that actually reads a table (`SELECT rate FROM config`). Run a query, update the table, run again within the *same transaction* (REPEATABLE READ... keep simple: same session) — what does the mislabeled IMMUTABLE risk? Document the rule: *never lie on the volatility label*.
🔴 **P8.** Set-returning function (the gateway to Day 10's power): `CREATE FUNCTION active_users() RETURNS SETOF users LANGUAGE sql AS $$ SELECT * FROM users WHERE is_active $$;` then `SELECT name FROM active_users();` — and in FROM. One line: what did you just build? (A parameterized, reusable subquery.)

## 🐛 Debugging

```sql
-- Bug 1: ERROR: "input is out of range" from the function on some rows.
-- What's the debugging workflow for functions? (isolate inputs, test with
-- SELECT my_func(suspicious_input), add guards)
-- Bug 2 (tag lie): IMMUTABLE function calling now(). What breaks, when?
-- Bug 3: CREATE FUNCTION ... RETURNS numeric AS 'SELECT $1 * 1.05'
-- LANGUAGE sql; -- missing rounding AND missing IMMUTABLE... and works.
-- Why do tags matter if the result is the same?
```

## 🧩 Combine Concepts

The consistency argument, embodied: two reports (orders by status label; label counts by month) both using `order_status_label`. Now change the business rule *once* (stale = 14 days) and re-run both — that's the function payoff. Write the two-sentence version of this story as your combine-concepts answer.

## 🔁 Previous Knowledge

1. View vs materialized view — the freshness trade.
2. What does CONCURRENTLY refresh require?
3. Partial unique constraints — one real use.
4. SQL: window vs GROUP BY.

## 🧠 Recall

1. IMMUTABLE / STABLE / VOLATILE — one line each.
2. What does mislabeling volatility risk?
3. When is a function the right design call? (The two-condition test.)
4. What does SETOF enable?

## 🎤 Interview Questions

1. "What are function volatility categories and why do they matter?" *(Planner optimization + index eligibility.)*
2. "When would you put business logic in a database function?"
3. "How do you use a function in an index?" *(IMMUTABLE + expression index.)*

## ✅ Completion Checklist

- [ ] Understand functions, plpgsql, volatility tags
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the consistency combine task
- [ ] Answered recall without notes
