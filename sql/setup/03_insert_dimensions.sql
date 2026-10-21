-- ============================================================
--  KENYA FOOD MARKET PRICES
--  FILE 3 OF 5: INSERT DIMENSION TABLES
--  Moves data from staging tables into the real dimension
--  tables, looking up foreign key IDs along the way.
--  Run after importing CSVs into staging tables in DBeaver.
-- ============================================================

USE kenya_food_market_prices;

-- ------------------------------------------------------------
--  1. INSERT INTO dim_towns
--     Looks up region_id from dim_regions using region_name
-- ------------------------------------------------------------
INSERT INTO dim_towns (town_name, region_id)
SELECT
    s.town_name,
    r.region_id
FROM stg_towns s
JOIN dim_regions r ON r.region_name = s.region_name;

-- ------------------------------------------------------------
--  2. INSERT INTO dim_markets
--     Looks up town_id from dim_towns using town_name
-- ------------------------------------------------------------
INSERT INTO dim_markets (market_name, town_id, latitude, longitude)
SELECT
    s.market_name,
    t.town_id,
    s.latitude,
    s.longitude
FROM stg_markets s
JOIN dim_towns t ON t.town_name = s.town_name;

-- ------------------------------------------------------------
--  3. INSERT INTO dim_commodities
--     Looks up category_id from dim_food_categories
-- ------------------------------------------------------------
INSERT INTO dim_commodities (commodity_name, category_id, unit)
SELECT
    s.commodity_name,
    fc.category_id,
    s.unit
FROM stg_commodities s
JOIN dim_food_categories fc ON fc.category_name = s.category_name;