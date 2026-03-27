-- ================================================
-- MercariDB -- Day 2
-- Topic: SELECT, FROM, WHERE
-- Author: Prashant
-- Date: 2026-03-27
-- ================================================

USE mercaridb;

-- ------------------------------------------------
-- SELECT basics
-- ------------------------------------------------

-- Get all columns and all rows
SELECT * FROM users;

-- Get only specific columns
SELECT username, country FROM users;

-- Rename columns in output using AS alias
SELECT username AS 'User Name', email AS 'Email Address' FROM users;

-- Remove duplicate values with DISTINCT
SELECT DISTINCT country FROM users;

-- ------------------------------------------------
-- WHERE -- filter rows by condition
-- ------------------------------------------------

-- Exact match: only India users
SELECT * FROM users WHERE country = 'India';

-- Greater than: users older than 25
SELECT username, age FROM users WHERE age > 25;

-- Less than or equal: users 25 or younger
SELECT username, age, country FROM users WHERE age <= 25;

-- LIKE with wildcard: gmail users only
-- % means "anything can be here"
SELECT username, email FROM users WHERE email LIKE '%gmail%';

-- LIKE: usernames starting with 'p'
SELECT username FROM users WHERE username LIKE 'p%';

-- LIKE: emails ending with .jp
SELECT username, email FROM users WHERE email LIKE '%.jp';

-- Not equal: exclude India
SELECT username, country FROM users WHERE country != 'India';

-- IS NULL: find users with no age set
-- NOTE: never use = NULL, always IS NULL
SELECT username FROM users WHERE age IS NULL;

-- ------------------------------------------------
-- Business queries (Mercari use cases)
-- ------------------------------------------------

-- Japan campaign: usernames and emails of Japanese users
SELECT username, email FROM users WHERE country = 'Japan';

-- Loyalty program: users aged 25 and above
SELECT username, age, country FROM users WHERE age >= 25;

-- Gen Z marketing: users under 25
SELECT username, age, country FROM users WHERE age < 25;
