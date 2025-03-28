alter table NCI_MEC_VAL_MAP add (MECM_ID number);

  CREATE OR REPLACE   VIEW "VW_VAL_MAP_IMP_TEMPLATE"  AS
  select  ' ' "DO_NOT_USE",
       ' ' "BATCH_USER",
       ' ' "BATCH_NAME",
       rownum "SEQ_ID",
       vmap.mdl_map_item_id "MODEL_MAP_ID",
       vmap.mdl_map_ver_nr "MODEL_MAP_VERSION",
	vmap.MECM_ID,
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
' '	"PROV_CONTACT",
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
    vmap.VM_CNCPT_CD,
    vmap.VM_CNCPT_NM,
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
    ' ' "CMNTS_DESC_TXT"
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec,	NCI_MEC_VAL_MAP vmap,
	  obj_key deg,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd,
vw_val_dom_ref_term svdrt,
vw_val_dom_ref_term tvdrt
	where  sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and
	  nvl(vmap.fld_delete,0) = 0 and
	 tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR  
	  and vmap.map_deg = deg.obj_key_id (+)
	  and vmap.prov_org_id = org.entty_id (+)
	        and smec.val_dom_item_id = svd.item_id 
	  and smec.val_dom_ver_nr = svd.ver_nr 
	  and tmec.val_dom_item_id = tvd.item_id 
 	  and tmec.val_dom_ver_nr = tvd.ver_nr 
          and svd.item_id = svdrt.item_id (+)
          and svd.ver_nr = svdrt.ver_nr (+)
          and tvd.item_id = tvdrt.item_id (+)
          and tvd.ver_nr = tvdrt.ver_nr (+)
          and vmap.src_mec_id = smec.mec_id
          and vmap.tgt_mec_id = tmec.mec_id;
	  

	  
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

update admin_item set creation_dt = creat_dt ;
commit;

alter table admin_item enable all triggers;



create table NCI_XWALK_DERV (
	SRC_CD		Varchar2(2000) not null,
	SRC_TERM  varchar2(8000) not null,
	SRC_EVS_SRC_ID integer not null,
	SRC_EVS_SRC_VER_NR varchar2(100) default 1,
	SRC_EVS_SRC_DESC  varchar2(255),
	SRC_TERM_TYP varchar2(8000),
	TGT_CD		Varchar2(2000) not null,
	TGT_TERM  varchar2(8000) not null,
	TGT_EVS_SRC_ID integer not null,
	TGT_EVS_SRC_VER_NR varchar2(100) default 1,
	TGT_EVS_SRC_DESC  varchar2(255),
	TGT_TERM_TYP varchar2(8000),
	CNCPT_CD  varchar2(30),
CNCPT_ITEM_ID number,
CNCPT_VER_NR number(4,2),
	CNCPT_NM varchar2(255),
	NCI_META_CUI  varchar2(100),
"CREAT_DT" DATE DEFAULT sysdate,
"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user,
"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user,
"FLD_DELETE" NUMBER(1,0) DEFAULT 0,
"LST_DEL_DT" DATE DEFAULT sysdate,
"S2P_TRN_DT" DATE DEFAULT sysdate,
"LST_UPD_DT" DATE DEFAULT sysdate,
primary key (SRC_CD, SRC_EVS_SRC_ID, SRC_EVS_SRC_VER_NR, TGT_CD, TGT_EVS_SRC_ID, TGT_EVS_SRC_VER_NR,cncpt_item_id, cncpt_ver_nr));


create table NCI_STG_MEC_VAL_MAP
(  STG_MECVM_ID  number primary key,
	BTCH_USR_NM	VARCHAR2(100 BYTE) not null,
BTCH_NM	VARCHAR2(100 BYTE) not null,
CTL_VAL_STUS	VARCHAR2(50 BYTE),
CTL_VAL_MSG	VARCHAR2(4000 BYTE),
	BTCH_SEQ_NBR	NUMBER,
MECVM_ID                           NUMBER    ,
	MDL_MAP_ITEM_ID	NUMBER not null,
MDL_MAP_VER_NR	NUMBER(4,2) not null,
	SRC_ME_PHY_NM	VARCHAR2(255 BYTE),
SRC_MEC_PHY_NM	VARCHAR2(255 BYTE),
TGT_ME_PHY_NM	VARCHAR2(255 BYTE),
TGT_MEC_PHY_NM	VARCHAR2(255 BYTE) ,
MECM_ID                 NUMBER,         
PROV_ORG_ID                         number   ,
PROV_CNTCT_ID                     number       ,
	IMP_PROV_ORG varchar2(255),
	IMP_PROV_CNTCT  varchar2(255),
PROV_REVIEW_REASON               VARCHAR2(4000) ,
PROV_TYPE_OF_REVIEW              VARCHAR2(4000) ,
PROV_REVIEW_DATE                 DATE           ,
PROV_APPROVAL_DATE               DATE           ,
SOURCE_DOMAIN_TYPE               VARCHAR2(50),   
TARGET_DOMAIN_TYPE               VARCHAR2(50) ,  
SRC_PV                           VARCHAR2(255) , 
TGT_PV                           VARCHAR2(255)  ,
SRC_LBL                          VARCHAR2(4000) ,
TGT_LBL                          VARCHAR2(4000) ,
VM_CNCPT_CD                      VARCHAR2(4000) ,
VM_CNCPT_NM                      VARCHAR2(4000) ,
IMP_MAP_DEG   varchar2(255),
MAP_DEG   int,
PROV_NOTES  varchar2(4000),
CREAT_DT                         DATE           default sysdate,
CREAT_USR_ID                     VARCHAR2(50) default user,   
LST_UPD_USR_ID                   VARCHAR2(50)   default user,
FLD_DELETE                       NUMBER(1)  default 0,    
LST_DEL_DT                       DATE    default sysdate,       
S2P_TRN_DT                       DATE           default sysdate,
LST_UPD_DT                       DATE           default sysdate,
SRC_MEC_ID                       NUMBER         ,
SOURCE_CDE_ITEM_ID               NUMBER         ,
SOURCE_CDE_VER                   NUMBER(4,2)    ,
TARGET_CDE_ITEM_ID               NUMBER         ,
TARGET_CDE_VER                   NUMBER(4,2)    ,
	SOURCE_VD_ITEM_ID               NUMBER         ,
SOURCE_VD_VER                   NUMBER(4,2)    ,
TARGET_VD_ITEM_ID               NUMBER         ,
TARGET_VD_VER                   NUMBER(4,2)    ,
TGT_MEC_ID                       NUMBER         ,
SOURCE_REF_TERM_SOURCE           VARCHAR2(1000) ,
TARGET_REF_TERM_SOURCE           VARCHAR2(1000) ,
CMNTS_DESC_TXT                   varchar2(4000)        ,
DT_SORT	TIMESTAMP(6),
DT_LAST_MODIFIED	VARCHAR2(32 BYTE)
);


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
	  'TEST' NCI_META_CUI
  --  xm.xmap_cd NCI_META_CUI
              FROM ADMIN_ITEM,  CNCPT, nci_admin_item_ext e, OBJ_KEY, (select item_id, ver_nr,  substr( LISTAGG(nm_desc, ' | ') WITHIN GROUP (ORDER by ITEM_ID),1,8000) AS SYN,
			        LISTAGG(MTCH_TERM_ADV , ' | ') WITHIN GROUP (ORDER by ITEM_ID) AS SYN_MTCH_TERM from ALT_NMS a group by item_id, ver_nr) a--,
	                     --   (Select item_id, ver_nr, xmap_cd from nci_admin_item_xmap xmap, obj_Key oo
	--  where xmap.evs_src_id = oo.obj_key_id and obj_typ_id = 23 and obj_key_desc = 'NCI_META_CUI') xm
       WHERE ADMIN_ITEM_TYP_ID = 49 and ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID and ADMIN_ITEM.VER_NR = CNCPT.VER_NR
       and admin_item.item_id = e.item_id and admin_item.ver_nr = e.ver_nr
	and cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID (+) and admin_item.admin_stus_nm_dn = 'RELEASED' 
	and ADMIN_ITEM.ITEM_ID = a.ITEM_ID (+) and ADMIN_ITEM.VER_NR = a.VER_NR (+);
	--  and ADMIN_ITEM.ITEM_ID = xm.ITEM_ID (+) and ADMIN_ITEM.VER_NR = xm.VER_NR (+);


alter table NCI_STG_PV_VM_IMPORT
add (	"CNCPT_2_ITEM_ID_1" NUMBER, 
	
	"CNCPT_2_VER_NR_1" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_2" NUMBER, 
	"CNCPT_2_VER_NR_2" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_3" NUMBER, 
	"CNCPT_2_VER_NR_3" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_4" NUMBER, 
	"CNCPT_2_VER_NR_4" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_5" NUMBER, 
	"CNCPT_2_VER_NR_5" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_6" NUMBER, 
	"CNCPT_2_VER_NR_6" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_7" NUMBER, 
	"CNCPT_2_VER_NR_7" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_8" NUMBER, 
	"CNCPT_2_VER_NR_8" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_9" NUMBER, 
	"CNCPT_2_VER_NR_9" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_10" NUMBER, 
	"CNCPT_2_VER_NR_10" NUMBER(4,2));

insert into obj_key (obj_key_id, obj_key_desc, obj_typ_id, obj_key_def) values (230, 'Export Data Collection Excel File', 31, 'Export Data Collection Excel File');
commit;

CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_MDL_MAP_IMP_TEMPLATE ("DO_NOT_USE", "BATCH_USER", "BATCH_NAME", "SEQ_ID", "MODEL_MAP_ID", "MODEL_MAP_VERSION", "MECM_ID", "SRC_CHAR_ORD", "SRC_ELMNT_PHY_NAME", "SRC_ELMNT_NAME", "SRC_PHY_NAME", "SRC_MEC_NAME", "TGT_ELMNT_PHY_NAME", "TGT_ELMNT_NAME", "TGT_PHY_NAME", "TGT_MEC_NAME", "TGT_CHAR_ORD", "MAPPING_GROUP_NAME", "MAPPING_GROUP_DESC", "SOURCE_FUNCTION", "TARGET_FUNCTION", "MAPPING_DEGREE", "TRANS_RULE_NOTATION", "DERIVATION_GROUP_NBR", "DERIVATION_GROUP_ORDER", "SOURCE_COMPARISON_VALUE", "SET_TARGET_DEFAULT", "TARGET_FUNCTION_PARAM", "OPERATOR", "OPERAND_TYPE", "FLOW_CONTROL", "PARENTHESIS", "RIGHT_OPERAND", "LEFT_OPERAND", "VALIDATION_PLATFORM", "TRANSFORMATION_NOTES", "TRANSFORMATION_RULE", "PROV_ORG", "PROV_CONTACT", "PROV_REVIEW_REASON", "PROV_TYPE_OF_REVIEW", "PROV_REVIEW_DATE", "PROV_APPROVAL_DATE", "VALUE_MAP_GENERATED_IND", "SOURCE_DOMAIN_TYPE", "TARGET_DOMAIN_TYPE", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "SRC_MEC_ID", "SOURCE_CDE_ITEM_ID", "SOURCE_CDE_VER", "TARGET_CDE_ITEM_ID", "TARGET_CDE_VER", "TGT_MEC_ID", "TGT_PK_IND", "SRC_PK_IND", "SOURCE_REF_TERM_SOURCE", "TARGET_REF_TERM_SOURCE", "TGT_ELMNT_PHY_NAME_DERV", "CMNTS_DESC_TXT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
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
svdrt.TERM_USE_NAME "SOURCE_REF_TERM_SOURCE",
tvdrt.TERM_USE_NAME "TARGET_REF_TERM_SOURCE"
	, tmed.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME_DERV",
    ' ' "CMNTS_DESC_TXT"
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


update obj_key set fld_delete = 1 where obj_key_id = 56;
commit;
