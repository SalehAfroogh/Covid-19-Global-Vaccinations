/*
Exploration Covid 19 Global_vaccinations data by SQL Queries

SQL SKILLS: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types
Group By, Conditional logic, Union All, Subqueries, Ranking functions, Aliasing, Set operators 
Case expressions, Date and time functions, Null handling functions, Full-text search functions 
Analytic functions (used to perform complex statistical analysis on data sets, such as ROW_NUMBER, RANK, DENSE_RANK, LEAD, and LAG)
*/

--  Total number of vaccinations administered per country
SELECT location, MAX(total_vaccinations) AS total_vaccinations
FROM vision.global_covid_vaccinations
GROUP BY location;

-- Total number of people fully vaccinated in each country/region

SELECT location, SUM(people_fully_vaccinated) AS people_fully_vaccinated 
FROM vision.global_covid_vaccinations
GROUP BY location;


--  Daily average number of vaccinations administered per country
SELECT location, AVG(daily_vaccinations) AS avg_daily_vaccinations
FROM vision.global_covid_vaccinations
GROUP BY location;

-- Average number of daily vaccinations in each country/region
SELECT location, AVG(daily_vaccinations) AS avg_daily_vaccinations 
FROM vision.global_covid_vaccinations
GROUP BY location;

-- Daily number of vaccinations administered globally
SELECT date, SUM(daily_vaccinations) AS daily_total_vaccinations
FROM vision.global_covid_vaccinations
GROUP BY date;

-- Total number of vaccinations administered globally by month
SELECT YEAR(date) AS year, MONTH(date) AS month, SUM(total_vaccinations) AS total_vaccinations
FROM vision.global_covid_vaccinations
GROUP BY YEAR(date), MONTH 

-- Total number of vaccinations administered on each date

SELECT date, SUM(total_vaccinations) AS total_vaccinations 
FROM vision.global_covid_vaccinations
GROUP BY date;

-- Total number of people fully vaccinated on each date
SELECT date, SUM(people_fully_vaccinated) AS people_fully_vaccinated 
FROM vision.global_covid_vaccinations
GROUP BY date;

-- Average number of daily vaccinations for each country/region on a specific date

SELECT location, AVG(daily_vaccinations) AS avg_daily_vaccinations 
FROM vision.global_covid_vaccinations
WHERE date = '2023-03-31'
GROUP BY location

-- Total Vaccinations in Last 7 Days by Location
SELECT location, 
       SUM(daily_vaccinations) AS total_vaccinations_last_7_days 
FROM vision.global_covid_vaccinations
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY location


-- The trend of daily vaccinations in different countries and identify any significant changes in the trend over time.
SELECT 
    location,
    AVG(daily_vaccinations) AS avg_daily_vaccinations,
    DATE_FORMAT(date, '%Y-%m') AS month_year
FROM 
    vision.global_covid_vaccinations
GROUP BY 
    location, 
    month_year
ORDER BY 
    location, 
    month_year

-- Countries/regions have administered the highest number of total vaccinations

SELECT location, total_vaccinations 
FROM vision.global_covid_vaccinations
ORDER BY total_vaccinations DESC
LIMIT 10;

-- The percentage change in the number of people fully vaccinated compared to the previous day for each country/region

SELECT location, 
       ROUND((people_fully_vaccinated - LAG(people_fully_vaccinated) OVER (PARTITION BY location ORDER BY date)) / LAG(people_fully_vaccinated) OVER (PARTITION BY location ORDER BY date) * 100, 2) AS pct_change_people_fully_vaccinated 
FROM vision.global_covid_vaccinations
WHERE people_fully_vaccinated IS NOT NULL;


-- 7-day rolling average of the daily number of vaccinations administered for each country/region and for the world as a whole

SELECT location, 
       date, 
       AVG(daily_vaccinations) OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_daily_vaccinations 
FROM vision.global_covid_vaccinations
UNION ALL
SELECT 'World', 
       date, 
       AVG(daily_vaccinations) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_daily_vaccinations 
FROM vision.global_covid_vaccinations;


-- The number of fully vaccinated people in countries/regions where the number of people vaccinated is more than 20 million

SELECT location, 
       MAX(date) AS latest_date,
       MAX(people_fully_vaccinated) AS fully_vaccinated
FROM vision.global_covid_vaccinations
WHERE people_vaccinated >= 40000000
GROUP BY location
ORDER BY fully_vaccinated DESC;



--  Top 10 and bottom 10 countries/regions with the highest and lowest number of total vaccinations in 2021

SELECT *
FROM (
  SELECT location,
         SUM(total_vaccinations) AS total_vaccinations_2021,
         ROW_NUMBER() OVER (ORDER BY SUM(total_vaccinations) DESC) AS rank_highest,
         ROW_NUMBER() OVER (ORDER BY SUM(total_vaccinations) ASC) AS rank_lowest
  FROM vision.global_covid_vaccinations
  WHERE YEAR(date) = 2021
  GROUP BY location
) t
WHERE rank_highest <= 10 OR rank_lowest <= 10
ORDER BY rank_highest, rank_lowest;

-- -----------------------------------------------------------------------------------------------

-- Joined a new table of world population to our database for more exploration
SELECT * FROM vision.global_covid_vaccinations g
inner join vision.world_population w
on g.location = w.country

-- Selecting the country, continent, date, total vaccinations, people vaccinated, people fully vaccinated,
-- and 2020 population from the two tables
SELECT
    g.location,
    w.continent,
    g.date,
    g.total_vaccinations,
    g.people_vaccinated,
    g.people_fully_vaccinated,
    w.`2020 population`,
    -- Calculating the percentage of the population that is vaccinated and fully vaccinated
    g.people_vaccinated / w.`2020 population` * 100 AS vaccinated_population_percentage,
    g.people_fully_vaccinated / w.`2020 population` * 100 AS fully_vaccinated_population_percentage
-- Joining the two tables on the location and country columns
FROM vision.global_covid_vaccinations g
INNER JOIN vision.world_population w
ON g.location = w.country
-- Selecting only the data for the latest date
WHERE g.date = (SELECT MAX(date) FROM vision.global_covid_vaccinations)
-- Sorting the data by vaccinated population percentage in descending order
ORDER BY vaccinated_population_percentage DESC




-- Calculate the percentage of global population that has been fully vaccinated
SELECT 
  SUM(g.people_fully_vaccinated) / SUM(w.`2020 population`) AS percent_global_population_fully_vaccinated
FROM vision.global_covid_vaccinations g
INNER JOIN vision.world_population w
ON g.location = w.country;



-- Calculate the average daily vaccination rate per capita for each continent
SELECT 
  w.continent,
  SUM(g.daily_vaccinations) / SUM(w.`2020 population`) AS avg_daily_vaccinations_per_capita
FROM vision.global_covid_vaccinations g
INNER JOIN vision.world_population w
ON g.location = w.country
GROUP BY w.continent;



-- Calculate the average daily vaccination rate per million people for each country
SELECT 
  g.location,
  SUM(g.daily_vaccinations) / (SUM(w.`2020 population`) / 1000000) AS avg_daily_vaccinations_per_million
FROM vision.global_covid_vaccinations g
INNER JOIN vision.world_population w
ON g.location = w.country
GROUP BY g.location;

-- Identify the top 10 countries with the highest percentage of their population fully vaccinated
SELECT 
  g.location,
  g.date,
  (g.people_fully_vaccinated / w.`2020 population`) * 100 AS percent_fully_vaccinated
FROM vision.global_covid_vaccinations g
INNER JOIN vision.world_population w
ON g.location = w.country
ORDER BY percent_fully_vaccinated DESC
LIMIT 10;


-- Calculate the total number of vaccinations and percentage of population vaccinated by continent
SELECT 
  w.continent,
  SUM(g.total_vaccinations) AS total_vaccinations,
  SUM(g.people_vaccinated) / SUM(w.`2020 population`) AS percent_population_vaccinated
FROM vision.global_covid_vaccinations g
INNER JOIN vision.world_population w
ON g.location = w.country
GROUP BY w.continent;


-- Calculate the z-score of daily vaccinations for each location
SELECT 
  g.location,
  g.date,
  g.daily_vaccinations,
  (g.daily_vaccinations - AVG(g.daily_vaccinations) OVER (PARTITION BY g.location)) / STDDEV(g.daily_vaccinations) OVER (PARTITION BY g.location) AS daily_vaccinations_zscore
FROM vision.global_covid_vaccinations g;


-- Calculate the number of days until a location reaches a certain percentage of population fully vaccinated
SELECT 
  g.location,
  g.date,
  g.people_fully_vaccinated / w.`2020 population` AS percent_population_fully_vaccinated,
  DATEDIFF(MIN(g.date) OVER (PARTITION BY g.location ORDER BY g.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), g.date) AS days_to_reach_percent_population_fully_vaccinated
FROM vision.global_covid_vaccinations g
INNER JOIN vision.world_population w
ON g.location = w.country
WHERE g.people_fully_vaccinated / w.`2020 population` >= 0.5;


-- -----------------------------------------------------------------------------------------------
--  SQL code to explore the topic of justice and fairness in the global and continental level for vaccination distribution. 


-- Calculate the percentage of the population fully vaccinated in Africa vs. Europe
SELECT 
  w.continent,
  g.date,
  (SUM(g.people_fully_vaccinated) / SUM(w.`2020 population`)) * 100 AS percent_fully_vaccinated
FROM vision.global_covid_vaccinations g
INNER JOIN vision.world_population w
ON g.location = w.country
WHERE w.continent IN ('Africa', 'Europe')
GROUP BY w.continent, g.date;


-- The top 10 countries with the highest total vaccinations and groups them by continent
SELECT w.continent, g.location, SUM(g.total_vaccinations) AS total_vaccinations
FROM vision.global_covid_vaccinations g
INNER JOIN vision.world_population w
ON g.location = w.country
GROUP BY w.continent, g.location
ORDER BY total_vaccinations DESC
LIMIT 10;

-- The bottom 10 countries with the lowest total vaccinations and groups them by continent
SELECT w.continent, g.location, SUM(g.total_vaccinations) AS total_vaccinations
FROM vision.global_covid_vaccinations g
INNER JOIN vision.world_population w
ON g.location = w.country
GROUP BY w.continent, g.location
ORDER BY total_vaccinations ASC
LIMIT 10;

-- -----------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------


/*
Exploration Covid 19 Global_vaccinations data by SQL Queries
SQL SKILLS:

Get the total number of vaccinations administered per country
Get the total number of people fully vaccinated in each country/region
Get the daily average number of vaccinations administered per country
Get the average number of daily vaccinations in each country/region
Get the daily number of vaccinations administered globally
Get the total number of vaccinations administered globally by month
Get the total number of vaccinations administered on each date
Get the total number of people fully vaccinated on each date
Get the average number of daily vaccinations for each country/region on a specific date
Get the total number of vaccinations administered in the last 7 days for each country/region
Analyze the trend of daily vaccinations in different countries and identify any significant changes in the trend over time
Get the countries/regions that have administered the highest number of total vaccinations
Get the percentage change in the number of people fully vaccinated compared to the previous day for each country/region
Get the 7-day rolling average of the daily number of vaccinations administered for each country/region and for the world as a whole
Get the number of fully vaccinated people in countries/regions where the number of people vaccinated is more than 40 million
Get the top 10 and bottom 10 countries/regions with the highest and lowest number of total vaccinations in 2021
Add a new table of world population to our database for more exploration
*/



