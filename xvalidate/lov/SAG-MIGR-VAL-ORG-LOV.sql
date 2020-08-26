create or replace FUNCTION SAG_FUNC_MIGR_VAL_ORG_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT NAME FROM 
    (SELECT ORG_IDSEQ,
                             NAME,
                             RA_IND,
                             MAIL_ADDRESS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM SBR.ORGANIZATIONS
              UNION ALL
              SELECT en.NCI_IDSEQ ORG_IDSEQ,
                             norg.ORG_NM NAME,
                             norg.RA_IND,
                             norg.MAIL_ADDR MAIL_ADDRESS,
                             norg.CREAT_USR_ID CREATED_BY,
                             norg.CREAT_DT DATE_CREATED,
                             Nvl (norg.LST_UPD_DT, norg.CREAT_DT) DATE_MODIFIED,
                             norg.LST_UPD_USR_ID MODIFIED_BY
                        FROM ONEDATA_WA.NCI_ORG norg inner join ONEDATA_WA.NCI_ENTTY en on Norg.Entty_Id = En.Entty_Id where En.Entty_Typ_Id = 72) t
      GROUP BY ORG_IDSEQ,
                     NAME,
                     RA_IND,
                     MAIL_ADDRESS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_VAL_ORG_LOV to SBREXT;