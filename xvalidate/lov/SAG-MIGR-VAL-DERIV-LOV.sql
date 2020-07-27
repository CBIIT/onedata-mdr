CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_DERIV_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT CRTL_NAME FROM 
    (SELECT CRTL_NAME,
                             DESCRIPTION,
                             CREATED_BY,
                             DATE_CREATED,
                             Nvl (DATE_MODIFIED, DATE_CREATED) DATE_MODIFIED,
                             MODIFIED_BY
                        FROM SBR.complex_rep_type_lov
              UNION ALL
              SELECT OBJ_KEY_DESC CRTL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             Nvl (LST_UPD_DT, CREAT_DT) DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=21) t
      GROUP BY CRTL_NAME,
                     DESCRIPTION,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY CRTL_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_DERIV_LOV to SBREXT;