USE AdventureWorksDW2019
GO

--1. Ilu unikalnych klient�w znajduje si� w bazie danych?

SELECT 
	COUNT(DISTINCT CustomerKey) AS UniqueCustomers
FROM dbo.DimCustomer;

--2. Wypisz klient�w z Niemiec, kt�rych imi� zawiera liter� �a�

SELECT 
	dc.CustomerKey, 
	dc.FirstName, 
	dc.LastName, 
	dg.EnglishCountryRegionName
FROM dbo.DimCustomer dc
JOIN dbo.DimGeography dg
	ON dc.GeographyKey = dg.GeographyKey
WHERE dg.EnglishCountryRegionName = 'Germany'
  AND dc.FirstName LIKE '%a%';

--3. Ilu klient�w pochodzi z ka�dego kraju? Posortuj malej�co po liczbie klient�w.

SELECT  
	dg.EnglishCountryRegionName,
	COUNT(1) AS TotalCustomers
FROM dbo.DimCustomer dc
JOIN [dbo].[DimGeography] dg
	ON dc.GeographyKey = dg.GeographyKey
GROUP BY
	dg.EnglishCountryRegionName
ORDER BY TotalCustomers DESC;

--4. Wypisz produkty, kt�re nigdy nie zosta�y zam�wione.

SELECT 
	p.ProductKey, 
	p.EnglishProductName
FROM dbo.DimProduct p
LEFT JOIN dbo.FactInternetSales s 
	ON s.ProductKey = p.ProductKey
WHERE s.ProductKey IS NULL;

--5. Kt�ry klient wyda� najwi�cej pieni�dzy w roku 2013?

SELECT TOP 1 
    c.CustomerKey,
    c.FirstName,
    c.LastName,
    SUM(s.SalesAmount) AS TotalSpent
FROM dbo.DimCustomer c
JOIN dbo.FactInternetSales s 
	ON s.CustomerKey = c.CustomerKey
JOIN dbo.DimDate d 
	ON s.OrderDateKey = d.DateKey
WHERE d.CalendarYear = 2013
GROUP BY c.CustomerKey, c.FirstName, c.LastName
ORDER BY TotalSpent DESC;

--6. Zoptymalizuj poni�sze zapytanie pod k�tem wydajno�ci i czytelno�ci
--Zoptymalizowane zapytanie:

WITH TotalSpentInfo AS (
	SELECT 
		s.CustomerKey
		,s.SalesOrderNumber
		,s.SalesAmount
		,d.DateKey
	FROM dbo.FactInternetSales s
	JOIN dbo.DimProduct p
		ON p.ProductKey = s.ProductKey
	JOIN dbo.DimDate d
		ON s.OrderDateKey = d.DateKey
	WHERE p.EnglishProductName LIKE '%Mountain%'
		  AND p.Color IN ('Red', 'Silver', 'Black')
		  AND d.CalendarYear BETWEEN 2012 AND 2014
		  AND d.DayNumberOfWeek IN (1, 7) -- Weekends
)

SELECT 
	c.CustomerKey,
	c.FirstName,
	c.LastName,
	COUNT(DISTINCT tsi.SalesOrderNumber) AS OrderCount,
	SUM(tsi.SalesAmount) AS TotalSpent
FROM dbo.DimCustomer c
JOIN TotalSpentInfo tsi
	ON c.CustomerKey = tsi.CustomerKey
GROUP BY 
	c.CustomerKey, 
	c.FirstName, 
	c.LastName
HAVING SUM(tsi.SalesAmount) > 5000
ORDER BY TotalSpent DESC;