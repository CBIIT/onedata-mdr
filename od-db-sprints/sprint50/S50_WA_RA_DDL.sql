

alter table NCI_MEC_VAL_MAP add PROV_NOTES  varchar2(4000);


  CREATE TABLE NCI_STG_MEC_MAP
   (	STG_MECM_ID number,
	"BTCH_USR_NM" VARCHAR2(100 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"BTCH_NM" VARCHAR2(100 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CTL_VAL_STUS" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP", 
	"CTL_VAL_MSG" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
       "MDL_MAP_ITEM_ID" NUMBER NOT NULL ENABLE, 
	"MDL_MAP_VER_NR" NUMBER(4,2) NOT NULL ENABLE, 
        SRC_ME_PHY_NM varchar2(255) null,
        SRC_MEC_PHY_NM varchar2(255) null,
        TGT_ME_PHY_NM varchar2(255) null,
        TGT_MEC_PHY_NM varchar2(255) null,
	"TRNS_DESC_TXT" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"MEC_MAP_NM" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"MAP_DEG" NUMBER(*,0), 
         IMP_MAP_DEG varchar2(255),
	"MEC_MAP_DESC" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"DIRECT_TYP" NUMBER(*,0), 
        IMP_DIRECT_TYP varchar2(255),
	"TRANS_RUL_NOT" NUMBER(*,0), 
	IMP_TRANS_RUL_NOT varchar2(255), 
	"VALID_PLTFORM" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"PROV_ORG_ID" NUMBER, 
         IMP_PROV_ORG varchar2(255),
	"MEC_GRP_RUL_NBR" NUMBER(*,0), 
	"MEC_GRP_RUL_DESC" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"SRC_VAL" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"TGT_VAL" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"CRDNLITY_ID" NUMBER(*,0), 
         IMP_CRDNLITY varchar2(255),
	"MEC_MAP_NOTES" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"MEC_SUB_GRP_NBR" NUMBER(*,0), 
	"PROV_CNTCT_ID" NUMBER(*,0),
         IMP_PROV_CNTCT varchar2(255), 
	"PROV_RSN_TXT" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"PROV_TYP_RVW_TXT" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"PROV_RVW_DT" DATE, 
	"PROV_APRV_DT" DATE, 
	 PRIMARY KEY (STG_MECM_ID));


ONEDATA_WA only

  CREATE OR REPLACE TRIGGER TR_NCI_STG_MEC_MAP 
  BEFORE  UPDATE
  on NCI_STG_MEC_MAP
  for each row
BEGIN
   :new.LST_UPD_DT := SYSDATE;

END;

/

CREATE OR REPLACE TRIGGER TR_NCI_STG_MEC_MAP_SEQ  BEFORE INSERT  on NCI_STG_MEC_MAP
  for each row
         BEGIN    IF (:NEW.STG_MECM_ID<= 0  or :NEW.STG_MECM_ID is null)  THEN
         select NCI_SEQ_MECM.nextval
    into :new.STG_MECM_ID  from  dual ;
END IF;

END ;
/


create table SAG_LOAD_MT
(NCI_Meta_CUI varchar2(100) not null,	
 NCI_Meta_Concept_Name	varchar2(4000) null,
 NCI_Code	varchar2(100) null,
 NCI_PT	varchar2(4000) null,
 Source_Atom_Code varchar2(4000) not null,	
 Source_Atom_Name	varchar2(4000) null,
 Source	varchar2(255) not null,
 Version varchar2(20) not null,
creat_dt date default sysdate);



create table SAG_LOAD_ICDO
(
 Subset_Code	varchar2(100) null,
 Subset_Name	varchar2(4000) null,
 Concept_Code	varchar2(100) null,
 NCIT_PT	varchar2(4000) null,
 Rel_to_Target  varchar2(100) null,
 Target_Code	varchar2(100) null,
 Target_Term	varchar2(4000) null,
 Target_Term_type	varchar2(100) null,
 Target_Terminology  	varchar2(100) null,
 Target_Terminology_Version  	varchar2(100) null);



  CREATE OR REPLACE VIEW VW_MDL_MAP_IMP_TEMPLATE AS
  select  ' ' "DO_NOT_USE",
       ' ' "BATCH_USER",
       ' ' "BATCH_NAME",
       map.mdl_map_item_id "MODEL_MAP_ID",
       map.mdl_map_ver_nr "MODEL_MAP_VERSION",
        map.mecm_id "MECM_ID", 
    	  sme.ITEM_PHY_OBJ_NM "SRC_ELMNT_PHY_NAME", 
	  smec."MEC_PHY_NM" "SRC_PHY_NAME", 
	  tme.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME", 
	  tmec."MEC_PHY_NM" "TGT_PHY_NAME", 
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
  map.valid_pltform	   "VALIDATION_PLATFORM",
	map.mec_map_notes "TRANSFORMATION_NOTES",
	map.TRNS_DESC_TXT "TRANSFORMATION_RULE",
	org.org_nm "PROV_ORG",
' '	"PROV_CONTACT",
	map.prov_rsn_txt "PROV_REVIEW_REASON",
	map.prov_typ_rvw_txt "PROV_TYPE_OF_REVIEW",
	map.PROV_RVW_DT "PROV_REVIEW_DATE",
	map.prov_APRV_DT "PROV_APPROVAL_DATE",
map.VAL_MAP_CREATE_IND "VALUE_MAP_GENERATED_IND",
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated')  "SOURCE_DOMAIN_TYPE",
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated')  "TARGET_DOMAIN_TYPE",
	   map."CREAT_DT",
	  map."CREAT_USR_ID",
	  map."LST_UPD_USR_ID",
	  map."FLD_DELETE",
	  map."LST_DEL_DT",
	  map."S2P_TRN_DT",
	  map."LST_UPD_DT"
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  obj_key crd,
	  obj_key deg,
	  obj_key src_func,
	  obj_key tgt_func,
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
          and smec.val_dom_item_id = svd.item_id (+)
	  and smec.val_dom_ver_nr = svd.ver_nr (+)
	  and tmec.val_dom_item_id = tvd.item_id (+)
 	  and tmec.val_dom_ver_nr = tvd.ver_nr (+);



	insert into obj_typ (obj_typ_id, obj_typ_desc) values (50,'Comparison Mapping Functions');
	     commit;

	insert into obj_typ (obj_typ_id, obj_typ_desc) values (51,'Assignment Mapping Functions');
	     commit;


delete from obj_key where obj_typ_id = 49 and obj_key_desc in ('Provider','Visit', 'Specimen');
commit;


alter table NCI_MEC_MAP add (SRC_FUNC_ID  integer, TGT_FUNC_ID integer);

alter table NCI_STG_MEC_MAP add (SRC_FUNC_ID  integer, IMP_SRC_FUNC varchar2(255), TGT_FUNC_ID integer, IMP_TGT_FUNC varchar2(255));


alter table NCI_STG_MEC_MAP add (SRC_VD_TYP varchar2(100), TGT_VD_TYP varchar2(100), VAL_MAP_CREATE_IND number(1));


