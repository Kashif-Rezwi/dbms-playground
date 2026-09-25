// ============================================================
// SOCIAL dataset (small) — MongoDB seed
// Load:  ./scripts/seed/seed-mongo.sh social
// Collections: users, posts, comments, likes, followers, messages
// ============================================================

db = db.getSiblingDB('social');
db.dropDatabase();

db.users.insertMany([
  { _id: 1, username: 'ayesha_k', email: 'ayesha@social.dev', bio: 'Backend dev. Coffee first.', joined_at: ISODate('2024-01-10') },
  { _id: 2, username: 'bilal_a',  email: 'bilal@social.dev',  bio: 'Runner. Occasional poet.',     joined_at: ISODate('2024-01-22') },
  { _id: 3, username: 'chen_w',   email: 'chen@social.dev',   bio: 'Data engineer.',               joined_at: ISODate('2024-02-14') },
  { _id: 4, username: 'dua_m',    email: 'dua@social.dev',    bio: null,                           joined_at: ISODate('2024-03-01') },
  { _id: 5, username: 'emre_y',   email: 'emre@social.dev',   bio: 'Photographer & cyclist.',      joined_at: ISODate('2024-03-19') },
  { _id: 6, username: 'farah_a',  email: 'farah@social.dev',  bio: 'UI designer.',                 joined_at: ISODate('2024-04-05') },
  { _id: 7, username: 'grace_o',  email: 'grace@social.dev',  bio: 'Community builder.',           joined_at: ISODate('2024-04-28') },
  { _id: 8, username: 'hassan_r', email: 'hassan@social.dev', bio: 'Lurker.',                       joined_at: ISODate('2024-05-15') },
  { _id: 9, username: 'ivy_s',    email: 'ivy@social.dev',    bio: 'Travel + tech.',                joined_at: ISODate('2024-06-02') },
  { _id: 10, username: 'junaid_s', email: 'junaid@social.dev', bio: 'Learning databases.',          joined_at: ISODate('2024-06-30') }
]);

db.posts.insertMany([
  { _id: 1,  user_id: 1, content: 'Finally shipped my first API. Two months of learning SQL paid off.', created_at: ISODate('2025-01-05'), likes_count: 3 },
  { _id: 2,  user_id: 3, content: 'ETL job ran in 40 minutes today. Yesterday: 4 hours. Indexes are magic.', created_at: ISODate('2025-01-07'), likes_count: 2 },
  { _id: 3,  user_id: 2, content: 'Ran 10km this morning before work.', created_at: ISODate('2025-01-10'), likes_count: 1 },
  { _id: 4,  user_id: 6, content: 'Redesigned our dashboard. Feedback welcome.', created_at: ISODate('2025-01-12'), likes_count: 1 },
  { _id: 5,  user_id: 7, content: 'Hosting a free databases study group this weekend.', created_at: ISODate('2025-01-15'), likes_count: 4 },
  { _id: 6,  user_id: 1, content: 'Reminder: normalize until it hurts, then stop.', created_at: ISODate('2025-01-18'), likes_count: 1 },
  { _id: 7,  user_id: 9, content: 'Flight to Seoul booked. Any dev meetups in March?', created_at: ISODate('2025-01-20'), likes_count: 0 },
  { _id: 8,  user_id: 5, content: 'Golden hour on the coast. No filter needed.', created_at: ISODate('2025-01-22'), likes_count: 1 },
  { _id: 9,  user_id: 10, content: 'Day 1 of #30DaysOfDatabases. Today: what even is a table?', created_at: ISODate('2025-01-25'), likes_count: 2 },
  { _id: 10, user_id: 3, content: 'Correlated subqueries finally clicked for me.', created_at: ISODate('2025-02-02'), likes_count: 0 },
  { _id: 11, user_id: 2, content: 'Poem draft #14: about NULL. It equals nothing, not even itself.', created_at: ISODate('2025-02-08'), likes_count: 0 },
  { _id: 12, user_id: 7, content: 'Study group recap thread: 42 people showed up.', created_at: ISODate('2025-02-10'), likes_count: 0 },
  { _id: 13, user_id: 1, content: 'Postgres EXPLAIN ANALYZE is my new favorite debugging tool.', created_at: ISODate('2025-02-15'), likes_count: 1 },
  { _id: 14, user_id: 6, content: 'Dark mode is not a personality trait. Or is it?', created_at: ISODate('2025-02-18'), likes_count: 0 },
]);

db.comments.insertMany([
  { _id: 1, post_id: 1, user_id: 2, content: 'Congrats! What stack?', created_at: ISODate('2025-01-05') },
  { _id: 2, post_id: 1, user_id: 6, content: 'Well deserved.', created_at: ISODate('2025-01-05') },
  { _id: 3, post_id: 2, user_id: 1, content: 'Which index did you add?', created_at: ISODate('2025-01-07') },
  { _id: 4, post_id: 2, user_id: 10, content: 'Saving this as motivation.', created_at: ISODate('2025-01-08') },
  { _id: 5, post_id: 3, user_id: 7, content: 'Beast mode.', created_at: ISODate('2025-01-10') },
  { _id: 6, post_id: 4, user_id: 1, content: 'The spacing is so clean now.', created_at: ISODate('2025-01-12') },
  { _id: 7, post_id: 4, user_id: 5, content: 'The charts finally make sense.', created_at: ISODate('2025-01-13') },
  { _id: 8, post_id: 5, user_id: 10, content: 'Joined! Beginner here.', created_at: ISODate('2025-01-15') },
  { _id: 9, post_id: 5, user_id: 3, content: 'Will share my aggregation notes.', created_at: ISODate('2025-01-16') },
  { _id: 10, post_id: 6, user_id: 9, content: 'Stealing this line for my README.', created_at: ISODate('2025-01-18') },
  { _id: 11, post_id: 7, user_id: 5, content: 'Seoul DevFest is in March!', created_at: ISODate('2025-01-20') },
  { _id: 12, post_id: 8, user_id: 2, content: 'Stunning shot.', created_at: ISODate('2025-01-22') },
  { _id: 13, post_id: 9, user_id: 1, content: 'A table is a very strict spreadsheet. Day 1 is easy.', created_at: ISODate('2025-01-25') },
  { _id: 14, post_id: 9, user_id: 7, content: 'Welcome aboard — do the debugging exercises, they teach the most.', created_at: ISODate('2025-01-26') },
  { _id: 15, post_id: 11, user_id: 10, content: 'A poem about NULL. We are the same.', created_at: ISODate('2025-02-08') },
  { _id: 16, post_id: 12, user_id: 1, content: 'The $lookup demo was the highlight.', created_at: ISODate('2025-02-10') },
  { _id: 17, post_id: 13, user_id: 3, content: 'Welcome to the plan-watching club.', created_at: ISODate('2025-02-15') },
  { _id: 18, post_id: 15, user_id: 3, content: 'RANK vs DENSE_RANK vs ROW_NUMBER, every time.', created_at: ISODate('2025-02-20') }
]);

db.likes.insertMany([
  { user_id: 1, post_id: 2, liked_at: ISODate('2025-01-07') }, { user_id: 1, post_id: 5, liked_at: ISODate('2025-01-15') },
  { user_id: 2, post_id: 1, liked_at: ISODate('2025-01-05') }, { user_id: 2, post_id: 8, liked_at: ISODate('2025-01-22') },
  { user_id: 3, post_id: 1, liked_at: ISODate('2025-01-05') }, { user_id: 3, post_id: 5, liked_at: ISODate('2025-01-15') },
  { user_id: 3, post_id: 9, liked_at: ISODate('2025-01-25') }, { user_id: 5, post_id: 4, liked_at: ISODate('2025-01-12') },
  { user_id: 6, post_id: 1, liked_at: ISODate('2025-01-05') }, { user_id: 7, post_id: 3, liked_at: ISODate('2025-01-10') },
  { user_id: 7, post_id: 9, liked_at: ISODate('2025-01-25') }, { user_id: 9, post_id: 5, liked_at: ISODate('2025-01-15') },
  { user_id: 10, post_id: 5, liked_at: ISODate('2025-01-15') }, { user_id: 10, post_id: 13, liked_at: ISODate('2025-02-15') },
  { user_id: 4, post_id: 2, liked_at: ISODate('2025-01-09') }
]);

db.followers.insertMany([
  { follower_id: 2, followed_id: 1, followed_at: ISODate('2025-01-04') }, { follower_id: 3, followed_id: 1, followed_at: ISODate('2025-01-06') },
  { follower_id: 6, followed_id: 1, followed_at: ISODate('2025-01-08') }, { follower_id: 7, followed_id: 1, followed_at: ISODate('2025-01-20') },
  { follower_id: 10, followed_id: 1, followed_at: ISODate('2025-01-25') }, { follower_id: 1, followed_id: 2, followed_at: ISODate('2025-01-05') },
  { follower_id: 7, followed_id: 2, followed_at: ISODate('2025-01-11') }, { follower_id: 1, followed_id: 3, followed_at: ISODate('2025-01-07') },
  { follower_id: 10, followed_id: 3, followed_at: ISODate('2025-01-08') }, { follower_id: 4, followed_id: 3, followed_at: ISODate('2025-02-03') },
  { follower_id: 5, followed_id: 4, followed_at: ISODate('2025-01-12') }, { follower_id: 8, followed_id: 4, followed_at: ISODate('2025-02-01') },
  { follower_id: 1, followed_id: 5, followed_at: ISODate('2025-01-23') }, { follower_id: 10, followed_id: 7, followed_at: ISODate('2025-01-15') }
]);

db.messages.insertMany([
  { _id: 1, sender_id: 10, receiver_id: 1, body: 'Is the study group beginner friendly?', sent_at: ISODate('2025-01-24'), is_read: true },
  { _id: 2, sender_id: 1, receiver_id: 10, body: 'Very. Bring a laptop with Postgres installed.', sent_at: ISODate('2025-01-24'), is_read: true },
  { _id: 3, sender_id: 1, receiver_id: 3, body: 'Which index fixed your ETL job?', sent_at: ISODate('2025-01-07'), is_read: true },
  { _id: 4, sender_id: 3, receiver_id: 1, body: 'Composite on (user_id, created_at). Post 2 story soon.', sent_at: ISODate('2025-01-07'), is_read: true },
  { _id: 5, sender_id: 9, receiver_id: 7, body: 'Can I present at the next meetup?', sent_at: ISODate('2025-02-01'), is_read: true },
  { _id: 6, sender_id: 7, receiver_id: 9, body: 'Yes! 15 minute slot is yours.', sent_at: ISODate('2025-02-02'), is_read: true },
  { _id: 7, sender_id: 6, receiver_id: 1, body: 'Could you review my dashboard query?', sent_at: ISODate('2025-02-14'), is_read: true },
  { _id: 8, sender_id: 1, receiver_id: 6, body: 'Send it over tonight.', sent_at: ISODate('2025-02-14'), is_read: true },
  { _id: 9, sender_id: 5, receiver_id: 2, body: 'Lahore photo walk next month?', sent_at: ISODate('2025-02-16'), is_read: true },
  { _id: 10, sender_id: 2, receiver_id: 5, body: 'Count me in.', sent_at: ISODate('2025-02-16'), is_read: false }
]);

print('✅ social dataset seeded: users 10, posts 15, comments 18, likes 15, followers 14, messages 10');

