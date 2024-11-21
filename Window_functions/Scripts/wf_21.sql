select distinct "SHOPNUMBER" , "CITY" , "ADDRESS",
SUM("QTY") over (partition by "SHOPNUMBER") as SUM_QTY,
SUM("PRICE") over (partition by "SHOPNUMBER") as SUM_QTY_PRICE
from (select "SHOPNUMBER" , "ID_GOOD",  "QTY"
from sales where "DATE"='2016-01-02')
left join shops using("SHOPNUMBER")
left join goods using("ID_GOOD")