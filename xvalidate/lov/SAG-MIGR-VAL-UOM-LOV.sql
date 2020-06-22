CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_UOM_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT UOML_NAME FROM 
    (SELECT UOML_NAME,
                             PRECISION,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             Nvl (DATE_MODIFIED, DATE_CREATED) DATE_MODIFIED,
                             MODIFIED_BY
                        FROM SBR.UNIT_OF_MEASURES_LOV
              UNION ALL
              SELECT UOM_NM UOML_NAME,
                             to_char(UOM_PREC) PRECISION,
                             UOM_DESC DESCRIPTION,
                             UOM_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             Nvl (LST_UPD_DT, CREAT_DT) DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.UOM) t
      GROUP BY UOML_NAME,
                     DESCRIPTION,
                     PRECISION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY UOML_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_UOM_LOV to SBREXT;