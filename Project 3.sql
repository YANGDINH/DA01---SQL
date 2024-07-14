--C1
SELECT 
    p.PRODUCTLINE,
    YEAR(s.ORDERDATE) AS YEAR_ID,
    s.DEALSIZE,
    SUM(s.SALES) AS REVENUE
FROM 
    Sales s
JOIN 
    Products p ON s.PRODUCTCODE = p.PRODUCTCODE
GROUP BY 
    p.PRODUCTLINE, YEAR(s.ORDERDATE), s.DEALSIZE
ORDER BY 
    p.PRODUCTLINE, YEAR_ID, s.DEALSIZE;

--C2
SELECT 
    MONTH(s.ORDERDATE) AS MONTH_ID,
    YEAR(s.ORDERDATE) AS YEAR_ID,
    SUM(s.SALES) AS REVENUE,
    COUNT(s.ORDERNUMBER) AS ORDER_NUMBER
FROM 
    Sales s
GROUP BY 
    YEAR(s.ORDERDATE), MONTH(s.ORDERDATE)
ORDER BY 
    YEAR_ID, REVENUE DESC;

--C3
SELECT 
    MONTH(s.ORDERDATE) AS MONTH_ID,
    p.PRODUCTLINE,
    SUM(s.SALES) AS REVENUE,
    COUNT(s.ORDERNUMBER) AS ORDER_NUMBER
FROM 
    Sales s
JOIN 
    Products p ON s.PRODUCTCODE = p.PRODUCTCODE
WHERE 
    MONTH(s.ORDERDATE) = 11
GROUP BY 
    MONTH_ID, p.PRODUCTLINE
ORDER BY 
    REVENUE DESC;

--C4
WITH product_sales_uk AS (
    SELECT 
        YEAR(s.ORDERDATE) AS YEAR_ID,
        p.PRODUCTLINE,
        SUM(s.SALES) AS REVENUE
    FROM 
        Sales s
    JOIN 
        Products p ON s.PRODUCTCODE = p.PRODUCTCODE
    JOIN 
        Customers c ON s.CUSTOMERNUMBER = c.CUSTOMERNUMBER
    WHERE 
        c.COUNTRY = 'UK'
    GROUP BY 
        YEAR_ID, p.PRODUCTLINE
)
SELECT 
    YEAR_ID,
    PRODUCTLINE,
    REVENUE,
    RANK() OVER (PARTITION BY YEAR_ID ORDER BY REVENUE DESC) AS RANK
FROM 
    product_sales_uk
ORDER BY 
    YEAR_ID, RANK;

--C5
SELECT 
    c.CUSTOMERNUMBER,
    c.CUSTOMERNAME,
    MAX(o.ORDERDATE) AS LAST_ORDER_DATE,
    COUNT(o.ORDERNUMBER) AS FREQUENCY,
    SUM(s.SALES) AS MONETARY,
    DENSE_RANK() OVER (ORDER BY MAX(o.ORDERDATE) DESC) AS RECENCY_RANK,
    DENSE_RANK() OVER (ORDER BY COUNT(o.ORDERNUMBER) DESC) AS FREQUENCY_RANK,
    DENSE_RANK() OVER (ORDER BY SUM(s.SALES) DESC) AS MONETARY_RANK
FROM 
    Customers c
JOIN 
    Orders o ON c.CUSTOMERNUMBER = o.CUSTOMERNUMBER
JOIN 
    Sales s ON o.ORDERNUMBER = s.ORDERNUMBER
GROUP BY 
    c.CUSTOMERNUMBER, c.CUSTOMERNAME
ORDER BY 
    RECENCY_RANK, FREQUENCY_RANK, MONETARY_RANK;