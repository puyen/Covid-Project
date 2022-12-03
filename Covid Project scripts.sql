
select *, STR_TO_DATE(date, '%m/%d/%Y') as dateofrecord
from coviddeaths
where continent not like ''
order by location, dateofrecord;

select *, STR_TO_DATE(date, '%m/%d/%Y') as dateofrecord
from covidvaccinations
where continent not like ''
order by location, dateofrecord;

select location, STR_TO_DATE(date, '%m/%d/%Y') as dateofrecord, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent not like ''
order by 1,2;

select location, STR_TO_DATE(date, '%m/%d/%Y') as dateofrecord, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from coviddeaths
#where location like 'Vietnam'
where continent not like ''
order by 1,2;

select location, STR_TO_DATE(date, '%m/%d/%Y') as dateofrecord, total_cases, population, (total_cases/population) *100 as InfectionPercentage
from coviddeaths
#where continent like 'Vietnam'
where continent not like ''
order by 1,2;

#Looking at country with highest Infection Rate compare to population

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as InfectionPercentage
from coviddeaths
#where location like 'Vietnam'
where continent not like ''
group by location, population
order by 1,2;

#Showing Countries with Highest Death Count per Population

select location, max(cast(total_deaths as decimal)) as TotalDeathCount
from coviddeaths
#where location like 'Vietnam'
where continent not like ''
group by location
order by TotalDeathCount desc;

#BREAK THINGS DOWN BY CONTINENT

#Showing continents with the highest death count per population

select continent, max(cast(total_deaths as decimal)) as TotalDeathCount
from coviddeaths
#where location like 'Vietnam'
where continent not like ''
group by continent
order by TotalDeathCount desc;

#GLOBAL NUMBERS
 
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from coviddeaths
#where location like 'Vietnam'
where continent not like ''
#group by dateofrecord
order by 1,2;

#Looking at Total Population vs Vaccinations

select dea.continent, dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y') as date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y')) 
as RollingPeopleVaccinated#, (RollingPeopleVaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
order by 2,3;


#USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y') as date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y')) 
as RollingPeopleVaccinated#, (RollingPeopleVaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac
order by 2,3;

#Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y') as date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y')) 
as RollingPeopleVaccinated#, (RollingPeopleVaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != '';

select * 
from percentpopulationvaccinated;
