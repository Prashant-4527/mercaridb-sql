-- ================================================
-- MercariDB -- Day 13
-- Topic: String Functions + Date Functions
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
-- STRING FUNCTIONS
-- ================================================

-- UPPER + LOWER: case conversion
SELECT
    username,
    UPPER(username)  AS username_upper,
    LOWER(email)     AS email_lower
FROM users;

-- LENGTH: string length in characters
SELECT username, LENGTH(username) AS name_length
FROM users
ORDER BY name_length DESC;

-- Find long usernames
SELECT username
FROM users
WHERE LENGTH(username) > 10;

-- CONCAT: join strings together
SELECT
    CONCAT(username, ' (', country, ')') AS display_name
FROM users;

-- CONCAT_WS: join with separator (cleaner, ignores NULLs)
SELECT
    CONCAT_WS(' | ', username, email, country) AS user_card
FROM users;

-- SUBSTRING: extract part of string
-- SUBSTRING(string, start_position, length)
-- Positions start at 1, not 0!
SELECT
    email,
    SUBSTRING(email, 1, 5) AS first_5_chars
FROM users;

-- Extract email domain (everything after @)
SELECT
    email,
    SUBSTRING(email, LOCATE('@', email) + 1) AS domain
FROM users;

-- REPLACE: substitute part of a string
SELECT
    email,
    REPLACE(email, '@', ' AT ') AS safe_email
FROM users;

-- TRIM: remove leading and trailing spaces
SELECT TRIM('  hello world  ') AS trimmed;

-- LEFT + RIGHT: take chars from start or end
SELECT
    username,
    LEFT(username, 4)  AS first_4_chars,
    RIGHT(username, 3) AS last_3_chars
FROM users;

-- LOCATE: find position of substring
SELECT
    email,
    LOCATE('@', email) AS at_sign_position
FROM users;

-- ================================================
-- DATE FUNCTIONS
-- ================================================

-- Current date and time
SELECT
    NOW()     AS current_datetime,
    CURDATE() AS current_date,
    CURTIME() AS current_time;

-- DATE_FORMAT: custom date display
-- %d=day %M=Month name %b=Month short %Y=Year %W=Weekday
SELECT
    username,
    created_at,
    DATE_FORMAT(created_at, '%d %M %Y')    AS readable_date,
    DATE_FORMAT(created_at, '%Y-%m')        AS year_month,
    DATE_FORMAT(created_at, '%W, %d %b %Y') AS full_date
FROM users;

-- DATEDIFF: days between two dates
SELECT
    username,
    created_at,
    DATEDIFF(NOW(), created_at) AS days_since_joined
FROM users
ORDER BY days_since_joined DESC;

-- Days since each order
SELECT
    o.order_id,
    u.username AS buyer,
    p.title,
    o.amount,
    DATEDIFF(NOW(), o.order_date) AS days_ago
FROM orders o
INNER JOIN users u    ON o.buyer_id   = u.user_id
INNER JOIN products p ON o.product_id = p.product_id
ORDER BY days_ago ASC;

-- YEAR() MONTH() DAY(): extract parts of a date
SELECT
    username,
    YEAR(created_at)  AS join_year,
    MONTH(created_at) AS join_month,
    DAY(created_at)   AS join_day
FROM users;

-- Users who joined this year
SELECT username, created_at
FROM users
WHERE YEAR(created_at) = YEAR(NOW());

-- Users who joined this month
SELECT username, created_at
FROM users
WHERE YEAR(created_at)  = YEAR(NOW())
AND   MONTH(created_at) = MONTH(NOW());

-- DATE_ADD + DATE_SUB: date arithmetic
SELECT
    username,
    created_at,
    DATE_ADD(created_at, INTERVAL 30 DAY) AS trial_ends,
    DATE_SUB(NOW(), INTERVAL 7 DAY)       AS one_week_ago
FROM users;

-- Users who joined in last 7 days
SELECT username, created_at
FROM users
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- Orders in last 30 days
SELECT COUNT(*) AS recent_orders
FROM orders
WHERE order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY);

-- TIMESTAMPDIFF: difference in specific unit
SELECT
    username,
    TIMESTAMPDIFF(YEAR,  created_at, NOW()) AS years_on_platform,
    TIMESTAMPDIFF(MONTH, created_at, NOW()) AS months_on_platform,
    TIMESTAMPDIFF(DAY,   created_at, NOW()) AS days_on_platform
FROM users;

-- ================================================
-- Combined business queries
-- ================================================

-- User profile card: strings + dates
SELECT
    UPPER(u.username)                             AS display_name,
    CONCAT_WS(' | ', u.email, u.country)          AS contact,
    SUBSTRING(u.email, LOCATE('@', u.email) + 1)  AS email_domain,
    DATEDIFF(NOW(), u.created_at)                 AS days_active,
    COUNT(p.product_id)                           AS total_listings
FROM users u
LEFT JOIN products p ON u.user_id = p.seller_id
GROUP BY u.user_id, u.username, u.email,
         u.country, u.created_at
ORDER BY days_active DESC;

-- Monthly revenue dashboard
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(o.order_id)                  AS total_orders,
    SUM(o.amount)                      AS total_revenue,
    ROUND(AVG(o.amount))               AS avg_order_value
FROM orders o
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month DESC;

-- Email domain analysis
SELECT
    SUBSTRING(email, LOCATE('@', email) + 1) AS domain,
    COUNT(*) AS users
FROM users
GROUP BY domain
ORDER BY users DESC;

-- Performance tip: use range instead of function on column
-- SLOW  (can't use index):
-- WHERE YEAR(created_at) = 2026
-- FAST (uses index):
-- WHERE created_at BETWEEN '2026-01-01' AND '2026-12-31'
SELECT username, created_at
FROM users
WHERE created_at BETWEEN '2026-01-01' AND '2026-12-31';
