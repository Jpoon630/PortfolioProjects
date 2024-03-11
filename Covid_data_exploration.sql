
select *
from CovidDeaths
order by 3,4

-- total cases vs total deaths in NZ

select location, continent,  date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from CovidDeaths
where continent is not null and location like 'New%'
order by 1,2

-- total cases vs population in NZ

select location, continent, date, total_cases, population, (total_cases/population) * 100 as InfectedPopulation
from CovidDeaths
where continent is not null and location like 'New%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as InfectedePopulation
from CovidDeaths
where continent is not null
group by location, population
order by InfectedePopulation desc

-- Countries with Highest Death Count per Population
-- cast because the data type is wrong
select location, max(cast(total_deaths as int)) as HighestDeath 
from CovidDeaths
where continent is not null
group by location
order by HighestDeath desc

-- Contintents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Globally cases

select sum(new_cases) as total_cases_g, sum(cast(new_deaths as int)) as total_deaths_g, (sum(cast(new_deaths as int)) / sum(new_cases)) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2

-- Gloablly cases per day

select date, sum(new_cases) as total_cases_g, sum(cast(new_deaths as int)) as total_deaths_g, (sum(cast(new_deaths as int)) / sum(new_cases)) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- total population vs vaccinations


select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, sum(cast(CovidVaccinations.new_vaccinations as int)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingPeopleVaccinated
from CovidDeaths join CovidVaccinations on CovidDeaths.location = CovidVaccinations.location 
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 2,3

-- with CTE method

with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, sum(cast(CovidVaccinations.new_vaccinations as int)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingPeopleVaccinated
from CovidDeaths join CovidVaccinations on CovidDeaths.location = CovidVaccinations.location 
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population) * 100
from PopvsVac



-- Temp table method

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, sum(cast(CovidVaccinations.new_vaccinations as int)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingPeopleVaccinated
from CovidDeaths join CovidVaccinations on CovidDeaths.location = CovidVaccinations.location 
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated


-- Creating View to store data for later visulations

Create View PercentPopulationVaccinated as
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, sum(cast(CovidVaccinations.new_vaccinations as int)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingPeopleVaccinated
from CovidDeaths join CovidVaccinations on CovidDeaths.location = CovidVaccinations.location 
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
-- order by 2,3

select *
from PercentPopulationVaccinated