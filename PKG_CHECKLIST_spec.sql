create or replace PACKAGE  "PKG_CHECKLIST" AS   
-- =========================================================================   
-- Description   
--  This package is used to manage CHECKLISTS  
-- =========================================================================   
-- ============================================================================= 
-- P U B L I C   T Y P E S   A N D   V A R I A B L E S 
-- ============================================================================= 
-- ============================================================================= 
-- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S  
-- ============================================================================= 
-- ----------------------------------------------------------------------------- 
-- function get_version()
-- ----------------------------------------------------------------------------- 
function get_version return varchar2;

-- ----------------------------------------------------------------------------- 
-- function: get_template_rec()  
-- ----------------------------------------------------------------------------- 
function get_template_rec( 
    pi_checklist_template_id in checklist_template.checklist_template_id%Type) 
  return checklist_template%RowType;   
 
function get_template_rec( 
    pi_short_name in checklist_template.short_name%Type, 
    pi_target_object_code in checklist_template.target_object_code%Type) 
  return checklist_template%RowType;   
 
-- ----------------------------------------------------------------------------- 
-- function: get_template_line_cursor()  
-- ----------------------------------------------------------------------------- 
function get_template_line_cursor( 
    pi_checklist_template_id in checklist_template.checklist_template_id%Type) 
  return SYS_REFCURSOR;   
 
function get_template_line_cursor( 
    pi_short_name in checklist_template.short_name%Type, 
    pi_target_object_code in checklist_template.target_object_code%Type) 
  return SYS_REFCURSOR;   
 
-- ----------------------------------------------------------------------------- 
-- function: instanciate()  
-- ----------------------------------------------------------------------------- 
function instanciate(  
    pi_checklist_template_id in checklist_template.checklist_template_id%Type, 
    pi_target_object_id in task.target_object_id%Type, 
    pi_target_object_name in varchar2) 
  return checklist.checklist_id%Type;   
   
-- ----------------------------------------------------------------------------- 
-- function: instanciate() 
-- ----------------------------------------------------------------------------- 
function instanciate(  
    pi_short_name in checklist_template.short_name%Type, 
    pi_target_object_code in checklist_template.target_object_code%Type, 
    pi_target_object_id in task.target_object_id%Type, 
    pi_target_object_name in varchar2) 
  return checklist.checklist_id%Type;   
-- ----------------------------------------------------------------------------- 
-- function get_unchecked_id( ) 
-- ----------------------------------------------------------------------------- 
function get_unchecked_id(   
     pi_short_name in task.short_name%Type, 
     pi_target_object_code in task.target_object_code%Type, 
     pi_target_object_id in task.target_object_id%Type,  
     pi_login_id in login.login_id%Type default null) 
     return checklist.checklist_id%Type;   

-- ----------------------------------------------------------------------------- 
-- procedure check_line() 
--   Execute the "check function" on checklist's line and set the
--   appropriate flag according to the result
-- ----------------------------------------------------------------------------- 
procedure check_line( 
   pi_checklist_line_id in checklist_line.checklist_line_id%Type, 
   pi_login_id in login.login_id%Type); 
-- ----------------------------------------------------------------------------- 
-- procedure check_it() 
-- Desciption
--   Execute the "check function" on each line of a checklist and set the
--   appropriate flag according to the result
-- ----------------------------------------------------------------------------- 
procedure check_it( 
   pi_checklist_id in checklist.checklist_id%Type, 
   pi_login_id in login.login_id%Type); 
   
-- ----------------------------------------------------------------------------- 
-- function get_checklist_template_id() 
-- ----------------------------------------------------------------------------- 
function get_checklist_template_id( 
     pi_short_name in checklist_template.short_name%Type, 
     pi_target_object_code in checklist_template.target_object_code%Type) 
  return checklist_template.checklist_template_id%Type; 
-- ----------------------------------------------------------------------------- 
-- function get_current_checklist() 
-- ----------------------------------------------------------------------------- 
Function get_current_checklist( 
    pi_short_name in checklist.short_name%Type,  
    pi_target_object_code in checklist.target_object_code%Type, 
    pi_target_object_id in checklist.target_object_id%Type) 
 return checklist%RowType; 
-- ----------------------------------------------------------------------------- 
-- function get_current_checklist() 
-- ----------------------------------------------------------------------------- 
Function get_current_checklist( 
    pi_checklist_template_id in checklist_template.checklist_template_id%Type, 
    pi_target_object_id in checklist.target_object_id%Type) 
 return checklist%RowType; 
 
-- ----------------------------------------------------------------------------- 
-- function: get_uncompleted_id()  
-- ----------------------------------------------------------------------------- 
function get_uncompleted_id(   
     pi_short_name in checklist.short_name%Type, 
     pi_target_object_code in checklist.target_object_code%Type, 
     pi_target_object_id in checklist.target_object_id%Type) 
    return checklist.checklist_id%Type ; 
     
-- ----------------------------------------------------------------------------- 
-- Function get_checklist_url()
-- ----------------------------------------------------------------------------- 
Function get_checklist_url(pi_checklist_id in checklist.checklist_id%Type, 
    pi_field_names in pkg_task.VARCHAR_TABLE_TYPE default pkg_task.VARCHAR_TABLE_TYPE(), 
    pi_field_values in pkg_task.VARCHAR_TABLE_TYPE default pkg_task.VARCHAR_TABLE_TYPE()) 
  return varchar2; 
 
-- ----------------------------------------------------------------------------- 
-- Procedure Complete_Checklist() 
-- ----------------------------------------------------------------------------- 
Procedure Complete_Checklist(pi_checklist_id in checklist.checklist_id%Type, pi_login_id in number := 1); 
Procedure Un_Complete_Checklist(pi_checklist_id in checklist.checklist_id%Type); 
 
-- ----------------------------------------------------------------------------- 
-- Procedure Complete_Line() 
-- ----------------------------------------------------------------------------- 
Procedure Complete_Line(
     pi_checklist_line_id in checklist_line.checklist_line_id%Type
	 , pi_login_id in number := 1
	 , pi_comments in checklist.comments%Type := null); 
Procedure Un_Complete_Line(
     pi_checklist_line_id in checklist_line.checklist_line_id%Type
	 , pi_comments in checklist.comments%Type := null); 
 
-- ----------------------------------------------------------------------------- 
-- function get_current_checklist_count() 
-- ----------------------------------------------------------------------------- 
Function get_current_checklist_count( 
    pi_target_object_code in checklist.target_object_code%Type, 
    pi_target_object_id in checklist.target_object_id%Type) 
 return number; 
 
-- ----------------------------------------------------------------------------- 
-- function get_completed_checklist_count() 
-- ----------------------------------------------------------------------------- 
Function get_completed_checklist_count( 
    pi_target_object_code in checklist.target_object_code%Type, 
    pi_target_object_id in checklist.target_object_id%Type) 
 return number; 
 
-- ----------------------------------------------------------------------------- 
-- function get_completed_line_count() 
-- ----------------------------------------------------------------------------- 
Function get_completed_line_count( 
    pi_target_object_code in checklist.target_object_code%Type, 
    pi_target_object_id in checklist.target_object_id%Type) 
 return number; 
 
-- ----------------------------------------------------------------------------- 
-- Procedure Add_Comments() 
-- ----------------------------------------------------------------------------- 
Procedure Add_Comments(
    pi_checklist_id in checklist.checklist_id%Type
	, pi_comments in checklist.comments%Type := null
	, pi_login_id in checklist.check_by_login_id%Type);

-- ----------------------------------------------------------------------------- 
-- Procedure Add_line_Comments() 
-- ----------------------------------------------------------------------------- 
Procedure Add_line_Comments(
    pi_checklist_line_id in checklist_line.checklist_line_id%Type
    , pi_comments in checklist_line.comments%Type := null
	, pi_login_id in checklist_line.check_by_login_id%Type);

-- ----------------------------------------------------------------------------- 
-- procedure check_all() 
-- Desciption
--   Execute the "check function" on each line of a checklist and set the
--   appropriate flag according to the result
-- ----------------------------------------------------------------------------- 
procedure check_all( 
   pi_target_object_code in checklist.target_object_code%Type, 
   pi_target_object_id in checklist.target_object_id%Type,
   pi_login_id in login.login_id%Type); 
   
END PKG_CHECKLIST; 
