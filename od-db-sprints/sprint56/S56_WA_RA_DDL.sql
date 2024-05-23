drop materialized view VW_VAL_DOM_REF_TERM;

  CREATE MATERIALIZED VIEW VW_VAL_DOM_REF_TERM
  AS select
vd.item_id, vd.ver_nr, vd.term_cncpt_item_id, vd.term_cncpt_ver_nr, nvl(a.nm_desc, c.item_nm) || '/' || o.obj_key_desc  term_use_name, nvl(a.nm_desc, c.item_nm)  term_name,obj_key_desc use_name from
value_dom vd, vw_cncpt c, obj_key o, (select item_id, ver_nr, nm_desc from alt_nms a, obj_key where obj_typ_id = 11 and obj_key_desc = 'Ref Term Short Name' and a.nm_typ_id = obj_key_id) a
where  vd.val_dom_typ_id = 16 and vd.term_cncpt_item_id = c.item_id and vd.term_cncpt_ver_nr = c.ver_nr and vd.TERM_USE_TYP= o.obj_key_id and
vd.term_cncpt_item_id = a.item_id (+) and vd.term_cncpt_ver_nr = a.ver_nr (+);


  CREATE OR REPLACE  VIEW VW_VALUE_DOM AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN,  ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
		      ADMIN_ITEM.CURRNT_VER_IND, VALUE_DOM.DTTYPE_ID, VALUE_DOM.VAL_DOM_MAX_CHAR, VALUE_DOM.CONC_DOM_VER_NR, VALUE_DOM.CONC_DOM_ITEM_ID, 
VALUE_DOM.NON_ENUM_VAL_DOM_DESC, VALUE_DOM.UOM_ID, VALUE_DOM.VAL_DOM_TYP_ID, VALUE_DOM.VAL_DOM_MIN_CHAR, VALUE_DOM.VAL_DOM_FMT_ID, 
VALUE_DOM.CHAR_SET_ID, VALUE_DOM.CREAT_DT, VALUE_DOM.CREAT_USR_ID, VALUE_DOM.LST_UPD_USR_ID, 
VALUE_DOM.FLD_DELETE, VALUE_DOM.LST_DEL_DT, VALUE_DOM.S2P_TRN_DT, VALUE_DOM.LST_UPD_DT , RC.ITEM_NM  REP_TERM_ITEM_NM,
	  value_dom.NCI_STD_DTTYPE_ID, term.term_name, term.use_name, term.term_use_name
FROM ADMIN_ITEM, VALUE_DOM, VW_REP_CLS RC, vw_val_dom_ref_term term
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 3
AND ADMIN_ITEM.ITEM_ID = VALUE_DOM.ITEM_ID
AND ADMIN_ITEM.VER_NR=VALUE_DOM.VER_NR and
VALUE_DOM.REP_CLS_ITEM_ID = RC.ITEM_ID (+) and 
VALUE_DOM.REP_CLS_VER_NR = RC.VER_NR (+)
and
VALUE_DOM.ITEM_ID = TERM.ITEM_ID (+) and 
VALUE_DOM.VER_NR = TERM.VER_NR (+);


  CREATE OR REPLACE  VIEW VW_CNCPT_XMAP AS
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
       WHERE o.obj_typ_id = 23 and o.obj_key_id = xmap.evs_src_id and pref_ind = 1 and xmap.item_id <> 0
       group by xmap.item_id, xmap.ver_nr;


  CREATE TABLE PERM_VAL_SUBSET 
   (	"PERM_VAL_BEG_DT" DATE DEFAULT sysdate, 
	"PERM_VAL_END_DT" DATE, 
	"PERM_VAL_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PERM_VAL_DESC_TXT" VARCHAR2(2000 BYTE) COLLATE "USING_NLS_COMP", 
	"VAL_DOM_ITEM_ID" NUMBER NOT NULL ENABLE, 
	"VAL_DOM_VER_NR" NUMBER(4,2) NOT NULL ENABLE, 
	"VAL_ID" NUMBER NOT NULL ENABLE, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"NCI_VAL_MEAN_ITEM_ID" NUMBER NOT NULL ENABLE, 
	"NCI_VAL_MEAN_VER_NR" NUMBER(4,2) NOT NULL ENABLE,
	  CONSTRAINT "XPKPERM_VAL_SUBSET" PRIMARY KEY ("VAL_ID"));

 
  CREATE OR REPLACE  VIEW VW_NCI_DE_PV AS
  SELECT pv.val_id, PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,
              DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR, VM.ITEM_NM, VM.ITEM_LONG_NM,
                VM.ITEM_DESC, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR,
                decode(e.cncpt_concat, e.cncpt_concat_nm, null, vm.item_long_nm, null, vm.item_id, null, e.cncpt_concat) cncpt_concat, e.CNCPT_CONCAT_NM,
		decode(e.cncpt_concat_with_int, e.cncpt_concat_nm, null, vm.item_long_nm, null, vm.item_id, null, e.cncpt_concat_with_int) cncpt_concat_with_int,
		PV.CREAT_DT, PV.CREAT_USR_ID, PV.LST_UPD_USR_ID, PV.FLD_DELETE, PV.LST_DEL_DT, PV.S2P_TRN_DT, PV.LST_UPD_DT,
                PV.PRNT_CNCPT_ITEM_ID, PV.PRNT_CNCPT_VER_NR, VM.ITEM_NM || ' ' || VM.ITEM_DESC  VM_SEARCH_STR,
	  'CDE' PV_TYP, de.VAL_DOM_ITEM_ID, de.val_dom_Ver_nr
       FROM  DE, PERM_VAL PV, ADMIN_ITEM VM, NCI_ADMIN_ITEM_EXT e where
	PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID and
	PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR and
	PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID and
	PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR and
        VM.ITEM_ID = e.ITEM_ID and
        VM.VER_NR = e.VER_NR and de.SUBSET_DESC <> 'Subset'
	  union
	 SELECT  pv.val_id,  PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,
              DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR, VM.ITEM_NM, VM.ITEM_LONG_NM,
                VM.ITEM_DESC, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR,
                decode(e.cncpt_concat, e.cncpt_concat_nm, null, vm.item_long_nm, null, vm.item_id, null, e.cncpt_concat) cncpt_concat, e.CNCPT_CONCAT_NM,
		decode(e.cncpt_concat_with_int, e.cncpt_concat_nm, null, vm.item_long_nm, null, vm.item_id, null, e.cncpt_concat_with_int) cncpt_concat_with_int,
		PV.CREAT_DT, PV.CREAT_USR_ID, PV.LST_UPD_USR_ID, PV.FLD_DELETE, PV.LST_DEL_DT, PV.S2P_TRN_DT, PV.LST_UPD_DT,
                null, null, VM.ITEM_NM || ' ' || VM.ITEM_DESC  VM_SEARCH_STR ,'SUBSET' PV_TYP, de.VAL_DOM_ITEM_ID, de.val_dom_Ver_nr
       FROM  DE, PERM_VAL_SUBSET PV, ADMIN_ITEM VM, NCI_ADMIN_ITEM_EXT e where
	PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID and
	PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR and
	PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID and
	PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR and
        VM.ITEM_ID = e.ITEM_ID and
        VM.VER_NR = e.VER_NR and de.SUBSET_DESC = 'Subset' ;



