use PortfolioProject

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
select location
      ,date
	  ,Cast(total_cases as float) as total_cases
	  ,Cast(total_deaths as float) as total_deaths
	  ,(Cast(total_deaths as float)/Cast(total_cases as float)) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select location
      ,date
	  ,population
	  ,Cast(total_cases as float) as total_cases
	  ,(Cast(total_cases as float)/population) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2



-- Looking at countries with highest infection rate compared to population
select location
	  ,population
	  ,Max(Cast(total_cases as float)) as HighestInfectionCount
	  ,Max((Cast(total_cases as float)/population) * 100) as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentagePopulationInfected desc


-- Showing countries with highest death count per population
select location
	  ,Max(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count
select continent
	  ,Max(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
select Sum(new_cases) as total_cases
	  ,Sum(new_deaths) as total_deaths
	  ,Sum(new_deaths)/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccination
select dea.continent
      ,dea.location
	  ,dea.date
	  ,dea.population
	  ,vac.new_vaccinations
	  ,Sum(Convert(float, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent
      ,dea.location
	  ,dea.date
	  ,dea.population
	  ,Cast(vac.new_vaccinations as int)
	  ,Sum(Convert(float, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *
      ,(RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
	Continent                nvarchar(255),
	Location                 nvarchar(255),
	Date                     datetime,
	Population               numeric,
	New_Vaccinations         numeric,
	RollingPeopleVaccinated  numeric
)


insert into #PercentPopulationVaccinated
select dea.continent
      ,dea.location
	  ,dea.date
	  ,dea.population
	  ,Cast(vac.new_vaccinations as int)
	  ,Sum(Convert(float, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null


select *
      ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualization
create view PercentPopulationVaccinated
as
select dea.continent
      ,dea.location
	  ,dea.date
	  ,dea.population
	  ,Cast(vac.new_vaccinations as int) as new_vaccinations
	  ,Sum(Convert(float, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null


select *
from PercentPopulationVaccinated