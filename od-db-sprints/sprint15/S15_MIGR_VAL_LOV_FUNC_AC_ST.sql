create or replace FUNCTION SAG_FUNC_MIGR_VAL_AC_ST_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT ASL_NAME FROM 
    (SELECT ASL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY,
                             DISPLAY_ORDER
                        FROM SBR.AC_STATUS_LOV
              UNION ALL
              SELECT NCI_STUS ASL_NAME,
                             STUS_DESC DESCRIPTION,
                             NCI_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY,
                             NCI_DISP_ORDR DISPLAY_ORDER
              FROM Stus_Mstr where STUS_TYP_ID = 2 and FLD_DELETE = 0) t
      GROUP BY ASL_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY,
                     DISPLAY_ORDER
      HAVING COUNT (*) <> 2
      ORDER BY ASL_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_VAL_AC_ST_LOV to SBREXT;