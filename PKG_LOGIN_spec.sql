create or replace PACKAGE  "PKG_LOGIN" AS 
-- ----------------------------------------------------------------------------- 
-- Function: get_position 
-- Purpose: Return the position of an employee using his login id 
-- ----------------------------------------------------------------------------- 
Function get_position(p_login_name in employee.login_name%Type) 
return varchar2; 
-- ----------------------------------------------------------------------------- 
-- Function: get_id 
-- Purpose: Return the login id of an user 
-- ----------------------------------------------------------------------------- 
Function get_id(pi_apex_username in login.apex_username%type) return login.login_id%Type; 
Function get_login_id(p_apex_username in login.apex_username%type) return login.login_id%Type; 
-- ----------------------------------------------------------------------------- 
-- Function: get_apex_username 
-- Purpose: Return the APEX username of an login 
-- ----------------------------------------------------------------------------- 
Function get_apex_username(pi_login_id in login.login_id%type) return login.apex_username%Type; 
 
-- ----------------------------------------------------------------------------- 
-- Function: is_authorized() 
-- Purpose: Return true if a login is authorized to access a given Menu item 
-- ----------------------------------------------------------------------------- 
Function Is_Authorized( 
      pi_login_id in login.login_id%Type, 
      pi_menu_id in adm_menu.menu_id%Type) return boolean ; 
 
Function Is_Authorized( 
      p_apex_username in login.apex_username%Type, 
      pi_menu_id in adm_menu.menu_id%Type) return boolean ; 
 
-- ----------------------------------------------------------------------------- 
-- Function get_version()
-- ----------------------------------------------------------------------------- 
Function get_version return varchar2;

END PKG_LOGIN; 
/
