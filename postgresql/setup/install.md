# 🐘 Installing PostgreSQL

## Option A — macOS with Homebrew (recommended)

```bash
brew install postgresql@16
brew services start postgresql@16     # auto-starts on login
```

Verify:

```bash
psql -V                              # psql (PostgreSQL) 16.x
psql -d postgres -c "SELECT version();"
```

Homebrew's PostgreSQL creates your macOS username as the initial **superuser** database role — that's why `psql -d postgres` "just works".

Stop / restart / logs:

```bash
brew services stop postgresql@16
brew services restart postgresql@16
tail -f $(brew --prefix)/var/log/postgresql@16.log
```

## Option B — Docker

```bash
docker compose -f scripts/setup/docker-compose.yml up -d
# connect: psql -h localhost -U postgres  (password: postgres)
```

## Option C — Other platforms

- **Ubuntu/Debian:** `sudo apt install postgresql postgresql-contrib`, then `sudo -u postgres psql`
- **Windows:** installer from postgresql.org; use **pgAdmin** or **psql** from the Start Menu

## Install the client tools you'll actually use (optional but nice)

- **DBeaver** or **pgAdmin** — a GUI; helpful for browsing, but **do the lessons in psql** — the shell is the interview and the job.
- `mongosh` comes later (MongoDB track).

## Create your practice environment

```bash
./scripts/setup/setup-postgres.sh      # creates ecommerce, social, saas, jobs
./scripts/seed/seed-postgres.sh ecommerce
psql -d ecommerce                      # you're in!
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `psql: command not found` | `brew link postgresql@16` or reopen terminal |
| `connection refused` / "is the server running?" | `brew services start postgresql@16`, check logs |
| `role "you" does not exist` (Docker) | `psql -h localhost -U postgres` |
| Password prompts everywhere | You're on Docker — password is `postgres` |

**Next: `psql-survival-guide.md` — the 20 commands that carry the whole track.**
