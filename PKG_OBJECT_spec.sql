create or replace PACKAGE  "PKG_OBJECT" as 
-- ============================================================================= 
-- P R I V A T E   F U N C T I O N S   A N D   P R O C E D U R E S 
-- ============================================================================= 
Function Get_Record ( 
   pi_object_code in glob_object.object_abbreviation%Type) 
   return glob_object%RowType; 
function Get_Short_Name ( 
   pi_object_code in glob_object.object_abbreviation%Type) 
   return varchar2; 
function Get_Name ( 
   pi_object_code in glob_object.object_abbreviation%Type) 
   return varchar2; 
function Get_Code ( 
   pi_object_name in glob_object.object_name%Type) 
   return varchar2; 
function Get_String ( 
   pi_object_code in glob_object.object_abbreviation%Type, 
   pi_object_id in number) 
   Return varchar2; 
function Get_Full_String ( 
   pi_object_code in glob_object.object_abbreviation%Type, 
   pi_object_id in number) 
   Return varchar2; 
-- ----------------------------------------------------------------------------- 
-- Get_Next_Id 
--  Get the next ID based on GLOB_OBJECT description 
-- ----------------------------------------------------------------------------- 
function Get_Next_Id ( 
   pi_object_code in glob_object.object_abbreviation%Type) 
   return number; 
 
-- ----------------------------------------------------------------------------- 
-- Function get_version()
-- ----------------------------------------------------------------------------- 
Function get_version return varchar2;

-- ----------------------------------------------------------------------------- 
-- Procedure Add_Instance_Comments()
-- ----------------------------------------------------------------------------- 
Procedure Add_Instance_Comments(
     pi_target_object_code in glob_object.object_abbreviation%Type,
     pi_target_object_id in number,
     pi_comments in varchar2,
	 pi_login_id in login.login_id%Type);

end PKG_OBJECT; 
