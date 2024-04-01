SELECT *
FROM `coviddeaths`
WHERE continent is not null
order by 3,4

-- SELECT *
-- FROM `covidvaccination`
-- order by 3,4


SELECT location ,date, total_cases, new_cases, total_deaths, population
FROM `coviddeaths`
WHERE continent is not null
ORDER BY 1,2;


SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM `coviddeaths`
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2;


SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM `coviddeaths`
-- WHERE location like '%states%' AND continent is not null
ORDER BY 1,2;


SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM `coviddeaths`
-- WHERE location like '%states%' AND continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM `coviddeaths`
-- WHERE location LIKE '%states%' 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM `coviddeaths`
-- WHERE location LIKE '%states%' 
WHERE location is not null
ORDER BY TotalDeathCount DESC;


SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM `coviddeaths`
-- WHERE location LIKE '%states%' 
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


SELECT date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths as UNSIGNED)) as total_deaths, SUM(CAST(new_deaths as UNSIGNED))/SUM(new_cases) *100 as DeathPercentage
FROM `coviddeaths`
-- WHERE location like '%states%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2;


USE `covid project`;

WITH PopvsVac(Continent, Location, date, Population, New_vaccinations, RollingPeopleVaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(vac.new_vaccinations) OVER (
            PARTITION BY dea.location 
            ORDER BY dea.location, dea.date
        ) AS RollingPeopleVaccinated
    FROM `coviddeaths` AS dea
    JOIN `covidvaccination` AS vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    -- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinationPercentage
FROM PopvsVac;


DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    Continent nvarchar(225),
    Location nvarchar(225),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
);


INSERT INTO PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT 
    dea.continent, 
    dea.location, 
    STR_TO_DATE(dea.date, '%m/%d/%y'), -- Convert 'M/D/YY' format to datetime
    dea.population, 
    COALESCE(NULLIF(vac.new_vaccinations, ''), 0), 
    SUM(COALESCE(NULLIF(vac.new_vaccinations, ''), 0)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, STR_TO_DATE(dea.date, '%m/%d/%y')
    ) AS RollingPeopleVaccinated
FROM `coviddeaths` AS dea
JOIN `covidvaccination` AS vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


CREATE VIEW PercentPopulationVaccinated as 
SELECT 
    dea.continent, 
    dea.location, 
    STR_TO_DATE(dea.date, '%m/%d/%y'), -- Convert 'M/D/YY' format to datetime
    dea.population, 
    COALESCE(NULLIF(vac.new_vaccinations, ''), 0), 
    SUM(COALESCE(NULLIF(vac.new_vaccinations, ''), 0)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, STR_TO_DATE(dea.date, '%m/%d/%y')
    ) AS RollingPeopleVaccinated
FROM `coviddeaths` AS dea
JOIN `covidvaccination` AS vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


SELECT *
FROM PercentPopulationVaccinated


