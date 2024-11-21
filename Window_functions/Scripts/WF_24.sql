WITH sales_with_prev_date AS (
    SELECT
        "DATE" AS DATE_,
        "SHOPNUMBER" AS SHOPNUMBER,
        "CATEGORY" AS CATEGORY,
        SUM("QTY"* "PRICE") AS sales_amount,
        LEAD("DATE") OVER (PARTITION BY "SHOPNUMBER", "CATEGORY" ORDER BY "DATE") AS prev_date
    FROM sales
    JOIN goods using("ID_GOOD")
    JOIN shops USING("SHOPNUMBER")
    WHERE shops."CITY" = 'СПб'
    GROUP BY 1,2,3
)
SELECT
    s1.DATE_,
    s1.SHOPNUMBER,
    s1.CATEGORY,
    COALESCE(SUM(s2.sales_amount), 0) AS PREV_SALES
FROM sales_with_prev_date s1
LEFT JOIN sales_with_prev_date s2
    ON s1.SHOPNUMBER = s2.SHOPNUMBER
    AND s1.CATEGORY = s2.CATEGORY
    AND s2.DATE_ = s1.prev_date
GROUP BY s1.DATE_, s1.SHOPNUMBER, s1.CATEGORY
ORDER BY s1.DATE_, s1.SHOPNUMBER, s1.CATEGORY;