CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_DATA_TP_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT DTL_NAME FROM 
    (SELECT DTL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED, 
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY, --uncomment when migration is corrected
                             SCHEME_REFERENCE,
                             ANNOTATION
                             --,CODEGEN_COMPATIBILITY_IND
                        FROM SBR.DATATYPES_LOV
              UNION ALL
              SELECT NCI_CD DTL_NAME,
                             DTTYPE_DESC DESCRIPTION,
                             NCI_DTTYPE_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED, --uncomment when migration is corrected
                             LST_UPD_USR_ID MODIFIED_BY,
                             DTTYPE_SCHM_REF SCHEME_REFERENCE,
                             DTTYPE_ANNTTN ANNOTATION
                             --, where is CODEGEN_COMPATIBILITY_IND
              FROM ONEDATA_WA.DATA_TYP where nci_dttype_typ_id = 1) t
      GROUP BY DTL_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     -- DATE_MODIFIED,
                     -- MODIFIED_BY,
                     SCHEME_REFERENCE,
                     ANNOTATION
      HAVING COUNT (*) <> 2
      ORDER BY DTL_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_DATA_TP_LOV to SBREXT;