-- Tracker 1954
alter table NCI_STG_AI_CNCPT_CREAT add (CNCPT_CONCAT_STR_1_ORI varchar2(4000), CNCPT_CONCAT_STR_2_ORI varchar2(4000));
alter table NCI_STG_AI_CNCPT_CREAT add (CURATED_NM varchar2(2000), CURATED_DEF varchar2(4000));
alter table NCI_DLOAD_HDR add (RETAIN_IND number(1) default 0);
alter table NCI_PROTCL modify (PROTCL_PHASE varchar2(3))

-- Tracker
alter table NCI_USR_CART add (CART_NM varchar2(255) default 'Default');
update NCI_USR_CART set CART_NM = 'Default';
commit;
alter table NCI_USR_CART drop primary key;

alter table NCI_USR_CART add primary key (ITEM_ID, VER_NR, CNTCT_SECU_ID, GUEST_USR_NM, CART_NM);


  CREATE OR REPLACE VIEW VW_NCI_USR_CART AS
  SELECT AI.ITEM_ID, AI.VER_NR, AI.ITEM_LONG_NM, AI.CNTXT_NM_DN, AI.ITEM_NM, AI.REGSTR_STUS_NM_DN, AI.ADMIN_STUS_NM_DN,
  AI.ADMIN_ITEM_TYP_ID,
  DECODE(AI.ADMIN_ITEM_TYP_ID, 4, 'Data Element', 54, 'Form', 52, 'Module') ADMIN_ITEM_TYP_NM,
UC.CNTCT_SECU_ID, UC.CREAT_DT, UC.CREAT_USR_ID, UC.LST_UPD_USR_ID,
UC.FLD_DELETE, UC.LST_DEL_DT, UC.S2P_TRN_DT, UC.LST_UPD_DT, UC.GUEST_USR_NM, UC.CART_NM
FROM NCI_USR_CART UC, ADMIN_ITEM AI WHERE AI.ITEM_ID = UC.ITEM_ID AND AI.VER_NR = UC.VER_NR
and admin_item_typ_id in (4,52,54,2,3);


 CREATE OR REPLACE  VIEW VW_LIST_USR_CART_NM AS
  SELECT distinct CART_NM, CART_NM CART_NM_SPEC, CNTCT_SECU_ID, CART_NM || ' : ' || CNTCT_SECU_ID CART_USR_NM, 
           user CREAT_USR_ID,
            user LST_UPD_USR_ID,
            0 FLD_DELETE,
           sysdate LST_DEL_DT,
           sysdate S2P_TRN_DT,
           sysdate LST_UPD_DT,
           sysdate CREAT_DT
           from NCI_USR_CART where nvl(fld_delete,0)  =0;
           


-- Tracker 1967, 1968
  CREATE OR REPLACE  VIEW VW_NCI_AI AS
  SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           CAST('.' || ADMIN_ITEM.ITEM_ID || '.' AS VARCHAR2(4000))    ITEM_ID_STR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.ITEM_DESC,
         trim(SUBSTR (
                 trim(ADMIN_ITEM.ITEM_LONG_NM)
              || '||'
              || trim(ADMIN_ITEM.ITEM_NM)
              || '||'
              || trim(ADMIN_ITEM.ITEM_DESC),1,
              4290))
              || '||'
              ||
              SUBSTR ( trim(REF_DESC),
             1,
              30000)                          SEARCH_STR
      FROM ADMIN_ITEM  ADMIN_ITEM,
           (  SELECT item_id,
                     ver_nr,
                     LISTAGG (trim(ref_desc),
                              '||'
                              ON OVERFLOW TRUNCATE )
                     WITHIN GROUP (ORDER BY ref_desc DESC)    ref_desc
                FROM REF, OBJ_KEY
               WHERE     REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                     AND LOWER (OBJ_KEY_DESC) LIKE '%question%'
            GROUP BY item_id, ver_nr) REF                                   --
     WHERE     ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = REF.VER_NR(+);

-- Tracker 1980
  
  CREATE OR REPLACE  VIEW VW_DE_CONC_RELEASED AS
  SELECT ADMIN_ITEM.LST_UPD_DT, DE_CONC.S2P_TRN_DT, DE_CONC.LST_DEL_DT, DE_CONC.FLD_DELETE, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.CREAT_DT, 
DE_CONC.OBJ_CLS_VER_NR, DE_CONC.OBJ_CLS_ITEM_ID, DE_CONC.PROP_ITEM_ID, DE_CONC.PROP_VER_NR, DE_CONC.CONC_DOM_ITEM_ID, DE_CONC.CONC_DOM_VER_NR, 
ADMIN_ITEM.ITEM_ID, 
ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, 
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
and ADMIN_ITEM.ADMIN_STUS_ID = 75
and DE_CONC.ITEM_ID = cde.DE_CONC_ITEM_ID and DE_CONC.VER_NR = CDE.DE_CONC_VER_NR;





--Tracker 2010 - adding CURRNT_VER_IND 
  CREATE OR REPLACE  VIEW VW_NCI_FORM_FLAT AS
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
de.ADMIN_STUS_NM_DN CDE_ADMIN_STUS_NM, nvl(de.CURRNT_VER_IND,0) CDE_CURRNT_VER_IND,
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
and air.nci_ver_nr = vv.q_ver_nr (+)
and nvl(air.fld_delete,0) = 0
and nvl(frm_mod.fld_delete,0) = 0
and nvl(vv.fld_delete,0) = 0;


  CREATE OR REPLACE  VIEW VW_NCI_MODULE_DE as
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
AIR.CREAT_DT, AIR.CREAT_USR_ID, AIR.LST_UPD_USR_ID, AIR.FLD_DELETE, AIR.LST_DEL_DT, AIR.S2P_TRN_DT, AIR.LST_UPD_DT, AIR.ITEM_LONG_NM QUEST_LONG_TXT, AIR.ITEM_NM QUEST_TXT
FROM  NCI_ADMIN_ITEM_REL_ALT_KEY AIR, ADMIN_ITEM AIM,
ADMIN_ITEM FRM, NCI_ADMIN_ITEM_REL FRM_MOD , ADMIN_ITEM DE
WHERE  AIR.REL_TYP_ID = 63
AND AIM.ITEM_ID = AIR.P_ITEM_ID AND AIM.VER_NR = AIR.P_ITEM_VER_NR
AND FRM.ITEM_ID = FRM_MOD.P_ITEM_ID AND FRM.VER_NR = FRM_MOD.P_ITEM_VER_NR AND AIM.ITEM_ID = FRM_MOD.C_ITEM_ID AND AIM.VER_NR = FRM_MOD.C_ITEM_VER_NR
AND FRM_MOD.REL_TYP_ID IN (61,62)
AND FRM.ADMIN_ITEM_TYP_ID IN ( 54,55)
AND AIR.C_ITEM_ID = DE.ITEM_ID
AND AIR.C_ITEM_VER_NR = DE.VER_NR;


  CREATE OR REPLACE  VIEW VW_ADMIN_ITEM_VM_MATCH as
  SELECT CNTXT_ITEM_ID, admin_item_typ_id, ITEM_DESC, ITEM_LONG_NM, REGSTR_STUS_ID, ITEM_ID, VER_NR, ITEM_NM, CREAT_DT, CNTXT_VER_NR, ADMIN_STUS_ID,
   CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT, NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN,
  decode(admin_item_typ_id, 49, ITEM_LONG_NM, 53, ITEM_ID, ITEM_NM)  ID_OR_CODE, decode(admin_item_typ_id, 49, 'Concepts', 53 ,'ID', 'Other') MATCH_TYP
       FROM ADMIN_ITEM where admin_item_typ_id in (49,53);
       
       
