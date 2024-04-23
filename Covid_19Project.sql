  select *
from ['CovidDeaths 2$']
where continent is not null
order by 1,3;

select  location, date, total_cases_per_million, new_cases, total_deaths, population
from ['CovidDeaths 2$']
Order by 1,2;

--SHOW THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
--TOTAL CASES VS TOTAL DEATHS
create view TotalCasesAndDeaths as
select location, date, total_cases_per_million,total_deaths
from ['CovidDeaths 2$']
--order by 1,2;

--b.
create view CasesVsDeathProportion as
select location, date, total_cases_per_million,total_deaths, (total_deaths / total_cases_per_million) * 100 as DeathPercentage
from ['CovidDeaths 2$']
where location = 'United States'
and continent is not null
--order by 1,2;


--SHOWS POPULATION THAT CAUGHT COVID
--Total cases Vs Population
create view TotalCovidCasesByLocation as
select location, date, total_cases_per_million,population, (total_cases_per_million/ population) * 100 as Covid_population
from ['CovidDeaths 2$']
where location = 'Canada'
and continent is not null
--order by 1,2

--Countries with the highest Covid Infection rate Vs Population
create view CountriesWithHighestInfectionRate as
select location, population, max([total_cases_per_million]) as HighestPopulationCount, max([total_cases_per_million]/population) * 100 as Highest_Infected_Population
from ['CovidDeaths 2$']
where continent is not null
group by location,population
--Order by Highest_Infected_Population desc;


--COUNTRIES/CONTINENT WITH THE HIGHEST DEATH COUNT Vs Population
create view HighestDeathCountbyCountries as
select location,MAX(cast(total_deaths as int)) as TotalPopulationDeaths
 from ['CovidDeaths 2$']
 where continent is not null
 group by location
 --order by TotalPopulationDeaths desc;

 --BY CONTINENT
 Create view HighestInfectionByContinent as
 select continent,max(cast(total_deaths as int)) as TotalPopulationDeaths
 from ['CovidDeaths 2$']
 where continent is not null
 group by continent
 --order by TotalPopulationDeaths desc;

--Global Numbers
create view GlobalNumber as
 select  sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths, sum(new_cases)/ sum(cast(new_deaths as int)) * 100 as TotalDeathsPercentage
 from ['CovidDeaths 2$']
 Where CONTINENT IS NOT NULL
--order by TotalDeathsPercentage

--B.
 select date,sum(total_cases_per_million) as Total_cases,sum(cast(total_deaths as int)) as Total_deaths, sum(total_cases_per_million)/ sum(cast(total_deaths as int)) * 100 as TotalDeathsPercentage
 from ['CovidDeaths 2$']
 --where Total_cases_per_million is not null
 Where CONTINENT IS NOT NULL
 group by date
 order by 1,4


 --Totalpop vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
 from ['CovidDeaths 2$'] dea
 join CovidVaccinations$ vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
order by 1,2
 
 --CTE
 --With Population vs Vaccination
 With PopulationVacc (continent,location, date,population,new_vaccinations,Rollingpeoplevaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
 from ['CovidDeaths 2$'] dea
 join CovidVaccinations$ vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null 
)

select *,RollingPeopleVaccinated/population *100
from PopulationVacc

--With TempTable 
create Table PercentageRollingPeopleVaccinated 
(
Continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Rollingpeoplevaccinated numeric
)

insert into PercentageRollingpeoplevaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
 from ['CovidDeaths 2$'] dea
 join CovidVaccinations$ vac
		on dea.location = vac.location
		and dea.date = vac.date

select *,RollingPeopleVaccinated/population *100
from PercentageRollingpeoplevaccinated

create view PercentageOfPeopleVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
 from ['CovidDeaths 2$'] dea
 join CovidVaccinations$ vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null 