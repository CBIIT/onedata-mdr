create table nci_mdr_cntrl
(ID  integer not null primary key,
 PARAM_NM varchar2(100) not null,
 PARAM_VAL varchar2(100) not null);

create table nci_mdr_debug (
ID date default sysdate primary key,
DATA_CLOB CLOB,
PARAM_VAL  varchar2(100));
		    
		    
create table cs_csi_copy as
select *  from sbrext.cs_csi;

create table cs_items_copy as
select *  from cs_items;

CREATE TABLE TEMP_IMPORT 
   (	ITEM_ID NUMBER NOT NULL ENABLE, 
	VER_NR NUMBER(4,2) NOT NULL ENABLE,
    	QC_ID number default 1,
	"PREFERRED_DEFINITION" VARCHAR2(2000 BYTE) ,
	REP_NO INTEGER,
    primary key (ITEM_ID, VER_NR, QC_ID));
    


CREATE OR REPLACE TRIGGER TR_NCI_QUEST_VV_AUD_TS
  BEFORE  UPDATE
  on NCI_QUEST_VALID_VALUE
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


CREATE OR REPLACE TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT ON ADMIN_ITEM for each row
BEGIN    IF (:NEW.ITEM_ID = -1  or :NEW.ITEM_ID is null)  THEN select od_seq_ADMIN_ITEM.nextval
 into :new.ITEM_ID  from  dual ;   END IF;
if (:new.nci_idseq is null) then 
 :new.nci_idseq := nci_11179.cmr_guid();
end if; 
if (:new.admin_item_typ_id  in (4,3,2,1,54) and :new.ver_nr = 1 and :new.admin_stus_id is null) then -- draft new
:new.admin_stus_id := 66;
end if;
if (:new.admin_item_typ_id  in (4,3,2) and :new.ver_nr = 1 and :new.regstr_stus_id is null) then -- default new reg status Application
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
if (:new.admin_item_typ_id  in (5,6)) then -- Set the default context
 :new.cntxt_item_id := 20000000024;
:new.cntxt_ver_nr := 1;
end if;
if (:new.ITEM_LONG_NM is null) then
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || to_char(:new.ver_nr,'99.99');
end if;
:new.creat_usr_id_x := :new.creat_usr_id;
:new.lst_upd_usr_id_x := :new.lst_upd_usr_id;
if (:new.lst_upd_dt is null) then
:new.lst_upd_dt := sysdate;
end if; 
END ;
/

