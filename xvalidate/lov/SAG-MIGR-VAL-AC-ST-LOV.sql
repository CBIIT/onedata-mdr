CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_VAL_ORG_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT NAME FROM 
    (SELECT ORG_IDSEQ,
                             NAME,
                             RA_IND,
                             MAIL_ADDRESS,
                             CREATED_BY,
                             DATE_CREATED,
                             Nvl (DATE_MODIFIED, DATE_CREATED) DATE_MODIFIED,
                             MODIFIED_BY
                        FROM SBR.ORGANIZATIONS
              UNION ALL
              SELECT NCI_IDSEQ ORG_IDSEQ,
                             ORG_NM NAME,
                             RA_IND,
                             ORG_MAIL_ADR MAIL_ADDRESS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             Nvl (LST_UPD_DT, CREAT_DT) DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.ORG) t
      GROUP BY ORG_IDSEQ,
                     NAME,
                     RA_IND,
                     MAIL_ADDRESS,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_VAL_ORG_LOV to SBREXT;