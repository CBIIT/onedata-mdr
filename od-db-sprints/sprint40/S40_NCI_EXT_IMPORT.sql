create or replace PACKAGE nci_Ext_import AS
procedure load_MedDra;
END;
/
create or replace PACKAGE BODY nci_ext_import AS

procedure load_Meddra
as
v_cnt integer;
begin

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

delete from nci_cncpt_rel where rel_typ_id = 74;

delete from onedata_Ra.nci_cncpt_rel where rel_typ_id = 74;

commit;

insert into admin_item (ver_nr, item_nm, item_long_nm, item_desc, regstr_stus_id, admin_stus_id, cntxt_item_id, cntxt_ver_nr, admin_item_typ_id)
select distinct 1, L1_NM, L1_CD, '1 - SOC',9 ,75, 20000000024,1,49 from nci_stg_meddra where l1_cd not in (Select item_long_nm from admin_item where admin_item_typ_id = 49)
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
admin_item_typ_id = 49 and ai.creat_dt >= sysdate -1 and ai.creat_usr_id = 'ONEDATA_WA';
commit;

insert into cncpt (item_id, ver_nr, evs_src_id)
select item_id, ver_nr, ok.obj_key_id from admin_item ai,  obj_key ok where ok.obj_typ_id = 23 and upper(obj_key_desc)  = 'MEDDRA_CODE'
and admin_item_typ_id = 49 and ai.creat_dt >= sysdate -1 and ai.creat_usr_id = 'ONEDATA_WA';
commit;


insert into onedata_Ra.cncpt (item_id, ver_nr, evs_src_id)
select item_id, ver_nr, ok.obj_key_id from admin_item ai,  obj_key ok where ok.obj_typ_id = 23 and upper(obj_key_desc)  = 'MEDDRA_CODE'
and admin_item_typ_id = 49 and ai.creat_dt >= sysdate -1 and ai.creat_usr_id = 'ONEDATA_WA';
commit;

DBMS_MVIEW.REFRESH('VW_CNCPT');

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

insert into onedata_Ra.nci_cncpt_rel select * from nci_cncpt_rel where rel_typ_id = 74;
commit;
end;
end;
/
