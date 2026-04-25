-- ================================================
-- MercariDB -- Day 22
-- Topic: Query Optimization + EXPLAIN + Indexes
-- Author: Prashant
-- Date: 2026-04-10
-- ================================================

DROP DATABASE IF EXISTS mercaridb;
CREATE DATABASE mercaridb;
USE mercaridb;

CREATE TABLE users (
    user_id     INT          NOT NULL AUTO_INCREMENT,
    username    VARCHAR(50)  NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    country     VARCHAR(50),
    age         INT,
    referred_by INT          DEFAULT NULL,
    created_at  DATETIME     DEFAULT NOW(),
    PRIMARY KEY (user_id)
);

CREATE TABLE products (
    product_id INT            NOT NULL AUTO_INCREMENT,
    seller_id  INT            NOT NULL,
    title      VARCHAR(200)   NOT NULL,
    category   VARCHAR(100),
    price      DECIMAL(10,2)  NOT NULL,
    status     VARCHAR(20)    DEFAULT 'active',
    PRIMARY KEY (product_id),
    FOREIGN KEY (seller_id) REFERENCES users(user_id)
);

CREATE TABLE orders (
    order_id   INT           NOT NULL AUTO_INCREMENT,
    product_id INT           NOT NULL,
    buyer_id   INT           NOT NULL,
    amount     DECIMAL(10,2) NOT NULL,
    order_date DATETIME      DEFAULT NOW(),
    PRIMARY KEY (order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (buyer_id)   REFERENCES users(user_id)
);

INSERT INTO users (username, email, country, age, referred_by) VALUES
('prashant_jpr',   'prashant@gmail.com',   'India',   17, 2),
('tanaka_hiroshi', 'tanaka@mercari.jp',    'Japan',   28, NULL),
('yuki_suzuki',    'yuki@gmail.com',       'Japan',   22, 2),
('sarah_chen',     'sarah@yahoo.com',      'USA',     34, NULL),
('rahul_sharma',   'rahul@gmail.com',      'India',   26, 1),
('amit_verma',     'amit@hotmail.com',     'India',   31, NULL),
('kenji_watanabe', 'kenji@docomo.jp',      'Japan',   19, NULL),
('lisa_mueller',   'lisa@gmail.de',        'Germany', 29, NULL),
('wang_fang',      'wang@qq.com',          'China',   24, NULL),
('priya_nair',     'priya@gmail.com',      'India',   20, 5),
('carlos_mx',      'carlos@gmail.mx',      'Mexico',  27, NULL);

INSERT INTO products (seller_id, title, category, price, status) VALUES
(2,  'iPhone 13 Pro 256GB',         'Electronics',  45000.00, 'active'),
(2,  'Sony WH-1000XM4 Headphones',  'Electronics',  18000.00, 'active'),
(3,  'Nike Air Max 2021',            'Fashion',       8500.00, 'sold'),
(4,  'Python Programming Book',      'Books',         1200.00, 'active'),
(5,  'Dell Monitor 27 inch',         'Electronics',  22000.00, 'active'),
(6,  'Vintage Camera Film Roll',     'Photography',   3500.00, 'active'),
(7,  'Mechanical Keyboard RGB',      'Electronics',   7800.00, 'active'),
(8,  'Levi Jeans 512 Slim',         'Fashion',        4200.00, 'sold'),
(2,  'iPad Air 5th Gen',             'Electronics',  55000.00, 'active'),
(5,  'Logitech MX Master 3',         'Electronics',   8900.00, 'active'),
(1,  'Data Science Handbook',        'Books',         1800.00, 'active'),
(3,  'Adidas Ultraboost 22',         'Fashion',       9500.00, 'active'),
(10, 'Yoga Mat Premium',             'Sports',        2200.00, 'active');

INSERT INTO orders (product_id, buyer_id, amount) VALUES
(1,  5,  45000.00),
(3,  1,   8500.00),
(4,  7,   1200.00),
(8,  3,   4200.00),
(9,  6,  55000.00),
(11, 2,   1800.00),
(13, 4,   2200.00);

-- ================================================
-- EXPLAIN — understand query execution
-- type=ALL  = full table scan (BAD on large tables)
-- type=ref  = index lookup (GOOD)
-- key=NULL  = no index used (potential problem)
-- rows      = estimated rows read (lower = better)
-- ================================================

-- Before index: full table scan
EXPLAIN SELECT * FROM users WHERE country = 'India';
-- type=ALL, key=NULL → reads every row

-- Before index: full scan on products
EXPLAIN SELECT * FROM products WHERE category = 'Electronics';
-- type=ALL → on 50M rows this would be very slow!

-- ================================================
-- CREATE INDEXES
-- ================================================

-- Single column indexes
CREATE INDEX idx_country  ON users(country);
CREATE INDEX idx_category ON products(category);
CREATE INDEX idx_status   ON products(status);

-- After index: fast lookup
EXPLAIN SELECT * FROM users WHERE country = 'India';
-- type=ref, key=idx_country → using index!

EXPLAIN SELECT * FROM products WHERE category = 'Electronics';
-- type=ref, key=idx_category → fast!

-- Composite index: multiple columns
-- Useful when filtering by both columns together
CREATE INDEX idx_cat_status ON products(category, status);

EXPLAIN SELECT * FROM products
WHERE category = 'Electronics' AND status = 'active';
-- Uses composite index!

-- Composite index: leftmost prefix rule
-- Can use idx_cat_status for:
EXPLAIN SELECT * FROM products WHERE category = 'Electronics'; -- YES
-- Cannot efficiently use for:
EXPLAIN SELECT * FROM products WHERE status = 'active';        -- NO (status alone)

-- Index on Foreign Keys (critical for JOIN performance!)
CREATE INDEX idx_seller_id  ON products(seller_id);
CREATE INDEX idx_buyer_id   ON orders(buyer_id);
CREATE INDEX idx_product_id ON orders(product_id);

-- JOIN with indexes: much faster
EXPLAIN
SELECT u.username, p.title, p.price
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE u.country = 'Japan';
-- Both tables using indexes now!

-- See all indexes
SHOW INDEX FROM users;
SHOW INDEX FROM products;
SHOW INDEX FROM orders;

-- ================================================
-- SLOW vs FAST QUERY PATTERNS
-- ================================================

-- ❌ SLOW: Function on indexed column breaks index
EXPLAIN SELECT * FROM users WHERE YEAR(created_at) = 2026;
-- type=ALL → function wrapping column = no index!

-- ✅ FAST: Range condition uses index
EXPLAIN SELECT * FROM users
WHERE created_at BETWEEN '2026-01-01' AND '2026-12-31';

-- ❌ SLOW: Leading wildcard
EXPLAIN SELECT * FROM users WHERE email LIKE '%gmail%';
-- type=ALL → leading % = full scan!

-- ✅ FASTER: No leading wildcard
EXPLAIN SELECT * FROM users WHERE username LIKE 'pra%';
-- Can use index on username!

-- ❌ SLOW: OR instead of IN
SELECT * FROM users
WHERE country = 'India' OR country = 'Japan' OR country = 'USA';

-- ✅ FAST: IN is cleaner and faster
SELECT * FROM users WHERE country IN ('India', 'Japan', 'USA');

-- ❌ SLOW: SELECT * (all columns, wastes bandwidth)
SELECT * FROM products;

-- ✅ FAST: Select only needed columns
SELECT title, price, category FROM products WHERE status = 'active';

-- ❌ SLOW: Correlated subquery (N+1 problem)
SELECT p.title,
    (SELECT u.username FROM users u WHERE u.user_id = p.seller_id) AS seller
FROM products p;

-- ✅ FAST: JOIN (single pass)
SELECT p.title, u.username AS seller
FROM products p
INNER JOIN users u ON p.seller_id = u.user_id;

-- ❌ SLOW: NOT IN with possible NULLs
SELECT username FROM users
WHERE user_id NOT IN (SELECT buyer_id FROM orders);

-- ✅ FAST + NULL SAFE: NOT EXISTS
SELECT username FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.buyer_id = u.user_id
);

-- ❌ SLOW: Large OFFSET pagination
-- SELECT * FROM products ORDER BY price DESC LIMIT 10 OFFSET 10000;

-- ✅ FAST: Cursor-based pagination
SELECT * FROM products
WHERE product_id > 5        -- last seen ID from previous page
ORDER BY product_id
LIMIT 5;

-- ================================================
-- QUERY REWRITES
-- ================================================

-- Rewrite: multiple separate queries → one GROUP BY
-- ❌ Three queries:
-- SELECT COUNT(*) FROM users WHERE country = 'India';
-- SELECT COUNT(*) FROM users WHERE country = 'Japan';
-- SELECT COUNT(*) FROM users WHERE country = 'USA';

-- ✅ One query:
SELECT country, COUNT(*) AS users
FROM users
WHERE country IN ('India', 'Japan', 'USA')
GROUP BY country;

-- Rewrite: nested subqueries → CTE (readable + debuggable)
-- ❌ Nested mess:
SELECT username FROM (
    SELECT u.username, SUM(o.amount) AS rev
    FROM users u
    INNER JOIN (
        SELECT o.buyer_id, o.amount FROM orders o
        WHERE o.amount > 1000
    ) o ON u.user_id = o.buyer_id
    GROUP BY u.user_id, u.username
) AS sub
WHERE rev > 5000;

-- ✅ CTE version:
WITH large_orders AS (
    SELECT buyer_id, amount FROM orders WHERE amount > 1000
),
buyer_revenue AS (
    SELECT u.username, SUM(lo.amount) AS rev
    FROM users u
    INNER JOIN large_orders lo ON u.user_id = lo.buyer_id
    GROUP BY u.user_id, u.username
)
SELECT username FROM buyer_revenue WHERE rev > 5000;

-- ================================================
-- EXPLAIN EXTENDED — more details
-- ================================================

EXPLAIN FORMAT=JSON
SELECT u.username, p.title, p.price
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE u.country = 'Japan'
  AND p.status = 'active'
ORDER BY p.price DESC;
-- JSON format shows detailed cost estimates!

-- ================================================
-- OPTIMIZATION CHECKLIST
-- ================================================
-- Before deploying any query to production:
-- 1. Run EXPLAIN — check for type=ALL on large tables
-- 2. Check key column — NULL means no index (add one?)
-- 3. Check rows column — can it be reduced?
-- 4. Avoid SELECT * — list only needed columns
-- 5. Avoid functions on indexed columns in WHERE
-- 6. Use NOT EXISTS over NOT IN
-- 7. Use IN over multiple ORs
-- 8. Replace correlated subqueries with JOINs
-- 9. Add indexes on FK columns used in JOINs
-- 10. Use LIMIT for development queries

-- ================================================
-- Clean up indexes (optional — keep if you want)
-- ================================================
DROP INDEX idx_country     ON users;
DROP INDEX idx_category    ON products;
DROP INDEX idx_status      ON products;
DROP INDEX idx_cat_status  ON products;
DROP INDEX idx_seller_id   ON products;
DROP INDEX idx_buyer_id    ON orders;
DROP INDEX idx_product_id  ON orders;
