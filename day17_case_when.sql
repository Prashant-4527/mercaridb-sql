-- ================================================
-- MercariDB -- Day 17
-- Topic: CASE WHEN — SQL's If-Else
-- Author: Prashant
-- Date: 2026-04-06
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
-- BASIC CASE WHEN
-- Searched CASE: full boolean expressions
-- ================================================

-- Age generation labels
SELECT
    username,
    age,
    CASE
        WHEN age < 20              THEN 'Teen'
        WHEN age BETWEEN 20 AND 26 THEN 'Gen Z'
        WHEN age BETWEEN 27 AND 42 THEN 'Millennial'
        ELSE                            'Other'
    END AS generation
FROM users;

-- Product price tiers
SELECT
    title,
    price,
    CASE
        WHEN price < 5000  THEN 'Budget'
        WHEN price < 20000 THEN 'Mid-range'
        ELSE                    'Premium'
    END AS price_tier
FROM products
ORDER BY price;

-- ================================================
-- SIMPLE CASE (exact value match)
-- Like a switch statement
-- ================================================

-- Country to region mapping
SELECT
    u.username,
    u.country,
    CASE u.country
        WHEN 'Japan'   THEN 'Asia Pacific'
        WHEN 'India'   THEN 'Asia Pacific'
        WHEN 'China'   THEN 'Asia Pacific'
        WHEN 'Germany' THEN 'Europe'
        WHEN 'USA'     THEN 'Americas'
        ELSE                'Other'
    END AS region
FROM users u;

-- ================================================
-- CASE IN ORDER BY — custom sort
-- ================================================

SELECT title, category, price
FROM products
ORDER BY
    CASE category
        WHEN 'Electronics' THEN 1
        WHEN 'Fashion'     THEN 2
        WHEN 'Books'       THEN 3
        ELSE                    4
    END,
    price DESC;

-- ================================================
-- CASE IN GROUP BY — group by derived label
-- ================================================

SELECT
    CASE
        WHEN price < 5000  THEN 'Budget'
        WHEN price < 20000 THEN 'Mid-range'
        ELSE                    'Premium'
    END          AS price_tier,
    COUNT(*)     AS product_count,
    ROUND(AVG(price)) AS avg_price
FROM products
GROUP BY
    CASE
        WHEN price < 5000  THEN 'Budget'
        WHEN price < 20000 THEN 'Mid-range'
        ELSE                    'Premium'
    END
ORDER BY avg_price;

-- ================================================
-- CONDITIONAL COUNTING — pivot pattern
-- SUM(CASE WHEN ... THEN 1 ELSE 0 END)
-- ================================================

-- Product count by price tier in one row
SELECT
    COUNT(*)                                         AS total_products,
    SUM(CASE WHEN price < 5000  THEN 1 ELSE 0 END)  AS budget_count,
    SUM(CASE WHEN price BETWEEN 5000 AND 20000
             THEN 1 ELSE 0 END)                      AS mid_range_count,
    SUM(CASE WHEN price > 20000 THEN 1 ELSE 0 END)  AS premium_count
FROM products;

-- Category pivot — all in one row
SELECT
    SUM(CASE WHEN category = 'Electronics'  THEN 1 ELSE 0 END) AS electronics,
    SUM(CASE WHEN category = 'Fashion'      THEN 1 ELSE 0 END) AS fashion,
    SUM(CASE WHEN category = 'Books'        THEN 1 ELSE 0 END) AS books,
    SUM(CASE WHEN category = 'Photography'  THEN 1 ELSE 0 END) AS photography,
    SUM(CASE WHEN category = 'Sports'       THEN 1 ELSE 0 END) AS sports
FROM products;

-- ================================================
-- CASE with JOINs + Aggregates
-- ================================================

-- Order tier + discount calculation
SELECT
    u.username AS buyer,
    p.title,
    o.amount,
    CASE
        WHEN o.amount >= 50000 THEN 'Platinum order'
        WHEN o.amount >= 10000 THEN 'Gold order'
        WHEN o.amount >= 5000  THEN 'Silver order'
        ELSE                        'Standard order'
    END AS order_tier,
    CASE
        WHEN o.amount >= 50000 THEN ROUND(o.amount * 0.10)
        WHEN o.amount >= 10000 THEN ROUND(o.amount * 0.05)
        ELSE                        0
    END AS discount_amount
FROM orders o
INNER JOIN users u    ON o.buyer_id   = u.user_id
INNER JOIN products p ON o.product_id = p.product_id
ORDER BY o.amount DESC;

-- Seller badge system
SELECT
    u.username,
    u.country,
    SUM(o.amount) AS total_revenue,
    CASE
        WHEN SUM(o.amount) >= 50000 THEN 'Diamond Seller'
        WHEN SUM(o.amount) >= 20000 THEN 'Gold Seller'
        WHEN SUM(o.amount) >= 5000  THEN 'Silver Seller'
        ELSE                             'Bronze Seller'
    END AS seller_tier
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
INNER JOIN users u    ON p.seller_id  = u.user_id
GROUP BY u.user_id, u.username, u.country
ORDER BY total_revenue DESC;

-- ================================================
-- CASE with Window Functions
-- ================================================

-- Seller award system using RANK
SELECT
    u.username,
    SUM(o.amount) AS revenue,
    RANK() OVER (ORDER BY SUM(o.amount) DESC) AS rnk,
    CASE RANK() OVER (ORDER BY SUM(o.amount) DESC)
        WHEN 1 THEN 'Gold Medal'
        WHEN 2 THEN 'Silver Medal'
        WHEN 3 THEN 'Bronze Medal'
        ELSE        'Participant'
    END AS award
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
INNER JOIN users u    ON p.seller_id  = u.user_id
GROUP BY u.user_id, u.username
ORDER BY revenue DESC;

-- User audience type using NTILE
SELECT
    username,
    age,
    CASE NTILE(3) OVER (ORDER BY age)
        WHEN 1 THEN 'Young Audience'
        WHEN 2 THEN 'Core Audience'
        WHEN 3 THEN 'Mature Audience'
    END AS audience_type
FROM users;

-- ================================================
-- Business queries (Mercari use cases)
-- ================================================

-- Complete product catalogue with tiers
SELECT
    u.username AS seller,
    p.title,
    p.category,
    p.price,
    CASE
        WHEN p.price < 5000  THEN 'Budget'
        WHEN p.price < 20000 THEN 'Mid-range'
        ELSE                      'Premium'
    END AS price_tier,
    CASE p.status
        WHEN 'active' THEN 'Available'
        WHEN 'sold'   THEN 'Sold Out'
        ELSE               'Unknown'
    END AS availability
FROM products p
INNER JOIN users u ON p.seller_id = u.user_id
ORDER BY p.price DESC;

-- Platform health dashboard — all in one row
SELECT
    COUNT(*)                                              AS total_users,
    SUM(CASE WHEN country IN ('India','Japan','China')
             THEN 1 ELSE 0 END)                           AS apac_users,
    SUM(CASE WHEN country = 'Germany' THEN 1 ELSE 0 END)  AS europe_users,
    SUM(CASE WHEN country = 'USA'     THEN 1 ELSE 0 END)  AS americas_users,
    SUM(CASE WHEN age < 25  THEN 1 ELSE 0 END)            AS under_25,
    SUM(CASE WHEN age >= 25 THEN 1 ELSE 0 END)            AS above_25
FROM users;

-- Order value tier summary
SELECT
    CASE
        WHEN o.amount >= 50000 THEN 'Platinum'
        WHEN o.amount >= 10000 THEN 'Gold'
        WHEN o.amount >= 5000  THEN 'Silver'
        ELSE                        'Standard'
    END                  AS order_tier,
    COUNT(*)             AS order_count,
    SUM(o.amount)        AS total_value,
    ROUND(AVG(o.amount)) AS avg_value
FROM orders o
GROUP BY
    CASE
        WHEN o.amount >= 50000 THEN 'Platinum'
        WHEN o.amount >= 10000 THEN 'Gold'
        WHEN o.amount >= 5000  THEN 'Silver'
        ELSE                        'Standard'
    END
ORDER BY avg_value DESC;
