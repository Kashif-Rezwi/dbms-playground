# 🔀 Cross-Database Exercises — Same Questions, Two Engines

> Requires: both `ecommerce` seeds loaded (SQL + Mongo — same data, different shapes!). Predict before running, every time.

## Setup

```bash
./scripts/seed/seed-postgres.sh ecommerce
./scripts/seed/seed-mongo.sh ecommerce
```

## Level 🟢 — Direct translations (predict the answer, run BOTH, compare)

**X1.** "Products under 2000, cheapest first, top 3" — SQL and Mongo. Same rows? Same order? (Note the tie-handling difference if two prices were equal — ORDER BY name as tiebreaker in both.)

**X2.** "Count of delivered orders" — `SELECT COUNT(*) WHERE status='delivered'` vs `countDocuments({ status: 'delivered' })`. One line: what's identical, what's different (a cursor vs a scalar... what does the API hand you?).

**X3.** "Users with no reviews" — the SQL LEFT JOIN pattern vs Mongo's app-side $in (or $lookup + $size 0). Which engine made this *easier*, and why? (Honest answer: SQL — the LEFT JOIN + IS NULL pattern is one statement.)

## Level 🟡 — Same business answer, different tools

**X4.** "Revenue per city" — SQL: JOIN + GROUP BY. Mongo: $match → $lookup → $unwind → $group. Run both; same numbers (Karachi 20547 — predicted yet?). Two lines: which shape felt more natural, and which *would* you rather maintain?

**X5.** "Top product by units sold" — SQL joins order_items; Mongo **unwinds embedded items**. Predict (product 9, 3 units) and verify both. THE asymmetry in one exercise: same data, one stored it referenced, one embedded.

**X6.** "Average rating per product" — SQL: GROUP BY on reviews. Mongo: same $group. Now add "with product names" — SQL adds one JOIN; Mongo adds $lookup + $unwind. Write the mental mapping (JOIN ↔ $lookup+$unwind).

**X7.** The *integrity* comparison: run `UPDATE products SET price = -5 WHERE id = 1` (after adding the CHECK — PG Day 19 P7) vs the Mongo equivalent — is one rejected and the other accepted? What tool fills the gap in Mongo (validator — add it and prove it now rejects).

## Level 🔴 — Design decisions, argued in both worlds

**X8.** "Model the shopping cart" — SQL: carts + cart_items tables. Mongo: cart doc with embedded items. Write both schemas; then answer: in which is the *add-to-cart* operation simpler (Mongo positional-$ 2-step vs SQL 2 inserts — discuss transactional needs honestly).

**X9.** "One active subscription per user" — SQL: partial UNIQUE index... wait, that's PG's tool; plain SQL: UNIQUE constraint on (user_id, status) + discipline. Mongo: partial unique index. Which mechanism is *more precise*, and what does each demand of the team?

**X10.** The final judgment: given a new project — (a) a social feed with flexible post types, (b) a payroll ledger with hard invariants — assign SQL or Mongo with the *access-pattern + integrity* reasoning (Mongo D12 + D27's frameworks). Two paragraphs, no fence-sitting.

## Debrief (write 5 lines)

- One thing SQL made obviously easier:
- One thing MongoDB made obviously easier:
- The single biggest conceptual difference you *felt*:
- One skill that transferred perfectly:
- One interview sentence you'd now say about "SQL vs NoSQL":
