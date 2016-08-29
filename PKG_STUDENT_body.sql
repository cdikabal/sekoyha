create or replace PACKAGE BODY  "PKG_STUDENT" AS
-- =============================================================================
-- P R I V A T E   T Y P E   A N D   V A R I A B L E S
-- =============================================================================
TYPE Cursor_Type is REF CURSOR;
-- =============================================================================
-- P R I V A T E   P R O C E D U R E S   A N D   F U N C T I O N S
-- =============================================================================
  function get_inscription_id
      (p_student_id in student.student_id%Type, 
       p_school_year_id in inscription.school_year_id%Type,
       p_grade_type_id in inscription.grade_type_id%Type)
  return number is
    l_id number;
  begin
    --
    select ins_id into l_id
      from inscription i
     where i.student_id = p_student_id
       and i.school_year_id = p_school_year_id
       and i.grade_type_id = p_grade_type_id;
    --
    return l_id;
    --
  exception
    when no_data_found then return null;
    when others then raise;
  end get_inscription_id;
  
-- -----------------------------------------------------------------------------
-- Function local_get_rel_type_id()
-- -----------------------------------------------------------------------------
  Function local_get_rel_type_id(pi_parent_id in parent.parent_id%Type) return relationship_type.rel_type_id%Type is
    l_rel_type_id relationship_type.rel_type_id%Type;
    Already_Caught Exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    begin
	  select ps.rel_type_id into l_rel_type_id 
	  from parent_student ps
	  where ps.parent_id = pi_parent_id
	  and rownum = 1;
	exception
	  when no_data_found then null;
	  when others then raise;
	end;
	--
	if l_rel_type_id is null then
	  begin
	    select 
		   case 
		      when p.gender = 'F' then (select r.rel_type_id from relationship_type r where r.rel_name = 'Mom')
			  else (select r.rel_type_id from relationship_type r where r.rel_name = 'Dad')
		   end
		   into l_rel_type_id
		from parent p
		where p.parent_id = pi_parent_id;
	  exception
  	    when no_data_found then null;
	    when others then raise;
	  end;
	end if;
	return l_rel_type_id;
  Exception
      when Already_Caught then raise;
      when others then
      raise_application_error(-20001, 
       'pkg_student.local_get_rel_type_id('||pi_parent_id||') - '||sqlerrm);
  End local_get_rel_type_id;
  
-- =============================================================================
-- P U B L I C   P R O C E D U R E S   A N D   F U N C T I O N S
-- =============================================================================
  Function create_or_replace (pi_student_record in student%RowType ) 
  return student.student_id%Type is
  l_id student.student_id%Type;
  Begin
    return l_id;
  End;
  --
-- -----------------------------------------------------------------------------
-- Function create_replace()
-- -----------------------------------------------------------------------------
  function create_replace(
               p_first_name in student.first_name%Type, 
               p_last_name in student.last_name%Type, 
               p_gender in student.gender%Type, 
               p_birth_date in student.birth_date%Type, 
               p_health_card in student.health_card%Type, 
               p_dr_id in student.dr_id%Type, 
               p_add_id in student.add_id%Type,
			   p_par1_parent_id in parent.parent_id%Type := null,
			   p_par2_parent_id in parent.parent_id%Type := null
			   )
  return student.student_id%Type AS
  l_id student.student_id%Type;
  BEGIN
    if p_first_name is null or p_last_name is null then return null; end if;
    l_id := get_id( p_first_name => upper(p_first_name), 
                    p_last_name => upper(p_last_name));
    if l_id is not null then return l_id; end if;
    --
    dbms_output.put('--> New student '||p_last_name||', '|| p_first_name);
    --
    /*
    insert into student(
       student_id, first_name, last_name, gender, birth_date,
       health_card, dr_id, add_id)
    values
      (person_seq.nextval, upper(p_first_name), upper(p_last_name), 
       upper(p_gender), p_birth_date, p_health_card, p_dr_id, p_add_id)
       returning student_id into l_id;
    */
    --
    dbms_output.put_line('<'||l_id||'>');
    --
    return l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.create_replace[1]('||p_first_name||','||p_last_name||') - '||sqlerrm);
  END create_replace;
-- -----------------------------------------------------------------------------
-- Function create_replace()
-- -----------------------------------------------------------------------------
  function create_replace( 
               p_student_id in student.student_id%Type, 
               p_first_name in student.first_name%Type, 
               p_last_name in student.last_name%Type, 
               p_gender in student.gender%Type, 
               p_birth_date in student.birth_date%Type, 
               p_health_card in student.health_card%Type, 
               p_dr_id in student.dr_id%Type, 
               p_add_id in student.add_id%Type,
               p_tylenol_ifneeded in student.tylenol_ifneeded%Type := null,
			   p_par1_parent_id in parent.parent_id%Type := null,
			   p_par2_parent_id in parent.parent_id%Type := null
			   )
  return student.student_id%Type As
  l_id student.student_id%Type;
  BEGIN
    /*
    if p_first_name is null or p_last_name is null then return null; end if;
    l_id := get_id( p_first_name => upper(p_first_name), 
                    p_last_name => upper(p_last_name));
    if l_id is not null and p_student_id = l_id then 
      update student
         set
           first_name = upper(p_first_name), 
           last_name = upper(p_last_name), 
           gender = nvl(p_gender, gender), 
           birth_date = p_birth_date, 
           health_card = nvl(p_health_card, health_card), 
           dr_id = p_dr_id, 
           add_id = p_add_id,
           tylenol_ifneeded = p_tylenol_ifneeded
       where student_id = l_id;
       return l_id;
    else
      --
      insert into student(
        student_id, first_name, last_name, gender, birth_date,
        health_card, dr_id, add_id, tylenol_ifneeded)
      values
        (p_student_id, upper(p_first_name), upper(p_last_name), 
         upper(p_gender), p_health_card, p_birth_date, p_dr_id, p_add_id, p_tylenol_ifneeded)
       returning student_id into l_id;
    end if;
    */
    --
    return l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.create_replace[2]('||p_student_id||','||p_first_name||','||p_last_name||') - '||sqlerrm);
  END create_replace;
-- -----------------------------------------------------------------------------
-- Function is_created()
-- -----------------------------------------------------------------------------
  function is_created(
     p_first_name in student.first_name%Type,
     p_last_name in student.last_name%Type) 
     return boolean AS
  l_id student.student_id%Type;
  BEGIN
    l_id := get_id( p_first_name => upper(p_first_name), 
                    p_last_name => upper(p_last_name));
    return (l_id is not null);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return false;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.create_replace('||p_first_name||','||p_last_name||') - '||sqlerrm);
  END is_created;
-- -----------------------------------------------------------------------------
-- Function is_created()
-- -----------------------------------------------------------------------------
  function is_created(
     p_student_id in student.student_id%Type)
     return boolean AS
  l_id student.student_id%Type;
  BEGIN
    select student_id into l_id from student where student_id = p_student_id;
    return (l_id is not null);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return false;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.create_replace(ID='||p_student_id||') - '||sqlerrm);
  END is_created;
-- -----------------------------------------------------------------------------
-- Function get_id()
-- -----------------------------------------------------------------------------
  function get_id(
     p_first_name in student.first_name%Type,
     p_last_name in student.last_name%Type) 
     return student.student_id%Type AS
  l_id student.student_id%Type;
  BEGIN
    select student_id into l_id
      from student
     where first_name = upper(p_first_name)
       and last_name = upper(p_last_name);
    --
    return l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.get_id('||p_first_name||','||p_last_name||') - '||sqlerrm);
  END get_id;
 
  function get_id(  
     p_student_number in student.student_number%Type)   
     return student.student_id%Type as
  l_id student.student_id%Type;
  BEGIN
    select student_id into l_id
      from student
     where student_number = p_student_number;
    --
    return l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.get_id('||p_student_number||') - '||sqlerrm);
  END get_id;
 
-- -----------------------------------------------------------------------------
-- procedure set_parent_student()
-- -----------------------------------------------------------------------------
procedure set_parent_student(
     p_student_id in parent_student.student_id%Type,
     p_parent_id in parent_student.parent_id%Type,
     p_rel_type_id in parent_student.rel_type_id%Type) is
  Begin
    merge into parent_student r
    using 
      (select p_student_id as student_id, p_parent_id as parent_id
         from dual t
      ) s on (s.student_id = r.student_id
              and s.parent_id = r.parent_id)
    when matched then
      update set r.rel_type_id = p_rel_type_id
    when not matched then
      insert (student_id, parent_id, rel_type_id)
      values (p_student_id, p_parent_id, p_rel_type_id);
  EXCEPTION
    WHEN NO_DATA_FOUND or DUP_VAL_ON_INDEX THEN null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.set_parent_student('||p_student_id||','||p_parent_id||') - '||sqlerrm);
  End set_parent_student;
-- -----------------------------------------------------------------------------
-- Procedure set_student_contact()
-- -----------------------------------------------------------------------------
procedure set_student_contact(
     p_student_id in student_contact.student_id%Type, 
     p_contact_id in student_contact.contact_id%Type, 
     p_rel_type_id in student_contact.rel_type_id%Type, 
     p_emergency in student_contact.emergency%Type default 'Y') is
  Begin
    merge into student_contact r
    using 
      (select p_student_id as student_id, p_contact_id as contact_id
         from dual ) s
      on (s.student_id = r.student_id 
          and s.contact_id = r.contact_id)
    when matched then
      update set r.rel_type_id = p_rel_type_id, r.emergency = p_emergency
    when not matched then
      insert (student_id, contact_id, rel_type_id, emergency)
      values (p_student_id, p_contact_id, p_rel_type_id, nvl(p_emergency,'Y'));
  EXCEPTION
    WHEN NO_DATA_FOUND or DUP_VAL_ON_INDEX THEN null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.set_student_contact('||p_student_id||','||p_contact_id||
       ','||p_rel_type_id||') - '||sqlerrm);
  End set_student_contact;
-- -----------------------------------------------------------------------------
-- Function register_in()
-- -----------------------------------------------------------------------------
  Function register_in(
     p_student_id in inscription.student_id%Type,
     p_school_year_id in inscription.school_year_id%Type,
     p_grade_type_id in inscription.grade_type_id%Type,
     p_class_id in inscription.class_id%Type,
     p_ins_date in inscription.ins_date%Type default sysdate,
     p_ins_comments in inscription.ins_comments%Type default null) 
     return inscription.ins_id%Type Is
  l_id inscription.ins_id%Type;
  Begin
    --
    l_id := get_inscription_id(p_student_id, p_school_year_id, p_grade_type_id);
    /*
    if l_id is not null then 
      update inscription set confirmed='Y', disabled='N'
       where ins_id = l_id;
      return l_id; 
    end if;
    --
    begin
      insert into inscription
        (ins_id, student_id, school_year_id, grade_type_id, ins_comments, ins_date, confirmed, disabled)
      values 
        (pkg_identifiers.get_next('inscription'),
         p_student_id, p_school_year_id, p_grade_type_id, p_ins_comments, nvl(p_ins_date, sysdate), 'Y', 'N')
      returning ins_id into l_id;
    exception
      when dup_val_on_index then 
        dbms_output.put_line('pkg_student.register::inscription'||
           '('||p_student_id||','||p_school_year_id||','||p_grade_type_id||') - Already exists');
      when others then 
        raise_application_error(-20001, 
           'pkg_student.register::inscription'||
           '('||p_student_id||','||p_school_year_id||','||p_grade_type_id||') - '||sqlerrm);
    end;
    --
    if p_employee_id is not null then
    begin
      insert into student_teacher(student_id, employee_id, school_year_id)
      values (p_student_id, p_employee_id, p_school_year_id);
    exception
      when dup_val_on_index then 
        dbms_output.put_line('pkg_student.register::student_teacher'||
           '('||p_student_id||','||p_school_year_id||','||p_grade_type_id||') - Already exists');
      when others then 
        raise_application_error(-20001, 
        'pkg_student.register::student_teacher'||
           '('||p_student_id||','||p_employee_id||','||p_school_year_id||') - '||sqlerrm);
    end;
    else
        dbms_output.put_line('pkg_student.register::student_teacher('||p_student_id||') -- No teacher');
    end if;
    */
    --
    return l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN RAISE;
  End register_in;
-- -----------------------------------------------------------------------------
-- Function get_name()
-- -----------------------------------------------------------------------------
  function get_name(p_student_id in student.student_id%Type)
  return varchar2
  is
    l_name varchar2(80);
  Begin
    select Initcap(std.last_name)||', '||Initcap(std.first_name)
      into l_name
      from student std
     where std.student_id = p_student_id;
    return l_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.get_name('||p_student_id||') - '||sqlerrm);
  End get_name;
-- -----------------------------------------------------------------------------
-- Function is_new() 
-- -----------------------------------------------------------------------------
  function is_new(p_student_id in student.student_id%Type) return boolean
  is
    l_count number;
  Begin
    /*
    select count(1) into l_count
      from inscription
     where student_id = p_student_id
       and school_year_id <> pkg_identifiers.get_current_school_year;
    */
    --
    return (l_count <= 0);
  Exception
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.is_new('||p_student_id||') - '||sqlerrm);
  End is_new;
-- -----------------------------------------------------------------------------
-- Function get_XML()
-- -----------------------------------------------------------------------------
  function get_XML(p_student_id in student.student_id%Type, p_add_xml_header in boolean default true)
  return clob is
    l_clob clob;
  begin
    /*
    if p_add_xml_header then
      l_clob := pkg_xml.K_XMLHeader;
    end if;
    --
    l_clob := l_clob||
       '<StudentForm>'||chr(10)||
       -- Student data
       pkg_xml.get_xml_rows(
          pi_table_name=>'vw_student'
          , pi_where_clause=>'student_id='||p_student_id||' and shy_code='''||
            pkg_identifiers.get_current_school_year()||''''
          , pi_entity_name=>'Student')||chr(10)||
       -- Parent data
       '<Parents>'||chr(10)||
       pkg_xml.get_xml_rows(
          pi_table_name=>'vw_parent_student', 
          pi_where_clause=>'student_id='||p_student_id, 
          pi_entity_name=>'Parent')||chr(10)||
       '</Parents>'||chr(10)||
       -- Contact data
       '<Contacts>'||chr(10)||
       pkg_xml.get_xml_rows(
          pi_table_name=>'vw_student_contact', 
          pi_where_clause=>'student_id='||p_student_id, 
          pi_entity_name=>'Contact')||chr(10)||
       '</Contacts>'||chr(10)||
       -- Contact data
       pkg_xml.get_xml_rows(
          pi_table_name=>'vw_student_inscription', 
          pi_where_clause=>'student_id='||p_student_id||
          ' and shy_code='''||pkg_identifiers.get_current_school_year||'''', 
          pi_entity_name=>'Inscription')||chr(10)||
       -- Health data
         '<Health>'||chr(10)||
       pkg_xml.get_xml_rows(
          pi_table_name=>'vw_student_doctor', 
          pi_where_clause=>'student_id='||p_student_id,
          pi_entity_name=>'Doctor')||chr(10)||
         '  <Allergies>'||chr(10)||
       pkg_xml.get_xml_rows(
          pi_table_name=>'vw_student_allergy', 
          pi_where_clause=>'student_id='||p_student_id,
          pi_entity_name=>'Allergy')||chr(10)||
         '  </Allergies>'||chr(10)||
         '  <Medications>'||chr(10)||
       pkg_xml.get_xml_rows(
          pi_table_name=>'vw_student_medication', 
          pi_where_clause=>'student_id='||p_student_id,
          pi_entity_name=>'Medication')||chr(10)||
         '  </Medications>'||chr(10)||
         '</Health>'||chr(10)||
       '</StudentForm>';
    */
    return l_clob;
  Exception
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.get_XML('||p_student_id||') - '||sqlerrm);
  end get_XML;
  function get_multi_XML(p_where_clause in varchar2)
  return clob is
    l_clob clob;
    l_SQL_String varchar2(1024);
    l_cursor Cursor_Type;
    l_student_id student.student_id%Type;
  begin
    /*
    l_SQL_String := 'select student_id from vw_student_list where '||p_where_clause;
    l_clob := pkg_xml.K_XMLHeader||'<StudentForms>'||chr(10);
    open l_cursor for l_SQL_String;
    loop
      fetch l_cursor into l_student_id;
      exit when l_cursor%NotFound;
      l_clob := l_clob || get_XML(p_student_id => l_student_id, p_add_xml_header => false);
    end loop;
    */
    return l_clob || chr(10)||'</StudentForms>';
  Exception
    WHEN NO_DATA_FOUND THEN return null;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.get_multi_XML('||p_where_clause||') - '||sqlerrm);
  end get_multi_XML;
-- -----------------------------------------------------------------------------
-- Function: create_replace()
-- -----------------------------------------------------------------------------
function create_replace( 
               p_student_id in student.student_id%Type, 
               p_student_number in student.student_id%Type,
               p_first_name in student.first_name%Type, 
               p_last_name in student.last_name%Type, 
               p_middle_name in student.middle_name%Type,
               p_usual_name in student.usual_name%Type,
               p_gender in student.gender%Type, 
               p_birth_date in student.birth_date%Type, 
               p_birth_country_id in student.birth_country_id%Type,
               p_birth_city in student.birth_city%Type,
               p_country_id in student.country_id%Type,
               p_add_id in student.add_id%Type := null,
			   p_par1_parent_id in parent.parent_id%Type := null,
			   p_par2_parent_id in parent.parent_id%Type := null
               ) 
  return student.student_id%Type is
    l_student_id STUDENT.student_id%Type := p_student_id;
	l_rel_type_id PARENT_STUDENT.rel_type_id%Type;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
    dbms_output.put_line(' Student ID = '||l_student_id);
    --
    if l_student_id is not null then 
      --
      dbms_output.put_line(' -> Attempt to update ');
      --
      update student t
         set
           first_name = nvl(upper(p_first_name), first_name),
           student_number = nvl(p_student_number, student_number),
           last_name = nvl(upper(p_last_name), last_name),
           middle_name = nvl(upper(p_middle_name), middle_name),
           usual_name = nvl(upper(p_usual_name), usual_name),
           gender = nvl(upper(p_gender), gender), 
           birth_date = p_birth_date, 
           birth_country_id = p_birth_country_id, 
           birth_city = p_birth_city, 
           country_id = p_country_id,
           add_id = nvl(p_add_id, t.add_id)
       where student_id = l_student_id;
      --
      dbms_output.put_line(' -> Done. Row Count = '||SQL%RowCount);
      --
       return l_student_id;
    else
      --
      insert into student(
        student_number, first_name, last_name, 
        middle_name, usual_name, gender, 
        birth_city, birth_date, birth_country_id, country_id, add_id)
      values
        (p_student_number, upper(p_first_name), upper(p_last_name), 
         upper(p_middle_name), upper(p_usual_name), upper(p_gender), 
         p_birth_city, p_birth_date, p_birth_country_id, p_country_id, p_add_id);
      --
      select s.student_id into l_student_id from student s where s.student_number = p_student_number;
      --
      insert into glob_student_picture(student_id) values (l_student_id);
    end if;
	--
	if p_par1_parent_id is not null then 
	  l_rel_type_id := local_get_rel_type_id(pi_parent_id => p_par1_parent_id);
	  insert into parent_student(parent_id, student_id, rel_type_id, is_primary) 
	  values (p_par1_parent_id, l_student_id, l_rel_type_id, 'Y');
	end if;
	--
	if p_par2_parent_id is not null then 
	  l_rel_type_id := local_get_rel_type_id(pi_parent_id => p_par2_parent_id);
	  insert into parent_student(parent_id, student_id, rel_type_id, is_primary) 
	  values (p_par2_parent_id, l_student_id, l_rel_type_id, 'N');
	end if;
    --
    return l_student_id;
  Exception
    WHEN NO_DATA_FOUND THEN return null;
    WHEN Already_Caught THEN raise;
    WHEN OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_student.create_replace[3]('||p_student_id||','||p_first_name||','||p_last_name||') - '||sqlerrm);
  End create_replace;
-- -----------------------------------------------------------------------------
-- Function: Get_Next_Student_Number()
-- -----------------------------------------------------------------------------
  Function Get_Next_Student_Number return student.student_number%type is
  Begin
    return pkg_identifiers.get_next('student number');
  End Get_Next_Student_Number;
-- -----------------------------------------------------------------------------
-- Function: Convert
-- -----------------------------------------------------------------------------
Function Convert(p_applicant_id in applicant.applicant_id%Type) return student.student_number%type
  is
    l_student_id STUDENT.student_id%Type;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    return l_student_id;
  Exception
      when Already_Caught then raise;
      when others then
      raise_application_error(-20001, 
       'pkg_student.convert('||p_applicant_id||') - '||sqlerrm);
  End convert;
-- -----------------------------------------------------------------------------
-- Function: Get_String()
-- -----------------------------------------------------------------------------
  Function get_string(pi_student_id in student.student_id%Type) return varchar2 is
    l_student_string varchar2(512);
	--
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    Return l_student_string;
  Exception
      when Already_Caught then raise;
      when others then raise_application_error(-20001, 'pkg_student.get_string('||pi_student_id||') - '||sqlerrm);
  End get_string;
-- ----------------------------------------------------------------------------- 
-- function get_version()
-- ----------------------------------------------------------------------------- 
  function get_version return varchar2 is
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    return '$Id$';
  Exception
      when Already_Caught then raise;
      when others then raise_application_error(-20001, 'pkg_student.get_version() - '||sqlerrm);
  End get_version;

-- ----------------------------------------------------------------------------- 
-- Completion check functions
-- ----------------------------------------------------------------------------- 
  Function contact_exists(pi_student_id in student.student_id%Type) return varchar2 is
    l_result varchar2(1) := null;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
	select 'Y' into l_result
	  from student_contact mstc
	 where mstc.student_id = pi_student_id
	   and rownum = 1;
    --
    return l_result;
  Exception
      when No_Data_Found then return 'N';
      when Already_Caught then raise;
      when others then raise_application_error(-20001, 'pkg_student.contact_exists('||pi_student_id||') - '||sqlerrm);
  End contact_exists;
  
  Function check_health_info(pi_student_id in student.student_id%Type) return varchar2 is
    l_result varchar2(1) := null;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
	select 'Y' into l_result
	  from student mstd
	 where mstd.student_id = pi_student_id
	   and mstd.DR_ID is not null
	   and mstd.HEALTH_CARD is not null;
    --
    return l_result;
  Exception
      when No_Data_Found then return 'N';
      when Already_Caught then raise;
      when others then raise_application_error(-20001, 'pkg_student.check_health_info('||pi_student_id||') - '||sqlerrm);
  End check_health_info;

  Function parent_exists(pi_student_id in student.student_id%Type) return varchar2 is
    l_result varchar2(1) := null;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
	select 'Y' into l_result
	  from parent_student mpas
	 where mpas.student_id = pi_student_id
	   and mpas.is_primary = 'Y'
	   and rownum = 1;
    --
    return l_result;
  Exception
      when No_Data_Found then return 'N';
      when Already_Caught then raise;
      when others then raise_application_error(-20001, 'pkg_student.parent_exists('||pi_student_id||') - '||sqlerrm);
  End parent_exists;

  Function check_student_demographic(pi_student_id in student.student_id%Type) return varchar2 is
    l_result varchar2(1) := null;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
	select 'Y' into l_result
	  from student mstd
	 where mstd.student_id = pi_student_id
	   and mstd.FIRST_NAME is not null
	   and mstd.LAST_NAME is not null
	   and mstd.GENDER is not null
	   and mstd.BIRTH_DATE is not null
	   and mstd.BIRTH_CITY is not null
	   and mstd.COUNTRY_ID is not null
	   and mstd.BIRTH_COUNTRY_ID is not null
	   ;
    --
    return l_result;
  Exception
      when No_Data_Found then return 'N';
      when Already_Caught then raise;
      when others then raise_application_error(-20001, 'pkg_student.check_student_demographic('||pi_student_id||') - '||sqlerrm);
  End check_student_demographic;

  Function account_exists(pi_student_id in student.student_id%Type) return varchar2 is
    l_result varchar2(1) := null;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    --
	select 'Y' into l_result
	  from student_account sacc
	 where sacc.student_id = pi_student_id
	   and rownum = 1;
    --
    return l_result;
  Exception
      when No_Data_Found then return 'N';
      when Already_Caught then raise;
      when others then raise_application_error(-20001, 'pkg_student.account_exists('||pi_student_id||') - '||sqlerrm);
  End account_exists;

  Function photo_exists(pi_student_id in student.student_id%Type) return varchar2 is
    l_result varchar2(1) := null;
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    select 'Y' into l_result from glob_picture pic 
	 where pic.TARGET_OBJECT_CODE = 'MSTD'
	   and pic.TARGET_OBJECT_ID = pi_student_id
	   and rownum = 1;
    return l_result;
  Exception
      when No_Data_Found then return 'N';
      when Already_Caught then raise;
      when others then raise_application_error(-20001, 'pkg_student.photo_exists('||pi_student_id||') - '||sqlerrm);
  End photo_exists;
  
-- ----------------------------------------------------------------------------- 
-- Procedure create_all_checklists()
-- ----------------------------------------------------------------------------- 
  Procedure create_all_checklists(
     pi_student_id in student.student_id%Type) is
    --
	l_checklist_id checklist.checklist_id%Type;
	l_student_name varchar2(512) := pkg_student.get_name(p_student_id=> pi_student_id);
	--
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin 
    for rec in (select * from checklist_template t
	             where t.TARGET_OBJECT_CODE = 'MSTD')
    loop
	  l_checklist_id := pkg_checklist.instanciate(  
         pi_short_name         => rec.short_name, 
         pi_target_object_code => rec.target_object_code, 
         pi_target_object_id   => pi_student_id, 
         pi_target_object_name => l_student_name);
	end loop;
  Exception
      when Already_Caught then raise;
      when others then raise_application_error(-20001, 'pkg_student.create_all_checklists('||pi_student_id||') - '||sqlerrm);
  End create_all_checklists;
  
-- ----------------------------------------------------------------------------- 
-- Function create_checklist()
-- ----------------------------------------------------------------------------- 
  Function create_checklist(
     pi_student_id in student.student_id%Type
     , pi_short_name in checklist_template.short_name%Type) 
   return checklist.checklist_id%Type is
   --
    l_checklist_id checklist.checklist_id%Type;
	l_short_name checklist_template.short_name%Type := pi_short_name;
   --
    Already_Caught exception;
    PRAGMA Exception_Init(Already_Caught, -20001);
  Begin
    if l_short_name is not null then
	  l_checklist_id := pkg_checklist.instanciate(  
         pi_short_name         => l_short_name, 
         pi_target_object_code => 'MSTD', 
         pi_target_object_id   => pi_student_id, 
         pi_target_object_name => pkg_student.get_name(p_student_id=>pi_student_id));
	else
	  raise_application_error(-20001, 'pkg_student.create_checklist('||pi_student_id||') - pi_short_name argument cannot be NULL');
	end if;
	return l_checklist_id;
  Exception
      when No_Data_Found then return null;
      when Already_Caught then raise;
      when others then raise_application_error(-20001, 'pkg_student.photo_exists('||pi_student_id||') - '||sqlerrm);
  End create_checklist;
  
END PKG_STUDENT;
/

select pkg_student.get_version() from dual;
