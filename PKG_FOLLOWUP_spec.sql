create or replace package "PKG_FOLLOWUP" is

-- ------------------------------------------------------------
-- Function get_version()
-- ------------------------------------------------------------
   Function get_version return varchar2;
   
-- ------------------------------------------------------------
-- Function: Create_Replace
-- ------------------------------------------------------------
   Function Create_Replace(
      Pi_FOLLOWUP_ID        in number,
      Pi_STICK_BY_LOGIN_ID  in number,
      Pi_STICK_DATE         in date,
      Pi_TARGET_OBJECT_CODE in varchar2,
      Pi_TARGET_OBJECT_ID   in number,
      Pi_SUBJECT            in varchar2,
      Pi_ADDITIONAL_INFO    in varchar2                        default null
   ) return followup.followup_id%Type;

-- ------------------------------------------------------------
-- Procedure: Clear
-- ------------------------------------------------------------
   Procedure Clear(
      Pi_FOLLOWUP_ID        in number,
      Pi_CLEAR_BY_LOGIN_ID  in number                          default 21,
      Pi_CLEAR_DATE         in date                            default sysdate
   );

-- ------------------------------------------------------------
-- Function get_unclear_count()
-- ------------------------------------------------------------
   Function get_unclear_count(
      pi_target_object_code in followup.target_object_code%Type
	  , pi_target_object_id in followup.target_object_id%Type)
	 return number;
	 
-- ------------------------------------------------------------
-- Function get_clear_count()
-- ------------------------------------------------------------
   Function get_clear_count(
      pi_target_object_code in followup.target_object_code%Type
	  , pi_target_object_id in followup.target_object_id%Type)
	 return number;
	 
-- ------------------------------------------------------------
-- Procedure: Clear_All
-- ------------------------------------------------------------
   Procedure Clear_All(
      pi_target_object_code in followup.target_object_code%Type,
	  pi_target_object_id   in followup.target_object_id%Type,
      Pi_CLEAR_BY_LOGIN_ID  in followup.clear_by_login_id%Type default 21,
      Pi_CLEAR_DATE         in date                            default sysdate
   );

-- ------------------------------------------------------------
-- create procedure for table "MLT_FOLLOWUP"
-- ------------------------------------------------------------
   procedure "INS_MLT_FOLLOWUP" (
      "P_FOLLOWUP_ID"        in number,
      "P_TENANT_ID"          in number,
      "P_STICK_BY_LOGIN_ID"  in number,
      "P_STICK_DATE"         in date,
      "P_TARGET_OBJECT_CODE" in varchar2,
      "P_TARGET_OBJECT_ID"   in number,
      "P_CLEARED"            in varchar2                        default '''N'' ',
      "P_CLEAR_BY_LOGIN_ID"  in number                          default null,
      "P_CLEAR_DATE"         in date                            default null,
      "P_SUBJECT"            in varchar2,
      "P_ADDITIONAL_INFO"    in varchar2                        default null,
      "P_DELETED"            in varchar2                        default '''N'' ',
      "P_DELETED_DATE"       in date                            default null,
      "P_CREATE_DATE"        in date                            default null,
      "P_CREATE_BY_LOGIN_ID" in number                          default null,
      "P_LAST_UPDATE_DATE"   in date                            default null,
      "P_UPDATE_BY_LOGIN_ID" in number                          default null
   );
-- ------------------------------------------------------------
-- update procedure for table "MLT_FOLLOWUP"
-- ------------------------------------------------------------
   procedure "UPD_MLT_FOLLOWUP" (
      "P_FOLLOWUP_ID" in number,
      "P_TENANT_ID"          in number,
      "P_STICK_BY_LOGIN_ID"  in number,
      "P_STICK_DATE"         in date,
      "P_TARGET_OBJECT_CODE" in varchar2,
      "P_TARGET_OBJECT_ID"   in number,
      "P_CLEARED"            in varchar2                        default '''N'' ',
      "P_CLEAR_BY_LOGIN_ID"  in number                          default null,
      "P_CLEAR_DATE"         in date                            default null,
      "P_SUBJECT"            in varchar2,
      "P_ADDITIONAL_INFO"    in varchar2                        default null,
      "P_DELETED"            in varchar2                        default '''N'' ',
      "P_DELETED_DATE"       in date                            default null,
      "P_CREATE_DATE"        in date                            default null,
      "P_CREATE_BY_LOGIN_ID" in number                          default null,
      "P_LAST_UPDATE_DATE"   in date                            default null,
      "P_UPDATE_BY_LOGIN_ID" in number                          default null,
      "P_MD5"                in varchar2                        default null
   );
-- ------------------------------------------------------------
-- delete procedure for table "MLT_FOLLOWUP"
-- ------------------------------------------------------------
   procedure "DEL_MLT_FOLLOWUP" (
      "P_FOLLOWUP_ID" in number
   );
-- ------------------------------------------------------------
-- get procedure for table "MLT_FOLLOWUP"
-- ------------------------------------------------------------
   procedure "GET_MLT_FOLLOWUP" (
      "P_FOLLOWUP_ID" in number,
      "P_TENANT_ID"          out number,
      "P_STICK_BY_LOGIN_ID"  out number,
      "P_STICK_DATE"         out date,
      "P_TARGET_OBJECT_CODE" out varchar2,
      "P_TARGET_OBJECT_ID"   out number,
      "P_CLEARED"            out varchar2,
      "P_CLEAR_BY_LOGIN_ID"  out number,
      "P_CLEAR_DATE"         out date,
      "P_SUBJECT"            out varchar2,
      "P_ADDITIONAL_INFO"    out varchar2,
      "P_DELETED"            out varchar2,
      "P_DELETED_DATE"       out date,
      "P_CREATE_DATE"        out date,
      "P_CREATE_BY_LOGIN_ID" out number,
      "P_LAST_UPDATE_DATE"   out date,
      "P_UPDATE_BY_LOGIN_ID" out number
   );
-- ------------------------------------------------------------
-- get procedure for table "MLT_FOLLOWUP"
-- ------------------------------------------------------------
   procedure "GET_MLT_FOLLOWUP" (
      "P_FOLLOWUP_ID" in number,
      "P_TENANT_ID"          out number,
      "P_STICK_BY_LOGIN_ID"  out number,
      "P_STICK_DATE"         out date,
      "P_TARGET_OBJECT_CODE" out varchar2,
      "P_TARGET_OBJECT_ID"   out number,
      "P_CLEARED"            out varchar2,
      "P_CLEAR_BY_LOGIN_ID"  out number,
      "P_CLEAR_DATE"         out date,
      "P_SUBJECT"            out varchar2,
      "P_ADDITIONAL_INFO"    out varchar2,
      "P_DELETED"            out varchar2,
      "P_DELETED_DATE"       out date,
      "P_CREATE_DATE"        out date,
      "P_CREATE_BY_LOGIN_ID" out number,
      "P_LAST_UPDATE_DATE"   out date,
      "P_UPDATE_BY_LOGIN_ID" out number,
      "P_MD5"                out varchar2
   );
-- ------------------------------------------------------------
-- build MD5 function for table "MLT_FOLLOWUP"
-- ------------------------------------------------------------
   function "BUILD_MLT_FOLLOWUP_MD5" (
      "P_FOLLOWUP_ID" in number,
      "P_TENANT_ID"          in number,
      "P_STICK_BY_LOGIN_ID"  in number,
      "P_STICK_DATE"         in date,
      "P_TARGET_OBJECT_CODE" in varchar2,
      "P_TARGET_OBJECT_ID"   in number,
      "P_CLEARED"            in varchar2                        default '''N'' ',
      "P_CLEAR_BY_LOGIN_ID"  in number                          default null,
      "P_CLEAR_DATE"         in date                            default null,
      "P_SUBJECT"            in varchar2,
      "P_ADDITIONAL_INFO"    in varchar2                        default null,
      "P_DELETED"            in varchar2                        default '''N'' ',
      "P_DELETED_DATE"       in date                            default null,
      "P_CREATE_DATE"        in date                            default null,
      "P_CREATE_BY_LOGIN_ID" in number                          default null,
      "P_LAST_UPDATE_DATE"   in date                            default null,
      "P_UPDATE_BY_LOGIN_ID" in number                          default null
   ) return varchar2;
 
end "PKG_FOLLOWUP";
/

