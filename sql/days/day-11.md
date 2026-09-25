# Day 11 — INNER JOIN: Combining Tables

**Track:** SQL · **Stage:** 3 — Relationships · **Difficulty:** Intermediate
**Prerequisites:** Days 01–10 · **Dataset:** `social`

## Goal

Understand *why* data lives in separate tables, and combine tables on their relationships with INNER JOIN.

## Fundamentals

Why not store the author's name inside every post? Because names change, users repeat, and one fact should live in **one place** (Day 20 makes this rigorous). Instead, posts carry a `user_id` — a **reference**. JOIN assembles the pieces:

```sql
SELECT posts.content, users.username
FROM posts
INNER JOIN users ON posts.user_id = users.id;
```

Read it as: *"for every pair of rows where `posts.user_id = users.id`, output one combined row."*

**Table aliases** keep this readable — every real query uses them:

```sql
SELECT p.content, u.username
FROM posts p
INNER JOIN users u ON p.user_id = u.id;
```

**What INNER means:** only *matching* rows survive. A post with a `user_id` that matches no user (shouldn't happen, thanks to foreign keys — Day 19) would vanish. Every post here has an author, so nothing is lost — but remember this for tomorrow.

**JOIN + WHERE + everything you know** — joins compose with your whole toolkit:

```sql
SELECT u.username, p.content
FROM posts p
INNER JOIN users u ON p.user_id = u.id
WHERE u.is_active AND p.likes_count >= 3
ORDER BY p.created_at DESC;
```

## Why It Matters

Relational databases are called *relational* because of this. Real data is split across dozens of tables; joining is how you rebuild one coherent view.

## Mental Model

> Two stacks of index cards — posts and users. INNER JOIN is a **stapler**: it pairs each post-card with the user-card whose ID matches, and staples them together. Unstapled pairs (no match) are discarded.

## Examples

```sql
-- every post with its author's username
SELECT p.content, u.username
FROM posts p
JOIN users u ON p.user_id = u.id;          -- INNER is the default

-- comments with commenter AND post
SELECT c.content AS comment, u.username AS commenter, p.content AS post
FROM comments c
JOIN users u ON c.user_id = u.id
JOIN posts p ON c.post_id = p.id;          -- chains! (Day 13 goes deeper)

-- likes with liker names
SELECT u.username, p.content
FROM likes l
JOIN users u ON u.id = l.user_id
JOIN posts p ON p.id = l.post_id;
```

## Practice

[Beginner] **P1.** Every post with author username, newest first.
[Beginner] **P2.** Every comment with its commenter's username.
[Beginner] **P3.** Every like: liker username + liked post content.
[Intermediate] **P4.** Posts written by users from Karachi — username, content, city in the output.
[Intermediate] **P5.** Likes on posts with at least 3 likes (join + filter on likes_count), liker + content.
[Intermediate] **P6. Predict first** — how many rows?

```sql
SELECT u.username, p.content
FROM users u
JOIN posts p ON p.user_id = u.id
WHERE u.username = 'junaid_s';
```

[Intermediate] **P7. From memory:** every message body with sender's username.
[Advanced] **P8.** Every comment on posts containing the word 'databases' (LIKE + JOIN): comment, commenter, post content.
[Advanced] **P9.** Using GROUP BY (Day 10) + JOIN: number of posts **per username**, busiest first. Write your prediction for the top username before running.

## Debugging

```sql
-- Bug 1 (wrong join column — runs fine, garbage meaning)
SELECT p.content, u.username
FROM posts p
JOIN users u ON p.id = u.id;

-- Bug 2 (ambiguous column)
SELECT user_id, username
FROM posts p
JOIN users u ON p.user_id = u.id;

-- Bug 3 (logic: meant posts BY a user, got... what?)
SELECT u.username, p.content
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE p.user_id = 1 OR u.id = 1;
```

*(Bug 2: which table owns `user_id`? Both! Qualify: `p.user_id`.)*

## Combine Concepts

Full stack: comments (with commenter username) on posts that have at least 2 likes, newest comments first, top 5. JOIN × 2 + WHERE + ORDER + LIMIT — everything from ten days in one query.

## Previous Knowledge

1. WHERE vs HAVING — one sentence each.
2. Write from memory: users per city, only cities with 2+ users.
3. What's the rule for columns in SELECT with GROUP BY?
4. Why is `SELECT name, MAX(price)` an error?

## Recall

1. What does the ON clause do, exactly?
2. Why do we alias tables?
3. What happens to rows with no match in an INNER JOIN?
4. In one sentence: why is data split across tables instead of one big table?

## Interview Questions

1. "What is a JOIN and what does ON do?"
2. "What happens to rows without a match in an INNER JOIN?"
3. "Why is storing the author's name in every post row a bad idea?" *(Preview of normalization.)*

## Completion Checklist

- [ ] Understand INNER JOIN, ON, aliases
- [ ] Completed P1–P9 (P6 and P9 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed combine task
- [ ] Answered recall without notes
- [ ] Can explain join matching out loud
