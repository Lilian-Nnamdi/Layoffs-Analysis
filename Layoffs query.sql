-----------------------------------Examine the data-------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
select * from layoffs
select distinct company from layoffs  --1599 rows
select distinct country from layoffs  --51 rows
select distinct industry from layoffs  --30 rows
select distinct stage from layoffs   --17 rows
select sum(total_laid_off) from layoffs  --381448
select min(date) as min_date, max(date) as max_date from layoffs


-- check for null data in the total_laid_off column and percentage_laid off column and date column
select * from layoffs 
where total_laid_off is null and percentage_laid_off is null
-- There are 352 rows of data that fall under this category
-- There is no information of how many people were laid off in this category, 
-- so for the purpose of this analysis, these rows will be excluded
select * from layoffs where date is null


-- check for duplicates
SELECT * FROM layoffs 
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised 
HAVING COUNT(*) > 1


-- we have one duplicate value, let's delete it
SELECT DISTINCT * INTO duplicate_table FROM layoffs
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised
HAVING COUNT(*) > 1
SELECT * FROM layoffs where company = 'Cazoo'  -- only 2 records
DELETE layoffs WHERE company IN 
(
SELECT company FROM duplicate_table
)
INSERT layoffs SELECT * FROM duplicate_table
DROP TABLE duplicate_table

------------------------------------------------------------------------------------------------------------------

-------------------------------------Data Analysis-----------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

-- Number of people laid off per year
With year_vs_layoff (year_layoff, total_laid_off) as
(
select year(date) as year_layoff, total_laid_off from layoffs
)
select year_layoff, sum(total_laid_off) as number_laid_off from year_vs_layoff 
group by year_layoff 
order by 1


--Number of people laid off per month each year
With monthyear_vs_layoff (industry, year_layoff, month_layoff, total_laid_off) as
(
select industry, year(date) as year_layoff, DATENAME(month,date) as month_layoff, total_laid_off 
from layoffs where total_laid_off is not null
)
select industry, year_layoff, month_layoff, sum(total_laid_off) as number_laid_off from monthyear_vs_layoff 
group by industry, year_layoff, month_layoff 
order by 1


-- Countries with the most layoffs
-- United States has the highest number of layoffs
-- India has the second highest while Netherlands has the third highest number
select country, sum(total_laid_off) as number_laid_off from layoffs
where total_laid_off is not null
group by country 
order by 2 desc


--Top 11 most affected companies in United States
--Amazon has the highest number of layoff, followed by
--Google, Meta, Salesforce, Microsoft, Uber, Dell, Cisco, Peloton, Carvana, Twitter in that order amidst others
select company, sum(total_laid_off) as number_laid_off from layoffs
where total_laid_off is not null and country = 'United States'
group by company
order by 2 desc

--Top 5 most affected companies in India
--Byju's has the highest number of layoff, followed by
--Swiggy, Ola, WhiteHat Jr, Bytedance in that order amidst others
select company, sum(total_laid_off) as number_laid_off from layoffs
where total_laid_off is not null and country = 'India'
group by company
order by 2 desc


--Companies with the most layoffs
-- Amazon has the highest number of layoffs
-- Google and Meta have the second and third highest number respectively
select company, country, industry, sum(total_laid_off) as number_laid_off from
(
select Company, country, industry, total_laid_off from layoffs
where total_laid_off is not null
) A
group by company, country, industry
order by 4 desc



--Top 20 countries and the top 3 companies with the highest layoffs in the country
-- Amazon, Google, Meta have the highest layoffs in the United States
-- Philips, Booking.com has the highest layoffs in Netherlands
-- Ericsson has the highest layoffs in Sweden
--Byju's, Swiggy, Ola has the highest layoffs in India
create view agg_layoffs as
select country, company, industry, sum(total_laid_off) as number_laid_off from layoffs 
where total_laid_off is not null
group by country, company, industry 

select * from
(
  select country, company, number_laid_off,
    row_number() over(Partition by country order by number_laid_off desc) rn
  from agg_layoffs
) src
where rn in (1) order by 3 desc



--Industry with the most layoffs
-- Consumer, Retail, Other, Transportation Industry have the highest layoffs respectively
select industry, sum(total_laid_off) as number_laid_off from layoffs
where total_laid_off is not null
group by industry 
order by 2 desc



--Top 3 companies in the top 10 Industry with the highest layoffs
-- Amazon in the Retail industry leads this list expectedly, it is closely followed by
-- Google, Meta in the Consumer Industry as expected still
-- Then, we have SalesForce in the Sales Industry and Microsoft in Other Industry and Philips in Healthcare
select * from
(
  select industry, company, number_laid_off,
    row_number() over(Partition by industry order by number_laid_off desc) rn
  from agg_layoffs
) src
where rn in (1) order by 3 desc



-- Layoff over time for Industries (top 10 highest layoffs)
create view agg_indu_layoffs as
With indu_layoff (industry, year_layoff, total_laid_off) as
(
select industry, year(date) as year_layoff, total_laid_off from layoffs
where total_laid_off is not null
)
select industry, year_layoff, sum(total_laid_off) as number_laid_off from indu_layoff 
group by industry, year_layoff

select * from
(
  select industry, year_layoff, number_laid_off,
    row_number() over(Partition by year_layoff order by number_laid_off desc) rn
  from agg_indu_layoffs
) src
where rn in (1,2,3,4,5,6,7,8,9,10) order by 3 desc



--Country, Company, stage of funding, funds raised and number of layoffs
select country, Company, stage, sum(funds_raised) as funds_raised, sum(total_laid_off) as number_laid_off from layoffs
where total_laid_off is not null
group by country, company, stage
order by 5 desc



--Country, Location with the most layoffs
-- The top 3 locations with the highest layoffs are in the United States
-- They are SF Bay Area, Seattle and New York City
-- Bengaluru in India is the 4th largest location with the highest location and the largest in India
select top 15 location, company, sum(total_laid_off) as number_laid_off from layoffs
where total_laid_off is not null
group by location, company 
order by 3 desc











