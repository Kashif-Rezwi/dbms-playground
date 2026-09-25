# MongoDB Cheat Sheet

*Shell syntax (mongosh / Node driver). JavaScript — objects and arrays everywhere.*

## Databases & collections

```javascript
use ecommerce                  // create/switch
show collections
db.createCollection('users')   // optional — auto-created on first insert
db.users.drop()
db.dropDatabase()
```

## Create

```javascript
db.users.insertOne({ name: 'Ayesha', city: 'Karachi', is_active: true })
db.users.insertMany([{...}, {...}])
// _id is added automatically (ObjectId) if you don't provide one
```

## Read

```javascript
db.users.find()                                // all
db.users.findOne({ _id: 1 })
db.users.find({ city: 'Karachi', is_active: true })
db.users.find({ age: { $gt: 25 } })            // comparison operators
db.users.find({ 'address.city': 'Karachi' })   // dot notation into nesting
db.users.find({ tags: 'sql' })                 // array contains
db.users.find({ tags: { $all: ['sql', 'book'] } })
db.users.find({ 'skills.skill': 'SQL' })       // match inside array-of-objects

// operators: $eq $ne $gt $gte $lt $lte $in $nin $exists $type
// logic: $and $or $not $nor — implicit AND for multiple fields

db.users.find(query, { name: 1, email: 1, _id: 0 })   // projection
db.users.find().sort({ price: -1 }).limit(10).skip(20)
db.users.find(query).count()        // prefer countDocuments(query)
db.users.distinct('city')
```

## Update

```javascript
db.users.updateOne({ _id: 1 }, { $set: { city: 'Lahore' } })
db.users.updateMany({ is_active: false }, { $set: { is_active: true } })
db.users.updateOne({ _id: 1 }, { $inc: { login_count: 1 } })
// field operators: $set $unset $inc $mul $rename $min $max $currentDate
// array operators: $push $addToSet $pull $pop $each $slice

db.users.replaceOne({ _id: 1 }, { name: 'A', city: 'B' })   // full replace
// upsert:
db.stats.updateOne({ user_id: 1 }, { $inc: { count: 1 } }, { upsert: true })
```

## Delete

```javascript
db.users.deleteOne({ _id: 5 })
db.users.deleteMany({ is_active: false })
```

## Indexes

```javascript
db.users.createIndex({ email: 1 })
db.orders.createIndex({ user_id: 1, ordered_at: -1 })       // compound
db.users.createIndex({ email: 1 }, { unique: true })
db.sessions.createIndex({ created_at: 1 }, { expireAfterSeconds: 3600 })  // TTL
db.products.createIndex({ tags: 1 })                         // multikey (arrays)
db.products.createIndex({ name: 'text' })                    // text search
db.users.getIndexes()
db.users.dropIndex('email_1')
db.orders.find({ user_id: 417 }).explain('executionStats')  // plan + numbers
```

## Aggregation pipeline

```javascript
db.orders.aggregate([
  { $match: { status: { $ne: 'cancelled' } } },
  { $group: { _id: '$user_id', total: { $sum: '$total_amount' }, n: { $sum: 1 } } },
  { $sort: { total: -1 } },
  { $limit: 5 }
])
// stages: $match $project $group $sort $limit $skip $unwind $lookup $count $facet
// accumulators: $sum $avg $min $max $push $addToSet $first $last $count
db.orders.aggregate([
  { $unwind: '$items' },
  { $lookup: { from: 'products', localField: 'items.product_id',
               foreignField: '_id', as: 'product' } },
  { $unwind: '$product' },
  { $project: { name: '$product.name', qty: '$items.quantity' } }
])
```

## Transactions

```javascript
const s = db.getMongo().startSession()
s.startTransaction()
const tdb = s.getDatabase('bank')
tdb.accounts.updateOne({ _id: 1 }, { $inc: { balance: -500 } })
tdb.accounts.updateOne({ _id: 2 }, { $inc: { balance: 500 } })
s.commitTransaction()     // or s.abortTransaction()
s.endSession()
```

## Ops quick hits

```javascript
db.serverStatus()
db.stats()
db.users.stats()
db.currentOp()                        // running ops
db.users.countDocuments()
// replica set status (if configured): rs.status()
```
