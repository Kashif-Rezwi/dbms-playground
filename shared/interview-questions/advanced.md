# Interview Questions — Advanced

> The seniority markers — trade-offs named, numbers cited, opinions owned. These are also the mock-interview spines of the capstones.

## Performance — with numbers

1. **"I added an index and the query didn't speed up." Hypotheses, ranked.** → *follow-up: when is a Seq Scan CORRECT?* → *follow-up: how do stale statistics mimic a missing index?* [PG D15-17, Mongo D17-18]
2. **Your slow-query process, tool by tool, both engines.** → *follow-up: what do BUFFERS/ratios reveal that timings alone don't?* [PG D16, Mongo D18]
3. **When is an index the WRONG solution?** → *follow-up: what do you do for full-aggregation reports?* [PG D17, Mongo D18, 20]
4. **Design the write path for 10k inserts/sec.** → *follow-up: how do you measure the index tax, and when do you accept it?* [SQL D22, PG D24, Mongo D16]

## Concurrency & Correctness

5. **A sold-out ticket was double-sold — walk me through the failure modes and defenses.** → *follow-up: atomic arithmetic vs FOR UPDATE vs SERIALIZABLE — when each?* → *follow-up: what does the app still owe (retries)?* [PG D19-20, Mongo D23-24]
6. **Isolation anomalies — which have you REPRODUCED, at which level?** → *follow-up: write skew — why doesn't REPEATABLE READ stop it?* [PG D19]
7. **What guarantees does MongoDB give cross-document, and how do you design to need fewer transactions?** → *follow-up: the single-doc atomicity argument.* [Mongo D23-24]

## Architecture & Judgment

8. **When do you shard, and what's the one-way door?** → *follow-up: how do you pick the key? What's scatter-gather?* [Mongo D26, PG D28]
9. **The scaling ladder — run through it for a slow-growing app.** → *follow-up: why is sharding last in BOTH ecosystems?* [PG D28, Mongo D26]
10. **"Should this be PostgreSQL or MongoDB?" — answer for a bank ledger, a CMS, an IoT pipeline.** → *follow-up: what question do you ask FIRST (access patterns + invariants)?* [Mongo D27, SQL D26]
11. **How do you enforce multi-tenant isolation?** → *follow-up: RLS's bypass traps? The MongoDB story without RLS?* [PG D22, Mongo D21+]
12. **Schema evolution without downtime — both ecosystems.** → *follow-up: schema_version lazy migration vs forward-only migrations.* [Mongo D15, PG D26]

## The capstone-grade questions (multi-minute, whiteboard)

13. **Design the ticket-booking database (either engine) end to end: schema, double-sell defense, hot indexes, the transaction, the failure demos.** [SQL/PG capstones]
14. **Design FitTrack (MongoDB): access patterns → patterns → transactions audit → production memo.** [Mongo capstone]
15. **"What's the weakest part of your design, and what would you do with one more day?"** — the honesty question. Practice a genuine answer; interviewers can smell fake humility.

## How to use this bank

- These are the recorded-mock-interview questions for SQL D28, PG D29, and Mongo D28.
- The bar: you can draw it, defend it, name the numbers, and admit the weak spot.
