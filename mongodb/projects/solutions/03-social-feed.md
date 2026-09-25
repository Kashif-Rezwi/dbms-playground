# Solutions — P3: Social Feed Queries

> Counts verified against the seed file — predict yours BEFORE comparing!

```javascript
// 1. feed preview projection
db.posts.find({ user_id: 7 }, { _id: 0, user_id: 1, likes_count: 1, created_at: 1 })
        .sort({ created_at: -1 })

// 2. both directions from one join-collection:
db.followers.find({ followed_id: 1 })   // who follows user 1 (5 people)
db.followers.find({ follower_id: 1 })   // who user 1 follows (3 people)
// Advantage: both directions are single-index queries — no dual-array drift.

// 3. comments + commenters, app-side $in batch (2 round trips, not N)
const c = db.comments.find({ post_id: 5 }).toArray()
const names = {}
db.users.find({ _id: { $in: c.map(x => x.user_id) } }, { username: 1 })
        .forEach(u => names[u._id] = u.username)
c.forEach(x => print(x.content, '—', names[x.user_id]))

// 4. unread → mark read
db.messages.find({ is_read: false })     // preview (1 message)
db.messages.updateMany({ is_read: false }, { $set: { is_read: true } })
db.messages.countDocuments({ is_read: false })   // 0

// 5. the $elemMatch difference (after adding reactions):
// WRONG (dotted): post with (user 2, 'like') among ANY two reactions... in
//   our data the pair actually lands on separate elements to demo it:
db.posts.find({ 'reactions.user_id': 2, 'reactions.type': 'like' })
// RIGHT (same element):
db.posts.find({ reactions: { $elemMatch: { user_id: 2, type: 'like' } } })
// Craft your seeded data so a post has (user 2, 'haha') and (user 9, 'like')
// — dotted matches it, $elemMatch correctly doesn't!

// 6. the matrix: 10 users; bio exists: 10; bio non-null: 9 (dua_m's is null)
db.users.countDocuments({ bio: { $exists: true } })         // 10
db.users.countDocuments({ bio: { $exists: true, $ne: null } })  // 9
db.users.countDocuments({ bio: null })   // 1 (matches null AND missing → careful!)
db.users.countDocuments({ bio: { $exists: false } })  // 0

// 7. most likes: user 3 — 3 likes (posts 1, 5, 9)
db.likes.find({ user_id: 3 }).count()

// 8. shape audit: all 15 posts have likes_count:
db.posts.countDocuments({ likes_count: { $exists: true } })   // 15
db.users.countDocuments({ joined_at: { $type: 'date' } })     // 10 — types honest

// 9. timeline (2-step): user 1's followees:
db.followers.find({ follower_id: 1 }).map(f => f.followed_id)  // [2, 3, 5]
db.posts.find({ user_id: { $in: [2, 3, 5] } }).sort({ created_at: -1 }).limit(5)
// predict the count first: posts by 2 (3), 3 (2), 5 (1) = 6 → top 5

// 10. unedited + popular:
db.posts.find({ edited: { $exists: false }, likes_count: { $gte: 2 } })
// $ne: true would ALSO match... nothing extra here since the field is absent
// on all non-edited posts — absent matches $ne. The safe "not edited" form
// is $exists:false when the field is ABSENT by convention; $ne when it's
// present-but-false. Say the convention you picked!

// 11. denormalize author_username (the drift chore: username changes must
// update posts too):
db.users.find().forEach(u => db.posts.updateMany({ user_id: u._id },
  { $set: { author_username: u.username } }))
db.posts.find({}, { author_username: 1, content: 1 }).limit(3)
```
