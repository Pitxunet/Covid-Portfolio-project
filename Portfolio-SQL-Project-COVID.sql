SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract COVID in France
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location='France'
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs. Population
-- Shows what percentage of population got COVID in France
SELECT Location, date, total_cases, Population, (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location='France'
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS CasesPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location='France'
WHERE continent is not NULL
GROUP BY Location,Population
ORDER BY CasesPercentage desc;

-- Let's break things down by continent
-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location='France'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Global numbers
SELECT date, SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location='France'
WHERE continent is not NULL
Group by date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location='France'
WHERE continent is not NULL
--Group by date
ORDER BY 1,2

--Looking at Total Population vs. Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
 dea.date ) AS RollingPeopleVaccinated, 
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3


--USE CTE or common table expression

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
 dea.date ) AS RollingPeopleVaccinated 
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
 dea.date ) AS RollingPeopleVaccinated 
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;

-- Now let's create "Views"
-- Creating "View" to store data for later visualizations
CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
 dea.date ) AS RollingPeopleVaccinated 
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated