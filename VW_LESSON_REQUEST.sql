CREATE OR REPLACE FORCE VIEW "VW_LESSON_REQUEST" 
 AS 
  select 
    lreq.LESSON_REQUEST_ID,
 	lreq.STUDENT_ID,
 	lreq.COURSE_ID,
	mcou.course_code, 
	mcou.course_name,
 	lreq.REQUEST_DATE,
 	lreq.DATE_REQUESTED,
 	lreq.START_TIME_CHAR,
 	lreq.DURATION_HOURS,
 	lreq.RATE_RANGE_START,
 	lreq.RATE_RANGE_END,
 	lreq.REQUEST_STATUS_ID,
 	lreq.ACCEPTED_OFFER_ID,
 	lreq.CREATE_DATE,
 	lreq.CREATE_BY_LOGIN_ID,
 	lreq.LAST_UPDATE_DATE,
 	lreq.UPDATE_BY_LOGIN_ID,
 	lreq.END_TIME_CHAR,
 	lreq.START_TIME_DT,
 	lreq.END_TIME_DT,
 	lreq.COMMENTS,
	gres.REQUEST_STATUS_NAME,
	clog.apex_username as create_by_user,
	ulog.apex_username as update_by_user
  from lesson_request lreq
     inner join glob_request_status gres on (gres.REQUEST_STATUS_ID = lreq.REQUEST_STATUS_ID)
	 inner join course mcou on (mcou.course_id = lreq.course_id)
	 left outer join login clog on (clog.login_id = lreq.CREATE_BY_LOGIN_ID)
	 left outer join login ulog on (ulog.login_id = lreq.UPDATE_BY_LOGIN_ID)
/

select * from VW_LESSON_REQUEST
where rownum = 1
;
