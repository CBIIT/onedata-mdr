 alter table nci_stg_cde_creat rename column DE_CONC_VER_VR_FND to DE_CONC_VER_NR_FND;
 
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

  CREATE OR REPLACE  VIEW VW_NCI_FORM_FLAT_REP AS
  select frm.item_long_nm frm_item_long_nm, frm.item_nm frm_item_nm, frm.item_id frm_item_id, frm.ver_nr frm_ver_nr, frm.item_desc  frm_item_def,
  frmst.hdr_instr, frmst.ftr_instr,
air.p_item_id mod_item_id, air.p_item_ver_nr mod_ver_nr, frm_mod.instr MOD_INSTR,
 air.c_item_id de_item_id, air.c_item_ver_nr de_ver_nr, air.disp_ord quest_disp_ord,frm_mod.disp_ord mod_disp_ord, frm_mod.rep_no  mod_rep_no,
aim.item_nm MOD_ITEM_NM, air.instr QUEST_INSTR, air.REQ_IND  QUEST_REQ_IND, 
vv.value REP_DEFLT_VAL_ENUM, 
       rep.EDIT_IND QUEST_EDIT_IND, rep.rep_seq,
 aim.item_long_nm  mod_item_long_nm, aim.item_desc mod_item_desc,
air.nci_pub_id QUEST_ITEM_ID,air.nci_ver_nr QUEST_VER_NR,
de.CNTXT_NM_DN CDE_CNTXT_NM, de.item_nm CDE_ITEM_NM, de.cntxt_item_id CDE_CNTXT_ITEM_ID, de.cntxt_VER_NR CDE_CNTXT_VER_NR, de.REGSTR_STUS_NM_DN CDE_REGSTR_STUS_NM,
de.ADMIN_STUS_NM_DN CDE_ADMIN_STUS_NM,
air.CREAT_DT, air.CREAT_USR_ID, air.LST_UPD_USR_ID, air.FLD_DELETE, air.LST_DEL_DT, air.S2P_TRN_DT, air.LST_UPD_DT, air.item_long_nm QUEST_LONG_TXT, air.item_nm QUEST_TXT,
rep.val REP_DEFLT_VAL 
from  nci_admin_item_rel_alt_key air, admin_item aim,
admin_item frm, nci_admin_item_rel frm_mod , admin_item de, nci_quest_vv_rep rep, nci_form frmst, nci_quest_valid_value vv
where  air.rel_typ_id = 63
and aim.item_id = air.p_item_id and aim.ver_nr = air.p_item_ver_nr
and frm.item_id = frm_mod.p_item_id and frm.ver_nr = frm_mod.p_item_ver_nr and aim.item_id = frm_mod.c_item_id and aim.ver_nr = frm_mod.c_item_ver_nr
and frm.item_id = frmst.item_id and frm.ver_nr = frmst.ver_nr
and frm_mod.rel_typ_id in (61,62)
and frm.admin_item_typ_id in ( 54,55)
and air.c_item_id = de.item_id (+)
and air.c_item_ver_nr = de.ver_nr (+)
and air.NCI_PUB_ID = rep.quest_pub_id (+)
and air.nci_ver_nr = rep.quest_ver_nr (+)
and rep.DEFLT_VAL_ID = vv.nci_pub_id (+);


create table nci_dload_als_form
( hdr_id number,
als_form_nm  varchar2(255),
als_prot_nm  varchar2(255),
PV_VM_IND  number,
 CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
primary key (hdr_id));
