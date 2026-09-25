# Day 13 — SELF JOIN + Multi-Table Chains

**Track:** SQL · **Stage:** 3 — Relationships · **Difficulty:** 🟡 Intermediate
**Prerequisites:** Days 11–12 · **Dataset:** `social`

## 🎯 Goal

Join a table to itself (aliases become mandatory) and chain three+ tables through a relationship path.

## 🧠 Fundamentals

**SELF JOIN** — a table joined to itself. To do that, it must appear **twice under two aliases**, acting as two "copies":

```sql
-- who follows whom? both sides are users!
SELECT follower.username AS follower, followed.username AS follows
FROM followers f
JOIN users follower ON follower.id = f.follower_id
JOIN users followed  ON followed.id  = f.followed_id;
```

`users` appears twice — once as `follower`, once as `followed`. Without aliases this is impossible to write.

Another self-join flavor (no junction table): a table whose column points at *its own* rows — `employees.manager_id → employees.id`. The dataset doesn't have one; we'll build a tiny one:

```sql
CREATE TABLE employees (
    id INT PRIMARY KEY, name TEXT, manager_id INT REFERENCES employees(id)
);
INSERT INTO employees VALUES
    (1, 'CEO', NULL), (2, 'Ali', 1), (3, 'Sara', 1), (4, 'Bilal', 2), (5, 'Dua', 3);
```

**Multi-table chains** — follow the foreign keys through the ER diagram:

```text
users → posts → comments          (whose comment on whose post?)
users → orders → order_items → products    (full order detail)
```

Each hop is one JOIN. Read joins aloud as sentences: *"join comments to users on commenter; join comments to posts on post."*

## 🔍 Why It Matters

Org charts, followers, threads, family trees — self-references are everywhere. And real questions almost never need one join; they need a *path* through 3–4 tables.

## 💡 Mental Model

> A self join is using the **same book twice** — open on the "followers" page and again on the "followed" page. Multi-table chains are following **red thread** from table to table: each JOIN holds one thread; follow three threads and you've connected a comment back to a city.

## 💻 Examples

```sql
-- follower graph with usernames
SELECT follower.username AS fan, followed.username AS idol
FROM followers f
JOIN users follower ON follower.id = f.follower_id
JOIN users followed ON followed.id = f.followed_id
ORDER BY fan;

-- employee → manager (self join on employees)
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON m.id = e.manager_id;   -- LEFT: the CEO has no manager

-- 3-table chain: message sender → receiver (users twice!)
SELECT s.username AS sender, r.username AS receiver, m.body
FROM messages m
JOIN users s ON s.id = m.sender_id
JOIN users r ON r.id = m.receiver_id;
```

## 🛠️ Practice

🟢 **P1.** Follower graph with usernames, like the example (type it yourself).
🟢 **P2.** Employee → manager names. Who has NULL manager? (Why LEFT JOIN?)
🟢 **P3.** Message sender + receiver usernames + body (users twice).
🟡 **P4.** Comments: commenter username + post content + comment text — the full 3-table chain.
🟡 **P5.** Followers of 'ayesha_k' specifically — their usernames.
🟡 **P6. ⭐ Predict first** — how many rows, and does the CEO appear?

```sql
SELECT e.name, m.name AS manager
FROM employees e
INNER JOIN employees m ON m.id = e.manager_id;
```

🟡 **P7. From memory:** posts per city — post content + author city (2 tables, GROUP BY).
🔴 **P8.** Pairs of users who follow the **same person** — without duplicates of the same pair. (Self-join followers against itself: `followers f1 JOIN followers f2 ON f1.followed_id = f2.followed_id AND f1.follower_id < f2.follower_id`.) Predict one such pair first.
🔴 **P9.** Comments on posts liked by 'junaid_s' — comment text + post content. (3 tables + likes chain.)

## 🐛 Debugging

```sql
-- Bug 1: self-join without aliases — what error?
SELECT username, username FROM users JOIN followers ON users.id = users.id;

-- Bug 2 (logical): employee pairs look wrong. What got mixed up?
SELECT m.name AS employee, e.name AS manager
FROM employees e
JOIN employees m ON e.id = m.manager_id;

-- Bug 3 (chain broken mid-way): what's this actually joining?
SELECT c.content, u.username
FROM comments c
JOIN users u ON c.user_id = u.id
JOIN posts p ON p.id = c.post_id
WHERE u.username = 'ayesha_k';
-- Intent was "comments BY ayesha_k" — but it returns comments on HER posts only. Diagnose ON vs WHERE here.
```

## 🧩 Combine Concepts

The influence report: **username, their total post count, and their follower count** — for users with at least 1 follower. (Two LEFT JOINs + two COUNT(o.id)s... or two separate GROUP BYs... tricky! Do it as: LEFT JOIN posts + GROUP BY for post count; LEFT JOIN followers + GROUP BY for follower count. Two queries side-by-side is honest work today; Day 15's CTEs will let you glue them.)

## 🔁 Previous Knowledge

1. The "never ordered" pattern — write it from memory.
2. Why `COUNT(*)` lies in LEFT JOIN counts?
3. What does GROUP BY's boxes metaphor mean?
4. What is the join order with WHERE — which happens first?

## 🧠 Recall

1. Why are aliases *mandatory* in a self join?
2. What does the `<` trick in P8 accomplish?
3. How many JOINs does a 4-table chain need?
4. Why LEFT JOIN for employee→manager?

## 🎤 Interview Questions

1. "How do you model and query a follow/like relationship?"
2. "How would you find each employee's manager?" *(Self join, LEFT for the top boss.)*
3. "What's a junction table and why does many-to-many need one?" *(followers/likes — talk about it with today's experience.)*

## ✅ Completion Checklist

- [ ] Understand self joins, aliases, chains
- [ ] Completed P1–P9 (P6 and P8 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed combine task (two queries acceptable)
- [ ] Answered recall without notes
- [ ] Can explain self joins out loud
