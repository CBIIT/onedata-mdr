
  CREATE or replace VIEW VW_NCI_CRDC_DE AS
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
	   ext.csi_concat,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
	   ADMIN_ITEM.ITEM_DEEP_LINK,
           ext.USED_BY                         CNTXT_AGG,
           nvl(CRDC_NM.NM_DESC,admin_item.item_nm)                        CRDC_NM,
           nvl(CRDC_DEF.DEF_DESC , admin_item.item_desc)                       CRDC_DEF,
               CODE_INSTR_REF_DESC CRDC_CODE_INSTR,
            INSTR_REF_DESC                            CRDC_INSTR,
          EXAMPL                           CRDC_EXMPL,
            vd.VAL_DOM_TYP_ID	  FROM ADMIN_ITEM,
           NCI_ADMIN_ITEM_EXT  ext,
	      de, VALUE_DOM vd,
       (  SELECT item_id, ver_nr,  
       max(decode(upper(obj_key_Desc),'CODING INSTRUCTIONS', ref_desc) ) CODE_INSTR_REF_DESC,
 --      max(decode(upper(obj_key_Desc),'CODING INSTRUCTIONS',ref_desc) ) CODE_INSTR_REF_DESC,
       max(decode(upper(obj_key_Desc),'INSTRUCTIONS', ref_desc) ) INSTR_REF_DESC,
       max(decode(upper(obj_key_Desc),'EXAMPLE', ref_desc) ) EXAMPL
       FROM REF, OBJ_KEY WHERE REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID   and obj_key.obj_typ_id = 1
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
and ADMIN_ITEM.CNTXT_NM_DN = 'CRDC'
and admin_item.regstr_stus_id = 2;



  CREATE OR REPLACE VIEW VW_NCI_DE_VM_ALT_NMS AS
  SELECT   DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR, PV.NCI_VAL_MEAN_ITEM_ID VAL_MEAN_ITEM_ID, PV.NCI_VAL_MEAN_VER_NR VAL_MEAN_VER_NR, vm.ITEM_NM VAL_MEAN_LONG_NM, 
	PV.VAL_DOM_ITEM_ID  VAL_DOM_ITEM_ID, PV.VAL_DOM_VER_NR VAL_DOM_VER_NR ,
		an.CREAT_DT, AN.CREAT_USR_ID, AN.LST_UPD_USR_ID, greatest(nvl(AN.FLD_DELETE,0),nvl(pv.fld_delete,0)) fld_delete, 
		an.LST_DEL_DT, an.S2P_TRN_DT, AN.LST_UPD_DT,
         an.NM_DESC,  an.nm_typ_id, an.CNTXT_NM_DN VM_CNTXT_NM_DN  ,
         an.LANG_ID, an.nm_id, PV.PERM_VAL_NM, PV.PERM_VAL_DESC_TXT,
	 e.CNCPT_CONCAT
       FROM  DE, PERM_VAL PV, ALT_NMS an, ADMIN_ITEM vm, NCI_ADMIN_ITEM_EXT e where 
	PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID and
	PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR and
	PV.NCI_VAL_MEAN_ITEM_ID = an.ITEM_ID and
	PV.NCI_VAL_MEAN_VER_NR = an.VER_NR and
	PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID and
	PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR and
	PV.NCI_VAL_MEAN_ITEM_ID =e.ITEM_ID
	and PV.NCI_VAL_MEAN_VER_NR= e.VER_NR;



  CREATE OR REPLACE  VIEW VW_NCI_DE_HORT AS
  SELECT ADMIN_ITEM.ITEM_ID                ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGISTRR_CNTCT_ID,
           ADMIN_ITEM.SUBMT_CNTCT_ID,
           ADMIN_ITEM.STEWRD_CNTCT_ID,
           ADMIN_ITEM.SUBMT_ORG_ID,
           ADMIN_ITEM.STEWRD_ORG_ID,
           ADMIN_ITEM.REGSTR_AUTH_ID,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           DE.PREF_QUEST_TXT ,
           VALUE_DOM.NCI_DEC_PREC DE_PREC,
           DE.DE_CONC_ITEM_ID,
           DE.DE_CONC_VER_NR,
           DE.VAL_DOM_VER_NR,
           DE.VAL_DOM_ITEM_ID,
           DE.REP_CLS_VER_NR,
           DE.REP_CLS_ITEM_ID,
           nvl(DE.DERV_DE_IND,0) DERV_DE_IND,
           DE.DERV_MTHD,
           DE.DERV_RUL,
           DE.DERV_TYP_ID,
           DE.CONCAT_CHAR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           DE.FLD_DELETE,
           DE.LST_DEL_DT,
           DE.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID                   CREAT_USR_ID_API,
          ADMIN_ITEM.LST_UPD_USR_ID                 LST_UPD_USR_ID_API,
           ADMIN_ITEM.CREAT_DT                       CREAT_DT_API,
           ADMIN_ITEM.LST_UPD_DT                     LST_UPD_DT_API,
           VALUE_DOM.CONC_DOM_VER_NR,
           VALUE_DOM.CONC_DOM_ITEM_ID,
           VALUE_DOM.NON_ENUM_VAL_DOM_DESC,
           VALUE_DOM.UOM_ID,
           VALUE_DOM.VAL_DOM_TYP_ID          VAL_DOM_TYP_ID,
           VALUE_DOM.VAL_DOM_MIN_CHAR,
           VALUE_DOM.VAL_DOM_MAX_CHAR,
           VALUE_DOM.VAL_DOM_HIGH_VAL_NUM,
           VALUE_DOM.VAL_DOM_LOW_VAL_NUM,
           VALUE_DOM.VAL_DOM_FMT_ID,
           VALUE_DOM.CHAR_SET_ID,
           VALUE_DOM_AI.CREAT_DT                VALUE_DOM_CREAT_DT,
           VALUE_DOM_AI.CREAT_USR_ID            VALUE_DOM_USR_ID,
           VALUE_DOM_AI.LST_UPD_USR_ID          VALUE_DOM_LST_UPD_USR_ID,
           VALUE_DOM_AI.LST_UPD_DT              VALUE_DOM_LST_UPD_DT,
           VALUE_DOM_AI.ITEM_NM              VALUE_DOM_ITEM_NM,
           VALUE_DOM_AI.ITEM_LONG_NM         VALUE_DOM_ITEM_LONG_NM,
           VALUE_DOM_AI.ITEM_DESC            VALUE_DOM_ITEM_DESC,
           VALUE_DOM_AI.CNTXT_NM_DN          VALUE_DOM_CNTXT_NM,
           VALUE_DOM_AI.CURRNT_VER_IND       VALUE_DOM_CURRNT_VER_IND,
           VALUE_DOM_AI.REGSTR_STUS_NM_DN    VALUE_DOM_REGSTR_STUS_NM,
           VALUE_DOM_AI.ADMIN_STUS_NM_DN     VALUE_DOM_ADMIN_STUS_NM,
           VALUE_DOM.NCI_STD_DTTYPE_ID,
           VALUE_DOM.DTTYPE_ID,
           VALUE_DOM.NCI_DEC_PREC,
           DEC_AI.ITEM_NM                    DEC_ITEM_NM,
           DEC_AI.ITEM_LONG_NM               DEC_ITEM_LONG_NM,
           DEC_AI.ITEM_DESC                  DEC_ITEM_DESC,
           DEC_AI.CNTXT_NM_DN                DEC_CNTXT_NM,
           DEC_AI.CURRNT_VER_IND             DEC_CURRNT_VER_IND,
           DEC_AI.REGSTR_STUS_NM_DN          DEC_REGSTR_STUS_NM,
           DEC_AI.ADMIN_STUS_NM_DN           DEC_ADMIN_STUS_NM,
           DEC_AI.CREAT_DT                   DEC_CREAT_DT,
           DEC_AI.CREAT_USR_ID               DEC_USR_ID,
           DEC_AI.LST_UPD_USR_ID             DEC_LST_UPD_USR_ID,
           DEC_AI.LST_UPD_DT                 DEC_LST_UPD_DT,
           DE_CONC.OBJ_CLS_ITEM_ID,
           DE_CONC.OBJ_CLS_VER_NR,
           OC.ITEM_NM                        OBJ_CLS_ITEM_NM,
           OC.ITEM_LONG_NM                   OBJ_CLS_ITEM_LONG_NM,
           CONOC.CNCPT_CONCAT 			OC_CNCPT_CONCAT,
           CONOC.CNCPT_CONCAT_NM			OC_CNCPT_CONCAT_NM,
           PROP.ITEM_NM                      PROP_ITEM_NM,
           PROP.ITEM_LONG_NM                 PROP_ITEM_LONG_NM,
           DE_CONC.PROP_ITEM_ID,
           DE_CONC.PROP_VER_NR,
           CONPROP.CNCPT_CONCAT			PROP_CNCPT_CONCAT,
           CONPROP.CNCPT_CONCAT_NM			PROP_CNCPT_CONCAT_NM	,
           DE_CONC.CONC_DOM_ITEM_ID          DEC_CD_ITEM_ID,
           DE_CONC.CONC_DOM_VER_NR           DEC_CD_VER_NR,
           DEC_CD.ITEM_NM                    DEC_CD_ITEM_NM,
           DEC_CD.ITEM_LONG_NM               DEC_CD_ITEM_LONG_NM,
           DEC_CD.ITEM_DESC                  DEC_CD_ITEM_DESC,
           DEC_CD.CNTXT_NM_DN                DEC_CD_CNTXT_NM,
           DEC_CD.CURRNT_VER_IND             DEC_CD_CURRNT_VER_IND,
           DEC_CD.REGSTR_STUS_NM_DN          DEC_CD_REGSTR_STUS_NM,
           DEC_CD.ADMIN_STUS_NM_DN           DEC_CD_ADMIN_STUS_NM,
           CD_AI.ITEM_NM                     CD_ITEM_NM,
           CD_AI.ITEM_LONG_NM                CD_ITEM_LONG_NM,
           CD_AI.ITEM_DESC                   CD_ITEM_DESC,
           CD_AI.CNTXT_NM_DN                 CD_CNTXT_NM,
           CD_AI.CURRNT_VER_IND              CD_CURRNT_VER_IND,
           CD_AI.REGSTR_STUS_NM_DN           CD_REGSTR_STUS_NM,
           CD_AI.ADMIN_STUS_NM_DN            CD_ADMIN_STUS_NM,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
           ''                                CNTXT_AGG,
             SYSDATE
           - GREATEST (DE.LST_UPD_DT,
                       admin_item.lst_upd_dt,
                       Value_dom.LST_UPD_DT,
                       dec_ai.LST_UPD_DT)    LST_UPD_CHG_DAYS
      FROM ADMIN_ITEM,
           DE,
           VALUE_DOM,
           ADMIN_ITEM          VALUE_DOM_AI,
           ADMIN_ITEM          DEC_AI,
           DE_CONC,
           VW_CONC_DOM         DEC_CD,
           VW_CONC_DOM         CD_AI,
           ADMIN_ITEM          OC,
           ADMIN_ITEM          PROP,
           NCI_ADMIN_ITEM_EXT  CONOC,
           NCI_ADMIN_ITEM_EXT  CONPROP
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
           AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
           AND DE.VER_NR = ADMIN_ITEM.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM_AI.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM_AI.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND DE.DE_CONC_ITEM_ID = DEC_AI.ITEM_ID
           AND DE.DE_CONC_VER_NR = DEC_AI.VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE_CONC.OBJ_CLS_ITEM_ID = OC.ITEM_ID
           AND DE_CONC.OBJ_CLS_VER_NR = OC.VER_NR
           AND DE_CONC.PROP_ITEM_ID = PROP.ITEM_ID
           AND DE_CONC.PROP_VER_NR = PROP.VER_NR
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
           AND DE_CONC.CONC_DOM_ITEM_ID = DEC_CD.ITEM_ID
           AND DE_CONC.CONC_DOM_VER_NR = DEC_CD.VER_NR
           AND VALUE_DOM.CONC_DOM_ITEM_ID = CD_AI.ITEM_ID
           AND VALUE_DOM.CONC_DOM_VER_NR = CD_AI.VER_NR
           AND OC.ITEM_ID = CONOC.ITEM_ID
           AND OC.VER_NR = CONOC.VER_NR
           AND PROP.ITEM_ID = CONPROP.ITEM_ID
           AND PROP.VER_NR = CONPROP.VER_NR;

alter table NCI_USR_CART add RETAIN_IND number(1);

  CREATE OR REPLACE  VIEW VW_NCI_USR_CART AS
  SELECT AI.ITEM_ID, AI.VER_NR, AI.ITEM_LONG_NM, AI.CNTXT_NM_DN, AI.ITEM_NM, AI.REGSTR_STUS_NM_DN, AI.ADMIN_STUS_NM_DN,
  AI.ADMIN_ITEM_TYP_ID,
  ok.OBJ_KEY_DESC ADMIN_ITEM_TYP_NM,
UC.CNTCT_SECU_ID, UC.CREAT_DT, UC.CREAT_USR_ID, UC.LST_UPD_USR_ID,
UC.FLD_DELETE, UC.LST_DEL_DT, UC.S2P_TRN_DT, UC.LST_UPD_DT, UC.GUEST_USR_NM, UC.CART_NM, UC.RETAIN_IND,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_cntct_secu_id=' || UC.CNTCT_SECU_ID || '\&p_guest_usr_nm=' || UC.GUEST_USR_NM ||'\&p_cart_nm=' || UC.CART_NM || '\&formatid=104\&type=usr\\Download_ALL_CDE_In_Cart_Legacy_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_cntct_secu_id=' || UC.CNTCT_SECU_ID || '\&p_guest_usr_nm=' || UC.GUEST_USR_NM ||'\&p_cart_nm=' || UC.CART_NM || '\&formatid=103\&type=usr\\Download_ALL_CDE_In_Cart_Legacy_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_cntct_secu_id=' || UC.CNTCT_SECU_ID || '\&p_guest_usr_nm=' || UC.GUEST_USR_NM ||'\&p_cart_nm=' || UC.CART_NM || '\&formatid=114\&type=usr\\Download_ALL_CDE_In_Cart_Prior_Legacy_XML' ITEM_RPT_PRIOR_EXCEL
FROM NCI_USR_CART UC, ADMIN_ITEM AI , OBJ_KEY ok, NCI_MDR_CNTRL c WHERE AI.ITEM_ID = UC.ITEM_ID AND AI.VER_NR = UC.VER_NR and ai.admin_item_typ_id = ok.obj_key_id and ok.obj_typ_id = 4
and admin_item_typ_id in (4,52,54,2,3) and c.param_nm='DOWNLOAD_HOST';

  CREATE MATERIALIZED VIEW MVW_CSI_NODE_DE_REL AS 
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
           de.PREF_QUEST_TXT, 
	   e.USED_BY,
	   'CSI' LVL
           FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, de , nci_admin_item_ext e
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR and ai.admin_item_typ_id = 4 and ak.rel_typ_id = 65 and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn not like '%RETIRED%'
and ai.admin_stus_nm_dn not like '%NON-CMPLNT%' and ai.CNTXT_NM_DN not in ('TEST','TRAINING')
and nvl(ai.CURRNT_VER_IND,0) = 1 and nvl(ak.fld_delete,0) = 0
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
e.USED_BY, 'CS' LVL
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi, de, nci_admin_item_Ext e
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ak.P_ITEM_ID = csi.ITEM_ID
           AND ak.P_ITEM_VER_NR = csi.VER_NR and ai.admin_item_typ_id = 4 and ak.rel_typ_id = 65 and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn not like '%RETIRED%'
and ai.admin_stus_nm_dn not like '%NON-CMPLNT%' and ai.CNTXT_NM_DN not in ('TEST','TRAINING')
and nvl(ai.CURRNT_VER_IND,0) = 1 
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
e.USED_BY, 'Context' LVL
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi, VW_CLSFCTN_SCHM cs, de, nci_admin_item_ext e
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ak.P_ITEM_ID = csi.ITEM_ID
           AND ak.P_ITEM_VER_NR = csi.VER_NR and ai.admin_item_typ_id = 4 and ak.rel_typ_id = 65
and csi.CS_ITEM_ID = cs.ITEM_ID and csi.CS_ITEM_VER_NR = cs.VER_NR and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn not like '%RETIRED%'
and ai.admin_stus_nm_dn not like '%NON-CMPLNT%' and ai.CNTXT_NM_DN not in ('TEST','TRAINING')
and nvl(ai.CURRNT_VER_IND,0) = 1 
;


--drop materialized view MVW_CSI_TREE_CDE ;

set escape on;

  CREATE MATERIALIZED VIEW MVW_CSI_TREE_CDE   AS 
  select 98 LVL, null P_ITEM_ID, null P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ITEM_LONG_NM,  ITEM_NM || ': ' 
|| ITEM_DESC  || ' (' || y.cnt || ')' ITEM_NM , ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=104\&type=csi\\Legacy_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=103\&type=csi\\Legacy_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE’s CDEs SWITCH “Details” TO  "View Associated CDEs”. ********' CHNG_NOTES
from 
ADMIN_ITEM ai, (select x.p_item_id, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='Context' group by x.p_item_id , 
x.p_item_ver_nr) y , nci_mdr_cntrl c
 where ADMIN_ITEM_TYP_ID = 8 and item_id = y.p_item_id (+) and ver_nr = y.p_item_ver_nr (+) and cntxt_nm_dn not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 union
select 99 LVL, CNTXT_ITEM_ID P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, 'CS - ' || 
ITEM_NM || ': ' || ITEM_DESC  || ' (' || y.cnt || ')', ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\\Legacy_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\\Legacy_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE’s CDEs SWITCH “Details” TO  "View Associated CDEs”. ********' CHNG_NOTES
 from 
ADMIN_ITEM ai, (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CS' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c
 where ADMIN_ITEM_TYP_ID = 9 and item_id = y.p_item_id and ver_nr = y.p_item_ver_nr and admin_stus_nm_dn ='RELEASED' and ai.cntxt_nm_dn not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 union
  select 100 LVL, csi.CS_ITEM_ID P_ITEM_ID, csi.CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
  'CSI - ' || ai.ITEM_NM ||  ': ' || ITEM_DESC  || ' (' || y.cnt || ')' , 
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
 c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\\Legacy_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\\Legacy_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE’s CDEs SWITCH “Details” TO  "View Associated CDEs”. ********'  CHNG_NOTES
from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CSI' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.p_item_id and ai.ver_nr = y.p_item_ver_nr and ai.cntxt_nm_dn not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 --and ai.admin_stus_nm_dn not like '%RETIRED%'
 union
 select 100 LVL, csi.P_ITEM_ID P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
  'CSI - ' || ai.ITEM_NM ||  ': ' || ITEM_DESC  || ' (' || y.cnt || ')' , 
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\\Legacy_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\\Legacy_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE’s CDEs SWITCH “Details” TO  "View Associated CDEs”. ********' CHNG_NOTES
 from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CSI' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.p_item_id and ai.ver_nr = y.p_item_ver_nr and ai.cntxt_nm_dn not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST';
 --and ai.admin_stus_nm_dn not like '%RETIRED%'
 
 
 

	   
	   
  CREATE OR REPLACE  VIEW VW_LIST_USR_CART_NM AS
  SELECT CART_NM, CART_NM CART_NM_SPEC, CNTCT_SECU_ID, GUEST_USR_NM, CART_NM || ' : ' || CNTCT_SECU_ID CART_USR_NM, max(nvl(retain_ind,0)) RETAIN_IND, 
  c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_cntct_secu_id=' || trim(replace(CNTCT_SECU_ID,' ' ,'%20')) || '\&p_guest_usr_nm=' || trim(replace(GUEST_USR_NM,' ' ,'%20')) ||'\&p_cart_nm=' || trim(replace(CART_NM,' ' ,'%20')) || '\&formatid=104\&type=usr\\Legacy_CDE_XML' ITEM_RPT_URL ,
  c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_cntct_secu_id=' || trim(replace(CNTCT_SECU_ID,' ' ,'%20')) || '\&p_guest_usr_nm=' ||  trim(replace(GUEST_USR_NM,' ' ,'%20')) ||'\&p_cart_nm=' || trim(replace(CART_NM,' ' ,'%20')) || '\&formatid=103\&type=usr\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
  c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_cntct_secu_id=' || trim(replace(CNTCT_SECU_ID,' ' ,'%20')) || '\&p_guest_usr_nm=' ||  trim(replace(GUEST_USR_NM,' ' ,'%20')) ||'\&p_cart_nm=' || trim(replace(CART_NM,' ' ,'%20')) || '\&formatid=114\&type=usr\\Legacy_Prior_CDE_Excel' ITEM_RPT_PRIOR_EXCEL ,
           user CREAT_USR_ID,
            user LST_UPD_USR_ID,
            0 FLD_DELETE,
           sysdate LST_DEL_DT,
           sysdate S2P_TRN_DT,
           sysdate LST_UPD_DT,
           sysdate CREAT_DT
           from NCI_USR_CART , NCI_MDR_CNTRL c where nvl(fld_delete,0)  =0  and  c.param_nm='DOWNLOAD_HOST' group by CART_NM, CNTCT_SECU_ID, GUEST_USR_NM , c.param_val;

drop materialized view vw_cntxt;

  CREATE MATERIALIZED VIEW VW_CNTXT 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH FORCE ON COMMIT
  AS SELECT ADMIN_ITEM.ITEM_ID,
       ADMIN_ITEM.VER_NR,
       ADMIN_ITEM.ITEM_NM,
       ADMIN_ITEM.ITEM_LONG_NM,
       ADMIN_ITEM.ITEM_DESC,
       ADMIN_ITEM.CNTXT_NM_DN,
       ADMIN_ITEM.CURRNT_VER_IND,
       ADMIN_ITEM.REGSTR_STUS_NM_DN,
       ADMIN_ITEM.ADMIN_STUS_NM_DN,
       ADMIN_ITEM.CREAT_DT,
       ADMIN_ITEM.CREAT_USR_ID,
       ADMIN_ITEM.LST_UPD_USR_ID,
       ADMIN_ITEM.FLD_DELETE,
       ADMIN_ITEM.LST_DEL_DT,
       ADMIN_ITEM.S2P_TRN_DT,
       ADMIN_ITEM.LST_UPD_DT,
       ADMIN_ITEM.NCI_IDSEQ,
 C.NCI_PRG_AREA_ID
  FROM ADMIN_ITEM, CNTXT C
 WHERE     ADMIN_ITEM_TYP_ID = 8
       AND ADMIN_ITEM.ITEM_ID = C.ITEM_ID
       AND ADMIN_ITEM.VER_NR = C.VER_NR;

