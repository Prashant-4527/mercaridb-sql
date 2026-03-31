-- ================================================
-- MercariDB -- Day 5
-- Topic: Aggregate Functions — COUNT, SUM, AVG, MIN, MAX
-- Author: Prashant
-- Date: 2026-03-28
-- ================================================

USE mercaridb;

-- ------------------------------------------------
-- COUNT -- how many rows
-- ------------------------------------------------

-- Count all rows (includes NULLs)
SELECT COUNT(*) AS total_users FROM users;

-- Count with WHERE filter
SELECT COUNT(*) AS india_users
FROM users
WHERE country = 'India';

-- COUNT(column) vs COUNT(*) -- KEY interview difference!
-- COUNT(*) = all rows including NULLs
-- COUNT(column) = only non-NULL values in that column
SELECT COUNT(*)   AS total_rows    FROM users;
SELECT COUNT(age) AS rows_with_age FROM users;

-- COUNT DISTINCT: how many unique values
SELECT COUNT(DISTINCT country) AS unique_countries FROM users;

-- ------------------------------------------------
-- SUM -- add up all values
-- ------------------------------------------------

-- Total of all ages (more useful with price/revenue)
SELECT SUM(age) AS total_age FROM users;

-- SUM with filter
SELECT SUM(age) AS india_age_total
FROM users
WHERE country = 'India';

-- ------------------------------------------------
-- AVG -- average value (NULLs are ignored automatically)
-- ------------------------------------------------

-- Average age of all users
SELECT AVG(age) AS average_age FROM users;

-- Round to 1 decimal place (always do this for AVG!)
SELECT ROUND(AVG(age), 1) AS avg_age FROM users;

-- Average age of non-Indian users
SELECT ROUND(AVG(age), 1) AS avg_age
FROM users
WHERE country != 'India';

-- ------------------------------------------------
-- MIN and MAX -- smallest and largest value
-- ------------------------------------------------

-- Youngest and oldest
SELECT MIN(age) AS youngest FROM users;
SELECT MAX(age) AS oldest   FROM users;

-- Both together
SELECT
    MIN(age) AS youngest,
    MAX(age) AS oldest,
    MAX(age) - MIN(age) AS age_range
FROM users;

-- ------------------------------------------------
-- Combining all aggregates -- dashboard query
-- ------------------------------------------------

-- Full platform summary (CEO dashboard)
SELECT
    COUNT(*)                AS total_users,
    COUNT(DISTINCT country) AS countries_covered,
    ROUND(AVG(age), 1)      AS avg_user_age,
    MIN(age)                AS youngest_user,
    MAX(age)                AS oldest_user
FROM users;

-- Summary filtered by country
SELECT
    COUNT(*)           AS india_users,
    ROUND(AVG(age), 1) AS avg_age,
    MIN(age)           AS youngest,
    MAX(age)           AS oldest
FROM users
WHERE country = 'India';

-- ------------------------------------------------
-- Business queries (Mercari use cases)
-- ------------------------------------------------

-- How many users are from Asian countries?
SELECT COUNT(*) AS asian_users
FROM users
WHERE country IN ('India', 'Japan', 'China');

-- How many Gmail users do we have?
SELECT COUNT(*) AS gmail_users
FROM users
WHERE email LIKE '%gmail%';

-- Gen Z users (age 18-26)
SELECT COUNT(*) AS gen_z_users
FROM users
WHERE age BETWEEN 18 AND 26;

-- Millennial users (age 27-42)
SELECT COUNT(*) AS millennial_users
FROM users
WHERE age BETWEEN 27 AND 42;

-- Average age of users aged 20 and above
SELECT ROUND(AVG(age), 1) AS avg_adult_age
FROM users
WHERE age >= 20;
