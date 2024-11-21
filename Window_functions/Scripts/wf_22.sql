with df as (select "DATE" as "DATE_", "CITY", "ID_GOOD", "PRICE"*"QTY" as total_sum
from sales 
right join (select * from goods
where "CATEGORY"='ЧИСТОТА') using("ID_GOOD")
left join shops using("SHOPNUMBER"))
select  distinct "DATE_", "CITY", 
round((sum(total_sum) over (partition by "CITY", "DATE_"))::DECIMAL/
(sum(total_sum) over (partition by "DATE_" order by "DATE_")),2) as "SUM_SALES_REL" from df