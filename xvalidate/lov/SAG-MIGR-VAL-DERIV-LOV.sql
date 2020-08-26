CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_DERIV_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT CRTL_NAME FROM 
    (SELECT CRTL_NAME,
                             DESCRIPTION,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM SBR.complex_rep_type_lov
              UNION ALL
              SELECT OBJ_KEY_DESC CRTL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
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