// ============================================================
// LARGE e-commerce dataset — MongoDB, for performance lessons
// ~50k users, 5k products, 200k orders (items embedded)
// Run via:  ./scripts/utilities/load-large-mongo.sh
// No indexes created on purpose — you add them in Day 16–18.
// ============================================================

db = db.getSiblingDB('perf_lab');
db.dropDatabase();

// Simple deterministic pseudo-random (LCG) so runs are repeatable
let seed = 42;
function rand() {
  seed = (seed * 1103515245 + 12345) % 2147483648;
  return seed / 2147483648;
}
const CITIES = ['Karachi', 'Lahore', 'Islamabad', 'Toronto', 'Istanbul', 'Lagos', 'Manila', 'London', 'Dubai'];
const STATUSES = ['delivered', 'delivered', 'delivered', 'shipped', 'pending', 'cancelled'];

// Users
let batch = [];
for (let i = 1; i <= 50000; i++) {
  batch.push({
    _id: i, name: 'User ' + i, email: 'user' + i + '@example.com',
    city: CITIES[Math.floor(rand() * CITIES.length)],
    is_active: rand() > 0.10,
    joined_at: new Date(Date.UTC(2024, 0, 1) + Math.floor(rand() * 500) * 86400000)
  });
  if (batch.length === 5000) { db.users.insertMany(batch); batch = []; }
}
if (batch.length) db.users.insertMany(batch);

// Products
batch = [];
for (let i = 1; i <= 5000; i++) {
  batch.push({
    _id: i, name: 'Product ' + i, category_id: 1 + Math.floor(rand() * 8),
    price: Math.round((100 + rand() * 9900) * 100) / 100,
    stock: Math.floor(rand() * 200),
    created_at: new Date(Date.UTC(2024, 0, 1) + Math.floor(rand() * 400) * 86400000)
  });
  if (batch.length === 5000) { db.products.insertMany(batch); batch = []; }
}
if (batch.length) db.products.insertMany(batch);

// Orders with embedded items (1–3 items each)
batch = [];
for (let i = 1; i <= 200000; i++) {
  const itemCount = 1 + Math.floor(rand() * 3);
  const items = [];
  let total = 0;
  for (let j = 0; j < itemCount; j++) {
    const price = Math.round((100 + rand() * 9900) * 100) / 100;
    const qty = 1 + Math.floor(rand() * 3);
    items.push({ product_id: 1 + Math.floor(rand() * 5000), quantity: qty, unit_price: price });
    total += price * qty;
  }
  batch.push({
    _id: i, user_id: 1 + Math.floor(rand() * 50000),
    status: STATUSES[Math.floor(rand() * STATUSES.length)],
    items: items, total_amount: Math.round(total * 100) / 100,
    ordered_at: new Date(Date.UTC(2024, 5, 1) + Math.floor(rand() * 500) * 86400000)
  });
  if (batch.length === 5000) { db.orders.insertMany(batch); batch = []; }
}
if (batch.length) db.orders.insertMany(batch);

print('✅ perf_lab ready: users ' + db.users.countDocuments() +
      ', products ' + db.products.countDocuments() +
      ', orders ' + db.orders.countDocuments());
