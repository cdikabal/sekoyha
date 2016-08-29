create or replace PACKAGE BODY  "PKG_ADDRESS" AS 
-- =========================================================================  
-- G L O B A L   P R I V A T E   V A R I A B L E S   A N D   C O N S T A N T S
-- =========================================================================  
   
-- =========================================================================  
-- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S   I M P L E M E N T A T I O N
-- =========================================================================  
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
      raise_application_error(-20001, 'PKG_ADDRESS.get_version() - '||sqlerrm);
  End get_version;
  
-- ----------------------------------------------------------------------------- 
-- function create_or_replace( )
-- ----------------------------------------------------------------------------- 
function create_or_replace( 
               pi_add_desc_1 in address.add_desc_1%Type, 
               pi_add_phone in address.add_phone%Type, 
               pi_add_postal_code in address.add_postal_code%Type, 
               pi_add_city in address.add_city%Type, 
               pi_province_id in address.province_id%Type := pkg_address.K_ONTARIO_PROVINCE_ID, 
               pi_country_id in address.country_id%Type := pkg_address.K_CANADA_COUNTRY_ID, 
               pi_desc_2 in address.add_desc_2%Type := null, 
               pi_add_comments in address.add_comments%Type := null, 
               pi_add_fax in address.add_fax%Type := null, 
               pi_add_id in address.add_id%Type := null, 
               pi_login_id in address.create_by_login_id%Type := 1)  
  return address.add_id%Type AS 
    l_id address.add_id%Type := pi_add_id; 
    Already_Caught exception; 
    PRAGMA Exception_Init(Already_Caught, -20001); 
  BEGIN 
    -- Update the existing address 
    if pi_add_id is not null then 
      update MLT_address a 
         set 
            a.ADD_DESC_1        = upper(pi_add_desc_1) 
            , a.ADD_DESC_2      = upper(pi_desc_2) 
            , a.ADD_PHONE       = pi_add_phone 
            , a.ADD_POSTAL_CODE = upper(pi_add_postal_code) 
            , a.ADD_CITY        = upper(pi_add_city) 
            , a.PROVINCE_ID     = nvl(pi_province_id, pkg_address.K_ONTARIO_PROVINCE_ID)
            , a.ADD_FAX         = pi_add_fax 
            , a.ADD_COMMENTS    = pi_add_comments 
            , a.COUNTRY_ID      = Nvl(pi_country_id, pkg_address.K_CANADA_COUNTRY_ID)
            , a.UPDATE_BY_LOGIN_ID = pi_login_id 
            , a.LAST_UPDATE_DATE = sysdate 
       where a.add_id = pi_add_id; 
       return pi_add_id; 
    end if; 
    -- 
    /* 
    if l_id is null then 
      l_id := get_id( 
               pi_add_desc_1, pi_add_postal_code,  
               pi_add_city, pi_province_id, pi_country_id, pi_add_phone); 
    end if; 
    */ 
    -- 
    if l_id is not null then  
      -- 
      if pi_desc_2 is not null or 
         pi_add_comments is not null or 
         pi_add_fax is not null then 
         update address a 
            set add_comments = pi_add_comments, 
                add_phone    = pi_add_phone, 
                add_fax      = pi_add_fax 
            , a.UPDATE_BY_LOGIN_ID = pi_login_id 
            , a.LAST_UPDATE_DATE = sysdate 
          where a.add_id = l_id; 
      end if; 
      -- 
      return l_id;  
    end if; 
    -- 
    if pi_add_desc_1 is null then return null; end if; 
      insert into MLT_address 
        (tenant_id, add_desc_1, add_desc_2, add_phone, add_postal_code,  
         add_city, province_id, country_id, add_comments, add_fax, 
         CREATE_BY_LOGIN_ID, CREATE_DATE, UPDATE_BY_LOGIN_ID, LAST_UPDATE_DATE) 
      values 
       (pkg_tenant.get_current_id(), upper(pi_add_desc_1), upper(pi_desc_2),  
        pi_add_phone, upper(pi_add_postal_code), upper(pi_add_city), nvl(pi_province_id, pkg_address.K_ONTARIO_PROVINCE_ID),  
        pi_country_id, pi_add_comments, pi_add_fax, 
        pi_login_id, sysdate, pi_login_id, sysdate) 
      returning add_id into l_id; 
    -- 
    return l_id; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return null; 
    WHEN Already_Caught then raise; 
    WHEN OTHERS THEN  
        raise_application_error(-20001, 'PKG_ADDRESS.create_or_replace[1]('||pi_add_desc_1||') ## '||sqlerrm); 
  END create_or_replace; 
 
  -- --------------------------------------------------------------------- 
  -- Function create_or_replace( ) 
  -- --------------------------------------------------------------------- 
  function create_or_replace( pi_address_record in address%RowType) 
    return address.add_id%Type is 
    l_id address.add_id%Type := pi_address_record.add_id; 
    Already_Caught exception; 
    PRAGMA Exception_Init(Already_Caught, -20001); 
  BEGIN 
 
   l_id := create_or_replace( 
      pi_add_desc_1 => pi_address_record.add_desc_1 , 
      pi_add_phone  => pi_address_record.add_phone , 
      pi_add_postal_code => pi_address_record.add_postal_code , 
      pi_add_city => pi_address_record.add_city , 
      pi_province_id => pi_address_record.province_id , 
      pi_country_id  => pi_address_record.country_id , 
      pi_desc_2      => pi_address_record.add_desc_2 , 
      pi_add_comments => pi_address_record.add_comments , 
      pi_add_fax => pi_address_record.add_fax , 
      pi_add_id => pi_address_record.add_id); 
   -- 
   Update MLT_address set  
       
      UPDATE_BY_LOGIN_ID = pi_address_record.UPDATE_BY_LOGIN_ID 
    Where add_id = l_id; 
    Return l_id;
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return null; 
    WHEN Already_Caught then raise; 
    WHEN OTHERS THEN  
        raise_application_error(-20001, 'PKG_ADDRESS.create_or_replace[2]('||pi_address_record.add_id||', '||pi_address_record.add_desc_1||') ## '||sqlerrm); 
  END create_or_replace; 
 
  -- --------------------------------------------------------------------- 
  -- procedure replace_it() 
  -- --------------------------------------------------------------------- 
  procedure replace_it( 
               pi_add_id in address.add_id%Type, 
               pi_add_desc_1 in address.add_desc_1%Type, 
               pi_add_phone in address.add_phone%Type, 
               pi_add_postal_code in address.add_postal_code%Type, 
               pi_add_city in address.add_city%Type, 
               pi_province_id in address.province_id%Type := pkg_address.K_ONTARIO_PROVINCE_ID, 
               pi_country_id in address.country_id%Type := pkg_address.K_CANADA_COUNTRY_ID, 
               pi_add_desc_2 in address.add_desc_2%Type := null, 
               pi_add_comments in address.add_comments%Type := null, 
               pi_add_fax in address.add_fax%Type := null) is 
    Already_Caught exception; 
    PRAGMA Exception_Init(Already_Caught, -20001); 
  Begin 
    update MLT_address 
       set add_desc_1      = upper(pi_add_desc_1),  
           add_desc_2      = upper(pi_add_desc_2),  
           add_phone       = pi_add_phone,  
           add_postal_code = upper(pi_add_postal_code),  
           add_city        = upper(pi_add_city),  
           province_id     = pi_province_id,  
           country_id      = pi_country_id,  
           add_comments    = pi_add_comments, 
           add_fax         = pi_add_fax 
    where add_id = pi_add_id; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN null; 
    WHEN Already_Caught then raise; 
    WHEN OTHERS THEN  
        raise_application_error(-20001, 'PKG_ADDRESS.replace_it('||pi_add_id||', '||pi_add_desc_1||') ## '||sqlerrm); 
  End replace_it; 
  -- --------------------------------------------------------------------- 
  -- Function is_created() 
  -- --------------------------------------------------------------------- 
  function is_created( 
               pi_add_desc_1 in address.add_desc_1%Type, 
               pi_add_postal_code in address.add_postal_code%Type, 
               pi_add_city in address.add_city%Type, 
               pi_province_id in address.province_id%Type := pkg_address.K_ONTARIO_PROVINCE_ID, 
               pi_country_id in address.country_id%Type   := pkg_address.K_CANADA_COUNTRY_ID)  
  return boolean AS 
    l_id address.add_id%Type; 
    Already_Caught exception; 
    PRAGMA Exception_Init(Already_Caught, -20001); 
  BEGIN 
    l_id := get_id( 
               upper(pi_add_desc_1), upper(pi_add_postal_code),  
               upper(pi_add_city), pi_province_id, pi_country_id); 
    RETURN (l_id is not null); 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return false; 
    WHEN Already_Caught then raise; 
    WHEN OTHERS THEN  
        raise_application_error(-20001, 'PKG_ADDRESS.is_created('||pi_add_desc_1||') ## '||sqlerrm); 
  END is_created; 
  -- --------------------------------------------------------------------- 
  -- Function get_id() 
  -- --------------------------------------------------------------------- 
  function get_id( 
               pi_add_desc_1 in address.add_desc_1%Type, 
               pi_add_postal_code in address.add_postal_code%Type, 
               pi_add_city in address.add_city%Type, 
               pi_province_id in address.province_id%Type := pkg_address.K_ONTARIO_PROVINCE_ID, 
               pi_country_id in address.country_id%Type   := pkg_address.K_CANADA_COUNTRY_ID, 
               pi_add_phone in address.add_phone%Type     := null)  
  return address.add_id%Type AS 
    l_id address.add_id%Type; 
    l_add_phone varchar2(32) := translate(pi_add_phone,'0123456789- ().#','0123456789'); 
    Already_Caught exception; 
    PRAGMA Exception_Init(Already_Caught, -20001); 
  BEGIN 
    select a.add_id 
      into l_id 
      from MLT_address a 
     where a.add_desc_1 = upper(pi_add_desc_1) 
       and a.add_postal_code = upper(pi_add_postal_code) 
       and a.add_city = upper(pi_add_city) 
       and a.province_id = pi_province_id 
       and a.country_id  = pi_country_id 
       and translate(a.add_phone,'0123456789- ().#','0123456789') =  
           nvl(l_add_phone, translate(a.add_phone,'0123456789- ().#','0123456789')); 
    return l_id; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN return null; 
    WHEN Already_Caught then raise; 
    WHEN OTHERS THEN  
        raise_application_error(-20001, 'PKG_ADDRESS.get_id('||pi_add_desc_1||') ## '||sqlerrm); 
  END get_id; 
END PKG_ADDRESS; 
/

select PKG_ADDRESS.get_version() from dual;