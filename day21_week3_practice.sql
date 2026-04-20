-- ================================================
-- MercariDB -- Day 21
-- Topic: Week 3 Practice + Mini Project v3
-- Concepts: Window Functions + CASE WHEN + CTEs + Views
-- Author: Prashant
-- Date: 2026-04-09
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
-- LEVEL 1: Window Functions Practice
-- ================================================

-- Q1: Rank products by price within each category
SELECT
    RANK() OVER (
        PARTITION BY category
        ORDER BY price DESC
    )        AS rank_in_category,
    category,
    title,
    price
FROM products
ORDER BY category, rank_in_category;

-- Q2: LAG — previous order amount per buyer
SELECT
    u.username,
    o.order_date,
    o.amount,
    LAG(o.amount, 1, 0) OVER (
        PARTITION BY o.buyer_id
        ORDER BY o.order_date
    ) AS prev_order_amount
FROM orders o
INNER JOIN users u ON o.buyer_id = u.user_id;

-- Q3: NTILE — users into 3 age groups
SELECT
    username,
    age,
    NTILE(3) OVER (ORDER BY age) AS grp,
    CASE NTILE(3) OVER (ORDER BY age)
        WHEN 1 THEN 'Young'
        WHEN 2 THEN 'Mid'
        WHEN 3 THEN 'Senior'
    END AS age_group
FROM users
WHERE age IS NOT NULL;

-- Q4: Running total by price ascending
SELECT
    title,
    price,
    SUM(price) OVER (ORDER BY price ASC) AS running_total
FROM products;

-- ================================================
-- LEVEL 2: CASE WHEN + CTEs Practice
-- ================================================

-- Q5: Products grouped by price tier
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
ORDER BY avg_price DESC;

-- Q6: CTE — top earners with tier classification
WITH seller_rev AS (
    SELECT
        p.seller_id,
        SUM(o.amount) AS total_revenue
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY p.seller_id
),
top_earners AS (
    SELECT seller_id, total_revenue
    FROM seller_rev
    WHERE total_revenue >= 5000
)
SELECT
    u.username,
    u.country,
    te.total_revenue,
    CASE
        WHEN te.total_revenue >= 50000 THEN 'Diamond'
        WHEN te.total_revenue >= 20000 THEN 'Gold'
        ELSE                                'Silver'
    END AS tier
FROM top_earners te
INNER JOIN users u ON te.seller_id = u.user_id
ORDER BY te.total_revenue DESC;

-- Q7: Conditional counting in one row
SELECT
    COUNT(*)                                         AS total_products,
    SUM(CASE WHEN category = 'Electronics'
             THEN 1 ELSE 0 END)                      AS electronics,
    SUM(CASE WHEN category = 'Fashion'
             THEN 1 ELSE 0 END)                      AS fashion,
    SUM(CASE WHEN category = 'Books'
             THEN 1 ELSE 0 END)                      AS books,
    SUM(CASE WHEN price > 20000
             THEN 1 ELSE 0 END)                      AS premium_count
FROM products;

-- ================================================
-- LEVEL 3: Views + Combined
-- ================================================

-- Q8: Top 2 products per category view
CREATE OR REPLACE VIEW top_products AS
SELECT category, title, price, rn
FROM (
    SELECT
        category,
        title,
        price,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY price DESC
        ) AS rn
    FROM products
) AS ranked
WHERE rn <= 2;

SELECT * FROM top_products ORDER BY category, rn;

-- Q9: CTE + RANK + Medal system
WITH seller_revenue AS (
    SELECT
        p.seller_id,
        SUM(o.amount) AS total_revenue
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY p.seller_id
),
ranked_sellers AS (
    SELECT
        seller_id,
        total_revenue,
        RANK() OVER (ORDER BY total_revenue DESC) AS rnk
    FROM seller_revenue
)
SELECT
    u.username,
    u.country,
    rs.total_revenue,
    rs.rnk,
    CASE rs.rnk
        WHEN 1 THEN 'Gold Medal'
        WHEN 2 THEN 'Silver Medal'
        WHEN 3 THEN 'Bronze Medal'
        ELSE        'Participant'
    END AS award
FROM ranked_sellers rs
INNER JOIN users u ON rs.seller_id = u.user_id
ORDER BY rs.rnk;

-- Q10: Market summary view
CREATE OR REPLACE VIEW market_summary AS
SELECT
    u.country,
    COUNT(DISTINCT u.user_id)   AS total_users,
    ROUND(AVG(u.age), 1)        AS avg_age,
    COUNT(DISTINCT p.seller_id) AS sellers,
    COUNT(DISTINCT o.buyer_id)  AS buyers
FROM users u
LEFT JOIN products p ON u.user_id = p.seller_id
LEFT JOIN orders o   ON u.user_id = o.buyer_id
GROUP BY u.country
ORDER BY total_users DESC;

SELECT * FROM market_summary;

-- ================================================
-- MINI PROJECT v3: Mercari Intelligence Report
-- ================================================

-- Platform Snapshot View
CREATE OR REPLACE VIEW platform_snapshot AS
SELECT
    (SELECT COUNT(*)    FROM users)    AS users,
    (SELECT COUNT(*)    FROM products) AS products,
    (SELECT COUNT(*)    FROM orders)   AS orders,
    (SELECT SUM(amount) FROM orders)   AS revenue;

SELECT * FROM platform_snapshot;

-- Seller Leaderboard: CTE + RANK + CASE + revenue share
WITH seller_stats AS (
    SELECT
        p.seller_id,
        COUNT(DISTINCT p.product_id) AS listings,
        COUNT(o.order_id)            AS sales,
        COALESCE(SUM(o.amount), 0)   AS revenue
    FROM products p
    LEFT JOIN orders o ON p.product_id = o.product_id
    GROUP BY p.seller_id
)
SELECT
    u.username,
    u.country,
    ss.listings,
    ss.sales,
    ss.revenue,
    RANK() OVER (ORDER BY ss.revenue DESC) AS revenue_rank,
    CASE
        WHEN ss.revenue >= 50000 THEN 'Diamond'
        WHEN ss.revenue >= 20000 THEN 'Gold'
        WHEN ss.revenue >= 5000  THEN 'Silver'
        WHEN ss.revenue > 0      THEN 'Bronze'
        ELSE                          'No Sales'
    END AS seller_tier,
    ROUND(ss.revenue * 100.0 /
        NULLIF(SUM(ss.revenue) OVER (), 0), 1) AS revenue_share_pct
FROM seller_stats ss
INNER JOIN users u ON ss.seller_id = u.user_id
ORDER BY ss.revenue DESC;

-- Product Intelligence View
CREATE OR REPLACE VIEW product_intelligence AS
SELECT
    p.title,
    p.category,
    p.price,
    p.status,
    u.username AS seller,
    u.country  AS seller_country,
    RANK() OVER (
        PARTITION BY p.category ORDER BY p.price DESC
    )                             AS rank_in_category,
    ROUND(AVG(p.price) OVER (
        PARTITION BY p.category
    ))                            AS category_avg,
    ROUND(p.price - AVG(p.price) OVER (
        PARTITION BY p.category
    ))                            AS vs_category_avg,
    CASE
        WHEN p.price < 5000  THEN 'Budget'
        WHEN p.price < 20000 THEN 'Mid-range'
        ELSE                      'Premium'
    END                           AS price_tier
FROM products p
INNER JOIN users u ON p.seller_id = u.user_id;

SELECT * FROM product_intelligence ORDER BY category, rank_in_category;
SELECT * FROM product_intelligence WHERE rank_in_category = 1;
SELECT * FROM product_intelligence WHERE price_tier = 'Premium';

-- User Behaviour View
CREATE OR REPLACE VIEW user_behaviour AS
SELECT
    u.username,
    u.country,
    u.age,
    CASE
        WHEN u.age < 20              THEN 'Teen'
        WHEN u.age BETWEEN 20 AND 26 THEN 'Gen Z'
        WHEN u.age BETWEEN 27 AND 42 THEN 'Millennial'
        ELSE                              'Other'
    END AS generation,
    NTILE(4) OVER (ORDER BY u.age) AS age_quartile,
    CASE
        WHEN EXISTS (SELECT 1 FROM orders   o WHERE o.buyer_id  = u.user_id)
         AND EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)
             THEN 'Power User'
        WHEN EXISTS (SELECT 1 FROM orders o WHERE o.buyer_id = u.user_id)
             THEN 'Buyer'
        WHEN EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)
             THEN 'Seller'
        ELSE 'Inactive'
    END AS user_type
FROM users u;

SELECT * FROM user_behaviour;
SELECT user_type, COUNT(*) AS count FROM user_behaviour GROUP BY user_type;

-- Spend Trend Analysis with LAG + CASE
SELECT
    u.username,
    o.amount,
    o.order_date,
    LAG(o.amount, 1, 0) OVER (
        PARTITION BY o.buyer_id ORDER BY o.order_date
    )                     AS prev_spend,
    o.amount - LAG(o.amount, 1, 0) OVER (
        PARTITION BY o.buyer_id ORDER BY o.order_date
    )                     AS spend_change,
    CASE
        WHEN LAG(o.amount, 1, 0) OVER (
            PARTITION BY o.buyer_id ORDER BY o.order_date) = 0
             THEN 'First Order'
        WHEN o.amount > LAG(o.amount, 1, 0) OVER (
            PARTITION BY o.buyer_id ORDER BY o.order_date)
             THEN 'Increased'
        ELSE 'Decreased'
    END AS spend_trend
FROM orders o
INNER JOIN users u ON o.buyer_id = u.user_id
ORDER BY u.username, o.order_date;

-- All views summary
SHOW FULL TABLES WHERE Table_type = 'VIEW';
