-- ============================================================
--  KENYA FOOD MARKET PRICES
--  PHASE 4: MARKET LEVEL ANALYSIS
--  Analyzes food prices at individual market level
--
--  Concepts covered:
--  RIGHT JOIN,
--  Window Functions: RANK(), ROW_NUMBER(), DENSE_RANK(),
--                    LAG(), LEAD(), SUM() OVER()
--  CTE combined with Window Functions
-- ============================================================

USE kenya_food_market_prices;


-- ------------------------------------------------------------
--  QUERY 1: Average price per market
--  Concepts: INNER JOIN chain, GROUP BY, AVG
--  Purpose:  See which individual markets have the highest
--            and lowest average food prices
-- ------------------------------------------------------------
SELECT 
    m.market_name,
    t.town_name,
    r.region_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM fact_prices f
INNER JOIN dim_markets   m ON m.market_id = f.market_id
INNER JOIN dim_towns     t ON t.town_id   = m.town_id
INNER JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY m.market_name, t.town_name, r.region_name
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 2: RIGHT JOIN — all markets even with no price records
--  Concepts: RIGHT JOIN
--  Purpose:  Show ALL markets whether they have price records
--            or not. Markets with no records show NULL for
--            avg_price and 0 for total_records.
--            RIGHT JOIN = all rows from the RIGHT table
--            (dim_markets) are returned whether matched or not
--            Compare with INNER JOIN — INNER JOIN would hide
--            markets with no price records completely
-- ------------------------------------------------------------
SELECT 
    m.market_name,
    t.town_name,
    r.region_name,
    ROUND(AVG(f.price_ksh), 2) AS avg_price,
    COUNT(f.price_id)           AS total_records
FROM fact_prices f
RIGHT JOIN dim_markets   m ON m.market_id = f.market_id
RIGHT JOIN dim_towns     t ON t.town_id   = m.town_id
RIGHT JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY m.market_name, t.town_name, r.region_name
ORDER BY avg_price DESC;


-- ------------------------------------------------------------
--  QUERY 3: Number of markets per region
--  Concepts: INNER JOIN, COUNT, GROUP BY
--  Purpose:  See how many markets exist in each region
--            and how many price records each region has
-- ------------------------------------------------------------
SELECT 
    r.region_name,
    COUNT(DISTINCT m.market_id) AS total_markets,
    COUNT(f.price_id)           AS total_price_records
FROM fact_prices f
INNER JOIN dim_markets   m ON m.market_id = f.market_id
INNER JOIN dim_towns     t ON t.town_id   = m.town_id
INNER JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY r.region_name
ORDER BY total_markets DESC;


-- ------------------------------------------------------------
--  QUERY 4: RANK() — rank markets by average price
--  Concepts: Window Function — RANK()
--  Purpose:  Assign a rank to each market based on its
--            average price. RANK() skips numbers after a tie
--            e.g if two markets tie for rank 1, next is rank 3
--            Window functions do not collapse rows like
--            GROUP BY — each row keeps its own identity
-- ------------------------------------------------------------
SELECT 
    m.market_name,
    t.town_name,
    r.region_name,
    ROUND(AVG(f.price_ksh), 2)                    AS avg_price,
    RANK() OVER (ORDER BY AVG(f.price_ksh) DESC)  AS price_rank
FROM fact_prices f
INNER JOIN dim_markets   m ON m.market_id = f.market_id
INNER JOIN dim_towns     t ON t.town_id   = m.town_id
INNER JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY m.market_name, t.town_name, r.region_name
ORDER BY price_rank ASC;


-- ------------------------------------------------------------
--  QUERY 5: DENSE_RANK() — rank markets within each region
--  Concepts: Window Function — DENSE_RANK(), PARTITION BY
--  Purpose:  Rank markets within their own region separately
--            PARTITION BY splits the ranking by region so
--            each region has its own rank 1, 2, 3...
--            DENSE_RANK does not skip numbers after a tie
--            e.g if two markets tie for rank 1, next is rank 2
-- ------------------------------------------------------------
SELECT 
    m.market_name,
    t.town_name,
    r.region_name,
    ROUND(AVG(f.price_ksh), 2)                                          AS avg_price,
    DENSE_RANK() OVER (PARTITION BY r.region_name 
                       ORDER BY AVG(f.price_ksh) DESC)                  AS region_rank
FROM fact_prices f
INNER JOIN dim_markets   m ON m.market_id = f.market_id
INNER JOIN dim_towns     t ON t.town_id   = m.town_id
INNER JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY m.market_name, t.town_name, r.region_name
ORDER BY r.region_name ASC, region_rank ASC;


-- ------------------------------------------------------------
--  QUERY 6: ROW_NUMBER() — number rows within each region
--  Concepts: Window Function — ROW_NUMBER()
--  Purpose:  Assign a unique row number within each region
--            Unlike RANK and DENSE_RANK, ROW_NUMBER never
--            repeats a number even when there is a tie —
--            it just picks one row arbitrarily as the winner
-- ------------------------------------------------------------
SELECT 
    m.market_name,
    t.town_name,
    r.region_name,
    ROUND(AVG(f.price_ksh), 2)                                          AS avg_price,
    ROW_NUMBER() OVER (PARTITION BY r.region_name 
                       ORDER BY AVG(f.price_ksh) DESC)                  AS row_num
FROM fact_prices f
INNER JOIN dim_markets   m ON m.market_id = f.market_id
INNER JOIN dim_towns     t ON t.town_id   = m.town_id
INNER JOIN dim_regions   r ON r.region_id = t.region_id
GROUP BY m.market_name, t.town_name, r.region_name
ORDER BY r.region_name ASC, row_num ASC;


-- ------------------------------------------------------------
--  QUERY 7: LAG() — compare each year's price to previous year
--  Concepts: Window Function — LAG(), CTE
--  Purpose:  LAG() looks at the previous row's value.
--            Here we use it to compare this year's average
--            price to last year's — showing year on year change
--            A positive difference means prices went up
--            A negative difference means prices went down
-- ------------------------------------------------------------
WITH yearly_prices AS (
    SELECT 
        YEAR(f.price_date)         AS year,
        ROUND(AVG(f.price_ksh), 2) AS avg_price
    FROM fact_prices f
    GROUP BY YEAR(f.price_date)
)
SELECT 
    year,
    avg_price,
    LAG(avg_price) OVER (ORDER BY year)                           AS prev_year_price,
    ROUND(avg_price - LAG(avg_price) OVER (ORDER BY year), 2)    AS year_on_year_change
FROM yearly_prices
ORDER BY year ASC;


-- ------------------------------------------------------------
--  QUERY 8: LEAD() — see next year's price from current row
--  Concepts: Window Function — LEAD(), CTE
--  Purpose:  LEAD() looks at the next row's value.
--            Here we use it to show what the price will be
--            in the following year from each current row
--            LAG  = look backwards at previous row
--            LEAD = look forwards at next row
-- ------------------------------------------------------------
WITH yearly_prices AS (
    SELECT 
        YEAR(f.price_date)         AS year,
        ROUND(AVG(f.price_ksh), 2) AS avg_price
    FROM fact_prices f
    GROUP BY YEAR(f.price_date)
)
SELECT 
    year,
    avg_price,
    LEAD(avg_price) OVER (ORDER BY year)                          AS next_year_price,
    ROUND(LEAD(avg_price) OVER (ORDER BY year) - avg_price, 2)   AS upcoming_change
FROM yearly_prices
ORDER BY year ASC;


-- ------------------------------------------------------------
--  QUERY 9: SUM() OVER() — running total of price records
--  Concepts: Window Function — SUM() OVER(), running total
--  Purpose:  Calculate a running cumulative total of price
--            records over the years — shows how the dataset
--            grew over time year by year
--            Unlike GROUP BY which collapses rows,
--            SUM() OVER() keeps all rows and adds a
--            cumulative column alongside them
-- ------------------------------------------------------------
WITH yearly_counts AS (
    SELECT 
        YEAR(price_date) AS year,
        COUNT(price_id)  AS total_records
    FROM fact_prices
    GROUP BY YEAR(price_date)
)
SELECT 
    year,
    total_records,
    SUM(total_records) OVER (ORDER BY year)  AS running_total
FROM yearly_counts
ORDER BY year ASC;


-- ------------------------------------------------------------
--  QUERY 10: Final summary — top market per region using CTE
--            and Window Functions combined
--  Concepts: CTE + RANK() + PARTITION BY all together
--  Purpose:  Find the single most expensive market in each
--            region — combines everything learned in Phase 4
--            Step 1: CTE calculates avg price per market
--            Step 2: RANK() ranks markets within each region
--            Step 3: Outer query filters to only rank 1
-- ------------------------------------------------------------
WITH market_prices AS (
    SELECT 
        m.market_name,
        t.town_name,
        r.region_name,
        ROUND(AVG(f.price_ksh), 2)                                      AS avg_price,
        RANK() OVER (PARTITION BY r.region_name 
                     ORDER BY AVG(f.price_ksh) DESC)                    AS region_rank
    FROM fact_prices f
    INNER JOIN dim_markets   m ON m.market_id = f.market_id
    INNER JOIN dim_towns     t ON t.town_id   = m.town_id
    INNER JOIN dim_regions   r ON r.region_id = t.region_id
    GROUP BY m.market_name, t.town_name, r.region_name
)
SELECT 
    region_name,
    market_name,
    town_name,
    avg_price
FROM market_prices
WHERE region_rank = 1
ORDER BY avg_price DESC;