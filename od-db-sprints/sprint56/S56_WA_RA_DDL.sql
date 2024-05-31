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


  CREATE TABLE PERM_VAL_SUBSET 
   (	"PERM_VAL_BEG_DT" DATE DEFAULT sysdate, 
	"PERM_VAL_END_DT" DATE, 
	"PERM_VAL_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PERM_VAL_DESC_TXT" VARCHAR2(2000 BYTE) COLLATE "USING_NLS_COMP", 
	"CDE_ITEM_ID" NUMBER NOT NULL ENABLE, 
	"CDE_VER_NR" NUMBER(4,2) NOT NULL ENABLE, 
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
        VM.VER_NR = e.VER_NR 
	  --and nvl(de.SUBSET_DESC,'xx') <> 'Subset'
	 /* union
	 SELECT  pv.val_id,  PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,
              pv.cde_ITEM_ID  DE_ITEM_ID,
		pv.cde_VER_NR DE_VER_NR, VM.ITEM_NM, VM.ITEM_LONG_NM,
                VM.ITEM_DESC, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR,
                decode(e.cncpt_concat, e.cncpt_concat_nm, null, vm.item_long_nm, null, vm.item_id, null, e.cncpt_concat) cncpt_concat, e.CNCPT_CONCAT_NM,
		decode(e.cncpt_concat_with_int, e.cncpt_concat_nm, null, vm.item_long_nm, null, vm.item_id, null, e.cncpt_concat_with_int) cncpt_concat_with_int,
		PV.CREAT_DT, PV.CREAT_USR_ID, PV.LST_UPD_USR_ID, PV.FLD_DELETE, PV.LST_DEL_DT, PV.S2P_TRN_DT, PV.LST_UPD_DT,
                null, null, VM.ITEM_NM || ' ' || VM.ITEM_DESC  VM_SEARCH_STR ,'SUBSET' PV_TYP, de.VAL_DOM_ITEM_ID, de.val_dom_Ver_nr
       FROM  DE, PERM_VAL_SUBSET PV, ADMIN_ITEM VM, NCI_ADMIN_ITEM_EXT e where
	  de.item_id = pv.cde_item_id and de.ver_nr = pv.cde_ver_nr and 
	PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID and
	PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR and
        VM.ITEM_ID = e.ITEM_ID and
        VM.VER_NR = e.VER_NR and de.SUBSET_DESC = 'Subset' ; */

 CREATE OR REPLACE VIEW VW_CNCPT_XMAP AS
  SELECT XMAP.ITEM_ID, XMAP.VER_NR, 
  listagg(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) ICD_O_CODE,
  listagg(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_desc,''),';') WITHIN GROUP (ORDER by XMAP_CD) ICD_O_DESC,
  listagg(decode(o.obj_key_desc, 'SNOMED-CT_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) SNOMED_CODE,
  listagg(decode(o.obj_key_desc, 'SNOMED-CT_CODE', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) SNOMED_DESC,
  listagg(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) MEDDRA_CODE,
 listagg(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) MEDDRA_DESC,
  listagg(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) LOINC_CODE,
 listagg(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) LOINC_DESC,
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) HUGO_CODE,
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_desc,''),';') WITHIN GROUP (ORDER by XMAP_CD)HUGO_CODE_DESC,
  listagg(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_CM_CODE,
  listagg(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_CM_DESC,
	   listagg(decode(o.obj_key_desc, 'OMOP_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) OMOP_CODE,
  listagg(decode(o.obj_key_desc, 'OMOP_CODE', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) OMOP_DESC,
	   listagg(decode(o.obj_key_desc, 'UBERON_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) UBERON_CODE,
  listagg(decode(o.obj_key_desc, 'UBERON_CODE', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) UBERON_DESC,
 listagg(decode(o.obj_key_desc, 'NCI_META_CUI', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD)META_CUI_CODE,
  listagg(decode(o.obj_key_desc, 'NCI_META_CUI', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) META_CUI_DESC,
	  listagg(decode(o.obj_key_desc, 'MED_RT_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) MED_RT_CODE,
  listagg(decode(o.obj_key_desc, 'MED_RT_CODE', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) MED_RT_DESC,
	 listagg(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_PCS_CODE,
  listagg(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_PCS_DESC,
	  listagg(decode(o.obj_key_desc, 'NCBI_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) NCBI_CODE,
  listagg(decode(o.obj_key_desc, 'NCBI_CODE', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) NCBI_DESC,
	 listagg(decode(o.obj_key_desc, 'HPO_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) HPO_CODE,
  listagg(decode(o.obj_key_desc, 'HPO_CODE', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) HPO_DESC,
	  listagg(decode(o.obj_key_desc, 'HCPCS_CODE', XMAP_Cd,''),';') WITHIN GROUP (ORDER by XMAP_CD) HCPCS_CODE,
  listagg(decode(o.obj_key_desc, 'HCPCS_CODE', XMAP_DESC,''),';') WITHIN GROUP (ORDER by XMAP_CD) HCPCS_DESC,
   listagg(decode(o.obj_key_desc, 'ICD-O_CODE', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) ICD_O_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'SNOMED-CT_CODE', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) SNOMED_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'MEDDRA_CODE', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) MEDDRA_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'LOINC_CODE', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) LOINC_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) HUGO_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'ICD-10-CM_CODE', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_CM_TERM_TYP,
 listagg(decode(o.obj_key_desc, 'NCI_META_CUI', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) META_CUI_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'MED_RT_CODE', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) MED_RT_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_PCS_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'NCBI_CODE', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) NCBI_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'HPO_CODE', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) HPO_TERM_TYP,
	 listagg(decode(o.obj_key_desc, 'HCPCS_CODE', TERM_TYP,''),';') WITHIN GROUP (ORDER by XMAP_CD) HCPCS_TERM_TYP,
  sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT 
       FROM NCI_ADMIN_ITEM_XMAP xmap, obj_key o
       WHERE o.obj_typ_id = 23 and o.obj_key_id = xmap.evs_src_id and pref_ind = 1 and xmap.item_id <> 0
       group by xmap.item_id, xmap.ver_nr;


set escape on;
drop MATERIALIZED VIEW VW_FORM_TREE_CDE;
   CREATE MATERIALIZED VIEW VW_FORM_TREE_CDE 
  AS select CNTXT_ITEM_ID P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ITEM_LONG_NM,  ITEM_NM || ' (' 
 || nvl(y.cnt,'0') || ')' ITEM_NM , ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X 
 ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=104\&type=frm\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=103\&type=frm\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=114\&type=frm\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=102\&type=protocol\\Legacy_Form_Builder_Excel' FORM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=105\&type=protocol\\Form_Excel'  FORM_RPT_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=109\&type=protocol\\REDCap_DD_Form'  FORM_RPT_RED_CAP,
c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CDEProt.PROT_ITEM_VER_NR=' || ai.item_id || 'v' || ai.ver_Nr ITEM_DEEP_LINK ,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES 
from 
ADMIN_ITEM ai, (select x.p_item_id, x.p_item_ver_nr, count(*) cnt from MVW_FORM_NODE_DE_REL x where lvl='Protocol' group by x.p_item_id , 
x.p_item_ver_nr) y , nci_mdr_cntrl c, nci_mdr_cntrl c1
 where ADMIN_ITEM_TYP_ID = 50 and item_id = y.p_item_id (+) and ver_nr = y.p_item_ver_nr (+)
 and upper(cntxt_nm_dn) not in ('TEST', 'TRAINING') 
 and c.param_nm='DOWNLOAD_HOST'
	  and c1.param_nm='DEEP_LINK'
 union
select  r.P_ITEM_ID, r.P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
ITEM_NM || ' (' || nvl(y.cnt,'0') || ')', ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN,ai. REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X
 ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=frm\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=frm\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=frm\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=102\&type=frm\\Legacy_Form_Builder_Excel' FORM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=105\&type=frm\\Form_Excel'  FORM_RPT_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=109\&type=frm\\REDCap_DD_Form'  FORM_RPT_RED_CAP,
c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CDEForm.FRM_ITEM_VER_NR=' || ai.item_id || 'v' || ai.ver_Nr ITEM_DEEP_LINK ,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES 
 from 
ADMIN_ITEM ai, (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_FORM_NODE_DE_REL x where lvl='Form' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c, nci_admin_item_rel r, nci_mdr_cntrl c1
 where ADMIN_ITEM_TYP_ID = 54 and item_id = y.p_item_id (+) and ver_nr = y.p_item_ver_nr (+)
and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn not like '%RETIRED%'
 and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') 
 and c.param_nm='DOWNLOAD_HOST' 	  and c1.param_nm='DEEP_LINK'

 and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr and r.rel_typ_id = 60 
 union
 select  distinct null P_ITEM_ID,null P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM,  
ITEM_NM || ' (' || ITEM_DESC  || ') (' || nvl(y.cnt,'0') || ')' , ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN,ai. REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X
 ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=frm\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=frm\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=frm\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'NA' FORM_RPT_PRIOR_EXCEL,
'NA' FORM_RPT_EXCEL,
'NA' FORM_RPT_RED_CAP,
c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CNTXT_ITEM_ID=' || ai.item_id  ITEM_DEEP_LINK ,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES 
 from 
ADMIN_ITEM ai, (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_FORM_NODE_DE_REL x where lvl='Context' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c, nci_mdr_cntrl c1
 where ADMIN_ITEM_TYP_ID = 8 and item_id = y.p_item_id (+)  and ver_nr = y.p_item_ver_nr (+)
 --and admin_stus_nm_dn ='RELEASED' 
 and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING')  	  and c1.param_nm='DEEP_LINK'
 and c.param_nm='DOWNLOAD_HOST';


  CREATE OR REPLACE VIEW VW_NCI_PROT_DE_REL AS
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
           ak.c_item_ver_nr ver_nr,
	  prot.P_ITEM_ID || 'v' ||prot.P_ITEM_VER_NR PROT_ITEM_VER_NR
           FROM NCI_ADMIN_ITEM_REL r, NCI_ADMIN_ITEM_REL_ALT_KEY ak , nci_admin_item_rel prot
     WHERE  ak.P_ITEM_ID = r.C_ITEM_ID and ak.P_ITEM_VER_NR = r.C_ITEM_VER_NR and
	   r.rel_typ_id = 61 
  and r.p_item_id = prot.c_item_id and r.p_item_ver_nr = prot.c_item_ver_nr and prot.rel_typ_id=60
  and nvl(ak.fld_delete,0) = 0;



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
DE.ADMIN_STUS_ID DE_ADMIN_STUS_ID, DE.REGSTR_STUS_ID DE_REGSTR_STUS_ID, 54 ADMIN_ITEM_TYP_ID, FRM.ITEM_ID ||'v'||FRM.VER_NR FRM_ITEM_VER_NR
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
DE.ADMIN_STUS_ID DE_ADMIN_STUS_ID, DE.REGSTR_STUS_ID DE_REGSTR_STUS_ID, 54, 'XX' FRM_ITEM_VER_NR
FROM  NCI_ADMIN_ITEM_REL_ALT_KEY AIR, ADMIN_ITEM AIM,
 NCI_ADMIN_ITEM_REL FRM_MOD , ADMIN_ITEM DE
WHERE  AIR.REL_TYP_ID = 63
AND AIM.ITEM_ID = AIR.P_ITEM_ID AND AIM.VER_NR = AIR.P_ITEM_VER_NR
AND AIM.ITEM_ID = FRM_MOD.C_ITEM_ID AND AIM.VER_NR = FRM_MOD.C_ITEM_VER_NR
AND FRM_MOD.REL_TYP_ID IN (61,62)
AND AIR.C_ITEM_ID = DE.ITEM_ID
AND AIR.C_ITEM_VER_NR = DE.VER_NR
and FRM_MOD.P_ITEM_ID = -1;

