create or replace package PKG_ACCOUNT as
 
-- =========================================================================  
-- Description  
--  This package is used to manage ACCOUNT entity  
-- =========================================================================  

-- =========================================================================  
-- P U B L I C   F U N C T I O N S   A N D   P R O C E D U R E S
-- =========================================================================  
-- -------------------------------------------------------------------------
-- Function get_version()
-- -------------------------------------------------------------------------
function get_version return varchar2;

-- -------------------------------------------------------------------------
-- Function create_or_update ()
-- -------------------------------------------------------------------------
function create_or_update (
    pi_account_id in account.account_id%Type,
    pi_student_id in student.student_id%Type,
    pi_preferred_hourly_rate in student_account.preferred_hourly_rate%Type := null,
	pi_comments account.comments%Type := null,
    pi_par1_parent_id in parent.parent_id%Type := null,
    pi_par2_parent_id in parent.parent_id%Type := null
)    return account.account_id%Type;
 
-- -------------------------------------------------------------------------
-- Function get_account_by_parent
-- -------------------------------------------------------------------------
function get_account_by_parent(pi_parent_id in parent.parent_id%Type, pi_student_id in student.student_id%Type) 
  return account.account_id%Type;

-- -------------------------------------------------------------------------
-- Procedure update_student_account
-- -------------------------------------------------------------------------
procedure update_student_account(
    pi_account_id in student_account.account_id%Type,
    pi_preferred_hourly_rate in student_account.preferred_hourly_rate%Type,
	pi_comments student_account.comments%Type);

end PKG_ACCOUNT;
/

show error
