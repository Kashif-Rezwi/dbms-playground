# 🎤 Mini Interview Checks — Stage Simulation Scripts

> The 5-minute end-of-stage simulations (spec §29). Do these OUT LOUD — a friend, a recorder, a duck. Difficulty climbs by design.

## Check 1 — After SQL Stage 1–2 (Day 10)

```text
Interviewer: What's the difference between WHERE and HAVING?
You:        [2 sentences with the filter-order]
Follow-up:  Write "cities with more than 2 active users."
Follow-up:  Why does COUNT(*) lie after a LEFT JOIN?
```

## Check 2 — After SQL Stage 3 (Day 15)

```text
Interviewer: How do you find users who never ordered?
You:        [the LEFT JOIN + IS NULL pattern — say it precisely]
Follow-up:  Why is NOT IN risky here?
Follow-up:  Now do it with a CTE — why would you?
```

## Check 3 — After SQL Stage 5 (Day 24)

```text
Interviewer: What is an index? Why does it speed up reads?
You:        [structure + no-full-scan]
Follow-up:  Can an index ever HURT performance?
Follow-up:  You added one and the query didn't improve — your next three checks?
Follow-up:  How would you investigate a slow query? [the 5 steps, by name]
```

## Check 4 — After PostgreSQL Stage 4 (Day 17)

```text
Interviewer: How does the planner pick between plans?
You:        [cost model + statistics]
Follow-up:  What happens when the statistics lie?
Follow-up:  Design the index for "this user's orders, newest first."
```

## Check 5 — After PostgreSQL Stage 5 (Day 20)

```text
Interviewer: Two users update the same balance at once — what can go wrong?
You:        [lost update, reproduced from experience]
Follow-up:  Three fixes, strongest first?
Follow-up:  What does SERIALIZABLE change, and what does the app now owe?
```

## Check 6 — After MongoDB Stage 4 (Day 15)

```text
Interviewer: How would you model reviews for products?
You:        [unbounded → reference + the hybrid cache]
Follow-up:  What's the drift duty of your design?
Follow-up:  Which of the seven patterns did you use?
```

## Check 7 — After MongoDB Stage 6 (Day 22)

```text
Interviewer: How do you join collections in MongoDB?
You:        [$lookup + $unwind-after]
Follow-up:  Why is the result always an array?
Follow-up:  When is app-side $in better?
```

## The Final Checks — Capstone Defenses

SQL (Day 28-30): schema defense → concurrency defense → performance-with-numbers → **"the weakest part."**
PostgreSQL (Day 29-30): same spine, plus the ops runbook walkthrough.
MongoDB (Day 28-30): same spine, plus the honest "should this be MongoDB?" paragraph.

**Grade yourself per check:** follow-ups survive without notes = pass. Anything else → the day's recall tomorrow morning.
