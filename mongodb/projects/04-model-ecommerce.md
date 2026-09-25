# P4 — Model an E-Commerce Store (Design Decisions Required)

**Milestone:** Mongo Days 12–15 · **Time:** ~90 min · **The modeling stage's capstone**

## Objective

Design an e-commerce document model **from requirements** — with the access patterns, pattern choices, and trade-offs written down. The *design document* is the deliverable; a working seed + queries proves it.

## Scenario & Requirements

A store needs: users, products (with categories, tags, price, stock), carts (active, per user), orders (with line items, status, totals), reviews (unbounded per product), and product search by name/tag.

## Part 1 — The Design Document (write this first)

1. **Access patterns, ranked** (≥8): the app's reads/writes from product page → cart → checkout → order history → admin analytics
2. **Per relationship**: 1:1? 1:few? 1:many? M:N? — embed/reference/bucket/hybrid with a one-line defense (the framework, every time)
3. **The seven named patterns**: which do you use, where, and why (at least three, labeled)
4. **The shape contract**: validators for users and products (required fields, types)
5. **The integrity list**: no FKs — which references need app-side checks, and what checks?

## Part 2 — Build & Prove

6. Create the collections with validators; seed: 8 users, 12 products, 4 carts, 6 orders, 15 reviews
7. **Top-3 reads, each in ONE query** (or app-side 2-step where your design chose referencing): product page (product + rating summary + top review), user's order history, active cart with product names
8. **The write flows**: add-to-cart (the positional-$ pattern from Day 10!), checkout (order creation + cart clear — in a transaction if your design genuinely needs one — ARGUE it), submit-review (+ the rating-summary maintenance)
9. **The index plan**: your top reads' queries → the ESR-reasoned indexes (create them; explain-verify the top 3)

## Challenge

10. The drift audit: change a product's price — which documents carry stale copies under YOUR design? List them and write each maintenance rule.
11. The comparison (if you know SQL): write 5 lines — "a relational version of this store would need junction tables for ___, while my design chose ___ because ___". (No SQL background? Instead: which of my collections would be hardest to express as flat tables, and why?)

## Bonus

12. Redesign one choice you made and argue why version 2 is better (e.g., bucket pattern for a hot path) — the mark of a real designer is knowing your own design's weak spots.

> [solutions/04-model-ecommerce.md](solutions/04-model-ecommerce.md)
