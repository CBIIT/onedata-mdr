

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

drop table SAG_LOAD_MT;

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


Subset Code	Subset Name	Concept Code	NCIt Preferred Term	Relationship To Target	Target Code	Target Term	Target Term Type
	Target Terminology	Target Terminology Version

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


Source_Atom_Code varchar2(4000) not null,	
 Source_Atom_Name	varchar2(4000) null,
 Source	varchar2(255) not null,
 Version varchar2(20) not null,
creat_dt date default sysdate);


,
  primary key (NCI_Meta_CUI ,Source_Atom_Code ,Source	,Version ));



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
	  deg.obj_key_Desc "MAPPING_DEGREE",
	  crd.obj_key_desc "MAPPING_CARDINALITY",
	  direct.obj_key_Desc "MAPPING_DIRECTION",
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
	  --map.mec_map_nm "Mapping Name", 
	  --map.mec_map_desc "Mapping Definition", 
	   map."CREAT_DT",
	  map."CREAT_USR_ID",
	  map."LST_UPD_USR_ID",
	  map."FLD_DELETE",
	  map."LST_DEL_DT",
	  map."S2P_TRN_DT",
	  map."LST_UPD_DT"
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  obj_key crd,
	  obj_key direct,
	  obj_key deg,
	  nci_org org
	where  sme.item_id (+)= smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr (+)= smec.MDL_ELMNT_VER_NR and
	 tme.item_id (+)= tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr (+)= tmec.MDL_ELMNT_VER_NR  and
	   smec.MEC_ID (+)= map.SRC_MEC_ID and tmec.mec_id (+)= map.TGT_MEC_ID
	  and map.map_deg = deg.obj_key_id (+)
	  and map.direct_typ = direct.obj_key_id (+)
	  and map.prov_org_id = org.entty_id (+)
	  and map.crdnlity_id = crd.obj_key_id (+);


