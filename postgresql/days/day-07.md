# Day 07 — Constraint System: UNIQUE, CHECK, Defaults, Exclusion

**Track:** PostgreSQL · **Stage:** 2 — Modeling in PG · **Difficulty:** 🟡 · **Milestone:** 🏗️ Project 1

## 🎯 Goal

Master PostgreSQL's constraint toolkit — including the two you haven't met: **partial/unique indexes as constraints** and **EXCLUDE** — and know when logic belongs in the DB vs the app.

## 🧠 Fundamentals

You know NOT NULL, UNIQUE, CHECK, DEFAULT, PK, FK. Today adds the PG-grade tools:

**1. Partial unique constraint** — uniqueness *only where a condition holds*:

```sql
-- a user has at most ONE active subscription
CREATE UNIQUE INDEX one_active_sub
    ON subscriptions(user_id) WHERE status = 'active';

-- an email is unique among NON-deleted rows only
CREATE UNIQUE INDEX users_email_live
    ON users(email) WHERE deleted_at IS NULL;
```

This single feature solves "unique except soft-deleted" — a pattern apps otherwise contort themselves over.

**2. Expression constraint** — uniqueness of a *computed* value:

```sql
CREATE UNIQUE INDEX users_email_lower ON users(lower(email));   -- case-insensitive uniqueness
```

**3. EXCLUDE** — "no two rows may *overlap*" (stronger than "not equal"):

```sql
CREATE TABLE bookings (
    room INT, during TSRANGE,
    EXCLUDE USING gist (room WITH =, during WITH &&)   -- no overlapping same-room bookings
);
INSERT INTO bookings VALUES (1, '[2025-03-01, 2025-03-05)');
INSERT INTO bookings VALUES (1, '[2025-03-03, 2025-03-09)');  -- ERROR: overlaps!
```

**4. CHECK can reference the row only** (no subqueries — a CHECK is not a trigger); DEFAULT can be an *expression* (`DEFAULT now()`), not a subquery either.

**DB vs app validation — the rule:** the database enforces **invariants** ("this can never be true, no matter which app, which developer, which decade"). The app handles **UX validation** ("password too short — show a friendly message"). Never trust the app alone for invariants: multiple apps + humans with psql exist.

## 🔍 Why It Matters

Partial unique indexes quietly solve some of the most-asked modeling questions ("unique per user per active state"). And knowing what a CHECK *can't* do (no subqueries, no other rows) prevents a whole genre of confused designs.

## 💡 Mental Model

> Constraints are the **physics of your table**: UNIQUE = "two objects can't occupy the same value-slot"; partial unique = "…but only in this *region* of the table (WHERE)"; EXCLUDE = "two objects can't *overlap*" — not just collide. Physics beats etiquette (app code) because it can't be forgotten.

## 🛠️ Practice

🟢 **P1.** Build the one-active-subscription partial unique; prove: two active subs for one user fails, active + cancelled + active again succeeds.
🟢 **P2.** Build the case-insensitive email index; prove 'A@x.com' collides with 'a@x.com'. Then explain what your app's login query must now look like (`WHERE lower(email) = lower($1)` — or the expression index is useless! Day 15-16 callback).
🟡 **P3.** The TSRANGE booking table: 3 inserts — legal, overlapping-same-room (fails), overlapping-DIFFERENT-room (passes). Explain why one fails.
🟡 **P4. ⭐ Predict first:** `INSERT INTO t (email) VALUES ('a@x.com')`, again `'a@x.com'`, again `'A@X.COM'` — with the *lower(email)* index and no plain one. Which of the three fail?
🟡 **P5.** Defaults as expressions: a table with `created_at TIMESTAMPTZ DEFAULT now()` and `code TEXT DEFAULT 'TEMP-' || md5(random()::text)` — insert without those columns; verify.
🟡 **P6. From memory:** the DDL for "at most one 'featured' product per category".
🔴 **P7.** The debate, written: your team stores money transfers. Should `amount > 0` be a CHECK, an app validation, or both? And "from_account ≠ to_account"? Write 4 sentences total, then implement both.
🔴 **P8.** A constraint that *needs* another row ("salary ≤ 2× team average") — impossible as CHECK. What's the right tool (trigger — tomorrow... Day 10 — or a deferred constraint design)? Sketch both options' trade-offs in two lines.

## 🐛 Debugging

```sql
-- Bug 1: "check constraint is violated by some row" on ALTER TABLE ADD
-- CONSTRAINT — what does this error tell you about existing data, and
-- what's your remediation sequence? (find rows → decide fix → add constraint)
-- Bug 2: partial unique on (user_id) WHERE status='active' but someone
-- wants "unique across active AND pending" — the constraint silently
-- allows it. Diagnose what the WHERE clause actually scoped.
-- Bug 3: CHECK (substring(email from '@') IS NOT NULL) as email validation.
-- Two ways this accepts garbage; what's the honest fix? (regex CHECK is
-- still weak — domain-level validation discussion)
```

## 🧩 Combine Concepts

Project 1 uses all of it: build **[P1: Task Manager, the PostgreSQL Way](../projects/01-task-manager-pg.md)** — the SQL-track project rebuilt with identity columns, TIMESTAMPTZ, partial unique constraints, and constraint-driven design. Attempt before solutions.

## 🔁 Previous Knowledge

1. The four ON DELETE behaviors.
2. Which index doesn't PG auto-create on FKs?
3. SQL: why is money NUMERIC?
4. WAL — what it guarantees.

## 🧠 Recall

1. Partial unique index — the syntax and one real problem it solves.
2. What's stronger than UNIQUE for time ranges?
3. What can a CHECK never reference? (Two things.)
4. DB constraints vs app validation — the rule in one line.

## 🎤 Interview Questions

1. "How do you enforce 'one active X per user' at the database level?" *(Partial unique index — say the words.)*
2. "Why keep validation in the database if the app already validates?" *(Invariant enforcement across all writers.)*
3. "Case-insensitive uniqueness — how?" *(Expression index on lower().)*

## ✅ Completion Checklist

- [ ] Understand partial/expression constraints, EXCLUDE, defaults
- [ ] Completed P1–P8 (P4 predicted first)
- [ ] Fixed all three bugs
- [ ] Started Project 1
- [ ] Answered recall without notes
