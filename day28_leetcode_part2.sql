-- ================================================
-- MercariDB -- Day 28
-- Topic: LeetCode SQL Top Problems — Part 2
-- Patterns: Moving Average, Pivot, Median,
--           Game Analytics, Advanced Window Fns
-- Author: Prashant
-- Date: 2026-04-16
-- ================================================

DROP DATABASE IF EXISTS mercaridb;
CREATE DATABASE mercaridb;
USE mercaridb;

-- MercariDB core tables
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

-- LeetCode-style tables
CREATE TABLE activity (
    player_id    INT, device_id INT,
    event_date   DATE, games_played INT
);
CREATE TABLE project    (project_id INT, employee_id INT);
CREATE TABLE emp_data   (employee_id INT, emp_name VARCHAR(50), experience_years INT);
CREATE TABLE student_scores (student_id INT, subject VARCHAR(20), score INT);
CREATE TABLE customer_visits (visited_on DATE, amount INT);
CREATE TABLE friend_requests (sender_id INT, receiver_id INT, request_date DATE);
CREATE TABLE request_accepted (requester_id INT, accepter_id INT, accept_date DATE);
CREATE TABLE company_salary (company_id INT, employee_id INT, salary INT);
CREATE TABLE trips (id INT, client_id INT, driver_id INT,
                   city_id INT, status VARCHAR(30), request_at DATE);
CREATE TABLE banned_users (users_id INT, banned VARCHAR(5), role VARCHAR(10));
CREATE TABLE stadium (id INT, visit_date DATE, people INT);

-- Insert data
INSERT INTO users (username, email, country, age, referred_by) VALUES
('prashant_jpr','prashant@gmail.com','India',17,2),
('tanaka_hiroshi','tanaka@mercari.jp','Japan',28,NULL),
('yuki_suzuki','yuki@gmail.com','Japan',22,2),
('sarah_chen','sarah@yahoo.com','USA',34,NULL),
('rahul_sharma','rahul@gmail.com','India',26,1),
('amit_verma','amit@hotmail.com','India',31,NULL),
('kenji_watanabe','kenji@docomo.jp','Japan',19,NULL),
('lisa_mueller','lisa@gmail.de','Germany',29,NULL),
('wang_fang','wang@qq.com','China',24,NULL),
('priya_nair','priya@gmail.com','India',20,5),
('carlos_mx','carlos@gmail.mx','Mexico',27,NULL);

INSERT INTO products (seller_id, title, category, price, status) VALUES
(2,'iPhone 13 Pro 256GB','Electronics',45000.00,'active'),
(2,'Sony WH-1000XM4 Headphones','Electronics',18000.00,'active'),
(3,'Nike Air Max 2021','Fashion',8500.00,'sold'),
(4,'Python Programming Book','Books',1200.00,'active'),
(5,'Dell Monitor 27 inch','Electronics',22000.00,'active'),
(6,'Vintage Camera Film Roll','Photography',3500.00,'active'),
(7,'Mechanical Keyboard RGB','Electronics',7800.00,'active'),
(8,'Levi Jeans 512 Slim','Fashion',4200.00,'sold'),
(2,'iPad Air 5th Gen','Electronics',55000.00,'active'),
(5,'Logitech MX Master 3','Electronics',8900.00,'active'),
(1,'Data Science Handbook','Books',1800.00,'active'),
(3,'Adidas Ultraboost 22','Fashion',9500.00,'active'),
(10,'Yoga Mat Premium','Sports',2200.00,'active');

INSERT INTO orders (product_id, buyer_id, amount) VALUES
(1,5,45000.00),(3,1,8500.00),(4,7,1200.00),
(8,3,4200.00),(9,6,55000.00),(11,2,1800.00),(13,4,2200.00);

INSERT INTO activity VALUES
(1,2,'2024-03-01',5),(1,2,'2024-05-02',6),
(2,3,'2024-02-03',1),(3,1,'2024-03-01',0),(3,4,'2024-07-03',5);

INSERT INTO project VALUES (1,1),(1,2),(1,3),(2,1),(2,4);
INSERT INTO emp_data VALUES (1,'Khaled',3),(2,'Ali',2),(3,'John',1),(4,'Doe',2);

INSERT INTO student_scores VALUES
(1,'Math',90),(1,'Science',85),(1,'English',78),
(2,'Math',70),(2,'Science',92),(2,'English',88),
(3,'Math',95),(3,'Science',67),(3,'English',91);

INSERT INTO customer_visits VALUES
('2024-01-01',100),('2024-01-02',110),('2024-01-03',120),
('2024-01-04',130),('2024-01-05',110),('2024-01-06',140),
('2024-01-07',150),('2024-01-08',80);

INSERT INTO friend_requests VALUES
(1,2,'2024-01-01'),(1,3,'2024-01-01'),(2,4,'2024-01-02');
INSERT INTO request_accepted VALUES
(1,2,'2024-01-04'),(1,3,'2024-01-05'),(2,4,'2024-01-06');

INSERT INTO company_salary VALUES
(1,1,2341),(1,2,341),(1,3,15),(1,4,15314),(1,5,451),(1,6,513),
(2,7,930),(2,8,3064),(2,9,55),(2,10,730),(2,11,1741),
(3,12,1804),(3,13,1422);

INSERT INTO trips VALUES
(1,1,10,1,'completed','2024-10-01'),
(2,2,11,1,'cancelled_by_driver','2024-10-01'),
(3,3,12,6,'completed','2024-10-01'),
(4,4,13,6,'cancelled_by_client','2024-10-02'),
(5,1,10,1,'completed','2024-10-02'),
(6,2,11,6,'completed','2024-10-02'),
(7,3,12,6,'completed','2024-10-03');

INSERT INTO banned_users VALUES
(1,'No','client'),(2,'Yes','client'),(3,'No','client'),(4,'No','client'),
(10,'No','driver'),(11,'No','driver'),(12,'No','driver'),(13,'No','driver');

INSERT INTO stadium VALUES
(1,'2024-01-01',10),(2,'2024-01-02',109),(3,'2024-01-03',150),
(4,'2024-01-04',99),(5,'2024-01-05',145),(6,'2024-01-06',1455),
(7,'2024-01-07',199),(8,'2024-01-08',188);

-- ================================================
-- PATTERN 1: GAME PLAY ANALYSIS (LC 511/512/534)
-- ================================================

-- First login per player (LC 511)
SELECT player_id, MIN(event_date) AS first_login
FROM activity
GROUP BY player_id;

-- Device on first login (LC 512)
SELECT player_id, device_id
FROM (
    SELECT player_id, device_id, event_date,
           RANK() OVER (PARTITION BY player_id ORDER BY event_date) AS rnk
    FROM activity
) AS ranked
WHERE rnk = 1;

-- Cumulative games per player (LC 534)
SELECT
    player_id,
    event_date,
    SUM(games_played) OVER (
        PARTITION BY player_id
        ORDER BY event_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS games_played_so_far
FROM activity;

-- Day-1 retention fraction (LC 550)
WITH first_logins AS (
    SELECT player_id, MIN(event_date) AS first_date
    FROM activity GROUP BY player_id
),
next_day AS (
    SELECT f.player_id
    FROM first_logins f
    WHERE EXISTS (
        SELECT 1 FROM activity a
        WHERE a.player_id = f.player_id
          AND a.event_date = DATE_ADD(f.first_date, INTERVAL 1 DAY)
    )
)
SELECT ROUND(
    COUNT(DISTINCT n.player_id) * 1.0 /
    COUNT(DISTINCT f.player_id), 2) AS fraction
FROM first_logins f
LEFT JOIN next_day n ON f.player_id = n.player_id;

-- ================================================
-- PATTERN 2: PROJECT EMPLOYEES (LC 1075/1076)
-- ================================================

-- Average experience per project
SELECT p.project_id,
       ROUND(AVG(e.experience_years), 2) AS average_years
FROM project p
INNER JOIN emp_data e ON p.employee_id = e.employee_id
GROUP BY p.project_id;

-- Project with most employees
SELECT project_id
FROM project
GROUP BY project_id
HAVING COUNT(employee_id) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(employee_id) AS cnt
        FROM project GROUP BY project_id
    ) AS counts
);

-- ================================================
-- PATTERN 3: PIVOT TABLE
-- ================================================

-- Student scores pivoted
SELECT
    student_id,
    MAX(CASE WHEN subject = 'Math'    THEN score END) AS Math,
    MAX(CASE WHEN subject = 'Science' THEN score END) AS Science,
    MAX(CASE WHEN subject = 'English' THEN score END) AS English
FROM student_scores
GROUP BY student_id
ORDER BY student_id;

-- MercariDB pivot: listings per category per country
SELECT
    country,
    SUM(CASE WHEN p.category = 'Electronics' THEN 1 ELSE 0 END) AS Electronics,
    SUM(CASE WHEN p.category = 'Fashion'     THEN 1 ELSE 0 END) AS Fashion,
    SUM(CASE WHEN p.category = 'Books'       THEN 1 ELSE 0 END) AS Books,
    SUM(CASE WHEN p.category = 'Photography' THEN 1 ELSE 0 END) AS Photography,
    SUM(CASE WHEN p.category = 'Sports'      THEN 1 ELSE 0 END) AS Sports,
    COUNT(p.product_id) AS total
FROM users u
LEFT JOIN products p ON u.user_id = p.seller_id
GROUP BY country
ORDER BY total DESC;

-- ================================================
-- PATTERN 4: MOVING AVERAGE (LC 1321)
-- ================================================

-- 7-day moving average
SELECT
    visited_on,
    SUM(amount) OVER (
        ORDER BY visited_on
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS amount_7day,
    ROUND(AVG(amount) OVER (
        ORDER BY visited_on
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS average_7day
FROM customer_visits
WHERE visited_on >= (
    SELECT MIN(visited_on) + INTERVAL 6 DAY
    FROM customer_visits
);

-- Frame clause options reference:
-- ROWS UNBOUNDED PRECEDING → running total from start
-- ROWS 6 PRECEDING         → 7-day moving window
-- ROWS 1 PRECEDING AND 1 FOLLOWING → 3-day centered avg

-- ================================================
-- PATTERN 5: FRIEND REQUESTS (LC 602)
-- ================================================

-- Acceptance rate
SELECT ROUND(
    COUNT(DISTINCT ra.requester_id, ra.accepter_id) * 1.0 /
    COUNT(DISTINCT fr.sender_id, fr.receiver_id), 2
) AS accept_rate
FROM friend_requests fr
LEFT JOIN request_accepted ra
    ON fr.sender_id   = ra.requester_id
   AND fr.receiver_id = ra.accepter_id;

-- Most friends (both directions)
SELECT id, COUNT(*) AS num_friends
FROM (
    SELECT requester_id AS id FROM request_accepted
    UNION ALL
    SELECT accepter_id  AS id FROM request_accepted
) AS all_friends
GROUP BY id
ORDER BY num_friends DESC
LIMIT 1;

-- ================================================
-- PATTERN 6: MEDIAN SALARY
-- ================================================

WITH ranked AS (
    SELECT
        company_id, salary, employee_id,
        ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY salary ASC)  AS row_asc,
        ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY salary DESC) AS row_desc,
        COUNT(*) OVER (PARTITION BY company_id) AS total_count
    FROM company_salary
)
SELECT company_id, employee_id, salary
FROM ranked
WHERE row_asc  BETWEEN total_count / 2.0 AND total_count / 2.0 + 1
   OR row_desc BETWEEN total_count / 2.0 AND total_count / 2.0 + 1
ORDER BY company_id, salary;

-- ================================================
-- PATTERN 7: TRIPS AND USERS (LC 262 — Hard)
-- ================================================

SELECT
    t.request_at AS Day,
    ROUND(
        SUM(CASE WHEN t.status != 'completed' THEN 1 ELSE 0 END) * 1.0 /
        COUNT(*), 2
    ) AS 'Cancellation Rate'
FROM trips t
WHERE t.client_id NOT IN (
    SELECT users_id FROM banned_users WHERE banned='Yes' AND role='client'
)
AND t.driver_id NOT IN (
    SELECT users_id FROM banned_users WHERE banned='Yes' AND role='driver'
)
GROUP BY t.request_at
ORDER BY t.request_at;

-- ================================================
-- PATTERN 8: CONSECUTIVE ROWS WITH CONDITION (LC 601)
-- ================================================

SELECT DISTINCT s1.*
FROM stadium s1, stadium s2, stadium s3
WHERE s1.people >= 100 AND s2.people >= 100 AND s3.people >= 100
AND (
    (s1.id = s2.id-1 AND s1.id = s3.id-2)
 OR (s2.id = s1.id-1 AND s2.id = s3.id-2)
 OR (s3.id = s1.id-1 AND s3.id = s2.id-2)
)
ORDER BY s1.visit_date;

-- ================================================
-- PATTERN 9: MERCARIDB ADVANCED ANALYTICS
-- ================================================

-- Month-over-month revenue growth
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(amount) AS revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0 /
        NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1
    ) AS growth_pct
FROM monthly
ORDER BY month;

-- Cumulative revenue per seller
SELECT
    u.username,
    o.order_date,
    o.amount,
    SUM(o.amount) OVER (
        PARTITION BY p.seller_id
        ORDER BY o.order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
INNER JOIN users u    ON p.seller_id  = u.user_id
ORDER BY u.username, o.order_date;

-- Product price percentile
SELECT
    title, category, price,
    ROUND(PERCENT_RANK() OVER (ORDER BY price) * 100, 1) AS price_percentile,
    NTILE(4) OVER (ORDER BY price) AS price_quartile
FROM products
ORDER BY price DESC;

-- Buyer lifetime value analysis
SELECT
    u.username,
    MIN(o.order_date)  AS first_order,
    MAX(o.order_date)  AS last_order,
    DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS days_as_customer,
    COUNT(o.order_id)  AS total_orders,
    SUM(o.amount)      AS lifetime_value,
    ROUND(AVG(o.amount)) AS avg_order_value
FROM orders o
INNER JOIN users u ON o.buyer_id = u.user_id
GROUP BY u.user_id, u.username
ORDER BY lifetime_value DESC;

-- Price quartile labels
SELECT
    title, category, price,
    NTILE(4) OVER (ORDER BY price) AS quartile,
    CASE NTILE(4) OVER (ORDER BY price)
        WHEN 1 THEN 'Bottom 25%'
        WHEN 2 THEN 'Lower Mid 25%'
        WHEN 3 THEN 'Upper Mid 25%'
        WHEN 4 THEN 'Top 25%'
    END AS quartile_label,
    ROUND(price - AVG(price) OVER ()) AS vs_avg
FROM products
ORDER BY price DESC;

-- ================================================
-- COMPLETE PATTERN REFERENCE
-- ================================================
-- Running total:    SUM OVER (ORDER BY date ROWS UNBOUNDED PRECEDING)
-- Moving N-day avg: AVG OVER (ORDER BY date ROWS N-1 PRECEDING)
-- Pivot:            MAX(CASE WHEN col=val THEN score END) GROUP BY
-- Median:           ROW_NUMBER ASC+DESC, WHERE between n/2 and n/2+1
-- Percentile:       PERCENT_RANK() * 100  OR  NTILE(100)
-- MoM growth:       (current - LAG) / NULLIF(LAG, 0) * 100
-- Both-way friends: UNION ALL both sides, GROUP BY COUNT
-- Cancel rate:      SUM(CASE status!='done')/COUNT filtered
-- Consecutive+cond: Self JOIN id+1,id+2 all WHERE condition
-- Retention:        EXISTS next_day JOIN with DATE_ADD
