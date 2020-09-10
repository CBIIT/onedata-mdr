create or replace procedure sp_insert_all 
as
v_cnt integer;
begin


insert into obj_typ select * from onedata_wa.obj_typ;
commit;

insert into obj_key select * from onedata_wa.obj_key;
commit;

insert into NCI_ENTTY select * from onedata_wa.nci_entty;
commit;
insert into NCI_org select * from onedata_wa.nci_org;
commit;
insert into NCI_prsn select * from onedata_wa.nci_prsn;
commit;
insert into NCI_ENTTY_addr select * from onedata_wa.nci_entty_addr;
commit;
insert into NCI_ENTTY_comm select * from onedata_wa.nci_entty_comm;
commit;
insert into admin_item select * from onedata_wa.admin_item;
commit;
insert into cntxt select * from onedata_wa.cntxt;
commit;
insert into alt_nms select * from onedata_wa.alt_nms;
commit;
insert into alt_def select * from onedata_wa.alt_def;
commit;
insert into ref select * from onedata_wa.ref
commit;
insert into cncpt select * from onedata_wa.cncpt;
commit;
insert into prop select * from onedata_wa.prop;
commit;
insert into obj_cls select * from onedata_wa.obj_cls;
commit;
insert into rep_cls select * from onedata_wa.rep_cls;
commit;
insert into clsfctn_schm select * from onedata_wa.clsfctn_schm;
commit;
insert into conc_dom select * from onedata_wa.conc_dom;
commit;
insert into value_dom select * from onedata_wa.value_dom;
commit;
insert into nci_form select * from onedata_wa.nci_form;
commit;
insert into de_conc select * from onedata_wa.de_conc;
commit;
insert into de select * from onedata_wa.de;
commit;

insert into perm_val select * from onedata_wa.perm_val;
commit;
insert into conc_dom_val_mean select * from onedata_wa.conc_dom_val_mean;
commit;
insert into cncpt_admin_item select * from onedata_wa.cncpt_admin_item;
commit;




insert into NCI_CLSFCTN_SCHM_ITEM select * from onedata_wa.NCI_CLSFCTN_SCHM_ITEM;
commit;
insert into NCI_OC_RECS select * from onedata_wa.NCI_OC_RECS;
commit;
insert into NCI_PROTCL select * from onedata_wa.NCI_PROTCL;
commit;
insert into NCI_VAL_MEAN select * from onedata_wa.NCI_VAL_MEAN;
commit;

insert into NCI_ADMIN_ITEM_REL select * from onedata_wa.NCI_ADMIN_ITEM_REL;
commit;

insert into NCI_ADMIN_ITEM_EXT select * from onedata_wa.NCI_ADMIN_ITEM_EXT;
commit;

insert into NCI_ADMIN_ITEM_REL_ALT_KEY select * from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY;
commit;
insert into NCI_QUEST_VALID_VALUE select * from onedata_wa.NCI_QUEST_VALID_VALUE;
commit;
insert into NCI_ALT_KEY_ADMIN_ITEM_REL select * from onedata_wa.NCI_ALT_KEY_ADMIN_ITEM_REL;
commit;

insert into NCI_CSI_ALT_DEFNMS select * from onedata_wa.NCI_CSI_ALT_DEFNMS;


insert into NCI_FORM_TA select * from onedata_wa.NCI_FORM_TA;
commit;
insert into NCI_INSTR select * from onedata_wa.NCI_INSTR;
commit;
insert into NCI_QUEST_VV_REP select * from onedata_wa.NCI_QUEST_VV_REP;
commit;
insert into NCI_FORM_TA_REL select * from onedata_wa.NCI_FORM_TA_REL;
commit;
insert into  NCI_AI_TYP_VALID_STUS select * from onedata_wa. NCI_AI_TYP_VALID_STUS;
commit;


end;
/

drop table admin_item;

  CREATE TABLE ADMIN_ITEM 
   (	"DATA_ID_STR" VARCHAR2(15 BYTE), 
	"ITEM_ID" NUMBER NOT NULL ENABLE, 
	"VER_NR" NUMBER(4,2) DEFAULT 1 NOT NULL ENABLE, 
	"CLSFCTN_SCHM_ID" NUMBER, 
	"ITEM_DESC" VARCHAR2(4000 BYTE), 
	"CNTXT_ITEM_ID" NUMBER, 
	"CNTXT_VER_NR" NUMBER(4,2) DEFAULT 1, 
	"ITEM_LONG_NM" VARCHAR2(255 BYTE), 
	"ITEM_NM" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"ADMIN_NOTES" VARCHAR2(4000 BYTE), 
	"CHNG_DESC_TXT" VARCHAR2(2000 BYTE), 
	"CREATION_DT" DATE DEFAULT sysdate, 
	"EFF_DT" DATE, 
	"ORIGIN" VARCHAR2(500 BYTE), 
	"UNRSLVD_ISSUE" VARCHAR2(1000 BYTE), 
	"UNTL_DT" DATE, 
	"CLSFCTN_SCHM_VER_NR" NUMBER(4,1), 
	"ADMIN_ITEM_TYP_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"CURRNT_VER_IND" NUMBER(1,0) DEFAULT 1 NOT NULL ENABLE, 
	"ADMIN_STUS_ID" NUMBER(38,0) DEFAULT NULL, 
	"REGSTR_STUS_ID" NUMBER(*,0), 
	"REGISTRR_CNTCT_ID" NUMBER, 
	"SUBMT_CNTCT_ID" NUMBER, 
	"STEWRD_CNTCT_ID" NUMBER, 
	"SUBMT_ORG_ID" NUMBER, 
	"STEWRD_ORG_ID" NUMBER, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"LEGCY_CD" VARCHAR2(50 BYTE), 
	"CASE_FILE_ID" NUMBER(*,0), 
	"REGSTR_AUTH_ID" NUMBER, 
	"BTCH_NR" NUMBER(*,0), 
	"ALT_KEY" VARCHAR2(20 BYTE), 
	"ABAC_ATTR" NUMBER(*,0), 
	"NCI_IDSEQ" CHAR(36 BYTE), 
	"ADMIN_STUS_NM_DN" VARCHAR2(50 BYTE), 
	"CNTXT_NM_DN" VARCHAR2(175 BYTE), 
	"REGSTR_STUS_NM_DN" VARCHAR2(50 BYTE), 
	"ORIGIN_ID" NUMBER, 
	"ORIGIN_ID_DN" VARCHAR2(500 BYTE), 
	"DEF_SRC" VARCHAR2(2000 BYTE), 
	"CREAT_USR_ID_X" VARCHAR2(50 BYTE), 
	"LST_UPD_USR_ID_X" VARCHAR2(50 BYTE), 
	 CONSTRAINT "XPKADMIN_ITEM" PRIMARY KEY ("ITEM_ID", "VER_NR")
 
   ) ;

  CREATE OR REPLACE EDITIONABLE TRIGGER TR_S2P_ADMIN_ITEM
BEFORE  UPDATE OR INSERT ON ADMIN_ITEM FOR EACH ROW 
BEGIN :new.S2P_TRN_DT := SYSDATE ; END;

/

  CREATE OR REPLACE EDITIONABLE TRIGGER TR_AI_EXT_TAB_INS
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
