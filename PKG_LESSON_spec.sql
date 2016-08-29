create or replace PACKAGE  "PKG_LESSON" as 
-- =========================================================================  
-- Description  
--  This package is used to manage LESSON_REQUEST,  
--  LESSON_OFFER, etc. 
-- List of public procedures and functions  
-- =========================================================================  
-- ----------------------------------------------------------------------------- 
-- Function get_version()
-- ----------------------------------------------------------------------------- 
Function get_version return varchar2;
 
-- ------------------------------------------------------------------------- 
-- Function: get_course_id 
-- ------------------------------------------------------------------------- 
function get_course_id(pi_course_code in course.course_code%Type) return course.course_id%Type; 
 
-- ------------------------------------------------------------------------- 
-- Function: get_course_record[1] 
-- ------------------------------------------------------------------------- 
function get_course_record(pi_course_code in course.course_code%Type) 
     return course%RowType;
	 
-- ------------------------------------------------------------------------- 
-- Function: get_course_record[2] 
-- ------------------------------------------------------------------------- 
function get_course_record(pi_course_id in course.course_id%Type) 
     return course%RowType;
	 
-- ------------------------------------------------------------------------- 
-- Function: create_request 
-- Create a new request and returns the ID 
-- ------------------------------------------------------------------------- 
function create_request ( 
   pi_course_id in course.COURSE_ID%Type, 
   pi_STUDENT_ID in lesson_request.STUDENT_ID%Type, 
   pi_DATE_REQUESTED in lesson_request.DATE_REQUESTED%Type, 
   pi_START_TIME_CHAR in lesson_request.START_TIME_CHAR%Type, 
   pi_DURATION_HOURS in lesson_request.DURATION_HOURS%Type, 
   pi_END_TIME_CHAR in lesson_request.END_TIME_CHAR%type, 
   pi_RATE_RANGE_START in lesson_request.RATE_RANGE_START%Type default null, 
   pi_RATE_RANGE_END in lesson_request.RATE_RANGE_END%Type default null,
   pi_COMMENTS in lesson_request.COMMENTS%Type default null) 
return LESSON_REQUEST.LESSON_REQUEST_ID%Type; 
 
function create_request ( 
   pi_course_code in course.COURSE_CODE%Type, 
   pi_STUDENT_ID in lesson_request.STUDENT_ID%Type, 
   pi_DATE_REQUESTED in lesson_request.DATE_REQUESTED%Type, 
   pi_START_TIME_CHAR in lesson_request.START_TIME_CHAR%Type, 
   pi_DURATION_HOURS in lesson_request.DURATION_HOURS%Type, 
   pi_END_TIME_CHAR in lesson_request.END_TIME_CHAR%type, 
   pi_RATE_RANGE_START in lesson_request.RATE_RANGE_START%Type default null, 
   pi_RATE_RANGE_END in lesson_request.RATE_RANGE_END%Type default null,
   pi_COMMENTS in lesson_request.COMMENTS%Type default null) 
return LESSON_REQUEST.LESSON_REQUEST_ID%Type; 
 
-- ------------------------------------------------------------------------- 
-- Procedure: update_request 
-- ------------------------------------------------------------------------- 
procedure update_request ( 
   pi_lesson_request_id in lesson_request.LESSON_REQUEST_ID%Type, 
   pi_DATE_REQUESTED in lesson_request.DATE_REQUESTED%Type, 
   pi_START_TIME_CHAR in lesson_request.START_TIME_CHAR%Type, 
   pi_DURATION_HOURS in lesson_request.DURATION_HOURS%Type, 
   pi_END_TIME_CHAR in lesson_request.END_TIME_CHAR%type, 
   pi_RATE_RANGE_START in lesson_request.RATE_RANGE_START%Type default null, 
   pi_RATE_RANGE_END in lesson_request.RATE_RANGE_END%Type default null,
   pi_COMMENTS in lesson_request.COMMENTS%Type default null) ;

-- ------------------------------------------------------------------------- 
-- Procedure: delete_request 
-- ------------------------------------------------------------------------- 
procedure delete_request ( pi_lesson_request_id in lesson_request.LESSON_REQUEST_ID%Type);

-- ------------------------------------------------------------------------- 
-- Function: create_offer 
-- Create an offer and returns the ID 
-- ------------------------------------------------------------------------- 
function create_offer( 
   pi_LESSON_REQUEST_ID in lesson_offer.LESSON_REQUEST_ID%Type, 
   pi_EMPLOYEE_ID in lesson_offer.EMPLOYEE_ID%Type, 
   pi_RATE in lesson_offer.RATE%Type, 
   pi_NOTE in lesson_offer.NOTE%Type 
) return LESSON_OFFER.LESSON_OFFER_ID%Type; 
 
-- ------------------------------------------------------------------------- 
-- procedure decline_offer( 
-- ------------------------------------------------------------------------- 
procedure decline_offer( 
   pi_LESSON_OFFER_ID in lesson_offer.LESSON_OFFER_ID%Type, 
   pi_DECLINE_REASON_ID	in lesson_offer.DECLINE_REASON_ID%Type, 
   pi_DECLINE_COMMENT in lesson_offer.DECLINE_COMMENT%Type); 
 
-- ------------------------------------------------------------------------- 
-- procedure accept_offer( 
-- ------------------------------------------------------------------------- 
procedure accept_offer( 
   pi_LESSON_OFFER_ID in lesson_offer.LESSON_OFFER_ID%Type); 
 
-- ------------------------------------------------------------------------- 
-- Function: get_qualified_mentors 
-- ------------------------------------------------------------------------- 
function get_qualified_mentors(pi_lesson_request_id in LESSON_REQUEST.LESSON_REQUEST_ID%Type) 
return sys_refcursor; 
 
-- ------------------------------------------------------------------------- 
-- Procedure: withdraw_offer 
-- ------------------------------------------------------------------------- 
procedure withdraw_offer( 
   pi_LESSON_OFFER_ID in lesson_offer.LESSON_OFFER_ID%Type, 
   pi_LOGIN_ID in login.LOGIN_ID%Type); 
 
-- ------------------------------------------------------------------------- 
-- Procedure: cancel_request 
-- ------------------------------------------------------------------------- 
procedure cancel_request( 
  pi_LESSON_REQUEST_ID in lesson_request.LESSON_REQUEST_ID%Type, 
  pi_LOGIN_ID in login.LOGIN_ID%Type); 
 
end PKG_LESSON; 
/
