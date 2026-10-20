alter table ref disable all triggers;
update ref set mtch_scr = 0 where ref_typ_id in (select obj_key_id from obj_Key where obj_typ_id = 1 and upper(obj_key_Desc) like '%QUESTION%') and mtch_scr is null;
commit;
alter table ref enable all triggers;

CREATE OR REPLACE VIEW VW_REF AS
select REF_ID,
REF_NM,
ITEM_ID,
CREAT_DT,
VER_NR,
CREAT_USR_ID,
LST_UPD_USR_ID,
FLD_DELETE,
LST_DEL_DT,
S2P_TRN_DT,
LST_UPD_DT,
REF_DESC,
REF_TYP_ID,
DISP_ORD,
LANG_ID,
NCI_CNTXT_ITEM_ID,
NCI_CNTXT_VER_NR,
URL,
NCI_IDSEQ,
REF_NM || ' ' || REF_DESC REF_SEARCH_STR,
MTCH_SCR
from REF;



CREATE TABLE NCI_LLM_CNFG 
   (	"LLM_MDL_VER" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"USE_CASE" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"PARAM_VAL" VARCHAR2(32000 BYTE) NOT NULL ENABLE, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
ALTER TABLE NCI_LLM_CNFG ADD PRIMARY KEY ("LLM_MDL_VER", "USE_CASE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE;

create unique index idxVW_CNCPT on vw_CNCPT (ITEM_ID, VER_NR);

CREATE TABLE NCI_DS_RSLT_MTCH_VAL 
   (	"HDR_ID" NUMBER NOT NULL ENABLE, 
	"ITEM_ID" NUMBER NOT NULL ENABLE, 
	"VER_NR" NUMBER(4,2) NOT NULL ENABLE,  
    "SRC_VAL" VARCHAR2(64) NOT NULL ENABLE,
    "CDE_VAL_MTCH" VARCHAR2(64),
	"SCORE" NUMBER(38,4),  
    "MTCH_DESC_TXT" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP",   
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate,   
	 PRIMARY KEY ("ITEM_ID", "VER_NR", "HDR_ID", "SRC_VAL")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP" SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;


  GRANT SELECT ON NCI_DS_RSLT_MTCH_VAL TO "ONEDATA_RO";

alter table nci_ds_btch_hdr add DESC_COL varchar2(200);
alter table nci_ds_btch_hdr disable all triggers;
update nci_ds_btch_hdr set DESC_COL = BTCH_USR_NM || ' | ' || BTCH_NM;
commit;
alter table nci_ds_rslt_mtch_val disable all triggers;
alter table nci_ds_rslt_mtch_val modify src_val varchar2(255); 
alter table nci_ds_rslt_mtch_val modify cde_val_mtch varchar2(255);
alter table nci_ds_rslt_mtch_val enable all triggers;

alter table nci_ds_rslt_mtch_val disable all triggers;
alter table nci_ds_rslt_mtch_val add MTCH_ID number(38,0);
update nci_ds_rslt_mtch_val set MTCH_ID = 0 where MTCH_ID is null;
commit;
alter table nci_ds_rslt_mtch_val modify MTCH_ID number(38,0) default 0 not null;
alter table nci_ds_rslt_mtch_val drop primary key;
alter table nci_ds_rslt_mtch_val add primary key (HDR_ID, ITEM_ID, VER_NR, SRC_VAL, MTCH_ID);

alter table nci_ds_btch_hdr enable all triggers;
alter table nci_ds_rslt_mtch_val enable all triggers;

alter table nci_ds_rslt modify num_pv_in_cde number default 0;

alter table ref modify mtch_scr default null;
alter table nci_ds_hdr add (variant_2 number(38,0));
alter table nci_ds_hdr add (val_dom_typ_id number(38,0));
alter table nci_ds_hdr add (admin_stus_id number(38,0));
alter table nci_ds_hdr add (reg_stus_id number(38,0));
