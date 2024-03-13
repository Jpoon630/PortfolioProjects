select *
from DataJobs

-- data cleaning

-- im going to remove the column Email, Date_Taken, Time_Taken, Browser, OS, City, Country, Referrer as it is irreleveant to the visualisation

alter table DataJobs
drop column Email, Date_Taken, Time_Taken, Browser, OS, City, COuntry, Referrer, Time_Spent

-- going to clean these column to just 'Other' when they specify Others

update DataJobs
set Current_Role = 'Other'
where Current_Role like 'Other%'

update DataJobs
set Industry_work_in = 'Other'
where Industry_work_in like 'Other%'

update DataJobs
set Favourite_Programming_Language = 'Other'
where Favourite_Programming_Language like 'Other%'

update DataJobs
set MostImportantThing_NewJob = 'Other'
where MostImportantThing_NewJob like 'Other%'

update DataJobs
set Country = 'Other'
where Country like 'Other%'

update DataJobs
set Ethnicity = 'Other'
where Ethnicity like 'Other%'

-- if participant didn't pick a education level 'None' is assigned

update DataJobs
set HighestLevelOfEducation = 'None'
where HighestLevelOfEducation = ''

-- modify current year salary to average

alter table DataJobs
add LowerHalfSalary nvarchar(255)

alter table DataJobs
add UpperHalfSalary nvarchar(255)

update DataJobs
set LowerHalfSalary = parsename(REPLACE(REPLACE([Current_Yearly_Salary_(USD)], '-', '.'), '+', '.'),2)

update DataJobs
set UpperHalfSalary = parsename(REPLACE(REPLACE([Current_Yearly_Salary_(USD)], '-', '.'), '+', '.'),1)

update DataJobs
set LowerHalfSalary = '255k'
where LowerHalfSalary is null

update DataJobs
set UpperHalfSalary = '255k'
where UpperHalfSalary is null

update DataJobs
set LowerHalfSalary = replace(LowerHalfSalary, 'k', '')
where LowerHalfSalary like '%k'

update DataJobs
set UpperHalfSalary = replace(UpperHalfSalary, 'k', '')
where UpperHalfSalary like '%k'

alter table DataJobs
add Average_Salary nvarchar(255)

update DataJobs
set Average_Salary = (convert(int, LowerHalfSalary) + convert(int, UpperHalfSalary)) / 2

-- clean the Age to Age_Brackets (Young, Middle Age, Old)

alter table DataJobs
add Age_Brackets nvarchar(255)

update DataJobs
set Age_Brackets = case
	when Age >= 18 and Age < 30  then 'Young'
	when Age >= 30 and Age < 50 then 'Middle Age'
	when Age >= 50 then 'Old'
	else null
end