
--STEP ONE STANDARDIZE DATE FORMAT
SELECT SaleDate
FROM Nashville
-- HERE WE WANT TO CONVET THE DATE TO STANDARDIZE IT BY USING CONVERT

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Nashville

--from here we can update it into the main table

UPDATE Nashville
SET SaleDate=CONVERT(Date, SaleDate)

--HERE SOMETIME IT MAY UPDATE AT TIMES IT MAY NOT, IN THE CASE IT DOESN'T THEN WE DO THIS METHOD BELOW

ALTER TABLE Nashville
add SaleDateConverted Date;

UPDATE Nashville
SET SaleDateConverted=CONVERT(Date, SaleDate)



SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Nashville



--STEP TWO POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM Nashville
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--We are going to do if two property address one has a propertyAddress and the other is not while the parcel ID is the same so we must populate the address
SELECT *
FROM Nashville

--To do this we to need a JOIN the two table

SELECT N.ParcelID, N.PropertyAddress, V.ParcelID, V.PropertyAddress
FROM Nashville N
JOIN Nashville V
ON N.ParcelID=V.ParcelID
AND N.[UniqueID ]<>V.[UniqueID ]
WHERE N.PropertyAddress IS NULL

--We have address but we not populating it so we use the ISNULL()

SELECT N.ParcelID, N.PropertyAddress, V.ParcelID, V.PropertyAddress, ISNULL(N.PropertyAddress, V.PropertyAddress)
FROM Nashville N
JOIN Nashville V
ON N.ParcelID=V.ParcelID
AND N.[UniqueID ]<>V.[UniqueID ]
WHERE N.PropertyAddress IS NULL

--NOW ITS BEEN POPULATE THEN WE UPDATE IT NOW

UPDATE N
SET PropertyAddress=ISNULL(N.PropertyAddress, V.PropertyAddress)
FROM Nashville N
JOIN Nashville V
ON N.ParcelID=V.ParcelID
AND N.[UniqueID ]<>V.[UniqueID ]
WHERE N.PropertyAddress IS NULL

--STEP THREE
---BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)


SELECT PropertyAddress
FROM Nashville

--To do this we need to use a  SUBSTRING AND CHARATER INDEX

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
FROM Nashville

--Now the command is gone

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Nashville



ALTER TABLE Nashville
add PropertysplitAddress Nvarchar(255);

UPDATE Nashville
SET PropertysplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville
add PropertysplitCity Nvarchar(255);

UPDATE Nashville
SET PropertysplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM Nashville



---Now the owner Address
SELECT OwnerAddress
FROM Nashville
--Here we are not going to use the SUBSTRING but a PARSENAME

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Nashville

---PARSENAME IS USED WITH PERIOD OR IT LOOKS FOR A PERIOD.
---PARSENAME TAKE THE ENTRIES IN BACKWARD.
---SO IT IS RECOMMENDED TO ARRANGE THE NUMBER IN THE BACKWARDS

---NOW WE ALERT THE TABLE AND UPDATE IT
ALTER TABLE Nashville
add OwnsplitAddress Nvarchar(255);

UPDATE Nashville
SET OwnsplitAddress=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Nashville
add OwnsplitCity Nvarchar(255);

UPDATE Nashville
SET OwnsplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE Nashville
add OwnsplitState Nvarchar(255);

UPDATE Nashville
SET OwnsplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT *
FROM Nashville


---STEP FOUR
---CHARGE Y AND N TO YES AND NO IN ''SOLD AS VACANT'' FIELD


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2

--SINCE WE HAVE IDEAS ON HOW MANY YES AND NO AND N AND Y ARE THERE. THEN WE CAN USE THE CASE STATEMENT

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant= 'Y' THEN 'YES'
     WHEN SoldAsVacant= 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM Nashville

--THEN WE UPDATE THE TABLE

UPDATE Nashville
SET SoldAsVacant= CASE WHEN SoldAsVacant= 'Y' THEN 'YES'
     WHEN SoldAsVacant= 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

--NOW WE CAN CHECK IF ITS IS UPDATE

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2


--STEP FIVE

---REMOVE DUPLICATES

--- WE USE CTE
WITH RowNumCTE AS( 
SELECT *,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY
			    UniqueID
				) row_num
FROM Nashville
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
---ORDER BY PropertyAddress


---STEP SEVEN
--DELETE UNUSED COLUMNS

SELECT *
FROM Nashville

ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate






