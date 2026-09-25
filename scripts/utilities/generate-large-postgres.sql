-- ============================================================
-- LARGE e-commerce dataset — for performance & index lessons
-- ~50k users, 5k products, 200k orders, ~340k order_items
--
# Run via:  ./scripts/utilities/load-large-postgres.sh
# (creates database perf_lab, loads this file, runs ANALYZE)
--
# NOTE: no indexes are created here on purpose —
# you create them yourself in Day 22–24 (SQL) / Day 13–17 (PG).
-- ============================================================

SELECT setseed(0.42);   -- deterministic randomness

BEGIN;

DROP TABLE IF EXISTS big_order_items, big_orders, big_products, big_users CASCADE;

CREATE TABLE big_users (
    id         INT PRIMARY KEY,
    name       TEXT NOT NULL,
    email      TEXT NOT NULL,
    city       TEXT,
    is_active  BOOLEAN NOT NULL DEFAULT TRUE,
    joined_at  DATE NOT NULL
);

INSERT INTO big_users
SELECT g,
       'User ' || g,
       'user' || g || '@example.com',
       (ARRAY['Karachi','Lahore','Islamabad','Toronto','Istanbul','Lagos','Manila','London','Dubai'])[1 + floor(random()*9)::int],
       random() > 0.10,
       DATE '2024-01-01' + (random() * 500)::int
FROM generate_series(1, 50000) g;

CREATE TABLE big_products (
    id           INT PRIMARY KEY,
    name         TEXT NOT NULL,
    category_id  INT NOT NULL,
    price        NUMERIC(8,2) NOT NULL,
    stock        INT NOT NULL DEFAULT 0,
    created_at   DATE NOT NULL
);

INSERT INTO big_products
SELECT g,
       'Product ' || g,
       1 + floor(random()*8)::int,
       round((100 + random()*9900)::numeric, 2),
       floor(random()*200)::int,
       DATE '2024-01-01' + (random() * 400)::int
FROM generate_series(1, 5000) g;

CREATE TABLE big_orders (
    id            INT PRIMARY KEY,
    user_id       INT NOT NULL REFERENCES big_users(id),
    status        TEXT NOT NULL,
    total_amount  NUMERIC(10,2) NOT NULL,
    ordered_at    DATE NOT NULL
);

INSERT INTO big_orders
SELECT g,
       1 + floor(random()*50000)::int,
       (ARRAY['delivered','delivered','delivered','shipped','pending','cancelled'])[1 + floor(random()*6)::int],
       0,   -- fixed by the item totals below
       DATE '2024-06-01' + (random() * 500)::int
FROM generate_series(1, 200000) g;

CREATE TABLE big_order_items (
    id          INT PRIMARY KEY,
    order_id    INT NOT NULL REFERENCES big_orders(id),
    product_id  INT NOT NULL REFERENCES big_products(id),
    quantity    INT NOT NULL,
    unit_price  NUMERIC(8,2) NOT NULL
);

INSERT INTO big_order_items
SELECT g,
       g,                                   -- 1st item: same id as order
       1 + floor(random()*5000)::int,
       1 + floor(random()*3)::int,
       round((100 + random()*9900)::numeric, 2)
FROM generate_series(1, 200000) g;

INSERT INTO big_order_items
SELECT 200000 + g,
       g,                                   -- ~half the orders get a 2nd item
       1 + floor(random()*5000)::int,
       1 + floor(random()*3)::int,
       round((100 + random()*9900)::numeric, 2)
FROM generate_series(1, 100000) g;

INSERT INTO big_order_items
SELECT 300000 + g,
       g,                                   -- a third get a 3rd item
       1 + floor(random()*5000)::int,
       1 + floor(random()*3)::int,
       round((100 + random()*9900)::numeric, 2)
FROM generate_series(1, 40000) g;

-- Fix order totals to match their items (a realistic integrity repair)
UPDATE big_orders o
   SET total_amount = sub.total
  FROM (SELECT order_id, SUM(quantity * unit_price) AS total
          FROM big_order_items GROUP BY order_id) sub
 WHERE sub.order_id = o.id;

COMMIT;

ANALYZE big_users;
ANALYZE big_products;
ANALYZE big_orders;
ANALYZE big_order_items;
