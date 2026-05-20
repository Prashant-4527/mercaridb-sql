-- ================================================
-- MercariDB Capstone
-- Section: Platform Overview
-- File: 01_platform_overview.sql
-- Author: Prashant
-- Date: 2025-01-01
-- Description: High-level KPIs to get a feel for the platform at a glance.
--              Simple aggregates only — warm-up queries before the deep dives.
-- ================================================
--
-- NOTE ON THIS DATASET
-- The Mercari sample has no users, orders, or date columns.
-- Columns available: listing_id, title, condition_id, category_id,
--                    brand_id, price, shipping_paid_by, description
-- KPIs are mapped to the closest real equivalent:
--   "users"   → brands (sellers signal)
--   "orders"  → listings (each listing = one item offered for sale)
--   "revenue" → Gross Merchandise Value = SUM(price)
--   "active vs sold" → branded vs unbranded ratio (no status column)
--   "countries" → main categories (the 10 top-level markets on the platform)
--   "new this month/year" → impossible without dates; see note in that section
-- ================================================

USE mercaridb;

-- ----------------------------------------
-- Q1: Total listings, brands, GMV, and average price — all in one query
-- Business context: The single most important slide in any board deck.
--                   Gives stakeholders an instant sense of platform scale.
-- ----------------------------------------
SELECT
    COUNT(*)                              AS total_listings,
    COUNT(DISTINCT brand_id)              AS unique_brands,
    COUNT(DISTINCT category_id)           AS unique_categories,
    ROUND(SUM(price), 2)                  AS gross_merchandise_value,
    ROUND(AVG(price), 2)                  AS avg_listing_price
FROM listings;
-- Expected insight: ~50 000 listings, ~1 000 brands, GMV ~$1.3 M.
--                   A low avg price (~$26) tells us this is a mass-market,
--                   everyday-item marketplace, not a luxury platform.

-- ----------------------------------------
-- Q2: Branded vs unbranded listings ratio
-- Business context: Closest proxy to "active vs sold" given no status column.
--                   Brand presence signals seller quality and buyer trust —
--                   branded items typically fetch higher prices and sell faster.
-- ----------------------------------------
SELECT
    CASE
        WHEN brand_id IS NULL THEN 'Unbranded'
        ELSE                       'Branded'
    END                                                          AS listing_type,
    COUNT(*)                                                     AS listing_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)          AS pct_of_total,
    ROUND(AVG(price), 2)                                         AS avg_price
FROM  listings
GROUP BY listing_type
ORDER BY listing_count DESC;
-- Expected insight: A large share of listings (~43%) will be unbranded.
--                   Branded items should show a measurable price premium —
--                   if they don't, brand names aren't driving value here.

-- ----------------------------------------
-- Q3: Average listing price (platform "order value")
-- Business context: Equivalent to Average Order Value (AOV) in e-commerce.
--                   Tracks revenue quality and guides pricing strategy.
--                   Broken down by condition so we can see the full spread.
-- ----------------------------------------
SELECT
    ic.condition_name,
    COUNT(*)                AS listing_count,
    ROUND(AVG(l.price), 2)  AS avg_price,
    ROUND(MIN(l.price), 2)  AS min_price,
    ROUND(MAX(l.price), 2)  AS max_price
FROM      listings        l
JOIN      item_conditions ic USING (condition_id)
GROUP BY  ic.condition_id, ic.condition_name
ORDER BY  ic.condition_id;
-- Expected insight: Price should drop with condition — New > Like New > Good …
--                   A flat or inverted curve would flag data quality issues
--                   or category composition effects worth investigating.

-- ----------------------------------------
-- Q4: Platform coverage — unique top-level markets (categories)
-- Business context: Maps to "unique countries" — these 10 main categories
--                   ARE the markets Mercari operates in. Understanding their
--                   size tells us where to invest and where there is white space.
-- ----------------------------------------
SELECT
    c.main_category                                              AS market,
    COUNT(*)                                                     AS listing_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)          AS pct_of_catalogue,
    ROUND(AVG(l.price), 2)                                       AS avg_price,
    ROUND(SUM(l.price), 2)                                       AS total_gmv
FROM      listings   l
JOIN      categories c USING (category_id)
GROUP BY  c.main_category
ORDER BY  listing_count DESC;
-- Expected insight: Women's dominates (~45% of listings).
--                   Electronics will have the highest avg price despite lower volume —
--                   a small catalogue, high-value market worth a closer look.

-- ----------------------------------------
-- Q5: Shipping cost split — who absorbs the cost, seller or buyer?
-- Business context: Replaces "new users this month/year" (no date column).
--                   Shipping strategy is the #1 hidden cost lever on any
--                   marketplace. A high seller-pays rate signals competitive
--                   pressure; a high buyer-pays rate can hurt conversion.
-- ----------------------------------------
SELECT
    CASE shipping_paid_by
        WHEN 1 THEN 'Seller pays'
        WHEN 0 THEN 'Buyer pays'
    END                                                          AS shipping_model,
    COUNT(*)                                                     AS listing_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)          AS pct_of_total,
    ROUND(AVG(price), 2)                                         AS avg_listing_price
FROM  listings
GROUP BY shipping_paid_by
ORDER BY listing_count DESC;
-- Expected insight: ~45% of listings absorb shipping for the buyer.
--                   Seller-pays listings tend to have a slightly higher price —
--                   sellers are baking the shipping cost into the list price.

-- ================================================
-- NOTE: "New users this month/year" query
-- The dataset has NO timestamp or date column (train_id is not a date).
-- This KPI requires a created_at / listed_at field.
-- When you enrich the schema with real Mercari export data that includes
-- dates, add a listed_at DATETIME column to the listings table and use:
--
--   SELECT
--       DATE_FORMAT(listed_at, '%Y-%m')  AS month,
--       COUNT(*)                         AS new_listings
--   FROM  listings
--   WHERE listed_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
--   GROUP BY month
--   ORDER BY month;
-- ================================================
