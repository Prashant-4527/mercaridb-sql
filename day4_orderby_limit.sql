-- ================================================
-- MercariDB -- Day 4
-- Topic: ORDER BY, LIMIT, OFFSET
-- Author: Prashant
-- Date: 2026-03-28
-- ================================================

USE mercaridb;

-- ------------------------------------------------
-- ORDER BY -- sort results
-- ASC = small to big, A to Z (default)
-- DESC = big to small, Z to A
-- ------------------------------------------------

-- Youngest to oldest (ASC is default, same result both ways)
SELECT username, age FROM users ORDER BY age ASC;
SELECT username, age FROM users ORDER BY age;

-- Oldest to youngest
SELECT username, age FROM users ORDER BY age DESC;

-- Alphabetical by username A to Z
SELECT username, country FROM users ORDER BY username ASC;

-- Sort by country first, then age within same country
SELECT username, country, age
FROM users
ORDER BY country ASC, age DESC;

-- WHERE + ORDER BY together
-- India users, oldest first
SELECT username, age, country
FROM users
WHERE country = 'India'
ORDER BY age DESC;

-- ------------------------------------------------
-- LIMIT -- how many rows to return
-- ------------------------------------------------

-- Top 5 oldest users
SELECT username, age
FROM users
ORDER BY age DESC
LIMIT 5;

-- Top 1 youngest user
SELECT username, age
FROM users
ORDER BY age ASC
LIMIT 1;

-- Top 3 youngest Japan users
SELECT username, age
FROM users
WHERE country = 'Japan'
ORDER BY age ASC
LIMIT 3;

-- Top 5 non-Japan users alphabetically
SELECT username, country
FROM users
WHERE country != 'Japan'
ORDER BY username ASC
LIMIT 5;

-- ------------------------------------------------
-- OFFSET -- skip N rows (used for pagination)
-- Formula: OFFSET = (page_number - 1) * rows_per_page
-- ------------------------------------------------

-- Page 1: rows 1 to 3
SELECT username, age
FROM users
ORDER BY age ASC
LIMIT 3 OFFSET 0;

-- Page 2: rows 4 to 6
SELECT username, age
FROM users
ORDER BY age ASC
LIMIT 3 OFFSET 3;

-- Page 3: rows 7 to 9
SELECT username, age
FROM users
ORDER BY age ASC
LIMIT 3 OFFSET 6;

-- ------------------------------------------------
-- Execution order (critical for interviews!)
-- FROM > WHERE > SELECT > ORDER BY > LIMIT
-- This is why SELECT aliases cannot be used in WHERE
-- ------------------------------------------------

-- WRONG -- will throw error (alias doesn't exist yet in WHERE):
-- SELECT username AS uname FROM users WHERE uname = 'prashant_jpr';

-- CORRECT -- use original column name in WHERE:
SELECT username AS uname FROM users WHERE username = 'prashant_jpr';

-- ------------------------------------------------
-- Business queries (Mercari use cases)
-- ------------------------------------------------

-- Mercari Japan leaderboard: top 3 youngest Japanese users
SELECT username, age
FROM users
WHERE country = 'Japan'
ORDER BY age ASC
LIMIT 3;

-- Page 2 of users -- 4 per page, alphabetically sorted
SELECT username, country
FROM users
ORDER BY username ASC
LIMIT 4 OFFSET 4;

-- Overall oldest user on the platform
SELECT username, age, country
FROM users
ORDER BY age DESC
LIMIT 1;

-- Youngest non-Indian user
SELECT username, age, country
FROM users
WHERE country != 'India'
ORDER BY age ASC
LIMIT 1;

-- Alphabetically last 3 usernames
SELECT username FROM users
ORDER BY username DESC
LIMIT 3;

-- Page 2 of users -- 4 per page, sorted by country
SELECT username, country FROM users
ORDER BY country ASC
LIMIT 4 OFFSET 4;
