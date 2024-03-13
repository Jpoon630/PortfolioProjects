-- Standardize Date Format

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

-- populate property address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- breaking address into individual columns (Address, City, State)

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as City
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

-- breaking owner address (other method)

select
parsename(replace(OwnerAddress, ',', '.'),3)
, parsename(replace(OwnerAddress, ',', '.'),2)
, parsename(replace(OwnerAddress, ',', '.'),1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'),3)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'),2)

update NashvilleHousing
set OwnerSplitState =  parsename(replace(OwnerAddress, ',', '.'),1)

-- change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant)
from NashvilleHousing

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

-- remove duplicates

with RowNumCTE as (
select *,
ROW_NUMBER() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1

-- delete unused columns

alter table NashvilleHousing
drop column TaxDistrict

select *
from NashvilleHousing

