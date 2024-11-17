with products_sales as (select product_id,product_name, product_category, sum(order_ammount) as total_price from orders o 
left join products p 
using(product_id)
group by product_id, product_name, product_category
order by 4 desc)
select product_name, product_category, total_price from products_sales
where (product_category, total_price) in (select product_category, 
max(total_price) from products_sales group by 1)
