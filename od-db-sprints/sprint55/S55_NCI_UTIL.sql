create or replace PACKAGE nci_util AS
procedure debugHook ( v_param_val in varchar2, v_data_out in clob);
procedure executeProc(v_data_in in clob, v_data_out out clob);
procedure renameContext (v_src_Nm varchar2, v_tgt_Nm varchar2);
procedure postProdUpdate;
procedure reset_seq(p_seq_name in varchar2, p_val in number default 0);
procedure createGenName;
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



procedure createGenName 
as
v_diff number;
begin

execute immediate 'alter table admin_item disable all triggers';
-- Value domain name

update admin_item set item_nm_curated = (select rt.item_nm || '/Non-enum/' || dt.dttype_nm || 
decode(VAL_DOM_MAX_CHAR,null,'','/Max Len:' ||VAL_DOM_MAX_CHAR  ) || decode(VAL_DOM_MIN_CHAR,null,'','/Min Len:' ||VAL_DOM_MIN_CHAR ) ||
decode(VAL_DOM_HIGH_VAL_NUM,null,'','/Max Val:' ||VAL_DOM_HIGH_VAL_NUM  ) || decode(VAL_DOM_LOW_VAL_NUM,null,'','/Min Val:' ||VAL_DOM_LOW_VAL_NUM  )
from admin_item rt, data_typ dt, value_dom vd where vd.REP_CLS_ITEM_ID= rt.item_id and vd.REP_CLS_VER_NR = rt.ver_Nr and 
vd.NCI_STD_DTTYPE_ID = dt.DTTYPE_ID and vd.val_dom_typ_id = 18 and vd.item_id = admin_item.item_id and vd.ver_nr = admin_item.ver_nr)
where (admin_item.item_id,admin_item.ver_nr) in (Select item_id, ver_nr from value_dom where val_dom_typ_id = 18);
commit;

update admin_item set item_nm_curated = (select substr(rt.item_nm || '/Enum/' || dt.dttype_nm || 
decode(VAL_DOM_MAX_CHAR,null,'','/Max Len:' ||VAL_DOM_MAX_CHAR) || decode(VAL_DOM_MIN_CHAR,null,'','/Min Len: ' ||VAL_DOM_MIN_CHAR ) ||
decode(VAL_DOM_HIGH_VAL_NUM,null,'','/Max Val:' ||VAL_DOM_HIGH_VAL_NUM) || decode(VAL_DOM_LOW_VAL_NUM,null,'','/Min Val:' ||VAL_DOM_LOW_VAL_NUM  )
|| ' (' || nvl(pv.pv_cnt,0) || ' Values)',1,255)
from admin_item rt, data_typ dt, value_dom vd,
(select val_dom_item_id, val_dom_ver_nr, count(*) pv_cnt from perm_val where nvl(fld_delete,0) = 0 group by val_dom_item_id, val_dom_ver_nr) pv where vd.REP_CLS_ITEM_ID= rt.item_id and vd.REP_CLS_VER_NR = rt.ver_Nr and 
vd.NCI_STD_DTTYPE_ID = dt.DTTYPE_ID and vd.val_dom_typ_id = 17 and vd.item_id = admin_item.item_id and vd.ver_nr = admin_item.ver_nr and
vd.item_id = pv.val_dom_item_id (+) and vd.ver_nr = pv.val_dom_ver_nr (+))
where (admin_item.item_id,admin_item.ver_nr) in (Select item_id, ver_nr from value_dom where val_dom_typ_id = 17);
commit;

-- Enum by reference

update admin_item set item_nm_curated = (select substr('Enum by Ref/' || r.item_nm || ' ' || o.obj_key_desc,1,255)
from vw_cncpt r, value_dom vd,obj_key o where vd.TERM_CNCPT_ITEM_ID= r.item_id and vd.TERM_CNCPT_VER_NR = r.ver_Nr and 
 vd.val_dom_typ_id = 16 and vd.item_id = admin_item.item_id and vd.ver_nr = admin_item.ver_nr 
 and vd.term_use_typ = o.obj_key_id)
where (admin_item.item_id,admin_item.ver_nr) in (Select item_id, ver_nr from value_dom where val_dom_typ_id = 16);
commit;

execute immediate 'alter table admin_item enable all triggers';


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


procedure reset_seq( p_seq_name in varchar2, p_val in number default 0)
is
  l_current number := 0;
  l_difference number := 0;
  l_minvalue user_sequences.min_value%type := 0;

begin

  select min_value
  into l_minvalue
  from user_sequences
  where sequence_name = p_seq_name;

  execute immediate
  'select ' || p_seq_name || '.nextval from dual' INTO l_current;

  if p_Val < l_minvalue then
    l_difference := l_minvalue - l_current;
  else
    l_difference := p_Val - l_current;
  end if;

  if l_difference = 0 then
    return;
  end if;

  execute immediate
    'alter sequence ' || p_seq_name || ' increment by ' || l_difference || 
       ' minvalue ' || l_minvalue;

  execute immediate
    'select ' || p_seq_name || '.nextval from dual' INTO l_difference;

  execute immediate
    'alter sequence ' || p_seq_name || ' increment by 1 minvalue ' || l_minvalue;
end;


end;
/
