-- ============================================================
-- E-COMMERCE dataset (small) — dbms-playground
-- Load:  ./scripts/seed/seed-postgres.sh ecommerce
-- Reset: ./scripts/reset/reset-postgres.sh ecommerce
-- Tables: users, categories, products, orders, order_items,
--         payments, reviews
-- ============================================================

BEGIN;

DROP TABLE IF EXISTS order_items, payments, reviews, orders, products, categories, users CASCADE;

CREATE TABLE users (
    id         INT PRIMARY KEY,
    name       TEXT NOT NULL,
    email      TEXT NOT NULL UNIQUE,
    city       TEXT,
    is_active  BOOLEAN NOT NULL DEFAULT TRUE,
    joined_at  DATE
);

CREATE TABLE categories (
    id    INT PRIMARY KEY,
    name  TEXT NOT NULL
);

CREATE TABLE products (
    id           INT PRIMARY KEY,
    name         TEXT NOT NULL,
    category_id  INT REFERENCES categories(id),
    price        NUMERIC(8,2) NOT NULL CHECK (price >= 0),
    stock        INT NOT NULL DEFAULT 0,
    created_at   DATE
);

CREATE TABLE orders (
    id            INT PRIMARY KEY,
    user_id       INT NOT NULL REFERENCES users(id),
    status        TEXT NOT NULL DEFAULT 'pending',   -- pending|shipped|delivered|cancelled
    total_amount  NUMERIC(10,2),
    ordered_at    DATE
);

CREATE TABLE order_items (
    id          INT PRIMARY KEY,
    order_id    INT NOT NULL REFERENCES orders(id),
    product_id  INT NOT NULL REFERENCES products(id),
    quantity    INT NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(8,2) NOT NULL
);

CREATE TABLE payments (
    id        INT PRIMARY KEY,
    order_id  INT NOT NULL UNIQUE REFERENCES orders(id),
    method    TEXT,                                   -- card|wallet|cod
    amount    NUMERIC(10,2) NOT NULL,
    paid_at   DATE
);

CREATE TABLE reviews (
    id          INT PRIMARY KEY,
    product_id  INT NOT NULL REFERENCES products(id),
    user_id     INT NOT NULL REFERENCES users(id),
    rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment     TEXT,
    created_at  DATE
);

INSERT INTO users (id, name, email, city, is_active, joined_at) VALUES
    (1,  'Ayesha Khan',   'ayesha@example.com',  'Karachi',   TRUE,  '2024-01-15'),
    (2,  'Bilal Ahmed',   'bilal@example.com',   'Lahore',    TRUE,  '2024-02-03'),
    (3,  'Chen Wei',      'chen@example.com',    'Toronto',   TRUE,  '2024-02-20'),
    (4,  'Dua Malik',     'dua@example.com',     'Islamabad', FALSE, '2024-03-11'),
    (5,  'Emre Yilmaz',   'emre@example.com',    'Istanbul',  TRUE,  '2024-04-02'),
    (6,  'Farah Ali',     'farah@example.com',   'Karachi',   TRUE,  '2024-04-18'),
    (7,  'Grace Okafor',  'grace@example.com',   'Lagos',     TRUE,  '2024-05-09'),
    (8,  'Hassan Raza',   'hassan@example.com',  'Multan',    FALSE, '2024-05-25'),
    (9,  'Ivy Santos',    'ivy@example.com',     'Manila',    TRUE,  '2024-06-14'),
    (10, 'Junaid Sheikh', 'junaid@example.com',  'Karachi',   TRUE,  '2024-07-01');

INSERT INTO categories (id, name) VALUES
    (1, 'Electronics'), (2, 'Clothing'), (3, 'Books'),
    (4, 'Home & Kitchen'), (5, 'Sports'), (6, 'Beauty'),
    (7, 'Toys'), (8, 'Groceries');

INSERT INTO products (id, name, category_id, price, stock, created_at) VALUES
    (1,  'Wireless Mouse',        1, 2499.00, 45,  '2024-06-01'),
    (2,  'Mechanical Keyboard',   1, 8500.00, 12,  '2024-06-01'),
    (3,  'USB-C Cable',           1, 899.00,  120, '2024-06-15'),
    (4,  'Smartphone Stand',      1, 1500.00, 0,   '2024-07-10'),
    (5,  'Cotton T-Shirt',        2, 1299.00, 80,  '2024-07-20'),
    (6,  'Denim Jacket',          2, 5999.00, 25,  '2024-08-05'),
    (7,  'Running Shoes',         5, 7500.00, 30,  '2024-08-05'),
    (8,  'Yoga Mat',              5, 2200.00, 18,  '2024-08-20'),
    (9,  'Introduction to SQL',    3, 1450.00, 55,  '2024-09-01'),
    (10, 'Database Internals',    3, 3200.00, 7,   '2024-09-01'),
    (11, 'Chef Knife',            4, 3800.00, 22,  '2024-09-15'),
    (12, 'Blender',               4, 8999.00, 9,   '2024-09-15'),
    (13, 'Face Serum',            6, 2500.00, 40,  '2024-10-01'),
    (14, 'Lip Balm',              6, 450.00,  150, '2024-10-01'),
    (15, 'Building Blocks',       7, 1999.00, 26,  '2024-10-10'),
    (16, 'Basmati Rice 5kg',      8, 1800.00, 60,  '2024-10-20');

INSERT INTO orders (id, user_id, status, total_amount, ordered_at) VALUES
    (1,  1,  'delivered', 3398.00,  '2025-01-10'),
    (2,  2,  'delivered', 8500.00,  '2025-01-22'),
    (3,  3,  'shipped',   15000.00, '2025-02-05'),
    (4,  1,  'delivered', 12799.00, '2025-02-14'),
    (5,  4,  'cancelled', 5999.00,  '2025-03-01'),
    (6,  6,  'delivered', 4350.00,  '2025-03-18'),
    (7,  7,  'shipped',   7200.00,  '2025-04-02'),
    (8,  2,  'pending',   1999.00,  '2025-04-25'),
    (9,  5,  'delivered', 5798.00,  '2025-05-06'),
    (10, 9,  'delivered', 1800.00,  '2025-06-11'),
    (11, 10, 'cancelled', 1500.00,  '2025-07-19'),
    (12, 3,  'delivered', 9449.00,  '2025-08-23');

INSERT INTO order_items (id, order_id, product_id, quantity, unit_price) VALUES
    (1,  1,  1,  1, 2499.00),
    (2,  1,  3,  1, 899.00),
    (3,  2,  2,  1, 8500.00),
    (4,  3,  7,  2, 7500.00),
    (5,  4,  11, 1, 3800.00),
    (6,  4,  12, 1, 8999.00),
    (7,  5,  6,  1, 5999.00),
    (8,  6,  9,  3, 1450.00),
    (9,  7,  8,  1, 2200.00),
    (10, 7,  13, 2, 2500.00),
    (11, 8,  15, 1, 1999.00),
    (12, 9,  10, 1, 3200.00),
    (13, 9,  5,  2, 1299.00),
    (14, 10, 16, 1, 1800.00),
    (15, 11, 4,  1, 1500.00),
    (16, 12, 12, 1, 8999.00),
    (17, 12, 14, 1, 450.00);

INSERT INTO payments (id, order_id, method, amount, paid_at) VALUES
    (1, 1,  'card',   3398.00,  '2025-01-10'),
    (2, 2,  'card',   8500.00,  '2025-01-23'),
    (3, 3,  'wallet', 15000.00, '2025-02-05'),
    (4, 4,  'cod',    12799.00, '2025-02-14'),
    (5, 6,  'card',   4350.00,  '2025-03-18'),
    (6, 7,  'card',   7200.00,  '2025-04-02'),
    (7, 9,  'wallet', 5798.00,  '2025-05-06'),
    (8, 10, 'cod',    1800.00,  '2025-06-11'),
    (9, 12, 'card',   9449.00,  '2025-08-23');

INSERT INTO reviews (id, product_id, user_id, rating, comment, created_at) VALUES
    (1,  1,  1,  5, 'Smooth and responsive.',          '2025-01-12'),
    (2,  2,  2,  4, 'Great feel, a bit loud.',         '2025-01-25'),
    (3,  7,  3,  5, 'Perfect for daily runs.',         '2025-02-08'),
    (4,  12, 1,  2, 'Stopped working after a month.',  '2025-02-20'),
    (5,  9,  6,  4, 'Clear examples.',                 '2025-03-20'),
    (6,  8,  7,  3, 'Slips a little on wood floors.',  '2025-04-05'),
    (7,  5,  5,  4, 'Good quality cotton.',            '2025-05-08'),
    (8,  16, 9,  5, 'Always fresh.',                   '2025-06-12'),
    (9,  10, 9,  5, 'Deep and practical.',            '2025-06-15'),
    (10, 13, 7,  4, 'Light and absorbs quickly.',     '2025-04-10'),
    (11, 14, 10, 5, 'Great value.',                    '2025-08-25'),
    (12, 11, 4,  5, 'Very sharp.',                     '2025-02-15');

COMMIT;

-- Sanity check (each should return the count shown):
-- users 10 | categories 8 | products 16 | orders 12 | order_items 17 | payments 9 | reviews 12

