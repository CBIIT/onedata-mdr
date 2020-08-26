set serveroutput on SIZE 1000000
spool SAG_MIGR_VAL_LOV.log
--REGISTRATION_STATUS
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation REGISTRATION_STATUS ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'REGISTRATION_STATUS';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_VAL_REG_ST_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
        Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
        Values(curval,'REGISTRATION_STATUS','Migration error');
      COMMIT;
      dbms_output.put_line('REGISTRATION_STATUS Error on Value: '||curval);
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation REGISTRATION_STATUS ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'REGISTRATION_STATUS';

--AC_STATUS
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation AC_STATUS ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'AC_STATUS';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_VAL_AC_ST_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
        Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
        Values(curval,'AC_STATUS','Migration error');
      COMMIT;
      dbms_output.put_line('AC_STATUS Error on Value: '||curval);
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation AC_STATUS ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'AC_STATUS';

--DESIGNATION_TYPE
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation DESIGNATION_TYPE ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'DESIGNATION_TYPE';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_VAL_DESIG_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
        Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
        Values(curval,'DESIGNATION_TYPE','Migration error');
      COMMIT;
      dbms_output.put_line('DESIGNATION_TYPE Error on Value: '||curval);
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation DESIGNATION_TYPE ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'DESIGNATION_TYPE';

--DEFINITION_TYPE
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation DEFINITION_TYPE ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'DEFINITION_TYPE';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_VAL_DEFIN_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
        Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
        Values(curval,'DESIGNATION_TYPE','Migration error');
      COMMIT;
      dbms_output.put_line('DESIGNATION_TYPES Error on Value: '||curval);
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation DEFINITION_TYPE ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'DEFINITION_TYPE';

--ORIGIN
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation ORIGIN ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'ORIGIN';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_ORIGIN_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
        Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
        Values(curval,'ORIGIN','Migration error');
      COMMIT;
      dbms_output.put_line('ORIGIN Error on Value: '||curval);
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation ORIGIN ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'ORIGIN';

--DERIVATION_TYPE
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation DERIVATION_TYPE ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'DERIVATION_TYPE';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_DERIV_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
        Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
        Values(curval,'DERIVATION_TYPE','Migration error');
      COMMIT;
      dbms_output.put_line('DERIVATION_TYPE Error on Value: '||curval);
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation DERIVATION_TYPE ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'DERIVATION_TYPE';

--concept_sources_lov_ext
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation CONCEPT_SOURCE ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'CONCEPT_SOURCE';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_CONC_SOURC_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
      dbms_output.put_line('CONCEPT_SOURCE Error on Value: '||curval);
        Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
        Values(curval,'CONCEPT_SOURCE','Migration error');
      COMMIT;
      --dbms_output.put_line('CONCEPT_SOURCE Error on Value: '||curval);
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation CONCEPT_SOURCE ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'CONCEPT_SOURCE';

--CSI Type
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation CSI_TYPE ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'CSI_TYPE';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_CSI_TYPES_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
      dbms_output.put_line('CSI Type Error on Value: '||curval);
      Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
      Values(curval,'CSI_TYPE','Migration error');
      COMMIT;
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation CSI_TYPE ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'CSI_TYPE';

--CS Type
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation CS_TYPE ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'CS_TYPE';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_CS_TYPES_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
      dbms_output.put_line('CS Type Error on Value: '||curval);
      Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
      Values(curval,'CS_TYPE','Migration error');
      COMMIT;
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation CS_TYPE ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'CS_TYPE';

--PA
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation PA ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'PA';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_VAL_PA_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
      dbms_output.put_line('PA Error on Value: '||curval);
      Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
      Values(curval,'PA','Migration error');
      COMMIT;
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation PA ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'PA';

--DOC_TYPE
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation DOC_TYPE ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'DOC_TYPE';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_VAL_DOC_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
      dbms_output.put_line('DOC_TYPE Error on Value: '||curval);
      Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
      Values(curval,'DOC_TYPE','Migration error');
      COMMIT;
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation DOC_TYPE ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'DOC_TYPE';

--QCDL_TYPE
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(50);
BEGIN
  dbms_output.put_line('----LoV Migration Validation QCDL_TYPE ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'QCDL_TYPE';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_VAL_QCDL_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
      dbms_output.put_line('QCDL_TYPE Error on Value: '||curval);
      Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
      Values(curval,'QCDL_TYPE','Migration error');
      COMMIT;
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation QCDL_TYPE ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'QCDL_TYPE';

--ORG
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(80);
BEGIN
  dbms_output.put_line('----LoV Migration Validation ORG ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'ORG';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_VAL_ORG_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
      dbms_output.put_line('ORG Error on Value: '||curval);
      Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
      Values(substr(curval, 1, 50),'ORG','Migration error');
      COMMIT;
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation ORG ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'ORG';

--FORMAT
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(80);
BEGIN
  dbms_output.put_line('----LoV Migration Validation FORMAT ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'FORMAT';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_FORMAT_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
      dbms_output.put_line('FORMAT Error on Value: '||curval);
      Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
      Values(substr(curval, 1, 50),'FORMAT','Migration error');
      COMMIT;
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation FORMAT ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'FORMAT';

--UOM
DECLARE
 cur SYS_REFCURSOR;
 curval VARCHAR2(80);
BEGIN
  dbms_output.put_line('----LoV Migration Validation UOM ----');
  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'UOM';
  Commit;
 cur := ONEDATA_WA.SAG_FUNC_MIGR_UOM_LOV();   -- Get ref cursor from function
 LOOP 
   FETCH cur into curval;
   EXIT WHEN cur%NOTFOUND;
      dbms_output.put_line('UOM Error on Value: '||curval);
      Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
      Values(substr(curval, 1, 50),'UOM','Migration error');
      COMMIT;
 END LOOP;
 CLOSE cur;
 dbms_output.put_line('----Finished LoV Migration Validation UOM ----');
END;
/
SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'UOM';

--DATA_TYPE
--DECLARE
-- cur SYS_REFCURSOR;
-- curval VARCHAR2(80);
--BEGIN
--  dbms_output.put_line('----LoV Migration Validation DATA_TYPE ----');
--  Delete From Sbrext.Sag_Migr_Lov_Err Where Lov_Name = 'DATA_TYPE';
--  Commit;
-- cur := ONEDATA_WA.SAG_FUNC_MIGR_DATA_TP_LOV();   -- Get ref cursor from function
-- LOOP 
--   FETCH cur into curval;
--   EXIT WHEN cur%NOTFOUND;
--     dbms_output.put_line('DATA_TYPE Error on Value: '||curval);
--      Insert Into Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, Error_Text)
--      Values(substr(curval, 1, 50),'DATA_TYPE','Migration error');
--      COMMIT;
-- END LOOP;
-- CLOSE cur;
-- dbms_output.put_line('----Finished LoV Migration Validation DATA_TYPE ----');
--END;
--/

--SELECT * FROM SBREXT.Sag_Migr_Lov_Err WHERE Lov_Name = 'DATA_TYPE';

spool off;

