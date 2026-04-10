-- ================================================
-- MercariDB -- Day 14
-- Topic: Week 2 Practice — All Concepts Combined
-- Author: Prashant
-- Date: 2026-04-03
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
-- LEVEL 1 -- JOIN Practice
-- ================================================

-- Q1: Active products with seller name + country
SELECT u.username AS seller, u.country, p.title, p.price
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
WHERE p.status = 'active'
ORDER BY p.price DESC;

-- Q2: Japan buyers purchase history
SELECT u.username AS buyer, p.title, o.amount
FROM orders o
INNER JOIN users u    ON o.buyer_id   = u.user_id
INNER JOIN products p ON o.product_id = p.product_id
WHERE u.country = 'Japan'
ORDER BY o.amount DESC;

-- Q3: Sellers with 2+ listings
SELECT
    u.username,
    COUNT(p.product_id) AS total_listings,
    SUM(p.price)        AS total_value
FROM users u
INNER JOIN products p ON u.user_id = p.seller_id
GROUP BY u.user_id, u.username
HAVING total_listings >= 2
ORDER BY total_value DESC;

-- ================================================
-- LEVEL 2 -- Subquery + EXISTS Practice
-- ================================================

-- Q4: Above-average price products with seller
SELECT u.username AS seller, p.title, p.price
FROM products p
INNER JOIN users u ON p.seller_id = u.user_id
WHERE p.price > (SELECT AVG(price) FROM products)
ORDER BY p.price DESC;

-- Q5: Users who never placed an order
SELECT username, country
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.buyer_id = u.user_id
);

-- Q6: Top revenue seller
SELECT u.username, u.country, SUM(o.amount) AS total_revenue
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
INNER JOIN users u    ON p.seller_id  = u.user_id
GROUP BY u.user_id, u.username, u.country
HAVING total_revenue = (
    SELECT MAX(total)
    FROM (
        SELECT SUM(o2.amount) AS total
        FROM orders o2
        INNER JOIN products p2 ON o2.product_id = p2.product_id
        GROUP BY p2.seller_id
    ) AS revenue_table
);

-- ================================================
-- LEVEL 3 -- UNION + String + Date Practice
-- ================================================

-- Q7: Email domain analysis
SELECT
    SUBSTRING(email, LOCATE('@', email) + 1) AS domain,
    COUNT(*) AS users
FROM users
GROUP BY domain
ORDER BY users DESC;

-- Q8: Full user segmentation
SELECT username, country, 'Power user' AS segment
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

-- Q9: Order history with days ago
SELECT
    u.username AS buyer,
    p.title,
    o.amount,
    DATEDIFF(NOW(), o.order_date) AS days_ago
FROM orders o
INNER JOIN users u    ON o.buyer_id   = u.user_id
INNER JOIN products p ON o.product_id = p.product_id
ORDER BY days_ago ASC;
