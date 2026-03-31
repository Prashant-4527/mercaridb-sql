-- ================================================
-- MercariDB -- Day 6
-- Topic: GROUP BY + HAVING
-- Author: Prashant
-- Date: 2026-03-29
-- ================================================

USE mercaridb;

-- ------------------------------------------------
-- GROUP BY -- split rows into groups, aggregate each group
-- Without GROUP BY: one result for the whole table
-- With GROUP BY: one result PER group
-- ------------------------------------------------

-- How many users per country?
SELECT country, COUNT(*) AS total_users
FROM users
GROUP BY country;
-- Result: India=4, Japan=3, USA=1, Germany=1, China=1, Mexico=1
-- Real world: "Which markets are our biggest?"

-- Average age per country
SELECT
    country,
    COUNT(*)           AS total_users,
    ROUND(AVG(age), 1) AS avg_age,
    MIN(age)           AS youngest,
    MAX(age)           AS oldest
FROM users
GROUP BY country;
-- Real world: "Demographics breakdown by country"

-- Count users per country, sorted by most users first
SELECT country, COUNT(*) AS total_users
FROM users
GROUP BY country
ORDER BY total_users DESC;
-- Real world: "Rank our markets by size"

-- ------------------------------------------------
-- GROUP BY with WHERE
-- WHERE filters BEFORE grouping
-- ------------------------------------------------

-- Count only users aged 20+ grouped by country
SELECT country, COUNT(*) AS users_20_plus
FROM users
WHERE age >= 20
GROUP BY country
ORDER BY users_20_plus DESC;
-- WHERE runs first, removes under-20s, THEN GROUP BY runs

-- Gmail users grouped by country
SELECT country, COUNT(*) AS gmail_users
FROM users
WHERE email LIKE '%gmail%'
GROUP BY country;

-- ------------------------------------------------
-- HAVING -- filter AFTER grouping
-- WHERE = filter rows (before grouping)
-- HAVING = filter groups (after grouping)
-- ------------------------------------------------

-- Countries with MORE than 1 user
SELECT country, COUNT(*) AS total_users
FROM users
GROUP BY country
HAVING total_users > 1;
-- Result: India(4), Japan(3) only
-- Real world: "Show only markets with real presence"

-- Countries where average age is above 25
SELECT
    country,
    ROUND(AVG(age), 1) AS avg_age
FROM users
GROUP BY country
HAVING avg_age > 25;

-- Countries with exactly 1 user (small markets)
SELECT country, COUNT(*) AS total_users
FROM users
GROUP BY country
HAVING total_users = 1;

-- ------------------------------------------------
-- WHERE vs HAVING -- the key difference
-- ------------------------------------------------

-- WHERE: filter individual rows before grouping
-- "Only consider users aged 18+" then group
SELECT country, COUNT(*) AS adult_users
FROM users
WHERE age >= 18
GROUP BY country;

-- HAVING: filter groups after aggregation
-- Group everyone, then "only show groups with 2+ users"
SELECT country, COUNT(*) AS total_users
FROM users
GROUP BY country
HAVING total_users >= 2;

-- BOTH together: WHERE + GROUP BY + HAVING
-- "Among users aged 18+, show countries with 2+ such users"
SELECT country, COUNT(*) AS adult_users
FROM users
WHERE age >= 18
GROUP BY country
HAVING adult_users >= 2
ORDER BY adult_users DESC;

-- ------------------------------------------------
-- Full execution order (must memorise for interviews!)
-- 1. FROM
-- 2. WHERE   (filter rows)
-- 3. GROUP BY (form groups)
-- 4. HAVING  (filter groups)
-- 5. SELECT  (pick columns)
-- 6. ORDER BY
-- 7. LIMIT
-- ------------------------------------------------

-- ------------------------------------------------
-- Business queries (Mercari use cases)
-- ------------------------------------------------

-- Market size report: countries with 2+ users, sorted
SELECT
    country,
    COUNT(*)           AS total_users,
    ROUND(AVG(age), 1) AS avg_age,
    MIN(age)           AS youngest,
    MAX(age)           AS oldest
FROM users
GROUP BY country
HAVING total_users >= 2
ORDER BY total_users DESC;

-- Young user markets: countries where avg age is under 27
SELECT country, ROUND(AVG(age), 1) AS avg_age
FROM users
GROUP BY country
HAVING avg_age < 27
ORDER BY avg_age ASC;

-- Gmail adoption by country (only countries with gmail users)
SELECT country, COUNT(*) AS gmail_users
FROM users
WHERE email LIKE '%gmail%'
GROUP BY country
HAVING gmail_users >= 1
ORDER BY gmail_users DESC;
