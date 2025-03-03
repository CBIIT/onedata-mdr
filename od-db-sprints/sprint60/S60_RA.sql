drop table nci_dload_cstm_col_key;

  CREATE TABLE NCI_DLOAD_CSTM_COL_KEY 
   (	"COL_ID" NUMBER NOT NULL ENABLE, 
	"COL_NM" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"COL_DEF" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"DLOAD_TYP" VARCHAR2(32 BYTE) COLLATE "USING_NLS_COMP", 
	"XPATH" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"COL_HDR" VARCHAR2(128 BYTE) COLLATE "USING_NLS_COMP", 
	"DATA_OBJECT" VARCHAR2(100 BYTE) COLLATE "USING_NLS_COMP", 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"IS_VISIBLE" NUMBER, 
	 PRIMARY KEY ("COL_ID")
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

alter table nci_dload_cstm_col_key add OUTPUT varchar2(16) default 'ROW';
insert into nci_dload_cstm_col_key select * from onedata_wa.nci_dload_cstm_col_key;
commit;


  CREATE TABLE NCI_DLOAD_CSTM_DATA_COLL
   (	"HDR_ID" NUMBER, 
	"COL_ID" NUMBER,  
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	 PRIMARY KEY ("HDR_ID"));
