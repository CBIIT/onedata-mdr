 CREATE SEQUENCE OD_SEQ_IMPORT
          INCREMENT BY 1
          START WITH 1000
         ;

-- Tracker 870
 CREATE OR REPLACE TRIGGER OD_TR_AI_CNCPT_CREAT  BEFORE INSERT  on NCI_STG_AI_CNCPT_CREAT  for each row
     BEGIN    IF (:NEW.STG_AI_ID = -1  or :NEW.STG_AI_ID is null)  THEN select od_seq_IMPORT.nextval
 into :new.STG_AI_ID  from  dual ;   END IF;
 END;
/

CREATE OR REPLACE TRIGGER TR_AI_AUD_TS
  BEFORE UPDATE ON ADMIN_ITEM
  REFERENCING FOR EACH ROW
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  :new.LST_UPD_USR_ID_X := :new.LST_UPD_USR_ID;

if (upper(:new.ITEM_LONG_NM) = 'SYSGEN') then 
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || trim(to_char(:new.ver_nr, '9999.99'));
end if;
END TR_AI_AUD_TS;
/

create or replace TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT ON ADMIN_ITEM for each row
BEGIN    IF (:NEW.ITEM_ID = -1  or :NEW.ITEM_ID is null)  THEN select od_seq_ADMIN_ITEM.nextval
 into :new.ITEM_ID  from  dual ;   END IF;
if (:new.nci_idseq is null) then 
 :new.nci_idseq := nci_11179.cmr_guid();
end if; 
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
if (:new.admin_item_typ_id  in (5,6)) then -- Set the default context
 :new.cntxt_item_id := 20000000024;
:new.cntxt_ver_nr := 1;
end if;
if (:new.ITEM_LONG_NM is null) then
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || trim(to_char(:new.ver_nr, '9999.99'));
end if;
:new.creat_usr_id_x := :new.creat_usr_id;
:new.lst_upd_usr_id_x := :new.lst_upd_usr_id;
if (:new.lst_upd_dt is null) then
:new.lst_upd_dt := sysdate;
end if; 
END ;
/

CREATE SEQUENCE OD_SEQ_DS_HDR
          INCREMENT BY 1
          START WITH 1000
         ;
         
    CREATE OR REPLACE TRIGGER OD_TR_DS_HDR  BEFORE INSERT  on  NCI_DS_HDR for each row
         BEGIN    IF (:NEW.HDR_ID<= 0  or :NEW.HDR_ID is null)  THEN 
         select od_seq_DS_HDR.nextval
    into :new.HDR_ID  from  dual ;   END IF; END ;
/
