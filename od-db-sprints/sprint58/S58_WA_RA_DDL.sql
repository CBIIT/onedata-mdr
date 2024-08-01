alter table NCI_MDL add (MAP_USG_TYP_ID integer);

insert into obj_typ(obj_typ_id, obj_typ_desc) values (61,'Model Usage Type for Mapping');
commit;
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,135, 'Source Only');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,136, 'Target Only');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,137, 'Source or Target');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,138, 'No Mapping');
commit

alter table NCI_MEC_MAP add (PCODE_SYSGEN varchar2(4000));

alter table NCI_MEC_MAP add (MEC_MAP_NM_GEN varchar2(4000));

  CREATE OR REPLACE  VIEW VW_NCI_MDL AS
  select
	ai."ITEM_ID",ai."VER_NR",
    ai."ITEM_DESC",ai."CNTXT_ITEM_ID",ai."CNTXT_VER_NR",ai."ITEM_LONG_NM",ai."ITEM_NM",ai."ADMIN_NOTES",
    ai."CHNG_DESC_TXT",ai."EFF_DT",ai."ORIGIN",ai."ADMIN_ITEM_TYP_ID",
    ai."CURRNT_VER_IND",ai."ADMIN_STUS_ID",ai."REGSTR_STUS_ID",ai."CREAT_DT",
    ai."CREAT_USR_ID",ai."LST_UPD_USR_ID",ai."FLD_DELETE",ai."LST_DEL_DT",ai."S2P_TRN_DT",ai."LST_UPD_DT",
    ai."ADMIN_STUS_NM_DN",ai."CNTXT_NM_DN",ai."REGSTR_STUS_NM_DN",ai."ORIGIN_ID",
   m.prmry_mdl_lang_id ,
    m.map_usg_Typ_id from admin_item ai, nci_mdl m where ai.item_id = m.item_id and ai.ver_nr = m.ver_nr and ai.admin_item_typ_id = 57;


  CREATE OR REPLACE  VIEW VW_CNCPT_XMAP AS
  SELECT XMAP.ITEM_ID, XMAP.VER_NR, 
  listagg(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_O_CODE,
  listagg(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_desc,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_O_DESC,
  listagg(decode(o.obj_key_desc, 'SNOMED-CT_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) SNOMED_CODE,
  listagg(decode(o.obj_key_desc, 'SNOMED-CT_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) SNOMED_DESC,
  listagg(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MEDDRA_CODE,
 listagg(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MEDDRA_DESC,
  listagg(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) LOINC_CODE,
 listagg(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) LOINC_DESC,
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HUGO_CODE,
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_desc,''),'|') WITHIN GROUP (ORDER by XMAP_CD)HUGO_CODE_DESC,
  listagg(decode(o.obj_key_desc, 'GO_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) GO_CODE,
  listagg(decode(o.obj_key_desc, 'GO_CODE', XMAP_desc,''),'|') WITHIN GROUP (ORDER by XMAP_CD)GO_CODE_DESC,
  listagg(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_CM_CODE,
  listagg(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_CM_DESC,
	   listagg(decode(o.obj_key_desc, 'OMOP_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) OMOP_CODE,
  listagg(decode(o.obj_key_desc, 'OMOP_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) OMOP_DESC,
	   listagg(decode(o.obj_key_desc, 'UBERON_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) UBERON_CODE,
  listagg(decode(o.obj_key_desc, 'UBERON_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) UBERON_DESC,
 listagg(decode(o.obj_key_desc, 'NCI_META_CUI', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD)META_CUI_CODE,
  listagg(decode(o.obj_key_desc, 'NCI_META_CUI', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) META_CUI_DESC,
	  listagg(decode(o.obj_key_desc, 'MED_RT_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MED_RT_CODE,
  listagg(decode(o.obj_key_desc, 'MED_RT_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MED_RT_DESC,
	 listagg(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_PCS_CODE,
  listagg(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_PCS_DESC,
	  listagg(decode(o.obj_key_desc, 'NCBI_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) NCBI_CODE,
  listagg(decode(o.obj_key_desc, 'NCBI_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) NCBI_DESC,
	 listagg(decode(o.obj_key_desc, 'HPO_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HPO_CODE,
  listagg(decode(o.obj_key_desc, 'HPO_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HPO_DESC,
	  listagg(decode(o.obj_key_desc, 'HCPCS_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HCPCS_CODE,
  listagg(decode(o.obj_key_desc, 'HCPCS_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HCPCS_DESC,
   listagg(decode(o.obj_key_desc, 'ICD-O_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_O_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'SNOMED-CT_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) SNOMED_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'MEDDRA_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MEDDRA_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'LOINC_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) LOINC_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HUGO_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'GO_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) GO_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'ICD-10-CM_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_CM_TERM_TYP,
 listagg(decode(o.obj_key_desc, 'NCI_META_CUI', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) META_CUI_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'MED_RT_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MED_RT_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_PCS_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'NCBI_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) NCBI_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'HPO_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HPO_TERM_TYP,
	 listagg(decode(o.obj_key_desc, 'HCPCS_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HCPCS_TERM_TYP,
  sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT 
       FROM NCI_ADMIN_ITEM_XMAP xmap, obj_key o
       WHERE o.obj_typ_id = 23 and o.obj_key_id = xmap.evs_src_id and pref_ind != 0 and xmap.item_id <> 0
       group by xmap.item_id, xmap.ver_nr;

alter table nci_mec_Map modify (TRNS_DESC_TXT varchar2(8000));

alter table nci_stg_mec_Map modify (TRNS_DESC_TXT varchar2(8000));

