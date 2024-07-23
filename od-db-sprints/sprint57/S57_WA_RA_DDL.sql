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

--jira 3357
alter table nci_stg_pv_vm_import add REF_BTCH_NBR integer;
--jira 3397
drop materialized view mvw_csi_node_form_rel;
CREATE MATERIALIZED VIEW MVW_CSI_NODE_FORM_REL ("CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "LST_UPD_DT", "S2P_TRN_DT", "LST_DEL_DT", "FLD_DELETE", "ITEM_NM", "ITEM_LONG_NM", "ITEM_ID", "VER_NR", "ITEM_DESC", "CNTXT_NM_DN", "ADMIN_STUS_NM_DN", "REGSTR_STUS_NM_DN", "P_ITEM_ID", "P_ITEM_VER_NR", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ADMIN_STUS_ID", "REGSTR_STUS_ID", "USED_BY", "LVL", "P_ITEM_ID_VER", "CURRNT_VER_IND")

  AS select distinct
           ai.CREAT_DT,
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
           r.P_ITEM_ID,
           r.P_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           e.USED_BY,
           'Form' LVL,
           r.c_item_id || 'v' || r.c_item_ver_nr P_ITEM_ID_VER,
           ai.CURRNT_VER_IND
from admin_item ai, admin_item ak, mvw_csi_rel csi, nci_admin_item_rel r, nci_admin_item_ext e, admin_item csix
where ai.admin_item_typ_id = 54 and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr
      and r.rel_typ_id =65
      and csi.item_id = r.p_item_id and csi.ver_nr = r.p_item_ver_nr
      and ak.item_id = csi.item_id and ak.ver_nr = csi.ver_nr
      and csi.base_id is not null
      and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr
      and ai.regstr_stus_nm_dn not like '%RETIRED%' 
      and ai.admin_stus_nm_dn not like '%RETIRED%'
      and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING')
      and nvl(ai.CURRNT_VER_IND,0) = 1 
      and nvl(r.fld_delete,0) = 0
      and csix.item_id = csi.item_id and csix.ver_nr = csi.ver_nr and csix.admin_stus_nm_dn = 'RELEASED'
union
    select distinct
        ai.CREAT_DT,
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
        e.USED_BY,
        'CSI' LVL,
        csi.BASE_ID || 'v' || csi.BASE_VER_NR P_ITEM_ID_VER,
        ai.CURRNT_VER_IND
    from admin_item ai, admin_item ak, mvw_csi_rel csi, nci_admin_item_rel r, nci_admin_item_ext e, admin_item csix
    where ai.admin_item_typ_id = 54 and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr
      and r.rel_typ_id =65
      and csi.item_id = r.p_item_id and csi.ver_nr = r.p_item_ver_nr
      and ak.item_id = csi.item_id and ak.ver_nr = csi.ver_nr
      and csi.base_id is not null
      and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr
      and ai.regstr_stus_nm_dn not like '%RETIRED%' 
      and ai.admin_stus_nm_dn not like '%RETIRED%'
      and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING')
      and nvl(ai.CURRNT_VER_IND,0) = 1 
      and nvl(r.fld_delete,0) = 0
      and csix.item_id = csi.item_id and csix.ver_nr = csi.ver_nr and csix.admin_stus_nm_dn = 'RELEASED'
union
select distinct 
           ai.CREAT_DT,
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
           e.USED_BY,
           'CS' LVL,
           csi.CS_ITEM_ID || 'v' || csi.CS_ITEM_VER_NR P_ITEM_ID_VER,
           ai.CURRNT_VER_IND
    from admin_item ai, nci_clsfctn_schm_item csi, nci_admin_item_rel r, nci_admin_item_ext e, admin_item csix
    where ai.admin_item_typ_id = 54 and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr
      and r.rel_typ_id = 65
      and csi.item_id = r.p_item_id and csi.ver_nr = r.p_item_ver_nr
      and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr
      and ai.regstr_stus_nm_dn not like '%RETIRED%' 
      and ai.admin_stus_nm_dn not like '%RETIRED%'
      and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING')
      and nvl(ai.CURRNT_VER_IND,0) = 1 
      and nvl(r.fld_delete,0) = 0
      and csix.item_id = csi.item_id and csix.ver_nr = csi.ver_nr and csix.admin_stus_nm_dn = 'RELEASED'
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
           e.USED_BY,
           'Context' LVL,
            cs.CNTXT_ITEM_ID || 'v' || cs.CNTXT_VER_NR P_ITEM_ID_VER,
            ai.CURRNT_VER_IND
    from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi, VW_CLSFCTN_SCHM cs, nci_admin_item_ext e, ADMIN_ITEM csix, nci_admin_item_rel r
    where ai.admin_item_typ_id = 54 and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr
      and r.rel_typ_id = 65
      and csi.item_id = r.p_item_id and csi.ver_nr = r.p_item_ver_nr
      and csi.CS_ITEM_ID = cs.ITEM_ID and csi.CS_ITEM_VER_NR = cs.VER_NR
      and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr
      and ai.regstr_stus_nm_dn not like '%RETIRED%' 
      and ai.admin_stus_nm_dn not like '%RETIRED%'
      and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING')
      and nvl(ai.CURRNT_VER_IND,0) = 1 
      and nvl(r.fld_delete,0) = 0
      and csix.item_id = csi.item_id and csix.ver_nr = csi.ver_nr and csix.admin_stus_nm_dn = 'RELEASED';

   COMMENT ON MATERIALIZED VIEW MVW_CSI_NODE_FORM_REL IS 'snapshot table for snapshot ONEDATA_WA.MVW_CSI_NODE_FORM_REL';

set define off;
set escape off;
drop materialized view mvw_csi_tree_form;
  CREATE MATERIALIZED VIEW MVW_CSI_TREE_FORM ("LVL", "P_ITEM_ID", "P_ITEM_VER_NR", "ITEM_ID", "VER_NR", "ITEM_DESC", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ITEM_LONG_NM", "ITEM_NM", "ADMIN_STUS_ID", "REGSTR_STUS_ID", "REGISTRR_CNTCT_ID", "SUBMT_CNTCT_ID", "STEWRD_CNTCT_ID", "SUBMT_ORG_ID", "STEWRD_ORG_ID", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "REGSTR_AUTH_ID", "NCI_IDSEQ", "ADMIN_STUS_NM_DN", "CNTXT_NM_DN", "REGSTR_STUS_NM_DN", "ORIGIN_ID", "ORIGIN_ID_DN", "CREAT_USR_ID_X", "LST_UPD_USR_ID_X", "ITEM_RPT_URL", "ITEM_RPT_EXCEL", "ITEM_RPT_PRIOR_EXCEL", "CHNG_NOTES", "TYP_ID", "P_ITEM_VER")

  AS select 98 LVL, null P_ITEM_ID, null P_ITEM_VER_NR,  ai.ITEM_ID || '(Context)' ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM,  
 ai.ITEM_NM || ' (' || ai.ITEM_DESC  || ') (' || nvl(y.cnt,'0') || ')'  ITEM_NM , ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
'NA' ITEM_RPT_URL ,
'NA' ITEM_RPT_EXCEL ,
'NA' ITEM_RPT_PRIOR_EXCEL,
'' CHNG_NOTES,
    0 TYP_ID,
null  P_ITEM_VER
from
ADMIN_ITEM ai, (select x.p_item_id, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_FORM_REL x where lvl='Context' and x.ADMIN_STUS_NM_DN not like '%RETIRED%' group by x.p_item_id ,
x.p_item_ver_nr) y , nci_mdr_cntrl c,nci_mdr_cntrl c1
 where ADMIN_ITEM_TYP_ID = 8 and ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 and c1.param_nm='DEEP_LINK'
 and y.cnt > 0
 union
select 99 LVL, CNTXT_ITEM_ID || '(Context)' P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ai.ITEM_ID || '(CS)' ,ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM,
ai.ITEM_NM || ' (' || nvl(y.cnt,'0') || ')' ITEM_NM, ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
'NA' ITEM_RPT_URL ,
'NA' ITEM_RPT_EXCEL ,
'NA' ITEM_RPT_PRIOR_EXCEL,
'' CHNG_NOTES,
      cs.CLSFCTN_SCHM_TYP_ID,
CNTXT_ITEM_ID || 'v'|| CNTXT_VER_NR P_ITEM_VER
 from
ADMIN_ITEM ai, clsfctn_schm cs,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_FORM_REL x where lvl='CS' and x.ADMIN_STUS_NM_DN not like '%RETIRED%' group by x.p_item_id ,
x.p_item_ver_nr) y, nci_mdr_cntrl c,nci_mdr_cntrl c1
 where ADMIN_ITEM_TYP_ID = 9 and ai.item_id =cs.item_id and ai.ver_nr = cs.ver_nr and  ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and admin_stus_nm_dn ='RELEASED' and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 and c1.param_nm='DEEP_LINK'
 and y.cnt > 0
 union
  select 100 LVL, csi.CS_ITEM_ID || '(CS)' P_ITEM_ID, csi.CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID || '(CSI)', ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM,
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' ITEM_NM,
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=101&type=csi\Legacy_Form_Builder_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=102&type=csi\Legacy_Form_Builder_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=105&type=csi\Form_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** USE THE LINKS ABOVE TO DOWNLOAD ALL FORMS FOR THIS NODE ********' CHNG_NOTES,
    csi.csi_typ_id,
csi.CS_ITEM_ID || 'v'|| csi.CS_ITEM_VER_NR P_ITEM_VER
from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_FORM_REL x where lvl='CSI' and x.ADMIN_STUS_NM_DN not like '%RETIRED%' group by x.p_item_id ,
x.p_item_ver_nr) y, nci_mdr_cntrl c,nci_mdr_cntrl c1
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
  and c1.param_nm='DEEP_LINK'
 and ai.admin_stus_nm_dn = 'RELEASED'
 and y.cnt > 0
 union
 select 100 LVL, csi.P_ITEM_ID || '(CSI)' P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, csi.P_ITEM_ID || ' '|| ai.ITEM_ID ITEM_ID , ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM,
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' ITEM_NM,
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=101&type=csi\Legacy_Form_Builder_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=102&type=csi\Legacy_Form_Builder_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=105&type=csi\Form_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** USE THE LINKS ABOVE TO DOWNLOAD ALL FORMS FOR THIS NODE ********' CHNG_NOTES,
    csi.CSI_TYP_ID,
csi.P_ITEM_ID || 'v'|| csi.P_ITEM_VER_NR P_ITEM_VER
 from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  
-- (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_FORM_REL x where lvl='CSI' and x.ADMIN_STUS_NM_DN not like '%RETIRED%' group by x.p_item_id ,
--x.p_item_ver_nr) y, 
(select x.csi_id, x.csi_ver, count(*) cnt from (select distinct z.form_id, z.form_ver, z.csi_id, z.csi_ver, z.admin_stus_nm_dn from mvw_csi_form_node_de_rel z) x 
where x.admin_stus_nm_dn not like '%RETIRED%' group by x.csi_id, x.csi_ver) y,
nci_mdr_cntrl c, nci_mdr_cntrl c1
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.csi_id (+) and ai.ver_nr = y.csi_ver (+) and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 and c1.param_nm='DEEP_LINK'
 and ai.admin_stus_nm_dn ='RELEASED'
 and y.cnt > 0
union
 select 225 LVL, r.P_ITEM_ID || '(CSI)' P_ITEM_ID, r.P_ITEM_VER_NR, r.P_ITEM_ID || ' '|| ai.ITEM_ID ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM,
   ai.ITEM_NM ITEM_NM,
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=101&type=frm\Legacy_Form_Builder_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=102&type=frm\Legacy_Form_Builder_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=105&type=frm\Form_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS FORM''s CDEs SWITCH "Details" TO  "View CDEs on Form". ********' CHNG_NOTES,
    54 CSI_TYP_ID,
r.P_ITEM_ID || 'v'|| r.P_ITEM_VER_NR P_ITEM_VER
 from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi, nci_mdr_cntrl c, nci_mdr_cntrl c1, nci_admin_item_rel r, 
 (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_FORM_REL x where lvl='Form' and x.ADMIN_STUS_NM_DN not like '%RETIRED%' group by x.p_item_id ,
x.p_item_ver_nr) y, 
--(select x.csi_id, x.csi_ver, count(*) from (select distinct z.form_id, z.form_ver, z.csi_id, z.csi_ver, z.admin_stus_nm_dn from mvw_csi_form_node_de_rel z) x 
--where x.admin_stus_nm_dn not like '%RETIRED%' group by x.csi_id, x.csi_ver) y,
admin_item csix, admin_item cs
 where ai.ADMIN_ITEM_TYP_ID = 54 and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr and r.rel_typ_id = 65 and
r.p_item_id=csi.item_id and r.p_item_ver_nr=csi.ver_nr and ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and
 upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 --and c1.param_nm='DEEP_LINK'
 and ai.admin_stus_nm_dn not like '%RETIRED%'
 and csi.item_id = csix.item_id and csi.ver_nr = csix.ver_nr and csix.admin_stus_nm_dn = 'RELEASED'
 and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr and cs.admin_stus_nm_dn = 'RELEASED'
 and ai.currnt_ver_ind = 1;

   COMMENT ON MATERIALIZED VIEW MVW_CSI_TREE_FORM  IS 'snapshot table for snapshot ONEDATA_WA.MVW_CSI_TREE_FORM';
alter table nci_stg_mdl add DT_LST_MODIFIED varchar2(32) default null;
commit;

--jira 3446
alter table nci_stg_mdl disable all triggers;
update nci_stg_mdl a set DT_LST_MODIFIED = to_char( (select lst_upd_dt from nci_stg_mdl b where b.mdl_imp_id = a.mdl_imp_id), 'MM/DD/YY HH24:MI:SS');
commit;
alter table nci_stg_mdl enable all triggers;

drop materialized view mvw_form_node_de_rel;
  CREATE MATERIALIZED VIEW MVW_FORM_NODE_DE_REL ("CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "LST_UPD_DT", "S2P_TRN_DT", "LST_DEL_DT", "FLD_DELETE", "ITEM_NM", "ITEM_LONG_NM", "ITEM_ID", "VER_NR", "ITEM_DESC", "CNTXT_NM_DN", "ADMIN_STUS_NM_DN", "REGSTR_STUS_NM_DN", "P_ITEM_ID", "P_ITEM_VER_NR", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ADMIN_STUS_ID", "REGSTR_STUS_ID", "PREF_QUEST_TXT", "USED_BY", "LVL")

  AS SELECT  distinct sysdate CREAT_DT, 
           'ONEDATA' CREAT_USR_ID,
           'ONEDATA' LST_UPD_USR_ID,
           sysdate LST_UPD_DT,
           sysdate S2P_TRN_DT,
           sysdate LST_DEL_DT,
           0 FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           r.P_ITEM_ID,  -- Form
           r.P_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           de.PREF_QUEST_TXT, 
	   e.USED_BY,
	   'Form' LVL
           FROM NCI_ADMIN_ITEM_REL r, NCI_ADMIN_ITEM_REL_ALT_KEY ak , ADMIN_ITEM ai, de , nci_admin_item_ext e, admin_item frm
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR and ai.admin_item_typ_id = 4 and ak.P_ITEM_ID = r.C_ITEM_ID and ak.P_ITEM_VER_NR = r.C_ITEM_VER_NR and
	   r.rel_typ_id = 61 and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr 
and nvl(ak.fld_delete,0) = 0 
and r.p_item_id = frm.item_id and r.p_item_ver_nr = frm.ver_nr and upper(frm.CNTXT_NM_DN) not in ('TEST', 'TRAINING') and frm.admin_stus_nm_dn not like '%RETIRED%' --jira 3435 exclude test/training/retired forms from cde counts
--and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn not like '%RETIRED%'
--and ai.admin_stus_nm_dn not like '%NON-CMPLNT%' and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING')
    UNION
  SELECT  distinct sysdate CREAT_DT, 
           'ONEDATA' CREAT_USR_ID,
           'ONEDATA' LST_UPD_USR_ID,
           sysdate LST_UPD_DT,
           sysdate S2P_TRN_DT,
           sysdate LST_DEL_DT,
           0 FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           prot.P_ITEM_ID,  -- Protocol
           prot.P_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           de.PREF_QUEST_TXT, 
	   e.USED_BY,
	   'Protocol' LVL
           FROM NCI_ADMIN_ITEM_REL r, nci_admin_item_rel prot, NCI_ADMIN_ITEM_REL_ALT_KEY ak , ADMIN_ITEM ai, de , nci_admin_item_ext e,
	   admin_item frm
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR and ai.admin_item_typ_id = 4 and ak.P_ITEM_ID = r.C_ITEM_ID and ak.P_ITEM_VER_NR = r.C_ITEM_VER_NR and
	   r.rel_typ_id = 61 and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
	   and r.p_item_id = prot.c_item_id and r.p_item_ver_nr = prot.c_item_ver_nr and prot.rel_typ_id=60
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and nvl(ak.fld_delete,0) = 0
and r.p_item_id = frm.item_id and r.p_item_ver_nr = frm.ver_nr 
--and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn not like '%RETIRED%'
--and ai.admin_stus_nm_dn not like '%NON-CMPLNT%' 
and upper(frm.CNTXT_NM_DN) not in ('TEST','TRAINING') and frm.admin_stus_nm_dn not like '%RETIRED%'
union
  SELECT  distinct sysdate CREAT_DT, 
           'ONEDATA' CREAT_USR_ID,
           'ONEDATA' LST_UPD_USR_ID,
           sysdate LST_UPD_DT,
           sysdate S2P_TRN_DT,
           sysdate LST_DEL_DT,
           0 FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           protai.CNTXT_ITEM_ID,  -- Context
           protai.CNTXT_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           de.PREF_QUEST_TXT, 
	   e.USED_BY,
	   'Context' LVL
           FROM NCI_ADMIN_ITEM_REL r, nci_admin_item_rel prot, NCI_ADMIN_ITEM_REL_ALT_KEY ak , ADMIN_ITEM ai, de , nci_admin_item_ext e,
	   admin_item protai, admin_item frm
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR and ai.admin_item_typ_id = 4 and ak.P_ITEM_ID = r.C_ITEM_ID and ak.P_ITEM_VER_NR = r.C_ITEM_VER_NR and
	   r.rel_typ_id = 61 and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
	   and r.p_item_id = prot.c_item_id and r.p_item_ver_nr = prot.c_item_ver_nr and prot.rel_typ_id=60
	   and prot.p_item_id = protai.item_id and prot.P_item_ver_nr = protai.ver_nr and protai.admin_item_typ_id = 50
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and nvl(ak.fld_delete,0) = 0
and r.p_item_id = frm.item_id and r.p_item_ver_nr = frm.ver_nr and upper(frm.CNTXT_NM_DN) not in ('TEST','TRAINING') and frm.admin_stus_nm_dn not like '%RETIRED%';

drop materialized view vw_form_tree_cde;
set define off;
set escape off;
  CREATE MATERIALIZED VIEW VW_FORM_TREE_CDE ("P_ITEM_ID", "P_ITEM_VER_NR", "ITEM_ID", "VER_NR", "ITEM_DESC", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ITEM_LONG_NM", "ITEM_NM", "ADMIN_STUS_ID", "REGSTR_STUS_ID", "REGISTRR_CNTCT_ID", "SUBMT_CNTCT_ID", "STEWRD_CNTCT_ID", "SUBMT_ORG_ID", "STEWRD_ORG_ID", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "REGSTR_AUTH_ID", "NCI_IDSEQ", "ADMIN_STUS_NM_DN", "CNTXT_NM_DN", "REGSTR_STUS_NM_DN", "ORIGIN_ID", "ORIGIN_ID_DN", "CREAT_USR_ID_X", "LST_UPD_USR_ID_X", "ITEM_RPT_URL", "ITEM_RPT_EXCEL", "ITEM_RPT_PRIOR_EXCEL", "FORM_RPT_PRIOR_EXCEL", "FORM_RPT_EXCEL", "FORM_RPT_RED_CAP", "ITEM_DEEP_LINK", "CHNG_NOTES")

  AS select CNTXT_ITEM_ID P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ITEM_LONG_NM,  ITEM_NM || ' (' 
 || nvl(y.cnt,'0') || ')' ITEM_NM , ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X 
 ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ver_nr || '&formatid=104&type=frm\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ver_nr || '&formatid=103&type=frm\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ver_nr || '&formatid=114&type=frm\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=102&type=protocol\Legacy_Form_Builder_Excel' FORM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=105&type=protocol\Form_Excel'  FORM_RPT_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=109&type=protocol\REDCap_DD_Form'  FORM_RPT_RED_CAP,
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
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=104&type=frm\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=103&type=frm\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=114&type=frm\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=102&type=frm\Legacy_Form_Builder_Excel' FORM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=105&type=frm\Form_Excel'  FORM_RPT_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=109&type=frm\REDCap_DD_Form'  FORM_RPT_RED_CAP,
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
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=104&type=frm\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=103&type=frm\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=114&type=frm\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'NA' FORM_RPT_PRIOR_EXCEL,
'NA' FORM_RPT_EXCEL,
'NA' FORM_RPT_RED_CAP,
--c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CDEForm.FRM_CNTXT_ITEM_ID=' || ai.item_id  ITEM_DEEP_LINK ,
''  ITEM_DEEP_LINK ,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES 
 from 
ADMIN_ITEM ai, (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_FORM_NODE_DE_REL x where lvl='Context' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c
	   --, nci_mdr_cntrl c1
 where ADMIN_ITEM_TYP_ID = 8 and item_id = y.p_item_id (+)  and ver_nr = y.p_item_ver_nr (+)
 --and admin_stus_nm_dn ='RELEASED' 
 and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING')  	
	   --and c1.param_nm='DEEP_LINK'
 and c.param_nm='DOWNLOAD_HOST';








