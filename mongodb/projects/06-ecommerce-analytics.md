# P6 — E-Commerce Analytics (Pipeline)

**Milestone:** Mongo Day 22 · **Time:** ~90 min · **Dataset:** `ecommerce` (reset first)

## Objective

The SQL-track P4 business battery, pipeline edition: joins, grouping, unwinds — same questions, different tools, predictions everywhere.

## Required Queries (pipelines unless noted)

1. **Top 3 products by units sold** — $unwind items → $group → $sort (predict the winner first: it's between the book ×3 and the shoes ×2)
2. **Revenue per city** — $match (non-cancelled) → $lookup users → $unwind → $group (predict the top city!)
3. **Top 3 customers by delivered revenue** — with their order count and first order date
4. **Payment method breakdown** — $group on payments, no join needed (predict the method totals first)
5. **Average rating per product with names** — reviews → $lookup products (top 3 by avg)
6. **Products never ordered** — $lookup from products → order_items... wait: items are EMBEDDED in orders. Two designs: (a) products → $lookup orders on `items.product_id` (can you $lookup into an array field? YES — localField matches array elements!) then $match `orders: {$size: 0}`; (b) app-side: collect sold ids, $nin. Do BOTH, verify equal.
7. **The monthly report**: month, orders, revenue — $group by {$month/$year of ordered_at} (the $dateToParts or $month trick — look up `$month: '$ordered_at'`)
8. **Orders with their item-count** — no pipeline: just... this is the embed payoff: one read per order. Write it as a find + projection and say WHY no aggregation is needed (the modeling↔pipeline connection).

## Challenge

9. The full chain: top 5 revenue products *with names, units, and each product's best single order* (max revenue line) — $unwind + $group twice + $lookup
10. The SQL↔pipeline cross-check (if you know SQL): pick queries 2 and 4; write them in SQL and compare row-for-row. Note one thing pipelines made EASIER and one thing SQL made easier. (No SQL background? Skip — or save it for the cross-database exercises later.)

## Bonus

11. The $facet report: ONE aggregation returning { topProducts, revenueByCity, methodTotals } — $facet runs multiple sub-pipelines. When is that the deployment-shaped answer?

> [solutions/06-ecommerce-analytics.md](solutions/06-ecommerce-analytics.md)
