  CREATE OR REPLACE  VIEW VW_CSI_TREE AS
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
 --and ai.admin_stus_nm_dn not like '%RETIRED%'
 union
 select 100  LVL, csi.P_ITEM_ID P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi
 where ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null ;
 --and ai.admin_stus_nm_dn not like '%RETIRED%';

 --Tracker 1442
 insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'Legacy VD Excel', 106, 'Legacy VD Excel', 'Legacy VD Excel');
commit;
 insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'Legacy DEC Excel', 107, 'Legacy DEC Excel', 'Legacy DEC Excel');
commit;
--Tracker 1432
insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'REDCap DD', 108, 'REDCap DD', 'REDCap DD');
commit;

CREATE OR REPLACE VIEW VW_NCI_FORM_FLAT AS
  select frm.item_long_nm frm_item_long_nm, frm.item_nm frm_item_nm, frm.item_id frm_item_id, frm.ver_nr frm_ver_nr, frm.item_desc  frm_item_def,
  frmst.hdr_instr, frmst.ftr_instr,
air.p_item_id mod_item_id, air.p_item_ver_nr mod_ver_nr, frm_mod.instr MOD_INSTR,
 air.c_item_id de_item_id, air.c_item_ver_nr de_ver_nr, air.disp_ord quest_disp_ord,frm_mod.disp_ord mod_disp_ord, frm_mod.rep_no  mod_rep_no,
aim.item_nm MOD_ITEM_NM, air.instr QUEST_INSTR, air.REQ_IND  QUEST_REQ_IND, air.DEFLT_VAL QUEST_DEFLT_VAL, 
decode(DEFLT_VAL_ID, nvl(vv.nci_pub_id, 1), vv.value) QUEST_DEFLT_VAL_ENUM, 
       air.EDIT_IND QUEST_EDIT_IND,
 aim.item_long_nm  mod_item_long_nm, aim.item_desc mod_item_desc,
air.nci_pub_id QUEST_ITEM_ID,air.nci_ver_nr QUEST_VER_NR,
de.CNTXT_NM_DN CDE_CNTXT_NM, de.item_nm CDE_ITEM_NM, de.cntxt_item_id CDE_CNTXT_ITEM_ID, de.cntxt_VER_NR CDE_CNTXT_VER_NR, de.REGSTR_STUS_NM_DN CDE_REGSTR_STUS_NM,
de.ADMIN_STUS_NM_DN CDE_ADMIN_STUS_NM,
air.CREAT_DT, air.CREAT_USR_ID, air.LST_UPD_USR_ID, air.FLD_DELETE, air.LST_DEL_DT, air.S2P_TRN_DT, air.LST_UPD_DT, air.item_long_nm QUEST_LONG_TXT, air.item_nm QUEST_TXT,
vv.VM_NM, vv.VM_LNM, vv.VM_DEF, vv.VALUE VV_VALUE, vv.EDIT_IND VV_EDIT_IND, vv.SEQ_NBR VV_SEQ_NR, vv.MEAN_TXT VV_MEAN_TXT, vv.DESC_TXT VV_DESC_TXT, nvl(vv.nci_pub_id, 1) VV_ITEM_ID,
nvl(vv.nci_ver_nr, 1) VV_VER_NR, vv.INSTR VV_INSTR, vv.DISP_ORD VV_DISP_ORD
from  nci_admin_item_rel_alt_key air, admin_item aim,
admin_item frm, nci_admin_item_rel frm_mod , admin_item de, nci_quest_valid_value vv, nci_form frmst
where  air.rel_typ_id = 63
and aim.item_id = air.p_item_id and aim.ver_nr = air.p_item_ver_nr
and frm.item_id = frm_mod.p_item_id and frm.ver_nr = frm_mod.p_item_ver_nr and aim.item_id = frm_mod.c_item_id and aim.ver_nr = frm_mod.c_item_ver_nr
and frm.item_id = frmst.item_id and frm.ver_nr = frmst.ver_nr
and frm_mod.rel_typ_id in (61,62)
and frm.admin_item_typ_id in ( 54,55)
and air.c_item_id = de.item_id (+)
and air.c_item_ver_nr = de.ver_nr (+)
and air.NCI_PUB_ID = vv.q_pub_id (+)
and air.nci_ver_nr = vv.q_ver_nr (+);


-- Tracker 1434

  CREATE OR REPLACE  VIEW VW_CSI_NODE_DE_REL AS
  SELECT  ak.CREAT_DT,
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
           ak.LST_UPD_USR_ID     LST_UPD_USR_ID_X,
	   ai.admin_item_typ_id,
	   ok.obj_key_desc  ADMIN_ITEM_TYP_DESC
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, vw_obj_key_4 ok
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ai.ADMIN_ITEM_TYP_ID = ok.obj_key_id
    UNION
    SELECT distinct ai.CREAT_DT,
           ai.CREAT_USR_ID,
           ai.LST_UPD_USR_ID,
           ai.LST_UPD_DT,
           ai.S2P_TRN_DT,
           ai.LST_DEL_DT,
           ai.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           csi.CS_ITEM_ID,
           csi.CS_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           ai.CREAT_USR_ID       CREAT_USR_ID_X,
           ai.LST_UPD_USR_ID     LST_UPD_USR_ID_X,
	   	   ai.admin_item_typ_id,
	   ok.obj_key_desc  ADMIN_ITEM_TYP_DESC
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,vw_obj_key_4 ok
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ai.ADMIN_ITEM_TYP_ID = ok.obj_key_id
           AND ak.P_ITEM_ID = csi.ITEM_ID
           AND ak.P_ITEM_VER_NR = csi.VER_NR;

alter table NCI_CLSFCTN_SCHM_ITEM add (FUL_PATH varchar(12000));

   /*
  CREATE OR REPLACE  VIEW VW_NCI_CSI_NODE AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM,  ADMIN_ITEM.ITEM_DESC,
CS.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT,
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT,
ADMIN_ITEM.LST_UPD_DT, ADMIN_ITEM.NCI_IDSEQ, CSI.P_ITEM_ID, CSI.P_ITEM_VER_NR,
csi.FUL_PATH,
cs.item_id cs_item_id, cs.ver_nr cs_ver_nr , cs.item_long_nm cs_long_nm, cs.item_nm cs_item_nm, cs.item_desc cs_item_desc,
 cs.admin_stus_nm_dn cs_admin_stus_nm_dn,CS.CLSFCTN_SCHM_TYP_ID
FROM ADMIN_ITEM, NCI_CLSFCTN_SCHM_ITEM csi, vw_clsfctn_schm cs
       WHERE ADMIN_ITEM_TYP_ID = 51 and ADMIN_ITEM.ITEM_ID = CSI.ITEM_ID and ADMIN_ITEM.VER_NR = CSI.VER_NR and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
  ;
*/


  CREATE OR REPLACE  VIEW VW_NCI_CSI_NODE AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM,  ADMIN_ITEM.ITEM_DESC,
CS.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT,
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT,
ADMIN_ITEM.LST_UPD_DT, ADMIN_ITEM.NCI_IDSEQ, CSI.P_ITEM_ID, CSI.P_ITEM_VER_NR,
substr(CAST(SYS_CONNECT_BY_PATH(replace(admin_item.ITEM_NM,'|',''), ' | ') as varchar2(4000)),4) FUL_PATH,
cs.item_id cs_item_id, cs.ver_nr cs_ver_nr , cs.item_long_nm cs_long_nm, cs.item_nm cs_item_nm, cs.item_desc cs_item_desc,
 cs.admin_stus_nm_dn cs_admin_stus_nm_dn,CS.CLSFCTN_SCHM_TYP_ID
FROM ADMIN_ITEM, NCI_CLSFCTN_SCHM_ITEM csi, vw_clsfctn_schm cs
       WHERE ADMIN_ITEM_TYP_ID = 51 and ADMIN_ITEM.ITEM_ID = CSI.ITEM_ID and ADMIN_ITEM.VER_NR = CSI.VER_NR and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
   start with p_item_id is null
   CONNECT BY PRIOR csi.item_id = csi.p_item_id;



  CREATE TABLE TEMP_CSI_PATH
   (	"ITEM_ID" NUMBER NOT NULL ENABLE, 
	"VER_NR" NUMBER(4,2) NOT NULL ENABLE, 
	"FUL_PATH" VARCHAR2(16000 BYTE) COLLATE "USING_NLS_COMP"
   )  ;

   
