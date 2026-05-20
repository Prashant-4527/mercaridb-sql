-- =============================================================
--  MercariDB Capstone Project
--  File        : 02_seed_data.sql
--  Description : Load raw CSV → populate normalized tables
--  Run AFTER   : 01_schema.sql
--  Engine      : MySQL 8.0+
-- =============================================================

USE mercaridb;

-- ─────────────────────────────────────────────
-- STEP 1 : Load raw CSV into staging table
--
--  Adjust the file path to wherever your CSV lives.
--  On MySQL Server you need:  GRANT FILE ON *.* TO 'youruser'@'localhost';
--  Or use MySQL Workbench Table Data Import Wizard as an alternative.
-- ─────────────────────────────────────────────
LOAD DATA LOCAL INFILE '/path/to/mercari_sample.csv'
INTO TABLE raw_listings
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(train_id, name, item_condition_id, category_name, brand_name, price, shipping, item_description);


-- ─────────────────────────────────────────────
-- STEP 2 : Populate brands (distinct non-null brand names)
-- ─────────────────────────────────────────────
INSERT IGNORE INTO brands (brand_name)
SELECT DISTINCT TRIM(brand_name)
FROM   raw_listings
WHERE  brand_name IS NOT NULL
  AND  TRIM(brand_name) != '';


-- ─────────────────────────────────────────────
-- STEP 3 : Populate categories
--   Split the slash-delimited string into 3 levels using SUBSTRING_INDEX.
--   Rows where category_name is NULL or empty are skipped.
-- ─────────────────────────────────────────────
INSERT IGNORE INTO categories (raw_category, main_category, sub_category, sub_sub_category)
SELECT
    TRIM(category_name)                                      AS raw_category,

    -- Level 1: everything before the first '/'
    TRIM(SUBSTRING_INDEX(category_name, '/', 1))             AS main_category,

    -- Level 2: between first and second '/'
    --   If there's no second '/', this equals main_category — filter those out below.
    NULLIF(
        TRIM(
            SUBSTRING_INDEX(SUBSTRING_INDEX(category_name, '/', 2), '/', -1)
        ),
        TRIM(SUBSTRING_INDEX(category_name, '/', 1))         -- same as level 1 → no sub
    )                                                         AS sub_category,

    -- Level 3: the part after the second '/'
    --   SUBSTRING_INDEX with -1 grabs the last segment; compare to level2 to detect missing level.
    NULLIF(
        TRIM(
            SUBSTRING_INDEX(SUBSTRING_INDEX(category_name, '/', 3), '/', -1)
        ),
        TRIM(
            SUBSTRING_INDEX(SUBSTRING_INDEX(category_name, '/', 2), '/', -1)
        )                                                      -- same as level 2 → no sub_sub
    )                                                          AS sub_sub_category

FROM (
    SELECT DISTINCT TRIM(category_name) AS category_name
    FROM   raw_listings
    WHERE  category_name IS NOT NULL
      AND  TRIM(category_name) != ''
) AS distinct_cats;


-- ─────────────────────────────────────────────
-- STEP 4 : Populate the main listings table
--   JOIN back to lookup tables to get FK IDs.
-- ─────────────────────────────────────────────
INSERT INTO listings (listing_id, title, condition_id, category_id, brand_id, price, shipping_paid_by, description)
SELECT
    r.train_id,
    TRIM(r.name),
    r.item_condition_id,
    c.category_id,                        -- NULL if category was missing/invalid
    b.brand_id,                           -- NULL if no brand
    r.price,
    r.shipping,
    r.item_description
FROM      raw_listings         r
LEFT JOIN categories           c  ON  TRIM(r.category_name) = c.raw_category
LEFT JOIN brands               b  ON  TRIM(r.brand_name)    = b.brand_name;


-- ─────────────────────────────────────────────
-- STEP 5 : Quick sanity checks (run manually)
-- ─────────────────────────────────────────────
-- SELECT COUNT(*) AS total_listings     FROM listings;         -- expect ~50 000
-- SELECT COUNT(*) AS total_brands       FROM brands;
-- SELECT COUNT(*) AS total_categories   FROM categories;
-- SELECT COUNT(*) AS listings_no_brand  FROM listings WHERE brand_id IS NULL;
-- SELECT COUNT(*) AS listings_no_cat    FROM listings WHERE category_id IS NULL;
