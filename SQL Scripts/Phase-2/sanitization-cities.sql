USE stg_Crime_Analysis_India
GO

UPDATE stg_Crime_Analysis_India
SET city=UPPER(TRIM(REPLACE(REPLACE(REPLACE(city,CHAR(9),''),CHAR(10),''),CHAR(13),'')));

SELECT DISTINCT city, COUNT(*) AS Total_Incidents
FROM stg_Crime_Analysis_India
GROUP BY city
ORDER BY Total_Incidents DESC