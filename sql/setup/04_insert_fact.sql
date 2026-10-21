-- ============================================================
--  KENYA FOOD MARKET PRICES
--  FILE 4 OF 5: INSERT FACT TABLE + DROP STAGING
--  Moves data from stg_prices into fact_prices by joining
--  all dimension tables to look up the correct IDs.
--  Run after file 03 has completed successfully.
-- ============================================================

USE kenya_food_market_prices;

-- ------------------------------------------------------------
--  INSERT INTO fact_prices
--  Joins staging to all dimension tables to swap names for IDs
--  STR_TO_DATE converts "1/15/2006" text into a proper DATE
-- ------------------------------------------------------------
INSERT INTO fact_prices
    (price_date, market_id, commodity_id,
     price_flag, price_type, currency, price_ksh, price_usd)
SELECT
    STR_TO_DATE(s.price_date, '%m/%d/%Y'),
    m.market_id,
    c.commodity_id,
    s.price_flag,
    s.price_type,
    s.currency,
    s.price_ksh,
    s.price_usd
FROM            stg_prices           s
JOIN  dim_markets        m  ON  m.market_name    = s.market_name
JOIN  dim_towns          t  ON  t.town_id        = m.town_id
                            AND t.town_name      = s.town_name
JOIN  dim_commodities    c  ON  c.commodity_name = s.commodity_name
JOIN  dim_food_categories fc ON fc.category_id  = c.category_id
                            AND fc.category_name = s.category_name;

-- ------------------------------------------------------------
--  DROP ALL STAGING TABLES
--  Data has been moved — staging tables no longer needed
-- ------------------------------------------------------------
DROP TABLE stg_towns;
DROP TABLE stg_markets;
DROP TABLE stg_commodities;
DROP TABLE stg_prices;