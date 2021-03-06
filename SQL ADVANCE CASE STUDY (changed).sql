SELECT TOP 1* FROM FACT_TRANSACTIONS
SELECT TOP 1* FROM DIM_DATE
SELECT TOP 1* FROM DIM_CUSTOMER
SELECT TOP 1* FROM DIM_LOCATION
SELECT TOP 1* FROM DIM_MODEL
SELECT TOP 1* FROM DIM_MANUFACTURER

-- Q1- List all the states in which we have customers who have bought cellphones from 2005 till today
SELECT DISTINCT STATE
FROM(SELECT 
STATE,DATE
FROM 
FACT_TRANSACTIONS T1
INNER JOIN DIM_LOCATION T2 ON T1.IDLOCATION=T2.IDLOCATION
WHERE DATENAME(YEAR,DATE) BETWEEN 2005 AND GETDATE())TT

--Q2- What state in the US is buying more 'Samsung' cellphones?
SELECT
STATE, SUM(Quantity) AS CNT_OF_CELLPHONES
FROM 
DIM_MODEL T1
RIGHT JOIN DIM_MANUFACTURER T2 ON T1.IDManufacturer=T2.IDManufacturer
INNER JOIN FACT_TRANSACTIONS T3 ON T1.IDMODEL=T3.IDMODEL
INNER JOIN DIM_LOCATION T4 ON T3.IDLocation=T4.IDLocation
WHERE Manufacturer_Name='SAMSUNG' AND COUNTRY='US'
GROUP BY STATE
ORDER BY SUM(QUANTITY) DESC

--Q3- Show the no of transactions for each model per zip code per state
SELECT 
T1.IDMODEL,MODEL_NAME,T3.IDLOCATION,ZIPCODE,COUNTRY,STATE,COUNT(T1.IDModel) AS NO_OF_TRANSACTIONS
FROM 
DIM_MODEL T1
INNER JOIN FACT_TRANSACTIONS T2 ON T1.IDMODEL=T2.IDMODEL
LEFT JOIN DIM_LOCATION T3 ON T2.IDLocation=T3.IDLocation
GROUP BY
T1.IDMODEL,MODEL_NAME,T3.IDLOCATION,ZIPCODE,COUNTRY,STATE

--Q4- Show the cheapest cellphone 
 SELECT 
 IDMODEL,MODEL_NAME,UNIT_PRICE
 FROM DIM_MODEL
 WHERE UNIT_PRICE= (SELECT MIN(Unit_price)
 FROM DIM_MODEL)
 
 --Q5-Find out the average price for each model in the top 5 manufacturers in terms of sales quantity and 
 --order by average price

SELECT Manufacturer_Name,AVG(UNIT_PRICE) AS AVG_PRICE_PER_MODEL
FROM
(SELECT TOP 5 *
FROM
(SELECT TOP 6 *
FROM
(SELECT T3.IDMANUFACTURER,MANUFACTURER_NAME,SUM(Quantity) AS TOTAL_QUANTITY
FROM 
FACT_TRANSACTIONS T1
LEFT JOIN DIM_MODEL T2 ON T1.IDMODEL=T2.IDMODEL
LEFT JOIN DIM_MANUFACTURER T3 ON T2.IDManufacturer=T3.IDManufacturer
GROUP BY
Manufacturer_Name,T3.IDMANUFACTURER)TT
ORDER BY TOTAL_QUANTITY DESC)TT)TT
LEFT JOIN DIM_MODEL T2 ON T2.IDManufacturer=TT.IDMANUFACTURER
GROUP BY Manufacturer_Name
ORDER BY AVG(Unit_price)

-- Q6- List the names of the customers and the average amount spent in 2009,where the average is higher than 500

SELECT T1.IDCUSTOMER,Customer_Name,AVG(TOTALPRICE) AS AVG_AMOUNT_SPENT
FROM FACT_TRANSACTIONS T1
LEFT JOIN DIM_CUSTOMER T2 ON T1.IDCUSTOMER=T2.IDCUSTOMER
WHERE DATENAME(YEAR,DATE)=2009
GROUP BY 
T1.IDCUSTOMER,Customer_Name
HAVING AVG(TOTALPRICE)>500

--Q7- List if there is any model that was in the top 5 in terms of quantity,simultaneously in 2008,2009, and 2010.


SELECT *
FROM
(SELECT TOP 5 T1.IDMODEL,MODEL_NAME,SUM(QUANTITY) AS TOTAL_QUANTITY
FROM FACT_TRANSACTIONS T1
LEFT JOIN DIM_MODEL T2 ON T1.IDMODEL=T2.IDMODEL
WHERE DATENAME(YEAR,DATE)=2008
GROUP BY T1.IDMODEL,MODEL_NAME
ORDER BY TOTAL_QUANTITY DESC)TT
INTERSECT
SELECT *
FROM
(SELECT TOP 5 T1.IDMODEL,MODEL_NAME,SUM(QUANTITY) AS TOTAL_QUANTITY
FROM 
FACT_TRANSACTIONS T1
LEFT JOIN DIM_MODEL T2 ON T1.IDMODEL=T2.IDMODEL
WHERE DATENAME(YEAR,DATE)=2009
GROUP BY T1.IDMODEL,MODEL_NAME
ORDER BY TOTAL_QUANTITY DESC)TT
INTERSECT
SELECT *
FROM
(SELECT TOP 5 T1.IDMODEL,MODEL_NAME,SUM(QUANTITY) AS TOTAL_QUANTITY
FROM 
FACT_TRANSACTIONS T1
LEFT JOIN DIM_MODEL T2 ON T1.IDMODEL=T2.IDMODEL
WHERE DATENAME(YEAR,DATE)=2010
GROUP BY T1.IDMODEL,MODEL_NAME
ORDER BY TOTAL_QUANTITY DESC)TT



--Q8- Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with 2nd top 
--sales in the year of 2010


SELECT *
FROM
(
SELECT Manufacturer_name , DATEPART(Year,date) as YEAR,
ROW_NUMBER() OVER (PARTITION BY DATEPART(Year,date) ORDER BY SUM(QUANTITY) DESC) AS RNUM
    FROM 
    Fact_Transactions T1
    LEFT JOIN DIM_Model T2 ON T1.IDModel = T2.IDModel
    LEFT JOIN DIM_MANUFACTURER T3  ON T3.IDManufacturer = T2.IDManufacturer
    WHERE DATEPART(Year,date) IN ('2009','2010')
    group by Manufacturer_name,DATEPART(Year,date) 
)TT
WHERE RNUM=2



--Q9-Show the manufacturers who sold cellphones in 2010 but didnt in 2009
SELECT DISTINCT MANUFACTURER_NAME
FROM(SELECT 
T3.IDManufacturer, Manufacturer_Name
FROM 
FACT_TRANSACTIONS T1
LEFT JOIN DIM_MODEL T2 ON T1.IDMODEL=T2.IDMODEL
LEFT JOIN DIM_MANUFACTURER T3 ON T2.IDManufacturer=T3.IDManufacturer
WHERE DATENAME(YEAR,DATE)=2010)TT
EXCEPT
SELECT DISTINCT MANUFACTURER_NAME
FROM(SELECT 
T3.IDManufacturer, Manufacturer_Name
FROM 
FACT_TRANSACTIONS T1
LEFT JOIN DIM_MODEL T2 ON T1.IDMODEL=T2.IDMODEL
LEFT JOIN DIM_MANUFACTURER T3 ON T2.IDManufacturer=T3.IDManufacturer
WHERE DATENAME(YEAR,DATE)=2009)TT

--Q10- Find top 100 customers and their average spend, average quantity by each year. Also 
--find the percentage of change in their spend

SELECT * FROM FACT_TRANSACTIONS
SELECT * FROM DIM_CUSTOMER


SELECT TOP 100 
    YEAR(FT.DATE) AS [YEAR],
    FT.IDCUSTOMER AS [CUSTOMER NAME],
    FT.TOTALPRICE AS [TOTAL AMT],
    AVG(FT.TOTALPRICE) AS [AVG SPEND],
    AVG(FT.QUANTITY) AS [AVG QUANTITY]
FROM 
    FACT_TRANSACTIONS FT
INNER JOIN 
    DIM_CUSTOMER DC ON FT.IDCUSTOMER = DC.IDCUSTOMER
GROUP BY 
    FT.DATE, FT.IDCUSTOMER, FT.TOTALPRICE
ORDER BY 
    3 DESC 