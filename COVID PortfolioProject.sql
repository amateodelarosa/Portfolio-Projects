SELECT *
FROM PortfolioProject..[covid deaths]
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..[covid vaccinations]
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..[covid deaths]
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of death if you get covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS PercentDeath
FROM PortfolioProject..[covid deaths]
WHERE LOCATION LIKE '%STATES%'
ORDER BY 1,2


-- Looking at Total Cases vs Population

SELECT location, date, population total_cases, (total_cases/population)* 100 AS PercentPopulationInfected
FROM PortfolioProject..[covid deaths]
WHERE continent is not null
--WHERE LOCATION LIKE '%STATES%'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to populations 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)* 100 AS PercentPopulationInfected
FROM PortfolioProject..[covid deaths]
--WHERE LOCATION LIKE '%STATES%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Showing continents with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..[covid deaths]
--WHERE LOCATION LIKE '%STATES%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global numbers

SELECT date,  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS PercentDeath
FROM PortfolioProject..[covid deaths]
--WHERE LOCATION LIKE '%STATES%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations as bigint) as new_vaccionations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as cumulative_sum_of_vaccinations
--MAX(cumulative_sum_of_vaccinations/population)*100
FROM PortfolioProject..[covid deaths] dea				
JOIN PortfolioProject..[covid vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3 


-- CTE

With PopulationvsVaccination (continent, location, date, population, new_vaccinations, cumulative_sum_of_vaccinations)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations as bigint) as new_vaccionations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as cumulative_sum_of_vaccinations
FROM PortfolioProject..[covid deaths] dea				
JOIN PortfolioProject..[covid vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (cumulative_sum_of_vaccinations/population)*100
FROM PopulationvsVaccination


-- TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255), 
date datetime, 
population numeric,
new_vaccinations numeric,
cumulative_sum_of_vaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations as bigint) as new_vaccionations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as cumulative_sum_of_vaccinations
FROM PortfolioProject..[covid deaths] dea				
JOIN PortfolioProject..[covid vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (cumulative_sum_of_vaccinations/population)*100
FROM #PercentPopulationVaccinated


-- Creating view for visualizations

-- Percent population Vaccinated

USE PortfolioProject 
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations as bigint) as new_vaccionations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as cumulative_sum_of_vaccinations
FROM PortfolioProject..[covid deaths] dea				
JOIN PortfolioProject..[covid vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM #PercentPopulationVaccinated




