create or replace package body "PKG_FOLLOWUP" is

-- ------------------------------------------------------------
-- Function get_version()
-- ------------------------------------------------------------
   Function get_version return varchar2 is
     Already_Caught Exception;
	 PRAGMA Exception_Init(Already_Caught, -20001);
   Begin
     return '$Id$';
   Exception
     When Already_Caught then raise;
     When others then
	    raise_application_error(-20001, 'pkg_followup.get_version() - '||sqlerrm);
   End get_version;
   
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
   ) return followup.followup_id%Type is
   --
     l_followup_id followup.followup_id%Type := Pi_FOLLOWUP_ID;
	 l_STICK_BY_LOGIN_ID number := nvl(Pi_STICK_BY_LOGIN_ID, pkg_login.get_login_id(p_apex_username=>v('APP_USER')));
   --
     Already_Caught Exception;
	 PRAGMA Exception_Init(Already_Caught, -20001);
   Begin
     if l_followup_id is not null then
	   update followup t
	      set t.ADDITIONAL_INFO = pi_ADDITIONAL_INFO
	    where t.followup_id = l_followup_id;
	 else
	   insert into followup(FOLLOWUP_ID, STICK_BY_LOGIN_ID, STICK_DATE, TARGET_OBJECT_CODE, TARGET_OBJECT_ID, SUBJECT, ADDITIONAL_INFO)
	   values (1, l_STICK_BY_LOGIN_ID, nvl(pi_STICK_DATE, sysdate), pi_TARGET_OBJECT_CODE, pi_TARGET_OBJECT_ID, pi_SUBJECT, pi_ADDITIONAL_INFO)
	   returning followup_id into l_followup_id;
	 end if;
	 --
     return l_followup_id;
   Exception
     When Already_Caught then raise;
     When others then
	    raise_application_error(-20001, 'pkg_followup.Create_Replace() - '||sqlerrm);
   End Create_Replace;

-- ------------------------------------------------------------
-- Procedure: Clear
-- ------------------------------------------------------------
   Procedure Clear(
      Pi_FOLLOWUP_ID        in number,
      Pi_CLEAR_BY_LOGIN_ID  in number                          default 21,
      Pi_CLEAR_DATE         in date                            default sysdate
   ) is
   --
     Already_Caught Exception;
	 PRAGMA Exception_Init(Already_Caught, -20001);
   Begin
     Update followup t
	    set t.CLEARED = 'Y'
		    , t.CLEAR_DATE = nvl(Pi_CLEAR_DATE, sysdate)
			, t.CLEAR_BY_LOGIN_ID = nvl(Pi_CLEAR_BY_LOGIN_ID, pkg_login.get_login_id(p_apex_username=>v('APP_USER')))
	  where t.followup_id = Pi_FOLLOWUP_ID;
   Exception
     When Already_Caught then raise;
     When others then
	    raise_application_error(-20001, 'pkg_followup.Clear() - '||sqlerrm);
   End Clear;

-- ------------------------------------------------------------
-- Procedure: Clear_All
-- ------------------------------------------------------------
   Procedure Clear_All(
      pi_target_object_code in followup.target_object_code%Type,
	  pi_target_object_id   in followup.target_object_id%Type,
      Pi_CLEAR_BY_LOGIN_ID  in followup.clear_by_login_id%Type default 21,
      Pi_CLEAR_DATE         in date                            default sysdate
   ) is
   --
     Already_Caught Exception;
	 PRAGMA Exception_Init(Already_Caught, -20001);
   Begin
     Update followup t
	    set t.CLEARED = 'Y'
		    , t.CLEAR_DATE = nvl(Pi_CLEAR_DATE, sysdate)
			, t.CLEAR_BY_LOGIN_ID = nvl(Pi_CLEAR_BY_LOGIN_ID, pkg_login.get_login_id(p_apex_username=>v('APP_USER')))
	  where t.target_object_code = Pi_target_object_code
	    and t.target_object_id = pi_target_object_id
		and t.cleared = 'N';
   Exception
     When Already_Caught then raise;
     When others then
	    raise_application_error(-20001, 'pkg_followup.Clear_All() - '||sqlerrm);
   End Clear_All;
   
-- ------------------------------------------------------------
-- Function get_unclear_count()
-- ------------------------------------------------------------
   Function get_unclear_count(
      pi_target_object_code in followup.target_object_code%Type
	  , pi_target_object_id in followup.target_object_id%Type)
	 return number is
	 l_count number ;
   --
     Already_Caught Exception;
	 PRAGMA Exception_Init(Already_Caught, -20001);
   Begin
     select count(1) into l_count
	   from followup flup
	  where flup.target_object_code = pi_target_object_code
	    and flup.target_object_id = pi_target_object_id
		and flup.cleared <> 'Y';
     return l_count;
   Exception
     When No_Data_Found then return 0;
     When Already_Caught then raise;
     When others then
	    raise_application_error(-20001, 'pkg_followup.get_unclear_count('||pi_target_object_code||','||pi_target_object_id||') - '||sqlerrm);
   End get_unclear_count;
   
-- ------------------------------------------------------------
-- Function get_clear_count()
-- ------------------------------------------------------------
   Function get_clear_count(
      pi_target_object_code in followup.target_object_code%Type
	  , pi_target_object_id in followup.target_object_id%Type)
	 return number is
	 l_count number ;
   --
     Already_Caught Exception;
	 PRAGMA Exception_Init(Already_Caught, -20001);
   Begin
     select count(1) into l_count
	   from followup flup
	  where flup.target_object_code = pi_target_object_code
	    and flup.target_object_id = pi_target_object_id
		and flup.cleared = 'Y';
     return l_count;
   Exception
     When No_Data_Found then return 0;
     When Already_Caught then raise;
     When others then
	    raise_application_error(-20001, 'pkg_followup.get_clear_count('||pi_target_object_code||','||pi_target_object_id||') - '||sqlerrm);
   End get_clear_count;
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
   ) is 
 
   begin
 
      insert into "MLT_FOLLOWUP" (
         "FOLLOWUP_ID",
         "TENANT_ID",
         "STICK_BY_LOGIN_ID",
         "STICK_DATE",
         "TARGET_OBJECT_CODE",
         "TARGET_OBJECT_ID",
         "CLEARED",
         "CLEAR_BY_LOGIN_ID",
         "CLEAR_DATE",
         "SUBJECT",
         "ADDITIONAL_INFO",
         "DELETED",
         "DELETED_DATE",
         "CREATE_DATE",
         "CREATE_BY_LOGIN_ID",
         "LAST_UPDATE_DATE",
         "UPDATE_BY_LOGIN_ID"
      ) values ( 
         "P_FOLLOWUP_ID",
         "P_TENANT_ID",
         "P_STICK_BY_LOGIN_ID",
         "P_STICK_DATE",
         "P_TARGET_OBJECT_CODE",
         "P_TARGET_OBJECT_ID",
         "P_CLEARED",
         "P_CLEAR_BY_LOGIN_ID",
         "P_CLEAR_DATE",
         "P_SUBJECT",
         "P_ADDITIONAL_INFO",
         "P_DELETED",
         "P_DELETED_DATE",
         "P_CREATE_DATE",
         "P_CREATE_BY_LOGIN_ID",
         "P_LAST_UPDATE_DATE",
         "P_UPDATE_BY_LOGIN_ID"
      );
 
   end "INS_MLT_FOLLOWUP";
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
   ) is 
 
      "L_MD5" varchar2(32767) := null;
 
   begin
 
      if "P_MD5" is not null then
         for c1 in (
            select * from "MLT_FOLLOWUP" 
            where "FOLLOWUP_ID" = "P_FOLLOWUP_ID" FOR UPDATE
         ) loop
 
            "L_MD5" := "BUILD_MLT_FOLLOWUP_MD5"(
               c1."FOLLOWUP_ID",
               c1."TENANT_ID",
               c1."STICK_BY_LOGIN_ID",
               c1."STICK_DATE",
               c1."TARGET_OBJECT_CODE",
               c1."TARGET_OBJECT_ID",
               c1."CLEARED",
               c1."CLEAR_BY_LOGIN_ID",
               c1."CLEAR_DATE",
               c1."SUBJECT",
               c1."ADDITIONAL_INFO",
               c1."DELETED",
               c1."DELETED_DATE",
               c1."CREATE_DATE",
               c1."CREATE_BY_LOGIN_ID",
               c1."LAST_UPDATE_DATE",
               c1."UPDATE_BY_LOGIN_ID"
            );
 
         end loop;
 
      end if;
 
      if ("P_MD5" is null) or ("L_MD5" = "P_MD5") then 
         update "MLT_FOLLOWUP" set
            "FOLLOWUP_ID"          = "P_FOLLOWUP_ID",
            "TENANT_ID"            = "P_TENANT_ID",
            "STICK_BY_LOGIN_ID"    = "P_STICK_BY_LOGIN_ID",
            "STICK_DATE"           = "P_STICK_DATE",
            "TARGET_OBJECT_CODE"   = "P_TARGET_OBJECT_CODE",
            "TARGET_OBJECT_ID"     = "P_TARGET_OBJECT_ID",
            "CLEARED"              = "P_CLEARED",
            "CLEAR_BY_LOGIN_ID"    = "P_CLEAR_BY_LOGIN_ID",
            "CLEAR_DATE"           = "P_CLEAR_DATE",
            "SUBJECT"              = "P_SUBJECT",
            "ADDITIONAL_INFO"      = "P_ADDITIONAL_INFO",
            "DELETED"              = "P_DELETED",
            "DELETED_DATE"         = "P_DELETED_DATE",
            "CREATE_DATE"          = "P_CREATE_DATE",
            "CREATE_BY_LOGIN_ID"   = "P_CREATE_BY_LOGIN_ID",
            "LAST_UPDATE_DATE"     = "P_LAST_UPDATE_DATE",
            "UPDATE_BY_LOGIN_ID"   = "P_UPDATE_BY_LOGIN_ID"
         where "FOLLOWUP_ID" = "P_FOLLOWUP_ID";
      else
         raise_application_error (-20001,'Current version of data in database has changed since user initiated update process. current checksum = "'||"L_MD5"||'", item checksum = "'||"P_MD5"||'".');  
      end if;
 
   end "UPD_MLT_FOLLOWUP";
-- ------------------------------------------------------------
-- delete procedure for table "MLT_FOLLOWUP"
-- ------------------------------------------------------------
   procedure "DEL_MLT_FOLLOWUP" (
      "P_FOLLOWUP_ID" in number
   ) is 
 
   begin
 
      delete from "MLT_FOLLOWUP" 
      where "FOLLOWUP_ID" = "P_FOLLOWUP_ID";
 
   end "DEL_MLT_FOLLOWUP";
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
   ) is 
 
      ignore varchar2(32676);
   begin
 
      "GET_MLT_FOLLOWUP" (
         "P_FOLLOWUP_ID",
         "P_TENANT_ID",
         "P_STICK_BY_LOGIN_ID",
         "P_STICK_DATE",
         "P_TARGET_OBJECT_CODE",
         "P_TARGET_OBJECT_ID",
         "P_CLEARED",
         "P_CLEAR_BY_LOGIN_ID",
         "P_CLEAR_DATE",
         "P_SUBJECT",
         "P_ADDITIONAL_INFO",
         "P_DELETED",
         "P_DELETED_DATE",
         "P_CREATE_DATE",
         "P_CREATE_BY_LOGIN_ID",
         "P_LAST_UPDATE_DATE",
         "P_UPDATE_BY_LOGIN_ID",
         ignore
      );
 
   end "GET_MLT_FOLLOWUP";
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
   ) is 
 
   begin
 
      for c1 in (
         select * from "MLT_FOLLOWUP" 
         where "FOLLOWUP_ID" = "P_FOLLOWUP_ID" 
      ) loop
         "P_TENANT_ID"          := c1."TENANT_ID";
         "P_STICK_BY_LOGIN_ID"  := c1."STICK_BY_LOGIN_ID";
         "P_STICK_DATE"         := c1."STICK_DATE";
         "P_TARGET_OBJECT_CODE" := c1."TARGET_OBJECT_CODE";
         "P_TARGET_OBJECT_ID"   := c1."TARGET_OBJECT_ID";
         "P_CLEARED"            := c1."CLEARED";
         "P_CLEAR_BY_LOGIN_ID"  := c1."CLEAR_BY_LOGIN_ID";
         "P_CLEAR_DATE"         := c1."CLEAR_DATE";
         "P_SUBJECT"            := c1."SUBJECT";
         "P_ADDITIONAL_INFO"    := c1."ADDITIONAL_INFO";
         "P_DELETED"            := c1."DELETED";
         "P_DELETED_DATE"       := c1."DELETED_DATE";
         "P_CREATE_DATE"        := c1."CREATE_DATE";
         "P_CREATE_BY_LOGIN_ID" := c1."CREATE_BY_LOGIN_ID";
         "P_LAST_UPDATE_DATE"   := c1."LAST_UPDATE_DATE";
         "P_UPDATE_BY_LOGIN_ID" := c1."UPDATE_BY_LOGIN_ID";
 
         "P_MD5" := "BUILD_MLT_FOLLOWUP_MD5"(
            c1."FOLLOWUP_ID",
            c1."TENANT_ID",
            c1."STICK_BY_LOGIN_ID",
            c1."STICK_DATE",
            c1."TARGET_OBJECT_CODE",
            c1."TARGET_OBJECT_ID",
            c1."CLEARED",
            c1."CLEAR_BY_LOGIN_ID",
            c1."CLEAR_DATE",
            c1."SUBJECT",
            c1."ADDITIONAL_INFO",
            c1."DELETED",
            c1."DELETED_DATE",
            c1."CREATE_DATE",
            c1."CREATE_BY_LOGIN_ID",
            c1."LAST_UPDATE_DATE",
            c1."UPDATE_BY_LOGIN_ID"
         );
      end loop;
 
   end "GET_MLT_FOLLOWUP";
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
   ) return varchar2 is 
 
   begin
 
      return apex_util.get_hash(apex_t_varchar2(
         "P_TENANT_ID",
         "P_STICK_BY_LOGIN_ID",
         to_char("P_STICK_DATE",'yyyymmddhh24:mi:ss'),
         "P_TARGET_OBJECT_CODE",
         "P_TARGET_OBJECT_ID",
         "P_CLEARED",
         "P_CLEAR_BY_LOGIN_ID",
         to_char("P_CLEAR_DATE",'yyyymmddhh24:mi:ss'),
         "P_SUBJECT",
         "P_ADDITIONAL_INFO",
         "P_DELETED",
         to_char("P_DELETED_DATE",'yyyymmddhh24:mi:ss'),
         to_char("P_CREATE_DATE",'yyyymmddhh24:mi:ss'),
         "P_CREATE_BY_LOGIN_ID",
         to_char("P_LAST_UPDATE_DATE",'yyyymmddhh24:mi:ss'),
         "P_UPDATE_BY_LOGIN_ID" ));
 
   end "BUILD_MLT_FOLLOWUP_MD5";
 
end "PKG_FOLLOWUP";
/

select pkg_followup.get_version() from dual;