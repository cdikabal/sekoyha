create or replace PACKAGE  "PKG_TASK" AS   
-- =========================================================================   
-- Description   
--  This package is used to manage TASKS  
-- =========================================================================   
-- ============================================================================= 
-- P U B L I C   T Y P E S   A N D   V A R I A B L E S 
-- ============================================================================= 
TYPE VARCHAR_TABLE_TYPE Is Table of Varchar(255); 
-- ============================================================================= 
-- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S  
-- ============================================================================= 
-- ----------------------------------------------------------------------------- 
-- Function get_version()
-- ----------------------------------------------------------------------------- 
Function get_version return varchar2;

-- ----------------------------------------------------------------------------- 
-- function: instanciate()  
-- ----------------------------------------------------------------------------- 
function instanciate(  
    pi_task_template_id in task_template.task_template_id%Type, 
    pi_target_object_id in task.target_object_id%Type, 
    pi_target_object_name in varchar2, 
    pi_field_names in VARCHAR_TABLE_TYPE, 
    pi_field_values in VARCHAR_TABLE_TYPE, 
    pi_login_id in login.login_id%Type default null, 
    pi_max_days in number default 20, 
    pi_deadline in date default null) 
  return task.task_id%Type;   
   
-- ----------------------------------------------------------------------------- 
-- function: instanciate() 
-- ----------------------------------------------------------------------------- 
function instanciate(  
    pi_short_name in task_template.short_name%Type, 
    pi_target_object_code in task_template.target_object_code%Type, 
    pi_target_object_id in task.target_object_id%Type, 
    pi_target_object_name in varchar2, 
    pi_field_names in VARCHAR_TABLE_TYPE, 
    pi_field_values in VARCHAR_TABLE_TYPE, 
    pi_login_id in login.login_id%Type default null, 
    pi_max_days in number default 20, 
    pi_deadline in date default null) 
  return task.task_id%Type;   
-- ----------------------------------------------------------------------------- 
-- function: is_step_completed() 
-- ----------------------------------------------------------------------------- 
function is_step_completed(pi_task_step_id task_step.task_step_id%Type) return varchar2;   
-- ----------------------------------------------------------------------------- 
-- function: is_task_completed() 
-- ----------------------------------------------------------------------------- 
function is_task_completed(pi_task_id task.task_id%Type) return varchar2;   
   
-- ----------------------------------------------------------------------------- 
-- function get_uncompleted_id( ) 
-- ----------------------------------------------------------------------------- 
function get_uncompleted_id(   
     pi_short_name in task.short_name%Type, 
     pi_target_object_code in task.target_object_code%Type, 
     pi_target_object_id in task.target_object_id%Type,  
     pi_login_id in login.login_id%Type default null) 
     return task.task_id%Type;   
-- ----------------------------------------------------------------------------- 
-- procedure complete_step() 
-- ----------------------------------------------------------------------------- 
procedure complete_step( 
   pi_task_step_id in task_step.task_step_id%Type, 
   pi_login_id in login.login_id%Type); 
-- ----------------------------------------------------------------------------- 
-- procedure complete_task() 
-- ----------------------------------------------------------------------------- 
procedure complete_task( 
   pi_task_id in task.task_id%Type, 
   pi_login_id in login.login_id%Type); 
-- ----------------------------------------------------------------------------- 
-- function get_step_id() 
-- ----------------------------------------------------------------------------- 
function get_step_id( 
     pi_task_id in task_step.task_id%Type, 
     pi_tab_order in task_step.tab_order%Type) return task_step.task_step_id%Type; 
-- ----------------------------------------------------------------------------- 
-- function get_task_template_id() 
-- ----------------------------------------------------------------------------- 
function get_task_template_id( 
     pi_short_name in task_template.short_name%Type, 
     pi_target_object_code in task_template.target_object_code%Type) 
  return task_template.task_template_id%Type; 
-- ----------------------------------------------------------------------------- 
-- function get_current_task_record() 
-- ----------------------------------------------------------------------------- 
Function get_current_task_record( 
    pi_short_name in task.short_name%Type,  
    pi_target_object_code in task.target_object_code%Type, 
    pi_target_object_id in task.target_object_id%Type, 
    pi_login_id in login.login_id%Type default null) 
 return task%RowType; 
-- ----------------------------------------------------------------------------- 
-- function get_current_task_record() 
-- ----------------------------------------------------------------------------- 
Function get_current_task_record( 
    pi_task_template_id in task_template.task_template_id%Type, 
    pi_target_object_id in task.target_object_id%Type, 
    pi_login_id in login.login_id%Type default null) 
 return task%RowType; 
 
-- ----------------------------------------------------------------------------- 
-- function get_current_task_record() 
-- ----------------------------------------------------------------------------- 
Function get_current_task_record( 
    pi_action_code in glob_action.action_code%Type, 
    pi_target_object_code in task.target_object_code%Type, 
    pi_target_object_id in task.target_object_id%Type, 
    pi_login_id in login.login_id%Type default null) 
 return task%RowType; 
-- ----------------------------------------------------------------------------- 
-- function get_current_step_record() 
-- ----------------------------------------------------------------------------- 
Function get_current_step_record( 
    pi_short_name in task.short_name%Type,  
    pi_target_object_code in task.target_object_code%Type, 
    pi_target_object_id in task.target_object_id%Type, 
    pi_target_page_id in task_step.target_page_id%Type, 
    pi_login_id in login.login_id%Type default null) 
 return task_step%RowType; 
-- ----------------------------------------------------------------------------- 
-- function get_current_step_record() 
-- ----------------------------------------------------------------------------- 
Function get_current_step_record( 
    pi_task_template_id in task_template.task_template_id%Type, 
    pi_target_object_id in task.target_object_id%Type, 
    pi_target_page_id in task_step.target_page_id%Type, 
    pi_login_id in login.login_id%Type default null) 
 return task_step%RowType; 
-- ----------------------------------------------------------------------------- 
-- function get_step_url() 
-- ----------------------------------------------------------------------------- 
Function get_step_url(pi_task_step_id in task_step.task_step_id%Type, 
    pi_field_names in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE(), 
    pi_field_values in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE()) 
 return varchar2; 
-- ----------------------------------------------------------------------------- 
-- function get_next_step_url() 
-- ----------------------------------------------------------------------------- 
Function get_next_step_url(pi_task_id in task_step.task_id%Type,  
    pi_tab_order in task_step.tab_order%Type, 
    pi_field_names in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE(), 
    pi_field_values in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE(), 
    pi_login_id in login.login_id%Type default null) 
  return varchar2; 
-- ----------------------------------------------------------------------------- 
-- function get_previous_step_url() 
-- ----------------------------------------------------------------------------- 
Function get_previous_step_url(pi_task_id in task_step.task_id%Type,  
    pi_tab_order in task_step.tab_order%Type, 
    pi_field_names in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE(), 
    pi_field_values in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE(), 
    pi_login_id in login.login_id%Type default null) 
  return varchar2; 
-- ----------------------------------------------------------------------------- 
-- function is_object_completed() 
-- ----------------------------------------------------------------------------- 
Function is_object_completed(pi_action_code in glob_action.action_code%Type, 
    pi_target_object_code in task.target_object_code%Type, 
    pi_target_object_id in task.target_object_id%Type) 
  return task.completed%Type; 
END PKG_TASK; 
/
