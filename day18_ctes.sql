-- ================================================
-- MercariDB -- Day 18
-- Topic: CTEs — Common Table Expressions (WITH)
-- Author: Prashant
-- Date: 2026-04-07
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
-- BASIC CTE
-- WITH name AS (query) SELECT FROM name
-- ================================================

-- Above average products using CTE
WITH avg_price_cte AS (
    SELECT AVG(price) AS avg_p FROM products
)
SELECT
    p.title,
    p.price,
    ROUND(a.avg_p) AS platform_avg
FROM products p
CROSS JOIN avg_price_cte a
WHERE p.price > a.avg_p
ORDER BY p.price DESC;

-- ================================================
-- MULTIPLE CTEs
-- Comma-separated, each builds on previous
-- ================================================

WITH
seller_revenue AS (
    SELECT
        p.seller_id,
        SUM(o.amount)     AS total_revenue,
        COUNT(o.order_id) AS total_orders
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY p.seller_id
),
top_sellers AS (
    SELECT seller_id, total_revenue, total_orders
    FROM seller_revenue
    WHERE total_revenue > 10000
),
top_seller_details AS (
    SELECT
        u.username,
        u.country,
        ts.total_revenue,
        ts.total_orders
    FROM top_sellers ts
    INNER JOIN users u ON ts.seller_id = u.user_id
)
SELECT
    username,
    country,
    total_revenue,
    total_orders,
    ROUND(total_revenue / total_orders) AS avg_order_value
FROM top_seller_details
ORDER BY total_revenue DESC;

-- ================================================
-- CTE vs SUBQUERY comparison
-- Same result, CTE is cleaner
-- ================================================

-- Subquery version (harder to read)
SELECT username, country, total_revenue
FROM (
    SELECT
        u.username,
        u.country,
        SUM(o.amount) AS total_revenue
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    INNER JOIN users u    ON p.seller_id  = u.user_id
    GROUP BY u.user_id, u.username, u.country
) AS seller_stats
WHERE total_revenue > 5000;

-- CTE version (clean + readable)
WITH seller_stats AS (
    SELECT
        u.username,
        u.country,
        SUM(o.amount) AS total_revenue
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    INNER JOIN users u    ON p.seller_id  = u.user_id
    GROUP BY u.user_id, u.username, u.country
)
SELECT username, country, total_revenue
FROM seller_stats
WHERE total_revenue > 5000;

-- ================================================
-- CTE REUSE — use same CTE multiple times
-- ================================================

WITH category_stats AS (
    SELECT
        category,
        COUNT(*)           AS product_count,
        ROUND(AVG(price))  AS avg_price,
        MIN(price)         AS min_price,
        MAX(price)         AS max_price
    FROM products
    GROUP BY category
)
SELECT
    p.title,
    p.price,
    p.category,
    cs.avg_price     AS category_avg,
    ROUND(p.price - cs.avg_price) AS diff_from_avg,
    CASE
        WHEN p.price > cs.avg_price THEN 'Above avg'
        ELSE                             'Below avg'
    END AS positioning
FROM products p
INNER JOIN category_stats cs ON p.category = cs.category
ORDER BY p.category, p.price DESC;

-- ================================================
-- RECURSIVE CTE
-- Requires RECURSIVE keyword
-- Base case + Recursive case
-- ================================================

WITH RECURSIVE referral_chain AS (
    -- Base case: users with no referrer (top level)
    SELECT
        user_id,
        username,
        referred_by,
        0 AS level
    FROM users
    WHERE referred_by IS NULL

    UNION ALL

    -- Recursive case: find users referred by previous level
    SELECT
        u.user_id,
        u.username,
        u.referred_by,
        rc.level + 1
    FROM users u
    INNER JOIN referral_chain rc ON u.referred_by = rc.user_id
)
SELECT
    CONCAT(REPEAT('  ', level), username) AS hierarchy,
    level AS depth
FROM referral_chain
ORDER BY level, username;

-- ================================================
-- Business queries (Mercari use cases)
-- ================================================

-- Seller intelligence report
WITH
seller_listings AS (
    SELECT
        seller_id,
        COUNT(*)          AS total_listed,
        ROUND(AVG(price)) AS avg_listing_price
    FROM products
    GROUP BY seller_id
),
seller_sales AS (
    SELECT
        p.seller_id,
        COUNT(o.order_id) AS total_sold,
        SUM(o.amount)     AS total_revenue
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY p.seller_id
),
seller_full AS (
    SELECT
        u.username,
        u.country,
        sl.total_listed,
        sl.avg_listing_price,
        COALESCE(ss.total_sold, 0)    AS total_sold,
        COALESCE(ss.total_revenue, 0) AS total_revenue
    FROM users u
    INNER JOIN seller_listings sl ON u.user_id = sl.seller_id
    LEFT JOIN  seller_sales    ss ON u.user_id = ss.seller_id
)
SELECT
    username,
    country,
    total_listed,
    avg_listing_price,
    total_sold,
    total_revenue,
    CASE
        WHEN total_revenue >= 50000 THEN 'Diamond'
        WHEN total_revenue >= 20000 THEN 'Gold'
        WHEN total_revenue >= 5000  THEN 'Silver'
        ELSE                             'Bronze'
    END AS seller_tier
FROM seller_full
ORDER BY total_revenue DESC;

-- Category comparison report
WITH
category_summary AS (
    SELECT
        category,
        COUNT(*)           AS total_products,
        ROUND(AVG(price))  AS avg_price
    FROM products
    GROUP BY category
),
category_sales AS (
    SELECT
        p.category,
        COUNT(o.order_id) AS items_sold,
        SUM(o.amount)     AS revenue
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category
)
SELECT
    cs.category,
    cs.total_products,
    cs.avg_price,
    COALESCE(csl.items_sold, 0) AS items_sold,
    COALESCE(csl.revenue, 0)    AS revenue,
    ROUND(COALESCE(csl.revenue, 0) /
          cs.total_products)    AS revenue_per_product
FROM category_summary cs
LEFT JOIN category_sales csl ON cs.category = csl.category
ORDER BY revenue DESC;

-- Platform funnel report
WITH
total_users AS (
    SELECT COUNT(*) AS n FROM users
),
active_sellers AS (
    SELECT COUNT(DISTINCT seller_id) AS n FROM products
),
active_buyers AS (
    SELECT COUNT(DISTINCT buyer_id) AS n FROM orders
),
power_users AS (
    SELECT COUNT(DISTINCT u.user_id) AS n
    FROM users u
    WHERE EXISTS (SELECT 1 FROM orders   o WHERE o.buyer_id  = u.user_id)
    AND   EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)
)
SELECT
    tu.n                                      AS total_users,
    asell.n                                   AS active_sellers,
    ab.n                                      AS active_buyers,
    pu.n                                      AS power_users,
    ROUND(asell.n * 100.0 / tu.n, 1)          AS seller_pct,
    ROUND(ab.n   * 100.0 / tu.n, 1)          AS buyer_pct,
    ROUND(pu.n   * 100.0 / tu.n, 1)          AS power_user_pct
FROM total_users    tu
CROSS JOIN active_sellers asell
CROSS JOIN active_buyers  ab
CROSS JOIN power_users    pu;
