# SQL Track Final Capstone — "LocalEvents" Ticket Platform

**Milestone:** SQL Days 29–30 · **Time:** 2 days · **Difficulty:** Advanced · **Everything you've learned**

## Objective

Design and build a complete relational system independently — with real design decisions, a transactional core, analytics, and a performance report. **There is no step-by-step solution for the design. Any defensible choice is correct; unexplained choices are not.**

## Scenario

LocalEvents sells tickets for local concerts/workshops. Requirements:

- **Organizers** create **events** (title, date, venue, base price, capacity)
- Each event has **seats** (generated: rows A–E × seats 1–8) with per-seat prices (VIP rows cost more)
- **Customers** browse and **book 1–4 seats** per booking
- A seat can't be sold twice; cancelled bookings free their seats
- **Payments** attach to bookings (method, amount = sum of seat prices — must match)

## Part 1 — Design (Day 29 morning) — no solution exists

1. Draw the **ER diagram** (Mermaid, in your `sql/projects/capstone-work/` folder)
2. Write the DDL: tables, PKs, FKs, CHECKs, UNIQUEs — every constraint earns its keep
3. Write the **design memo** (Day 26 format): data types chosen, two justified denormalizations *or* "none because ___", and a one-paragraph security note (who should read what)
4. Two design decisions you must make and defend:
   - How do you prevent double-selling a seat? (UNIQUE partial index? status column + constraint? locking? — you know some of these tools; pick your level and defend it)
   - Do you store the seat price *on the booking* (history) or join to the seat's current price? (Day 26 Case A — apply it.)

## Part 2 — Build & Prove Atomicity (Day 29 afternoon/evening)

5. Seed: 5 events, 200 seats, 10 customers, ~30 bookings (some cancelled)
6. Write the **booking transaction**: pick two available seats for an event, create the booking + items, mark seats sold, compute the payment — all atomically
7. **Failure theater** — prove each leaves NOTHING behind:
   - booking a seat id that doesn't exist (FK)
   - booking an already-sold seat (your double-sell defense fires)
   - a payment amount ≠ seat sum (CHECK fires)

## Part 3 — Analytics (Day 30 morning)

Write from memory where possible — all over your own schema:

8. Revenue per event, sell-out % (seats sold ÷ total seats), top 3 by revenue
9. Each customer's total spend + seat count + distinct events attended
10. Monthly revenue trend (Day 17 pattern) with a LAG-based month-over-month column
11. Events with < 50% seats sold that happen within 30 days (the "panic marketing" list — CTE + window or subquery)

## Part 4 — Performance (Day 30 afternoon)

12. Scale: generate 100k+ bookings with `generate_series` (reuse the `perf_lab` script's techniques)
13. Profile your three hottest queries with EXPLAIN ANALYZE; add at most **3 indexes**; re-measure; write the before/after report — justify each index
14. The write-tax check: bulk-insert timing with and without your indexes

## Part 5 — Defense (Day 30 evening)

Record yourself answering, no notes:

- "Walk me through your schema and why it's shaped that way."
- "How does your system prevent double-selling a seat?"
- "Show me a query you made faster and how."
- "What's the weakest part of your design, and what would you do with one more day?"

## Expected Outcome

`sql/projects/capstone-work/` containing: ER diagram, schema.sql, design memo, seed.sql, booking transaction + failure demos, analytics.sql, perf report, and a link to your recorded defense (or its transcript).

## Self-Review — before ticking PROGRESS.md

- [ ] Schema is 3NF with every constraint load-bearing
- [ ] Design memo defends types, denormalization choices, security
- [ ] Booking is atomic — all three failure demos clean
- [ ] 4 analytics queries verified against predicted numbers
- [ ] Perf report has real numbers and ≤ 3 justified indexes
- [ ] Defense recording done — follow-ups survivable?

> **This is the SQL track's finish line.** The PostgreSQL track makes you dangerous on the engine behind it; the MongoDB track broadens your modeling instincts.
