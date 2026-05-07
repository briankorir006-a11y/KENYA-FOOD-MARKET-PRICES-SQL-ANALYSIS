-- ============================================================
--  KENYA FOOD MARKET PRICES
--  PHASE 1: TRENDS OVER TIME
--  Analyzes how food prices have changed from 2006 to 2023
--  
--  Concepts covered:
--  SELECT, WHERE, ORDER BY, LIMIT, YEAR(), MONTH(),
--  BETWEEN, GROUP BY, ROUND(),
--  Aggregations: COUNT, AVG, MIN, MAX
--  Joins: INNER JOIN (fact_prices + dim_commodities + dim_markets
--                     + dim_towns + dim_regions)
-- ============================================================

USE kenya_food_market_prices;

-- ------------------------------------------------------------
--  QUERY 1: See the first 10 price records
--  Concepts: SELECT, LIMIT
--  Purpose:  Get a quick look at the raw fact table
-- ------------------------------------------------------------
SELECT *
FROM fact_prices
LIMIT 10;


-- ------------------------------------------------------------
--  QUERY 2: See prices in date order
--  Concepts: ORDER BY ASC/DESC
--  Purpose:  Understand the date range of the dataset
--            Change ASC to DESC to see most recent records first
-- ------------------------------------------------------------
SELECT *
FROM fact_prices
ORDER BY price_date ASC
LIMIT 10;


-- ------------------------------------------------------------
--  QUERY 3: Filter by a specific year
--  Concepts: WHERE, YEAR()
--  Purpose:  Narrow down records to a single year
-- ------------------------------------------------------------
SELECT *
FROM fact_prices
WHERE YEAR(price_date) = 2020
LIMIT 10;


-- ------------------------------------------------------------
--  QUERY 4: Filter by a date range
--  Concepts: WHERE, BETWEEN
--  Purpose:  Return all records within a specific date range
--            BETWEEN is cleaner than writing >= AND <=
-- ------------------------------------------------------------
SELECT *
FROM fact_prices
WHERE price_date BETWEEN '2020-01-01' AND '2020-12-31'
ORDER BY price_date ASC;


-- ------------------------------------------------------------
--  QUERY 5: Count how many price records exist per year
--  Concepts: COUNT(*), GROUP BY, ORDER BY
--  Purpose:  See how many observations were recorded each year
-- ------------------------------------------------------------
SELECT 
    YEAR(price_date)  AS year,
    COUNT(*)          AS total_records
FROM fact_prices
GROUP BY YEAR(price_date)
ORDER BY year ASC;


-- ------------------------------------------------------------
--  QUERY 6: Average price per year
--  Concepts: AVG(), ROUND(), GROUP BY
--  Purpose:  See how the overall average price changed yearly
--            ROUND() limits result to 2 decimal places
-- ------------------------------------------------------------
SELECT 
    YEAR(price_date)         AS year,
    ROUND(AVG(price_ksh), 2) AS avg_price_ksh
FROM fact_prices
GROUP BY YEAR(price_date)
ORDER BY year ASC;


-- ------------------------------------------------------------
--  QUERY 7: Min, Max and Average price per year
--  Concepts: MIN(), MAX(), AVG(), COUNT(), GROUP BY
--  Purpose:  Get a full price summary for each year
--            Shows the spread between cheapest and most expensive
-- ------------------------------------------------------------
SELECT 
    YEAR(price_date)         AS year,
    ROUND(MIN(price_ksh), 2) AS min_price,
    ROUND(MAX(price_ksh), 2) AS max_price,
    ROUND(AVG(price_ksh), 2) AS avg_price,
    COUNT(*)                 AS total_records
FROM fact_prices
GROUP BY YEAR(price_date)
ORDER BY year ASC;


-- ------------------------------------------------------------
--  QUERY 8: Average price per month in a specific year
--  Concepts: MONTH(), GROUP BY multiple columns
--  Purpose:  See monthly price fluctuations within a year
--            Change the year value to explore different years
-- ------------------------------------------------------------
SELECT 
    YEAR(price_date)         AS year,
    MONTH(price_date)        AS month,
    ROUND(AVG(price_ksh), 2) AS avg_price
FROM fact_prices
WHERE YEAR(price_date) = 2020
GROUP BY YEAR(price_date), MONTH(price_date)
ORDER BY month ASC;


-- ------------------------------------------------------------
--  QUERY 9: Average price per year by commodity (INNER JOIN)
--  Concepts: INNER JOIN, aliases, GROUP BY multiple columns
--  Purpose:  Replace commodity_id with actual commodity names
--            INNER JOIN only returns rows that match in both tables
--            f = fact_prices alias, c = dim_commodities alias
-- ------------------------------------------------------------
SELECT 
    YEAR(f.price_date)         AS year,
    c.commodity_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price
FROM fact_prices f
INNER JOIN dim_commodities c ON c.commodity_id = f.commodity_id
GROUP BY YEAR(f.price_date), c.commodity_name
ORDER BY year ASC, avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 10: Average price per year by commodity and market
--  Concepts: Multiple INNER JOINs
--  Purpose:  Join three tables at once to get commodity names
--            and market names alongside the price trends
-- ------------------------------------------------------------
SELECT 
    YEAR(f.price_date)         AS year,
    c.commodity_name,
    m.market_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price
FROM fact_prices f
INNER JOIN dim_commodities c ON c.commodity_id = f.commodity_id
INNER JOIN dim_markets     m ON m.market_id    = f.market_id
GROUP BY YEAR(f.price_date), c.commodity_name, m.market_name
ORDER BY year ASC, avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 11: Full chain JOIN — price trends with region names
--  Concepts: Joining all 5 tables, full chain JOIN
--  Purpose:  Pull in commodity, market, town and region names
--            all in one query — the complete picture
--            Shows how the star schema connects end to end:
--            fact_prices → dim_markets → dim_towns → dim_regions
--                        → dim_commodities
-- ------------------------------------------------------------
SELECT 
    YEAR(f.price_date)         AS year,
    c.commodity_name,
    m.market_name,
    t.town_name,
    r.region_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price
FROM fact_prices f
INNER JOIN dim_commodities   c ON c.commodity_id = f.commodity_id
INNER JOIN dim_markets       m ON m.market_id    = f.market_id
INNER JOIN dim_towns         t ON t.town_id      = m.town_id
INNER JOIN dim_regions       r ON r.region_id    = t.region_id
GROUP BY YEAR(f.price_date), c.commodity_name, m.market_name, t.town_name, r.region_name
ORDER BY year ASC, avg_price DESC;