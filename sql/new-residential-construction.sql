select
  distinct on(permit_case_number) permit_case_number,
  dense_rank() over (order by permit_case_number) as gid,
  extract(year from issue_date)::numeric as year,
  permit_case_type,
  address_full,
  geom
from permits
where
  permit_case_type in(
    'Residential 1 & 2 Family Permit, Single Family Dwelling, New Construction',
    'Residential 1 & 2 Family Permit, Townhouse (2 Units), New Construction',
    'Residential 1 & 2 Family Permit, Townhouse (3 or more units), New Construction',
    'Residential 1 & 2 Family Permit, Duplex, New Construction') and
  extract(year from issue_date) >= 2014;
