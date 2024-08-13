select * 
from PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4 

--select * 
--from PortfolioProject..CovidVaccinations 
--order by 3,4 

--Select Data that we are going to be using


select	location, date,  total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2 


--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select	location, date,  total_cases, total_deaths, (total_deaths/nullif(total_cases,0))* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Algeria%'
order by 1,2 


--Looking at total cases vs Population
--Shows what percentage of population got covid
select	location, date, population, total_cases, (total_cases/nullif(population,0))* 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Algeria%'
order by 1,2 


-- Looking at countries wwith highest infection rate compared to population
select	location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/nullif(population,0)))* 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Algeria%'
Group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
select	location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Algeria%'
where continent is not null
Group by location
order by TotalDeathCount desc


--let's break things down by continent

select	location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Algeria%'
where continent is null
Group by location
order by TotalDeathCount desc


--Showing continents with the highest death count per population

select	continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Algeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc




--Global Numbers

select	 sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths,sum(new_deaths)/sum(nullif(new_cases,0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%Algeria%'
where continent is not null
--group by date
order by 1,2 


--Looking at total Population vs Vaccinations

select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as  RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
order by 2,3


---USE cte

With PopvsVac (Continent,location,date, population,new_vaccinations ,RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as  RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac




--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as  RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as  RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null



select * from PercentPopulationVaccinated