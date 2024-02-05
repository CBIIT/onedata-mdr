create or replace PACKAGE nci_util AS
procedure debugHook ( v_param_val in varchar2, v_data_out in clob);
procedure executeProc(v_data_in in clob, v_data_out out clob);
procedure renameContext (v_src_Nm varchar2, v_tgt_Nm varchar2);
procedure postProdUpdate;
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



procedure postProdUpdate 
as
v_cur_max_id number;
v_cur_seq_id number;
v_diff number;
begin
-- Data Audit sequence
select max(da_id) + 1 into v_cur_max_id from nci_data_audt;
select NCI_SEQ_DATA_AUDT.nextval into v_cur_seq_id from dual;

v_diff := v_cur_max_id - v_cur_seq_id + 10;

--raise_Application_error(-20000,v_diff);


execute immediate 'alter sequence nci_seq_data_audt increment by ' || v_diff ;
select NCI_SEQ_DATA_AUDT.nextval into v_cur_seq_id from dual;

execute immediate 'alter sequence nci_seq_data_audt increment by 1' ;

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


PROCEDURE renameContext
  (v_src_Nm varchar2, v_tgt_Nm varchar2)
AS
 v_temp integer;
 v_item_id number;
 v_ver_nr number(4,2);
BEGIN
 


select count(*) into v_temp from admin_item where  admin_item_typ_id = 8 and upper(item_nm) = upper(v_src_nm);
if (v_temp= 1) then

execute immediate 'alter table admin_item disable all triggers';

execute immediate 'alter table alt_nms  disable all triggers';
select item_id, ver_nr into v_item_id, v_ver_nr from admin_item where admin_item_typ_id = 8 and upper(item_nm) = upper(v_src_nm);


update admin_item set cntxt_nm_dn = v_tgt_nm where cntxt_item_id = v_item_id and cntxt_ver_nr = v_ver_nr;
commit;
update alt_nms set cntxt_nm_dn = v_tgt_nm where cntxt_item_id = v_item_id and cntxt_ver_nr = v_ver_nr;
commit;
DBMS_MVIEW.REFRESH('VW_CNTXT');


execute immediate 'alter table admin_item enable all triggers';

execute immediate 'alter table alt_nms enable all triggers';


update admin_item set item_nm = v_tgt_nm, item_long_nm = v_tgt_nm where item_id = v_item_id and ver_nr = v_ver_nr;
commit;
end if;
execute immediate 'alter table admin_item enable all triggers';

execute immediate 'alter table alt_nms enable all triggers';

end;

end;
/
