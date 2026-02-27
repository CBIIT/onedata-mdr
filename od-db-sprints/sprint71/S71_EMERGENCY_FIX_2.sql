
drop trigger TR_NCI_ALT_NMS;
drop trigger TR_NCI_ALT_DEF;
drop trigger TR_NCI_PERM_VAL;

CREATE OR REPLACE TRIGGER OD_TR_REF_DOC  BEFORE INSERT  on REF_DOC  for each row
                  BEGIN    IF (:NEW.REF_DOC_ID<= 0  or :NEW.REF_DOC_ID is null)  THEN 
                  select od_seq_REF_DOC.nextval
            into :new.REF_DOC_ID  from  dual ;   END IF; 

end;
/

CREATE OR REPLACE TRIGGER NCI_TR_ENTTY  BEFORE INSERT  on NCI_ENTTY  for each row
     BEGIN    IF (:NEW.ENTTY_ID = -1  or :NEW.ENTTY_ID is null)  THEN select nci_seq_ENTTY.nextval
 into :new.ENTTY_ID  from  dual ;   END IF;
END ;
/
