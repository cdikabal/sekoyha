create or replace PACKAGE BODY  "PKG_PARENT" AS 
 
-- ------------------------------------------------------------------------- 
-- Function create_or_replace[1] - Parent record 
-- ------------------------------------------------------------------------- 
  function create_or_replace( pi_parent_record parent%RowType )  
  return parent.parent_id%Type is 
     l_parent_id parent.parent_id%Type := pi_parent_record.parent_id; 
     l_parent_number parent.parent_number%Type := pi_parent_record.parent_number;
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  Begin 
    -- 
    if l_parent_id is null then 
      if NOT is_created(pi_parent_id => l_parent_id) then l_parent_id := null; end if; 
    end if; 
    -- 
    if l_parent_number is null then
        l_parent_number := pkg_identifiers.get_next('parent');
    end if;
    --
    if l_parent_id is null then 
      Insert Into MLT_PARENT( 
      TENANT_ID,  
      PARENT_NUMBER,  
      FIRST_NAME,  
      LAST_NAME,  
      MIDDLE_NAME,  
      GENDER,  
      CELL_PHONE,  
      WORK_PHONE,  
      EMAIL_ADDRESS,  
      ADD_ID,  
      COMPANY_NAME,  
      OCCUPATION,  
      TITLE_ID,  
      CREATE_BY_LOGIN_ID,  
      UPDATE_BY_LOGIN_ID)     
      Values ( 
      pkg_tenant.GET_CURRENT_ID(),  
      l_parent_number,  
      Upper(pi_parent_record.FIRST_NAME),  
      Upper(pi_parent_record.LAST_NAME),  
      Upper(pi_parent_record.MIDDLE_NAME),  
      Upper(pi_parent_record.GENDER),  
      pi_parent_record.CELL_PHONE,  
      pi_parent_record.WORK_PHONE,  
      pi_parent_record.EMAIL_ADDRESS,  
      pi_parent_record.ADD_ID ,  
      pi_parent_record.COMPANY_NAME,  
      pi_parent_record.OCCUPATION,  
      pi_parent_record.TITLE_ID,  
      pi_parent_record.CREATE_BY_LOGIN_ID,  
      pi_parent_record.UPDATE_BY_LOGIN_ID)     
      returning PARENT_ID into l_parent_id; 
    else 
      Update MLT_Parent Set 
      PARENT_NUMBER = pi_parent_record.PARENT_NUMBER,  
      FIRST_NAME = Upper(pi_parent_record.FIRST_NAME),  
      LAST_NAME = Upper(pi_parent_record.LAST_NAME),  
      MIDDLE_NAME = Upper(pi_parent_record.MIDDLE_NAME),  
      GENDER = Upper(pi_parent_record.GENDER),  
      CELL_PHONE = pi_parent_record.CELL_PHONE,  
      WORK_PHONE = pi_parent_record.WORK_PHONE,  
      EMAIL_ADDRESS = pi_parent_record.EMAIL_ADDRESS,  
      ADD_ID = pi_parent_record.ADD_ID,  
      COMPANY_NAME = pi_parent_record.COMPANY_NAME,  
      OCCUPATION = pi_parent_record.OCCUPATION,  
      TITLE_ID = pi_parent_record.TITLE_ID,  
       LAST_UPDATE_DATE = sysdate, 
      UPDATE_BY_LOGIN_ID = pi_parent_record.UPDATE_BY_LOGIN_ID 
      Where PARENT_ID = l_parent_id; 
 
    end if; 
    -- 
    return l_parent_id; 
  Exception 
     when no_data_found then return null; 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'pkg_parent.create_or_replace[1]('||pi_parent_record.parent_id||') ## '||sqlerrm); 
  End create_or_replace; 
 
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
  return parent.parent_id%Type AS 
     l_id parent.parent_id%Type; 
     l_parent_number parent.parent_number%Type := pi_parent_number;
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  BEGIN 
    if pi_first_name is null or pi_last_name is null then return null; end if; 
   /*
    l_id := get_id( pi_first_name => upper(pi_first_name),  
                    pi_last_name => upper(pi_last_name)); 
    if l_id is not null then return l_id; end if; 
   */
    --
    if l_parent_number is null then l_parent_number := pkg_identifiers.get_next('parent'); end if;
    -- 
    l_id := get_id(pi_parent_number => l_parent_number);
    If l_id is null then
    insert into MLT_parent( 
       tenant_id, first_name, last_name, middle_name, gender, cell_phone, 
       work_phone, email_address, add_id, parent_number, occupation, title_id, company_name) 
    values 
      (pkg_tenant.GET_CURRENT_ID(), upper(pi_first_name), upper(pi_last_name), upper(pi_middle_name), 
       upper(pi_gender), pi_cell_phone, pi_work_phone, pi_email_address, pi_add_id, l_parent_number, 
	   pi_occupation, pi_title_id, pi_company_name) 
       returning parent_id into l_id; 
    Else
        update parent
           set first_name = upper(pi_first_name),
               last_name = upper(pi_last_name),
               gender = pi_gender,
               middle_name = pi_middle_name,
               cell_phone = pi_cell_phone,
               work_phone = pi_work_phone,
               email_address = pi_email_address,
               Add_id = pi_add_id
         Where parent_id = l_id;
    end if;
    -- 
    return l_id; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return null; 
    WHEN Already_Caught then raise; 
    WHEN OTHERS THEN  
      raise_application_error(-20001,  
       'pkg_parent.create_or_replace[2]('||pi_first_name||','||pi_last_name||') - '||sqlerrm); 
  END create_or_replace; 
 
-- ------------------------------------------------------------------------- 
-- Function create_or_replace[3] - Parent ID provided 
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
  return parent.parent_id%Type As 
     l_id parent.parent_id%Type := pi_parent_id; 
     l_parent_number parent.parent_number%Type := pi_parent_number;
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  BEGIN 
    if pi_first_name is null or pi_last_name is null then return null; end if; 
    if l_id is null then
       l_id := get_id( pi_first_name => upper(pi_first_name), pi_last_name => upper(pi_last_name)); 
    end if;
    --
    if l_id is not null and l_id = pi_parent_id then  
      --
      if l_parent_number is null then l_parent_number := pkg_identifiers.get_next('parent'); end if;
      --
      update MLT_parent 
         set 
           first_name = upper(pi_first_name),  
           last_name = upper(pi_last_name),  
           gender = pi_gender,  
           cell_phone = pi_cell_phone,  
           work_phone = pi_work_phone,  
           email_address = pi_email_address, 
           add_id = pi_add_id, 
           company_name = pi_company_name,  
           occupation = pi_occupation,  
           title_id = pi_title_id,
           parent_number = l_parent_number,
           middle_name = pi_middle_name
       where parent_id = l_id; 
       return l_id; 
    else 
      --
      if l_parent_number is null then l_parent_number := pkg_identifiers.get_next('parent'); end if;
      --
      insert into MLT_parent( 
         tenant_id, first_name, last_name, gender, cell_phone, 
         work_phone, email_address, add_id, company_name, occupation, title_id,
         parent_number, middle_name) 
      values 
        (pkg_tenant.GET_CURRENT_ID(), upper(pi_first_name), upper(pi_last_name),  
         upper(pi_gender), pi_cell_phone, pi_work_phone, pi_email_address, pi_add_id, 
         pi_company_name, pi_occupation, pi_title_id, l_parent_number, pi_middle_name ) 
      returning parent_id into l_id; 
    end if; 
    -- 
    return l_id; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return null; 
    WHEN Already_Caught then raise; 
    WHEN OTHERS THEN  
      raise_application_error(-20001,  
       'pkg_parent.create_or_replace[3]('||pi_parent_id||','||pi_first_name||','||pi_last_name||') - '||sqlerrm); 
  END create_or_replace; 
 
-- ------------------------------------------------------------------------- 
-- Function is_created() 
-- ------------------------------------------------------------------------- 
  function is_created( 
     pi_first_name in parent.first_name%Type, 
     pi_last_name in parent.last_name%Type)  
     return boolean AS 
     l_id parent.parent_id%Type; 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  BEGIN 
    l_id := get_id( pi_first_name => upper(pi_first_name),  
                    pi_last_name => upper(pi_last_name)); 
    return (l_id is not null); 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return false; 
    WHEN Already_Caught then raise; 
    WHEN OTHERS THEN  
      raise_application_error(-20001,  
       'pkg_parent.is_created('||pi_first_name||','||pi_last_name||') - '||sqlerrm); 
  END is_created; 
 
  function is_created( pi_parent_id in parent.parent_id%Type)  
     return boolean IS  
     l_name varchar2(512); 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  BEGIN 
    l_name := get_name( pi_parent_id => pi_parent_id ); 
    return (l_name is not null); 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return false; 
    WHEN Already_Caught then raise; 
    WHEN OTHERS THEN  
      raise_application_error(-20001,  
       'pkg_parent.is_created('||pi_parent_id ||') - '||sqlerrm); 
  END is_created; 
   
-- ------------------------------------------------------------------------- 
-- Function is_created() 
-- ------------------------------------------------------------------------- 
  function get_id( 
     pi_first_name in parent.first_name%Type, 
     pi_last_name in parent.last_name%Type)  
     return parent.parent_id%Type AS 
     l_id parent.parent_id%Type; 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  BEGIN 
    select parent_id into l_id from 
      (select parent_id 
         from parent 
        where trim(upper(first_name)) = trim(upper(pi_first_name)) 
       and trim(upper(last_name)) = trim(upper(pi_last_name)) 
       order by updated_date desc) 
      where rownum < 2; 
    -- 
    return l_id; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return null; 
    WHEN Already_Caught THEN raise; 
    WHEN OTHERS THEN  
      raise_application_error(-20001,  
       'pkg_parent.get_id('||pi_first_name||','||pi_last_name||') - '||sqlerrm); 
  END get_id; 
  Function get_id(pi_parent_number in parent.parent_number%Type)
     return parent.parent_id%Type Is
     l_id parent.parent_id%Type; 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  BEGIN
    Select parent_id into l_id
      from parent
     where parent_number = pi_parent_number;
    -- 
    return l_id; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return null; 
    WHEN Already_Caught THEN raise; 
    WHEN OTHERS THEN  
      raise_application_error(-20001,  
       'pkg_parent.get_id('||pi_parent_number||') - '||sqlerrm); 
  END get_id; 
-- ------------------------------------------------------------------------- 
-- Function is_created() 
-- ------------------------------------------------------------------------- 
  function get_like_id(  
     pi_first_name in parent.first_name%Type,  
     pi_last_name in parent.last_name%Type)   
     return parent.parent_id%Type is 
     l_id parent.parent_id%Type; 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  BEGIN 
    select parent_id into l_id from 
      (select parent_id 
         from parent 
        where trim(upper(first_name)) like trim(upper(pi_first_name)) 
       and trim(upper(last_name)) = trim(upper(pi_last_name))||'%' 
       order by upper(first_name), upper(last_name), updated_date desc) 
      where rownum < 2; 
    -- 
    return l_id; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return null; 
    WHEN Already_Caught THEN raise; 
    WHEN OTHERS THEN  
      raise_application_error(-20001,  
       'pkg_parent.get_id('||pi_first_name||','||pi_last_name||') - '||sqlerrm); 
  END get_like_id; 
 
-- ------------------------------------------------------------------------- 
-- Function get_name() 
-- ------------------------------------------------------------------------- 
  function get_name( 
     pi_parent_id in parent.parent_id%Type) return varchar2 
  is 
    l_name varchar2(80); 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  Begin 
    select Initcap(par.last_name)||' '||Initcap(par.first_name) into l_name 
       from parent par  
      where par.parent_id = pi_parent_id; 
    -- 
    return l_name; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return null; 
    WHEN Already_Caught THEN raise; 
    WHEN OTHERS THEN  
      raise_application_error(-20001,  
       'pkg_parent.get_name('||pi_parent_id||') - '||sqlerrm); 
  END get_name; 
 
-- ------------------------------------------------------------------------- 
-- Function get_name() 
-- ------------------------------------------------------------------------- 
  function get_other_parent_id( 
     pi_parent_id in parent.parent_id%Type) return parent.parent_id%Type 
  is 
    l_id parent.parent_id%Type; 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  Begin 
    select distinct parent_id into l_id 
       from parent_student 
      where student_id in  
             (select student_id from parent_student where parent_id = pi_parent_id) 
        and parent_id <> pi_parent_id; 
    -- 
    return l_id; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return null; 
    WHEN Already_Caught THEN raise; 
    WHEN OTHERS THEN  
      raise_application_error(-20001,  
       'pkg_parent.get_other_parent_id('||pi_parent_id||') - '||sqlerrm); 
  END get_other_parent_id; 
 
-- ------------------------------------------------------------------------- 
-- Function get_other_parent_name() 
-- ------------------------------------------------------------------------- 
  function get_other_parent_name( 
     pi_parent_id in parent.parent_id%Type) return varchar2 
  is 
    l_name varchar2(80); 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  Begin 
    select distinct Initcap(par.last_name)||' '||Initcap(par.first_name) into l_name 
       from parent_student pst 
            inner join parent par on (par.parent_id = pst.parent_id) 
      where pst.student_id in  
             (select x.student_id from parent_student x where x.parent_id = pi_parent_id) 
        and pst.parent_id <> pi_parent_id; 
    -- 
    return l_name; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return null; 
    WHEN Already_Caught THEN raise; 
    WHEN OTHERS THEN  
      raise_application_error(-20001,  
       'pkg_parent.get_other_parent_name('||pi_parent_id||') - '||sqlerrm); 
  END get_other_parent_name; 
 
-- -------------------------------------------------------------------------  
-- Procedure set_parent_student
-- -------------------------------------------------------------------------  
  procedure set_parent_student(
       pi_parent_id in parent.parent_id%Type, 
	   pi_student_id in student.student_id%type,
	   pi_rel_type_id in parent_student.rel_type_id%type,
	   pi_is_primary in parent_student.is_primary%type := 'N') is
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  Begin
    /*
    Merge into parent_student t
	Using (select pi_parent_id as parent_id, pi_student_id as student_id, 
	              pi_rel_type_id as rel_type_id, upper(pi_is_primary) as is_primary from system.dual) s
	  on (s.parent_id = t.parent_id and s.student_id = t.student_id)
	When Matched then update set t.rel_type_id = s.rel_type_id, t.is_primary = s.is_primary
	When Not Matched then 
    Insert (parent_id, student_id, rel_type_id, is_primary)
	values (s.parent_id, s.student_id, s.rel_type_id, s.is_primary);
	*/
	Update parent_student t
	   set t.rel_type_id = pi_rel_type_id, t.is_primary = pi_is_primary
	 where t.parent_id = pi_parent_id and t.student_id = pi_student_id;
	if sql%rowcount <= 0 then
      Insert into parent_student (parent_id, student_id, rel_type_id, is_primary)
	  values (pi_parent_id, pi_student_id, pi_rel_type_id, pi_is_primary);
	end if;
  EXCEPTION 
    WHEN Already_Caught THEN raise; 
    WHEN OTHERS THEN  
      raise_application_error(-20001,  
       'pkg_parent.set_parent_student('||pi_parent_id||', '||pi_student_id||') - '||sqlerrm); 
  End  set_parent_student; 

END PKG_PARENT; 
