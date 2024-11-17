select product_category, sum(order_ammount) as total_price from orders o 
left join products p 
using(product_id)
group by 1
order by 2 desc

