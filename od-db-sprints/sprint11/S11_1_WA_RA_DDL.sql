drop table nci_dload_hdr;

create table nci_dload_hdr
( hdr_id number,
dload_typ_id integer not null,
dload_fmt_id integer not null,
dload_hdr_nm varchar2(255),
dload_status varchar2(30) default 'CREATED',
 CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
       CREATED_DT           DATE DEFAULT sysdate null,
       CREATED_BY           varchar2(50) null,
       LST_TRIGGER_DT       DATE DEFAULT sysdate null,
       FILE_NM VARCHAR2(350), 
       FILE_BLOB  BLOB,		
primary key (hdr_id));


create table nci_dload_als
( hdr_id number,
als_form_nm  varchar2(255),
als_prot_nm  varchar2(255),
PV_VM_IND  number,
 CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
primary key (hdr_id));

create table nci_dload_dtl
(hdr_id number ,
item_id number,
ver_nr number(4,2),
 CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NULL,
primary key (hdr_id, item_id,ver_nr));

alter table NCI_STG_AI_CNCPT_CREAT
add (DTTYPE_ID NUMBER, 
	VAL_DOM_MAX_CHAR number, 
	VAL_DOM_TYP_ID NUMBER, 
	UOM_ID NUMBER, 
	VD_CONC_DOM_VER_NR NUMBER(4,2)  , 
	VD_CONC_DOM_ITEM_ID NUMBER, 
	REP_CLS_VER_NR NUMBER(4,2), 
	REP_CLS_ITEM_ID NUMBER, 
	VAL_DOM_MIN_CHAR NUMBER, 
	VAL_DOM_FMT_ID NUMBER, 
	CHAR_SET_ID NUMBER, 
	VAL_DOM_HIGH_VAL_NUM VARCHAR2(50), 
	VAL_DOM_LOW_VAL_NUM VARCHAR2(50), 
	NCI_DEC_PREC NUMBER(2,0),
	PERM_VAL_NM  varchar2(255),
	PV_1  varchar2(255),
	PV_2  varchar2(255),
	PV_3	varchar2(255),
	PV_4	varchar2(255),
	PV_5	varchar2(255),
	PV_6	varchar2(255),
	PV_7	varchar2(255),
	PV_8	varchar2(255),
	PV_9	varchar2(255),
	PV_10	varchar2(255));



--

Inserts


insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (31, 'Download Format');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (32, 'Download Component Type');
commit;

insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (90,31,'ALS', 'ALS', '', 'ALS');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (91,31,'Other', 'Other', '', 'Other');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (92,32,'Form', 'Form', '', 'Form');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (93,32,'CDE', 'CDE', '', 'CDE');
commit;
