# Solutions — P2: Book Catalog

## Reference seed (abridged — yours will differ)

```javascript
db.books.insertMany([
  { title: 'The Quiet Machine', authors: ['A. Khan'], year: 2021, genre: 'tech', price: 2200, in_stock: true,  tags: ['ai', 'classic'] },
  { title: 'Deep Queries',       authors: ['C. Wei', 'E. Yilmaz'], year: 2019, genre: 'tech', price: 1800, in_stock: true,  tags: ['classic'] },
  { title: 'Poems of the City',  authors: ['B. Ahmed'], year: 1998, genre: 'poetry', price: 900, in_stock: false, tags: ['classic'] },
  { title: 'The Ledger',         authors: ['F. Ali'], year: 2015, genre: 'fiction', price: 1500, in_stock: true, tags: ['bestseller'] },
  { title: 'The Ledger II',       authors: ['F. Ali'], year: 2018, genre: 'fiction', price: 1700, in_stock: true, tags: ['bestseller'] },
  { title: 'Maps and Men',       authors: ['G. Okafor'], year: 2002, genre: 'history', price: 1100, in_stock: true }
  // ...one more history book, one out-of-stock, etc. — 12 total
])
```

## Queries

```javascript
// 1.
db.books.find({}, { _id: 0, title: 1, price: 1 })

// 2.
db.books.find({ genre: 'tech' }, { title: 1, year: 1, _id: 0 })
        .sort({ year: -1 }).limit(3)

// 3. inclusive range
db.books.find({ price: { $gte: 1000, $lte: 2000 } })

// 4. multi-author — two ways:
db.books.find({ authors: { $size: 2 } })            // exactly 2
db.books.find({ 'authors.1': { $exists: true } })   // has a 2nd element (any count > 1)

// 5. the missing-tags quirk: the book with NO tags field does NOT match
//    { tags: 'classic' } — missing fields never match values.
db.books.find({ tags: 'classic' })

// 6. skip-page vs cursor:
db.books.find().sort({ price: 1 }).skip(3).limit(3)
// cursor style (after seeing last (price, _id)):
db.books.find({ $or: [ { price: { $gt: 1700 } },
                       { price: 1700, _id: { $gt: lastId } } ] })
        .sort({ price: 1, _id: 1 }).limit(3)

// 7. repeat authors:
db.books.distinct('authors')                        // then compare counts, or:
const counts = {}
db.books.find({}, { authors: 1, _id: 0 }).forEach(b =>
  b.authors.forEach(a => counts[a] = (counts[a] || 0) + 1))
// F. Ali: 2

// 8. exclude mode
db.books.find({}, { price: 0 })

// 9. the combiner
db.books.find({ in_stock: true, genre: { $in: ['tech', 'history'] },
               price: { $lt: 2000 } },
              { title: 1, authors: 1, _id: 0 })
        .sort({ year: -1 }).limit(4)

// 10. covered preview
db.books.createIndex({ genre: 1, title: 1 })
db.books.find({ genre: 'tech' }, { title: 1, _id: 0 })
  .explain('executionStats').executionStats.totalDocsExamined   // 0
```

## Bonus 11 — mixed-type sorting

After `year: '1999'` (string), ascending sort places... **numbers first, then strings** (BSON type order: numbers < strings). The sabotaged book lands *after* all numeric years regardless of its value — silent wrongness. Fix: `$set` it back to a number. Lesson: shape discipline (Day 11's $type audits catch this).
