/* Covid Data Exploration
Commands used: joins, CTE, Temp table, Aggregate function, views
*/

--select data 
select * from PortfolioProjects..CovidDeaths
order by 3,4

select * from CovidVaccinations
order by 3,4
Go

--select Data we want to use
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2

--Get total cases vs Total  Cases (shows Death percentage)
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercent
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2

--Get Total cases vs Population (shows Covid infection percentage)
select location,date,total_cases,population,(total_cases/population)*100 as InfectedPopulationPercentage
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2

--Get countries with highest infection rate compared to population
select location,population,MAX(total_cases) as HighestInfectedCount,MAX((total_cases/population))*100 as InfectedPopulationPercentage
from CovidDeaths
where continent is not null
group by location,population
order by InfectedPopulationPercentage desc

--Get coutries with highest death count per population
select location,max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Get continent with highest death count per population
select continent,sum(new_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Data

--Get death percentage across world
select SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null

--Get totalpopulation vs vaccinations for each date (shows vaccinated population)
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

--Get totalpopulation vs vaccinations and total vaccination for each date
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(CONVERT(float,cv.new_vaccinations)) 
over (partition by cd.location order by cd.location,cd.date) as RollingPeoplevaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

--Get RollingPeoplevaccinated percentage using CTE (shows vaccinated population percentage)
with populationVsVaccination (continent,location,date,population,new_vaccinations,RollingPeoplevaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(CONVERT(float,cv.new_vaccinations)) 
over (partition by cd.location order by cd.location,cd.date) as RollingPeoplevaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
)
select *,(RollingPeoplevaccinated/population)*100 As VaccinationPercentage
from populationVsVaccination 
order by 2,3


--Get RollingPeoplevaccinated percentage using TEMP table (shows vaccinated population percentage)
create table #PopulationVaccinatedPercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)

insert into #PopulationVaccinatedPercentage
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(CONVERT(float,cv.new_vaccinations)) 
over (partition by cd.location order by cd.location,cd.date) as RollingPeoplevaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null

select *,(RollingPeoplevaccinated/population)*100 As VaccinationPercentage
from #PopulationVaccinatedPercentage 
order by 2,3

--Views to store data for visualizations

--view for PopulationVaccinated
create view PopulationVaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(CONVERT(float,cv.new_vaccinations)) 
over (partition by cd.location order by cd.location,cd.date) as RollingPeoplevaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null


select * from PopulationVaccinated order by 2,3

--view for DeathPercentage
create view DeathPercentage as 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercent
from PortfolioProjects..CovidDeaths
where continent is not null

select * from DeathPercentage order by 1,2
