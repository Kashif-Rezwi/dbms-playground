# Day 20 — Locks & Deadlocks

**Track:** PostgreSQL · **Stage:** 5 — Transactions & Concurrency · **Difficulty:** Advanced · **Milestone:** Project 4

## Goal

Understand the lock table — row locks, table locks, deadlocks — and diagnose a blocked session like an operator.

## Fundamentals

**Under MVCC, plain reads never lock. What locks:**

- **Row locks** — `UPDATE`, `DELETE`, and explicit `SELECT ... FOR UPDATE/FOR NO KEY UPDATE` claim the row; a *second writer* to the same row **waits**
- **Table locks** — DDL (`ALTER TABLE`), bulk loads, `LOCK TABLE` — levels from `ACCESS SHARE` to `ACCESS EXCLUSIVE` (everything vs everything)
- **Advisory locks** — app-level named locks (`pg_advisory_lock(42)`) — "only one migration runs at a time"

**Waiting is normal; waiting forever is a problem.** `lock_timeout` bounds it:

```sql
SET lock_timeout = '3s';   -- then errors instead of hanging forever
```

**Deadlock** — S1 holds row A, wants row B; S2 holds B, wants A. Neither moves. PostgreSQL *detects* it, kills one transaction with `ERROR: deadlock detected`, and the app must **retry** the killed one. Prevention = consistent ordering:

```sql
-- always: lock rows in the same order (e.g. ORDER BY id) or lowest-id-first
SELECT * FROM accounts WHERE id IN (1,2) ORDER BY id FOR UPDATE;
```

**The operator's view — the blocked-session drill:**

```sql
-- in S2 (blocked), from ANY session:
SELECT pid, wait_event_type, wait_event, state, query
FROM pg_stat_activity WHERE wait_event_type = 'Lock';

SELECT pg_blocking_pids(<blocked_pid>);       -- WHO is blocking
SELECT locktype, relation::regclass, mode, granted FROM pg_locks
WHERE pid = <blocked_pid>;

SELECT pg_terminate_backend(<blocker_pid>);  -- the hammer (last resort)
```

## Why It Matters

"Everything is slow" incidents are usually a blocked queue behind one transaction. Knowing `pg_stat_activity → pg_blocking_pids → fix or kill` is the actual on-call skill.

## Mental Model

> Row locks are **stall doors in a corridor** (one writer per stall). MVCC means *walkers* (readers) never queue. Deadlock = two people each holding a door, each waiting for the other's — the manager (deadlock detector) picks a victim and walks one out (rollback). Consistent ordering = everyone always claims stalls left-to-right, so no cycle can form.

## Practice

[Beginner] **P1.** S1: `BEGIN; UPDATE users SET city='X' WHERE id=1;` (hold) — S2: `UPDATE users SET city='Y' WHERE id=1;` → **blocked**. In a third session, run the `pg_stat_activity` query; find the blocked PID and `pg_blocking_pids`. Commit S1; watch S2 finish.
[Beginner] **P2.** Same setup, but S2 first runs `SET lock_timeout='2s';` — error instead of hang. When is a short timeout the right call? (UX paths, migrations.)
[Intermediate] **P3.** **Reproduce a real deadlock:** S1 locks user 1 then user 2; S2 locks user 2 then user 1 (stagger the seconds — run one statement at a time per session). One session gets `deadlock detected`. Identify the victim and explain why the app must retry it.
[Intermediate] **P4.** **Prevention:** redo the same interleaving with both sessions doing `SELECT ... ORDER BY id FOR UPDATE` first — no deadlock. One line: why did ordering kill the cycle?
[Intermediate] **P5. Predict first:** S1 holds a row lock on user 1 (uncommitted UPDATE). S2 runs (a) plain `SELECT * FROM users WHERE id=1;` (b) `UPDATE ... WHERE id=1` (c) `ALTER TABLE users ADD COLUMN x int;`. Which block, which don't? Verify all three.
[Intermediate] **P6. From memory:** the diagnostic query sequence for a blocked session (activity → blocker → locks).
[Advanced] **P7.** Advisory lock taste: `SELECT pg_advisory_lock(99);` in S1; S2 same call → blocks; S1 `pg_advisory_unlock_all();` — S2 proceeds. One use case in two lines (e.g., single-flight cron jobs — `pg_try_advisory_lock` returning false = "another worker has it").
[Advanced] **P8.** The DDL freeze: S1 `BEGIN; SELECT * FROM users FOR UPDATE;` (hold rows) — S2 `ALTER TABLE users ...` → blocked. Why do DDL and row locks conflict at the *table* level? What does this mean for migrations on live systems? (Day 26 preview: keep transactions short; run migrations with lock_timeout.)

## Debugging — The Incident Drill

```sql
-- Incident: "app hangs entirely." Your runbook, in order:
-- 1. pg_stat_activity: how many Lock waiters? one blocker or many?
-- 2. pg_blocking_pids per waiter — the common root?
-- 3. The blocker's query in pg_stat_activity — what is it waiting on?
--    (idle in transaction? another lock? a human's open psql?)
-- 4. Decision: wait it out, kill the blocker, or fix the code ordering.
-- Practice the whole runbook on the P1 setup.
```

## Combine Concepts

**[P4: Bank Transfer, Concurrency Edition](../projects/04-bank-concurrency.md)** — your SQL-track P5 rebuilt with: atomic arithmetic, `FOR UPDATE` with ordering, a reproduced deadlock and its fix, SERIALIZABLE-with-retry for one path, and the incident runbook applied. Two-session work; attempt before solutions.

## Previous Knowledge

1. Which four anomalies did you reproduce at which levels?
2. What must an app do with a retryable error?
3. MVCC — why don't plain readers lock?
4. What does REPEATABLE READ's snapshot fix?

## Recall

1. Which operations take row locks? Which never do?
2. How does PostgreSQL resolve a deadlock, and who retries?
3. The deadlock-prevention habit in one line.
4. Your 4-step blocked-session runbook.

## Interview Questions

1. "A query hangs in production — walk me through your diagnosis." *(pg_stat_activity → blocking_pids → root → fix/kill.)*
2. "How do you prevent deadlocks?" *(Consistent lock ordering; keep transactions short; retry logic.)*
3. "What's an advisory lock and when is it the right tool?"

## Completion Checklist

- [ ] Understand row/table/advisory locks, deadlock detection, runbook
- [ ] Reproduced a deadlock AND prevented it with ordering
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Practiced the incident runbook
- [ ] Started Project 4
