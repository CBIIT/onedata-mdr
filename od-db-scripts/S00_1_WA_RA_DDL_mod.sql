
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
alter table OBJ_CLS modify (ver_nr number(4,2));
alter table PROP modify (ver_nr number(4,2));
alter table CLSFCTN_SCHM modify (ver_nr number(4,2));
alter table REF modify (ver_nr number(4,2));
alter table REF add (NCI_IDSEQ char(36));
alter table PERM_VAL add (NCI_IDSEQ char(36));


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
alter table REF add (ORG_ID number);

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
ALTER TABLE ALT_NMS   ADD CONSTRAINT PK_ALT_NMS PRIMARY KEY (NM_ID);
alter table ALT_DEF drop primary key;
ALTER TABLE ALT_DEF       ADD CONSTRAINT PK_ALT_DEF PRIMARY KEY (DEF_ID);

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
(	TA_ID number ,
	NCI_PUB_ID number ,
 	NCI_VER_NR number(4,2) ,
       CREAT_DT             DATE DEFAULT sysdate ,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user ,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user ,
       FLD_DELETE           NUMBER(1) DEFAULT 0 ,
       LST_DEL_DT           DATE DEFAULT sysdate ,
       S2P_TRN_DT           DATE DEFAULT sysdate ,
       LST_UPD_DT           DATE DEFAULT sysdate ,
	primary key (TA_ID, NCI_PUB_ID, NCI_VER_NR)
);

create table test_results (
TABLE_NAME varchar2(50) primary key,
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


--Performance indexes


create index idx_altnms_cntxt_id on alt_nms(cntxt_item_id);
create index idx_ref_ref_typ on ref(ref_typ_id);
create index idx_ref_item_id on ref(item_id, ver_nr);
create index idx_ai_idseq on admin_item(nci_idseq);
create index idx_ai_cntxt_id on admin_item(cntxt_item_id);


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


alter table DE_CONC modify (LST_UPD_DT default sysdate);


alter table NCI_USR_CART add (GUEST_USR_NM  varchar2(255));

alter table nci_usr_cart drop primary key;

alter table nci_usr_cart modify (GUEST_USR_NM default 'NONE');

alter table nci_usr_cart add primary key (ITEM_ID, VER_NR, CNTCT_SECU_ID, GUEST_USR_NM);



alter table nci_quest_valid_value drop primary key;

alter table nci_quest_valid_value add primary key (NCI_PUB_ID, NCI_VER_NR);

alter table obj_key add (DISP_ORD integer null);

create unique index UX_PERM_VAL on PERM_VAL (VAL_DOM_ITEM_ID, VAL_DOM_VER_NR, PERM_VAL_NM, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR);

alter table NCI_STG_ADMIN_ITEM add (STRT_OBJ_CLS_ITEM_ID  number, STRT_OBJ_CLS_VER_NR number(4,2), STRT_PROP_ITEM_ID  number, STRT_PROP_VER_NR number(4,2));


alter table NCI_STG_ADMIN_ITEM add (STRT_DE_CONC_ITEM_ID  number, STRT_DE_CONC_VER_NR number(4,2));

					     
alter table NCI_ADMIN_ITEM_REL_ALT_KEY add (ITEM_NM  varchar2(30) null);

drop view vw_cncpt;
create materialized view VW_CNCPT 
  BUILD IMMEDIATE
  REFRESH FORCE
  ON COMMIT AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM,  ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CREATION_DT, 
ADMIN_ITEM.EFF_DT, ADMIN_ITEM.ORIGIN,  ADMIN_ITEM.UNTL_DT,  ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
 ADMIN_ITEM.CREAT_DT, ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, ADMIN_ITEM.LST_UPD_DT, 
ADMIN_ITEM.DEF_SRC, OBJ_KEY.OBJ_KEY_DESC EVS_SRC
       FROM ADMIN_ITEM, CNCPT, OBJ_KEY
       WHERE ADMIN_ITEM_TYP_ID = 49 and ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID and ADMIN_ITEM.VER_NR = CNCPT.VER_NR
	and cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID (+);
 
drop view VW_CONC_DOM;

CREATE MATERIALIZED VIEW VW_CONC_DOM
  BUILD IMMEDIATE
  REFRESH FORCE
  ON COMMIT AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT, 
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT
FROM ADMIN_ITEM
       WHERE ADMIN_ITEM_TYP_ID = 1;


drop view vw_rep_cls;


CREATE MATERIALIZED VIEW VW_REP_CLS
  BUILD IMMEDIATE
  REFRESH FORCE
  ON COMMIT AS
SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT, 
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT
FROM ADMIN_ITEM
       WHERE ADMIN_ITEM_TYP_ID = 7;

drop  view VW_CLSFCTN_SCHM;

CREATE MATERIALIZED VIEW VW_CLSFCTN_SCHM
  BUILD IMMEDIATE
  REFRESH FORCE
  ON COMMIT AS
SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT, 
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT, CS.CLSFCTN_SCHM_TYP_ID, ADMIN_ITEM.NCI_IDSEQ, ADMIN_ITEM.CNTXT_ITEM_ID, ADMIN_ITEM.CNTXT_VER_NR
FROM ADMIN_ITEM, CLSFCTN_SCHM CS
       WHERE ADMIN_ITEM_TYP_ID = 9 and ADMIN_ITEM.ITEM_ID = CS.ITEM_ID and ADMIN_ITEM.VER_NR = CS.VER_NR;



CREATE MATERIALIZED VIEW VW_CLSFCTN_SCHM_ITEM
  BUILD IMMEDIATE
  REFRESH FORCE
  ON COMMIT AS
 SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM,  ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT, 
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT, ADMIN_ITEM.NCI_IDSEQ
FROM ADMIN_ITEM
       WHERE ADMIN_ITEM_TYP_ID = 51;



drop view VW_CNTXT;

CREATE MATERIALIZED VIEW VW_CNTXT
  BUILD IMMEDIATE
  REFRESH FORCE
  ON COMMIT AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC,
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT, 
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT, C.NCI_PRG_AREA_ID
FROM ADMIN_ITEM, CNTXT C
       WHERE ADMIN_ITEM_TYP_ID = 8 and ADMIN_ITEM.ITEM_ID = C.ITEM_ID and ADMIN_ITEM.VER_NR = C.VER_NR;




alter table alt_def modify (LST_UPD_DT default sysdate);


  CREATE TABLE NCI_STG_AI_REL
   (	
	STG_AI_ID NUMBER NOT NULL , 
	ITEM_ID NUMBER NOT NULL , 
	VER_NR NUMBER(4,2) NOT NULL , 
	LVL_NM VARCHAR2(10 BYTE) NOT NULL , 
	CREAT_DT DATE DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50 BYTE) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50 BYTE) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate, 
	 PRIMARY KEY (STG_AI_ID, ITEM_ID, VER_NR));


create or replace trigger TR_AI_EXT_TAB_INS
  AFTER INSERT
  on ADMIN_ITEM
  for each row
BEGIN

if (:new.admin_item_typ_id in (5,6)) then
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def )
select :new.item_id, :new.ver_nr, :new.item_long_nm, :new.item_nm, :new.item_desc from dual;
else
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR)
select :new.ITEM_ID, :new.VER_NR from dual;
end if;
END;
/

create table NCI_STG_AI_CNCPT_CREAT
( STG_AI_ID  number not null primary key,
  CTL_VAL_MSG  varchar2(4000) null,
  GEN_STR   varchar2(255) null,
  CNCPT_CONCAT_STR_1  varchar2(4000) null,
  CNCPT_CONCAT_STR_2  varchar2(4000) null,
  ITEM_1_ID  number null,
  ITEM_1_VER_NR number(4,2) null,
  ITEM_2_ID number null,
  ITEM_2_VER_NR number(4,2) null, 
  ITEM_1_NM  varchar2(255) null,
  ITEM_1_LONG_NM varchar2(255) null,
  ITEM_1_DEF  varchar2(4000) null,
  ITEM_2_NM  varchar2(255) null,
  ITEM_2_LONG_NM varchar2(255) null,
  ITEM_2_DEF  varchar2(4000) null, 
  CONC_DOM_ITEM_ID number null,
  CONC_DOM_VER_NR  number(4,2) null,
       CNTXT_ITEM_ID        NUMBER NULL,
       CNTXT_VER_NR         NUMBER(4,2) NULL,
       ADMIN_STUS_ID        SMALLINT NULL,
       REGSTR_STUS_ID       SMALLINT NULL,
  CNCPT_1_ITEM_ID_1 number null,
  CNCPT_1_VER_NR_1 number(4,2)   null,
  CNCPT_1_ITEM_ID_2 number null,
  CNCPT_1_VER_NR_2 number(4,2)  null,
  CNCPT_1_ITEM_ID_3 number null,
  CNCPT_1_VER_NR_3 number(4,2) null,
  CNCPT_1_ITEM_ID_4 number null,
  CNCPT_1_VER_NR_4 number(4,2)  null,
  CNCPT_1_ITEM_ID_5 number null,
  CNCPT_1_VER_NR_5 number(4,2) null,
CNCPT_1_ITEM_ID_6 number null,
  CNCPT_1_VER_NR_6 number(4,2) null,
  CNCPT_1_ITEM_ID_7 number null,
  CNCPT_1_VER_NR_7 number(4,2) null,
  CNCPT_1_ITEM_ID_8 number null,
  CNCPT_1_VER_NR_8 number(4,2) null,
  CNCPT_1_ITEM_ID_9 number null,
  CNCPT_1_VER_NR_9 number(4,2) null,
  CNCPT_1_ITEM_ID_10 number null,
  CNCPT_1_VER_NR_10 number(4,2) null,
  CNCPT_2_ITEM_ID_1 number null,
  CNCPT_2_VER_NR_1 number(4,2)  null,
  CNCPT_2_ITEM_ID_2 number null,
  CNCPT_2_VER_NR_2 number(4,2) null,
  CNCPT_2_ITEM_ID_3 number null,
  CNCPT_2_VER_NR_3 number(4,2)  null,
  CNCPT_2_ITEM_ID_4 number null,
  CNCPT_2_VER_NR_4 number(4,2)  null,
  CNCPT_2_ITEM_ID_5 number null,
  CNCPT_2_VER_NR_5 number(4,2)  null,
  CNCPT_2_ITEM_ID_6 number null,
  CNCPT_2_VER_NR_6 number(4,2)  null,
  CNCPT_2_ITEM_ID_7 number null,
  CNCPT_2_VER_NR_7 number(4,2)  null,
  CNCPT_2_ITEM_ID_8 number null,
  CNCPT_2_VER_NR_8 number(4,2)  null,
  CNCPT_2_ITEM_ID_9 number null,
  CNCPT_2_VER_NR_9 number(4,2)  null,
  CNCPT_2_ITEM_ID_10 number null,
  CNCPT_2_VER_NR_10 number(4,2) null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL
);

alter table ADMIN_ITEM modify (ITEM_LONG_NM varchar2(30));

alter table PERM_VAL add (NCI_ORIGIN_ID  number, NCI_ORIGIN varchar2(500));

--
ALTER TABLE ADMIN_ITEM MODIFY DEF_SRC VARCHAR2(2000)  ;

ALTER TABLE DATA_TYP MODIFY DTTYPE_ANNTTN VARCHAR2(2000 BYTE);

ALTER TABLE DATA_TYP MODIFY DTTYPE_SCHM_REF VARCHAR2(255 BYTE);

ALTER TABLE NCI_ADMIN_ITEM_REL_ALT_KEY MODIFY ITEM_LONG_NM VARCHAR2(4000 BYTE);

ALTER TABLE NCI_INSTR MODIFY  INSTR_LNG VARCHAR2(4000 BYTE)      ;

ALTER TABLE NCI_QUEST_VALID_VALUE MODIFY VALUE VARCHAR2(4000 BYTE)    ;

ALTER TABLE NCI_CSI_ALT_DEFNMS MODIFY TYP_NM VARCHAR2(30)     ;

ALTER TABLE REF_DOC MODIFY  FILE_NM VARCHAR2(350);


alter table admin_item add (CREAT_USR_ID_X varchar2(50), LST_UPD_USR_ID_X varchar2(50));
alter table de add (PREF_QUEST_TXT  varchar2(4000));

alter table NCI_ADMIN_ITEM_REL_ALT_KEY modify (C_ITEM_ID number null, C_ITEM_VER_NR number(4,2) null);

drop trigger TR_AI_AUDIT_TAB_INS;



create table NCI_AI_TYP_VALID_STUS
( ADMIN_ITEM_TYP_ID integer not null,
  STUS_ID  integer not null,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL,
primary key (ADMIN_ITEM_TYP_ID, STUS_ID));

create table NCI_ENTTY
( ENTTY_ID number not null primary key,
  ENTTY_TYP_ID  integer not null,
  NCI_IDSEQ  char(36) not null,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL);

create table NCI_ORG
( ENTTY_ID number not null primary key,
   RAI  varchar2(255) null,
 ORG_NM varchar2(80) not null,
 RA_IND  varchar2(3) null,
  MAIL_ADDR  varchar2(240) null,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL);

create table NCI_PRSN
( ENTTY_ID number not null primary key,
  PRNT_ORG_ID  number null,
  LAST_NM varchar2(80) not null,
  FIRST_NM varchar2(30) not null,
  RNK_ORD  number(3,0) not null,
  MI varchar2(2) null,
  POS varchar2(80) null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL);

create table NCI_ENTTY_COMM
( ENTTY_ID number not null,
  COMM_TYP_ID integer not null, 
  RNK_ORD  number(3,0) not null,
  CYB_ADDR varchar2(255) not null,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL,
   primary key (ENTTY_ID, COMM_TYP_ID, RNK_ORD));

create table NCI_ENTTY_ADDR
( ENTTY_ID number not null,
  ADDR_TYP_ID integer not null, 
  RNK_ORD number(3,0) not null,
  ADDR_LINE1  varchar2(80) not null,
  ADDR_LINE2 varchar2(80) null,
  CITY  varchar2(30) not null,
  STATE_PROV varchar2(30) not null,
  POSTAL_CD varchar2(10) not null,
  CNTRY  varchar2(30) null,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL,
   primary key (ENTTY_ID, ADDR_TYP_ID, RNK_ORD));


create table NCI_CHANGE_HISTORY
(ACCH_IDSEQ  char(36) not null primary key,
 AC_IDSEQ char(36) not null,
CHANGE_DATETIMESTAMP date NOT NULL,           
CHANGE_ACTION        VARCHAR2(10) NOT NULL  ,  
CHANGED_BY           VARCHAR2(30) NOT NULL  , 
CHANGED_TABLE         VARCHAR2(30)   NOT NULL ,
CHANGED_TABLE_IDSEQ   CHAR(36)   NOT NULL  ,   
CHANGED_COLUMN        VARCHAR2(30) NOT NULL ,  
OLD_VALUE                     VARCHAR2(4000), 
NEW_VALUE                     VARCHAR2(4000) ,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL);


alter table ref_doc add (NCI_MIME_TYPE	VARCHAR2(128 BYTE) null, 
NCI_DOC_SIZE	number null,
NCI_CHARSET	VARCHAR2(128 BYTE) null,
NCI_DOC_LST_UPD_DT	DATE null,
NCI_REF_ID  number not null);


alter table REF_DOC modify (REF_DOC_TYP_ID null);


-- Tracker 
alter table PERM_VAL add  (PRNT_CNCPT_ITEM_ID number null, PRNT_CNCPT_VER_NR number(4,2) null);

alter table ref_doc add (BLOB_COL BLOB);


--


update OBJ_KEY set NCI_CD =  'DATAELEMENT' where OBJ_KEY_ID=4;
update OBJ_KEY set NCI_CD =  'DE_CONCEPT' where OBJ_KEY_ID=2;
update OBJ_KEY set NCI_CD =  'VALUEDOMAIN' where OBJ_KEY_ID=3;
update OBJ_KEY set NCI_CD =  'CONCEPTUALDOMAIN' where OBJ_KEY_ID=1;
update OBJ_KEY set NCI_CD =  'CLASSIFICATION' where OBJ_KEY_ID=9;
update OBJ_KEY set NCI_CD =  'OBJECTCLASS' where OBJ_KEY_ID=5;
update OBJ_KEY set NCI_CD =  'PROPERTY' where OBJ_KEY_ID=6;
update OBJ_KEY set NCI_CD =  'REPRESENTATION' where OBJ_KEY_ID=7;
update OBJ_KEY set NCI_CD =  'CONCEPT' where OBJ_KEY_ID=49;

commit;

insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (53,4,'Value Meaning', 'Value Meaning', '', 'VALUEMEANING');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (51,4,'Classification Scheme Item', 'Classification Scheme Item', '', 'CS_ITEM');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (50,4,'Protocol', 'Protocol for Cancer Trials', 'A named collection of questionnaires used on a specific trial or study', 'PROTOCOL');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (52,4,'Module', 'Module ', 'Module', 'MODULE');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (54,4,'Form', 'Form', 'Form', 'CRF');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (55,4,'Template', 'Template', 'Template', 'TEMPLATE');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (56,4,'Object Recs', 'OBJECTRECS', 'OBJECTRECS', 'OBJECTRECS');

commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (14, 'NCI Program Areas');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (15, 'NCI Definition Type');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (16, 'NCI Standard Data Type');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (17, 'NCI Item Relationships');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (18, 'Origin');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (19, 'NCI Protocol Type'); 
commit;


insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (20, 'NCI CSI Types');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (21, 'NCI Derivation Types');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (22, 'Form Category');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (23, 'Concept Source');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (24, 'Form Type');
commit;

insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (60,17,'Protocol-Form Relationship', 'NCI Protocol-Form Relationship');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (61,17,'Form-Module Relationship', 'NCI Form-Module Relationship');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (63,17,'Module-DE Relationship', 'NCI Question');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (64,17,'CSI-CSI-CS', 'CSI Node relationship');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (65,17,'CSI-DE Reationship', 'CSI-DE Relationship');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (66,17,'Derived DE Children', 'Derived DE children');
commit;

insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (70,24,'CRF', 'Form');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (71,24,'Template', 'Template');
commit;

update obj_key set fld_delete = 1 where obj_key_id = 10;
commit;

update obj_key set obj_key_desc = 'Representation Term' where obj_key_id = 7;
commit;


insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (25, 'Address Type');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (26, 'Communication Type');
commit;


insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (27, 'Entity Type');
commit;

insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) 
values (72,27,'Organization', 'Organization');


insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) 
values (73,27,'Person', 'Person');
commit;


-- views


  CREATE OR REPLACE VIEW VW_ADMIN_STUS AS
  SELECT "STUS_ID","STUS_NM","STUS_DESC","STUS_TYP_ID","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","STUS_MSK","STUS_ACRO","NCI_STUS","NCI_CMNTS","NCI_DISP_ORDR"
       FROM STUS_MSTR
       WHERE STUS_TYP_ID = 2;



  CREATE OR REPLACE  VIEW VW_REGSTR_STUS AS
  SELECT "STUS_ID","STUS_NM","STUS_DESC","STUS_TYP_ID","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","STUS_MSK","STUS_ACRO","NCI_STUS","NCI_CMNTS","NCI_DISP_ORDR"
       FROM STUS_MSTR
       WHERE STUS_TYP_ID = 1;


create or replace view VW_CSI_NODE_DEC_REL as 	select ak.NCI_PUB_ID, ak.NCI_VER_NR, ak.CREAT_DT, ak.CREAT_USR_ID, ak.LST_UPD_USR_ID, ak.LST_UPD_DT, ak.S2P_TRN_DT, ak.LST_DEL_DT, ak.FLD_DELETE,
ai.ITEM_NM, ai.ITEM_LONG_NM, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC
from NCI_ALT_KEY_ADMIN_ITEM_REL ak, ADMIN_ITEM ai
where ak.C_ITEM_ID  = ai.ITEM_ID and ak.C_ITEM_VER_NR  = ai.VER_NR and ai.ADMIN_ITEM_TYP_ID = 2;

create or replace view VW_CSI_NODE_DE_REL as 	select ak.NCI_PUB_ID, ak.NCI_VER_NR, ak.CREAT_DT, ak.CREAT_USR_ID, ak.LST_UPD_USR_ID, ak.LST_UPD_DT, ak.S2P_TRN_DT, ak.LST_DEL_DT, ak.FLD_DELETE,
ai.ITEM_NM, ai.ITEM_LONG_NM, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC
from NCI_ALT_KEY_ADMIN_ITEM_REL ak, ADMIN_ITEM ai
where ak.C_ITEM_ID  = ai.ITEM_ID and ak.C_ITEM_VER_NR  = ai.VER_NR and ai.ADMIN_ITEM_TYP_ID = 4;

create or replace view VW_CSI_NODE_FORM_REL as 	select ak.NCI_PUB_ID, ak.NCI_VER_NR, ak.CREAT_DT, ak.CREAT_USR_ID, ak.LST_UPD_USR_ID, ak.LST_UPD_DT, ak.S2P_TRN_DT, ak.LST_DEL_DT, ak.FLD_DELETE,
ai.ITEM_NM, ai.ITEM_LONG_NM, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC
from NCI_ALT_KEY_ADMIN_ITEM_REL ak, ADMIN_ITEM ai
where ak.C_ITEM_ID  = ai.ITEM_ID and ak.C_ITEM_VER_NR  = ai.VER_NR and ai.ADMIN_ITEM_TYP_ID = 54;

create or replace view VW_CSI_NODE_VD_REL as 	select ak.NCI_PUB_ID, ak.NCI_VER_NR, ak.CREAT_DT, ak.CREAT_USR_ID, ak.LST_UPD_USR_ID, ak.LST_UPD_DT, ak.S2P_TRN_DT, ak.LST_DEL_DT, ak.FLD_DELETE,
ai.ITEM_NM, ai.ITEM_LONG_NM, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC
from NCI_ALT_KEY_ADMIN_ITEM_REL ak, ADMIN_ITEM ai
where ak.C_ITEM_ID  = ai.ITEM_ID and ak.C_ITEM_VER_NR  = ai.VER_NR and ai.ADMIN_ITEM_TYP_ID = 3;


  CREATE OR REPLACE  VIEW VW_DE AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, 
ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CNTXT_NM_DN, 
ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
 DE.DE_CONC_VER_NR, DE.DE_CONC_ITEM_ID, DE.VAL_DOM_VER_NR, DE.VAL_DOM_ITEM_ID, DE.REP_CLS_VER_NR, DE.REP_CLS_ITEM_ID, 
DE.CREAT_USR_ID, DE.LST_UPD_USR_ID, DE.FLD_DELETE, DE.LST_DEL_DT, DE.S2P_TRN_DT, DE.LST_UPD_DT, DE.CREAT_DT,
DE.PREF_QUEST_TXT
   FROM ADMIN_ITEM, DE
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
and DE.VER_NR = ADMIN_ITEM.VER_NR;

create or replace view VW_DE_CONC as 	SELECT DE_CONC.LST_UPD_DT, DE_CONC.S2P_TRN_DT, DE_CONC.LST_DEL_DT, DE_CONC.FLD_DELETE, DE_CONC.LST_UPD_USR_ID, DE_CONC.CREAT_USR_ID, DE_CONC.CREAT_DT, 
DE_CONC.OBJ_CLS_VER_NR, DE_CONC.OBJ_CLS_ITEM_ID, DE_CONC.PROP_ITEM_ID, DE_CONC.PROP_VER_NR, DE_CONC.CONC_DOM_ITEM_ID, DE_CONC.CONC_DOM_VER_NR, 
ADMIN_ITEM.ITEM_ID, 
ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, 
ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CNTXT_ITEM_ID, ADMIN_ITEM.CNTXT_VER_NR, ADMIN_ITEM.ADMIN_NOTES,
 ADMIN_ITEM.CHNG_DESC_TXT, ADMIN_ITEM.CREATION_DT, ADMIN_ITEM.EFF_DT, ADMIN_ITEM.DATA_ID_STR, ADMIN_ITEM.ADMIN_ITEM_TYP_ID, 
ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_ID, ADMIN_ITEM.ADMIN_STUS_ID
FROM ADMIN_ITEM, DE_CONC
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID=2 
AND ADMIN_ITEM.ITEM_ID = DE_CONC.ITEM_ID
AND ADMIN_ITEM.VER_NR = DE_CONC.VER_NR;

create or replace view VW_NCI_AI as 	select 
	ADMIN_ITEM.ITEM_ID, 
	ADMIN_ITEM.VER_NR, 
        '.' || ADMIN_ITEM.ITEM_ID || '.' ITEM_ID_STR,
	ADMIN_ITEM.CREAT_USR_ID, 
	ADMIN_ITEM.LST_UPD_USR_ID, 
	ADMIN_ITEM.FLD_DELETE, 
	ADMIN_ITEM.LST_DEL_DT, 
	ADMIN_ITEM.S2P_TRN_DT, 
	ADMIN_ITEM.LST_UPD_DT, 
	ADMIN_ITEM.CREAT_DT,
        ADMIN_ITEM.ITEM_LONG_NM || 	ADMIN_ITEM.ITEM_NM || ADMIN_ITEM.ITEM_DESC  SEARCH_STR
from ADMIN_ITEM;

create or replace view VW_NCI_ALT_DEF as 	
SELECT ALT_DEF.DEF_ID, 'CDE' ALT_DEF_LVL, DE_AI.ITEM_ID  DE_ITEM_ID, 
		DE_AI.VER_NR DE_VER_NR,
		ALT_DEF.ITEM_ID, ALT_DEF.VER_NR, 
		ALT_DEF.CNTXT_ITEM_ID, ALT_DEF.CNTXT_VER_NR, 
		ALT_DEF.DEF_DESC, ALT_DEF.NCI_DEF_TYP_ID,
        	ALT_DEF.PREF_DEF_IND, ALT_DEF.LANG_ID, AGG.CSI_ALT_DEFS,
		ALT_DEF.CREAT_DT, ALT_DEF.CREAT_USR_ID, ALT_DEF.LST_UPD_USR_ID, ALT_DEF.FLD_DELETE, 
        ALT_DEF.LST_DEL_DT, ALT_DEF.S2P_TRN_DT, ALT_DEF.LST_UPD_DT
       FROM ALT_DEF, ADMIN_ITEM DE_AI,
      (select a.def_id, listagg(cs.item_nm ||  '/' || ai.item_nm, chr(10)) within group (order by a.item_id) CSI_ALT_DEFS
        from alt_def a , NCI_CSI_ALT_DEFNMS n, nci_admin_item_rel_alt_key x, admin_item ai , admin_item cs, de
       where n.nmdef_id = a.def_id and n.nci_pub_id = x.nci_pub_id and x.c_item_id = ai.item_id  and a.item_id = de.item_id and a.ver_nr = de.ver_nr
       and x.c_item_ver_nr = ai.ver_nr and x.cntxt_cs_item_id = cs.item_id and x.cntxt_cs_ver_nr = cs.ver_nr
       group by a.def_id) agg
 where DE_AI.ADMIN_ITEM_TYP_ID = 4 and
	ALT_DEF.ITEM_ID = DE_AI.ITEM_ID and
	ALT_DEF.VER_NR = DE_AI.VER_NR and
	ALT_DEF.DEF_ID = AGG.DEF_ID (+);

create or replace view VW_NCI_ALT_NMS as 	SELECT ALT_NMS.NM_ID, 'CDE' ALT_NMS_LVL, DE_AI.ITEM_ID  DE_ITEM_ID, 
		DE_AI.VER_NR DE_VER_NR,
		ALT_NMS.ITEM_ID, ALT_NMS.VER_NR, 
		ALT_NMS.CNTXT_ITEM_ID, ALT_NMS.CNTXT_VER_NR, 
		ALT_NMS.NM_DESC, 
        	ALT_NMS.PREF_NM_IND, ALT_NMS.LANG_ID, AGG.CSI_ALT_NMS,
		ALT_NMS.CREAT_DT, ALT_NMS.CREAT_USR_ID, ALT_NMS.LST_UPD_USR_ID, ALT_NMS.FLD_DELETE, ALT_NMS.LST_DEL_DT, ALT_NMS.S2P_TRN_DT, ALT_NMS.LST_UPD_DT, ALT_NMS.NM_TYP_ID
       FROM ALT_NMS, ADMIN_ITEM DE_AI,
       (select a.nm_id, listagg(cs.item_nm ||  '/' || ai.item_nm, chr(10)) within group (order by a.item_id) CSI_ALT_NMS
        from alt_nms a , NCI_CSI_ALT_DEFNMS n, nci_admin_item_rel_alt_key x, admin_item ai , admin_item cs, de
       where n.nmdef_id = a.nm_id and n.nci_pub_id = x.nci_pub_id and x.c_item_id = ai.item_id and a.item_id = de.item_id and a.ver_nr = de.ver_nr
       and x.c_item_ver_nr = ai.ver_nr and x.cntxt_cs_item_id = cs.item_id and x.cntxt_cs_ver_nr = cs.ver_nr
       group by a.nm_id) agg
 where DE_AI.ADMIN_ITEM_TYP_ID = 4 and
	ALT_NMS.ITEM_ID = DE_AI.ITEM_ID and
	ALT_NMS.VER_NR = DE_AI.VER_NR and upper(ALT_NMS.NM_DESC) <> upper(ALT_NMS.CNTXT_NM_DN) 
	and alt_nms.nm_id = agg.nm_id (+);

create or replace view VW_NCI_CSI_DE as 	select  aim.NCI_PUB_ID, AIM.NCI_VER_NR,  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, ai.item_id csi_item_id, ai.ver_nr csi_ver_nr, 
  ai.item_nm csi_ITEM_NM, air.cntxt_cs_item_id CS_ITEM_ID, air.CNTXT_CS_VER_NR CS_VER_NR, aim.rel_typ_id,
 ai.item_long_nm  csi_item_long_nm, ai.item_desc csi_item_desc, air.p_item_Id p_CS_ITEM_ID, air.P_ITEM_VER_NR p_CS_VER_NR,
aim.CREAT_DT, aim.CREAT_USR_ID, aim.LST_UPD_USR_ID, aim.FLD_DELETE, aim.LST_DEL_DT, aim.S2P_TRN_DT, aim.LST_UPD_DT,
 ai.item_nm || ' ' || cs.ITEM_NM CSI_SEARCH_STR, cs.ITEM_NM  CS_ITEM_NM, cs.ITEM_LONG_NM CS_ITEM_LONG_NM
from admin_item ai, nci_admin_item_rel_alt_key air, nci_alt_key_admin_item_rel aim, admin_item cs 
where ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr 
and air.rel_typ_id = 64
and aim.nci_pub_id = air.nci_pub_id and aim.nci_ver_nr = air.nci_ver_nr
and air.cntxt_cs_item_id = cs.item_id and air.cntxt_cs_ver_nr = cs.ver_nr and cs.admin_item_typ_id = 9;

create or replace view VW_NCI_CSI_NM as 	select  x.NCI_PUB_ID, x.NCI_VER_NR, ai.item_nm CSI_NM, ai.item_long_nm  csi_long_nm, cs.ITEM_NM CS_NM, cs.item_id cs_item_id, cs.ver_nr cs_ver_nr, ai.item_id csi_item_id,
       ai.ver_nr  csi_ver_nr, cs.item_long_nm ||  '/' || ai.item_long_nm CSI_FULL_NM,
       x.CREAT_DT, x.CREAT_USR_ID, x.LST_UPD_USR_ID, x.FLD_DELETE, x.LST_DEL_DT, x.S2P_TRN_DT, x.LST_UPD_DT
       from nci_admin_item_rel_alt_key x, admin_item ai , admin_item cs
       where  x.c_item_id = ai.item_id 
       and x.c_item_ver_nr = ai.ver_nr and x.cntxt_cs_item_id = cs.item_id and x.cntxt_cs_ver_nr = cs.ver_nr and
       x.rel_typ_id = 64;

create or replace view VW_NCI_CSI_NODE as 	SELECT NODE.NCI_PUB_ID, NODE.NCI_VER_NR, CSI.ITEM_ID, CSI.VER_NR, CSI.ITEM_NM, CSI.ITEM_LONG_NM, CSI.ITEM_DESC, 
CSI.CNTXT_NM_DN, CSI.CURRNT_VER_IND, CSI.REGSTR_STUS_NM_DN, CSI.ADMIN_STUS_NM_DN, NODE.CREAT_DT, 
NODE.CREAT_USR_ID, NODE.LST_UPD_USR_ID, NODE.FLD_DELETE, NODE.LST_DEL_DT, NODE.S2P_TRN_DT, 
NODE.LST_UPD_DT, cs.CNTXT_ITEM_ID, CS.CNTXT_VER_NR,
cs.item_id cs_item_id, cs.ver_nr cs_ver_nr , cs.item_long_nm cs_long_nm, cs.item_nm cs_item_nm, cs.item_desc cs_item_desc,
pcsi.item_id pcsi_item_id, pcsi.ver_nr pcsi_ver_nr, pcsi.item_long_nm pcsi_long_nm, pcsi.item_nm pcsi_item_nm, cs.admin_stus_nm_dn cs_admin_stus_nm_dn,CS.CLSFCTN_SCHM_TYP_ID
FROM VW_CLSFCTN_SCHM_ITEM CSI, NCI_ADMIN_ITEM_REL_ALT_KEY NODE, VW_CLSFCTN_SCHM CS, VW_CLSFCTN_SCHM_ITEM PCSI
       WHERE  node.c_item_id = csi.item_id and node.c_item_ver_nr = csi.ver_nr
       and node.cntxt_cs_item_id = cs.item_id and node.cntxt_cs_Ver_nr = cs.ver_nr
       and node.rel_typ_id = 64
       and node.p_item_id = pcsi.item_id (+)
       and node.p_item_ver_nr = pcsi.ver_nr (+);

create or replace view VW_NCI_DE as 	select 
	ADMIN_ITEM.ITEM_ID, 
	ADMIN_ITEM.VER_NR, 
        '.' || ADMIN_ITEM.ITEM_ID || '.' ITEM_ID_STR,
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
--	ADMIN_ITEM.REGSTR_STUS_NM_DN,
--	ADMIN_ITEM.ADMIN_STUS_NM_DN,
	ADMIN_ITEM.CNTXT_NM_DN,
	ADMIN_ITEM.CNTXT_ITEM_ID,
	ADMIN_ITEM.CNTXT_VER_NR,
	ADMIN_ITEM.CREAT_USR_ID, 
	ADMIN_ITEM.CREAT_USR_ID CREAT_USR_ID_X, 
	ADMIN_ITEM.LST_UPD_USR_ID, 
	ADMIN_ITEM.LST_UPD_USR_ID LST_UPD_USR_ID_X, 
        rs.NCI_DISP_ORDR REGSTR_STUS_DISP_ORD,
        ws.NCI_DISP_ORDR ADMIN_STUS_DISP_ORD,
	ADMIN_ITEM.FLD_DELETE, 
	ADMIN_ITEM.LST_DEL_DT, 
	ADMIN_ITEM.S2P_TRN_DT, 
	ADMIN_ITEM.LST_UPD_DT, 
	ADMIN_ITEM.CREAT_DT,
ADMIN_ITEM.NCI_IDSEQ,
CNTXT.NCI_PRG_AREA_ID,
ADMIN_ITEM_TYP_ID,
  ext.USED_BY CNTXT_AGG,
	ref.ref_desc PREF_QUEST_TXT,
	    substr(ADMIN_ITEM.ITEM_LONG_NM || 	ADMIN_ITEM.ITEM_NM || nvl(ref.ref_desc, ''),1,4000)  SEARCH_STR 
from ADMIN_ITEM,  VW_CNTXT CNTXT, 
NCI_ADMIN_ITEM_EXT ext,
 (select item_id, ver_nr, ref_desc from ref where ref_typ_id = 80) ref,
VW_REGSTR_STUS rs,
VW_ADMIN_STUS ws
  where ADMIN_ITEM_TYP_ID = 4 
--and ADMIN_ITEM.ITEM_Id = de.item_id 
--and ADMIN_ITEM.VER_NR = DE.VER_NR
and ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
and ADMIN_ITEM.VER_NR = EXT.VER_NR
and ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
and ADMIN_ITEM.VER_NR = REF.VER_NR(+)
and ADMIN_ITEM.REGSTR_STUS_ID = rs.STUS_ID (+)
and ADMIN_ITEM.ADMIN_STUS_ID = ws.STUS_ID (+)
and ADMIN_ITEM.CNTXT_ITEM_ID = CNTXT.ITEM_ID
and ADMIN_ITEM.CNTXT_VER_NR = CNTXT.VER_NR;

create or replace view VW_NCI_DEC_CNCPT as 	SELECT  '2. Object Class' ALT_NMS_LVL, DEC.ITEM_ID  DEC_ITEM_ID, 
		DEC.VER_NR DEC_VER_NR,
		a.ITEM_ID, a.VER_NR, 
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR, 
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID, 
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT, 
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE_CONC DEC where 
	a.ITEM_ID = DEC.OBJ_CLS_ITEM_ID and
	a.VER_NR = DEC.OBJ_CLS_VER_NR
	union
         SELECT '1. Property' ALT_NMS_LVL, DEC.ITEM_ID  DEC_ITEM_ID, 
		DEC.VER_NR DEC_VER_NR,
		a.ITEM_ID, a.VER_NR, 
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR, 
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID, 
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT, 
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE_CONC DEC where 
	a.ITEM_ID = DEC.PROP_ITEM_ID and
	a.VER_NR = DEC.PROP_VER_NR;

create or replace view VW_NCI_DE_CNCPT as 	SELECT  '5. Object Class' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR, 
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR, 
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID, 
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT, 
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where 
	a.ITEM_ID = DE_CONC.OBJ_CLS_ITEM_ID and
	a.VER_NR = DE_CONC.OBJ_CLS_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '4. Property' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR, 
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR, 
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID, 
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT, 
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where 
	a.ITEM_ID = DE_CONC.PROP_ITEM_ID and
	a.VER_NR = DE_CONC.PROP_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '3. Representation Term' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR, 
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR, 
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID, 
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT, 
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, VALUE_DOM VD where 
	a.ITEM_ID = VD.REP_CLS_ITEM_ID and
	a.VER_NR = VD.REP_CLS_VER_NR and
	DE.VAL_DOM_ITEM_ID = VD.ITEM_ID and
	DE.VAL_DOM_VER_NR = VD.VER_NR
	union
         SELECT '1. Value Meaning' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR, 
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR, 
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID, 
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT, 
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, PERM_VAL PV where 
	a.ITEM_ID = PV.NCI_VAL_MEAN_ITEM_ID and
	a.VER_NR = PV.NCI_VAL_MEAN_VER_NR and
	DE.VAL_DOM_ITEM_ID = PV.VAL_DOM_ITEM_ID and
	DE.VAL_DOM_VER_NR = PV.VAL_DOM_VER_NR
	union
         SELECT '2. Value Domain' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR, 
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR, 
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID, 
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT, 
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE where 
	DE.VAL_DOM_ITEM_ID = a.ITEM_ID and
	DE.VAL_DOM_VER_NR = a.VER_NR;

create or replace view VW_NCI_DE_HORT as 	SELECT 
	ADMIN_ITEM.ITEM_ID ITEM_ID, 
	ADMIN_ITEM.VER_NR, 
	ADMIN_ITEM.ITEM_NM, 
	ADMIN_ITEM.ITEM_LONG_NM, 
	ADMIN_ITEM.ITEM_DESC, 
	ADMIN_ITEM.CNTXT_NM_DN, 
	ADMIN_ITEM.ORIGIN, 
        ADMIN_ITEM.ORIGIN_ID_DN,
	ADMIN_ITEM.UNTL_DT, 
	ADMIN_ITEM.CURRNT_VER_IND, 
	DE.DE_PREC,
	DE.DE_CONC_ITEM_ID,
	DE.DE_CONC_VER_NR, 
	DE.VAL_DOM_VER_NR, 
	DE.VAL_DOM_ITEM_ID,
	DE.REP_CLS_VER_NR, 
	DE.REP_CLS_ITEM_ID, 
DE.DERV_DE_IND,
DE.DERV_MTHD,
DE.DERV_RUL,
DE.DERV_TYP_ID,
	DE.CREAT_USR_ID, 
	DE.LST_UPD_USR_ID, 
	DE.FLD_DELETE, 
	DE.LST_DEL_DT, 
	DE.S2P_TRN_DT, 
	DE.LST_UPD_DT, 
	DE.CREAT_DT, 
	DE.CREAT_USR_ID CREAT_USR_ID_API, 
	DE.LST_UPD_USR_ID LST_UPD_USR_ID_API, 
	DE.CREAT_DT CREAT_DT_API, 
	DE.LST_UPD_DT LST_UPD_DT_API, 
	VALUE_DOM.CONC_DOM_VER_NR, 
	VALUE_DOM.CONC_DOM_ITEM_ID, 
	VALUE_DOM.NON_ENUM_VAL_DOM_DESC, 
	VALUE_DOM.UOM_ID, 
	VALUE_DOM.VAL_DOM_TYP_ID VAL_DOM_TYP_ID, 
	VALUE_DOM.VAL_DOM_MIN_CHAR, 
	VALUE_DOM.VAL_DOM_MAX_CHAR, 
	VALUE_DOM.VAL_DOM_FMT_ID, 
	VALUE_DOM.CHAR_SET_ID, 
	VALUE_DOM.CREAT_DT VALUE_DOM_CREAT_DT, 
	VALUE_DOM.CREAT_USR_ID VALUE_DOM_USR_ID, 
	VALUE_DOM.LST_UPD_USR_ID VALUE_DOM_LST_UPD_USR_ID, 
	VALUE_DOM.LST_UPD_DT VALUE_DOM_LST_UPD_DT,
	VALUE_DOM_AI.ITEM_NM VALUE_DOM_ITEM_NM, 
	VALUE_DOM_AI.ITEM_LONG_NM VALUE_DOM_ITEM_LONG_NM, 
	VALUE_DOM_AI.ITEM_DESC  VALUE_DOM_ITEM_DESC, 
	VALUE_DOM_AI.CNTXT_NM_DN VALUE_DOM_CNTXT_NM, 
	VALUE_DOM_AI.CURRNT_VER_IND VALUE_DOM_CURRNT_VER_IND, 
	VALUE_DOM_AI.REGSTR_STUS_NM_DN VALUE_DOM_REGSTR_STUS_NM, 
	VALUE_DOM_AI.ADMIN_STUS_NM_DN VALUE_DOM_ADMIN_STUS_NM, 
	VALUE_DOM.NCI_STD_DTTYPE_ID,
    VALUE_DOM.DTTYPE_ID,
	ADMIN_ITEM.REGSTR_AUTH_ID,
	DEC_AI.ITEM_NM DEC_ITEM_NM, 
	DEC_AI.ITEM_LONG_NM DEC_ITEM_LONG_NM, 
	DEC_AI.ITEM_DESC  DEC_ITEM_DESC, 
	DEC_AI.CNTXT_NM_DN DEC_CNTXT_NM, 
	DEC_AI.CURRNT_VER_IND DEC_CURRNT_VER_IND, 
	DEC_AI.REGSTR_STUS_NM_DN DEC_REGSTR_STUS_NM, 
	DEC_AI.ADMIN_STUS_NM_DN DEC_ADMIN_STUS_NM, 
	DEC_AI.CREAT_DT DEC_CREAT_DT, 
	DEC_AI.CREAT_USR_ID DEC_USR_ID, 
	DEC_AI.LST_UPD_USR_ID DEC_LST_UPD_USR_ID, 
	DEC_AI.LST_UPD_DT DEC_LST_UPD_DT,
	DE_CONC.OBJ_CLS_ITEM_ID,
	DE_CONC.OBJ_CLS_VER_NR,
        OC.ITEM_NM OBJ_CLS_ITEM_NM,
        OC.ITEM_LONG_NM OBJ_CLS_ITEM_LONG_NM,
        PROP.ITEM_NM PROP_ITEM_NM,
        PROP.ITEM_LONG_NM PROP_ITEM_LONG_NM,
	DE_CONC.PROP_ITEM_ID,
	DE_CONC.PROP_VER_NR,
	DE_CONC.CONC_DOM_ITEM_ID DEC_CD_ITEM_ID,
	DE_CONC.CONC_DOM_VER_NR DEC_CD_VER_NR,
	DEC_CD.ITEM_NM DEC_CD_ITEM_NM, 
	DEC_CD.ITEM_LONG_NM DEC_CD_ITEM_LONG_NM, 
	DEC_CD.ITEM_DESC  DEC_CD_ITEM_DESC, 
	DEC_CD.CNTXT_NM_DN DEC_CD_CNTXT_NM, 
	DEC_CD.CURRNT_VER_IND DEC_CD_CURRNT_VER_IND, 
	DEC_CD.REGSTR_STUS_NM_DN DEC_CD_REGSTR_STUS_NM, 
	DEC_CD.ADMIN_STUS_NM_DN DEC_CD_ADMIN_STUS_NM, 
	CD_AI.ITEM_NM CD_ITEM_NM, 
	CD_AI.ITEM_LONG_NM CD_ITEM_LONG_NM, 
	CD_AI.ITEM_DESC  CD_ITEM_DESC, 
	CD_AI.CNTXT_NM_DN CD_CNTXT_NM, 
	CD_AI.CURRNT_VER_IND CD_CURRNT_VER_IND, 
	CD_AI.REGSTR_STUS_NM_DN CD_REGSTR_STUS_NM, 
	CD_AI.ADMIN_STUS_NM_DN CD_ADMIN_STUS_NM, 
	       ADMIN_ITEM.ADMIN_ITEM_TYP_ID ,
        '' CNTXT_AGG,
        SYSDATE - greatest(DE.LST_UPD_DT, admin_item.lst_upd_dt, Value_dom.LST_UPD_DT, dec_ai.LST_UPD_DT) LST_UPD_CHG_DAYS
       FROM ADMIN_ITEM, DE,  VALUE_DOM, ADMIN_ITEM VALUE_DOM_AI, 
	ADMIN_ITEM DEC_AI, DE_CONC, VW_CONC_DOM DEC_CD,
	VW_CONC_DOM CD_AI, ADMIN_ITEM OC, ADMIN_ITEM PROP
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
and DE.VER_NR = ADMIN_ITEM.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM_AI.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM_AI.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
and DE.DE_CONC_ITEM_ID = DEC_AI.ITEM_ID
and DE.DE_CONC_VER_NR = DEC_AI.VER_NR
and DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
and DE_CONC.OBJ_CLS_ITEM_ID = OC.ITEM_ID
and DE_CONC.OBJ_CLS_VER_NR = OC.VER_NR
and DE_CONC.PROP_ITEM_ID = PROP.ITEM_ID
and DE_CONC.PROP_VER_NR = PROP.VER_NR
and DE.DE_CONC_VER_NR = DE_CONC.VER_NR
and DE_CONC.CONC_DOM_ITEM_ID = DEC_CD.ITEM_ID
and DE_CONC.CONC_DOM_VER_NR = DEC_CD.VER_NR
and VALUE_DOM.CONC_DOM_ITEM_ID = CD_AI.ITEM_ID
and VALUE_DOM.CONC_DOM_VER_NR = CD_AI.VER_NR;

create or replace view VW_NCI_DE_PV as 	SELECT PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT, 
              DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR, VM.ITEM_NM, VM.ITEM_LONG_NM, 
                VM.ITEM_DESC, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR, e.CNCPT_CONCAT, e.CNCPT_CONCAT_NM,
		PV.CREAT_DT, PV.CREAT_USR_ID, PV.LST_UPD_USR_ID, PV.FLD_DELETE, PV.LST_DEL_DT, PV.S2P_TRN_DT, PV.LST_UPD_DT,
                PV.PRNT_CNCPT_ITEM_ID, PV.PRNT_CNCPT_VER_NR, VM.ITEM_NM || ' ' || VM.ITEM_DESC  VM_SEARCH_STR
       FROM  DE, PERM_VAL PV, ADMIN_ITEM VM, NCI_ADMIN_ITEM_EXT e where 
	PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID and
	PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR and
	PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID and
	PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR and
        VM.ITEM_ID = e.ITEM_ID and
        VM.VER_NR = e.VER_NR;

create or replace view VW_NCI_FORM as 	select air.p_item_id, air.p_item_ver_nr, ai.item_id, ai.ver_nr, ai.item_nm, ai.item_long_nm, ai.item_desc, ai.cntxt_item_id, ai.cntxt_ver_nr,
'FORM' admin_item_typ_nm, f.catgry_id, f.FORM_TYP_ID, ai.admin_stus_id,
ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, air.disp_ord, air.rep_no
from admin_item ai, nci_admin_item_rel air, nci_form f where 
ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr and air.rel_typ_id = 60 and ai.item_id = f.item_id and ai.ver_nr = f.ver_nr;

create or replace view VW_NCI_FORM_MODULE as 	select air.p_item_id, air.p_item_ver_nr, ai.item_id, ai.ver_nr, ai.item_nm, ai.item_long_nm, ai.item_desc,
'MODULE' admin_item_typ_nm,
ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, air.disp_ord, air.rep_no
from admin_item ai, nci_admin_item_rel air where ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr and air.rel_typ_id in (61,62);

create or replace view VW_NCI_MODULE_DE as 	select frm.item_long_nm frm_item_long_nm, frm.item_nm frm_item_nm, frm.item_id frm_item_id, frm.ver_nr frm_ver_nr, 
air.p_item_id mod_item_id, air.p_item_ver_nr mod_ver_nr,
 air.c_item_id de_item_id, air.c_item_ver_nr de_ver_nr, air.disp_ord,
aim.item_nm MOD_ITEM_NM,
 aim.item_long_nm  mod_item_long_nm, aim.item_desc mod_item_desc,
'QUESTION' admin_item_typ_nm, air.nci_pub_id,air.nci_ver_nr, 
air.CREAT_DT, air.CREAT_USR_ID, air.LST_UPD_USR_ID, air.FLD_DELETE, air.LST_DEL_DT, air.S2P_TRN_DT, air.LST_UPD_DT, air.item_long_nm QUEST_LONG_TXT, air.item_nm QUEST_TXT
from  nci_admin_item_rel_alt_key air, admin_item aim,
admin_item frm, nci_admin_item_rel frm_mod 
where  air.rel_typ_id = 63
and aim.item_id = air.p_item_id and aim.ver_nr = air.p_item_ver_nr
and frm.item_id = frm_mod.p_item_id and frm.ver_nr = frm_mod.p_item_ver_nr and aim.item_id = frm_mod.c_item_id and aim.ver_nr = frm_mod.c_item_ver_nr
and frm_mod.rel_typ_id in (61,62) 
and frm.admin_item_typ_id in ( 54,55);

create or replace view VW_NCI_USED_BY as select distinct ITEM_ID, VER_NR , CNTXT_ITEM_ID, CNTXT_VER_NR, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DE, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
from (
  SELECT distinct DE.ITEM_ID, DE.VER_NR, a.CNTXT_ITEM_ID, a.CNTXT_VER_NR, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, a.FLD_DELETE, a.LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
       FROM DE, ALT_NMS a, obj_key ok
       WHERE DE.ITEM_ID = a.ITEM_ID and DE.VER_NR = a.VER_NR
       and nvl(a.fld_delete,0) = 0
       and nvl(de.fld_delete,0) = 0
       and a.nm_typ_id = ok.obj_key_id and ok.obj_typ_id =11 and ok.obj_key_desc <> 'USED_BY'
      and a.CNTXT_ITEM_ID is not null
union
  SELECT distinct DE.ITEM_ID, DE.VER_NR, a.NCI_CNTXT_ITEM_ID, a.NCI_CNTXT_VER_NR, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, a.FLD_DELETE, a.LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
       FROM DE, REF a
       WHERE DE.ITEM_ID = a.ITEM_ID and DE.VER_NR = a.VER_NR
       and nvl(a.fld_delete,0) = 0
       and nvl(de.fld_delete,0) = 0
      and a.NCI_CNTXT_ITEM_ID is not null
union
  SELECT distinct DE.C_ITEM_ID, DE.C_ITEM_VER_NR, cs.CNTXT_ITEM_ID, cs.CNTXT_VER_NR, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, cscsi.FLD_DELETE, cscsi.LST_DEL_DT, sysdate S2P_TRN_DT, 
  sysdate LST_UPD_DT
       FROM NCI_ALT_KEY_ADMIN_ITEM_REL de, NCI_ADMIN_ITEM_REL_ALT_KEY cscsi, admin_item cs
       WHERE DE.NCI_PUB_ID = cscsi.NCI_PUB_ID and de.NCI_VER_NR = cscsi.NCI_VER_NR
       and nvl(cscsi.fld_delete,0) = 0
       and nvl(de.fld_delete,0) = 0
       and cscsi.CNTXT_CS_ITEM_ID = cs.item_id and 
       cscsi.CNTXT_CS_VER_NR = cs.ver_nr and
       cs.admin_item_typ_id = 9       and cs.CNTXT_ITEM_ID is not null
);

create or replace view VW_NCI_USR_CART as 	SELECT AI.ITEM_ID, AI.VER_NR, AI.ITEM_LONG_NM, AI.CNTXT_NM_DN, AI.ITEM_NM, AI.REGSTR_STUS_NM_DN, AI.ADMIN_STUS_NM_DN, DECODE(AI.ADMIN_ITEM_TYP_ID, 4, 'Data Element', 54, 'Form') ADMIN_ITEM_TYP_NM,
UC.CNTCT_SECU_ID, UC.CREAT_DT, UC.CREAT_USR_ID, UC.LST_UPD_USR_ID, UC.FLD_DELETE, UC.LST_DEL_DT, UC.S2P_TRN_DT, UC.LST_UPD_DT, UC.GUEST_USR_NM
FROM NCI_USR_CART UC, ADMIN_ITEM AI WHERE AI.ITEM_ID = UC.ITEM_ID AND AI.VER_NR = UC.VER_NR;

create or replace view VW_OBJ_CLS as 	SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC,
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT, 
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT, e.CNCPT_CONCAT, e.CNCPT_CONCAT_NM
FROM ADMIN_ITEM, NCI_ADMIN_ITEM_EXT e
       WHERE ADMIN_ITEM_TYP_ID = 5 and ADMIN_ITEM.ITEM_ID = e.ITEM_ID and ADMIN_ITEM.VER_NR = e.VER_NR;

create or replace view VW_OC_PROP as 	select admin_item.item_id, admin_item.ver_nr, admin_item.item_nm, admin_item.item_long_nm,
admin_item.admin_item_typ_id,
CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT
, CNCPT_AGG.CNCPT_CD, CNCPT_AGG.CNCPT_NM from admin_item, (SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_nm, ';')WITHIN GROUP (ORDER by cai.ITEM_ID) as CNCPT_CD , LISTAGG(ai.item_long_nm, ';') WITHIN GROUP (ORDER by cai.ITEM_ID) AS CNCPT_NM
from cncpt_admin_item cai, admin_item ai where ai.item_id = cai.cncpt_item_id and ai.ver_nr = cai.cncpt_ver_nr
group by cai.item_id, cai.ver_nr) CNCPT_AGG
where admin_item.item_id = cncpt_agg.item_id (+) and admin_item.ver_nr = cncpt_agg.ver_nr (+)
and admin_item.admin_item_typ_id in (5,6);

create or replace view VW_PROP as 	SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT, 
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT, e.CNCPT_CONCAT, e.CNCPT_CONCAT_NM
FROM ADMIN_ITEM, NCI_ADMIN_ITEM_EXT e
       WHERE ADMIN_ITEM_TYP_ID = 6 and ADMIN_ITEM.ITEM_ID = e.ITEM_ID and ADMIN_ITEM.VER_NR = e.VER_NR;

create or replace view VW_REF as 	select REF_ID,
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
REF_NM || ' ' || REF_DESC  REF_SEARCH_STR
from REF;

create or replace view VW_VALUE_DOM as 	SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN,  ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN,  VALUE_DOM.DTTYPE_ID, VALUE_DOM.VAL_DOM_MAX_CHAR, VALUE_DOM.CONC_DOM_VER_NR, VALUE_DOM.CONC_DOM_ITEM_ID, 
VALUE_DOM.NON_ENUM_VAL_DOM_DESC, VALUE_DOM.UOM_ID, VALUE_DOM.VAL_DOM_TYP_ID, VALUE_DOM.VAL_DOM_MIN_CHAR, VALUE_DOM.VAL_DOM_FMT_ID, 
VALUE_DOM.CHAR_SET_ID, VALUE_DOM.CREAT_DT, VALUE_DOM.CREAT_USR_ID, VALUE_DOM.LST_UPD_USR_ID, 
VALUE_DOM.FLD_DELETE, VALUE_DOM.LST_DEL_DT, VALUE_DOM.S2P_TRN_DT, VALUE_DOM.LST_UPD_DT , RC.ITEM_NM  REP_TERM_ITEM_NM
FROM ADMIN_ITEM, VALUE_DOM, VW_REP_CLS RC
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 3
AND ADMIN_ITEM.ITEM_ID = VALUE_DOM.ITEM_ID
AND ADMIN_ITEM.VER_NR=VALUE_DOM.VER_NR and
VALUE_DOM.REP_CLS_ITEM_ID = RC.ITEM_ID (+) and 
VALUE_DOM.REP_CLS_VER_NR = RC.VER_NR (+);

create or replace view VW_VAL_MEAN as 	SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM,  ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT, 
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT, ext.cncpt_concat, ext.cncpt_concat_nm, nvl(admin_item.origin_id_dn, origin) ORIGIN_NM
FROM ADMIN_ITEM, NCI_ADMIN_ITEM_EXT ext
       WHERE ADMIN_ITEM_TYP_ID = 53 and admin_item.item_id = ext.item_id and admin_item.ver_nr = ext.ver_nr;



  CREATE OR REPLACE  VIEW VW_NCI_AI_CURRNT AS
  select "DATA_ID_STR","ITEM_ID","VER_NR","CLSFCTN_SCHM_ID","ITEM_DESC","CNTXT_ITEM_ID",
"CNTXT_VER_NR","ITEM_LONG_NM","ITEM_NM","ADMIN_NOTES","CHNG_DESC_TXT","CREATION_DT","EFF_DT",
"ORIGIN","UNRSLVD_ISSUE","UNTL_DT","CLSFCTN_SCHM_VER_NR","ADMIN_ITEM_TYP_ID","CURRNT_VER_IND",
"ADMIN_STUS_ID","REGSTR_STUS_ID","REGISTRR_CNTCT_ID","SUBMT_CNTCT_ID","STEWRD_CNTCT_ID","SUBMT_ORG_ID","STEWRD_ORG_ID","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID",
"FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","LEGCY_CD","CASE_FILE_ID","REGSTR_AUTH_ID","BTCH_NR","ALT_KEY","ABAC_ATTR","NCI_IDSEQ","ADMIN_STUS_NM_DN","CNTXT_NM_DN","REGSTR_STUS_NM_DN","ORIGIN_ID","ORIGIN_ID_DN","DEF_SRC" from admin_item where ADMIN_ITEM.CURRNT_VER_IND = '1';

alter table nci_csi_alt_defnms drop primary key;

alter table nci_csi_alt_defnms add primary key (NCI_PUB_ID,NCI_VER_NR,NMDEF_ID,TYP_NM);
