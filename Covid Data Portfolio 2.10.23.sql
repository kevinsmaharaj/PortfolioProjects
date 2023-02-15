

SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select Data

SELECT Location, date, total_cases, New_cases, total_deaths, population
FROM CovidDeaths
order by 1,2

-- Look at Total Cases vs Total Deaths
-- Shows fatality rate if contracted
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
Where location like '%trinidad%'
order by 1,2

-- Look at Total Cases vs Population
-- Shows percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
FROM CovidDeaths
Where location like '%trinidad%'
order by 1,2

-- Look at countries with highest infection rate compared to population

SELECT Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectionPercentage
FROM CovidDeaths
group by location, population
order by InfectionPercentage desc

-- Show countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM CovidDeaths
Where continent is not null
group by location
order by TotalDeathsCount desc

-- Show continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM CovidDeaths
Where continent is not null 
group by continent
order by TotalDeathsCount desc

-- Global Figures

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
FROM CovidDeaths
where continent is not null
order by 1,2

-- Look at total population vs vaccincations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Create View to store data for later visuals

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
