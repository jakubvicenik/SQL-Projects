-- Cleaning Data in SQL Queries

SELECT *
FROM [Portfolio Project]..NashvilleHousing

-- Standartize date format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ALTER COLUMN SaleDate DATE;

-- Populate property adress data

SELECT *
FROM [Portfolio Project]..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- Using the fact that the same ParcelID = the same PropertyAdress

SELECT Nas1.ParcelID, Nas1.PropertyAddress, Nas2.ParcelID, Nas2.PropertyAddress, ISNULL(Nas1.PropertyAddress, Nas2.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing Nas1
JOIN [Portfolio Project]..NashvilleHousing Nas2
	ON Nas1.ParcelID = Nas2.ParcelID
	AND Nas1.[UniqueID ] <> Nas2.[UniqueID ]
WHERE Nas1.PropertyAddress IS NULL

UPDATE Nas1
SET PropertyAddress = ISNULL(Nas1.PropertyAddress, Nas2.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing Nas1
JOIN [Portfolio Project]..NashvilleHousing Nas2
	ON Nas1.ParcelID = Nas2.ParcelID
	AND Nas1.[UniqueID ] <> Nas2.[UniqueID ]
WHERE Nas1.PropertyAddress IS NULL

SELECT *
FROM [Portfolio Project]..NashvilleHousing
WHERE PropertyAddress IS NULL

-- Breaking down Adresses into individual columns (Address, City, State)

SELECT PropertyAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Adress,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAdress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



SELECT *
FROM [Portfolio Project]..NashvilleHousing


SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM [Portfolio Project]..NashvilleHousing
ORDER BY OwnerAddress DESC


-- Adding new columns, takeaway -> PARSENAME > SUBSTRING in this case :)

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

-- Change Y and N to Yes and No in SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END

-- Remove Duplicates

WITH DuplicateCTE AS
(SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID) row_num
FROM [Portfolio Project]..NashvilleHousing
)
DELETE
FROM DuplicateCTE
WHERE row_num >1


-- Delete Unused Columns

SELECT *
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress




