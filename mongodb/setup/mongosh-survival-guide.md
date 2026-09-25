# 🛟 mongosh Survival Guide

`mongosh` is a JavaScript shell with a `db` object. It feels like a REPL crossed with a query tool. These are the moves that carry the whole track.

## Getting oriented

```javascript
show dbs                        // list databases
use ecommerce                   // switch (creates on first write)
show collections                // list collections in current db
db                              // which db am I in?
```

## The one habit that changes everything: `.pretty()` (and its successors)

```javascript
db.users.find()                 // dense, hard-to-read
db.users.find().pretty()        // rotated, readable — or use the settings below
```

Better: make every find readable in this session:

```javascript
config.set("displayBatchSize", 20)   // if supported in your version — otherwise:
db.users.find().limit(20).pretty()   // the classic habit
```

## The `.forEach` printing trick

```javascript
db.users.find().forEach(u => print(u.name, "—", u.city))
```

**Iterating query results in JS is legitimate mongosh practice** — but the *database* has its own iteration (cursors, batching) underneath.

## Counts, distinct, existence

```javascript
db.users.countDocuments({ is_active: true })
db.users.distinct('city')
db.users.exists?  no such thing — use:
db.users.findOne({ email: 'x@y.com' }) !== null
```

## Working with results

```javascript
const u = db.users.findOne({ _id: 1 })
u.name                       // dot into results
const top = db.products.find().sort({ price: -1 }).limit(3).toArray()
top.map(p => p.name)
```

## Help system

```javascript
db.help()
db.users.help()
```

## Scripting (running the seed files, your own files)

```bash
mongosh --file shared/datasets/ecommerce.mongo.js
mongosh ecommerce --file my_queries.js
```

## Your session starters

```javascript
use ecommerce
db.users.findOne()
// then whatever today's lesson says
```

## Reset any time

```bash
./scripts/reset/reset-mongo.sh ecommerce
```

Breaking things and resetting them IS the workflow — same as the SQL tracks.
