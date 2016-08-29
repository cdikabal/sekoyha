create or replace PACKAGE  "PKG_STUDENT" Is 

-- =========================================================================  
-- Description  
--  This package is used to manage STUDENT entity  
-- List of public procedures and functions  
-- =========================================================================  
 
Function create_or_replace (pi_student_record in student%RowType )  
return student.student_id%Type;  
   
function create_replace(  
               p_first_name in student.first_name%Type,  
               p_last_name in student.last_name%Type,  
               p_gender in student.gender%Type,  
               p_birth_date in student.birth_date%Type,  
               p_health_card in student.health_card%Type,  
               p_dr_id in student.dr_id%Type,  
               p_add_id in student.add_id%Type,
			   p_par1_parent_id in parent.parent_id%Type := null,
			   p_par2_parent_id in parent.parent_id%Type := null
			   ) 
  return student.student_id%Type;  
  
function create_replace(  
               p_student_id in student.student_id%Type,  
               p_first_name in student.first_name%Type,  
               p_last_name in student.last_name%Type,  
               p_gender in student.gender%Type,  
               p_birth_date in student.birth_date%Type,  
               p_health_card in student.health_card%Type,  
               p_dr_id in student.dr_id%Type,  
               p_add_id in student.add_id%Type, 
               p_tylenol_ifneeded in student.tylenol_ifneeded%Type := null,
			   p_par1_parent_id in parent.parent_id%Type := null,
			   p_par2_parent_id in parent.parent_id%Type := null
			   )  
  return student.student_id%Type;  
function create_replace(  
               p_student_id in student.student_id%Type,  
               p_student_number in student.student_id%Type, 
               p_first_name in student.first_name%Type,  
               p_last_name in student.last_name%Type,  
               p_middle_name in student.middle_name%Type, 
               p_usual_name in student.usual_name%Type, 
               p_gender in student.gender%Type,  
               p_birth_date in student.birth_date%Type,  
               p_birth_country_id in student.birth_country_id%Type, 
               p_birth_city in student.birth_city%Type, 
               p_country_id in student.country_id%Type,
               p_add_id in student.add_id%Type := null,
			   p_par1_parent_id in parent.parent_id%Type := null,
			   p_par2_parent_id in parent.parent_id%Type := null
               )  
  return student.student_id%Type;  
function is_created(  
     p_first_name in student.first_name%Type,  
     p_last_name in student.last_name%Type)   
     return boolean;  
function is_created(  
     p_student_id in student.student_id%Type) 
     return boolean;  
function get_id(  
     p_first_name in student.first_name%Type,  
     p_last_name in student.last_name%Type)   
     return student.student_id%Type;  
function get_id(  
     p_student_number in student.student_number%Type)   
     return student.student_id%Type;  
  
procedure set_parent_student( 
     p_student_id in parent_student.student_id%Type, 
     p_parent_id in parent_student.parent_id%Type, 
     p_rel_type_id in parent_student.rel_type_id%Type); 
procedure set_student_contact( 
     p_student_id in student_contact.student_id%Type,  
     p_contact_id in student_contact.contact_id%Type,  
     p_rel_type_id in student_contact.rel_type_id%Type,  
     p_emergency in student_contact.emergency%Type default 'Y'); 
function register_in( 
     p_student_id in inscription.student_id%Type, 
     p_school_year_id in inscription.school_year_id%Type, 
     p_grade_type_id in inscription.grade_type_id%Type, 
     p_class_id in inscription.class_id%Type, 
     p_ins_date in inscription.ins_date%Type default sysdate, 
     p_ins_comments in inscription.ins_comments%Type default null)  
     return inscription.ins_id%Type; 
function get_name(p_student_id in student.student_id%Type) 
  return varchar2; 
function get_XML(p_student_id in student.student_id%Type, p_add_xml_header in boolean default true) 
  return clob; 
 
-- ----------------------------------------------------------------------------- 
-- Function: Get_Multi_XML() 
-- ----------------------------------------------------------------------------- 
function get_multi_XML(p_where_clause in varchar2) 
  return clob; 
 
-- ----------------------------------------------------------------------------- 
-- Function: Is_New() 
-- ----------------------------------------------------------------------------- 
function is_new(p_student_id in student.student_id%Type) return boolean; 
 
-- ----------------------------------------------------------------------------- 
-- Function: Get_Next_Student_Number() 
-- ----------------------------------------------------------------------------- 
   Function Get_Next_Student_Number return student.student_number%type; 
 
-- ----------------------------------------------------------------------------- 
-- Function: Convert 
-- ----------------------------------------------------------------------------- 
Function Convert(p_applicant_id in applicant.applicant_id%Type) return student.student_number%type; 
 
-- ----------------------------------------------------------------------------- 
-- Function: Get_String() 
-- ----------------------------------------------------------------------------- 
Function get_string(pi_student_id in student.student_id%Type) return varchar2; 

-- ----------------------------------------------------------------------------- 
-- function get_version()
-- ----------------------------------------------------------------------------- 
function get_version return varchar2;

-- ----------------------------------------------------------------------------- 
-- Completion check functions
-- ----------------------------------------------------------------------------- 
Function contact_exists(pi_student_id in student.student_id%Type) return varchar2;
Function check_health_info(pi_student_id in student.student_id%Type) return varchar2; 
Function parent_exists(pi_student_id in student.student_id%Type) return varchar2; 
Function check_student_demographic(pi_student_id in student.student_id%Type) return varchar2; 
Function account_exists(pi_student_id in student.student_id%Type) return varchar2; 
Function photo_exists(pi_student_id in student.student_id%Type) return varchar2; 

-- ----------------------------------------------------------------------------- 
-- Procedure create_all_checklists()
-- ----------------------------------------------------------------------------- 
Procedure create_all_checklists(pi_student_id in student.student_id%Type);

-- ----------------------------------------------------------------------------- 
-- Function create_checklist()
-- ----------------------------------------------------------------------------- 
Function create_checklist(
   pi_student_id in student.student_id%Type
   , pi_short_name in checklist_template.short_name%Type) 
   return checklist.checklist_id%Type;

END PKG_STUDENT; 
/
