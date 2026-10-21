# KENYA-FOOD-MARKET-PRICES-SQL-ANALYSIS

## Project Overview
This project analyzes food commodity prices across Kenya's markets from 2006 to 2023.
The original dataset was a single flat file containing 10,647 records and 14 columns.
It was normalized into a star schema with 5 dimension tables and 1 fact table to enable
a full SQL analysis experience covering all major SQL concepts.

---

## Dataset
- **Source:** Kenya Food Prices (WFP — World Food Programme)
- **Period:** January 2006 — September 2023
- **Coverage:** 7 regions, 22 towns, 62 markets, 47 commodities
- **Original file:** `data/raw/FOOD_PRICES_IN_KENYA.csv`
Click [here](https://drive.google.com/file/d/1xrJ2JxMjTsg-BcsH_42J8K8vfCmEnFJt/view?usp=drive_link) to download the dataset.
---

## Project Structure
```
kenya_food_market_prices/
│
├── data/
│   ├── raw/
│   │   └── FOOD_PRICES_IN_KENYA.csv        ← original flat file
│   │
│   └── processed/
│       ├── dim_regions.csv
│       ├── dim_food_categories.csv
│       ├── dim_towns.csv
│       ├── dim_markets.csv
│       ├── dim_commodities.csv
│       └── fact_prices_raw.csv
│
├── sql/
│   ├── setup/
│   │   ├── 01_create_schema.sql
│   │   ├── 02_create_staging.sql
│   │   ├── 03_insert_dimensions.sql
│   │   ├── 04_insert_fact.sql
│   │   └── 05_verify.sql
│   │
│   └── analysis/
│       ├── 01_trends_over_time.sql
│       ├── 02_regional_comparison.sql
│       ├── 03_commodity_analysis.sql
│       └── 04_market_analysis.sql
│
└── README.md
```

---

## Database Schema
The flat file was normalized into a star schema:

```
dim_regions
    region_id (PK)
    region_name
        │
        └── dim_towns
                town_id (PK)
                town_name
                region_id (FK → dim_regions)
                    │
                    └── dim_markets
                            market_id (PK)
                            market_name
                            town_id (FK → dim_towns)
                            latitude
                            longitude
                                │
dim_food_categories             │
    category_id (PK)            │
    category_name               │
        │                       │
        └── dim_commodities     │
                commodity_id (PK)
                commodity_name  │
                category_id (FK → dim_food_categories)
                unit            │
                    │           │
                    └───────────┴──── fact_prices
                                          price_id (PK)
                                          price_date
                                          market_id (FK → dim_markets)
                                          commodity_id (FK → dim_commodities)
                                          price_flag
                                          price_type
                                          currency
                                          price_ksh
                                          price_usd
```

---

## How to Set Up

### Requirements
- MySQL 8.0 or higher
- DBeaver or MySQL Workbench or VS Code with SQL Tools extension

### Step 1 — Create the database and tables
Run `sql/setup/01_create_schema.sql`

### Step 2 — Create staging tables
Run `sql/setup/02_create_staging.sql`

### Step 3 — Import CSVs via DBeaver
Import the processed CSVs in this exact order:

| CSV File | Import Into | Method |
|---|---|---|
| dim_regions.csv | dim_regions | Direct import |
| dim_food_categories.csv | dim_food_categories | Direct import |
| dim_towns.csv | stg_towns | Staging import |
| dim_markets.csv | stg_markets | Staging import |
| dim_commodities.csv | stg_commodities | Staging import |
| fact_prices_raw.csv | stg_prices | Staging import |

### Step 4 — Insert dimension tables
Run `sql/setup/03_insert_dimensions.sql`

### Step 5 — Insert fact table and drop staging
Run `sql/setup/04_insert_fact.sql`

### Step 6 — Verify all tables loaded correctly
Run `sql/setup/05_verify.sql`

**Expected row counts:**
| Table | Rows |
|---|---|
| dim_regions | 7 |
| dim_food_categories | 8 |
| dim_towns | 22 |
| dim_markets | 62 |
| dim_commodities | 47 |
| fact_prices | 10,647 |

---

## Analysis

### Phase 1 — Trends Over Time (`01_trends_over_time.sql`)
Analyzes how food prices changed from 2006 to 2023.

**SQL concepts covered:**
- SELECT, WHERE, ORDER BY, LIMIT
- YEAR(), MONTH(), BETWEEN
- GROUP BY, ROUND()
- Aggregations: COUNT, AVG, MIN, MAX
- INNER JOIN across multiple tables

---

### Phase 2 — Regional Price Comparison (`02_regional_comparison.sql`)
Analyzes how food prices differ across Kenya's 7 regions.

**SQL concepts covered:**
- INNER JOIN chain
- LEFT JOIN
- GROUP BY multiple columns
- HAVING clause
- CASE WHEN

---

### Phase 3 — Commodity Price Analysis (`03_commodity_analysis.sql`)
Analyzes food commodity prices across all categories.

**SQL concepts covered:**
- INNER JOIN with dim_food_categories
- HAVING clause
- Subqueries
- CASE WHEN
- FULL OUTER JOIN (via UNION)
- CTE — Common Table Expressions

---

### Phase 4 — Market Level Analysis (`04_market_analysis.sql`)
Analyzes food prices at individual market level.

**SQL concepts covered:**
- RIGHT JOIN
- COUNT DISTINCT
- Window Functions: RANK(), DENSE_RANK(), ROW_NUMBER()
- Window Functions: LAG(), LEAD(), SUM() OVER()
- PARTITION BY
- CTE combined with Window Functions

---

## Key SQL Concepts Summary

| Concept | Where Used |
|---|---|
| SELECT, WHERE, ORDER BY | All phases |
| INNER JOIN | All phases |
| LEFT JOIN | Phase 2 |
| RIGHT JOIN | Phase 4 |
| FULL OUTER JOIN | Phase 3 |
| GROUP BY + Aggregations | All phases |
| HAVING | Phase 2 & 3 |
| Subqueries | Phase 3 |
| CASE WHEN | Phase 2 & 3 |
| CTE | Phase 3 & 4 |
| Window Functions | Phase 4 |

---

## Author
**Brian Kipkorir Kiptoo** — [LinkedIn]([https://www.linkedin.com/in/brian-kiptoo-602932387/](https://www.linkedin.com/in/brian-kiptoo-602932387/?utm_source=chatgpt.com))
This project was built as a portfolio SQL analysis project demonstrating
database design, normalization, data loading and multi-phase SQL analysis
on a real world dataset.
