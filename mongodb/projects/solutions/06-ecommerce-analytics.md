# Solutions — P6: E-Commerce Analytics (Pipeline)

> Counts verified against the seed data — predict before you compare!

```javascript
// 1. top products by UNITS — predict first: book (id 9) sells qty 3 in one order!
db.orders.aggregate([
  { $match: { status: { $ne: 'cancelled' } } },
  { $unwind: '$items' },
  { $group: { _id: '$items.product_id', units: { $sum: '$items.quantity' } } },
  { $sort: { units: -1 } }, { $limit: 3 }
])
// → 9 (units 3), 7 (qty 2), 12/13/5 (qty 2)... note the tie at 2 —
// say how you'd break it (add revenue as the second sort key)

// 2. revenue per city — predict: Karachi users (1,6,10) spend: 3398+12799+4350+1500(cancelled? no—11 IS cancelled, excluded!) = 3398+12799+4350 = 20547
db.orders.aggregate([
  { $match: { status: { $ne: 'cancelled' } } },
  { $lookup: { from: 'users', localField: 'user_id', foreignField: '_id', as: 'user' } },
  { $unwind: '$user' },
  { $group: { _id: '$user.city', revenue: { $sum: '$total_amount' }, orders: { $sum: 1 } } },
  { $sort: { revenue: -1 } }
])

// 3. top customers by delivered revenue (user 1: 3398+12799 = 16197 — predict it!)
db.orders.aggregate([
  { $match: { status: 'delivered' } },
  { $group: { _id: '$user_id', revenue: { $sum: '$total_amount' },
              n: { $sum: 1 }, first: { $min: '$ordered_at' } } },
  { $sort: { revenue: -1 } }, { $limit: 3 }
])

// 4. payment methods — predict: card = 3398+8500+4350+7200+9449 = 32897
db.payments.aggregate([
  { $group: { _id: '$method', total: { $sum: '$amount' }, n: { $sum: 1 } } },
  { $sort: { total: -1 } } ])

// 5. avg rating with names
db.reviews.aggregate([
  { $group: { _id: '$product_id', avg: { $avg: '$rating' }, n: { $sum: 1 } } },
  { $lookup: { from: 'products', localField: '_id', foreignField: '_id', as: 'p' } },
  { $unwind: '$p' },
  { $project: { product: '$p.name', avg: { $round: ['$avg', 2] }, n: 1, _id: 0 } },
  { $sort: { avg: -1, n: -1 } }, { $limit: 3 } ])

// 6. never ordered — YES, $lookup matches INTO embedded arrays:
db.products.aggregate([
  { $lookup: { from: 'orders', localField: '_id',
               foreignField: 'items.product_id', as: 'sold' } },
  { $match: { sold: { $size: 0 } } },
  { $project: { name: 1, _id: 0 } } ])
// app-side version: collect all items.product_ids, then
db.products.find({ _id: { $nin: soldIds } }, { name: 1 })
// both → the same products (2, 8, 10, 14, 15 by the seed)

// 7. monthly report
db.orders.aggregate([
  { $group: { _id: { y: { $year: '$ordered_at' }, m: { $month: '$ordered_at' } },
              orders: { $sum: 1 }, revenue: { $sum: '$total_amount' } } },
  { $sort: { '_id.y': 1, '_id.m': 1 } } ])

// 8. the embed payoff — no pipeline needed at all:
db.orders.find({ user_id: 1 }, { 'items': 1, status: 1 })
// items live IN the order doc: one read = the whole order detail. The
// pipeline is for CROSS-document answers; embedding removes the need here.
```

## 9. The full chain (reference)

```javascript
db.orders.aggregate([
  { $match: { status: { $ne: 'cancelled' } } },
  { $unwind: '$items' },
  { $lookup: { from: 'products', localField: 'items.product_id',
               foreignField: '_id', as: 'p' } },
  { $unwind: '$p' },
  { $addFields: { line: { $multiply: ['$items.quantity', '$items.unit_price'] } } },
  { $group: { _id: '$p.name', units: { $sum: '$items.quantity' },
              revenue: { $sum: '$line' },
              best_line: { $max: '$line' } } },
  { $sort: { revenue: -1 } }, { $limit: 5 }
])
```

## 10. The cross-check (reference notes)

Same numbers as SQL P4's queries 4-5 — row-for-row. Pipelines made the *unwind+group* natural (no join needed for embedded data); SQL made the *multi-table integrity and ad-hoc joins* easier. Both, honestly.
