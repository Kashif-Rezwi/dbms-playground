# 🏗️ Project 4 — E-Commerce Analytics

**Milestone:** SQL Stage 4 (after Day 19) · **Time:** ~90 min · **Dataset:** `ecommerce` (reset first)

## Objective

Answer a real business's analytics questions over the shared multi-table dataset — joins, aggregation, windows, dates, all in one battery.

## Scenario

The shop's owner asks for a quarterly report. You have the data; you have the tools. Deliver.

## Required Queries

**Foundation (🟢)**

1. Full order detail: order id, customer name, city, product name, quantity, line total (4-table chain)
2. Revenue per customer, including customers who never ordered (LEFT JOIN + COALESCE for zero)
3. Products that have never been reviewed *or* ordered (EXCEPT or two LEFT JOINs — your pick, defend it)

**Analytics (🟡)**

4. Monthly revenue by status (month, status, revenue — two-level GROUP BY)
5. Category performance: category, product count, avg price, total revenue (join chain + GROUP BY)
6. Top 3 customers by revenue — with the running-total column alongside (window)
7. Each order's share of its customer's total spending (window: SUM OVER PARTITION)
8. Products ranked by revenue *within their category* (window + join; top 2 per category via the row_number pattern)

**Deep cuts (🔴)**

9. The "second-order conversion" question: customers whose *first* order was in Q1 2025 and who ordered *again* — count them (CTE + self-join or correlated thinking)
10. A cohort-style table: rows = join month of customer, columns... keep it: customers joined per month + how many of those ever ordered (two CTEs + conditional count)
11. Payment method breakdown per month (payments + orders... payments has no month independent of orders — join needed; think carefully about cancelled orders)

## Constraints

- Every count predicted before running
- Query 3 written two ways, results verified identical

## Performance Requirement

On the tiny dataset: none. But — EXPLAIN (plain, no ANALYZE) queries 1 and 4 and note which scans happen. (Day 22–24 gives you the tools to fix what you see.)

## Challenge Tasks ⭐

12. The owner wants a view `monthly_dashboard` (month, orders, revenue, active customers) — build it (Day 25 preview: views)
13. Data quality audit: find any order whose `total_amount` ≠ sum of its items (there should be NONE — prove it, and explain what WOULD enforce this beyond discipline)

## Bonus Challenge 🔴

14. Revenue "same month last year" comparison — with only 2025 data you can't... adapt: compare each month against the *previous* month's revenue (window LAG — research it: `LAG(revenue) OVER (ORDER BY month)`), and compute month-over-month % change.

## Expected Outcome

14 analytics queries delivered with predictions verified — a portfolio-grade report battery.

## Self-Review Questions

- Which query needed the most tables? Which was the most valuable to the business?
- Where did NULL show up uninvited, and how did you handle it?
- Which queries would break as the data grows to 100k rows — and which tool would you reach for first?

> ✅ Done? [solutions/04-ecommerce-analytics.md](solutions/04-ecommerce-analytics.md)
