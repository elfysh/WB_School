SELECT 
    distinct customer_id, 
    name
FROM 
customers_new
RIGHT JOIN 
(SELECT customer_id FROM orders_new
WHERE EXTRACT(EPOCH FROM (shipment_date - order_date)) = (
SELECT MAX(EXTRACT(EPOCH FROM (shipment_date - order_date))) 
FROM orders_new))
USING (customer_id)