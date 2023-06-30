create table NCI_MDL
(ITEM_ID number not null,
  VER_NR number(4,2) not null,
  PRMRY_MDL_LANG_ID  integer null,
  CREAT_DT DATE  DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate, 
primary key (ITEM_ID, ver_NR));

create table NCI_MDL_ELMNT
( ITEM_ID number not null,
  VER_NR number (4,2) not null,
  MDL_ITEM_ID  number not null,
  MDL_ITEM_VER_NR number(4,2) not null,
  ITEM_LONG_NM varchar2(255) not null,
  ITEM_PHY_OBJ_NM varchar2(255) null,
  CREAT_DT DATE  DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate, 
  primary key (ITEM_ID, VER_NR));

create table NCI_MDL_ELMNT_REL
( REL_ID number not null primary key, 
  PRNT_ITEM_ID number not null,
  PRNT_ITEM_VER_NR number (4,2) not null,
  CHLD_ITEM_ID number not null,
  CHLD_ITEM_VER_NR number (4,2) not null,
  REL_TYP_ID integer not null,
   CREAT_DT DATE  DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate);

create table NCI_MDL_ELMNT_CHAR
( MEC_ID number not null primary key,
  MDL_ELMNT_ITEM_ID number not null,
  MDL_ELMNT_VER_NR number (4,2) not null,
  MEC_TYP_ID integer not null,
   CREAT_DT DATE  DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate)
  ;

insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (57,'Model',4,'Model','Model','Model' );
commit;




