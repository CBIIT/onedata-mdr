create or replace FUNCTION SAG_FUNC_MIGR_VAL_QCDL_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT QCDL_NAME FROM 
    (SELECT QCDL_NAME,
                             DESCRIPTION,
                             --DISPLAY_ORDER,
                             CREATED_BY,
                             DATE_CREATED,
                             Nvl (DATE_MODIFIED, DATE_CREATED) DATE_MODIFIED,
                             MODIFIED_BY
                        FROM SBREXT.QC_DISPLAY_LOV_EXT
              UNION ALL
              SELECT OBJ_KEY_DESC QCDL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             --where is DISPLAY_ORDER,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             Nvl (LST_UPD_DT, CREAT_DT) DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=22) t
      GROUP BY QCDL_NAME,
                     DESCRIPTION,
                     --DISPLAY_ORDER,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY QCDL_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_VAL_QCDL_LOV to SBREXT;