-- ============================================================
--  KENYA FOOD MARKET PRICES
--  FILE 1 OF 5: CREATE DATABASE AND TABLES
--  Run this file first before anything else
-- ============================================================

CREATE DATABASE IF NOT EXISTS kenya_food_market_prices
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE kenya_food_market_prices;

-- ------------------------------------------------------------
-- 1. REGIONS (7 rows)
--    No foreign keys — create first
-- ------------------------------------------------------------
CREATE TABLE dim_regions (
    region_id   INT          NOT NULL AUTO_INCREMENT,
    region_name VARCHAR(60)  NOT NULL,
    PRIMARY KEY (region_id),
    UNIQUE KEY uq_region_name (region_name)
);

-- ------------------------------------------------------------
-- 2. FOOD CATEGORIES (8 rows)
--    No foreign keys — create second
-- ------------------------------------------------------------
CREATE TABLE dim_food_categories (
    category_id   INT         NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(60) NOT NULL,
    PRIMARY KEY (category_id),
    UNIQUE KEY uq_category_name (category_name)
);

-- ------------------------------------------------------------
-- 3. TOWNS (22 rows)
--    Needs dim_regions first
-- ------------------------------------------------------------
CREATE TABLE dim_towns (
    town_id   INT         NOT NULL AUTO_INCREMENT,
    town_name VARCHAR(80) NOT NULL,
    region_id INT         NOT NULL,
    PRIMARY KEY (town_id),
    UNIQUE KEY uq_town_region (town_name, region_id),
    CONSTRAINT fk_town_region
        FOREIGN KEY (region_id) REFERENCES dim_regions (region_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 4. MARKETS (62 rows)
--    Needs dim_towns first
-- ------------------------------------------------------------
CREATE TABLE dim_markets (
    market_id   INT          NOT NULL AUTO_INCREMENT,
    market_name VARCHAR(100) NOT NULL,
    town_id     INT          NOT NULL,
    latitude    DECIMAL(9,6) NOT NULL,
    longitude   DECIMAL(9,6) NOT NULL,
    PRIMARY KEY (market_id),
    UNIQUE KEY uq_market_town (market_name, town_id),
    CONSTRAINT fk_market_town
        FOREIGN KEY (town_id) REFERENCES dim_towns (town_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 5. COMMODITIES (47 rows)
--    Needs dim_food_categories first
-- ------------------------------------------------------------
CREATE TABLE dim_commodities (
    commodity_id   INT          NOT NULL AUTO_INCREMENT,
    commodity_name VARCHAR(100) NOT NULL,
    category_id    INT          NOT NULL,
    unit           VARCHAR(20)  NOT NULL,
    PRIMARY KEY (commodity_id),
    UNIQUE KEY uq_commodity_category (commodity_name, category_id),
    CONSTRAINT fk_commodity_category
        FOREIGN KEY (category_id) REFERENCES dim_food_categories (category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 6. FACT PRICES (10,647 rows)
--    Needs dim_markets and dim_commodities first
-- ------------------------------------------------------------
CREATE TABLE fact_prices (
    price_id     INT                        NOT NULL AUTO_INCREMENT,
    price_date   DATE                       NOT NULL,
    market_id    INT                        NOT NULL,
    commodity_id INT                        NOT NULL,
    price_flag   ENUM('actual','aggregate') NOT NULL,
    price_type   ENUM('Retail','Wholesale') NOT NULL,
    currency     CHAR(3)                    NOT NULL DEFAULT 'KES',
    price_ksh    DECIMAL(12,4)              NOT NULL,
    price_usd    DECIMAL(12,4)              NOT NULL,
    PRIMARY KEY (price_id),
    INDEX idx_date      (price_date),
    INDEX idx_market    (market_id),
    INDEX idx_commodity (commodity_id),
    CONSTRAINT fk_price_market
        FOREIGN KEY (market_id)    REFERENCES dim_markets    (market_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_price_commodity
        FOREIGN KEY (commodity_id) REFERENCES dim_commodities (commodity_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);