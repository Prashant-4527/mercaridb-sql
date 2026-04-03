-- ================================================
-- MercariDB -- Day 9
-- Topic: RIGHT JOIN, SELF JOIN, Multi-table JOINs
-- Author: Prashant
-- Date: 2026-03-31
-- ================================================

-- Run day8_joins.sql first to set up users + products tables
-- OR run the fresh start block below

-- ================================================
-- FRESH START (if needed)
-- ================================================

DROP DATABASE IF EXISTS mercaridb;
CREATE DATABASE mercaridb;
USE mercaridb;

CREATE TABLE users (
    user_id    INT          NOT NULL AUTO_INCREMENT,
    username   VARCHAR(50)  NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    country    VARCHAR(50),
    age        INT,
    referred_by INT         DEFAULT NULL,
    created_at DATETIME     DEFAULT NOW(),
    PRIMARY KEY (user_id)
);

CREATE TABLE products (
    product_id  INT            NOT NULL AUTO_INCREMENT,
    seller_id   INT            NOT NULL,
    title       VARCHAR(200)   NOT NULL,
    category    VARCHAR(100),
    price       DECIMAL(10,2)  NOT NULL,
    status      VARCHAR(20)    DEFAULT 'active',
    PRIMARY KEY (product_id),
    FOREIGN KEY (seller_id) REFERENCES users(user_id)
);

CREATE TABLE orders (
    order_id    INT           NOT NULL AUTO_INCREMENT,
    product_id  INT           NOT NULL,
    buyer_id    INT           NOT NULL,
    amount      DECIMAL(10,2) NOT NULL,
    order_date  DATETIME      DEFAULT NOW(),
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
-- RIGHT JOIN
-- Returns ALL rows from right table (products)
-- + matching rows from left table (users)
-- Opposite of LEFT JOIN
-- ================================================

-- All products + their seller (right table = products)
SELECT
    u.username,
    u.country,
    p.title,
    p.price
FROM users u
RIGHT JOIN products p ON u.user_id = p.seller_id;

-- Interview note: this is same as LEFT JOIN with tables swapped
-- Preferred way (LEFT JOIN version):
SELECT
    u.username,
    p.title,
    p.price
FROM products p
LEFT JOIN users u ON p.seller_id = u.user_id;

-- ================================================
-- SELF JOIN
-- A table joining with itself
-- Use case: referrals, hierarchies, org charts
-- ================================================

-- Who referred whom?
-- u1 = the referred user, u2 = the referrer
SELECT
    u1.username                          AS user_name,
    u2.username                          AS referred_by_user
FROM users u1
INNER JOIN users u2 ON u1.referred_by = u2.user_id;

-- All users + their referrer (NULL if no referrer)
SELECT
    u1.username                            AS user_name,
    COALESCE(u2.username, 'No referrer')   AS referred_by
FROM users u1
LEFT JOIN users u2 ON u1.referred_by = u2.user_id;

-- Top referrers: who referred most people?
SELECT
    u2.username       AS referrer,
    u2.country,
    COUNT(u1.user_id) AS people_referred
FROM users u1
INNER JOIN users u2 ON u1.referred_by = u2.user_id
GROUP BY u2.user_id, u2.username, u2.country
ORDER BY people_referred DESC;

-- ================================================
-- MULTI-TABLE JOIN (3 tables)
-- users + products + orders
-- ================================================

-- Full order details: buyer + product + seller + amount
SELECT
    buyer.username  AS buyer,
    seller.username AS seller,
    p.title         AS product,
    p.category,
    o.amount
FROM orders o
INNER JOIN users buyer   ON o.buyer_id   = buyer.user_id
INNER JOIN products p    ON o.product_id = p.product_id
INNER JOIN users seller  ON p.seller_id  = seller.user_id
ORDER BY o.amount DESC;

-- Total revenue per seller
SELECT
    seller.username   AS seller,
    seller.country,
    COUNT(o.order_id) AS orders_received,
    SUM(o.amount)     AS total_revenue
FROM orders o
INNER JOIN products p    ON o.product_id = p.product_id
INNER JOIN users seller  ON p.seller_id  = seller.user_id
GROUP BY seller.user_id, seller.username, seller.country
ORDER BY total_revenue DESC;

-- Buyer purchase history
SELECT
    buyer.username AS buyer,
    buyer.country,
    p.title,
    p.category,
    o.amount,
    o.order_date
FROM orders o
INNER JOIN users buyer ON o.buyer_id   = buyer.user_id
INNER JOIN products p  ON o.product_id = p.product_id
ORDER BY buyer.username, o.amount DESC;

-- ================================================
-- Business queries (Mercari use cases)
-- ================================================

-- Cross-country transactions: India buyers + Japan sellers
SELECT
    buyer.username  AS indian_buyer,
    seller.username AS japanese_seller,
    p.title,
    o.amount
FROM orders o
INNER JOIN users buyer  ON o.buyer_id   = buyer.user_id
INNER JOIN products p   ON o.product_id = p.product_id
INNER JOIN users seller ON p.seller_id  = seller.user_id
WHERE buyer.country  = 'India'
  AND seller.country = 'Japan';

-- Unsold inventory: products with no orders
SELECT
    p.title,
    p.price,
    p.category,
    u.username AS seller
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
INNER JOIN users u ON p.seller_id  = u.user_id
WHERE o.order_id IS NULL;

-- Platform summary: total orders + total revenue
SELECT
    COUNT(o.order_id) AS total_orders,
    SUM(o.amount)     AS total_revenue,
    ROUND(AVG(o.amount)) AS avg_order_value
FROM orders o;
