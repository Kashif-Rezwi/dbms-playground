// ============================================================
// E-COMMERCE dataset (small) — MongoDB seed
// Load:  ./scripts/seed/seed-mongo.sh ecommerce
// Collections: users, categories, products, orders,
//               payments, reviews
// ============================================================

db = db.getSiblingDB('ecommerce');
db.dropDatabase();

db.users.insertMany([
  { _id: 1, name: 'Ayesha Khan',   email: 'ayesha@example.com', city: 'Karachi',   is_active: true,  joined_at: ISODate('2024-01-15') },
  { _id: 2, name: 'Bilal Ahmed',   email: 'bilal@example.com',  city: 'Lahore',    is_active: true,  joined_at: ISODate('2024-02-03') },
  { _id: 3, name: 'Chen Wei',      email: 'chen@example.com',   city: 'Toronto',   is_active: true,  joined_at: ISODate('2024-02-20') },
  { _id: 4, name: 'Dua Malik',     email: 'dua@example.com',    city: 'Islamabad', is_active: false, joined_at: ISODate('2024-03-11') },
  { _id: 5, name: 'Emre Yilmaz',   email: 'emre@example.com',   city: 'Istanbul',  is_active: true,  joined_at: ISODate('2024-04-02') },
  { _id: 6, name: 'Farah Ali',     email: 'farah@example.com',  city: 'Karachi',   is_active: true,  joined_at: ISODate('2024-04-18') },
  { _id: 7, name: 'Grace Okafor',  email: 'grace@example.com',  city: 'Lagos',     is_active: true,  joined_at: ISODate('2024-05-09') },
  { _id: 8, name: 'Hassan Raza',   email: 'hassan@example.com', city: 'Multan',    is_active: false, joined_at: ISODate('2024-05-25') },
  { _id: 9, name: 'Ivy Santos',    email: 'ivy@example.com',    city: 'Manila',    is_active: true,  joined_at: ISODate('2024-06-14') },
  { _id: 10, name: 'Junaid Sheikh', email: 'junaid@example.com', city: 'Karachi',  is_active: true,  joined_at: ISODate('2024-07-01') }
]);

db.categories.insertMany([
  { _id: 1, name: 'Electronics' }, { _id: 2, name: 'Clothing' },
  { _id: 3, name: 'Books' }, { _id: 4, name: 'Home & Kitchen' },
  { _id: 5, name: 'Sports' }, { _id: 6, name: 'Beauty' },
  { _id: 7, name: 'Toys' }, { _id: 8, name: 'Groceries' }
]);

db.products.insertMany([
  { _id: 1,  name: 'Wireless Mouse',     category_id: 1, price: 2499.00, stock: 45,  tags: ['wireless', 'mouse'],   created_at: ISODate('2024-06-01') },
  { _id: 2,  name: 'Mechanical Keyboard',category_id: 1, price: 8500.00, stock: 12,  tags: ['keyboard'],           created_at: ISODate('2024-06-01') },
  { _id: 3,  name: 'USB-C Cable',        category_id: 1, price: 899.00,  stock: 120, tags: ['cable', 'usb'],       created_at: ISODate('2024-06-15') },
  { _id: 4,  name: 'Smartphone Stand',   category_id: 1, price: 1500.00, stock: 0,   tags: ['stand'],              created_at: ISODate('2024-07-10') },
  { _id: 5,  name: 'Cotton T-Shirt',     category_id: 2, price: 1299.00, stock: 80,  tags: ['cotton', 'summer'],   created_at: ISODate('2024-07-20') },
  { _id: 6,  name: 'Denim Jacket',       category_id: 2, price: 5999.00, stock: 25,  tags: ['denim', 'winter'],    created_at: ISODate('2024-08-05') },
  { _id: 7,  name: 'Running Shoes',      category_id: 5, price: 7500.00, stock: 30,  tags: ['shoes', 'running'],   created_at: ISODate('2024-08-05') },
  { _id: 8,  name: 'Yoga Mat',           category_id: 5, price: 2200.00, stock: 18,  tags: ['yoga', 'fitness'],    created_at: ISODate('2024-08-20') },
  { _id: 9,  name: 'Introduction to SQL',category_id: 3, price: 1450.00, stock: 55,  tags: ['book', 'sql'],         created_at: ISODate('2024-09-01') },
  { _id: 10, name: 'Database Internals', category_id: 3, price: 3200.00, stock: 7,   tags: ['book', 'advanced'],   created_at: ISODate('2024-09-01') },
  { _id: 11, name: 'Chef Knife',         category_id: 4, price: 3800.00, stock: 22,  tags: ['kitchen', 'knife'],   created_at: ISODate('2024-09-15') },
  { _id: 12, name: 'Blender',            category_id: 4, price: 8999.00, stock: 9,   tags: ['kitchen', 'appliance'],created_at: ISODate('2024-09-15') },
  { _id: 13, name: 'Face Serum',         category_id: 6, price: 2500.00, stock: 40,  tags: ['skincare'],           created_at: ISODate('2024-10-01') },
  { _id: 14, name: 'Lip Balm',           category_id: 6, price: 450.00,  stock: 150, tags: ['skincare', 'lips'],   created_at: ISODate('2024-10-01') },
  { _id: 15, name: 'Building Blocks',    category_id: 7, price: 1999.00, stock: 26,  tags: ['toys', 'creative'],   created_at: ISODate('2024-10-10') },
  { _id: 16, name: 'Basmati Rice 5kg',   category_id: 8, price: 1800.00, stock: 60,  tags: ['grocery', 'rice'],     created_at: ISODate('2024-10-20') }
]);

db.orders.insertMany([
  { _id: 1, user_id: 1, status: 'delivered', total_amount: 3398.00, ordered_at: ISODate('2025-01-10'),
    items: [ { product_id: 1, quantity: 1, unit_price: 2499.00 }, { product_id: 3, quantity: 1, unit_price: 899.00 } ] },
  { _id: 2, user_id: 2, status: 'delivered', total_amount: 8500.00, ordered_at: ISODate('2025-01-22'),
    items: [ { product_id: 2, quantity: 1, unit_price: 8500.00 } ] },
  { _id: 3, user_id: 3, status: 'shipped', total_amount: 15000.00, ordered_at: ISODate('2025-02-05'),
    items: [ { product_id: 7, quantity: 2, unit_price: 7500.00 } ] },
  { _id: 4, user_id: 1, status: 'delivered', total_amount: 12799.00, ordered_at: ISODate('2025-02-14'),
    items: [ { product_id: 11, quantity: 1, unit_price: 3800.00 }, { product_id: 12, quantity: 1, unit_price: 8999.00 } ] },
  { _id: 5, user_id: 4, status: 'cancelled', total_amount: 5999.00, ordered_at: ISODate('2025-03-01'),
    items: [ { product_id: 6, quantity: 1, unit_price: 5999.00 } ] },
  { _id: 6, user_id: 6, status: 'delivered', total_amount: 4350.00, ordered_at: ISODate('2025-03-18'),
    items: [ { product_id: 9, quantity: 3, unit_price: 1450.00 } ] },
  { _id: 7, user_id: 7, status: 'shipped', total_amount: 7200.00, ordered_at: ISODate('2025-04-02'),
    items: [ { product_id: 8, quantity: 1, unit_price: 2200.00 }, { product_id: 13, quantity: 2, unit_price: 2500.00 } ] },
  { _id: 8, user_id: 2, status: 'pending', total_amount: 1999.00, ordered_at: ISODate('2025-04-25'),
    items: [ { product_id: 15, quantity: 1, unit_price: 1999.00 } ] },
  { _id: 9, user_id: 5, status: 'delivered', total_amount: 5798.00, ordered_at: ISODate('2025-05-06'),
    items: [ { product_id: 10, quantity: 1, unit_price: 3200.00 }, { product_id: 5, quantity: 2, unit_price: 1299.00 } ] },
  { _id: 10, user_id: 9, status: 'delivered', total_amount: 1800.00, ordered_at: ISODate('2025-06-11'),
    items: [ { product_id: 16, quantity: 1, unit_price: 1800.00 } ] },
  { _id: 11, user_id: 10, status: 'cancelled', total_amount: 1500.00, ordered_at: ISODate('2025-07-19'),
    items: [ { product_id: 4, quantity: 1, unit_price: 1500.00 } ] },
  { _id: 12, user_id: 3, status: 'delivered', total_amount: 9449.00, ordered_at: ISODate('2025-08-23'),
    items: [ { product_id: 12, quantity: 1, unit_price: 8999.00 }, { product_id: 14, quantity: 1, unit_price: 450.00 } ] }
]);

db.payments.insertMany([
  { _id: 1, order_id: 1, method: 'card', amount: 3398.00, paid_at: ISODate('2025-01-10') },
  { _id: 2, order_id: 2, method: 'card', amount: 8500.00, paid_at: ISODate('2025-01-23') },
  { _id: 3, order_id: 3, method: 'wallet', amount: 15000.00, paid_at: ISODate('2025-02-05') },
  { _id: 4, order_id: 4, method: 'cod', amount: 12799.00, paid_at: ISODate('2025-02-14') },
  { _id: 5, order_id: 6, method: 'card', amount: 4350.00, paid_at: ISODate('2025-03-18') },
  { _id: 6, order_id: 7, method: 'card', amount: 7200.00, paid_at: ISODate('2025-04-02') },
  { _id: 7, order_id: 9, method: 'wallet', amount: 5798.00, paid_at: ISODate('2025-05-06') },
  { _id: 8, order_id: 10, method: 'cod', amount: 1800.00, paid_at: ISODate('2025-06-11') },
  { _id: 9, order_id: 12, method: 'card', amount: 9449.00, paid_at: ISODate('2025-08-23') }
]);

db.reviews.insertMany([
  { _id: 1, product_id: 1, user_id: 1, rating: 5, comment: 'Smooth and responsive.', created_at: ISODate('2025-01-12') },
  { _id: 2, product_id: 2, user_id: 2, rating: 4, comment: 'Great feel, a bit loud.', created_at: ISODate('2025-01-25') },
  { _id: 3, product_id: 7, user_id: 3, rating: 5, comment: 'Perfect for daily runs.', created_at: ISODate('2025-02-08') },
  { _id: 4, product_id: 12, user_id: 1, rating: 2, comment: 'Stopped working after a month.', created_at: ISODate('2025-02-20') },
  { _id: 5, product_id: 9, user_id: 6, rating: 4, comment: 'Clear examples.', created_at: ISODate('2025-03-20') },
  { _id: 6, product_id: 8, user_id: 7, rating: 3, comment: 'Slips a little on wood floors.', created_at: ISODate('2025-04-05') },
  { _id: 7, product_id: 5, user_id: 5, rating: 4, comment: 'Good quality cotton.', created_at: ISODate('2025-05-08') },
  { _id: 8, product_id: 16, user_id: 9, rating: 5, comment: 'Always fresh.', created_at: ISODate('2025-06-12') },
  { _id: 9, product_id: 10, user_id: 9, rating: 5, comment: 'Deep and practical.', created_at: ISODate('2025-06-15') },
  { _id: 10, product_id: 13, user_id: 7, rating: 4, comment: 'Light and absorbs quickly.', created_at: ISODate('2025-04-10') },
  { _id: 11, product_id: 14, user_id: 10, rating: 5, comment: 'Great value.', created_at: ISODate('2025-08-25') },
  { _id: 12, product_id: 11, user_id: 4, rating: 5, comment: 'Very sharp.', created_at: ISODate('2025-02-15') }
]);

print('✅ ecommerce dataset seeded: users 10, categories 8, products 16, orders 12 (items embedded), payments 9, reviews 12');

