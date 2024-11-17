SELECT 
    cn.customer_id,
    cn.name,
    COUNT(CASE WHEN shipment_date - order_date > '5 days' THEN 1 END) AS delayed_orders_count,
    COUNT(CASE WHEN order_status = 'Cancel' THEN 1 END) AS canceled_orders_count,
    SUM(o.order_ammount) AS total_order_amount
FROM 
    customers_new cn
LEFT JOIN 
    orders_new o 
USING(customer_id)
GROUP BY 
    cn.customer_id, cn.name
HAVING 
    COUNT(CASE WHEN shipment_date - order_date > '5 days' THEN 1 END) > 0 
    OR COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) > 0
ORDER BY 
    total_order_amount DESC