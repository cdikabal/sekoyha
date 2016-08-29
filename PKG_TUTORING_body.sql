create or replace package body PKG_TUTORING as
 
-- ===============================================================================
-- P U B L I C   P R O C E D U R E S   A N D   F U N C T I O N S 
-- ===============================================================================
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
      raise_application_error(-20001, 'pkg_tutoring.get_version() - '||sqlerrm);
  End get_version;

-- ========================================
-- Student functions and procedures
-- ========================================
   -- ----------------------------------------------------------------------
   -- procedure create_student()
   -- ----------------------------------------------------------------------
   procedure create_student(pi_vw_student_record in vw_student_tutoring%RowType) is
     l_student_id student.student_id%Type;
     l_student_add_id address.add_id%Type;
     l_par_1_id parent.parent_id%type; 
     l_par_1_add_id address.add_id%type; 
     l_par_2_id parent.parent_id%type; 
     l_par_2_add_id address.add_id%type; 
     -- 
     l_add_record address%RowType; 
     -- 
	 l_account_id pi_vw_student_record.account_id%Type;
	 --
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
   begin 
    -- -------
    -- Create addresses
    -- -------
    l_student_add_id := pkg_address.create_or_replace(
               pi_add_desc_1      => pi_vw_student_record.ADD_DESC_1, 
               pi_add_phone       => pi_vw_student_record.add_phone, 
               pi_add_postal_code => pi_vw_student_record.add_postal_code, 
               pi_add_city        => pi_vw_student_record.add_city, 
               pi_province_id     => pi_vw_student_record.saddr_province_id, 
               pi_country_id      => pi_vw_student_record.saddr_country_id, 
               pi_desc_2          => pi_vw_student_record.add_desc_2, 
               pi_add_comments    => pi_vw_student_record.add_comments, 
               pi_add_fax         => pi_vw_student_record.add_fax, 
               pi_add_id          => NULL, 
               pi_login_id        => pi_vw_student_record.create_by_login_id) ; 
    if pi_vw_student_record.PAR_SAME_ADDRESS_1 = 'Y' then
      l_par_1_add_id := l_student_add_id;
    else
      l_par_1_add_id := pkg_address.create_or_replace(
               pi_add_desc_1      => pi_vw_student_record.PAR_ADD_DESC_1, 
               pi_add_phone       => pi_vw_student_record.PAR_ADD_PHONE_1, 
               pi_add_postal_code => pi_vw_student_record.PAR_ADD_POSTAL_CODE_1, 
               pi_add_city        => pi_vw_student_record.PAR_ADD_CITY_1, 
               pi_province_id     => pi_vw_student_record.PAR_PROVINCE_ID_1, 
               pi_country_id      => pi_vw_student_record.PAR_COUNTRY_ID_1, 
               pi_desc_2          => NULL, 
               pi_add_comments    => pi_vw_student_record.PAR_ADD_COMMENTS_1, 
               pi_add_fax         => pi_vw_student_record.PAR_ADD_FAX_1, 
               pi_add_id          => NULL, 
               pi_login_id        => pi_vw_student_record.create_by_login_id) ; 
    end if;
    --
    if pi_vw_student_record.PAR_SAME_ADDRESS_2 = 'Y' then
      l_par_2_add_id := l_student_add_id;
    else
      l_par_2_add_id := pkg_address.create_or_replace(
               pi_add_desc_1      => pi_vw_student_record.PAR_ADD_DESC_2, 
               pi_add_phone       => pi_vw_student_record.PAR_ADD_PHONE_2, 
               pi_add_postal_code => pi_vw_student_record.PAR_ADD_POSTAL_CODE_2, 
               pi_add_city        => pi_vw_student_record.PAR_ADD_CITY_2, 
               pi_province_id     => pi_vw_student_record.PAR_PROVINCE_ID_2, 
               pi_country_id      => pi_vw_student_record.PAR_COUNTRY_ID_2, 
               pi_desc_2          => NULL, 
               pi_add_comments    => pi_vw_student_record.PAR_ADD_COMMENTS_2, 
               pi_add_fax         => pi_vw_student_record.PAR_ADD_FAX_2, 
               pi_add_id          => NULL, 
               pi_login_id        => pi_vw_student_record.create_by_login_id) ; 
    end if;
    -- -------
    -- Create the student
    -- -------
    l_student_id :=
      pkg_student.create_replace( 
               p_student_id     => null, 
               p_student_number => pi_vw_student_record.student_number,
               p_first_name     => pi_vw_student_record.first_name, 
               p_last_name      => pi_vw_student_record.last_name, 
               p_middle_name    => pi_vw_student_record.middle_name,
               p_usual_name     => pi_vw_student_record.usual_name,
               p_gender         => pi_vw_student_record.gender, 
               p_birth_date     => pi_vw_student_record.birth_date, 
               p_birth_country_id => pi_vw_student_record.birth_country_id,
               p_birth_city     => pi_vw_student_record.birth_city,
               p_country_id     => pi_vw_student_record.country_id,
			   p_add_id         => l_student_add_id);
    -- -------
    -- Create parents
    -- -------
	if pi_vw_student_record.par_first_name_1 is not null then
      l_par_1_id := pkg_parent.create_or_replace(   
               pi_first_name    => pi_vw_student_record.par_first_name_1,
               pi_last_name     => pi_vw_student_record.par_last_name_1,   
               pi_gender        => pi_vw_student_record.par_gender_1,   
               pi_cell_phone    => pi_vw_student_record.par_cell_phone_1,   
               pi_work_phone    => pi_vw_student_record.par_work_phone_1,   
               pi_email_address => pi_vw_student_record.par_email_address_1,   
               pi_add_id        => l_par_1_add_id,  
               pi_middle_name   => pi_vw_student_record.par_middle_name_1, 
               pi_parent_number => pi_vw_student_record.par_parent_number_1); 
	  --
	  pkg_parent.set_parent_student(
	      pi_parent_id   => l_par_1_id, 
	      pi_student_id  => l_student_id,
	      pi_rel_type_id => pi_vw_student_record.PAR_REL_TYPE_ID_1,
	      pi_is_primary  => 'Y');
	end if;
    --
	if pi_vw_student_record.par_first_name_2 is not null then
      l_par_2_id := pkg_parent.create_or_replace(   
               pi_first_name    => pi_vw_student_record.par_first_name_2,
               pi_last_name     => pi_vw_student_record.par_last_name_2,   
               pi_gender        => pi_vw_student_record.par_gender_2,
               pi_cell_phone    => pi_vw_student_record.par_cell_phone_2,
               pi_work_phone    => pi_vw_student_record.par_work_phone_2,
               pi_email_address => pi_vw_student_record.par_email_address_2,
               pi_add_id        => l_par_2_add_id,  
               pi_middle_name   => pi_vw_student_record.par_middle_name_2, 
               pi_parent_number => pi_vw_student_record.par_parent_number_2); 
	  --
	  pkg_parent.set_parent_student(
	      pi_parent_id   => l_par_2_id, 
	      pi_student_id  => l_student_id,
	      pi_rel_type_id => pi_vw_student_record.PAR_REL_TYPE_ID_2,
	      pi_is_primary  => case when l_par_1_id is null then 'Y' else 'N' end);
	end if;
	
    -- -------
    -- Create account
    -- -------
	if l_student_id > 0 then
      l_account_id := pkg_account.create_or_update (
         pi_account_id     => null,
         pi_student_id     => l_student_id,
         pi_comments       => pi_vw_student_record.account_comments,
         pi_par1_parent_id => l_par_1_id,
         pi_par2_parent_id => l_par_2_id,
         pi_preferred_hourly_rate => pi_vw_student_record.preferred_hourly_rate);
	end if;
	--
   exception 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'PKG_TUTORING.create_student('||
          pi_vw_student_record.first_name||','||pi_vw_student_record.last_name||') ## '||sqlerrm); 
   end create_student;
 
   -- ----------------------------------------------------------------------
   -- procedure update_student()
   -- ----------------------------------------------------------------------
   procedure update_student(pi_vw_student_record in vw_student_tutoring%RowType) is
     l_student_id student.student_id%Type;
	 l_student_add_id student.add_id%Type := pi_vw_student_record.ADD_ID;
     l_par_1_id parent.parent_id%type; 
     l_par_1_add_id address.add_id%type; 
     l_par_2_id parent.parent_id%type; 
     l_par_2_add_id address.add_id%type; 
     -- 
	 l_account_id pi_vw_student_record.account_id%Type;
	 --
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
   begin 
	-- ------------------------
    -- Set addresses
	-- ------------------------
    if l_student_add_id is null then
      l_student_add_id := pkg_address.create_or_replace(
               pi_add_desc_1      => pi_vw_student_record.ADD_DESC_1, 
               pi_add_phone       => pi_vw_student_record.add_phone, 
               pi_add_postal_code => pi_vw_student_record.add_postal_code, 
               pi_add_city        => pi_vw_student_record.add_city, 
               pi_province_id     => pi_vw_student_record.saddr_province_id, 
               pi_country_id      => pi_vw_student_record.saddr_country_id, 
               pi_desc_2          => pi_vw_student_record.add_desc_2, 
               pi_add_comments    => pi_vw_student_record.add_comments, 
               pi_add_fax         => pi_vw_student_record.add_fax, 
               pi_add_id          => NULL, 
               pi_login_id        => pi_vw_student_record.create_by_login_id) ; 
	end if;
	--
    if pi_vw_student_record.PAR_SAME_ADDRESS_1 = 'Y' then
      l_par_1_add_id := l_student_add_id;
    else
      l_par_1_add_id := pkg_address.create_or_replace(
               pi_add_desc_1      => pi_vw_student_record.PAR_ADD_DESC_1, 
               pi_add_phone       => pi_vw_student_record.PAR_ADD_PHONE_1, 
               pi_add_postal_code => pi_vw_student_record.PAR_ADD_POSTAL_CODE_1, 
               pi_add_city        => pi_vw_student_record.PAR_ADD_CITY_1, 
               pi_province_id     => pi_vw_student_record.PAR_PROVINCE_ID_1, 
               pi_country_id      => pi_vw_student_record.PAR_COUNTRY_ID_1, 
               pi_desc_2          => NULL, 
               pi_add_comments    => pi_vw_student_record.PAR_ADD_COMMENTS_1, 
               pi_add_fax         => pi_vw_student_record.PAR_ADD_FAX_1, 
               pi_add_id          => Null, 
               pi_login_id        => pi_vw_student_record.create_by_login_id) ; 
    end if;
    --
    if pi_vw_student_record.PAR_SAME_ADDRESS_2 = 'Y' then
      l_par_2_add_id := l_student_add_id;
    else
      l_par_2_add_id := pkg_address.create_or_replace(
               pi_add_desc_1      => pi_vw_student_record.PAR_ADD_DESC_2, 
               pi_add_phone       => pi_vw_student_record.PAR_ADD_PHONE_2, 
               pi_add_postal_code => pi_vw_student_record.PAR_ADD_POSTAL_CODE_2, 
               pi_add_city        => pi_vw_student_record.PAR_ADD_CITY_2, 
               pi_province_id     => pi_vw_student_record.PAR_PROVINCE_ID_2, 
               pi_country_id      => pi_vw_student_record.PAR_COUNTRY_ID_2, 
               pi_desc_2          => NULL, 
               pi_add_comments    => pi_vw_student_record.PAR_ADD_COMMENTS_2, 
               pi_add_fax         => pi_vw_student_record.PAR_ADD_FAX_2, 
               pi_add_id          => Null, 
               pi_login_id        => pi_vw_student_record.create_by_login_id) ; 
    end if;
	-- -----------------------
	-- Set student info
	-- -----------------------
    l_student_id :=
      pkg_student.create_replace( 
               p_student_id     => pi_vw_student_record.student_id, 
               p_student_number => pi_vw_student_record.student_number,
               p_first_name     => pi_vw_student_record.first_name, 
               p_last_name      => pi_vw_student_record.last_name, 
               p_middle_name    => pi_vw_student_record.middle_name,
               p_usual_name     => pi_vw_student_record.usual_name,
               p_gender         => pi_vw_student_record.gender, 
               p_birth_date     => pi_vw_student_record.birth_date, 
               p_birth_country_id => pi_vw_student_record.birth_country_id,
               p_birth_city     => pi_vw_student_record.birth_city,
               p_country_id     => pi_vw_student_record.country_id,
			   p_add_id         => l_student_add_id);
    -- -------
    -- Update Parents
    -- -------
	if pi_vw_student_record.par_first_name_1 is not null then
	  l_par_1_id := pkg_parent.create_or_replace(   
               pi_parent_id  => pi_vw_student_record.par_parent_id_1,   
               pi_first_name    => pi_vw_student_record.par_first_name_1,
               pi_last_name     => pi_vw_student_record.par_last_name_1,   
               pi_middle_name   => pi_vw_student_record.par_middle_name_1, 
               pi_gender        => pi_vw_student_record.par_gender_1,   
               pi_cell_phone    => pi_vw_student_record.par_cell_phone_1,   
               pi_work_phone    => pi_vw_student_record.par_work_phone_1,   
               pi_occupation    => null,
               pi_title_id      => null,
               pi_company_name  => null,
               pi_email_address => pi_vw_student_record.par_email_address_1,   
               pi_add_id        => l_par_1_add_id);
      --
	  pkg_parent.set_parent_student(
	      pi_parent_id   => l_par_1_id, 
	      pi_student_id  => l_student_id,
	      pi_rel_type_id => pi_vw_student_record.PAR_REL_TYPE_ID_1,
	      pi_is_primary  => 'Y');
	end if;
	--
	if pi_vw_student_record.par_first_name_2 is not null then
	  l_par_2_id := pkg_parent.create_or_replace(   
               pi_parent_id  => pi_vw_student_record.par_parent_id_2,   
               pi_first_name    => pi_vw_student_record.par_first_name_2,
               pi_last_name     => pi_vw_student_record.par_last_name_2,   
               pi_middle_name   => pi_vw_student_record.par_middle_name_2, 
               pi_gender        => pi_vw_student_record.par_gender_2,   
               pi_cell_phone    => pi_vw_student_record.par_cell_phone_2,   
               pi_work_phone    => pi_vw_student_record.par_work_phone_2,   
               pi_occupation    => null,
               pi_title_id      => null,
               pi_company_name  => null,
               pi_email_address => pi_vw_student_record.par_email_address_2,   
               pi_add_id        => l_par_2_add_id);
      --
 	  pkg_parent.set_parent_student(
	      pi_parent_id   => l_par_2_id, 
	      pi_student_id  => l_student_id,
	      pi_rel_type_id => pi_vw_student_record.PAR_REL_TYPE_ID_2,
	      pi_is_primary  => case when l_par_1_id is null then 'Y' else 'N' end);
	end if;
	--
	if pi_vw_student_record.preferred_hourly_rate > 0 then
      l_account_id := pkg_account.create_or_update (
         pi_account_id     => pi_vw_student_record.account_id,
         pi_student_id     => l_student_id,
         pi_comments       => pi_vw_student_record.account_comments,
         pi_par1_parent_id => l_par_1_id,
         pi_par2_parent_id => l_par_2_id,
         pi_preferred_hourly_rate => pi_vw_student_record.preferred_hourly_rate);
	end if;
	--
   exception 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'PKG_TUTORING.update_student('||
          pi_vw_student_record.student_id||','||
          pi_vw_student_record.first_name||','||pi_vw_student_record.last_name||') ## '||sqlerrm); 
   end update_student;
 
   procedure delete_student(pi_student_id in student.student_id%Type) is
   begin null;
   end delete_student;
 
   -- ----------------------------------------------------------------------
   -- function get_student()
   -- ----------------------------------------------------------------------
   function get_student(pi_student_id in student.student_id%Type) return vw_student_tutoring%RowType is
     l_vw_student_record vw_student_tutoring%RowType;
     -- 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
   begin 
     select * into l_vw_student_record 
       from vw_student_tutoring std
      where std.student_id = pi_student_id;
     return l_vw_student_record; 
   exception 
     when no_data_found then return null; 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'PKG_TUTORING.get_student[1]('||pi_student_id||') ## '||sqlerrm); 
   end get_student;
 
   -- ----------------------------------------------------------------------
   -- function get_student[2]()
   -- ----------------------------------------------------------------------
   function get_students(pi_criterias in CRITERIA_TAB_TYPE) return SYS_REFCURSOR is
     -- 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
   begin 
   return null; 
   exception 
     when no_data_found then return null; 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'PKG_TUTORING.get_student[2]() ## '||sqlerrm); 
   end get_students;
 
   -- ----------------------------------------------------------------------
   -- procedure create_student_checklist()
   -- ----------------------------------------------------------------------
   procedure create_student_checklist(pi_student_id in student.student_id%Type) is
      l_checklist_id checklist.checklist_id%Type;
     -- 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  begin
    l_checklist_id := pkg_checklist.instanciate(
        pi_short_name         => 'New Student',
        pi_target_object_code => 'MSTD',
        pi_target_object_id   => pi_student_id ,
        pi_target_object_name => pkg_object.get_string(pi_object_code => 'MSTD', pi_object_id => pi_student_id ));
  exception 
     when no_data_found then null; 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'PKG_TUTORING.create_student_checklist('||pi_student_id||') ## '||sqlerrm); 
   end create_student_checklist;
 
end PKG_TUTORING;
/

select pkg_tutoring.get_version() from dual;