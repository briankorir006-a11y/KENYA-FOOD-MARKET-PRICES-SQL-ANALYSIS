-- ============================================================
--  KENYA FOOD MARKET PRICES
--  FILE 5 OF 5: VERIFY ALL TABLES LOADED CORRECTLY
--  Run after file 04 to confirm row counts are correct
-- ============================================================

USE kenya_food_market_prices;

-- ------------------------------------------------------------
--  Row count check — expected results:
--  dim_regions        →  7 rows
--  dim_food_categories→  8 rows
--  dim_towns          → 22 rows
--  dim_markets        → 62 rows
--  dim_commodities    → 47 rows
--  fact_prices        → 10,647 rows
-- ------------------------------------------------------------
SELECT 'dim_regions'          AS table_name, COUNT(*) AS total_rows FROM dim_regions
UNION ALL
SELECT 'dim_food_categories',               COUNT(*)               FROM dim_food_categories
UNION ALL
SELECT 'dim_towns',                         COUNT(*)               FROM dim_towns
UNION ALL
SELECT 'dim_markets',                       COUNT(*)               FROM dim_markets
UNION ALL
SELECT 'dim_commodities',                   COUNT(*)               FROM dim_commodities
UNION ALL
SELECT 'fact_prices',                       COUNT(*)               FROM fact_prices;

-- ------------------------------------------------------------
--  Sample data check — peek at each table
-- ------------------------------------------------------------
SELECT * FROM dim_regions           LIMIT 5;
SELECT * FROM dim_food_categories   LIMIT 5;
SELECT * FROM dim_towns             LIMIT 5;
SELECT * FROM dim_markets           LIMIT 5;
SELECT * FROM dim_commodities       LIMIT 5;
SELECT * FROM fact_prices           LIMIT 5;