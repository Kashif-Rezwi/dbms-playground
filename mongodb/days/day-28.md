# Day 28 — Full Review + Mock Interview

**Track:** MongoDB · **Stage:** 7 · No new material — consolidation of all 27 days.

## Part A — Concept Check (write first, verify after)

1. Document/collection/BSON/ObjectId — and _id's rules (Days 1–2)
2. CRUD operators: insert batches, update operators + the replace trap, upserts, delete ritual (Days 3–6)
3. Query operators: comparisons, logic, null/missing matrix, $elemMatch (Days 7, 11)
4. Projection/sort/paging + cursor pagination (Day 8)
5. Array operators + positional $ (Days 9–10)
6. The modeling rule + workflow + four forces (Day 12)
7. Embed vs reference framework + the no-FK reality + hybrid (Day 13)
8. Relationship tiers + bucket pattern (Day 14) + M:N patterns + the seven named patterns (Day 15)
9. Indexes: ESR, multikey, unique/partial, TTL, explain ratios (Days 16–17)
10. Performance patterns: covered queries, regex rules, profiler (Day 18)
11. Pipelines: $match-first, $project computations, $group/HAVING positioning, $unwind behaviors, $lookup's array rule (Days 19–22)
12. Transactions: single-doc atomicity, the session template, retries, filter-carried guards (Days 23–24)
13. Replica sets: oplog, elections, write/read concerns (Day 25) + sharding: key properties, scatter-gather, one-way door (Day 26)
14. Production: working set, backups, security, "when not" (Day 27)

## Part B — Hands-On Drills (dataset: `ecommerce`, reset first)

[Beginner] **D1.** Insert a product with tags + nested specs; find by tag and by dot-notation; update via positional... (scratch doc) — the full cycle.
[Beginner] **D2.** A query combining: $in, $gte range, and an array-contains condition on products.
[Intermediate] **D3.** "One active subscription per user" — the partial unique index, from memory, with proof.
[Intermediate] **D4.** The top-3-users-by-delivered-revenue pipeline — from memory, prediction first.
[Intermediate] **D5.** Products never ordered — pipeline ($lookup + $size 0) AND app-side (ids diff); both, verified equal.
[Advanced] **D6.** A retry-wrapped session transaction: transfer + log row + abort path — from memory.
[Advanced] **D7.** The explain-ratio audit of D4's pipeline + one index improvement, with numbers.

## Part C — Mock Interview (recorded, out loud)

1. "What is a document database and when would you choose one?" → *follow-up: vs PostgreSQL for a social feed?* → *follow-up: what are the trade-offs?*
2. "How do you model one-to-many in MongoDB?" → *follow-up: what's the bucket pattern?* → *follow-up: when is embedding WRONG?*
3. "How do indexes work here — and how do you know a query uses one?" → *follow-up: ESR?* → *follow-up: what do explain ratios tell you?*
4. "Does MongoDB support transactions?" → *follow-up: what's always been atomic?* → *follow-up: when do you design around them?*
5. "How does MongoDB scale?" → *follow-up: replica set vs sharding?* → *follow-up: how would you pick a shard key?*

**Pass bar:** follow-ups, no notes. Shaky → that day's recall tomorrow morning, then the capstone.

**Next: Days 29–30 → [projects/08-capstone.md](../projects/08-capstone.md)**
