# Solutions — P1: Task Manager (Mongo)

## Reference shape (yours may differ — judge the *reasoning*)

```javascript
db.tasks.insertOne({
  title: 'Learn MongoDB updates', status: 'todo', priority: 'high',
  created_at: new Date(), tags: ['db'],
  meta: { created_by: 'you', source: 'lesson' }
})

db.tasks.insertMany([
  { title: 'Ship project',   status: 'doing', priority: 'medium', created_at: new Date(Date.now() - 86400000) },
  { title: 'Write tests',    status: 'todo',  priority: 'low',    created_at: new Date(Date.now() - 2*86400000) },
  { title: 'Review PR',      status: 'doing', priority: 'high',   created_at: new Date(Date.now() - 3*86400000), points: 3 },
  { title: 'Call the bank',   status: 'todo',  priority: 'medium', created_at: new Date(Date.now() - 4*86400000) }
])
```

## The operations

```javascript
// 2. mark done — both fields, one atomic update
db.tasks.updateOne({ title: 'Ship project' },
  { $set: { status: 'done', completed_at: new Date() } })

// 3. $inc
db.tasks.updateOne({ title: 'Review PR' }, { $inc: { points: 1 } })
db.tasks.updateOne({ title: 'Review PR' }, { $inc: { points: -2 } })

// 4. array ops — feel the push/addToSet difference
db.tasks.updateOne({ title: 'Review PR' }, { $push:   { tags: 'urgent' } })
db.tasks.updateOne({ title: 'Review PR' }, { $addToSet: { tags: 'urgent' } })  // no dup!
db.tasks.updateOne({ title: 'Review PR' }, { $pull:   { tags: 'urgent' } })

// 5. the upsert stat
db.task_stats.updateOne({ user_id: 1 }, { $inc: { done_count: 1 } }, { upsert: true })
// run twice → done_count: 2 — created on the first call, incremented since.
```

## The queries

```javascript
// 6. newest first — by created_at (ids aren't honest event order; Day 2/SQL Day 5)
db.tasks.find().sort({ created_at: -1 })

// 7.
db.tasks.find({ status: 'todo' })
db.tasks.find({ status: 'todo', priority: 'high' })   // implicit AND

// 8.
db.tasks.find({ tags: { $exists: true } })
db.tasks.find({ tags: 'db' })

// 9. nested read
db.tasks.find({ 'meta.source': 'lesson' })

// 10. delete ritual + soft delete
db.tasks.find({ title: 'Call the bank' })      // preview
db.tasks.deleteOne({ title: 'Call the bank' }) // then
db.tasks.updateOne({ title: 'Review PR' }, { $set: { hidden: true } })
db.tasks.find({ hidden: { $ne: true } })
```

## Challenges (short)

**11.** Three countDocuments per status is fine today; note what Day 20 fixes: ONE `$group: {_id: '$status'}` pipeline.

**12.** Stored `done_count` (computed pattern): wins when read on every profile view; cost = every completion must `$inc` it (drift risk if some writer forgets). Computed: always true, pays a $group per view. Rule: hot read + controlled write path → store it.

**13.** Validator:

```javascript
db.createCollection('tasks_v', { validator: { $jsonSchema: {
  required: ['title', 'status'],
  properties: {
    title:  { bsonType: 'string' },
    status: { enum: ['todo', 'doing', 'done'] }
  } } } })
db.tasks_v.insertOne({ title: 'X' })          // fails: status missing
db.tasks_v.insertOne({ title: 'X', status: 'weird' })  // fails: enum
```
