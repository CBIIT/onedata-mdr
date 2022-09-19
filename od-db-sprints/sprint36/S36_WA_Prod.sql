CREATE SEQUENCE NCI_SEQ_DATA_AUDT  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1000 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;

CREATE OR REPLACE TRIGGER NCI_TR_DATA_AUDT  BEFORE INSERT  on NCI_DATA_AUDT  for each row
       Begin  select NCI_SEQ_DATA_AUDT.nextval
    into :new.DA_ID  from  dual ;    END ;
    /
    
    -- REverse update for wrong context in ref doc.
 create table tempx as select * from admin_item where admin_item_typ_id = 8;
   
   update sbr.reference_documents d set ( CONTE_IDSEQ)=
    (select  c.nci_idseq
    from ref ad,  tempx c
    where
     ad.nci_cntxt_item_id = c.item_id
    and   ad.nci_cntxt_ver_nr = c.ver_nr
    and   ad.nci_idseq = d.rd_idseq
    and c.admin_item_Typ_id = 8
    and d.conte_idseq <> c.nci_idseq)
    where date_modified > sysdate - 180;
    commit;
    
    
    drop table tempx;

  create table TMP_DATA_AUDT
  (	"OBJ_ID" NUMBER, 
	"CHNGREQ_NR" NUMBER NOT NULL ENABLE, 
	"UPD_COL_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"UPD_COL_OLD_VAL" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"UPD_COL_NEW_VAL" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"TRNS_TYP" CHAR(1 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CNCPTL_OBJ_ID" NUMBER, 
	"CREAT_DT" DATE DEFAULT SYSDATE, 
	"CREAT_USR_ID" VARCHAR2(100 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"AUDT_DESC" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"AUDT_DETL" CLOB COLLATE "USING_NLS_COMP", 
	"PK_REF" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"TBL_NM" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP", 
	"AUDT_CMNTS" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP",
   	ITEM_ID number,
   	VER_NR number(4,2),
   	C_ITEM_ID number,
   	C_ITEM_VER_NR number(4,2),
   	P_ITEM_ID number,
        P_ITEM_VER_NR number(4,2),
        REL_TYP_ID integer);
	

insert into NCI_MDR_CNTRL (ID,PARAM_NM, PARAM_VAL)
values (10, 'DOWNLOAD_HOST', 'https://cadsrapi.cancer.gov');
commit;

alter table admin_item disable all triggers;

update ADMIN_ITEM set ITEM_RPT_URL = (select PARAM_VAL || '/invoke/FormDownload/printerFriendly?item_id=' || item_id ||  chr(38) || 'version=' || ver_nr || '\Click_to_View'
from NCI_MDR_CNTRL where PARAM_NM = 'DOWNLOAD_HOST') where ADMIN_ITEM_TYP_ID = 54;
commit;

alter table admin_item enable all triggers;

CREATE OR REPLACE TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT ON ADMIN_ITEM for each row
declare 
v_item_typ_nm varchar2(100);
v_param_Val varchar2(255);
BEGIN    IF (:NEW.ITEM_ID = -1  or :NEW.ITEM_ID is null)  THEN select od_seq_ADMIN_ITEM.nextval
 into :new.ITEM_ID  from  dual ;   END IF;
 :new.nci_idseq := nci_11179.cmr_guid();
if (:new.admin_item_typ_id  in (4,3,2,1,54) and :new.ver_nr = 1 and :new.admin_stus_id is null) then -- draft new
:new.admin_stus_id := 66;
end if;
--if (:new.admin_item_typ_id  in (4,3,2) and :new.ver_nr = 1 and :new.regstr_stus_id is null) then -- default new reg status Application
--:new.regstr_stus_id := 9; -- not sure if rules are changed
--end if;
 -- Tracker 806
if (:new.regstr_stus_id is null) then -- default new reg status Application
:new.regstr_stus_id := 9; -- not sure if rules are changed
end if;

if (:new.admin_item_typ_id  in (4,3,2,1) and :new.ver_nr > 1) then -- draft mod
:new.admin_stus_id := 65;
end if;
if (:new.admin_item_typ_id  in (5,6,49,53,7)) then -- Released
:new.admin_stus_id := 75;
end if;
if (:new.admin_item_typ_id  in (49) and :new.cntxt_item_id is null) then -- Set the default context for concept if empty
 :new.cntxt_item_id := 20000000024;
 :new.cntxt_ver_nr := 1;
end if;
if (:new.admin_item_typ_id  in (49) and :new.ORIGIN_ID is null) then -- Set the default origin for concept if empty
 :new.ORIGIN_ID := get_origin_id_nci_thesaurus; --NCI Thesaurus DSRMWS-748
end if;
if (:new.admin_item_typ_id = 54) then -- Set Download URL
select param_val into v_param_val from NCI_MDR_CNTRL where PARAM_NM = 'DOWNLOAD_HOST';
:new.ITEM_RPT_URL := v_param_val || '/invoke/FormDownload/printerFriendly?item_id=' || :new.item_id ||  chr(38) || 'version=' || :new.ver_nr || '\Click_to_View';

end if;
if (:new.admin_item_typ_id  in (5,6)) then -- Set the default context
 :new.cntxt_item_id := 20000000024;
:new.cntxt_ver_nr := 1;
end if;
if (:new.ITEM_LONG_NM is null or ((:new.ITEM_LONG_NM = 'SYSGEN' or :new.ITEM_LONG_NM = 'Enter Text or Auto-Generated') and :new.admin_item_typ_id not in (3,4)) or :new.admin_item_typ_id = 53) then
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || trim(to_char(:new.ver_nr, '9999.99'));
end if;

:new.creat_usr_id_x := :new.creat_usr_id;
:new.lst_upd_usr_id_x := :new.lst_upd_usr_id;
-- Tracker 1704 - make it for all AI
--if (:new.admin_item_typ_id = 53) then -- Value Meaning
select obj_key_desc into v_item_typ_nm from obj_key where obj_key_id = :new.admin_item_typ_id;

:new.ITEM_NM_ID_VER :=  :new.item_nm || '|' || :new.ITEM_ID || '|' || :new.ver_nr || '|' || v_item_typ_nm ;

if (:new.lst_upd_dt is null) then
:new.lst_upd_dt := sysdate;
end if;


END ;
/
--Tracker 2106

CREATE OR REPLACE TRIGGER OD_TR_CDE_UPD 
BEFORE UPDATE ON NCI_STG_CDE_CREAT
for each row
BEGIN
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
END;
/
create or replace TRIGGER OD_TR_CDE_CREAT
BEFORE INSERT  on NCI_STG_CDE_CREAT
for each row
BEGIN
IF (:NEW.STG_AI_ID = -1  or :NEW.STG_AI_ID is null)  THEN select od_seq_CDE_IMPORT.nextval
into :new.STG_AI_ID  from  dual ;
END IF;
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
END;
/
CREATE OR REPLACE TRIGGER OD_TR_ALT_NMS_UPD --OD_TR_CDE_UPD 
BEFORE UPDATE ON NCI_STG_ALT_NMS
for each row
BEGIN
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
END;
/
--Tracker 2126, 2117

create or replace TRIGGER OD_TR_DS_HDR  BEFORE INSERT  on  NCI_DS_HDR for each row
         BEGIN    IF (:NEW.HDR_ID<= 0  or :NEW.HDR_ID is null)  THEN 
         select od_seq_DS_HDR.nextval
    into :new.HDR_ID  from  dual ;   END IF; 
      :new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
      END ;
/
CREATE OR REPLACE TRIGGER OD_TR_DS_UPD 
BEFORE UPDATE ON NCI_DS_HDR
for each row
BEGIN
  :new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
END;

/
