create or replace PACKAGE BODY  "PKG_CHECKLIST" AS  
-- =============================================================================
-- P R I V A T E   T Y P E S   A N D   V A R I A B L E S
-- =============================================================================
function local_execute_check(pi_select in varchar2, pi_object_id in number) return varchar2 is
  l_result varchar2(512);
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  begin
    dbms_output.put(pi_select||' using '||pi_object_id);
    execute immediate pi_select into l_result using pi_object_id ;
  exception
    when no_data_found then l_result := 'N/A';
    when others then l_result := sqlcode;
  end;
  dbms_output.put_line(' => Result = '||l_result);
  return l_result;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'PKG_CHECKLIST.local_execute_check() ## '||sqlerrm);
End local_execute_check;

-- =============================================================================
-- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S 
-- =============================================================================
-- ----------------------------------------------------------------------------- 
-- function get_version()
-- ----------------------------------------------------------------------------- 
function get_version return varchar2 is
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  return '$Id$' ;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'PKG_CHECKLIST.get_version() ## '||sqlerrm);
End get_version;

-- -----------------------------------------------------------------------------
-- function: get_template_rec() 
-- -----------------------------------------------------------------------------
function get_template_rec(
    pi_checklist_template_id in checklist_template.checklist_template_id%Type)
  return checklist_template%RowType is
  --
  l_template_rec checklist_template%RowType;
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  select * into l_template_rec from checklist_template where checklist_template_id = pi_checklist_template_id;
  return l_template_rec ;
Exception
  when no_data_found then 
     raise_application_error(-20001, 'pkg_checklist.get_template_rec[1](TemplateID= '||pi_checklist_template_id||') ## '||sqlerrm);
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.get_template_rec[1](TemplateID= '||pi_checklist_template_id||') ## '||sqlerrm);
End get_template_rec;

function get_template_rec(
    pi_short_name in checklist_template.short_name%Type,
    pi_target_object_code in checklist_template.target_object_code%Type)
  return checklist_template%RowType is
  --
  l_template_rec checklist_template%RowType;
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  select * into l_template_rec 
    from checklist_template chkt
   where upper(chkt.short_name) = upper(pi_short_name)
     and upper(chkt.target_object_code) = upper(pi_target_object_code);
  return l_template_rec ;
Exception
  when no_data_found then 
     raise_application_error(-20001, 'pkg_checklist.get_template_rec[2]('||pi_short_name||','||pi_target_object_code||') ## '||sqlerrm);
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.get_template_rec[2]('||pi_short_name||','||pi_target_object_code||') ## '||sqlerrm);
End get_template_rec;
-- -----------------------------------------------------------------------------
-- function: get_template_line_cursor() 
-- -----------------------------------------------------------------------------
function get_template_line_cursor(
    pi_checklist_template_id in checklist_template.checklist_template_id%Type)
  return SYS_REFCURSOR is
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
-- TODO
  return null;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.get_template_line_cursor[1](TemplateID='||pi_checklist_template_id  ||') ## '||sqlerrm);
End get_template_line_cursor;
function get_template_line_cursor(
    pi_short_name in checklist_template.short_name%Type,
    pi_target_object_code in checklist_template.target_object_code%Type)
  return SYS_REFCURSOR is
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  return null;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.get_template_line_cursor[2]('||pi_short_name||','||pi_target_object_code ||') ## '||sqlerrm);
End get_template_line_cursor;
-- -----------------------------------------------------------------------------
-- function: instanciate() 
-- -----------------------------------------------------------------------------
function instanciate( 
    pi_checklist_template_id in checklist_template.checklist_template_id%Type,
    pi_target_object_id in task.target_object_id%Type,
    pi_target_object_name in varchar2)
  return checklist.checklist_id%Type is
  --
  l_template_rec checklist_template%RowType := get_template_rec(pi_checklist_template_id => pi_checklist_template_id );
  l_checklist_id checklist.checklist_id%Type;
  l_checklist_name checklist.short_name%Type;
  l_total_checks number;
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  l_checklist_name := l_template_rec.short_name||' < ' ||pi_target_object_name||' >';
  l_checklist_id := get_uncompleted_id(  
     pi_short_name => l_checklist_name,
     pi_target_object_code => l_template_rec.target_object_code,
     pi_target_object_id => pi_target_object_id);
  --
  if l_checklist_id is not null then return l_checklist_id; end if;
  --
/*
  if l_login_id is null then l_login_id := pkg_login.get_login_id(p_apex_username => nvl(v('APP_USER'), 'ADMIN')); end if;
  --dbms_output.put_line('-> Login ID = '||l_login_id);
  l_department_id := pkg_employee.get_record(p_login_id => l_login_id).department_id;
  --dbms_output.put_line('-> Department ID = '||l_department_id);
  --
*/
  Insert Into MLT_CHECKLIST(short_name, long_name, target_object_code, target_object_id, checked, target_page_id, tenant_id, deleted)
  Values (l_checklist_name, 
          l_template_rec.short_name||' < ' ||pi_target_object_name||' >', 
      l_template_rec.target_object_code, pi_target_object_id, 'N', l_template_rec.target_page_id,
	  pkg_tenant.get_current_id(), 'N')
   Returning checklist_id into l_checklist_id;
  --
  --dbms_output.put('-> Task created ');
  /*
  l_checklist_id := get_uncompleted_id(  
     pi_short_name => l_checklist_name,
     pi_target_object_code => l_template_rec.target_object_code,
     pi_target_object_id => pi_target_object_id);
  */
  --dbms_output.put_line('- ID = '||l_task_id);
  --
  select count(1) into l_total_checks from checklist_line_template st where st.checklist_template_id = pi_checklist_template_id;
  --
  for rec in (select rownum as rn, short_name, long_name, description, is_mandatory, check_function
                from checklist_line_template st
               where st.checklist_template_id = pi_checklist_template_id)
  loop
    Insert into checklist_line(short_name, long_name, description, checklist_id, checked, is_mandatory, check_function)
    Values(rec.short_name, l_checklist_name||' ('||rec.rn||'/'||l_total_checks||') - '||rec.short_name, 
        rec.description, l_checklist_id, 'N', rec.is_mandatory, rec.check_function);
    --
  end loop;
  --
  return l_checklist_id;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.instanciate[1](TemplateID= '||pi_checklist_template_id||') ## '||sqlerrm);
End instanciate;
  
-- -----------------------------------------------------------------------------
-- function: instanciate()
-- -----------------------------------------------------------------------------
function instanciate( 
    pi_short_name in checklist_template.short_name%Type,
    pi_target_object_code in checklist_template.target_object_code%Type,
    pi_target_object_id in task.target_object_id%Type,
    pi_target_object_name in varchar2)
  return checklist.checklist_id%Type
is
  l_template_rec checklist_template%RowType := 
       get_template_rec(pi_short_name => pi_short_name, pi_target_object_code => pi_target_object_code );
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  return 
    instanciate(
       pi_checklist_template_id => l_template_rec.checklist_template_id,
       pi_target_object_name  => pi_target_object_name ,
       pi_target_object_id => pi_target_object_id );
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.instanciate(ShortName= '||pi_short_name||', '||pi_target_object_code||') ## '||sqlerrm);
End instanciate;
-- -----------------------------------------------------------------------------
-- function get_unchecked_id( )
-- -----------------------------------------------------------------------------
function get_unchecked_id(  
     pi_short_name in task.short_name%Type,
     pi_target_object_code in task.target_object_code%Type,
     pi_target_object_id in task.target_object_id%Type, 
     pi_login_id in login.login_id%Type default null)
     return checklist.checklist_id%Type 
is
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
-- TODO
  return null;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.get_unchecked_id(ShortName= '||pi_short_name||', '||pi_target_object_code||') ## '||sqlerrm);
End get_unchecked_id;
-- -----------------------------------------------------------------------------
-- procedure check_line()
-- -----------------------------------------------------------------------------
procedure check_line(
   pi_checklist_line_id in checklist_line.checklist_line_id%Type,
   pi_login_id in login.login_id%Type)
is
  l_checklist_line checklist_line%RowType;
  l_TARGET_OBJECT_ID checklist.TARGET_OBJECT_ID%Type;
  l_CHECK_FUNCTION checklist_line.CHECK_FUNCTION%Type;
  l_result varchar2(512);
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  select t.CHECK_FUNCTION, r.TARGET_OBJECT_ID
  into l_CHECK_FUNCTION, l_TARGET_OBJECT_ID 
  from checklist_line t
       inner join checklist r on (r.checklist_id = t.checklist_id)
  where t.checklist_line_id = pi_checklist_line_id;
  --
  if l_CHECK_FUNCTION is not null then
    l_result := local_execute_check('select '||l_CHECK_FUNCTION||' from dual', l_TARGET_OBJECT_ID); 
  end if;
  --
  if l_result = 'Y' then 
    pkg_checklist.Complete_Line(pi_checklist_line_id => pi_checklist_line_id, pi_login_id => pi_login_id
	     , pi_comments => 'Succefully executed automatic check function.');
  else
    pkg_checklist.Un_Complete_Line(pi_checklist_line_id => pi_checklist_line_id
	     , pi_comments => 'Automatic check function failed.');
  end if;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.check_line( '||pi_checklist_line_id||', '||pi_login_id||') ## '||sqlerrm);
End check_line;
-- -----------------------------------------------------------------------------
-- procedure check_it()
-- -----------------------------------------------------------------------------
procedure check_it(
   pi_checklist_id in checklist.checklist_id%Type,
   pi_login_id in login.login_id%Type)
is
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  for rec in (select checklist_line_id from checklist_line t where t.checklist_id = pi_checklist_id)
  loop
     pkg_checklist.check_line(pi_checklist_line_id => rec.checklist_line_id, pi_login_id => pi_login_id);
  end loop;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.check_it( '||pi_checklist_id||', '||pi_login_id||') ## '||sqlerrm);
End check_it;
-- -----------------------------------------------------------------------------
-- function get_checklist_template_id()
-- -----------------------------------------------------------------------------
function get_checklist_template_id(
     pi_short_name in checklist_template.short_name%Type,
     pi_target_object_code in checklist_template.target_object_code%Type)
  return checklist_template.checklist_template_id%Type
is
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
-- TODO
  return null;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.get_checklist_template_id( '||pi_short_name||', '||pi_target_object_code||') ## '||sqlerrm);
End get_checklist_template_id;
-- -----------------------------------------------------------------------------
-- function get_current_checklist()
-- -----------------------------------------------------------------------------
Function get_current_checklist( 
    pi_short_name in checklist.short_name%Type,  
    pi_target_object_code in checklist.target_object_code%Type, 
    pi_target_object_id in checklist.target_object_id%Type) 
 return checklist%RowType
is
  l_checklist_record checklist%RowType;
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  select chkl.* into l_checklist_record
    from checklist chkl
   where upper(chkl.SHORT_NAME) = upper(pi_short_name)
     and upper(chkl.TARGET_OBJECT_CODE) = upper(pi_target_object_code)
	 and chkl.TARGET_OBJECT_ID = pi_target_object_id;
	 --and chkl.CHECKED <> 'Y';
  --
  return l_checklist_record;
Exception
  when No_Data_Found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.get_current_checklist( '||pi_short_name||', '||pi_target_object_code||') ## '||sqlerrm);
End get_current_checklist;
-- -----------------------------------------------------------------------------
-- function get_current_checklist()
-- -----------------------------------------------------------------------------
Function get_current_checklist(
    pi_checklist_template_id in checklist_template.checklist_template_id%Type, 
    pi_target_object_id in checklist.target_object_id%Type) 
 return checklist%RowType is
  l_checklist_record checklist%RowType;
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  select chkl.* into l_checklist_record
    from checklist_template chkt 
	  inner join checklist chkl on (upper(chkl.SHORT_NAME) like upper(chkt.SHORT_NAME)||'%' and upper(chkl.TARGET_OBJECT_CODE) = upper(chkt.TARGET_OBJECT_CODE))
   where chkt.checklist_template_id = pi_checklist_template_id
	 and chkl.TARGET_OBJECT_ID = pi_target_object_id;
	 --and chkl.CHECKED <> 'Y';
  return l_checklist_record;
Exception
  when No_Data_Found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.get_current_checklist( Template ID='||pi_checklist_template_id||', '||pi_target_object_id||') ## '||sqlerrm);
End get_current_checklist;
-- -----------------------------------------------------------------------------
-- function: get_uncompleted_id() 
-- -----------------------------------------------------------------------------
function get_uncompleted_id(  
     pi_short_name in checklist.short_name%Type,
     pi_target_object_code in checklist.target_object_code%Type,
     pi_target_object_id in checklist.target_object_id%Type)
    return checklist.checklist_id%Type is
  --
  l_checklist_id checklist.checklist_id%Type;
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  select checklist_id into l_checklist_id 
    from 
    (select checklist_id 
      from checklist chkl
     where upper(chkl.short_name) = upper(pi_short_name)
       and upper(chkl.target_object_code) = upper(pi_target_object_code)
       and target_object_id = pi_target_object_id
       and checked = 'N'
        order by create_date desc)
     where rownum = 1;
  --
  return l_checklist_id ;
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.get_uncompleted_id('||pi_short_name||','||pi_target_object_code||','||pi_target_object_id||') ## '||sqlerrm);
End get_uncompleted_id;
    
-- -----------------------------------------------------------------------------
-- function get_checklist_url()
-- -----------------------------------------------------------------------------
Function get_checklist_url(pi_checklist_id in checklist.checklist_id%Type,
    pi_field_names in pkg_task.VARCHAR_TABLE_TYPE default pkg_task.VARCHAR_TABLE_TYPE(),
    pi_field_values in pkg_task.VARCHAR_TABLE_TYPE default pkg_task.VARCHAR_TABLE_TYPE())
  return varchar2 is
  l_comma varchar2(1) := null;
  l_field_names varchar2(512);
  l_field_values varchar2(512);
  l_target_page_id checklist.target_page_id%Type;
  l_target_object_id checklist.target_object_id%Type;
  l_pk_field_name glob_object.pk_name%Type;
  l_var varchar2(32);
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  --
  select s.target_page_id, s.target_object_id, o.pk_name
    into l_target_page_id, l_target_object_id, l_pk_field_name
    from checklist s
         inner join glob_object o on (o.object_abbreviation = s.target_object_code)
   where s.checklist_id = pi_checklist_id;
  --
  if pi_field_names.COUNT > 0 then
    for i in pi_field_names.FIRST..pi_field_names.LAST loop
      l_field_names := l_field_names||l_comma||'P'||rtrim(ltrim(to_char(l_target_page_id)))||'_'||pi_field_names(i);
      l_field_values := l_field_values||l_comma||'\'||pi_field_values(i)||'\';
--	  l_var := '\'';
      l_comma := ',';
    end loop;
  end if;
  --
  return 'f?p='||NVL(v('APP_ID'),104)||':'||l_target_page_id||':'||v('SESSION')||':'||v('REQUEST')||':'||v('DEBUG')||'::'||
      l_field_names||':'||l_field_values||':'||v('PRINTER_FRIENDLY');
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'pkg_checklist.get_checklist_url('||pi_checklist_id||') ## '||sqlerrm);
End get_checklist_url;

-- -----------------------------------------------------------------------------
-- Procedure Complete_Checklist()
-- -----------------------------------------------------------------------------
  Procedure Complete_Checklist(pi_checklist_id in checklist.checklist_id%Type, pi_login_id in number := 1) is
    l_unchecked_count number;
   --
   Already_Caught exception;
   PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    Select count(1) into l_unchecked_count
      from checklist_line 
     where checklist_id = pi_checklist_id
	   and checked = 'N';
    --
    If l_unchecked_count = 0 then
       update checklist set 
             checked = 'Y', check_date = sysdate, check_by_login_id = pi_login_id
         where checklist_id = pi_checklist_id;
    End if;
  Exception
    when no_data_found then null;
    when Already_Caught then raise;
    when others then
      raise_application_error(-20001, 'pkg_checklist.Complete_Checklist('||pi_checklist_id||') ## '||sqlerrm);
  End Complete_Checklist;
-- -----------------------------------------------------------------------------
-- Procedure Complete_Checklist()
-- -----------------------------------------------------------------------------
  Procedure Un_Complete_Checklist(pi_checklist_id in checklist.checklist_id%Type) is
   --
   Already_Caught exception;
   PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
       update checklist set 
             checked = 'N', check_date = null, check_by_login_id = null
         where checklist_id = pi_checklist_id;
  Exception
    when no_data_found then null;
    when Already_Caught then raise;
    when others then
      raise_application_error(-20001, 'pkg_checklist.Un_Complete_Checklist('||pi_checklist_id||') ## '||sqlerrm);
  End Un_Complete_Checklist;

-- -----------------------------------------------------------------------------
-- Procedure Complete_Line()
-- -----------------------------------------------------------------------------
  Procedure Complete_Line(
       pi_checklist_line_id in checklist_line.checklist_line_id%Type
	   , pi_login_id in number := 1
	   , pi_comments in checklist.comments%Type := null) is
    l_checklist_id checklist.checklist_id%Type;
   --
   l_comments checklist_line.comments%Type := pi_comments;
   --
   Already_Caught exception;
   PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
	if l_comments is not null 
	then 
  	  l_comments := '-- '||to_char(sysdate, 'dd-MON-yyyy hh:mi PM')
	                ||' by "'||pkg_login.get_apex_username(pi_login_id => pi_login_id)||'"'
					||chr(10)||l_comments;
	end if;
	--
    Update MLT_checklist_line 
	   set checked = 'Y', check_by_login_id = pi_login_id, check_date = sysdate
	       , comments = case when comments is null then l_comments else l_comments||chr(10)||comments end
     where checklist_line_id = pi_checklist_line_id
     returning checklist_id into l_checklist_id;
    --
    pkg_checklist.Complete_Checklist(pi_checklist_id => l_checklist_id, pi_login_id => pi_login_id);
  Exception
    when no_data_found then null;
    when Already_Caught then raise;
    when others then
      raise_application_error(-20001, 'pkg_checklist.Complete_Line('||pi_checklist_line_id||') ## '||sqlerrm);
  End Complete_Line;
          
-- -----------------------------------------------------------------------------
-- Procedure Un_Complete_Line()
-- -----------------------------------------------------------------------------
  Procedure Un_Complete_Line(
       pi_checklist_line_id in checklist_line.checklist_line_id%Type
	   , pi_comments in checklist.comments%Type := null) is
    l_checklist_id checklist.checklist_id%Type;
   --
   l_comments checklist_line.comments%Type := pi_comments;
   --
   Already_Caught exception;
   PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
	if l_comments is not null 
	then 
  	  l_comments := chr(10)||'-- '||to_char(sysdate, 'dd-MON-yyyy hh:mi PM')||chr(10)||l_comments;
	end if;
    Update MLT_checklist_line 
	   set checked = 'N', check_by_login_id = null, check_date = null
	       , comments = case when comments is null then l_comments else l_comments||chr(10)||comments end
     where checklist_line_id = pi_checklist_line_id
     returning checklist_id into l_checklist_id;
    --
    pkg_checklist.Un_Complete_Checklist(pi_checklist_id => l_checklist_id);
  Exception
    when no_data_found then null;
    when Already_Caught then raise;
    when others then
      raise_application_error(-20001, 'pkg_checklist.Un_Complete_Line('||pi_checklist_line_id||') ## '||sqlerrm);
  End Un_Complete_Line;
  
-- ----------------------------------------------------------------------------- 
-- Function get_checklist_record()
-- ----------------------------------------------------------------------------- 
  Function get_checklist_record(pi_checklist_id in checklist.checklist_id%Type) return checklist%RowType
  is
   --
   Already_Caught exception;
   PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    return null;
  Exception
    when no_data_found then return null;
    when Already_Caught then raise;
    when others then
      raise_application_error(-20001, 'pkg_checklist.get_checklist_record('||pi_checklist_id||') ## '||sqlerrm);
  End get_checklist_record;

-- ----------------------------------------------------------------------------- 
-- Function get_current_checklist_count()
-- ----------------------------------------------------------------------------- 
  Function get_current_checklist_count( 
    pi_target_object_code in checklist.target_object_code%Type, 
    pi_target_object_id in checklist.target_object_id%Type) 
   return number is
   --
   l_count number;
   --
   Already_Caught exception;
   PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
	select count(1) into l_count
	  from checklist chkl 
	 where chkl.target_object_code = pi_target_object_code
	   and chkl.target_object_id = pi_target_object_id
	   and chkl.checked <> 'Y';
	--
    return l_count;
  Exception
    when no_data_found then return 0;
    when Already_Caught then raise;
    when others then
      raise_application_error(-20001, 'pkg_checklist.get_current_checklist_count('||pi_target_object_code||','||pi_target_object_id||') ## '||sqlerrm);
  End get_current_checklist_count;
  
-- ----------------------------------------------------------------------------- 
-- function get_completed_checklist_count() 
-- ----------------------------------------------------------------------------- 
  Function get_completed_checklist_count( 
    pi_target_object_code in checklist.target_object_code%Type, 
    pi_target_object_id in checklist.target_object_id%Type) 
   return number is
   --
   l_count number;
   --
   Already_Caught exception;
   PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
	select count(1) into l_count
	  from checklist chkl 
	 where chkl.target_object_code = pi_target_object_code
	   and chkl.target_object_id = pi_target_object_id
	   and chkl.checked = 'Y';
	--
    return l_count;
  Exception
    when no_data_found then return 0;
    when Already_Caught then raise;
    when others then
      raise_application_error(-20001, 'pkg_checklist.get_completed_checklist_count('||pi_target_object_code||','||pi_target_object_id||') ## '||sqlerrm);
  End get_completed_checklist_count;
 
-- ----------------------------------------------------------------------------- 
-- function get_completed_line_count() 
-- ----------------------------------------------------------------------------- 
  Function get_completed_line_count( 
    pi_target_object_code in checklist.target_object_code%Type, 
    pi_target_object_id in checklist.target_object_id%Type) 
   return number is
   --
   l_count number;
   --
   Already_Caught exception;
   PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
	select count(1) into l_count
	  from checklist chkl 
	     inner join checklist_line chke on (chke.checklist_id = chkl.checklist_id)
	 where chkl.target_object_code = pi_target_object_code
	   and chkl.target_object_id = pi_target_object_id
	   and chke.checked = 'Y';
	--
    return l_count;
  Exception
    when no_data_found then return 0;
    when Already_Caught then raise;
    when others then
      raise_application_error(-20001, 'pkg_checklist.get_completed_line_count('||pi_target_object_code||','||pi_target_object_id||') ## '||sqlerrm);
  End get_completed_line_count;
 
-- ----------------------------------------------------------------------------- 
-- Procedure Add_Comments() 
-- ----------------------------------------------------------------------------- 
  Procedure Add_Comments(
     pi_checklist_id in checklist.checklist_id%Type
	 , pi_comments in checklist.comments%Type := null
	 , pi_login_id in checklist.check_by_login_id%Type) is
   --
   Already_Caught exception;
   PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    pkg_object.Add_Instance_Comments(
       pi_target_object_code => 'CHKL', -- Checklist 
       pi_target_object_id   => pi_checklist_id,
       pi_comments           => pi_comments,
	   pi_login_id           => pi_login_id);
  Exception
    when Already_Caught then raise;
    when others then
      raise_application_error(-20001, 'pkg_checklist.Add_Comments('||pi_checklist_id||') ## '||sqlerrm);
  End Add_Comments;

-- ----------------------------------------------------------------------------- 
-- Procedure Add_line_Comments() 
-- ----------------------------------------------------------------------------- 
  Procedure Add_line_Comments(
     pi_checklist_line_id in checklist_line.checklist_line_id%Type
	 , pi_comments in checklist_line.comments%Type := null
	 , pi_login_id in checklist_line.check_by_login_id%Type) is
   --
   Already_Caught exception;
   PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    pkg_object.Add_Instance_Comments(
       pi_target_object_code => 'CHKE', -- Checklist Line
       pi_target_object_id   => pi_checklist_line_id,
       pi_comments           => pi_comments,
	   pi_login_id           => pi_login_id);
  Exception
    when Already_Caught then raise;
    when others then
      raise_application_error(-20001, 'pkg_checklist.Add_line_Comments('||pi_checklist_line_id||') ## '||sqlerrm);
  End Add_line_Comments;

-- ----------------------------------------------------------------------------- 
-- procedure check_all() 
-- Desciption
--   Execute the "check function" on each line of a checklist and set the
--   appropriate flag according to the result
-- ----------------------------------------------------------------------------- 
  procedure check_all( 
     pi_target_object_code in checklist.target_object_code%Type, 
     pi_target_object_id in checklist.target_object_id%Type,
     pi_login_id in login.login_id%Type) is
   --
   Already_Caught exception;
   PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    for rec in (select * from checklist chkl 
	             where chkl.target_object_code = pi_target_object_code
				   and chkl.target_object_id = pi_target_object_id)
	loop
	  pkg_checklist.check_it(pi_checklist_id=>rec.checklist_id, pi_login_id=>pi_login_id);
	end loop;
  Exception
    when Already_Caught then raise;
    when others then
      raise_application_error(-20001, 'pkg_checklist.check_all('||pi_target_object_code||','||pi_target_object_id||','||pi_login_id||') ## '||sqlerrm);
  End check_all;
   
END PKG_CHECKLIST;
/

select pkg_checklist.get_version() from dual;