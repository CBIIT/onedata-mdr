

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

