create or replace PACKAGE  "PKG_DBADMIN" AS  
  -- --------------------------------------------------------------------------- 
  -- Procedure: Create_View 
  -- Purpose: 
  --  Create the tenant view of a multi-tenant table if that view doesn't exist 
  --  Replace the tenant view of a multi-tenant table if the view exists but  
  --  doesn't have any instead-of triggers 
  -- --------------------------------------------------------------------------- 
  Procedure Create_Tenant_View( 
      pi_table_name in varchar2, pi_view_name in varchar2 default null,  
      pi_abbreviation in varchar2 default null); 
  -- --------------------------------------------------------------------------- 
  -- Procedure: Create_Audit_Trigger 
  -- --------------------------------------------------------------------------- 
  Procedure Create_Audit_Trigger( 
      pi_table_name in varchar2, pi_table_abbreviation in varchar2 default null); 
  -- --------------------------------------------------------------------------- 
  -- Procedure: Create_Audit_Fk 
  -- --------------------------------------------------------------------------- 
  Procedure Create_Audit_Fk( 
      pi_table_name in varchar2, pi_table_abbreviation in varchar2 default null); 
  -- --------------------------------------------------------------------------- 
  -- Procedure: Create_Audit_Column 
  -- --------------------------------------------------------------------------- 
  Procedure Create_Audit_Column( 
      pi_table_name in varchar2, pi_table_abbreviation in varchar2 default null); 
  -- --------------------------------------------------------------------------- 
  -- Function: Has_InsteadOf_Triggers 
  -- --------------------------------------------------------------------------- 
  Function Has_InsteadOf_Triggers(pi_view_name in varchar2) return boolean; 
  -- --------------------------------------------------------------------------- 
  -- Function: Has_all_audit_fields() return boolean 
  -- --------------------------------------------------------------------------- 
  Function Has_all_audit_fields(pi_table_name in varchar2) return boolean; 
  -- --------------------------------------------------------------------------- 
  -- Function: get_abbreviation() return varchar2 
  -- --------------------------------------------------------------------------- 
  Function get_abbreviation(pi_table_name in varchar2) return varchar2; 
  -- --------------------------------------------------------------------------- 
  -- Procedure: Create_Identifier_Trigger 
  -- --------------------------------------------------------------------------- 
  Procedure Create_Identifier_Trigger( 
      pi_table_name in varchar2, pi_abbreviation in varchar2:= null, pi_identity_name in varchar2 := null); 
 
  -- --------------------------------------------------------------------------- 
  -- Procedure: Get_Pk_Name 
  -- --------------------------------------------------------------------------- 
  Function Get_Pk_Name(pi_table_name in varchar2) return varchar2; 
 
  -- --------------------------------------------------------------------------- 
  -- Procedure: Set_Pk_Name 
  -- --------------------------------------------------------------------------- 
  Procedure Set_Pk_Name(pi_table_name in varchar2); 
 
  -- --------------------------------------------------------------------------- 
  -- Function: Get_Current_Max_ID 
  -- --------------------------------------------------------------------------- 
  Function Get_Current_Max_ID(pi_table_name in varchar2) return number; 
 
  -- --------------------------------------------------------------------------- 
  -- Function:Get_Version()
  -- --------------------------------------------------------------------------- 
  Function get_version return varchar2;
  
END PKG_DBADMIN; 
