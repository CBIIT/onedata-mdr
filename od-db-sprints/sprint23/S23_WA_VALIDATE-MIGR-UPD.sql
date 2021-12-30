create or replace FUNCTION SAG_FUNC_MIGR_VAL_DESIG_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT DETL_NAME FROM 
    (SELECT DETL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             -- NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             -- Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM SBR.designation_types_lov
              UNION ALL
              SELECT OBJ_KEY_DESC DETL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             -- CREAT_DT DATE_CREATED,
                             -- LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM OBJ_KEY where OBJ_TYP_ID=11) t
      GROUP BY DETL_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     -- DATE_CREATED,
                     -- DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY DETL_NAME;
  RETURN c;
END;
/
create or replace FUNCTION SAG_FUNC_MIGR_VAL_DEFIN_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT DEFL_NAME FROM 
    (SELECT DEFL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             -- NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             -- Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM SBREXT.definition_types_lov_ext
              UNION ALL
              SELECT OBJ_KEY_DESC DEFL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             -- CREAT_DT DATE_CREATED,
                             -- LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM OBJ_KEY where OBJ_TYP_ID=15) t
      GROUP BY DEFL_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     -- DATE_CREATED,
                     -- DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY DEFL_NAME;
  RETURN c;
END;
/
create or replace PROCEDURE            SAG_MIGR_VAL_LOV_FULL
AS
    cur      SYS_REFCURSOR;
    curval   VARCHAR2 (500);
BEGIN

    DELETE FROM Sag_Migr_Lov_Err;
    COMMIT;

    cur := SAG_FUNC_MIGR_VAL_REG_ST_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'REGISTRATION_STATUS', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --AC_STATUS

    cur := SAG_FUNC_MIGR_VAL_AC_ST_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'AC_STATUS', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DESIGNATION_TYPE

    cur := SAG_FUNC_MIGR_VAL_DESIG_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DESIGNATION_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DEFINITION_TYPE

    cur := SAG_FUNC_MIGR_VAL_DEFIN_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DEFINITION_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --ORIGIN

    cur := SAG_FUNC_MIGR_ORIGIN_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'ORIGIN', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DERIVATION_TYPE

    cur := SAG_FUNC_MIGR_DERIV_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DERIVATION_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --concept_sources_lov_ext

    cur := SAG_FUNC_MIGR_CONC_SOURC_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'CONCEPT_SOURCE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --CSI Type

    cur := SAG_FUNC_MIGR_CSI_TYPES_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'CSI_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --CS Type

    cur := SAG_FUNC_MIGR_CS_TYPES_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'CS_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --PA

    cur := SAG_FUNC_MIGR_VAL_PA_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'PA', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DOC_TYPE

    cur := SAG_FUNC_MIGR_VAL_DOC_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DOC_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --QCDL_TYPE

    cur := SAG_FUNC_MIGR_VAL_QCDL_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'QCDL_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --ORG

    cur := SAG_FUNC_MIGR_VAL_ORG_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'ORG', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --FORMAT

    cur := SAG_FUNC_MIGR_FORMAT_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'FORMAT', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --UOM
    cur := SAG_FUNC_MIGR_UOM_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'UOM', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DATA_TYPE

    cur := SAG_FUNC_MIGR_DATA_TP_LOV(); --Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DATA_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;
END;
/