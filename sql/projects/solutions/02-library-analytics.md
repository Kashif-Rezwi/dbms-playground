# ✅ Solutions — Project 2: Library Analytics

> Your data differs, so results differ — check *methods*, not numbers.

## Reference schema

```sql
CREATE TABLE books (
    id INT PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    year_published INT,
    genre TEXT NOT NULL
);

CREATE TABLE checkouts (
    id INT PRIMARY KEY,
    book_id INT NOT NULL REFERENCES books(id),
    member_name TEXT NOT NULL,
    checkout_date DATE NOT NULL,
    returned_date DATE                        -- NULL = still out
);
```

## Queries 4–12

```sql
-- 4
SELECT COUNT(*) FROM books;
SELECT COUNT(*) FROM checkouts;

-- 5. checkouts per book INCLUDING zero — the Day 12 pattern
SELECT b.title, COUNT(c.id) AS checkouts
FROM books b
LEFT JOIN checkouts c ON c.book_id = b.id
GROUP BY b.title
ORDER BY checkouts DESC
LIMIT 5;

-- 6a. never checked out (LEFT JOIN + IS NULL — the safe idiom)
SELECT b.title
FROM books b
LEFT JOIN checkouts c ON c.book_id = b.id
WHERE c.id IS NULL;
-- 6b. NOT IN version (safe: c.book_id is NOT NULL by constraint)
SELECT b.title FROM books
WHERE b.id NOT IN (SELECT book_id FROM checkouts);

-- 7. most active member
SELECT member_name, COUNT(*) AS n
FROM checkouts GROUP BY member_name
ORDER BY n DESC LIMIT 1;

-- 8. per genre (needs the join: genre lives in books)
SELECT b.genre, COUNT(*) AS checkouts
FROM checkouts c JOIN books b ON b.id = c.book_id
GROUP BY b.genre;

-- 9. members with > 3 checkouts
SELECT member_name, COUNT(*) AS n
FROM checkouts GROUP BY member_name HAVING COUNT(*) > 3;

-- 10. avg duration in days; AVG ignores NULLs (returned_date NULL = still out)
SELECT ROUND(AVG(returned_date - checkout_date), 1) AS avg_days
FROM checkouts
WHERE returned_date IS NOT NULL;

-- 11. per month
SELECT EXTRACT(YEAR  FROM checkout_date) AS yr,
       EXTRACT(MONTH FROM checkout_date) AS mo,
       COUNT(*) AS checkouts
FROM checkouts
GROUP BY 1, 2 ORDER BY 1, 2;

-- 12. more popular than the average book (scalar vs average of per-book counts)
SELECT title, n FROM (
    SELECT b.title, COUNT(c.id) AS n
    FROM books b LEFT JOIN checkouts c ON c.book_id = b.id
    GROUP BY b.title
) t
WHERE n > (SELECT AVG(cnt) FROM
           (SELECT COUNT(*) AS cnt FROM checkouts GROUP BY book_id) s);
```

## Challenges 13–14

```sql
-- 13. overdue: out for more than 30 days
SELECT b.title, c.member_name, c.checkout_date
FROM checkouts c JOIN books b ON b.id = c.book_id
WHERE c.returned_date IS NULL
  AND c.checkout_date < CURRENT_DATE - 30;

-- 14. per-member report
SELECT c.member_name,
       COUNT(*) AS total,
       COUNT(*) FILTER (WHERE c.returned_date IS NULL) AS still_out,
       ROUND(AVG(c.returned_date - c.checkout_date), 1) AS avg_days
FROM checkouts c
GROUP BY c.member_name;
```

## Bonus 15 — genre loyalty (window flavor)

```sql
WITH per_member_genre AS (
    SELECT c.member_name, b.genre, COUNT(*) AS n
    FROM checkouts c JOIN books b ON b.id = c.book_id
    GROUP BY c.member_name, b.genre
)
SELECT member_name, genre, n
FROM (
    SELECT member_name, genre, n,
           ROW_NUMBER() OVER (PARTITION BY member_name ORDER BY n DESC) AS rn
    FROM per_member_genre
) t WHERE rn = 1;
```

## Self-review answers (short)

- "Never checked out" needs the outer join because INNER JOIN only keeps books that *have* checkouts — the lonely books vanish (Day 12).
- NULL in returned_date = "still out"; AVG/SUM quietly skip it (Day 7/9) — which is *correct* here, but you must notice.
