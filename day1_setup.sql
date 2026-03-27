-- ================================================
-- MercariDB -- Day 1
-- Topic: Database Setup, CREATE TABLE
-- Author: Prashant
-- Date: 2026-03-27
-- ================================================

-- Create the database (safe to rerun anytime)
CREATE DATABASE IF NOT EXISTS mercaridb;

-- Select the database
USE mercaridb;

-- Drop table if exists so script is always rerunnable
DROP TABLE IF EXISTS users;

-- Create users table with all constraints
CREATE TABLE users (
    user_id    INT          NOT NULL AUTO_INCREMENT,  -- unique ID, auto assigned
    username   VARCHAR(50)  NOT NULL,                 -- required, max 50 chars
    email      VARCHAR(100) NOT NULL UNIQUE,          -- required, no duplicates
    country    VARCHAR(50),                           -- optional
    age        INT,                                   -- optional, can be NULL
    created_at DATETIME     DEFAULT NOW(),            -- auto timestamp

    PRIMARY KEY (user_id)
);

-- Insert sample data
INSERT INTO users (username, email, country, age) VALUES
('prashant_jpr',   'prashant@gmail.com',   'India',   17),
('tanaka_hiroshi', 'tanaka@mercari.jp',    'Japan',   28),
('yuki_suzuki',    'yuki@gmail.com',       'Japan',   22),
('sarah_chen',     'sarah@yahoo.com',      'USA',     34),
('rahul_sharma',   'rahul@gmail.com',      'India',   26),
('amit_verma',     'amit@hotmail.com',     'India',   31),
('kenji_watanabe', 'kenji@docomo.jp',      'Japan',   19),
('lisa_mueller',   'lisa@gmail.de',        'Germany', 29),
('wang_fang',      'wang@qq.com',          'China',   24),
('priya_nair',     'priya@gmail.com',      'India',   20),
('carlos_mx',      'carlos@gmail.mx',      'Mexico',  27);

-- Verify data loaded correctly
SELECT * FROM users;
