with task_1 as (select product_category, sum(order_ammount) as total_price from orders o 
left join products p 
using(product_id)
group by 1
order by 2 desc),
task_2 as (select product_id, product_category, sum(order_ammount) as total_price from orders o 
left join products p 
using(product_id)
group by 1,2
order by 3 desc
limit 1),
products_sales as (select product_id,product_name, product_category, sum(order_ammount) as total_price from orders o 
left join products p 
using(product_id)
group by product_id, product_name, product_category
order by 4 desc),
task_3 as (
select product_name, product_category, total_price from products_sales
where (product_category, total_price) in (select product_category, 
max(total_price) from products_sales group by 1)
)
select * from task_1


