# Day 02 — SELECT: Reading Data

**Track:** SQL · **Stage:** 1 — Foundation · **Difficulty:** 🟢 Beginner
**Prerequisites:** Day 01 · **Dataset:** `ecommerce`

## 🎯 Goal

Write SELECT queries confidently: choose columns, compute expressions, alias results, and understand that queries never change data.

## 🧠 Fundamentals

`SELECT` answers two questions: **which columns?** and (later) **which rows?**

```sql
SELECT name, price FROM products;
```

Read it as: *"Give me the `name` and `price` columns from the `products` table."* The order you list columns is the order they appear.

**Expressions**: you can compute, not just fetch:

```sql
SELECT name, price, price * 0.9 AS discounted_price FROM products;
```

**`AS`** creates an *alias* — a name for the computed column. Without it the header is ugly (`?column?`). Aliases are for humans; they don't change the data.

**`SELECT *`** means "all columns." Fine for exploring; avoid it in real code (it fetches more than you need and breaks when the table changes).

**Crucial fact:** SELECT never modifies data. Run a query a hundred times — the table is untouched. It's a *read*.

## 🔍 Why It Matters

Reading data is 80% of daily database work. Every report, API endpoint, and dashboard is a SELECT in disguise.

## 💡 Mental Model

> `SELECT` is like ordering at a counter: *"I'll take the name and the price, and by the way, call that last thing 'discounted_price'."* The kitchen (table) isn't touched.

## 💻 Examples

```sql
-- specific columns
SELECT name, stock FROM products;

-- all columns (exploring only)
SELECT * FROM categories;

-- arithmetic + alias
SELECT name, price, price * 1.05 AS price_with_tax FROM products;

-- text operations preview
SELECT name, name || ' (out of stock)' AS label FROM products;
```

## 🛠️ Practice

🟢 **P1.** Select `name` and `email` from `users`.
🟢 **P2.** Select `name`, `price`, and `stock` from `products` — but reverse the column order in your output (`stock` first). Verify order matters.
🟢 **P3.** From `products`, show `name` and a computed column `stock_value` = `price * stock`. Alias it.
🟢 **P4.** From `orders`, select `id` and a computed column `is_big` = `total_amount > 5000` (a boolean expression).
🟡 **P5.** Same as P3, but with `AS` omitted on the computed column. What header does PostgreSQL give it? Why does the alias matter?
🟡 **P6. ⭐ Predict first:** how many columns and rows will this return, and what will the third column's values be?

```sql
SELECT name, price, price * 2 AS doubled FROM products WHERE price > 8000;
```

(If WHERE is unfamiliar, run it *after* predicting — Day 3 makes it clear.)

🟡 **P7. From memory:** write a query showing each product's `name` and `price_in_cents` (price × 100), for the products table. No notes, no peeking at today's examples.

## 🐛 Debugging

Diagnose both. For each: what's wrong, why, fix it, verify the fix.

```sql
-- Bug 1
SELECT name price FROM products;

-- Bug 2
SELECT name, price FROM product;
```

*(Hint for Bug 1: there's no error message! That's what makes it a logical bug.)*

## 🧩 Combine Concepts

Use the ER diagram from Day 1: write a query on `order_items` showing `order_id`, `product_id`, and a computed column `line_total` (`quantity * unit_price`). Then, in a sentence, connect this to why the `order_items` table exists at all.

## 🔁 Previous Knowledge

1. What's the difference between a database and a DBMS?
2. Which table connects orders to the products inside them?
3. What psql command shows a table's structure?
4. Is `SELECT` dangerous to run? Why or why not?

## 🧠 Recall

1. What are the two "questions" a SELECT answers?
2. What does `AS` do? What happens without it?
3. When is `SELECT *` acceptable?
4. Does SELECT change data? Prove it: run a query twice, check the table between runs.

## 🎤 Interview Questions

1. "What does SELECT do, and what are its main clauses?"
2. "Why is `SELECT *` considered bad practice in application code?" *(You need only today's reasons; more come in Day 24.)*
3. "Can a SELECT query ever change data?" *(Trick question — the honest answer: not directly.)*

## ✅ Completion Checklist

- [ ] Understand SELECT, expressions, aliases
- [ ] Completed P1–P7 (predictions written *before* running)
- [ ] Fixed Bug 1 and Bug 2 and explained each
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Can explain SELECT + aliasing out loud
