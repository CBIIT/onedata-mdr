alter table NCI_STG_AI_CNCPT_CREAT
 ADD ( CNCPT_INT_1_1 varchar2(255), CNCPT_INT_1_2 varchar2(255), CNCPT_INT_1_3 varchar2(255), CNCPT_INT_1_4 varchar2(255), CNCPT_INT_1_5 varchar2(255), 
 CNCPT_INT_1_6 varchar2(255), CNCPT_INT_1_7 varchar2(255), CNCPT_INT_1_8 varchar2(255), CNCPT_INT_1_9 varchar2(255), CNCPT_INT_1_10 varchar2(255), 
 CNCPT_INT_2_1 varchar2(255), CNCPT_INT_2_2 varchar2(255), CNCPT_INT_2_3 varchar2(255), CNCPT_INT_2_4 varchar2(255), CNCPT_INT_2_5 varchar2(255), 
 CNCPT_INT_2_6 varchar2(255), CNCPT_INT_2_7 varchar2(255), CNCPT_INT_2_8 varchar2(255), CNCPT_INT_2_9 varchar2(255), CNCPT_INT_2_10 varchar2(255));
 
 alter table 
 NCI_STG_PV_VM_BULK
 ADD ( CNCPT_INT_1_1 varchar2(255), CNCPT_INT_1_2 varchar2(255), CNCPT_INT_1_3 varchar2(255), CNCPT_INT_1_4 varchar2(255), CNCPT_INT_1_5 varchar2(255), 
 CNCPT_INT_1_6 varchar2(255), CNCPT_INT_1_7 varchar2(255), CNCPT_INT_1_8 varchar2(255), CNCPT_INT_1_9 varchar2(255), CNCPT_INT_1_10 varchar2(255), 
 STR_DESC_1  varchar2(4000),STR_DESC_2  varchar2(4000),STR_DESC_3  varchar2(4000),STR_DESC_4  varchar2(4000),STR_DESC_5  varchar2(4000),
     STR_DESC_6  varchar2(4000),STR_DESC_7  varchar2(4000),STR_DESC_8  varchar2(4000),STR_DESC_9  varchar2(4000),STR_DESC_10  varchar2(4000));
 
  alter table 
 NCI_STG_PV_VM_BULK
 ADD ( blank_1 char(1), blank_2 char(1), blank_3 char(1), blank_4 char(1), blank_5 char(1),
     blank_6 char(1), blank_7 char(1), blank_8 char(1), blank_9 char(1), blank_10 char(1) );
 
alter table nci_admin_item_ext add (CNCPT_CONCAT_WITH_INT varchar2(4000));

alter table nci_admin_item_rel_alt_key add (PREF_NM_MIGRATED varchar2(30));

alter table NCI_CLSFCTN_SCHM_ITEM add (DISP_ORD integer default 0);
update NCI_ADMIN_ITEM_REL set  REP_NO=NVL(REP_NO,0) where REP_NO is null;
commit;

alter  NCI_ADMIN_ITEM_REL modify (REP_NO	NUMBER  default 0 not null );



-- Current
CREATE OR REPLACE  VIEW VW_NCI_CSI_DE AS
  select  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, aim.p_item_id csi_item_id, aim.p_item_ver_nr csi_ver_nr, 
  csi.item_nm csi_ITEM_NM, csist.cs_item_id CS_ITEM_ID, csist.CS_ITEM_VER_NR CS_VER_NR, aim.rel_typ_id,
 csi.item_long_nm  csi_item_long_nm, csi.item_desc csi_item_desc, csist.p_item_Id p_CS_ITEM_ID, csist.P_ITEM_VER_NR p_CS_VER_NR,
aim.CREAT_DT, aim.CREAT_USR_ID, aim.LST_UPD_USR_ID, aim.FLD_DELETE, aim.LST_DEL_DT, aim.S2P_TRN_DT, aim.LST_UPD_DT,
 csi.item_nm || ' ' || cs.ITEM_NM CSI_SEARCH_STR, cs.ITEM_NM  CS_ITEM_NM, cs.ITEM_LONG_NM CS_ITEM_LONG_NM
from  admin_item csi, NCI_CLSFCTN_SCHM_ITEM csist, nci_admin_item_rel aim, vw_CLSFCTN_SCHM cs 
where csi.item_id = aim.p_item_id and csi.ver_nr = aim.p_item_ver_nr 
and aim.rel_typ_id = 65 
and csi.item_id = csist.item_id and csi.ver_nr = csist.ver_nr
and csist.cs_item_id = cs.item_id and csist.cs_item_ver_nr = cs.ver_nr;

/*
-- Trial
CREATE OR REPLACE  VIEW VW_NCI_CSI_DE AS
  select  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, aim.p_item_id csi_item_id, aim.p_item_ver_nr csi_ver_nr, 
  csi.item_nm csi_ITEM_NM, csist.cs_item_id CS_ITEM_ID, csist.CS_ITEM_VER_NR CS_VER_NR, aim.rel_typ_id,
 csi.item_long_nm  csi_item_long_nm, csi.item_desc csi_item_desc, csist.p_item_Id p_CS_ITEM_ID, csist.P_ITEM_VER_NR p_CS_VER_NR,
aim.CREAT_DT, aim.CREAT_USR_ID, aim.LST_UPD_USR_ID, aim.FLD_DELETE, aim.LST_DEL_DT, aim.S2P_TRN_DT, aim.LST_UPD_DT,
 csi.item_nm || ' ' || cs.ITEM_NM CSI_SEARCH_STR, cs.ITEM_NM  CS_ITEM_NM, cs.ITEM_LONG_NM CS_ITEM_LONG_NM
from  admin_item csi, NCI_CLSFCTN_SCHM_ITEM csist, nci_admin_item_rel aim, admin_item cs 
where csi.item_id = aim.p_item_id and csi.ver_nr = aim.p_item_ver_nr 
and aim.rel_typ_id = 65 
and csi.item_id = csist.item_id and csi.ver_nr = csist.ver_nr
and cs.admin_item_typ_id = 9
and csist.cs_item_id = cs.item_id and csist.cs_item_ver_nr = cs.ver_nr;
*/


alter table NCI_STG_AI_CNCPT_CREAT add (ITEM_1_LONG_NM_INT varchar2(255));

  CREATE TABLE NCI_MODULE
   (	"VER_NR" NUMBER(4,2) NOT NULL ENABLE, 
	"ITEM_ID" NUMBER NOT NULL ENABLE, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	 CONSTRAINT "PK_MODULE" PRIMARY KEY ("ITEM_ID", "VER_NR"));
 
 create or replace view vw_value_dom_comp
as
select v.*,
pv.code_name
from value_dom v,  
--(SELECT val_dom_item_id, val_dom_ver_nr, substr(LISTAGG(PERM_VAL_NM|| ':' || PERM_VAL_DESC_TXT || ':' || e.cncpt_concat_nm || ':' || e.cncpt_concat, '   ,  ') WITHIN GROUP (ORDER by PERM_VAL_DESC_TXT),1,2000) AS CODE_NAME
--(SELECT val_dom_item_id, val_dom_ver_nr, substr(LISTAGG(PERM_VAL_NM|| ':' || PERM_VAL_DESC_TXT || ':' || e.cncpt_concat, '   ,  ') WITHIN GROUP (ORDER by PERM_VAL_DESC_TXT),1,2000) AS CODE_NAME
(SELECT val_dom_item_id, val_dom_ver_nr, substr(LISTAGG(PERM_VAL_NM|| ':' ||  e.cncpt_concat_nm || ':' || e.cncpt_concat, '   ,  ') WITHIN GROUP (ORDER by PERM_VAL_DESC_TXT),1,2000) AS CODE_NAME
FROM PERM_VAL, nci_admin_item_ext e
 where perm_val.nci_val_mean_item_id = e.item_id
 and perm_val.nci_val_mean_ver_nr = e.ver_nr
GROUP BY val_dom_item_id, val_dom_ver_nr) pv
where v.item_id = pv.val_dom_item_id (+) and v.ver_nr = pv.val_dom_ver_nr (+);

CREATE OR REPLACE  VIEW VW_NCI_FORM_FLAT AS
  select frm.item_long_nm frm_item_long_nm, frm.item_nm frm_item_nm, frm.item_id frm_item_id, frm.ver_nr frm_ver_nr, frm.item_desc  frm_item_def,
  frmst.hdr_instr, frmst.ftr_instr, 
air.p_item_id mod_item_id, air.p_item_ver_nr mod_ver_nr, frm_mod.instr MOD_INSTR,
 air.c_item_id de_item_id, air.c_item_ver_nr de_ver_nr, air.disp_ord quest_disp_ord,frm_mod.disp_ord mod_disp_ord, frm_mod.rep_no  mod_rep_no,
aim.item_nm MOD_ITEM_NM, air.instr QUEST_INSTR, air.REQ_IND  QUEST_REQ_IND, air.DEFLT_VAL QUEST_DEFLT_VAL, air.EDIT_IND QUEST_EDIT_IND,
 aim.item_long_nm  mod_item_long_nm, aim.item_desc mod_item_desc,
air.nci_pub_id QUEST_ITEM_ID,air.nci_ver_nr QUEST_VER_NR,
de.CNTXT_NM_DN CDE_CNTXT_NM, de.item_nm CDE_ITEM_NM, de.cntxt_item_id CDE_CNTXT_ITEM_ID, de.cntxt_VER_NR CDE_CNTXT_VER_NR,
air.CREAT_DT, air.CREAT_USR_ID, air.LST_UPD_USR_ID, air.FLD_DELETE, air.LST_DEL_DT, air.S2P_TRN_DT, air.LST_UPD_DT, air.item_long_nm QUEST_LONG_TXT, air.item_nm QUEST_TXT,
vv.VM_NM, vv.VM_LNM, vv.VM_DEF, vv.VALUE VV_VALUE, vv.EDIT_IND VV_EDIT_IND, vv.SEQ_NBR VV_SEQ_NR, vv.MEAN_TXT VV_MEAN_TXT, vv.DESC_TXT VV_DESC_TXT, nvl(vv.nci_pub_id, 1) VV_ITEM_ID,
nvl(vv.nci_ver_nr, 1) VV_VER_NR, vv.INSTR VV_INSTR
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


alter table NCI_DLOAD_HDR add (GUEST_USR_NM varchar2(50), GUEST_USR_PWD number(6));

alter table nci_dload_hdr modify (LST_TRIGGER_DT timestamp, LST_GEN_DT timestamp);

alter table nci_dload_hdr modify (	GUEST_USR_NM varchar2(255));


