# Write-From-Memory Drill Pack

> No notes, no cheat-sheet, no peeking at previous days. Write each query, run it, *then* compare with the day files. Dataset: `ecommerce` / `social` as noted.

## Level 1 (Beginner) — One operation (Days 2–8)

1. Names and emails of all users.
2. The 3 cheapest products.
3. Users from Karachi.
4. Unique order statuses.
5. Insert a category `(12, 'Musical Instruments')`.
6. Set all `'pending'` orders to `'shipped'` (safely — with preview!).
7. Products whose name contains `'Mat'` or `'Shoes'`.
8. Prices between 500 and 2500 (inclusive).

## Level 2 (Intermediate) — Combinations (Days 9–17)

9. Revenue (SUM of total_amount) for delivered orders only.
10. Order count per status, alphabetical by status.
11. Top 3 users by number of reviews.
12. Users who never ordered (LEFT JOIN pattern — not NOT IN).
13. Every comment with its author's username and post content (`social`).
14. Followers of 'ayesha_k', usernames only (`social`).
15. Reviews above the overall average rating (scalar subquery).
16. Monthly revenue, chronological (EXTRACT pattern).
17. Every order with a running total of all revenue so far (window).

## Level 3 (Advanced) — Full patterns (Days 12–24)

18. Top 2 products by revenue per category (CTE + row_number).
19. Categories with average price above the overall average (subquery of a GROUP BY).
20. Users with name + post count + follower count in ONE query, zeros included (`social`, two CTEs + COALESCE).
21. A transaction: insert order + item + decrement stock, then ROLLBACK everything.
22. The 5-step diagnostic method for a slow query — written out, then applied to any query on `perf_lab`.

## Rules

- Miss one? Note the *day* it belongs to and redo that day's recall tomorrow.
- Perfect on a level? Skip re-testing it for a week (spaced repetition — come back in Day 20 and Day 28's review).
