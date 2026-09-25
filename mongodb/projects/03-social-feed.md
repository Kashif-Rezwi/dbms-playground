# 🏗️ P3 — Social Feed Queries

**Milestone:** Mongo Days 9–11 · **Time:** ~75 min · **Dataset:** `social` (reset first)

## Objective

Over the social dataset: nested data, arrays, $elemMatch, shape audits — Stage 3's consolidation. Predict before every count.

## Required Queries

1. Posts by user_id 7, newest first — with a **projection that hides content** (feed preview: user_id, likes_count, created_at only)
2. The follow graph: who follows user 1? Who does user 1 follow? (The followers collection serves both directions — say why that's the join-collection advantage.)
3. Comments on post 5, with commenter usernames — the app-side $in batch: fetch comments, collect user_ids, one `find({_id: {$in}})`. (A $lookup would work too — Day 22's preview; do it app-side today and note what's coming.)
4. Unread messages (is_read false) — then mark them all read (updateMany + verify)
5. The $elemMatch case: messages... our data's arrays are flat. Create one: add a `reactions: [{ user_id, type }]` array to three posts (one gets TWO reactions from the same user with different types). Now: posts where ONE reaction is (user 2, 'like') — both the dotted-pair version (wrong!) and $elemMatch (right). Verify they differ!
6. $exists/$type audit on users: who has a bio field? Who has bio non-null? (The matrix — write all four numbers.)
7. Likes-per-user: count the likes collection by user (app-side group... or just run the three $match counts) — who liked the most posts? Predict first.
8. **The shape audit**: for posts — do all 15 have likes_count? `countDocuments({likes_count: {$exists: true}})` — and any anomalies with $type across users' bio?

## Challenge ⭐

9. The "timeline" build: user 1's feed = posts from users 1 follows (4 users), newest first, top 5 — write the 2-query flow (followers → posts with $in), predict the count first
10. Add `edited: true` to one post; write the query for "unedited posts with ≥ 2 likes" — $exists:false (the safe "not edited" form — say why `$ne: true` also catches... what?)

## Bonus 🔴

11. The denormalization taste: add `author_username` to each post (batch updateMany from users — loop or $lookup-free JS). Now the feed is ONE collection read. Write the drift chore and when this trade wins.

> ✅ [solutions/03-social-feed.md](solutions/03-social-feed.md)
