-- ================================================
-- MercariDB -- Day 15
-- Topic: Window Functions
--        ROW_NUMBER, RANK, DENSE_RANK
--        SUM/AVG/COUNT OVER()
-- Author: Prashant
-- Date: 2026-04-04
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
-- ROW_NUMBER()
-- Unique sequential number per row
-- Ties get different numbers
-- ================================================

-- All products numbered by price descending
SELECT
    ROW_NUMBER() OVER (ORDER BY price DESC) AS row_num,
    title,
    price,
    category
FROM products;

-- Numbered within each category
SELECT
    ROW_NUMBER() OVER (
        PARTITION BY category
        ORDER BY price DESC
    )           AS rank_in_category,
    category,
    title,
    price
FROM products;

-- Top 1 product per category
SELECT category, title, price
FROM (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY price DESC
        ) AS rn,
        category, title, price
    FROM products
) AS ranked
WHERE rn = 1;

-- ================================================
-- RANK() vs DENSE_RANK()
-- RANK:       ties get same rank, next rank skips
-- DENSE_RANK: ties get same rank, no gap after
-- ================================================

-- Compare all three side by side
SELECT
    ROW_NUMBER()  OVER (ORDER BY price DESC) AS row_num,
    RANK()        OVER (ORDER BY price DESC) AS rnk,
    DENSE_RANK()  OVER (ORDER BY price DESC) AS dense_rnk,
    title,
    price
FROM products;

-- Seller revenue ranking using RANK
SELECT
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    username,
    country,
    total_revenue
FROM (
    SELECT
        u.username,
        u.country,
        SUM(o.amount) AS total_revenue
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    INNER JOIN users u    ON p.seller_id  = u.user_id
    GROUP BY u.user_id, u.username, u.country
) AS seller_revenue;

-- Top 3 sellers only
SELECT username, country, total_revenue, revenue_rank
FROM (
    SELECT
        u.username,
        u.country,
        SUM(o.amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(o.amount) DESC) AS revenue_rank
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    INNER JOIN users u    ON p.seller_id  = u.user_id
    GROUP BY u.user_id, u.username, u.country
) AS ranked_sellers
WHERE revenue_rank <= 3;

-- ================================================
-- SUM / AVG / COUNT with OVER()
-- Running totals, percentages, comparisons
-- ================================================

-- Running total by price descending
SELECT
    title,
    price,
    SUM(price) OVER (ORDER BY price DESC) AS running_total
FROM products;

-- Each product as % of platform total
SELECT
    title,
    category,
    price,
    SUM(price) OVER ()                            AS platform_total,
    ROUND(price * 100.0 / SUM(price) OVER (), 1)  AS price_pct
FROM products
ORDER BY price DESC;

-- Each product as % of its own category total
SELECT
    title,
    category,
    price,
    SUM(price) OVER (PARTITION BY category)           AS category_total,
    ROUND(price * 100.0 /
          SUM(price) OVER (PARTITION BY category), 1) AS pct_of_category
FROM products
ORDER BY category, price DESC;

-- How far each product is from platform average
SELECT
    title,
    price,
    ROUND(AVG(price) OVER ())         AS platform_avg,
    ROUND(price - AVG(price) OVER ()) AS diff_from_avg
FROM products
ORDER BY diff_from_avg DESC;

-- ================================================
-- Business queries (Mercari use cases)
-- ================================================

-- Seller leaderboard with revenue share %
SELECT
    revenue_rank,
    username,
    country,
    total_revenue,
    ROUND(total_revenue * 100.0 /
          SUM(total_revenue) OVER (), 1) AS revenue_share_pct
FROM (
    SELECT
        u.username,
        u.country,
        SUM(o.amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(o.amount) DESC) AS revenue_rank
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    INNER JOIN users u    ON p.seller_id  = u.user_id
    GROUP BY u.user_id, u.username, u.country
) AS ranked;

-- Top 2 products per category
SELECT category, title, price, rank_in_cat
FROM (
    SELECT
        category,
        title,
        price,
        RANK() OVER (
            PARTITION BY category
            ORDER BY price DESC
        ) AS rank_in_cat
    FROM products
) AS ranked
WHERE rank_in_cat <= 2
ORDER BY category, rank_in_cat;

-- Each user's order sequence (1st order, 2nd order...)
SELECT
    u.username,
    p.title,
    o.amount,
    ROW_NUMBER() OVER (
        PARTITION BY o.buyer_id
        ORDER BY o.order_date
    ) AS order_sequence
FROM orders o
INNER JOIN users u    ON o.buyer_id   = u.user_id
INNER JOIN products p ON o.product_id = p.product_id;
