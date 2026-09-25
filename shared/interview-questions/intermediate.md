# 🎤 Interview Questions — Intermediate

> Requires the deeper layers of the tracks. Follow-ups are the bar.

## Querying & Patterns

1. **Write: top 3 customers by revenue including zero-order customers.** → *follow-up: why COUNT(*) lies here.* [SQL D12]
2. **Write: top 2 products per category.** → *follow-up: why can't WHERE see window results?* [SQL D16]
3. **Subquery vs JOIN — when each?** → *follow-up: what's a correlated subquery's cost?* [SQL D14]
4. **What is a CTE and why prefer it over nested subqueries?** → *follow-up: recursive CTE — seed and step?* [SQL D15]
5. **Write: monthly revenue in SQL / in a pipeline.** → *follow-up: the pipeline rule you never break?* [SQL D17, Mongo D19-20]
6. **How do you implement search-box filtering?** → *follow-up: why can't an index serve `LIKE '%x'`?* [SQL D8, D22]

## PostgreSQL Engine

7. **A query is slow — your diagnostic process, tool by tool.** → *follow-up: estimates vs actuals disagree — next step?* [SQL D23, PG D15-16, 24]
8. **How does the planner choose a plan?** → *follow-up: what are statistics, and what is a bad estimate's consequence?* [PG D15]
9. **Design the index for `WHERE a = ? AND b > ? ORDER BY b`.** → *follow-up: why that order? What's leftmost-prefix?* [SQL D14, PG D14]
10. **What is MVCC and what does it give you?** → *follow-up: what's bloat and why do long transactions cause it?* [PG D18, 25]
11. **Isolation levels — which anomaly did you reproduce at READ COMMITTED?** → *follow-up: how do you fix a lost update — three ways?* [PG D19]
12. **How do you find the blocked session and its blocker?** → *follow-up: how do you prevent deadlocks?* [PG D20]
13. **How do you secure a web app's database access?** → *follow-up: what's least privilege in practice — the grants and defaults?* [PG D21]

## MongoDB Engine

14. **Design the index for the same query in MongoDB.** → *follow-up: what does ESR add over the SQL rule?* [Mongo D16]
15. **$lookup vs app-side $in — when each?** → *follow-up: why is $lookup's result an array, and what always follows it?* [Mongo D22]
16. **How do you enforce "one active X per user"?** → *follow-up: in MongoDB vs in PostgreSQL — compare the tools.* [Mongo D17, PG D7]
17. **Embedding vs referencing for reviews — argue both sides.** → *follow-up: what's the hybrid and its drift duty?* [Mongo D13, 15]
18. **Replica set vs sharding — what does each solve?** → *follow-up: three properties of a good shard key?* [Mongo D25-26]

## Design & Production

19. **Normalize this orders table — walk me through it.** → *follow-up: which anomaly does each normal form kill?* [SQL D20]
20. **How would you run schema migrations on a big live table?** → *follow-up: which DDL rewrites the table? What's lock_timeout for?* [PG D26]
21. **What's your backup strategy?** → *follow-up: what does pg_dump/mongodump NOT protect — and what does?* [PG D23, Mongo D27]
22. **Pagination at depth — why does it degrade and what's the fix?** → *follow-up: write the keyset version.* [SQL D24, Mongo D8]

## How to use this bank

Attempt 3 out loud at each stage review (SQL D20, PG D22, Mongo D22+). Anything wobbly → the day's recall section the next morning.
