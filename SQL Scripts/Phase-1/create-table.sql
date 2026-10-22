USE stg_Crime_Analysis_India
GO

IF OBJECT_ID('stg_Crime_Analysis_India','U') IS NULL
BEGIN
    CREATE TABLE dbo.stg_Crime_Analysis_India(
        report_number NVARCHAR(MAX) NULL,
        date_reported NVARCHAR(MAX) NULL,
        date_of_occurrence NVARCHAR(MAX) NULL,
        time_of_occurrence NVARCHAR(MAX) NULL,
        city NVARCHAR(MAX) NULL,
        crime_code NVARCHAR(MAX) NULL,
        crime_description NVARCHAR(MAX) NULL,
        victim_age NVARCHAR(MAX) NULL,
        victim_gender NVARCHAR(MAX) NULL,
        weapon_used NVARCHAR(MAX) NULL,
        crime_domain NVARCHAR(MAX) NULL,
        police_deployed NVARCHAR(MAX) NULL,
        case_closed NVARCHAR(MAX) NULL,
        date_case_closed NVARCHAR(MAX) NULL
    );
END;
GO
