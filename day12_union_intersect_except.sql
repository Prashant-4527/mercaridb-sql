-- ================================================
-- MercariDB -- Day 12
-- Topic: UNION + INTERSECT + EXCEPT
-- Author: Prashant
-- Date: 2026-04-02
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
-- UNION
-- Combines results of two queries
-- Removes duplicates automatically
-- Rules: same column count + compatible types
-- ================================================

-- Buyers + Sellers combined unique list
SELECT buyer_id  AS user_id, 'buyer'  AS role FROM orders
UNION
SELECT seller_id,             'seller'          FROM products;

-- UNION ALL: keep duplicates (faster — no dedup step)
SELECT buyer_id  AS user_id FROM orders
UNION ALL
SELECT seller_id             FROM products;

-- All active users with their role
-- ORDER BY always at the very end!
SELECT u.username, u.country, 'buyer' AS role
FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.buyer_id = u.user_id
)
UNION
SELECT u.username, u.country, 'seller'
FROM users u
WHERE EXISTS (
    SELECT 1 FROM products p WHERE p.seller_id = u.user_id
)
ORDER BY username;

-- ================================================
-- INTERSECT simulation in MySQL
-- MySQL has no native INTERSECT (before 8.0.31)
-- Use IN or EXISTS instead
-- ================================================

-- Users who are BOTH buyers AND sellers (Method 1: IN)
SELECT DISTINCT u.username, u.country
FROM users u
WHERE u.user_id IN (SELECT buyer_id  FROM orders)
AND   u.user_id IN (SELECT seller_id FROM products);

-- Same result (Method 2: EXISTS — preferred, NULL-safe)
SELECT u.username, u.country
FROM users u
WHERE EXISTS (SELECT 1 FROM orders   o WHERE o.buyer_id  = u.user_id)
AND   EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id);

-- Same result (Method 3: INNER JOIN)
SELECT DISTINCT u.username, u.country
FROM users u
INNER JOIN orders   o ON u.user_id = o.buyer_id
INNER JOIN products p ON u.user_id = p.seller_id;

-- ================================================
-- EXCEPT simulation in MySQL
-- MySQL has no native EXCEPT
-- Use NOT IN or NOT EXISTS instead
-- ================================================

-- Pure buyers: ordered something but never listed anything
SELECT u.username, u.country
FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.buyer_id = u.user_id
)
AND NOT EXISTS (
    SELECT 1 FROM products p WHERE p.seller_id = u.user_id
);
-- Real world: "Target them to become sellers too"

-- Pure sellers: listed products but never bought anything
SELECT u.username, u.country
FROM users u
WHERE EXISTS (
    SELECT 1 FROM products p WHERE p.seller_id = u.user_id
)
AND NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.buyer_id = u.user_id
);
-- Real world: "Encourage them to shop on the platform"

-- ================================================
-- UNION advanced use cases
-- ================================================

-- Category summary report with total row
SELECT 'Electronics' AS category,
       COUNT(*)       AS products,
       ROUND(AVG(price)) AS avg_price
FROM products WHERE category = 'Electronics'

UNION ALL

SELECT 'Fashion', COUNT(*), ROUND(AVG(price))
FROM products WHERE category = 'Fashion'

UNION ALL

SELECT 'Books', COUNT(*), ROUND(AVG(price))
FROM products WHERE category = 'Books'

UNION ALL

SELECT 'All Categories', COUNT(*), ROUND(AVG(price))
FROM products;

-- Activity feed: listings + purchases combined
SELECT
    'New listing' AS activity,
    u.username    AS user,
    p.title       AS description,
    p.price       AS amount
FROM products p
INNER JOIN users u ON p.seller_id = u.user_id

UNION ALL

SELECT
    'Purchase',
    u.username,
    p.title,
    o.amount
FROM orders o
INNER JOIN users u    ON o.buyer_id   = u.user_id
INNER JOIN products p ON o.product_id = p.product_id

ORDER BY amount DESC;
-- Real world: Mercari platform activity feed!

-- ================================================
-- Business queries (Mercari use cases)
-- ================================================

-- Full user segmentation report
SELECT username, country, 'Power user'    AS segment
FROM users u
WHERE EXISTS (SELECT 1 FROM orders   o WHERE o.buyer_id  = u.user_id)
AND   EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)

UNION

SELECT username, country, 'Buyer only'
FROM users u
WHERE     EXISTS (SELECT 1 FROM orders   o WHERE o.buyer_id  = u.user_id)
AND NOT EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)

UNION

SELECT username, country, 'Seller only'
FROM users u
WHERE     EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)
AND NOT EXISTS (SELECT 1 FROM orders   o WHERE o.buyer_id  = u.user_id)

UNION

SELECT username, country, 'Inactive'
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM orders   o WHERE o.buyer_id  = u.user_id)
AND   NOT EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)

ORDER BY segment, username;
-- Real world: Complete user segmentation for marketing!
