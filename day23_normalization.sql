-- ================================================
-- MercariDB -- Day 23
-- Topic: Normalization — 1NF, 2NF, 3NF
-- Author: Prashant
-- Date: 2026-04-11
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
-- 1NF — FIRST NORMAL FORM
-- Rule: Atomic values only + unique rows + no repeating groups
-- ================================================

-- ❌ 1NF VIOLATION: multiple values in one cell
CREATE TABLE orders_bad_1nf (
    order_id   INT,
    buyer_name VARCHAR(50),
    products   VARCHAR(200)   -- "iPhone, iPad" = VIOLATION!
);

INSERT INTO orders_bad_1nf VALUES
(1, 'Prashant', 'iPhone, iPad'),
(2, 'Tanaka',   'Nike, Keyboard');

SELECT * FROM orders_bad_1nf;
-- Cannot filter/sort/count individual products!

-- ❌ 1NF VIOLATION: repeating columns
CREATE TABLE orders_bad_1nf_v2 (
    order_id INT,
    buyer    VARCHAR(50),
    product1 VARCHAR(100),    -- repeating group!
    product2 VARCHAR(100),    -- repeating group!
    product3 VARCHAR(100)     -- repeating group!
    -- What if 4th product needed? Must ALTER TABLE!
);

-- ✅ 1NF COMPLIANT: our MercariDB structure
-- One value per cell, one product per row
SELECT
    o.order_id,
    u.username AS buyer,
    p.title    AS product,
    o.amount
FROM orders o
INNER JOIN users u    ON o.buyer_id   = u.user_id
INNER JOIN products p ON o.product_id = p.product_id;

-- Clean up bad tables
DROP TABLE orders_bad_1nf;
DROP TABLE orders_bad_1nf_v2;

-- ================================================
-- 2NF — SECOND NORMAL FORM
-- Rule: 1NF + no partial dependencies
-- (Only relevant with composite primary keys)
-- Every non-key column must depend on ENTIRE PK
-- ================================================

-- ❌ 2NF VIOLATION example:
-- Imagine: PRIMARY KEY = (order_id, product_id)
-- | order_id | product_id | buyer_name | product_title | qty |
-- buyer_name depends only on order_id (partial dependency!)
-- product_title depends only on product_id (partial dependency!)

-- ✅ 2NF FIX: separate tables
-- orders table: order_id PK → buyer_id, amount, order_date
-- products table: product_id PK → title, price, category
-- order_items: (order_id, product_id) PK → quantity

-- Our MercariDB is 2NF compliant!
-- orders: only order-specific data
SELECT order_id, buyer_id, product_id, amount, order_date FROM orders;
-- products: only product-specific data
SELECT product_id, seller_id, title, category, price FROM products;

-- ================================================
-- 3NF — THIRD NORMAL FORM
-- Rule: 2NF + no transitive dependencies
-- Non-key columns must depend ONLY on the PK
-- NOT on other non-key columns
-- ================================================

-- ❌ 3NF VIOLATION example:
-- | user_id | username | zip_code | city   | state     |
-- city and state depend on zip_code (not directly on user_id!)
-- This is a transitive dependency: user_id → zip_code → city

-- ✅ 3NF FIX: extract to separate table
CREATE TABLE zip_codes (
    zip_code VARCHAR(10)  NOT NULL,
    city     VARCHAR(100) NOT NULL,
    state    VARCHAR(100),
    country  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (zip_code)
);

INSERT INTO zip_codes VALUES
('302001', 'Jaipur',   'Rajasthan', 'India'),
('100001', 'Tokyo',    'Tokyo',     'Japan'),
('10001',  'New York', 'NY',        'USA');

SELECT * FROM zip_codes;
-- Now city/state depend directly on zip_code PK
-- No transitive dependency!

DROP TABLE zip_codes;

-- ================================================
-- MERCARIDB NORMALIZATION PROOF
-- ================================================

-- users table: 3NF ✅
-- Every column depends only on user_id (PK)
DESCRIBE users;

-- products table: 3NF ✅
-- seller info NOT stored here — just seller_id FK
-- seller name/email accessed via JOIN
DESCRIBE products;

-- orders table: 3NF ✅
-- buyer info NOT stored — just buyer_id FK
-- product info NOT stored — just product_id FK
DESCRIBE orders;

-- ================================================
-- ANOMALY DEMONSTRATION
-- ================================================

-- UPDATE ANOMALY (why normalization matters):
-- ❌ Denormalized: seller email stored in EVERY order row
-- Change email = update THOUSANDS of rows!

-- ✅ Normalized: email stored ONCE in users table
-- Change email = update ONE row, all JOINs reflect it!
UPDATE users
SET email = 'newtanaka@mercari.jp'
WHERE username = 'tanaka_hiroshi';

-- All queries that JOIN users automatically get new email!
SELECT u.username, u.email, p.title
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE u.username = 'tanaka_hiroshi';

-- Revert:
UPDATE users
SET email = 'tanaka@mercari.jp'
WHERE username = 'tanaka_hiroshi';

-- ================================================
-- DENORMALIZED vs NORMALIZED COMPARISON
-- ================================================

-- ❌ DENORMALIZED (bad design):
CREATE TABLE orders_denormalized (
    order_id      INT,
    buyer_name    VARCHAR(50),    -- redundant!
    buyer_email   VARCHAR(100),   -- redundant!
    buyer_country VARCHAR(50),    -- redundant!
    product_title VARCHAR(200),   -- redundant!
    product_price DECIMAL(10,2),  -- redundant!
    seller_name   VARCHAR(50),    -- redundant!
    seller_email  VARCHAR(100),   -- redundant!
    amount        DECIMAL(10,2)
);
-- Problems: update anomaly, insert anomaly, delete anomaly
-- 7 redundant columns per order row!

-- ✅ NORMALIZED (our design):
-- orders: order_id, product_id, buyer_id, amount, order_date
-- Everything else accessed via JOIN — zero redundancy!
SELECT
    o.order_id,
    buyer.username   AS buyer_name,
    buyer.email      AS buyer_email,
    buyer.country    AS buyer_country,
    p.title          AS product_title,
    p.price          AS product_price,
    seller.username  AS seller_name,
    seller.email     AS seller_email,
    o.amount
FROM orders o
INNER JOIN users buyer  ON o.buyer_id   = buyer.user_id
INNER JOIN products p   ON o.product_id = p.product_id
INNER JOIN users seller ON p.seller_id  = seller.user_id;

DROP TABLE orders_denormalized;

-- ================================================
-- OLTP vs OLAP
-- ================================================

-- OLTP (Online Transaction Processing) = our MercariDB
-- Highly normalized (3NF)
-- Many small INSERT/UPDATE/DELETE operations
-- Data integrity critical

-- OLAP (Online Analytical Processing) = Data Warehouse
-- Denormalized (star schema / snowflake schema)
-- Few large analytical SELECT queries
-- Read performance critical

SELECT
    'OLTP'                    AS system_type,
    'Highly normalized (3NF)' AS design,
    'Data integrity'          AS priority,
    'INSERT/UPDATE/DELETE'    AS operations
UNION ALL
SELECT
    'OLAP',
    'Denormalized (Star Schema)',
    'Query performance',
    'Large SELECT queries';

-- ================================================
-- NORMALIZATION QUICK REFERENCE
-- ================================================
-- 1NF: atomic values + unique rows + no repeating groups
-- 2NF: 1NF + no partial dependencies (full PK dependency)
-- 3NF: 2NF + no transitive dependencies (key only dependency)
-- BCNF: stronger 3NF — every determinant is candidate key

-- MEMORY AID:
-- "The key (1NF),
--  the whole key (2NF),
--  and nothing but the key (3NF),
--  so help me Codd." — Edgar F. Codd (SQL inventor!)
