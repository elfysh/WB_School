WITH seller_categories AS (
    SELECT
        seller_id,
        ARRAY_AGG(DISTINCT category ORDER BY category) AS categories,
        SUM(revenue) AS total_revenue
    FROM
        sellers  
    GROUP BY
        seller_id
    HAVING
        COUNT(DISTINCT category) = 2
        AND SUM(revenue) > 75000 AND
        EXTRACT(YEAR FROM min(date_reg)) = 2022
)
SELECT
    seller_id,
    CONCAT(categories[1], ' - ', categories[2]) AS category_pair
FROM
    seller_categories
ORDER BY
    seller_id;