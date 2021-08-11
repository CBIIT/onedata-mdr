
  
insert into obj_typ (obj_typ_id, obj_typ_Desc) values (35, 'Download File Format');
commit;
insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, NCI_CD) values (35, 'Excel', 110, 'Excel');
insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, NCI_CD) values (35, 'XML', 111, 'XML');
insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, NCI_CD) values (35, 'JSON', 112, 'JSON');
insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, NCI_CD) values (31, 'Form', 101, 'Form');

commit;

CREATE OR REPLACE  VIEW VW_NCI_MODULE_DE AS
  select frm.item_long_nm frm_item_long_nm, frm.item_nm frm_item_nm, frm.item_id frm_item_id, frm.ver_nr frm_ver_nr, 
air.p_item_id mod_item_id, air.p_item_ver_nr mod_ver_nr,
 air.c_item_id de_item_id, air.c_item_ver_nr de_ver_nr, air.disp_ord,
aim.item_nm MOD_ITEM_NM,
 aim.item_long_nm  mod_item_long_nm, aim.item_desc mod_item_desc,
'QUESTION' admin_item_typ_nm, air.nci_pub_id,air.nci_ver_nr, 
de.CNTXT_NM_DN, de.item_nm DE_ITEM_NM, de.cntxt_item_id DE_CNTXT_ITEM_ID, de.cntxt_VER_NR DE_CNTXT_VER_NR,
air.CREAT_DT, air.CREAT_USR_ID, air.LST_UPD_USR_ID, air.FLD_DELETE, air.LST_DEL_DT, air.S2P_TRN_DT, air.LST_UPD_DT, air.item_long_nm QUEST_LONG_TXT, air.item_nm QUEST_TXT
from  nci_admin_item_rel_alt_key air, admin_item aim,
admin_item frm, nci_admin_item_rel frm_mod , admin_item de
where  air.rel_typ_id = 63
and aim.item_id = air.p_item_id and aim.ver_nr = air.p_item_ver_nr
and frm.item_id = frm_mod.p_item_id and frm.ver_nr = frm_mod.p_item_ver_nr and aim.item_id = frm_mod.c_item_id and aim.ver_nr = frm_mod.c_item_ver_nr
and frm_mod.rel_typ_id in (61,62) 
and frm.admin_item_typ_id in ( 54,55)
and air.c_item_id = de.item_id
and air.c_item_ver_nr = de.ver_nr;



  CREATE OR REPLACE  VIEW VW_CSI_TREE ("LVL", "P_ITEM_ID", "P_ITEM_VER_NR", "ITEM_ID", "VER_NR", "ITEM_DESC", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ITEM_LONG_NM", "ITEM_NM", "ADMIN_STUS_ID", "REGSTR_STUS_ID", "REGISTRR_CNTCT_ID", "SUBMT_CNTCT_ID", "STEWRD_CNTCT_ID", "SUBMT_ORG_ID", "STEWRD_ORG_ID", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "REGSTR_AUTH_ID", "NCI_IDSEQ", "ADMIN_STUS_NM_DN", "CNTXT_NM_DN", "REGSTR_STUS_NM_DN", "ORIGIN_ID", "ORIGIN_ID_DN", "CREAT_USR_ID_X", "LST_UPD_USR_ID_X") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select 98 LVL, null P_ITEM_ID, null P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID, 
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT, 
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 8
 union 
select 99 LVL, CNTXT_ITEM_ID P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID, 
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT, 
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 9
 union
 select 100 LVL, CS_ITEM_ID P_ITEM_ID, CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID, 
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, 
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi
 where ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is null and csi.CS_ITEM_ID is not null
 union
 select 100  LVL, csi.P_ITEM_ID P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID, 
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, 
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi
 where ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null;

alter table nci_dload_hdr modify (lst_trigger_dt date default null);


create or replace view vw_stg_bulk_cntxt_upd as
select item_id cntxt_item_id, ver_nr cntxt_ver_nr, item_id to_cntxt_item_id, ver_nr to_cntxt_ver_nr,
derv_de_ind IND_ALL_TYPES, derv_de_ind  IND_TYP_1, derv_de_ind  IND_TYP_2, 
derv_de_ind  IND_TYP_3, derv_de_ind  IND_TYP_4, derv_de_ind  IND_TYP_5, derv_de_ind  IND_TYP_6, derv_de_ind  IND_TYP_7, 
derv_de_ind  IND_TYP_9, derv_de_ind  IND_TYP_49, derv_de_ind  IND_TYP_50,derv_de_ind  IND_TYP_51, derv_de_ind  IND_TYP_52,derv_de_ind  IND_TYP_54,
derv_de_ind  IND_ALT_NMS, derv_de_ind  IND_ALT_DEF, derv_de_ind  IND_REF_DOC,
 CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT
 from de;


-- Old one

  CREATE OR REPLACE VIEW VW_CLSFCTN_SCHM_ITEM AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM,  ADMIN_ITEM.ITEM_DESC,
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT,
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT,
ADMIN_ITEM.LST_UPD_DT, ADMIN_ITEM.NCI_IDSEQ, CSI.P_ITEM_ID, CSI.P_ITEM_VER_NR, CSI.CS_ITEM_ID, CSI.CS_ITEM_VER_NR
FROM ADMIN_ITEM, NCI_CLSFCTN_SCHM_ITEM csi
       WHERE ADMIN_ITEM_TYP_ID = 51 and ADMIN_ITEM.ITEM_ID = CSI.ITEM_ID and ADMIN_ITEM.VER_NR = CSI.VER_NR;

-- temporary 

create or replace view vw_clsfctn_schm_item as
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM,  ADMIN_ITEM.ITEM_DESC,
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT,
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT,
ADMIN_ITEM.LST_UPD_DT, ADMIN_ITEM.NCI_IDSEQ, CSI.P_ITEM_ID, CSI.P_ITEM_VER_NR, CSI.CS_ITEM_ID, CSI.CS_ITEM_VER_NR,   CAST(cs.item_nm || SYS_CONNECT_BY_PATH(admin_item.ITEM_NM, ' | ') as varchar2(4000)) FUL_PATH
FROM ADMIN_ITEM, NCI_CLSFCTN_SCHM_ITEM csi, vw_clsfctn_schm cs
       WHERE ADMIN_ITEM_TYP_ID = 51 and ADMIN_ITEM.ITEM_ID = CSI.ITEM_ID and ADMIN_ITEM.VER_NR = CSI.VER_NR and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
   start with p_item_id is null
   CONNECT BY PRIOR csi.item_id = csi.p_item_id;
--



  CREATE OR REPLACE  VIEW VW_CSI_ONLY_NODE_DE_REL AS
  SELECT ak.CREAT_DT,
           ak.CREAT_USR_ID,
           ak.LST_UPD_USR_ID,
           ak.LST_UPD_DT,
           ak.S2P_TRN_DT,
           ak.LST_DEL_DT,
           ak.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           ak.P_ITEM_ID,
           ak.P_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           ak.CREAT_USR_ID       CREAT_USR_ID_X,
           ak.LST_UPD_USR_ID     LST_UPD_USR_ID_X
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ai.ADMIN_ITEM_TYP_ID = 4;
           
           
           
  CREATE OR REPLACE  VIEW VW_VAL_MEAN AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM,  ADMIN_ITEM.ITEM_DESC,
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT,
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT,
ADMIN_ITEM.LST_UPD_DT, decode(ext.cncpt_concat, ext.cncpt_concat_nm, null, admin_item.item_long_nm, null, admin_item.item_id, null, ext.cncpt_concat)  cncpt_concat, ext.cncpt_concat_nm, nvl(admin_item.origin_id_dn, origin) ORIGIN_NM
FROM ADMIN_ITEM, NCI_ADMIN_ITEM_EXT ext
       WHERE ADMIN_ITEM_TYP_ID = 53 and admin_item.item_id = ext.item_id and admin_item.ver_nr = ext.ver_nr;


insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (67,17,'Module-Module Relationship ', 'Module-Module Relationship', '', 'MMR');
commit;

  CREATE OR REPLACE  VIEW VW_NCI_FORM_MODULE AS
  select air.p_item_id, air.p_item_ver_nr, ai.item_id, ai.ver_nr, ai.item_nm, ai.item_nm FORM_NM, ai.item_desc,
'MODULE' admin_item_typ_nm,air.INSTR,
ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, air.disp_ord, air.rep_no,
ai.regstr_stus_id, ai.admin_stus_id, ai.cntxt_item_id, ai.cntxt_ver_nr, ai.item_long_nm 
from admin_item ai, nci_admin_item_rel air where ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr and air.rel_typ_id in (61,62);

 CREATE OR REPLACE VIEW VW_CSI_FORM_REL AS
  SELECT ak.CREAT_DT,
           ak.CREAT_USR_ID,
           ak.LST_UPD_USR_ID,
           ak.LST_UPD_DT,
           ak.S2P_TRN_DT,
           ak.LST_DEL_DT,
           ak.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           ak.P_ITEM_ID,
           ak.P_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           ak.CREAT_USR_ID       CREAT_USR_ID_X,
           ak.LST_UPD_USR_ID     LST_UPD_USR_ID_X
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ai.ADMIN_ITEM_TYP_ID = 54;

alter table NCI_DLOAD_HDR add (FILE_FMT_ID integer);

