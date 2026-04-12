-- ================================================
-- MercariDB -- Day 16
-- Topic: Window Functions — LAG, LEAD, NTILE
-- Author: Prashant
-- Date: 2026-04-05
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
-- LAG() -- fetch value from previous row
-- LAG(column, offset, default)
-- offset default = 1 (one row back)
-- ================================================

-- Previous order amount alongside current
SELECT
    u.username,
    o.amount,
    o.order_date,
    LAG(o.amount) OVER (ORDER BY o.order_date) AS prev_order_amount
FROM orders o
INNER JOIN users u ON o.buyer_id = u.user_id;

-- Change from previous order
SELECT
    u.username,
    o.amount,
    LAG(o.amount) OVER (ORDER BY o.order_date)  AS prev_amount,
    o.amount - LAG(o.amount) OVER (
        ORDER BY o.order_date
    )                                            AS change_from_prev
FROM orders o
INNER JOIN users u ON o.buyer_id = u.user_id;

-- LAG per user (PARTITION BY resets window per user)
SELECT
    u.username,
    o.amount,
    o.order_date,
    LAG(o.amount) OVER (
        PARTITION BY o.buyer_id
        ORDER BY o.order_date
    ) AS prev_order_same_user
FROM orders o
INNER JOIN users u ON o.buyer_id = u.user_id;

-- LAG with default value instead of NULL
-- LAG(column, offset, default_if_null)
SELECT
    u.username,
    o.amount,
    LAG(o.amount, 1, 0) OVER (
        PARTITION BY o.buyer_id
        ORDER BY o.order_date
    ) AS prev_amount
FROM orders o
INNER JOIN users u ON o.buyer_id = u.user_id;

-- ================================================
-- LEAD() -- fetch value from next row
-- Opposite of LAG
-- ================================================

-- Next order amount alongside current
SELECT
    u.username,
    o.amount,
    o.order_date,
    LEAD(o.amount) OVER (ORDER BY o.order_date) AS next_order_amount
FROM orders o
INNER JOIN users u ON o.buyer_id = u.user_id;

-- Price gap between products in same category
SELECT
    title,
    category,
    price,
    LEAD(price) OVER (
        PARTITION BY category
        ORDER BY price DESC
    )             AS next_cheaper_price,
    price - LEAD(price) OVER (
        PARTITION BY category
        ORDER BY price DESC
    )             AS price_gap_to_next
FROM products;

-- LAG + LEAD together: previous and next price
SELECT
    title,
    price,
    LAG(price)  OVER (ORDER BY price DESC) AS higher_priced,
    LEAD(price) OVER (ORDER BY price DESC) AS lower_priced
FROM products;

-- ================================================
-- NTILE(n) -- divide rows into n equal buckets
-- ================================================

-- Split users into 4 age quartiles
SELECT
    username,
    age,
    NTILE(4) OVER (ORDER BY age) AS age_quartile
FROM users
WHERE age IS NOT NULL;

-- Quartiles with labels using CASE WHEN
SELECT
    username,
    age,
    NTILE(4) OVER (ORDER BY age) AS quartile,
    CASE NTILE(4) OVER (ORDER BY age)
        WHEN 1 THEN 'Young (Q1)'
        WHEN 2 THEN 'Young-Mid (Q2)'
        WHEN 3 THEN 'Mid-Senior (Q3)'
        WHEN 4 THEN 'Senior (Q4)'
    END AS age_group
FROM users
WHERE age IS NOT NULL;

-- Products into 3 price tiers
SELECT
    title,
    category,
    price,
    NTILE(3) OVER (ORDER BY price) AS price_tier,
    CASE NTILE(3) OVER (ORDER BY price)
        WHEN 1 THEN 'Budget'
        WHEN 2 THEN 'Mid-range'
        WHEN 3 THEN 'Premium'
    END AS tier_name
FROM products
ORDER BY price;

-- NTILE within category
SELECT
    title,
    category,
    price,
    NTILE(2) OVER (
        PARTITION BY category
        ORDER BY price DESC
    ) AS price_half_in_category
FROM products
ORDER BY category, price DESC;

-- ================================================
-- All window functions combined
-- ================================================

SELECT
    title,
    category,
    price,
    ROW_NUMBER() OVER (
        PARTITION BY category ORDER BY price DESC
    )                                                AS rank_in_cat,
    ROUND(AVG(price) OVER (PARTITION BY category))   AS cat_avg,
    ROUND(price - AVG(price) OVER (
        PARTITION BY category
    ))                                               AS diff_from_cat_avg,
    NTILE(3) OVER (ORDER BY price)                   AS price_tier,
    LAG(price)  OVER (
        PARTITION BY category ORDER BY price DESC
    )                                                AS next_expensive,
    LEAD(price) OVER (
        PARTITION BY category ORDER BY price DESC
    )                                                AS next_cheaper
FROM products
ORDER BY category, price DESC;

-- ================================================
-- Business queries (Mercari use cases)
-- ================================================

-- Revenue growth per buyer
SELECT
    u.username,
    o.order_date,
    o.amount,
    LAG(o.amount, 1, 0) OVER (
        PARTITION BY o.buyer_id
        ORDER BY o.order_date
    )              AS prev_spend,
    o.amount - LAG(o.amount, 1, 0) OVER (
        PARTITION BY o.buyer_id
        ORDER BY o.order_date
    )              AS spend_change
FROM orders o
INNER JOIN users u ON o.buyer_id = u.user_id
ORDER BY u.username, o.order_date;

-- Price positioning per category
SELECT
    u.username AS seller,
    p.title,
    p.category,
    p.price,
    LAG(p.price) OVER (
        PARTITION BY p.category
        ORDER BY p.price
    )              AS cheaper_competitor,
    LEAD(p.price) OVER (
        PARTITION BY p.category
        ORDER BY p.price
    )              AS pricier_competitor
FROM products p
INNER JOIN users u ON p.seller_id = u.user_id
ORDER BY p.category, p.price;

-- User generation segmentation with order count
SELECT
    u.username,
    u.country,
    u.age,
    NTILE(3) OVER (ORDER BY u.age) AS age_tier,
    CASE NTILE(3) OVER (ORDER BY u.age)
        WHEN 1 THEN 'Gen Z'
        WHEN 2 THEN 'Millennial'
        WHEN 3 THEN 'Senior'
    END                            AS generation,
    COUNT(o.order_id)              AS total_orders
FROM users u
LEFT JOIN orders o ON u.user_id = o.buyer_id
GROUP BY u.user_id, u.username, u.country, u.age
ORDER BY age_tier, total_orders DESC;
