CREATE OR REPLACE  VIEW VW_NCI_AI_CNCPT AS
  SELECT  '5. Object Class' ALT_NMS_LVL, DE.ITEM_ID  ITEM_ID,
		DE.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where
	a.ITEM_ID = DE_CONC.OBJ_CLS_ITEM_ID and
	a.VER_NR = DE_CONC.OBJ_CLS_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '4. Property' ALT_NMS_LVL, DE.ITEM_ID  ITEM_ID,
		DE.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND,  NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where
	a.ITEM_ID = DE_CONC.PROP_ITEM_ID and
	a.VER_NR = DE_CONC.PROP_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '3. Representation Term' ALT_NMS_LVL, DE.ITEM_ID  ITEM_ID,
		DE.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, VALUE_DOM VD where
	a.ITEM_ID = VD.REP_CLS_ITEM_ID and
	a.VER_NR = VD.REP_CLS_VER_NR and
	DE.VAL_DOM_ITEM_ID = VD.ITEM_ID and
	DE.VAL_DOM_VER_NR = VD.VER_NR
	union
         SELECT '1. Value Meaning' ALT_NMS_LVL, DE.ITEM_ID  ITEM_ID,
		DE.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, PERM_VAL PV where
	a.ITEM_ID = PV.NCI_VAL_MEAN_ITEM_ID and
	a.VER_NR = PV.NCI_VAL_MEAN_VER_NR and
	DE.VAL_DOM_ITEM_ID = PV.VAL_DOM_ITEM_ID and
	DE.VAL_DOM_VER_NR = PV.VAL_DOM_VER_NR and
nvl(pv.fld_delete,0) = 0
	union
         SELECT '2. Value Domain' ALT_NMS_LVL, DE.ITEM_ID  ITEM_ID,
		DE.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE where
	DE.VAL_DOM_ITEM_ID = a.ITEM_ID and
	DE.VAL_DOM_VER_NR = a.VER_NR
  union
    SELECT  '2. Object Class' ALT_NMS_LVL, DEC.ITEM_ID  ITEM_ID,
		DEC.VER_NR VER_NR,
	a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE_CONC DEC where
	a.ITEM_ID = DEC.OBJ_CLS_ITEM_ID and
	a.VER_NR = DEC.OBJ_CLS_VER_NR
	union
         SELECT '1. Property' ALT_NMS_LVL, DEC.ITEM_ID  ITEM_ID,
		DEC.VER_NR VER_NR,
	a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
			a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE_CONC DEC where
	a.ITEM_ID = DEC.PROP_ITEM_ID and
	a.VER_NR = DEC.PROP_VER_NR
  union
  SELECT  'Component Concept' ALT_NMS_LVL, a.ITEM_ID, a.VER_NR,
	a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a
   union
      SELECT '2. Representation Term' ALT_NMS_LVL, VD.ITEM_ID  ITEM_ID,
	VD.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, VALUE_DOM VD where
	a.ITEM_ID = VD.REP_CLS_ITEM_ID and
	a.VER_NR = VD.REP_CLS_VER_NR
	union
	SELECT '1. Value Meaning' ALT_NMS_LVL,  PV.VAL_DOM_ITEM_ID  ITEM_ID,
		PV.VAL_DOM_VER_NR VER_NR,
		PV.NCI_VAL_MEAN_ITEM_ID, PV.NCI_VAL_MEAN_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a,  PERM_VAL PV where
	a.ITEM_ID = PV.NCI_VAL_MEAN_ITEM_ID and
	a.VER_NR = PV.NCI_VAL_MEAN_VER_NR
and nvl(pv.fld_delete,0) = 0
	union
	SELECT  'Concept Relationship' ALT_NMS_LVL, 
		a.P_ITEM_ID ITEM_ID, a.P_ITEM_VER_NR VER_NR,
        a.P_ITEM_ID CORE_ITEM_ID, a.P_ITEM_VER_NR CORE_VER_NR,
		a.C_ITEM_ID CNCPT_ITEM_ID, a.C_ITEM_VER_NR CNCPT_VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, 1 NCI_ORD, 1 NCI_PRMRY_IND , '1' NCI_CNCPT_VAL,
		'1' NCI_PRMRY_IND_TXT, REL_TYP_ID
       FROM NCI_CNCPT_REL a;



  CREATE OR REPLACE  VIEW VW_NCI_DE_CNCPT AS
  SELECT  '5. Object Class' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where
	a.ITEM_ID = DE_CONC.OBJ_CLS_ITEM_ID and
	a.VER_NR = DE_CONC.OBJ_CLS_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '4. Property' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND,  NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where
	a.ITEM_ID = DE_CONC.PROP_ITEM_ID and
	a.VER_NR = DE_CONC.PROP_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '3. Representation Term' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, VALUE_DOM VD where
	a.ITEM_ID = VD.REP_CLS_ITEM_ID and
	a.VER_NR = VD.REP_CLS_VER_NR and
	DE.VAL_DOM_ITEM_ID = VD.ITEM_ID and
	DE.VAL_DOM_VER_NR = VD.VER_NR
	union
         SELECT '1. Value Meaning' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, PERM_VAL PV where
	a.ITEM_ID = PV.NCI_VAL_MEAN_ITEM_ID and
	a.VER_NR = PV.NCI_VAL_MEAN_VER_NR and
	DE.VAL_DOM_ITEM_ID = PV.VAL_DOM_ITEM_ID and
	DE.VAL_DOM_VER_NR = PV.VAL_DOM_VER_NR and nvl(pv.fld_delete,0) = 0
	union
         SELECT '2. Value Domain' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE where
	DE.VAL_DOM_ITEM_ID = a.ITEM_ID and
	DE.VAL_DOM_VER_NR = a.VER_NR;



  CREATE OR REPLACE VIEW VW_NCI_VD_CNCPT AS
  SELECT  '3. Component Concept' ALT_NMS_LVL, a.ITEM_ID, a.VER_NR,
	a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a
   union
      SELECT '2. Representation Term' ALT_NMS_LVL, VD.ITEM_ID  ITEM_ID,
		VD.VER_NR VER_NR,
		VD.REP_CLS_ITEM_ID CORE_ITEM_ID, VD.REP_CLS_VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, VALUE_DOM VD where
	a.ITEM_ID = VD.REP_CLS_ITEM_ID and
	a.VER_NR = VD.REP_CLS_VER_NR
	union
	 SELECT '1. Value Meaning' ALT_NMS_LVL,  PV.VAL_DOM_ITEM_ID  ITEM_ID,
		PV.VAL_DOM_VER_NR VER_NR,
		PV.NCI_VAL_MEAN_ITEM_ID, PV.NCI_VAL_MEAN_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a,  PERM_VAL PV where
	a.ITEM_ID = PV.NCI_VAL_MEAN_ITEM_ID and
	a.VER_NR = PV.NCI_VAL_MEAN_VER_NR and nvl(pv.fld_delete,0) = 0;




alter table NCI_MDL_ELMNT_CHAR add (DEFLT_VAL_ID number, DEFLT_VAL varchar2(4000));


create table SAG_LOAD_ICDO_RAW
( SRC_FILE  varchar2(100) not null,
  CODE  varchar2(100) not null,
  LVL_STRUCT  varchar2(100) not null,
  LBL_TOPIC  varchar2(1000) not null);


  CREATE TABLE NCI_ADMIN_ITEM_XMAP 
   (	ITEM_ID NUMBER NOT NULL , 
	VER_NR NUMBER(4,2) NOT NULL, 
	XMAP_CD	varchar2(4000) not null,
	XMAP_DESC varchar2(4000) null,
	CREAT_DT DATE DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50 BYTE)  DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50 BYTE) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate, 
	REL_TYP_ID INTEGER NULL, 
	EVS_SRC_ID INTEGER NOT NULL,
        EVS_SRC_VER_NR varchar2(10) not null,
	 PRIMARY KEY (ITEM_ID, VER_NR, XMAP_CD, EVS_SRC_ID, EVS_SRC_VER_NR)
 );

alter table NCI_MEC_MAP add TGT_FUNC_PARAM varchar2(1000);

drop materialized view MVW_CSI_TREE_CDE;
set escape on;

  CREATE MATERIALIZED VIEW MVW_CSI_TREE_CDE
  AS select 98 LVL, null P_ITEM_ID, null P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ITEM_LONG_NM,  
  ITEM_NM || ' (' || ITEM_DESC  || ') (' || nvl(y.cnt,'0') || ')'  ITEM_NM , ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X ,
c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CDEDD%20Classification.P_ITEM_ID=' || ai.item_id ITEM_DEEP_LINK ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=104\&type=csi\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=103\&type=csi\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=114\&type=csi\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES,
    0 TYP_ID,
null  P_ITEM_VER
from 
ADMIN_ITEM ai, (select x.p_item_id, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='Context' and x.ADMIN_STUS_NM_DN='RELEASED' group by x.p_item_id , 
x.p_item_ver_nr) y , nci_mdr_cntrl c,nci_mdr_cntrl c1
 where ADMIN_ITEM_TYP_ID = 8 and item_id = y.p_item_id (+) and ver_nr = y.p_item_ver_nr (+) and upper(cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 and c1.param_nm='DEEP_LINK'
 union
select 99 LVL, CNTXT_ITEM_ID P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ai.ITEM_ID,ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, 
ITEM_NM || ' (' || nvl(y.cnt,'0') || ')', ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X ,
c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CDEDD%20Classification.P_ITEM_ID=' || ai.item_id ITEM_DEEP_LINK ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES,
      cs.CLSFCTN_SCHM_TYP_ID,
CNTXT_ITEM_ID || 'v'|| CNTXT_VER_NR P_ITEM_VER
 from 
ADMIN_ITEM ai, clsfctn_schm cs,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CS' and x.ADMIN_STUS_NM_DN='RELEASED' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c,nci_mdr_cntrl c1
 where ADMIN_ITEM_TYP_ID = 9 and ai.item_id =cs.item_id and ai.ver_nr = cs.ver_nr and  ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and admin_stus_nm_dn ='RELEASED' and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 and c1.param_nm='DEEP_LINK'
 union
  select 100 LVL, csi.CS_ITEM_ID P_ITEM_ID, csi.CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' , 
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CDEDD%20Classification.P_ITEM_ID=' || ai.item_id ITEM_DEEP_LINK ,
 c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********'  CHNG_NOTES,
    csi.csi_typ_id,
csi.CS_ITEM_ID || 'v'|| csi.CS_ITEM_VER_NR P_ITEM_VER 
from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CSI' and x.ADMIN_STUS_NM_DN='RELEASED' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c,nci_mdr_cntrl c1
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
  and c1.param_nm='DEEP_LINK'
 and ai.admin_stus_nm_dn = 'RELEASED'
 union
 select 100 LVL, csi.P_ITEM_ID P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' , 
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CDEDD%20Classification.P_ITEM_ID=' || ai.item_id ITEM_DEEP_LINK ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\Legacy_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\Legacy_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\Prior_Legacy_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES,
    csi.CSI_TYP_ID,
csi.P_ITEM_ID || 'v'|| csi.P_ITEM_VER_NR P_ITEM_VER 
 from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CSI' and x.ADMIN_STUS_NM_DN='RELEASED' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c,nci_mdr_cntrl c1
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 and c1.param_nm='DEEP_LINK'
 and ai.admin_stus_nm_dn = 'RELEASED';

alter table nci_admin_item_rel add (P_ITEM_ID_VER  varchar2(50), C_ITEM_ID_VER  varchar2(50));

alter table nci_admin_item_rel disable all triggers;

update nci_admin_item_rel set P_ITEM_ID_VER = P_ITEM_ID || 'v'|| P_ITEM_VER_NR, C_ITEM_ID_VER = C_ITEM_ID || 'v' || C_ITEM_VER_NR;
commit;

alter table nci_admin_item_rel enable all triggers;


drop materialized view MVW_CSI_NODE_DE_REL;

  CREATE MATERIALIZED VIEW MVW_CSI_NODE_DE_REL
  AS SELECT  distinct ai.CREAT_DT,
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
           csi.BASE_ID P_ITEM_ID,
           csi.BASE_VER_NR P_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           de.PREF_QUEST_TXT, 
	   e.USED_BY,
	   'CSI' LVL,
       csi.BASE_ID || 'v' || csi.BASE_VER_NR P_ITEM_ID_VER
           FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, de , nci_admin_item_ext e, MVW_CSI_REL csi, ADMIN_ITEM csix
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR and ai.admin_item_typ_id = 4 and ak.rel_typ_id = 65 and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn = 'RELEASED'
and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING')
and csi.ITEM_ID= ak.P_ITEM_ID and csi.VER_NR = ak.P_item_ver_nr
and csix.ITEM_ID=csi.ITEM_ID and csix.VER_NR=csi.VER_NR and csix.admin_stus_nm_dn = 'RELEASED'
--and nvl(ai.CURRNT_VER_IND,0) = 1 
and nvl(ak.fld_delete,0) = 0
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
       de.PREF_QUEST_TXT,
e.USED_BY, 'CS' LVL,
  csi.CS_ITEM_ID || 'v' || csi.CS_ITEM_VER_NR P_ITEM_ID_VER
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi, de, nci_admin_item_Ext e, ADMIN_ITEM csix
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ak.P_ITEM_ID = csi.ITEM_ID
           AND ak.P_ITEM_VER_NR = csi.VER_NR and ai.admin_item_typ_id = 4 and ak.rel_typ_id = 65 and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn = 'RELEASED' and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING')
and csix.ITEM_ID=csi.ITEM_ID and csix.VER_NR =csi.VER_NR and csix.admin_stus_nm_dn = 'RELEASED'
--and nvl(ai.CURRNT_VER_IND,0) = 1 
union
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
           cs.CNTXT_ITEM_ID,
           cs.CNTXT_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
            de.PREF_QUEST_TXT,
e.USED_BY, 'Context' LVL,
  cs.CNTXT_ITEM_ID || 'v' || cs.CNTXT_VER_NR P_ITEM_ID_VER
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi, VW_CLSFCTN_SCHM cs, de, nci_admin_item_ext e, ADMIN_ITEM csix
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ak.P_ITEM_ID = csi.ITEM_ID
           AND ak.P_ITEM_VER_NR = csi.VER_NR and ai.admin_item_typ_id = 4 and ak.rel_typ_id = 65
and csi.CS_ITEM_ID = cs.ITEM_ID and csi.CS_ITEM_VER_NR = cs.VER_NR and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn ='RELEASED' and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING') 
and cs.admin_stus_nm_dn ='RELEASED'
and csix.ITEM_ID=csi.ITEM_ID and csix.VER_NR =csi.VER_NR and csix.admin_stus_nm_dn = 'RELEASED';



