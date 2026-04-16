grant read on nci_ds_prmtr to onedata_ra;

create  TRIGGER TR_NCI_dS_CNTXT_SEL
  BEFORE UPDATE or INSERT ON NCI_DS_CNTXT_SEL
  FOR EACH ROW
  declare 
v_temp varchar2(255);
  BEGIN
  if :new.CNTXT_NM_DN is null then
  select cntxt_nm_dn into v_temp from vw_cntxt_ds where cntxt_id_ver = :new.cntxt_Id_ver;
  :new.cntxt_nm_dn := v_temp;
  end if;
  

END;
/

  CREATE OR REPLACE EDITIONABLE TRIGGER TR_DS_PRMTR_TEMP_ID_INS
BEFORE INSERT ON NCI_DS_PRMTR_TEMP
FOR EACH ROW
BEGIN
    IF (:NEW.PRMTR_ID<= 0  or :NEW.PRMTR_ID is null)  THEN 

        SELECT SEQ_DS_PRMTR_ID.NEXTVAL
        INTO :new.PRMTR_ID
        FROM dual;
    END IF;
END;
/
