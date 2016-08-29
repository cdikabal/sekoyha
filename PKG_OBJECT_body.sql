create or replace PACKAGE BODY  "PKG_OBJECT" as 
-- ============================================================================
-- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S
-- ============================================================================
  Function Get_Record (
     pi_object_code in glob_object.object_abbreviation%Type)
     return glob_object%RowType is
    l_record glob_object%RowType;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -2000);
  Begin
    select * into l_record
      from glob_object s
     where s.object_abbreviation = upper(pi_object_code);
      return l_record; 
  Exception
    when Already_Caught then raise;
    when no_data_found then return null;
    when others then
        raise_application_error(-20001, 'Get_Record('||pi_object_code||') - '||sqlerrm);
  End Get_Record;
--  
  Function Get_Short_Name (
     pi_object_code in glob_object.object_abbreviation%Type)
     return varchar2 is
    l_short_name glob_object.short_name%Type;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -2000);
  Begin
   select short_name into l_short_name
     from glob_object s
    where s.object_abbreviation = upper(pi_object_code);
     return l_short_name;   
  Exception
    when Already_Caught then raise;
    when no_data_found then return null;
    when others then
        raise_application_error(-20001, 'Get_Short_Name ('||pi_object_code||') - '||sqlerrm);
  End Get_Short_Name ;
  Function Get_Name (
     pi_object_code in glob_object.object_abbreviation%Type)
     return varchar2 is
    l_name glob_object.object_name%Type;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -2000);
  Begin
   select object_name into l_name
     from glob_object s
    where s.object_abbreviation = upper(pi_object_code);
     return l_name;   
  Exception
    when Already_Caught then raise;
    when no_data_found then return null;
    when others then
        raise_application_error(-20001, 'Get_Name('||pi_object_code||') - '||sqlerrm);
  End Get_Name;
  Function Get_Code (
     pi_object_name in glob_object.object_name%Type)
     return varchar2 is
    l_code glob_object.object_abbreviation%Type;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -2000);
  Begin
   select object_abbreviation into l_code
     from glob_object s
    where s.object_name = upper(pi_object_name);
     return l_code ;   
  Exception
    when Already_Caught then raise;
    when no_data_found then return null;
    when others then
        raise_application_error(-20001, 'Get_Code('||pi_object_name||') - '||sqlerrm);
  End Get_Code;
  Function Get_String (
     pi_object_code in glob_object.object_abbreviation%Type,
     pi_object_id in number)
   Return varchar2 is
     l_string varchar2(2000);
     l_SQL_String varchar2(4000);
     --
     Already_Caught exception;
     PRAGMA Exception_Init(Already_Caught, -2000);
  Begin
    select 'Select '||nvl(GET_STRING_EXPRESSION,'s.'||pk_name)||' from '||object_name||' s where s.'||pk_name ||' = :1 '
      into l_SQL_String 
      from glob_object
      where object_abbreviation = upper(pi_object_code)
       and get_string_expression is not null
       and pk_name is not null;
    --
    execute immediate l_SQL_String into l_string using pi_object_id;
    --
    return l_string;
  Exception
    when Already_Caught then raise;
    when no_data_found then return pi_object_code||'.'||pi_object_id||' is not found';
    when others then
        raise_application_error(-20001, 'Get_String ('||pi_object_code||', '||pi_object_id ||') - '||sqlerrm);
  End Get_String ;
    
-- --------------------------------------------------------------------------
-- Get_Full_String()
-- --------------------------------------------------------------------------
  Function Get_Full_String (
     pi_object_code in glob_object.object_abbreviation%Type,
     pi_object_id in number)
     Return varchar2 is
     --
     l_string varchar2(2000);
     l_short_name glob_object.short_name%Type;
     l_SQL_String varchar2(4000);
     --
     Already_Caught exception;
     PRAGMA Exception_Init(Already_Caught, -2000);
  Begin
   select short_name into l_short_name
     from glob_object s
    where s.object_abbreviation = upper(pi_object_code);
      
    select nvl(short_name, object_abbreviation) 
           , 'Select '||nvl(GET_FULL_STRING_EXPRESSION,'s.'||pk_name)||' from '||object_name||' s where s.'||pk_name ||' = :1 '
      into l_short_name, l_SQL_String 
      from glob_object
      where object_abbreviation = upper(pi_object_code)
       and get_string_expression is not null
       and pk_name is not null;
    --
    execute immediate l_SQL_String into l_string using pi_object_id;
    --
    return l_short_name||': '||l_string;
  Exception
    when Already_Caught then raise;
    when no_data_found then return pi_object_code||'.'||pi_object_id||' is not found';
    when others then
        raise_application_error(-20001, 'Get_Full_String ('||pi_object_code||', '||pi_object_id ||') - '||sqlerrm);
  End Get_Full_String ;
-- -----------------------------------------------------------------------------
-- Get_Next_Id
-- -----------------------------------------------------------------------------
  Function Get_Next_Id (
   pi_object_code in glob_object.object_abbreviation%Type)
   return number is
     l_id_name glob_object.id_name%Type;
     l_id_query varchar2(512) := 'Select seq_[IDENTIFIER].nextval from dual';
     l_id_value number := null;
     Already_Caught exception;
     PRAGMA Exception_Init(Already_Caught, -2000);
  Begin
    begin
      select case when nvl(g.id_name,'N/A') = 'N/A' then 'OTHERS' else g.id_name end
        into l_id_name
        from glob_object g
       where g.object_abbreviation = upper(pi_object_code);
    exception 
       when no_data_found then l_id_name := 'OTHERS';
    end;
    --
    l_id_query := replace(l_id_query, '[IDENTIFIER]', l_id_name);
    execute immediate l_id_query into l_id_value;
    --
    return l_id_value;
  Exception
    when Already_Caught then raise;
    when others then
        raise_application_error(-20001, 'Get_Next_Id ('||pi_object_code||') - '||sqlerrm);
  End Get_Next_Id ;
 
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
      raise_application_error(-20001, 'PKG_OBJECT.get_version() - '||sqlerrm);
  End get_version;

-- ----------------------------------------------------------------------------- 
-- Procedure Add_Instance_Comments()
-- ----------------------------------------------------------------------------- 
  Procedure Add_Instance_Comments(
     pi_target_object_code in glob_object.object_abbreviation%Type,
     pi_target_object_id in number,
     pi_comments in varchar2,
	 pi_login_id in login.login_id%Type) is
	--
    l_object glob_object%RowType := get_record(pi_object_code => pi_target_object_code);
	l_comments varchar2(2000)  := pi_comments;
	l_sqlstring varchar2(2000) := 
	    'Update [TableName] t '||chr(10)||
		'   Set t.COMMENTS = case when t.COMMENTS is null then :1 else :2 || chr(10)||t.COMMENTS end '||chr(10)||
		' Where t.[PrimaryKeyColumn] = :3';
	--
	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
	INVALID_IDENTIFIER exception;
	PRAGMA Exception_Init(INVALID_IDENTIFIER, -00904);
  Begin
    if l_comments is not null then
  	  l_comments := '-- '||to_char(sysdate, 'dd-MON-yyyy hh:mi PM')
	                ||' by "'||pkg_login.get_apex_username(pi_login_id => pi_login_id)||'"'
					||chr(10)||l_comments;
	end if;
	--
    Execute Immediate 
	  replace(
  	     replace(l_sqlstring, '[TableName]', l_object.object_name)
		 , '[PrimaryKeyColumn]', l_object.pk_name)
	  Using l_comments, l_comments, pi_target_object_id;
  Exception
    When INVALID_IDENTIFIER then null;
    When ALREADY_CAUGHT then raise;
    When OTHERS THEN 
      raise_application_error(-20001, 'PKG_OBJECT.Add_Instance_Comments() - '||sqlerrm);
  End Add_Instance_Comments;

end PKG_OBJECT;
/

select pkg_object.get_version() from dual;