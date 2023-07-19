
  CREATE OR REPLACE  VIEW VW_NCI_PROT_DE_REL AS
  SELECT  distinct sysdate CREAT_DT, 
           'ONEDATA' CREAT_USR_ID,
           'ONEDATA' LST_UPD_USR_ID,
           sysdate LST_UPD_DT,
            sysdate S2P_TRN_DT,
           sysdate LST_DEL_DT,
           0 FLD_DELETE,
           prot.P_ITEM_ID PROT_ITEM_ID,
           prot.P_ITEM_VER_NR PROT_VER_NR,
           ak.c_item_id item_id,
           ak.c_item_ver_nr ver_nr
           FROM NCI_ADMIN_ITEM_REL r, NCI_ADMIN_ITEM_REL_ALT_KEY ak , nci_admin_item_rel prot
     WHERE  ak.P_ITEM_ID = r.C_ITEM_ID and ak.P_ITEM_VER_NR = r.C_ITEM_VER_NR and
	   r.rel_typ_id = 61 
  and r.p_item_id = prot.c_item_id and r.p_item_ver_nr = prot.c_item_ver_nr and prot.rel_typ_id=60
  and nvl(ak.fld_delete,0) = 0;
/

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
	DE.VAL_DOM_VER_NR = PV.VAL_DOM_VER_NR
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
/

  CREATE OR REPLACE  VIEW VW_NCI_MODULE_DE AS
  SELECT FRM.ITEM_LONG_NM FRM_ITEM_LONG_NM, FRM.ITEM_NM FRM_ITEM_NM, FRM.ITEM_ID FRM_ITEM_ID, FRM.VER_NR FRM_VER_NR,  FRM.CNTXT_NM_DN FRM_CNTXT_NM_DN,
  FRM.ADMIN_STUS_NM_DN FRM_ADMIN_STUS_NM_DN, FRM.REGSTR_STUS_NM_DN FRM_REGSTR_STUS_NM_DN,
FRM.CNTXT_ITEM_ID FRM_CNTXT_ITEM_ID, FRM.CNTXT_VER_NR FRM_CNTXT_VER_NR,
AIR.P_ITEM_ID MOD_ITEM_ID, AIR.P_ITEM_VER_NR MOD_VER_NR,
AIR.C_ITEM_ID DE_ITEM_ID, AIR.C_ITEM_VER_NR DE_VER_NR, AIR.DISP_ORD QUEST_DISP_ORD,FRM_MOD.DISP_ORD MOD_DISP_ORD,
AIM.ITEM_NM MOD_ITEM_NM, AIR.INSTR,
AIM.ITEM_LONG_NM  MOD_ITEM_LONG_NM, AIM.ITEM_DESC MOD_ITEM_DESC,
'QUESTION' ADMIN_ITEM_TYP_NM, AIR.NCI_PUB_ID,AIR.NCI_VER_NR,
DE.CNTXT_NM_DN, DE.ITEM_NM DE_ITEM_NM, DE.ITEM_DESC DE_ITEM_DESC, DE.CNTXT_ITEM_ID DE_CNTXT_ITEM_ID, DE.CNTXT_VER_NR DE_CNTXT_VER_NR, 
DE.ADMIN_STUS_NM_DN DE_ADMIN_STUS_NM_DN, DE.REGSTR_STUS_NM_DN DE_REGSTR_STUS_NM_DN,DE.CURRNT_VER_IND DE_CURRNT_VER_IND, 
AIR.CREAT_DT, AIR.CREAT_USR_ID, AIR.LST_UPD_USR_ID, AIR.FLD_DELETE, AIR.LST_DEL_DT, AIR.S2P_TRN_DT, AIR.LST_UPD_DT, AIR.ITEM_LONG_NM QUEST_LONG_TXT, AIR.ITEM_NM QUEST_TXT,
DE.ADMIN_STUS_ID DE_ADMIN_STUS_ID, DE.REGSTR_STUS_ID DE_REGSTR_STUS_ID, 54 ADMIN_ITEM_TYP_ID
FROM  NCI_ADMIN_ITEM_REL_ALT_KEY AIR, ADMIN_ITEM AIM,
ADMIN_ITEM FRM, NCI_ADMIN_ITEM_REL FRM_MOD , ADMIN_ITEM DE
WHERE  AIR.REL_TYP_ID = 63
AND AIM.ITEM_ID = AIR.P_ITEM_ID AND AIM.VER_NR = AIR.P_ITEM_VER_NR
AND FRM.ITEM_ID = FRM_MOD.P_ITEM_ID AND FRM.VER_NR = FRM_MOD.P_ITEM_VER_NR AND AIM.ITEM_ID = FRM_MOD.C_ITEM_ID AND AIM.VER_NR = FRM_MOD.C_ITEM_VER_NR
AND FRM_MOD.REL_TYP_ID IN (61,62)
AND FRM.ADMIN_ITEM_TYP_ID IN ( 54,55)
AND AIR.C_ITEM_ID = DE.ITEM_ID
AND AIR.C_ITEM_VER_NR = DE.VER_NR
union
 SELECT 'No Form Relationship' FRM_ITEM_LONG_NM,'No Form Relationship' FRM_ITEM_NM,-1 FRM_ITEM_ID, 1 FRM_VER_NR,  'NCIP' FRM_CNTXT_NM_DN,
  'RELEASED' FRM_ADMIN_STUS_NM_DN, 'STANDARD' FRM_REGSTR_STUS_NM_DN,
20000000024 FRM_CNTXT_ITEM_ID, 1 FRM_CNTXT_VER_NR,
AIR.P_ITEM_ID MOD_ITEM_ID, AIR.P_ITEM_VER_NR MOD_VER_NR,
AIR.C_ITEM_ID DE_ITEM_ID, AIR.C_ITEM_VER_NR DE_VER_NR, AIR.DISP_ORD QUEST_DISP_ORD,FRM_MOD.DISP_ORD MOD_DISP_ORD,
AIM.ITEM_NM MOD_ITEM_NM, AIR.INSTR,
AIM.ITEM_LONG_NM  MOD_ITEM_LONG_NM, AIM.ITEM_DESC MOD_ITEM_DESC,
'QUESTION' ADMIN_ITEM_TYP_NM, AIR.NCI_PUB_ID,AIR.NCI_VER_NR,
DE.CNTXT_NM_DN, DE.ITEM_NM DE_ITEM_NM, DE.ITEM_DESC DE_ITEM_DESC, DE.CNTXT_ITEM_ID DE_CNTXT_ITEM_ID, DE.CNTXT_VER_NR DE_CNTXT_VER_NR, 
DE.ADMIN_STUS_NM_DN DE_ADMIN_STUS_NM_DN, DE.REGSTR_STUS_NM_DN DE_REGSTR_STUS_NM_DN,DE.CURRNT_VER_IND DE_CURRNT_VER_IND, 
AIR.CREAT_DT, AIR.CREAT_USR_ID, AIR.LST_UPD_USR_ID, AIR.FLD_DELETE, AIR.LST_DEL_DT, AIR.S2P_TRN_DT, AIR.LST_UPD_DT, AIR.ITEM_LONG_NM QUEST_LONG_TXT, AIR.ITEM_NM QUEST_TXT,
DE.ADMIN_STUS_ID DE_ADMIN_STUS_ID, DE.REGSTR_STUS_ID DE_REGSTR_STUS_ID, 54
FROM  NCI_ADMIN_ITEM_REL_ALT_KEY AIR, ADMIN_ITEM AIM,
 NCI_ADMIN_ITEM_REL FRM_MOD , ADMIN_ITEM DE
WHERE  AIR.REL_TYP_ID = 63
AND AIM.ITEM_ID = AIR.P_ITEM_ID AND AIM.VER_NR = AIR.P_ITEM_VER_NR
AND AIM.ITEM_ID = FRM_MOD.C_ITEM_ID AND AIM.VER_NR = FRM_MOD.C_ITEM_VER_NR
AND FRM_MOD.REL_TYP_ID IN (61,62)
AND AIR.C_ITEM_ID = DE.ITEM_ID
AND AIR.C_ITEM_VER_NR = DE.VER_NR
and FRM_MOD.P_ITEM_ID = -1;
/


  CREATE OR REPLACE  VIEW VW_DE_CONC_RELEASED AS
  SELECT ADMIN_ITEM.LST_UPD_DT, DE_CONC.S2P_TRN_DT, DE_CONC.LST_DEL_DT, DE_CONC.FLD_DELETE, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.CREAT_DT, 
DE_CONC.OBJ_CLS_VER_NR, DE_CONC.OBJ_CLS_ITEM_ID, DE_CONC.PROP_ITEM_ID, DE_CONC.PROP_VER_NR, DE_CONC.CONC_DOM_ITEM_ID, DE_CONC.CONC_DOM_VER_NR, 
ADMIN_ITEM.ITEM_ID, 
ADMIN_ITEM.VER_NR, 
CAST('.' || ADMIN_ITEM.ITEM_ID || '.' AS VARCHAR2(4000))    ITEM_ID_STR,
     ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, 
ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CNTXT_ITEM_ID, ADMIN_ITEM.CNTXT_VER_NR, ADMIN_ITEM.ADMIN_NOTES,
 ADMIN_ITEM.CHNG_DESC_TXT, ADMIN_ITEM.CREATION_DT, ADMIN_ITEM.EFF_DT, ADMIN_ITEM.DATA_ID_STR, ADMIN_ITEM.ADMIN_ITEM_TYP_ID, 
ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_ID, ADMIN_ITEM.ADMIN_STUS_ID, ADMIN_STUS_NM_DN, REGSTR_STUS_NM_DN, CDE.CNT_CDE,
ORIGIN, UNRSLVD_ISSUE, UNTL_DT,  REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID, STEWRD_CNTCT_ID, SUBMT_ORG_ID,
STEWRD_ORG_ID, CNTXT_NM_DN,ORIGIN_ID_DN, REGSTR_AUTH_ID, ADMIN_ITEM.LST_UPD_USR_ID LST_UPD_USR_ID_X, ADMIN_ITEM.CREAT_USR_ID CREAT_USR_ID_X
FROM ADMIN_ITEM, DE_CONC, 
(select de_conc_item_id , de_conc_ver_nr, count(*) CNT_CDE from de group by de_conc_item_id , de_conc_ver_nr) cde 
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID=2 
AND ADMIN_ITEM.ITEM_ID = DE_CONC.ITEM_ID
AND ADMIN_ITEM.VER_NR = DE_CONC.VER_NR
and ADMIN_ITEM.ADMIN_STUS_ID <> 77
and DE_CONC.ITEM_ID = cde.DE_CONC_ITEM_ID and DE_CONC.VER_NR = CDE.DE_CONC_VER_NR;
/
insert into cntct (cntct_nm, cntct_secu_id) values ('Load Job Administrator','ONEDATA_WA');
commit;

/*
 CREATE OR REPLACE  VIEW VW_VALUE_DOM_COMP AS
  select v."NON_ENUM_VAL_DOM_DESC",v."DTTYPE_ID",v."VAL_DOM_MAX_CHAR",v."VAL_DOM_TYP_ID",v."UOM_ID",v."CREAT_DT",v."CONC_DOM_VER_NR",v."CREAT_USR_ID",v."CONC_DOM_ITEM_ID",v."LST_UPD_USR_ID",v."REP_CLS_VER_NR",v."FLD_DELETE",v."REP_CLS_ITEM_ID",v."LST_DEL_DT",v."VER_NR",v."S2P_TRN_DT",v."ITEM_ID",v."LST_UPD_DT",v."VAL_DOM_MIN_CHAR",v."VAL_DOM_FMT_ID",v."CHAR_SET_ID",v."VAL_DOM_SYS_NM",v."VAL_DOM_HIGH_VAL_NUM",v."VAL_DOM_LOW_VAL_NUM",v."X_VAL_DOM_ITEM_ID",v."Y_VAL_DOM_ITEM_ID",v."Z_VAL_DOM_ITEM_ID",v."X_VAL_DOM_VER_NR",v."Y_VAL_DOM_VER_NR",v."Z_VAL_DOM_VER_NR",v."NCI_DEC_PREC",v."NCI_STD_DTTYPE_ID",
pv.code_name
from value_dom v,
--(SELECT val_dom_item_id, val_dom_ver_nr, substr(LISTAGG(PERM_VAL_NM|| ':' || PERM_VAL_DESC_TXT || ':' || e.cncpt_concat_nm || ':' || e.cncpt_concat, '   ,  ') WITHIN GROUP (ORDER by PERM_VAL_DESC_TXT),1,8000) AS CODE_NAME
--(SELECT val_dom_item_id, val_dom_ver_nr, substr(LISTAGG(PERM_VAL_NM|| ':' || PERM_VAL_DESC_TXT || ':' || e.cncpt_concat, '   ,  ') WITHIN GROUP (ORDER by PERM_VAL_DESC_TXT),1,8000) AS CODE_NAME
(SELECT val_dom_item_id, val_dom_ver_nr, substr(LISTAGG(PERM_VAL_NM|| ':' ||  e.cncpt_concat_nm || ':' || e.cncpt_concat, '   ,  ') WITHIN GROUP (ORDER by PERM_VAL_DESC_TXT),1,8000) AS CODE_NAME
FROM PERM_VAL, nci_admin_item_ext e
 where perm_val.nci_val_mean_item_id = e.item_id
 and perm_val.nci_val_mean_ver_nr = e.ver_nr
GROUP BY val_dom_item_id, val_dom_ver_nr) pv
where v.item_id = pv.val_dom_item_id (+) and v.ver_nr = pv.val_dom_ver_nr (+);
/
*/

CREATE OR REPLACE  VIEW VW_VALUE_DOM_COMP AS
  select ai.item_nm, ai.item_long_nm, ai.admin_stus_nm_dn, ai.regstr_stus_nm_dn, ai.cntxt_nm_dn, v."NON_ENUM_VAL_DOM_DESC",v."DTTYPE_ID",v."VAL_DOM_MAX_CHAR",v."VAL_DOM_TYP_ID",v."UOM_ID",v."CREAT_DT",v."CONC_DOM_VER_NR",
	v."CREAT_USR_ID",v."CONC_DOM_ITEM_ID",v."LST_UPD_USR_ID",v."REP_CLS_VER_NR",v."FLD_DELETE",v."REP_CLS_ITEM_ID",v."LST_DEL_DT",v."VER_NR",v."S2P_TRN_DT",
	v."ITEM_ID",v."LST_UPD_DT",v."VAL_DOM_MIN_CHAR",v."VAL_DOM_FMT_ID",v."CHAR_SET_ID",v."VAL_DOM_SYS_NM",v."VAL_DOM_HIGH_VAL_NUM",v."VAL_DOM_LOW_VAL_NUM",
	v."NCI_DEC_PREC",v."NCI_STD_DTTYPE_ID"
from value_dom v, admin_item ai
where v.item_id = ai.item_id and v.ver_nr = ai.ver_nr
/
	

  CREATE OR REPLACE  VIEW VW_ADMIN_ITEM_VM_MATCH AS
  SELECT CNTXT_ITEM_ID, admin_item_typ_id,decode(admin_item_typ_id, 49, 'Concepts', 53 ,'VM', 'Other') ADMIN_ITEM_TYP,  ITEM_DESC, ITEM_LONG_NM, REGSTR_STUS_ID, ai.ITEM_ID, ai.VER_NR, ITEM_NM, ai.CREAT_DT, CNTXT_VER_NR, ADMIN_STUS_ID,
   ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN,
  decode(admin_item_typ_id, 49, ITEM_LONG_NM, 53, ai.ITEM_ID, ITEM_NM)  ID_OR_CODE, 
  decode(admin_item_typ_id, 53, decode(e.cncpt_concat, e.cncpt_concat_nm, '',e.cncpt_concat),'') VM_CONCEPTS, 
  decode(admin_item_typ_id, 49, 'Concepts', 53 ,'ID', 2 ,'ID', 'Other') MATCH_TYP
       FROM ADMIN_ITEM ai, NCI_ADMIN_ITEM_EXT e where admin_item_typ_id in (49,53)
       and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr;

/
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Superceded By',8,'Superceded By','Superceded By','Superceded By' );
commit;

alter table NCI_DS_HDR add (NUM_DEC_MTCH integer, DE_CONC_ITEM_ID number, DE_CONC_VER_NR number(4,2));

alter table NCI_DS_RSLT add (MTCH_TYP varchar2(10));

alter table NCI_DS_RSLT disable all triggers;
update NCI_DS_RSLT set MTCH_TYP = 'CDE';
commit;
alter table NCI_DS_RSLT enable all triggers;


  CREATE OR REPLACE  VIEW "VW_NCI_CRDC_DE" ("ITEM_ID", "VER_NR", "ITEM_ID_STR", "ITEM_NM", "ITEM_LONG_NM", "ITEM_DESC", "ADMIN_NOTES", "CHNG_DESC_TXT", "CREATION_DT", "EFF_DT", "ORIGIN", "ORIGIN_ID", "ORIGIN_ID_DN", "UNRSLVD_ISSUE", "UNTL_DT", "CURRNT_VER_IND", "REGSTR_STUS_ID", "ADMIN_STUS_ID", "CNTXT_NM_DN", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "CREAT_USR_ID", "CREAT_USR_ID_X", "LST_UPD_USR_ID", "LST_UPD_USR_ID_X", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "CREAT_DT", "NCI_IDSEQ", "CSI_CONCAT", "ADMIN_ITEM_TYP_ID", "ITEM_DEEP_LINK", "CNTXT_AGG", "CRDC_NM", "CRDC_DEF", "CRDC_CODE_INSTR", "CRDC_INSTR", "CRDC_EXMPL", "VAL_DOM_TYP_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT distinct ADMIN_ITEM.ITEM_ID,
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
	   ext.csi_concat,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
	   ADMIN_ITEM.ITEM_DEEP_LINK,
           ext.USED_BY                         CNTXT_AGG,
           nvl(CRDC_NM.NM_DESC,admin_item.item_nm)                        CRDC_NM,
           CRDC_DEF.DEF_DESC                 CRDC_DEF,
               CODE_INSTR_REF_DESC CRDC_CODE_INSTR,
            INSTR_REF_DESC                            CRDC_INSTR,
          EXAMPL                           CRDC_EXMPL,
            vd.VAL_DOM_TYP_ID	  FROM ADMIN_ITEM,
           NCI_ADMIN_ITEM_EXT  ext,
	      de, VALUE_DOM vd, nci_admin_item_rel r, vw_clsfctn_schm_item csi,
       (  SELECT item_id, ver_nr,  
       max(decode(upper(obj_key_Desc),'CODING INSTRUCTIONS', ref_desc) ) CODE_INSTR_REF_DESC,
 --      max(decode(upper(obj_key_Desc),'CODING INSTRUCTIONS',ref_desc) ) CODE_INSTR_REF_DESC,
       max(decode(upper(obj_key_Desc),'INSTRUCTIONS', ref_desc) ) INSTR_REF_DESC,
       max(decode(upper(obj_key_Desc),'EXAMPLE', ref_desc) ) EXAMPL
       FROM REF, OBJ_KEY WHERE REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID   and obj_key.obj_typ_id = 1 and nvl(ref.fld_delete,0) = 0
           AND UPPER(OBJ_KEY_DESC) in ('INSTRUCTIONS', 'CODING INSTRUCTIONS','EXAMPLE')  and NCI_CNTXT_ITEM_ID = 20000000047
           group by item_id ,ver_nr)  CODE_INSTR,
             (  SELECT item_id,ver_nr, max(nm_desc) nm_desc FROM ALT_NMS, OBJ_KEY WHERE NM_TYP_ID = OBJ_KEY.OBJ_KEY_ID   and obj_key.obj_typ_id =  11 
             AND UPPER(OBJ_KEY_DESC)='CRDC ALT NAME' group by item_id, ver_nr)  CRDC_NM,
           (  SELECT item_id, ver_nr, max(def_desc) def_desc FROM ALT_DEF, OBJ_KEY 
           WHERE NCI_DEF_TYP_ID = OBJ_KEY.OBJ_KEY_ID   AND UPPER(OBJ_KEY_DESC)='CRDC DEFINITION'  and obj_key.obj_typ_id =  15 group by item_id, ver_nr)  CRDC_DEF        
     WHERE     ADMIN_ITEM_TYP_ID = 4
           and ADMIN_ITEM.ITEM_Id = de.item_id
           and ADMIN_ITEM.VER_NR = DE.VER_NR
           and de.VAL_DOM_ITEM_ID = vd.ITEM_ID
	   and de.VAL_DOM_VER_NR = vd.VER_NR
	   AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
           AND ADMIN_ITEM.ITEM_ID = CRDC_NM.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = CRDC_NM.VER_NR(+)
 AND ADMIN_ITEM.ITEM_ID = CRDC_DEF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = CRDC_DEF.VER_NR(+)
 AND ADMIN_ITEM.ITEM_ID = CODE_INSTR.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = CODE_INSTR.VER_NR(+)
	   and admin_item.item_id = r.c_item_id and admin_item.ver_nr = r.c_item_ver_nr and r.p_item_id = csi.item_id and r.p_item_ver_nr = csi.ver_nr 
	   and csi.cs_item_id = 10466051 and r.rel_typ_id = 65
--and ADMIN_ITEM.CNTXT_NM_DN = 'CRDC'
and admin_item.regstr_stus_id = 2;

alter table NCI_DS_HDR add (	ENTTY_DEF  varchar2(6000));


  CREATE OR REPLACE  VIEW VW_NCI_DE AS
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
           -- ADMIN_ITEM.REGSTR_STUS_NM_DN,
           -- ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.CREAT_USR_ID             CREAT_USR_ID_X,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID           LST_UPD_USR_ID_X,
           rs.NCI_DISP_ORDR                    REGSTR_STUS_DISP_ORD,
           ws.NCI_DISP_ORDR                    ADMIN_STUS_DISP_ORD,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.NCI_IDSEQ,
	   ext.csi_concat,
           CNTXT.NCI_PRG_AREA_ID,
           ADMIN_ITEM_TYP_ID,
	   ADMIN_ITEM.ITEM_DEEP_LINK,
       replace (ADMIN_ITEM.ITEM_NM_ID_VER,'|Data Element','') ITEM_NM_ID_VER,
           ext.USED_BY                         CNTXT_AGG,
           REF.PREF_QUEST_TXT                        PREF_QUEST_TXT,
	   vd.VAL_DOM_TYP_ID	,
          trim(SUBSTR (
                 trim(ADMIN_ITEM.ITEM_LONG_NM)
              || '||'
              || trim(ADMIN_ITEM.ITEM_NM)
              || '||'
              || trim(ADMIN_ITEM.ITEM_DESC),1,
              4290))
              || '||'
              ||
              SUBSTR ( trim(REF_DESC.REF_DESC),
             1,
              30000)                            SEARCH_STR
      FROM ADMIN_ITEM,
           VW_CNTXT            CNTXT,
       --    VALUE_DOM vd,
           NCI_ADMIN_ITEM_EXT  ext,
	   de, VALUE_DOM vd,
           (SELECT item_id, ver_nr, ref_desc PREF_QUEST_TXT
              FROM REF
             WHERE ref_typ_id = 80) REF,
           (  SELECT item_id,
                     ver_nr,
                     LISTAGG (ref_desc, '||' ON OVERFLOW TRUNCATE ) WITHIN GROUP (ORDER BY REF_DESC desc)    ref_desc
                FROM REF, OBJ_KEY
               WHERE     REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                     AND LOWER (OBJ_KEY_DESC) LIKE '%question%'
            GROUP BY item_id, ver_nr) ref_desc,
           VW_REGSTR_STUS      rs,
           VW_ADMIN_STUS       ws
     WHERE     ADMIN_ITEM_TYP_ID = 4
           and ADMIN_ITEM.ITEM_Id = de.item_id
           and ADMIN_ITEM.VER_NR = DE.VER_NR
           and de.VAL_DOM_ITEM_ID = vd.ITEM_ID
	   and de.VAL_DOM_VER_NR = vd.VER_NR
	   AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
           AND ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = REF.VER_NR(+)
           AND ADMIN_ITEM.ITEM_ID = ref_desc.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = ref_desc.VER_NR(+)
           AND ADMIN_ITEM.REGSTR_STUS_ID = rs.STUS_ID(+)
           AND ADMIN_ITEM.ADMIN_STUS_ID = ws.STUS_ID(+)
           AND ADMIN_ITEM.CNTXT_ITEM_ID = CNTXT.ITEM_ID
           AND ADMIN_ITEM.CNTXT_VER_NR = CNTXT.VER_NR;


alter table NCI_DS_HDR add (PREF_CNCPT_CONCAT  varchar2(4000));

alter table NCI_DS_HDR add (PREF_CNCPT_CONCAT_NM  varchar2(32000));

  CREATE OR REPLACE  VIEW VW_DE_DEC_MTCH
	   AS
  SELECT 
r.HDR_ID,
ADMIN_ITEM.ITEM_ID, 
ADMIN_ITEM.VER_NR, 
ADMIN_ITEM.ITEM_NM, 
ADMIN_ITEM.ITEM_LONG_NM, 
ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN, 
ADMIN_ITEM.CURRNT_VER_IND, 
ADMIN_ITEM.REGSTR_STUS_NM_DN, 
ADMIN_ITEM.ADMIN_STUS_NM_DN,
ADMIN_ITEM.REGSTR_STUS_ID, 
ADMIN_ITEM.ADMIN_STUS_ID,
 DE.DE_CONC_VER_NR, 
 DE.DE_CONC_ITEM_ID, 
 DE.VAL_DOM_VER_NR, 
 DE.VAL_DOM_ITEM_ID, 
 DE.REP_CLS_VER_NR, 
 DE.REP_CLS_ITEM_ID, 
DE.CREAT_USR_ID, 
DE.LST_UPD_USR_ID, 
DE.FLD_DELETE, 
DE.LST_DEL_DT, 
DE.S2P_TRN_DT, 
DE.LST_UPD_DT, 
DE.CREAT_DT,
DE.PREF_QUEST_TXT, 
VALUE_DOM.NON_ENUM_VAL_DOM_DESC, 
VALUE_DOM.DTTYPE_ID, 
VAL_DOM_MAX_CHAR, 
VAL_DOM_TYP_ID, 
VALUE_DOM.UOM_ID,
VAL_DOM_MIN_CHAR, 
VAL_DOM_FMT_ID, 
CHAR_SET_ID, 
VAL_DOM_HIGH_VAL_NUM, 
VAL_DOM_LOW_VAL_NUM, 
FMT_NM, 
DTTYPE_NM, 
UOM_NM,
decode(VALUE_DOM.VAL_DOM_TYP_ID,17 ,'Enumerated', 18,'Non-Enumerated') VAL_DOM_TYP
FROM ADMIN_ITEM, DE, VALUE_DOM, DATA_TYP, FMT, UOM, NCI_DS_RSLT r
WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
and DE.VER_NR = ADMIN_ITEM.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
	  and de.de_conc_item_id = r.item_id and de.de_conc_ver_nr = r.ver_nr
and VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID (+)
and VALUE_DOM.DTTYPE_ID = DATA_TYP.DTTYPE_ID (+)
and VALUE_DOM.UOM_ID = UOM.UOM_ID (+);


  CREATE OR REPLACE  VIEW VW_ADMIN_ITEM_WITH_EXT ("ITEM_ID", "VER_NR", "ITEM_DESC", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ITEM_LONG_NM", "ITEM_NM", "ADMIN_NOTES", "CHNG_DESC_TXT", "EFF_DT", "ORIGIN", "UNRSLVD_ISSUE", "UNTL_DT", "ADMIN_ITEM_TYP_ID", "CURRNT_VER_IND", "ADMIN_STUS_ID", "REGSTR_STUS_ID", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "NCI_IDSEQ", "ADMIN_STUS_NM_DN", "CNTXT_NM_DN", "REGSTR_STUS_NM_DN", "ORIGIN_ID", "ORIGIN_ID_DN", "EVS_SRC_ORI", "CNCPT_CONCAT", "CNCPT_CONCAT_NM", "CNCPT_CONCAT_DEF") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, ai.ITEM_NM, ai.ADMIN_NOTES, ai.CHNG_DESC_TXT, 
ai.EFF_DT, ai.ORIGIN, ai.UNRSLVD_ISSUE, ai.UNTL_DT, decode(ai.ADMIN_ITEM_TYP_ID , 49, 'Concept', 53, 'Value Meaning') ADMIN_ITEM_TYP_ID ,ai. CURRNT_VER_IND, ai.ADMIN_STUS_ID, 
ai.REGSTR_STUS_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, 
ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN, e.cncpt_concat_src_typ evs_src_ori,
decode(e.CNCPT_CONCAT,e.cncpt_concat_nm, null, e.cncpt_concat)  cncpt_concat, e.CNCPT_CONCAT_NM, e.CNCPT_CONCAT_DEF
from admin_item ai, nci_admin_item_Ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr ;


  CREATE OR REPLACE VIEW VW_NCI_GENERIC_DE AS
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
	    csi.cs_item_id,
	  csi.cs_item_ver_nr,
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
          group by an.item_id, an.ver_nr, csian.NCI_PUB_ID,csian.NCI_VER_NR) adef
        WHERE     admin_item.ADMIN_ITEM_TYP_ID = 4
           and ADMIN_ITEM.ITEM_Id = de.item_id
           and ADMIN_ITEM.VER_NR = DE.VER_NR
           and de.VAL_DOM_ITEM_ID = vd.ITEM_ID
	   and de.VAL_DOM_VER_NR = vd.VER_NR
	   AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
	   and admin_item.item_id = an.item_id 
	   and admin_item.ver_nr = an.ver_nr 
	   and admin_item.item_id = adef.item_id (+)
	   and admin_item.ver_nr = adef.ver_nr (+)
	   and admin_item.item_id = an.item_id (+)
	   and admin_item.ver_nr = an.ver_nr (+)
	  and csi.item_id = r.p_item_id 
	  and csi.ver_nr = r.p_item_ver_nr
	  and admin_item.item_id = r.c_item_id
	  and admin_item.ver_nr = r.c_item_ver_nr
	  and r.rel_typ_id = 65
	  and csi.item_id = an.csi_item_id (+)
	  and csi.ver_nr = an.csi_ver_nr (+)
	  and csi.item_id = adef.csi_item_id (+)
	  and csi.ver_Nr = adef.csi_ver_nr (+);

