with max_salary_by_industry as (
select concat(first_name,' ', last_name) as name_ighest_sal, salary, industry
from salary
where (salary, industry) in (select max("salary") as max_salary,
industry from salary s
group by industry))
select first_name, last_name, salary.salary, industry, name_ighest_sal from
salary left join max_salary_by_industry using(industry)
