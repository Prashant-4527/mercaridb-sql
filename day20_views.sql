-- ================================================
-- MercariDB -- Day 20
-- Topic: Views — Virtual Tables
-- Author: Prashant
-- Date: 2026-04-08
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
-- CREATE VIEWS
-- CREATE OR REPLACE = safest, always use this
-- ================================================

-- VIEW 1: Active product listings with seller info
CREATE OR REPLACE VIEW active_listings AS
SELECT
    u.username     AS seller,
    u.country      AS seller_country,
    p.product_id,
    p.title,
    p.category,
    p.price,
    p.status
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE p.status = 'active';

-- Use it like a table!
SELECT * FROM active_listings;
SELECT * FROM active_listings WHERE category = 'Electronics';
SELECT * FROM active_listings WHERE price > 10000 ORDER BY price DESC;
SELECT seller, COUNT(*) AS listings FROM active_listings GROUP BY seller;

-- VIEW 2: Seller performance summary
CREATE OR REPLACE VIEW seller_performance AS
SELECT
    u.user_id,
    u.username,
    u.country,
    COUNT(p.product_id)   AS total_listings,
    SUM(p.price)          AS total_listed_value,
    ROUND(AVG(p.price))   AS avg_listing_price
FROM users u
LEFT JOIN products p ON u.user_id = p.seller_id
GROUP BY u.user_id, u.username, u.country;

SELECT * FROM seller_performance ORDER BY total_listings DESC;
SELECT * FROM seller_performance WHERE country = 'Japan';
SELECT * FROM seller_performance WHERE total_listings >= 2;

-- VIEW 3: Full order details (no JOIN needed when using!)
CREATE OR REPLACE VIEW order_details AS
SELECT
    o.order_id,
    buyer.username    AS buyer_name,
    buyer.country     AS buyer_country,
    seller.username   AS seller_name,
    seller.country    AS seller_country,
    p.title           AS product,
    p.category,
    o.amount,
    o.order_date,
    DATEDIFF(NOW(), o.order_date) AS days_ago
FROM orders o
INNER JOIN users buyer  ON o.buyer_id   = buyer.user_id
INNER JOIN products p   ON o.product_id = p.product_id
INNER JOIN users seller ON p.seller_id  = seller.user_id;

SELECT * FROM order_details;
SELECT * FROM order_details WHERE buyer_country = 'India';
SELECT * FROM order_details ORDER BY amount DESC;

-- VIEW 4: User segmentation
CREATE OR REPLACE VIEW user_segments AS
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
    CASE
        WHEN u.country IN ('India','Japan','China') THEN 'APAC'
        WHEN u.country = 'Germany'                 THEN 'Europe'
        WHEN u.country = 'USA'                     THEN 'Americas'
        ELSE                                            'Other'
    END AS region,
    CASE
        WHEN EXISTS (SELECT 1 FROM orders   o WHERE o.buyer_id  = u.user_id)
         AND EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)
             THEN 'Power User'
        WHEN EXISTS (SELECT 1 FROM orders o WHERE o.buyer_id = u.user_id)
             THEN 'Buyer Only'
        WHEN EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)
             THEN 'Seller Only'
        ELSE 'Inactive'
    END AS user_type
FROM users u;

SELECT * FROM user_segments;
SELECT * FROM user_segments WHERE user_type = 'Power User';
SELECT region, COUNT(*) AS users FROM user_segments GROUP BY region;
SELECT generation, user_type, COUNT(*) AS count
FROM user_segments
GROUP BY generation, user_type
ORDER BY generation, count DESC;

-- ================================================
-- VIEW with Window Functions + CASE WHEN
-- ================================================

CREATE OR REPLACE VIEW product_rankings AS
SELECT
    p.title,
    p.category,
    p.price,
    u.username AS seller,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY p.price DESC
    ) AS rank_in_category,
    ROUND(AVG(p.price) OVER (
        PARTITION BY p.category
    )) AS category_avg_price,
    CASE
        WHEN p.price < 5000  THEN 'Budget'
        WHEN p.price < 20000 THEN 'Mid-range'
        ELSE                      'Premium'
    END AS price_tier
FROM products p
INNER JOIN users u ON p.seller_id = u.user_id;

-- Complex window query made simple!
SELECT * FROM product_rankings WHERE rank_in_category = 1;
SELECT * FROM product_rankings WHERE price_tier = 'Premium';
SELECT category, COUNT(*) AS products, ROUND(AVG(price)) AS avg
FROM product_rankings
GROUP BY category;

-- ================================================
-- VIEW MANAGEMENT
-- ================================================

-- See all views in database
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- See view definition
SHOW CREATE VIEW active_listings;

-- Drop a view safely
DROP VIEW IF EXISTS active_listings;

-- Recreate it
CREATE OR REPLACE VIEW active_listings AS
SELECT
    u.username AS seller,
    u.country  AS seller_country,
    p.title,
    p.category,
    p.price
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE p.status = 'active';

-- ================================================
-- Dashboard views using CTEs inside views
-- ================================================

-- Platform overview dashboard
CREATE OR REPLACE VIEW platform_overview AS
SELECT
    (SELECT COUNT(*)    FROM users)    AS total_users,
    (SELECT COUNT(*)    FROM products) AS total_products,
    (SELECT COUNT(*)    FROM orders)   AS total_orders,
    (SELECT SUM(amount) FROM orders)   AS total_revenue,
    (SELECT COUNT(DISTINCT country) FROM users) AS markets;

SELECT * FROM platform_overview;

-- Revenue leaderboard view
CREATE OR REPLACE VIEW revenue_leaderboard AS
WITH seller_rev AS (
    SELECT
        p.seller_id,
        SUM(o.amount)     AS total_revenue,
        COUNT(o.order_id) AS orders_fulfilled
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY p.seller_id
)
SELECT
    u.username,
    u.country,
    sr.total_revenue,
    sr.orders_fulfilled,
    RANK() OVER (ORDER BY sr.total_revenue DESC) AS revenue_rank,
    CASE
        WHEN sr.total_revenue >= 50000 THEN 'Diamond'
        WHEN sr.total_revenue >= 20000 THEN 'Gold'
        WHEN sr.total_revenue >= 5000  THEN 'Silver'
        ELSE                                'Bronze'
    END AS tier
FROM seller_rev sr
INNER JOIN users u ON sr.seller_id = u.user_id;

SELECT * FROM revenue_leaderboard;
SELECT * FROM revenue_leaderboard WHERE country = 'Japan';
SELECT * FROM revenue_leaderboard WHERE revenue_rank <= 3;
