create or replace PACKAGE  "PKG_TUTORING" as 
-- =============================================================================================== 
-- Package: PKG_TUTORING 
-- Contains all the business logic used for enrollment 
-- =============================================================================================== 

-- =========================================================================  
-- P U B L I C   T Y P E S   A N D   C O N S T A N T S
-- =========================================================================  
TYPE CRITERIA_RECORD is Record ( 
  Field_Name varchar2(64), Operator_Name varchar2(64), Value varchar2(512)); 
TYPE CRITERIA_TAB_TYPE is Table of CRITERIA_RECORD INDEX BY BINARY_INTEGER; 
 
  K_APPL_REVIEW_CHEKLIST_NAME CONSTANT checklist_template.short_name%Type := 'Application Review'; 
  K_APPLICANT_OBJECT_CODE CONSTANT glob_object.object_abbreviation%Type := 'MAPP'; 
 
-- =========================================================================  
-- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S
-- =========================================================================  
-- -------------------------------------------------------------------------
-- Function get_version()
-- -------------------------------------------------------------------------
function get_version return varchar2;

 -- ======================================== 
-- Student functions and procedures 
-- ======================================== 
procedure create_student(pi_vw_student_record in vw_student_tutoring%RowType); 
procedure update_student(pi_vw_student_record in vw_student_tutoring%RowType); 
procedure delete_student(pi_student_id in student.student_id%Type); 
function get_student(pi_student_id in student.student_id%Type) return vw_student_tutoring%RowType; 
function get_students(pi_criterias in CRITERIA_TAB_TYPE) return SYS_REFCURSOR; 
 
procedure create_student_checklist(pi_student_id in student.student_id%Type); 
 
end PKG_TUTORING; 
/
