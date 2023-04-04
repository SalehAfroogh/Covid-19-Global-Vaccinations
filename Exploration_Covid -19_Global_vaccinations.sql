
/*
Cleaning Covid 19 Global_vaccinations data by SQL Queries
SQL SKILLS: Dropping columns, GROUP BY clause, Counting function, 
Converting data types, Updating data, Modifying column
*/



Select *
From `COVID.V.Project`.global_vaccinations

-- --------------------------------------------------------------------------------------------------------------------------

-- Drop unnecessary columns from original table
ALTER TABLE vision.global_covid_vaccinations
    DROP COLUMN iso_code, 
         DROP COLUMN total_boosters, 
         DROP COLUMN daily_vaccinations_raw, 
         DROP COLUMN total_vaccinations_per_hundred, 
         DROP COLUMN people_vaccinated_per_hundred, 
         DROP COLUMN people_fully_vaccinated_per_hundred, 
         DROP COLUMN total_boosters_per_hundred, 
         DROP COLUMN daily_vaccinations_per_million, 
         DROP COLUMN daily_people_vaccinated, 
         DROP COLUMN daily_people_vaccinated_per_hundred;

-- --------------------------------------------------------------------------------------------------------------------------

-- Identify missing data

SELECT COUNT(*) AS missing_total_vaccinations
FROM vision.global_covid_vaccinations 
WHERE total_vaccinations IS NULL;

SELECT COUNT(*) AS missing_people_vaccinated
FROM vision.global_covid_vaccinations
WHERE people_vaccinated IS NULL;

SELECT COUNT(*) AS missing_people_fully_vaccinated
FROM vision.global_covid_vaccinations
WHERE people_fully_vaccinated IS NULL;

SELECT COUNT(*) AS missing_daily_vaccinations
FROM vision.global_covid_vaccinations
WHERE daily_vaccinations IS NULL;

-- --------------------------------------------------------------------------------------------------------------------------


-- Remove duplicates records
SELECT COUNT(*) AS total_duplicate_rows
FROM vision.global_covid_vaccinations
GROUP BY location, date, total_vaccinations, people_vaccinated, people_fully_vaccinated, daily_vaccinations
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------------------------------------------------------------


-- Check Data Types

SELECT location, DATE_FORMAT(date, '%Y-%m-%d') AS date_str, CAST(total_vaccinations AS UNSIGNED) AS total_vaccinations, CAST(people_vaccinated AS UNSIGNED) AS people_vaccinated, CAST(people_fully_vaccinated AS UNSIGNED) AS people_fully_vaccinated, CAST(daily_vaccinations AS UNSIGNED) AS daily_vaccinations
FROM vision.global_covid_vaccinations;


-- --------------------------------------------------------------------------------------------------------------------------

-- Remove outliers: Identify and remove any extreme values that are likely to skew the analysis
SELECT *
FROM vision.global_covid_vaccinations
WHERE total_vaccinations > 500000000
OR people_vaccinated > 400000000
OR people_fully_vaccinated > 400000000
OR daily_vaccinations > 20000000;


-- --------------------------------------------------------------------------------------------------------------------------


-- Handle inconsistencies: Check for any inconsistencies in the data, such as spelling errors, inconsistent capitalization, or formatting issues.

UPDATE vision.global_covid_vaccinations
SET location = REPLACE(location, 'United Kingdom', 'UK'),
    location = REPLACE(location, 'United States', 'USA'),
    location = REPLACE(location, 'Czech Republic', 'Czechia'),
    location = REPLACE(location, 'Taiwan', 'Taiwan*'),
    location = REPLACE(location, 'Bonaire Sint Eustatius and Saba', 'Bonaire, Sint Eustatius and Saba')


-- --------------------------------------------------------------------------------------------------------------------------

-- Standardize Data Type 

ALTER TABLE vision.global_covid_vaccinations
MODIFY COLUMN date DATE,
MODIFY COLUMN location VARCHAR(255),
MODIFY COLUMN total_vaccinations BIGINT,
MODIFY COLUMN people_vaccinated BIGINT,
MODIFY COLUMN people_fully_vaccinated BIGINT,
MODIFY COLUMN daily_vaccinations INT;


ALTER TABLE `COVID.V.Project`.global_vaccinations
CHANGE COLUMN `date` `VAXdate` DATE;

-- --------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------

-- Document the cleaning process

/*
The following cleaning steps were performed on the `vision.global_covid_vaccinations` table:

1. Drop unnecessary columns
2. Identify missing data
3. Remove any duplicate records
4. Check Data Types
5. Remove outliers (none found in the data)
6. Handle inconsistencies (none found in the data)
7. Standardize Data Type and Format (capitalization of location names, chaning names, etc)

*/













