/*
Cleaning data in SQK Queries
*/
SELECT *
FROM Portfolio_Project..NashvilleHousing


--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio_Project..NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate=CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property Address Data

SELECT *
FROM Portfolio_Project..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID



SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress , ISNULL (A.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project..NashvilleHousing A
JOIN Portfolio_Project..NashvilleHousing B
ON A.ParcelID=b.ParcelID
AND A.[UniqueID ]<>b.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project..NashvilleHousing A
JOIN Portfolio_Project..NashvilleHousing B
ON A.ParcelID = b.ParcelID
AND A.[UniqueID ]<>b.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--Breaking out Address into Individual columns(Address, city,state)

SELECT PropertyAddress
FROM Portfolio_Project..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress , 1 , CHARINDEX (',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress , CHARINDEX (',', PropertyAddress) +1,LEN(PropertyAddress)) AS Address
FROM Portfolio_Project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255) ;


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX (',', PropertyAddress) -1)



ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress , CHARINDEX (',', PropertyAddress) +1,LEN(PropertyAddress))



SELECT *
FROM Portfolio_Project..NashvilleHousing




SELECT OwnerAddress
FROM Portfolio_Project..NashvilleHousing




SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portfolio_Project..NashvilleHousing




ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255) ;


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT *
FROM Portfolio_Project..NashvilleHousing



--Change Y and N to Yes and No in "Sold as vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project..NashvilleHousing
GROUP BY SoldAsVacant 
ORDER BY 2 


SELECT SoldAsVacant
,CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM Portfolio_Project..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM Portfolio_Project..NashvilleHousing



-- Removing Duplicates
WITH RowNumCTE AS (
SELECT *,
        ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
		             PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER  BY 
					        UniqueID
							) row_num
FROM Portfolio_Project..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress





SELECT *
FROM Portfolio_Project..NashvilleHousing



ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN SaleDate



