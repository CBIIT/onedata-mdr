CREATE OR REPLACE PROCEDURE SAG_MIGR_VAL_LOV_FULL
AS
    cur      SYS_REFCURSOR;
    curval   VARCHAR2 (500);
BEGIN

    DELETE FROM Sbrext.Sag_Migr_Lov_Err;
    COMMIT;

    cur := SAG_FUNC_MIGR_VAL_REG_ST_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'REGISTRATION_STATUS', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --AC_STATUS

    cur := SAG_FUNC_MIGR_VAL_AC_ST_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'AC_STATUS', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DESIGNATION_TYPE

    cur := SAG_FUNC_MIGR_VAL_DESIG_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DESIGNATION_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DEFINITION_TYPE

    cur := SAG_FUNC_MIGR_VAL_DEFIN_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DESIGNATION_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --ORIGIN

    cur := SAG_FUNC_MIGR_ORIGIN_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'ORIGIN', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DERIVATION_TYPE

    cur := SAG_FUNC_MIGR_DERIV_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DERIVATION_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --concept_sources_lov_ext

    cur := SAG_FUNC_MIGR_CONC_SOURC_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'CONCEPT_SOURCE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --CSI Type

    cur := SAG_FUNC_MIGR_CSI_TYPES_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'CSI_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --CS Type

    cur := SAG_FUNC_MIGR_CS_TYPES_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'CS_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --PA

    cur := SAG_FUNC_MIGR_VAL_PA_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'PA', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DOC_TYPE

    cur := SAG_FUNC_MIGR_VAL_DOC_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DOC_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --QCDL_TYPE

    cur := SAG_FUNC_MIGR_VAL_QCDL_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'QCDL_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --ORG

    cur := SAG_FUNC_MIGR_VAL_ORG_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (SUBSTR (curval, 1, 50), 'ORG', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --FORMAT

    cur := SAG_FUNC_MIGR_FORMAT_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (SUBSTR (curval, 1, 50), 'FORMAT', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --UOM
    cur := SAG_FUNC_MIGR_UOM_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (SUBSTR (curval, 1, 50), 'UOM', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DATA_TYPE

    cur := SAG_FUNC_MIGR_DATA_TP_LOV(); --Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sbrext.Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (SUBSTR (curval, 1, 50), 'DATA_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;
END;
