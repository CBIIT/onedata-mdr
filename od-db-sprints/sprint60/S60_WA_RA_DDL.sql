  CREATE OR REPLACE  VIEW VW_VAL_MAP_IMP_TEMPLATE AS
  select  ' ' "DO_NOT_USE",
       ' ' "BATCH_USER",
       ' ' "BATCH_NAME",
       rownum "SEQ_ID",
       map.mdl_map_item_id "MODEL_MAP_ID",
       map.mdl_map_ver_nr "MODEL_MAP_VERSION",
        vmap.mecvm_id "MECvM_ID", 
        map.mecm_id,
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
' '	"PROV_CONTACT",
	vmap.prov_rsn_txt "PROV_REVIEW_REASON",
	vmap.prov_typ_rvw_txt "PROV_TYPE_OF_REVIEW",
	vmap.PROV_RVW_DT "PROV_REVIEW_DATE",
	vmap.prov_APRV_DT "PROV_APPROVAL_DATE",
decode(nvl(map.VAL_MAP_CREATE_IND,0),1, 'Yes','No') "VALUE_MAP_GENERATED_IND",
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "SOURCE_DOMAIN_TYPE",
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "TARGET_DOMAIN_TYPE",
    vmap.SRC_PV,
    vmap.TGT_PV,
    vmap.SRC_LBL,
    vmap.TGT_LBL, 
    vmap.VM_CNCPT_CD,
    vmap.VM_CNCPT_NM,
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
svdrt.TERM_USE_NAME "SOURCE_REF_TERM_SOURCE",
tvdrt.TERM_USE_NAME "TARGET_REF_TERM_SOURCE",
    ' ' "CMNTS_DESC_TXT"
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map, 	NCI_MEC_VAL_MAP vmap,
	  obj_key deg,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd,
vw_val_dom_ref_term svdrt,
vw_val_dom_ref_term tvdrt
	where  sme.item_id (+)= smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr (+)= smec.MDL_ELMNT_VER_NR and
	 tme.item_id (+)= tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr (+)= tmec.MDL_ELMNT_VER_NR  and
	   smec.MEC_ID (+)= map.SRC_MEC_ID and tmec.mec_id (+)= map.TGT_MEC_ID
	  and map.map_deg = deg.obj_key_id (+)
	  and map.prov_org_id = org.entty_id (+)
	        and smec.val_dom_item_id = svd.item_id (+)
	  and smec.val_dom_ver_nr = svd.ver_nr (+)
	  and tmec.val_dom_item_id = tvd.item_id (+)
 	  and tmec.val_dom_ver_nr = tvd.ver_nr (+)
          and svd.item_id = svdrt.item_id (+)
          and svd.ver_nr = svdrt.ver_nr (+)
          and tvd.item_id = tvdrt.item_id (+)
          and tvd.ver_nr = tvdrt.ver_nr (+)
    and map.MDL_MAP_ITEM_ID = vmap.MDL_MAP_ITEM_ID
    and map.MDL_MAP_VER_NR = vmap.MDL_MAP_VER_NR
    and map.SRC_MEC_ID = vmap.SRC_MEC_ID
    and map.tgt_mec_id = vmap.tgt_mec_id;


create table NCI_MDL_MAP_CNFG (
CNFG_ID  number,
MDL_MAP_ITEM_ID  number,
MDL_MAP_VER_NR number(4,2),
TRANS_RUL_NOT integer,
TRANS_RUL_NOT_DTL integer,
SRC_LOC  varchar2(4000),
TGT_LOC  varchar2(4000),
SRC_VMAP_LOC  varchar2(4000),
SRC_XMAP_LOC  varchar2(4000),
VMAP_NM  varchar2(1000),
VMAP_MDL_ID_COL_NM  varchar2(1000),
VMAP_MDL_VER_COL_NM  varchar2(1000),
VMAP_SRC_ELMNT_COL_NM  varchar2(1000),
VMAP_TGT_ELMNT_COL_NM  varchar2(1000),
VMAP_SRC_CHAR_COL_NM  varchar2(1000),
VMAP_TGT_CHAR_COL_NM  varchar2(1000),
VMAP_SRC_CODE_COL_NM  varchar2(1000),
VMAP_TGT_CODE_COL_NM  varchar2(1000),
XMAP_NM  varchar2(1000),
XMAP_SRC_TERM_COL_NM  varchar2(1000),
XMAP_TGT_TERM_COL_NM  varchar2(1000),
XMAP_SRC_CODE_COL_NM  varchar2(1000),
XMAP_TGT_CODE_COL_NM  varchar2(1000),
XMAP_SRC_DESC_COL_NM  varchar2(1000),
XMAP_TGT_DESC_COL_NM  varchar2(1000),
 "CNFG_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP",
"CNFG_STATUS" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP" DEFAULT 'CREATED',
"CREAT_DT" DATE DEFAULT sysdate,
"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user,
"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user,
"FLD_DELETE" NUMBER(1,0) DEFAULT 0,
"LST_DEL_DT" DATE DEFAULT sysdate,
"S2P_TRN_DT" DATE DEFAULT sysdate,
"LST_UPD_DT" DATE DEFAULT sysdate,
"CREATED_DT" DATE DEFAULT sysdate,
"CREATED_BY" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP",
"LST_TRIGGER_DT" TIMESTAMP (6) DEFAULT null,
"FILE_NM" VARCHAR2(350 BYTE) COLLATE "USING_NLS_COMP",
"FILE_BLOB" BLOB,
"EMAIL_ADDR" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP",
"CMNT_TXT" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP",
"LST_GEN_DT" TIMESTAMP (6),
primary key (CNFG_ID));



alter table admin_item disable all triggers;

update admin_item set creation_dt = creat_dt where admin_item_typ_id = 53;
commit;

alter table admin_item enable all triggers;




