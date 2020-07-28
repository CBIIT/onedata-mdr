 CREATE SEQUENCE NCI_SEQ_ENTTY
          INCREMENT BY 1
          START WITH 1000
         ;

CREATE OR REPLACE TRIGGER NCI_TR_ENTTY  BEFORE INSERT  on NCI_ENTTY  for each row
     BEGIN    IF (:NEW.ENTTY_ID = -1  or :NEW.ENTTY_ID is null)  THEN select nci_seq_ENTTY.nextval
 into :new.ENTTY_ID  from  dual ;   END IF;
if (:new.nci_idseq is null) then 
 :new.nci_idseq := nci_11179.cmr_guid();
end if; END ;
/

CREATE OR REPLACE TRIGGER NCI_TR_ENTTY_ORG  BEFORE INSERT  on NCI_ORG  for each row
     BEGIN    IF (:NEW.ENTTY_ID = -1  or :NEW.ENTTY_ID is null)  THEN select nci_seq_ENTTY.nextval
 into :new.ENTTY_ID  from  dual ;   END IF;
insert into nci_entty(entty_id, entty_typ_id) values (:new.entty_id, 72);
end;
/


CREATE OR REPLACE TRIGGER NCI_TR_ENTTY_PRSN  BEFORE INSERT  on NCI_PRSN  for each row
     BEGIN    IF (:NEW.ENTTY_ID = -1  or :NEW.ENTTY_ID is null)  THEN select nci_seq_ENTTY.nextval
 into :new.ENTTY_ID  from  dual ;   END IF;
insert into nci_entty(entty_id, entty_typ_id) values (:new.entty_id, 73);
end;
/


create trigger TR_NCI_AI_TYP_VALID_STUS_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_AI_TYP_VALID_STUS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/






create trigger TR_NCI_ENTTY_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_ENTTY
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create trigger TR_NCI_ENTTY_COMM_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_ENTTY_COMM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create trigger TR_NCI_ENTTY_ADDR_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_ENTTY_ADDR
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create trigger TR_NCI_ORG_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_ORG
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create trigger TR_NCI_PRSN_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_PRSN
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/
