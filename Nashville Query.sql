/* 
Cleaning Data in SQL Queries 

*/

SELECT * 
FROM NashvilleHousing




------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT
	SaleDate
FROM 
	NashvilleHousing


ALTER TABLE 
	dbo.NashvilleHousing
ALTER COLUMN  
	SaleDate date 

SELECT
	SaleDate
FROM 
	NashvilleHousing




------------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address 


SELECT 
*
FROM 
dbo.NashvilleHousing
-- WHERE PropertyAddress is null 
ORDER BY 
ParcelID

SELECT 
	a.ParcelID, 
	a.PropertyAddress, 
	b.ParcelID, 
	b.PropertyAddress, 
	ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a 
JOIN dbo.NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a 
JOIN dbo.NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress is null 



------------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State) 


SELECT 
PropertyAddress
FROM 
dbo.NashvilleHousing
-- WHERE PropertyAddress is null 
-- ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address 
FROM 
dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255) 
GO 

UPDATE NashvilleHousing	
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing 
ADD PropertySplitCity nvarchar(255)  
GO 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))






SELECT
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
FROM dbo.NashvilleHousing




ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress nvarchar(255);  
GO 

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)
GO 

ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity nvarchar(255);  
GO 

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)
GO 

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState nvarchar(25);  
GO 

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)






------------------------------------------------------------------------------------------------------------------------------



-- Change Y and N to Yes and No in the "Sold as Vacant" field 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY 
SoldAsVacant
ORDER BY 
2




SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END 
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END 


------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM NashvilleHousing 
--ORDER BY ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns 

Select * 
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress
