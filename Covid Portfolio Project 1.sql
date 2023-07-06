---Total Death vs Total Deaths
---Shows the likelihood of Death if you contract covid in your country


select location, date, total_cases, total_deaths, (cast(total_deaths as numeric))/ cast(total_cases as numeric) * 100 as 
DeathPercentage 
from PortfolioProject..CovidDeath
where location like '%united%'
order by 1,2

--- Looking Total case vs population

---This shows what percentage of population Got covid in Ethiopia

select location, date, total_cases, population, (cast(total_cases as numeric))/ cast(population as numeric) * 100 as 
DeathPercentage 
from PortfolioProject..CovidDeath
where location like '%Ethiopia%'
order by 1,2

---Looking with highest infection rate compared to population

select location,population, MAX(total_cases) as HighestInfectionCount,  
MAX((cast(total_cases as numeric))/ cast(population as numeric)) * 100 as 
PercentPopulationInfected 
from PortfolioProject..CovidDeath
Group by population, location
order by PercentPopulationInfected DESC

--- The countries with highest death count per population

select location,MAX(cast(total_deaths as int))  as HighestDeathCount 
from PortfolioProject..CovidDeath
where continent is not Null
Group by location
order by HighestDeathCount DESC


select location,population, MAX(total_deaths) as HighestDeathCount,  
MAX((cast(total_deaths as numeric))/ cast(population as numeric)) * 100 as 
PercentDeadPopulation 
from PortfolioProject..CovidDeath
Group by population, location
order by PercentDeadPopulation DESC

---break things down by continent

select continent,MAX(cast(total_deaths as int))  as HighestDeathCount 
from PortfolioProject..CovidDeath
where continent is Not Null
Group by continent
order by HighestDeathCount DESC

--- Showing the continents with the highest death count per population

select continent,MAX(cast(total_deaths as int))  as TotalDeathCount 
from PortfolioProject..CovidDeath
where continent is Not Null
Group by continent
order by TotalDeathCount DESC


---Global Numbers

select date, Sum(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths-- SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 
--as DeathPercentage
from PortfolioProject..CovidDeath

where continent is not Null
Group by date
order by 1,2

---trial_1

Set ARITHABORT off;
set ANSI_WARNINGS off;
select date, Sum(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as numeric))/SUM(cast(new_cases as numeric))*100 
as DeathPercentage
from PortfolioProject..CovidDeath

where continent is not Null
Group by date
order by 1,2


select  Sum(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as numeric))/SUM(cast(new_cases as numeric))*100 
as DeathPercentage
from PortfolioProject..CovidDeath

where continent is not Null
order by 1,2

---Looking total population vs vaccination
select dea.continent, dea.date, dea.population, vac.new_vaccinations 
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and
dea.date = vac.date
where dea.continent is not null
order by 1,2,3


select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int , vac.new_vaccinations)) 
Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and
dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Use CTE

with PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int , vac.new_vaccinations)) 
Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and
dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccperPop from PopVsVac


--Temp table

create table #PercentPopulationVaccinated
(Continent nvarchar(255), location nvarchar(255), date datetime, 
population numeric, New_vaccinations numeric,RollingPeopleVaccinated numeric)


Insert into #PercentPopulationVaccinated
select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int , vac.new_vaccinations)) 
Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and
dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccperPop from #PercentPopulationVaccinated



---Creating view to store data fro later visualizations

create view PercentagePopulationVacc as
select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int , vac.new_vaccinations)) 
Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and
dea.date = vac.date
where dea.continent is not null

Select * from PercentagePopulationVacc
