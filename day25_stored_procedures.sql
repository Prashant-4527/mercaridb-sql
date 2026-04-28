-- ================================================
-- MercariDB -- Day 25
-- Topic: Stored Procedures + Functions
-- Author: Prashant
-- Date: 2026-04-13
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
-- STORED PROCEDURES
-- DELIMITER must be changed before creating!
-- ================================================

-- Basic procedure: no parameters
DELIMITER $$

CREATE PROCEDURE get_all_users()
BEGIN
    SELECT user_id, username, country, age
    FROM users
    ORDER BY user_id;
END$$

DELIMITER ;

CALL get_all_users();
DROP PROCEDURE IF EXISTS get_all_users;

-- ================================================
-- IN PARAMETER — input from caller
-- ================================================

DELIMITER $$

CREATE PROCEDURE get_seller_stats(IN p_seller_id INT)
BEGIN
    SELECT
        u.username,
        u.country,
        COUNT(DISTINCT p.product_id)   AS total_listings,
        COALESCE(SUM(o.amount), 0)     AS total_revenue,
        COALESCE(COUNT(o.order_id), 0) AS total_sales
    FROM users u
    LEFT JOIN products p ON u.user_id    = p.seller_id
    LEFT JOIN orders o   ON p.product_id = o.product_id
    WHERE u.user_id = p_seller_id
    GROUP BY u.user_id, u.username, u.country;
END$$

DELIMITER ;

CALL get_seller_stats(2);   -- tanaka_hiroshi
CALL get_seller_stats(5);   -- rahul_sharma
CALL get_seller_stats(1);   -- prashant_jpr

-- Multiple IN parameters
DELIMITER $$

CREATE PROCEDURE get_products_by_filter(
    IN p_category  VARCHAR(100),
    IN p_min_price DECIMAL(10,2),
    IN p_max_price DECIMAL(10,2)
)
BEGIN
    SELECT
        p.title,
        p.category,
        p.price,
        p.status,
        u.username AS seller
    FROM products p
    INNER JOIN users u ON p.seller_id = u.user_id
    WHERE p.category = p_category
      AND p.price BETWEEN p_min_price AND p_max_price
    ORDER BY p.price DESC;
END$$

DELIMITER ;

CALL get_products_by_filter('Electronics', 10000, 60000);
CALL get_products_by_filter('Fashion', 0, 10000);
CALL get_products_by_filter('Books', 0, 5000);

-- ================================================
-- OUT PARAMETER — return value to caller
-- ================================================

DELIMITER $$

CREATE PROCEDURE get_platform_stats(
    OUT p_total_users    INT,
    OUT p_total_products INT,
    OUT p_total_revenue  DECIMAL(15,2)
)
BEGIN
    SELECT COUNT(*)              INTO p_total_users    FROM users;
    SELECT COUNT(*)              INTO p_total_products FROM products;
    SELECT COALESCE(SUM(amount), 0) INTO p_total_revenue FROM orders;
END$$

DELIMITER ;

-- Call and read OUT values via session variables (@)
CALL get_platform_stats(@users, @products, @revenue);
SELECT
    @users    AS total_users,
    @products AS total_products,
    @revenue  AS total_revenue;

-- ================================================
-- INOUT PARAMETER — both input and output
-- ================================================

DELIMITER $$

CREATE PROCEDURE apply_discount(
    INOUT p_price DECIMAL(10,2),
    IN    p_pct   INT
)
BEGIN
    SET p_price = p_price - (p_price * p_pct / 100);
END$$

DELIMITER ;

SET @price = 45000.00;
CALL apply_discount(@price, 10);   -- 10% discount
SELECT @price AS discounted_price; -- 40500.00

-- ================================================
-- IF ELSE + DECLARE variables inside procedure
-- ================================================

DELIMITER $$

CREATE PROCEDURE classify_seller(IN p_seller_id INT)
BEGIN
    DECLARE v_revenue  DECIMAL(15,2);
    DECLARE v_tier     VARCHAR(20);
    DECLARE v_username VARCHAR(50);

    -- Fetch revenue into variable
    SELECT
        u.username,
        COALESCE(SUM(o.amount), 0)
    INTO v_username, v_revenue
    FROM users u
    LEFT JOIN products p  ON u.user_id    = p.seller_id
    LEFT JOIN orders o    ON p.product_id = o.product_id
    WHERE u.user_id = p_seller_id
    GROUP BY u.user_id, u.username;

    -- IF ELSE classification
    IF v_revenue >= 50000 THEN
        SET v_tier = 'Diamond';
    ELSEIF v_revenue >= 20000 THEN
        SET v_tier = 'Gold';
    ELSEIF v_revenue >= 5000 THEN
        SET v_tier = 'Silver';
    ELSE
        SET v_tier = 'Bronze';
    END IF;

    -- Return result
    SELECT v_username AS seller, v_revenue AS revenue, v_tier AS tier;
END$$

DELIMITER ;

CALL classify_seller(2);   -- tanaka
CALL classify_seller(5);   -- rahul
CALL classify_seller(1);   -- prashant

-- ================================================
-- STORED FUNCTIONS
-- Returns single value, usable in SQL queries
-- ================================================

DELIMITER $$

-- Function: seller tier as string
CREATE FUNCTION get_seller_tier(p_seller_id INT)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_revenue DECIMAL(15,2);
    DECLARE v_tier    VARCHAR(20);

    SELECT COALESCE(SUM(o.amount), 0)
    INTO v_revenue
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    WHERE p.seller_id = p_seller_id;

    IF v_revenue >= 50000 THEN
        SET v_tier = 'Diamond';
    ELSEIF v_revenue >= 20000 THEN
        SET v_tier = 'Gold';
    ELSEIF v_revenue >= 5000 THEN
        SET v_tier = 'Silver';
    ELSE
        SET v_tier = 'Bronze';
    END IF;

    RETURN v_tier;
END$$

-- Function: age group label
CREATE FUNCTION get_age_group(p_age INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE v_group VARCHAR(20);

    IF p_age < 20 THEN
        SET v_group = 'Teen';
    ELSEIF p_age BETWEEN 20 AND 26 THEN
        SET v_group = 'Gen Z';
    ELSEIF p_age BETWEEN 27 AND 42 THEN
        SET v_group = 'Millennial';
    ELSE
        SET v_group = 'Other';
    END IF;

    RETURN v_group;
END$$

DELIMITER ;

-- Use functions INSIDE queries!
SELECT
    u.username,
    u.age,
    get_age_group(u.age)       AS generation,
    get_seller_tier(u.user_id) AS seller_tier
FROM users u
ORDER BY u.age;

-- Use in WHERE clause
SELECT username, age
FROM users
WHERE get_age_group(age) = 'Gen Z';

-- Use in GROUP BY + HAVING
SELECT
    get_age_group(age) AS generation,
    COUNT(*)           AS users
FROM users
GROUP BY get_age_group(age)
HAVING COUNT(*) >= 2;

-- ================================================
-- WHILE LOOP in procedure
-- ================================================

DELIMITER $$

CREATE PROCEDURE generate_test_users(IN p_count INT)
BEGIN
    DECLARE v_i        INT DEFAULT 1;
    DECLARE v_username VARCHAR(50);
    DECLARE v_email    VARCHAR(100);

    WHILE v_i <= p_count DO
        SET v_username = CONCAT('test_user_', v_i);
        SET v_email    = CONCAT('test', v_i, '@gmail.com');

        INSERT INTO users (username, email, country, age)
        VALUES (v_username, v_email, 'India', 20 + v_i);

        SET v_i = v_i + 1;
    END WHILE;

    SELECT CONCAT(p_count, ' test users created!') AS result;
END$$

DELIMITER ;

CALL generate_test_users(3);
SELECT username, email, age FROM users WHERE username LIKE 'test_user%';
DELETE FROM users WHERE username LIKE 'test_user%';

-- ================================================
-- MANAGE PROCEDURES + FUNCTIONS
-- ================================================

SHOW PROCEDURE STATUS WHERE Db = 'mercaridb';
SHOW FUNCTION  STATUS WHERE Db = 'mercaridb';

SHOW CREATE PROCEDURE get_seller_stats;
SHOW CREATE FUNCTION  get_seller_tier;

-- Drop all
DROP PROCEDURE IF EXISTS get_seller_stats;
DROP PROCEDURE IF EXISTS get_products_by_filter;
DROP PROCEDURE IF EXISTS get_platform_stats;
DROP PROCEDURE IF EXISTS apply_discount;
DROP PROCEDURE IF EXISTS classify_seller;
DROP PROCEDURE IF EXISTS generate_test_users;
DROP FUNCTION  IF EXISTS get_seller_tier;
DROP FUNCTION  IF EXISTS get_age_group;

-- ================================================
-- QUICK REFERENCE
-- ================================================
-- PROCEDURE:
--   DELIMITER $$
--   CREATE PROCEDURE name(IN p INT, OUT q INT)
--   BEGIN ... END$$
--   DELIMITER ;
--   CALL name(val, @var);
--
-- FUNCTION:
--   DELIMITER $$
--   CREATE FUNCTION name(p INT) RETURNS VARCHAR(20)
--   DETERMINISTIC READS SQL DATA
--   BEGIN DECLARE v VARCHAR(20); ... RETURN v; END$$
--   DELIMITER ;
--   SELECT name(val) FROM table;
--
-- VARIABLES:
--   DECLARE v_name TYPE;           local variable
--   SET v_name = value;            assign value
--   SELECT col INTO v_name FROM..  assign from query
--   @session_var                   session variable
--
-- FLOW CONTROL:
--   IF cond THEN ... ELSEIF ... ELSE ... END IF;
--   WHILE cond DO ... END WHILE;
--   LOOP ... END LOOP;
