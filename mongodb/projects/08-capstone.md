# 🏗️ MongoDB Capstone — "FitTrack" (Days 29–30)

**Difficulty:** 🔴 · Design decisions are the deliverable — no solution exists.

## Objective

Independently design and build a fitness-tracking app's MongoDB backend: access-pattern-driven schema, validators, indexes, transactions only where earned, and a production memo — all defensible in a recorded interview.

## The Product

Users track workouts and meals; follow friends; see feeds; premium subscriptions; coaches review clients' progress.

**Core needs:** workout logging (with per-exercise sets: [{exercise, weight, reps}]), meal logging, friend follows, a feed of friends' activities, personal streaks/stats, coach↔client relationships, subscription states.

## Part 1 — Design (Day 29 morning)

1. **Access patterns, ranked (~8)** — the screens/queries, by frequency
2. **Collections + shapes** — every relationship tiered (1:1/1:few/1:many/M:N) with embed/reference/bucket/hybrid + one-line defenses
3. **Three+ named patterns used and labeled** (subset? computed? bucket? schema versioning?)
4. **Shape contract**: validators on 2+ collections; the shape-audit queries
5. **Integrity plan**: your no-FK checks (what cleans ghost references?)

## Part 2 — Build (Day 29 afternoon/evening)

6. Collections + validators + seed data: 6 users, 3 coaches, ~30 workouts (realistic sets arrays!), follows, subscriptions
7. The **top-5 reads as one-query flows** (or honest 2-step app-side where referenced)
8. **Indexes**: ESR-reasoned, ≤5, explain-ratio-verified

## Part 3 — Behaviors (Day 30 morning)

9. **Log-workout flow** (embed payoff: one insert) + **follow flow** (the M:N choice) + **the streak counter** (computed vs stored — you decide, you defend)
10. **The transaction audit**: exactly where multi-doc invariants exist (subscription upgrade + log row?) — implement ONE with the retry template; label every other flow "single-doc atomic by design"
11. **The pipeline battery**: friends' recent workouts (feed), per-user streaks, most-logged exercise, coach's client summary — predictions first

## Part 4 — Production (Day 30 afternoon)

12. The **production memo**: replica set, write concerns (which writes get majority — defend), backups (snapshots vs dumps — sizing), working-set math at 100k users, security (roles), and **the honest paragraph**: is MongoDB right for FitTrack — argue from your own grand comparison table
13. The **sharding hypothetical**: at 50M users, which collection shards first, on what key, with what cross-shard casualty?

## Part 5 — Defense (Day 30 evening, recorded)

14. "Walk me through your schema and the access patterns behind it."
15. "Show me one embed and one reference choice — defend both."
16. "Where did you need a transaction — and where did design make one unnecessary?"
17. "What's the weakest part of your design, and what would you do with one more day?"

## Rules

- Every design decision: one-line justification in the files
- Every count: predicted first
- Reuse your Day 12–27 artifacts (manifesto, index plans, comparison table)

**Done = all three tracks complete. Fill in `PROGRESS.md` honestly — and start the cross-database exercises in `shared/cross-database/` if you haven't.**
