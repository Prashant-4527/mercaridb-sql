-- ================================================
-- MercariDB -- Day 3
-- Topic: AND, OR, NOT, IN, BETWEEN, LIKE patterns
-- Author: Prashant
-- Date: 2026-03-27
-- ================================================

USE mercaridb;

-- ------------------------------------------------
-- AND -- both conditions must be TRUE
-- ------------------------------------------------

-- India users who are older than 25
SELECT username, country, age
FROM users
WHERE country = 'India' AND age > 25;

-- Japan users with gmail
SELECT username, country, email
FROM users
WHERE country = 'Japan' AND email LIKE '%gmail%';

-- ------------------------------------------------
-- OR -- at least one condition must be TRUE
-- ------------------------------------------------

-- India OR Japan users
SELECT username, country
FROM users
WHERE country = 'India' OR country = 'Japan';

-- Users younger than 20 OR older than 30
SELECT username, age
FROM users
WHERE age < 20 OR age > 30;

-- ------------------------------------------------
-- IMPORTANT: Brackets rule
-- AND has higher priority than OR (like * vs + in maths)
-- Always use brackets when mixing AND + OR
-- ------------------------------------------------

-- WRONG (ambiguous, MySQL reads it wrong):
-- WHERE country = 'India' OR country = 'Japan' AND age > 25

-- CORRECT (brackets make it clear):
SELECT username, country, age
FROM users
WHERE (country = 'India' OR country = 'Japan') AND age > 25;

-- ------------------------------------------------
-- NOT -- reverse/exclude a condition
-- ------------------------------------------------

-- Everyone except India
SELECT username, country
FROM users
WHERE NOT country = 'India';

-- Japan users who are NOT under 20
SELECT username, country, age
FROM users
WHERE country = 'Japan' AND NOT age < 20;

-- ------------------------------------------------
-- IN -- cleaner alternative to multiple OR conditions
-- ------------------------------------------------

-- Multiple countries (ugly OR version):
-- WHERE country = 'India' OR country = 'Japan' OR country = 'Germany'

-- Same result, cleaner with IN:
SELECT username, country
FROM users
WHERE country IN ('India', 'Japan', 'Germany');

-- NOT IN: exclude specific countries
SELECT username, country
FROM users
WHERE country NOT IN ('India', 'Japan');

-- IN with numbers
SELECT username, age
FROM users
WHERE age IN (17, 22, 28, 34);

-- ------------------------------------------------
-- BETWEEN -- range filter (INCLUSIVE on both ends)
-- ------------------------------------------------

-- Age 20 to 30 (includes 20 and 30)
SELECT username, age
FROM users
WHERE age BETWEEN 20 AND 30;

-- Outside the range with NOT BETWEEN
SELECT username, age
FROM users
WHERE age NOT BETWEEN 20 AND 30;

-- BETWEEN with dates
SELECT username, created_at
FROM users
WHERE created_at BETWEEN '2026-01-01' AND '2026-12-31';

-- ------------------------------------------------
-- LIKE patterns (advanced)
-- % = zero or more characters
-- _ = exactly one character
-- ------------------------------------------------

-- Starts with 'p'
SELECT username FROM users WHERE username LIKE 'p%';

-- Contains 'a' anywhere
SELECT username FROM users WHERE username LIKE '%a%';

-- Ends with .jp
SELECT username, email FROM users WHERE email LIKE '%.jp';

-- At least 5 characters long
SELECT username FROM users WHERE username LIKE '_____%';

-- ------------------------------------------------
-- Business queries (Mercari use cases)
-- ------------------------------------------------

-- Gen Z campaign: India/Japan users aged 18-30 on Gmail
SELECT username, country, age, email
FROM users
WHERE (country = 'India' OR country = 'Japan')
  AND age BETWEEN 18 AND 30
  AND email LIKE '%gmail%';

-- Non-Asian markets aged over 25
SELECT username, country, age
FROM users
WHERE country IN ('Mexico', 'Germany', 'USA')
  AND age > 25;

-- Users whose username does not start with 'a'
SELECT username
FROM users
WHERE username NOT LIKE 'a%';
