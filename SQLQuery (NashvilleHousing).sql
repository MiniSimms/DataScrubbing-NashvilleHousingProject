
--STANDARDIZE DATE FORMAT (2 versions)
--(versions: update/convert vs delete columns)

--Version 1 (update/convert)
	update NashvilleHousing
	set SaleDate = convert(date, saledate)

--Version 2 (delete columns)
	alter table NashvilleHousing
	add SaleDate2 date

	update NashvilleHousing
	set SaleDate2 = convert(date, saledate)

	alter table NashvilleHousing
	drop column SalesDate

-----------------------------------------------------------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA (self join)

-- test query, need to do a self join
select [UniqueID ], ParcelID
from NashvilleHousing
where ParcelID = ParcelID 
--and [UniqueID ] != [UniqueID ]
group by [UniqueID ], ParcelID

--solution
select NashA.ParcelID, NashA.PropertyAddress, NashB.ParcelID, NashB.PropertyAddress, ISNULL(NashA.PropertyAddress, NashB.PropertyAddress)
from NashvilleHousing NashA
join NashvilleHousing NashB
	on NashA.ParcelID = NashB.ParcelID
	and NashA.[UniqueID ] != NashB.[UniqueID ]
where NashA.PropertyAddress is null
order by NashA.ParcelID

Update NashA
Set PropertyAddress =  ISNULL(NashA.PropertyAddress, NashB.PropertyAddress)
from NashvilleHousing NashA
join NashvilleHousing NashB
	on NashA.ParcelID = NashB.ParcelID
	and NashA.[UniqueID ] != NashB.[UniqueID ]

-----------------------------------------------------------------------------------------------------------------------------------------------------------

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
--(2 versions: Substring vs ParseName)

--Version 1 (substring)
select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress) +1, len(PropertyAddress)) as Address
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)
	update NashvilleHousing
	set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)
	update NashvilleHousing
	set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress) +1, len(PropertyAddress))

--Version 2 (parsename)
select
parsename(Replace(Owneraddress, ',', '.'), 3),
parsename(Replace(Owneraddress, ',', '.'), 2),
parsename(Replace(Owneraddress, ',', '.'), 1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)
	update NashvilleHousing
	set OwnerSplitAddress = parsename(Replace(Owneraddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)
	update NashvilleHousing
	set OwnerSplitCity = parsename(Replace(Owneraddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)
	update NashvilleHousing
	set OwnerSplitState = parsename(Replace(Owneraddress, ',', '.'), 1)

-----------------------------------------------------------------------------------------------------------------------------------------------------------

--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD
select SoldAsVacant,
	case
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from nashvillehousing

update NashvilleHousing
Set SoldAsVacant = case
						when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
					end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES
With RowNumCTE as (
select *,
	ROW_NUMBER() Over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
from NashvilleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num > 1


