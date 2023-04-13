/*

Cleaning Data in SQL Queries

*/


SELECT * FROM nashvillehousing;

SELECT SaleDate
FROM nashvillehousing;

--------------------------------------------------------------------------------------------------------------------------


--Populate Property address data 
SELECT *
FROM nashvillehousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

 --------------------------------------------------------------------------------------------------------------------------


--Using a selfjoin, we are going to match the property address to the parcelid where the data is NULL
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,  COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashvillehousing a
JOIN nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE nashvillehousing AS a
SET PropertyAddress = COALESCE(b.propertyaddress, a.propertyaddress)
FROM nashvillehousing AS b 
WHERE a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid AND a.propertyaddress IS NULL;



--------------------------------------------------------------------------------------------------------------------------


-- Break out the address into individual columns (Address, City, State)

SELECT SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',')-1) AS Address, 
				SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') +1, LENGTH(PropertyAddress) )AS Address2
FROM nashvillehousing;

ALTER TABLE  nashvillehousing
ADD PropertySplitAddress NVARCHAR(255) ;

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',')-1) 

ALTER TABLE  nashvillehousing
ADD PropertySplitCity NVARCHAR(255) ;

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') +1, LENGTH(PropertyAddress) );


 --------------------------------------------------------------------------------------------------------------------------


-- Breakout the owner address 
SELECT SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress, ',')-1) AS Address, 
				SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',' )+1, LENGTH(OwnerAddress) -4)AS Address2,
				SUBSTRING(OwnerAddress, INSTR(OwnerAddress, 'TN') , LENGTH(OwnerAddress) )AS Address2
FROM nashvillehousing


ALTER TABLE  nashvillehousing
ADD ownerSplitAddress NVARCHAR(255) ;


UPDATE nashvillehousing
SET ownerSplitAddress =  SUBSTRING(OwnerAddress, 1, INSTR(OwnerAddress, ',')-1) 


ALTER TABLE  nashvillehousing
ADD ownerSplitCity NVARCHAR(255) ;


UPDATE nashvillehousing
SET ownerSplitCity = SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',' )+1, LENGTH(OwnerAddress) );


ALTER TABLE  nashvillehousing
ADD ownerSplitState NVARCHAR(255) ;


UPDATE nashvillehousing
SET ownerSplitState = SUBSTRING(OwnerAddress, INSTR(OwnerAddress, 'TN') , LENGTH(OwnerAddress) );


 --------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in 'Sold as Vacant' field
SELECT DISTINCT SoldAsVacant, COUNT(*)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		     WHEN SoldAsVacant = 'N' THEN 'No'
		     ELSE SoldAsVacant
		     END AS edit		
FROM nashvillehousing


UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END

 --------------------------------------------------------------------------------------------------------------------------



--Let's remove duplicates

SELECT * , ROW_NUMBER() OVER(PARTITION BY  ParcelID, 
						PropertySplitAddress,
						SalePrice,
						SaleDate,
	ORDER BY  UniqueID) AS row_num																				
FROM nashvillehousing;

WITH RowNumCTE AS
		( SELECT * , ROW_NUMBER() OVER(PARTITION BY  ParcelID, 
								PropertySplitAddress,
								SalePrice,
								SaleDate,
								LegalReference
		  ORDER BY         UniqueID) AS row_num																				
		  FROM nashvillehousing)
															

DELETE
FROM RowNumCTE
WHERE row_num  > 1;


 --------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns

SELECT * 
FROM nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;





