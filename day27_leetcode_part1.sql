-- ================================================
-- MercariDB -- Day 27
-- Topic: LeetCode SQL Top Problems — Part 1
-- Patterns: Nth Highest, Ranking, Consecutive,
--           Delete Duplicates, Self JOIN
-- Author: Prashant
-- Date: 2026-04-15
-- ================================================

DROP DATABASE IF EXISTS mercaridb;
CREATE DATABASE mercaridb;
USE mercaridb;

-- MercariDB tables
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
CREATE TABLE employees (
    emp_id     INT         NOT NULL,
    emp_name   VARCHAR(50) NOT NULL,
    salary     INT         NOT NULL,
    dept_id    INT,
    manager_id INT,
    PRIMARY KEY (emp_id)
);

CREATE TABLE departments (
    dept_id   INT         NOT NULL,
    dept_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (dept_id)
);

CREATE TABLE scores    (id INT, score DECIMAL(3,2));
CREATE TABLE logs      (id INT, num INT);
CREATE TABLE weather   (id INT, record_date DATE, temperature INT);
CREATE TABLE person_emails (id INT, email VARCHAR(100));
CREATE TABLE my_numbers    (num INT);

-- Insert data
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

INSERT INTO employees VALUES
(1,'Tanaka',85000,1,NULL),(2,'Prashant',42000,2,1),
(3,'Yuki',67000,1,1),(4,'Sarah',95000,2,NULL),
(5,'Rahul',54000,3,4),(6,'Amit',48000,3,4),
(7,'Kenji',71000,1,1),(8,'Lisa',88000,2,NULL),
(9,'Wang',39000,3,4),(10,'Carlos',62000,2,8);

INSERT INTO departments VALUES
(1,'Engineering'),(2,'Sales'),(3,'Marketing');

INSERT INTO scores VALUES
(1,3.50),(2,3.65),(3,4.00),(4,3.85),(5,4.00),(6,3.65);

INSERT INTO logs VALUES
(1,1),(2,1),(3,1),(4,2),(5,1),(6,2),(7,2);

INSERT INTO weather VALUES
(1,'2024-01-01',10),(2,'2024-01-02',25),
(3,'2024-01-03',20),(4,'2024-01-04',30);

INSERT INTO person_emails VALUES
(1,'john@example.com'),(2,'bob@example.com'),(3,'john@example.com');

INSERT INTO my_numbers VALUES (8),(8),(3),(3),(1),(4),(5),(6);

-- ================================================
-- PATTERN 1: Nth HIGHEST VALUE (LC 176)
-- ================================================

-- Second highest salary — NULL safe
SELECT MAX(salary) AS SecondHighestSalary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- Using DENSE_RANK (most flexible)
SELECT salary AS SecondHighestSalary
FROM (
    SELECT DISTINCT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
) AS ranked
WHERE rnk = 2
LIMIT 1;

-- Nth highest (general — change N here)
SELECT salary AS NthHighestSalary
FROM (
    SELECT DISTINCT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
) AS ranked
WHERE rnk = 3;

-- Applied to MercariDB: 2nd highest product price
SELECT MAX(price) AS SecondHighestPrice
FROM products
WHERE price < (SELECT MAX(price) FROM products);

-- ================================================
-- PATTERN 2: RANK SCORES (LC 178)
-- ================================================

-- DENSE_RANK: no gaps in ranking
SELECT
    score,
    DENSE_RANK() OVER (ORDER BY score DESC) AS `rank`
FROM scores
ORDER BY score DESC;
-- 4.00→1, 4.00→1, 3.85→2, 3.65→3, 3.65→3, 3.50→4

-- Applied to MercariDB: rank products by price
SELECT
    title,
    price,
    DENSE_RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products
ORDER BY price DESC;

-- ================================================
-- PATTERN 3: CONSECUTIVE NUMBERS (LC 180)
-- ================================================

-- Self JOIN approach
SELECT DISTINCT l1.num AS ConsecutiveNums
FROM logs l1
INNER JOIN logs l2 ON l2.id = l1.id + 1 AND l2.num = l1.num
INNER JOIN logs l3 ON l3.id = l1.id + 2 AND l3.num = l1.num;

-- LAG + LEAD approach (cleaner!)
SELECT DISTINCT num AS ConsecutiveNums
FROM (
    SELECT
        num,
        LAG(num)  OVER (ORDER BY id) AS prev_num,
        LEAD(num) OVER (ORDER BY id) AS next_num
    FROM logs
) AS t
WHERE num = prev_num AND num = next_num;

-- ================================================
-- PATTERN 4: HIGHEST PER GROUP (LC 184)
-- ================================================

-- Method 1: Tuple subquery
SELECT d.dept_name AS Department, e.emp_name AS Employee, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE (e.dept_id, e.salary) IN (
    SELECT dept_id, MAX(salary) FROM employees GROUP BY dept_id
);

-- Method 2: Window function (preferred!)
SELECT Department, Employee, Salary
FROM (
    SELECT
        d.dept_name AS Department,
        e.emp_name  AS Employee,
        e.salary    AS Salary,
        RANK() OVER (
            PARTITION BY e.dept_id
            ORDER BY e.salary DESC
        ) AS rnk
    FROM employees e
    INNER JOIN departments d ON e.dept_id = d.dept_id
) AS ranked
WHERE rnk = 1;

-- Applied to MercariDB: top product per category
SELECT category, title, price
FROM (
    SELECT
        category, title, price,
        RANK() OVER (
            PARTITION BY category ORDER BY price DESC
        ) AS rnk
    FROM products
) AS ranked
WHERE rnk = 1;

-- ================================================
-- PATTERN 5: DELETE DUPLICATES (LC 196)
-- ================================================

-- View before:
SELECT * FROM person_emails ORDER BY email, id;

-- Delete duplicates — keep smallest id
DELETE p1 FROM person_emails p1
INNER JOIN person_emails p2
ON p1.email = p2.email AND p1.id > p2.id;

-- View after — only one row per email remains:
SELECT * FROM person_emails;

-- ================================================
-- PATTERN 6: RISING TEMPERATURE (LC 197)
-- ================================================

-- Method 1: Self JOIN on consecutive dates
SELECT w2.id
FROM weather w1
INNER JOIN weather w2
ON w2.record_date = DATE_ADD(w1.record_date, INTERVAL 1 DAY)
WHERE w2.temperature > w1.temperature;

-- Method 2: LAG (cleaner!)
SELECT id
FROM (
    SELECT
        id, temperature,
        LAG(temperature) OVER (ORDER BY record_date) AS prev_temp,
        LAG(record_date)  OVER (ORDER BY record_date) AS prev_date
    FROM weather
) AS t
WHERE temperature > prev_temp
  AND record_date = DATE_ADD(prev_date, INTERVAL 1 DAY);

-- ================================================
-- PATTERN 7: EMPLOYEE VS MANAGER (LC 181)
-- ================================================

-- Self JOIN: employee table joined with itself
SELECT e.emp_name AS Employee
FROM employees e
INNER JOIN employees m ON e.manager_id = m.emp_id
WHERE e.salary > m.salary;

-- Full details version:
SELECT
    e.emp_name AS Employee,
    e.salary   AS EmpSalary,
    m.emp_name AS Manager,
    m.salary   AS MgrSalary,
    e.salary - m.salary AS Difference
FROM employees e
INNER JOIN employees m ON e.manager_id = m.emp_id
WHERE e.salary > m.salary;

-- ================================================
-- PATTERN 8: NEVER ORDERED (LC 183)
-- ================================================

-- Method 1: NOT EXISTS (best — NULL safe)
SELECT username AS Customers
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.buyer_id = u.user_id
);

-- Method 2: LEFT JOIN
SELECT u.username AS Customers
FROM users u
LEFT JOIN orders o ON u.user_id = o.buyer_id
WHERE o.order_id IS NULL;

-- ================================================
-- PATTERN 9: TOP N PER GROUP (LC 185)
-- ================================================

-- Top 3 salaries per department (DENSE_RANK!)
SELECT Department, Employee, Salary
FROM (
    SELECT
        d.dept_name AS Department,
        e.emp_name  AS Employee,
        e.salary    AS Salary,
        DENSE_RANK() OVER (
            PARTITION BY e.dept_id
            ORDER BY e.salary DESC
        ) AS rnk
    FROM employees e
    INNER JOIN departments d ON e.dept_id = d.dept_id
) AS ranked
WHERE rnk <= 3
ORDER BY Department, Salary DESC;

-- Applied to MercariDB: top 2 products per category
SELECT category, title, price
FROM (
    SELECT
        category, title, price,
        DENSE_RANK() OVER (
            PARTITION BY category ORDER BY price DESC
        ) AS rnk
    FROM products
) AS ranked
WHERE rnk <= 2
ORDER BY category, price DESC;

-- ================================================
-- PATTERN 10: SINGLE OCCURRENCE MAX (LC 619)
-- ================================================

SELECT MAX(num) AS num
FROM (
    SELECT num FROM my_numbers
    GROUP BY num
    HAVING COUNT(*) = 1
) AS singles;

-- ================================================
-- MERCARIDB CUSTOM LC-STYLE PROBLEMS
-- ================================================

-- P1: 2nd most expensive product per category
SELECT category, title, price
FROM (
    SELECT
        category, title, price,
        DENSE_RANK() OVER (
            PARTITION BY category ORDER BY price DESC
        ) AS rnk
    FROM products
) AS ranked
WHERE rnk = 2;

-- P2: Top earning seller per country
SELECT country, username, total_revenue
FROM (
    SELECT
        u.country,
        u.username,
        COALESCE(SUM(o.amount), 0) AS total_revenue,
        RANK() OVER (
            PARTITION BY u.country
            ORDER BY COALESCE(SUM(o.amount), 0) DESC
        ) AS rnk
    FROM users u
    LEFT JOIN products p  ON u.user_id    = p.seller_id
    LEFT JOIN orders o    ON p.product_id = o.product_id
    GROUP BY u.user_id, u.username, u.country
) AS ranked
WHERE rnk = 1
ORDER BY total_revenue DESC;

-- P3: Products above their category average
SELECT p.title, p.category, p.price, cat_avg.avg_price
FROM products p
INNER JOIN (
    SELECT category, ROUND(AVG(price), 2) AS avg_price
    FROM products GROUP BY category
) AS cat_avg ON p.category = cat_avg.category
WHERE p.price > cat_avg.avg_price
ORDER BY p.category, p.price DESC;

-- P4: Sellers with no completed sales
SELECT u.username, u.country
FROM users u
WHERE EXISTS (
    SELECT 1 FROM products p WHERE p.seller_id = u.user_id
)
AND NOT EXISTS (
    SELECT 1 FROM products p
    INNER JOIN orders o ON p.product_id = o.product_id
    WHERE p.seller_id = u.user_id
);

-- P5: Users who spent more than average buyer
SELECT username, total_spent
FROM (
    SELECT
        u.username,
        SUM(o.amount) AS total_spent
    FROM users u
    INNER JOIN orders o ON u.user_id = o.buyer_id
    GROUP BY u.user_id, u.username
) AS buyer_totals
WHERE total_spent > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(amount) AS total
        FROM orders
        GROUP BY buyer_id
    ) AS buyer_avgs
)
ORDER BY total_spent DESC;

-- ================================================
-- PATTERN CHEAT SHEET (as comments)
-- ================================================
-- Nth Highest:    DENSE_RANK WHERE rnk=N  OR  MAX WHERE < MAX
-- Rank no gap:    DENSE_RANK() OVER (ORDER BY col DESC)
-- Top N per grp:  PARTITION BY grp ORDER BY col, WHERE rnk<=N
-- Consecutive:    Self JOIN id+1,id+2  OR  LAG/LEAD compare
-- Delete dupes:   DELETE self JOIN same col AND id > smaller id
-- Temp rising:    LAG compare  OR  self JOIN DATE_ADD 1 day
-- Emp > Manager:  self JOIN on manager_id, compare salaries
-- Never ordered:  NOT EXISTS  OR  LEFT JOIN IS NULL
-- Single occur:   GROUP BY HAVING COUNT=1, then MAX/MIN
