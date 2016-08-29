create or replace package body "PKG_APPS_LOG" is
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
      raise_application_error(-20001, 'PKG_APPS_LOG.get_version() - '||sqlerrm);
  End get_version;

  --------------------------------------------------------------
-- create procedure for table "GLOB_APPS_LOG"
   procedure "INS_GLOB_APPS_LOG" (
      "P_APPS_LOG_SOURCE"    in varchar2,
      "P_APPS_LOG_TEXT"      in varchar2,
      "P_APPS_LOG_LEVEL"     in number  := 9,
	  "P_P0"                 in varchar2 := null,
	  "P_P1"                 in varchar2 := null,
	  "P_P2"                 in varchar2 := null,
	  "P_P3"                 in varchar2 := null,
	  "P_P4"                 in varchar2 := null,
	  "P_P5"                 in varchar2 := null,
	  "P_P6"                 in varchar2 := null,
	  "P_P7"                 in varchar2 := null,
	  "P_P8"                 in varchar2 := null,
	  "P_P9"                 in varchar2 := null
   ) is
   l_text GLOB_APPS_LOG.APPS_LOG_TEXT%Type := "P_APPS_LOG_SOURCE"||'([PARAM])';
   l_param varchar2(2000);
   l_comma varchar2(1);
   PRAGMA Autonomous_Transaction;
   begin
    if "P_P0" is not null then l_param := l_param||l_comma||"P_P0"; l_comma := ','; end if;
    if "P_P1" is not null then l_param := l_param||l_comma||"P_P1"; l_comma := ','; end if;
    if "P_P2" is not null then l_param := l_param||l_comma||"P_P2"; l_comma := ','; end if;
    if "P_P3" is not null then l_param := l_param||l_comma||"P_P3"; l_comma := ','; end if;
    if "P_P4" is not null then l_param := l_param||l_comma||"P_P4"; l_comma := ','; end if;
    if "P_P5" is not null then l_param := l_param||l_comma||"P_P5"; l_comma := ','; end if;
    if "P_P6" is not null then l_param := l_param||l_comma||"P_P6"; l_comma := ','; end if;
    if "P_P7" is not null then l_param := l_param||l_comma||"P_P7"; l_comma := ','; end if;
    if "P_P8" is not null then l_param := l_param||l_comma||"P_P8"; l_comma := ','; end if;
    if "P_P9" is not null then l_param := l_param||l_comma||"P_P9"; l_comma := ','; end if;
	l_text := replace(l_text, '[PARAM]', l_param);
    insert into "GLOB_APPS_LOG" (
         "APPS_LOG_LEVEL",
         "APPS_LOG_SOURCE",
         "APPS_LOG_TEXT"
      ) values ( 
         "P_APPS_LOG_LEVEL",
         l_text,
         "P_APPS_LOG_TEXT"
      );
     commit;
   exception
     when others then rollback; raise;
   end "INS_GLOB_APPS_LOG";
--------------------------------------------------------------
-- create procedure for table "GLOB_APPS_LOG"
   procedure "INS_GLOB_APPS_LOG" (
      "P_APPS_LOG_ID"        in number,
      "P_APPS_LOG_TIMESTAMP" in timestamp,
      "P_APPS_LOG_LEVEL"     in number,
      "P_APPS_LOG_SOURCE"    in varchar2,
      "P_APPS_LOG_TEXT"      in varchar2                        default null
   ) is 
 
   begin
 
      insert into "GLOB_APPS_LOG" (
         "APPS_LOG_ID",
         "APPS_LOG_TIMESTAMP",
         "APPS_LOG_LEVEL",
         "APPS_LOG_SOURCE",
         "APPS_LOG_TEXT"
      ) values ( 
         "P_APPS_LOG_ID",
         "P_APPS_LOG_TIMESTAMP",
         "P_APPS_LOG_LEVEL",
         "P_APPS_LOG_SOURCE",
         "P_APPS_LOG_TEXT"
      );
 
   end "INS_GLOB_APPS_LOG";
--------------------------------------------------------------
-- update procedure for table "GLOB_APPS_LOG"
   procedure "UPD_GLOB_APPS_LOG" (
      "P_APPS_LOG_ID" in number,
      "P_APPS_LOG_TIMESTAMP" in timestamp,
      "P_APPS_LOG_LEVEL"     in number,
      "P_APPS_LOG_SOURCE"    in varchar2,
      "P_APPS_LOG_TEXT"      in varchar2                        default null,
      "P_MD5"                in varchar2                        default null
   ) is 
 
      "L_MD5" varchar2(32767) := null;
 
   begin
 
      if "P_MD5" is not null then
         for c1 in (
            select * from "GLOB_APPS_LOG" 
            where "APPS_LOG_ID" = "P_APPS_LOG_ID" FOR UPDATE
         ) loop
 
            "L_MD5" := "BUILD_GLOB_APPS_LOG_MD5"(
               c1."APPS_LOG_ID",
               c1."APPS_LOG_TIMESTAMP",
               c1."APPS_LOG_LEVEL",
               c1."APPS_LOG_SOURCE",
               c1."APPS_LOG_TEXT"
            );
 
         end loop;
 
      end if;
 
      if ("P_MD5" is null) or ("L_MD5" = "P_MD5") then 
         update "GLOB_APPS_LOG" set
            "APPS_LOG_ID"          = "P_APPS_LOG_ID",
            "APPS_LOG_TIMESTAMP"   = "P_APPS_LOG_TIMESTAMP",
            "APPS_LOG_LEVEL"       = "P_APPS_LOG_LEVEL",
            "APPS_LOG_SOURCE"      = "P_APPS_LOG_SOURCE",
            "APPS_LOG_TEXT"        = "P_APPS_LOG_TEXT"
         where "APPS_LOG_ID" = "P_APPS_LOG_ID";
      else
         raise_application_error (-20001,'Current version of data in database has changed since user initiated update process. current checksum = "'||"L_MD5"||'", item checksum = "'||"P_MD5"||'".');  
      end if;
 
   end "UPD_GLOB_APPS_LOG";
--------------------------------------------------------------
-- delete procedure for table "GLOB_APPS_LOG"
   procedure "DEL_GLOB_APPS_LOG" (
      "P_APPS_LOG_ID" in number
   ) is 
 
   begin
 
      delete from "GLOB_APPS_LOG" 
      where "APPS_LOG_ID" = "P_APPS_LOG_ID";
 
   end "DEL_GLOB_APPS_LOG";
--------------------------------------------------------------
-- get procedure for table "GLOB_APPS_LOG"
   procedure "GET_GLOB_APPS_LOG" (
      "P_APPS_LOG_ID" in number,
      "P_APPS_LOG_TIMESTAMP" out timestamp,
      "P_APPS_LOG_LEVEL"     out number,
      "P_APPS_LOG_SOURCE"    out varchar2,
      "P_APPS_LOG_TEXT"      out varchar2
   ) is 
 
      ignore varchar2(32676);
   begin
 
      "GET_GLOB_APPS_LOG" (
         "P_APPS_LOG_ID",
         "P_APPS_LOG_TIMESTAMP",
         "P_APPS_LOG_LEVEL",
         "P_APPS_LOG_SOURCE",
         "P_APPS_LOG_TEXT",
         ignore
      );
 
   end "GET_GLOB_APPS_LOG";
--------------------------------------------------------------
-- get procedure for table "GLOB_APPS_LOG"
   procedure "GET_GLOB_APPS_LOG" (
      "P_APPS_LOG_ID" in number,
      "P_APPS_LOG_TIMESTAMP" out timestamp,
      "P_APPS_LOG_LEVEL"     out number,
      "P_APPS_LOG_SOURCE"    out varchar2,
      "P_APPS_LOG_TEXT"      out varchar2,
      "P_MD5"                out varchar2
   ) is 
 
   begin
 
      for c1 in (
         select * from "GLOB_APPS_LOG" 
         where "APPS_LOG_ID" = "P_APPS_LOG_ID" 
      ) loop
         "P_APPS_LOG_TIMESTAMP" := c1."APPS_LOG_TIMESTAMP";
         "P_APPS_LOG_LEVEL"     := c1."APPS_LOG_LEVEL";
         "P_APPS_LOG_SOURCE"    := c1."APPS_LOG_SOURCE";
         "P_APPS_LOG_TEXT"      := c1."APPS_LOG_TEXT";
 
         "P_MD5" := "BUILD_GLOB_APPS_LOG_MD5"(
            c1."APPS_LOG_ID",
            c1."APPS_LOG_TIMESTAMP",
            c1."APPS_LOG_LEVEL",
            c1."APPS_LOG_SOURCE",
            c1."APPS_LOG_TEXT"
         );
      end loop;
 
   end "GET_GLOB_APPS_LOG";
--------------------------------------------------------------
-- build MD5 function for table "GLOB_APPS_LOG"
   function "BUILD_GLOB_APPS_LOG_MD5" (
      "P_APPS_LOG_ID" in number,
      "P_APPS_LOG_TIMESTAMP" in timestamp,
      "P_APPS_LOG_LEVEL"     in number,
      "P_APPS_LOG_SOURCE"    in varchar2,
      "P_APPS_LOG_TEXT"      in varchar2                        default null
   ) return varchar2 is 
 
   begin
 
      return apex_util.get_hash(apex_t_varchar2(
         to_char("P_APPS_LOG_TIMESTAMP",'yyyymmddhh24:mi:ss'),
         "P_APPS_LOG_LEVEL",
         "P_APPS_LOG_SOURCE",
         "P_APPS_LOG_TEXT" ));
 
   end "BUILD_GLOB_APPS_LOG_MD5";
 
end "PKG_APPS_LOG";
