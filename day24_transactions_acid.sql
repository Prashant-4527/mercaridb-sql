-- ================================================
-- MercariDB -- Day 24
-- Topic: Transactions + ACID Properties
-- Author: Prashant
-- Date: 2026-04-12
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
-- BASIC TRANSACTION SYNTAX
-- START TRANSACTION → COMMIT or ROLLBACK
-- ================================================

-- Simple COMMIT example
START TRANSACTION;
    UPDATE users SET age = 18 WHERE username = 'prashant_jpr';
    UPDATE users SET age = 29 WHERE username = 'tanaka_hiroshi';
COMMIT;

SELECT username, age FROM users
WHERE username IN ('prashant_jpr', 'tanaka_hiroshi');

-- Revert:
START TRANSACTION;
    UPDATE users SET age = 17 WHERE username = 'prashant_jpr';
    UPDATE users SET age = 28 WHERE username = 'tanaka_hiroshi';
COMMIT;

-- ROLLBACK example — undo everything!
START TRANSACTION;
    INSERT INTO users (username, email, country, age)
    VALUES ('test_user', 'test@gmail.com', 'India', 25);

    SELECT * FROM users WHERE username = 'test_user';
    -- Row visible WITHIN this transaction!

ROLLBACK;
-- Row is GONE — as if it never happened!

SELECT * FROM users WHERE username = 'test_user';
-- Empty result ✅

-- ================================================
-- AUTOCOMMIT
-- MySQL default: every statement auto-commits!
-- Disable to control manually
-- ================================================

SELECT @@autocommit;  -- check current setting (1 = on)

-- Disable autocommit
SET autocommit = 0;
    UPDATE users SET age = 99 WHERE username = 'prashant_jpr';
    -- Not committed yet!
    SELECT age FROM users WHERE username = 'prashant_jpr';
    -- Shows 99 in THIS session
ROLLBACK;
-- Undone!
SELECT age FROM users WHERE username = 'prashant_jpr';
-- Back to 17 ✅

-- Re-enable autocommit
SET autocommit = 1;

-- ================================================
-- ACID — ATOMICITY
-- All or nothing!
-- ================================================

-- Simulated Mercari purchase
START TRANSACTION;

    -- Step 1: Create order
    INSERT INTO orders (product_id, buyer_id, amount)
    VALUES (4, 1, 1200.00);

    -- Step 2: Mark product sold
    UPDATE products SET status = 'sold' WHERE product_id = 4;

    -- Both steps succeed → COMMIT
COMMIT;

-- Verify atomicity: both happened!
SELECT status FROM products WHERE product_id = 4;
SELECT * FROM orders WHERE product_id = 4 AND buyer_id = 1;

-- Cleanup
DELETE FROM orders WHERE product_id = 4 AND buyer_id = 1;
UPDATE products SET status = 'active' WHERE product_id = 4;

-- ROLLBACK simulation: payment failed mid-transaction
START TRANSACTION;
    INSERT INTO orders (product_id, buyer_id, amount)
    VALUES (5, 3, 22000.00);
    UPDATE products SET status = 'sold' WHERE product_id = 5;
    -- Server crash / payment timeout!
ROLLBACK;

-- Neither happened:
SELECT status FROM products WHERE product_id = 5;  -- still 'active'
SELECT COUNT(*) FROM orders WHERE product_id = 5;  -- 0

-- ================================================
-- ACID — CONSISTENCY
-- Database always in valid state
-- Constraints enforced!
-- ================================================

-- FK constraint enforces consistency
START TRANSACTION;
    -- This FAILS — seller_id 9999 doesn't exist!
    -- INSERT INTO products (seller_id, title, price)
    -- VALUES (9999, 'Ghost Product', 5000.00);

    -- This WORKS — seller_id 2 exists
    INSERT INTO products (seller_id, title, category, price)
    VALUES (2, 'Consistency Test', 'Electronics', 7777.00);
COMMIT;

SELECT * FROM products WHERE title = 'Consistency Test';
DELETE FROM products WHERE title = 'Consistency Test';

-- ================================================
-- ACID — ISOLATION
-- Concurrent transactions don't interfere
-- ================================================

-- Check current isolation level
SELECT @@transaction_isolation;
-- MySQL default: REPEATABLE-READ

-- 4 Isolation Levels (low to high safety):
-- READ UNCOMMITTED → dirty reads (most dangerous)
-- READ COMMITTED   → only committed data visible
-- REPEATABLE READ  → MySQL default
-- SERIALIZABLE     → strictest, slowest

-- Change isolation level for session:
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation;  -- now READ-COMMITTED

-- Reset to MySQL default:
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT @@transaction_isolation;  -- back to REPEATABLE-READ

-- ================================================
-- ACID — DURABILITY
-- Committed data survives crashes!
-- ================================================

START TRANSACTION;
    INSERT INTO users (username, email, country, age)
    VALUES ('durable_user', 'durable@gmail.com', 'India', 20);
COMMIT;
-- Even if power cuts NOW → this row is permanent!
-- MySQL InnoDB writes to disk before COMMIT returns

SELECT * FROM users WHERE username = 'durable_user';
DELETE FROM users WHERE username = 'durable_user';

-- ================================================
-- SAVEPOINTS
-- Partial rollback within a transaction
-- ================================================

START TRANSACTION;

    INSERT INTO users (username, email, country, age)
    VALUES ('user_a', 'usera@gmail.com', 'India', 22);

    SAVEPOINT after_user_a;  -- checkpoint 1

    INSERT INTO users (username, email, country, age)
    VALUES ('user_b', 'userb@gmail.com', 'Japan', 25);

    SAVEPOINT after_user_b;  -- checkpoint 2

    INSERT INTO users (username, email, country, age)
    VALUES ('user_c', 'userc@gmail.com', 'USA', 28);

    -- Oops! user_c was a mistake
    ROLLBACK TO after_user_b;
    -- Only user_c insert is undone
    -- user_a and user_b still in transaction!

COMMIT;

-- Result:
SELECT username FROM users
WHERE username IN ('user_a', 'user_b', 'user_c');
-- user_a ✅  user_b ✅  user_c ❌ (rolled back)

-- Cleanup
DELETE FROM users WHERE username IN ('user_a', 'user_b');

-- RELEASE SAVEPOINT (optional — frees memory)
-- START TRANSACTION;
-- SAVEPOINT sp1;
-- RELEASE SAVEPOINT sp1;  -- remove savepoint
-- COMMIT;

-- ================================================
-- COMPLETE MERCARI TRANSACTION FLOW
-- ================================================

START TRANSACTION;

    -- 1. Create the order
    INSERT INTO orders (product_id, buyer_id, amount)
    VALUES (6, 2, 3500.00);  -- tanaka buys camera roll

    SAVEPOINT order_created;

    -- 2. Mark product sold
    UPDATE products SET status = 'sold' WHERE product_id = 6;

    SAVEPOINT product_updated;

    -- 3. Final verification
    SELECT
        o.order_id,
        buyer.username  AS buyer,
        seller.username AS seller,
        p.title,
        p.status,
        o.amount
    FROM orders o
    INNER JOIN users buyer  ON o.buyer_id   = buyer.user_id
    INNER JOIN products p   ON o.product_id = p.product_id
    INNER JOIN users seller ON p.seller_id  = seller.user_id
    WHERE p.product_id = 6;

COMMIT;

-- Verify committed:
SELECT title, status FROM products WHERE product_id = 6;

-- Cleanup
DELETE FROM orders WHERE product_id = 6 AND buyer_id = 2;
UPDATE products SET status = 'active' WHERE product_id = 6;

-- ================================================
-- QUICK REFERENCE
-- ================================================
-- START TRANSACTION  → begin transaction
-- COMMIT             → permanently save all changes
-- ROLLBACK           → undo all changes
-- SAVEPOINT name     → create a checkpoint
-- ROLLBACK TO name   → undo to checkpoint
-- RELEASE SAVEPOINT  → remove checkpoint
-- SET autocommit = 0 → manual commit mode
-- SET autocommit = 1 → auto commit mode (default)

-- ACID:
-- Atomicity    = all or nothing
-- Consistency  = always valid state
-- Isolation    = transactions don't interfere
-- Durability   = committed = permanent

-- ISOLATION LEVELS (low → high):
-- READ UNCOMMITTED → dirty reads possible
-- READ COMMITTED   → only committed data
-- REPEATABLE READ  → MySQL default
-- SERIALIZABLE     → strictest
