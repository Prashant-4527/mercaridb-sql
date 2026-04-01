-- ================================================
-- MercariDB -- Day 7
-- Topic: Practice Day -- Week 1 All Concepts
-- Author: Prashant
-- Date: 2026-03-29
-- ================================================

USE mercaridb;

-- ================================================
-- LEVEL 1 -- Basic (Days 1-2)
-- ================================================

-- Q1: All users sorted youngest to oldest
SELECT username, country, age
FROM users
ORDER BY age ASC;

-- Q2: Japan users name and email
SELECT username, email
FROM users
WHERE country = 'Japan';

-- Q3: Usernames starting with 'k'
SELECT username
FROM users
WHERE username LIKE 'k%';

-- Q4: Users aged 25+ oldest first
SELECT username, age
FROM users
WHERE age >= 25
ORDER BY age DESC;

-- Q5: Gmail users
SELECT username, email
FROM users
WHERE email LIKE '%gmail%';

-- ================================================
-- LEVEL 2 -- Intermediate (Days 3-4)
-- ================================================

-- Q6: India or Japan users aged 20-30
SELECT username, country, age
FROM users
WHERE (country = 'India' OR country = 'Japan')
  AND age BETWEEN 20 AND 30;

-- Q7: Mexico, Germany, USA users sorted by age
SELECT username, country, age
FROM users
WHERE country IN ('Mexico', 'Germany', 'USA')
ORDER BY age ASC;

-- Q8: Top 3 oldest users
SELECT username, age, country
FROM users
ORDER BY age DESC
LIMIT 3;

-- Q9: Page 2 -- 3 users per page, alphabetically sorted
SELECT username, country
FROM users
ORDER BY username ASC
LIMIT 3 OFFSET 3;

-- Q10: Non-Indian users with .jp email
SELECT username, email
FROM users
WHERE country != 'India'
  AND email LIKE '%.jp';

-- ================================================
-- LEVEL 3 -- Advanced (Days 5-6)
-- ================================================

-- Q11: Total users + unique countries
SELECT
    COUNT(*)                AS total_users,
    COUNT(DISTINCT country) AS unique_countries
FROM users;

-- Q12: Users per country, most first
SELECT country, COUNT(*) AS total_users
FROM users
GROUP BY country
ORDER BY total_users DESC;

-- Q13: Countries with 2+ users -- avg age included
SELECT
    country,
    COUNT(*)           AS total_users,
    ROUND(AVG(age), 1) AS avg_age
FROM users
GROUP BY country
HAVING total_users >= 2
ORDER BY total_users DESC;

-- Q14: Full platform summary
SELECT
    COUNT(*)                AS total_users,
    ROUND(AVG(age), 1)      AS avg_age,
    MIN(age)                AS youngest,
    MAX(age)                AS oldest,
    COUNT(DISTINCT country) AS unique_countries
FROM users;

-- Q15: Countries where avg age is under 25
SELECT country, ROUND(AVG(age), 1) AS avg_age
FROM users
GROUP BY country
HAVING avg_age < 25
ORDER BY avg_age ASC;
