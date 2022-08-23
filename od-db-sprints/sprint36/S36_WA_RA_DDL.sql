-- Data Audit table

create table NCI_DATA_AUDT 
( DA_ID number not null primary key,
ITEM_ID number not null,
  VER_NR number not null,
  ADMIN_ITEM_TYP_ID int  null,
  ACTION_TYP  char(1) not null,
  LVL varchar2(100) not null,
  LVL_PK  varchar2(255) null,
  ATTR_NM  varchar2(255) null,
  FROM_VAL  varchar2(4000) null,
  TO_VAL varchar2(4000) null,
  CREAT_USR_ID_AUDT varchar2(255) null,
  LST_UPD_USR_ID_AUDT varchar2(255) null,
  CREAT_DT_AUDT date null,
  LST_UPD_DT_AUDT date null,
 AUDT_CMNTS varchar2(4000) null,
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE)  DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE)  DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate);
  
  
  
