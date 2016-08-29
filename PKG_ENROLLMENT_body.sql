create or replace package body PKG_ENROLLMENT as
 
  procedure create_applicant(pi_vw_applicant_record in vw_applicant_full%RowType) is
 
    l_par_1_id parent.parent_id%type; 
    l_par_1_add_id address.add_id%type; 
    l_par_2_id parent.parent_id%type; 
    l_par_2_add_id address.add_id%type; 
    -- 
    l_add_record address%RowType; 
    l_applicant_record applicant%RowType; 
    l_parent_record parent%RowType;
     -- 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  begin 
  -- 
    -- ======================= 
    -- Populate address table 
    -- ======================= 
    if pi_vw_applicant_record.add_id = 0 then l_add_record.add_id := null;
    Else l_add_record.add_id := pi_vw_applicant_record.add_id; 
    end if;
    --
    l_add_record.ADD_DESC_1 := pi_vw_applicant_record.ADD_DESC_1; 
    l_add_record.ADD_DESC_2 := pi_vw_applicant_record.ADD_DESC_2; 
    l_add_record.ADD_PHONE := pi_vw_applicant_record.ADD_PHONE; 
    l_add_record.ADD_POSTAL_CODE := pi_vw_applicant_record.ADD_POSTAL_CODE; 
    l_add_record.ADD_CITY := pi_vw_applicant_record.ADD_CITY; 
    l_add_record.ADD_FAX := pi_vw_applicant_record.ADD_FAX; 
    l_add_record.ADD_COMMENTS := pi_vw_applicant_record.ADD_COMMENTS; 
    l_add_record.COUNTRY_ID := pi_vw_applicant_record.COUNTRY_ID ; 
    l_add_record.PROVINCE_ID := pi_vw_applicant_record.PROVINCE_ID; 
    l_add_record.CREATE_DATE := pi_vw_applicant_record.CREATE_DATE; 
    l_add_record.CREATE_BY_LOGIN_ID := pi_vw_applicant_record.CREATE_BY_LOGIN_ID; 
    l_add_record.LAST_UPDATE_DATE := pi_vw_applicant_record.LAST_UPDATE_DATE; 
    l_add_record.UPDATE_BY_LOGIN_ID := pi_vw_applicant_record.UPDATE_BY_LOGIN_ID; 
    l_add_record.add_id := pkg_address.create_or_replace(pi_address_record => l_add_record); 
    -- 
    -- ======================= 
    -- Populate parent table 
    -- ======================= 
    -- Parent 1 
    if pi_vw_applicant_record.p1_first_name is not null and 
       pi_vw_applicant_record.p1_last_name is not null then 
      l_par_1_add_id := l_add_record.add_id; 
      if nvl(pi_vw_applicant_record.p1_same_address, 'Y') = 'N' then
        l_par_1_add_id := pkg_address.create_or_replace 
         (pi_add_id => pi_vw_applicant_record.p1_add_id,
          pi_province_id => pi_vw_applicant_record.p1_province_id, 
          pi_country_id  => pi_vw_applicant_record.P1_COUNTRY_ID, 
          pi_add_city     => pi_vw_applicant_record.p1_add_city, 
          pi_add_postal_code => pi_vw_applicant_record.p1_add_postal_code, 
          pi_add_phone    => pi_vw_applicant_record.p1_add_phone, 
          pi_add_desc_1   => pi_vw_applicant_record.p1_add_desc_1, 
          pi_desc_2       => pi_vw_applicant_record.p1_add_desc_2, 
          pi_add_comments => pi_vw_applicant_record.p1_add_comments, 
          pi_add_fax      => pi_vw_applicant_record.p1_add_fax, 
          pi_login_id     => pi_vw_applicant_record.update_by_login_id); 
      end if; 
      l_par_1_id := pkg_parent.create_or_replace( 
         pi_add_id        => l_par_1_add_id, 
         pi_email_address => pi_vw_applicant_record.p1_email_address, 
         pi_work_phone    => pi_vw_applicant_record.p1_work_phone, 
         pi_cell_phone    => pi_vw_applicant_record.p1_cell_phone, 
         pi_gender        => pi_vw_applicant_record.p1_gender, 
         pi_first_name    => upper(pi_vw_applicant_record.p1_first_name), 
         pi_last_name     => upper(pi_vw_applicant_record.p1_last_name), 
         pi_middle_name   => upper(pi_vw_applicant_record.p1_middle_name),
         pi_parent_number => pi_vw_applicant_record.p1_parent_number); 
      -- 
    end if; 
    -- Parent 2 
    if pi_vw_applicant_record.p2_first_name is not null and 
       pi_vw_applicant_record.p2_last_name is not null then 
      l_par_2_add_id := l_add_record.add_id; 
      if nvl(pi_vw_applicant_record.p2_same_address,'Y') = 'N' then
        l_par_2_add_id := pkg_address.create_or_replace 
         (pi_add_id => pi_vw_applicant_record.p2_add_id,
          pi_province_id  => pi_vw_applicant_record.p2_province_id, 
          pi_country_id   => pi_vw_applicant_record.p2_country_id, 
          pi_add_city     => pi_vw_applicant_record.p2_add_city, 
          pi_add_postal_code => pi_vw_applicant_record.p2_add_postal_code, 
          pi_add_phone    => pi_vw_applicant_record.p2_add_phone, 
          pi_add_desc_1   => pi_vw_applicant_record.p2_add_desc_1, 
          pi_desc_2       => pi_vw_applicant_record.p2_add_desc_2, 
          pi_add_fax      => pi_vw_applicant_record.p2_add_fax,
          pi_login_id     => pi_vw_applicant_record.update_by_login_id); 
      end if; 
      l_par_2_id := pkg_parent.create_or_replace( 
         pi_add_id        => l_par_2_add_id, 
         pi_email_address => pi_vw_applicant_record.p2_email_address, 
         pi_work_phone    => pi_vw_applicant_record.p2_work_phone, 
         pi_cell_phone    => pi_vw_applicant_record.p2_cell_phone, 
         pi_gender        => pi_vw_applicant_record.p2_gender, 
         pi_first_name    => upper(pi_vw_applicant_record.p2_first_name), 
         pi_last_name     => upper(pi_vw_applicant_record.p2_last_name), 
         pi_middle_name   => upper(pi_vw_applicant_record.p2_middle_name),
         pi_parent_number => pi_vw_applicant_record.p2_parent_number); 
    end if; 
    -- ======================= 
    -- Populate applicant table 
    -- ======================= 
 
    l_applicant_record.APPLICANT_ID := pi_vw_applicant_record.APPLICANT_ID; 
    l_applicant_record.FIRST_NAME := Upper(pi_vw_applicant_record.FIRST_NAME); 
    l_applicant_record.LAST_NAME := Upper(pi_vw_applicant_record.LAST_NAME); 
    l_applicant_record.MIDDLE_NAME := Upper(pi_vw_applicant_record.MIDDLE_NAME); 
    l_applicant_record.APPLICATION_DATE := pi_vw_applicant_record.APPLICATION_DATE; 
    l_applicant_record.APPLICATION_STATUS_ID := pi_vw_applicant_record.APPLICATION_STATUS_ID; 
    l_applicant_record.BIRTH_DATE := pi_vw_applicant_record.BIRTH_DATE; 
    l_applicant_record.BIRTH_CITY := pi_vw_applicant_record.BIRTH_CITY; 
    l_applicant_record.BIRTH_COUNTRY_ID := pi_vw_applicant_record.BIRTH_COUNTRY_ID; 
    l_applicant_record.COUNTRY_ID := pi_vw_applicant_record.CITIZEN_COUNTRY_ID; 
    l_applicant_record.ADD_ID := l_add_record.add_id; 
    l_applicant_record.COMMENTS := pi_vw_applicant_record.COMMENTS; 
    l_applicant_record.CURRENT_SCHOOL := pi_vw_applicant_record.CURRENT_SCHOOL; 
    l_applicant_record.CURRENT_PRINCIPAL := pi_vw_applicant_record.CURRENT_PRINCIPAL; 
    l_applicant_record.CREATE_DATE := sysdate;  
    l_applicant_record.CREATE_BY_LOGIN_ID := pi_vw_applicant_record.CREATE_BY_LOGIN_ID; 
    l_applicant_record.LAST_UPDATE_DATE := sysdate;  
    l_applicant_record.UPDATE_BY_LOGIN_ID := pi_vw_applicant_record.UPDATE_BY_LOGIN_ID; 
    l_applicant_record.CELL_PHONE := pi_vw_applicant_record.CELL_PHONE; 
    l_applicant_record.EMAIL_ADDRESS := pi_vw_applicant_record.EMAIL_ADDRESS; 
    l_applicant_record.USUAL_NAME := pi_vw_applicant_record.USUAL_NAME; 
 
    l_APPLICANT_record.applicant_id := pkg_applicant.create_or_replace( 
        pi_APPLICANT_record => l_applicant_record); 
    -- ======================= 
    -- Set parent student relationship 
    -- ======================= 
    if l_par_1_id is not null then 
      pkg_applicant.set_parent_applicant( 
           pi_APPLICANT_id => l_APPLICANT_record.applicant_id,  
           pi_parent_id  => l_par_1_id, 
           pi_IS_PRIMARY => 'Y',  
           pi_login_id   => pi_vw_applicant_record.UPDATE_BY_LOGIN_ID); 
    end if; 
    -- 
    if l_par_2_id is not null then 
      pkg_applicant.set_parent_applicant( 
           pi_APPLICANT_id => l_APPLICANT_record.applicant_id,  
           pi_parent_id => l_par_2_id, 
           pi_IS_PRIMARY => 'N',  
           pi_login_id   => pi_vw_applicant_record.UPDATE_BY_LOGIN_ID); 
    end if; 
    -- 
    
  exception 
     when no_data_found then null; 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'pkg_enrollment.create_or_replace('||pi_vw_applicant_record.applicant_id||') ## '||sqlerrm); 
  end create_applicant;
 
-- -------------------------------------------------------------------------------
-- procedure update_applicant()
-- -------------------------------------------------------------------------------
procedure update_applicant(pi_vw_applicant_record in vw_applicant_full%RowType) is
 
    l_add_record address%RowType; 
    l_applicant_record applicant%RowType; 
    l_parent_record parent%RowType;
    l_par_1_id parent.add_id%Type;
    l_par_2_id parent.add_id%Type;
    l_p1_add_id number;
    l_p2_add_id number;
     -- 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  begin 
  -- 
    -- ======================= 
    -- Update address data 
    -- ======================= 
    --
    l_add_record.ADD_ID       := pi_vw_applicant_record.ADD_ID; 
    l_add_record.ADD_DESC_1   := pi_vw_applicant_record.ADD_DESC_1; 
    l_add_record.ADD_DESC_2   := pi_vw_applicant_record.ADD_DESC_2; 
    l_add_record.ADD_PHONE    := pi_vw_applicant_record.ADD_PHONE; 
    l_add_record.ADD_POSTAL_CODE := pi_vw_applicant_record.ADD_POSTAL_CODE; 
    l_add_record.ADD_CITY     := pi_vw_applicant_record.ADD_CITY; 
    l_add_record.ADD_FAX      := pi_vw_applicant_record.ADD_FAX; 
    l_add_record.ADD_COMMENTS := pi_vw_applicant_record.ADD_COMMENTS; 
    l_add_record.COUNTRY_ID   := pi_vw_applicant_record.COUNTRY_ID ; 
    l_add_record.PROVINCE_ID  := pi_vw_applicant_record.PROVINCE_ID; 
    l_add_record.CREATE_DATE        := pi_vw_applicant_record.CREATE_DATE; 
    l_add_record.CREATE_BY_LOGIN_ID := pi_vw_applicant_record.CREATE_BY_LOGIN_ID; 
    l_add_record.LAST_UPDATE_DATE   := pi_vw_applicant_record.LAST_UPDATE_DATE; 
    l_add_record.UPDATE_BY_LOGIN_ID := pi_vw_applicant_record.UPDATE_BY_LOGIN_ID; 
    l_add_record.add_id := pkg_address.create_or_replace(pi_address_record => l_add_record); 
    --
    if pi_vw_applicant_record.p1_same_address = 'N' then
       l_add_record.ADD_ID       := pi_vw_applicant_record.p1_ADD_ID; 
       l_add_record.ADD_DESC_1   := pi_vw_applicant_record.p1_ADD_DESC_1; 
       l_add_record.ADD_DESC_2   := pi_vw_applicant_record.p1_ADD_DESC_2; 
       l_add_record.ADD_PHONE    := pi_vw_applicant_record.p1_ADD_PHONE; 
       l_add_record.ADD_POSTAL_CODE := pi_vw_applicant_record.p1_ADD_POSTAL_CODE; 
       l_add_record.ADD_CITY     := pi_vw_applicant_record.p1_ADD_CITY; 
       l_add_record.ADD_FAX      := pi_vw_applicant_record.p1_ADD_FAX; 
       l_add_record.ADD_COMMENTS := pi_vw_applicant_record.p1_ADD_COMMENTS; 
       l_add_record.COUNTRY_ID   := pi_vw_applicant_record.p1_COUNTRY_ID ; 
       l_add_record.PROVINCE_ID  := pi_vw_applicant_record.p1_PROVINCE_ID; 
       l_add_record.CREATE_DATE        := sysdate; 
       l_add_record.CREATE_BY_LOGIN_ID := pi_vw_applicant_record.CREATE_BY_LOGIN_ID; 
       l_add_record.LAST_UPDATE_DATE   := sysdate; 
       l_add_record.UPDATE_BY_LOGIN_ID := pi_vw_applicant_record.UPDATE_BY_LOGIN_ID; 
       l_p1_add_id := pkg_address.create_or_replace(pi_address_record => l_add_record); 
    Else
       l_p1_add_id := l_add_record.add_id;
    end if;
    --
    if pi_vw_applicant_record.p2_same_address = 'N' then
       l_add_record.ADD_ID       := pi_vw_applicant_record.p2_ADD_ID; 
       l_add_record.ADD_DESC_1   := pi_vw_applicant_record.p2_ADD_DESC_1; 
       l_add_record.ADD_DESC_2   := pi_vw_applicant_record.p2_ADD_DESC_2; 
       l_add_record.ADD_PHONE    := pi_vw_applicant_record.p2_ADD_PHONE; 
       l_add_record.ADD_POSTAL_CODE := pi_vw_applicant_record.p2_ADD_POSTAL_CODE; 
       l_add_record.ADD_CITY     := pi_vw_applicant_record.p2_ADD_CITY; 
       l_add_record.ADD_FAX      := pi_vw_applicant_record.p2_ADD_FAX; 
       l_add_record.ADD_COMMENTS := pi_vw_applicant_record.p2_ADD_COMMENTS; 
       l_add_record.COUNTRY_ID   := pi_vw_applicant_record.p2_COUNTRY_ID ; 
       l_add_record.PROVINCE_ID  := pi_vw_applicant_record.p2_PROVINCE_ID; 
       l_add_record.CREATE_DATE        := sysdate; 
       l_add_record.CREATE_BY_LOGIN_ID := pi_vw_applicant_record.CREATE_BY_LOGIN_ID; 
       l_add_record.LAST_UPDATE_DATE   := sysdate; 
       l_add_record.UPDATE_BY_LOGIN_ID := pi_vw_applicant_record.UPDATE_BY_LOGIN_ID; 
       l_p2_add_id := pkg_address.create_or_replace(pi_address_record => l_add_record); 
    Else
       l_p2_add_id := l_add_record.add_id;
    end if;
    --
    l_par_1_id := pkg_parent.create_or_replace( 
         pi_add_id        => l_p1_add_id, 
         pi_email_address => pi_vw_applicant_record.p1_email_address, 
         pi_work_phone    => pi_vw_applicant_record.p1_work_phone, 
         pi_cell_phone    => pi_vw_applicant_record.p1_cell_phone, 
         pi_gender        => pi_vw_applicant_record.p1_gender, 
         pi_first_name    => upper(pi_vw_applicant_record.p1_first_name), 
         pi_last_name     => upper(pi_vw_applicant_record.p1_last_name), 
         pi_middle_name   => upper(pi_vw_applicant_record.p1_middle_name),
         pi_parent_number => pi_vw_applicant_record.p1_parent_number); 
    --
    l_par_2_id := pkg_parent.create_or_replace( 
         pi_add_id        => l_p2_add_id, 
         pi_email_address => pi_vw_applicant_record.p2_email_address, 
         pi_work_phone    => pi_vw_applicant_record.p2_work_phone, 
         pi_cell_phone    => pi_vw_applicant_record.p2_cell_phone, 
         pi_gender        => pi_vw_applicant_record.p2_gender, 
         pi_first_name    => upper(pi_vw_applicant_record.p2_first_name), 
         pi_last_name     => upper(pi_vw_applicant_record.p2_last_name), 
         pi_middle_name   => upper(pi_vw_applicant_record.p2_middle_name),
         pi_parent_number => pi_vw_applicant_record.p2_parent_number); 
 
    -- ======================= 
    -- Update applicant data
    -- =======================  
    l_applicant_record.APPLICANT_ID := pi_vw_applicant_record.APPLICANT_ID; 
    l_applicant_record.FIRST_NAME := Upper(pi_vw_applicant_record.FIRST_NAME); 
    l_applicant_record.LAST_NAME := Upper(pi_vw_applicant_record.LAST_NAME); 
    l_applicant_record.MIDDLE_NAME := Upper(pi_vw_applicant_record.MIDDLE_NAME); 
    l_applicant_record.APPLICATION_DATE := pi_vw_applicant_record.APPLICATION_DATE; 
    l_applicant_record.APPLICATION_STATUS_ID := pi_vw_applicant_record.APPLICATION_STATUS_ID; 
    l_applicant_record.BIRTH_DATE := pi_vw_applicant_record.BIRTH_DATE; 
    l_applicant_record.BIRTH_CITY := pi_vw_applicant_record.BIRTH_CITY; 
    l_applicant_record.BIRTH_COUNTRY_ID := pi_vw_applicant_record.BIRTH_COUNTRY_ID; 
    l_applicant_record.COUNTRY_ID := pi_vw_applicant_record.CITIZEN_COUNTRY_ID; 
    l_applicant_record.ADD_ID := pi_vw_applicant_record.add_id; 
    l_applicant_record.COMMENTS := pi_vw_applicant_record.COMMENTS; 
    l_applicant_record.CURRENT_SCHOOL := pi_vw_applicant_record.CURRENT_SCHOOL; 
    l_applicant_record.CURRENT_PRINCIPAL := pi_vw_applicant_record.CURRENT_PRINCIPAL; 
    l_applicant_record.CREATE_DATE := sysdate;  
    l_applicant_record.CREATE_BY_LOGIN_ID := pi_vw_applicant_record.CREATE_BY_LOGIN_ID; 
    l_applicant_record.LAST_UPDATE_DATE := sysdate;  
    l_applicant_record.UPDATE_BY_LOGIN_ID := pi_vw_applicant_record.UPDATE_BY_LOGIN_ID; 
    l_applicant_record.CELL_PHONE := pi_vw_applicant_record.CELL_PHONE; 
    l_applicant_record.EMAIL_ADDRESS := pi_vw_applicant_record.EMAIL_ADDRESS; 
    l_applicant_record.USUAL_NAME := pi_vw_applicant_record.USUAL_NAME; 
 
    l_APPLICANT_record.applicant_id := pkg_applicant.create_or_replace( 
        pi_APPLICANT_record => l_applicant_record); 
    --
  exception 
     when no_data_found then null; 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'pkg_applicant.update_applicant('||pi_vw_applicant_record.applicant_id||') ## '||sqlerrm); 
  end update_applicant;
 
-- -------------------------------------------------------------------------------
-- procedure create_applicant_checklist()
-- -------------------------------------------------------------------------------
  procedure create_applicant_checklist(pi_applicant_id in applicant.applicant_id%Type) is
      l_checklist_id checklist.checklist_id%Type;
     -- 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
  begin
    l_checklist_id := pkg_checklist.instanciate(
          pi_short_name => K_APPL_REVIEW_CHEKLIST_NAME,
          pi_target_object_code => K_APPLICANT_OBJECT_CODE,
          pi_target_object_id => pi_applicant_id ,
        pi_target_object_name => pkg_object.get_string(pi_object_code => K_APPLICANT_OBJECT_CODE, pi_object_id => pi_applicant_id ));
  exception 
     when no_data_found then null; 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'pkg_enrollment.create_applicant_checklist('||pi_applicant_id||') ## '||sqlerrm); 
  end create_applicant_checklist;
    
-- -------------------------------------------------------------------------------
    -- procedure delete_applicant()
-- -------------------------------------------------------------------------------
procedure delete_applicant(pi_applicant_id in applicant.applicant_id%Type) is
    begin null; end delete_applicant;
function get_applicant(pi_applicant_id in applicant.applicant_id%Type) return vw_applicant_full%RowType is
    begin return null; end get_applicant;
function get_applicants(pi_criterias in CRITERIA_TAB_TYPE) return SYS_REFCURSOR is
    begin return null; end get_applicants;
 
-- ========================================
-- Student functions and procedures
-- ========================================

   -- ----------------------------------------------------------------------
   -- procedure create_student()
   -- ----------------------------------------------------------------------
   procedure create_student(pi_vw_student_record in vw_student_full%RowType) is
     l_student_id student.student_id%Type;
     l_student_add_id address.add_id%Type;
     l_par_1_id parent.parent_id%type; 
     l_par_1_add_id address.add_id%type; 
     l_par_2_id parent.parent_id%type; 
     l_par_2_add_id address.add_id%type; 
    -- 
    l_add_record address%RowType; 
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
    -- Create doctor
    -- -------
   exception 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'pkg_enrollment.create_student('||
          pi_vw_student_record.first_name||','||pi_vw_student_record.last_name||') ## '||sqlerrm); 
   end create_student;
 
   -- ----------------------------------------------------------------------
   -- procedure update_student()
   -- ----------------------------------------------------------------------
   procedure update_student(pi_vw_student_record in vw_student_full%RowType) is
     l_student_id student.student_id%Type;
	 l_student_add_id student.add_id%Type := pi_vw_student_record.ADD_ID;
     l_par_1_id parent.parent_id%type; 
     l_par_1_add_id address.add_id%type; 
     l_par_2_id parent.parent_id%type; 
     l_par_2_add_id address.add_id%type; 
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
	      pi_is_primary  => case when pi_vw_student_record.par_parent_id_1 is null then 'Y' else 'N' end);
	end if;
	--
   exception 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'pkg_enrollment.update_student('||
          pi_vw_student_record.student_number||','||
          pi_vw_student_record.first_name||','||pi_vw_student_record.last_name||') ## '||sqlerrm); 
   end update_student;
 
   procedure delete_student(pi_student_id in student.student_id%Type) is
   begin null;
   end delete_student;
 
   -- ----------------------------------------------------------------------
   -- function get_student()
   -- ----------------------------------------------------------------------
   function get_student(pi_student_id in student.student_id%Type) return vw_student_full%RowType is
     l_vw_student_record vw_student_full%RowType;
     -- 
     Already_Caught exception; 
     PRAGMA Exception_Init(Already_Caught, -20001); 
   begin 
     select * into l_vw_student_record 
       from vw_student_full std
      where std.student_id = pi_student_id;
     return l_vw_student_record; 
   exception 
     when no_data_found then return null; 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'pkg_enrollment.get_student('||pi_student_id||') ## '||sqlerrm); 
   end get_student;
 
   function get_students(pi_criterias in CRITERIA_TAB_TYPE) return SYS_REFCURSOR is
   begin return null; end get_students;
 
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
        pi_short_name         => 'Student Review',
        pi_target_object_code => 'MSTD',
        pi_target_object_id   => pi_student_id ,
        pi_target_object_name => pkg_object.get_string(pi_object_code => 'MSTD', pi_object_id => pi_student_id ));
  exception 
     when no_data_found then null; 
     when Already_Caught then raise; 
     when others then 
        raise_application_error(-20001, 'pkg_enrollment.create_student_checklist('||pi_student_id||') ## '||sqlerrm); 
   end create_student_checklist;
 
end PKG_ENROLLMENT;
/

show error