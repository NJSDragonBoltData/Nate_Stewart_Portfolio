SELECT *
FROM COVID_practice..CovidDeaths
ORDER BY 3, 4;

SELECT *
FROM COVID_practice..CovidVaccinations
ORDER BY 3, 4;


-- What would be the total percentage of fatalities of people in the US that were infected by COVID?
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Percentage_of_fatalities
FROM COVID_practice..CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2;

-- Find the percentage of people in the US who were infected by COVID.
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percentage_of_infections
FROM COVID_practice..CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2;

-- Find the highest percentage of people worldwide who were infected by COVID.
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percentage_of_infections
FROM COVID_practice..CovidDeaths
WHERE location = 'World'
ORDER BY 5 DESC;

-- The total_deaths column was first imported as a nvarchar data type. 
-- And so, it has to be changed into a 'float' or 'int' data type to perform calculations
-- ALTER TABLE COVID_practice..CovidDeaths ALTER COLUMN total_deaths float

-- Or it can be changed using a CAST function
-- CAST(total_deaths AS int)

-- Or use CONVERT
-- CONVERT(float, total_deaths)

-- Which country has the highest average mortality rate?
SELECT continent, location, AVG(CONVERT(float, total_deaths)) AS avg_mortality_rate
FROM COVID_practice..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY avg_mortality_rate DESC;

-- Which continent has the highest average mortality rate?
SELECT continent, AVG(total_deaths) AS avg_mortality_rate
FROM COVID_practice..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY avg_mortality_rate DESC;

-- Joining the two tables together
SELECT *
FROM COVID_practice..CovidDeaths cd
JOIN COVID_practice..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date;

-- Finding the total population vs vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vac
FROM COVID_practice..CovidDeaths cd
JOIN COVID_practice..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTE in order to take rolling_people_vac and divide it under population
WITH Pop_Vs_Vac (continent, location, date, population, new_vaccinations, rolling_people_vac)
AS (
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vac
FROM COVID_practice..CovidDeaths cd
JOIN COVID_practice..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (rolling_people_vac/population)*100 AS Pop_Vac_Percent
FROM Pop_Vs_Vac;


-- Creating a TEMP table for Pop_Vac_Percent
DROP TABLE IF EXISTS #Pop_Vac_Percent 
CREATE TABLE #Pop_Vac_Percent
(
continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population int, 
new_vaccinations int, 
rolling_people_vac float
);

INSERT INTO #Pop_Vac_Percent
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vac
FROM COVID_practice..CovidDeaths cd
JOIN COVID_practice..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;

SELECT *, (rolling_people_vac/population)*100 AS Pop_Vac_Percent
FROM #Pop_Vac_Percent
ORDER BY Pop_Vac_Percent DESC;
