USE stg_Crime_Analysis_India
GO

WITH classification AS (
    SELECT
        crime_description,
        crime_domain,
        CASE
            WHEN CHARINDEX('FIREARM OFFENSE',crime_description) > 0
                THEN 'Firearms Crime'
            WHEN CHARINDEX('TRAFFIC VIOLATION',crime_description)>0
                THEN 'Traffic Crime'
            WHEN CHARINDEX('CYBERCRIME',crime_description)>0
                THEN 'Cyber Crime'
            WHEN CHARINDEX('PUBLIC INTOXICATION',crime_description)>0
            OR CHARINDEX('ILLEGAL POSSESSION',crime_description)>0
            OR CHARINDEX('DRUG OFFENSE',crime_description)>0
                THEN 'Public Order'
            WHEN CHARINDEX('FRAUD',crime_description)>0
            OR CHARINDEX('COUNTERFEITING',crime_description)>0
            OR CHARINDEX('EXTORTION',crime_description)>0
            OR CHARINDEX('IDENTITY THEFT',crime_description)>0
                THEN 'Financial Crime'
            WHEN CHARINDEX('BURGLARY',crime_description)>0
            OR CHARINDEX('VANDALISM',crime_description)>0
            OR CHARINDEX('SHOPLIFTING',crime_description)>0
            OR CHARINDEX('VEHICLE - STOLEN',crime_description)>0
            OR CHARINDEX('ARSON',crime_description)>0
                THEN 'Property Crime'
            WHEN CHARINDEX('HOMICIDE', crime_description) > 0
            OR CHARINDEX('ASSAULT', crime_description) > 0
            OR CHARINDEX('ROBBERY', crime_description) > 0
            OR CHARINDEX('KIDNAPPING', crime_description) > 0
            OR CHARINDEX('DOMESTIC VIOLENCE', crime_description) > 0
                THEN 'Violent Crime'
            ELSE
                'Unclassified'
    END AS crime_bucket
    FROM stg_Crime_Analysis_India
)
SELECT crime_bucket,COUNT(*) AS Incidents
FROM classification
GROUP BY crime_bucket
ORDER BY Incidents DESC
