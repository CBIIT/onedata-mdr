
create materialized view vw_prmry_oc_cncpt as select ai.item_id, ai.ver_nr, item_nm from admin_item ai, cncpt c where ai.item_id = c.item_id and ai.ver_nr= c.ver_nr and
nvl(prmry_obj_cls_ind,0) = 1;

    
drop materialized view VW_PRMRY_OC_CNCPT_REL;

  CREATE MATERIALIZED VIEW VW_PRMRY_OC_CNCPT_REL
  AS select c_item_id, c_item_ver_nr, listagg(sys_path_distinct, '|') sys_path_final, listagg(lvl, '|') lvl
from (
select  c_item_id, c_item_ver_nr, substr( sys_path, instr(sys_path,'|',1,1)+1, instr(sys_path,'|',1,2)-instr(sys_path,'|',1,1)-1) sys_path_distinct, min(lvl) lvl
 from
(select  c_item_id, c_item_ver_nr,
 CAST (SYS_CONNECT_BY_PATH (ai.ITEM_NM, '|') AS VARCHAR2 (4000)) SYS_PATH, level lvl
--listagg(ai.item_nm ,'|')
from admin_Item ai, nci_cncpt_rel r where r.rel_typ_id = 68 and ai.item_id = r.p_item_id and ai.ver_nr = r.p_item_ver_nr
and ai.admin_item_typ_id = 49
start with r.p_item_id in (select item_id from vw_prmry_oc_cncpt) 
  CONNECT BY PRIOR  to_char(r.c_item_id || to_char(r.c_item_ver_nr,'99.99')) = to_char(r.p_item_id || to_char(r.P_item_ver_nr,'99.99'))) 
  group by c_item_id, c_item_ver_nr, substr( sys_path, instr(sys_path,'|',1,1)+1, instr(sys_path,'|',1,2)-instr(sys_path,'|',1,1)-1))
  group by c_iteM_id, c_item_ver_nr;
  
drop materialized view vw_cncpt;

               
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
        substr(ADMIN_ITEM.ITEM_NM || ' | ' || a.SYN, 1, 4000) SYN,substr(a.SYN_MTCH_TERM,1,4000) SYN_MTCH_TERM, MTCH_TERM, MTCH_TERM_ADV,
    nvl(PRMRY_OBJ_CLS_IND,0) PRMRY_OBJ_CLS_IND,  decode(PRMRY_OBJ_CLS_IND,1,'Yes','') PRMRY_OBJ_CLS_IND_NM ,
    b.sys_path_final,
	  b.lvl,
 'TEST' NCI_META_CUI
  --  xm.xmap_cd NCI_META_CUI
              FROM ADMIN_ITEM,  CNCPT, nci_admin_item_ext e, OBJ_KEY, (select item_id, ver_nr,  substr( LISTAGG(nm_desc, ' | ') WITHIN GROUP (ORDER by ITEM_ID),1,8000) AS SYN,
			        LISTAGG(MTCH_TERM_ADV , ' | ') WITHIN GROUP (ORDER by ITEM_ID) AS SYN_MTCH_TERM from ALT_NMS a group by item_id, ver_nr) a,
                vw_prmry_oc_cncpt_rel b
       WHERE ADMIN_ITEM_TYP_ID = 49 and ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID and ADMIN_ITEM.VER_NR = CNCPT.VER_NR
       and admin_item.item_id = e.item_id and admin_item.ver_nr = e.ver_nr
	and cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID (+) and admin_item.admin_stus_nm_dn = 'RELEASED' 
	and ADMIN_ITEM.ITEM_ID = a.ITEM_ID (+) and ADMIN_ITEM.VER_NR = a.VER_NR (+)
    and admin_item.item_id = b.c_item_id  (+) and admin_item.ver_nr = b.c_item_ver_nr (+);



alter table NCI_MEC_VAL_MAP add (SORT_ORD integer);
alter table NCI_STG_MEC_VAL_MAP add (SORT_ORD integer);
alter table NCI_MEC_MAP add (SORT_ORD integer);
alter table NCI_STG_MEC_MAP add (SORT_ORD integer);

--jira 4135
insert into obj_key( obj_key_id, obj_key_desc, obj_typ_id, obj_key_def) values (244, 'Model Mappings - Value Mappings', 31,'Model Mappings - Value Mappings');
commit;


  CREATE OR REPLACE  VIEW VW_VAL_MAP_IMP_TEMPLATE AS
  select  ' ' "DO_NOT_USE",
       ' ' "BATCH_USER",
       ' ' "BATCH_NAME",
       rownum "SEQ_ID",
       vmap.mdl_map_item_id "MODEL_MAP_ID",
       vmap.mdl_map_ver_nr "MODEL_MAP_VERSION",
	vmap.MECM_ID_DESC,
        vmap.mecvm_id "MECVM_ID", 
   	sme.ITEM_PHY_OBJ_NM "SRC_ELMNT_PHY_NAME", 
	sme.ITEM_LONG_NM "SRC_ELMNT_NAME", 
  smec."MEC_PHY_NM" "SRC_PHY_NAME", 
	smec.MEC_LONG_NM "SRC_MEC_NAME", 
	  tme.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME", 
	 tme.ITEM_LONG_NM "TGT_ELMNT_NAME", 
	  tmec."MEC_PHY_NM" "TGT_PHY_NAME", 
   	tmec.MEC_LONG_NM "TGT_MEC_NAME", 
   	  deg.obj_key_Desc "MAPPING_DEGREE",
	org.org_nm "PROV_ORG",
cnt.PRSN_FULL_NM_DERV	"PROV_CONTACT",
	vmap.prov_rsn_txt "PROV_REVIEW_REASON",
	vmap.prov_typ_rvw_txt "PROV_TYPE_OF_REVIEW",
	vmap.PROV_RVW_DT "PROV_REVIEW_DATE",
	vmap.prov_APRV_DT "PROV_APPROVAL_DATE",
	vmap.prov_Notes "PROV_APPROVAL_NOTES",
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "SOURCE_DOMAIN_TYPE",
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "TARGET_DOMAIN_TYPE",
    vmap.SRC_PV,
    vmap.TGT_PV,
    vmap.SRC_LBL,
    vmap.TGT_LBL, 
    vmap.SRC_VM_CNCPT_CD,
    vmap.SRC_VM_CNCPT_NM,
  vmap.TGT_VM_CNCPT_CD,
    vmap.TGT_VM_CNCPT_NM,
	   vmap."CREAT_DT",
	  vmap."CREAT_USR_ID",
	  vmap."LST_UPD_USR_ID",
	  vmap."FLD_DELETE",
	  vmap."LST_DEL_DT",
	  vmap."S2P_TRN_DT",
	  vmap."LST_UPD_DT",
      smec.MEC_ID SRC_MEC_ID,
      smec.CDE_ITEM_ID  "SOURCE_CDE_ITEM_ID",
      smec.CDE_VER_NR  "SOURCE_CDE_VER",
      tmec.CDE_ITEM_ID  "TARGET_CDE_ITEM_ID",
      tmec.CDE_VER_NR  "TARGET_CDE_VER",
       svd.ITEM_ID  "SOURCE_VD_ITEM_ID",
      svd.VER_NR  "SOURCE_VD_VER",
      tvd.ITEM_ID  "TARGET_VD_ITEM_ID",
      tvd.VER_NR  "TARGET_VD_VER",
tmec.MEC_ID TGT_MEC_ID,
svdrt.TERM_USE_NAME "SOURCE_REF_TERM_SOURCE",
tvdrt.TERM_USE_NAME "TARGET_REF_TERM_SOURCE",
    ' ' "CMNTS_DESC_TXT",
	  sort_ord "SORT_ORDER"
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec,	NCI_MEC_VAL_MAP vmap,
	  obj_key deg,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd,
vw_val_dom_ref_term svdrt,
vw_val_dom_ref_term tvdrt,
	  NCI_PRSN cnt
	where  sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and
	  nvl(vmap.fld_delete,0) = 0 and
	 tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR  
	  and vmap.map_deg = deg.obj_key_id (+)
	  and vmap.prov_org_id = org.entty_id (+)
	        and smec.val_dom_item_id = svd.item_id (+)
	  and smec.val_dom_ver_nr = svd.ver_nr (+)
	  and tmec.val_dom_item_id = tvd.item_id (+)
 	  and tmec.val_dom_ver_nr = tvd.ver_nr  (+)
          and svd.item_id = svdrt.item_id (+)
	  and vmap.PROV_CNTCT_ID = cnt.entty_id (+)
          and svd.ver_nr = svdrt.ver_nr (+)
          and tvd.item_id = tvdrt.item_id (+)
          and tvd.ver_nr = tvdrt.ver_nr (+)
          and vmap.src_mec_id = smec.mec_id
          and vmap.tgt_mec_id = tmec.mec_id;


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
	 tme.ITEM_LONG_NM "TGT_ELMNT_NAME", 
	  tmec."MEC_PHY_NM" "TGT_PHY_NAME", 
   	tmec.MEC_LONG_NM "TGT_MEC_NAME", 
       tmec.char_ord TGT_CHAR_ORD,
          map.MEC_MAP_NM "MAPPING_GROUP_NAME",
    map.tgt_func_id "TARGET_FUNCTION_ID",
          ' ' "TRANS_RULE_NOTATION",
map.mec_sub_grp_nbr	"DERIVATION_GROUP_ORDER",
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
cnt.PRSN_FULL_NM_DERV	"PROV_CONTACT",
	map.prov_rsn_txt "PROV_REVIEW_REASON",
	map.prov_typ_rvw_txt "PROV_TYPE_OF_REVIEW",
	map.PROV_RVW_DT "PROV_REVIEW_DATE",
	map.prov_APRV_DT "PROV_APPROVAL_DATE",
	  map.pcode_sysgen,
	  map.map_deg,
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
	  smec.val_dom_item_id "SOURCE_VD_ITEM_ID",
	  smec.val_dom_ver_nr "SOURCE_VD_VER_NR",
	    tmec.val_dom_item_id "TARGET_VD_ITEM_ID",
	  tmec.val_dom_ver_nr "TARGET_VD_VER_NR",
	  sme.MDL_ITEM_ID SRC_MDL_ITEM_ID,
	  sme.MDL_item_ver_nr src_mdl_ver_nr,
	  tme.MDL_ITEM_ID TGT_MDL_ITEM_ID,
	  tme.MDL_item_ver_nr TGT_mdl_ver_nr,
tmec.MEC_ID TGT_MEC_ID,
tmec.pk_ind TGT_PK_IND,
smec.pk_ind SRC_PK_IND,
svdrt.TERM_USE_NAME "SOURCE_REF_TERM_SOURCE",
tvdrt.TERM_USE_NAME "TARGET_REF_TERM_SOURCE"
	, tmed.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME_DERV",
    ' ' "CMNTS_DESC_TXT",
	  map.creat_usr_id creat_usr_id_x,
	  map.lst_upd_usr_id lst_upd_usr_id_x,
	  map.creat_dt creat_dt_x,
	  map.lst_upd_dt lst_upd_dt_x,
	  map.sort_ord
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd,
	  obj_key op,
	  obj_key op_typ,
	  obj_key flow_cntrl,
	  obj_key paren,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd,
vw_val_dom_ref_term svdrt,
vw_val_dom_ref_term tvdrt,
	  NCI_PRSN cnt
	where  sme.item_id (+)= smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr (+)= smec.MDL_ELMNT_VER_NR and
	 tme.item_id (+)= tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr (+)= tmec.MDL_ELMNT_VER_NR  and
	 tmed.item_id (+)= tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr (+)= tmecd.MDL_ELMNT_VER_NR  and
	   smec.MEC_ID (+)= map.SRC_MEC_ID and tmec.mec_id (+)= map.TGT_MEC_ID
	  and tmecd.mec_id (+)= map.TGT_MEC_ID_DERV
	  and map.PROV_CNTCT_ID = cnt.entty_id (+)
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

alter table nci_mdl_elmnt_char add (MDL_PK_IND number(1));
alter table nci_stg_mdl_elmnt_char add (MDL_PK_IND varchar2(10));


  CREATE OR REPLACE  VIEW VW_MDL_IMP_TEMPLATE AS
  SELECT ' '                DO_NOT_USE,
       ' '                  BATCH_USER,
       ' '                  BATCH_NAME,
       ROWNUM               SEQ_ID,
       ai.item_nm           MDL_NM, 
       ai.item_id           MDL_ID, 
       ai.ver_nr            MDL_VER_NR, 
       me.item_long_nm      ME_LONG_NM, 
       me.item_phy_obj_nm   ME_PHY_NM, 
       me.item_desc         ME_DESC, 
       me_typ.obj_key_desc ME_TYP_DESC,   
       mec.mec_long_nm      MEC_LONG_NM, 
       mec.MEC_PHY_NM       MEC_PHY_NM, 
       mec.CHAR_ORD         MEC_CHAR_ORD, 
       mec.                 MEC_DESC, 
       mec_typ.obj_key_Desc MEC_TYP_DESC,  
       mec.src_min_char     MEC_MIN_CHAR, 
       mec.src_max_char     MEC_MAX_CHAR, 
       dt.dttype_nm         MEC_DT_TYP_DESC, 
       uom.uom_nm           UOM_DESC,  
       mec_req.obj_key_Desc          MEC_MNDTRY,  
       decode(mec.pk_ind,1,'Yes','No')           MEC_PK_IND,    
       decode(mec.mdl_pk_ind,1,'Yes','No')           MEC_MDL_PK_IND,    
       mec.src_deflt_val    MEC_DEFLT_VAL, 
       mec.cde_item_id      CDE_ID, 
       mec.cde_ver_nr       CDE_vERSION, 
       decode(mec.FK_IND,1,'Yes','No')           MEC_FK_IND, 
       mec.                 FK_ELMNT_PHY_NM, 
       mec.                 FK_ELMNT_CHAR_PHY_NM, 
       ' '                  COMMENTS            
FROM admin_item            ai,
     nci_mdl               mdl,
     nci_mdl_elmnt         me,
     nci_mdl_elmnt_char    mec,
     obj_key               mec_typ,
     obj_key               me_typ,
     obj_key               mec_req,
     data_typ              dt,
     uom                   uom,
     value_dom             vdst 
WHERE ai.item_id                  = mdl.item_id
  AND ai.ver_nr                   = mdl.ver_nr
  AND ai.admin_item_typ_id        = 57
  AND mdl.item_id                 = me.mdl_item_id
  AND mdl.ver_nr                  = me.mdl_item_ver_nr
  AND me.item_id                  = mec.mdl_elmnt_item_id
  AND me.ver_nr                   = mec.mdl_elmnt_ver_nr
  AND mec.val_dom_item_id         = vdst.item_id (+)
  AND mec.val_dom_ver_nr          = vdst.ver_nr (+)
  AND mec.mdl_elmnt_char_typ_id   = mec_typ.obj_key_id (+)
  AND mec.req_ind  = mec_req.obj_key_id (+)
  AND me.ME_TYP_ID  = me_typ.obj_key_id (+)
  AND vdst.nci_std_dttype_id      = dt.dttype_id (+)
  AND vdst.uom_id                 = uom.uom_id (+);


  CREATE OR REPLACE VIEW VW_NCI_MEC AS
  select m.item_id mdl_item_id, m.ver_nr mdl_ver_nr, m.item_nm mdl_item_nm, me.item_id ME_ITEM_ID, me.ver_nr me_VER_NR,
	me.ITEM_LONG_NM me_item_nm, me.ITEM_PHY_OBJ_NM me_phy_nm, mec."MEC_ID",mec."MDL_ELMNT_ITEM_ID",mec."MDL_ELMNT_VER_NR",mec."MEC_TYP_ID",mec."CREAT_DT",
mec."CREAT_USR_ID",mec."LST_UPD_USR_ID",mec."FLD_DELETE", mec.char_ord, mec.pk_ind,
	  mec."LST_DEL_DT",mec."S2P_TRN_DT",mec."LST_UPD_DT",mec."SRC_DTTYPE",mec."STD_DTTYPE_ID",mec."SRC_MAX_CHAR",mec."SRC_MIN_CHAR",
vd."VAL_DOM_TYP_ID",mec."SRC_UOM",mec."UOM_ID",mec."SRC_DEFLT_VAL",mec."SRC_ENUM_SRC",mec."DE_CONC_ITEM_ID",mec."DE_CONC_VER_NR",
mec."VAL_DOM_ITEM_ID",mec."VAL_DOM_VER_NR",mec."NUM_PV",mec."MEC_LONG_NM",mec."MEC_PHY_NM",mec."MEC_DESC",mec."CDE_ITEM_ID",mec."CDE_VER_NR",
decode(vd.val_dom_typ_id, 16, 'Enumerated by Reference', 17, 'Enumerated',18,'Non-enumerated','') VAL_DOM_TYP_DESC,
vd.TERM_CNCPT_ITEM_ID,
vd.TERM_CNCPT_VER_NR,
  me.ITEM_PHY_OBJ_NM || '.' || mec.MEC_PHY_NM me_mec_phy_nm, 
  me.ITEM_LONG_NM || '.' || mec.MEC_LONG_NM me_mec_long_nm, term.term_use_name TERM_CNCPT_DESC
-- nvl(term.term_use_name, cncpt.ITEM_NM)  TERM_CNCPT_DESC
	from admin_item m, NCI_MDL_ELMNT me,NCI_MDL_ELMNT_CHAR mec, value_dom vd,
	  --vw_cncpt cncpt, 
	  vw_val_dom_ref_term term
	where m.item_id = me.mdl_item_id and m.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.MDL_ELMNT_ITEM_ID
	and me.ver_nr = mec.MDL_ELMNT_VER_NR and m.admin_item_typ_id = 57
	  and mec.val_dom_item_id = vd.item_id(+) and mec.val_dom_ver_nr = vd.ver_nr(+)
--and vd.TERM_CNCPT_ITEM_ID = cncpt.item_id (+)
--and vd.term_cncpt_ver_nr = cncpt.ver_nr (+)
and vd.ITEM_ID = term.item_id (+)
and vd.ver_nr = term.ver_nr (+);



  CREATE OR REPLACE  VIEW VW_MDL_FLAT_VB AS
  select ai.item_id MDL_ITEM_ID, 
	ai.ver_nr  MDL_VER_NR, 
	ai.item_nm  MDL_NM, 
        ai.cntxt_nm_dn  MDL_CNTXT_NM, 
	ai.admin_stus_nm_dn  MDL_ADMIN_STUS_NM, 
	ai.regstr_stus_nm_dn  MDL_REGSTR_STUS_NM,
	mdl_lang.obj_key_desc MDL_LANG_DESC ,
	mdl_typ.obj_key_desc MDL_TYP_DESC,
	ai.currnt_ver_ind MDL_CURRNT_VER_IND, 
	me.item_long_nm  ME_LONG_NM, 
	me.item_phy_obj_nm ME_PHY_NM ,
	me_typ.obj_key_desc ME_TYP_DESC,
	me.item_desc ME_DESC,
	me_grp.obj_key_desc ME_MAP_GRP_DESC,
	me.item_id ME_ITEM_ID, 
	me.ver_nr ME_VER_NR, 
	mec.creat_dt, 
	mec.creat_usr_id, 
	mec.lst_upd_dt, 
	mec.lst_upd_usr_id, 
	mec.s2p_trn_dt, 
	mec.fld_delete, 
	mec.lst_del_dt,
	mec.src_dttype MEC_DTTYP, 
	mec.CHAR_ORD MEC_CHAR_ORD, 
	mec.src_max_char MEC_MAX_CHAR, 
	mec.src_min_char MEC_MIN_CHAR, 
	mec.src_uom MEC_UOM, 
	mec.src_deflt_val MEC_DEFLT_VAL, 
	mec.de_conc_item_id, 
	mec.de_conc_ver_nr,
	dec.item_nm DEC_NM,
	dec.cntxt_nm_dn DEC_CNTXT_NM,
--	mec.val_dom_item_id,
--	mec.val_dom_ver_nr, 
	mec.mec_long_nm , 
	mec.mec_phy_nm , 
	mec.mec_desc , 
	mec.cde_item_id , 
	  mec.val_dom_item_id, 
	  mec.val_dom_ver_nr,
decode(vdst.VAL_DOM_TYP_ID,16, 'Enumerated by Reference', 17, 'Enumerated',18, 'Non-enumerated') VAL_DOM_TYP,
	  vdrt.TERM_NAME,
	  vdrt.USE_NAME,
	  vdst.VAL_DOM_MIN_CHAR, 
	  vdst.VAL_DOM_MAX_CHAR, 
	  vd.item_nm vd_item_nm,
	  dt.dttype_nm DT_TYP_DESC,
	  uom.uom_nm uom_DESC,
      mec_typ.obj_key_Desc MEC_TYP_DESC,
	mec.cde_ver_nr ,
	cde.Item_nm CDE_NM,
	cde.cntxt_nm_dn CDE_CNTXT_NM,
	  mec.mec_id,
	  mec.req_ind,
	  mec.pk_ind,
	  mec.fk_ind,
	  mec.mdl_pk_ind,
	  mec.FK_ELMNT_PHY_NM,
	  mec.FK_ELMNT_CHAR_PHY_NM,
      vdst.VAL_DOM_TYP_ID
from admin_item ai, nci_mdl mdl, nci_mdl_elmnt me, nci_mdl_elmnt_char mec,admin_item dec, admin_item cde, obj_key me_grp, obj_key mdl_typ, obj_key mdl_lang, obj_key me_typ, 
obj_key mec_typ, data_typ dt, uom uom,
	  admin_item vd, value_dom vdst, VW_VAL_DOM_REF_TERM vdrt
where ai.item_id = mdl.item_id and ai.ver_nr = mdl.ver_nr and ai.admin_item_typ_id = 57 and mdl.item_id = me.mdl_item_id
and mdl.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr
	and mec.cde_item_id = cde.item_id (+)
	and mec.cde_ver_nr = cde.ver_nr (+)
	and mec.val_dom_item_id = vd.item_id (+)
	and mec.val_dom_ver_nr = vd.ver_nr (+)	  
	and mec.val_dom_item_id = vdst.item_id (+)
	and mec.val_dom_ver_nr = vdst.ver_nr (+)	  
	and mec.val_dom_item_id = vdrt.item_id (+)
	and mec.val_dom_ver_nr = vdrt.ver_nr (+)	  
	and cde.admin_item_typ_id (+)= 4
	and mec.de_conc_item_id = dec.item_id (+)
	and mec.de_conc_ver_nr = dec.ver_nr (+)
	and dec.admin_item_typ_id (+)= 2
	and mdl.mdl_typ_id =mdl_typ.obj_key_id (+)
	and mdl.prmry_mdl_lang_id =mdl_lang.obj_key_id (+)
	and me.me_typ_id = me_typ.obj_key_id (+)
	and mec.MDL_ELMNT_CHAR_TYP_ID = mec_typ.obj_key_id (+)
	and me.me_grp_id = me_grp.obj_key_id (+)
	and vdst.NCI_STD_DTTYPE_ID = dt.dttype_id (+)
	  and vdst.uom_id = uom.uom_id (+);

--jira 4091 and 4092
INSERT ALL
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',133,'Data Element Concept Public ID', '/dataElementConcepts/publicId','DATA_ELEMENT_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',134,'Data Element Concept Short Name','/dataElementConcepts/shortName','DATA_ELEMENT_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',135,'Data Element Concept Long Name','/dataElementConcepts/longName','DATA_ELEMENT_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',136,'Data Element Concept Version','/dataElementConcepts/version','DATA_ELEMENT_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',137,'Data Element Concept Context Name','/dataElementConcepts/contextName','DATA_ELEMENT_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',138,'Data Element Concept Context Version','/dataElementConcepts/contextVersion','DATA_ELEMENT_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',139,'Object Class Public ID','/dataElementConcepts/objectClass/publicId','OBJECT_CLASS')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',140,'Object Class Long Name','/dataElementConcepts/objectClass/longName','OBJECT_CLASS')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',141,'Object Class Short Name','/dataElementConcepts/objectClass/shortName','OBJECT_CLASS')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',142,'Object Class Context Name','/dataElementConcepts/objectClass/contextName','OBJECT_CLASS')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',143,'Object Class Version','/dataElementConcepts/objectClass/version','OBJECT_CLASS')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',144,'Object Class Concept Name','/dataElementConcepts/objectClass/concepts/longName','OBJECT_CLASS_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',145,'Object Class Concept Code','/dataElementConcepts/objectClass/concepts/value','OBJECT_CLASS_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',146,'Object Class Concept Public ID','/dataElementConcepts/objectClass/concepts/publicId','OBJECT_CLASS_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',147,'Object Class Concept Definition Source','/dataElementConcepts/objectClass/concepts/definitionSource','OBJECT_CLASS_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',148,'Object Class Concept EVS Source','/dataElementConcepts/objectClass/concepts/evsSource','OBJECT_CLASS_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',149,'Object Class Concept Primary Flag','/dataElementConcepts/objectClass/concepts/primaryFlag','OBJECT_CLASS_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',150,'Property Public ID','/dataElementConcepts/property/publicId','PROPERTY')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',151,'Property Long Name','/dataElementConcepts/property/longName','PROPERTY')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',152,'Property Short Name','/dataElementConcepts/property/shortName','PROPERTY')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',153,'Property Context Name','/dataElementConcepts/property/contextName','PROPERTY')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',154,'Property Version','/dataElementConcepts/property/version','PROPERTY')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',155,'Property Concept Name','/dataElementConcepts/property/concepts/longName','PROPERTY_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',156,'Property Concept Code','/dataElementConcepts/property/concepts/value','PROPERTY_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',157,'Property Concept Public ID','/dataElementConcepts/property/concepts/publicId','PROPERTY_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',158,'Property Concept Definition Source','/dataElementConcepts/property/concepts/definitionSource','PROPERTY_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',159,'Property Concept EVS Source','/dataElementConcepts/property/concepts/evsSource','PROPERTY_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',160,'Property Concept Primary Flag','/dataElementConcepts/property/concepts/primaryFlag','PROPERTY_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',161,'Classification Scheme Short Name','/dataElementConcepts/classificationScheme/shortName','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',162,'Classification Scheme Public ID','/dataElementConcepts/classificationScheme/publicId','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',163,'Classification Scheme Version','/dataElementConcepts/classificationScheme/version','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',164,'Classification Scheme Context Name','/dataElementConcepts/classificationScheme/contextName','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',165,'Classification Scheme Context Version','/dataElementConcepts/classificationScheme/contextVersion','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',166,'Classification Scheme Item Name','/dataElementConcepts/classificationScheme/classificationSchemeItems/longName','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',167,'Classification Scheme Item Type Name','/dataElementConcepts/classificationScheme/classificationSchemeItems/typeName','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',168,'Classification Scheme Item Public Id','/dataElementConcepts/classificationScheme/classificationSchemeItems/publicId','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',169,'Classification Scheme Item Version','/dataElementConcepts/classificationScheme/classificationSchemeItems/version','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',170,'Data Element Concept Alternate Name Context Name','/dataElementConcepts/alternateNames/contextName','ALTERNATE_NAME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',171,'Data Element Concept Alternate Name Context Version','/dataElementConcepts/alternateNames/contextVersion','ALTERNATE_NAME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',172,'Data Element Concept Alternate Name','/dataElementConcepts/alternateNames/name','ALTERNATE_NAME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',173,'Data Element Concept Alternate Name Type','/dataElementConcepts/alternateNames/nameType','ALTERNATE_NAME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',174,'Data Element Concept RAI','/dataElementConcepts/RAI','')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',175,'Object Class RAI','/dataElementConcepts/objectClass/RAI','')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',176,'Property RAI','/dataElementConcepts/property/RAI','')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',177,'Object Class Concept Origin','/dataElementConcepts/objectClass/concepts/origin','OBJECT_CLASS_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',178,'Property Concept Origin','/dataElementConcepts/property/concepts/origin','PROPERTY_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',179,'Conceptual Domain Public ID','/dataElementConcepts/conceptualDomain/publicId','DATA_ELEMENT_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',180,'Conceptual Domain Short Name','/dataElementConcepts/conceptualDomain/shortName','DATA_ELEMENT_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',181,'Conceptual Domain Version','/dataElementConcepts/conceptualDomain/version','DATA_ELEMENT_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_id, col_nm, xpath, data_object) VALUES (1, 'ROW', 'DEC',182,'Conceptual Domain Context Name','/dataElementConcepts/conceptualDomain/contextName','DATA_ELEMENT_CONCEPT')
SELECT * FROM DUAL;
commit;


CREATE TABLE NCI_DLOAD_CSTM_DEC_SUBTYP
   (	"HDR_ID" NUMBER NOT NULL ENABLE, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	 PRIMARY KEY ("HDR_ID"));
     
       CREATE TABLE NCI_DLOAD_CSTM_VD_SUBTYP
   (	"HDR_ID" NUMBER NOT NULL ENABLE, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	 PRIMARY KEY ("HDR_ID"));
     
       CREATE TABLE NCI_DLOAD_CSTM_COL_DTL_DEC
   (	"HDR_ID" NUMBER NOT NULL ENABLE, 
	"FMT_NM" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP", 
	"COL_ID" NUMBER NOT NULL ENABLE, 
	"DT_LAST_MODIFIED" DATE, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP", 
	"RETAIN_IND" NUMBER(1,0) DEFAULT 0, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"COL_POS" NUMBER DEFAULT 1, 
	 PRIMARY KEY ("HDR_ID", "COL_ID"));
     
       CREATE TABLE NCI_DLOAD_CSTM_COL_DTL_VD
   (	"HDR_ID" NUMBER NOT NULL ENABLE, 
	"FMT_NM" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP", 
	"COL_ID" NUMBER NOT NULL ENABLE, 
	"DT_LAST_MODIFIED" DATE, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP", 
	"RETAIN_IND" NUMBER(1,0) DEFAULT 0, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"COL_POS" NUMBER DEFAULT 1, 
	 PRIMARY KEY ("HDR_ID", "COL_ID"));
     
    grant read on nci_dload_cstm_dec_subtyp to onedata_ro;
     grant read on nci_dload_cstm_vd_subtyp to onedata_ro;
     grant read on nci_dload_cstm_col_dtl_dec to onedata_ro;
     grant read on nci_dload_cstm_col_dtl_vd to onedata_ro;
     
     grant all on nci_dload_cstm_dec_subtyp to onedata_wa;
     grant all on nci_dload_cstm_vd_subtyp to onedata_wa;
     grant all on nci_dload_cstm_col_dtl_dec to onedata_wa;
     grant all on nci_dload_cstm_col_dtl_vd to onedata_wa;

update nci_dload_cstm_col_key set xpath = replace(xpath, '/dataElementConcepts', '') where data_object = 'CLASSIFICATION_SCHEME' and DLOAD_TYP = 'DEC';
commit;

INSERT ALL
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Public ID',183,'/valueDomain/publicId','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Short Name',184,'/valueDomain/shortName','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Long Name',185,'/valueDomain/longName','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Version',186,'/valueDomain/version','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Context Name',187,'/valueDomain/contextName','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Context Version',188,'/valueDomain/contextVersion','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Type',189,'/valueDomain/Type','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Datatype',190,'/valueDomain/dataType','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Min Length',191,'/valueDomain/minlength','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Max Length',192,'/valueDomain/maxlength','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Min Value',193,'/valueDomain/minValue','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Max Value',194,'/valueDomain/maxValue','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Decimal Place',195,'/valueDomain/decimalPlace','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Format',196,'/valueDomain/format','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Concept Name',197,'/valueDomain/concepts/longName','VALUE_DOMAIN_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Concept Code',198,'/valueDomain/concepts/shortName','VALUE_DOMAIN_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Concept Public ID',199,'/valueDomain/concepts/publicId','VALUE_DOMAIN_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Concept Definition Source',200,'/valueDomain/concepts/definitionSource','VALUE_DOMAIN_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Concept EVS Source',201,'/valueDomain/concepts/evsSource','VALUE_DOMAIN_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Concept Primary Flag',202,'/valueDomain/concepts/primaryFlag','VALUE_DOMAIN_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Public ID',203,'/valueDomain/representation/publicId','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Long Name',204,'/valueDomain/representation/longName','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Short Name',205,'/valueDomain/representation/shortName','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Context Name',206,'/valueDomain/representation/contextName','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Version',207,'/valueDomain/representation/version','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Concept Name',208,'/valueDomain/representation/concepts/longName','REPRESENTATION_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Concept Code',209,'/valueDomain/representation/concepts/shortName','REPRESENTATION_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Concept Public ID',210,'/valueDomain/representation/concepts/publicId','REPRESENTATION_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Concept Definition Source',211,'/valueDomain/representation/concepts/definitionSource','REPRESENTATION_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Concept EVS Source',212,'/valueDomain/representation/concepts/evsSource','REPRESENTATION_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Concept Primary Flag',213,'/valueDomain/representation/concepts/primaryFlag','REPRESENTATION_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Valid Values',214,'/valueDomain/permissibleValues/value','PV')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Meaning Name',215,'/valueDomain/permissibleValues/valueMeanings/longName','PV')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Meaning Description',216,'/valueDomain/permissibleValues/valueMeanings/definition','PV')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Meaning Concepts',217,'/valueDomain/permissibleValues/valueMeanings/concepts','PV')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','PV Begin Date',218,'/valueDomain/permissibleValues/beginDate','PV')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','PV End Date',219,'/valueDomain/permissibleValues/endDate','PV')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Meaning Public ID',220,'/valueDomain/permissibleValues/valueMeanings/publicId','PV')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Meaning Version',221,'/valueDomain/permissibleValues/valueMeanings/version','PV')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Meaning Alternate Definitions',222,'/valueDomain/permissibleValues/valueMeanings/designations','PV')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Classification Scheme Short Name',223,'/classificationSchemes/shortName','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Classification Scheme Version',224,'/classificationSchemes/version','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Classification Scheme Context Name',225,'/classificationSchemes/contextName','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Classification Scheme Context Version',226,'/classificationSchemes/contextVersion','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Classification Scheme Item Name',227,'/classificationSchemes/classificationSchemeItems/longName','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Classification Scheme Item Type Name',228,'/classificationSchemes/classificationSchemeItems/typeName','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Classification Scheme Item Public Id',229,'/classificationSchemes/classificationSchemeItems/publicId','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Classification Scheme Item Version',230,'/classificationSchemes/classificationSchemeItems/version','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Alternate Name Context Name',231,'/valueDomain/alternateNames/contextName','ALTERNATE_NAME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Alternate Name Context Version',232,'/valueDomain/alternateNames/contextVersion','ALTERNATE_NAME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Alternate Name',233,'/valueDomain/alternateNames/name','ALTERNATE_NAME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Alternate Name Type',234,'/valueDomain/alternateNames/nameType','ALTERNATE_NAME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain RAI',235,'/valueDomain/RAI','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation RAI',236,'/valueDomain/representation/RAI', 'VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Workflow Status',237,'/valueDomain/workflowStatus','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Registration Status',238,'/valueDomain/registrationStatus','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Value Domain Concept Origin',239,'/valueDomain/concepts/origin','VALUE_DOMAIN_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Representation Concept Origin',240,'/valueDomain/representation/concepts/origin','REPRESENTATION_CONCEPT')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Classification Scheme Public ID',241,'/classificationScheme/publicId','CLASSIFICATION_SCHEME')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Conceptual Domain Public ID',242,'/valueDomain/conceptualDomain/publicId','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Conceptual Domain Short Name',243,'/valueDomain/conceptualDomain/shortName','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Conceptual Domain Version',244,'/valueDomain/conceptualDomain/version','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Conceptual Domain Context Name',245,'/valueDomain/conceptualDomain/contextName','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Reference Terminology',246,'/valueDomain/referenceTerminology','VALUE_DOMAIN')
INTO nci_dload_cstm_col_key(is_visible, output, dload_typ, col_nm, col_id, xpath, data_object) VALUES (1, 'ROW', 'VD','Reference Terminology Data Value Source',247,'/valueDomain/referenceTerminologyDataValue','VALUE_DOMAIN')
SELECT * FROM DUAL;
commit;

update nci_dload_cstm_col_key set xpath = replace(xpath, 'valueDomain', 'valueDomains') where DLOAD_TYP = 'VD';
commit;

update nci_dload_cstm_col_key set is_visible = 0 where dload_typ = 'DEC' and data_object = 'CLASSIFICATION_SCHEME';
update nci_dload_cstm_col_key set is_visible = 0 where col_nm like '%RAI%' and dload_typ = 'DEC';
commit;

---jira 4114
ALTER TABLE nci_ds_dtl ADD PVVM_ID number;
