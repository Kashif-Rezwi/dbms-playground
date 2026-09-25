# Day 28 — Stage Review + Mock Interview

**Track:** SQL · **Stage:** 6 — Advanced Application · **Difficulty:** 🟡 Mixed

**Prerequisites:** Days 01–27 · No new material today — this is consolidation.

## 🎯 Goal

Prove to yourself the 27 days stuck. Written review → query drills → debugging drills → a recorded mock interview.

## 📝 Part 1 — Concept Review (no notes!)

Answer in writing, then check against the day files:

1. What's the difference between a database, a DBMS, and SQL? (Day 1)
2. WHERE vs HAVING — with the clause-order list. (Day 10)
3. INNER vs LEFT JOIN, and the "no match" pattern. (Days 11–12)
4. Correlated subquery — what and cost? (Day 14)
5. Window function vs GROUP BY — input/output rows. (Day 16)
6. The three anomalies + the 1NF→3NF staircase. (Day 20)
7. ACID — with a story for each letter. (Day 21)
8. Index: structure, benefit, two costs, when ignored. (Day 22–23)
9. The 5-step slow-query method. (Day 23)
10. View vs materialized view. (Day 25)

## 🛠️ Part 2 — Query Drills (dataset: `ecommerce`, reset first)

Write each from memory. Verify. If you can't, re-read that day — that's the *system working*.

🟢 **D1.** Top 3 most expensive in-stock products. (Days 3–4)
🟢 **D2.** Count of delivered orders. (Days 3, 9)
🟢 **D3.** Insert a new user safely. (Day 5)
🟡 **D4.** Users who never ordered. (Day 12)
🟡 **D5.** Revenue per month, non-cancelled, chronological. (Days 17, 10)
🟡 **D6.** Categories with average price above the overall average. (Day 14)
🟡 **D7.** Each product's rating vs its own average rating. (Day 14/16)
🔴 **D8.** Top 3 revenue products per category — the full pattern. (Day 16)
🔴 **D9.** A transaction: create order + item + decrement stock, with a deliberate failure showing atomicity. (Day 21)
🔴 **D10.** EXPLAIN ANALYZE a query of your choice on `perf_lab`; fix one thing; show before/after. (Days 22–24)

## 🐛 Part 3 — Debugging Drills

```sql
-- A: silent empty result (name it, fix it)
SELECT name FROM users WHERE city = NULL;

-- B: wrong count for "users with zero orders" (fix it)
SELECT u.name, COUNT(*) AS orders
FROM users u LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.name HAVING COUNT(*) = 0;

-- C: meant "revenue over 5000 per user", runs but returns nothing... why?
SELECT user_id, SUM(total_amount) FROM orders GROUP BY user_id WHERE SUM(total_amount) > 5000;

-- D: slow on purpose — explain why each is slow:
SELECT * FROM big_orders WHERE UPPER(status) = 'DELIVERED';
SELECT * FROM big_orders ORDER BY id LIMIT 10 OFFSET 199990;
```

## 🎤 Part 4 — Mock Interview (30 minutes)

Do this out loud — record yourself on your phone. Answer each, then follow-ups:

1. **"Walk me through what happens when I run a SELECT with WHERE and ORDER BY."**
   - *Follow-up:* which clause runs first?
   - *Follow-up:* where do indexes come in?
2. **"Explain JOINs — INNER vs LEFT."**
   - *Follow-up:* how do you find rows with no match?
   - *Follow-up:* what's the LEFT JOIN + WHERE trap?
3. **"What is an index, and when would you NOT add one?"**
   - *Follow-up:* why can an index hurt performance?
   - *Follow-up:* how do you investigate a slow query?
4. **"Explain ACID."**
   - *Follow-up:* what does ROLLBACK undo?
   - *Follow-up:* give me a real transaction example.
5. **"Normalize this: `orders(id, customer_name, customer_city, item_list_csv)`."**
   - *Follow-up:* name the anomalies this design invites.
   - *Follow-up:* when would you denormalize parts of it?

Grade yourself per question: could I answer the *follow-ups* without notes? Anything shaky → re-do that day's recall section tomorrow morning before Day 29.

## ✅ Completion Checklist

- [ ] Part 1 answered in writing before checking
- [ ] D1–D10 written from memory and verified
- [ ] Debugging drills diagnosed correctly
- [ ] Mock interview recorded and graded honestly
- [ ] Shaky topics scheduled for morning review
