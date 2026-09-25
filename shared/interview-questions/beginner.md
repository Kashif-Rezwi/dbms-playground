# 🎤 Interview Questions — Beginner

> Not memorization prompts — understanding tests. After each, the *follow-ups* are the real interview. If you can answer those without notes, you own it. All are covered by the tracks — day references in brackets.

## Concepts & Terms

1. **What is a database? A DBMS? Why not just files?** → *follow-up: what does a DBMS guarantee that a JSON file can't?* [SQL D1]
2. **What is a table / row / column? A document / collection?** → *follow-up: which is more rigid, and what's the cost of each?* [SQL D1, Mongo D1-2]
3. **What's the difference between SQL and PostgreSQL?** → *follow-up: is NoSQL a language?* [PG D1, Mongo D1]
4. **What is a primary key? What makes a good one?** → *follow-up: surrogate vs natural keys?* [SQL D19, PG D5]
5. **What is a foreign key and what does it enforce?** → *follow-up: what are the ON DELETE options?* [SQL D19, PG D6]

## SQL Fundamentals

6. **Write: users older than 25, alphabetical, top 10.** → *follow-up: what's the clause execution order?* [SQL D2-4]
7. **What does WHERE do vs HAVING?** → *follow-up: write "cities with 5+ users".* [SQL D10]
8. **What is NULL and how is it different from 0 or ''?** → *follow-up: why does `= NULL` return nothing? What does COUNT(col) skip?* [SQL D3, 7, 9]
9. **INNER vs LEFT JOIN — concrete example.** → *follow-up: how do you find users with no orders?* [SQL D11-12]
10. **What is an index, in plain words?** → *follow-up: why does it speed reads? What does it cost?* [SQL D22]
11. **What is a transaction, with a real example?** → *follow-up: what does ROLLBACK undo?* [SQL D21]
12. **Explain ACID with a story for each letter.** [SQL D21]

## MongoDB Fundamentals

13. **What is a document database? When would you choose one?** → *follow-up: give a case where you wouldn't.* [Mongo D1, 27]
14. **What's an ObjectId and what does it secretly give you?** → *follow-up: why are there gaps in sequences?* [Mongo D2, SQL D5]
15. **How do you update a document safely?** → *follow-up: what happens without $set? What's an upsert?* [Mongo D5]
16. **How do you query fields inside arrays or nested objects?** → *follow-up: the difference between dotted conditions and $elemMatch?* [Mongo D4, 10-11]
17. **Does MongoDB have transactions?** → *follow-up: what was always atomic, even before?* [Mongo D23]

## Design & Judgment (the beginner tier's stretch)

18. **What is normalization and why do we do it?** → *follow-up: name one anomaly with an example.* [SQL D20]
19. **When would you denormalize?** → *follow-up: what's the standing cost?* [SQL D26, Mongo D13]
20. **"We have replicas, so we don't need backups." What's wrong?** → *follow-up: what does a backup protect that replication can't?* [PG D27, Mongo D25]

## How to use this bank

- Every ~5 stage days, answer 3 of these out loud — no notes.
- The day-level questions in each lesson are the spaced-repetition layer; this bank is the consolidation layer.
- Grading: you pass when the *follow-up* survives.
