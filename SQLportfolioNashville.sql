/*
Cleaning data in SQL Queries
*/
--------------------------------------------------------------

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------

--Standardize date format

SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,Saledate)

SELECT SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------

--Populate column

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--	Self join where the parcel ID is the same but it is not the same row

SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, 
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <>b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <>b.UniqueID
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------

--Break into columns

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255),
	PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT PARSENAME(replace(OwnerAddress,',','.'),3) as OwnerSplitAddress ,
	  PARSENAME(replace(OwnerAddress,',','.'),2) as OwnerSplitCity,
	  PARSENAME(replace(OwnerAddress,',','.'),1) as OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3),
	OwnerSplitCity =  PARSENAME(replace(OwnerAddress,',','.'),2),
	OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'), 1);

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousing 

--------------------------------------------------------------

-- Change Y to Yes and N to No

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing

SELECT (SoldAsVacant),
	CASE WHEN SoldAsVacant = 'N' THEN 'No' 
		 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing
WHERE SoldAsVacant = 'Y' or SoldAsVacant= 'N'

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No' 
					WHEN SoldAsVacant = 'Y' THEN 'Yes'
					ELSE SoldAsVacant
					END
--------------------------------------------------------------

--Remove duplicates

WITH RowNumCTE AS (
	SELECT *, 
		ROW_NUMBER() OVER 
		(PARTITION BY ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference 
			ORDER BY UniqueID) AS row_num
	FROM PortfolioProject.dbo.NashvilleHousing)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

DELETE
FROM RowNumCTE
WHERE row_num > 1

--------------------------------------------------------------

--Delete unused columns 

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

SELECT PropertyAddress, OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

