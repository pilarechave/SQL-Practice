SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1, 2

SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is null
ORDER BY 1, 2

--Select data to use

SELECT location, date,total_cases,new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1, 2

--BY LOCATION

--Look at total cases vs total deaths 

SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as death_percentage
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1, 2

SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as death_percentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%Argentina%'
ORDER BY 1, 2

--Look at total cases vs population

SELECT location, date, total_cases, population, round((total_cases/population)*100,3) as percentage_with_covid
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%Argentina%'
ORDER BY 1, 2

--Look at countries with highest inefction rate compared to population

SELECT location, max(total_cases) as highest_infection_count, population, 
	round(max(total_cases/population)*100,2) as percentage_with_covid
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC

--Show countries with highest death count compared to population

SELECT location, max(total_deaths) as total_death_count
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC

--BY CONTINENT

--Look at total cases vs total deaths 

SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as death_percentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is null
ORDER BY 1, 2

--Look at countries with highest inefction rate compared to population

SELECT location, max(total_cases) as highest_infection_count, population, 
	round(max(total_cases/population)*100,2) as percentage_with_covid
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is null
GROUP BY location, population
ORDER BY 4 DESC

SELECT continent, location
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent = 'European Union'

SELECT continent, location
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent = 'Europe'

--Show continents with highest death count

SELECT location, max(total_deaths) as total_death_count
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY total_death_count DESC


--GLOBAL NUMBERS

--Look at total cases vs total deaths 

SELECT date, sum(new_cases) as total_global_cases, sum(new_deaths) as total_global_deaths, 
	round((sum(new_deaths)/sum(new_cases))*100,2) as death_percentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1, 4

SELECT sum(new_cases) as total_global_cases, sum(new_deaths) as total_global_deaths, 
	round((sum(new_deaths)/sum(new_cases))*100,2) as death_percentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1

-- Total population vs vaccinations with rolling count

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date)
	AS rolling_vaccinated_count, (rolling_vaccinated_count/population)*100
FROM PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--CTE (for %)

WITH PopVsVac (continent, location, date, population,new_vaccinations, rolling_vaccinated_count)
AS 
	(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date)
		AS rolling_vaccinated_count
	FROM PortfolioProject.dbo.CovidDeaths$ dea
	JOIN PortfolioProject.dbo.CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	)

SELECT *, round((rolling_vaccinated_count/population)*100,2)
FROM PopVsVac

--Temp table (for %)

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_vaccinated_count numeric
	)

INSERT INTO PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date)
		AS rolling_vaccinated_count
	FROM PortfolioProject.dbo.CovidDeaths$ dea
	JOIN PortfolioProject.dbo.CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date	

SELECT *, round((rolling_vaccinated_count/population)*100,2)
FROM PercentPopulationVaccinated

--View of continents with total death count

CREATE VIEW PopulationVaccinated  AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date)
		AS rolling_vaccinated_count
	FROM PortfolioProject.dbo.CovidDeaths$ dea
	JOIN PortfolioProject.dbo.CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date	
	WHERE dea.continent IS NOT NULL

SELECT * FROM PopulationVaccinated