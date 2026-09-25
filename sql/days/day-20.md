# Day 20 — Normalization (1NF→3NF) & Denormalization

**Track:** SQL · **Stage:** 4 — Intermediate Querying · **Difficulty:** Intermediate
**Prerequisites:** Day 19 · **Dataset:** build your own today!

## Goal

Understand why "one fact, one place" saves your database — and when breaking that rule (denormalization) is the right call.

## Fundamentals

**The problem normalization solves.** Look at this "table":

```text
orders_bad
order_id | customer_name | customer_city | items
1        | Ayesha Khan    | Karachi       | "Mouse x1, Cable x1"
```

It *works*... until: Ayesha moves city — update **every** row she's in; you want to store a customer with no orders yet — **impossible**; Ayesha appears as "Ayesha Khan" in one row and "ayesha" in another — you can't tell if that's one person. These are **anomalies**:

- **Update anomaly** — one fact duplicated; rows drift apart
- **Insert anomaly** — can't record a fact without an unrelated fact existing first
- **Delete anomaly** — deleting the last order deletes the customer's entire existence

**The normal forms** (a staircase, each fixing the level below):

**1NF — atomic values, no repeating groups.** No comma-lists in cells, no "item1, item2" columns. Fix: one value per cell → move items into their own `order_items` table.

**2NF — no partial dependency on a composite key.** If a table is keyed by (order_id, product_id), then columns that depend on *only* product_id (like product name) don't belong. *(Only matters with composite keys.)*

**3NF — no transitive dependencies.** Non-key columns depend on *the key, the whole key, and nothing but the key*. If `orders` stores `user_id` *and* `user_city`, then city depends on user (a non-key thing) — move city to `users`.

**The working rule:**

> **"One fact in one place."** If you find yourself writing the same value in multiple rows, it probably belongs in its own table.

**Denormalization — deliberately breaking the rule.** Example: storing `posts.likes_count` instead of counting `likes` every time. It's a *trade*: faster reads / more storage / update risk (counter drift). You denormalize for read speed and accept the bookkeeping cost — never as an excuse for laziness.

## Why It Matters

Every schema you'll ever design needs this judgment. Interviews *love* "normalize this table" questions, and every real system eventually denormalizes something — knowing both sides is the skill.

## Mental Model

> Normalization is a **filing system**: one fact gets one folder, referenced everywhere else by pointer — you never photocopy the fact around (photocopies drift out of date). Denormalization is *deliberately keeping a photocopy on your desk* because walking to the filing room a thousand times a day costs more than the risk of the photocopy going stale.

## Examples — Do It Yourself

Create the deliberately-bad table and feel the anomalies:

```sql
CREATE TABLE flat_orders (
    order_id INT, customer_name TEXT, customer_city TEXT,
    product_name TEXT, quantity INT, unit_price NUMERIC(8,2)
);
INSERT INTO flat_orders VALUES
    (1, 'Ayesha Khan', 'Karachi', 'Wireless Mouse', 1, 2499.00),
    (1, 'Ayesha Khan', 'Karachi', 'USB-C Cable',   1, 899.00),
    (2, 'Bilal Ahmed', 'Lahore',  'Blender',        1, 8999.00);
```

Now prove the anomalies:

```sql
-- update anomaly: Ayesha moves. Which rows must change? (Both of hers!)
UPDATE flat_orders SET customer_city = 'Islamabad' WHERE customer_name = 'Ayesha Khan';

-- delete anomaly: delete Bilal's only order — Bilal ceases to exist
DELETE FROM flat_orders WHERE order_id = 2;
```

## Practice

[Beginner] **P1.** Build `flat_orders`. Run the update-anomaly UPDATE. SELECT * and point at the duplicated fact.
[Beginner] **P2.** Show the delete anomaly: what knowledge about Blenders disappeared with Bilal's order?
[Intermediate] **P3.** **Normalize to 1NF:** design tables where every cell is atomic (orders + order_items split). Write the CREATEs and INSERTs.
[Intermediate] **P4.** **Normalize to 3NF:** continue — customers get their own table, products get their own. Four tables: customers, products, orders, order_items. Add PKs and FKs (Day 19!).
[Intermediate] **P5. Predict first** — which normal form is violated, and which anomaly can bite?

```text
students(student_id PK, name, advisor_id, advisor_name, advisor_room)
```

[Intermediate] **P6.** Is the `ecommerce` schema normalized? Walk each table: 1NF? 2NF? 3NF?
[Advanced] **P7.** Denormalize *on purpose*: add `likes_count` to a copy of posts (mental exercise is fine). Write the UPDATE that maintains it after inserting a like. What can go wrong over time?
[Advanced] **P8.** Argue in 3 sentences: should `orders.total_amount` exist, or should it always be computed from `order_items`? Consider read speed, write cost, drift risk.

## Debugging

Design debugging — each design invites an anomaly. Name it:

```sql
-- Design 1
CREATE TABLE cars (id INT PRIMARY KEY, brand TEXT, brand_country TEXT, model TEXT);
-- (Ferrari appears 12 times, each with its own brand_country...)

-- Design 2
CREATE TABLE playlists (id INT PRIMARY KEY, song1 TEXT, song2 TEXT, song3 TEXT);

-- Design 3
CREATE TABLE invoices (id INT PRIMARY KEY, client_name TEXT, client_email TEXT, amount NUMERIC);
```

## Combine Concepts

Full cycle: take `flat_orders` → normalize into 4 tables (P4) → write the JOIN that *reconstructs* the original flat view (orders JOIN customers JOIN order_items JOIN products) → compare row-for-row with `flat_orders`. That's the whole point: **normalized storage, denormalized views via joins**.

## Previous Knowledge

1. PK vs FK — one line each.
2. What does ON DELETE CASCADE do — and its risk?
3. The "users with no orders" pattern — from memory.
4. Constraints — name all five you know.

## Recall

1. Name the three anomalies with one-line examples.
2. 1NF, 2NF, 3NF — one line each.
3. The working rule of thumb (four words)?
4. When is denormalization correct — and what does it cost?

## Interview Questions

1. "What is normalization and why do we do it?" *(Anomalies + one fact one place.)*
2. "Walk me through normalizing an orders table." *(You literally did this today.)*
3. "When would you denormalize?" *(Read-heavy, expensive joins, counters — with drift risk named.)*

## Completion Checklist

- [ ] Understand anomalies, 1NF–3NF, denormalization trade-offs
- [ ] Built flat_orders and felt every anomaly
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Completed the normalize-then-reconstruct combine task
- [ ] Answered recall without notes
- [ ] Can explain normalization out loud with an example

