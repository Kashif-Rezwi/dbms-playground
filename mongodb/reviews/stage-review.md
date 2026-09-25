# 📋 MongoDB Stage Review — Indexes & Pipelines (Days 16–22)

Run after Day 22 (before Day 23). No notes until written.

## Part A — Concept Check

1. Indexes: types, ESR rule, leftmost prefix, multikey (Day 16)
2. Unique/partial/TTL indexes + the explain ratios (Day 17)
3. The eight performance patterns + profiler (Day 18)
4. Pipelines: $match-first, $project expressions, $count shape (Day 19)
5. $group: _id semantics, accumulators, WHERE vs HAVING positioning (Day 20)
6. $unwind: mechanics, empty-array behavior, what unlocks (Day 21)
7. $lookup: four fields, array rule, $unwind-after, indexing the join (Day 22)

## Part B — Hands-On Drills (dataset: `ecommerce`, reset)

🟢 **D1.** The partial unique "one active subscription per user" — from memory, with proof.
🟢 **D2.** Covered query: names of in-stock category-3 products — docsExamined = 0, shown.
🟡 **D3.** The ESR composite: user's pending orders sorted by date — index + explain (no SORT stage).
🟡 **D4.** Revenue per city ($lookup + $group) — prediction first.
🟡 **D5.** Units per product ($unwind + $group) — prediction first.
🔴 **D6.** The full chain: top 5 products by revenue with names (match → unwind → lookup → unwind → group → sort → limit).
🔴 **D7.** The ratio audit on D4 and D6: the three numbers each; one fix; re-measured.

## Part C — Mock Interview (recorded)

1. "How do you index a MongoDB query?" → *follow-up: ESR?* → *follow-up: how do you verify?*
2. "How do you join collections?" → *follow-up: why is the result an array?* → *follow-up: what makes $lookup fast?*
3. "Aggregate embedded array data for me — revenue by product from orders." → *follow-up: what happens to empty orders?*

**Pass bar:** follow-ups, no notes. Then: transactions (Day 23) — the replica set waits for you.
