--будем считать неуспешными тех, которые не являются rich
with unsuccess as(
select seller_id,
(current_date-min(date_reg))/30 as month_from_registration,
min(delivery_days) as min_dd,
max(delivery_days) as max_dd
from sellers
where category!='Bedding'
group by seller_id
having not(count(distinct category)>1 and sum(revenue)>50000)
)
select seller_id,
month_from_registration,
(select max(max_dd) from unsuccess)-(select min(min_dd) from unsuccess) as max_delivery_difference
from unsuccess
order by seller_id