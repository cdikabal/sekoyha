CREATE OR REPLACE FORCE VIEW "VW_STUDENT_FULL" AS 
  select  
    std.STUDENT_ID, std.FIRST_NAME, std.LAST_NAME 
    , std.middle_name, std.gender, std.student_number 
    , Initcap(std.LAST_NAME)||', '||Initcap(std.FIRST_NAME) as student_name 
    , std.BIRTH_DATE, std.HEALTH_CARD, std.BIRTH_CITY 
    , bctr.country_code as BIRTH_COUNTRY_CODE, bctr.country_name as birth_country_name, std.birth_country_id 
    , bprv.province_code as BIRTH_PROVINCE_CODE, bprv.province_name as birth_province_name, std.birth_province_id 
    , cctr.country_code as CITIZENSHIP_COUNTRY_CODE, bctr.country_name as citizenship_country_name, std.country_id as country_id 
    , std.usual_name 
    , std.create_by_login_id, std.create_date, std.update_by_login_id, std.last_update_date
    , pic.PHOTO, pic.PHOTO_FILENAME, pic.PHOTO_UPDATED_DATE, pic.PHOTO_CHARSET, pic.PHOTO_MIMETYPE, pic.picture_id 
    , std.TYLENOL_IFNEEDED 
	, sacc.account_id
	, sacc.preferred_hourly_rate
    -- Student address 
    , std.add_id 
    , sadr.add_desc_1, sadr.add_desc_2, sadr.add_phone, sadr.add_postal_code 
    , sadr.add_city, sadr.province_id as saddr_province_id, sadr.add_fax, sadr.add_comments 
    , sadr.country_id as saddr_country_id 
    , spr.province_code as student_addr_province, sctr.country_code as student_addr_country 
    -- Parent 1 
	, par1.parent_id as par_parent_id_1
    , (select x.rel_name from relationship_type x where x.rel_type_id  = pst1.rel_type_id) as par_rel_type_1 
    , pst1.rel_type_id as par_rel_type_id_1
    , par1.parent_number as par_parent_number_1 
    , par1.first_name as par_first_name_1 
    , par1.last_name as par_last_name_1 
    , par1.middle_name as par_middle_name_1 
    , par1.gender as par_gender_1 
    , par1.work_phone as par_work_phone_1 
    , par1.cell_phone as par_cell_phone_1 
    , par1.email_address as par_email_address_1 
	, par1.occupation as par_occupation_1
	, par1.company_name as par_company_name_1
	, par1.title_id as par_title_id_1
    -- Parent 1 address 
    , case 
        when nvl(std.add_id,-1) = nvl(par1.add_id,-1) then 'Y' 
        else 'N' 
      end as par_same_address_1 
    , par1.add_id as par_add_id_1 
    , p1_adr.ADD_DESC_1 as par_add_desc_1 
    , p1_adr.ADD_PHONE as par_add_phone_1 
    , p1_adr.ADD_POSTAL_CODE as par_add_postal_code_1 
    , p1_adr.add_city as par_add_city_1 
    , (select x.province_code from glob_province x where x.province_id = p1_adr.PROVINCE_ID) as par_add_province_1 
    , p1_adr.PROVINCE_ID as par_PROVINCE_ID_1 
    , p1_adr.ADD_FAX as par_add_fax_1 
    , p1_adr.add_comments as par_add_comments_1 
    , (select x.country_code from glob_country x where x.country_id = p1_adr.country_id) as par_add_country_1 
    , p1_adr.country_id as par_country_id_1 
    -- Parent 2 
	, par2.parent_id as par_parent_id_2
    , (select x.rel_name from relationship_type x where x.rel_type_id  = pst2.rel_type_id) as par_rel_type_2 
    , pst2.rel_type_id as par_rel_type_id_2
    , par2.parent_number as par_parent_number_2 
    , par2.first_name as par_first_name_2 
    , par2.last_name as par_last_name_2 
    , par2.middle_name as par_middle_name_2 
    , par2.gender as par_gender_2 
    , par2.work_phone as par_work_phone_2 
    , par2.cell_phone as par_cell_phone_2 
    , par2.email_address as par_email_address_2 
	, par2.occupation as par_occupation_2
	, par2.company_name as par_company_name_2
	, par2.title_id as par_title_id_2
    -- Parent 2 address 
    , case 
        when nvl(std.add_id,-1) = nvl(par2.add_id,-1) then 'Y' 
        else 'N' 
      end as par_same_address_2 
    , par2.add_id as par_add_id_2 
    , p2_adr.ADD_DESC_1 as par_add_desc_2 
    , p2_adr.ADD_PHONE as par_add_phone_2 
    , p2_adr.ADD_POSTAL_CODE as par_add_postal_code_2 
    , p2_adr.ADD_CITY as par_add_city_2 
    , (select x.province_code from glob_province x where x.province_id = p2_adr.province_id) as par_add_province_2 
    , p2_adr.PROVINCE_ID as par_PROVINCE_ID_2 
    , p2_adr.ADD_FAX as par_add_fax_2 
    , p2_adr.add_comments as par_add_comments_2 
    , (select x.country_code from glob_country x where x.country_id = p2_adr.country_id) as par_add_country_2 
    , p2_adr.country_id as par_country_id_2 
    -- Doctor 
    , std.DR_ID 
    , dr.dr_name, dr.dr_phone 
    , dr.add_id dr_add_id 
    , dr_adr.ADD_DESC_1 as dr_add_desc_1 
    , dr_adr.ADD_POSTAL_CODE as dr_add_postal_code 
    , dr_adr.ADD_CITY as dr_add_city 
    , (select x.province_code from glob_province x where x.province_id = dr_adr.province_id) as dr_add_province 
    , dr_adr.PROVINCE_ID as dr_province_id 
    , dr_adr.COUNTRY_ID as dr_country_id 
    , dr_adr.add_fax as dr_add_fax 
  from 
        student std 
        left outer join glob_picture pic on (pic.TARGET_OBJECT_ID = std.student_id and pic.TARGET_OBJECT_CODE = 'MSTD') 
        left outer join glob_country bctr on (bctr.country_id = std.birth_country_id) 
        left outer join glob_province bprv on (bprv.province_id = std.birth_province_id) 
        left outer join glob_country cctr on (cctr.country_id = std.country_id) 
        left outer join address sadr on (sadr.add_id = std.add_id) 
        left outer join glob_province spr on (spr.province_id = sadr.province_id) 
        left outer join glob_country sctr on (sctr.country_id = sadr.country_id) 
        left outer join parent_student pst1 on (pst1.student_id = std.student_id and pst1.is_primary = 'Y') 
        left outer join parent_student pst2 on (pst2.student_id = std.student_id and pst2.is_primary = 'N') 
        left outer join parent par1 on (par1.parent_id = pst1.parent_id) 
        left outer join parent par2 on (par2.parent_id = pst2.parent_id) 
        left outer join doctor dr on (dr.dr_id = std.dr_id) 
        left outer join address dr_adr on (dr_adr.add_id = dr.add_id) 
        left outer join address p1_adr on (p1_adr.add_id = par1.add_id) 
        left outer join address p2_adr on (p2_adr.add_id = par2.add_id)
		left outer join student_account sacc on (sacc.student_id = std.student_id)
/

