alter table nci_mec_map add (TGT_MEC_ID_DERV number);


  CREATE OR REPLACE VIEW VW_CNCPT_XMAP As
  SELECT XMAP.ITEM_ID, XMAP.VER_NR, 
  max(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_Cd,'')) ICD_O_CODE,
  max(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_desc,'')) ICD_O_DESC,
  max(decode(o.obj_key_desc, 'SNOMED-CT_CODE', XMAP_Cd,'')) SNOMED_CODE,
  max(decode(o.obj_key_desc, 'SNOMED-CT_CODE', XMAP_DESC,'')) SNOMED_DESC,
  max(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_Cd,'')) MEDDRA_CODE,
  max(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_DESC,'')) MEDDRA_DESC,
  max(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_Cd,'')) LOINC_CODE,
  max(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_DESC,'')) LOINC_DESC,
  max(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_Cd,'')) HUGO_CODE,
  max(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_desc,'')) HUGO_CODE_DESC,
  max(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_Cd,'')) ICD_10_CM_CODE,
  max(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_DESC,'')) ICD_10_CM_DESC,
	    max(decode(o.obj_key_desc, 'OMOP_CODE', XMAP_Cd,'')) OMOP_CODE,
  max(decode(o.obj_key_desc, 'OMOP_CODE', XMAP_DESC,'')) OMOP_DESC,
	    max(decode(o.obj_key_desc, 'UBERON_CODE', XMAP_Cd,'')) UBERON_CODE,
  max(decode(o.obj_key_desc, 'UBERON_CODE', XMAP_DESC,'')) UBERON_DESC,
 max(decode(o.obj_key_desc, 'NCI_META_CUI', XMAP_Cd,'')) META_CUI_CODE,
  max(decode(o.obj_key_desc, 'NCI_META_CUI', XMAP_DESC,'')) META_CUI_DESC,
	  max(decode(o.obj_key_desc, 'MED_RT_CODE', XMAP_Cd,'')) MED_RT_CODE,
  max(decode(o.obj_key_desc, 'MED_RT_CODE', XMAP_DESC,'')) MED_RT_DESC,
	  max(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', XMAP_Cd,'')) ICD_10_PCS_CODE,
  max(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', XMAP_DESC,'')) ICD_10_PCS_DESC,
	  max(decode(o.obj_key_desc, 'NCBI_CODE', XMAP_Cd,'')) NCBI_CODE,
  max(decode(o.obj_key_desc, 'NCBI_CODE', XMAP_DESC,'')) NCBI_DESC,
	  max(decode(o.obj_key_desc, 'HPO_CODE', XMAP_Cd,'')) HPO_CODE,
  max(decode(o.obj_key_desc, 'HPO_CODE', XMAP_DESC,'')) HPO_DESC,
	  max(decode(o.obj_key_desc, 'HCPCS_CODE', XMAP_Cd,'')) HCPCS_CODE,
  max(decode(o.obj_key_desc, 'HCPCS_CODE', XMAP_DESC,'')) HCPCS_DESC,
   max(decode(o.obj_key_desc, 'ICD-O_CODE', TERM_TYP,'')) ICD_O_TERM_TYP,
  max(decode(o.obj_key_desc, 'SNOMED-CT_CODE', TERM_TYP,'')) SNOMED_TERM_TYP,
  max(decode(o.obj_key_desc, 'MEDDRA_CODE', TERM_TYP,'')) MEDDRA_TERM_TYP,
  max(decode(o.obj_key_desc, 'LOINC_CODE', TERM_TYP,'')) LOINC_TERM_TYP,
  max(decode(o.obj_key_desc, 'HUGO_CODE', TERM_TYP,'')) HUGO_TERM_TYP,
  max(decode(o.obj_key_desc, 'ICD-10-CM_CODE', TERM_TYP,'')) ICD_10_CM_TERM_TYP,
 max(decode(o.obj_key_desc, 'NCI_META_CUI', TERM_TYP,'')) META_CUI_TERM_TYP,
	  max(decode(o.obj_key_desc, 'MED_RT_CODE', TERM_TYP,'')) MED_RT_TERM_TYP,
	  max(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', TERM_TYP,'')) ICD_10_PCS_TERM_TYP,
	  max(decode(o.obj_key_desc, 'NCBI_CODE', TERM_TYP,'')) NCBI_TERM_TYP,
	  max(decode(o.obj_key_desc, 'HPO_CODE', TERM_TYP,'')) HPO_TERM_TYP,
	  max(decode(o.obj_key_desc, 'HCPCS_CODE', TERM_TYP,'')) HCPCS_TERM_TYP,
  sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT 
       FROM NCI_ADMIN_ITEM_XMAP xmap, obj_key o
       WHERE o.obj_typ_id = 23 and o.obj_key_id = xmap.evs_src_id and pref_ind = 1
       group by xmap.item_id, xmap.ver_nr;


insert into obj_key (obj_typ_id, obj_key_desc, obj_key_Def) values (23,'UBERON_CODE','Uberon is an integrated cross-species ontology covering anatomical structures in animals.');commit;

alter table NCI_STG_CDE_CREAT add (ORIGIN_ID integer, IMP_ORIGIN varchar2(1000));


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
	  VALUE_DOM.TERM_CNCPT_ITEM_ID,
	  VALUE_DOM.TERM_CNCPT_VER_NR,
	  VALUE_DOM.TERM_USE_TYP,
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


drop materialized view vw_cncpt;

  CREATE MATERIALIZED VIEW VW_CNCPT 
  AS SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM,  ADMIN_ITEM.ITEM_LONG_NM, '.' ||ADMIN_ITEM.ITEM_NM ||'.' ITEM_NM_PERIOD,  '.' ||ADMIN_ITEM.ITEM_LONG_NM || '.' ITEM_LONG_NM_PERIOD, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CREATION_DT, 
ADMIN_ITEM.EFF_DT, ADMIN_ITEM.ORIGIN,  ADMIN_ITEM.UNTL_DT,  ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CNTXT_ITEM_ID,
ADMIN_ITEM.CNTXT_VER_NR, ADMIN_ITEM.CNTXT_NM_DN,
 ADMIN_ITEM.CREAT_DT, ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, ADMIN_ITEM.LST_UPD_DT, CNCPT.PRMRY_CNCPT_IND,
nvl(decode(trim(ADMIN_ITEM.DEF_SRC), 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') DEF_SRC, e.CNCPT_CONCAT_WITH_INT,
		      decode(trim(OBJ_KEY.OBJ_KEY_DESC), 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC) EVS_SRC,
		      trim(OBJ_KEY.OBJ_KEY_DESC) EVS_SRC_ORI,
			cncpt.evs_Src_id,
		      nvl(decode(trim(ADMIN_ITEM.DEF_SRC), 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') || '|' ||
		      nvl(decode(trim(OBJ_KEY.OBJ_KEY_DESC), 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC), 'No EVS Source') DEF_EVS_SRC,
        substr(ADMIN_ITEM.ITEM_NM || ' | ' || a.SYN, 1, 4000) SYN,substr(a.SYN_MTCH_TERM,1,4000) SYN_MTCH_TERM, MTCH_TERM, MTCH_TERM_ADV
              FROM ADMIN_ITEM,  CNCPT, nci_admin_item_ext e, OBJ_KEY, (select item_id, ver_nr,   LISTAGG(nm_desc, ' | ') WITHIN GROUP (ORDER by ITEM_ID) AS SYN,
			        LISTAGG(MTCH_TERM_ADV , ' | ') WITHIN GROUP (ORDER by ITEM_ID) AS SYN_MTCH_TERM from ALT_NMS a group by item_id, ver_nr) a
       WHERE ADMIN_ITEM_TYP_ID = 49 and ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID and ADMIN_ITEM.VER_NR = CNCPT.VER_NR
       and admin_item.item_id = e.item_id and admin_item.ver_nr = e.ver_nr
	and cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID (+) and admin_item.admin_stus_nm_dn = 'RELEASED' 
	and ADMIN_ITEM.ITEM_ID = a.ITEM_ID (+) and ADMIN_ITEM.VER_NR = a.VER_NR (+);


  CREATE OR REPLACE VIEW VW_NCI_DE_HORT_FOR_COMP AS
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
	   VALUE_DOM.TERM_CNCPT_ITEM_ID,
	  VALUE_DOM.TERM_CNCPT_VER_NR,
	  VALUE_DOM.TERM_USE_TYP,
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
           CONRT.CNCPT_CONCAT			REP_TERM_CNCPT_CONCAT,
           CONRT.CNCPT_CONCAT_NM			REP_TERM_CNCPT_CONCAT_NM	,
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
           NCI_ADMIN_ITEM_EXT  CONPROP,
           NCI_ADMIN_ITEM_EXT  CONRT
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
           AND PROP.VER_NR = CONPROP.VER_NR
	     AND VALUE_DOM.REP_CLS_ITEM_ID = CONRT.ITEM_ID
           AND VALUE_DOM.REP_CLS_VER_NR = CONRT.VER_NR;


  CREATE OR REPLACE  VIEW VW_VALUE_DOM_COMP AS
  select ai.item_nm, ai.item_long_nm, ai.admin_stus_nm_dn, ai.regstr_stus_nm_dn, ai.cntxt_nm_dn, v."NON_ENUM_VAL_DOM_DESC",v."DTTYPE_ID",v."VAL_DOM_MAX_CHAR",v."VAL_DOM_TYP_ID",v."UOM_ID",v."CREAT_DT",v."CONC_DOM_VER_NR",
	v."CREAT_USR_ID",v."CONC_DOM_ITEM_ID",v."LST_UPD_USR_ID",v."REP_CLS_VER_NR",v."FLD_DELETE",v."REP_CLS_ITEM_ID",v."LST_DEL_DT",v."VER_NR",v."S2P_TRN_DT",
	v."ITEM_ID",v."LST_UPD_DT",v."VAL_DOM_MIN_CHAR",v."VAL_DOM_FMT_ID",v."CHAR_SET_ID",v."VAL_DOM_SYS_NM",v."VAL_DOM_HIGH_VAL_NUM",v."VAL_DOM_LOW_VAL_NUM",
	v."NCI_DEC_PREC",v."NCI_STD_DTTYPE_ID"  ,v.TERM_CNCPT_ITEM_ID,v.TERM_CNCPT_VER_NR,v.TERM_USE_TYP
from value_dom v, admin_item ai
where v.item_id = ai.item_id and v.ver_nr = ai.ver_nr;

alter table NCI_STG_CDE_CREAT add (TERM_CNCPT_ITEM_ID number, TERM_CNCPT_VER_NR number, TERM_USE_TYP integer, imp_ref_term varchar2(255), imp_term_use_typ varchar2(255));

alter table NCI_STG_CDE_CREAT add (CREAT_PV_VM number(1));

alter table NCI_STG_CDE_CREAT add (IMP_CREAT_PV_VM varchar2(10));


create materialized view vw_val_dom_ref_term as 
select
vd.item_id, vd.ver_nr, vd.term_cncpt_item_id, vd.term_cncpt_ver_nr, nvl(a.nm_desc, c.item_nm) term_name from
value_dom vd, vw_cncpt c, alt_nms a, (select obj_key_id from obj_key where obj_typ_id = 11 and obj_key_desc = 'Ref Term Short Name') o
where  vd.val_dom_typ_id = 16 and vd.term_cncpt_item_id = c.item_id and vd.term_cncpt_ver_nr = c.ver_nr and 
vd.term_cncpt_item_id = a.item_id (+) and vd.term_cncpt_ver_nr = a.ver_nr (+) and a.nm_typ_id = o.obj_key_id (+);

alter table value_dom add (PRNT_SUBSET_ITEM_ID number, PRNT_SUBSET_VER_NR number(4,2),SUBSET_DESC varchar2(100));


  CREATE OR REPLACE  VIEW VW_VALUE_DOM AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN,  ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
		      ADMIN_ITEM.CURRNT_VER_IND, VALUE_DOM.DTTYPE_ID, VALUE_DOM.VAL_DOM_MAX_CHAR, VALUE_DOM.CONC_DOM_VER_NR, VALUE_DOM.CONC_DOM_ITEM_ID, 
VALUE_DOM.NON_ENUM_VAL_DOM_DESC, VALUE_DOM.UOM_ID, VALUE_DOM.VAL_DOM_TYP_ID, VALUE_DOM.VAL_DOM_MIN_CHAR, VALUE_DOM.VAL_DOM_FMT_ID, 
VALUE_DOM.CHAR_SET_ID, VALUE_DOM.CREAT_DT, VALUE_DOM.CREAT_USR_ID, VALUE_DOM.LST_UPD_USR_ID, 
VALUE_DOM.FLD_DELETE, VALUE_DOM.LST_DEL_DT, VALUE_DOM.S2P_TRN_DT, VALUE_DOM.LST_UPD_DT , RC.ITEM_NM  REP_TERM_ITEM_NM,
	  value_dom.NCI_STD_DTTYPE_ID, term.term_name
FROM ADMIN_ITEM, VALUE_DOM, VW_REP_CLS RC, vw_val_dom_ref_term term
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 3
AND ADMIN_ITEM.ITEM_ID = VALUE_DOM.ITEM_ID
AND ADMIN_ITEM.VER_NR=VALUE_DOM.VER_NR and
VALUE_DOM.REP_CLS_ITEM_ID = RC.ITEM_ID (+) and 
VALUE_DOM.REP_CLS_VER_NR = RC.VER_NR (+)
and
VALUE_DOM.ITEM_ID = TERM.ITEM_ID (+) and 
VALUE_DOM.VER_NR = TERM.VER_NR (+)
;

  CREATE OR REPLACE  VIEW VW_NCI_MEC AS
  select m.item_id mdl_item_id, m.ver_nr mdl_ver_nr, m.item_nm mdl_item_nm, me.item_id ME_ITEM_ID, me.ver_nr me_VER_NR,
	me.ITEM_LONG_NM me_item_nm, me.ITEM_PHY_OBJ_NM me_phy_nm, mec."MEC_ID",mec."MDL_ELMNT_ITEM_ID",mec."MDL_ELMNT_VER_NR",mec."MEC_TYP_ID",mec."CREAT_DT",
mec."CREAT_USR_ID",mec."LST_UPD_USR_ID",mec."FLD_DELETE", mec.char_ord, mec.pk_ind,
	  mec."LST_DEL_DT",mec."S2P_TRN_DT",mec."LST_UPD_DT",mec."SRC_DTTYPE",mec."STD_DTTYPE_ID",mec."SRC_MAX_CHAR",mec."SRC_MIN_CHAR",
vd."VAL_DOM_TYP_ID",mec."SRC_UOM",mec."UOM_ID",mec."SRC_DEFLT_VAL",mec."SRC_ENUM_SRC",mec."DE_CONC_ITEM_ID",mec."DE_CONC_VER_NR",
mec."VAL_DOM_ITEM_ID",mec."VAL_DOM_VER_NR",mec."NUM_PV",mec."MEC_LONG_NM",mec."MEC_PHY_NM",mec."MEC_DESC",mec."CDE_ITEM_ID",mec."CDE_VER_NR",
decode(vd.val_dom_typ_id, 16, 'Enumerated by Reference', 17, 'Enumerated',18,'Non-enumerated','') VAL_DOM_TYP_DESC,
vd.TERM_CNCPT_ITEM_ID,
vd.TERM_CNCPT_VER_NR,
nvl(term.term_name, cncpt.ITEM_NM)  TERM_CNCPT_DESC
	from admin_item m, NCI_MDL_ELMNT me,NCI_MDL_ELMNT_CHAR mec, value_dom vd, vw_cncpt cncpt, vw_val_dom_ref_term term
	where m.item_id = me.mdl_item_id and m.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.MDL_ELMNT_ITEM_ID
	and me.ver_nr = mec.MDL_ELMNT_VER_NR and m.admin_item_typ_id = 57
	  and mec.val_dom_item_id = vd.item_id(+) and mec.val_dom_ver_nr = vd.ver_nr(+)
and vd.TERM_CNCPT_ITEM_ID = cncpt.item_id (+)
and vd.term_cncpt_ver_nr = cncpt.ver_nr (+)
and vd.ITEM_ID = term.item_id (+)
and vd.ver_nr = term.ver_nr (+);



   


  CREATE OR REPLACE VIEW VW_MDL_MAP_FLAT AS
  select  map.MDL_MAP_ITEM_ID "Model Map ID",
         map.mdl_map_ver_nr "Model Map Version",
       m.ITEM_NM "Model Map Name",
       m.ITEM_NM_CURATED "Model Map Generated Name",
 m.ADMIN_STUS_NM_DN "Model Map Status",
         m.REGSTR_STUS_NM_DN "Model Map Registration Status",
           m.CNTXT_NM_DN "Model Map Context",
        m.CURRNT_VER_IND "Model Map Latest Version Indicator",
        s.item_id "Source Model Public ID",
        s.ver_nr "Source Model Version", 
        s.item_nm "Source Model Name", 
         s.ADMIN_STUS_NM_DN "Source Model Status",
         s.CNTXT_NM_DN "Source Model Context",
    t.item_id "Target Model Public ID", 
        t.ver_nr "Target Model Version", 
        t.item_nm "Target Model Name",  
         t.ADMIN_STUS_NM_DN "Target Model Status",
           t.CNTXT_NM_DN "Target Model Context",
   --   map.MECM_ID "Rule ID",
        map.mec_map_nm "Characteristic Group Name",
        map.MEC_GRP_RUL_NBR "Derivation Group Nbr",
       crd.obj_key_desc "Mapping Cardinality",
   decode(nvl(map.VAL_MAP_CREATE_IND,0),1, 'Yes','No') "Values Mapped Indicator",
        sme.ITEM_PHY_OBJ_NM "Source Element Physical Name", 
        smec."MEC_PHY_NM" "Source Characteristic Physical Name", 
	smec.char_ord "Source Char Order",        
smec."CDE_ITEM_ID" "Source CDE Public ID",
        smec."CDE_VER_NR" "Source CDE Version",
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "Source VD Type",
          src_func.obj_key_Desc "Source Function",
	--map.SRC_FUNC_PARAM "Source Function Parameter",
	   map.SRC_VAL "Source Value",
        tme.ITEM_PHY_OBJ_NM "Target Element Physical Name", 
       tmec.char_ord "Target Char Order",        
        tmec."MEC_PHY_NM" "Target Characteristic Physical Name", 
        tmec."CDE_ITEM_ID" "Target CDE Public ID",
        tmec."CDE_VER_NR" "Target CDE Version" ,
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "Target VD Type",
       tgt_func.obj_key_Desc "Target Function",
	map.TGT_FUNC_PARAM "Target Function Parameter",
        map.TGT_VAL "Target Value",
        map.mec_sub_grp_nbr "Group Order",
        map.mec_map_notes "Transformation Notes",
        map.MEC_MAP_NOTES "Transformation Rule",
        map.TRANS_RUL_NOT "Transformation Rule Notation",
        deg.obj_key_Desc "Mapping Type",
        map.valid_pltform	   "Validation Platform",
        org.org_nm "Provenance Organization",
        c.PRSN_FULL_NM_DERV  "Provenance Contact",
        --map.prov_cntct_id mec_map_prov_cntct_id, 
        map.prov_rsn_txt "Provenance Reason",
        map.prov_typ_rvw_txt "Provenance Type of Review",
        map.prov_rvw_dt "Provenance Review Date",   
        map.prov_aprv_dt "Provenance Approval Date",
	    m.creat_dt "Model Map Create Date",
	  m.creat_usr_id "Model Map Create User",	  
	  m.lst_upd_dt "Model Map Last Update Date",
	  m.lst_upd_usr_id "Model Map Last Update User",	  
	  map.creat_dt "Characteristic Map Create Date",
	  map.creat_usr_id "Characteristic Map Create User",	  
	  map.lst_upd_dt "Characteristic Map Last Update Date",
	  map.lst_upd_usr_id "Characteristic Map Last Update User" 
        --map.prov_notes "Provenance Notes"
	from admin_item s, NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, admin_item t, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
admin_item m,
	  obj_key crd,
	  obj_key deg,
	  nci_org org,
 obj_key src_func,
	  obj_key tgt_func,
	  obj_key op,
         value_dom svd,
value_dom tvd,
    nci_prsn c
	where s.item_id = sme.mdl_item_id and s.ver_nr = sme.mdl_item_ver_nr and sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and s.admin_item_typ_id = 57 and
	  t.item_id = tme.mdl_item_id and t.ver_nr = tme.mdl_item_ver_nr and tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR and t.admin_item_typ_id = 57 and
	   smec.MEC_ID = map.SRC_MEC_ID and tmec.mec_id = map.TGT_MEC_ID and
map.mdl_map_item_id = m.item_id and map.mdl_map_ver_nr = m.ver_nr 
	  and map.map_deg = deg.obj_key_id (+)
 and map.src_func_id= src_func.obj_key_id (+)
	  and map.tgt_func_id= tgt_func.obj_key_id (+)
	  and map.prov_org_id = org.entty_id (+)
	  and map.crdnlity_id = crd.obj_key_id (+)
 and map.op_id = op.obj_key_id (+)
and map.prov_cntct_id  = c.entty_ID (+)
          and smec.val_dom_item_id = svd.item_id (+)
	  and smec.val_dom_ver_nr = svd.ver_nr (+)
	  and tmec.val_dom_item_id = tvd.item_id (+)
 	  and tmec.val_dom_ver_nr = tvd.ver_nr (+);



  CREATE OR REPLACE  VIEW VW_MDL_VAL_MAP_FLAT AS
  select  map.MDL_MAP_ITEM_ID "Model Map ID",
         map.mdl_map_ver_nr "Model Map Version",
      m.ITEM_NM "Model Map Name",
 m.ITEM_NM_CURATED "Model Map Generated Name",
    m.ADMIN_STUS_NM_DN "Model Map Status",
         m.REGSTR_STUS_NM_DN "Model Map Registration Status",
              m.CNTXT_NM_DN "Model Map Context",
       m.CURRNT_VER_IND "Model Map Latest Version Indicator",
       s.item_id  "Source Model Public ID",
	  s.ver_nr  "Source Model Version", 
	  s.item_nm  "Source Model Name",
        s.CNTXT_NM_DN "Source Model Context",
 	  --s.item_desc  "Source Model Definition", --REMOVED
      --s.cntxt_nm_dn "Source Model Context",  --REMOVED
	  sme.item_id "Source Element ID", 
  sme.ver_nr "Source Element Version",
	--sme.ITEM_LONG_NM "Source Element Name",  --REMOVED
	  sme.ITEM_PHY_OBJ_NM "Source Element Physical Name", 
	--  smec."MEC_ID" SRC_MEC_ID, 
	 -- smec."MEC_TYP_ID" SRC_MEC_TYP_ID,
	  --map."CREAT_DT",map."CREAT_USR_ID",map."LST_UPD_USR_ID",map."FLD_DELETE",map."LST_DEL_DT",map."S2P_TRN_DT",map."LST_UPD_DT",
	  -- smec."DE_CONC_ITEM_ID" "Source DEC Public ID", --REMOVED
	  --smec."DE_CONC_VER_NR" "Source DEC Version", --REMOVED
	  --smec."VAL_DOM_ITEM_ID" SRC_VAL_DOM_ITEM_ID,smec."VAL_DOM_VER_NR" SRC_VAL_DOM_VER_NR,
	  --smec."MEC_LONG_NM" "Source Characteristic Name" , --REMOVED
	  smec."MEC_PHY_NM" "Source Characteristic Physical Name", 
	  smec."CDE_ITEM_ID" "Source CDE Public ID",
	  smec."CDE_VER_NR" "Source CDE Version",
	   t.item_id "Target Model Public ID", 
	  t.ver_nr "Target Model Version", 
	  t.item_nm "Target Model Name",  
          t.CNTXT_NM_DN "Target Model Context",
 	  --t.item_desc "Target Model Definition", --REMOVED
  	 --t.cntxt_nm_dn "Target Model Context", --REMOVED
	  --tme.ITEM_LONG_NM "Target Element Name",  --REMOVED
	  tme.ITEM_PHY_OBJ_NM "Target Element Physical Name", 
	  --tmec."MEC_ID" tgt_MEC_ID, tmec."MDL_ELMNT_ITEM_ID" tgt_ME_ITEM_ID,tmec."MDL_ELMNT_VER_NR" tgt_ME_VER_NR,
	--tmec."MEC_TYP_ID" tgt_MEC_TYP_ID,  
	  --tmec."DE_CONC_ITEM_ID" "Target DEC Public Id", --REMOVED
	  --tmec."DE_CONC_VER_NR" "Target DEC Version", --REMOVED
	  --tmec."VAL_DOM_ITEM_ID" tgt_VAL_DOM_ITEM_ID,
	  --tmec."VAL_DOM_VER_NR" tgt_VAL_DOM_VER_NR,
	  --tmec."MEC_LONG_NM" "Target Characteristic Name" , --REMOVED
	  tmec."MEC_PHY_NM" "Target Characteristic Physical Name", 
	  tmec."CDE_ITEM_ID" "Target CDE ID",
	  tmec."CDE_VER_NR" "Target CDE Version" ,
	 map.src_pv "Source PV",
     map.tgt_pv "Target PV",
      map.vm_cncpt_cd "VM Concept Code", 
      map.vm_cncpt_nm "VM Concept Name",
      org.org_nm "Provenance Organization",
      c.cntct_nm    "Provenance Contact",
	  --map.prov_cntct_id mec_map_prov_cntct_id, 
	  map.prov_rsn_txt "Provenance Reason",
      map.prov_typ_rvw_txt "Provenance Type of Review",
      map.prov_rvw_dt "Provenance Review Date",   
      map.prov_aprv_dt "Provenance Approval Date",
      map.prov_notes "Provenance Notes",
    m.creat_dt "Model Map Create Date",
	  m.creat_usr_id "Model Map Create User",	  
	  m.lst_upd_dt "Model Map Last Update Date",
	  m.lst_upd_usr_id "Model Map Last Update User",	  
	  map.creat_dt "Value Map Create Date",
	  map.creat_usr_id "Value Map Create User",	  
	  map.lst_upd_dt "Value Map Last Update Date",
	  map.lst_upd_usr_id "Value Map Last Update User" 
FROM admin_item s, 
    NCI_MDL_ELMNT sme,
    NCI_MDL_ELMNT_CHAR smec, 
    admin_item t, 
    NCI_MDL_ELMNT tme,
    NCI_MDL_ELMNT_CHAR tmec, 
    nci_MEC_VAL_MAP map, 
    nci_org org,
    CNTCT c,admin_item m
where map.MDL_MAP_ITEM_ID=m.item_id and map.MDL_MAP_VER_NR = m.ver_nr and 
s.item_id = sme.mdl_item_id and s.ver_nr = sme.mdl_item_ver_nr and sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and s.admin_item_typ_id = 57 and
	  t.item_id = tme.mdl_item_id and t.ver_nr = tme.mdl_item_ver_nr and tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR and t.admin_item_typ_id = 57 and
	   smec.MEC_ID = map.SRC_MEC_ID and tmec.mec_id = map.TGT_MEC_ID
	  and map.prov_org_id = org.entty_id (+)
      AND map.PROV_CNTCT_ID = c.cntct_id (+);



  CREATE OR REPLACE  VIEW VW_MDL_MAP_LIST AS
  select  m.ITEM_ID "Model Map ID",
         m.ver_nr "Model Map Version",
	m.ITEM_NM "Model Map Name",
 m.ITEM_NM_CURATED "Model Map Generated Name",
    m.ADMIN_STUS_NM_DN "Model Map Status",
         m.REGSTR_STUS_NM_DN "Model Map Registration Status", 
	m.cntxt_nm_dn "Model Map Context",
           decode(m.CURRNT_VER_IND,1,'Yes',0,'No') "Model Map Latest Version Indicator",
     s.item_id "Source Model Public ID",
        s.ver_nr "Source Model Version", 
        s.item_nm "Source Model Name",
         s.ADMIN_STUS_NM_DN "Source Model Status",
	s.cntxt_nm_dn "Source Model Context",
        t.item_id "Target Model Public ID", 
        t.ver_nr "Target Model Version", 
        t.item_nm "Target Model Name",  
         t.ADMIN_STUS_NM_DN "Target Model Status",
	t.cntxt_nm_dn "Target Model Context",
        org.org_nm "Provenance Organization",
	p.PRSN_FULL_NM_DERV  "Provenance Contact",
	   m.creat_dt "Model Map Create Date",
	  m.creat_usr_id "Model Map Create User",	  
	  m.lst_upd_dt "Model Map Last Update Date",
	  m.lst_upd_usr_id "Model Map Last Update User"
     from admin_item s,  admin_item t, nci_mdl_map mm,
admin_item m, nci_org org, nci_prsn p
	where m.item_id = mm.item_id and m.ver_nr = mm.ver_nr and mm.SRC_MDL_ITEM_ID= s.item_id and mm.TGT_MDL_ITEM_ID= t.item_id 
and mm.SRC_MDL_VER_NR = s.ver_nr and mm.TGT_MDL_VER_NR = t.ver_nr 
 and mm.PROV_ORG_ID = org.entty_id (+)
and mm.prov_cntct_id  = p.entty_ID (+);



update obj_key set obj_key_def = 'Reference Enumerated' where obj_key_id = 16;
update obj_key set obj_key_def = 'Enumerated' where obj_key_id = 17;
update obj_key set obj_key_def = 'Non-Enumerated' where obj_key_id = 18;
commit;



alter table nci_mec_map add (right_op  varchar2(255), left_op varchar2(255), flow_cntrl integer, op_typ integer);
alter table nci_stg_mec_map add (right_op  varchar2(255), left_op varchar2(255),imp_flow_cntrl varchar2(255), flow_cntrl integer, imp_op_typ varchar2(255), op_typ integer);
 
insert into obj_typ (obj_typ_Id, obj_typ_Desc) values (56, 'Mapping Flow Control');
insert into obj_typ (obj_typ_Id, obj_typ_Desc) values (57, 'Mapping Operand Type');
commit;


  CREATE OR REPLACE  VIEW VW_MDL_MAP_IMP_TEMPLATE AS 
  select  ' ' "DO_NOT_USE",
       ' ' "BATCH_USER",
       ' ' "BATCH_NAME",
       rownum "SEQ_ID",
       map.mdl_map_item_id "MODEL_MAP_ID",
       map.mdl_map_ver_nr "MODEL_MAP_VERSION",
        map.mecm_id "MECM_ID", 
        smec.char_ord SRC_CHAR_ORD,
	sme.ITEM_PHY_OBJ_NM "SRC_ELMNT_PHY_NAME", 
	sme.ITEM_LONG_NM "SRC_ELMNT_NAME", 
  smec."MEC_PHY_NM" "SRC_PHY_NAME", 
	smec.MEC_LONG_NM "SRC_MEC_NAME", 
	  tme.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME", 
	 sme.ITEM_LONG_NM "TGT_ELMNT_NAME", 
	  tmec."MEC_PHY_NM" "TGT_PHY_NAME", 
   	tmec.MEC_LONG_NM "TGT_MEC_NAME", 
       tmec.char_ord TGT_CHAR_ORD,
          map.MEC_MAP_NM "MAPPING_GROUP_NAME",
          map.MEC_MAP_DESC "MAPPING_GROUP_DESC",
	  src_func.obj_key_Desc "SOURCE_FUNCTION",
	  tgt_func.obj_key_Desc "TARGET_FUNCTION",
	  crd.obj_key_desc "MAPPING_CARDINALITY",
	  deg.obj_key_Desc "MAPPING_DEGREE",
          ' ' "TRANS_RULE_NOTATION",
map.mec_grp_rul_nbr "DERIVATION_GROUP_NBR",
map.mec_sub_grp_nbr	"DERIVATION_GROUP_ORDER",
	map.SRC_VAL "SOURCE_COMPARISON_VALUE",
	map.TGT_VAL "SET_TARGET_DEFAULT"	,
map.TGT_FUNC_PARAM "TARGET_FUNCTION_PARAM"	,
	op.obj_key_desc "OPERATOR",
	op_typ.obj_key_desc "OPERAND_TYPE",
	flow_cntrl.obj_key_desc "FLOW_CONTROL",
	map.right_op "RIGHT_OPERAND",
	map.left_op "LEFT_OPERAND",
  map.valid_pltform	   "VALIDATION_PLATFORM",
	map.mec_map_notes "TRANSFORMATION_NOTES",
	map.TRNS_DESC_TXT "TRANSFORMATION_RULE",
	org.org_nm "PROV_ORG",
' '	"PROV_CONTACT",
	map.prov_rsn_txt "PROV_REVIEW_REASON",
	map.prov_typ_rvw_txt "PROV_TYPE_OF_REVIEW",
	map.PROV_RVW_DT "PROV_REVIEW_DATE",
	map.prov_APRV_DT "PROV_APPROVAL_DATE",
decode(nvl(map.VAL_MAP_CREATE_IND,0),1, 'Yes','No') "VALUE_MAP_GENERATED_IND",
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "SOURCE_DOMAIN_TYPE",
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "TARGET_DOMAIN_TYPE",
	   map."CREAT_DT",
	  map."CREAT_USR_ID",
	  map."LST_UPD_USR_ID",
	  map."FLD_DELETE",
	  map."LST_DEL_DT",
	  map."S2P_TRN_DT",
	  map."LST_UPD_DT",
      smec.MEC_ID SRC_MEC_ID,
tmec.MEC_ID TGT_MEC_ID,
tmec.pk_ind TGT_PK_IND,
smec.pk_ind SRC_PK_IND
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  obj_key crd,
	  obj_key deg,
	  obj_key src_func,
	  obj_key tgt_func,
	  obj_key op,
	  obj_key op_typ,
	  obj_key flow_cntrl,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd
	where  sme.item_id (+)= smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr (+)= smec.MDL_ELMNT_VER_NR and
	 tme.item_id (+)= tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr (+)= tmec.MDL_ELMNT_VER_NR  and
	   smec.MEC_ID (+)= map.SRC_MEC_ID and tmec.mec_id (+)= map.TGT_MEC_ID
	  and map.map_deg = deg.obj_key_id (+)
	  and map.src_func_id= src_func.obj_key_id (+)
	  and map.tgt_func_id= tgt_func.obj_key_id (+)
	  and map.prov_org_id = org.entty_id (+)
	  and map.crdnlity_id = crd.obj_key_id (+)
	  and map.op_id = op.obj_key_id (+)
	  and map.op_typ = op_typ.obj_key_id (+)
	  and map.flow_cntrl = flow_cntrl.obj_key_id (+)
          and smec.val_dom_item_id = svd.item_id (+)
	  and smec.val_dom_ver_nr = svd.ver_nr (+)
	  and tmec.val_dom_item_id = tvd.item_id (+)
 	  and tmec.val_dom_ver_nr = tvd.ver_nr (+);

