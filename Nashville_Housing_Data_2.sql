-- Data Cleaning Practice

SELECT *
FROM Nashville_Housing..Nashville_Data;



-- Converting date format from datetime to Date 

ALTER TABLE Nashville_Housing..Nashville_Data ADD sale_date_2 Date;

UPDATE Nashville_Housing..Nashville_Data
SET sale_date_2  = CONVERT(Date, SaleDate);


-- Populating property address data. Self join table to where the null values in PropertyAddress that have duplicate ParcelIDs can have duplicate addresses. But not having the same UniqueID.

SELECT PropertyAddress
FROM Nashville_Housing..Nashville_Data
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Self joining table

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing..Nashville_Data a
JOIN Nashville_Housing..Nashville_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Replacing the null values of table a's PropertyAddress with table b's PropertyAddress

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing..Nashville_Data a
JOIN Nashville_Housing..Nashville_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


-- Dividing PropertyAddress into individual columns

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Nashville_Housing..Nashville_Data;

ALTER TABLE Nashville_Housing..Nashville_Data ADD Split_Property_Address nvarchar(255);

UPDATE Nashville_Housing..Nashville_Data
SET Split_Property_Address  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE Nashville_Housing..Nashville_Data ADD Split_Property_City nvarchar(255);

UPDATE Nashville_Housing..Nashville_Data
SET Split_Property_City  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


SELECT *
FROM Nashville_Housing..Nashville_Data;


---- Dividing OwnerAddress into individual columns

SELECT OwnerAddress
FROM Nashville_Housing..Nashville_Data;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM Nashville_Housing..Nashville_Data;

ALTER TABLE Nashville_Housing..Nashville_Data ADD Split_Address_Owner nvarchar(255);

UPDATE Nashville_Housing..Nashville_Data
SET Split_Address_Owner  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE Nashville_Housing..Nashville_Data ADD Split_City_Owner nvarchar(255);

UPDATE Nashville_Housing..Nashville_Data
SET Split_City_Owner  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE Nashville_Housing..Nashville_Data ADD Split_State_Owner nvarchar(255);

UPDATE Nashville_Housing..Nashville_Data
SET Split_State_Owner  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM Nashville_Housing..Nashville_Data;

-- Changing 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM Nashville_Housing..Nashville_Data
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Nashville_Housing..Nashville_Data;

UPDATE Nashville_Housing..Nashville_Data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;

-- Results after data value change for SoldAsVacant
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM Nashville_Housing..Nashville_Data
GROUP BY SoldAsVacant
ORDER BY 2;


-- Removing duplicates
-- Using CTE to find duplicate rows aside from having different values from UniqueID
-- If the row number is greater then 1, that means it is a duplicate

WITH Row_num_CTE AS(

SELECT *, ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM Nashville_Housing..Nashville_Data
-- ORDER BY ParcelID

)
SELECT *
FROM Row_num_CTE
WHERE row_num > 1
ORDER BY PropertyAddress;


-- Deleting duplicate rows

WITH Row_num_CTE AS(

SELECT *, ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM Nashville_Housing..Nashville_Data
-- ORDER BY ParcelID

)
DELETE
FROM Row_num_CTE
WHERE row_num > 1


-- Deleting unused columns

ALTER TABLE Nashville_Housing..Nashville_Data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

SELECT *
FROM Nashville_Housing..Nashville_Data;