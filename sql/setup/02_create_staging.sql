-- ============================================================
--  KENYA FOOD MARKET PRICES
--  FILE 2 OF 5: CREATE STAGING TABLES
--  Staging tables are temporary dumping grounds for raw CSV
--  data. They have no foreign keys or strict constraints.
--  They will be dropped in file 04 after data is moved.
-- ============================================================

USE kenya_food_market_prices;

-- ------------------------------------------------------------
--  NOTE: dim_regions and dim_food_categories do NOT need
--  staging tables because their CSVs have no foreign keys.
--  Import those two CSVs directly into the real tables
--  via DBeaver before running files 03 and 04.
-- ------------------------------------------------------------

-- Staging for dim_towns
CREATE TABLE stg_towns (
    town_name   VARCHAR(80),
    region_name VARCHAR(60)
);

-- Staging for dim_markets
CREATE TABLE stg_markets (
    market_name VARCHAR(100),
    town_name   VARCHAR(80),
    latitude    DECIMAL(9,6),
    longitude   DECIMAL(9,6)
);

-- Staging for dim_commodities
CREATE TABLE stg_commodities (
    commodity_name VARCHAR(100),
    category_name  VARCHAR(60),
    unit           VARCHAR(20)
);

-- Staging for fact_prices
CREATE TABLE stg_prices (
    price_date     VARCHAR(20),
    market_name    VARCHAR(100),
    town_name      VARCHAR(80),
    commodity_name VARCHAR(100),
    category_name  VARCHAR(60),
    price_flag     VARCHAR(20),
    price_type     VARCHAR(20),
    currency       CHAR(3),
    price_ksh      DECIMAL(12,4),
    price_usd      DECIMAL(12,4)
);

-- ============================================================
--  NEXT STEP:
--  Go to DBeaver and import the CSVs into the staging tables:
--    dim_regions.csv          → dim_regions       (direct)
--    dim_food_categories.csv  → dim_food_categories (direct)
--    dim_towns.csv            → stg_towns
--    dim_markets.csv          → stg_markets
--    dim_commodities.csv      → stg_commodities
--    fact_prices_raw.csv      → stg_prices
--  Then run file 03
-- ============================================================