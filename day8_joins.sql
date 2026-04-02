-- ================================================
-- MercariDB -- Day 8
-- Topic: JOINs — INNER JOIN + LEFT JOIN
-- Author: Prashant
-- Date: 2026-03-30
-- ================================================

-- ================================================
-- FULL FRESH START — Run this first every time!
-- ================================================

DROP DATABASE IF EXISTS mercaridb;
CREATE DATABASE mercaridb;
USE mercaridb;

-- Users table
CREATE TABLE users (
    user_id    INT          NOT NULL AUTO_INCREMENT,
    username   VARCHAR(50)  NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    country    VARCHAR(50),
    age        INT,
    created_at DATETIME     DEFAULT NOW(),
    PRIMARY KEY (user_id)
);

-- Products table (seller_id links to users.user_id)
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

-- Users data
INSERT INTO users (username, email, country, age) VALUES
('prashant_jpr',   'prashant@gmail.com',   'India',   17),
('tanaka_hiroshi', 'tanaka@mercari.jp',    'Japan',   28),
('yuki_suzuki',    'yuki@gmail.com',       'Japan',   22),
('sarah_chen',     'sarah@yahoo.com',      'USA',     34),
('rahul_sharma',   'rahul@gmail.com',      'India',   26),
('amit_verma',     'amit@hotmail.com',     'India',   31),
('kenji_watanabe', 'kenji@docomo.jp',      'Japan',   19),
('lisa_mueller',   'lisa@gmail.de',        'Germany', 29),
('wang_fang',      'wang@qq.com',          'China',   24),
('priya_nair',     'priya@gmail.com',      'India',   20),
('carlos_mx',      'carlos@gmail.mx',      'Mexico',  27);

-- Products data
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

-- Verify both tables
SELECT * FROM users;
SELECT * FROM products;

-- ================================================
-- INNER JOIN
-- Returns ONLY rows that match in BOTH tables
-- Users without products = NOT included
-- ================================================

-- Basic INNER JOIN: which user is selling what?
SELECT
    users.username,
    users.country,
    products.title,
    products.price
FROM users
INNER JOIN products ON users.user_id = products.seller_id;

-- Same query with table aliases (professional way)
-- u = users, p = products
SELECT
    u.username,
    u.country,
    p.title,
    p.price,
    p.status
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id;

-- INNER JOIN + WHERE: only active products
SELECT
    u.username,
    p.title,
    p.price
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE p.status = 'active';

-- INNER JOIN + WHERE + ORDER BY: most expensive first
SELECT
    u.username,
    u.country,
    p.title,
    p.price
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE p.status = 'active'
ORDER BY p.price DESC;

-- INNER JOIN + GROUP BY: how many products per seller?
SELECT
    u.username,
    u.country,
    COUNT(p.product_id) AS total_listings
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
GROUP BY u.user_id, u.username, u.country
ORDER BY total_listings DESC;

-- ================================================
-- LEFT JOIN
-- Returns ALL rows from left table (users)
-- + matching rows from right table (products)
-- No match = NULL values for product columns
-- ================================================

-- ALL users + their products (NULL if no products)
SELECT
    u.username,
    u.country,
    p.title,
    p.price
FROM users u
LEFT JOIN products p ON u.user_id = p.seller_id;

-- LEFT JOIN superpower: find users with NO products
-- WHERE filters for NULL = no match found
SELECT
    u.username,
    u.country,
    u.age
FROM users u
LEFT JOIN products p ON u.user_id = p.seller_id
WHERE p.product_id IS NULL;
-- Real world: "Inactive users — send activation email!"

-- ================================================
-- INNER vs LEFT — key difference
-- ================================================

-- INNER JOIN: only sellers (users WITH products)
SELECT u.username, COUNT(p.product_id) AS listings
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
GROUP BY u.user_id, u.username;

-- LEFT JOIN: ALL users, 0 listings if no products
SELECT u.username, COUNT(p.product_id) AS listings
FROM users u
LEFT JOIN products p ON u.user_id = p.seller_id
GROUP BY u.user_id, u.username
ORDER BY listings DESC;

-- ================================================
-- Business queries (Mercari use cases)
-- ================================================

-- Electronics sellers + product details
SELECT
    u.username   AS seller,
    u.country,
    p.title,
    p.price
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE p.category = 'Electronics'
  AND p.status = 'active'
ORDER BY p.price DESC;

-- Japan sellers and their products
SELECT
    u.username AS japanese_seller,
    p.title,
    p.price,
    p.category
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE u.country = 'Japan'
ORDER BY p.price DESC;

-- Seller performance report
SELECT
    u.username,
    u.country,
    COUNT(p.product_id)  AS total_listings,
    SUM(p.price)         AS total_value,
    ROUND(AVG(p.price))  AS avg_price
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
GROUP BY u.user_id, u.username, u.country
ORDER BY total_value DESC;

-- Inactive sellers (no listings at all)
SELECT
    u.username,
    u.country,
    u.age
FROM users u
LEFT JOIN products p ON u.user_id = p.seller_id
WHERE p.product_id IS NULL;

-- ================================================
-- Homework queries
-- ================================================

-- Books category products + seller info
SELECT u.username, u.country, p.title, p.price
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE p.category = 'Books';

-- Sold products + who was the seller
SELECT u.username, p.title, p.price, p.status
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE p.status = 'sold';

-- India sellers total listings
SELECT u.username, COUNT(p.product_id) AS listings
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE u.country = 'India'
GROUP BY u.user_id, u.username
ORDER BY listings DESC;

-- Most expensive product + its seller
SELECT u.username, p.title, p.price
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
ORDER BY p.price DESC
LIMIT 1;
