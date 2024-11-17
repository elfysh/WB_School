with more_one_category as(
select seller_id, count(distinct category) as total_categ, round(avg(rating),2) as avg_rating,
sum(revenue) as total_revenue from sellers
where category!='Bedding'
group by seller_id
having count(distinct category)>1
)
select seller_id, total_categ, avg_rating, total_revenue,
case 
	when total_revenue>50000 then 'rich'
	else 'poor'
end as seller_type
from more_one_category
order by seller_id
