create or replace PACKAGE  "PKG_ADDRESS" AS  
-- =========================================================================  
-- G L O B A L   P U B L I C   V A R I A B L E S   A N D   C O N S T A N T S
-- =========================================================================  
   K_ONTARIO_PROVINCE_ID CONSTANT address.province_id%Type := 12;
   K_CANADA_COUNTRY_ID CONSTANT address.country_id%Type := 1;
   
-- =========================================================================  
-- Description  
--  This package is used to manage ADDRESS entity  
-- List of public procedures and functions  
-- =========================================================================  
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
    return address.add_id%Type;  
  
  function create_or_replace( pi_address_record in address%RowType)  
    return address.add_id%Type;  
  
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
               pi_add_fax in address.add_fax%Type := null) ;  
  
  function is_created(  
               pi_add_desc_1 in address.add_desc_1%Type,  
               pi_add_postal_code in address.add_postal_code%Type,  
               pi_add_city in address.add_city%Type,  
               pi_province_id in address.province_id%Type := pkg_address.K_ONTARIO_PROVINCE_ID,  
               pi_country_id in address.country_id%Type   := pkg_address.K_CANADA_COUNTRY_ID)   
    return boolean;  
  
  function get_id(  
               pi_add_desc_1 in address.add_desc_1%Type,  
               pi_add_postal_code in address.add_postal_code%Type,  
               pi_add_city in address.add_city%Type,  
               pi_province_id in address.province_id%Type := pkg_address.K_ONTARIO_PROVINCE_ID,  
               pi_country_id in address.country_id%Type   := pkg_address.K_CANADA_COUNTRY_ID,  
               pi_add_phone in address.add_phone%Type     := null)   
    return address.add_id%Type;  
  
-- ----------------------------------------------------------------------------- 
-- Function get_version()
-- ----------------------------------------------------------------------------- 
Function get_version return varchar2;

END PKG_ADDRESS;  
/
