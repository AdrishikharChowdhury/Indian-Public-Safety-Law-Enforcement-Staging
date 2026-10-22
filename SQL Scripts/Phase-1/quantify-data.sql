USE stg_Crime_Analysis_India
GO

SELECT
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN weapon_used IS NULL
        OR LTRIM(RTRIM(weapon_used)) IN ('','None')
        THEN 1 ELSE 0 END) AS Missing_Weapons,
    SUM(CASE WHEN UPPER(RTRIM(LTRIM(case_closed))) = 'NO'
        THEN 1 ELSE 0 END) AS Unclosed_Cases,
    SUM(CASE WHEN date_case_closed IS NULL
        OR RTRIM(LTRIM(date_case_closed)) =''
        THEN 1 ELSE 0 END) AS Cases_Date_Not_Closed,
    COUNT(DISTINCT city) AS No_of_Cities_Affected,
    COUNT(DISTINCT UPPER(RTRIM(LTRIM(city)))) AS No_of_Cities_Affected_Cleaned
FROM stg_Crime_Analysis_India
