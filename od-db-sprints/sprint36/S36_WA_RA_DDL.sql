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
  
  
  CREATE OR REPLACE  VIEW VW_NCI_DATA_AUDT
  AS
  select "DA_ID","ITEM_ID","VER_NR","ADMIN_ITEM_TYP_ID",decode(ACTION_TYP, 'I', 'Insert','U', 'Update','D', 'Delete') ACTION_TYP,
  "LVL","LVL_PK","ATTR_NM","FROM_VAL","TO_VAL","CREAT_USR_ID_AUDT",
  "LST_UPD_USR_ID_AUDT","CREAT_DT_AUDT","LST_UPD_DT_AUDT","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","AUDT_CMNTS" from NCI_DATA_AUDT;

