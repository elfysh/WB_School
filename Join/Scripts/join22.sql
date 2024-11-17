select product_id, product_category, sum(order_ammount) as total_price from orders o 
left join products p 
using(product_id)
group by 1,2
order by 3 desc
limit 1