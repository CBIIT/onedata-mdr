create or replace PACKAGE nci_Ext_import AS
procedure load_MedDra;
procedure loadBiomarkerSyn;
procedure load_Subsets_old;
procedure spLoadSubset (v_data_in in clob, v_data_out out clob);
end;
/
create or replace PACKAGE BODY nci_ext_import AS

FUNCTION getWordCountGeneric (v_nm IN varchar2, v_char in varchar2) RETURN integer IS
    V_OUT   Integer;
  BEGIN
  v_out := REGEXP_COUNT( v_nm, v_Char);

    RETURN V_OUT+1;
  END;
  
  

/* Get the string in position v_idx within string v_nm */
function getWordGeneric(v_nm in varchar2, v_idx in integer, v_max in integer, v_char in varchar2) return varchar2 is
   v_word  varchar2(4000);
begin
  if (v_idx = 1 and v_idx = v_max)then
    v_word := v_nm;
  elsif  (v_idx = 1 and v_idx < v_max)then
    v_word := substr(v_nm, 1, instr(v_nm, v_char,1,1)-1);
  elsif (v_idx = v_max) then
     v_word := substr(v_nm, instr(v_nm, v_char,1,v_idx-1)+1);
  else
     v_word := substr(v_nm, instr(v_nm, v_char,1,v_idx-1)+1,instr(v_nm, v_char,1,v_idx)-instr(v_nm, v_char,1,v_idx-1));
  end if;
  return trim(upper(v_word));
end;

procedure load_subsets_old
as
v_subset varchar2(8000);
i integer;
cnt integer;
v_code varchar2(4000);
v_c_item_id number;
v_c_ver_nr number(4,2);
begin
/*
delete from NCI_CNCPT_REL where rel_typ_id = 69;
commit;
delete from onedata_ra.NCI_CNCPT_REL where rel_typ_id = 69;
commit;

insert into NCI_CNCPT_REL (P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID)
select p.item_id, p.ver_nr, c.item_id, c.ver_nr, 69
from vw_cncpt p, vw_cncpt c, SAG_LOAD_CONCEPTS_EVS s
where s.subset_terminologies is not null and s.subset_terminologies not like '%|%' 
and s.subset_terminologies = p.item_nm and s.code = c.item_long_nm;
commit;
*/
for cur in (select code, subset_terminologies from SAG_LOAD_CONCEPTS_EVS  where subset_terminologies like '%CDISC SDTM Laboratory Test Code Terminology%' ) loop
v_subset := cur.subset_terminologies;
cnt := getwordcountGeneric(v_subset,'\|');
for cur1 in (select item_id, ver_nr  from admin_item where admin_item_typ_id = 49 and item_long_nm = cur.code) loop
 v_c_item_id := cur1.item_id;
 v_c_ver_nr := cur1.ver_nr;
 for i in 1..cnt loop
v_code := getWordGeneric(v_subset, i,cnt,'|');
--raise_application_error(-20000, cur.code || ' ' || v_subset || ' ' || cnt || ' ' || v_code);
insert into NCI_CNCPT_REL (P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID, REL_CATGRY_NM)
select p.item_id, p.ver_nr, v_c_item_id, v_c_ver_nr, 69, 'Default'
from vw_cncpt p
where upper(p.item_nm)= upper(v_code);
commit;
end loop;
end loop;
end loop;

end;


procedure loadBioMarkerSyn
as
v_temp integer;
v_meddra integer;
v_ver varchar2(255);
v_obj_key integer;
v_syn_key integer;
begin

select obj_key_id into v_obj_key from obj_key where obj_key_Desc = 'Biomarker Synonym' and obj_typ_id = 11;

select obj_key_id into v_syn_key from obj_key where obj_key_Desc = 'Synonym' and obj_typ_id = 11;

for cur in (select  distinct nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat from perm_val p, nci_admin_item_ext e where val_dom_item_id = 2015675  and val_dom_ver_nr = 16
and p.nci_val_mean_item_id = e.item_id and p.nci_val_mean_ver_nr = e.ver_nr) loop
for cur2 in (select n.* from alt_nms n, admin_item ai where ai.admin_item_typ_id = 49 and ai.item_long_nm = cur.cncpt_concat and ai.item_id = n.item_id and ai.ver_nr = n.ver_nr 
and ai.currnt_ver_ind = 1 and nm_typ_id = v_syn_key) loop
select count(*) into v_temp from alt_nms where item_id = cur.nci_Val_mean_item_id and ver_nr = cur.nci_val_mean_ver_nr and NM_TYP_ID = v_obj_key 
and cntxt_item_id = 20000000024 and cntxt_ver_nr = 1 and upper(cur2.NM_DESC) = upper(nm_desc);
if (v_temp = 0) then -- insert alternate name
insert into alt_nms (item_id, ver_nr, nm_typ_id, cntxt_item_id, cntxt_ver_nr, nm_desc,lang_id)
values (cur.nci_val_mean_item_id, cur.nci_val_mean_ver_nr, v_obj_key, 20000000024,1,cur2.nm_desc,1000);
end if;
end loop;
commit;
end loop;
insert into onedata_Ra.alt_nms select * from alt_nms where nm_id not in (select nm_id from onedata_ra.alt_nms);
commit;
end;
procedure load_Meddra
as
v_cnt integer;
v_meddra integer;
v_ver varchar2(255);
begin
/*
delete from admin_item where (item_id, ver_nr) in 
(select item_id, ver_nr  from cncpt where creat_dt > sysdate - 30 and creat_usr_id = 'ONEDATA_WA' and 
evs_src_id in (Select obj_key_id from obj_key where obj_key_Desc = 'MEDDRA_CODE'));

delete from onedata_Ra.admin_item where (item_id, ver_nr) in 
(select item_id, ver_nr  from cncpt where creat_dt > sysdate - 30 and creat_usr_id = 'ONEDATA_WA' and 
evs_src_id in (Select obj_key_id from obj_key where obj_key_Desc = 'MEDDRA_CODE'));

delete from cncpt where creat_dt > sysdate - 30 and creat_usr_id = 'ONEDATA_WA' and 
evs_src_id in (Select obj_key_id from obj_key where obj_key_Desc = 'MEDDRA_CODE');


delete from onedata_Ra.cncpt where creat_dt > sysdate - 30 and creat_usr_id = 'ONEDATA_WA' and 
evs_src_id in (Select obj_key_id from obj_key where obj_key_Desc = 'MEDDRA_CODE');
*/

select obj_key_id into v_meddra from obj_key ok where ok.obj_typ_id = 23 and upper(obj_key_desc)  = 'MEDDRA_CODE';

delete from nci_cncpt_rel where p_item_id in (select item_id from cncpt where evs_src_id = v_meddra);

commit;

v_ver := '';

select param_val into v_ver from NCI_MDR_CNTRL where param_nm ='MEDDRA';

insert into admin_item (ver_nr, item_nm, item_long_nm, item_desc, regstr_stus_id, admin_stus_id, cntxt_item_id, cntxt_ver_nr, admin_item_typ_id)
select distinct 1, L1_NM, L1_CD, '1 - SOC ',9 ,75, 20000000024,1,49 from nci_stg_meddra where l1_cd not in (Select item_long_nm from admin_item where admin_item_typ_id = 49)
and L1_cd <> 'LLT';

commit;

--delete from cncpt where item_id in (select item_id from admin_item where admin_item_typ_id = 49 and creat_usr_id = 'ONEDATA_WA'
insert into admin_item (ver_nr, item_nm, item_long_nm, item_desc, regstr_stus_id, admin_stus_id, cntxt_item_id, cntxt_ver_nr, admin_item_typ_id)
select distinct 1, L2_NM, L2_CD, '2 - HLTG',9 ,75, 20000000024,1,49 from nci_stg_meddra where l2_cd not in (Select item_long_nm from admin_item where admin_item_typ_id = 49)
and L1_cd <> 'LLT';

commit;

insert into admin_item (ver_nr, item_nm, item_long_nm, item_desc, regstr_stus_id, admin_stus_id, cntxt_item_id, cntxt_ver_nr, admin_item_typ_id)
select distinct 1, L3_NM, L3_CD, '3 - HLT',9 ,75, 20000000024,1,49 from nci_stg_meddra where l3_cd not in (Select item_long_nm from admin_item where admin_item_typ_id = 49)
and L1_cd <> 'LLT';

commit;


insert into admin_item (ver_nr, item_nm, item_long_nm, item_desc, regstr_stus_id, admin_stus_id, cntxt_item_id, cntxt_ver_nr, admin_item_typ_id)
select distinct 1, L4_NM, L4_CD, '4 - PT',9 ,75, 20000000024,1,49 from nci_stg_meddra where l4_cd not in (Select item_long_nm from admin_item where admin_item_typ_id = 49)
and L1_cd <> 'LLT';

commit;


insert into admin_item (ver_nr, item_nm, item_long_nm, item_desc, regstr_stus_id, admin_stus_id, cntxt_item_id, cntxt_ver_nr, admin_item_typ_id)
select distinct 1, L4_NM, L4_CD, '5 - LLT',9 ,75, 20000000024,1,49 from nci_stg_meddra where l4_cd not in (Select item_long_nm from admin_item where admin_item_typ_id = 49)
and L1_cd = 'LLT';

commit;

insert into onedata_Ra.admin_item select * from admin_item ai where 
admin_item_typ_id = 49 and item_id not in (select item_id from onedata_Ra.admin_item where admin_item_typ_id = 49) and ai.creat_dt >= sysdate -1 and ai.creat_usr_id = 'ONEDATA_WA';
commit;

insert into cncpt (item_id, ver_nr, evs_src_id)
select item_id, ver_nr, v_meddra from admin_item ai where
 admin_item_typ_id = 49 and (item_id, ver_nr) not in (select item_id, Ver_nr from cncpt)
 and ai.creat_dt >= sysdate -1 and ai.creat_usr_id = 'ONEDATA_WA';
commit;


insert into onedata_Ra.cncpt (item_id, ver_nr, evs_src_id)
select item_id, ver_nr, v_meddra  from admin_item ai where
admin_item_typ_id = 49 and (item_id, ver_nr) not in (select item_id, ver_nr from onedata_Ra.cncpt) and ai.creat_dt >= sysdate -1 and ai.creat_usr_id = 'ONEDATA_WA';
commit;

DBMS_MVIEW.REFRESH('VW_CNCPT');

--if (v_ver <> '') then

execute immediate 'alter table admin_item disable all triggers';
--(-20000,'Inside');

update admin_item set item_desc = '1 - SOC' || '  ' || v_ver where item_desc like '1 - SOC%' and creat_usr_id = 'ONEDATA_WA' and admin_item_typ_id = 49;
update admin_item set item_desc = '4 - PT' || '  ' || v_ver where item_desc like '4 - PT%' and creat_usr_id = 'ONEDATA_WA' and admin_item_typ_id = 49;
update admin_item set item_desc = '5 - LLT' || '  ' || v_ver where item_desc like '5 - LLT%' and creat_usr_id = 'ONEDATA_WA' and admin_item_typ_id = 49;
update admin_item set item_desc = '2 - HLTG' || '  ' || v_ver where item_desc like '2 - HLTG%' and creat_usr_id = 'ONEDATA_WA' and admin_item_typ_id = 49;
update admin_item set item_desc = '3 - HLT' || '  ' || v_ver where item_desc like '3 - HLT%' and creat_usr_id = 'ONEDATA_WA' and admin_item_typ_id = 49;
commit;

execute immediate 'alter table admin_item enable all triggers';
--end if;

insert into nci_cncpt_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_Ver_nr, rel_typ_id,rel_catgry_nm )
select distinct p.item_id, p.ver_nr, c.item_id, c.Ver_nr, 74, 'Meddra - SOC - HTLG' from vw_cncpt p, vw_cncpt c, nci_stg_meddra m
where m.L1_cd = p.item_long_nm and m.l2_cd = c.item_long_nm
and m.L1_CD <> 'LLT';


commit;


insert into nci_cncpt_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_Ver_nr, rel_typ_id,rel_catgry_nm )
select distinct p.item_id, p.ver_nr, c.item_id, c.Ver_nr, 74, 'Meddra - HTLG-HTL' from vw_cncpt p, vw_cncpt c, nci_stg_meddra m
where m.L2_cd = p.item_long_nm and m.l3_cd = c.item_long_nm
and m.L1_CD <> 'LLT';

commit;

insert into nci_cncpt_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_Ver_nr, rel_typ_id,rel_catgry_nm )
select distinct p.item_id, p.ver_nr, c.item_id, c.Ver_nr, 74, 'Meddra - HTL-PT' from vw_cncpt p, vw_cncpt c, nci_stg_meddra m
where m.L3_cd = p.item_long_nm and m.l4_cd = c.item_long_nm
and m.L1_CD <> 'LLT';

commit;

insert into nci_cncpt_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_Ver_nr, rel_typ_id,rel_catgry_nm )
select distinct p.item_id, p.ver_nr, c.item_id, c.Ver_nr, 74, 'Meddra - PT-LLT' from vw_cncpt p, vw_cncpt c, nci_stg_meddra m
where m.L3_cd = p.item_long_nm and m.l4_cd = c.item_long_nm
and m.L1_CD = 'LLT';

commit;

-- For pt-llt, it is inseting a self record
delete from nci_cncpt_rel where rel_typ_id = 74 and p_item_id = c_item_id;

commit;

delete from onedata_ra.nci_cncpt_rel where rel_typ_id = 74;
commit;

insert into onedata_Ra.nci_cncpt_rel select * from nci_cncpt_rel where rel_typ_id = 74;
commit;
end;


procedure spLoadSubset  ( v_data_in IN CLOB, v_data_out OUT CLOB)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori t_row;
 v_item_id number;
v_ver_nr number(4,2);
v_cncpt_nm varchar2(4000);
v_temp integer;

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
 row_ori :=  hookInput.originalRowset.rowset(1);

 if (ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') <> 49) then
 raise_application_error(-20000,'Please choose a concept.');
 end if;
 v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
 v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
 v_cncpt_nm := ihook.getColumnValue(row_ori,'ITEM_NM');
 
 
 select count(*) into v_temp from vw_cncpt c, SAG_LOAD_CONCEPTS_EVS s
where  s.subset_terminologies like '%' || v_cncpt_nm || '%' 
and  s.code = c.item_long_nm;
--raise_application_error(-20000, v_temp || v_cncpt_nm);


delete from NCI_CNCPT_REL where rel_typ_id = 69 and p_item_id = v_item_id and p_item_ver_nr = v_ver_nr;
commit;
delete from onedata_ra.NCI_CNCPT_REL where rel_typ_id = 69 and p_item_id = v_item_id and p_item_ver_nr = v_ver_nr;
commit;

insert into NCI_CNCPT_REL (P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID)
select v_item_id, v_ver_nr, c.item_id, c.ver_nr, 69
from vw_cncpt c, SAG_LOAD_CONCEPTS_EVS s
where  s.subset_terminologies like '%' || v_cncpt_nm || '%' 
and  s.code = c.item_long_nm;
commit;

insert into onedata_Ra.nci_cncpt_rel select * from nci_cncpt_rel where p_item_id = v_item_id and p_item_ver_nr = v_ver_nr and rel_typ_id = 69;
commit;

hookoutput.message := v_temp || ' children concept relationships added.';
--for i in 1..hookinput.originalrowset.rowset.count loop
-- row_ori :=  hookInput.originalRowset.rowset(i);

--end loop;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

end;
/
