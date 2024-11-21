with min_salary_by_industry as (
select concat(first_name,' ', last_name) as name_iglest_sal, salary, industry
from salary
where (salary, industry) in (select min("salary") as min_salary,
industry from salary s
group by industry))
select first_name, last_name, salary.salary, industry, name_iglest_sal from
salary left join min_salary_by_industry using(industry)
