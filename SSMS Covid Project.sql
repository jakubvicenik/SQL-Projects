UPDATE CovidDeathsCSV
SET date = CONVERT(DATE, SUBSTRING(date, 7, 4) + '-' + SUBSTRING(date, 4, 2) + '-' + SUBSTRING(date, 1, 2), 120);

-- Trošièku zlobil data type

--SELECT *
--FROM [Portfolio Project]..CovidDeathsCSV
--ORDER BY 3,4;

--SELECT *
--FROM [Portfolio Project]..CovidVaccinationsCSV
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeathsCSV
ORDER BY 1,2

-- Total cases vs Total Deaths
-- Pravdìpodobnost smrti na covid v pøípadì nákazy.
SELECT Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS Deathpercentage
FROM [Portfolio Project]..CovidDeathsCSV
WHERE location LIKE '%Czech%'
ORDER BY 1,2

-- Total cases vs Population
-- Procento populace nakaženo Covidem
SELECT Location, date, total_cases, Population, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 AS Populationpercentage
FROM [Portfolio Project]..CovidDeathsCSV
WHERE location LIKE '%Czech%'
ORDER BY 1,2

-- Czechia 3rd place LETSGOOOOOOO
SELECT Location,Population, MAX(total_cases) AS HighestInfectionCount, 
MAX((CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0)))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeathsCSV
--WHERE location LIKE '%Czech%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Highest death count per country

SELECT Location,MAX(total_deaths) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeathsCSV
WHERE continent NOT LIKE ''
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Highest death count per continent

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeathsCSV
WHERE continent LIKE ''
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeathsCSV
--WHERE location LIKE '%Czech%'
WHERE continent NOT LIKE ''
--GROUP BY date
ORDER BY 1,2

-- Date format troubles :-)
UPDATE [Portfolio Project]..CovidVaccinationsCSV
SET date = CONVERT(DATE, SUBSTRING(date, 7, 4) + '-' + SUBSTRING(date, 4, 2) + '-' + SUBSTRING(date, 1, 2), 120)
WHERE 
    ISDATE(SUBSTRING(date, 7, 4) + '-' + SUBSTRING(date, 4, 2) + '-' + SUBSTRING(date, 1, 2)) = 1;

SELECT *
FROM [Portfolio Project]..CovidDeathsCSV dea
JOIN [Portfolio Project]..CovidVaccinationsCSV vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_daily
FROM [Portfolio Project]..CovidDeathsCSV dea
JOIN [Portfolio Project]..CovidVaccinationsCSV vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent NOT LIKE ''
ORDER BY 2,3;

-- Gotta use CTE so I can work aggregate total_vaccinations_daily / TEMP table was an option

WITH CTE_banger (Continent, Location, Date, Population, New_vaccinations, total_vaccinations_daily)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_daily
FROM [Portfolio Project]..CovidDeathsCSV dea
JOIN [Portfolio Project]..CovidVaccinationsCSV vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent NOT LIKE ''
--ORDER BY 2,3
)
SELECT *, total_vaccinations_daily/NULLIF(CONVERT(float,Population),0)*100 AS PopVsVac
FROM CTE_banger
--WHERE Location = 'Czechia'


-- Creating some views for future vizualisations
USE [Portfolio Project];
GO
Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_daily
FROM [Portfolio Project]..CovidDeathsCSV dea
JOIN [Portfolio Project]..CovidVaccinationsCSV vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent NOT LIKE ''
--ORDER BY 2,3

CREATE View DeathCountPerContinent AS
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeathsCSV
WHERE continent LIKE ''
GROUP BY Location
--ORDER BY TotalDeathCount DESC

CREATE View DeathCountPerCountry AS
SELECT Location,MAX(total_deaths) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeathsCSV
WHERE continent NOT LIKE ''
GROUP BY Location
--ORDER BY TotalDeathCount DESC

CREATE View GlobalNumbers AS
SELECT SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeathsCSV
--WHERE location LIKE '%Czech%'
WHERE continent NOT LIKE ''
--GROUP BY date
--ORDER BY 1,2

CREATE View TotalCasesVsTotalDeaths AS
SELECT Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS Deathpercentage
FROM [Portfolio Project]..CovidDeathsCSV
--WHERE location LIKE '%Czech%'
--ORDER BY 1,2

CREATE View TotalCasesVsPopulation AS
SELECT Location, date, total_cases, Population, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 AS Populationpercentage
FROM [Portfolio Project]..CovidDeathsCSV
--WHERE location LIKE '%Czech%'
--ORDER BY 1,2

Create View PercentPopulationInfected AS
SELECT Location,Population, MAX(total_cases) AS HighestInfectionCount, 
MAX((CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0)))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeathsCSV
--WHERE location LIKE '%Czech%'
GROUP BY Location, Population
--ORDER BY PercentPopulationInfected DESC
GO

