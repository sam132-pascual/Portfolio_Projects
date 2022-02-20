--DATA CLEANING AND TRANSFORMATION

-- Cleansed Dim_Date Table --

SELECT 
  [DateKey]
  ,[FullDateAlternateKey] AS 'Date'
  --,[DayNumberOfWeek] 
  ,[EnglishDayNameOfWeek] AS 'Day'
  ,RIGHT([FullDateAlternateKey], CHARINDEX('-', REVERSE([FullDateAlternateKey]))-1) AS 'DayNr'
  --,[SpanishDayNameOfWeek]
  --,[FrenchDayNameOfWeek]
  --,[DayNumberOfMonth]
  --,[DayNumberOfYear]
  ,[WeekNumberOfYear] AS 'WeekNr'
  ,[EnglishMonthName] AS 'Month'
  ,LEFT([EnglishMonthName], 3) AS 'MonthShort'
  --,[SpanishMonthName]
  --,[FrenchMonthName]
  ,[MonthNumberOfYear] AS 'MonthNr'
  ,[CalendarQuarter] AS 'Quarter'
  ,[CalendarYear] AS 'Year'
  --,[CalendarSemester]
  --,[FiscalQuarter]
  --,[FiscalYear]
  --,[FiscalSemester]
FROM 
  [AdventureWorksDW2019].[dbo].[DimDate] 
WHERE
  [CalendarYear] >= 2019
GO

-- Cleansed Dim_Customer Table

SELECT 
	  [C].[CustomerKey] 
      --,[GeographyKey]
      --,[CustomerAlternateKey]
      --,[Title]
      ,[C].[FirstName]
      --,[MiddleName]
      ,[C].[LastName]
      --,[NameStyle]
      --,[BirthDate]
      --,[MaritalStatus]
      --,[Suffix]
      ,CASE -- Change M and F to Male Female in Gender column
		[C].[Gender] WHEN 'M' THEN 'Male'
					 ELSE 'Female' 
	   END AS 'Gender'
      --,[EmailAddress]
      --,[YearlyIncome]
      --,[TotalChildren]
      --,[NumberChildrenAtHome]
      --,[EnglishEducation]
      --,[SpanishEducation]
      --,[FrenchEducation]
      --,[EnglishOccupation]
      --,[SpanishOccupation]
      --,[FrenchOccupation]
      --,[HouseOwnerFlag]
      --,[NumberCarsOwned]
      --,[AddressLine1]
      --,[AddressLine2]
      --,[Phone]
      ,[C].[DateFirstPurchase]
	  ,PARSENAME(REPLACE([C].[DateFirstPurchase], '-', '.'),3) AS 'Year'-- Breaking out DateFirstPurchase (Year)
	  ,PARSENAME(REPLACE([C].[DateFirstPurchase], '-', '.'),2) AS 'Month'-- Breaking out DateFirstPurchase (Month)
	  ,PARSENAME(REPLACE([C].[DateFirstPurchase], '-', '.'),1) AS 'Day'-- Breaking out DateFirstPurchase (Day)
      --,[CommuteDistance]
	  ,[G].[City] AS 'CustomeCity'-- Joined in Customer City from DimGeography table
  FROM 
	  [AdventureWorksDW2019].[dbo].[DimCustomer] AS [C]
  LEFT JOIN 
	  [AdventureWorksDW2019].[dbo].[DimGeography] AS [G]
  ON
	  [G].[GeographyKey] = [C].[GeographyKey]
  ORDER BY
      [C].[CustomerKey] ASC-- Ordered List by CustomerKey
GO

-- Cleansed Dim_Products Table

SELECT 
  [P].[ProductKey], 
  [P].[ProductAlternateKey] AS 'ProductItemCode', 
  --[ProductSubcategoryKey], 
  --[WeightUnitMeasureCode], 
  --[SizeUnitMeasureCode], 
  [P].[EnglishProductName] AS 'ProductName',
  [PC].[EnglishProductCategoryName] AS 'Product Category', -- Joined in from Category TableJ
  [PS].[EnglishProductSubcategoryName] AS 'Sub Category', -- Joined in from Sub Category Table
  --[SpanishProductName], 
  --[FrenchProductName], 
  --[StandardCost], 
  --[FinishedGoodsFlag], 
  [P].[Color] AS 'Product Color', 
  --[SafetyStockLevel], 
  --[ReorderPoint], 
  --[ListPrice], 
  [P].[Size] AS 'Product Size', 
  --[SizeRange], 
  --[Weight], 
  --[DaysToManufacture], 
  [P].[ProductLine] AS 'Product Line', 
  --[DealerPrice], 
  --[Class], 
  --[Style], 
  [P].[ModelName] AS 'Product Model Name', 
  --[LargePhoto], 
  [P].[EnglishDescription] AS 'Product Description', 
  --[FrenchDescription], 
  --[ChineseDescription], 
  --[ArabicDescription], 
  --[HebrewDescription], 
  --[ThaiDescription], 
  --[GermanDescription], 
  --[JapaneseDescription], 
  --[TurkishDescription], 
  --[StartDate], 
  --[EndDate], 
  ISNULL([P].[Status], 'Outdated') AS 'Product Status' --convert nulls by Outdated
FROM 
	[AdventureWorksDW2019].[dbo].[DimProduct] AS [P]
	LEFT JOIN
		[AdventureWorksDW2019].[dbo].[DimProductSubcategory] AS [PS]
	ON
		[PS].[ProductSubcategoryKey] = [P].[ProductSubcategoryKey]
	LEFT JOIN
		[AdventureWorksDW2019].[dbo].[DimProductCategory] AS [PC]
	ON
		[PS].[ProductCategoryKey] = [PC].[ProductCategoryKey]
ORDER BY
	[P].[ProductKey] ASC-- Ordered List by ProductKey 
GO

-- Cleansed FACT_InternetSales Table

SELECT 
  [ProductKey], 
  [OrderDateKey],
  CONVERT(DATE, CONVERT(VARCHAR(8),[OrderDateKey])) AS 'Order Date',--Convert Orderdatekey in date
  [DueDateKey], 
  CONVERT(DATE, CONVERT(VARCHAR(8),[DueDateKey])) AS 'Due Date',--Convert DueDateKey in date
  [ShipDateKey], 
  CONVERT(DATE, CONVERT(VARCHAR(8),[ShipDateKey])) AS 'Ship Date',--Convert ShipDateKey in date
  [CustomerKey], 
  --[PromotionKey], 
  --[CurrencyKey], 
  --[SalesTerritoryKey], 
  [SalesOrderNumber], 
  --[SalesOrderLineNumber], 
  --[RevisionNumber], 
  --[OrderQuantity], 
  --[UnitPrice], 
  --[ExtendedAmount], 
  --[UnitPriceDiscountPct], 
  --[DiscountAmount], 
  --[ProductStandardCost], 
  --[TotalProductCost], 
  [SalesAmount]
  --[TaxAmt], 
  --[Freight], 
  --[CarrierTrackingNumber], 
  --[CustomerPONumber], 
  --[OrderDate], 
  --[DueDate], 
  --[ShipDate] 
FROM 
  [AdventureWorksDW2019].[dbo].[FactInternetSales]
WHERE
  LEFT(OrderDateKey, 4) >= YEAR(GETDATE()) - 2 -- Ensures we always only bring two last years of date from extraction
ORDER BY
  OrderDateKey ASC
GO
