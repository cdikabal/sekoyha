create or replace PACKAGE BODY           "PKG_EMPLOYEE" AS
-- =============================================================================
-- P R I V A T E   F U N C T I O N S   A N D   P R O C E D U R E S
-- =============================================================================
-- =============================================================================
-- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S
-- =============================================================================
function create_replace( 
               p_first_name in employee.first_name%Type, 
               p_last_name in employee.last_name%Type, 
               p_gender in employee.gender%Type default null, 
               p_home_phone in employee.home_phone%Type default null, 
               p_is_teacher in employee.is_teacher%Type default 'Y',
               p_add_id in employee.add_id%Type default null) 
  return employee.employee_id%Type AS
  l_id employee.employee_id%Type;
  l_employee_number employee.employee_number%Type;
  BEGIN
    if p_first_name is null or p_last_name is null then return null; end if;
    l_id := get_id( p_first_name => upper(p_first_name), 
                    p_last_name => upper(p_last_name));
    if l_id is not null then return l_id; end if;
    --
    l_employee_number := pkg_identifiers.get_next('employee');
    insert into employee(
       first_name, last_name, gender, home_phone,
       is_teacher, add_id, employee_number)
    values
      (upper(p_first_name), upper(p_last_name), 
       upper(p_gender), p_home_phone, p_is_teacher, p_add_id, l_employee_number);
    --
    l_id := get_id(p_employee_number => l_employee_number);
    --
    return l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_employee.create_replace('||p_first_name||','||p_last_name||') - '||sqlerrm);
  END create_replace;
function create_replace( 
               p_employee_id in employee.employee_id%Type,
               p_first_name in employee.first_name%Type, 
               p_last_name in employee.last_name%Type, 
               p_gender in employee.gender%Type, 
               p_home_phone in employee.home_phone%Type, 
               p_cell_phone in employee.cell_phone%Type, 
               p_work_phone in employee.work_phone%Type, 
               p_title_id in employee.title_id%Type, 
               p_email_address in employee.email_address%Type, 
               p_is_teacher in employee.is_teacher%Type,
               p_ss_number in employee.ss_number%Type,
               p_hire_date in employee.hire_date%Type,
               p_terminate_date in employee.terminate_date%Type,
               p_add_id in employee.add_id%Type) 
  return employee.employee_id%Type As
  l_id employee.employee_id%Type;
  BEGIN
    if p_first_name is null or p_last_name is null then return null; end if;
    l_id := get_id( p_first_name => upper(p_first_name), 
                      p_last_name => upper(p_last_name));
    --
    if l_id is not null then 
      update employee
         set
           first_name = p_first_name, 
           last_name = p_last_name, 
           gender = upper(p_gender), 
           cell_phone = p_cell_phone, 
           work_phone = p_work_phone, 
           email_address = p_email_address, 
           home_phone    = p_home_phone,
           title_id     = p_title_id,
           is_teacher   = p_is_teacher,
           ss_number    = p_ss_number,
           hire_date    = p_hire_date,
           terminate_date  = p_terminate_date,
           add_id = p_add_id
       where employee_id = l_id;
       return l_id;
    else
      --
      if p_employee_id is null then 
        l_id := pkg_identifiers.get_next('employee');
      else
        l_id := p_employee_id;
      end if;
      insert into employee(
         employee_id, first_name, last_name, gender, cell_phone,
         work_phone, email_address, add_id, home_phone, 
         title_id, is_teacher, ss_number, hire_date, terminate_date)
      values
        --(pkg_identifiers.get_next('employee'), upper(p_first_name), upper(p_last_name), 
        (l_id, upper(p_first_name), upper(p_last_name), 
         upper(p_gender), p_cell_phone, p_work_phone, p_email_address, p_add_id,
         p_home_phone, p_title_id, p_is_teacher, p_ss_number, p_hire_date, 
         p_terminate_date)
      returning employee_id into l_id;
    end if;
    return l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_employee.create_replace('
         ||p_employee_id||','||p_first_name||','||p_last_name||') - '||sqlerrm);
  END create_replace;
-- -----------------------------------------------------------------------------
-- function is_created() -- Full Employee record
-- -----------------------------------------------------------------------------
  function create_replace(p_employee_record in employee%RowType)  return employee.employee_id%Type
  is
    l_employee_id employee.employee_id%Type;
    --
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    if p_employee_record.employee_id is not null then
      Update employee set row = p_employee_record
      where employee_id = p_employee_record.employee_id;
      l_employee_id := p_employee_record.employee_id;
    else
      Insert Into employee Values p_employee_record;
      --
      l_employee_id := get_id(p_employee_record.first_name, p_employee_record.last_name);
    end if;
    --
    return l_employee_id;
  Exception
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'create_replace-record('||p_employee_record.employee_id||'/'||p_employee_record.first_name||') ## '||sqlerrm);
  End create_replace;
  
-- -----------------------------------------------------------------------------
-- function is_created()
-- -----------------------------------------------------------------------------
  function is_created(
     p_first_name in employee.first_name%Type,
     p_last_name in employee.last_name%Type) 
     return boolean AS
  l_id employee.employee_id%Type;
  BEGIN
    l_id := get_id( p_first_name => upper(p_first_name), 
                    p_last_name => upper(p_last_name));
    return (l_id is not null);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return false;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_employee.is_created('||p_first_name||','||p_last_name||') - '||sqlerrm);
  END is_created;
  -- ---------------------------------------------------------------------------
  -- ---------------------------------------------------------------------------
  function get_id(
     p_first_name in employee.first_name%Type,
     p_last_name in employee.last_name%Type) 
     return employee.employee_id%Type AS
  l_id employee.employee_id%Type;
  BEGIN
    select employee_id into l_id
      from employee
     where first_name = upper(p_first_name)
       and last_name = upper(p_last_name);
    --
    return l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_employee.get_id('||p_first_name||','||p_last_name||') - '||sqlerrm);
  END get_id;
  -- ---------------------------------------------------------------------------
  -- function get_id()
  -- ---------------------------------------------------------------------------
  function get_id(p_employee_number in employee.employee_number%Type) return employee.employee_id%Type is
  l_id employee.employee_id%Type;
  BEGIN
    select employee_id into l_id
      from employee
     where employee_number = p_employee_number;
    --
    return l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_employee.get_id(empno= '||p_employee_number||') - '||sqlerrm);
  END get_id;
  -- ---------------------------------------------------------------------------
  -- procedure set_employee_contact()
  -- ---------------------------------------------------------------------------
  procedure set_employee_contact(
     p_employee_id in employee_contact.employee_id%Type, 
     p_contact_id in employee_contact.contact_id%Type, 
     p_rel_type_id in employee_contact.rel_type_id%Type default 'SPOUSE', 
     p_emergency in employee_contact.emergency%Type default 'Y') is
  Begin
    merge into employee_contact r
    using 
      (select p_employee_id as employee_id, p_contact_id as contact_id
         from dual ) s
      on (s.employee_id = r.employee_id 
          and s.contact_id = r.contact_id)
    when matched then
      update set r.rel_type_id = p_rel_type_id, r.emergency = p_emergency
    when not matched then
      insert (employee_id, contact_id, rel_type_id, emergency)
      values (p_employee_id, p_contact_id, p_rel_type_id, nvl(p_emergency,'Y'));
  EXCEPTION
    WHEN NO_DATA_FOUND or DUP_VAL_ON_INDEX THEN null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.set_employee_contact('||p_employee_id||','||p_contact_id||
       ','||p_rel_type_id||') - '||sqlerrm);
  END set_employee_contact;
  -- ---------------------------------------------------------------------------
  -- function get_name()
  -- ---------------------------------------------------------------------------
  function get_name(pi_employee_id in employee.employee_id%Type) 
  return varchar2 is
    l_name varchar2(255);
  begin
    select initcap(last_name)||', '||initcap(first_name)
      into l_name
      from employee
     where employee_id = pi_employee_id;
    --
    return l_name;
  exception
    when no_data_found then return null;
    when OTHERS then 
      raise_application_error(-20001, 
       'pkg_student.get_name('||pi_employee_id||') - '||sqlerrm);
  end get_name;
  -- ---------------------------------------------------------------------------
  -- function get_record()
  -- ---------------------------------------------------------------------------
  function get_record(p_employee_id in employee.employee_id%Type) return employee%RowType
  is
    l_employee_record employee%RowType;
    --
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    select * into l_employee_record 
      from employee where employee_id = p_employee_id;
    return l_employee_record;
  Exception
    when no_data_found then return null;
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'get_record(EmployeeID= '||p_employee_id||') ## '||sqlerrm);
  End get_record;
  -- ---------------------------------------------------------------------------
  -- function get_record()
  -- ---------------------------------------------------------------------------
  function get_record(p_login_name in employee.login_name%Type) return employee%RowType
  is
    l_employee_record employee%RowType;
    --
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    select memp.* into l_employee_record 
      from employee memp 
      where upper(memp.login_name) = upper(p_login_name);
    --
    --dbms_output.put_line('-> get_record(loginName= '||p_login_name||') : Employe ID is <'||l_employee_record.employee_id||'> ');
    --
    return l_employee_record;
  Exception
    when no_data_found then return null;
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'get_record(loginName= '||p_login_name||') ## '||sqlerrm);
  End get_record;
  -- ---------------------------------------------------------------------------
  -- function get_record()
  -- ---------------------------------------------------------------------------
  function get_record(p_login_id in login.login_id%Type) return employee%RowType
  is
    l_employee_record employee%RowType;
    --
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    select memp.* into l_employee_record 
      from employee memp 
      where upper(memp.login_name) = (select upper(login_name) from login mlog where mlog.login_id = p_login_id );
    --
    --dbms_output.put_line('-> get_record(loginName= '||p_login_name||') : Employe ID is <'||l_employee_record.employee_id||'> ');
    --
    return l_employee_record;
  Exception
    when no_data_found then return null;
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'get_record(loginName= '||p_login_id||') ## '||sqlerrm);
  End get_record;
 
-- ---------------------------------------------------------------------------
-- procedure create_employee()
-- ---------------------------------------------------------------------------
  Function create_employee(
               pi_first_name in employee.first_name%Type       , 
               pi_last_name in employee.last_name%Type         , 
               pi_gender in employee.gender%Type               , 
               pi_home_phone in employee.home_phone%Type       := null, 
               pi_cell_phone in employee.cell_phone%Type       := null, 
               pi_work_phone in employee.work_phone%Type       := null, 
               pi_title_id in employee.title_id%Type           := null, 
               pi_email_address in employee.email_address%Type := null, 
               pi_is_teacher in employee.is_teacher%Type       := 'N',
               pi_ss_number in employee.ss_number%Type         := null,
               pi_hire_date in employee.hire_date%Type         := null,
               pi_position_id in employee.position_id%Type     := null,
               pi_department_id in employee.department_id%Type := null,
    -- Address
               pi_add_desc_1 in address.add_desc_1%Type,
               pi_add_desc_2 in address.add_desc_2%Type        := null,
               pi_add_city in address.add_city%Type,
               pi_add_postal_code in address.add_postal_code%Type,
               pi_province_id in address.province_id%Type,
               pi_country_id in address.country_id%Type,
               pi_add_fax in address.add_fax%Type := null,
    -- 1st contact
               pi_mcon1_FIRST_NAME in contact.FIRST_NAME%Type   := null, 
   	           pi_mcon1_LAST_NAME in contact.LAST_NAME%Type     := null, 
	           pi_mcon1_PHONE_1 in contact.PHONE_1%Type         := null, 
	           pi_mcon1_PHONE_2 in contact.PHONE_2%Type         := null, 
               pi_mcon1_desc_1 in address.add_desc_1%Type       := null,
               pi_mcon1_desc_2 in address.add_desc_2%Type       := null,
               pi_mcon1_city in address.add_city%Type           := null,
               pi_mcon1_postal_code in address.add_postal_code%Type := null,
               pi_mcon1_province_id in address.province_id%Type := null,
               pi_mcon1_country_id in address.country_id%Type   := null,
	           pi_mcon1_GENDER in contact.GENDER%Type           := null, 
	           pi_mcon1_EMAIL_ADDRESS in contact.EMAIL_ADDRESS%Type := null, 
	           pi_mcon1_COMMENTS in contact.COMMENTS%Type       := null,
               pi_mcon1_REL_TYPE_ID in employee_contact.REL_TYPE_ID%Type := null,
               pi_mcon1_EMERGENCY in employee_contact.EMERGENCY%Type := null,
    -- 2nd contact
               pi_mcon2_FIRST_NAME in contact.FIRST_NAME%Type   := null, 
   	           pi_mcon2_LAST_NAME in contact.LAST_NAME%Type     := null, 
	           pi_mcon2_PHONE_1 in contact.PHONE_1%Type         := null, 
	           pi_mcon2_PHONE_2 in contact.PHONE_2%Type         := null, 
               pi_mcon2_desc_1 in address.add_desc_1%Type       := null,
               pi_mcon2_desc_2 in address.add_desc_2%Type       := null,
               pi_mcon2_city in address.add_city%Type           := null,
               pi_mcon2_postal_code in address.add_postal_code%Type := null,
               pi_mcon2_province_id in address.province_id%Type := null,
               pi_mcon2_country_id in address.country_id%Type   := null,
	           pi_mcon2_GENDER in contact.GENDER%Type           := null, 
	           pi_mcon2_EMAIL_ADDRESS in contact.EMAIL_ADDRESS%Type := null, 
	           pi_mcon2_COMMENTS in contact.COMMENTS%Type       := null,
               pi_mcon2_REL_TYPE_ID in employee_contact.REL_TYPE_ID%Type := null,
               pi_mcon2_EMERGENCY in employee_contact.EMERGENCY%Type := null
  ) return employee.employee_id%Type is
    l_add_id address.add_id%Type;
    l_employee_id employee.employee_id%Type;
    l_contact_id contact.contact_id%Type;
    --
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    l_add_id := pkg_address.create_or_replace( 
               pi_add_desc_1 => pi_add_desc_1, 
               pi_add_phone => pi_home_phone, 
               pi_add_postal_code => pi_add_postal_code, 
               pi_add_city => pi_add_city, 
               pi_province_id => pi_province_id, 
               pi_country_id => pi_country_id, 
               pi_desc_2 => pi_add_desc_2, 
               pi_add_fax => pi_add_fax);
    --
    Insert Into MLT_EMPLOYEE(
        FIRST_NAME, 	LAST_NAME,     IS_TEACHER, IS_ADMIN_STAFF,
        SS_NUMBER, 	ADD_ID,        HIRE_DATE, 
        GENDER, 	WORK_PHONE,    HOME_PHONE, 
        CELL_PHONE, 	EMAIL_ADDRESS, TITLE_ID, POSITION_ID,
        EMPLOYEE_NUMBER, DEPARTMENT_ID,
        EMPLOYEE_ID, TENANT_ID) 
  Values(pi_first_name, pi_last_name, pi_is_teacher,
         case when pi_is_teacher = 'Y' then 'N' else 'Y' end,
         pi_ss_number, l_add_id, pi_hire_date, pi_gender,
         pi_work_phone, pi_home_phone, pi_cell_phone,
         pi_email_address, pi_title_id, pi_position_id,
         pkg_identifiers.get_next('employee number'), pi_department_id,
         pkg_object.Get_Next_Id(pi_object_code=>pkg_object.get_code(pi_object_name=>'MLT_EMPLOYEE')),
         pkg_tenant.get_current_id())
  returning employee_id into l_employee_id
  ;
  -- --------------------------------
  -- Contact 1
  -- --------------------------------
  if pi_mcon1_FIRST_NAME is not null and pi_mcon1_LAST_NAME is not null and pi_mcon1_REL_TYPE_ID is not null
  then
    if pi_mcon1_desc_1 is not null and pi_mcon1_PHONE_1 is not null and pi_mcon1_postal_code is not null
    then
      l_add_id := pkg_address.create_or_replace( 
               pi_add_desc_1 => pi_mcon1_desc_1, 
               pi_add_phone => pi_mcon1_PHONE_1, 
               pi_add_postal_code => pi_mcon1_postal_code, 
               pi_add_city => pi_mcon1_city, 
               pi_province_id => pi_mcon1_province_id, 
               pi_country_id => pi_mcon1_country_id, 
               pi_desc_2 => pi_mcon1_desc_2);
    else
      l_add_id := null;
    end if;
    --
    l_contact_id := pkg_contact.create_replace(  
               p_first_name => pi_mcon1_FIRST_NAME,  
               p_last_name  => pi_mcon1_LAST_NAME,  
               p_phone_1    => pi_mcon1_PHONE_1,  
               p_add_id     => l_add_id,
               --p_phone_2 in contact.phone_2%Type := null,  
               p_gender     => pi_mcon1_GENDER,  
               p_email_address => pi_mcon1_EMAIL_ADDRESS);
               --p_comments in contact.comments%Type := null);
    --
    Insert into employee_contact(employee_id, contact_id, rel_type_id, emergency)
    Values(l_employee_id, l_contact_id, pi_mcon1_REL_TYPE_ID, nvl(pi_mcon1_EMERGENCY,'N'));
  End if;
  -- --------------------------------
  -- Contact 2
  -- --------------------------------
  if pi_mcon2_FIRST_NAME is not null and pi_mcon2_LAST_NAME is not null and pi_mcon2_REL_TYPE_ID is not null
  then
    if pi_mcon2_desc_1 is not null and pi_mcon2_PHONE_1 is not null and pi_mcon2_postal_code is not null
    then
      l_add_id := pkg_address.create_or_replace( 
               pi_add_desc_1  => pi_mcon2_desc_1, 
               pi_add_phone   => pi_mcon2_PHONE_1, 
               pi_add_postal_code => pi_mcon2_postal_code, 
               pi_add_city    => pi_mcon2_city, 
               pi_province_id => pi_mcon2_province_id, 
               pi_country_id  => pi_mcon2_country_id, 
               pi_desc_2      => pi_mcon2_desc_2);
    else
      l_add_id := null;
    end if;
    --
    l_contact_id := pkg_contact.create_replace(  
               p_first_name => pi_mcon2_FIRST_NAME,  
               p_last_name  => pi_mcon2_LAST_NAME,  
               p_phone_1    => pi_mcon2_PHONE_1,  
               p_add_id     => l_add_id,
               --p_phone_2 in contact.phone_2%Type := null,  
               p_gender     => pi_mcon2_GENDER,  
               p_email_address => pi_mcon2_EMAIL_ADDRESS);
               --p_comments in contact.comments%Type := null);
    --
    Insert into employee_contact(employee_id, contact_id, rel_type_id, emergency)
    Values(l_employee_id, l_contact_id, pi_mcon2_REL_TYPE_ID, nvl(pi_mcon2_EMERGENCY,'N'));
  End if;
  --
  return l_employee_id;
  Exception
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'Create_Employee('||pi_Last_Name||','||pi_first_name||') ## '||sqlerrm);
  End Create_Employee;
 
-- ---------------------------------------------------------------------------
-- procedure update_employee()
-- ---------------------------------------------------------------------------
  procedure update_employee(
               pi_employee_id in employee.employee_id%Type     ,
               pi_first_name in employee.first_name%Type       , 
               pi_last_name in employee.last_name%Type         , 
               pi_gender in employee.gender%Type               , 
               pi_home_phone in employee.home_phone%Type       := null, 
               pi_cell_phone in employee.cell_phone%Type       := null, 
               pi_work_phone in employee.work_phone%Type       := null, 
               pi_title_id in employee.title_id%Type           := null, 
               pi_email_address in employee.email_address%Type := null, 
               pi_is_teacher in employee.is_teacher%Type       := 'N',
               pi_ss_number in employee.ss_number%Type         := null,
               pi_hire_date in employee.hire_date%Type         := null,
               pi_position_id in employee.position_id%Type     := null,
               pi_department_id in employee.department_id%Type     := null,
    -- Address
               pi_add_id in address.add_id%Type                ,
               pi_add_desc_1 in address.add_desc_1%Type        ,
               pi_add_desc_2 in address.add_desc_2%Type        := null,
               pi_add_city in address.add_city%Type            ,
               pi_add_postal_code in address.add_postal_code%Type,
               pi_province_id in address.province_id%Type      ,
               pi_country_id in address.country_id%Type        ,
               pi_add_fax in address.add_fax%Type := null)
  Is
    l_add_id address.add_id%Type := pi_add_id;
    --
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    if pi_add_id is null then
      l_add_id := pkg_address.create_or_replace( 
               pi_add_desc_1 => pi_add_desc_1, 
               pi_add_phone => pi_home_phone, 
               pi_add_postal_code => pi_add_postal_code, 
               pi_add_city => pi_add_city, 
               pi_province_id => pi_province_id, 
               pi_country_id => pi_country_id, 
               pi_desc_2 => pi_add_desc_2, 
               pi_add_fax => pi_add_fax);
    end if;
    --
    Update employee
       set first_name = upper(pi_first_name)
           , last_name = upper(pi_last_name)
           , gender = upper(pi_gender)
           , home_phone = pi_home_phone
           , cell_phone = pi_cell_phone
           , work_phone = pi_work_phone
           , title_id = pi_title_id
           , email_address = pi_email_address
           , is_teacher = pi_is_teacher
           , ss_number = pi_ss_number
           , hire_date = pi_hire_date
           , position_id = pi_position_id
           , department_id = pi_department_id
           , last_update_date = sysdate
      where employee_id = pi_employee_id;
    --
  Exception
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'Update_Employee('||pi_employee_id||','||pi_Last_Name||','||pi_first_name||') ## '||sqlerrm);
  End Update_Employee;
 
  -- ---------------------------------------------------------------------------
  -- procedure delete_employee()
  -- ---------------------------------------------------------------------------
  procedure delete_employee(pi_employee_id in employee.employee_id%Type) 
  Is
    --
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    Delete from ADDRESS where add_id in (select memp.add_id from EMPLOYEE memp where memp.employee_id = pi_employee_id);
    Delete from EMPLOYEE_CONTACT where employee_id = pi_employee_id;
    Delete from CONTACT mcon where mcon.contact_id not in (select x.contact_id from EMPLOYEE_CONTACT x);
    Delete from EMPLOYEE where employee_id = pi_employee_id;
  Exception
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'delete_employee('||pi_employee_id||') ## '||sqlerrm);
  End delete_employee;
 
  -- ---------------------------------------------------------------------------
  -- procedure create_employee_activity_type()
  -- ---------------------------------------------------------------------------
  procedure create_employee_activity_type(
        pi_employee_id in employee_activity_type.employee_id%Type,
        pi_activity_type_id in employee_activity_type.activity_type_id%Type)
  Is
    --
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    Insert Into employee_activity_type(employee_id, activity_type_id)
    values (pi_employee_id, pi_activity_type_id);
  Exception
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'create_employee_activity_type(employe_id='||pi_employee_id||',activity_type='||pi_activity_type_id||') ## '||sqlerrm);
  End create_employee_activity_type;
 
  -- ---------------------------------------------------------------------------
  -- procedure delete_employee_activity_type()
  -- ---------------------------------------------------------------------------
  procedure delete_employee_activity_type(
        pi_employee_id in employee_activity_type.employee_id%Type     ,
        pi_activity_type_id in employee_activity_type.activity_type_id%Type)
  Is
    --
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    Delete From employee_activity_type
     Where employee_id = pi_employee_id
       And activity_type_id = pi_activity_type_id;
  Exception
    when Already_Caught then raise;
    when others then
       raise_application_error(-20001, 'delete_employee_activity_type(employe_id='||pi_employee_id||',activity_type='||pi_activity_type_id||') ## '||sqlerrm);
  End delete_employee_activity_type;
 
END PKG_EMPLOYEE;
