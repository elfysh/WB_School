WITH max_order_count AS (
    SELECT 
        COUNT(order_id) AS max_orders
    FROM 
        orders_new
    GROUP BY 
        customer_id
    ORDER BY 
        1 DESC
    LIMIT 1
),
filtered_customers AS (
    SELECT 
        customer_id, 
        round(AVG(EXTRACT(EPOCH FROM (shipment_date - order_date)))/3600, 1) AS average_waiting_time,
        SUM(order_ammount) AS total_price,
        COUNT(order_id) AS order_count
    FROM 
        orders_new
    GROUP BY 
        customer_id
    HAVING 
        COUNT(order_id) = (SELECT max_orders FROM max_order_count)
)
SELECT 
    fc.customer_id, 
    cn.name, 
    fc.average_waiting_time, 
    fc.total_price
FROM 
    filtered_customers fc
LEFT JOIN 
    customers_new cn 
USING (customer_id)
order by total_price DESC