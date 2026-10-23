# Day 26 — Design Decisions: When to Normalize, When to Denormalize

**Track:** SQL · **Stage:** 6 — Advanced Application · **Difficulty:** Advanced
**Prerequisites:** Days 01–25 · **Dataset:** thinking day (light SQL optional)

## Goal

Turn Day 20's theory into *decision-making* — given requirements, choose a structure and defend the trade-offs.

## Fundamentals

You know the two forces. Now the **decision framework** — walk these questions in order:

```text
1. Is the data relational at heart? (entities with identities + relationships → relational)
2. Normalize first. 3NF is the correct DEFAULT — anomalies are real bugs.
3. What's the read/write ratio? (reads >> writes → denormalization candidates appear)
4. Which specific queries are hot? (denormalize ONLY what those need)
5. Can the app keep the duplicate fresh? (a counter you never update is worse than a join)
6. Would an index/materialized view solve it without duplicating data? (try this first!)
```

**Canonical examples of *justified* denormalization:**

- `posts.likes_count` — counting millions of likes per page view is insane; one UPDATE per like is cheap
- An orders snapshot (item name + price *at time of order*) — that's not even denormalization, that's **history** — the product's price will change, the order must not
- Reporting tables refreshed nightly from normalized sources

**The anti-pattern to avoid:** denormalizing out of laziness before profiling. Duplication *before* evidence = every anomaly from Day 20, on purpose.

**Sizing rule:** duplication costs (a) storage, (b) write complexity, (c) drift risk. It buys (a) read speed, (b) simpler queries. Write down both sides before choosing.

## Why It Matters

This is the difference between "knows SQL syntax" and "can design a system". Interview system-design rounds almost always include a "how would you store this?" — the answer is a reasoned trade, not a reflex.

## Mental Model

> Normalization is the **default diet**; denormalization is **supplements** — you add specific ones for specific deficits, after a checkup (profiling), not the whole pharmacy.

## Examples — Decision Walkthroughs

**Case A: "Product name in order_items"** — legit or not? The item's `unit_price` is *history* (prices change). But `product_name` is a join convenience... unless you want the name *as it was at order time*. Decision: keep `unit_price` (history), join for name (current) — or snapshot both if invoice fidelity matters. There is no universal answer — that's the point.

**Case B: "Author name copied into posts"** — unjustified: names change (update anomaly), the join is cheap and indexed. Verdict: normalize.

## Practice

Each scenario: decide, then defend in writing (2–3 sentences each, naming the specific trade):

### 🟢 Warm Up

[Beginner] **W1.** A chat app stores 50 messages/second and displays each conversation's message count on load. Count live, or store a counter?

[Beginner] **W2.** A hotel booking site must show the room price *booked at the time*, even if prices change later. Structure?

### 🔵 Core

[Intermediate] **C1.** An analytics dashboard runs a 20-second GROUP BY over orders on every page load, hourly traffic. Options in order of preference?

[Intermediate] **C2.** An e-commerce product page needs avg rating + review count. Computing AVG over all reviews on every page view: keep, or denormalize? What keeps a denormalized version honest?

[Intermediate] **C3.** `[Predict]` a "tags" field on products as comma-separated text (`"wireless,usb"`). What are the three concrete problems (1NF anomaly, unsearchable joins, no referential integrity) — and the normalized fix?

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Schema A: reviews carry product_name AND user_name copied in.
-- List every anomaly possible, and the migration path to fix it
-- (which tables/keys do you create, and what's the one-time backfill query?)

-- Schema B: orders store JSON blobs: '{"user": {...}, "items": [...]}'
-- in a TEXT column. What can't the database do for you anymore?
-- (FKs? Indexes? Constraints? Aggregation? Joins?)

-- Schema C: a products table with columns price_2023, price_2024, price_2025.
-- What's wrong, and what's the right structure? (Repeating groups → 1NF.)
```

[Advanced] **H2.** Capstone pre-work: take your P3 (student-course) design and write a one-page **design memo** — schema, keys, two justified denormalizations (or "none, and why"), index plan (which queries are hot?), and a security note (who reads what). You'll reuse this format in the capstone.

[Advanced] **H3.** Full design: a **ticket-booking system** (events, seats, bookings) — write the 3NF schema (tables + keys), then list two places you'd deliberately denormalize for the *checkout flow*, with costs.

## Interview Questions

1. "When would you denormalize a schema?" *(Hot reads + cheap keeps-it-fresh writes + profiling first.)*
2. "What are the risks of denormalization?" *(Drift, write complexity, storage.)*
3. "How do you store historical data like past prices?" *(Snapshot rows / history tables — normalization doesn't mean forgetting history.)*

## Completion Checklist

- [ ] Understand the decision framework
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Completed the three schema reviews
- [ ] Completed the design memo
- [ ] Can defend a normalize/denormalize choice out loud
