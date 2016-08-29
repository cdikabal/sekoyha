create or replace TRIGGER  "TRG_VW_LESSON_REQUEST_IO_IUD" 
INSTEAD OF INSERT or UPDATE or DELETE ON VW_LESSON_REQUEST 
DECLARE 
  -- 
  l_vw_lesson_request vw_lesson_request%RowType; 
  -- 
begin
  if (inserting) then
    l_vw_lesson_request.lesson_request_id := 
	 pkg_lesson.create_request ( 
        pi_course_id => :new.COURSE_ID, 
        pi_STUDENT_ID => :new.STUDENT_ID, 
        pi_DATE_REQUESTED => :new.DATE_REQUESTED, 
        pi_START_TIME_CHAR => :new.START_TIME_CHAR, 
        pi_DURATION_HOURS => :new.DURATION_HOURS, 
        pi_END_TIME_CHAR => :new.END_TIME_CHAR, 
        pi_RATE_RANGE_START => :new.RATE_RANGE_START, 
        pi_RATE_RANGE_END => :new.RATE_RANGE_END,
		pi_COMMENTS => :new.COMMENTS);
  elsif (updating) then
	 pkg_lesson.update_request ( 
        pi_lesson_request_id => :new.LESSON_REQUEST_ID, 
        pi_DATE_REQUESTED => :new.DATE_REQUESTED, 
        pi_START_TIME_CHAR => :new.START_TIME_CHAR, 
        pi_DURATION_HOURS => :new.DURATION_HOURS, 
        pi_END_TIME_CHAR => :new.END_TIME_CHAR, 
        pi_RATE_RANGE_START => :new.RATE_RANGE_START, 
        pi_RATE_RANGE_END => :new.RATE_RANGE_END,
		pi_COMMENTS => :new.COMMENTS);
  elsif (deleting) then
     pkg_lesson.delete_request(pi_lesson_request_id => :new.LESSON_REQUEST_ID);
  end if;
exception 
  when others then raise; 
end "TRG_VW_LESSON_REQUEST_IO_IUD";
/
