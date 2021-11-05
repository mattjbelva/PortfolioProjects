SELECT*
FROM 
dbo.CovidDeaths
WHERE continent is not null 

SELECT*
FROM 
dbo.CovidVaccinations
ORDER BY 
3,4


-- Total cases vs. population 

SELECT 
location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM 
dbo.CovidVaccinations
WHERE 
location like '%states%'
ORDER BY 
1,2 

-- Looking at Countries with Highest Infection Rate Compared to Population 

SELECT 
location, continent, date, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM 
dbo.CovidVaccinations
-- WHERE location like '%states%'
GROUP BY 
location, population
ORDER BY 
PercentPopulationInfected

-- Countries with Highest Death Rate Per Population 
SELECT 
Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM 
[PortfolioProject ]..CovidVaccinations
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT *
FROM 
CovidVaccinations


-- Total Cases Vs. Total Deaths
SELECT
Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate 
FROM 
dbo.CovidVaccinations
WHERE Location like '%states%' 


-- When Covid had its highest death rate
SELECT
Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate 
FROM 
dbo.CovidVaccinations
WHERE Location like '%states%' 
ORDER BY 5 DESC

-- Looking at Countries with Highest Infection Rate Compared to Population 
SELECT 
location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected  
FROM 
dbo.CovidVaccinations
GROUP BY 
location, population
ORDER BY 
PercentPopulationInfected DESC 


-- Countries with the Highest Death Count Per Population 
SELECT 
location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
dbo.CovidVaccinations
WHERE 
continent is not null 
GROUP BY 
location
ORDER BY 
TotalDeathCount DESC 

-- Breaking things down by continent 

SELECT 
continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
dbo.CovidVaccinations
WHERE 
continent is not null 
GROUP BY 
continent
ORDER BY 
TotalDeathCount DESC 

-- Showing continents with the highest death count per population 

SELECT 
	continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
	dbo.CovidVaccinations
WHERE 
	continent is not null 
GROUP BY 
	continent
ORDER BY 
	TotalDeathCount DESC 

-- Global Numbers.  Total Cases, Total Deaths, Total Deaths across the world 

SELECT
	-- date 
	SUM(new_cases) as TotalCases
	,SUM(cast(new_deaths as int)) as TotalDeaths
	,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM 
	dbo.CovidVaccinations
WHERE 
	continent is not null 
-- GROUP BY 
	-- date 
ORDER BY 
	1,2

-- New Cases, Total Cases, Total Deaths, Death Percentage (Mortality Rate) 

SELECT
	date 
	,SUM(new_cases) as TotalCases
	,SUM(cast(new_deaths as int)) as TotalDeaths
	,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM 
	dbo.CovidVaccinations
WHERE 
	continent is not null  
GROUP BY 
	date 
ORDER BY 
	1,2

-- Rolling Tally of Vaccinations: Vaccinations Per Day Added to a Cumulative Sum, broken up by country 

SELECT 
	vac.location, 
	vac.date, 
	vac.population, 
	dea.new_vaccinations, 
	SUM(CONVERT(Bigint, dea.new_vaccinations)) OVER (Partition by vac.location ORDER BY vac.location, dea.date) as RollingTallyVaccinations
FROM dbo.CovidVaccinations vac
JOIN dbo.CovidDeaths dea 
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE vac.continent is not null 
ORDER BY 
vac.location, vac.date


-- Percentage of Population Vaccinated
-- Use CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTallyVaccinations) 
as (
SELECT 
	dea.continent,
	vac.location, 
	vac.date, 
	vac.population, 
	dea.new_vaccinations, 
	SUM(CONVERT(Bigint, dea.new_vaccinations)) OVER (Partition by vac.location ORDER BY vac.location, dea.date) as RollingTallyVaccinations
FROM dbo.CovidVaccinations vac
JOIN dbo.CovidDeaths dea 
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE vac.continent is not null 
-- ORDER BY vac.location,vac.date
)
SELECT *,(RollingTallyVaccinations/Population)*100
FROM 
PopvsVac


-- TEMP TABLE 

Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar (255), 
Date datetime,
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent,
	vac.location, 
	vac.date, 
	vac.population, 
	dea.new_vaccinations, 
	SUM(CONVERT(Bigint, dea.new_vaccinations)) OVER (Partition by vac.location ORDER BY vac.location, dea.date) as RollingTallyVaccinations
FROM dbo.CovidVaccinations vac
JOIN dbo.CovidDeaths dea 
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE vac.continent is not null
-- ORDER BY vac.location,vac.date
SELECT *, (RollingPeopleVaccinated/Population)*100 as ProportionVaccinated
FROM 
#PercentPopulationVaccinated

-- Creating view to store for later visualization 

Create View PercentPopulationVaccinated as 
SELECT 
	dea.continent,
	vac.location, 
	vac.date, 
	vac.population, 
	dea.new_vaccinations, 
	SUM(CONVERT(Bigint, dea.new_vaccinations)) OVER (Partition by vac.location ORDER BY vac.location, dea.date) as RollingTallyVaccinations
FROM dbo.CovidVaccinations vac
JOIN dbo.CovidDeaths dea 
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE vac.continent is not null
-- ORDER BY vac.location,vac.date

SELECT *
FROM PercentPopulationVaccinated

