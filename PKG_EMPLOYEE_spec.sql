create or replace PACKAGE           "PKG_EMPLOYEE" AS 
-- ========================================================================= 
-- Description 
--  This package is used to manage EMPLOYEE entity 
-- List of public procedures and functions 
-- ========================================================================= 
 
function create_replace( 
               p_first_name in employee.first_name%Type, 
               p_last_name in employee.last_name%Type, 
               p_gender in employee.gender%Type default null, 
               p_home_phone in employee.home_phone%Type default null, 
               p_is_teacher in employee.is_teacher%Type default 'Y',
               p_add_id in employee.add_id%Type default null) 
  return employee.employee_id%Type; 
 
function create_replace( 
               p_employee_id in employee.employee_id%Type, 
               p_first_name in employee.first_name%Type, 
               p_last_name in employee.last_name%Type, 
               p_gender in employee.gender%Type, 
               p_home_phone in employee.home_phone%Type, 
               p_cell_phone in employee.cell_phone%Type, 
               p_work_phone in employee.work_phone%Type, 
               p_title_id in employee.title_id%Type, 
               p_email_address in employee.email_address%Type, 
               p_is_teacher in employee.is_teacher%Type,
               p_ss_number in employee.ss_number%Type,
               p_hire_date in employee.hire_date%Type,
               p_terminate_date in employee.terminate_date%Type,
               p_add_id in employee.add_id%Type) 
  return employee.employee_id%Type; 
function create_replace(p_employee_record in employee%RowType)  return employee.employee_id%Type; 
-- ---------------------------------------------------------------------------
-- function get_record()
-- ---------------------------------------------------------------------------
function get_record(p_employee_id in employee.employee_id%Type) return employee%RowType;
function get_record(p_login_name in employee.login_name%Type) return employee%RowType;
function get_record(p_login_id in login.login_id%Type) return employee%RowType;
-- ---------------------------------------------------------------------------
-- function is_created( )
-- ---------------------------------------------------------------------------
function is_created( 
     p_first_name in employee.first_name%Type, 
     p_last_name in employee.last_name%Type)  
     return boolean; 
--function is_created( 
--            p_first_name in employee.first_name%Type,  
--            p_last_name in employee.last_name%Type) return boolean; 
 
-- ---------------------------------------------------------------------------
-- function get_id( name )
-- ---------------------------------------------------------------------------
function get_id( 
     p_first_name in employee.first_name%Type, 
     p_last_name in employee.last_name%Type)  
     return employee.employee_id%Type; 
 
-- -----------------------------------------------------------------------------
-- function get_id( employee number )
-- -----------------------------------------------------------------------------
function get_id(p_employee_number in employee.employee_number%Type) return employee.employee_id%Type;
-- ---------------------------------------------------------------------------
-- procedure set_employee_contact()
-- ---------------------------------------------------------------------------
procedure set_employee_contact(
     p_employee_id in employee_contact.employee_id%Type, 
     p_contact_id in employee_contact.contact_id%Type, 
     p_rel_type_id in employee_contact.rel_type_id%Type default 'SPOUSE', 
     p_emergency in employee_contact.emergency%Type default 'Y');
function get_name(pi_employee_id in employee.employee_id%Type) return varchar2;
 
-- ---------------------------------------------------------------------------
-- function create_employee()
-- ---------------------------------------------------------------------------
function create_employee(
               pi_first_name in employee.first_name%Type       , 
               pi_last_name in employee.last_name%Type         , 
               pi_gender in employee.gender%Type               , 
               pi_home_phone in employee.home_phone%Type       := null, 
               pi_cell_phone in employee.cell_phone%Type       := null, 
               pi_work_phone in employee.work_phone%Type       := null, 
               pi_title_id in employee.title_id%Type           := null, 
               pi_email_address in employee.email_address%Type := null, 
               pi_is_teacher in employee.is_teacher%Type       := 'N',
               pi_ss_number in employee.ss_number%Type         := null,
               pi_hire_date in employee.hire_date%Type         := null,
               pi_position_id in employee.position_id%Type     := null,
               pi_department_id in employee.department_id%Type     := null,
    -- Address
               pi_add_desc_1 in address.add_desc_1%Type        ,
               pi_add_desc_2 in address.add_desc_2%Type        := null,
               pi_add_city in address.add_city%Type            ,
               pi_add_postal_code in address.add_postal_code%Type,
               pi_province_id in address.province_id%Type      ,
               pi_country_id in address.country_id%Type        ,
               pi_add_fax in address.add_fax%Type := null      ,
    -- 1st contact
               pi_mcon1_FIRST_NAME in contact.FIRST_NAME%Type   := null, 
   	           pi_mcon1_LAST_NAME in contact.LAST_NAME%Type     := null, 
	           pi_mcon1_PHONE_1 in contact.PHONE_1%Type         := null, 
	           pi_mcon1_PHONE_2 in contact.PHONE_2%Type         := null, 
               pi_mcon1_desc_1 in address.add_desc_1%Type       := null,
               pi_mcon1_desc_2 in address.add_desc_2%Type       := null,
               pi_mcon1_city in address.add_city%Type           := null,
               pi_mcon1_postal_code in address.add_postal_code%Type := null,
               pi_mcon1_province_id in address.province_id%Type := null,
               pi_mcon1_country_id in address.country_id%Type   := null,
	           pi_mcon1_GENDER in contact.GENDER%Type           := null, 
	           pi_mcon1_EMAIL_ADDRESS in contact.EMAIL_ADDRESS%Type := null, 
	           pi_mcon1_COMMENTS in contact.COMMENTS%Type       := null,
               pi_mcon1_REL_TYPE_ID in employee_contact.REL_TYPE_ID%Type := null,
               pi_mcon1_EMERGENCY in employee_contact.EMERGENCY%Type := null,
    -- 2nd contact
               pi_mcon2_FIRST_NAME in contact.FIRST_NAME%Type   := null, 
   	           pi_mcon2_LAST_NAME in contact.LAST_NAME%Type     := null, 
	           pi_mcon2_PHONE_1 in contact.PHONE_1%Type         := null, 
	           pi_mcon2_PHONE_2 in contact.PHONE_2%Type         := null, 
               pi_mcon2_desc_1 in address.add_desc_1%Type       := null,
               pi_mcon2_desc_2 in address.add_desc_2%Type       := null,
               pi_mcon2_city in address.add_city%Type           := null,
               pi_mcon2_postal_code in address.add_postal_code%Type := null,
               pi_mcon2_province_id in address.province_id%Type := null,
               pi_mcon2_country_id in address.country_id%Type   := null,
	           pi_mcon2_GENDER in contact.GENDER%Type           := null, 
	           pi_mcon2_EMAIL_ADDRESS in contact.EMAIL_ADDRESS%Type := null, 
	           pi_mcon2_COMMENTS in contact.COMMENTS%Type       := null,
               pi_mcon2_REL_TYPE_ID in employee_contact.REL_TYPE_ID%Type := null,
               pi_mcon2_EMERGENCY in employee_contact.EMERGENCY%Type := null
) return employee.employee_id%Type;
 
-- ---------------------------------------------------------------------------
-- procedure update_employee()
-- ---------------------------------------------------------------------------
procedure update_employee(
               pi_employee_id in employee.employee_id%Type     ,
               pi_first_name in employee.first_name%Type       , 
               pi_last_name in employee.last_name%Type         , 
               pi_gender in employee.gender%Type               , 
               pi_home_phone in employee.home_phone%Type       := null, 
               pi_cell_phone in employee.cell_phone%Type       := null, 
               pi_work_phone in employee.work_phone%Type       := null, 
               pi_title_id in employee.title_id%Type           := null, 
               pi_email_address in employee.email_address%Type := null, 
               pi_is_teacher in employee.is_teacher%Type       := 'N',
               pi_ss_number in employee.ss_number%Type         := null,
               pi_hire_date in employee.hire_date%Type         := null,
               pi_position_id in employee.position_id%Type     := null,
               pi_department_id in employee.department_id%Type     := null,
    -- Address
               pi_add_id in address.add_id%Type                ,
               pi_add_desc_1 in address.add_desc_1%Type        ,
               pi_add_desc_2 in address.add_desc_2%Type        := null,
               pi_add_city in address.add_city%Type            ,
               pi_add_postal_code in address.add_postal_code%Type,
               pi_province_id in address.province_id%Type      ,
               pi_country_id in address.country_id%Type        ,
               pi_add_fax in address.add_fax%Type := null);
 
-- ---------------------------------------------------------------------------
-- procedure delete_employee()
-- ---------------------------------------------------------------------------
procedure delete_employee(pi_employee_id in employee.employee_id%Type);
 
-- ---------------------------------------------------------------------------
-- procedure create_employee_activity_type()
-- ---------------------------------------------------------------------------
procedure create_employee_activity_type(
        pi_employee_id in employee_activity_type.employee_id%Type     ,
        pi_activity_type_id in employee_activity_type.activity_type_id%Type);
 
-- ---------------------------------------------------------------------------
-- procedure delete_employee_activity_type()
-- ---------------------------------------------------------------------------
procedure delete_employee_activity_type(
        pi_employee_id in employee_activity_type.employee_id%Type     ,
        pi_activity_type_id in employee_activity_type.activity_type_id%Type);
 
END PKG_EMPLOYEE;
