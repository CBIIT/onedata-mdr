alter table NCI_STG_MEC_MAP add (DT_LAST_MODIFIED varchar2(32));

alter table NCI_MDL_ELMNT_CHAR add (CHAR_ORD integer);

alter table NCI_STG_MDL_ELMNT_CHAR add (CHAR_ORD integer);
alter table NCI_STG_MDL_ELMNT_CHAR add (PK_IND varchar(10));

create or replace view vw_cncpt_with_NA
as select ITEM_ID,VER_NR,ITEM_NM,ITEM_LONG_NM,ITEM_DESC,CURRNT_VER_IND,REGSTR_STUS_NM_DN,ADMIN_STUS_NM_DN,
CNTXT_NM_DN,CREAT_DT,CREAT_USR_ID,LST_UPD_USR_ID,FLD_DELETE,LST_DEL_DT,S2P_TRN_DT,LST_UPD_DT from admin_item where admin_item_typ_id = 49
union
select 0,1, 'No Concept Attached','NA', 'No Concept Attached',1,'Application','DRAFT-NEW','NA', sysdate, 'ONEDATA', 'ONEDATA', 0, sysdate, sysdate, sysdate
from dual
	
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
	  smec."MEC_PHY_NM" "SRC_PHY_NAME", 
	  tme.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME", 
	  tmec."MEC_PHY_NM" "TGT_PHY_NAME", 
          tmec.char_ord SRC_CHAR_ORD,
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
map.TGT_FUNC_PARAM "TARGET_FUNCTION_PARAM"	,
	op.obj_key_desc "OPERATOR",
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
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated')  "SOURCE_DOMAIN_TYPE",
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated')  "TARGET_DOMAIN_TYPE",
	   map."CREAT_DT",
	  map."CREAT_USR_ID",
	  map."LST_UPD_USR_ID",
	  map."FLD_DELETE",
	  map."LST_DEL_DT",
	  map."S2P_TRN_DT",
	  map."LST_UPD_DT",
      smec.MEC_ID SRC_MEC_ID,
tmec.MEC_ID TGT_MEC_ID,
tmec.pk_ind TGT_PK_IND,
smec.pk_ind SRC_PK_IND
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  obj_key crd,
	  obj_key deg,
	  obj_key src_func,
	  obj_key tgt_func,
	  obj_key op,
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
	  and map.op_id = op.obj_key_id (+)
          and smec.val_dom_item_id = svd.item_id (+)
	  and smec.val_dom_ver_nr = svd.ver_nr (+)
	  and tmec.val_dom_item_id = tvd.item_id (+)
 	  and tmec.val_dom_ver_nr = tvd.ver_nr (+);

alter table SAG_LOAD_MT add (PREF_IND number(1) default 0);

alter table SAG_LOAD_MT add (TERM_TYP varchar2(100));



drop table NCI_ADMIN_ITEM_XMAP;
  CREATE TABLE NCI_ADMIN_ITEM_XMAP
   (	"ITEM_ID" NUMBER NOT NULL ENABLE, 
	"VER_NR" NUMBER(4,2) NOT NULL ENABLE, 
	"XMAP_CD" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"XMAP_DESC" VARCHAR2(1000 BYTE) COLLATE "USING_NLS_COMP" NOT NULL, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"REL_TYP_ID" NUMBER(*,0), 
	"EVS_SRC_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"EVS_SRC_VER_NR" VARCHAR2(10 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"DT_SRC" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PREF_IND" NUMBER(1,0) DEFAULT 0, 
	  TERM_TYP varchar2(100) default '--',
	 PRIMARY KEY ("ITEM_ID", "VER_NR", "XMAP_CD", XMAP_DESC,"EVS_SRC_ID", "EVS_SRC_VER_NR",TERM_TYP))
   ;




  CREATE OR REPLACE VIEW VW_CNCPT_XMAP AS
  SELECT XMAP.ITEM_ID, XMAP.VER_NR, 
  max(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_Cd,'')) ICD_O_CODE,
  max(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_desc,'')) ICD_O_DESC,
  max(decode(o.obj_key_desc, 'SNOMED_CODE', XMAP_Cd,'')) SNOMED_CODE,
  max(decode(o.obj_key_desc, 'SNOMED_CODE', XMAP_DESC,'')) SNOMED_DESC,
  max(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_Cd,'')) MEDDRA_CODE,
  max(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_DESC,'')) MEDDRA_DESC,
  max(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_Cd,'')) LOINC_CODE,
  max(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_DESC,'')) LOINC_DESC,
  max(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_Cd,'')) HUGO_CODE,
  max(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_desc,'')) HUGO_CODE_DESC,
  max(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_Cd,'')) ICD_10_CM_CODE,
  max(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_DESC,'')) ICD_10_CM_DESC,
  sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT 
       FROM NCI_ADMIN_ITEM_XMAP xmap, obj_key o
       WHERE o.obj_typ_id = 23 and o.obj_key_id = xmap.evs_src_id and pref_ind = 1
       group by xmap.item_id, xmap.ver_nr;


update obj_key set OBJ_KEY_CMNTS = 'SNOMEDCT_US' where obj_key_Desc = 'SNOMED-CT_CODE' and obj_typ_id = 23;
update obj_key set OBJ_KEY_CMNTS = 'MDR' where obj_key_Desc = 'MEDDRA_CODE' and obj_typ_id = 23;
update obj_key set OBJ_KEY_CMNTS = 'ICD10CM' where obj_key_Desc = 'ICD-10-CM_CODE' and obj_typ_id = 23;
update obj_key set OBJ_KEY_CMNTS = 'ICD10' where obj_key_Desc = 'ICD-10_CODE' and obj_typ_id = 23;
update obj_key set OBJ_KEY_CMNTS = 'ICD)' where obj_key_Desc = 'ICD-O_CODE' and obj_typ_id = 23;
update obj_key set OBJ_KEY_CMNTS = 'LNC' where obj_key_Desc = 'LOINC_CODE' and obj_typ_id = 23;
update obj_key set OBJ_KEY_CMNTS = 'RADLEX' where obj_key_Desc = 'RADLEX_CODE' and obj_typ_id = 23;
update obj_key set OBJ_KEY_CMNTS = 'GO' where obj_key_Desc = 'GO_CODE' and obj_typ_id = 23;
update obj_key set OBJ_KEY_CMNTS = 'ICD9CM' where obj_key_Desc = 'ICD-9_CM_CODE' and obj_typ_id = 23;
update obj_key set OBJ_KEY_CMNTS = 'HGNC' where obj_key_Desc = 'HUGO_CODE' and obj_typ_id = 23;
commit;





  CREATE OR REPLACE  VIEW VW_NCI_MDL_MAP_FOR_VIEW
  select distinct s.item_id MDL_ITEM_ID, s.ver_nr MDL_VER_NR, map.item_id MDL_MAP_ITEM_ID, map.ver_nr MDL_MAP_VER_NR,
'Source' LVL_TYP, s.item_id src_mdl_item_id, s.ver_nr src_mdl_ver_nr, s.item_nm 
src_mdl_item_nm,  sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' 
LST_UPD_USR_ID,map.FLD_DELETE,sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT,
	 t.item_id tgt_mdl_item_id, t.ver_nr tgt_mdl_ver_nr, t.item_nm tgt_mdl_item_nm
		from admin_item s, NCI_MDL_MAP map , admin_item t
	where s.item_id = map.src_mdl_item_id and s.ver_nr = map.src_mdl_ver_nr 
       and t.item_id = map.tgt_MDL_ITEM_ID
	and t.ver_nr = map.tgt_MDL_VER_NR and s.admin_item_typ_id = 57 and
t.admin_item_typ_id = 57 
union
  select distinct t.item_id MDL_ITEM_ID, t.ver_nr MDL_VER_NR, map.item_id MDL_MAP_ITEM_ID, map.ver_nr MDL_MAP_VER_NR,
'Target' LVL_TYP, s.item_id src_mdl_item_id, s.ver_nr src_mdl_ver_nr, s.item_nm 
src_mdl_item_nm,  sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' 
LST_UPD_USR_ID,map.FLD_DELETE,sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT,
	 t.item_id tgt_mdl_item_id, t.ver_nr tgt_mdl_ver_nr, t.item_nm tgt_mdl_item_nm
		from admin_item s, NCI_MDL_MAP map , admin_item t
	where s.item_id = map.src_mdl_item_id and s.ver_nr = map.src_mdl_ver_nr 
       and t.item_id = map.tgt_MDL_ITEM_ID
	and t.ver_nr = map.tgt_MDL_VER_NR and s.admin_item_typ_id = 57 and
t.admin_item_typ_id = 57;


  CREATE OR REPLACE  VIEW VW_NCI_MEC AS
  select m.item_id mdl_item_id, m.ver_nr mdl_ver_nr, m.item_nm mdl_item_nm, me.item_id ME_ITEM_ID, me.ver_nr me_VER_NR,
	me.ITEM_LONG_NM me_item_nm, me.ITEM_PHY_OBJ_NM me_phy_nm, mec."MEC_ID",mec."MDL_ELMNT_ITEM_ID",mec."MDL_ELMNT_VER_NR",mec."MEC_TYP_ID",mec."CREAT_DT",mec."CREAT_USR_ID",mec."LST_UPD_USR_ID",mec."FLD_DELETE", mec.char_ord, mec.pk_ind,
	  mec."LST_DEL_DT",mec."S2P_TRN_DT",mec."LST_UPD_DT",mec."SRC_DTTYPE",mec."STD_DTTYPE_ID",mec."SRC_MAX_CHAR",mec."SRC_MIN_CHAR",vd."VAL_DOM_TYP_ID",mec."SRC_UOM",mec."UOM_ID",mec."SRC_DEFLT_VAL",mec."SRC_ENUM_SRC",mec."DE_CONC_ITEM_ID",mec."DE_CONC_VER_NR",mec."VAL_DOM_ITEM_ID",mec."VAL_DOM_VER_NR",mec."NUM_PV",mec."MEC_LONG_NM",mec."MEC_PHY_NM",mec."MEC_DESC",mec."CDE_ITEM_ID",mec."CDE_VER_NR"
	from admin_item m, NCI_MDL_ELMNT me,NCI_MDL_ELMNT_CHAR mec, value_dom vd
	where m.item_id = me.mdl_item_id and m.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.MDL_ELMNT_ITEM_ID
	and me.ver_nr = mec.MDL_ELMNT_VER_NR and m.admin_item_typ_id = 57
	  and mec.val_dom_item_id = vd.item_id(+) and mec.val_dom_ver_nr = vd.ver_nr(+);


CREATE OR REPLACE  VIEW VW_FOR_OD_VM_MTCH AS 
  SELECT EVS_SRC_ID EVS_SRC_ID, EVS_SRC_ID MTCH_TYP_ID, EVS_SRC_ID MTCH_AI_TYP_ID,
	CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT
       FROM CNCPT;


insert into obj_typ (obj_typ_id, obj_typ_desc) values
(53, 'Match Type');
commit;

insert into obj_key (obj_typ_Id, obj_key_id, obj_key_desc) values (53, 127,'Restricted');
insert into obj_key (obj_typ_Id, obj_key_id, obj_key_desc) values (53, 128,'Unrestricted');
commit;


  CREATE OR REPLACE  VIEW VW_ADMIN_ITEM_WITH_EXT AS
  select ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.ITEM_LONG_NM, ai.ITEM_NM, ai.CHNG_DESC_TXT, 
 decode(ai.ADMIN_ITEM_TYP_ID , 49, 'Concept', 53, 'Value Meaning') ADMIN_ITEM_TYP_ID ,ai.CURRNT_VER_IND,
 ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, 
 ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, e.cncpt_concat_src_typ evs_src_ori,
decode(e.CNCPT_CONCAT,e.cncpt_concat_nm, null, e.cncpt_concat)  cncpt_concat, e.CNCPT_CONCAT_NM, e.CNCPT_CONCAT_DEF
from admin_item ai, nci_admin_item_Ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr
	  union
	    select 0,1, 'No Concept Associated',  'NA', 'No Concept Associated', '',
'Concept' ,1, 
sysdate, 'ONEDATA', 'ONEDATA', 0,sysdate, sysdate ,sysdate,
 'DRAFT-NEW', 'NA', 'Application', 'NA',
'NA'  , 'NA', 'NA' from dual;

alter table NCI_DS_RSLT add (EVS_SRC_ID integer, XMAP_CD varchar2(1000), XMAP_DESC varchar2(1000));


alter table nci_mdl_elmnt_char add (FK_IND number(1), FK_ELMNT_PHY_NM  varchar2(255), FK_ELMNT_CHAR_PHY_NM  varchar2(255));
alter table nci_STG_mdl_elmnt_char add (FK_IND_TXT varchar(10), FK_ELMNT_PHY_NM  varchar2(255), FK_ELMNT_CHAR_PHY_NM  varchar2(255));

alter table nci_stg_mec_map add (OP_ID integer, IMP_OP_NM varchar2(255));
alter table nci_mec_map add (OP_ID integer, IMP_OP_NM varchar2(255));




insert into obj_typ (obj_typ_id, obj_typ_desc) values
(54, 'Mapping Operator');
commit;
