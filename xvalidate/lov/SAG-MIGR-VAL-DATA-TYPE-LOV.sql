CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_DATA_TP_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT DTL_NAME FROM 
    (SELECT DTL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             Nvl (DATE_MODIFIED, DATE_CREATED) DATE_MODIFIED,
                             MODIFIED_BY,
                             SCHEME_REFERENCE,
                             ANNOTATION
                             --,CODEGEN_COMPATIBILITY_IND
                        FROM SBR.DATATYPES_LOV
              UNION ALL
              SELECT DTTYPE_NM DTL_NAME,
                             DTTYPE_DESC DESCRIPTION,
                             NCI_DTTYPE_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             Nvl (LST_UPD_DT, CREAT_DT) DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY,
                             DTTYPE_SCHM_REF SCHEME_REFERENCE,
                             DTTYPE_ANNTTN ANNOTATION
                             --, where is CODEGEN_COMPATIBILITY_IND
              FROM ONEDATA_WA.DATA_TYP) t
      GROUP BY DTL_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY,
                     SCHEME_REFERENCE,
                     ANNOTATION
      HAVING COUNT (*) <> 2
      ORDER BY DTL_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_DATA_TP_LOV to SBREXT;