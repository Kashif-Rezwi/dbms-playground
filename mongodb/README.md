# MongoDB Track — The Document Database

> **MongoDB is not "SQL with different syntax."** It's a different way of modeling data: self-contained *documents*, flexible structure, arrays and nesting as first-class citizens, embedding instead of joining. This track teaches it standalone — zero SQL assumed.

## What You'll Learn

```text
Days 1–4    Foundation: mongosh, documents, BSON, insertOne/insertMany, find
Days 5–8    CRUD mastery: update operators, delete, query operators, projection/sort/paging
Days 9–11   Arrays & nested data: the document superpowers
Days 12–15  Data modeling: embedding vs referencing, relationship shapes
Days 16–18  Indexes & performance: compound, unique, TTL, explain()
Days 19–22  Aggregation pipeline: $match → $group → $unwind → $lookup
Days 23–27  Transactions → replication → sharding → production
Days 28–30  Review + CAPSTONE
```

## How to Run the Lessons

```bash
brew install mongodb-community && brew services start mongodb-community
./scripts/seed/seed-mongo.sh ecommerce
mongosh ecommerce
```

Full setup: [setup/install.md](./setup/install.md) · [setup/mongosh-survival-guide.md](./setup/mongosh-survival-guide.md)

## Structure

```text
mongodb/
├── setup/                        ← install + mongosh survival guide
├── days/day-01.md … day-28.md, day-29-30.md
├── projects/                     ← consolidation milestones
├── reviews/                      ← stage review
└── cheat-sheet.md
```

## A Warning to Carried-Over SQL Habits

You *will* be tempted to build "tables" and "foreign keys" with the same instincts as SQL. Resist: the first rule of this track is **design around your data access patterns, not around normalization**. Days 12–15 make that rigorous — the early days keep it simple.

**Start → [days/day-01.md](./days/day-01.md)**
