# 📚 STUDY-GUIDE — How to Work Through Each Day

## Before Day 1: Environment Setup

### Option A — Native install (recommended on macOS)

```bash
brew install postgresql@16
brew services start postgresql@16
brew install mongodb-community
brew services start mongodb-community
```

Then create your practice databases:

```bash
./scripts/setup/setup-postgres.sh     # creates ecommerce, social, saas, jobs databases
```

### Option B — Docker (optional)

```bash
docker compose -f scripts/setup/docker-compose.yml up -d
# PostgreSQL on localhost:5432, MongoDB on localhost:27017
```

### Verify you're connected

```bash
psql -d ecommerce -c "SELECT version();"
mongosh --eval "db.runCommand({ ping: 1 })"
```

### Loading datasets

Every day that needs data tells you which dataset to load. To (re)load:

```bash
./scripts/seed/seed-postgres.sh ecommerce   # or: social | saas | jobs
./scripts/seed/seed-mongo.sh ecommerce
./scripts/reset/reset-postgres.sh ecommerce # drop + reseed (use freely — experimentation is the point)
./scripts/reset/reset-mongo.sh ecommerce
```

> 💡 **Resetting is not failure — it's the workflow.** Break things. Reset. Break them differently.

## The Daily Loop (45–90 minutes per day)

```text
1. 🔁 Previous Knowledge      — answer 2–5 recall questions from earlier days FIRST, without notes
2. 🎯 Goal + 🧠 Fundamentals   — read the concept (keep it short)
3. 💻 Examples                — run every example yourself; observe the output
4. 🛠️ Practice               — do ALL exercises, in order, including predict-the-result
5. 🐛 Debugging              — diagnose the broken queries (what? why? fix? verify?)
6. 🧩 Combine Concepts       — one task that mixes today + earlier days
7. 🧠 Recall + 🎤 Interview   — answer without notes; say interview answers OUT LOUD
8. 📝 PROGRESS.md             — tick honestly (practiced ≠ read)
```

## Rules That Make This Work

1. **Type every query yourself.** Never copy-paste examples. Muscle memory is the goal.
2. **Predict before you run.** For every ⭐ predict-the-result exercise, write your prediction down *before* executing.
3. **Write-from-memory means no peeking.** If you can't, re-read yesterday's lesson — that's a normal part of learning, not a failure.
4. **Attempt projects before solutions.** Every project has a `solutions/` folder. Spending 20 stuck minutes teaches more than 2 minutes of reading.
5. **Explain out loud.** The last checkbox every day: *can I explain this without notes?* Literally talk to a rubber duck.
6. **Don't skip debugging days.** Reading a broken query and knowing *why* it fails is the skill interviews actually test.
7. **If you miss days, don't restart.** Redo the last day's 🔁 recall section, then continue.

## How Difficulty Works

- 🟢 Beginner — direct application of today's concept
- 🟡 Intermediate — combines today with prior concepts, or needs thought
- 🔴 Advanced — design/debug/performance thinking; mostly appears after Day 20

## Self-Assessment: "Read" vs "Learned"

Tick `PROGRESS.md` only when you can honestly say:

| Claim | It means you... |
|---|---|
| **Learned** | read the concept and ran the examples |
| **Practiced** | completed the exercises (typed, not copied) |
| **Debugged** | fixed the broken query AND explained why it broke |
| **Recalled** | answered recall questions without notes |
| **Challenge** | completed the combine-concepts task |
| **Project** | built it yourself before opening solutions |
| **Explain** | explained it out loud without notes |

## Suggested Track Order

1. **SQL track (Days 1–30)** — the language and relational thinking
2. **PostgreSQL track** — deepens everything; assumes SQL Days 1–24
3. **MongoDB track** — standalone; do `shared/cross-database/` exercises after it

Busy day? Do steps 1, 4 and 7 only — keep the recall streak alive.

**Go to `ROADMAP.md` → pick your track → open `sql/days/day-01.md`.**
