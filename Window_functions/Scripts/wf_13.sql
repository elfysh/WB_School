select first_name, last_name, salary, industry,
first_value(first_name || ' ' || last_name) over (partition by industry order by salary DESC) 
as name_ighest_sal
from salary