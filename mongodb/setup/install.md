# 🍃 Installing MongoDB + mongosh

## Option A — macOS with Homebrew

```bash
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community    # runs on localhost:27017
brew install mongodb-shell               # mongosh (if not bundled)
```

Verify:

```bash
mongosh --eval "db.runCommand({ ping: 1 })"
# { ok: 1 }  → you're connected
```

Stop / restart / logs:

```bash
brew services stop mongodb-community
tail -f $(brew --prefix)/var/log/mongodb/mongo.log
```

## Option B — Docker

```bash
docker compose -f scripts/setup/docker-compose.yml up -d
# MongoDB on localhost:27017, no auth (local learning only)
```

## Option C — Other platforms

- **Ubuntu:** `sudo apt install mongodb-org` per MongoDB's official docs, then `sudo systemctl start mongod`
- **Windows:** the MSI installer + MongoDB Compass (optional GUI)

## mongosh — your shell for this track

```bash
mongosh              # connects to localhost:27017, test database
mongosh ecommerce    # straight into a database
mongosh --file x.js  # run a script
```

Inside mongosh you write **JavaScript** with a global `db`:

```javascript
show dbs
use ecommerce
show collections
db.users.find()
db.users.findOne({ email: 'ayesha@example.com' })
```

**Autocomplete everywhere** — press Tab liberally. `.help` lists shell helpers; `db.help()` and `db.collection.help()` exist.

## Load the datasets

```bash
./scripts/seed/seed-mongo.sh ecommerce   # or social | saas | jobs
mongosh ecommerce
db.users.countDocuments()                // 10
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `mongosh: command not found` | install `mongodb-shell`, reopen terminal |
| `connect ECONNREFUSED 127.0.0.1:27017` | `brew services start mongodb-community`, check the log |
| Dataset "missing" | rerun the seed script; check `show dbs` |

**Next: `mongosh-survival-guide.md` — the shell habits that carry the track.**
