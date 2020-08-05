alter table REF add (NCI_IDSEQ char(36));
alter table PERM_VAL add (NCI_IDSEQ char(36));

alter table NCI_ADMIN_ITEM_REL_ALT_KEY add (ITEM_LONG_NM  varchar2(2000) null);

alter table NCI_STG_ADMIN_ITEM add (  OBJ_CLS_DESC  varchar2(4000) null,
  PROP_DESC  varchar2(4000) null);

alter table NCI_STG_AI_CNCPT add(  NCI_ORD  number(2) not null,
  NCI_PRMRY_IND  number(1) not null);
alter table NCI_STG_AI_CNCPT drop column  DISP_ORD;


alter table ref modify NCI_CNTXT_VER_NR number(4,2);

alter table admin_item modify (item_nm  varchar2(255));


create table NCI_ADMIN_ITEM_EXT 
( ITEM_ID number not null, 
  VER_NR number(4,2) not null,
  USED_BY  varchar2(4000),
  CNCPT_CONCAT varchar2(4000),
  CNCPT_CONCAT_NM  varchar2(4000),
  CNCPT_CONCAT_DEF  varchar2(4000),
  PRIMARY KEY (ITEM_ID, VER_NR),
  CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL);

alter table nci_admin_item_rel_alt_key modify (p_item_id null, p_item_ver_nr null);

create index idx_perm_val on perm_val (VAL_DOM_ITEM_ID, VAL_DOM_VER_NR);

create index idx2_perm_val on perm_val (VAL_DOM_ITEM_ID, VAL_DOM_VER_NR, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR);

NCI_FORM_TA_REL, OBJ_KEY - lst-upd-dt

alter table ADMIN_ITEM modify (LST_UPD_DT not null);
alter table ALT_DEF modify (LST_UPD_DT not null);
alter table ALT_NMS modify (LST_UPD_DT not null);
alter table CHAR_SET modify (LST_UPD_DT not null);
alter table CLSFCTN_SCHM modify (LST_UPD_DT not null);
alter table CNCPT modify (LST_UPD_DT not null);
alter table CNTCT modify (LST_UPD_DT not null);
alter table CNTXT modify (LST_UPD_DT not null);
alter table CONC_DOM modify (LST_UPD_DT not null);
alter table DATA_TYP modify (LST_UPD_DT not null);
alter table DE modify (LST_UPD_DT not null);
alter table DE_CONC modify (LST_UPD_DT not null);
alter table FMT modify (LST_UPD_DT not null);
alter table LANG modify (LST_UPD_DT not null);
alter table OBJ_CLS modify (LST_UPD_DT not null);
alter table OBJ_KEY modify (LST_UPD_DT not null);
alter table OBJ_TYP modify (LST_UPD_DT not null);
alter table ORG modify (LST_UPD_DT not null);
alter table ORG_CNTCT modify (LST_UPD_DT not null);
alter table PERM_VAL modify (LST_UPD_DT not null);
alter table PROP modify (LST_UPD_DT not null);
alter table REF modify (LST_UPD_DT not null);
alter table REF_DOC modify (LST_UPD_DT not null);
alter table REP_CLS modify (LST_UPD_DT not null);
alter table STUS_MSTR modify (LST_UPD_DT not null);
alter table UOM modify (LST_UPD_DT not null);
alter table USR_GRP modify (LST_UPD_DT not null);
alter table VAL_MEAN modify (LST_UPD_DT not null);
alter table NCI_CS_ITEM_REL modify (LST_UPD_DT not null);
alter table CONC_DOM_VAL_MEAN modify (LST_UPD_DT not null);
alter table NCI_ADMIN_ITEM_REL modify (LST_UPD_DT not null);
alter table NCI_ALT_KEY_ADMIN_ITEM_REL modify (LST_UPD_DT not null);
alter table NCI_CLSFCTN_SCHM_ITEM modify (LST_UPD_DT not null);
alter table NCI_VAL_MEAN modify (LST_UPD_DT not null);
alter table NCI_PROTCL modify (LST_UPD_DT not null);
alter table NCI_ADMIN_ITEM_REL_ALT_KEY modify (LST_UPD_DT not null);
alter table NCI_INSTR modify (LST_UPD_DT not null);
alter table NCI_STG_ADMIN_ITEM modify (LST_UPD_DT not null);
alter table NCI_FORM modify (LST_UPD_DT not null);
alter table NCI_OC_RECS modify (LST_UPD_DT not null);
alter table NCI_QUEST_VALID_VALUE modify (LST_UPD_DT not null);
alter table NCI_CSI_ALT_DEFNMS modify (LST_UPD_DT not null);
alter table NCI_QUEST_VV_REP modify (LST_UPD_DT not null);
alter table NCI_FORM_TA_REL modify (LST_UPD_DT not null);
alter table NCI_FORM_TA modify (LST_UPD_DT not null);
alter table NCI_USR_CART modify (LST_UPD_DT not null);
alter table NCI_STG_AI_CNCPT modify (LST_UPD_DT not null);
alter table VALUE_DOM modify (LST_UPD_DT not null);
alter table CNCPT_ADMIN_ITEM modify (LST_UPD_DT not null);
alter table NCI_ADMIN_ITEM_EXT modify (LST_UPD_DT not null);
