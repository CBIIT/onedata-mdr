

DDL Changes for NIH

alter table admin_item modify (ver_nr number(4,2));
alter table admin_item modify (cntxt_ver_nr number(4,2));
alter table conc_dom modify (ver_nr number(4,2));
alter table DE_conc modify (ver_nr number(4,2));
alter table DE modify (ver_nr number(4,2));
alter table VALUE_DOM modify (ver_nr number(4,2));
alter table VALUE_DOM modify (REP_CLS_VER_NR number(4,2));

alter table CNTXT modify (ver_nr number(4,2));
alter table ALT_DEF modify (ver_nr number(4,2));
alter table ALT_NMS modify (ver_nr number(4,2));
alter table CNCPT_ADMIN_ITEM modify (ver_nr number(4,2));
alter table REP_CLS modify (ver_nr number(4,2));
alter table OBJ_CLS modify (ver_nr number(4,2));-
alter table PROP modify (ver_nr number(4,2));
alter table CLSFCTN_SCHM modify (ver_nr number(4,2));
alter table REF modify (ver_nr number(4,2));
alter table REF add (NCI_IDSEQ char(36));
alter table PERM_VAL add (NCI_IDSEQ char(36));
alter table NCI_ADMIN_ITEM_REL_ALT_KEY add (NCI_IDSEQ char(36));


alter table CNCPT modify (ver_nr number(4,2));
alter table ADMIN_ITEM_AUDIT modify (ver_nr number(4,2));
alter table CNCPT_ADMIN_ITEM modify (cncpt_ver_nr number(4,2));
alter table ALT_DEF modify (cntxt_ver_nr number(4,2));
alter table ALT_NMS modify (cntxt_ver_nr number(4,2));

alter table de modify (val_dom_ver_nr number(4,2), de_conc_ver_nr number(4,2), rep_cls_ver_nr number(4,2), derv_rul_ver_nr number(4,2));
alter table DE_CONC modify (conc_dom_ver_nr number(4,2), obj_cls_ver_nr number(4,2), prop_ver_nr number(4,2));
alter table value_dom modify (conc_dom_ver_nr number(4,2));
alter table PERM_VAL modify (val_dom_ver_nr number(4,2));

alter table ALT_DEF add (NCI_IDSEQ char(36));
alter table ALT_NMS  add (NCI_IDSEQ char(36));


alter table obj_key modify(obj_key_desc varchar2(500));

alter table admin_item add (origin_id number, origin_id_dn varchar2(500),  def_src varchar2(500));
alter table admin_item modify (origin varchar2(500));
alter table ADMIN_ITEM modify CNTXT_VER_NR default 1;


alter table CNCPT add (EVS_SRC_ID integer);


alter table admin_item add (REGSTR_STUS_NM_DN  varchar2(50), ADMIN_STUS_NM_DN varchar2(50),  CNTXT_NM_DN varchar2(175));

alter table ALT_NMS add ( CNTXT_NM_DN varchar2(175));


alter table ADMIN_ITEM add (NCI_IDSEQ char(36) null);
alter table ORG add (NCI_IDSEQ char(36) null);
alter table ORG modify (ORG_NM varchar2(80));


alter table STUS_MSTR add (NCI_STUS varchar2(20) null);
alter table STUS_MSTR add (NCI_CMNTS  varchar2(4000) null);
alter table STUS_MSTR modify ( STUS_DESC varchar2(2000));
alter table STUS_MSTR add (NCI_DISP_ORDR  integer null);

alter table OBJ_KEY add (NCI_CD varchar2(500) null);

alter table DATA_TYP add (NCI_DTTYPE_CMNTS	VARCHAR2(2000 BYTE) null);

alter table DATA_TYP add (NCI_CD varchar2(20) null);

alter table DATA_TYP add (NCI_DTTYPE_TYP_ID integer null);

alter table FMT add (NCI_CD varchar2(20) null);
alter table UOM add (NCI_CD varchar2(20) null);

alter table VALUE_DOM add (NCI_DEC_PREC number(2) null);

alter table VALUE_DOM add (NCI_STD_DTTYPE_ID number null);

alter table ALT_DEF add (NCI_DEF_TYP_ID integer null);

alter table ALT_NMS modify (NM_DESC varchar2(2000));

alter table REF add (NCI_CNTXT_ITEM_ID number, NCI_CNTXT_VER_NR number(4,2)  );

 alter table REF add ( URL varchar2(255)  );
alter table ref modify (REF_NM varchar2(255));

alter table DATA_TYP add (NCI_DTTYPE_MAP varchar2(50) null);

alter table CNCPT_ADMIN_ITEM add (NCI_ORD number(2));
alter table CNCPT_ADMIN_ITEM add (NCI_PRMRY_IND number(1));

alter table DE add (DERV_MTHD	VARCHAR2(4000), DERV_RUL varchar2(4000), DERV_TYP_ID integer);

alter table REGIST_RUL_REQ_COLMNS add (MAP_COL_NM  varchar2(50), COL_DESC varchar2(100));


alter table ALT_NMS drop primary key;


ALTER TABLE ALT_NMS
       ADD CONSTRAINT PK_ALT_NMS PRIMARY KEY (NM_ID);



alter table ALT_DEF drop primary key;


ALTER TABLE ALT_DEF
       ADD CONSTRAINT PK_ALT_DEF PRIMARY KEY (DEF_ID);

alter table PERM_VAL modify (VAL_MEAN_ID null);
alter table PERM_VAL add (       NCI_VAL_MEAN_ITEM_ID	number not null,
	NCI_VAL_MEAN_VER_NR	number(4,2) not null);



alter table CNTXT add (NCI_PRG_AREA_ID number not null);

alter table clsfctn_schm add (NCI_LABEL_TYP_FLG  char(1) null);

alter table cncpt_admin_item drop primary key;

alter table cncpt_admin_item add (nci_cncpt_val  varchar2(255), cncpt_ai_id  number not null);


ALTER TABLE CNCPT_ADMIN_ITEM
       ADD CONSTRAINT XPKCNCPT_ADMIN_ITEM PRIMARY KEY (CNCPT_AI_ID);


ALTER TABLE CNCPT_ADMIN_ITEM
       ADD CONSTRAINT U_CNCPT_ADMIN_ITEM  unique (CNCPT_ITEM_ID, 
              CNCPT_VER_NR, ITEM_ID, VER_NR,NCI_ORD);


drop table conc_dom_val_mean;

CREATE TABLE CONC_DOM_VAL_MEAN (
       CONC_DOM_VER_NR      NUMBER(4,2) NOT NULL,
       CONC_DOM_ITEM_ID     NUMBER NOT NULL,
       NCI_VAL_MEAN_ITEM_ID		number not null,
	NCI_VAL_MEAN_VER_NR		number(4,2) not null,
       VAL_MEAN_ID          NUMBER NULL,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL
);


ALTER TABLE CONC_DOM_VAL_MEAN
       ADD CONSTRAINT XPKCONC_DOM_VAL_MEAN PRIMARY KEY (
              CONC_DOM_VER_NR, CONC_DOM_ITEM_ID, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR);




CREATE TABLE NCI_CLSFCTN_SCHM_ITEM (
       ITEM_ID	number not null,
       VER_NR  number(4,2) not null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
       CSI_TYP_ID	 INTEGER NULL,
       CSI_DESC_TXT             VARCHAR2(4000) NULL,
       CSI_CMNTS	varchar2(4000) null,
       PRIMARY KEY (ITEM_ID, VER_NR)
);



CREATE TABLE NCI_VAL_MEAN (
       ITEM_ID	number not null,
       VER_NR  number(4,2) not null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
       VM_DESC_TXT             VARCHAR2(4000) NULL,
       VM_CMNTS	varchar2(4000) null,
	PRIMARY KEY (ITEM_ID, VER_NR)
);

CREATE TABLE NCI_FORM (
       ITEM_ID	number not null,
       VER_NR  number(4,2) not null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
	CATGRY_ID		integer null,
       FORM_TYP_ID	integer not null,
	PRIMARY KEY (ITEM_ID, VER_NR)
);



CREATE TABLE NCI_PROTCL (
       ITEM_ID	number not null,
       VER_NR  number(4,2) not null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
       PROTCL_TYP_ID       INTEGER NULL,
       PROTCL_ID	varchar2(50) null,
       PROTCL_PHASE    varchar2(50) null,
       LEAD_ORG	       varchar2(100) null,
	CHNG_TYP	VARCHAR2(10),
	CHNG_NBR	NUMBER,
	RVWD_DT		DATE,
	RVWD_USR_ID	VARCHAR2(30 BYTE),
	APPRVD_DT	DATE,
	APPRVD_USR_ID	VARCHAR2(30),
	PRIMARY KEY (ITEM_ID, VER_NR)
);



create table NCI_ADMIN_ITEM_REL 
( P_ITEM_ID  number not null,
  P_ITEM_VER_NR  number(4,2) not null,
  C_ITEM_ID number not null,
  C_ITEM_VER_NR number(4,2) not null,
  CNTXT_ITEM_ID  number  null,
  CNTXT_VER_NR number(4,2) null,
  REL_TYP_ID integer not null,
  DISP_ORD  integer null,
  DISP_LBL  varchar2(255) null,
  REP_NO Integer null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
   primary key (P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID));


create table NCI_ADMIN_ITEM_REL_ALT_KEY
( NCI_PUB_ID  number not null,
  NCI_VER_NR number(4,2) default 1 not null,
  P_ITEM_ID  number not null,
  P_ITEM_VER_NR  number(4,2) not null,
  C_ITEM_ID number not null,
  C_ITEM_VER_NR number(4,2) not null,
  CNTXT_CS_ITEM_ID  number  null,
  CNTXT_CS_VER_NR number(4,2) null,
  REL_TYP_ID integer not null,
  DISP_ORD  integer null,
  DISP_LBL  varchar2(255) null,
  NCI_IDSEQ char(36) null,
  EDIT_IND  number(1) null,
  DEFLT_VAL   varchar2(2000) null,
  REQ_IND number(1) null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
   primary key (NCI_PUB_ID, NCI_VER_NR));






create table NCI_QUEST_VALID_VALUE
(  NCI_PUB_ID  number not null,
   NCI_VER_NR  number(4,2) default 1 not null,
   Q_VER_NR  number(4,2) default 1 not null,
   Q_PUB_ID  number not null,
   VM_NM   varchar2(255) null,
   VM_LNM  varchar2(1000) null,
   VM_DEF	varchar2(4000) null,
   VALUE   varchar2(500) null, 
   CMNTS  varchar2(1000) null,
   EDIT_IND  char(1) null,
   SEQ_NBR integer null,
   NCI_IDSEQ char(36) null,
   MEAN_TXT   varchar2(2000) null,
   DESC_TXT  varchar2(2000) null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
   DISP_ORD  integer null,
   primary key (NCI_PUB_ID, NCI_VER_NR, Q_VER_NR, Q_PUB_ID));



create table NCI_CSI_ALT_DEFNMS
( NCI_PUB_ID number not null,
  NCI_VER_NR number(4,2) default 1 not null ,
  NMDEF_ID  number not null,
  TYP_NM  varchar2(20) not null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
primary key (NCI_PUB_ID, NCI_VER_NR, NMDEF_ID)
);

 
create table NCI_INSTR
(  INSTR_ID  number not null,
   NCI_PUB_ID  number not null,
   NCI_VER_NR  number(4,2) not null,
   NCI_LVL    varchar2(30) not null,
   NCI_TYP    varchar2(30) not null,
   SEQ_NR  integer not null,
   INSTR_LNG   varchar2(1000),
   INSTR_SHRT  varchar2(255),
   INSTR_DEF varchar2(4000) null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
	 primary key (INSTR_ID));



create table NCI_ALT_KEY_ADMIN_ITEM_REL
 ( NCI_PUB_ID  number not null,
  NCI_VER_NR number(4,2) default 1 not null,
  C_ITEM_ID number not null,
  C_ITEM_VER_NR number(4,2) not null,
  CNTXT_CS_ITEM_ID  number  null,
  CNTXT_CS_VER_NR number(4,2) null,
  REL_TYP_ID integer not null,
  DISP_ORD  integer null,
  DISP_LBL  varchar2(255) null,
  NCI_IDSEQ char(36) null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
   primary key (NCI_PUB_ID, NCI_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID));



create table NCI_STG_ADMIN_ITEM
( STG_AI_ID  number not null primary key,
  DE_ITEM_ID number null,
  DE_VER_NR number(4,2) null,
  DE_CONC_ITEM_ID number null,
  DE_CONC_VER_NR  number(4,2) null,
  CONC_DOM_ITEM_ID number null,
  CONC_DOM_VER_NR  number(4,2) null,
  VAL_DOM_ITEM_ID number null,
  VAL_DOM_VER_NR number(4,2) null,
  OBJ_CLS_ITEM_ID number null,
  OBJ_CLS_VER_NR number(4,2) null,
  OBJ_CLS_LONG_NM  varchar2(255) null,
  PROP_LONG_NM  varchar2(255) null,
  PROP_ITEM_ID number null,
  PROP_VER_NR number(4,2) null,
  CREAT_DE_IND  number(1) default 0,
  CREAT_VD_IND  number(1) default 0,
       CNTXT_ITEM_ID        NUMBER NULL,
       CNTXT_VER_NR         NUMBER(4,2) NULL,
       DE_ITEM_DESC            VARCHAR2(4000) NULL,
       DE_ITEM_LONG_NM         VARCHAR2(255) NULL,
       DE_ITEM_NM              VARCHAR2(175) NULL,
       DE_ORIGIN               number NULL,
       DEC_ORIGIN               number NULL,
       VD_ORIGIN               number NULL,
       VD_ITEM_DESC            VARCHAR2(4000) NULL,
       VD_ITEM_LONG_NM         VARCHAR2(255) NULL,
       VD_ITEM_NM              VARCHAR2(175) NULL,
       DEC_ITEM_DESC            VARCHAR2(4000) NULL,
       DEC_ITEM_LONG_NM         VARCHAR2(255) NULL,
       DEC_ITEM_NM              VARCHAR2(175)  NULL,
       ADMIN_STUS_ID        SMALLINT NULL,
       REGSTR_STUS_ID       SMALLINT NULL,
       DE_PREC              NUMBER NULL,
       REP_CLS_VER_NR       NUMBER(4,2) NULL,
       REP_CLS_ITEM_ID      NUMBER NULL,
       CTL_REC_STUS	   varchar2(100) default 'CREATED',
       CTL_VAL_MSG	  varchar2(1000) null,
       CTL_USR_ID         varchar2(100) null,
       NON_ENUM_VAL_DOM_DESC VARCHAR2(4000) NULL,
       DTTYPE_ID            NUMBER NULL,
       VAL_DOM_MAX_CHAR     SMALLINT NULL,
       VAL_DOM_TYP_ID       NUMBER NULL,
       UOM_ID               NUMBER NULL,
       VAL_DOM_MIN_CHAR     SMALLINT NULL,
       VAL_DOM_FMT_ID       NUMBER NULL,
       VAL_DOM_HIGH_VAL_NUM VARCHAR2(50) NULL,
       VAL_DOM_LOW_VAL_NUM  VARCHAR2(50) NULL,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL
);



create table NCI_STG_AI_CNCPT
( STG_AI_CNCPT_ID number not null primary key,
  STG_AI_ID  number not null,
  LVL_NM  varchar2(10) not null,
  DISP_ORD  integer not null,
  CNCPT_ITEM_ID  number not null,
  CNCPT_VER_NR number(4,2) not null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL);

create table NCI_OC_RECS (
ITEM_ID number not null,
VER_NR number(4,2) not null,
TRGT_OBJ_CLS_ITEM_ID number not null,
TRGT_OBJ_CLS_VER_NR number(4,2) not null,	
SRC_OBJ_CLS_ITEM_ID number not null,
SRC_OBJ_CLS_VER_NR number(4,2) not null,	
REL_TYP_NM	VARCHAR2(20 BYTE),
SRC_ROLE	VARCHAR2(255 BYTE),
TRGT_ROLE	VARCHAR2(255 BYTE),
DRCTN	VARCHAR2(20 BYTE),
SRC_LOW_MULT	integer,
SRC_HIGH_MULT	integer,
TRGT_LOW_MULT	integer,
TRGT_HIGH_MULT	integer,
DISP_ORD	integer,
DIMNSNLTY	integer,
ARRAY_IND	VARCHAR2(3 BYTE),
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
 primary key (ITEM_ID, VER_NR));



create table NCI_QUEST_VV_REP
(	QUEST_VV_REP_ID number not null primary key,
	QUEST_PUB_ID number not null,
 	QUEST_VER_NR number(4,2) not null,
	VV_PUB_ID  number,
  	VV_VER_NR number(4,2),
	VAL varchar2(255),
	EDIT_IND number(1),
	REP_SEQ  integer,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL
);

create table NCI_FORM_TA
(	TA_ID number not null primary key,
	SRC_PUB_ID number not null,
 	SRC_VER_NR number(4,2) not null,
	TRGT_PUB_ID  number not null,
  	TRGT_VER_NR number(4,2) not null,
	TA_INSTR   varchar2(2000),
	SRC_TYP_NM  varchar2(30),
	TRGT_TYP_NM varchar2(30),
	TA_IDSEQ  char(36),
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL
);



create table NCI_FORM_TA_REL
(	TA_ID number not null,
	NCI_PUB_ID number not null,
 	NCI_VER_NR number(4,2) not null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
	primary key (TA_ID, NCI_PUB_ID, NCI_VER_NR)
);



create table test_results (
TABLE_NAME varchar2(50) not null primary key,
RA_CNT  integer,
WA_CNT  integer,
caDSR_CNT  integer);

create table NCI_USR_CART
(
CNTCT_SECU_ID	VARCHAR2(50 BYTE) not null,
ITEM_ID   number not null,
VER_NR number(4,2) not null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
primary key (CNTCT_SECU_ID, ITEM_ID, VER_NR));


Performance indexes


create index idx_altnms_cntxt_id on alt_nms(cntxt_item_id);
create index idx_ref_ref_typ on ref(ref_typ_id);
create index idx_ref_item_id on ref(item_id, ver_nr);
create index idx_ai_idseq on admin_item(nci_idseq);
create index idx_ai_cntxt_id on admin_item(cntxt_item_id);


       