create or replace package body PKG_ACCOUNT as
 
-- =========================================================================  
-- P R I V A T E   F U N C T I O N S   A N D   P R O C E D U R E S
-- =========================================================================  

-- =========================================================================  
-- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S
-- =========================================================================  
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
      raise_application_error(-20001, 'pkg_account.get_version() - '||sqlerrm);
  End get_version;

  -- -------------------------------------------------------------------------
-- Function: create_or_update[1] ()
-- -------------------------------------------------------------------------
  function create_or_update (
    pi_account_id in account.account_id%Type,
    pi_student_id in student.student_id%Type,
    pi_preferred_hourly_rate in student_account.preferred_hourly_rate%Type := null,
	pi_comments account.comments%Type := null,
    pi_par1_parent_id in parent.parent_id%Type := null,
    pi_par2_parent_id in parent.parent_id%Type := null
  )    return account.account_id%Type is
    l_account_id account.account_id%Type := pi_account_id;
	l_tenant_id glob_tenant.tenant_id%Type := pkg_tenant.get_current_id();
	l_preferred_hourly_rate student_account.preferred_hourly_rate%Type := pkg_tenant.get_property_value('Preferred Hourly Rate', pkg_tenant.get_current_id());
	l_comments account.comments%Type := pi_comments;
	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
  Begin
    -- Get the account ID by the parent
	if l_account_id is null and pi_par1_parent_id is not null then
	  l_account_id := pkg_account.get_account_by_parent(pi_parent_id=>pi_par1_parent_id, pi_student_id=>pi_student_id) ;
	end if;
	--
	-- ------------
    -- Create the account if it does not exists yet
	-- ------------
    if l_account_id is null then
	  if l_comments is null then l_comments := 'Account automatically created'; end if;
	  Insert Into MLT_account(tenant_id, deleted, COMMENTS, BALANCE)
	  Values (l_tenant_id, 'N', l_comments, 0)
	  returning account_id into l_account_id;
	  --
	  if pi_par1_parent_id is not null then 
  	    Insert into parent_account(parent_id, account_id) values (pi_par1_parent_id, l_account_id);
	  end if;
	  --
	  if pi_par2_parent_id is not null then 
  	    Insert into parent_account(parent_id, account_id) values (pi_par2_parent_id, l_account_id);
	  end if;
	else
	  update account set comments = l_comments
	   where account_id = l_account_id;
	end if;
	--
	-- -----------
	-- Set the student's preferred rate
	-- -----------
	if pi_preferred_hourly_rate is not null then l_preferred_hourly_rate := pi_preferred_hourly_rate; end if;
	--
	Merge into MLT_student_account t
	Using (select pi_student_id as student_id, l_account_id as account_id
	             , l_preferred_hourly_rate as preferred_hourly_rate, l_comments as comments from dual) s
	   on (s.student_id = t.student_id)
	When Matched Then update set t.account_id = s.account_id, t.preferred_hourly_rate = s.preferred_hourly_rate, t.comments = s.comments
	When Not Matched Then 
	  insert (tenant_id, deleted, student_id, account_id, preferred_hourly_rate, comments)
	  values (l_tenant_id, 'N', s.student_id, s.account_id, s.preferred_hourly_rate, s.comments);

    return l_account_id;
  Exception
    When ALREADY_CAUGHT then raise;
    When OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_account.create_or_update(account='||pi_account_id||', student='||pi_student_id||') - '||sqlerrm);
  End create_or_update;
  
-- -------------------------------------------------------------------------
-- Function get_account_by_parent
-- -------------------------------------------------------------------------
  function get_account_by_parent(pi_parent_id in parent.parent_id%Type, pi_student_id in student.student_id%Type) 
    return account.account_id%Type is
	--
    l_account_id account.account_id%Type;
	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
  Begin
    select ACCOUNT_ID INTO l_account_id
	from 
	  (select pstd.is_primary, pacc.account_id
	     from parent_account pacc
	          inner join parent_student pstd on (pstd.parent_id = pacc.parent_id and pstd.student_id = pi_student_id)
	    where pacc.parent_id = pi_parent_id
	    order by 1 desc)
	where rownum = 1;
    --
    return l_account_id;
  Exception
    When NO_DATA_FOUND then return null;
    When ALREADY_CAUGHT then raise;
    When OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_account.create_or_update(parent='||pi_parent_id||', student='||pi_student_id||') - '||sqlerrm);
  End get_account_by_parent;

-- -------------------------------------------------------------------------
-- Procedure update_student_account
-- -------------------------------------------------------------------------
  procedure update_student_account(
    pi_account_id in student_account.account_id%Type,
    pi_preferred_hourly_rate in student_account.preferred_hourly_rate%Type,
	pi_comments student_account.comments%Type) is
	ALREADY_CAUGHT exception;
	PRAGMA Exception_Init(ALREADY_CAUGHT, -20001);
  Begin
    update student_account sacc
	   set sacc.preferred_hourly_rate = pi_account_id, sacc.comments = pi_comments
	 where sacc.account_id = pi_account_id;
  Exception
    When NO_DATA_FOUND then null;
    When ALREADY_CAUGHT then raise;
    When OTHERS THEN 
      raise_application_error(-20001, 
       'pkg_account.update_student_account('||pi_account_id||', '||pi_preferred_hourly_rate||', '||pi_comments||') - '||sqlerrm);
  End update_student_account;
  
End PKG_ACCOUNT;
/

show error

select pkg_account.get_version() from dual;