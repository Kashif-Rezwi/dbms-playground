# Day 09 — Aggregates: COUNT, SUM, AVG, MIN, MAX

**Track:** SQL · **Stage:** 2 — CRUD + Querying · **Difficulty:** 🟢 Beginner
**Prerequisites:** Days 01–08 · **Dataset:** `ecommerce` (reset first)

## 🎯 Goal

Collapse many rows into single numbers — and understand what an aggregate *does* to a result set.

## 🧠 Fundamentals

An **aggregate function** takes many rows in and returns **one value**:

```sql
SELECT COUNT(*) FROM orders;               -- 12  (how many rows?)
SELECT SUM(total_amount) FROM orders;      -- one number: total revenue
SELECT AVG(rating) FROM reviews;           -- one number: average rating
SELECT MIN(price), MAX(price) FROM products;
```

**The fundamental rule:** once you aggregate, you've collapsed the result. This **fails**:

```sql
SELECT name, MAX(price) FROM products;     -- ERROR in PostgreSQL
```

Why? `name` has 16 values; `MAX(price)` has 1. Which name goes with it? The question is meaningless — unless you GROUP (tomorrow!). Today: aggregates return **exactly one row**.

**Useful details:**

- `COUNT(*)` counts rows; `COUNT(col)` counts non-NULL values of that column
- `AVG` ignores NULLs entirely (it averages *known* values)
- Aggregates work with WHERE — the filter happens first:

```sql
SELECT AVG(price) FROM products WHERE category_id = 1;   -- avg price of Electronics only
```

- `ROUND(AVG(x), 2)` tames long decimals

## 🔍 Why It Matters

"Total revenue this month", "how many users", "cheapest product" — every dashboard, every report, every "statistics" page is aggregate functions. Business questions are aggregate questions.

## 💡 Mental Model

> An aggregate is a **trash compactor**: 16 rows go in, 1 box comes out. You can't keep an original label (a `name`) glued to the box — unless you sort things into *groups of boxes* first (that's GROUP BY, tomorrow).

## 💻 Examples

```sql
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM users WHERE is_active;

SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';   -- realized revenue
SELECT ROUND(AVG(rating), 2) FROM reviews;

SELECT MIN(price), MAX(price) FROM products;
SELECT COUNT(*) FROM products WHERE stock = 0;                       -- out of stock count
SELECT SUM(quantity * unit_price) FROM order_items;                  -- gross merchandise value
```

## 🛠️ Practice

🟢 **P1.** How many products are in the catalog?
🟢 **P2.** Total stock across all products (SUM of stock).
🟢 **P3.** Average price of category 5 (Sports) — rounded to 2 decimals.
🟢 **P4.** Cheapest and most expensive product prices (one query, two aggregates).
🟡 **P5.** Total value of all *delivered* orders.
🟡 **P6.** Number of reviews, and the average rating, where rating >= 3.
🟡 **P7. ⭐ Predict first** (write the number down before running):

```sql
SELECT COUNT(*) FROM orders WHERE status <> 'cancelled';
```

🟡 **P8. From memory:** count of users joined in 2024.
🔴 **P9.** One query, four numbers: for products in category 1 — the count, average price, min price, and max price. What is the column header for each?
🔴 **P10.** Revenue if every out-of-stock item were restocked to 1 and sold at current price. (Silly, but it forces: COUNT + price. One aggregate query.)

## 🐛 Debugging

```sql
-- Bug 1: what is wrong and what error do you get?
SELECT name, MAX(price) FROM products;

-- Bug 2 (logical): the analyst ran this to count inactive users. Wrong number — why?
SELECT COUNT(is_active) FROM users WHERE is_active = FALSE;

-- Bug 3 (logical): intended "average price of Sports products". Look closely.
SELECT AVG(price) FROM products WHERE category_id <> 5;
```

## 🧩 Combine Concepts

Business questions need filters + aggregates: **average rating of products that cost more than 2000** (join reviews to prices? not yet — reviews don't carry price. Instead: average price of *reviewed* products is Day 11+ territory). Do this instead: **total quantity sold** across all `order_items` for `quantity >= 2` — then repeat with `BETWEEN` on `unit_price` (Day 8 + today). Predict both numbers first.

## 🔁 Previous Knowledge

1. What do `%` and `_` mean in LIKE?
2. Why does `COUNT(col)` differ from `COUNT(*)`? (You proved it on Day 7.)
3. Write from memory: candidates with 2–6 years experience in cities containing 'o'.
4. What does EXISTS answer?

## 🧠 Recall

1. What does an aggregate function do to a result set — input vs output?
2. Why is `SELECT name, MAX(price)` an error?
3. How does WHERE interact with aggregates (which happens first)?
4. What does AVG do with NULLs?

## 🎤 Interview Questions

1. "How would you compute the total revenue of delivered orders?"
2. "What's the difference between COUNT(*) and COUNT(column)?"
3. "Why can't you select a normal column next to an aggregate without GROUP BY?"

## ✅ Completion Checklist

- [ ] Understand all five aggregates + NULL behavior
- [ ] Completed P1–P10 (P7 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Can explain "one value out, rows in" out loud
