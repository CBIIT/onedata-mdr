alter table NCI_MDL add (MAP_USG_TYP_ID integer);

insert into obj_typ(obj_typ_id, obj_typ_desc) values (61,'Model Usage Type for Mapping');
commit;
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,135, 'Source Only');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,136, 'Target Only');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,137, 'Source or Target');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,138, 'Do Not Use');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (31, 229, 'Model Mapping Rules', 'Model Mapping Rules');
commit;

	alter table nci_mdl disable all triggers;
	update nci_mdl set 	MAP_USG_TYP_ID = 137 where 	MAP_USG_TYP_ID is null;
commit;
alter table nci_mdl enable all triggers;

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
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HGNC_CODE,
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_desc,''),'|') WITHIN GROUP (ORDER by XMAP_CD)HGNC_CODE_DESC,
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
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HGNC_TERM_TYP,
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


  CREATE OR REPLACE VIEW VW_MDL_MAP_IMP_TEMPLATE AS
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
	 tme.ITEM_LONG_NM "TGT_ELMNT_NAME", 
	  tmec."MEC_PHY_NM" "TGT_PHY_NAME", 
   	tmec.MEC_LONG_NM "TGT_MEC_NAME", 
       tmec.char_ord TGT_CHAR_ORD,
          map.MEC_MAP_NM "MAPPING_GROUP_NAME",
          map.MEC_MAP_DESC "MAPPING_GROUP_DESC",
	  src_func.obj_key_Desc "SOURCE_FUNCTION",
	  tgt_func.obj_key_Desc "TARGET_FUNCTION",
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
	paren.obj_key_desc "PARENTHESIS",
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
      smec.CDE_ITEM_ID  "SOURCE_CDE_ITEM_ID",
      smec.CDE_VER_NR  "SOURCE_CDE_VER",
      tmec.CDE_ITEM_ID  "TARGET_CDE_ITEM_ID",
      tmec.CDE_VER_NR  "TARGET_CDE_VER",
tmec.MEC_ID TGT_MEC_ID,
tmec.pk_ind TGT_PK_IND,
smec.pk_ind SRC_PK_IND,
svdrt.TERM_NAME "SOURCE_REF_TERM_SOURCE",
tvdrt.TERM_NAME "TARGET_REF_TERM_SOURCE"
	, tmed.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME_DERV"
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd,
	  obj_key deg,
	  obj_key src_func,
	  obj_key tgt_func,
	  obj_key op,
	  obj_key op_typ,
	  obj_key flow_cntrl,
	  obj_key paren,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd,
vw_val_dom_ref_term svdrt,
vw_val_dom_ref_term tvdrt
	where  sme.item_id (+)= smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr (+)= smec.MDL_ELMNT_VER_NR and
	 tme.item_id (+)= tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr (+)= tmec.MDL_ELMNT_VER_NR  and
	 tmed.item_id (+)= tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr (+)= tmecd.MDL_ELMNT_VER_NR  and
	   smec.MEC_ID (+)= map.SRC_MEC_ID and tmec.mec_id (+)= map.TGT_MEC_ID
	  and tmecd.mec_id (+)= map.TGT_MEC_ID_DERV
	  and map.map_deg = deg.obj_key_id (+)
	  and map.src_func_id= src_func.obj_key_id (+)
	  and map.tgt_func_id= tgt_func.obj_key_id (+)
	  and map.prov_org_id = org.entty_id (+)
	  and map.op_id = op.obj_key_id (+)
	  and map.paren = paren.obj_key_id (+)
	  and map.op_typ = op_typ.obj_key_id (+)
	  and map.flow_cntrl = flow_cntrl.obj_key_id (+)
          and smec.val_dom_item_id = svd.item_id (+)
	  and smec.val_dom_ver_nr = svd.ver_nr (+)
	  and tmec.val_dom_item_id = tvd.item_id (+)
 	  and tmec.val_dom_ver_nr = tvd.ver_nr (+)
          and svd.item_id = svdrt.item_id (+)
          and svd.ver_nr = svdrt.ver_nr (+)
          and tvd.item_id = tvdrt.item_id (+)
          and tvd.ver_nr = tvdrt.ver_nr (+);



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
nvl(term.term_use_name, cncpt.ITEM_NM)  TERM_CNCPT_DESC
	from admin_item m, NCI_MDL_ELMNT me,NCI_MDL_ELMNT_CHAR mec, value_dom vd, vw_cncpt cncpt, vw_val_dom_ref_term term
	where m.item_id = me.mdl_item_id and m.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.MDL_ELMNT_ITEM_ID
	and me.ver_nr = mec.MDL_ELMNT_VER_NR and m.admin_item_typ_id = 57
	  and mec.val_dom_item_id = vd.item_id(+) and mec.val_dom_ver_nr = vd.ver_nr(+)
and vd.TERM_CNCPT_ITEM_ID = cncpt.item_id (+)
and vd.term_cncpt_ver_nr = cncpt.ver_nr (+)
and vd.ITEM_ID = term.item_id (+)
and vd.ver_nr = term.ver_nr (+);


  CREATE OR REPLACE  VIEW VW_MDL_MAP_MANIFEST AS
  select   x.MDL_MAP_ITEM_ID ,
         x.mdl_map_ver_nr ,
        listagg(x.SRC_ELMNT_PHY_NM,',') within group (order by x.SRC_ELMNT_PHY_NM) SRC_ELMNT_NMS, 
	    substr(max(x.XWALK) || max(x.VALUE_MAP),2) SRC_FILES, 
 --  x.XWALK, x.VALUE_MAP,
        x.TGT_ELMNT_PHY_NM, 
        sysdate creat_dt,
	  'ONEDATA' creat_usr_id,	  
	   sysdate lst_upd_dt,
	  'ONEDATA' lst_upd_usr_id,
      0 FLD_DELETE,
      sysdate S2P_TRN_DT,
      sysdate LST_DEL_DT
	from
(  select   map.MDL_MAP_ITEM_ID ,
         map.mdl_map_ver_nr ,
sme.ITEM_PHY_OBJ_NM SRC_ELMNT_PHY_NM,
    max(CASE WHEN map.tgt_func_param LIKE '%XWALK%'
           THEN ',XWALK' END)  XWALK,
    max(CASE WHEN map.tgt_func_param LIKE 'VALUE%MAP%'
          THEN ',VALUE MAP' END)  VALUE_MAP,
        tme.ITEM_PHY_OBJ_NM  TGT_ELMNT_PHY_NM from
    --admin_item s, 
    NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec,NCI_MDL_ELMNT_CHAR tmec,
    --admin_item t, 
    NCI_MDL_ELMNT tme, nci_MEC_MAP map,
nci_mdl_map mm
	where mm.src_mdl_item_id = sme.mdl_item_id and mm.src_mdl_ver_nr = sme.mdl_item_ver_nr 
    and sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR and
	   smec.MEC_ID = map.SRC_MEC_ID and tmec.mec_id = map.TGT_MEC_ID 
    --and s.admin_item_typ_id = 57 
    and	  mm.tgt_mdl_item_id = tme.mdl_item_id and mm.tgt_mdl_ver_nr = tme.mdl_item_ver_nr 
and mm.item_id =  map.mdl_map_item_id and mm.ver_nr = map.mdl_map_ver_nr
group by map.MDL_MAP_ITEM_ID ,
         map.mdl_map_ver_nr ,sme.ITEM_PHY_OBJ_NM,tme.ITEM_PHY_OBJ_NM
         ) x
         group by x.MDL_MAP_ITEM_ID, x.MDL_MAP_VER_NR, x.TGT_ELMNT_PHY_NM;

--jira 3510
  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_NCI_DE_VM_ALT_NMS ("DE_ITEM_ID", "DE_VER_NR", "VAL_MEAN_ITEM_ID", "VAL_MEAN_VER_NR", "VAL_MEAN_LONG_NM", "VAL_DOM_ITEM_ID", "VAL_DOM_VER_NR", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "NM_DESC", "NM_TYP_ID", "VM_CNTXT_NM_DN", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "LANG_ID", "NM_ID", "PERM_VAL_NM", "PERM_VAL_DESC_TXT", "CNCPT_CONCAT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT   DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR, PV.NCI_VAL_MEAN_ITEM_ID VAL_MEAN_ITEM_ID, PV.NCI_VAL_MEAN_VER_NR VAL_MEAN_VER_NR, vm.ITEM_NM VAL_MEAN_LONG_NM, 
	PV.VAL_DOM_ITEM_ID  VAL_DOM_ITEM_ID, PV.VAL_DOM_VER_NR VAL_DOM_VER_NR ,
		an.CREAT_DT, AN.CREAT_USR_ID, AN.LST_UPD_USR_ID, greatest(nvl(AN.FLD_DELETE,0),nvl(pv.fld_delete,0)) fld_delete, 
		an.LST_DEL_DT, an.S2P_TRN_DT, AN.LST_UPD_DT,
         an.NM_DESC,  an.nm_typ_id, an.CNTXT_NM_DN VM_CNTXT_NM_DN  , an.CNTXT_ITEM_ID, an.CNTXT_VER_NR ,
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


--jira 3540
drop materialized view vw_form_tree_cde;
set define off;
set escape off;
  CREATE MATERIALIZED VIEW VW_FORM_TREE_CDE ("P_ITEM_ID", "P_ITEM_VER_NR", "ITEM_ID", "VER_NR", "ITEM_DESC", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ITEM_LONG_NM", "ITEM_NM", "ADMIN_STUS_ID", "REGSTR_STUS_ID", "REGISTRR_CNTCT_ID", "SUBMT_CNTCT_ID", "STEWRD_CNTCT_ID", "SUBMT_ORG_ID", "STEWRD_ORG_ID", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "REGSTR_AUTH_ID", "NCI_IDSEQ", "ADMIN_STUS_NM_DN", "CNTXT_NM_DN", "REGSTR_STUS_NM_DN", "ORIGIN_ID", "ORIGIN_ID_DN", "CREAT_USR_ID_X", "LST_UPD_USR_ID_X", "ITEM_RPT_URL", "ITEM_RPT_EXCEL", "ITEM_RPT_PRIOR_EXCEL", "FORM_RPT_PRIOR_EXCEL", "FORM_RPT_EXCEL", "FORM_RPT_RED_CAP", "ITEM_DEEP_LINK", "ITEM_RPT_PFL", "CHNG_NOTES")

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
'NA' ITEM_RPT_PFL,
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
c.PARAM_VAL || '/invoke/downloads.form/printerFriendly?item_id=' || ai.item_id || '&version=' || ai.ver_nr || '\Click_to_View' ITEM_RPT_PFL,
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
'NA' ITEM_RPT_PFL,
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

--jira 3545
  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_NCI_CRDC_DE ("ITEM_ID", "VER_NR", "ITEM_ID_STR", "ITEM_NM", "ITEM_LONG_NM", "ITEM_DESC", "ADMIN_NOTES", "CHNG_DESC_TXT", "CREATION_DT", "EFF_DT", "ORIGIN", "ORIGIN_ID", "ORIGIN_ID_DN", "UNRSLVD_ISSUE", "UNTL_DT", "CURRNT_VER_IND", "REGSTR_STUS_ID", "ADMIN_STUS_ID", "CNTXT_NM_DN", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "CREAT_USR_ID", "CREAT_USR_ID_X", "LST_UPD_USR_ID", "LST_UPD_USR_ID_X", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "LST_UPD_DT_X", "CREAT_DT", "NCI_IDSEQ", "CSI_CONCAT", "PRNT_SUBSET_ITEM_ID", "PRNT_SUBSET_VER_NR", "SUBSET_DESC", "ADMIN_ITEM_TYP_ID", "ITEM_DEEP_LINK", "CNTXT_AGG", "CRDC_NM", "CRDC_DEF", "CRDC_CODE_INSTR", "CRDC_INSTR", "CRDC_EXMPL", "DEC_ID", "DEC_VER", "VAL_DOM_TYP_ID", "VD_ID", "VD_VER") DEFAULT COLLATION "USING_NLS_COMP"  AS 
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
           ADMIN_ITEM.LST_UPD_DT                LST_UPD_DT_X,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.NCI_IDSEQ,
	   ext.csi_concat,
           de.PRNT_SUBSET_ITEM_ID,
	  de.PRNT_SUBSET_VER_NR,
	DE.SUBSET_DESC, 
	  ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
	   ADMIN_ITEM.ITEM_DEEP_LINK,
           ext.USED_BY                         CNTXT_AGG,
           nvl(CRDC_NM.NM_DESC,admin_item.item_nm)                        CRDC_NM,
           CRDC_DEF.DEF_DESC                 CRDC_DEF,
               CODE_INSTR_REF_DESC CRDC_CODE_INSTR,
            INSTR_REF_DESC                            CRDC_INSTR,
          EXAMPL                           CRDC_EXMPL,
            de.de_conc_item_id DEC_ID,
	de.de_conc_ver_nr DEC_VER,
            vd.VAL_DOM_TYP_ID,
            vd.item_id VD_ID,
            vd.ver_nr VD_VER	  FROM ADMIN_ITEM,
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
and admin_item.regstr_stus_id in (2, 3);

  CREATE TABLE NCI_DLOAD_MDL_MAP
   (	"HDR_ID" NUMBER, 
	"MDL_MAP_ID" NUMBER, 
	"MDL_MAP_VER_NR" NUMBER(4,2), 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	 PRIMARY KEY ("HDR_ID"))
 ;
   GRANT SELECT ON NCI_DLOAD_MDL_MAP TO "ONEDATA_RO";

drop materialized view mvw_csi_form_node_de_rel; 
 CREATE MATERIALIZED VIEW MVW_CSI_FORM_NODE_DE_REL ("CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "LST_UPD_DT", "S2P_TRN_DT", "LST_DEL_DT", "FLD_DELETE", "ITEM_NM", "ITEM_LONG_NM", "ITEM_ID", "VER_NR", "ITEM_DESC", "CNTXT_NM_DN", "ADMIN_STUS_NM_DN", "REGSTR_STUS_NM_DN", "FORM_ID", "FORM_VER", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ADMIN_STUS_ID", "REGSTR_STUS_ID", "PREF_QUEST_TXT", "C_ITEM_ID", "C_ITEM_VER_NR", "CSI_ID", "CSI_VER", "USED_BY", "LVL")

  AS SELECT  distinct ai.CREAT_DT,
           ai.CREAT_USR_ID,
           ai.LST_UPD_USR_ID,
           sysdate LST_UPD_DT,
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
          f.P_ITEM_ID FORM_ID,
          f.P_ITEM_VER_NR FORM_VER,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           de.PREF_QUEST_TXT,
           
          csi.P_ITEM_ID || ' ' || f.P_ITEM_ID C_ITEM_ID,
          f.P_ITEM_VER_NR C_ITEM_VER_NR,
        csi.p_item_id CSI_ID,
        csi.p_item_ver_nr CSI_VER,
           e.USED_BY,
           'Form' LVL
       --    csi.P_ITEM_ID || 'v' || csi.P_ITEM_VER_NR P_ITEM_ID_VER
           
from nci_admin_item_rel_alt_key m, admin_item ai, nci_admin_item_rel f, nci_admin_item_rel csi,  de, nci_admin_item_ext e
where 
    m.rel_typ_id = 63
    and m.C_ITEM_ID = ai.item_id and m.C_ITEM_VER_NR = ai.ver_nr and ai.admin_item_typ_id = 4
    and m.P_ITEM_ID = f.C_ITEM_ID and m.P_ITEM_VER_NR = f.C_ITEM_VER_NR and f.rel_typ_id = 61
    and f.P_ITEM_ID = csi.C_ITEM_ID and f.P_ITEM_VER_NR = csi.C_ITEM_VER_NR and csi.rel_typ_id = 65
    and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
    and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr
    and nvl(m.fld_delete,0) = 0
    and nvl(f.fld_delete,0) = 0
    and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING');

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
from admin_item ai, mvw_csi_rel csi, nci_admin_item_rel r, nci_admin_item_ext e, admin_item csix
where ai.admin_item_typ_id = 54 and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr
      and r.rel_typ_id =65
      and csi.item_id = r.p_item_id and csi.ver_nr = r.p_item_ver_nr
  --    and ak.item_id = csi.item_id and ak.ver_nr = csi.ver_nr
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
    from admin_item ai, mvw_csi_rel csi, nci_admin_item_rel r, nci_admin_item_ext e, admin_item csix
    where ai.admin_item_typ_id = 54 and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr
      and r.rel_typ_id =65
      and csi.item_id = r.p_item_id and csi.ver_nr = r.p_item_ver_nr
   --   and ak.item_id = csi.item_id and ak.ver_nr = csi.ver_nr
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
           csi.CS_ITEM_ID P_ITEM_ID,
           csi.CS_ITEM_VER_NR P_ITEM_VER_NR,
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
           cs.CNTXT_ITEM_ID P_ITEM_ID,
           cs.CNTXT_VER_NR P_ITEM_VER_NR,
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

drop materialized view mvw_csi_tree_form;
set define off;
set escape off;
  CREATE MATERIALIZED VIEW MVW_CSI_TREE_FORM ("LVL", "P_ITEM_ID", "P_ITEM_VER_NR", "ITEM_ID", "VER_NR", "ITEM_DESC", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ITEM_LONG_NM", "ITEM_NM", "ADMIN_STUS_ID", "REGSTR_STUS_ID", "REGISTRR_CNTCT_ID", "SUBMT_CNTCT_ID", "STEWRD_CNTCT_ID", "SUBMT_ORG_ID", "STEWRD_ORG_ID", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "REGSTR_AUTH_ID", "NCI_IDSEQ", "ADMIN_STUS_NM_DN", "CNTXT_NM_DN", "REGSTR_STUS_NM_DN", "ORIGIN_ID", "ORIGIN_ID_DN", "CREAT_USR_ID_X", "LST_UPD_USR_ID_X", "ITEM_RPT_URL", "ITEM_RPT_EXCEL", "ITEM_RPT_PRIOR_EXCEL", "ITEM_RPT_PFL", "CHNG_NOTES", "TYP_ID", "P_ITEM_VER")
  AS select 98 LVL, null P_ITEM_ID, null P_ITEM_VER_NR,  ai.ITEM_ID || '(Context)' ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM,  
 ai.ITEM_NM || ' (' || ai.ITEM_DESC  || ') (' || nvl(y.cnt,'0') || ')'  ITEM_NM , ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
'NA' ITEM_RPT_URL ,
'NA' ITEM_RPT_EXCEL ,
'NA' ITEM_RPT_PRIOR_EXCEL,
'NA' ITEM_RPT_PFL,
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
'NA' ITEM_RPT_PFL,
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
  select 100 LVL, csi.CS_ITEM_ID || '(CS)' P_ITEM_ID, csi.CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID || '(CSI)' ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM,
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' ITEM_NM,
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=101&type=csi\Legacy_Form_Builder_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=102&type=csi\Legacy_Form_Builder_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=105&type=csi\Form_Excel' ITEM_RPT_PRIOR_EXCEL,
'NA' ITEM_RPT_PFL,
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
 select 100 LVL, csi.P_ITEM_ID || '(CSI)' P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID || '(CSI)' ITEM_ID , ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM,
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' ITEM_NM,
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=101&type=csi\Legacy_Form_Builder_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=102&type=csi\Legacy_Form_Builder_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || csi.item_id || '&p_item_ver_nr=' || csi.ver_nr || '&formatid=105&type=csi\Form_Excel' ITEM_RPT_PRIOR_EXCEL,
'NA' ITEM_RPT_PFL,
'******** USE THE LINKS ABOVE TO DOWNLOAD ALL FORMS FOR THIS NODE ********' CHNG_NOTES,
    csi.CSI_TYP_ID,
csi.P_ITEM_ID || 'v'|| csi.P_ITEM_VER_NR P_ITEM_VER
 from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  
(select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_FORM_REL x where lvl='CSI' and x.ADMIN_STUS_NM_DN not like '%RETIRED%' group by x.p_item_id ,
x.p_item_ver_nr) y, 
--(select x.csi_id, x.csi_ver, count(*) cnt from (select distinct z.form_id, z.form_ver, z.csi_id, z.csi_ver, z.admin_stus_nm_dn from mvw_csi_form_node_de_rel z) x 
--where x.admin_stus_nm_dn not like '%RETIRED%' group by x.csi_id, x.csi_ver) y,
nci_mdr_cntrl c, nci_mdr_cntrl c1
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null and csi.CS_ITEM_ID is not null and
 --ai.item_id = y.csi_id (+) and ai.ver_nr = y.csi_ver (+)
 ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+)
  and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
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
c.PARAM_VAL || '/invoke/downloads.form/printerFriendly?item_id=' || ai.item_id || '&version=' || ai.ver_nr || '\Click_to_View' ITEM_RPT_PFL,
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
 and ai.currnt_ver_ind = 1
 union
 select 225 LVL, r.P_ITEM_ID || '(CSI)' P_ITEM_ID, r.P_ITEM_VER_NR, r.P_ITEM_ID || ' '|| ai.ITEM_ID ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM,
   ai.ITEM_NM ITEM_NM,
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=101&type=frm\Legacy_Form_Builder_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=102&type=frm\Legacy_Form_Builder_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=105&type=frm\Form_Excel' ITEM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/invoke/downloads.form/printerFriendly?item_id=' || ai.item_id || '&version=' || ai.ver_nr || '\Click_to_View' ITEM_RPT_PFL,
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
 and csi.p_item_id is not null
 and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr and cs.admin_stus_nm_dn = 'RELEASED'
 and ai.currnt_ver_ind = 1;

CREATE TABLE "NCI_CNCPT_PATH" 
   (	"BEGINCONCEPTCODE" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP", 
	"ENDCONCEPTCODE" VARCHAR2(400 BYTE) COLLATE "USING_NLS_COMP", 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	 PRIMARY KEY ("BEGINCONCEPTCODE", "ENDCONCEPTCODE"));

alter table NCI_DS_HDR add (PREF_CNCPT_CONCAT_DEF varchar2(8000));

