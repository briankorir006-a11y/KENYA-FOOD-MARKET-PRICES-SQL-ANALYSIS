-- ============================================================
--  KENYA FOOD MARKET PRICES
--  PHASE 3: COMMODITY PRICE ANALYSIS
--  Analyzes food commodity prices across categories
--
--  Concepts covered:
--  INNER JOIN (including dim_food_categories),
--  FULL OUTER JOIN,
--  HAVING clause,
--  Subqueries,
--  CASE WHEN,
--  CTE (Common Table Expressions)
-- ============================================================

USE kenya_food_market_prices;


-- ------------------------------------------------------------
--  QUERY 1: Top 10 most expensive commodities overall
--  Concepts: INNER JOIN, AVG, ORDER BY, LIMIT
--  Purpose:  Identify which commodities have the highest
--            average price across the entire dataset
-- ------------------------------------------------------------
SELECT 
    c.commodity_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM fact_prices f
INNER JOIN dim_commodities c ON c.commodity_id = f.commodity_id
GROUP BY c.commodity_name
ORDER BY avg_price DESC
LIMIT 10;


-- ------------------------------------------------------------
--  QUERY 2: Most expensive commodity per category
--  Concepts: INNER JOIN with dim_food_categories
--  Purpose:  This is where category_name finally comes back!
--            We join dim_food_categories to get category names
--            alongside commodity names and their average prices
-- ------------------------------------------------------------
SELECT 
    fc.category_name,
    c.commodity_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM fact_prices f
INNER JOIN dim_commodities     c  ON c.commodity_id  = f.commodity_id
INNER JOIN dim_food_categories fc ON fc.category_id  = c.category_id
GROUP BY fc.category_name, c.commodity_name
ORDER BY fc.category_name ASC, avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 3: Average price per food category
--  Concepts: INNER JOIN, GROUP BY, AVG, ORDER BY
--  Purpose:  Compare entire food categories against each other
--            e.g is 'meat, fish and eggs' more expensive than
--            'cereals and tubers' on average?
-- ------------------------------------------------------------
SELECT 
    fc.category_name,
    ROUND(MIN(f.price_ksh), 2) AS min_price,
    ROUND(MAX(f.price_ksh), 2) AS max_price,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM fact_prices f
INNER JOIN dim_commodities     c  ON c.commodity_id = f.commodity_id
INNER JOIN dim_food_categories fc ON fc.category_id = c.category_id
GROUP BY fc.category_name
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 4: HAVING — commodities with average price above 1000
--  Concepts: HAVING clause
--  Purpose:  Filter results AFTER aggregation
--            WHERE filters rows BEFORE grouping
--            HAVING filters groups AFTER grouping
--            Think of HAVING as WHERE for aggregated results
-- ------------------------------------------------------------
SELECT 
    c.commodity_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM fact_prices f
INNER JOIN dim_commodities c ON c.commodity_id = f.commodity_id
GROUP BY c.commodity_name
HAVING avg_price > 1000
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 5: Subquery — commodities above the overall average
--  Concepts: Subquery (inner SELECT inside brackets)
--  Purpose:  The inner query runs first and calculates the
--            overall average price of all commodities.
--            The outer query then uses that result to filter
--            only commodities whose average is above it.
--            Think of it like a nested AVERAGEIF in Excel
-- ------------------------------------------------------------
SELECT 
    c.commodity_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price
FROM fact_prices f
INNER JOIN dim_commodities c ON c.commodity_id = f.commodity_id
GROUP BY c.commodity_name
HAVING avg_price > (
    SELECT AVG(price_ksh) 
    FROM fact_prices
)
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 6: CASE WHEN — classify commodities by price level
--  Concepts: CASE WHEN (SQL version of Excel IF statement)
--  Purpose:  Add a calculated column that labels each
--            commodity as 'High', 'Medium' or 'Low' based
--            on its average price
-- ------------------------------------------------------------
SELECT 
    c.commodity_name,
    fc.category_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    CASE 
        WHEN AVG(f.price_ksh) > 2000 THEN 'High'
        WHEN AVG(f.price_ksh) > 500  THEN 'Medium'
        ELSE 'Low'
    END AS price_level
FROM fact_prices f
INNER JOIN dim_commodities     c  ON c.commodity_id = f.commodity_id
INNER JOIN dim_food_categories fc ON fc.category_id = c.category_id
GROUP BY c.commodity_name, fc.category_name
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 7: FULL OUTER JOIN — all commodities and all prices
--  Concepts: FULL OUTER JOIN
--  Purpose:  Show ALL commodities and ALL price records
--            whether they match or not.
--            LEFT JOIN  = all from left table
--            RIGHT JOIN = all from right table
--            FULL OUTER JOIN = all from BOTH tables
--  Note:     MySQL does not support FULL OUTER JOIN directly
--            so we combine LEFT JOIN and RIGHT JOIN using UNION
-- ------------------------------------------------------------
SELECT 
    c.commodity_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM dim_commodities c
LEFT JOIN fact_prices f ON f.commodity_id = c.commodity_id
GROUP BY c.commodity_name

UNION

SELECT 
    c.commodity_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM fact_prices f
RIGHT JOIN dim_commodities c ON c.commodity_id = f.commodity_id
GROUP BY c.commodity_name

ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 8: CTE — Common Table Expression
--  Concepts: CTE (WITH clause)
--  Purpose:  A CTE is a temporary named result set that you
--            define at the top and then use like a table below.
--            Think of it as creating a temporary view just
--            for this one query — cleaner than subqueries
--            when you need to reuse the same result multiple
--            times in one query.
--
--            Here we first calculate avg price per commodity
--            in the CTE, then use it to find commodities
--            above the overall average — same as Query 5
--            but written in a much cleaner way
-- ------------------------------------------------------------
WITH commodity_avg AS (
    SELECT 
        c.commodity_name,
        fc.category_name,
        ROUND(AVG(f.price_ksh), 2) AS avg_price,
        COUNT(f.price_id)           AS total_records
    FROM fact_prices f
    INNER JOIN dim_commodities     c  ON c.commodity_id = f.commodity_id
    INNER JOIN dim_food_categories fc ON fc.category_id = c.category_id
    GROUP BY c.commodity_name, fc.category_name
)
SELECT 
    commodity_name,
    category_name,
    avg_price,
    total_records
FROM commodity_avg
WHERE avg_price > (SELECT AVG(avg_price) FROM commodity_avg)
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 9: CTE — Price trend per commodity over the years
--  Concepts: CTE with multiple columns, GROUP BY, ORDER BY
--  Purpose:  Use a CTE to first summarize yearly prices per
--            commodity, then query from that summary cleanly
-- ------------------------------------------------------------
WITH yearly_commodity_prices AS (
    SELECT 
        YEAR(f.price_date)         AS year,
        c.commodity_name,
        fc.category_name,
        ROUND(AVG(f.price_ksh), 2) AS avg_price
    FROM fact_prices f
    INNER JOIN dim_commodities     c  ON c.commodity_id = f.commodity_id
    INNER JOIN dim_food_categories fc ON fc.category_id = c.category_id
    GROUP BY YEAR(f.price_date), c.commodity_name, fc.category_name
)
SELECT 
    year,
    commodity_name,
    category_name,
    avg_price
FROM yearly_commodity_prices
ORDER BY commodity_name ASC, year ASC;