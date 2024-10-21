

 CREATE SEQUENCE SEQ_CODE_CNFG
          INCREMENT BY 1
          START WITH 1000
         ;

create or replace TRIGGER TR_CODE_CNFG  BEFORE INSERT  on  NCI_MDL_MAP_CNFG for each row
BEGIN    IF (:NEW.CNFG_ID<= 0  or :NEW.CNFG_ID is null)  THEN
         select SEQ_CODE_CNFG.nextval
    into :new.CNFG_ID  from  dual ;   END IF;
    :new.CREATED_BY := :new.CREAT_USR_ID;
    :new.CREATED_DT := :new.CREAT_DT;
    END ;
/


CREATE OR REPLACE TRIGGER TR_NCI_STG_VAL_MAP_SEQ  BEFORE INSERT  on NCI_STG_MEC_VAL_MAP
  for each row
         BEGIN    IF (:NEW.STG_MECVM_ID<= 0  or :NEW.STG_MECVM_ID is null)  THEN
         select NCI_SEQ_MECVM.nextval
    into :new.STG_MECVM_ID  from  dual ;
END IF;

END ;
/
 


CREATE OR REPLACE TRIGGER OD_TR_NCI_STG_MEC_VAL_MAP_UPD 
BEFORE INSERT or UPDATE ON NCI_STG_MEC_VAL_MAP
for each row
BEGIN
  :new.DT_SORT := systimestamp();
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
  :new.lst_upd_dt := sysdate();
END;
/
alter table nci_dload_cstm_col_key add OUTPUT varchar2(16) default 'ROW';
update nci_dload_cstm_col_key set OUTPUT = 'ROW';
update nci_dload_cstm_col_key set xpath = replace(xpath, 'classifications', 'classificationSchemes') where data_object = 'CLASSIFICATION_SCHEME';
update nci_dload_cstm_col_key set xpath = '/dataElements/classificationSchemes/contextName' where col_id = 82;
update nci_dload_cstm_col_key set xpath = '/dataElements/classificationSchemes/shortName' where col_id = 80;
update nci_dload_cstm_col_key set xpath = '/dataElements/classificationSchemes/version' where col_id = 81;
update nci_dload_cstm_col_key set xpath = '/dataElements/classificationSchemes/contextVersion' where col_id = 83;
update nci_dload_cstm_col_key set xpath = '/dataElements/classificationSchemes/classificationSchemeItems/longName' where col_id =84;
update nci_dload_cstm_col_key set xpath = '/dataElements/classificationSchemes/classificationSchemeItems/typeName' where col_id = 85;
update nci_dload_cstm_col_key set xpath = '/dataElements/classificationSchemes/classificationSchemeItems/publicId' where col_id = 86;
update nci_dload_cstm_col_key set xpath = '/dataElements/classificationSchemes/classificationSchemeItems/version' where col_id = 87;
update nci_dload_cstm_col_key set xpath = '/dataElements/classificationSchemes/publicId' where col_id = 120;
update nci_dload_cstm_col_key set data_object = 'CLASSIFICATION_SCHEME' where col_id = 120;
update nci_dload_cstm_col_key set xpath = '/dataElements/contextVersion' where col_id = 7;
update nci_dload_cstm_col_key set xpath = '/dataElements/workflowStatus' where col_id = 9;
update nci_dload_cstm_col_key set xpath = '/dataElements/valueDomain/permissibleValues/valueMeanings/definition' where col_id = 74;
update nci_dload_cstm_col_key set xpath = '/dataElements/valueDomain/permissibleValues/valueMeanings/concepts/shortName' where col_id = 75;
update nci_dload_cstm_col_key set xpath = '/dataElements/valueDomain/permissibleValues/beginDate' where col_id = 76;
update nci_dload_cstm_col_key set xpath = '/dataElements/valueDomain/permissibleValues/endDate' where col_id = 77;
update nci_dload_cstm_col_key set xpath = '/dataElements/valueDomain/permissibleValues/valueMeanings/publicId' where col_id = 78;
update nci_dload_cstm_col_key set xpath = '/dataElements/valueDomain/permissibleValues/valueMeanings/version' where col_id = 79;
update nci_dload_cstm_col_key set col_nm = 'Value Meaning Public ID' where col_id = 78;
update nci_dload_cstm_col_key set xpath = '/dataElements/dataElementConcept/publicId' where col_id = 13;
update nci_dload_cstm_col_key set xpath = '/dataElements/dataElementConcept/version' where col_id = 16;
update nci_dload_cstm_col_key set xpath ='/dataElements/dataElementConcept/longName' where col_id = 15;
update nci_dload_cstm_col_key set xpath ='/dataElements/dataElementConcept/shortName' where col_id = 14;
update nci_dload_cstm_col_key set xpath ='/dataElements/dataElementConcept/contextName' where col_id = 17;
update nci_dload_cstm_col_key set xpath ='/dataElements/dataElementConcept/contextVersion' where col_id = 18;
update nci_dload_cstm_col_key set xpath ='/dataElements/dataElementConcept/workflowStatus' where col_id = 110;
update nci_dload_cstm_col_key set xpath ='/dataElements/dataElementConcept/registrationStatus' where col_id = 111;
update nci_dload_cstm_col_key set xpath ='/dataElements/valueDomain/conceptualDomain/publicId' where col_id = 125;
update nci_dload_cstm_col_key set xpath ='/dataElements/valueDomain/conceptualDomain/version' where col_id = 127;
update nci_dload_cstm_col_key set xpath ='/dataElements/valueDomain/conceptualDomain/shortName' where col_id = 126;
update nci_dload_cstm_col_key set xpath ='/dataElements/valueDomain/conceptualDomain/contextName' where col_id = 128;
--update nci_dload_cstm_col_key set xpath ='/dataElements/valueDomain/conceptualDomain/contextVersion' where col_id = 111;
--update nci_dload_cstm_col_key set xpath ='/dataElements/valueDomain/conceptualDomain/longName' where col_id = 111;
update nci_dload_cstm_col_key set col_nm = 'VD Conceptual Domain Public ID' where col_id = 125;
update nci_dload_cstm_col_key set col_nm = 'VD Conceptual Domain Short Name' where col_id= 126;
update nci_dload_cstm_col_key set col_nm = 'VD Conceptual Domain Version' where col_id = 127;
update nci_dload_cstm_col_key set col_nm = 'VD Conceptual Domain Context Name' where col_id = 128;
update nci_dload_cstm_col_key set OUTPUT = 'ROW';
update nci_dload_cstm_col_key set OUTPUT = 'CELL' where col_id = 75;
update nci_dload_cstm_col_key set xpath = '/dataElements/objectClass/contextName' where col_id = 22;
update nci_dload_cstm_col_key set xpath = '/dataElements/objectClass/version' where col_id = 23;
update nci_dload_cstm_col_key set xpath = replace(xpath, '/dataElements/valueDomain/', '/') where data_object = 'PV';
update nci_dload_cstm_col_key set xpath = replace(xpath, '/dataElements/', '/') where data_object = 'CLASSIFICATION_SCHEME';
commit;
