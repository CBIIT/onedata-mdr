
   CREATE SEQUENCE  OD_SEQ_FORM_IMPORT  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;

create or replace TRIGGER OD_TR_FORM_IMPORT  BEFORE INSERT  on NCI_STG_FORM_IMPORT  for each row
     BEGIN    IF (:NEW.FORM_IMP_ID = -1  or :NEW.FORM_IMP_ID is null)  THEN select od_seq_FORM_IMPORT.nextval
 into :new.FORM_IMP_ID  from  dual ;   END IF;
 END;
/


create or replace TRIGGER TR_FORM_QUEST_IMPORT  BEFORE INSERT  on NCI_STG_FORM_QUEST_IMPORT  for each row
     BEGIN    IF (:NEW.QUEST_IMP_ID = -1  or :NEW.QUEST_IMP_ID is null)  THEN select od_seq_FORM_IMPORT.nextval
 into :new.QUEST_IMP_ID  from  dual ;   END IF;
 END;
/

create or replace TRIGGER OD_TR_FORM_VV_IMPORT  BEFORE INSERT  on NCI_STG_FORM_VV_IMPORT  for each row
     BEGIN    IF (:NEW.VAL_IMP_ID = -1  or :NEW.VAL_IMP_ID is null)  THEN select od_seq_FORM_IMPORT.nextval
 into :new.VAL_IMP_ID  from  dual ;   END IF;
END;
/



-- Form Match
alter table NCI_DS_RSLT_DTL add user_id varchar2(255);
alter table nci_ds_rslt add mtch_typ  varchar2(50);
