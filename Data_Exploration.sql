SELECT *
FROM Portfolio_Project.dbo.Covid_Data_Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM Portfolio_Project.dbo.Covid_Data_Vaccinations
--ORDER BY 3,4

--Select data that we are going to be using

SELECT location,date, total_cases,new_cases,total_deaths,population
FROM Portfolio_Project.dbo.Covid_Data_Deaths
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact in your country 

SELECT location,date, total_cases,total_deaths,(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM Portfolio_Project.dbo.Covid_Data_Deaths
WHERE location LIKE '%states%'
AND  continent IS NOT NULL
ORDER BY 1,2

--looking at Total Cases vs Population
--Shows what % of population got COVID

SELECT location, date, population, total_cases,(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,population),0))*100 AS PercentOFPopulationInfected
FROM Portfolio_Project.dbo.Covid_Data_Deaths
--WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at countries with Highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,MAX(total_deaths/population)*100 AS PercentOFPopulationInfected
FROM Portfolio_Project.dbo.Covid_Data_Deaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentOFPopulationInfected DESC


--Showing the countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project.dbo.Covid_Data_Deaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT 


SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project.dbo.Covid_Data_Deaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Showing continents with the highest death count per population


SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project.dbo.Covid_Data_Deaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage --,total_deaths,(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM Portfolio_Project.dbo.Covid_Data_Deaths
--WHERE location LIKE '%states%'
WHERE continent IS  NULL
GROUP BY date
ORDER BY 1,2


--Looking at total Population vs Vaccination

SELECT DEA.continent,DEA.location,DEA.date, DEA.population,VAC.new_vaccinations,SUM(CAST(VAC.new_vaccinations AS float))OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)* 100
FROM Portfolio_Project..Covid_Data_Deaths DEA
JOIN Portfolio_Project..Covid_Data_Vaccinations VAC
     ON DEA.location=VAC.location
	 AND DEA.date=VAC.date
	 WHERE DEA.continent IS NOT NULL
	 ORDER BY 1,2,3


--USE CTE
WITH popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT DEA.continent,DEA.location,DEA.date, DEA.population,VAC.new_vaccinations,SUM(CAST(VAC.new_vaccinations AS float))OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)* 100
FROM Portfolio_Project..Covid_Data_Deaths DEA
JOIN Portfolio_Project..Covid_Data_Vaccinations VAC
     ON DEA.location=VAC.location
	 AND DEA.date=VAC.date
	 WHERE DEA.continent IS NOT NULL
	-- ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS Percentage
FROM popvsvac



-- TEMP Table
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar (255),
location  nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT DEA.continent,DEA.location,DEA.date, DEA.population,VAC.new_vaccinations,SUM(CAST(VAC.new_vaccinations AS float))OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)* 100
FROM Portfolio_Project..Covid_Data_Deaths DEA
JOIN Portfolio_Project..Covid_Data_Vaccinations VAC
     ON DEA.location=VAC.location
	 AND DEA.date=VAC.date
	 WHERE DEA.continent IS NOT NULL
	-- ORDER BY 2,3
	

SELECT *,(RollingPeopleVaccinated/population)*100 AS Percentage
FROM #PercentagePopulationVaccinated



--Creating view to store data for later visualizations

CREATE VIEW PercentagePopulationVaccinated
AS
SELECT DEA.continent,DEA.location,DEA.date, DEA.population,VAC.new_vaccinations,SUM(CAST(VAC.new_vaccinations AS float))OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)* 100
FROM Portfolio_Project..Covid_Data_Deaths DEA
JOIN Portfolio_Project..Covid_Data_Vaccinations VAC
     ON DEA.location=VAC.location
	 AND DEA.date=VAC.date
	 WHERE DEA.continent IS NOT NULL
	-- ORDER BY 2,3

SELECT *
FROM PercentagePopulationVaccinated


