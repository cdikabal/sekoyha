create or replace PACKAGE BODY  "PKG_DBADMIN" AS 
  -- ===========================================================================
  -- P R I V A T E   G L O B A L   C O N S T A N T S   A N D   V A R I A B L E S
  -- ===========================================================================
  TYPE Cursor_Type IS REF CURSOR;
  TYPE Column_Record_Type IS RECORD (cname varchar2(64), cformat varchar2(64), cdefault varchar2(256));
  TYPE Column_Table_Type IS TABLE of Column_Record_Type;
  --
  K_CREATE_TRIGGER_STRING CONSTANT varchar2(4000) := 
  'create or replace trigger trg_[TABLE_ABBREVIATION]_io_iud'||chr(10)||
  '   instead of insert or delete or update on [VIEW_NAME]'||chr(10)||
  'begin '||chr(10)||
  '  if inserting then '||chr(10)||
  '   Insert into [GLOB_TABLE_NAME] (TENANT_ID, DELETED, DELETED_DATE, [INSERT_COLUMN_LIST])'||chr(10)||
  '   values (pkg_tenant.get_current_id(), ''N'', null, [NEW_COLUMN_LIST]);'||chr(10)||
  '  elsif updating then '||chr(10)||
  '   Update [GLOB_TABLE_NAME] t Set'||chr(10)||
  '     [UPDATE_SET_CLAUSE]'||chr(10)||
  '    Where t.TENANT_ID = pkg_tenant.get_current_id()'||chr(10)||
  '      And [NEW_PK_WHERE_CLAUSE]; '||chr(10)||
  '  elsif deleting then '||chr(10)||
  '   Update [GLOB_TABLE_NAME] t '||chr(10)||
  '      set t.DELETED = ''Y'', t.DELETED_DATE = SYSDATE '||chr(10)||
  '    Where t.TENANT_ID = pkg_tenant.get_current_id() '||chr(10)||
  '      And [OLD_PK_WHERE_CLAUSE]; '||chr(10)||
  '  end if;'||chr(10)||
  'end trg_[TABLE_ABBREVIATION]_io_iud;';
  --
  K_CREATE_VIEW_STRING CONSTANT varchar2(4000) := 
    'Create Or Replace View [VIEW_NAME] as '||chr(10)||
    ' Select [COLUMN_LIST] From [TABLE_NAME] t '||chr(10)||
    '  Where t.TENANT_ID = pkg_tenant.get_current_id()'||chr(10)||
    '    And t.DELETED = ''N'' WITH CHECK OPTION';
  --
  K_COLUMN_LIST_QUERY CONSTANT varchar2(4000) :=
       'select column_name from user_tab_columns col '||chr(10)||
       ' where table_name = :1 '||chr(10)||
       '   and col.column_name not in (''TENANT_ID'', ''DELETED'', ''DELETED_DATE'')'||chr(10)||
       ' order by col.column_id';
  --
  K_PK_COLUMN_LIST_QUERY CONSTANT varchar2(4000) :=
       'select col.column_name from user_cons_columns col '||chr(10)||
       ' inner join user_constraints pk on (pk.constraint_name = col.constraint_name) '||chr(10)||
       ' where pk.table_name = :1 '||chr(10)||
       ' and col.column_name not in (''TENANT_ID'', ''DELETED'', ''DELETED_DATE'')'||chr(10)||
       ' and pk.constraint_type = ''P'''||chr(10)||
       '  order by col.position';
  --
  K_CREATE_AUDIT_TRIGGER CONSTANT varchar2(4000) :=
    'create or replace trigger trg_audit_[TABLE_ABBREVIATION]_bi_e '||chr(10)||
    '   before insert or update on [TABLE_NAME] for each row '||chr(10)||
    'begin  '||chr(10)||
    '  if inserting then  '||chr(10)||
    '    :new.CREATE_DATE := sysdate; '||chr(10)||
    '    :new.CREATE_BY_LOGIN_ID := nvl(pkg_login.get_login_id(p_apex_username=>v(''APP_USER'')), 21); '||chr(10)||
    '    :new.LAST_UPDATE_DATE := sysdate; '||chr(10)||
    '    :new.UPDATE_BY_LOGIN_ID := nvl(pkg_login.get_login_id(p_apex_username=>v(''APP_USER'')), 21); '||chr(10)||
    '  end if; '||chr(10)||
    '  --  '||chr(10)||
    '  if updating then  '||chr(10)||
    '    :new.LAST_UPDATE_DATE := sysdate; '||chr(10)||
    '    :new.UPDATE_BY_LOGIN_ID := nvl(pkg_login.get_login_id(p_apex_username=>v(''APP_USER'')), 21); '||chr(10)||
    '  end if; '||chr(10)||
    'end trg_audit_[TABLE_ABBREVIATION]_bi_e; ';
  --
  K_CREATE_IDENTITY_TRIGGER CONSTANT varchar2(4000) :=
    'create or replace trigger trg_identity_MCON_bi_e '||chr(10)||
    '   before insert on MLT_CONTACT for each row '||chr(10)||
    'begin  '||chr(10)||
    '  if :new.CONTACT_ID is null then  '||chr(10)||
    '    :new.CONTACT_ID := SEQ_TENANT_OTHERS.nextval; '||chr(10)||
    '  end if; '||chr(10)||
    'end trg_identity_MCON_bi_e;';
  --
  K_CREATE_FK1_AUDIT CONSTANT varchar2(4000) :=
    'ALTER TABLE [TABLE_NAME] ADD CONSTRAINT FK1_[TABLE_ABBREVIATION]_MLOG '||chr(10)||
    '  FOREIGN KEY (CREATE_BY_LOGIN_ID) '||chr(10)||
    '  REFERENCES MLT_LOGIN (LOGIN_ID) ';
  --
  K_CREATE_FK2_AUDIT CONSTANT varchar2(4000) :=
    'ALTER TABLE [TABLE_NAME] ADD CONSTRAINT FK2_[TABLE_ABBREVIATION]_MLOG '||chr(10)||
    '  FOREIGN KEY (UPDATE_BY_LOGIN_ID) '||chr(10)||
    '  REFERENCES MLT_LOGIN (LOGIN_ID)';
  --
  K_CREATE_IX1_AUDIT CONSTANT varchar2(4000) :=
    'CREATE INDEX FK1_[TABLE_ABBREVIATION]_MLOGX ON [TABLE_NAME] (CREATE_BY_LOGIN_ID) ';
  --
  K_CREATE_IX2_AUDIT CONSTANT varchar2(4000) :=
    'CREATE INDEX FK2_[TABLE_ABBREVIATION]_MLOGX ON [TABLE_NAME] (UPDATE_BY_LOGIN_ID) ';
  --
  K_IDENTITY_TRIGGER CONSTANT varchar2(4000) :=
    'Create Or Replace trigger trg_identity_[ABBREVIATION]_bi_e '||chr(10)||
    '   before insert on [TABLE_NAME] for each row '||chr(10)||
    'begin  '||chr(10)||
    '  :new.[PK_COLUMN_NAME] := [SEQUENCE_NAME].nextval; '||chr(10)||
    'end trg_identity_[ABBREVIATION]_bi_e; ';
  --
  g_Audit_Column_Table Column_Table_Type;
  -- ===========================================================================
  -- P R I V A T E   F U N C T I O N S   A N D   P R O C E D U R E S
  -- ===========================================================================
  Function Get_Column_List(pi_table_name in varchar2) return varchar2 is
    col_cursor CURSOR_TYPE;
    l_string varchar2(4000);
    l_comma varchar2(3) := chr(9);
    l_column_name varchar2(64);
  Begin
    Open col_cursor For K_COLUMN_LIST_QUERY Using pi_table_name;
    Loop
      Fetch col_cursor into l_column_name;
      exit when col_cursor%NOTFOUND;
      l_string := l_string||l_comma||l_column_name;
      l_comma := ',';
    end loop;
    Close col_cursor;
    return l_string;
  End Get_Column_List;
  --
  Function Get_New_Column_List(pi_table_name in varchar2) return varchar2 is
    col_cursor CURSOR_TYPE;
    l_string varchar2(4000);
    l_comma varchar2(3) := chr(9);
    l_column_name varchar2(64);
  Begin
    Open col_cursor For K_COLUMN_LIST_QUERY Using pi_table_name;
    Loop
      Fetch col_cursor into l_column_name;
      exit when col_cursor%NOTFOUND;
      l_string := l_string||l_comma||':NEW.'||l_column_name;
      l_comma := ',';
    end loop;
    Close col_cursor;
    return l_string;
  End Get_New_Column_List;
  --
  Function Get_Update_Set_Clause(pi_table_name in varchar2) return varchar2 is
    col_cursor CURSOR_TYPE;
    l_string varchar2(4000);
    l_comma varchar2(3) := chr(9);
    l_column_name varchar2(64);
  Begin
    Open col_cursor For K_COLUMN_LIST_QUERY Using pi_table_name;
    Loop
      Fetch col_cursor into l_column_name;
      exit when col_cursor%NOTFOUND;
      l_string := l_string||l_comma||'t.'||l_column_name||'='||
         case
           when l_column_name = 'UPDATED_BY' then 'nvl(:NEW.UPDATED_BY,''admin'')'
           when l_column_name = 'UPDATED_DATE' then 'nvl(:NEW.UPDATED_DATE,sysdate)'
           else ':NEW.'||l_column_name
         end;
      l_comma := ', ';
    end loop;
    Close col_cursor;
    return l_string;
  End Get_Update_Set_Clause;
  --
  Function Get_PK_Where_Clause(pi_table_name in varchar2, pi_old_or_new in varchar2 := ':OLD') return varchar2 is
    col_cursor CURSOR_TYPE;
    l_column_name varchar2(64);
    l_string varchar2(4000);
    l_comma varchar2(10) := null;
  Begin
    Open col_cursor For K_PK_COLUMN_LIST_QUERY Using pi_table_name;
    Loop
      Fetch col_cursor into l_column_name;
      exit when col_cursor%NOTFOUND;
      l_string := l_string||l_comma||'t.'||l_column_name||'='||pi_old_or_new||'.'||l_column_name;
      l_comma := ' And ';
    end loop;
    Close col_cursor;
    return l_string;
  End Get_PK_Where_Clause;
  --
  Procedure Exec_DDL(pi_ddl_string in varchar2) is
  Begin
    --dbms_output.put(pi_ddl_string);
    execute immediate pi_ddl_string;
    --dbms_output.put_line(' : Ok');
  Exception	
    when others then dbms_output.put_line('Exec_DDL('||substr(pi_ddl_string,1,64)||') # '||sqlerrm);
  End Exec_DDL;
  -- ---------------------------------------------------------------------------
  -- Local Procedure Drop_Index()
  -- ---------------------------------------------------------------------------
  Procedure Drop_Index(pi_table_name in varchar2, pi_column_name1 in varchar2, pi_column_name2 in varchar2) is
    ind_cursor CURSOR_TYPE;
    l_index_name varchar2(64);
    l_query varchar2(512) := 
      'select index_name from user_ind_columns ic '||chr(10)||
      ' where ic.table_name = :1 '||chr(10)||
      ' and ic.column_name in (:2, :3)';
  Begin
    Open ind_cursor For l_query Using pi_table_name, nvl(pi_column_name1,'@'), nvl(pi_column_name2, '@');
    Loop
      Fetch ind_cursor into l_index_name;
      exit when ind_cursor%NOTFOUND;
      Exec_DDL('Drop Index '||l_index_name);
    End Loop;
    Close ind_cursor;
  End Drop_Index;
  -- ---------------------------------------------------------------------------
  -- Local Procedure Drop_Foreign_key()
  -- ---------------------------------------------------------------------------
  Procedure Drop_Foreign_key(pi_table_name in varchar2, pi_column_name1 in varchar2, pi_column_name2 in varchar2) is
    fk_cursor CURSOR_TYPE;
    l_fk_name varchar2(64);
    l_query varchar2(512) := 
      'select fkc.constraint_name from user_cons_columns fkc '||chr(10)||
      '    inner join user_constraints fk on (fk.constraint_name = fkc.constraint_name) '||chr(10)||
      ' where fkc.table_name = :1'||chr(10)||
      '   and fkc.column_name in (:2, :3) '||chr(10)||
      '   and fk.constraint_type = ''R''';
  Begin
    Open fk_cursor For l_query Using pi_table_name, nvl(pi_column_name1,'@'), nvl(pi_column_name2, '@');
    Loop
      Fetch fk_cursor into l_fk_name ;
      exit when fk_cursor%NOTFOUND;
      Exec_DDL('Alter Table '||pi_table_name||' Drop Constraint '||l_fk_name);
    End Loop;
    Close fk_cursor;
  End Drop_Foreign_key;
  --
  Function local_column_exists(pi_table_name in varchar2, pi_column_name in varchar2) return boolean is
    l_val number;
  Begin
    execute immediate 'Select count(1) from user_tab_columns where table_name=:1 and column_name=:2' into l_val 
      using upper(pi_table_name), upper(pi_column_name);
    return (l_val > 0);
  Exception
    when others then 
       raise_application_error(-20001, 'local_column_exists('||pi_table_name||', '||pi_column_name||') ## '||sqlerrm);
  End local_column_exists;
  --
  Function local_trigger_exists(pi_trigger_name in varchar2) return boolean is
    l_val number;
  Begin
    execute immediate 'Select count(1) from user_triggers where trigger_name=:1' into l_val using upper(pi_trigger_name);
    return (l_val > 0);
  Exception
    when others then 
       raise_application_error(-20001, 'local_trigger_exists('||pi_trigger_name||') ## '||sqlerrm);
  End local_trigger_exists;
  --
  Function local_sequence_exists(pi_sequence_name in varchar2) return boolean is
    l_val number;
  Begin
    execute immediate 'Select count(1) from user_sequences where sequence_name=:1' into l_val using upper(pi_sequence_name);
    return (l_val > 0);
  Exception
    when others then 
       raise_application_error(-20001, 'local_sequence_exists('||pi_sequence_name||') ## '||sqlerrm);
  End local_sequence_exists;
  --
  Procedure create_or_replace_column(pi_table_name in varchar2, pi_column_record in Column_Record_Type) is
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    if local_column_exists(pi_table_name,pi_column_record.cname) then
      Exec_DDL('Alter Table '||pi_table_name||' Drop Column '||pi_column_record.cname);
    end if;
    --
    Exec_DDL('Alter Table '||pi_table_name||' Add '||pi_column_record.cname||' '||pi_column_record.cformat||' '||
       case when upper(pi_column_record.cdefault) <> 'NULL' then ' Default '||pi_column_record.cdefault end);
  Exception
    when Already_Caught then raise;
    when others then 
       raise_application_error(-20001, 'create_or_replace_column('||pi_table_name||', '||pi_column_record.cname||') ## '||sqlerrm);
  End create_or_replace_column;
  -- ===========================================================================
  -- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S
  -- ===========================================================================
  -- ---------------------------------------------------------------------------
  -- Function: Has_InsteadOf_Triggers
  -- ---------------------------------------------------------------------------
  Function Has_InsteadOf_Triggers(pi_view_name in varchar2) return boolean
  is
    l_count number := 0;
  Begin
    execute immediate 'select count(1) from user_triggers where table_name=:1 and trigger_name<>:2'
    into l_count using upper(pi_view_name), 'TRG_'||pi_view_name||'_IO_IUD';
    return (l_count > 0);
  End Has_InsteadOf_Triggers;
  -- ---------------------------------------------------------------------------
  -- Function: Has_all_audit_fields() return boolean
  -- ---------------------------------------------------------------------------
  Function Has_all_audit_fields(pi_table_name in varchar2) return boolean
  is
    l_count number := 0;
  Begin
    --dbms_output.put('. Checking audit fields: '||pi_table_name);
    execute immediate 'select count(1) from user_tab_columns where table_name=:1 and column_name in (:2, :3, :4, :5)'
    into l_count using upper(pi_table_name), 'CREATE_DATE', 'CREATE_BY_LOGIN_ID', 'LAST_UPDATE_DATE', 'UPDATE_BY_LOGIN_ID';
	--dbms_output.put_line(' => '||l_count);
    return (l_count >= 4);
  Exception
    When others then
     raise_application_error(-20001, 'Has_all_audit_fields('||pi_table_name||') ## '||sqlerrm);
  End Has_all_audit_fields;
  -- ---------------------------------------------------------------------------
  -- Function: get_abbreviation() return varchar2
  -- ---------------------------------------------------------------------------
  Function get_abbreviation(pi_table_name in varchar2) return varchar2
  is
    l_object_abbreviation GLOB_OBJECT.object_abbreviation%Type;
  Begin
    select object_abbreviation into l_object_abbreviation from GLOB_OBJECT where OBJECT_NAME=pi_table_name;
    -- 
    --dbms_output.put_line('-> get_abbreviation('||pi_table_name||') = '||l_object_abbreviation);
    return l_object_abbreviation;
  Exception
    When others then
     raise_application_error(-20001, 'get_abbreviation('||pi_table_name||') ## '||sqlerrm);
  End get_abbreviation;
  -- ---------------------------------------------------------------------------
  -- Procedure: Create_Tenant_View
  -- ---------------------------------------------------------------------------
  Procedure Create_Tenant_View(
      pi_table_name in varchar2, pi_view_name in varchar2 default null, pi_abbreviation in varchar2 default null)
  is
    l_view_name varchar2(64) := pi_view_name;
    l_abbreviation glob_object.object_abbreviation%Type := pi_abbreviation;
  Begin
    if pi_table_name not like 'MLT\_%' escape '\' then return; end if;
	-- '\
    --
    if l_abbreviation is null then l_abbreviation := pkg_object.get_code(pi_object_name=>pi_table_name); end if;
    --
    if l_view_name is null then
      l_view_name := substr(pi_table_name, 5);
    end if;
    -- 
    --dbms_output.put_line('- View Name = '||l_view_name);
    --if Not Has_InsteadOf_Triggers(pi_view_name=>l_view_name) then
    --  dbms_output.put_line('- Has InseadOf triggers = False');
      --
      --dbms_output.put_line('- Column List = '||chr(10)||Get_Column_List(pi_table_name=>pi_table_name));
      --dbms_output.put_line('- NEW Column List = '||chr(10)||Get_New_Column_List(pi_table_name=>pi_table_name));
      --dbms_output.put_line('- Update Set Clause = '||chr(10)||Get_Update_Set_Clause(pi_table_name=>pi_table_name));
      --dbms_output.put_line('- PK Where Clause = '||chr(10)||Get_PK_Where_Clause(pi_table_name=>pi_table_name,pi_old_or_new=>':NEW'));
      --
      -- Create view
      Exec_DDL(
        replace(
           replace(
              replace(K_CREATE_VIEW_STRING,
                 '[VIEW_NAME]', l_view_name),
             '[TABLE_NAME]', pi_table_name),
          '[COLUMN_LIST]', Get_Column_List(pi_table_name=>pi_table_name))
      );
      -- Create INSTEAD OF trigger
      Exec_DDL(
        replace(
           replace(
              replace(
                 replace(
                    replace(
                       replace(
                          replace(
                             replace(K_Create_Trigger_String, 
                                  '[TABLE_ABBREVIATION]', l_abbreviation),
                               '[NEW_PK_WHERE_CLAUSE]', Get_PK_Where_Clause(pi_table_name=>pi_table_name,pi_old_or_new=>':NEW')),
                            '[VIEW_NAME]', l_view_name),
                         '[OLD_PK_WHERE_CLAUSE]', Get_PK_Where_Clause(pi_table_name=>pi_table_name,pi_old_or_new=>':OLD')),
                      '[UPDATE_SET_CLAUSE]', Get_Update_Set_Clause(pi_table_name=>pi_table_name)),
                   '[NEW_COLUMN_LIST]', Get_New_Column_List(pi_table_name=>pi_table_name)),
                '[INSERT_COLUMN_LIST]', Get_Column_List(pi_table_name=>pi_table_name) ),
            '[GLOB_TABLE_NAME]', pi_table_name)
          );
    /*
    else
      dbms_output.put_line('- Has InseadOf triggers = True');
    end if;
    */
  End Create_Tenant_View;
  -- ---------------------------------------------------------------------------
  -- Procedure: Create_Audit_Trigger
  -- ---------------------------------------------------------------------------
  Procedure Create_Audit_Trigger(
      pi_table_name in varchar2, pi_table_abbreviation in varchar2 default null) is
    l_table_abbreviation GLOB_OBJECT.object_abbreviation%Type := nvl(pi_table_abbreviation, get_abbreviation(pi_table_name => pi_table_name));
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
    if Has_all_audit_fields(pi_table_name => pi_table_name) then
      -- Create AUDIT trigger
      Exec_DDL(
        replace(
           replace(K_CREATE_AUDIT_TRIGGER, '[TABLE_ABBREVIATION]', l_table_abbreviation)
              , '[TABLE_NAME]', pi_table_name)
        );
    end if;
  Exception
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'Create_Audit_Trigger('||pi_table_name||') ## '||sqlerrm);
  End Create_Audit_Trigger;
  -- ---------------------------------------------------------------------------
  -- Procedure: Create_Audit_Fk
  -- ---------------------------------------------------------------------------
  Procedure Create_Audit_Fk(
      pi_table_name in varchar2, pi_table_abbreviation in varchar2 ) is
    l_table_abbreviation GLOB_OBJECT.object_abbreviation%Type := nvl(pi_table_abbreviation, get_abbreviation(pi_table_name => pi_table_name));
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
    if Has_all_audit_fields(pi_table_name => pi_table_name) then
      -- Create AUDIT FK
      Exec_DDL(
        replace(
           replace(K_CREATE_FK1_AUDIT, '[TABLE_ABBREVIATION]', l_table_abbreviation)
              , '[TABLE_NAME]', pi_table_name));
      Exec_DDL(
        replace(
           replace(K_CREATE_FK2_AUDIT, '[TABLE_ABBREVIATION]', l_table_abbreviation)
              , '[TABLE_NAME]', pi_table_name));
      -- Create AUDIT Indexes
      Exec_DDL(
        replace(
           replace(K_CREATE_IX1_AUDIT, '[TABLE_ABBREVIATION]', l_table_abbreviation)
              , '[TABLE_NAME]', pi_table_name));
      Exec_DDL(
        replace(
           replace(K_CREATE_IX2_AUDIT, '[TABLE_ABBREVIATION]', l_table_abbreviation)
              , '[TABLE_NAME]', pi_table_name));
    end if;
  Exception
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'Create_Audit_Fk('||pi_table_name||') ## '||sqlerrm);
  End Create_Audit_Fk;
  -- ---------------------------------------------------------------------------
  -- Procedure: Create_Audit_Column
  -- ---------------------------------------------------------------------------
  Procedure Create_Audit_Column(
      pi_table_name in varchar2, pi_table_abbreviation in varchar2 default null) is
    l_table_abbreviation GLOB_OBJECT.object_abbreviation%Type := nvl(pi_table_abbreviation, get_abbreviation(pi_table_name => pi_table_name));
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    for i in g_Audit_Column_Table.FIRST..g_Audit_Column_Table.LAST loop
      create_or_replace_column(pi_table_name=>pi_table_name, pi_column_record=>g_Audit_Column_Table(i));
    end loop;
  Exception
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'Create_Audit_Column('||pi_table_name||') ## '||sqlerrm);
  End Create_Audit_Column;
  -- ---------------------------------------------------------------------------
  -- Procedure: Create_Identifier_Trigger
  -- ---------------------------------------------------------------------------
  Procedure Create_Identifier_Trigger(
      pi_table_name in varchar2, pi_abbreviation in varchar2:= null, pi_identity_name in varchar2 := null) is
    l_glob_object GLOB_OBJECT%RowType;
    l_trigger_name varchar2(64) := 'trg_identity_[ABBREVIATION]_bi_e';
    l_sequence_name varchar2(64) := 'seq_[IDENTITY_NAME]';
    l_pk_column_name varchar2(64);
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
    if pi_abbreviation is null and pi_identity_name is null then
    select * into l_glob_object
      from GLOB_OBJECT o 
     where o.object_name = upper(pi_table_name);
    else
      l_glob_object.object_name := pi_table_name;
      l_glob_object.object_abbreviation := pi_abbreviation;
      l_glob_object.id_name := pi_identity_name;
    end if;
    --
    if l_glob_object.id_name in ('N/A') then
      dbms_output.put_line('> Identity trigger is not applicable for table <'||l_glob_object.object_name||'>');
    else
      --
      l_trigger_name := replace(l_trigger_name, '[ABBREVIATION]', l_glob_object.object_abbreviation);
      if local_trigger_exists(pi_trigger_name => l_trigger_name) then
        exec_DDL('Drop Trigger '||l_trigger_name);
      end if;
      --
      l_sequence_name := replace(l_sequence_name, '[IDENTITY_NAME]', l_glob_object.id_name);
      if NOT local_sequence_exists(pi_sequence_name => l_sequence_name) then
        exec_DDL('Create Sequence '||l_sequence_name);
      end if;
      --
      execute immediate K_PK_COLUMN_LIST_QUERY into l_pk_column_name using upper(l_glob_object.object_name);
      --
      Exec_DDL(
        replace(
          replace(
            replace(
              replace(K_IDENTITY_TRIGGER, '[PK_COLUMN_NAME]', l_pk_column_name)
              , '[SEQUENCE_NAME]', l_sequence_name)
            , '[TABLE_NAME]', l_glob_object.object_name)
          , '[ABBREVIATION]', l_glob_object.object_abbreviation)
      );
    end if;
  Exception
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'Create_Identifier_Trigger('||pi_table_name||') ## '||sqlerrm);
  End Create_Identifier_Trigger;
  Function Get_Pk_Name(pi_table_name in varchar2) return varchar2 is
      l_name varchar2(64);
      l_count number;
  Begin
      --
      execute immediate 
      'select count(1) from user_cons_columns pkc inner join user_constraints pk on (pk.constraint_name = pkc.constraint_name) '||
      ' inner join user_tab_columns col on (col.table_name = pk.table_name and col.column_name = pkc.column_name) '||
      ' where pk.table_name = :1 and pk.constraint_type = ''P'' and col.data_type = ''NUMBER'''
      into l_count using pi_table_name;
      --
      if l_count <> 1 then return null; end if;
      --
      execute immediate 
      'select pkc.column_name from user_cons_columns pkc inner join user_constraints pk on (pk.constraint_name = pkc.constraint_name)'||
      ' inner join user_tab_columns col on (col.table_name = pk.table_name and col.column_name = pkc.column_name) '||
      ' where pk.table_name = :1 and pk.constraint_type = ''P'' and col.data_type = ''NUMBER'''
      into l_name using pi_table_name;
      --
      return l_name;
  Exception
      when no_data_found then return null;
      when others then
       raise_application_error(-20001, 'Get_Pk_Name('||pi_table_name||') ## '||sqlerrm);
  End Get_Pk_Name;
  Procedure Set_Pk_Name(pi_table_name in varchar2) is
      l_name glob_object.pk_name%Type;
  Begin
      l_name := Get_Pk_Name(pi_table_name => pi_table_name );
      --
      update glob_object set pk_name = l_name  
       where object_name = pi_table_name ;
      --
  Exception
      when no_data_found then null;
      when others then
       raise_application_error(-20001, 'Set_Pk_Name('||pi_table_name||') ## '||sqlerrm);
  End Set_Pk_Name;
  -- ---------------------------------------------------------------------------
  -- Function: Get_Current_Max_ID
  -- ---------------------------------------------------------------------------
  Function Get_Current_Max_ID(pi_table_name in varchar2) return number is
      l_counter number;
      l_pk_name glob_object.pk_name%Type := Get_Pk_Name(pi_table_name=>pi_table_name);
  Begin
      if l_pk_name is not null then
        Execute Immediate
         'Select max('||l_pk_name||') From '||pi_table_name 
        Into l_counter;
      end if;
      --
      return l_counter;
  Exception
      when no_data_found then return null;
      when others then
       raise_application_error(-20001, 'pkg_dbadmin.Get_Current_Max_ID('||pi_table_name||') ## '||sqlerrm);
  End Get_Current_Max_ID;
      
  -- --------------------------------------------------------------------------- 
  -- Function:Get_Version()
  -- --------------------------------------------------------------------------- 
  Function get_version return varchar2 is
    Already_Caught EXCEPTION;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    return '$Id$';
  Exception
    when Already_Caught then raise;
    when others then 
       raise_application_error(-20001, 'pkg_dbadmin.get_version() ## '||sqlerrm);
  End get_version;
  
-- =============================================================================
-- I N I T I A L I Z A T I O N S
-- =============================================================================
Begin
  g_Audit_Column_Table := Column_Table_Type();
  g_Audit_Column_Table.EXTEND;
  g_Audit_Column_Table(g_Audit_Column_Table.last).cname := 'CREATE_DATE';  g_Audit_Column_Table(g_Audit_Column_Table.last).cformat := 'DATE';  g_Audit_Column_Table(g_Audit_Column_Table.last).cdefault := 'sysdate';
  --
  g_Audit_Column_Table.EXTEND;
  g_Audit_Column_Table(g_Audit_Column_Table.last).cname := 'CREATE_BY_LOGIN_ID';  g_Audit_Column_Table(g_Audit_Column_Table.last).cformat := 'NUMBER';  g_Audit_Column_Table(g_Audit_Column_Table.last).cdefault := null;
  --
  g_Audit_Column_Table.EXTEND;
  g_Audit_Column_Table(g_Audit_Column_Table.last).cname := 'LAST_UPDATE_DATE';  g_Audit_Column_Table(g_Audit_Column_Table.last).cformat := 'DATE';  g_Audit_Column_Table(g_Audit_Column_Table.last).cdefault := 'sysdate';
  --
  g_Audit_Column_Table.EXTEND;
  g_Audit_Column_Table(g_Audit_Column_Table.last).cname := 'UPDATE_BY_LOGIN_ID';  g_Audit_Column_Table(g_Audit_Column_Table.last).cformat := 'NUMBER';  g_Audit_Column_Table(g_Audit_Column_Table.last).cdefault := null;
  --
END PKG_DBADMIN;
/

select pkg_dbadmin.get_version() from dual;
