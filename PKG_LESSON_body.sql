create or replace PACKAGE BODY  "PKG_LESSON" as
-- ========================================================================= 
-- P U B L I C   M E T H O D S   I M P L E M E N T A T I O N
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
      raise_application_error(-20001, 'PKG_LESSON.get_version() - '||sqlerrm);
  End get_version;
  
-- ------------------------------------------------------------------------- 
-- Function: get_course_id 
-- ------------------------------------------------------------------------- 
  function get_course_id(pi_course_code in course.course_code%Type) 
  return course.course_id%Type is
     l_course_id course.course_id%Type;
     ALREADY_CAUGHT exception;
     PRAGMA exception_init(ALREADY_CAUGHT, -20001);
  begin
   select mcou.course_id into l_course_id
     from course mcou
	where mcou.COURSE_CODE = pi_course_code;
   return l_course_id;
  exception
    when no_data_found then return null;
    when ALREADY_CAUGHT then raise;
    when others then
     raise_application_error(-20001, 'PKG_LESSON.get_course_id('||pi_course_code||') - '||sqlerrm);
  end get_course_id;

-- ------------------------------------------------------------------------- 
-- Function: get_course_record[1] 
-- ------------------------------------------------------------------------- 
  function get_course_record(pi_course_code in course.course_code%Type) 
     return course%RowType is
     l_course_record course%RowType;
     ALREADY_CAUGHT exception;
     PRAGMA exception_init(ALREADY_CAUGHT, -20001);
  begin
   select mcou.* into l_course_record
     from course mcou
	where mcou.COURSE_CODE = pi_course_code;
   return l_course_record;
  exception
    when no_data_found then return null;
    when ALREADY_CAUGHT then raise;
    when others then
     raise_application_error(-20001, 'PKG_LESSON.get_course_record[1]('||pi_course_code||') - '||sqlerrm);
  end get_course_record;

-- ------------------------------------------------------------------------- 
-- Function: get_course_record[2] 
-- ------------------------------------------------------------------------- 
  function get_course_record(pi_course_id in course.course_id%Type) 
     return course%RowType is
     l_course_record course%RowType;
     ALREADY_CAUGHT exception;
     PRAGMA exception_init(ALREADY_CAUGHT, -20001);
  begin
   select mcou.* into l_course_record
     from course mcou
	where mcou.COURSE_ID = pi_course_id;
   return l_course_record;
  exception
    when no_data_found then return null;
    when ALREADY_CAUGHT then raise;
    when others then
     raise_application_error(-20001, 'PKG_LESSON.get_course_record[2]('||pi_course_id||') - '||sqlerrm);
  end get_course_record;

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
   return LESSON_REQUEST.LESSON_REQUEST_ID%Type is
   --
   l_lesson_request_id LESSON_REQUEST.LESSON_REQUEST_ID%Type;
   l_current_login_id login.login_id%Type := pkg_login.get_login_id(p_apex_username => v('APP_USER'));
   l_status_pending GLOB_REQUEST_STATUS.REQUEST_STATUS_ID%Type := 374;
   l_END_TIME_CHAR lesson_request.END_TIME_CHAR%Type :=
      to_char(to_date(pi_START_TIME_CHAR, 'hh24:mi') + (pi_DURATION_HOURS/24), 'hh24:mi');
   --
   ALREADY_CAUGHT exception;
   PRAGMA exception_init(ALREADY_CAUGHT, -20001);
  begin
   --
   Insert into MLT_LESSON_REQUEST
      (LESSON_REQUEST_ID, STUDENT_ID, COURSE_ID, DATE_REQUESTED
      , START_TIME_CHAR, START_TIME_DT, DURATION_HOURS, END_TIME_CHAR, END_TIME_DT
	  , RATE_RANGE_START, RATE_RANGE_END, REQUEST_DATE, REQUEST_STATUS_ID, COMMENTS
	  , DELETED, DELETED_DATE, TENANT_ID
	  , CREATE_DATE, CREATE_BY_LOGIN_ID, LAST_UPDATE_DATE, UPDATE_BY_LOGIN_ID)
   Values 
      (1, pi_STUDENT_ID, pi_course_id, pi_DATE_REQUESTED
      , pi_START_TIME_CHAR, to_date(to_char(pi_DATE_REQUESTED,'dd-mon-yyyy')||' '||pi_START_TIME_CHAR, 'dd-mon-yyyy hh24:mi:ss')
	  , pi_DURATION_HOURS, l_END_TIME_CHAR
	  , to_date(to_char(pi_DATE_REQUESTED,'dd-mon-yyyy')||' '||l_END_TIME_CHAR, 'dd-mon-yyyy hh24:mi:ss')
	  , pi_RATE_RANGE_START, pi_RATE_RANGE_END, sysdate, l_status_pending, pi_COMMENTS
	  , 'N', null, pkg_tenant.get_current_id()
	  , sysdate, l_current_login_id, sysdate, l_current_login_id)
   returning LESSON_REQUEST_ID into l_lesson_request_id;
   --
   return l_lesson_request_id;
  exception
   when ALREADY_CAUGHT then raise;
   when others then
     raise_application_error(-20001, 'PKG_LESSON.create_request(course_id='||pi_course_id||') - '||sqlerrm);
  end create_request;

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
  return LESSON_REQUEST.LESSON_REQUEST_ID%Type is
    ALREADY_CAUGHT exception;
    PRAGMA exception_init(ALREADY_CAUGHT, -20001);
  begin
    return create_request (
       pi_course_id       => get_course_id(pi_course_code => pi_course_code), 
       pi_STUDENT_ID      => pi_STUDENT_ID, 
       pi_DATE_REQUESTED  => pi_DATE_REQUESTED, 
       pi_START_TIME_CHAR => pi_START_TIME_CHAR, 
       pi_DURATION_HOURS  => pi_DURATION_HOURS, 
       pi_END_TIME_CHAR   => pi_END_TIME_CHAR, 
       pi_RATE_RANGE_START => pi_RATE_RANGE_START, 
       pi_RATE_RANGE_END   => pi_RATE_RANGE_END,
       pi_COMMENTS         => pi_COMMENTS);
  exception
    when ALREADY_CAUGHT then raise;
    when others then
     raise_application_error(-20001, 'PKG_LESSON.create_request[2](course_code='||pi_course_code||') - '||sqlerrm);
  end create_request;
  
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
     pi_COMMENTS in lesson_request.COMMENTS%Type default null) is
	--
    l_current_login_id login.login_id%Type := pkg_login.get_login_id(p_apex_username => v('APP_USER'));
    ALREADY_CAUGHT exception;
    PRAGMA exception_init(ALREADY_CAUGHT, -20001);
  Begin 
    Update MLT_lesson_request 
	   set DATE_REQUESTED   = pi_DATE_REQUESTED
	     , START_TIME_CHAR  = pi_START_TIME_CHAR
		 , END_TIME_CHAR    = pi_END_TIME_CHAR
		 , DURATION_HOURS   = pi_DURATION_HOURS
		 , RATE_RANGE_START = pi_RATE_RANGE_START
		 , RATE_RANGE_END   = pi_RATE_RANGE_END
		 , COMMENTS         = pi_COMMENTS
		 , UPDATE_BY_LOGIN_ID = l_current_login_id
		 , LAST_UPDATE_DATE   = sysdate
	 Where LESSON_REQUEST_ID  = pi_LESSON_REQUEST_ID;
  Exception
    when ALREADY_CAUGHT then raise;
    when others then
     raise_application_error(-20001, 'PKG_LESSON.update_request('||pi_LESSON_REQUEST_ID||') - '||sqlerrm);
  End update_request;

-- ------------------------------------------------------------------------- 
-- Procedure: delete_request 
-- ------------------------------------------------------------------------- 
  procedure delete_request ( pi_lesson_request_id in lesson_request.LESSON_REQUEST_ID%Type) is
    ALREADY_CAUGHT exception;
    PRAGMA exception_init(ALREADY_CAUGHT, -20001);
  Begin
    Delete lesson_request
	 Where lesson_request_id = pi_lesson_request_id;
  Exception
    when ALREADY_CAUGHT then raise;
    when others then
     raise_application_error(-20001, 'PKG_LESSON.delete_request(lesson_code='||pi_lesson_request_id||') - '||sqlerrm);
  End delete_request;

-- -------------------------------------------------------------------------
-- Function: create_offer
-- Create an offer and returns the ID
-- -------------------------------------------------------------------------
  function create_offer(
   pi_LESSON_REQUEST_ID in lesson_offer.LESSON_REQUEST_ID%Type,
   pi_EMPLOYEE_ID in lesson_offer.EMPLOYEE_ID%Type,
   pi_RATE in lesson_offer.RATE%Type,
   pi_NOTE in lesson_offer.NOTE%Type)
  return LESSON_OFFER.LESSON_OFFER_ID%Type is
    ALREADY_CAUGHT exception;
    PRAGMA exception_init(ALREADY_CAUGHT, -20001);
  begin
    return null;
  exception
   when ALREADY_CAUGHT then raise;
   when others then
     raise_application_error(-20001, 'PKG_LESSON.create_offer(request#='||pi_LESSON_REQUEST_ID||') - '||sqlerrm);
  end create_offer;
-- -------------------------------------------------------------------------
-- procedure decline_offer(
-- -------------------------------------------------------------------------
procedure decline_offer(
   pi_LESSON_OFFER_ID in lesson_offer.LESSON_OFFER_ID%Type,
   pi_DECLINE_REASON_ID	in lesson_offer.DECLINE_REASON_ID%Type,
   pi_DECLINE_COMMENT in lesson_offer.DECLINE_COMMENT%Type)
is
   ALREADY_CAUGHT exception;
   PRAGMA exception_init(ALREADY_CAUGHT, -20001);
begin
   null;
exception
   when ALREADY_CAUGHT then raise;
   when others then
     raise_application_error(-20001, 'PKG_LESSON.decline_offer(offer#='||pi_LESSON_OFFER_ID||') - '||sqlerrm);
end decline_offer;
-- -------------------------------------------------------------------------
-- procedure accept_offer(
-- -------------------------------------------------------------------------
procedure accept_offer(
   pi_LESSON_OFFER_ID in lesson_offer.LESSON_OFFER_ID%Type)
is
   ALREADY_CAUGHT exception;
   PRAGMA exception_init(ALREADY_CAUGHT, -20001);
begin
   null;
exception
   when ALREADY_CAUGHT then raise;
   when others then
     raise_application_error(-20001, 'PKG_LESSON.accept_offer(offer#='||pi_LESSON_OFFER_ID||') - '||sqlerrm);
end accept_offer;
-- -------------------------------------------------------------------------
-- function get_qualified_mentors
-- -------------------------------------------------------------------------
function get_qualified_mentors(pi_lesson_request_id in LESSON_REQUEST.LESSON_REQUEST_ID%Type)
return sys_refcursor is
   ALREADY_CAUGHT exception;
   PRAGMA exception_init(ALREADY_CAUGHT, -20001);
begin
   return null;
exception
   when ALREADY_CAUGHT then raise;
   when others then
     raise_application_error(-20001, 'PKG_LESSON.get_qualified_mentors(request#='||pi_lesson_request_id||') - '||sqlerrm);
end get_qualified_mentors;
-- -------------------------------------------------------------------------
-- procedure withdraw_offer(
-- -------------------------------------------------------------------------
procedure withdraw_offer(
   pi_LESSON_OFFER_ID in lesson_offer.LESSON_OFFER_ID%Type,
   pi_LOGIN_ID in login.LOGIN_ID%Type)
is
   ALREADY_CAUGHT exception;
   PRAGMA exception_init(ALREADY_CAUGHT, -20001);
begin
   null;
exception
   when ALREADY_CAUGHT then raise;
   when others then
     raise_application_error(-20001, 'PKG_LESSON.withdraw_offer(offer#='||pi_LESSON_OFFER_ID||') - '||sqlerrm);
end withdraw_offer;
-- -------------------------------------------------------------------------
-- procedure cancel_request(
-- -------------------------------------------------------------------------
procedure cancel_request(
  pi_LESSON_REQUEST_ID in lesson_request.LESSON_REQUEST_ID%Type,
  pi_LOGIN_ID in login.LOGIN_ID%Type) is
   ALREADY_CAUGHT exception;
   PRAGMA exception_init(ALREADY_CAUGHT, -20001);
begin
   null;
exception
   when ALREADY_CAUGHT then raise;
   when others then
     raise_application_error(-20001, 'PKG_LESSON.cancel_request(request#='||pi_LESSON_REQUEST_ID||') - '||sqlerrm);
end cancel_request;

end PKG_LESSON;
/

select PKG_LESSON.get_version() from dual;