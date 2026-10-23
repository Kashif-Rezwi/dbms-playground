# Day 04 — ORDER BY, LIMIT, DISTINCT

**Track:** SQL · **Stage:** 1 — Foundation · **Difficulty:** Beginner
**Prerequisites:** Days 01–03 · **Dataset:** `ecommerce`

## Goal

Sort results, take top-N, page through results, and remove duplicates — the finishing touches on every read query.

## Fundamentals

**ORDER BY** sorts the *result* (never the table). Default is ascending (`ASC`); `DESC` flips it. Multiple keys sort in order — ties on the first key are broken by the second:

```sql
SELECT name, price, stock FROM products ORDER BY price DESC, name ASC;
```

**LIMIT** keeps only the first N rows *after sorting* — the classic "top N" pattern:

```sql
SELECT name, price FROM products ORDER BY price DESC LIMIT 3;   -- 3 most expensive
```

**OFFSET** skips rows — with LIMIT it makes *pagination*:

```sql
SELECT name FROM products ORDER BY name LIMIT 5 OFFSET 5;   -- rows 6–10
```

**DISTINCT** de-duplicates a result:

```sql
SELECT DISTINCT city FROM users;   -- each city once
```

** A real gotcha:** without ORDER BY, row order is *not guaranteed*. "LIMIT 5" without ORDER BY gives you 5 *arbitrary* rows — databases don't promise insertion order.

## Why It Matters

Every product listing ("sort by price"), every leaderboard ("top 10"), every "page 2 of results" is ORDER BY + LIMIT/OFFSET. DISTINCT answers "what unique values exist?" (e.g., which cities do our users live in?).

## Mental Model

> The result is built as a pile of rows. **WHERE** is the bouncer deciding who gets in. **ORDER BY** sorts the pile. **LIMIT/OFFSET** slice the sorted pile: "skip 5, take 5." **DISTINCT** removes lookalikes from the final list. Note what happens under the hood: filter → sort → slice.

## Examples

```sql
-- sort by price, cheapest first
SELECT name, price FROM products ORDER BY price;

-- most expensive first, name breaks ties
SELECT name, price FROM products ORDER BY price DESC, name;

-- top 3 priciest
SELECT name, price FROM products ORDER BY price DESC LIMIT 3;

-- page 2 of 3-at-a-time listing
SELECT name FROM products ORDER BY name LIMIT 3 OFFSET 3;

-- unique cities
SELECT DISTINCT city FROM users;

-- unique (city, active) combinations
SELECT DISTINCT city, is_active FROM users ORDER BY city;
```

## Practice

### 🟢 Warm Up

[Beginner] **W1.** All products, cheapest first (name, price).

[Beginner] **W2.** The 5 **most recent** products by `created_at` (name, created_at). Newest first!

### 🔵 Core

[Intermediate] **C1.** `[Predict]` — exactly which rows and in what order:

```sql
SELECT name, rating FROM reviews ORDER BY rating DESC, created_at LIMIT 4;
```

[Intermediate] **C2.** `[From Memory]` the single most expensive product (name, price). One row only.

[Intermediate] **C3.** Unique `status` values from `orders`.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Bug 1 (logical): meant "3 most expensive", got 3 random ones
SELECT name, price FROM products LIMIT 3;

-- Bug 2 (logical): no error — but why is this ORDER BY useless here?
SELECT DISTINCT city FROM users ORDER BY city DESC, is_active;

-- Bug 3 (syntax)
SELECT name FROM products ORDER price;
```

[Advanced] **H2.** "Top 3 reviews": product name (not id!), rating, and created date for the 3 **highest-rated** reviews, newest first. You need Day 2 (expressions? maybe) — wait, you need to *join* names... that's Day 11. Instead: from `reviews`, show rating + comment, and in a sentence explain *why* you can't show the product name yet. (Anticipating a limitation is a skill.)

[Advanced] **H3.** Unique `city` + `is_active` pairs among **inactive users only**, sorted by city. Predict the count first.

## Interview Questions

1. "How do you get the top 5 rows by some value?"
2. "What's the pagination pattern in SQL? Any problems with big OFFSETs?" *(Bonus awareness: large OFFSETs get slow — Day 24.)*
3. "Is result order guaranteed without ORDER BY?"

## Completion Checklist

- [ ] Understand ORDER BY, LIMIT, OFFSET, DISTINCT
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Can explain filter→sort→slice out loud
