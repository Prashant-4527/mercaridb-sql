-- ================================================
-- MercariDB -- Day 26
-- Topic: Real-World Case Study
-- 5 Business Problems — All Concepts Combined
-- Author: Prashant
-- Date: 2026-04-14
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
-- CASE 1: SELLER HEALTH REPORT
-- Sell-through rate + revenue tier + rank
-- ================================================

WITH seller_listings AS (
    SELECT
        seller_id,
        COUNT(*)                                            AS total_listed,
        SUM(CASE WHEN status = 'sold'   THEN 1 ELSE 0 END) AS total_sold,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS total_active,
        ROUND(AVG(price))                                   AS avg_price
    FROM products
    GROUP BY seller_id
),
seller_revenue AS (
    SELECT
        p.seller_id,
        COALESCE(SUM(o.amount), 0)    AS total_revenue,
        COALESCE(COUNT(o.order_id), 0) AS orders_fulfilled
    FROM products p
    LEFT JOIN orders o ON p.product_id = o.product_id
    GROUP BY p.seller_id
),
seller_health AS (
    SELECT
        u.username,
        u.country,
        sl.total_listed,
        sl.total_sold,
        sl.total_active,
        sl.avg_price,
        sr.total_revenue,
        sr.orders_fulfilled,
        ROUND(sl.total_sold * 100.0 /
              NULLIF(sl.total_listed, 0), 1) AS sell_through_rate
    FROM users u
    INNER JOIN seller_listings sl ON u.user_id = sl.seller_id
    INNER JOIN seller_revenue  sr ON u.user_id = sr.seller_id
)
SELECT
    username,
    country,
    total_listed,
    total_sold,
    total_active,
    avg_price,
    total_revenue,
    orders_fulfilled,
    sell_through_rate,
    CASE
        WHEN sell_through_rate >= 80 THEN 'Excellent'
        WHEN sell_through_rate >= 50 THEN 'Good'
        WHEN sell_through_rate >= 20 THEN 'Average'
        ELSE                               'Poor'
    END AS sell_through_grade,
    CASE
        WHEN total_revenue >= 50000 THEN 'Diamond'
        WHEN total_revenue >= 20000 THEN 'Gold'
        WHEN total_revenue >= 5000  THEN 'Silver'
        WHEN total_revenue > 0      THEN 'Bronze'
        ELSE                             'No Sales'
    END AS revenue_tier,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM seller_health
ORDER BY total_revenue DESC;

-- ================================================
-- CASE 2: BUYER BEHAVIOUR ANALYSIS
-- Segments + favourite category + spending rank
-- ================================================

WITH buyer_stats AS (
    SELECT
        o.buyer_id,
        COUNT(o.order_id)    AS total_orders,
        SUM(o.amount)        AS total_spent,
        ROUND(AVG(o.amount)) AS avg_order_value
    FROM orders o
    GROUP BY o.buyer_id
),
buyer_fav_category AS (
    SELECT
        o.buyer_id,
        p.category,
        COUNT(*) AS cat_count,
        ROW_NUMBER() OVER (
            PARTITION BY o.buyer_id
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    GROUP BY o.buyer_id, p.category
),
buyer_full AS (
    SELECT
        u.username,
        u.country,
        u.age,
        bs.total_orders,
        bs.total_spent,
        bs.avg_order_value,
        bfc.category AS fav_category
    FROM users u
    INNER JOIN buyer_stats        bs  ON u.user_id = bs.buyer_id
    LEFT JOIN  buyer_fav_category bfc ON u.user_id = bfc.buyer_id
                                      AND bfc.rn = 1
)
SELECT
    username,
    country,
    age,
    total_orders,
    total_spent,
    avg_order_value,
    fav_category,
    CASE
        WHEN total_spent >= 50000 THEN 'Whale'
        WHEN total_spent >= 20000 THEN 'High Value'
        WHEN total_spent >= 5000  THEN 'Mid Value'
        ELSE                          'Low Value'
    END AS buyer_segment,
    RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM buyer_full
ORDER BY total_spent DESC;

-- ================================================
-- CASE 3: CATEGORY INTELLIGENCE REPORT
-- Market share + conversion rate + dual ranking
-- ================================================

WITH category_listings AS (
    SELECT
        category,
        COUNT(*)                                            AS total_listed,
        SUM(CASE WHEN status = 'sold'   THEN 1 ELSE 0 END) AS total_sold,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS still_active,
        ROUND(AVG(price))                                   AS avg_price,
        MIN(price)                                          AS min_price,
        MAX(price)                                          AS max_price
    FROM products
    GROUP BY category
),
category_revenue AS (
    SELECT
        p.category,
        COALESCE(SUM(o.amount), 0)    AS revenue,
        COALESCE(COUNT(o.order_id), 0) AS orders
    FROM products p
    LEFT JOIN orders o ON p.product_id = o.product_id
    GROUP BY p.category
)
SELECT
    cl.category,
    cl.total_listed,
    cl.total_sold,
    cl.still_active,
    cl.avg_price,
    cl.min_price,
    cl.max_price,
    cr.revenue,
    cr.orders,
    ROUND(cl.total_sold * 100.0 /
          NULLIF(cl.total_listed, 0), 1)          AS conversion_rate_pct,
    ROUND(cr.revenue * 100.0 /
          NULLIF(SUM(cr.revenue) OVER (), 0), 1)  AS revenue_share_pct,
    RANK() OVER (ORDER BY cr.revenue DESC)         AS revenue_rank,
    RANK() OVER (
        ORDER BY cl.total_sold * 1.0 /
        NULLIF(cl.total_listed, 0) DESC
    )                                              AS conversion_rank
FROM category_listings cl
INNER JOIN category_revenue cr ON cl.category = cr.category
ORDER BY cr.revenue DESC;

-- ================================================
-- CASE 4: CROSS-COUNTRY TRANSACTION FLOW
-- Money flow matrix + top cross-border pairs
-- ================================================

-- Full transaction matrix
WITH transaction_flow AS (
    SELECT
        buyer.country  AS from_country,
        seller.country AS to_country,
        COUNT(*)       AS transaction_count,
        SUM(o.amount)  AS total_value,
        ROUND(AVG(o.amount)) AS avg_transaction
    FROM orders o
    INNER JOIN users buyer  ON o.buyer_id   = buyer.user_id
    INNER JOIN products p   ON o.product_id = p.product_id
    INNER JOIN users seller ON p.seller_id  = seller.user_id
    GROUP BY buyer.country, seller.country
)
SELECT
    RANK() OVER (ORDER BY total_value DESC) AS value_rank,
    from_country AS buyer_country,
    to_country   AS seller_country,
    CASE
        WHEN from_country = to_country THEN 'Domestic'
        ELSE                                'International'
    END AS flow_type,
    transaction_count,
    total_value,
    avg_transaction
FROM transaction_flow
ORDER BY total_value DESC;

-- Top 3 cross-border pairs
SELECT
    buyer.country  AS from_country,
    seller.country AS to_country,
    COUNT(*)       AS transactions,
    SUM(o.amount)  AS total_value
FROM orders o
INNER JOIN users buyer  ON o.buyer_id   = buyer.user_id
INNER JOIN products p   ON o.product_id = p.product_id
INNER JOIN users seller ON p.seller_id  = seller.user_id
WHERE buyer.country != seller.country
GROUP BY buyer.country, seller.country
ORDER BY total_value DESC
LIMIT 3;

-- ================================================
-- CASE 5: GROWTH OPPORTUNITIES
-- Inactive users, dead stock, potential sellers
-- ================================================

-- Opportunity 1: Inactive users
SELECT
    'Inactive Users' AS opportunity,
    username,
    country,
    age,
    DATEDIFF(NOW(), created_at) AS days_since_joined
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM orders   o WHERE o.buyer_id  = u.user_id)
AND   NOT EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)
ORDER BY days_since_joined DESC;

-- Opportunity 2: Dead stock
SELECT
    p.title,
    p.category,
    p.price,
    u.username AS seller,
    u.country,
    CASE
        WHEN p.price > (SELECT AVG(price) FROM products)
             THEN 'Possibly overpriced'
        ELSE 'Check visibility / promotion'
    END AS recommendation
FROM products p
INNER JOIN users u ON p.seller_id = u.user_id
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.product_id = p.product_id
)
ORDER BY p.price DESC;

-- Opportunity 3: Buyers who haven't sold yet
SELECT
    u.username,
    u.country,
    COUNT(o.order_id) AS orders_placed,
    SUM(o.amount)     AS total_spent,
    'Convert to seller' AS recommendation
FROM users u
INNER JOIN orders o ON u.user_id = o.buyer_id
WHERE NOT EXISTS (
    SELECT 1 FROM products p WHERE p.seller_id = u.user_id
)
GROUP BY u.user_id, u.username, u.country
ORDER BY total_spent DESC;

-- Opportunity 4: Underperforming categories
SELECT
    category,
    COUNT(*) AS listed,
    SUM(CASE WHEN status = 'sold' THEN 1 ELSE 0 END) AS sold,
    ROUND(SUM(CASE WHEN status = 'sold' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 1) AS conversion_pct,
    'Needs marketing push' AS recommendation
FROM products
GROUP BY category
HAVING conversion_pct < 50
ORDER BY conversion_pct ASC;

-- ================================================
-- EXECUTIVE DASHBOARD — All KPIs in one place
-- ================================================

-- Platform KPIs
SELECT
    (SELECT COUNT(*) FROM users)                AS total_users,
    (SELECT COUNT(*) FROM products)             AS total_products,
    (SELECT COUNT(*) FROM orders)               AS total_orders,
    (SELECT COALESCE(SUM(amount), 0) FROM orders) AS total_revenue,
    (SELECT COUNT(DISTINCT country) FROM users) AS markets,
    (SELECT ROUND(AVG(amount)) FROM orders)     AS avg_order_value;

-- Top 3 sellers
SELECT u.username, u.country,
       SUM(o.amount) AS revenue,
       RANK() OVER (ORDER BY SUM(o.amount) DESC) AS rnk
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
INNER JOIN users u    ON p.seller_id  = u.user_id
GROUP BY u.user_id, u.username, u.country
ORDER BY revenue DESC
LIMIT 3;

-- Category performance
SELECT
    p.category,
    COUNT(DISTINCT p.product_id)  AS products,
    COUNT(o.order_id)             AS sales,
    COALESCE(SUM(o.amount), 0)    AS revenue
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- User segment counts
SELECT user_type, COUNT(*) AS count
FROM (
    SELECT
        CASE
            WHEN EXISTS (SELECT 1 FROM orders   o WHERE o.buyer_id  = u.user_id)
             AND EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)
                 THEN 'Power User'
            WHEN EXISTS (SELECT 1 FROM orders o   WHERE o.buyer_id  = u.user_id)
                 THEN 'Buyer Only'
            WHEN EXISTS (SELECT 1 FROM products p WHERE p.seller_id = u.user_id)
                 THEN 'Seller Only'
            ELSE 'Inactive'
        END AS user_type
    FROM users u
) AS segs
GROUP BY user_type
ORDER BY count DESC;
