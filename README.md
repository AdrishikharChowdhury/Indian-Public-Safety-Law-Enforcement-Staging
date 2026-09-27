# 📌Crime Analysis India — SQL Server Staging & Data Cleaning Pipeline

---

## 📖 Overview

This repository contains an end-to-end SQL data cleaning and ETL transformation pipeline executed in **Microsoft SQL Server running inside a Docker container on CachyOS (Linux)**. Following the **Alex the Analyst** portfolio project methodology, this project transforms an uncleaned, production-messy staging dataset ([Crime Analysis India on Kaggle](https://www.kaggle.com/datasets/sumedh1507/crime-in-india-dataset?utm_source=gemini)) into an audit-ready relational data warehouse.

The raw dataset presents real-world data quality flaws: concatenated string fields merging police stations and zones (`Reporting_Agency`), non-standardized string casing across locations, multi-format timestamp strings, missing/null categorical flags, and duplicate incident records.

---

## 🛠️ Environment & Infrastructure

* **Database Engine:** Microsoft SQL Server 2022 (Docker Container)
* **Host Operating System:** CachyOS Linux
* **Dataset Source:** Kaggle — `Crime Analysis India`
* **Orchestration & Client Tools:** Bash Automation Scripts, `sqlcmd` CLI, Azure Data Studio

---

## 📂 Project Directory Structure

```text
sql-crime-analysis-india/
├── data/
│   ├── raw/
│   │   └── crime_analysis_india.csv          # Uncleaned Kaggle CSV dataset
│   └── processed/
│       └── cleaned_crime_incidents.csv       # Exported clean dataset post-pipeline
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

## 📋 Execution Roadmap (Questions & Technical Tasks)

### Phase 1: Staging & Setup

#### Q1. Staging Table Creation & Raw Ingestion

* **Task:** Create `dbo.stg_Crime_Analysis_India` with all attributes defined as flexible text types (`NVARCHAR(MAX)`).
* **Objective:** Prevent bulk import failures caused by mixed date strings, malformed numerical fields, or unexpected delimiter artifacts during raw CSV loading.

#### Q2. Metadata & Baseline Data Audit

* **Task:** Execute diagnostic queries using `COUNT(*)`, `COUNT(DISTINCT ...)`, and `SUM(CASE WHEN ... IS NULL THEN 1 END)` across core attributes (`Status`, `Weapon_Used`, `Victim_Age`).
* **Objective:** Quantify baseline noise, null counts, and whitespace inconsistencies prior to running structural updates.

---

### Phase 2: String Parsing & Structural Extraction

#### Q3. Agency & Zone Extraction (`Reporting_Agency`)

* **Task:** Parse compound `Reporting_Agency` strings (e.g., `'PS_Park_Street-South_Div-Zone_1'`) into distinct columns:
* `Police_Station`
* `Jurisdiction_Zone`


* **Objective:** Isolate nested administrative attributes using string manipulation functions (`SUBSTRING`, `CHARINDEX`, `PARSENAME`).

#### Q4. Delimiter Stripping & Text Formatting

* **Task:** Strip underscores (`_`), hyper-dashes, and trailing spaces from parsed fields using `REPLACE()` and `TRIM()`.
* **Objective:** Standardize extracted agency and station names into clean, readable labels.

---

### Phase 3: Categorical Normalization & Missing Value Imputation

#### Q5. Spatial Entity & Casing Unification

* **Task:** Standardize casing and historical text variations across `State/UT` and `District` columns (e.g., `'KOLKATA'`, `'Kolkata '`, `'calcutta'`).
* **Objective:** Apply `UPPER()`, `TRIM()`, and `CASE` conditional mapping to eliminate split categorical groups in spatial queries.

#### Q6. Missing & Null Categorical Imputation

* **Task:** Standardize missing values, blank entries, and text flags (`'null'`, `'N/A'`, `'None'`) across categorical columns like `Status` and `Weapon_Used`.
* **Objective:** Utilize `COALESCE()` and `CASE` expressions to reassign missing flags to unified `'Unspecified'` or `'Under Investigation'` categories.

---

### Phase 4: Date Parsing & Data Type Casting

#### Q7. Multi-Format Date Standardization

* **Task:** Convert heterogeneous string date entries (`DD/MM/YYYY`, `YYYY-MM-DD`, `DD-MM-YYYY`) into standard SQL `DATE` values (`YYYY-MM-DD`).
* **Objective:** Employ `TRY_CONVERT()` / `TRY_PARSE()` to safely execute typecasting without triggering batch conversion crashes.

#### Q8. Temporal Anomaly Filtering

* **Task:** Audit and flag corrupt or out-of-bounds date entries (e.g., future dates or historical timestamps prior to `2000-01-01`).
* **Objective:** Nullify or reassign invalid date entries to protect downstream time-series metrics.

---

### Phase 5: Deduplication via Window Functions & CTEs

#### Q9. Identifying Duplicate Incident Records

* **Task:** Locate operational multi-filings sharing identical incident dates, locations, crime categories, and victim demographics under differing auto-IDs.
* **Objective:** Construct duplicate detection queries to log record redundancy.

#### Q10. Deduplication Purge via `ROW_NUMBER()` CTE

* **Task:** Construct a Common Table Expression (CTE) using `ROW_NUMBER() OVER (PARTITION BY State, District, Incident_Date, Crime_Type, Victim_Age ORDER BY Incident_ID)` to isolate and `DELETE` duplicate entries (`WHERE RowNum > 1`).
* **Objective:** Enforce row-level uniqueness while retaining a single primary master record.

---

### Phase 6: Production Schema & Staging-to-Production ETL Load

#### Q11. Production Schema Definition (`Fact_Crime_Incidents`)

* **Task:** Write the DDL script for `dbo.Fact_Crime_Incidents` specifying strict relational data types (`INT`, `DATE`, `VARCHAR`), primary key constraints, and default values.
* **Objective:** Enforce schema validation and data integrity on the production warehouse table.

#### Q12. Production Data Transformation & Insert

* **Task:** Write the final `INSERT INTO dbo.Fact_Crime_Incidents SELECT ...` script migrating cleaned, parsed, deduplicated, and typed data from staging into production.
* **Objective:** Finalize the staging-to-production ETL pipeline.

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

---
