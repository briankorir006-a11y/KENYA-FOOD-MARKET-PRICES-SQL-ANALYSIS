-- ============================================================
--  KENYA FOOD MARKET PRICES
--  PHASE 2: PRICE COMPARISON ACROSS REGIONS
--  Analyzes how food prices differ across Kenya's 7 regions
--
--  Concepts covered:
--  INNER JOIN (multi-table chain),
--  LEFT JOIN,
--  GROUP BY, ORDER BY,
--  Aggregations: AVG, COUNT, MIN, MAX, ROUND
--  HAVING clause,
--  CASE WHEN
-- ============================================================

USE kenya_food_market_prices;


-- ------------------------------------------------------------
--  QUERY 1: Average price per region
--  Concepts: INNER JOIN chain, GROUP BY, AVG, ORDER BY
--  Purpose:  See which region has the highest average food
--            prices overall across the entire dataset
-- ------------------------------------------------------------
SELECT 
    r.region_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price
FROM fact_prices f
INNER JOIN dim_markets   m ON m.market_id = f.market_id
INNER JOIN dim_towns     t ON t.town_id   = m.town_id
INNER JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY r.region_name
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 2: Average price per region per year
--  Concepts: INNER JOIN chain, GROUP BY multiple columns
--  Purpose:  Track how each region's prices changed over the
--            years — shows regional price trends side by side
-- ------------------------------------------------------------
SELECT 
    YEAR(f.price_date)         AS year,
    r.region_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price
FROM fact_prices f
INNER JOIN dim_markets   m ON m.market_id = f.market_id
INNER JOIN dim_towns     t ON t.town_id   = m.town_id
INNER JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY YEAR(f.price_date), r.region_name
ORDER BY year ASC, avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 3: LEFT JOIN — all regions even with no price records
--  Concepts: LEFT JOIN, COUNT
--  Purpose:  Show ALL regions whether they have price records
--            or not. Regions with no records show NULL for
--            avg_price and 0 for total_records.
--            Compare with INNER JOIN — INNER JOIN would hide
--            regions with no price records completely
--  Note:     Query starts from dim_regions (left table) not
--            fact_prices — this is what makes it a LEFT JOIN
-- ------------------------------------------------------------
SELECT 
    r.region_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM dim_regions r
LEFT JOIN dim_towns    t ON t.region_id = r.region_id
LEFT JOIN dim_markets  m ON m.town_id   = t.town_id
LEFT JOIN fact_prices  f ON f.market_id = m.market_id
GROUP BY r.region_name
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 4: Price comparison by region and commodity
--  Concepts: INNER JOIN chain, GROUP BY multiple columns
--  Purpose:  See how the price of each commodity differs
--            across regions — e.g is Maize cheaper in
--            Rift Valley than in Nairobi?
-- ------------------------------------------------------------
SELECT 
    r.region_name,
    c.commodity_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM fact_prices f
INNER JOIN dim_commodities c ON c.commodity_id = f.commodity_id
INNER JOIN dim_markets     m ON m.market_id    = f.market_id
INNER JOIN dim_towns       t ON t.town_id      = m.town_id
INNER JOIN dim_regions     r ON r.region_id    = t.region_id
GROUP BY r.region_name, c.commodity_name
ORDER BY c.commodity_name ASC, avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 5: Min, Max and Average price per region
--  Concepts: MIN, MAX, AVG, COUNT all together
--  Purpose:  Get a full price summary per region showing
--            the cheapest, most expensive and average prices
-- ------------------------------------------------------------
SELECT 
    r.region_name,
    ROUND(MIN(f.price_ksh), 2) AS min_price,
    ROUND(MAX(f.price_ksh), 2) AS max_price,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM fact_prices f
INNER JOIN dim_markets   m ON m.market_id = f.market_id
INNER JOIN dim_towns     t ON t.town_id   = m.town_id
INNER JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY r.region_name
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 6: HAVING — regions with average price above 500 KSH
--  Concepts: HAVING clause
--  Purpose:  Filter AFTER aggregation — HAVING works like WHERE
--            but is used on aggregated results like AVG, COUNT
--            WHERE filters rows BEFORE grouping
--            HAVING filters groups AFTER grouping
-- ------------------------------------------------------------
SELECT 
    r.region_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price
FROM fact_prices f
INNER JOIN dim_markets   m ON m.market_id = f.market_id
INNER JOIN dim_towns     t ON t.town_id   = m.town_id
INNER JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY r.region_name
HAVING avg_price > 500
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 7: CASE WHEN — classify regions by price level
--  Concepts: CASE WHEN, GROUP BY, AVG
--  Purpose:  Add a calculated column that labels each region
--            as 'High', 'Medium' or 'Low' based on avg price
--            CASE WHEN is SQL's version of Excel IF statement
-- ------------------------------------------------------------
SELECT 
    r.region_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    CASE 
        WHEN AVG(f.price_ksh) > 1000 THEN 'High'
        WHEN AVG(f.price_ksh) > 500  THEN 'Medium'
        ELSE 'Low'
    END AS price_level
FROM fact_prices f
INNER JOIN dim_markets   m ON m.market_id = f.market_id
INNER JOIN dim_towns     t ON t.town_id   = m.town_id
INNER JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY r.region_name
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 8: Retail vs Wholesale price comparison by region
--  Concepts: CASE WHEN, GROUP BY multiple columns
--  Purpose:  Compare retail and wholesale prices side by side
--            per region to see the price markup
-- ------------------------------------------------------------
SELECT 
    r.region_name,
    f.price_type,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM fact_prices f
INNER JOIN dim_markets   m ON m.market_id = f.market_id
INNER JOIN dim_towns     t ON t.town_id   = m.town_id
INNER JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY r.region_name, f.price_type
ORDER BY r.region_name ASC, f.price_type ASC;