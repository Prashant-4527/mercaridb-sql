-- ================================================
-- MercariDB -- Day 11
-- Topic: EXISTS + NOT EXISTS
-- Author: Prashant
-- Date: 2026-04-02
-- ================================================

-- Run day10 fresh start block first OR this one:
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
-- EXISTS
-- Returns TRUE if subquery finds at least one row
-- SELECT 1 = we only care about existence, not value
-- ================================================

-- Users who have placed at least one order
SELECT u.username, u.country
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.buyer_id = u.user_id
);

-- ================================================
-- NOT EXISTS
-- Returns TRUE if subquery finds NO rows
-- ================================================

-- Users who have NEVER placed an order
SELECT u.username, u.country
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.buyer_id = u.user_id
);
-- Real world: "Inactive buyers — send discount email!"

-- ================================================
-- EXISTS vs IN vs JOIN — same result, 3 ways
-- ================================================

-- Method 1: EXISTS (fastest on large data, NULL-safe)
SELECT username FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.buyer_id = u.user_id
);

-- Method 2: IN (simple, readable)
SELECT username FROM users
WHERE user_id IN (
    SELECT buyer_id FROM orders
);

-- Method 3: JOIN (also common)
SELECT DISTINCT u.username
FROM users u
INNER JOIN orders o ON u.user_id = o.buyer_id;

-- ================================================
-- NOT IN vs NOT EXISTS — critical NULL difference!
-- NOT EXISTS is always safer — use this in production
-- ================================================

-- NOT IN — dangerous if NULLs exist in subquery
SELECT username FROM users
WHERE user_id NOT IN (
    SELECT buyer_id FROM orders
);

-- NOT EXISTS — always correct even with NULLs
SELECT username FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.buyer_id = u.user_id
);

-- ================================================
-- EXISTS with multiple conditions
-- ================================================

-- Japan users who have placed orders
SELECT u.username, u.country
FROM users u
WHERE u.country = 'Japan'
AND EXISTS (
    SELECT 1 FROM orders o
    WHERE o.buyer_id = u.user_id
);

-- Products that have been sold at least once
SELECT p.title, p.price, p.category
FROM products p
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.product_id = p.product_id
);

-- Products that have NEVER been sold (dead stock)
SELECT p.title, p.price, p.category
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.product_id = p.product_id
);
-- Real world: "Dead stock report"

-- Sellers with at least one active listing
SELECT u.username, u.country
FROM users u
WHERE EXISTS (
    SELECT 1 FROM products p
    WHERE p.seller_id = u.user_id
    AND p.status = 'active'
);

-- Power users: both buying AND selling
SELECT u.username, u.country
FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.buyer_id = u.user_id
)
AND EXISTS (
    SELECT 1 FROM products p
    WHERE p.seller_id = u.user_id
);
-- Real world: "Most engaged users on platform"

-- ================================================
-- Business queries (Mercari use cases)
-- ================================================

-- India active sellers
SELECT u.username, u.country, u.age
FROM users u
WHERE u.country = 'India'
AND EXISTS (
    SELECT 1 FROM products p
    WHERE p.seller_id = u.user_id
    AND p.status = 'active'
);

-- Sellers who made at least one Electronics sale
SELECT DISTINCT u.username, u.country
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM products p
    INNER JOIN orders o ON p.product_id = o.product_id
    WHERE p.seller_id = u.user_id
    AND p.category = 'Electronics'
);

-- Completely inactive users: never bought, never sold
SELECT u.username, u.country, u.age
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.buyer_id = u.user_id
)
AND NOT EXISTS (
    SELECT 1 FROM products p
    WHERE p.seller_id = u.user_id
);
-- Real world: "Ghost accounts — cleanup candidates"
