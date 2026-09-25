-- ============================================================
-- SOCIAL dataset (small) — dbms-playground
-- Load:  ./scripts/seed/seed-postgres.sh social
-- Tables: users, posts, comments, likes, followers, messages
-- ============================================================

BEGIN;

DROP TABLE IF EXISTS likes, followers, messages, comments, posts, users CASCADE;

CREATE TABLE users (
    id         INT PRIMARY KEY,
    username   TEXT NOT NULL UNIQUE,
    email      TEXT NOT NULL UNIQUE,
    bio        TEXT,
    joined_at  DATE
);

CREATE TABLE posts (
    id          INT PRIMARY KEY,
    user_id     INT NOT NULL REFERENCES users(id),
    content     TEXT NOT NULL,
    created_at  DATE NOT NULL
);

CREATE TABLE comments (
    id          INT PRIMARY KEY,
    post_id     INT NOT NULL REFERENCES posts(id),
    user_id     INT NOT NULL REFERENCES users(id),
    content     TEXT NOT NULL,
    created_at  DATE NOT NULL
);

CREATE TABLE likes (
    user_id   INT NOT NULL REFERENCES users(id),
    post_id   INT NOT NULL REFERENCES posts(id),
    liked_at  DATE NOT NULL,
    PRIMARY KEY (user_id, post_id)
);

CREATE TABLE followers (
    follower_id  INT NOT NULL REFERENCES users(id),
    followed_id  INT NOT NULL REFERENCES users(id),
    followed_at  DATE NOT NULL,
    PRIMARY KEY (follower_id, followed_id),
    CHECK (follower_id <> followed_id)
);

CREATE TABLE messages (
    id          INT PRIMARY KEY,
    sender_id   INT NOT NULL REFERENCES users(id),
    receiver_id INT NOT NULL REFERENCES users(id),
    body        TEXT NOT NULL,
    sent_at     DATE NOT NULL,
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    CHECK (sender_id <> receiver_id)
);

INSERT INTO users (id, username, email, bio, joined_at) VALUES
    (1, 'ayesha_k',  'ayesha@social.dev',  'Backend dev. Coffee first.',  '2024-01-10'),
    (2, 'bilal_a',   'bilal@social.dev',   'Runner. Occasional poet.',    '2024-01-22'),
    (3, 'chen_w',    'chen@social.dev',    'Data engineer.',             '2024-02-14'),
    (4, 'dua_m',     'dua@social.dev',     NULL,                          '2024-03-01'),
    (5, 'emre_y',    'emre@social.dev',    'Photographer & cyclist.',    '2024-03-19'),
    (6, 'farah_a',   'farah@social.dev',   'UI designer.',               '2024-04-05'),
    (7, 'grace_o',   'grace@social.dev',   'Community builder.',         '2024-04-28'),
    (8, 'hassan_r',  'hassan@social.dev',  'Lurker.',                    '2024-05-15'),
    (9, 'ivy_s',     'ivy@social.dev',     'Travel + tech.',            '2024-06-02'),
    (10,'junaid_s',  'junaid@social.dev',  'Learning databases.',        '2024-06-30');

INSERT INTO posts (id, user_id, content, created_at) VALUES
    (1,  1, 'Finally shipped my first API. Two months of learning SQL paid off.',   '2025-01-05'),
    (2,  3, 'ETL job ran in 40 minutes today. Yesterday: 4 hours. Indexes are magic.','2025-01-07'),
    (3,  2, 'Ran 10km this morning before work.',                                    '2025-01-10'),
    (4,  6, 'Redesigned our dashboard. Feedback welcome.',                          '2025-01-12'),
    (5,  7, 'Hosting a free databases study group this weekend.',                   '2025-01-15'),
    (6,  1, 'Reminder: normalize until it hurts, then stop.',                       '2025-01-18'),
    (7,  9, 'Flight to Seoul booked. Any dev meetups in March?',                    '2025-01-20'),
    (8,  5, 'Golden hour on the coast. No filter needed.',                          '2025-01-22'),
    (9,  10,'Day 1 of #30DaysOfDatabases. Today: what even is a table?',           '2025-01-25'),
    (10, 3, 'Correlated subqueries finally clicked for me.',                        '2025-02-02'),
    (11, 2, 'Poem draft #14: about NULL. It equals nothing, not even itself.',     '2025-02-08'),
    (12, 7, 'Study group recap thread: 42 people showed up.',                       '2025-02-10'),
    (13, 1, 'Postgres EXPLAIN ANALYZE is my new favorite debugging tool.',         '2025-02-15'),
    (14, 6, 'Dark mode is not a personality trait. Or is it?',                      '2025-02-18'),
    (15, 10,'Day 18: window functions are powerful but my brain hurts.',           '2025-02-20');

INSERT INTO comments (id, post_id, user_id, content, created_at) VALUES
    (1,  1,  2, 'Congrats! What stack?',                            '2025-01-05'),
    (2,  1,  6, 'Well deserved.',                                   '2025-01-05'),
    (3,  2,  1, 'Which index did you add?',                         '2025-01-07'),
    (4,  2,  10, 'Saving this as motivation.',                      '2025-01-08'),
    (5,  3,  7, 'Beast mode.',                                      '2025-01-10'),
    (6,  4,  1, 'The spacing is so clean now.',                     '2025-01-12'),
    (7,  4,  5, 'The charts finally make sense.',                  '2025-01-13'),
    (8,  5,  10, 'Joined! Beginner here.',                          '2025-01-15'),
    (9,  5,  3, 'Will share my aggregation notes.',                '2025-01-16'),
    (10, 6,  9, 'Stealing this line for my README.',                '2025-01-18'),
    (11, 7,  5, 'Seoul DevFest is in March!',                      '2025-01-20'),
    (12, 8,  2, 'Stunning shot.',                                  '2025-01-22'),
    (13, 9,  1, 'A table is a very strict spreadsheet. Day 1 is easy.', '2025-01-25'),
    (14, 9,  7, 'Welcome aboard — do the debugging exercises, they teach the most.', '2025-01-26'),
    (15, 11, 10, 'A poem about NULL. We are the same.',             '2025-02-08'),
    (16, 12, 1, 'The $lookup demo was the highlight.',              '2025-02-10'),
    (17, 13, 3, 'Welcome to the plan-watching club.',               '2025-02-15'),
    (18, 15, 3, 'RANK vs DENSE_RANK vs ROW_NUMBER, every time.',    '2025-02-20');

INSERT INTO likes (user_id, post_id, liked_at) VALUES
    (1, 2,  '2025-01-07'), (1, 5,  '2025-01-15'), (2, 1, '2025-01-05'),
    (2, 8,  '2025-01-22'), (3, 1,  '2025-01-05'), (3, 5, '2025-01-15'),
    (3, 9,  '2025-01-25'), (5, 4,  '2025-01-12'), (6, 1, '2025-01-05'),
    (7, 3,  '2025-01-10'), (7, 9,  '2025-01-25'), (9, 5, '2025-01-15'),
    (10, 5, '2025-01-15'), (10, 13, '2025-02-15'), (4, 2, '2025-01-09');

INSERT INTO followers (follower_id, followed_id, followed_at) VALUES
    (2, 1, '2025-01-04'), (3, 1, '2025-01-06'), (6, 1, '2025-01-08'),
    (7, 1, '2025-01-20'), (10, 1, '2025-01-25'), (1, 2, '2025-01-05'),
    (7, 2, '2025-01-11'), (1, 3, '2025-01-07'), (10, 3, '2025-01-08'),
    (4, 3, '2025-02-03'), (5, 4, '2025-01-12'), (8, 4, '2025-02-01'),
    (1, 5, '2025-01-23'), (10, 7, '2025-01-15');

INSERT INTO messages (id, sender_id, receiver_id, body, sent_at, is_read) VALUES
    (1,  10, 1, 'Is the study group beginner friendly?',        '2025-01-24', TRUE),
    (2,  1,  10, 'Very. Bring a laptop with Postgres installed.', '2025-01-24', TRUE),
    (3,  1,  3, 'Which index fixed your ETL job?',               '2025-01-07', TRUE),
    (4,  3,  1, 'Composite on (user_id, created_at). Post 2 story soon.', '2025-01-07', TRUE),
    (5,  9,  7, 'Can I present at the next meetup?',             '2025-02-01', TRUE),
    (6,  7,  9, 'Yes! 15 minute slot is yours.',                 '2025-02-02', TRUE),
    (7,  6,  1, 'Could you review my dashboard query?',          '2025-02-14', TRUE),
    (8,  1,  6, 'Send it over tonight.',                          '2025-02-14', TRUE),
    (9,  5,  2, 'Lahore photo walk next month?',                  '2025-02-16', TRUE),
    (10, 2,  5, 'Count me in.',                                  '2025-02-16', FALSE);

COMMIT;

-- Sanity check: users 10 | posts 15 | comments 18 | likes 15 | followers 14 | messages 10

