create or replace PACKAGE  "PKG_TENANT" AS  
-- ========================================================================= 
-- Description 
-- This package is used to manage GLOB_TENANT entity 
-- ========================================================================= 
-- ============================================================================= 
-- P U B L I C   T Y P E S ,   C O N S T A N T S   A N D   V A R I A B L E S 
-- ============================================================================= 
-- ============================================================================= 
-- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S 
-- ============================================================================= 
-- ----------------------------------------------------------------------------- 
-- Function: create_replace() 
-- ----------------------------------------------------------------------------- 
function create_replace(pi_tenant_name     in GLOB_TENANT.TENANT_NAME%Type, 
                           pi_tenant_appid    in GLOB_TENANT_SITE.TENANT_APPID%Type,
						   pi_tenant_website  in GLOB_TENANT.TENANT_WEBSITE%Type := null,
						   pi_TENANT_DBA_NAME in GLOB_TENANT.TENANT_DBA_NAME%Type := null,
						   pi_DESCRIPTION     in GLOB_TENANT.DESCRIPTION%Type := null,
						   pi_LOGO_URL        in GLOB_TENANT.LOGO_URL%Type := null,
						   pi_COUNTRY_ID      in GLOB_TENANT.COUNTRY_ID%Type := 1,
						   pi_PROVINCE_ID     in GLOB_TENANT.PROVINCE_ID%Type := 12)
return GLOB_TENANT.TENANT_ID%Type; 
-- ----------------------------------------------------------------------------- 
-- Function: get_id 
-- Returns the ID of a tenant based on it's application id or it's name 
-- ----------------------------------------------------------------------------- 
function get_id(pi_tenant_appid in GLOB_TENANT_SITE.TENANT_APPID%Type)  
return GLOB_TENANT.TENANT_ID%Type; 
function get_id(pi_tenant_name in GLOB_TENANT.TENANT_NAME%Type) 
return GLOB_TENANT.TENANT_ID%Type; 
function get_name(pi_tenant_appid in GLOB_TENANT_SITE.TENANT_APPID%Type)  
return GLOB_TENANT.TENANT_NAME%Type; 
function get_name(pi_tenant_id in GLOB_TENANT.TENANT_ID%Type)  
return GLOB_TENANT.TENANT_NAME%Type; 
-- ----------------------------------------------------------------------------- 
-- Function: get_current_id 
-- Returns the current TENANT ID 
-- ----------------------------------------------------------------------------- 
function get_current_id return GLOB_TENANT.TENANT_ID%Type; 

-- ----------------------------------------------------------------------------- 
-- Function: get_current_name 
-- Returns the current TENANT NAME 
-- ----------------------------------------------------------------------------- 
function get_current_name return GLOB_TENANT.TENANT_NAME%Type; 

-- ----------------------------------------------------------------------------- 
-- Function: is_locked_out 
-- Returns the locked out status of the current tenant 
-- ----------------------------------------------------------------------------- 
function is_locked_out return boolean; 

-- ----------------------------------------------------------------------------- 
-- Function: is_locked_out 
-- Returns the locked out status of a given tenant 
-- ----------------------------------------------------------------------------- 
function is_locked_out(pi_tenant_id in GLOB_TENANT.TENANT_ID%Type) return boolean; 
function is_locked_out(pi_tenant_appid in GLOB_TENANT_SITE.TENANT_APPID%Type) return boolean; 

-- ----------------------------------------------------------------------------- 
-- Function: set_current 
-- Set the current TENANT ID 
-- ----------------------------------------------------------------------------- 
procedure set_current(pi_tenant_appid in GLOB_TENANT_SITE.TENANT_APPID%Type); 
procedure set_current(pi_tenant_name in GLOB_TENANT.TENANT_NAME%Type); 
procedure set_current(pi_tenant_id in GLOB_TENANT.TENANT_ID%Type); 

-- ----------------------------------------------------------------------------- 
-- function get_property_value()
-- ----------------------------------------------------------------------------- 
function get_property_value(
   pi_property_key in GLOB_TENANT_PROPERTIES.property_key%Type, 
   pi_tenant_id in GLOB_TENANT_PROPERTIES.tenant_id%Type := pkg_tenant.get_current_id())
   return GLOB_TENANT_PROPERTIES.property_value%Type;
   
-- ----------------------------------------------------------------------------- 
-- funtion get_version()
-- ----------------------------------------------------------------------------- 
function get_version return varchar2;

-- ----------------------------------------------------------------------------- 
-- procedure Initialize_Checklist()
-- ----------------------------------------------------------------------------- 
procedure Initialize_Checklist(
      pi_source_tenant_id in GLOB_TENANT.tenant_id%Type
	  , pi_target_tenant_id in GLOB_TENANT.tenant_id%Type);

-- ----------------------------------------------------------------------------- 
-- procedure Initialize_Task_Tmpl()
-- ----------------------------------------------------------------------------- 
  procedure Initialize_Task_Tmpl(
      pi_source_tenant_id in GLOB_TENANT.tenant_id%Type
	  , pi_target_tenant_id in GLOB_TENANT.tenant_id%Type);

-- ----------------------------------------------------------------------------- 
-- procedure Initialize_Ref_Data()
-- ----------------------------------------------------------------------------- 
procedure Initialize_Ref_Data(
      pi_source_tenant_id in GLOB_TENANT.tenant_id%Type
	  , pi_target_tenant_id in GLOB_TENANT.tenant_id%Type);

-- ----------------------------------------------------------------------------- 
-- function Initialize_Ref_Table()
-- ----------------------------------------------------------------------------- 
function Initialize_Ref_Table(
      pi_source_tenant_id in GLOB_TENANT.tenant_id%Type
	  , pi_target_tenant_id in GLOB_TENANT.tenant_id%Type
	  , pi_table_name in varchar2) return number;

END PKG_TENANT; 
/

show error