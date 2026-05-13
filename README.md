# U.S. Housing Market Analysis (2012–2023)

A data analytics project exploring what factors drove housing price appreciation across U.S. metro areas over the past decade, using PostgreSQL, R, and public economic datasets.

## Research Question
**Which economic and demographic factors most strongly predict housing price appreciation across U.S. metro areas from 2012–2023?**

## Key Findings
- The **West region** had the highest overall price appreciation at over 100% from 2012–2023, driven by remote work migration into Mountain West markets
- The **top appreciating metros** were not major coastal cities but smaller adjacent markets (Fernley NV, Boise ID, Coeur d'Alene ID) that absorbed migration from expensive hubs
- The **pandemic boom peaked in 2021** with 18% year-over-year growth in the West — the highest single-year growth rate in the dataset
- **2023 had the highest home values despite the highest mortgage rates**, illustrating the inventory lock-in effect. Homeowners with low fixed rates refused to sell, keeping supply constrained and prices elevated

## Data Sources
| Dataset | Source | Description |
|---|---|---|
| Home Values (ZHVI) | Zillow Research | Monthly median home values by metro, 2012–2023 |
| Mortgage Rates | Freddie Mac PMMS | Weekly 30-year fixed mortgage rates |
| Demographics | U.S. Census ACS | Population, median income, education by metro |
| Unemployment | U.S. Census ACS | Annual unemployment rates by metro |

## Tech Stack
- **PostgreSQL** — relational database storing 150,000+ rows across 5 tables
- **DBeaver** — SQL querying and schema management
- **R** — data cleaning, reshaping, and loading via tidyverse, tidycensus, readxl, DBI, and RPostgres

## Database Schema
- housing.metro_areas — 894 U.S. metro areas with region classifications
- housing.housing_prices — 126,405 monthly median home values (Zillow ZHVI)
- housing.demographics — 10,331 annual demographic records (Census ACS)
- housing.employment — 10,331 annual unemployment records (Census ACS)
- housing.mortgage_rates — 144 monthly averaged 30-year fixed rates

## SQL Concepts Demonstrated
- Multi-table JOINs across 3+ tables
- CTEs (Common Table Expressions) for readable multi-step queries
- Window functions (LAG) for year-over-year growth calculations
- Conditional aggregation with CASE WHEN
- Subqueries and calculated columns

## File Structure
- data_loading.Rmd — R Markdown: data cleaning and PostgreSQL loading
- analysis_queries.sql — All 5 SQL analysis queries with comments
- README.md

## How to Reproduce
1. Install PostgreSQL and create a database
2. Run data_loading.Rmd in RStudio to pull and load all data
   - Requires a free Census API key from api.census.gov
   - Requires Zillow ZHVI CSV and Freddie Mac PMMS XLSX downloads
3. Run analysis_queries.sql in DBeaver or any PostgreSQL client

## Author
Micah Copple
[Website](https://micahcopple.netlify.app) | [GitHub](https://github.com/micahcopple4287) | [LinkedIn](https://www.linkedin.com/in/micah-copple/)
