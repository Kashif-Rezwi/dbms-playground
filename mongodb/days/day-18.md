# Day 18 — Performance Patterns → Project 5

**Track:** MongoDB · **Stage:** 5 — Indexes & Performance · **Difficulty:** Advanced · **Milestone:** Project 5

## Goal

Collect the recurring MongoDB performance patterns — the ones behind real "it's slow" tickets — and consolidate the stage in the lab.

## Fundamentals — The Pattern Catalog

**1. The covered query** — index contains everything; zero docs fetched:

```javascript
db.products.createIndex({ category_id: 1, name: 1 })
db.products.find({ category_id: 3 }, { name: 1, _id: 0 })
// explain: totalDocsExamined = 0. The index alone answered.
```

**2. Deep skip = the OFFSET disease (again):** cursor pagination, Day 08's pattern — `{ _id: { $lt: lastId } }` — MongoDB's version of keyset.

**3. Regex without a prefix kills indexes:** `/usb/` scans; `/^usb/` uses the index (same as `%x` vs `x%`).

**4. Unbounded arrays poison documents** (Day 13's write-amp) — the fix is modeling (bucket/reference), not indexes.

**5. $lookup is a join — price it like one** (Day 22): batch with $in app-side when you can, keep $lookup for true analytics.

**6. The N+1 in app code** — same disease, same cure (batch, don't loop).

**7. The read-your-write cache in docs (computed pattern)** — a summary field beats re-computation *if* something maintains it (Day 15's drift chore).

**8. Profiler, when guessing isn't allowed:**

```javascript
db.setProfilingLevel(1, { slowms: 100 })   // log queries > 100ms
db.system.profile.find().sort({ ts: -1 }).limit(5)
```

## Why It Matters

These eight cover the vast majority of real-world MongoDB slowness. And the profiler + explain ratios = your diagnostic toolkit — the exact analog of pg_stat_statements + EXPLAIN ANALYZE.

## Mental Model

> The covered query = the **catalog answers without walking to the shelf** (docs examined: 0). Regex-prefix = asking for "**all words starting with 'a'**" (index-able) vs "** all words containing 'a'**" (whole-dictionary scan). The profiler = the **security camera that only records slow shoppers** — you review footage, not the whole day.

## Examples

```javascript
// covered query check
db.products.createIndex({ category_id: 1, name: 1 })
db.products.find({ category_id: 3 }, { name: 1, _id: 0 })
  .explain('executionStats').executionStats.totalDocsExamined   // 0!

// regex, both ways
db.products.find({ name: /^Wireless/ }).explain()   // IXSCAN
db.products.find({ name: /less/ }).explain()        // COLLSCAN — felt

// profiler on
db.setProfilingLevel(1, { slowms: 100 })
// ...run slow stuff...
db.system.profile.find({}, { ns: 1, millis: 1, command: 1 }).limit(5).pretty()
db.setProfilingLevel(0)   // and off — profiles have overhead
```

## Practice

[Beginner] **P1.** Build the covered query above; verify `totalDocsExamined: 0`. Now add `_id` back to the projection — docs examined again?! ( _id needs the doc... unless excluded!) Explain why `_id: 0` matters for coverage.
[Beginner] **P2.** Regex drill: both regexes above, before/after explain.
[Intermediate] **P3.** The deep-skip numbers: `skip(10000).limit(10)` vs cursor-style on a 20k-doc scratch collection — time both; write the ratio.
[Intermediate] **P4. Predict first:** which is faster — one query returning 3 docs via perfect index, or an app loop of 3 findOne-by-id calls? Predict, then measure (the answer is about round-trips — 3× ~0.5ms network + overhead vs 1 round trip).
[Advanced] **P5.** Profiler lab: enable (slowms: 100), manufacture a slow query (COLLSCAN on 100k+ scratch docs... generate with a loop), read the profile entry, name the pattern, fix it (index), verify the profile goes quiet. The full diagnosis loop, MongoDB edition.
[Advanced] **P6.** From memory: all eight patterns + one line each on the fix.

## Debugging

```javascript
// Bug 1: "queries got slow after the last deploy" — the deploy added
// db.users.find({ email: /GMAIL.COM$/i }). What's wrong, and TWO fixes
// (normalized field + equality; or drop the regex for a $in on normalized)
// Bug 2: covered query stopped being covered after someone added a
// returned field not in the index. Which stat exposes it instantly?
// Bug 3: profile collection is growing forever. What's the maintenance
// (capped collection — research it), and when should you even run level 1?
```

## Combine Concepts → Project 5

Build **[P5: Index Performance Lab](../projects/05-index-lab.md)** — the before/after lab, MongoDB edition: profilers, ratios, covered queries, cursor pagination, a written report.

## Previous Knowledge

1. The three explain numbers + health ratio?
2. TTL contract?
3. Partial unique pattern?
4. ESR rule?

## Recall

1. What makes a query "covered" — and what usually breaks coverage?
2. Regex + indexes — the rule?
3. Deep skip's cure — in MongoDB syntax?
4. The profiler's levels and their overhead trade?

## Interview Questions

1. "A MongoDB query is slow — your diagnostic process?" *(explain ratios first, then profiler, then the pattern catalog.)*
2. "What's a covered query?" *(Index-only; docsExamined = 0.)*
3. "How do you find slow queries in production MongoDB?" *(Profiler slowms / Atlas query insights.)*

## Completion Checklist

- [ ] Understand all eight patterns + profiler + ratios
- [ ] Completed P1–P6 (P4 predicted first)
- [ ] Fixed all three bugs
- [ ] Started Project 5
- [ ] Can recite the diagnostic loop from memory
