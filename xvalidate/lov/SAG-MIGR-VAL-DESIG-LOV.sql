CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_VAL_DESIG_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT DETL_NAME FROM 
    (SELECT DETL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM SBR.designation_types_lov
              UNION ALL
              SELECT OBJ_KEY_DESC DETL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=11) t
      GROUP BY DETL_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY DETL_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_VAL_DESIG_LOV to SBREXT;