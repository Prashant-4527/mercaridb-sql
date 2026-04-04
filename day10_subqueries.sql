-- ================================================
-- MercariDB -- Day 10
-- Topic: Subqueries — WHERE, FROM, SELECT
-- Author: Prashant
-- Date: 2026-04-01
-- ================================================

-- Run day9 fresh start block first OR this one:
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
-- SUBQUERY IN WHERE CLAUSE
-- Most common use — filter against a calculated value
-- ================================================

-- Products priced above platform average
SELECT title, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Most expensive product on platform
SELECT title, price
FROM products
WHERE price = (SELECT MAX(price) FROM products);

-- Cheapest product on platform
SELECT title, price
FROM products
WHERE price = (SELECT MIN(price) FROM products);

-- Tanaka's products (without knowing his user_id)
SELECT title, price, category
FROM products
WHERE seller_id = (
    SELECT user_id
    FROM users
    WHERE username = 'tanaka_hiroshi'
);

-- Japan sellers' products using IN
SELECT title, price, category
FROM products
WHERE seller_id IN (
    SELECT user_id
    FROM users
    WHERE country = 'Japan'
);

-- Products NOT from Indian sellers using NOT IN
SELECT title, price, category
FROM products
WHERE seller_id NOT IN (
    SELECT user_id
    FROM users
    WHERE country = 'India'
);

-- ================================================
-- SUBQUERY IN FROM CLAUSE (Derived Table)
-- Subquery creates a temporary virtual table
-- MUST have an alias!
-- ================================================

-- Average price per category — filter above 10000
SELECT category, avg_price
FROM (
    SELECT
        category,
        ROUND(AVG(price), 2) AS avg_price
    FROM products
    GROUP BY category
) AS category_summary
WHERE avg_price > 10000;

-- Seller revenue leaderboard using derived table
SELECT
    u.username,
    u.country,
    seller_stats.total_revenue
FROM users u
INNER JOIN (
    SELECT
        p.seller_id,
        SUM(o.amount) AS total_revenue
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY p.seller_id
) AS seller_stats ON u.user_id = seller_stats.seller_id
ORDER BY seller_stats.total_revenue DESC;

-- ================================================
-- SUBQUERY IN SELECT CLAUSE (Correlated)
-- Runs once per row of outer query — slower
-- Good for adding calculated columns
-- ================================================

-- Each product with its seller name
SELECT
    p.title,
    p.price,
    (SELECT u.username
     FROM users u
     WHERE u.user_id = p.seller_id) AS seller_name
FROM products p;

-- Each user with their total listing count
SELECT
    u.username,
    u.country,
    (SELECT COUNT(*)
     FROM products p
     WHERE p.seller_id = u.user_id) AS total_listings
FROM users u
ORDER BY total_listings DESC;

-- ================================================
-- SUBQUERY vs JOIN comparison
-- Same result, two approaches
-- ================================================

-- Method 1: JOIN (preferred — faster)
SELECT u.username, p.title, p.price
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE u.country = 'Japan';

-- Method 2: Subquery (cleaner for simple filters)
SELECT title, price
FROM products
WHERE seller_id IN (
    SELECT user_id FROM users WHERE country = 'Japan'
);

-- ================================================
-- Business queries (Mercari use cases)
-- ================================================

-- Above-average products with seller info
SELECT
    u.username AS seller,
    p.title,
    p.price
FROM products p
INNER JOIN users u ON p.seller_id = u.user_id
WHERE p.price > (SELECT AVG(price) FROM products)
ORDER BY p.price DESC;

-- Users who have never placed an order
SELECT username, country
FROM users
WHERE user_id NOT IN (
    SELECT DISTINCT buyer_id FROM orders
);

-- Most expensive product per category (correlated)
SELECT title, category, price
FROM products p1
WHERE price = (
    SELECT MAX(price)
    FROM products p2
    WHERE p2.category = p1.category
);

-- Sellers with above-average revenue
SELECT
    u.username,
    u.country,
    SUM(o.amount) AS revenue
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
INNER JOIN users u    ON p.seller_id  = u.user_id
GROUP BY u.user_id, u.username, u.country
HAVING SUM(o.amount) > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(amount) AS total
        FROM orders o2
        INNER JOIN products p2 ON o2.product_id = p2.product_id
        GROUP BY p2.seller_id
    ) AS seller_totals
);
