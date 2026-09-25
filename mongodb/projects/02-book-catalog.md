# P2 — Book Catalog

**Milestone:** Mongo Days 6–8 · **Time:** ~60 min

## Objective

Build a small book catalog and answer a battery of querying/projection/paging drills — Stage 2's consolidation.

## Requirements

Insert ~12 books with: title, author(s) (array — some single, some multi-author!), year, genre, price, in_stock, tags (array). Include: two books sharing a genre, one out of stock, one with a *missing* `tags` field, two with the same author.

## Required Queries

1. All books — title + price only (projection, hide _id)
2. Books in a genre, sorted by year descending, top 3
3. Price range: books between two prices (inclusive)
4. Multi-author books only (hint: `$size`... or array length — your choice; say what you used)
5. Books with the tag 'classic' — and the one book with NO tags field: does it match? (Predict first — Day 7's quirk!)
6. Page 2 of 3-per-page, sorted by price ascending — then rewrite it cursor-style (Day 8)
7. Authors of more than one book (distinct + count, or your own approach — predict who first)
8. Everything EXCEPT price (exclude-mode projection)

## Challenge

9. One query, everything combined: in-stock, genre X or Y ($in), under a price, showing title+author only, sorted by year desc, limit 4
10. The covered-query preview: create `{ genre: 1, title: 1 }` index; query books by genre projecting title — check explain for docsExamined (a Day 18 preview — just find the number)

## Bonus

11. A mixed-type sabotage: update one book's year to the string `'1999'`; now sort by year ascending — where does it land and why? (Day 8 Bug 2, witnessed.) Fix it back.

> [solutions/02-book-catalog.md](solutions/02-book-catalog.md)
