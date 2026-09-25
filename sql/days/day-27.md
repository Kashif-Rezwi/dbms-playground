# Day 27 — SQL Anti-Patterns & Common Mistakes

**Track:** SQL · **Stage:** 6 — Advanced Application · **Difficulty:** 🟡 Intermediate
**Prerequisites:** Days 01–26 · **Dataset:** `ecommerce` (reset first)

## 🎯 Goal

Collect the classic mistakes into one checklist — most of which you've already *made and fixed* in this track. Today cements the pattern recognition.

## 🧠 Fundamentals — The Anti-Pattern Catalog

**Correctness mistakes:**

1. **`= NULL`** instead of `IS NULL` (Day 3) — silent empty results
2. **`NOT IN` with a nullable subquery** (Day 8) — one NULL poisons the whole list
3. **`COUNT(*)` after LEFT JOIN** to count children (Day 12) — counts the NULL row too; use `COUNT(child.id)`
4. **WHERE on the right side of an outer join** — filters on the right table's columns turn LEFT JOIN back into INNER. Correct: put right-side conditions in ON (the one exception: the `IS NULL` pattern).
5. **Impossible AND-logic**: `WHERE city = 'K' AND city = 'L'` (Day 3 Bug 2)

**Design mistakes:**

6. **Comma-separated values in one cell** (Day 20) — kills 1NF, joins, integrity
7. **Repeating columns** (`price_2023, price_2024...`) — same disease, different shape
8. **Copying facts** instead of referencing (update anomaly)
9. **Natural keys that change** — emails as PKs break every FK the day someone's email changes

**Performance mistakes:**

10. **`SELECT *` in code** (Day 2/24) — over-fetching, breaks on schema change
11. **Functions on indexed columns** (Day 23) — index death
12. **OFFSET pagination at depth** (Day 24) — reads everything to skip it
13. **Indexing everything** — write tax on every INSERT/UPDATE
14. **N+1 queries in application code** — a loop running one query per row; SQL wants a JOIN

**The meta-skill:** when a query misbehaves, *which family is it?* Wrong results → correctness list. Weird-but-fast → design list. Slow → performance list (then EXPLAIN ANALYZE).

## 🔍 Why It Matters

These exact mistakes appear in code reviews and interviews constantly. Recognizing them on sight is a genuine mid-level signal.

## 💡 Mental Model

> Anti-patterns are **potholes on your regular route**: everyone hits them once. Today you install the signposts — the goal isn't "never make mistakes", it's "recognize them within seconds".

## 💻 Examples — Spot the Pothole

```sql
-- 1. Silent empty result
SELECT * FROM users WHERE email = NULL;

-- 2. The LEFT JOIN + WHERE trap (filter on right table's column!)
SELECT u.name, o.id FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE o.status = 'delivered';        -- silently became an INNER JOIN!

-- 3. COUNT(*) lies
SELECT u.name, COUNT(*) FROM users u
LEFT JOIN orders o ON o.user_id = u.id GROUP BY u.name;

-- 4. CSV disease
CREATE TABLE bad_products (id INT, name TEXT, tags TEXT);
INSERT INTO bad_products VALUES (1, 'Mouse', 'wireless,usb,black');

-- 5. N+1 in application pseudo-code
for user in SELECT id FROM users:                -- 1 query
    SELECT * FROM orders WHERE user_id = user.id -- ...and N more
-- The fix: ONE join.
```

## 🛠️ Practice — Diagnose on Sight

Each has exactly one anti-pattern. Name it, explain the symptom, write the fix:

🟢 **P1.** `SELECT COUNT(*) FROM users u LEFT JOIN reviews r ON r.user_id = u.id WHERE u.name = 'Ayesha Khan';` — right count? What if she has no reviews? Fix it.
🟡 **P2.** The LEFT JOIN + WHERE trap (example 2). Predict the row-count change vs moving `o.status = 'delivered'` into the ON clause. Measure both.
🟡 **P3.** `SELECT * FROM users WHERE SUBSTRING(email, 1, 6) = 'ayesha'` with an index on email — name the problem and rewrite.
🟡 **P4. ⭐ Predict first:** rows returned by

```sql
SELECT name FROM users WHERE id NOT IN (SELECT user_id FROM orders WHERE status = 'cancelled');
```

— then check whether `orders.user_id` being NOT NULL saves this query (it does — but say exactly why).
🔴 **P5.** Fix `bad_products`: design the normalized version (products, tags, product_tags) and write the query "products with the 'usb' tag" in *both* worlds. Feel the difference.
🔴 **P6.** The N+1 rewrite: write the single query that replaces the pseudo-code loop — plus the window-function version listing each user's orders in one round trip.
🔴 **P7. From memory:** write the anti-pattern catalog's *titles* from memory. Which three did you personally hit in this track? Link the day.

## 🐛 Debugging — The Gauntlet

Three snippets, three different families — diagnose, fix, verify:

```sql
-- A: "users who never reviewed" returns nothing, but some users have no reviews
SELECT u.name FROM users u WHERE u.id NOT IN (SELECT user_id FROM reviews);

-- B: this dashboard query takes 4 seconds in prod; locally it's instant
SELECT * FROM orders WHERE ordered_at - INTERVAL '30 days' > CURRENT_DATE - INTERVAL '60 days';

-- C: the tag search finds nothing for 'black' even though it's in there
SELECT name FROM bad_products WHERE tags = 'black';
```

## 🧩 Combine Concepts

Write your team's **SQL style guide**, 10 rules max, in your notes — mixing this day's catalog with your own scars ("always preview WHERE before UPDATE", "always COUNT(child.id)", "no functions on indexed columns"). The capstone asks you to apply it.

## 🔁 Previous Knowledge

1. The 6-question denormalization framework — from memory.
2. Why is a price snapshot in order_items *history*, not duplication?
3. What should you try before denormalizing?
4. EXPLAIN vs EXPLAIN ANALYZE — one line.

## 🧠 Recall

1. Name the five correctness anti-patterns.
2. Explain the LEFT JOIN + WHERE trap in one sentence.
3. Why is `NOT IN` risky, and what's the safer idiom?
4. What is N+1 and its fix?

## 🎤 Interview Questions

1. "What are the most common SQL mistakes you've seen?" *(Name four with fixes — from experience, not a list.)*
2. "A LEFT JOIN query silently loses unmatched rows — what happened?" *(WHERE on the right side.)*
3. "What's the N+1 problem and how do you fix it?"

## ✅ Completion Checklist

- [ ] Understand all three anti-pattern families
- [ ] Completed P1–P7 (P4 predicted first)
- [ ] Survived the gauntlet
- [ ] Wrote your personal style guide
- [ ] Answered recall without notes
- [ ] Can diagnose wrong-results vs slow-results queries on sight

