-- =============================================================
--  MercariDB Capstone Project
--  File        : 01_schema.sql
--  Description : Normalized schema for the Mercari marketplace dataset
--  Engine      : MySQL 8.0+
--  Dataset     : mercari_sample.csv (50,000 listings)
--
--  ERD overview (flat → normalized):
--
--    item_conditions  ──┐
--    brands           ──┼──  listings  ──── raw_listings (staging)
--    categories       ──┘
--
--  Original flat columns mapped:
--    train_id          → listings.listing_id
--    name              → listings.title
--    item_condition_id → listings.condition_id  (FK → item_conditions)
--    category_name     → listings.category_id   (FK → categories)
--    brand_name        → listings.brand_id      (FK → brands, nullable)
--    price             → listings.price
--    shipping          → listings.shipping_paid_by
--    item_description  → listings.description
-- =============================================================

-- ─────────────────────────────────────────────
-- 0. Database setup
-- ─────────────────────────────────────────────
CREATE DATABASE IF NOT EXISTS mercaridb
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE mercaridb;

-- ─────────────────────────────────────────────
-- 1. STAGING TABLE  (import CSV here first)
--    Mirrors the raw CSV exactly — no FKs, everything VARCHAR.
--    Use this as your LOAD DATA INFILE target.
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS raw_listings;
CREATE TABLE raw_listings (
    train_id          INT,
    name              VARCHAR(500),
    item_condition_id TINYINT,
    category_name     VARCHAR(300),
    brand_name        VARCHAR(200),
    price             DECIMAL(10, 2),
    shipping          TINYINT,           -- 0 = buyer pays | 1 = seller pays
    item_description  TEXT
);

-- ─────────────────────────────────────────────
-- 2. LOOKUP : item_conditions
--    Mercari uses a 1-5 integer scale.
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS item_conditions;
CREATE TABLE item_conditions (
    condition_id   TINYINT      NOT NULL,
    condition_name VARCHAR(50)  NOT NULL,
    description    VARCHAR(200),
    PRIMARY KEY (condition_id)
);

INSERT INTO item_conditions (condition_id, condition_name, description) VALUES
    (1, 'New',                  'Brand new, never used, may still have tags'),
    (2, 'Like New',             'Used once or twice, no visible wear'),
    (3, 'Good',                 'Minor signs of use, fully functional'),
    (4, 'Fair',                 'Visible wear and/or minor defects'),
    (5, 'Poor',                 'Heavy wear, defects, or incomplete');

-- ─────────────────────────────────────────────
-- 3. LOOKUP : brands
--    Extracted from brand_name. NULL in source → no brand row.
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS brands;
CREATE TABLE brands (
    brand_id   INT          NOT NULL AUTO_INCREMENT,
    brand_name VARCHAR(200) NOT NULL,
    PRIMARY KEY (brand_id),
    UNIQUE KEY uq_brand_name (brand_name)
);

-- ─────────────────────────────────────────────
-- 4. LOOKUP : categories
--    category_name is a slash-delimited hierarchy (up to 3 levels).
--    Example: "Women/Tops & Blouses/Blouse"
--      → main_category    = Women
--      → sub_category     = Tops & Blouses
--      → sub_sub_category = Blouse
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
    category_id       INT          NOT NULL AUTO_INCREMENT,
    raw_category      VARCHAR(300) NOT NULL,           -- original slash-joined value
    main_category     VARCHAR(100) NOT NULL,
    sub_category      VARCHAR(100),
    sub_sub_category  VARCHAR(100),
    PRIMARY KEY (category_id),
    UNIQUE KEY uq_raw_category (raw_category),
    INDEX idx_main_cat   (main_category),
    INDEX idx_sub_cat    (sub_category)
);

-- ─────────────────────────────────────────────
-- 5. FACT TABLE : listings
--    One row per item listing in the dataset.
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS listings;
CREATE TABLE listings (
    listing_id        INT            NOT NULL,
    title             VARCHAR(500)   NOT NULL,
    condition_id      TINYINT        NOT NULL,
    category_id       INT,                            -- NULL when source row had no category
    brand_id          INT,                            -- NULL = no brand listed
    price             DECIMAL(10, 2) NOT NULL,
    shipping_paid_by  TINYINT        NOT NULL,         -- 0 = buyer | 1 = seller
    description       TEXT,
    PRIMARY KEY (listing_id),
    CONSTRAINT fk_listings_condition  FOREIGN KEY (condition_id)  REFERENCES item_conditions (condition_id),
    CONSTRAINT fk_listings_category   FOREIGN KEY (category_id)   REFERENCES categories (category_id),
    CONSTRAINT fk_listings_brand      FOREIGN KEY (brand_id)      REFERENCES brands (brand_id),
    INDEX idx_price          (price),
    INDEX idx_condition      (condition_id),
    INDEX idx_category       (category_id),
    INDEX idx_brand          (brand_id),
    INDEX idx_shipping       (shipping_paid_by)
);

-- =============================================================
--  HOW TO LOAD DATA AFTER CREATING SCHEMA
--  Run 02_seed_data.sql next — it:
--    1. LOAD DATA INFILE into raw_listings
--    2. INSERT DISTINCT values into brands & categories
--    3. INSERT into listings with the resolved FK IDs
-- =============================================================
