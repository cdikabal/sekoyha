create or replace PACKAGE  "PKG_PARENT" AS   
-- =========================================================================   
-- Description   
--  This package is used to manage PARENT entity   
-- List of public procedures and functions   
-- =========================================================================   
  
-- -------------------------------------------------------------------------  
-- Function create_or_replace[1] - Parent record  
-- -------------------------------------------------------------------------  
function create_or_replace( pi_parent_record parent%RowType )  
  return parent.parent_id%Type;  
   
-- -------------------------------------------------------------------------  
-- Function create_or_replace[2] - No ID  
-- -------------------------------------------------------------------------  
function create_or_replace(   
               pi_first_name in parent.first_name%Type,   
               pi_last_name in parent.last_name%Type,   
               pi_gender in parent.gender%Type,   
               pi_cell_phone in parent.cell_phone%Type,   
               pi_work_phone in parent.work_phone%Type,   
               pi_email_address in parent.email_address%Type,   
               pi_add_id in parent.add_id%Type,  
               pi_middle_name in parent.middle_name%Type := null, 
               pi_parent_number in parent.parent_number%Type := null,
               pi_occupation in parent.occupation%Type := null,   
               pi_title_id in parent.title_id%Type := null,
               pi_company_name in parent.company_name%Type := null)  
  return parent.parent_id%Type;   
   
-- -------------------------------------------------------------------------  
-- Function create_or_replace[3] - ID is provided  
-- -------------------------------------------------------------------------  
function create_or_replace(   
               pi_parent_id in parent.parent_id%Type,   
               pi_first_name in parent.first_name%Type,   
               pi_last_name in parent.last_name%Type,   
               pi_middle_name in parent.middle_name%Type,   
               pi_gender in parent.gender%Type,   
               pi_cell_phone in parent.cell_phone%Type,   
               pi_work_phone in parent.work_phone%Type,   
               pi_occupation in parent.occupation%Type,   
               pi_title_id in parent.title_id%Type,   
               pi_company_name in parent.company_name%Type,  
               pi_email_address in parent.email_address%Type,   
               pi_add_id in parent.add_id%Type, 
               pi_parent_number in parent.parent_number%Type := null)   
  return parent.parent_id%Type;   
  
-- -------------------------------------------------------------------------  
-- Procedure set_parent_student
-- -------------------------------------------------------------------------  
procedure set_parent_student(
       pi_parent_id in parent.parent_id%Type, 
	   pi_student_id in student.student_id%type,
	   pi_rel_type_id in parent_student.rel_type_id%type,
	   pi_is_primary in parent_student.is_primary%type := 'N');
-- -------------------------------------------------------------------------  
-- Function is_created(   
-- -------------------------------------------------------------------------  
  function is_created(   
     pi_first_name in parent.first_name%Type,   
     pi_last_name in parent.last_name%Type)    
     return boolean;   
  
  function is_created( pi_parent_id in parent.parent_id%Type)   
     return boolean;   
  
-- -------------------------------------------------------------------------  
-- Function get_id(   
-- -------------------------------------------------------------------------  
  function get_id(   
     pi_first_name in parent.first_name%Type,   
     pi_last_name in parent.last_name%Type)    
     return parent.parent_id%Type;   
  
  Function get_id(pi_parent_number in parent.parent_number%Type) 
     return parent.parent_id%Type; 
 
-- -------------------------------------------------------------------------  
-- Function get_like_id(   
-- -------------------------------------------------------------------------  
  function get_like_id(   
     pi_first_name in parent.first_name%Type,   
     pi_last_name in parent.last_name%Type)    
     return parent.parent_id%Type;   
   
-- -------------------------------------------------------------------------  
-- Function get_name()  
-- -------------------------------------------------------------------------  
  function get_name(  
     pi_parent_id in parent.parent_id%Type) return varchar2;  
  
-- -------------------------------------------------------------------------  
-- Function get_other_parent_id()  
-- -------------------------------------------------------------------------  
  function get_other_parent_id(  
     pi_parent_id in parent.parent_id%Type) return parent.parent_id%Type;  
  
-- -------------------------------------------------------------------------  
-- Function get_other_parent_name()  
-- -------------------------------------------------------------------------  
  function get_other_parent_name(  
     pi_parent_id in parent.parent_id%Type) return varchar2;  
  
END PKG_PARENT;  
