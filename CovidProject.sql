SELECT *
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location like '%states%' 
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date,  Population, total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population


SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,(MAX(total_cases/population))*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Let's break things down by Continent 
-- Showing the Continents with the Highest Death Count per Population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers by Date


SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(CAST(New_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Global Numbers Total


SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(CAST(New_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Use CTE


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentVaccinated
FROM PopvsVac


-- Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentVaccinated
FROM #PercentPopulationVaccinated


-- Creating view to store data for later vizualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3