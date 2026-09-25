# Day 15 — Many-to-Many + Modeling Patterns → Project 4

**Track:** MongoDB · **Stage:** 4 — Data Modeling · **Difficulty:** Advanced · **Milestone:** Project 4

## Goal

Model the trickiest shape — many-to-many — plus the named modeling patterns, then consolidate the whole stage in Project 4.

## Fundamentals

**Many-to-many** (students ↔ courses; products ↔ orders via items; users ↔ follows) — the document toolkit:

**1. Both sides reference (the classic)** — when the *pairs* carry no extra data:

```javascript
// follows: each user doc carries a small array of user_ids
{ _id: 7, follows: [1, 3, 9] }       // or its own follows collection
```
Scales when each side's list is bounded-ish (a user follows hundreds — fine; millions — bucket).

**2. The join collection (the relational transplant)** — when pairs carry data or lists are huge:

```javascript
// enrollments: { student_id, course_id, grade, enrolled_at }
db.enrollments.find({ student_id: 1 })
db.enrollments.find({ course_id: 2 })
// same as SQL's junction table — because the SHAPE demands it
```

**3. Hybrid denormalization** — pair data + one cached summary:

```javascript
{ _id: 'e-1', student_id: 1, course_id: 2, grade: 'A', course_title: 'SQL 101' }
// course_title is a cache — renaming the course must update enrollments (drift chore)
```

**The named patterns you now own** (know all seven by name):

| Pattern | One line |
|---|---|
| **Embedded** | bounded related data inside the doc |
| **Reference** | ids + app-side/$lookup joins |
| **Extended reference** (hybrid) | reference + denormalized snapshot fields |
| **Bucket** | split unbounded lists into page documents |
| **Computed** (pattern) | store what's expensive to compute (avg rating) |
| **Subset** | keep top-3 + count, reference the rest |
| **Schema versioning** | `schema_version: 2` field to migrate shapes over time |

## Why It Matters

M:N is where relational instinct says "junction table always" and document modeling says "depends on the read patterns". And the pattern names are the *lingua franca* of MongoDB design discussions (and interviews).

## Mental Model

> Many-to-many = **the friendship bracelet**: each side can list some friends on their wrist (two-sided reference), OR the club keeps a **sign-up sheet** (join collection) that both sides query. Pairs with extra data (grades!) *force* the sheet. The hybrid tapes a **name tag** next to each sign-up (the cached course_title) — everyone reads faster, but renaming means retagging (drift).

## Practice

[Beginner] **P1.** Design followers for the social app — choose a pattern, defend with the four forces, sketch the query "who does user 7 follow?" and "who follows user 7?" (Both directions! Which pattern answers BOTH cheaply — that's the classic gotcha.)
[Beginner] **P2.** Design enrollments-with-grades (join collection + one hybrid snapshot field). Write the drift chore.
[Intermediate] **P3.** Subset pattern, live: `products` gets `reviews_cache: { avg, count, top: [first 2] }` (in a copy of the collection) — query "product 9 with rating summary" in ONE read. Then update a review and… the cache lies. Write the two maintenance options (app-updates; scheduled recompute).
[Intermediate] **P4. Predict first:** which query gets cheap and which gets expensive with two-sided follow arrays: "A follows B?" vs "B's followers" (answer per pattern choice from P1). Then verify your design on the social dataset's real `followers` collection (it's a join-collection — compare!).
[Advanced] **P5.** Schema versioning, mini-drill: you have `users_v1` docs without `preferences`; design the v2 migration (read old docs → $set defaults → mark `schema_version: 2`) and run it on a copy. Two lines: why is in-place, lazy migration preferred over a big-bang rewrite?
[Advanced] **P6.** From memory: all seven pattern names + one line each.

## Debugging

```javascript
// Bug 1: follows stored as arrays on both sides; the app updated one side
// and forgot the other. Which pattern would have prevented it, at what
// cost? (Join collection: one write, two query directions.)
// Bug 2: reviews_cache.avg hasn't matched reality for weeks. List the
// maintenance options and pick one for "accuracy matters, traffic high".
// (Trigger-ish app hook vs scheduled recompute — say the trade.)
// Bug 3: the team embedded tags as an array (good!) but ALSO stores
// tag names in a tags collection "for integrity" that nobody reads.
// What's the honest cleanup? (Either maintain it properly with a
// write-through or delete it — ghost data is worse than no data.)
```

## Combine Concepts → Project 4

Build **[P4: Model an E-Commerce Store](../projects/04-model-ecommerce.md)** — design a fresh e-commerce document model from requirements, with the access patterns, pattern choices, and trade-offs written down. The stage's capstone.

## Previous Knowledge

1. The three 1:many tiers + modeling answers.
2. Which side holds references — and why?
3. The 5-question embed/reference framework.
4. The no-FK mitigation list?

## Recall

1. The three M:N patterns + when each wins.
2. All seven named patterns — one line each.
3. What does every hybrid/denormalization buy, and what's the standing chore?
4. Why does schema versioning exist — what problem does it solve that SQL migrations solve differently?

## Interview Questions

1. "How do you model many-to-many in MongoDB?" *(Both-sides arrays vs join collection — pairs' data decides; both query directions considered.)*
2. "Name some MongoDB design patterns and when to use them." *(Subset, bucket, extended reference, computed...)*
3. "How do you handle schema evolution in a document database?" *(Lazy migration + schema_version.)*

## Completion Checklist

- [ ] Understand M:N patterns + the seven named patterns
- [ ] Completed P1–P6 (P4 reasoned before verifying)
- [ ] Fixed all three bugs
- [ ] Started Project 4
- [ ] Can name all patterns from memory
