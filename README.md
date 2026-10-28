# Zomato Restaurant Data Warehouse & BI Project

**Stack:** PostgreSQL · SQL · Docker · Data Modeling · BI  
**Source:** Zomato restaurant dataset (9,551 records)  
**Dataset Url:** https://www.kaggle.com/datasets/srisyra02/zomato-market-analysis  
**Status:** Data warehouse development; dashboard publication pending

## Overview

An SQL-first data warehouse project that converts raw restaurant data into reliable analytical models. The architecture separates ingestion, cleaning/normalization, and business reporting using **staging → silver → gold** schemas.

The project is designed to answer questions about restaurant distribution, cuisines, ratings, price ranges, table booking, and delivery availability across geographic areas.

## Architecture

```text
Zomato dataset
      |
      v
staging (raw imported records)
      |
      | SQL cleaning, validation, normalization
      v
silver (relational, typed, deduplicated entities)
      |
      | SQL aggregation, KPI definitions, dimensional models
      v
gold (analytics-ready datasets)
      |
      v
BI dashboards / reports (planned)
```

### Environment Variables

```env
DB_PASSWORD=your_database_password
```

### Technology

| Component | Responsibility |
|---|---|
| PostgreSQL | Warehouse storage, SQL transformations, analytical queries |
| Docker | Local reproducible database environment |
| SQL | Data quality, joins, CTEs, aggregations, transformations |
| BI tool | Planned dashboard and visual reporting |

**Scope:** This project deliberately uses SQL for data transformations; it does not require Python, Airflow, or Spark.

## Dataset

The raw dataset contains **9,551 restaurants** and includes restaurant IDs/names, country codes, addresses, locality information, coordinates, cuisines, average cost for two, currencies, price ranges, ratings, votes, and service availability flags.

Important limitations:

- Some locality names appear in multiple cities and require careful mapping.
- `0` ratings may mean **not rated**, not a poor rating.
- Costs across currencies should not be compared without conversion.
- Coordinates imported as text require validation before numeric conversion.
- The dataset should not be treated as a complete census of restaurants.

## Warehouse Design

### Staging — Source Preservation

The `staging` schema retains raw fields, including:

`rest_id`, `rest_name`, `country_code`, `address`, `locality`, `locality_verbose`, `long`, `lat`, `cuisines`, `avg_cost_for_two`, `currency`, `price_range`, `agg_rating`, `rating_color`, `rating_text`, `votes`, `has_table_booking`, `has_online_delivery`, `is_delivering_now`, `switch_to_order_menu`.

### Silver — Cleaned Relational Model

| Table | Purpose |
|---|---|
| `silver.locations` | Geographic locations; unique `(country_code, city, locality)` |
| `silver.location_city_mapping` | Resolves locality/city mapping |
| `silver.restaurants` | Restaurant attributes with `location_id` foreign key |
| `silver.cuisines` | Distinct cuisine entities |
| `silver.restaurant_cuisines` | Many-to-many mapping; unique cuisine/restaurant pairs |

Selected modeling decisions:

- Restaurant IDs remain unique primary keys.
- Location IDs are surrogate keys.
- Latitude/longitude are stored as `NUMERIC(9,6)`.
- Cost is stored as `NUMERIC(10,2)` and ratings as `NUMERIC(2,1)`.
- Booking/delivery indicators are normalized to booleans.
- Cuisine strings are separated into a normalized relationship.

### Gold — Business-Facing Models

The gold layer is intended to expose reusable reporting datasets for:

- Restaurant count by country, city, and locality
- Rated restaurant count and average rating
- Cuisine popularity and distribution
- Price range and cost segmentation
- Online delivery and table booking coverage

Final model names and metrics should be documented from the actual SQL scripts.

## Data Quality Strategy

| Check | Purpose |
|---|---|
| Unique restaurant IDs | Prevent duplicate source entities |
| Restaurant count reconciliation | Explain differences from 9,551 source rows |
| Foreign key integrity | Ensure every restaurant has a valid location |
| Unique cuisine mappings | Prevent repeated cuisine/restaurant pairs |
| Coordinate validation | Latitude -90..90, longitude -180..180 |
| Rating validity | Check bounds and unrated semantics |
| Nonnegative costs | Detect invalid monetary values |
| Geographic ambiguity | Validate country/city/locality mapping |

### Rating Categories

| Score | Category |
|---|---|
| 0.0 | Not rated |
| 0.01–2.49 | Poor |
| 2.50–3.49 | Average |
| 3.50–3.99 | Good |
| 4.00–4.49 | Very good |
| 4.50+ | Excellent |

## Example Analytical SQL

### Restaurants by Country

```sql
SELECT l.country_code, COUNT(*) AS restaurant_count
FROM silver.restaurants AS r
JOIN silver.locations AS l ON l.location_id = r.location_id
GROUP BY l.country_code
ORDER BY restaurant_count DESC;
```

### Average Rating by City (Excluding Unrated)

```sql
SELECT
    l.country_code,
    l.city,
    COUNT(*) FILTER (WHERE r.agg_rating > 0) AS rated_count,
    ROUND(AVG(r.agg_rating) FILTER (WHERE r.agg_rating > 0), 2)
        AS average_rating
FROM silver.restaurants AS r
JOIN silver.locations AS l ON l.location_id = r.location_id
GROUP BY l.country_code, l.city
ORDER BY rated_count DESC;
```

> These examples use the discussed silver schema. Validate against the final repository DDL before execution.

## Planned BI Dashboards

1. **Executive Overview:** restaurant count, country coverage, average rating, rated/unrated split.
2. **Geographic Analysis:** country → city → locality drill-down and map.
3. **Cuisine Analysis:** popularity and ratings by cuisine and location.
4. **Pricing & Ratings:** price-range breakdowns and rating distributions.
5. **Service Availability:** online delivery and table booking adoption.

**Metric caveats:** Show sample sizes with averages; exclude unrated restaurants from rating averages; do not directly compare costs in different currencies.

## Suggested Repository Structure

```text
.
├── README.md
├── docker-compose.yml
├── sql/
│   ├── staging/
│   ├── silver/
│   ├── gold/
│   └── quality_checks/
├── docs/
│   ├── data_dictionary.md
│   └── er_diagram.png
└── dashboards/
    └── screenshots/
```

This is a suggested structure, not a claim that all files currently exist.

## Local Setup

1. Start a PostgreSQL instance using Docker.
2. Create the `staging`, `silver`, and `gold` schemas.
3. Import the Zomato source dataset into `staging`.
4. Run silver transformation scripts in dependency order.
5. Execute gold queries and data quality checks.
6. Connect a BI tool to the gold models when ready.

Add exact commands and environment configuration after finalizing the repository scripts. Never commit credentials.

## Project Status

**Built / discussed:** Raw staging, normalized silver tables, location mapping, cuisine relationships, SQL transformations.

**Next:** Verify and document gold models, add automated validation queries, publish BI dashboard screenshots, add an ER diagram, and document analytical findings.

## Skills Demonstrated

SQL-based ELT · PostgreSQL · relational modeling · data cleansing · data quality · dimensional analytics · business metric design.

---

**Disclaimer:** Independent educational portfolio project; not affiliated with or endorsed by Zomato.
