 CREATE OR REPLACE  VIEW VW_NCI_USR_CART AS
  SELECT AI.ITEM_ID, AI.VER_NR, AI.ITEM_LONG_NM, AI.CNTXT_NM_DN, AI.ITEM_NM, AI.REGSTR_STUS_NM_DN, AI.ADMIN_STUS_NM_DN,
  AI.ADMIN_ITEM_TYP_ID,
  DECODE(AI.ADMIN_ITEM_TYP_ID, 4, 'Data Element', 54, 'Form', 52, 'Module') ADMIN_ITEM_TYP_NM,
UC.CNTCT_SECU_ID, UC.CREAT_DT, UC.CREAT_USR_ID, UC.LST_UPD_USR_ID,
UC.FLD_DELETE, UC.LST_DEL_DT, UC.S2P_TRN_DT, UC.LST_UPD_DT, UC.GUEST_USR_NM
FROM NCI_USR_CART UC, ADMIN_ITEM AI WHERE AI.ITEM_ID = UC.ITEM_ID AND AI.VER_NR = UC.VER_NR
and admin_item_typ_id in (4,52,54,2,3);


-- Tracker
delete from obj_key where obj_key_id in (90, 108, 110, 105);
commit;
 insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'RAVE ALS CDE', 90, 'RAVE ALS CDE', 'RAVE ALS CDE');
 insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'REDCap DD Form', 109, 'REDCap DD Form', 'REDCap DD Form');
insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'REDCap DD CDE', 108, 'REDCap DD CDE', 'REDCap DD CDE');
insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'RAVE ALS Form', 110, 'RAVE ALS Form', 'RAVE ALS Form');
insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'Form Excel', 105, 'Form Excel', 'Form Excel');

commit;


alter table nci_dload_hdr modify (DLOAD_TYP_ID integer null);

update nci_dload_hdr set dload_fmt_id = 110 where dload_typ_id = 92 and dload_fmt_id = 90;
update nci_dload_hdr set dload_fmt_id = 109 where dload_typ_id = 92 and dload_fmt_id = 108;
commit;
