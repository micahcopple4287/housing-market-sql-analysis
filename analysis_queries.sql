-- QUERY 1: Average annual home price by region
-- Shows which regions appreciated fastest 2012-2023
-- For each region and each year, find the average home value across all metro areas in that region.

SELECT 
    m.region,
    hp.year,
    ROUND(AVG(hp.median_home_value)::NUMERIC, 0) AS avg_home_value
FROM housing.housing_prices hp
JOIN housing.metro_areas m 
    ON hp.cbsa_code = m.cbsa_code
GROUP BY m.region, hp.year
ORDER BY m.region, hp.year;



-- QUERY 2: Price appreciation by region (2012 vs 2023)
-- Shows % change in home values over the window
-- Calculate what percentage home values grew from 2012 to 2023 for each region, sorted from highest to lowest appreciation.

WITH base_year AS (
    SELECT 
        m.region,
        ROUND(AVG(hp.median_home_value)::NUMERIC, 0) AS avg_2012
    FROM housing.housing_prices hp
    JOIN housing.metro_areas m ON hp.cbsa_code = m.cbsa_code
    WHERE hp.year = 2012
    GROUP BY m.region
),
end_year AS (
    SELECT 
        m.region,
        ROUND(AVG(hp.median_home_value)::NUMERIC, 0) AS avg_2023
    FROM housing.housing_prices hp
    JOIN housing.metro_areas m ON hp.cbsa_code = m.cbsa_code
    WHERE hp.year = 2023
    GROUP BY m.region
)
SELECT 
    b.region,
    b.avg_2012,
    e.avg_2023,
    ROUND(((e.avg_2023 - b.avg_2012) / b.avg_2012 * 100)::NUMERIC, 1) AS pct_change
FROM base_year b
JOIN end_year e ON b.region = e.region
ORDER BY pct_change DESC;




-- QUERY 3: National avg home price vs mortgage rate by year
-- Key research question: do higher rates suppress prices?
-- For each year, show the national average home value alongside the average 30-year mortgage rate. 
-- This lets me visually compare whether rate increases correlate with price changes,

SELECT
    hp.year,
    ROUND(AVG(hp.median_home_value)::NUMERIC, 0) AS avg_home_value,
    ROUND(AVG(mr.avg_30yr_rate)::NUMERIC, 2)     AS avg_mortgage_rate
FROM housing.housing_prices hp
JOIN housing.mortgage_rates mr
    ON hp.year = mr.year
GROUP BY hp.year
ORDER BY hp.year;


-- QUERY 4: Do higher income metros have more price appreciation?
-- Joins housing prices with demographics to compare
-- income levels vs home value growth
-- For each metro area, calculate both its average household income and its home price appreciation from 2012 to 2023
-- Then show the top 20 highest-appreciating metros alongside their income levels to see if wealthier metros appreciated faster

WITH appreciation AS (
    SELECT
        hp.cbsa_code,
        ROUND(AVG(CASE WHEN hp.year = 2012 
            THEN hp.median_home_value END)::NUMERIC, 0) AS avg_2012,
        ROUND(AVG(CASE WHEN hp.year = 2023 
            THEN hp.median_home_value END)::NUMERIC, 0) AS avg_2023
    FROM housing.housing_prices hp
    GROUP BY hp.cbsa_code
),
income AS (
    SELECT
        cbsa_code,
        metro_name,
        ROUND(AVG(median_income)::NUMERIC, 0) AS avg_income
    FROM housing.demographics
    GROUP BY cbsa_code, metro_name
)
SELECT
    m.metro_name,
    m.region,
    i.avg_income,
    a.avg_2012,
    a.avg_2023,
    ROUND(((a.avg_2023 - a.avg_2012) / a.avg_2012 * 100)::NUMERIC, 1) AS pct_change
FROM appreciation a
JOIN housing.metro_areas m ON a.cbsa_code = m.cbsa_code
JOIN income i ON LOWER(SPLIT_PART(m.metro_name, ',', 1)) = 
                 LOWER(SPLIT_PART(i.metro_name, ',', 1))
WHERE a.avg_2012 IS NOT NULL AND a.avg_2023 IS NOT NULL
ORDER BY pct_change DESC
LIMIT 20;



-- QUERY 5: Year-over-year price growth rate by region
-- Uses a window function (LAG) to compare each year to the prior
--  For each region and year, show the average home price alongside what it was the prior year, and calculate the YOY percentage growth

WITH annual_prices AS (
    SELECT
        m.region,
        hp.year,
        ROUND(AVG(hp.median_home_value)::NUMERIC, 0) AS avg_price
    FROM housing.housing_prices hp
    JOIN housing.metro_areas m ON hp.cbsa_code = m.cbsa_code
    GROUP BY m.region, hp.year
)
SELECT
    region,
    year,
    avg_price,
    -- LAG looks back at the previous row's value
    LAG(avg_price) OVER (PARTITION BY region ORDER BY year) AS prior_year_price,
    ROUND(
        ((avg_price - LAG(avg_price) OVER (PARTITION BY region ORDER BY year))
        / LAG(avg_price) OVER (PARTITION BY region ORDER BY year) * 100)::NUMERIC
    , 1) AS yoy_growth_pct
FROM annual_prices
ORDER BY region, year;



