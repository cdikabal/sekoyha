create or replace PACKAGE BODY  "PKG_TENANT" AS
-- =============================================================================
-- P R I V A T E   G L O B A L   V A R I A B L E S   A N D   T Y P E S
-- =============================================================================
   Type Tenant_Record is RECORD (
     tenant_id GLOB_TENANT.tenant_id%Type,
     tenant_name GLOB_TENANT.tenant_name%Type,
     tenant_website GLOB_TENANT.tenant_website%Type,
     logo_url GLOB_TENANT.logo_url%Type,
     is_locked_out GLOB_TENANT.is_locked_out%Type,
     is_active GLOB_TENANT.is_active%Type,
     country_id GLOB_TENANT.country_id%Type,
     province_id GLOB_TENANT.province_id%Type,
     tenant_appid GLOB_TENANT_SITE.tenant_appid%Type
   );
   g_current_tenant Tenant_Record;
-- -----------------------------------------------------------------------------
-- P R I V A T E   P R O C E D U R E S   A N D   F U N C T I O N S
-- -----------------------------------------------------------------------------
   function local_get_tenant_record(pi_tenant_id in glob_tenant.tenant_id%Type)
   return Tenant_Record is
     l_glob_tenant_record Tenant_Record;
   Begin
     select t.tenant_id, t.tenant_name, t.tenant_website, t.logo_url,
            t.is_locked_out, t.is_active,
            t.country_id, t.province_id, to_number(null) as tenant_appid 
     INTO l_glob_tenant_record.tenant_id, l_glob_tenant_record.tenant_name, 
          l_glob_tenant_record.tenant_website, l_glob_tenant_record.logo_url,
          l_glob_tenant_record.is_locked_out, l_glob_tenant_record.is_active,
          l_glob_tenant_record.country_id, l_glob_tenant_record.province_id, 
          l_glob_tenant_record.tenant_appid
       from glob_tenant t 
      where t.tenant_id = pi_tenant_id;
     return l_glob_tenant_record;
   Exception
     when no_data_found then return null;
     when others then raise;
   End local_get_tenant_record;
   
-- -----------------------------------------------------------------------------
-- function local_get_tenant_record()
-- -----------------------------------------------------------------------------
   function local_get_tenant_record(pi_tenant_appid in glob_tenant_site.tenant_appid%Type)
   return Tenant_Record is
     l_glob_tenant_record Tenant_Record;
   Begin
     select t.tenant_id, t.tenant_name, t.tenant_website, t.logo_url,
            t.is_locked_out, t.is_active,
            t.country_id, t.province_id, s.tenant_appid 
     INTO l_glob_tenant_record.tenant_id, l_glob_tenant_record.tenant_name, 
          l_glob_tenant_record.tenant_website, l_glob_tenant_record.logo_url,
          l_glob_tenant_record.is_locked_out, l_glob_tenant_record.is_active,
          l_glob_tenant_record.country_id, l_glob_tenant_record.province_id, 
          l_glob_tenant_record.tenant_appid
       from glob_tenant t
            inner join glob_tenant_site s on (s.tenant_id = t.tenant_id)
      where s.tenant_appid = pi_tenant_appid;
     return l_glob_tenant_record;
   Exception
     --when no_data_found then return null;
     when no_data_found then raise;
     when others then raise;
   End local_get_tenant_record;

-- -----------------------------------------------------------------------------
-- function local_get_tenant_record()
-- -----------------------------------------------------------------------------
   function local_get_tenant_record(pi_tenant_name in glob_tenant.tenant_name%Type)
   return Tenant_Record is
     l_glob_tenant_record Tenant_Record;
   Begin
     select t.tenant_id, t.tenant_name, t.tenant_website, t.logo_url,
            t.is_locked_out, t.is_active,
            t.country_id, t.province_id, null as tenant_appid
       into l_glob_tenant_record
       /*
     INTO l_glob_tenant_record.tenant_id, l_glob_tenant_record.tenant_name, 
          l_glob_tenant_record.tenant_website, l_glob_tenant_record.logo_url,
          l_glob_tenant_record.is_locked_out, l_glob_tenant_record.is_active,
          l_glob_tenant_record.country_id, l_glob_tenant_record.province_id, 
          l_glob_tenant_record.tenant_appid
          */
     from glob_tenant t
      where t.tenant_name = pi_tenant_name;
     return l_glob_tenant_record;
   Exception
     when no_data_found then return null;
     when others then raise;
   End local_get_tenant_record;
   
-- -----------------------------------------------------------------------------
-- function local_get_checklist_tmpl_id()
-- -----------------------------------------------------------------------------
  function local_get_checklist_tmpl_id(
     pi_tenant_id in mlt_checklist_template.TENANT_ID%Type
	 , pi_short_name in mlt_checklist_template.SHORT_NAME%Type
	 , pi_target_object_code in mlt_checklist_template.TARGET_OBJECT_CODE%Type
	 ) return mlt_checklist_template.CHECKLIST_TEMPLATE_ID%Type is
    ls_id mlt_checklist_template.CHECKLIST_TEMPLATE_ID%Type;
  begin
	select x.CHECKLIST_TEMPLATE_ID
	  into ls_id
	  from mlt_checklist_template x
	 where x.TENANT_ID = pi_tenant_id
	   and x.SHORT_NAME = pi_short_name
	   and x.TARGET_OBJECT_CODE = pi_target_object_code;
	--
	return ls_id;
  exception
    when no_data_found then return null;
	when others then
      raise_application_error(-20001, 
       'pkg_tenant.local_get_checklist_tmpl_id('||pi_tenant_id||', '||pi_short_name||', '||pi_target_object_code||') - '||sqlerrm);
  end local_get_checklist_tmpl_id;
  
-- -----------------------------------------------------------------------------
-- function local_get_task_tmpl_id()
-- -----------------------------------------------------------------------------
  function local_get_task_tmpl_id(
     pi_tenant_id in mlt_checklist_template.TENANT_ID%Type
	 , pi_short_name in mlt_checklist_template.SHORT_NAME%Type
	 , pi_target_object_code in mlt_checklist_template.TARGET_OBJECT_CODE%Type
	 ) return mlt_task_template.TASK_TEMPLATE_ID%Type is
    ls_id mlt_task_template.TASK_TEMPLATE_ID%Type;
  begin
	select x.TASK_TEMPLATE_ID
	  into ls_id
	  from mlt_task_template x
	 where x.TENANT_ID = pi_tenant_id
	   and x.SHORT_NAME = pi_short_name
	   and x.TARGET_OBJECT_CODE = pi_target_object_code;
	--
	return ls_id;
  exception
    when no_data_found then return null;
	when others then
      raise_application_error(-20001, 
       'pkg_tenant.local_get_task_tmpl_id('||pi_tenant_id||', '||pi_short_name||', '||pi_target_object_code||') - '||sqlerrm);
  end local_get_task_tmpl_id;
  
-- -----------------------------------------------------------------------------
-- function local_execute_dml()
-- -----------------------------------------------------------------------------
  function local_execute_dml(pi_dml_string in varchar2) return number is
  begin
    execute immediate pi_dml_string;
	return sql%RowCount;
  exception
    when no_data_found then return null;
	when others then
      raise_application_error(-20001, 
       'pkg_tenant.local_execute_dml('||pi_dml_string||') - '||sqlerrm);
  end local_execute_dml;

-- =============================================================================
-- P U B L I C   P R O C E D U R E S   A N D   F U N C T I O N S
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
   return GLOB_TENANT.TENANT_ID%Type is
     l_tenant_id GLOB_TENANT.tenant_id%Type;
  	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
   Begin
     l_tenant_id := pkg_tenant.get_id(pi_tenant_appid => pi_tenant_appid);
	 --
	 if l_tenant_id is not null then
	   update GLOB_TENANT t
	      set t.TENANT_NAME = nvl(pi_tenant_name, t.TENANT_NAME)
		where TENANT_ID = l_tenant_id;
	   return l_tenant_id;
	 end if;
	 --
	 Insert Into GLOB_TENANT
	   (TENANT_ID, TENANT_NAME, ACTIVATION_DATE, TENANT_WEBSITE, TENANT_DBA_NAME, DESCRIPTION, LOGO_URL, COUNTRY_ID, PROVINCE_ID, CREATE_DATE, LAST_UPDATE_DATE)
	 Values (1, pi_tenant_name, sysdate, pi_tenant_website, pi_TENANT_DBA_NAME, pi_DESCRIPTION, pi_LOGO_URL, nvl(pi_COUNTRY_ID, 1), nvl(pi_PROVINCE_ID, 12), sysdate, sysdate)
	 Returning TENANT_ID into l_tenant_id;
	 --
	 Insert Into GLOB_TENANT_SITE(TENANT_APPID, SITE_NAME, SITE_URL, DESCRIPTION, TENANT_ID, SITE_TYPE_ID)
	 Values (pi_TENANT_APPID, 'TBD', 'TBD', 'None', l_tenant_id, 1) ;
	 --
     return l_tenant_id;
   Exception
     When ALREADY_CAUGHT then raise;
	 When OTHERS then
	    raise_application_error(-20001, 'pkg_tenant.create_replace('||pi_tenant_name||','||pi_tenant_appid||') - '||sqlerrm);
   End create_replace;

-- -----------------------------------------------------------------------------
-- Function: get_id
-- Returns the ID of a tenant based on it's application id or it's name
-- -----------------------------------------------------------------------------
   function get_id(pi_tenant_appid in GLOB_TENANT_SITE.TENANT_APPID%Type) 
   return GLOB_TENANT.TENANT_ID%Type is
     l_tenant_id GLOB_TENANT.TENANT_ID%Type;
	--
  	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
   Begin
     select tenant_id INTO l_tenant_id from glob_tenant_site  
      where tenant_appid = pi_tenant_appid;
     return l_tenant_id;
   Exception
     When NO_DATA_FOUND then return null;
     When ALREADY_CAUGHT then raise;
	 When OTHERS then
	    raise_application_error(-20001, 'pkg_tenant.get_id[1](pi_tenant_appid='||pi_tenant_appid||') - '||sqlerrm);
   End get_id;
   
   function get_id(pi_tenant_name in GLOB_TENANT.TENANT_NAME%Type)
   return GLOB_TENANT.TENANT_ID%Type is
     l_tenant_id GLOB_TENANT.TENANT_ID%Type;
	--
  	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
   Begin
     select tenant_id INTO l_tenant_id from glob_tenant  
      where tenant_name = pi_tenant_name;
     return l_tenant_id;
   Exception
     When NO_DATA_FOUND then return null;
     When ALREADY_CAUGHT then raise;
	 When OTHERS then
	    raise_application_error(-20001, 'pkg_tenant.get_id[2](pi_tenant_name='||pi_tenant_name||') - '||sqlerrm);
   End get_id;
   
-- -----------------------------------------------------------------------------
-- function get_name() 
-- -----------------------------------------------------------------------------
   function get_name(pi_tenant_appid in GLOB_TENANT_SITE.TENANT_APPID%Type) 
   return GLOB_TENANT.TENANT_NAME%Type is
     l_tenant_name GLOB_TENANT.TENANT_NAME%Type;
	--
  	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
   Begin
     select t.tenant_name INTO l_tenant_name 
       from glob_tenant t 
            inner join glob_tenant_site s on (s.tenant_id = t.tenant_id)
      where s.tenant_appid = pi_tenant_appid;
     return l_tenant_name;
   Exception
     When NO_DATA_FOUND then return null;
     When ALREADY_CAUGHT then raise;
	 When OTHERS then
	    raise_application_error(-20001, 'pkg_tenant.get_name[1](pi_tenant_appid='||pi_tenant_appid||') - '||sqlerrm);
   End get_name;
   
   function get_name(pi_tenant_id in GLOB_TENANT.TENANT_ID%Type) 
   return GLOB_TENANT.TENANT_NAME%Type is
     l_tenant_name GLOB_TENANT.TENANT_NAME%Type;
	--
  	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
   Begin
     select tenant_name INTO l_tenant_name from glob_tenant  
      where tenant_id = pi_tenant_id;
     return l_tenant_name;
   Exception
     When NO_DATA_FOUND then return null;
     When ALREADY_CAUGHT then raise;
	 When OTHERS then
	    raise_application_error(-20001, 'pkg_tenant.get_name[2](pi_tenant_id='||pi_tenant_id||') - '||sqlerrm);
   End get_name;
   
-- -----------------------------------------------------------------------------
-- Function: get_current
-- Returns the current TENANT ID
-- -----------------------------------------------------------------------------
   function get_current_id return GLOB_TENANT.TENANT_ID%Type is
   Begin
     if nv('APP_ID') is not null then return get_id(pi_tenant_appid => nv('APP_ID'));
     else return g_current_tenant.tenant_id;
     end if;
   End get_current_id;
   
-- -----------------------------------------------------------------------------
-- Function: get_current_name
-- Returns the current TENANT NAME
-- -----------------------------------------------------------------------------
   function get_current_name return GLOB_TENANT.TENANT_NAME%Type is
   Begin
     if nv('APP_ID') is not null then return get_name(pi_tenant_appid => nv('APP_ID'));
     else return g_current_tenant.tenant_name;
     end if;
   End get_current_name;
   
-- -----------------------------------------------------------------------------
-- Function: is_locked_out
-- Returns the locked out status of the current tenant
-- -----------------------------------------------------------------------------
   function is_locked_out return boolean is
     l_is_locked_out GLOB_TENANT.IS_LOCKED_OUT%Type;
	--
  	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
   Begin
     if nv('APP_ID') is not null then
       select IS_LOCKED_OUT into l_is_locked_out
         from GLOB_TENANT
        where TENANT_ID = pkg_tenant.get_id( pi_tenant_appid => nv('APP_ID') );
        return l_is_locked_out = 'Y';
     else
       return (case when g_current_tenant.tenant_id is not null then (g_current_tenant.is_locked_out = 'Y') else null end);
     end if;
   Exception
     When NO_DATA_FOUND then return null;
     When ALREADY_CAUGHT then raise;
	 When OTHERS then
	    raise_application_error(-20001, 'pkg_tenant.is_locked_out[1]() - '||sqlerrm);
   End is_locked_out;
   
-- -----------------------------------------------------------------------------
-- Function: is_locked_out
-- Returns the locked out status of a given tenant
-- -----------------------------------------------------------------------------
   function is_locked_out(pi_tenant_id in GLOB_TENANT.TENANT_ID%Type) return boolean is
     l_is_locked_out GLOB_TENANT.IS_LOCKED_OUT%Type;
	--
  	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
   Begin
     if pi_tenant_id is null then
       return is_locked_out();
     else
       select IS_LOCKED_OUT into l_is_locked_out
         from GLOB_TENANT
        where TENANT_ID = pi_tenant_id;
        return l_is_locked_out = 'Y';
     end if;
   Exception
     when no_data_found then return null;
     When ALREADY_CAUGHT then raise;
	 When OTHERS then
	    raise_application_error(-20001, 'pkg_tenant.is_locked_out[2](pi_tenant_id='||pi_tenant_id||') - '||sqlerrm);
   End is_locked_out;
   --
   function is_locked_out(pi_tenant_appid in GLOB_TENANT_SITE.TENANT_APPID%Type) return boolean is
     l_is_locked_out GLOB_TENANT.IS_LOCKED_OUT%Type;
	--
  	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
   Begin
     if pi_tenant_appid is null then
       return is_locked_out();
     else
       select IS_LOCKED_OUT into l_is_locked_out
         from GLOB_TENANT
        where TENANT_ID = pi_tenant_appid;
        return l_is_locked_out = 'Y';
     end if;
   Exception
     when no_data_found then return null;
     When ALREADY_CAUGHT then raise;
	 When OTHERS then
	    raise_application_error(-20001, 'pkg_tenant.is_locked_out[3](pi_tenant_appid='||pi_tenant_appid||') - '||sqlerrm);
   End is_locked_out;

-- -----------------------------------------------------------------------------
-- Function: set_current
-- Set the current TENANT ID
-- -----------------------------------------------------------------------------
   procedure set_current(pi_tenant_appid in GLOB_TENANT_SITE.TENANT_APPID%Type) is
   Begin
     g_current_tenant := local_get_tenant_record(pi_tenant_appid => pi_tenant_appid);
     --pkg_context.set_current_tenant_id(pi_appid => pi_tenant_appid);
   End set_current;
   procedure set_current(pi_tenant_name in GLOB_TENANT.TENANT_NAME%Type) is
     l_tenant_appid GLOB_TENANT_SITE.TENANT_APPID%Type := local_get_tenant_record(pi_tenant_name => pi_tenant_name).tenant_appid;
   Begin
     g_current_tenant := local_get_tenant_record(pi_tenant_name => pi_tenant_name);
     --pkg_context.set_current_tenant_id(pi_appid => l_tenant_appid);
   End set_current;
   procedure set_current(pi_tenant_id in GLOB_TENANT.TENANT_ID%Type) is
     l_tenant_appid GLOB_TENANT_SITE.TENANT_ID%Type := local_get_tenant_record(pi_tenant_id => pi_tenant_id).tenant_appid;
   Begin
     g_current_tenant := local_get_tenant_record(pi_tenant_id => pi_tenant_id);
     --pkg_context.set_current_tenant_id(pi_appid => l_tenant_appid);
   End set_current;

-- ----------------------------------------------------------------------------- 
-- function get_property_value()
-- ----------------------------------------------------------------------------- 
   function get_property_value(
      pi_property_key in GLOB_TENANT_PROPERTIES.property_key%Type, 
      pi_tenant_id in GLOB_TENANT_PROPERTIES.tenant_id%Type := pkg_tenant.get_current_id())
   return GLOB_TENANT_PROPERTIES.property_value%Type is
    l_property_value GLOB_TENANT_PROPERTIES.property_value%Type;
  	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
   Begin
     select nvl((select GTPR.property_value 
	               from GLOB_TENANT_PROPERTIES GTPR 
				  where GTPR.tenant_id = pkg_tenant.get_current_id() 
				    and GTPR.property_key = GPKY.property_key)
			    , GPKY.property_default)
	   into l_property_value
	   from GLOB_PROPERTY_KEY GPKY
	  where upper(GPKY.property_key) = upper(pi_property_key);
	 return l_property_value;
  Exception
    When NO_DATA_FOUND then return null;
    When ALREADY_CAUGHT then raise;
    When OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_tenant.get_property_value(key='||pi_property_key||', tenant='||pi_tenant_id||') - '||sqlerrm);
  End get_property_value;

-- -------------------------------------------------------------------------
-- Function: get_version()
-- -------------------------------------------------------------------------
  function get_version return varchar2 is  
	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
  Begin
    return '$Id$';
  Exception
    When ALREADY_CAUGHT then raise;
    When OTHERS THEN 
      raise_application_error(-20001, 'pkg_tenant.get_version() - '||sqlerrm);
  End get_version;

-- ----------------------------------------------------------------------------- 
-- funtion Initialize_Checklist()
-- ----------------------------------------------------------------------------- 
  procedure Initialize_Checklist(
      pi_source_tenant_id in GLOB_TENANT.tenant_id%Type
	  , pi_target_tenant_id in GLOB_TENANT.tenant_id%Type)
  is
  l_CHECKLIST_TEMPLATE_ID mlt_checklist_template.CHECKLIST_TEMPLATE_ID%Type;
  l_CHECKLIST_LINE_TEMPLATE_ID MLT_CHECKLIST_LINE_TEMPLATE.CHECKLIST_LINE_TEMPLATE_ID%Type;
  l_new_tenant_id mlt_checklist_template.TENANT_ID%Type := pi_target_tenant_id;
  --
	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
  begin
    for r1 in (
     select s.CHECKLIST_TEMPLATE_ID, s.SHORT_NAME, s.LONG_NAME, s.TARGET_OBJECT_CODE, s.TARGET_PAGE_ID, s.DFLT_ASSIGN_TO_DEPARTMENT_ID
       from mlt_checklist_template s
      where s.TENANT_ID = pi_source_tenant_id  
		)
    loop
      l_CHECKLIST_TEMPLATE_ID := local_get_checklist_tmpl_id(pi_tenant_id=>l_new_tenant_id, pi_short_name=>r1.SHORT_NAME, pi_target_object_code=>r1.TARGET_OBJECT_CODE);
	  --
	  if l_CHECKLIST_TEMPLATE_ID is null then
        insert into mlt_checklist_template(
        CHECKLIST_TEMPLATE_ID, SHORT_NAME, LONG_NAME, TARGET_OBJECT_CODE, TARGET_PAGE_ID, DFLT_ASSIGN_TO_DEPARTMENT_ID
	    , TENANT_ID, DELETED)
	    values (
         1, r1.SHORT_NAME, r1.LONG_NAME, r1.TARGET_OBJECT_CODE, r1.TARGET_PAGE_ID, r1.DFLT_ASSIGN_TO_DEPARTMENT_ID
	     , l_new_tenant_id, 'N')
        returning CHECKLIST_TEMPLATE_ID into l_CHECKLIST_TEMPLATE_ID;
	    dbms_output.put_line('-> New MLT_CHECKLIST_TEMPLATE entry <'|| l_CHECKLIST_TEMPLATE_ID||'> created');
	  else
	    delete from MLT_CHECKLIST_LINE_TEMPLATE where CHECKLIST_TEMPLATE_ID = l_CHECKLIST_TEMPLATE_ID;
	    dbms_output.put_line('-> Existing MLT_CHECKLIST_TEMPLATE entry <'|| l_CHECKLIST_TEMPLATE_ID||'> updated - '||
	                        sql%RowCount||' record(s) deleted from MLT_CHECKLIST_LINE_TEMPLATE');
	  end if;
      --
	  for r2 in (
        select s.CHECKLIST_TEMPLATE_ID, s.SHORT_NAME, s.LONG_NAME, s.DESCRIPTION, s.IS_MANDATORY, s.CHECK_FUNCTION
	      from MLT_CHECKLIST_LINE_TEMPLATE s
	     where s.CHECKLIST_TEMPLATE_ID = r1.CHECKLIST_TEMPLATE_ID)
  	  loop
        insert into MLT_CHECKLIST_LINE_TEMPLATE(
          CHECKLIST_TEMPLATE_ID, CHECKLIST_LINE_TEMPLATE_ID, SHORT_NAME, LONG_NAME, DESCRIPTION
	      , IS_MANDATORY, CHECK_FUNCTION, TENANT_ID, DELETED)
	    values (
	      l_CHECKLIST_TEMPLATE_ID, 1, r2.SHORT_NAME, r2.LONG_NAME, r2.DESCRIPTION, r2.IS_MANDATORY, r2.CHECK_FUNCTION
	      , l_new_tenant_id, 'N')
	     returning CHECKLIST_LINE_TEMPLATE_ID into l_CHECKLIST_LINE_TEMPLATE_ID;
	    --
        dbms_output.put_line(chr(9)||'- New MLT_CHECKLIST_LINE_TEMPLATE entry: '|| l_CHECKLIST_LINE_TEMPLATE_ID);
	  end loop;
    end loop;
  Exception
    When ALREADY_CAUGHT then raise;
    When OTHERS THEN 
      raise_application_error(-20001, 'pkg_tenant.Initialize_Checklist('||pi_source_tenant_id||', '||pi_target_tenant_id||') - '||sqlerrm);
  end Initialize_Checklist;

-- ----------------------------------------------------------------------------- 
-- funtion Initialize_Task_Tmpl()
-- ----------------------------------------------------------------------------- 
  procedure Initialize_Task_Tmpl(
      pi_source_tenant_id in GLOB_TENANT.tenant_id%Type
	  , pi_target_tenant_id in GLOB_TENANT.tenant_id%Type)
  is
  l_TASK_TEMPLATE_ID mlt_task_template.TASK_TEMPLATE_ID%Type;
  l_TASK_STEP_TEMPLATE_ID MLT_TASK_STEP_TEMPLATE.TASK_STEP_TEMPLATE_ID%Type;
  l_new_tenant_id mlt_task_template.TENANT_ID%Type := pi_target_tenant_id;
  --
	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
  begin
    for r1 in (
     select s.TASK_TEMPLATE_ID, s.SHORT_NAME, s.LONG_NAME, s.DESCRIPTION, s.TARGET_OBJECT_CODE, s.ESTIMATE_HOUR
       from mlt_task_template s
      where s.TENANT_ID = pi_source_tenant_id  
		)
    loop
      l_TASK_TEMPLATE_ID := local_get_task_tmpl_id(pi_tenant_id=>l_new_tenant_id, pi_short_name=>r1.SHORT_NAME, pi_target_object_code=>r1.TARGET_OBJECT_CODE);
	  --
	  if l_TASK_TEMPLATE_ID is null then
        insert into mlt_task_template(
        TASK_TEMPLATE_ID, SHORT_NAME, LONG_NAME, DESCRIPTION, TARGET_OBJECT_CODE, ESTIMATE_HOUR
	    , TENANT_ID, DELETED)
	    values (
         1, r1.SHORT_NAME, r1.LONG_NAME, r1.DESCRIPTION, r1.TARGET_OBJECT_CODE, r1.ESTIMATE_HOUR
	     , l_new_tenant_id, 'N')
        returning TASK_TEMPLATE_ID into l_TASK_TEMPLATE_ID;
	    dbms_output.put_line('-> New MLT_CHECKLIST_TEMPLATE entry <'|| l_TASK_TEMPLATE_ID||'> created');
	  else
	    delete from MLT_TASK_STEP_TEMPLATE where TASK_TEMPLATE_ID = l_TASK_TEMPLATE_ID;
	    dbms_output.put_line('-> Existing MLT_CHECKLIST_TEMPLATE entry <'|| l_TASK_TEMPLATE_ID||'> updated - '||
	                        sql%RowCount||' record(s) deleted from MLT_TASK_STEP_TEMPLATE');
	  end if;
      --
	  for r2 in (
        select s.TASK_STEP_TEMPLATE_ID, s.SHORT_NAME, s.LONG_NAME, s.DESCRIPTION, s.TAB_ORDER
		       , s.TARGET_PAGE_ID, s.ESTIMATE_HOUR, s.DFLT_ASSIGN_TO_DEPARTMENT_ID
	      from MLT_TASK_STEP_TEMPLATE s
	     where s.TASK_TEMPLATE_ID = r1.TASK_TEMPLATE_ID)
  	  loop
        insert into MLT_TASK_STEP_TEMPLATE(
          TASK_TEMPLATE_ID, TASK_STEP_TEMPLATE_ID, SHORT_NAME, LONG_NAME, DESCRIPTION
	      , TAB_ORDER, TARGET_PAGE_ID, ESTIMATE_HOUR, DFLT_ASSIGN_TO_DEPARTMENT_ID, TENANT_ID, DELETED)
	    values (
	      l_TASK_TEMPLATE_ID, 1, r2.SHORT_NAME, r2.LONG_NAME, r2.DESCRIPTION, r2.TAB_ORDER, r2.TARGET_PAGE_ID
		  , r2.ESTIMATE_HOUR, r2.DFLT_ASSIGN_TO_DEPARTMENT_ID
	      , l_new_tenant_id, 'N')
	     returning TASK_STEP_TEMPLATE_ID into l_TASK_STEP_TEMPLATE_ID;
	    --
        dbms_output.put_line(chr(9)||'- New MLT_TASK_STEP_TEMPLATE entry: '|| l_TASK_STEP_TEMPLATE_ID);
	  end loop;
    end loop;
  Exception
    When ALREADY_CAUGHT then raise;
    When OTHERS THEN 
      raise_application_error(-20001, 'pkg_tenant.Initialize_Task_Tmpl('||pi_source_tenant_id||', '||pi_target_tenant_id||') - '||sqlerrm);
  end Initialize_Task_Tmpl;
  
-- ----------------------------------------------------------------------------- 
-- procedure Initialize_Ref_Data()
-- ----------------------------------------------------------------------------- 
  procedure Initialize_Ref_Data(
      pi_source_tenant_id in GLOB_TENANT.tenant_id%Type
	  , pi_target_tenant_id in GLOB_TENANT.tenant_id%Type) is
  --
    l_count number := 0;
	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
  Begin
    for tab in (select o.OBJECT_NAME, o.OBJECT_ABBREVIATION
                  from glob_object o where o.IS_GLOBAL = 'N' and o.IS_REF_DATA = 'Y'
	               and o.OBJECT_NAME not in ('MLT_CHECKLIST_LINE_TEMPLATE', 'MLT_TASK_STEP_TEMPLATE')
				 order by 1 desc)
	loop
	  dbms_output.put('=> Initializing '||tab.OBJECT_NAME||' ('||tab.OBJECT_ABBREVIATION||'): ');
	  if tab.OBJECT_NAME = 'MLT_CHECKLIST_TEMPLATE' then
	    dbms_output.put_line('');
	    pkg_tenant.Initialize_Checklist(
          pi_source_tenant_id   => pi_source_tenant_id
	      , pi_target_tenant_id => pi_target_tenant_id);
	  elsif tab.OBJECT_NAME = 'MLT_TASK_TEMPLATE' then
	    dbms_output.put_line('');
	    pkg_tenant.Initialize_Task_Tmpl(
          pi_source_tenant_id   => pi_source_tenant_id
	      , pi_target_tenant_id => pi_target_tenant_id);
	  else
	    l_count := pkg_tenant.Initialize_Ref_Table(
          pi_source_tenant_id   => pi_source_tenant_id
	      , pi_target_tenant_id => pi_target_tenant_id
	      , pi_table_name       => tab.OBJECT_NAME		);
	    dbms_output.put_line(l_count||' record(s) processed.');
	  end if;
	end loop;
  Exception
    When ALREADY_CAUGHT then raise;
    When OTHERS THEN 
      raise_application_error(-20001, 'pkg_tenant.Initialize_Ref_Data() - '||sqlerrm);
  End Initialize_Ref_Data;
-- ----------------------------------------------------------------------------- 
-- procedure Initialize_Ref_Table()
-- ----------------------------------------------------------------------------- 
  function Initialize_Ref_Table(
      pi_source_tenant_id in GLOB_TENANT.tenant_id%Type
	  , pi_target_tenant_id in GLOB_TENANT.tenant_id%Type
	  , pi_table_name in varchar2) return number is
  l_Insert_String varchar2(4000);
  l_Select_String varchar2(4000);
  l_Delete_String varchar2(4000);
  l_comma varchar2(3) := '';
  l_count number := 0;
  --
	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
  Begin
    for rec in 
     (Select tc.column_name, case when pkc.constraint_name is null then 'N' else 'Y' end as is_primary
        from user_tab_columns tc
            left outer join 
		          (select x.table_name, x.constraint_name, y.column_name
                     from user_constraints x
                         inner join user_cons_columns y on (y.constraint_name = x.constraint_name)
                    where x.constraint_type = 'P') pkc 
                  on (pkc.table_name = tc.table_name and pkc.column_name = tc.column_name)
       where tc.table_name = pi_table_name
         and tc.column_name not in 
	         ('CREATE_BY_LOGIN_ID', 'UPDATE_BY_LOGIN_ID', 'CREATE_DATE', 'LAST_UPDATE_DATE', 'DELETED_DATE', 'TENANT_ID')
  	  order by 2 desc nulls last )
    loop
       l_Insert_String := l_Insert_String|| l_comma ||rec.column_name;
	   if rec.is_primary = 'Y' then 
         l_Select_String := l_Select_String|| l_comma ||'1';
	   else
         l_Select_String := l_Select_String|| l_comma ||rec.column_name;
	   end if;
	   --
	   l_comma := ','||chr(10);
     end loop;
     --
	 l_Delete_String := 'Delete From '||pi_table_name||' Where TENANT_ID = '||pi_target_tenant_id;
     l_Insert_String := 'Insert into '||pi_table_name||'('||chr(10)||l_Insert_String||l_comma||'TENANT_ID)';
     l_Select_String := 'Select '||chr(10)||l_Select_String||l_comma||pi_target_tenant_id||chr(10)||
                      '  From '||pi_table_name||chr(10)||
					  ' Where TENANT_ID = '||pi_source_tenant_id||' and DELETED = ''N''';
     --
	 /*
     dbms_output.put_line(l_Delete_String);
     dbms_output.put_line(l_Insert_String);
     dbms_output.put_line(l_Select_String);	
	 */
	 --
	 l_count := local_execute_dml(l_Delete_String);
	 l_count := local_execute_dml(l_Insert_String||' '||l_Select_String);
	 --
	 return l_count;
  Exception
    When ALREADY_CAUGHT then raise;
    When OTHERS THEN 
      raise_application_error(-20001, 'pkg_tenant.Initialize_Ref_Table('||pi_source_tenant_id||', '||pi_target_tenant_id||', '||pi_table_name||') - '||sqlerrm);
  End Initialize_Ref_Table;

END PKG_TENANT;
/


Select pkg_tenant.get_version() from dual;	