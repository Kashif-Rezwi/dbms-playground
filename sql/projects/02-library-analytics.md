# Project 2 — Library Analytics

**Milestone:** SQL Stage 2 (after Day 10) · **Time:** ~60 min · **Dataset:** your own small library dataset

## Objective

Build a small library dataset and answer a battery of analytics questions with aggregation — the full Stage 2 toolkit in one place.

## Scenario

A neighborhood library wants basic reports: how popular is each book, who reads the most, when are checkouts busiest.

## Requirements

Create these two tables yourself (types and constraints your choice):

- `books`: id, title, author, year_published, genre
- `checkouts`: id, book_id (→ books), member_name, checkout_date, returned_date (NULL = still out)

Insert **10 books** and **25+ checkouts** spread across genres, members, and months (2024 dates). Include at least: one book with 4+ checkouts, two books never checked out, three still-out books (NULL return), one member with 5+ checkouts.

## Required Queries

4. Count of books / count of checkouts (two queries or one)
5. Checkouts per book (book title + count, books with zero included!) — top 5 by popularity
6. Books *never* checked out (two ways: LEFT JOIN + IS NULL, and NOT IN)
7. The most active member (member + checkout count)
8. Checkouts per genre
9. Members with more than 3 checkouts
10. Average checkout duration (returned_date − checkout_date, in days — NULLs excluded; explain *why* they're excluded)
11. Checkouts per month (the date pattern — EXTRACT + GROUP BY)
12. Books checked out more than the average book (correlated or scalar subquery)

## Constraints

- Predict every result before running — especially counts (5, 6, 7, 9)
- No solutions until you've written your own

## Performance Requirement

Tiny data — none. Focus on *correctness*.

## Challenge Tasks

13. Overdue detection: books where `returned_date IS NULL` and checkout older than 30 days
14. Per-member report: member, total checkouts, still-out count, average duration — one query, LEFT JOIN + GROUP BY + conditional counting

## Bonus Challenge

15. "Genre loyalty": for each member, the genre they check out most. (Hint: GROUP BY member, genre + a window function — Day 16 preview; or do it with a subquery.)

## Expected Outcome

A library you built, 12+ queries answered, and a feel for what "analytics" means in SQL: GROUP BY everywhere.

## Self-Review Questions

- Which was harder: building honest fake data, or the queries?
- Why does the "never checked out" question need an outer join?
- What did NULL mean in your data — and which aggregate silently ignored it?

> Done? [solutions/02-library-analytics.md](solutions/02-library-analytics.md)
