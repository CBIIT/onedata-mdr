 CREATE SEQUENCE OD_SEQ_NCI_JOB_LOG
          INCREMENT BY 1
          START WITH 1000;
          
drop sequence od_seq_lang;

 CREATE SEQUENCE od_seq_lang
          INCREMENT BY 1
          START WITH 2000;

CREATE OR REPLACE TRIGGER OD_TR_REF_DOC  BEFORE INSERT  on REF_DOC  for each row
                  BEGIN    IF (:NEW.REF_DOC_ID<= 0  or :NEW.REF_DOC_ID is null)  THEN 
                  select od_seq_REF_DOC.nextval
            into :new.REF_DOC_ID  from  dual ;   END IF; 
  
             IF (:new.nci_idseq is null)  THEN 
                  :new.nci_idseq := nci_11179.cmr_guid();  END IF; 
                  END ;          
/

create or replace TRIGGER TR_AI_MV_REFRESH
  AFTER INSERT ON ADMIN_ITEM
  FOR EACH ROW
  begin
  case :new.admin_item_typ_id
  when 8 then  DBMS_MVIEW.REFRESH('VW_CNTXT');
  when 9 then DBMS_MVIEW.REFRESH('VW_CLSFCTN_SCHM');
  when 51 then DBMS_MVIEW.REFRESH('VW_CLSFCTN_SCHM_ITEM');
  when 49 then DBMS_MVIEW.REFRESH('VW_CNCPT');
  when 1 then DBMS_MVIEW.REFRESH('VW_CONC_DOM');
  end case;
END;
/
