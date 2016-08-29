create or replace package "PKG_APPS_LOG" is
-- -------------------------------------------------------------------------
-- Function get_version()
-- -------------------------------------------------------------------------
function get_version return varchar2;

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
   );
 
--------------------------------------------------------------
-- create procedure for table "GLOB_APPS_LOG"
   procedure "INS_GLOB_APPS_LOG" (
      "P_APPS_LOG_ID"        in number,
      "P_APPS_LOG_TIMESTAMP" in timestamp,
      "P_APPS_LOG_LEVEL"     in number,
      "P_APPS_LOG_SOURCE"    in varchar2,
      "P_APPS_LOG_TEXT"      in varchar2                        default null
   );
--------------------------------------------------------------
-- update procedure for table "GLOB_APPS_LOG"
   procedure "UPD_GLOB_APPS_LOG" (
      "P_APPS_LOG_ID" in number,
      "P_APPS_LOG_TIMESTAMP" in timestamp,
      "P_APPS_LOG_LEVEL"     in number,
      "P_APPS_LOG_SOURCE"    in varchar2,
      "P_APPS_LOG_TEXT"      in varchar2                        default null,
      "P_MD5"                in varchar2                        default null
   );
--------------------------------------------------------------
-- delete procedure for table "GLOB_APPS_LOG"
   procedure "DEL_GLOB_APPS_LOG" (
      "P_APPS_LOG_ID" in number
   );
--------------------------------------------------------------
-- get procedure for table "GLOB_APPS_LOG"
   procedure "GET_GLOB_APPS_LOG" (
      "P_APPS_LOG_ID" in number,
      "P_APPS_LOG_TIMESTAMP" out timestamp,
      "P_APPS_LOG_LEVEL"     out number,
      "P_APPS_LOG_SOURCE"    out varchar2,
      "P_APPS_LOG_TEXT"      out varchar2
   );
--------------------------------------------------------------
-- get procedure for table "GLOB_APPS_LOG"
   procedure "GET_GLOB_APPS_LOG" (
      "P_APPS_LOG_ID" in number,
      "P_APPS_LOG_TIMESTAMP" out timestamp,
      "P_APPS_LOG_LEVEL"     out number,
      "P_APPS_LOG_SOURCE"    out varchar2,
      "P_APPS_LOG_TEXT"      out varchar2,
      "P_MD5"                out varchar2
   );
--------------------------------------------------------------
-- build MD5 function for table "GLOB_APPS_LOG"
   function "BUILD_GLOB_APPS_LOG_MD5" (
      "P_APPS_LOG_ID" in number,
      "P_APPS_LOG_TIMESTAMP" in timestamp,
      "P_APPS_LOG_LEVEL"     in number,
      "P_APPS_LOG_SOURCE"    in varchar2,
      "P_APPS_LOG_TEXT"      in varchar2                        default null
   ) return varchar2;
 
end "PKG_APPS_LOG";
