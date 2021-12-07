Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percent of the population got COVID
Select Location, date, Population, total_cases, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
--where location like '%states%'
order by 1,2


--Looking at Countries with the Highest Infection Rate Compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasePercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
--where location like '%states%'
Group by Location, Population
order by CasePercentage desc

-- BREAKING THINGS DOWN BY CONTINENT


--Showing Countries with the Highest Death Count per Population

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE



DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated
