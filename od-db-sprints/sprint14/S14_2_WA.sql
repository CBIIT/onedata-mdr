

CREATE OR REPLACE TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT ON ADMIN_ITEM for each row
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
if (:new.admin_item_typ_id  in (5,6)) then -- Set the default context
 :new.cntxt_item_id := 20000000024;
:new.cntxt_ver_nr := 1;
end if;
if (:new.ITEM_LONG_NM is null or :new.ITEM_LONG_NM = 'SYSGEN') then
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || trim(to_char(:new.ver_nr, '9999.99'));
end if;
:new.creat_usr_id_x := :new.creat_usr_id;
:new.lst_upd_usr_id_x := :new.lst_upd_usr_id;
if (:new.lst_upd_dt is null) then
:new.lst_upd_dt := sysdate;
end if; 
END ;
/
CREATE OR REPLACE TRIGGER TR_NCI_ALT_NMS
  BEFORE INSERT  on ALT_NMS
  for each row
BEGIN
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
END;
/

create or replace TRIGGER TR_NCI_ALT_DEF
  BEFORE INSERT 
  on ALT_DEF
  for each row
BEGIN
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
END;
/
CREATE OR REPLACE TRIGGER OD_TR_ALT_KEY  BEFORE INSERT  on NCI_ADMIN_ITEM_REL_ALT_KEY
  for each row
         BEGIN    IF (:NEW.NCI_PUB_ID<= 0  or :NEW.NCI_PUB_ID is null)  THEN 
         select od_seq_ADMIN_ITEM.nextval
    into :new.NCI_PUB_ID  from  dual ;   
 :new.nci_idseq := nci_11179.cmr_guid();
END IF; END ;
/
CREATE OR REPLACE TRIGGER OD_TR_QUEST_VV BEFORE INSERT  ON NCI_QUEST_VALID_VALUE
  for each row
BEGIN    IF (:NEW.NCI_PUB_ID<= 0  or :NEW.NCI_PUB_ID is null)  THEN
         select od_seq_ADMIN_ITEM.nextval
    into :new.NCI_PUB_ID  from  dual ;   END IF;
 :new.nci_idseq := nci_11179.cmr_guid();
 END ;
/
