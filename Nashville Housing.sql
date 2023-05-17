/* 

Cleaning Data in SQL Queries

*/

SELECT *
FROM PorfolioProject..NashvilleHousing

--1. Standarize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PorfolioProject..NashvilleHousing

UPDATE PorfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PorfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)

---2. Populate Property Address Data

SELECT *
FROM PorfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PorfolioProject..NashvilleHousing AS a
JOIN PorfolioProject..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PorfolioProject..NashvilleHousing AS a
JOIN PorfolioProject..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- 3. Breaking out Address into indivuals columns (Address, City, State)


SELECT *
FROM PorfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PorfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR (255);

UPDATE PorfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR (255);

UPDATE PorfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM PorfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PorfolioProject..NashvilleHousing

ALTER TABLE PorfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (255);

UPDATE PorfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PorfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR (255);

UPDATE PorfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PorfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR (255);

UPDATE PorfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- 4. Change Y and N to Yes and No in "SoldAsVacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PorfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 
FROM PorfolioProject..NashvilleHousing

UPDATE PorfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 

-- 5. Remove Duplicates

WITH RowNumCte AS 
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY  ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) AS row_num

FROM PorfolioProject..NashvilleHousing)

--DELETE
--FROM RowNumCte
--WHERE row_num > 1

SELECT *
FROM RowNumCte
WHERE row_num > 1

-- 6. Delete Unused Columns	

SELECT *
FROM PorfolioProject..NashvilleHousing

ALTER TABLE PorfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PorfolioProject..NashvilleHousing
DROP COLUMN SaleDate
