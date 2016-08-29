create or replace PACKAGE BODY  "PKG_LOGIN" AS
  Function get_position(p_login_name in employee.login_name%Type)
  return varchar2 AS
  l_position position.position_name%Type;
  Begin
    select p.position_name into l_position
      from employee e
           inner join position p on (p.position_id = e.position_id)
     where e.login_name = upper(p_login_name);
    RETURN l_position;
  Exception 
    when NO_DATA_FOUND then null;
    when OTHERS then
       raise_application_error(-20001, 'PKG_LOGIN.get_position('||
          p_login_name||') ## '||sqlerrm);
  End get_position;
-- -----------------------------------------------------------------------------
-- Function: get_id
-- Purpose: Return the login id of an user
-- -----------------------------------------------------------------------------
  Function get_id(pi_apex_username in login.apex_username%type) return login.login_id%Type
  is
    l_login_id login.login_id%Type;
    already_caught exception;
    PRAGMA Exception_Init(already_caught, -20001);
  Begin
    select login_id into l_login_id from login where upper(apex_username) = upper(pi_apex_username);
    return l_login_id;
  Exception
    when already_caught then raise;
    when no_data_found then return null;
    when others then raise_application_error(-20001,'PKG_LOGIN.get_id('||pi_apex_username||') ## '||sqlerrm);
  End get_id;
-- -----------------------------------------------------------------------------
  Function get_login_id(p_apex_username in login.apex_username%type) return login.login_id%Type
  is
    l_login_id login.login_id%Type;
    already_caught exception;
    PRAGMA Exception_Init(already_caught, -20001);
  Begin
    select login_id into l_login_id from login where upper(apex_username) = upper(p_apex_username);
    return l_login_id;
  Exception
    when already_caught then raise;
    when no_data_found then return null;
    when others then raise_application_error(-20001,'PKG_LOGIN.get_id('||p_apex_username||') ## '||sqlerrm);
  End get_login_id;
-- -----------------------------------------------------------------------------
-- Function: get_apex_username
-- Purpose: Return the APEX username of an login
-- -----------------------------------------------------------------------------
  Function get_apex_username(pi_login_id in login.login_id%type) return login.apex_username%Type
  is
    l_apex_username login.apex_username%Type;
    already_caught exception;
    PRAGMA Exception_Init(already_caught, -20001);
  Begin
    select apex_username into l_apex_username from login where login_id = pi_login_id;
    return l_apex_username;
  Exception
    when already_caught then raise;
    when no_data_found then return null;
    when others then raise_application_error(-20001,'PKG_LOGIN.get_apex_username('||pi_login_id||') ## '||sqlerrm);
  End get_apex_username;
-- -----------------------------------------------------------------------------
-- Function: is_authorized()
-- Purpose: Return true if a login is authorized to access a given Menu item
-- -----------------------------------------------------------------------------
-- LOGIN_ID
  Function Is_Authorized(
      pi_login_id in login.login_id%Type,
      pi_menu_id in adm_menu.menu_id%Type) return boolean 
  is
    l_menu_id adm_menu.menu_id%Type := null;
    already_caught exception;
    PRAGMA Exception_Init(already_caught, -20001);
  Begin
    select a.MENU_ID into l_menu_id
      from ADM_MENU_PERMISSION a
           inner join ADM_LOGIN_PERMISSION b on (b.PERMISSION_ID = a.PERMISSION_ID)
     where b.LOGIN_ID = pi_login_id
       and a.MENU_ID = pi_menu_id ;
    return true;
  Exception
    when already_caught then raise;
    --when no_data_found then return false;
    -- For now we return TRUE -- TODO
    when no_data_found then return true;
    when others then raise_application_error(-20001,'PKG_LOGIN.Is_Authorized('||pi_login_id||', '||pi_menu_id||') ## '||sqlerrm);
  End Is_Authorized;
    
-- APEX_USERNAME
  Function Is_Authorized(
      p_apex_username in login.apex_username%Type,
      pi_menu_id in adm_menu.menu_id%Type) return boolean 
  is
    l_menu_id adm_menu.menu_id%Type := null;
    already_caught exception;
    PRAGMA Exception_Init(already_caught, -20001);
  Begin
    select a.MENU_ID into l_menu_id
      from ADM_MENU_PERMISSION a
           inner join ADM_LOGIN_PERMISSION b on (b.PERMISSION_ID = a.PERMISSION_ID)
           inner join LOGIN c on (c.LOGIN_ID = b.LOGIN_ID)
     where upper(c.apex_username) = upper(p_apex_username)
       and a.MENU_ID = pi_menu_id ;
    return true;
  Exception
    when already_caught then raise;
    --when no_data_found then return false;
    -- For now we return TRUE -- TODO
    when no_data_found then return true;
    when others then raise_application_error(-20001,'PKG_LOGIN.Is_Authorized('||p_apex_username ||', '||pi_menu_id||') ## '||sqlerrm);
  End Is_Authorized;

-- ----------------------------------------------------------------------------- 
-- Function get_version()
-- ----------------------------------------------------------------------------- 
  Function get_version return varchar2 is
	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
  Begin
    return '$Id$';
  Exception
    When ALREADY_CAUGHT then raise;
    When OTHERS THEN 
      raise_application_error(-20001, 'PKG_LOGIN.get_version() - '||sqlerrm);
  End get_version;

END PKG_LOGIN;
/

select pkg_login.get_version() from dual;