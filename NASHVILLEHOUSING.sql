--Cleaning Data in SQL Queries

Select *
From PortfolioProject..NashVilleHousing


--Standardise SaleDate Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject..NashVilleHousing

Update PortfolioProject..NashVilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProject..NashVilleHousing
Add SaleDateConverted Date;

Update NashVilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashVilleHousing

------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data.

Select *
From PortfolioProject..NashVilleHousing
--Where PropertyAddress is NULL
Order by ParcelID


Select x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress
From PortfolioProject..NashVilleHousing x
JOIN PortfolioProject..NashVilleHousing y
 ON x.ParcelID = y.ParcelID
 AND x.[UniqueID] <> y.[UniqueID]
Where x.PropertyAddress is Null

Select x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress, ISNULL(x.PropertyAddress, y.PropertyAddress)
From PortfolioProject..NashVilleHousing x
JOIN PortfolioProject..NashVilleHousing y
 ON x.ParcelID = y.ParcelID
 AND x.[UniqueID] <> y.[UniqueID]
Where x.PropertyAddress is Null


Update x
Set PropertyAddress = ISNULL(x.PropertyAddress, y.PropertyAddress)
From PortfolioProject..NashVilleHousing x
JOIN PortfolioProject..NashVilleHousing y
 ON x.ParcelID = y.ParcelID
 AND x.[UniqueID] <> y.[UniqueID]
Where x.PropertyAddress is Null


--Breaking out Property Address into individual columns (Address, City, State).

Select PropertyAddress
From PortfolioProject..NashVilleHousing


Select
SUBSTRING (PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) as Address
From PortfolioProject..NashVilleHousing


Select
SUBSTRING (PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashVilleHousing


ALTER TABLE PortfolioProject..NashVilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashVilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE PortfolioProject..NashVilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashVilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashVilleHousing


--Breaking out Owner Address into individual columns (Address, City, State).

Select OwnerAddress
From PortfolioProject..NashVilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject..NashVilleHousing


ALTER TABLE PortfolioProject..NashVilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE PortfolioProject..NashVilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE PortfolioProject..NashVilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


Select *
From PortfolioProject..NashVilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct (SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashVilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashVilleHousing


Update PortfolioProject..NashVilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

--To see the Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				 UniqueID
				 ) row_num

From PortfolioProject..NashVilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--To delete the Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				 UniqueID
				 ) row_num

From PortfolioProject..NashVilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-----------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject..NashVilleHousing

ALTER TABLE PortfolioProject..NashVilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject..NashVilleHousing
DROP COLUMN SaleDate
