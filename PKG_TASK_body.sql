create or replace PACKAGE BODY  "PKG_TASK" AS  
-- =============================================================================
-- P R I V A T E   F U N C T I O N S   A N D   P R O C E D U R E S
-- =============================================================================
Function local_get_task_template(pi_task_template_id in task_template.task_template_id%Type)
  return task_template%RowType is
  l_task_template task_template%Rowtype;
Begin
  select * into l_task_template
  from task_template t where t.task_template_id = pi_task_template_id;
  return l_task_template;
Exception
  when no_data_found then return null;
  when others then
     raise_application_error(-20001, 'local_get_task_template('||pi_task_template_id||') ## '||sqlerrm);
End local_get_task_template;
--
Function local_get_task_template(
    pi_short_name in task_template.short_name%Type,
    pi_target_object_code in task_template.target_object_code%Type)
  return task_template%RowType is
  l_task_template task_template%Rowtype;
Begin
  select * into l_task_template
    from task_template t 
   where t.short_name = pi_short_name
     and t.target_object_code = pi_target_object_code;
  return l_task_template;
Exception
  when no_data_found then return null;
  when others then
     raise_application_error(-20001, 'local_get_task_template('||pi_short_name||','||pi_target_object_code||') ## '||sqlerrm);
End local_get_task_template;
-- -----------------------------------------------------------------------------
-- Function local_get_step_record()
-- -----------------------------------------------------------------------------
Function local_get_task_step(pi_task_step_id in task_step.task_step_id%Type) return task_step%RowType is
  l_task_step task_step%Rowtype;
Begin
  select * into l_task_step
    from task_step t 
   where t.task_step_id = pi_task_step_id;
  return l_task_step;
Exception
  when no_data_found then return null;
  when others then
     raise_application_error(-20001, 'local_get_task_step('||pi_task_step_id||') ## '||sqlerrm);
End local_get_task_step;
-- -----------------------------------------------------------------------------
-- Function local_get_task()
-- -----------------------------------------------------------------------------
Function local_get_task(pi_task_id in task.task_id%Type) return task%RowType is
  l_task task%Rowtype;
Begin
  select * into l_task
    from task t 
   where t.task_id = pi_task_id;
  return l_task;
Exception
  when no_data_found then return null;
  when others then
     raise_application_error(-20001, 'local_get_task('||pi_task_id||') ## '||sqlerrm);
End local_get_task;
Function local_get_glob_action(pi_action_code in glob_action.action_code%Type) return glob_action%rowType is
  l_glob_action glob_action%RowType;
Begin
    return pkg_global.get_action_record(pi_action_code => pi_action_code );
Exception
  when no_data_found then return null;
  when others then
     raise_application_error(-20001, 'local_get_glob_action('||pi_action_code||') ## '||sqlerrm);
End local_get_glob_action;

-- =============================================================================
-- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S
-- =============================================================================
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
      raise_application_error(-20001, 'PKG_TASK.get_version() - '||sqlerrm);
  End get_version;
  
-- -----------------------------------------------------------------------------
-- function: instanciate() 
-- -----------------------------------------------------------------------------
function instanciate( 
    pi_task_template_id in task_template.task_template_id%Type,
    pi_target_object_id in task.target_object_id%Type,
    pi_target_object_name in varchar2,
    pi_field_names in VARCHAR_TABLE_TYPE,
    pi_field_values in VARCHAR_TABLE_TYPE,
    pi_login_id in login.login_id%Type default null,
    pi_max_days in number default 20,
    pi_deadline in date default null)
  return task.task_id%Type is
  --
  l_task_id task.task_id%Type;
  l_task_rec task_template%Rowtype := local_get_task_template(pi_task_template_id=>pi_task_template_id);
  l_login_id login.login_id%Type := pi_login_id;
  l_department_id employee.department_id%Type;
  l_task_step_id task_step.task_step_id%Type;
  l_task_name task.short_name%Type;
  l_total_tasks number;
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  l_task_name := l_task_rec.short_name||' < ' ||pi_target_object_name||' >';
  l_task_id := get_uncompleted_id(  
     pi_short_name => l_task_name,
     pi_target_object_code => l_task_rec.target_object_code,
     pi_target_object_id => pi_target_object_id);
  --
  if l_task_id is not null then return l_task_id; end if;
  --
  if l_login_id is null then l_login_id := pkg_login.get_login_id(p_apex_username => nvl(v('APP_USER'), 'ADMIN')); end if;
  --dbms_output.put_line('-> Login ID = '||l_login_id);
  l_department_id := pkg_employee.get_record(p_login_id => l_login_id).department_id;
  --dbms_output.put_line('-> Department ID = '||l_department_id);
  --
  Insert Into TASK(short_name, long_name, description, target_object_code, target_object_id, 
                   start_by_login_id, start_date, completed, estimate_complete_date, deadline)
  Values (l_task_name, 
          l_task_rec.short_name||' < ' ||pi_target_object_name||' >', l_task_rec.description||' < ' ||pi_target_object_name||' >', 
          l_task_rec.target_object_code, pi_target_object_id,
          l_login_id, sysdate, 'N', sysdate+(l_task_rec.estimate_hour/24),
          nvl(pi_deadline, (sysdate+nvl(pi_max_days,20))));
  --
  --dbms_output.put('-> Task created ');
  l_task_id := get_uncompleted_id(  
     pi_short_name => l_task_name,
     pi_target_object_code => l_task_rec.target_object_code,
     pi_target_object_id => pi_target_object_id);
  --dbms_output.put_line('- ID = '||l_task_id);
  --
  select count(1) into l_total_tasks from Task_Step_Template st where st.task_template_id = pi_task_template_id;
  --
  for rec in (select * from Task_Step_Template st where st.task_template_id = pi_task_template_id)
  loop
    Insert into Task_Step(short_name, long_name, description, task_id,
        start_by_login_id, start_date, started, completed, tab_order, target_page_id,
        assign_to_login_id, assign_to_department_id, estimate_complete_date)
    Values(l_task_name||' ('||rec.tab_order||'/'||l_total_tasks||')', 
      l_task_name||' ('||rec.tab_order||'/'||l_total_tasks||') - '||rec.short_name, 
      rec.description, l_task_id, 
      l_login_id, sysdate, 'Y', 'N', rec.tab_order, rec.target_page_id,
      l_login_id, l_department_id, sysdate+(rec.estimate_hour/24));
    --
    l_task_step_id := get_step_id(pi_task_id => l_task_id, pi_tab_order => rec.tab_order);
    --
    for i in pi_field_names.FIRST..pi_field_names.LAST loop
      if pi_field_names.EXISTS(i) and pi_field_values.EXISTS(i) then
        insert into task_step_field(task_step_id, field_name, field_value)
        values (l_task_step_id, pi_field_names(i), pi_field_values(i));
      end if;
    end loop;
    --
  end loop;
  --
  return l_task_id;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'instanciate(TemplateID= '||pi_task_template_id||') ## '||sqlerrm);
End instanciate;
-- -----------------------------------------------------------------------------
-- function: instanciate()
-- -----------------------------------------------------------------------------
function instanciate( 
    pi_short_name in task_template.short_name%Type,
    pi_target_object_code in task_template.target_object_code%Type,
    pi_target_object_id in task.target_object_id%Type,
    pi_target_object_name in varchar2,
    pi_field_names in VARCHAR_TABLE_TYPE,
    pi_field_values in VARCHAR_TABLE_TYPE,
    pi_login_id in login.login_id%Type default null,
    pi_max_days in number default 20,
    pi_deadline in date default null)
  return task.task_id%Type
is
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  --
  return instanciate(
    pi_task_template_id => get_task_template_id(pi_short_name=>pi_short_name, pi_target_object_code=>pi_target_object_code),
    pi_target_object_id => pi_target_object_id,
    pi_target_object_name => pi_target_object_name,
    pi_field_names        => pi_field_names,
    pi_field_values       => pi_field_values,
    pi_login_id           => pi_login_id, 
    pi_max_days           => pi_max_days,
    pi_deadline           => pi_deadline);
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'instanciate(Name= '||pi_short_name||','||pi_target_object_code||') ## '||sqlerrm);
End instanciate;
-- -----------------------------------------------------------------------------
-- function: is_step_completed()
-- -----------------------------------------------------------------------------
function is_step_completed(pi_task_step_id task_step.task_step_id%Type) return varchar2
is
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  return local_get_task_step(pi_task_step_id=>pi_task_step_id).completed;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'is_step_completed('||pi_task_step_id||') ## '||sqlerrm);
End is_step_completed;
-- -----------------------------------------------------------------------------
-- function: is_task_completed()
-- -----------------------------------------------------------------------------
function is_task_completed(pi_task_id task.task_id%Type) return varchar2  
is
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  return local_get_task(pi_task_id=>pi_task_id).completed;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'is_task_completed('||pi_task_id||') ## '||sqlerrm);
End is_task_completed;
  
-- -----------------------------------------------------------------------------
-- function get_uncompleted_id( )
-- -----------------------------------------------------------------------------
function get_uncompleted_id(  
     pi_short_name in task.short_name%Type,
     pi_target_object_code in task.target_object_code%Type,
     pi_target_object_id in task.target_object_id%Type,
     pi_login_id in login.login_id%Type default null)
     return task.task_id%Type
is
  l_task_id task.task_id%Type;
  l_login_id login.login_id%Type := pi_login_id;
  l_department_id department.department_id%Type;
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  --
  if l_login_id is null then l_login_id := pkg_login.get_login_id(p_apex_username => nvl(v('APP_USER'), 'ADMIN')); end if;
  --dbms_output.put_line('-> Login ID = '||l_login_id);
  l_department_id := pkg_employee.get_record(p_login_id => l_login_id).department_id;
  --dbms_output.put_line('-> Department ID = '||l_department_id);
  /*
  dbms_output.put_line('-> get_uncompleted_id() - Searching task for');
  dbms_output.put_line(' . Name        = '||pi_short_name);
  dbms_output.put_line(' . Object Code = '||pi_target_object_code);
  dbms_output.put_line(' . Object ID   = '||pi_target_object_id);
  */
  --
  select task_id into l_task_id
    from task t
   where t.short_name = pi_short_name
     and t.target_object_code = pi_target_object_code
     and t.target_object_id = pi_target_object_id
     and nvl(t.completed, 'N') = 'N'
     and exists (select 'x' 
                   from task_step st 
                  where st.task_id = t.task_id 
                    and (st.assign_to_login_id = l_login_id or st.assign_to_department_id = l_department_id));
  --
  --dbms_output.put_line(' ==> FOUND: '||l_task_id);
  --
  return l_task_id;
Exception
  when no_data_found then return null; 
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'get_uncompleted_id('||pi_short_name||', '||pi_target_object_code||', '||pi_target_object_id||') ## '||sqlerrm);
End get_uncompleted_id;
-- -----------------------------------------------------------------------------
-- procedure complete_step()
-- -----------------------------------------------------------------------------
procedure complete_step(
   pi_task_step_id in task_step.task_step_id%Type,
   pi_login_id in login.login_id%Type)
is
  l_task_id task.task_id%Type;
  l_counter number;
  l_department_id department.department_id%Type := pkg_employee.get_record(p_login_id => pi_login_id).department_id;
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  Update task_step set 
     completed = 'Y', 
     complete_date = sysdate, 
     complete_by_login_id = pi_login_id
  Where task_step_id = pi_task_step_id
    and (assign_to_login_id = pi_login_id or assign_to_department_id = l_department_id);
  --
  select st.task_id, sum(case when st.completed='N' then 1 else 0 end) as counter
    into l_task_id, l_counter
    from task_step st
   where st.task_id = (select x.task_id from task_step x where x.task_step_id = pi_task_step_id)
   group by st.task_id;
  --
  if l_counter = 0 then pkg_task.complete_task(pi_task_id => l_task_id, pi_login_id => pi_login_id); end if;
  --
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'complete_step('||pi_task_step_id||') ## '||sqlerrm);
End complete_step;
-- -----------------------------------------------------------------------------
-- procedure complete_task()
-- -----------------------------------------------------------------------------
procedure complete_task(
   pi_task_id in task.task_id%Type,
   pi_login_id in login.login_id%Type)
is
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  Update task set 
     completed = 'Y' ,
     complete_date = sysdate ,
     complete_by_login_id = pi_login_id
  where task_id = pi_task_id;
Exception
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'complete_task('||pi_task_id||') ## '||sqlerrm);
End complete_task;
-- -----------------------------------------------------------------------------
-- function get_step_id()
-- -----------------------------------------------------------------------------
function get_step_id(
     pi_task_id in task_step.task_id%Type,
     pi_tab_order in task_step.tab_order%Type) return task_step.task_step_id%Type
is
  l_task_step_id task_step.task_step_id%Type;
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  select st.task_step_id into l_task_step_id
    from task_step st 
  where st.task_id = pi_task_id and st.tab_order = pi_tab_order;
  return l_task_step_id;
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'get_step_id('||pi_task_id||', '||pi_tab_order||') ## '||sqlerrm);
End get_step_id;
-- -----------------------------------------------------------------------------
-- function get_task_template_id()
-- -----------------------------------------------------------------------------
function get_task_template_id(
     pi_short_name in task_template.short_name%Type,
     pi_target_object_code in task_template.target_object_code%Type)
  return task_template.task_template_id%Type
is
  l_task_template_id task_template.task_template_id%Type;
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  select tpl.task_template_id into l_task_template_id
    from task_template tpl 
  where tpl.short_name = pi_short_name
    and tpl.target_object_code = pi_target_object_code;
  return l_task_template_id;
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'get_task_template_id('||pi_short_name||', '||pi_target_object_code||') ## '||sqlerrm);
End get_task_template_id;
-- -----------------------------------------------------------------------------
-- function get_current_task_record()
-- -----------------------------------------------------------------------------
Function get_current_task_record(
    pi_short_name in task.short_name%Type, 
    pi_target_object_code in task.target_object_code%Type,
    pi_target_object_id in task.target_object_id%Type,
    pi_login_id in login.login_id%Type default null)
 return task%RowType
is
  l_task task%RowType;
  l_login_id login.login_id%Type := pi_login_id;
  l_department_id department.department_id%Type;
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  --
  if l_login_id is null then l_login_id := pkg_login.get_login_id(p_apex_username => nvl(v('APP_USER'), 'ADMIN')); end if;
  --dbms_output.put_line('-> Login ID = '||l_login_id);
  l_department_id := pkg_employee.get_record(p_login_id => l_login_id).department_id;
  --
  select * into l_task
  from
     (select * from task t
       where t.short_name = pi_short_name
         and t.target_object_code = pi_target_object_code
         and t.target_object_id = pi_target_object_id
         and exists (select 'x' from task_step x where x.task_id = t.task_id and (x.assign_to_login_id = l_login_id or x.assign_to_department_id = l_department_id))
       order by completed asc, create_date desc)
  where rownum = 1;
  return l_task;
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'get_current_task_record(1)('||pi_short_name||', '||pi_target_object_code||', '||pi_target_object_id||') ## '||sqlerrm);
End get_current_task_record;
-- -----------------------------------------------------------------------------
-- function get_current_task_record()
-- -----------------------------------------------------------------------------
Function get_current_task_record(
    pi_task_template_id in task_template.task_template_id%Type,
    pi_target_object_id in task.target_object_id%Type,
    pi_login_id in login.login_id%Type default null)
 return task%RowType
is
  l_task task%RowType;
  l_task_template task_template%RowType := local_get_task_template(pi_task_template_id => pi_task_template_id);
  l_login_id login.login_id%Type := pi_login_id;
  l_department_id department.department_id%Type;
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  --
  if l_login_id is null then l_login_id := pkg_login.get_login_id(p_apex_username => nvl(v('APP_USER'), 'ADMIN')); end if;
  l_department_id := pkg_employee.get_record(p_login_id => l_login_id).department_id;
  --
  select * into l_task
  from
     (select * from task t
       where t.short_name like l_task_template.short_name||'%'
         and t.target_object_code = l_task_template.target_object_code
         and t.target_object_id = pi_target_object_id
         and exists (select 'x' from task_step x where x.task_id = t.task_id and (x.assign_to_login_id = l_login_id or x.assign_to_department_id = l_department_id))
       order by completed asc, create_date desc)
  where rownum = 1;
  return l_task;
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'get_current_task_record(2)(pi_template_id='||pi_task_template_id||', '||pi_target_object_id||') ## '||sqlerrm);
End get_current_task_record;
-- -----------------------------------------------------------------------------
-- function get_current_task_record()
-- -----------------------------------------------------------------------------
Function get_current_task_record(
    pi_action_code in glob_action.action_code%Type,
    pi_target_object_code in task.target_object_code%Type,
    pi_target_object_id in task.target_object_id%Type,
    pi_login_id in login.login_id%Type default null)
 return task%RowType is
  l_task task%RowType;
  l_login_id login.login_id%Type := pi_login_id;
  l_department_id department.department_id%Type;
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  --
  if l_login_id is null then l_login_id := pkg_login.get_login_id(p_apex_username => nvl(v('APP_USER'), 'ADMIN')); end if;
  l_department_id := pkg_employee.get_record(p_login_id => l_login_id).department_id;
  --
  select * into l_task
  from
     (select * from task t
       where t.action_id = pkg_global.get_action_id(pi_action_code => pi_action_code)
         and t.target_object_code = pi_target_object_code
         and t.target_object_id = pi_target_object_id
         and exists (select 'x' from task_step x where x.task_id = t.task_id and (x.assign_to_login_id = l_login_id or x.assign_to_department_id = l_department_id))
       order by completed asc, create_date desc)
  where rownum = 1;
  return l_task;
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'get_current_task_record(3)(pi_action_code='||pi_action_code||', '||pi_target_object_id ||') ## '||sqlerrm);
End get_current_task_record;
-- -----------------------------------------------------------------------------
-- function get_current_step_record()
-- -----------------------------------------------------------------------------
Function get_current_step_record(
    pi_short_name in task.short_name%Type, 
    pi_target_object_code in task.target_object_code%Type,
    pi_target_object_id in task.target_object_id%Type,
    pi_target_page_id in task_step.target_page_id%Type,
    pi_login_id in login.login_id%Type default null)
 return task_step%RowType is
  l_task_step task_step%RowType;
  l_task task%RowType := get_current_task_record(pi_short_name=>pi_short_name, pi_target_object_code=>pi_target_object_code, pi_target_object_id=>pi_target_object_id);
  l_login_id login.login_id%Type := pi_login_id;
  l_department_id department.department_id%Type;
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  --
  if l_login_id is null then l_login_id := pkg_login.get_login_id(p_apex_username => nvl(v('APP_USER'), 'ADMIN')); end if;
  l_department_id := pkg_employee.get_record(p_login_id => l_login_id).department_id;
  --
  select * into l_task_step 
    from task_step t 
   where t.task_id = l_task.task_id 
    and t.target_page_id = pi_target_page_id
    and (t.assign_to_login_id = l_login_id or t.assign_to_department_id = l_department_id);
  return l_task_step;
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'get_current_step_record(1)('||pi_short_name||', '||
         pi_target_object_code||', '||pi_target_object_id||', '||pi_target_page_id||') ## '||sqlerrm);
End get_current_step_record;
-- -----------------------------------------------------------------------------
-- function get_current_step_record()
-- -----------------------------------------------------------------------------
Function get_current_step_record(
    pi_task_template_id in task_template.task_template_id%Type,
    pi_target_object_id in task.target_object_id%Type,
    pi_target_page_id in task_step.target_page_id%Type,
    pi_login_id in login.login_id%Type default null)
 return task_step%RowType is
  l_task_step task_step%RowType;
  l_task task%RowType := get_current_task_record(pi_task_template_id=>pi_task_template_id, pi_target_object_id=>pi_target_object_id);
  l_login_id login.login_id%Type := pi_login_id;
  l_department_id department.department_id%Type;
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  --
  if l_login_id is null then l_login_id := pkg_login.get_login_id(p_apex_username => nvl(v('APP_USER'), 'ADMIN')); end if;
  l_department_id := pkg_employee.get_record(p_login_id => l_login_id).department_id;
  --
  select * into l_task_step from task_step t where t.task_id = l_task.task_id and t.target_page_id = pi_target_page_id
    and (t.assign_to_login_id = l_login_id or t.assign_to_department_id = l_department_id);
  return l_task_step;
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'get_current_step_record(2)('||pi_task_template_id||', '||
         pi_target_object_id||', '||pi_target_page_id||') ## '||sqlerrm);
End get_current_step_record;
-- -----------------------------------------------------------------------------
-- function get_step_url()
-- -----------------------------------------------------------------------------
Function get_step_url(pi_task_step_id in task_step.task_step_id%Type,
    pi_field_names in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE(),
    pi_field_values in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE())
  return varchar2 is
  l_comma varchar2(1) := null;
  l_field_names varchar2(512);
  l_field_values varchar2(512);
  l_target_page_id task_step.target_page_id%Type;
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  --
  for rec in (select s.task_step_id, s.target_page_id, sf.field_name, sf.field_value
                from task_step s 
                 inner join task_step_field sf on (sf.task_step_id = s.task_step_id)
                where s.task_step_id = pi_task_step_id)
  loop
    l_field_names := l_field_names||l_comma||'P'||rtrim(ltrim(to_char(rec.target_page_id)))||'_'||rec.field_name;
    l_field_values := l_field_values||l_comma||'\'||rec.field_value||'\';
	--\\'
    l_target_page_id := rec.target_page_id;
    l_comma := ',';
  end loop;
  --
  if pi_field_names.COUNT > 0 then
    for i in pi_field_names.FIRST..pi_field_names.LAST loop
      l_field_names := l_field_names||l_comma||'P'||rtrim(ltrim(to_char(l_target_page_id)))||'_'||pi_field_names(i);
      l_field_values := l_field_values||l_comma||'\'||pi_field_values(i)||'\';
	--\\'
    end loop;
  end if;
  --
  return 'f?p='||NVL(v('APP_ID'),104)||':'||l_target_page_id||':'||v('SESSION')||':'||v('REQUEST')||':'||v('DEBUG')||'::'||
      l_field_names||':'||l_field_values||':'||v('PRINTER_FRIENDLY');
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'get_step_url('||pi_task_step_id||') ## '||sqlerrm);
End get_step_url;
-- -----------------------------------------------------------------------------
-- function get_next_step_url()
-- -----------------------------------------------------------------------------
Function get_next_step_url(pi_task_id in task_step.task_id%Type, 
    pi_tab_order in task_step.tab_order%Type,
    pi_field_names in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE(),
    pi_field_values in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE(),
    pi_login_id in login.login_id%Type default null)
  return varchar2 is
  l_task_step task_step%RowType;
  l_login_id login.login_id%Type := pi_login_id;
  l_department_id department.department_id%Type;
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  --
  if l_login_id is null then l_login_id := pkg_login.get_login_id(p_apex_username => nvl(v('APP_USER'), 'ADMIN')); end if;
  l_department_id := pkg_employee.get_record(p_login_id => l_login_id).department_id;
  --
  select * into l_task_step
  from task_step n
  where n.task_id = pi_task_id and n.tab_order = pi_tab_order+1
    and (n.assign_to_login_id = l_login_id or n.assign_to_department_id = l_department_id);
  --
  return get_step_url(pi_task_step_id => l_task_step.task_step_id, pi_field_names=>pi_field_names, pi_field_values=>pi_field_values);
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'get_next_step_url('||pi_task_id||', '||pi_tab_order||') ## '||sqlerrm);
End get_next_step_url;
-- -----------------------------------------------------------------------------
-- function get_previous_step_url()
-- -----------------------------------------------------------------------------
Function get_previous_step_url(pi_task_id in task_step.task_id%Type, 
    pi_tab_order in task_step.tab_order%Type,
    pi_field_names in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE(),
    pi_field_values in VARCHAR_TABLE_TYPE default VARCHAR_TABLE_TYPE(),
    pi_login_id in login.login_id%Type default null)
  return varchar2 is
  l_task_step task_step%RowType;
  l_login_id login.login_id%Type := pi_login_id;
  l_department_id department.department_id%Type;
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  if pi_tab_order <= 1 then return null; end if;
  --
  if l_login_id is null then l_login_id := pkg_login.get_login_id(p_apex_username => nvl(v('APP_USER'), 'ADMIN')); end if;
  l_department_id := pkg_employee.get_record(p_login_id => l_login_id).department_id;
  --
  select * into l_task_step
  from task_step n
  where n.task_id = pi_task_id and n.tab_order = pi_tab_order-1
    and (n.assign_to_login_id = l_login_id or n.assign_to_department_id = l_department_id);
  --
  return get_step_url(pi_task_step_id => l_task_step.task_step_id, pi_field_names=>pi_field_names, pi_field_values=>pi_field_values);
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'get_previous_step_url('||pi_task_id||', '||pi_tab_order||') ## '||sqlerrm);
End get_previous_step_url;
-- -----------------------------------------------------------------------------
-- function is_object_completed()
-- -----------------------------------------------------------------------------
Function is_object_completed(pi_action_code in glob_action.action_code%Type,
    pi_target_object_code in task.target_object_code%Type,
    pi_target_object_id in task.target_object_id%Type)
  return task.completed%Type is
  l_completed task.completed%Type;
  --
  Already_Caught exception;
  PRAGMA Exception_Init(Already_Caught, -20001);
Begin
  select completed into l_completed
  from
     (select * from task t
       where t.action_id = pkg_global.get_action_id(pi_action_code => pi_action_code)
         and t.target_object_code = pi_target_object_code
         and t.target_object_id = pi_target_object_id
       order by completed asc, create_date desc)
  where rownum = 1;
  return l_completed;
Exception
  when no_data_found then return null;
  when Already_Caught then raise;
  when others then
     raise_application_error(-20001, 'is_object_completed('||pi_action_code||', '||pi_target_object_code||', '||pi_target_object_id||') ## '||sqlerrm);
End is_object_completed;
        
END PKG_TASK;
/

select PKG_TASK.get_version() from dual;
