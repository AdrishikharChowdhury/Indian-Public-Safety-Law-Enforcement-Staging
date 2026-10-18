# 📌 Crime Analysis India — SQL Server Staging & Data Cleaning Pipeline

---

## 📖 Overview

This repository contains an end-to-end SQL data cleaning and ETL transformation pipeline executed in **Microsoft SQL Server running inside a Docker container on CachyOS (Linux)**. Following the **Alex the Analyst** portfolio project methodology, this project transforms an uncleaned, production-messy staging dataset into an audit-ready relational data warehouse using the production file schema (`clean_crime_incidents.csv` containing **40,160 records** across **14 core attributes**).

The dataset handles real-world data engineering requirements: processing string timestamps, managing **5,790 missing weapon values**, handling **20,098 unclosed cases**, standardizing spatial distributions across 29 Indian cities, and purging duplicate incident filings.

---

## 🛠️ Environment & Infrastructure

* **Database Engine:** Microsoft SQL Server 2022 (Docker Container)
* **Host Operating System:** CachyOS Linux
* **Dataset File:** `clean_crime_incidents.csv` (40,160 rows, 14 columns)
* **Orchestration & Client Tools:** Bash Automation Scripts, `sqlcmd` CLI, Azure Data Studio

---

## 📂 Project Directory Structure

```text
sql-crime-analysis-india/
├── data/
│   ├── raw/
│   │   └── crime_analysis_india.csv          # Uncleaned CSV dataset
│   └── processed/
│       └── clean_crime_incidents.csv         # Processed dataset (40,160 rows, 14 attributes)
├── sql/
│   ├── 01_raw_staging_import.sql            # Staging table DDL & baseline noise audit (Q1, Q2)
│   ├── 02_string_parsing_agency.sql         # SUBSTRING/PARSENAME extraction & delimiter stripping (Q3, Q4)
│   ├── 03_categorical_standardization.sql   # UPPER/TRIM casing unification & COALESCE NULL handling (Q5, Q6)
│   ├── 04_date_parsing_typecasting.sql      # TRY_CONVERT multi-format dates & anomaly filtering (Q7, Q8)
│   ├── 05_cte_deduplication.sql             # ROW_NUMBER() CTE duplicate isolation & purge (Q9, Q10)
│   └── 06_production_schema_load.sql       # Final Fact table DDL & staging-to-prod ETL INSERT (Q11, Q12)
├── scripts/
│   ├── load_data.sh                          # Bulk CSV load script into Docker container
│   └── run_pipeline.sh                      # Master pipeline script executing 01-06 sequentially
├── docker-compose.yml                       # SQL Server 2022 Docker container definition
├── .gitignore
├── LICENSE
└── README.md

```

---

## 📋 Technical Execution & Interview Question Set

### Phase 1: Staging Infrastructure & Baseline Data Auditing

#### Q1. Raw Staging Schema Design

* **Task:** Write the DDL to construct `dbo.stg_Crime_Analysis_India` with all raw ingestion columns (`report_number`, `date_reported`, `date_of_occurrence`, `time_of_occurrence`, `city`, `crime_code`, `crime_description`, `victim_age`, `victim_gender`, `weapon_used`, `crime_domain`, `police_deployed`, `case_closed`, `date_case_closed`) typed as flexible `NVARCHAR(MAX)` fields.
* **Interview Drill:** Why do we define every column in our staging table as `NVARCHAR(MAX)` instead of strongly typed fields (`INT`, `DATE`, `VARCHAR(50)`) during raw CSV ingestion? What explicit SQL Server error occurs if a string date like `'31/02/2020'` or an empty string `''` is loaded directly into a `DATE` type column via `BULK INSERT`?
* **Objective:** Prevent bulk import failures caused by mixed date strings, malformed numerical fields, or unexpected delimiter artifacts during raw CSV loading.

#### Q2. Quantifying Data Quality & Baseline Noise

* **Task:** Execute diagnostic queries using `COUNT(*)`, `COUNT(DISTINCT ...)`, and `SUM(CASE WHEN ... IS NULL THEN 1 END)` across core attributes (`weapon_used`, `date_case_closed`, `case_closed`).
* **Interview Drill:** Write a single SQL Server diagnostic query to evaluate data completeness on `dbo.stg_Crime_Analysis_India`. The query must output:
1. Total row count (`TotalRecords` = 40,160).
2. Count of missing `weapon_used` entries (5,790 missing records).
3. Count of unclosed cases where `case_closed = 'No'` (20,098 records) compared against `NULL` counts in `date_case_closed` (20,098 records).
4. Count of distinct `city` values before and after applying `TRIM()` and `UPPER()`.


* **Objective:** Quantify baseline noise, null counts, and whitespace inconsistencies prior to running structural updates.

---

### Phase 2: Advanced String Parsing & Feature Extraction

#### Q3. Crime Domain & Description Segmentation

* **Task:** Parse categorical descriptors across `crime_description` and `crime_domain` to isolate parent crime categories (e.g., separating `IDENTITY THEFT`, `HOMICIDE`, and `KIDNAPPING` into `Violent Crime` vs `Other Crime`).
* **Interview Drill:** Write a query using SQL Server string functions (`CHARINDEX`, `SUBSTRING`, or `CASE`) to classify `crime_description` entries into high-level tactical buckets based on keyword triggers (`THEFT`, `HOMICIDE`, `ASSAULT`).
* **Objective:** Create standardized, high-level categorical features from unstructured crime descriptors.

#### Q4. Delimiter Sanitization & Location Formatting

* **Task:** Strip leading/trailing whitespaces, non-printable characters, and case variations across all 29 cities in the `city` column (`Ahmedabad`, `Chennai`, `Ludhiana`, `Delhi`, `Mumbai`, etc.).
* **Interview Drill:** Write an `UPDATE` query utilizing `TRIM()`, `UPPER()`, and `REPLACE()` to guarantee spatial consistency across all location entities in the database.
* **Objective:** Standardize location labels across all 40,160 entries for spatial joins.

---

### Phase 3: Categorical Normalization & Defensive Imputation

#### Q5. Geospatial & Domain Casing Unification

* **Task:** Standardize casing and historical text variations across `city`, `crime_description`, and `crime_domain` columns.
* **Interview Drill:** Write a SQL `UPDATE` statement utilizing `CASE WHEN`, `UPPER()`, and `TRIM()` to normalize spelling variations and standardize spatial entries across all 29 major Indian cities represented in the dataset.
* **Objective:** Eliminate split categorical groups caused by case sensitivity in spatial aggregations.

#### Q6. Conditional Imputation & Null Handling

* **Task:** Handle the 5,790 missing `weapon_used` entries and validate the 20,098 `NULL` values in `date_case_closed`.
* **Interview Drill:** In the dataset, 5,790 records contain `NULL` for `weapon_used` and 20,098 records contain `NULL` for `date_case_closed` where `case_closed = 'No'`. Write a SQL query using `COALESCE` combined with `NULLIF` to reassign missing `weapon_used` entries to `'Unspecified / Personal Weapon'`, while ensuring `date_case_closed` remains strictly `NULL` for open cases (`case_closed = 'No'`).
* **Objective:** Preserve row integrity and eliminate untracked `NULL` groups in downstream reporting queries.

---

### Phase 4: Safe Date Parsing & Data Type Casting

#### Q7. Multi-Format String-to-Date Conversion

* **Task:** Convert heterogeneous string timestamp entries (`DD-MM-YYYY HH:MI`, `YYYY-MM-DD HH:MI:SS`) in `date_reported`, `date_of_occurrence`, `time_of_occurrence`, and `date_case_closed` into standard SQL `DATETIME2` values.
* **Interview Drill:** The raw `date_reported` column contains string values (e.g., `'02-01-2020 00:00'`). Explain why standard `CAST(date_reported AS DATETIME2)` fails in SQL Server when encountering multi-format string data. Write a SQL query using `TRY_CONVERT()` or `TRY_PARSE()` with explicit culture/style codes (e.g., `103`, `120`) to safely parse these date strings into `DATETIME2` fields.
* **Objective:** Execute robust typecasting across date fields without triggering batch execution crashes.

#### Q8. Temporal Anomaly & Reporting Lag Metrics

* **Task:** Audit temporal sequences to ensure `date_reported` $\ge$ `date_of_occurrence` and `date_case_closed` $\ge$ `date_reported`.
* **Interview Drill:** Write a query to calculate `Reporting_Lag_Hours` (`DATEDIFF(HOUR, date_of_occurrence, date_reported)`) and `Closure_Duration_Days` (`DATEDIFF(DAY, date_of_occurrence, date_case_closed)`). Identify any anomalous rows where lag is negative or where closure date precedes occurrence date, and update anomalous date entries to `NULL`.
* **Objective:** Protect time-series metrics from corrupted date sequences.

---

### Phase 5: Entity Deduplication via Window Functions

#### Q9. Identifying Duplicate Incident Filings

* **Task:** Locate operational multi-filings sharing identical occurrence dates, cities, crime codes, victim demographics, and police deployment levels under differing `report_number` values.
* **Interview Drill:** Write a query using `GROUP BY` and `HAVING COUNT(*) > 1` to locate duplicate crime reports that share identical values across `date_of_occurrence`, `city`, `crime_code`, `victim_age`, and `victim_gender`, regardless of their auto-generated `report_number`.
* **Objective:** Detect operational multi-entry filings and log duplicates.

#### Q10. Idempotent Deduplication using CTE & `ROW_NUMBER()`

* **Task:** Construct a Common Table Expression (CTE) using `ROW_NUMBER() OVER (PARTITION BY date_of_occurrence, city, crime_code, victim_age, victim_gender ORDER BY report_number ASC)` to isolate and `DELETE` duplicate entries (`WHERE RowNum > 1`).
* **Interview Drill:** Construct a CTE using `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)` partitioning by logical incident key attributes. Show how to execute a `DELETE` statement directly against the CTE to purge all duplicate rows (`RowNum > 1`) while retaining exactly one master record.
* **Objective:** Guarantee row-level uniqueness across incident records.

---

### Phase 6: Production Schema & Staging-to-Production ETL Load

#### Q11. Production Schema Definition (`dbo.Fact_Crime_Incidents`)

* **Task:** Write the DDL script for `dbo.Fact_Crime_Incidents` specifying strict relational data types (`INT`, `DATETIME2`, `DATE`, `VARCHAR`), primary key constraints, and default values.
* **Interview Drill:** Write the complete DDL (`CREATE TABLE`) statement for `dbo.Fact_Crime_Incidents` matching your production dataset structure:
```sql
CREATE TABLE dbo.Fact_Crime_Incidents (
    report_number INT PRIMARY KEY,
    date_reported DATETIME2 NOT NULL,
    date_of_occurrence DATETIME2 NOT NULL,
    time_of_occurrence DATETIME2 NOT NULL,
    city VARCHAR(100) NOT NULL,
    crime_code INT NOT NULL,
    crime_description VARCHAR(150) NOT NULL,
    victim_age INT NOT NULL,
    victim_gender VARCHAR(10) NOT NULL,
    weapon_used VARCHAR(100) NULL,
    crime_domain VARCHAR(100) NOT NULL,
    police_deployed INT NOT NULL,
    case_closed VARCHAR(5) NOT NULL,
    date_case_closed DATETIME2 NULL,
    created_at DATETIME2 DEFAULT GETDATE()
);

```


* **Objective:** Enforce schema validation and data integrity on the production warehouse table.

#### Q12. Staging-to-Production Atomic ETL Script

* **Task:** Write the final `INSERT INTO dbo.Fact_Crime_Incidents (...) SELECT ...` script migrating cleaned, parsed, deduplicated, and typed data from staging into production.
* **Interview Drill:** Write the final `INSERT INTO dbo.Fact_Crime_Incidents (...) SELECT ...` query that reads from `dbo.stg_Crime_Analysis_India` and populates `dbo.Fact_Crime_Incidents`. How do you ensure this load operation is idempotent (e.g., using `NOT EXISTS` or `MERGE`) so re-running the script does not duplicate records in production?
* **Objective:** Finalize the staging-to-production ETL transformation pipeline.

---

## 🚀 Environment Setup & Pipeline Execution

### 1. Provision Docker Container

Start the SQL Server 2022 container on CachyOS:

```bash
docker-compose up -d

```

### 2. Ingest Raw Dataset

Load the uncleaned CSV into the staging database:

```bash
bash scripts/load_data.sh

```

### 3. Run Pipeline Scripts

Execute the SQL transformation sequence (`01` through `06`):

```bash
bash scripts/run_pipeline.sh

```