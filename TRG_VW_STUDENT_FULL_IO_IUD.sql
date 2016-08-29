create or replace TRIGGER  "TRG_VW_STUDENT_FULL_IO_IUD" 
INSTEAD OF INSERT or UPDATE or DELETE ON VW_STUDENT_FULL 
DECLARE 
  -- 
  l_add_id number;
  l_vw_student_record vw_student_full%RowType; 
  l_picture_rec glob_picture%rowType;
  -- 
begin 
    --dbms_output.put_line('**> Student : '||:new.last_name||', '||:new.first_name); 
    l_vw_student_record.ADD_DESC_1 := :new.ADD_DESC_1; 
    l_vw_student_record.ADD_DESC_2 := :new.ADD_DESC_2; 
    l_vw_student_record.ADD_PHONE := :new.ADD_PHONE; 
    l_vw_student_record.ADD_POSTAL_CODE := :new.ADD_POSTAL_CODE; 
    l_vw_student_record.ADD_CITY := :new.ADD_CITY; 
    l_vw_student_record.ADD_FAX := :new.ADD_FAX; 
    l_vw_student_record.ADD_COMMENTS := :new.ADD_COMMENTS; 
    l_vw_student_record.SADDR_COUNTRY_ID := :new.SADDR_COUNTRY_ID ; 
    l_vw_student_record.SADDR_PROVINCE_ID := :new.SADDR_PROVINCE_ID; 
    --l_vw_student_record.TENANT_ID := pkg_tenant.GET_CURRENT_ID(); 
    -- 
    -- ======================= 
    -- Populate parent table 
    -- ======================= 
    -- Parent 1 
     l_vw_student_record.par_add_id_1        := :new.par_add_id_1;
	 if :new.par_same_address_1 = 'Y' then l_vw_student_record.par_add_id_1 := :new.add_id; end if;
     l_vw_student_record.par_province_id_1   := :new.par_province_id_1;
     l_vw_student_record.par_country_id_1    := :new.par_country_id_1;
     l_vw_student_record.par_add_city_1      := :new.par_add_city_1;
     l_vw_student_record.par_add_postal_code_1 := :new.par_add_postal_code_1;
     l_vw_student_record.par_add_phone_1     := :new.par_add_phone_1;
     L_vw_student_record.par_same_address_1  := :new.par_same_address_1;
     l_vw_student_record.par_add_desc_1      := :new.par_add_desc_1; 
     l_vw_student_record.par_add_comments_1  := :new.par_add_comments_1;
     l_vw_student_record.par_add_fax_1       := :new.par_add_fax_1;
     l_vw_student_record.par_email_address_1 := :new.par_email_address_1; 
     l_vw_student_record.par_work_phone_1    := :new.par_work_phone_1; 
     l_vw_student_record.par_cell_phone_1    := :new.par_cell_phone_1; 
     l_vw_student_record.par_gender_1        := :new.par_gender_1; 
     l_vw_student_record.par_first_name_1    := upper(:new.par_first_name_1);
     l_vw_student_record.par_last_name_1     := upper(:new.par_last_name_1); 
     l_vw_student_record.par_middle_name_1   := upper(:new.par_middle_name_1);
     l_vw_student_record.par_parent_number_1 := :new.par_parent_number_1; 
     l_vw_student_record.PAR_REL_TYPE_1      := :new.PAR_REL_TYPE_1;
     l_vw_student_record.par_parent_id_1     := :new.par_parent_id_1; 
     l_vw_student_record.PAR_REL_TYPE_ID_1   := :new.PAR_REL_TYPE_ID_1;
      -- 
    -- Parent 2 
     l_vw_student_record.par_add_id_2        := :new.par_add_id_2;
	 if :new.par_same_address_2 = 'Y' then l_vw_student_record.par_add_id_2 := :new.add_id; end if;
     l_vw_student_record.par_province_id_2   := :new.par_province_id_2;
     l_vw_student_record.par_country_id_2    := :new.par_country_id_2;
     l_vw_student_record.par_add_city_2      := :new.par_add_city_2;
     l_vw_student_record.par_add_postal_code_2 := :new.par_add_postal_code_2;
     l_vw_student_record.par_add_phone_2     := :new.par_add_phone_2;
     L_vw_student_record.par_same_address_2  := :new.par_same_address_2;
     l_vw_student_record.par_add_desc_2      := :new.par_add_desc_2; 
     l_vw_student_record.par_add_comments_2  := :new.par_add_comments_2;
     l_vw_student_record.par_add_fax_2       := :new.par_add_fax_2;
     l_vw_student_record.par_email_address_2 := :new.par_email_address_2; 
     l_vw_student_record.par_work_phone_2    := :new.par_work_phone_2; 
     l_vw_student_record.par_cell_phone_2    := :new.par_cell_phone_2; 
     l_vw_student_record.par_gender_2        := :new.par_gender_2; 
     l_vw_student_record.par_first_name_2    := upper(:new.par_first_name_2);
     l_vw_student_record.par_last_name_2     := upper(:new.par_last_name_2); 
     l_vw_student_record.par_middle_name_2   := upper(:new.par_middle_name_2);
     l_vw_student_record.par_parent_number_2 := :new.par_parent_number_2; 
     l_vw_student_record.PAR_REL_TYPE_2      := :new.PAR_REL_TYPE_2;
     l_vw_student_record.par_parent_id_2     := :new.par_parent_id_2; 
     l_vw_student_record.PAR_REL_TYPE_ID_2   := :new.PAR_REL_TYPE_ID_2;
 
    -- Medical data
     l_vw_student_record.TYLENOL_IFNEEDED    := :new.TYLENOL_IFNEEDED;
     l_vw_student_record.HEALTH_CARD         := :new.HEALTH_CARD;
     l_vw_student_record.dr_add_id           := :new.dr_add_id;
     l_vw_student_record.dr_name             := :new.dr_name;
     l_vw_student_record.dr_phone            := :new.dr_phone;
     l_vw_student_record.dr_add_id           := :new.dr_add_id;
     l_vw_student_record.dr_ADD_DESC_1       := :new.dr_add_desc_1;
     l_vw_student_record.dr_ADD_POSTAL_CODE  := :new.dr_add_postal_code;
     l_vw_student_record.dr_ADD_CITY         := :new.dr_add_city;
     l_vw_student_record.dr_PROVINCE_ID      := :new.dr_province_id;
     l_vw_student_record.dr_COUNTRY_ID       := :new.dr_country_id;
     l_vw_student_record.dr_add_fax          := :new.dr_add_fax;
    -- ======================= 
    -- Populate student data
    -- ======================= 
    l_vw_student_record.STUDENT_NUMBER       := :new.STUDENT_NUMBER; 
    l_vw_student_record.STUDENT_ID           := :new.STUDENT_ID; 
    l_vw_student_record.FIRST_NAME           := Upper(:new.FIRST_NAME); 
    l_vw_student_record.LAST_NAME            := Upper(:new.LAST_NAME); 
    l_vw_student_record.MIDDLE_NAME          := Upper(:new.MIDDLE_NAME); 
    l_vw_student_record.BIRTH_DATE           := :new.BIRTH_DATE; 
    l_vw_student_record.BIRTH_CITY           := :new.BIRTH_CITY; 
    l_vw_student_record.BIRTH_COUNTRY_ID     := :new.BIRTH_COUNTRY_ID; 
    l_vw_student_record.COUNTRY_ID           := :new.COUNTRY_ID; 
    l_vw_student_record.ADD_ID               := :new.add_id; 
    l_vw_student_record.ADD_COMMENTS         := :new.ADD_COMMENTS; 
    l_vw_student_record.CREATE_DATE := sysdate;  
    l_vw_student_record.CREATE_BY_LOGIN_ID := :new.CREATE_BY_LOGIN_ID; 
    l_vw_student_record.LAST_UPDATE_DATE := sysdate;  
    l_vw_student_record.UPDATE_BY_LOGIN_ID := :new.UPDATE_BY_LOGIN_ID; 
    --l_vw_student_record.CELL_PHONE := :new.CELL_PHONE; 
    --l_vw_student_record.EMAIL_ADDRESS := :new.EMAIL_ADDRESS; 
    l_vw_student_record.USUAL_NAME := :new.USUAL_NAME; 
    --
    l_picture_rec.DESCRIPTION        := :new.STUDENT_NAME;
    l_picture_rec.PICTURE_ID         := :new.PICTURE_ID;
    l_picture_rec.PHOTO              := :new.PHOTO;
    l_picture_rec.PHOTO_FILENAME     := :new.PHOTO_FILENAME;
    l_picture_rec.PHOTO_UPDATED_DATE := :new.PHOTO_UPDATED_DATE;
    l_picture_rec.PHOTO_MIMETYPE     := :new.PHOTO_MIMETYPE;
    l_picture_rec.PHOTO_CHARSET      := :new.PHOTO_CHARSET;
    l_picture_rec.TARGET_OBJECT_CODE := 'MSTD';
    l_picture_rec.TARGET_OBJECT_ID   := :new.STUDENT_ID;
    --l_picture_rec.CREATE_BY_LOGIN_ID := :new.CREATE_BY_LOGIN_ID;
    --l_picture_rec.UPDATE_BY_LOGIN_ID := :new.UPDATE_BY_LOGIN_ID;
    l_picture_rec.CREATE_DATE        := sysdate;
    l_picture_rec.LAST_UPDATE_DATE   := sysdate;
    --
    if (inserting) then
      pkg_enrollment.create_student( 
           pi_vw_student_record => l_vw_student_record); 
      --
      -- create the picture
      l_picture_rec.picture_id := pkg_picture.create_picture(pi_picture_rec => l_picture_rec);
    -- 
    elsif (updating) then
      pkg_enrollment.update_student( 
           pi_vw_student_record => l_vw_student_record); 
      --
      -- update the picture
      pkg_picture.update_picture(pi_picture_rec => l_picture_rec);
    -- 
    elsif (deleting) then
      pkg_enrollment.delete_student( 
           pi_student_id => l_vw_student_record.student_id); 
      --
      -- create the picture
      pkg_picture.delete_picture(pi_picture_id => l_picture_rec.picture_id);
    end if;
exception 
  when others then raise; 
end; 
