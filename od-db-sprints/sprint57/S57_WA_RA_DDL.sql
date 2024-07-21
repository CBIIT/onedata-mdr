alter table cncpt add (REF_TERM_IND number(1));
alter table NCI_MEC_MAP add (CMNTS_DESC_TXT varchar2(4000));

update obj_key set obj_Key_Desc = 'Not Mapped Yet' where obj_key_id = 130;
commit;

update cncpt set ref_term_ind = 1 where item_id in (select TERM_CNCPT_ITEM_ID from value_dom where TERM_CNCPT_ITEM_ID is not null);
commit;

drop materialized view VW_CNCPT;

  CREATE MATERIALIZED VIEW VW_CNCPT 
  AS SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM,  ADMIN_ITEM.ITEM_LONG_NM, '.' ||ADMIN_ITEM.ITEM_NM ||'.' ITEM_NM_PERIOD,  '.' ||ADMIN_ITEM.ITEM_LONG_NM || '.' ITEM_LONG_NM_PERIOD, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CREATION_DT, 
ADMIN_ITEM.EFF_DT, ADMIN_ITEM.ORIGIN,  ADMIN_ITEM.UNTL_DT,  ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CNTXT_ITEM_ID,
ADMIN_ITEM.CNTXT_VER_NR, ADMIN_ITEM.CNTXT_NM_DN,
 ADMIN_ITEM.CREAT_DT, ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, ADMIN_ITEM.LST_UPD_DT, CNCPT.PRMRY_CNCPT_IND,
nvl(decode(trim(ADMIN_ITEM.DEF_SRC), 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') DEF_SRC, e.CNCPT_CONCAT_WITH_INT,
		      decode(trim(OBJ_KEY.OBJ_KEY_DESC), 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC) EVS_SRC,
		      trim(OBJ_KEY.OBJ_KEY_DESC) EVS_SRC_ORI,
			cncpt.evs_Src_id,nvl(cncpt.ref_term_ind,0) REF_TERM_IND,
		      nvl(decode(trim(ADMIN_ITEM.DEF_SRC), 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') || '|' ||
		      nvl(decode(trim(OBJ_KEY.OBJ_KEY_DESC), 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC), 'No EVS Source') DEF_EVS_SRC,
        substr(ADMIN_ITEM.ITEM_NM || ' | ' || a.SYN, 1, 4000) SYN,substr(a.SYN_MTCH_TERM,1,4000) SYN_MTCH_TERM, MTCH_TERM, MTCH_TERM_ADV
              FROM ADMIN_ITEM,  CNCPT, nci_admin_item_ext e, OBJ_KEY, (select item_id, ver_nr,   LISTAGG(nm_desc, ' | ') WITHIN GROUP (ORDER by ITEM_ID) AS SYN,
			        LISTAGG(MTCH_TERM_ADV , ' | ') WITHIN GROUP (ORDER by ITEM_ID) AS SYN_MTCH_TERM from ALT_NMS a group by item_id, ver_nr) a
       WHERE ADMIN_ITEM_TYP_ID = 49 and ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID and ADMIN_ITEM.VER_NR = CNCPT.VER_NR
       and admin_item.item_id = e.item_id and admin_item.ver_nr = e.ver_nr
	and cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID (+) and admin_item.admin_stus_nm_dn = 'RELEASED' 
	and ADMIN_ITEM.ITEM_ID = a.ITEM_ID (+) and ADMIN_ITEM.VER_NR = a.VER_NR (+);

alter table nci_mdl_elmnt_char modify (req_ind integer);
alter table nci_stg_mdl_elmnt_char modify (src_mand_ind varchar2(50));


insert into obj_typ(obj_typ_id, obj_typ_desc) values (59,'Characteristics Mandatory Indicator');
commit;
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (59,132,'Mandatory');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (59,133,'Not Mandatory');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (59,134,'Expected');
commit;

alter table nci_mdl_elmnt_char disable all triggers;
update NCI_MDL_ELMNT_CHAR set REQ_IND = 133 where REQ_IND is null or REQ_IND = 0;
update NCI_MDL_ELMNT_CHAR set REQ_IND = 132 where REQ_IND = 1;
commit;
alter table nci_mdl_elmnt_char enable all triggers;


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

  CREATE OR REPLACE  VIEW VW_XMAP_PREF as
  SELECT 0 PREF_ID, 'No' PREF_DESC,
 sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
from dual
union
  SELECT 1 PREF_ID, 'Yes' PREF_DESC,
 sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
from dual
union
  SELECT 2 PREF_ID, 'Unknown' PREF_DESC,
 sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
from dual;

