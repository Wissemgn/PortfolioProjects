/*

Cleaning data in SQL queries

*/


select * from PortfolioProject..NashvilleHousing

--Standardize date format "SaleDate"


select SaleDateConverted, CONVERT(Date,SaleDate) 
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
set SaleDate=Convert(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
set SaleDateConverted=Convert(Date,SaleDate)



--Populate Property address Data


select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



---Breaking out Adress into individual columns (Adress,City,State)


--first solution

select PropertyAddress
From PortfolioProject..NashvilleHousing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) AS Address2

From PortfolioProject..NashvilleHousing



Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))


select * 
from PortfolioProject..NashvilleHousing





--second solution


select	OwnerAddress
from PortfolioProject..NashvilleHousing


select PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress= PARSENAME(replace(OwnerAddress,',','.'),3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity= PARSENAME(replace(OwnerAddress,',','.'),2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState= PARSENAME(replace(OwnerAddress,',','.'),1)




select * 
from PortfolioProject..NashvilleHousing


---Change Y and N to Yes and No in "Sold as vacant" Field

select distinct(SoldAsVacant),count(SoldAsVacant) 
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2




select SoldAsVacant,
case when SoldAsVacant='Y' then 'YES'
     when SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
	 End
from PortfolioProject..NashvilleHousing



Update PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant='Y' then 'YES'
     when SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
	 End




--Remove duplicates

with RowNumCte as(
select *,
ROW_NUMBER() Over (
partition by ParcelID,
             PropertyAddress,
             SalePrice,
			 SaleDate,
			 LegalReference
			 Order By UniqueID
) row_num
from PortfolioProject..NashvilleHousing
--order By ParcelID
)
select *
from RowNumCte
where row_num > 1
order By PropertyAddress


delete
from RowNumCte
where row_num > 1
--order By PropertyAddress

select * 
from PortfolioProject..NashvilleHousing


--Delete unused columns

select * 
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress



alter table PortfolioProject..NashvilleHousing
drop column SaleDate

