create or replace PACKAGE nci_util AS
procedure debugHook ( v_param_val in varchar2, v_data_out in clob);
procedure executeProc(v_data_in in clob, v_data_out out clob);
END;
/
create or replace PACKAGE BODY nci_util AS

procedure debugHook ( v_param_val in varchar2, v_data_out in clob)
as
v_cnt integer;
begin
for cur in (select * from nci_mdr_cntrl where upper(param_nm) = 'HOOK_DEBUG' and upper(param_val) = upper(v_param_val)) loop
insert into NCI_MDR_DEBUG (DATA_CLOB, PARAM_VAL) values (v_data_out, v_param_val);
commit;
end loop;
end;

PROCEDURE executeProc
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
 
  row_ori t_row;
  rows  t_rows;
  rowsvv t_rows;
  v_sql varchar(1000);
 
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori :=  hookInput.originalRowset.rowset(1);
  v_sql := 'begin ' || ihook.getColumnValue(row_ori,'JOB_STEP_SP') || ';  end;';
execute immediate v_sql;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;
end;
/
