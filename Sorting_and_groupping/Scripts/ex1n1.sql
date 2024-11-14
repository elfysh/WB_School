select city,
case
	when age>0 and age<21 then 'young'
	when age between 21 and 49 then 'adult'
	when age between 50 and 112 then 'old'
	else 'undefined' 
end as "category",
count(*) as "quantity"
from users
group by 1, 2
order by 3 desc, 1

