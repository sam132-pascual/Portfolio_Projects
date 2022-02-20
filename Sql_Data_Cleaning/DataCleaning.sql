--
USE [Portf];
GO
CREATE TABLE NashvilleHousing(
	[UniqueID ] NVARCHAR(50) NOT NULL
	,[ParcelID] INT 
	,[LandUse] NVARCHAR(70) 
	,[PropertyAddress] NVARCHAR(150)
	,[SaleDate] DATETIME 
	,[SalePrice] FLOAT
	,[LegalReference] INT
	,[SoldAsVacant] NVARCHAR(2)
	,[OwnerName] NVARCHAR(70)
	,[OwnerAddress] NVARCHAR(150)
	,[Acreage] FLOAT 
	,[TaxDistrict] NVARCHAR(150)
	,[LandValue] INT
	,[BuildingValue] INT
	,[TotalValue] INT
	,[YearBuilt] INT
	,[Bedrooms] INT
	,[FullBath] INT
	,[HalfBath] INT

	CONSTRAINT [PK_UniqueID] PRIMARY KEY CLUSTERED
	(
		[UniqueID ]
	)
);
GO

--Importing Data using OPENROWSET AND BULK INSERT


sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE
GO


USE [Portf];
GO

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
GO
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
GO

--Using Bulk insert

USE [Portf];
GO
BULK INSERT
	NashvilleHousing
FROM
	'C:\Users\samue\Desktop\DATABASE\NashvilleHousingData.xlsx'
WITH(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
	--FIRSTROW = 2
);
GO

-- Cleaning Data in SQL Queries
--See the data

SELECT * FROM [Portf].[dbo].[NashvilleHousing];
GO

-- Standardize Date Format

SELECT 
	SaleDateConverted
	,CONVERT(DATE, SaleDate)
FROM 
	[Portf].[dbo].[NashvilleHousing]
GO

UPDATE 
	[Portf].[dbo].[NashvilleHousing]
SET 
	SaleDate = CONVERT(DATE, SaleDate)
GO

--Populate Property Adress Data

SELECT 
	*
FROM 
	[Portf].[dbo].[NashvilleHousing]
ORDER BY
	ParcelID
GO

--there are addresses with null but in the data there are repetitions of ParcelID and the addresses are the same so 
--I will try to fill in as many addresses as possible using that.


SELECT 
	[A].[ParcelID]
	,[A].[PropertyAddress]
	,[B].[ParcelID]
	,[B].[PropertyAddress] 
	,ISNULL([A].[PropertyAddress], [B].[PropertyAddress])
FROM
	[Portf].[dbo].[NashvilleHousing] AS [A]
JOIN 
	[Portf].[dbo].[NashvilleHousing]  AS [B]
	ON 
		[A].[ParcelID] = [B].[ParcelID] AND [A].[UniqueID ] <> [B].[UniqueID ]
WHERE
	[A].[PropertyAddress] IS NULL
GO

-- We got 35 Address
-- Update this in the table

UPDATE 
	[A]
SET
	PropertyAddress = ISNULL([A].[PropertyAddress], [B].[PropertyAddress])
FROM
	[Portf].[dbo].[NashvilleHousing] AS [A]
JOIN 
	[Portf].[dbo].[NashvilleHousing]  AS [B]
	ON 
		[A].[ParcelID] = [B].[ParcelID] AND [A].[UniqueID ] <> [B].[UniqueID ]
WHERE
	[A].[PropertyAddress] IS NULL
GO

--Breaking out Address into individual columns(Address, City, State)

SELECT 
	PropertyAddress
FROM 
	[Portf].[dbo].[NashvilleHousing]
GO

SELECT 
	SUBSTRING([N].[PropertyAddress], 1, CHARINDEX(',', [N].[PropertyAddress])-1) AS 'Address'
	,RIGHT([N].[PropertyAddress], CHARINDEX(',', REVERSE([N].[PropertyAddress]))-1) AS 'City'
FROM 
	[Portf].[dbo].[NashvilleHousing] AS [N]
GO

ALTER TABLE 
	[dbo].[NashvilleHousing]
ADD
	PropertySplitAddress NVARCHAR(255)

UPDATE 
	[dbo].[NashvilleHousing]
SET
	PropertySplitAddress = SUBSTRING([PropertyAddress], 1, CHARINDEX(',', [PropertyAddress])-1)

ALTER TABLE 
	[dbo].[NashvilleHousing]
ADD
	PropertySplitCity NVARCHAR(255)

UPDATE 
	[dbo].[NashvilleHousing]
SET
	PropertySplitCity = RIGHT([PropertyAddress], CHARINDEX(',', REVERSE([PropertyAddress]))-1) 
GO

-- Let's do the same with OwnerAdress

select OwnerAddress from NashvilleHousing

SELECT
	PARSENAME(REPLACE([N].[OwnerAddress], ',', '.'), 3)
	,PARSENAME(REPLACE([N].[OwnerAddress], ',', '.'), 2)
	,PARSENAME(REPLACE([N].[OwnerAddress], ',', '.'), 1)
FROM
	[Portf].[dbo].[NashvilleHousing] AS [N]

ALTER TABLE 
	[dbo].[NashvilleHousing]
ADD
	OwnerSplitAddress NVARCHAR(255)

UPDATE 
	[dbo].[NashvilleHousing]
SET
	OwnerSplitAddress = PARSENAME(REPLACE([OwnerAddress], ',', '.'), 3)


ALTER TABLE 
	[dbo].[NashvilleHousing]
ADD
	OwnerSplitCity NVARCHAR(255)

UPDATE 
	[dbo].[NashvilleHousing]
SET
	OwnerSplitCity = PARSENAME(REPLACE([OwnerAddress], ',', '.'), 2)

ALTER TABLE 
	[dbo].[NashvilleHousing]
ADD
	OwnerSplitState NVARCHAR(255)

UPDATE 
	[dbo].[NashvilleHousing]
SET
	OwnerSplitState = PARSENAME(REPLACE([OwnerAddress], ',', '.'), 1)

-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT 
	[N].[SoldAsVacant]
	,COUNT([N].[SoldAsVacant])
FROM 
	[Portf].[dbo].[NashvilleHousing] AS [N]
GROUP BY
	[N].[SoldAsVacant]
ORDER BY
	2

SELECT 
	CASE WHEN [N].[SoldAsVacant] = 'Y' THEN 'Yes'
		 WHEN [N].[SoldAsVacant] = 'N' THEN 'No'
		 ELSE [N].[SoldAsVacant]
	END
FROM 
	[Portf].[dbo].[NashvilleHousing] AS [N]

--
BEGIN TRAN
UPDATE 
	[Portf].[dbo].[NashvilleHousing]
SET
	[dbo].[NashvilleHousing].[SoldAsVacant] =
							CASE WHEN [N].[SoldAsVacant] = 'Y' THEN 'Yes'
								 WHEN [N].[SoldAsVacant] = 'N' THEN 'No'
								 ELSE [N].[SoldAsVacant]
							END
						FROM 
							[Portf].[dbo].[NashvilleHousing] AS [N]
select distinct SoldAsVacant, count(SoldAsVacant) from NashvilleHousing group by SoldAsVacant
COMMIT TRAN
GO

-- Delete duplicates

WITH RowNumCTE AS (
	SELECT *,
			ROW_NUMBER() OVER(
				PARTITION BY ParcelID,
							 PropertyAddress,
							 SalePrice,
							 SaleDate,
							 LegalReference
							 ORDER BY
								UniqueID
			) AS row_num
	FROM
		Portf.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
GO

--Delete Unused Columns
ALTER TABLE Portf.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--Null Values


SELECT 
	[N].[UniqueID ]
	,[N].[ParcelID]
	,[N].[LandUse]
	,[N].[SalePrice]
	,[N].[LegalReference]
	,[N].[SoldAsVacant]
	,ISNULL([N].[OwnerName], 'Unknow') AS 'OwnerName'--Replace ('OwnerName') nulls to Unknow
	,COALESCE([N].[Acreage], AVG([N].[Acreage]) OVER()) AS 'Acreage' -- Replace with average
	,COALESCE([N].[LandValue], AVG([N].[LandValue]) OVER()) AS 'LandValue' -- Replace with average
	,COALESCE([N].[BuildingValue], AVG([N].[BuildingValue]) OVER()) AS 'BuildingValue'-- Replace with average
	,COALESCE([N].[TotalValue], AVG([N].[TotalValue]) OVER()) AS 'TotalValue'-- Replace with average
	,LEFT(COALESCE([N].[Bedrooms], AVG([N].[Bedrooms]) OVER()),1) AS 'Bedrooms'-- Replace with average
	,LEFT(COALESCE([N].[FullBath], AVG([N].[FullBath]) OVER()),1) AS 'FullBath'-- Replace with average
	,LEFT(COALESCE([N].[HalfBath], AVG([N].[HalfBath]) OVER()),1) AS 'HalfBath'-- Replace with average
	,[N].[SaleDateConverted]
	,[N].[PropertySplitAddress]
	,[N].[PropertySplitCity]
	,ISNULL([N].[OwnerSplitAddress],'Unknow') AS 'OwnerSplitAddress'--Replace ('OwnerName') nulls to Unknow
	,ISNULL([N].[OwnerSplitCity],'Unknow') AS 'OwnerSplitCity'--Replace ('OwnerName') nulls to Unknow
	,ISNULL([N].[OwnerSplitState],'Unknow') AS 'OwnerSplitAddress'--Replace ('OwnerName') nulls to Unknow
FROM
	Portf.dbo.NashvilleHousing AS [N]

-- Use of the temporary table to make the above changes

DROP Table if exists #NashvilleHousingClean
Create Table #NashvilleHousingClean
(
	 [UniqueID ] FLOAT
	,[ParcelID] NVARCHAR(255)
	,[LandUse] NVARCHAR(255) 
	,[SalePrice] FLOAT
	,[LegalReference] NVARCHAR(255)
	,[SoldAsVacant] NVARCHAR(255)
	,[OwnerName] NVARCHAR(255)
	,[Acreage] FLOAT 
	,[LandValue] FLOAT
	,[BuildingValue] FLOAT
	,[TotalValue] FLOAT
	,[YearBuilt] FLOAT
	,[Bedrooms] FLOAT
	,[FullBath] FLOAT
	,[HalfBath] FLOAT
	,[SaleDateConverted] DATE
	,[PropertySplitAddress] NVARCHAR(255)
	,[PropertySplitCity] NVARCHAR(255)
	,[OwnerSplitAddress] NVARCHAR(255)
	,[OwnerSplitCity] NVARCHAR(255)
	,[OwnerSplitState] NVARCHAR(255)
)

Insert into #NashvilleHousingClean
	SELECT 
		[N].[UniqueID ]
		,[N].[ParcelID]
		,[N].[LandUse]
		,[N].[SalePrice]
		,[N].[LegalReference]
		,[N].[SoldAsVacant]
		,ISNULL([N].[OwnerName], 'Unknow') AS 'OwnerName'--Replace ('OwnerName') nulls to Unknow
		,COALESCE([N].[Acreage], AVG([N].[Acreage]) OVER()) AS 'Acreage' -- Replace with average
		,COALESCE([N].[LandValue], AVG([N].[LandValue]) OVER()) AS 'LandValue' -- Replace with average
		,COALESCE([N].[BuildingValue], AVG([N].[BuildingValue]) OVER()) AS 'BuildingValue'-- Replace with average
		,COALESCE([N].[TotalValue], AVG([N].[TotalValue]) OVER()) AS 'TotalValue'-- Replace with average
		,LEFT(COALESCE([N].[Bedrooms], AVG([N].[Bedrooms]) OVER()),1) AS 'Bedrooms'-- Replace with average
		,LEFT(COALESCE([N].[FullBath], AVG([N].[FullBath]) OVER()),1) AS 'FullBath'-- Replace with average
		,LEFT(COALESCE([N].[HalfBath], AVG([N].[HalfBath]) OVER()),1) AS 'HalfBath'-- Replace with average
		,[N].[SaleDateConverted]
		,[N].[PropertySplitAddress]
		,[N].[PropertySplitCity]
		,ISNULL([N].[OwnerSplitAddress],'Unknow') AS 'OwnerSplitAddress'--Replace ('OwnerName') nulls to Unknow
		,ISNULL([N].[OwnerSplitCity],'Unknow') AS 'OwnerSplitCity'--Replace ('OwnerName') nulls to Unknow
		,ISNULL([N].[OwnerSplitState],'Unknow') AS 'OwnerSplitState'--Replace ('OwnerName') nulls to Unknow
	FROM
		Portf.dbo.NashvilleHousing AS [N]

SELECT * from #NashvilleHousingClean

-- Creating View to store data for later visualizations

CREATE VIEW Clean_Data
AS
	SELECT 
		[N].[UniqueID ]
		,[N].[ParcelID]
		,[N].[LandUse]
		,[N].[SalePrice]
		,[N].[LegalReference]
		,[N].[SoldAsVacant]
		,ISNULL([N].[OwnerName], 'Unknow') AS 'OwnerName'--Replace ('OwnerName') nulls to Unknow
		,COALESCE([N].[Acreage], AVG([N].[Acreage]) OVER()) AS 'Acreage' -- Replace with average
		,COALESCE([N].[LandValue], AVG([N].[LandValue]) OVER()) AS 'LandValue' -- Replace with average
		,COALESCE([N].[BuildingValue], AVG([N].[BuildingValue]) OVER()) AS 'BuildingValue'-- Replace with average
		,COALESCE([N].[TotalValue], AVG([N].[TotalValue]) OVER()) AS 'TotalValue'-- Replace with average
		,LEFT(COALESCE([N].[Bedrooms], AVG([N].[Bedrooms]) OVER()),1) AS 'Bedrooms'-- Replace with average
		,LEFT(COALESCE([N].[FullBath], AVG([N].[FullBath]) OVER()),1) AS 'FullBath'-- Replace with average
		,LEFT(COALESCE([N].[HalfBath], AVG([N].[HalfBath]) OVER()),1) AS 'HalfBath'-- Replace with average
		,[N].[SaleDateConverted]
		,PARSENAME(REPLACE([N].[SaleDateConverted], '-','.'), 3) AS 'Year'-- Split SaleDateConverted by Year
		,PARSENAME(REPLACE([N].[SaleDateConverted], '-','.'), 2) AS 'Month'-- Split SaleDateConverted by Month
		,PARSENAME(REPLACE([N].[SaleDateConverted], '-','.'), 1) AS 'Day'-- Split SaleDateConverted by Day
		,[N].[PropertySplitAddress]
		,[N].[PropertySplitCity]
		,ISNULL([N].[OwnerSplitAddress],'Unknow') AS 'OwnerSplitAddress'--Replace ('OwnerName') nulls to Unknow
		,ISNULL([N].[OwnerSplitCity],'Unknow') AS 'OwnerSplitCity'--Replace ('OwnerName') nulls to Unknow
		,ISNULL([N].[OwnerSplitState],'Unknow') AS 'OwnerSplitState'--Replace ('OwnerName') nulls to Unknow
	FROM
		Portf.dbo.NashvilleHousing AS [N]

-- Final View

SELECT 
	*
FROM
	Clean_Data 
ORDER BY
	[Year]

