# DBMS Playground

> A 30-day interactive database laboratory. Learn databases by **using them every single day** — not by reading about them.

## What This Is

This repository is a complete, practice-first learning program for Database Management Systems. It contains **three parallel 30-day tracks**:

| Track | What it teaches | What it is NOT |
|---|---|---|
| **`sql/`** | SQL — the *query language*: SELECT, filtering, joins, aggregation, subqueries, CTEs, window functions, transactions, normalization | Not a database. SQL is a language you speak *to* a database. |
| **`postgresql/`** | PostgreSQL — an actual *database system*: schemas, data types, constraints, indexes, the query planner, EXPLAIN, isolation levels, locks, roles, backups | Not just "SQL again" — it's the engine itself. |
| **`mongodb/`** | MongoDB — a *document-oriented NoSQL database*: documents, collections, BSON, embedding vs referencing, aggregation pipelines, TTL indexes, scaling | Not "SQL with different syntax" — a different way of modeling data. |

## Who It's For

A beginner developer learning databases seriously for the first time. **Zero database knowledge is assumed.** Every concept starts from "what is it and why does it exist?"

## The Learning Philosophy

Every concept follows this loop:

```text
Concept → Understand → Observe Example → Implement → Practice Repeatedly
       → Debug → Combine Concepts → Build Something → Recall From Memory
```

Each daily lesson pushes you through that loop. Reading is the smallest part. Most of your time is spent typing queries, predicting outputs, fixing broken queries, and writing queries from memory.

## How the 30-Day Challenge Works

1. **One track day = one sitting (45–90 min).** Follow the standard lesson format in `STUDY-GUIDE.md`.
2. **Progress is tracked in `PROGRESS.md`** — and it tracks *learning*, not reading: practiced? debugged? recalled? can you explain it without notes?
3. **Projects are consolidation milestones.** After a group of related concepts, you build something with them before moving on (see `ROADMAP.md`).
4. **Exercises are labeled by difficulty:** `[Beginner]`, `[Intermediate]`, `[Advanced]`. Early days are mostly Beginner; Advanced appears only after the foundation is built.
5. **Interview prep is built in.** Every day ends with interview questions, and every stage ends with a mini interview simulation. Understanding *is* the interview prep.

## Quick Start

```bash
# PostgreSQL (used to execute SQL-track lessons)
brew install postgresql@16 && brew services start postgresql@16
./scripts/setup/setup-postgres.sh

# Seed a dataset (e-commerce, social, saas, jobs)
./scripts/seed/seed-postgres.sh ecommerce

# MongoDB
brew install mongodb-community && brew services start mongodb-community
./scripts/seed/seed-mongo.sh ecommerce

# Reset a dataset back to its original state any time
./scripts/reset/reset-postgres.sh ecommerce
./scripts/reset/reset-mongo.sh ecommerce

# Later — the performance lessons (SQL Day 22+, PG Day 13+, Mongo Day 16+)
# use a generated 100k+ row database; load it only when a lesson says to:
./scripts/utilities/load-large-postgres.sh    # creates perf_lab (~500k rows)
./scripts/utilities/load-large-mongo.sh
```

Full environment setup (including optional Docker): see `STUDY-GUIDE.md` and `postgresql/setup/`, `mongodb/setup/`.

## Repository Structure

```text
dbms-playground/
├── README.md            ← you are here
├── ROADMAP.md           ← the complete 30-day progression for all 3 tracks
├── STUDY-GUIDE.md       ← how to work through each day
├── PROGRESS.md          ← your learning tracker
├── GLOSSARY.md          ← every database term, defined simply
├── sql/                 ← SQL track (30 days, projects, reviews, exercises)
├── postgresql/          ← PostgreSQL track (30 days, projects, reviews, setup)
├── mongodb/             ← MongoDB track (30 days, projects, reviews, setup)
├── shared/
│   ├── datasets/        ← realistic SQL + MongoDB seed data (4 domains)
│   ├── diagrams/        ← ER diagrams (Mermaid)
│   ├── interview-questions/
│   ├── cross-database/  ← SQL ↔ MongoDB comparison exercises
│   └── cheat-sheets/
└── scripts/             ← setup / seed / reset / utilities
```

## The Four Datasets

All lessons reuse four realistic domains (details in `shared/datasets/`):

| Domain | Tables / Collections |
|---|---|
| **E-commerce** | users, products, categories, orders, order_items, payments, reviews |
| **Social** | users, posts, comments, likes, followers, messages |
| **SaaS** | organizations, users, projects, tasks, subscriptions, invoices |
| **Jobs** | candidates, companies, jobs, applications, skills |

Datasets grow as you progress: small (~dozens of rows) for foundation days, generated large datasets (100k+ rows) for the performance stages.

## Guiding Balance

```text
~30% Conceptual understanding   ~40% Hands-on practice
~20% Projects / problem solving ~10% Interview & recall
```

The goal is **muscle memory**: after 30 days you should write common database operations from memory, design a data model from requirements, investigate a slow query, and talk confidently about fundamental database topics in interviews.

**Start here → `STUDY-GUIDE.md`, then `ROADMAP.md`.**
