create table nci_job_log 
(log_id integer not null primary key, 
 start_dt timestamp default sysdate,
 job_step_desc  varchar2(255) not null,
 run_param varchar2(255),
 end_dt timestamp,
 exec_by varchar2(50),
 "CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate);
 
alter table NCI_STG_CDE_CREAT add (DE_CONC_VER_NR_CREAT number(4,2), VAL_DOM_VER_NR_CREAT number(4,2));
