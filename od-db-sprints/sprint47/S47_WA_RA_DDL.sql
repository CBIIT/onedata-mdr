
  CREATE OR REPLACE VIEW VW_CSI_TREE AS
  select 98 LVL, null P_ITEM_ID, null P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X , 0 CS_TYP_ID, 0 CSI_TYP_ID, 0 COMB_TYP_ID from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 8
 union
select 99 LVL, ai.CNTXT_ITEM_ID P_ITEM_ID, ai.CNTXT_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  ai.CREAT_USR_ID CREAT_USR_ID_X, ai.LST_UPD_USR_ID LST_UPD_USR_ID_X, 
 CLSFCTN_SCHM_TYP_ID CS_TYP_ID, 0 CSI_TYP_ID, CLSFCTN_SCHM_TYP_ID COMB_TYP_ID from ADMIN_ITEM ai, CLSFCTN_SCHM cs
 where ai.admin_item_typ_id = 9 and ai.item_id = cs.item_id and ai.ver_nr = cs.ver_nr
 union
 select 100 LVL, CS_ITEM_ID P_ITEM_ID, CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X , 0 CS_TYP_ID, CSI_TYP_ID CSI_TYP_ID, CSI_TYP_ID COMB_TYP_ID from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi
 where ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is null and csi.CS_ITEM_ID is not null 
 --and ai.admin_stus_nm_dn not like '%RETIRED%'
 union
 select 100  LVL, csi.P_ITEM_ID P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X, 0 CS_TYP_ID, CSI_TYP_ID CSI_TYP_ID, CSI_TYP_ID COMB_TYP_ID from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi
 where ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null;


drop materialized view MVW_CSI_TREE_CDE;

  CREATE MATERIALIZED VIEW MVW_CSI_TREE_CDE
  AS select 98 LVL, null P_ITEM_ID, null P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ITEM_LONG_NM,  
  ITEM_NM || ' (' || ITEM_DESC  || ') (' || nvl(y.cnt,'0') || ')'  ITEM_NM , ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=104\&type=csi\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=103\&type=csi\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES,
    0 TYP_ID
from 
ADMIN_ITEM ai, (select x.p_item_id, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='Context' group by x.p_item_id , 
x.p_item_ver_nr) y , nci_mdr_cntrl c
 where ADMIN_ITEM_TYP_ID = 8 and item_id = y.p_item_id (+) and ver_nr = y.p_item_ver_nr (+) and upper(cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 union
select 99 LVL, CNTXT_ITEM_ID P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ai.ITEM_ID,ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, 
ITEM_NM || ' (' || nvl(y.cnt,'0') || ')', ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES,
      cs.CLSFCTN_SCHM_TYP_ID
 from 
ADMIN_ITEM ai, clsfctn_schm cs,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CS' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c
 where ADMIN_ITEM_TYP_ID = 9 and ai.item_id =cs.item_id and ai.ver_nr = cs.ver_nr and  ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and admin_stus_nm_dn ='RELEASED' and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 union
  select 100 LVL, csi.CS_ITEM_ID P_ITEM_ID, csi.CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' , 
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
 c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********'  CHNG_NOTES,
    csi.csi_typ_id
from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CSI' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 --and ai.admin_stus_nm_dn not like '%RETIRED%'
 union
 select 100 LVL, csi.P_ITEM_ID P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' , 
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\\Legacy_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\\Legacy_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES,
    csi.CSI_TYP_ID
 from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CSI' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST';

alter table NCI_STG_FORM_QUEST_IMPORT add SRC_MOD_INSTR varchar2(4000);


 CREATE TABLE NCI_STG_MDL
   (	"MDL_IMP_ID" NUMBER NOT NULL ENABLE, 
	"SRC_MDL_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"SRC_MDL_VER" number(4,2) , 
	"CTL_VAL_STUS" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP", 
	"CTL_VAL_MSG" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"SRC_MDL_TYP" varchar2(255),
	 SRC_PRMRY_LANG varchar2(255),
	 MDL_TYP_ID  integer,
	 PRMRY_MDL_LANG_ID  integer,
		"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE)  DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE)  DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"BTCH_USR_NM" VARCHAR2(100 BYTE)  NOT NULL , 
	"BTCH_NM" VARCHAR2(100 BYTE)  NOT NULL, 
	"SRC_MDL_DESC" VARCHAR2(4000 BYTE)  NOT NULL, 
	"CREATED_MDL_ITEM_ID" NUMBER, 
	"DT_SORT" TIMESTAMP (2) DEFAULT sysdate, 
	 PRIMARY KEY ("MDL_IMP_ID"));


  CREATE TABLE "NCI_STG_MDL_ELMNT_REL" 
   (	"MDL_IMP_ID" NUMBER NOT NULL ENABLE, 
	"PRNT_MDL_ELMNT_LONG_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"CHLD_MDL_ELMNT_LONG_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"CTL_VAL_STUS" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP", 
	"CTL_VAL_MSG" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
		"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"DT_SORT" TIMESTAMP (2) DEFAULT sysdate, 
	SEQ_NBR integer,
	 PRIMARY KEY ("MDL_IMP_ID", PRNT_MDL_ELMNT_LONG_NM,CHLD_MDL_ELMNT_LONG_NM));


insert into obj_key ( OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (77, 'Is Referenced By',42,'Is Referenced By','Is Referenced By','Is Referenced By' );
commit;


  CREATE OR REPLACE  VIEW VW_DE_CONC_FOR_COMP  AS
  SELECT DE_CONC.LST_UPD_DT, DE_CONC.S2P_TRN_DT, DE_CONC.LST_DEL_DT, DE_CONC.FLD_DELETE, DE_CONC.LST_UPD_USR_ID, DE_CONC.CREAT_USR_ID, DE_CONC.CREAT_DT, 
DE_CONC.OBJ_CLS_VER_NR, DE_CONC.OBJ_CLS_ITEM_ID, DE_CONC.PROP_ITEM_ID, DE_CONC.PROP_VER_NR, DE_CONC.CONC_DOM_ITEM_ID, DE_CONC.CONC_DOM_VER_NR, 
ADMIN_ITEM.ITEM_ID, CD.ITEM_NM  CONC_DOM_ITEM_NM,
ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, 
ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CNTXT_ITEM_ID, ADMIN_ITEM.CNTXT_VER_NR, ADMIN_ITEM.ADMIN_NOTES,
 ADMIN_ITEM.CHNG_DESC_TXT, ADMIN_ITEM.CREATION_DT, ADMIN_ITEM.EFF_DT, ADMIN_ITEM.DATA_ID_STR, ADMIN_ITEM.ADMIN_ITEM_TYP_ID, 
ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_ID, ADMIN_ITEM.ADMIN_STUS_ID, admin_item.ADMIN_STUS_NM_DN, admin_item.REGSTR_STUS_NM_DN, admin_item.CNTXT_NM_DN, de.CNT_DE
FROM ADMIN_ITEM, DE_CONC, VW_CONC_DOM cd,
	  (Select de_conc_item_id, de_conc_ver_nr, count(*) CNT_DE from admin_item ai, de where ai.admin_item_typ_id = 4 and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr 
	  and upper(ai.admin_stus_nm_dn) not like '%RETIRED%' group by de_conc_item_id, de_conc_ver_nr)  de
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID=2 
AND ADMIN_ITEM.ITEM_ID = DE_CONC.ITEM_ID
AND ADMIN_ITEM.VER_NR = DE_CONC.VER_NR
	  and DE_CONC.CONC_DOM_ITEM_ID = CD.ITEM_ID and DE_CONC.CONC_DOM_VER_NR = cd.ver_nr
	  and admin_item.item_id = de.de_conc_item_id and admin_item.ver_nr = de.de_Conc_ver_nr;


alter table admin_item disable all triggers;

update admin_item set regstr_stus_nm_dn = (select s.stus_nm from vw_regstr_stus s where admin_item.regstr_stus_id = s.stus_id);
	
commit;

alter table admin_item enable all triggers;


  CREATE OR REPLACE  VIEW VW_VALUE_DOM AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN,  ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
		      ADMIN_ITEM.CURRNT_VER_IND, VALUE_DOM.DTTYPE_ID, VALUE_DOM.VAL_DOM_MAX_CHAR, VALUE_DOM.CONC_DOM_VER_NR, VALUE_DOM.CONC_DOM_ITEM_ID, 
VALUE_DOM.NON_ENUM_VAL_DOM_DESC, VALUE_DOM.UOM_ID, VALUE_DOM.VAL_DOM_TYP_ID, VALUE_DOM.VAL_DOM_MIN_CHAR, VALUE_DOM.VAL_DOM_FMT_ID, 
VALUE_DOM.CHAR_SET_ID, VALUE_DOM.CREAT_DT, VALUE_DOM.CREAT_USR_ID, VALUE_DOM.LST_UPD_USR_ID, 
VALUE_DOM.FLD_DELETE, VALUE_DOM.LST_DEL_DT, VALUE_DOM.S2P_TRN_DT, VALUE_DOM.LST_UPD_DT , RC.ITEM_NM  REP_TERM_ITEM_NM,
	  value_dom.NCI_STD_DTTYPE_ID
FROM ADMIN_ITEM, VALUE_DOM, VW_REP_CLS RC
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 3
AND ADMIN_ITEM.ITEM_ID = VALUE_DOM.ITEM_ID
AND ADMIN_ITEM.VER_NR=VALUE_DOM.VER_NR and
VALUE_DOM.REP_CLS_ITEM_ID = RC.ITEM_ID (+) and 
VALUE_DOM.REP_CLS_VER_NR = RC.VER_NR (+);

alter table nci_ds_hdr add (stus_fltr_id integer, stus_fltr_nm varchar2(4000));

  CREATE TABLE NCI_STG_MDL_ELMNT 
   (	MDL_IMP_ID number not null, 
	"ITEM_LONG_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"ITEM_PHY_OBJ_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"ME_TYP_NM" varchar2(255) not null, 
	"ITEM_DESC" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	  
	"DT_SORT" TIMESTAMP (2) DEFAULT sysdate, 
	 PRIMARY KEY ("MDL_IMP_ID", "ITEM_LONG_NM"));


  CREATE TABLE NCI_STG_MDL_ELMNT_CHAR 
   (	"MDL_IMP_ID" NUMBER NOT NULL ENABLE, 
	"ME_ITEM_LONG_NM" varchar2(255) not null, 
	"MEC_TYP_NM" varchar2(255), 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"SRC_DTTYPE" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"SRC_MAND_IND" VARCHAR2(10) , 
	"STD_DTTYPE_ID" NUMBER, 
	"SRC_MAX_CHAR" NUMBER(*,0), 
	"SRC_MIN_CHAR" NUMBER(*,0), 
	"VAL_DOM_TYP_ID" NUMBER, 
	"SRC_UOM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"UOM_ID" NUMBER, 
	"SRC_DEFLT_VAL" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"SRC_ENUM_SRC" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"DE_CONC_ITEM_ID" NUMBER, 
	"DE_CONC_VER_NR" NUMBER(4,2), 
	"VAL_DOM_ITEM_ID" NUMBER, 
	"VAL_DOM_VER_NR" NUMBER(4,2), 
	"NUM_PV" NUMBER(*,0), 
	"MEC_LONG_NM" VARCHAR2(255 BYTE) not null, 
	"MEC_PHY_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"MEC_DESC" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"CDE_ITEM_ID" NUMBER, 
	"CDE_VER_NR" NUMBER(4,2), 
	"DT_SORT" TIMESTAMP (2) DEFAULT sysdate, 
	SEQ_NBR integer not null,
	 PRIMARY KEY (MDL_IMP_ID, SEQ_NBR));

insert into obj_typ (obj_typ_id, obj_typ_desc) values (44,'Model Type');
commit;

insert into obj_key (obj_key_id, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (79,'Semantic Model',44,'Semantic Model','Semantic Model','Semantic Model' );
commit;

insert into obj_key (obj_key_id, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (78,'Physical Model',44,'Physical Model','Physical Model','Physical Model' );
commit;


CREATE TABLE SAG_CONCEPT_MERGE_BY_DATE
(
  RETIRED_DT    DATE                            NOT NULL,
  CODE_RETIRED  VARCHAR2(120 BYTE)              NOT NULL,
  ACTION        VARCHAR2(50 BYTE),
  NAME_DESC     VARCHAR2(2000 BYTE),
  ACTIVE_CODE   VARCHAR2(120 BYTE),
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE)  DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE)  DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate
);
CREATE TABLE SAG_CONCEPT_RETIRED_BY_DATE
(
  RETIRED_DT    DATE,
  CODE_RETIRED  VARCHAR2(50 BYTE),
  NAME_DESC     VARCHAR2(2000 BYTE),
  ACTION        VARCHAR2(50 BYTE),
  ACTIVE_CODE   VARCHAR2(120 BYTE),
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE)  DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE)  DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate
);

alter table NCI_MDL add (MDL_TYP_ID integer);


  CREATE OR REPLACE  VIEW  VW_NCI_GENERIC_DE AS
  SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
          CAST('.' || ADMIN_ITEM.ITEM_ID || '.' AS VARCHAR2(4000))    ITEM_ID_STR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.ADMIN_NOTES,
           ADMIN_ITEM.CHNG_DESC_TXT,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNRSLVD_ISSUE,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.CREAT_USR_ID             CREAT_USR_ID_X,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID           LST_UPD_USR_ID_X,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.NCI_IDSEQ,
	     ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
	   ADMIN_ITEM.ITEM_DEEP_LINK,
           ext.USED_BY                         CNTXT_AGG,
             vd.VAL_DOM_TYP_ID	 ,
	     an.NM_DESC,
	     adef.def_desc,
         aref.CODE_INSTR_REF_DESC,
         aref.INSTR_REF_DESC,
         aref.EXAMPL,
	    csi.cs_item_id,
	  csi.cs_item_ver_nr,
	  csi.item_id csi_item_id,
	  csi.ver_nr csi_ver_nr,
	    admin_item.cntxt_item_id srch_cntxt_id ,
	    admin_item.cntxt_ver_nr srch_cntxt_ver_nr
	     FROM ADMIN_ITEM,
           NCI_ADMIN_ITEM_EXT  ext,
	    nci_admin_item_rel r,
	    nci_clsfctn_schm_item csi,
	      de, VALUE_DOM vd, 
	     (SELECT an.item_id, an.ver_nr,  csian.NCI_PUB_ID csi_item_id, csian.NCI_VER_NR  csi_ver_nr, max(nm_desc) as NM_DESC
	      from alt_nms an,  NCI_CSI_ALT_DEFNMS csian
	  where an.nm_id = csian.nmdef_id and csian.TYP_NM='DESIGNATION'
          group by an.item_id, an.ver_nr, csian.NCI_PUB_ID,csian.NCI_VER_NR) an,
	     (SELECT an.item_id, an.ver_nr,  csian.NCI_PUB_ID csi_item_id, csian.NCI_VER_NR  csi_ver_nr, max(def_desc) as def_DESC
	      from alt_def an, NCI_CSI_ALT_DEFNMS csian
	  where an.def_id = csian.nmdef_id and csian.TYP_NM='DEFINITION'
          group by an.item_id, an.ver_nr, csian.NCI_PUB_ID,csian.NCI_VER_NR) adef,
	    (SELECT an.item_id, an.ver_nr,  csian.NCI_PUB_ID csi_item_id, csian.NCI_VER_NR  csi_ver_nr,  
	  max(decode(upper(obj_key_Desc),'CODING INSTRUCTIONS',ref_desc) ) CODE_INSTR_REF_DESC,
       max(decode(upper(obj_key_Desc),'INSTRUCTIONS', ref_desc) ) INSTR_REF_DESC,
       max(decode(upper(obj_key_Desc),'EXAMPLE', ref_desc) ) EXAMPL
	      from ref an, NCI_CSI_ALT_DEFNMS csian, OBJ_KEY
	  where an.ref_id = csian.nmdef_id and csian.TYP_NM='REFERENCE' and an.REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID   and obj_key.obj_typ_id = 1 and nvl(an.fld_delete,0) = 0
	  AND UPPER(OBJ_KEY_DESC) in ('INSTRUCTIONS', 'CODING INSTRUCTIONS','EXAMPLE') 
          group by an.item_id, an.ver_nr, csian.NCI_PUB_ID,csian.NCI_VER_NR) aref
        WHERE     admin_item.ADMIN_ITEM_TYP_ID = 4
           and ADMIN_ITEM.ITEM_Id = de.item_id
           and ADMIN_ITEM.VER_NR = DE.VER_NR
           and de.VAL_DOM_ITEM_ID = vd.ITEM_ID
	   and de.VAL_DOM_VER_NR = vd.VER_NR
	   AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
	   and admin_item.item_id = adef.item_id (+)
	   and admin_item.ver_nr = adef.ver_nr (+)
	   and admin_item.item_id = an.item_id (+)
	   and admin_item.ver_nr = an.ver_nr (+)
	     and admin_item.item_id = aref.item_id (+)
	   and admin_item.ver_nr = aref.ver_nr (+)
	  and csi.item_id = r.p_item_id 
	  and csi.ver_nr = r.p_item_ver_nr
	  and admin_item.item_id = r.c_item_id
	  and admin_item.ver_nr = r.c_item_ver_nr
	  and r.rel_typ_id = 65
	  and csi.item_id = an.csi_item_id (+)
	  and csi.ver_nr = an.csi_ver_nr (+)
	  and csi.item_id = adef.csi_item_id (+)
	  and csi.ver_Nr = adef.csi_ver_nr (+)
	    and csi.item_id = aref.csi_item_id (+)
	  and csi.ver_Nr = aref.csi_ver_nr (+);

