# Installing MongoDB + mongosh

## Installation (macOS via Homebrew)

```bash
brew tap mongodb/brew
brew install mongodb-community@8.0
brew services start mongodb-community@8.0    # runs on localhost:27017
brew install mongosh                    # installs the shell (if not bundled)

```

### Verify

```bash
mongosh --eval "db.runCommand({ ping: 1 })"
# { ok: 1 }  → you're connected

```

### Stop / Restart / Logs

```bash
brew services stop mongodb-community@8.0
tail -f $(brew --prefix)/var/log/mongodb/mongo.log

```

---

## mongosh — Your Shell for This Track

```bash
mongosh              # connects to localhost:27017, test database
mongosh ecommerce    # straight into a database
mongosh --file x.js  # run a script

```

Inside `mongosh`, you write **JavaScript** with a global `db`:

```javascript
show dbs
use ecommerce
show collections
db.users.find()
db.users.findOne({ email: 'ayesha@example.com' })

```

**Autocomplete everywhere** — press Tab liberally. `.help` lists shell helpers; `db.help()` and `db.collection.help()` exist.

---

## Load the Datasets

```bash
./scripts/seed/seed-mongo.sh ecommerce   # or social | saas | jobs | all
# or seed everything at once:  ./scripts/setup/setup-mongo.sh
mongosh ecommerce
db.users.countDocuments()                // 10

```

---

## Enabling Transactions Locally (Replica Set)

**Skip this until Day 23.** Multi-document transactions require a *replica set* — even a single-node one. A standalone `mongod` (the default after install) refuses them with `Transaction numbers are only allowed on a replica set member or mongos`.

```bash
# 1. Add replication to the config:
#      $(brew --prefix)/etc/mongod.conf
#
#      replication:
#        replSetName: rs0

# 2. Restart the service
brew services restart mongodb-community@8.0

# 3. Initialize the one-node replica set (once, ever)
mongosh --eval "rs.initiate()"

# 4. Verify — myState 1 means PRIMARY, transactions now work
mongosh --eval "rs.status().myState"

```

Your existing databases survive this change. If `mongosh` sessions started *before* `rs.initiate()` behave oddly, reconnect (Day 23 covers why).

---

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `mongosh: command not found` | Run `brew install mongosh` and reopen terminal |
| `connect ECONNREFUSED 127.0.0.1:27017` | `brew services start mongodb-community@8.0`, check the log |
| Dataset "missing" in `show dbs` | Connecting never creates a database (MongoDB creates DBs on first write) — run `./scripts/seed/seed-mongo.sh ecommerce` (or `all`) |
| `Transaction numbers are only allowed on a replica set...` | Follow the replica-set steps above |
| `rs.initiate()` errors with "not started with --replSet" | `mongod` wasn't restarted with the replication config — check steps 1–2 |

**Next: `mongosh-survival-guide.md` — the shell habits that carry the track.**