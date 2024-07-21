create or replace PACKAGE nci_Ext_import AS
procedure load_MedDra;
procedure loadBiomarkerSyn;
procedure load_Subsets_old;
procedure spLoadSubset (v_data_in in clob, v_data_out out clob);
--procedure load_ICDO;
procedure load_ICDO_Concepts; -- not used
procedure load_ICDO_External_codes (v_ver in number);
procedure load_MT;
procedure load_Athena;
procedure load_NCIT_CUI;
procedure load_term(v_term_nm in varchar2, v_term_nm_xmap in varchar2);
procedure load_MedDra_xmap (v_ver in number);
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


procedure load_term (v_term_nm in varchar2, v_term_nm_xmap in varchar2)
AS
    
 v_evs_src_id number;
v_temp integer;

BEGIN

select obj_Key_id into v_evs_src_id from obj_key where obj_typ_id =23 and upper(obj_key_desc) like upper(v_term_nm_xmap ||'%');


if (v_term_nm_xmap = 'ICDO') then
insert into NCI_CNCPT_REL (P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID, REL_CATGRY_NM)
select distinct p.item_id, p.ver_Nr, c.item_id, c.ver_nr, 125, v_term_nm_xmap
from admin_item p,admin_item c, SAG_LOAD_NCIT_TERM i
where  i.SUBSET_CODE = p.item_long_nm and i.concept_code =c.item_long_nm and p.admin_item_typ_id = 49 and c.admin_item_typ_id = 49 and
(p.item_id, p.ver_Nr, c.item_id, c.ver_nr) not in (Select P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR from nci_cncpt_rel where rel_typ_id = 125
and rel_catgry_nm = 'ICDO');

commit;
end if;


delete from nci_admin_item_xmap where dt_src = v_term_nm_xmap;
commit;


insert into nci_admin_item_xmap (item_id, ver_nr, xmap_cd,xmap_desc, evs_src_id, evs_Src_ver_Nr, PREF_IND,DT_SRC)
select distinct c.item_id, c.ver_nr, TARGET_CODE,TARGET_TERM,v_evs_Src_id, 
TARGET_TERMINOLOGY_VERSION,1,v_term_nm_xmap from 
admin_item c, SAG_LOAD_NCIT_TERM i where c.admin_item_typ_id = 49 and i.CONCEPT_CODe = c.item_long_nm and i.Target_Terminology= v_term_nm
and ( TARGET_CODE, target_term) not in (select xmap_cd, xmap_desc
from nci_admin_item_xmap where evs_src_id = v_evs_src_id);
commit;

-- update if xmap added due to external terminology dump

for cur in (select c.item_id, c.ver_nr, x.xmap_cd, x.xmap_desc from admin_item c, SAG_LOAD_NCIT_TERM i,
nci_admin_item_xmap x where c.admin_item_typ_id = 49 and i.CONCEPT_CODe = c.item_long_nm and i.Target_Terminology= v_term_nm
and i.TARGET_CODE = x.xmap_cd and upper(i.target_term) = upper(x.xmap_desc) and x.evs_src_id = v_evs_src_id and  x.item_id =0 and dt_src = v_term_nm_xmap) loop
update nci_admin_item_xmap set item_id = cur.item_id, ver_nr = cur.ver_nr where 
item_id = 0 and ver_nr = 1 and xmap_cd = cur.xmap_cd and xmap_desc = cur.xmap_desc and evs_src_id = v_evs_src_id and dt_src = v_term_nm_xmap;


commit;
end loop;


/*update nci_admin_item_xmap x set (item_id, ver_nr) = 
(select distinct c.item_id, c.ver_nr 
 from 
admin_item c, SAG_LOAD_ICDo i where c.admin_item_typ_id = 49 and i.CONCEPT_CODe = c.item_long_nm
and i.TARGET_CODE = x.xmap_cd and upper(i.target_term) = upper(x.xmap_desc) and x.evs_src_id = v_evs_src_id and (x.item_id is null or x.item_id =0))
where (x.item_id is null or x.item_id = 0) and evs_Src_id = v_evs_src_id
and (x.xmap_cd,x.xmap_desc) in (Select target_code, target_term from sag_load_icdo);
commit;
*/
END;


procedure load_MT
AS
    
 v_evs_src_id number;
v_temp integer;

BEGIN

/*select nci_code, source, max(source_atom_code), max(source_atom_name) from sag_load_mt
group by nci_code, source) */
update sag_load_mt set pref_ind = 0;
commit;
/*
update sag_load_mt set PREF_IND = 1 where (nci_code, source)  in 
(select nci_code,  source
from sag_load_mt group by nci_code, source having count(distinct source_atom_code) = 1)
and (source_atom_code, source)  in 
(select source_atom_code,  source
from sag_load_mt group by source_atom_code, source having count(distinct nci_code) = 1);
commit;

update sag_load_mt set PREF_IND = 1 where (nci_code, source)  in 
(select nci_code,  source
from sag_load_mt group by nci_code, source having count(distinct source_atom_code) > 1)
and (source_atom_code, source)  in 
(select source_atom_code,  source
from sag_load_mt group by source_atom_code, source having count(distinct nci_code) = 1)
and pref_ind=0 
and TERM_TYP = 'PT';
commit;

update sag_load_mt set PREF_IND = 1 where (nci_code, source)  in 
(select nci_code,  source
from sag_load_mt group by nci_code, source having count(distinct source_atom_code) = 1)
and (source_atom_code, source)  in 
(select source_atom_code,  source
from sag_load_mt group by source_atom_code, source having count(distinct nci_code) > 1)
and pref_ind=0 
and TERM_TYP = 'PT';
commit;

update sag_load_mt set PREF_IND = 1 where upper(source_atom_name) = upper(nci_meta_concept_name) and (nci_code, source)  in 
(select nci_code,  source
from sag_load_mt group by nci_code, source having count(distinct source_atom_code) > 1)
and pref_ind <> 1;
commit;







update sag_load_mt set PREF_IND = 1 where  (nci_code, source)  in 
(select nci_code,  source
from sag_load_mt group by nci_code, source having count(distinct pref_ind) =1
and count(distinct source_atom_code) > 1)
and pref_ind = 0
and TERM_TYP = 'PT';
commit;
*/
update sag_load_mt set PREF_IND = 1 where  (nci_code, source)  in 
(select nci_code,  source
from sag_load_mt group by nci_code, source having count(distinct pref_ind) =1
and count(distinct source_atom_code) > 1)
and pref_ind = 0
and TERM_TYP = 'LA'
and source = 'LNC';
commit;






update sag_load_mt set PREF_IND = 1 where  (nci_code, source)  in 
(select nci_code,  source
from sag_load_mt group by nci_code, source having count(distinct pref_ind) =1
and count(distinct source_atom_code) > 1)
and pref_ind = 0
and TERM_TYP = 'LA'
and source = 'LNC';
commit;


update sag_load_mt set PREF_IND = 1 where upper(trim(replace(source_atom_name,'NOS',''))) = upper(nci_meta_concept_name) and (nci_code, source)  in 
(select nci_code,  source
from sag_load_mt group by nci_code, source having count(distinct pref_ind) =1
and count(distinct source_atom_code) > 1)
and pref_ind = 0
and TERM_TYP = 'ET';
commit;



delete from nci_admin_item_xmap where DT_SRC = 'MT';
commit;

insert into nci_admin_item_xmap (item_id, ver_nr, xmap_cd,xmap_desc, evs_src_id, evs_Src_ver_Nr,pref_ind, dt_src, term_typ)
select  c.item_id, c.ver_nr, i.SOURCE_ATOM_CODE,i.SOURCE_ATOM_NAME,o.obj_key_Id, 
max(version),max(pref_ind), 'MT', term_typ from 
admin_item c,  sag_load_mt i, obj_Key o
where c.admin_item_typ_id = 49 and i.nci_CODe = c.item_long_nm
and i.source = o.OBJ_KEY_CMNTS and o.obj_typ_id = 23
and (i.source_atom_Code, o.obj_key_id) not in (select xmap_cd,  evs_src_id from nci_admin_item_xmap)
group by c.item_id, c.ver_nr, i.SOURCE_ATOM_CODE,i.SOURCE_ATOM_NAME,o.obj_key_Id, term_typ ;
commit;

	
select obj_Key_id into v_evs_src_id from obj_key where obj_typ_id = 23 and obj_key_desc = 'NCI_META_CUI';

insert into nci_admin_item_xmap (item_id, ver_nr, xmap_cd,xmap_desc, evs_src_id, evs_Src_ver_Nr,pref_ind, dt_src, term_typ)
select  distinct c.item_id, c.ver_nr, nci_meta_cui, nci_meta_concept_name,v_evs_src_id, 1,
1, 'MT', '--' from 
admin_item c,  sag_load_mt i
where c.admin_item_typ_id = 49 and i.nci_CODe = c.item_long_nm;

commit;


-- update pref_ind
-- 1 code
update nci_admin_item_xmap set pref_ind = 1 where (xmap_cd, evs_src_id) in (select xmap_cd, evs_src_id from nci_admin_item_xmap 
group by xmap_cd, evs_src_id having count(*) =1 and count(distinct pref_ind) = 1)
and pref_ind = 0;
commit;


-- update pref_ind

update nci_admin_item_xmap set pref_ind = 1 where (xmap_cd, evs_src_id) in (select xmap_cd, evs_src_id from nci_admin_item_xmap 
group by xmap_cd, evs_src_id having count(*) >1 and count(distinct pref_ind) = 1)
and (xmap_cd, evs_src_id) in (select xmap_cd, evs_src_id from nci_admin_item_xmap where term_typ = 'PT'
group by xmap_cd, evs_src_id having count(*) =1 )
and pref_ind = 0 and term_typ='PT';
commit;

-- Set pref code for ICD0 source to 1. 
select obj_Key_id into v_evs_src_id from obj_key where obj_typ_id =23 and upper(obj_key_desc) like 'ICD-O%';
update nci_admin_item_xmap set pref_ind = 1 where evs_src_id = v_evs_src_id and pref_ind <> 1;
commit;

-- for all others set pref-ind to 2.
update nci_admin_item_xmap set pref_ind = 2 where (xmap_cd, evs_src_id) in (select xmap_cd, evs_src_id from nci_admin_item_xmap --where evs_src_id <> 2680
group by xmap_cd, evs_src_id having count(distinct pref_ind) = 1 and count(distinct item_id) > 1)
and pref_ind = 0;
commit;


END;


procedure load_NCIT_CUI
AS
    
 v_evs_src_id number;
v_temp integer;

BEGIN


	
select obj_Key_id into v_evs_src_id from obj_key where obj_typ_id = 23 and obj_key_desc = 'NCI_META_CUI';

insert into nci_admin_item_xmap (item_id, ver_nr, xmap_cd,xmap_desc, evs_src_id, evs_Src_ver_Nr,pref_ind, dt_src, term_typ)
select   c.item_id, c.ver_nr, i.target_code, i.target_term,v_evs_src_id, 1,
1, 'META CUI', '--' from 
admin_item c,  sag_load_ncit_term i
where c.admin_item_typ_id = 49 and i.concept_code = c.item_long_nm
and i.target_terminology = 'META CUI' and
(i.target_code) not in (select xmap_cd from nci_admin_item_xmap where evs_src_id = v_evs_src_id);


commit;



END;


procedure load_ICDO_Concepts -- not used
AS
    
 v_evs_src_id number;
v_temp integer;

BEGIN

select obj_Key_id into v_evs_src_id from obj_key where obj_typ_id =23 and upper(obj_key_desc) like 'ICD-O%';


insert into ADMIN_ITEM (ADMIN_ITEM_TYP_ID, ITEM_NM, ITEM_LONG_NM, CNTXT_ITEM_ID, CNTXT_VER_NR, admin_stus_id, regstr_stus_id, admin_stus_nm_dn, regstr_stus_nm_dn, cntxt_nm_dn,DEF_SRC)
select 49, LBL_TOPIC, CODE, 20000000024, 1, 75, 2, 'RELEASED', 'STANDARD', 'NCIP', 'ICDO Morphology' from  SAG_LOAD_ICDo_raw 
where src_file = 'MORPHOLOGY' and code not in ( select item_long_nm from admin_item where admin_item_typ_id = 49) and
lvl_struct = 'title';
commit;
insert into ADMIN_ITEM (ADMIN_ITEM_TYP_ID, ITEM_NM, ITEM_LONG_NM, CNTXT_ITEM_ID, CNTXT_VER_NR, admin_stus_id, regstr_stus_id, admin_stus_nm_dn, regstr_stus_nm_dn, cntxt_nm_dn,DEF_SRC)
select 49, LBL_TOPIC, CODE, 20000000024, 1, 75, 2, 'RELEASED', 'STANDARD', 'NCIP', 'ICDO Topology' from  SAG_LOAD_ICDo_raw 
where src_file = 'TOPOLOGY' and code not in ( select item_long_nm from admin_item where admin_item_typ_id = 49) and
lvl_struct = '4';
commit;

insert into cncpt (item_id, ver_nr, evs_src_id) select item_id, ver_nr, v_evs_src_id from admin_item where admin_item_typ_id = 49 and 
(item_id, ver_nr) not in (select item_id, ver_nr from cncpt) and def_src like 'ICDO%';
commit;

insert into onedata_Ra.admin_item 
select * from admin_item where admin_item_typ_id = 49 and (item_id, ver_nr) not in (select item_id, ver_nr from onedata_ra.admin_item);
commit;

insert into onedata_Ra.cncpt 
select * from cncpt where  (item_id, ver_nr) not in (select item_id, ver_nr from onedata_ra.cncpt);
commit;

END;
procedure load_ICDO_External_Codes  (v_ver in number)-- Load external codes into xmap with a concept of 0.
AS
    
 v_evs_src_id number;
v_temp integer;

BEGIN

select obj_Key_id into v_evs_src_id from obj_key where obj_typ_id =23 and upper(obj_key_desc) like 'ICD-O%';


delete from nci_admin_item_xmap where dt_src = 'ICDO_EXT_RAW';
commit;

insert into nci_admin_item_xmap (item_id, ver_nr, xmap_cd,xmap_desc, evs_src_id, evs_Src_ver_Nr, PREF_IND,DT_SRC)
select distinct 0,1, code,LBL_TOPIC, v_evs_Src_id, 
v_ver,1,'ICDO_EXT_RAW' from 
 SAG_LOAD_ICDo_raw i where 
(code) not in (select  xmap_cd
from nci_admin_item_xmap where evs_src_id = v_evs_src_id)
and lvl_struct not in ('incl','sub');
commit;

END;


procedure load_meddra_xmap  (v_ver in number)-- Load external codes into xmap with a concept of 0.
AS
    
 v_evs_src_id number;
v_temp integer;


BEGIN

select obj_Key_id into v_evs_src_id from obj_key where obj_typ_id =23 and upper(obj_key_desc) like 'MEDDRA%';



delete from nci_admin_item_xmap where dt_src = 'MEDDRA_RAW';
commit;

insert into nci_admin_item_xmap (item_id, ver_nr, xmap_cd,xmap_desc, evs_src_id, evs_Src_ver_Nr, PREF_IND,DT_SRC, TERM_TYP)
select distinct 0,1,L1_CD,  L1_NM,  v_evs_Src_id, 
v_ver,1,'MEDDRA_RAW' ,'1 - SOC' from 
 nci_stg_meddra i where 
(L1_CD, L1_NM) not in (select  xmap_cd, xmap_desc
from nci_admin_item_xmap where evs_src_id = v_evs_src_id)
and l1_nm is not null;
commit;



insert into nci_admin_item_xmap (item_id, ver_nr, xmap_cd,xmap_desc, evs_src_id, evs_Src_ver_Nr, PREF_IND,DT_SRC, TERM_TYP)
select distinct 0,1,L2_CD,  L2_NM,  v_evs_Src_id, 
v_ver,1,'MEDDRA_RAW' , '2 - HLTG' from 
 nci_stg_meddra i where 
(L2_CD, L2_NM) not in (select  xmap_cd, xmap_desc
from nci_admin_item_xmap where evs_src_id = v_evs_src_id)
and l2_nm is not null;
commit;


insert into nci_admin_item_xmap (item_id, ver_nr, xmap_cd,xmap_desc, evs_src_id, evs_Src_ver_Nr, PREF_IND,DT_SRC, TERM_TYP)
select distinct 0,1,L3_CD,  L3_NM,  v_evs_Src_id, 
v_ver,1,'MEDDRA_RAW','3 - HLT' from 
 nci_stg_meddra i where 
(L3_CD, L3_NM) not in (select  xmap_cd, xmap_desc
from nci_admin_item_xmap where evs_src_id = v_evs_src_id)
and l3_nm is not null;
commit;

insert into nci_admin_item_xmap (item_id, ver_nr, xmap_cd,xmap_desc, evs_src_id, evs_Src_ver_Nr, PREF_IND,DT_SRC,TERM_TYP)
select distinct 0,1,L4_CD,  L4_NM,  v_evs_Src_id, 
v_ver,1,'MEDDRA_RAW' , '4 - PT' from 
 nci_stg_meddra i where 
(L4_CD, L4_NM) not in (select  xmap_cd, xmap_desc
from nci_admin_item_xmap where evs_src_id = v_evs_src_id)
and l4_nm is not null and  L1_cd <> 'LLT';
commit;

insert into nci_admin_item_xmap (item_id, ver_nr, xmap_cd,xmap_desc, evs_src_id, evs_Src_ver_Nr, PREF_IND,DT_SRC,TERM_TYP)
select distinct 0,1,L4_CD,  L4_NM,  v_evs_Src_id, 
v_ver,1,'MEDDRA_RAW','5 - LLT' from 
 nci_stg_meddra i where 
(L4_CD, L4_NM) not in (select  xmap_cd, xmap_desc
from nci_admin_item_xmap where evs_src_id = v_evs_src_id)
and l4_nm is not null and L1_cd = 'LLT';
commit;
END;

procedure load_Athena
AS
    
 v_evs_src_id number;
v_temp integer;
v_snomed_src_id integer;

BEGIN

select obj_Key_id into v_evs_src_id from obj_key where obj_typ_id =23 and upper(obj_key_desc) like 'OMOP%';

select obj_Key_id into v_snomed_src_id from obj_key where obj_typ_id =23 and upper(obj_key_desc) like 'SNOMED%';


delete from nci_admin_item_xmap where dt_src = 'ATHENA';
commit;

-- OMOP to SNOMED to EVS
insert into nci_admin_item_xmap (item_id, ver_nr, xmap_cd,xmap_desc, evs_src_id, evs_Src_ver_Nr, PREF_IND,DT_SRC)
select distinct snomed.item_id,snomed.ver_nr, a.concept_id,a.concept_name, v_evs_Src_id, 
1,1,'ATHENA' from 
 ATHENA_CONCEPT a, nci_admin_item_xmap snomed where 
snomed.evs_Src_id = v_snomed_src_id and snomed.xmap_cd = a.concept_code and a.standard_concept = 'S' and a.vocabulary_id = 'SNOMED'
and nvl(snomed.pref_ind,0) = 1;
commit;

END;
end;
/
