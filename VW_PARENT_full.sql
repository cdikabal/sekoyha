CREATE OR REPLACE FORCE VIEW "VW_PARENT_FULL" AS 
select 
  mpar.parent_id, mpar.parent_number
  , mpar.title_id
  , initcap(mpar.last_name) ||', '||initcap(mpar.first_name) as parent_name
  , mpar.first_name
  , mpar.last_name
  , mpar.middle_name
  , mpar.gender
  , mpar.cell_phone
  , mpar.work_phone
  , mpar.email_address
  , mpar.occupation
  , mpar.company_name
  , mpar.add_id
  , madr.add_phone
  , madr.add_fax
  , madr.add_desc_1
  , madr.add_desc_2
  , madr.add_city
  , madr.add_postal_code
  , madr.province_id
  , madr.country_id
  , madr.add_comments
  , (select count(1) from parent_student x where x.parent_id = mpar.parent_id) as kids
from parent mpar
  inner join address madr on (madr.add_id = mpar.add_id)
/

