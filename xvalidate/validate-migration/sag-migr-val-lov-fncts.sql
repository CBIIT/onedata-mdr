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
              FROM ONEDATA_WA.Stus_Mstr where STUS_TYP_ID = 2) t
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
GRANT EXECUTE ON SAG_FUNC_MIGR_VAL_AC_ST_LOV to SBREXT;
CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_CONC_SOURC_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT CONCEPT_SOURCE FROM 
    (SELECT CONCEPT_SOURCE,
                             DESCRIPTION,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM SBREXT.concept_sources_lov_ext
              UNION ALL
              SELECT OBJ_KEY_DESC CONCEPT_SOURCE,
                             OBJ_KEY_DEF DESCRIPTION,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=23) t
      GROUP BY CONCEPT_SOURCE,
                     DESCRIPTION,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY CONCEPT_SOURCE;
  RETURN c;
END;
/
GRANT EXECUTE ON ONWEDATA_A.SAG_FUNC_MIGR_CONC_SOURC_LOV to SBREXT;
create or replace FUNCTION SAG_FUNC_MIGR_CS_TYPES_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT CSTL_NAME FROM 
    (SELECT CSTL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM sbr.CS_TYPES_LOV
              UNION ALL
              SELECT OBJ_KEY_DESC CSTL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=3) t
      GROUP BY CSTL_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY CSTL_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_CS_TYPES_LOV to SBREXT;
create or replace FUNCTION SAG_FUNC_MIGR_CSI_TYPES_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT CSITL_NAME FROM 
    (SELECT CSITL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM sbr.CSI_TYPES_LOV
              UNION ALL
              SELECT OBJ_KEY_DESC CSITL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=20) t
      GROUP BY CSITL_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY CSITL_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_CSI_TYPES_LOV to SBREXT;
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
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY,
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
                             LST_UPD_DT DATE_MODIFIED,
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
CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_VAL_DEFIN_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT DEFL_NAME FROM 
    (SELECT DEFL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM SBREXT.definition_types_lov_ext
              UNION ALL
              SELECT OBJ_KEY_DESC DEFL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=15) t
      GROUP BY DEFL_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY DEFL_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_VAL_DEFIN_LOV to SBREXT;
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
create or replace FUNCTION SAG_FUNC_MIGR_VAL_DOC_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT DCTL_NAME FROM 
    (SELECT DCTL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM sbr.DOCUMENT_TYPES_LOV
              UNION ALL
              SELECT OBJ_KEY_DESC DCTL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=1) t
      GROUP BY DCTL_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY DCTL_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_VAL_DOC_LOV to SBREXT;
CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_FORMAT_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT FORML_NAME FROM 
    (SELECT FORML_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM SBR.FORMATS_LOV
              UNION ALL
              SELECT FMT_NM FORML_NAME,
                             FMT_DESC DESCRIPTION,
                             FMT_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.FMT) t
      GROUP BY FORML_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY FORML_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_FORMAT_LOV to SBREXT;
CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_LANG_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT NAME FROM 
    (SELECT NAME,
                             DESCRIPTION,
                             CREATED_BY,
                             DATE_CREATED,
                             Nvl (DATE_MODIFIED, DATE_CREATED) DATE_MODIFIED,
                             MODIFIED_BY
                        FROM SBR.LANGUAGES_LOV
              UNION ALL
              SELECT LANG_NM NAME,
                             LANG_DESC DESCRIPTION,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             Nvl (LST_UPD_DT, CREAT_DT) DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.LANG) t
      GROUP BY NAME,
                     DESCRIPTION,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_LANG_LOV to SBREXT;
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
CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_ORIGIN_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT SRC_NAME FROM 
    (SELECT SRC_NAME,
                             DESCRIPTION,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM SBREXT.sources_ext
              UNION ALL
              SELECT OBJ_KEY_DESC SRC_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=18) t
      GROUP BY SRC_NAME,
                     DESCRIPTION,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY SRC_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_ORIGIN_LOV to SBREXT;
create or replace FUNCTION SAG_FUNC_MIGR_VAL_PA_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT PAL_NAME FROM 
    (SELECT PAL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM sbr.PROGRAM_AREAS_LOV
              UNION ALL
              SELECT OBJ_KEY_DESC PAL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=14) t
      GROUP BY PAL_NAME,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY
      HAVING COUNT (*) <> 2
      ORDER BY PAL_NAME;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_VAL_PA_LOV to SBREXT;
create or replace FUNCTION SAG_FUNC_MIGR_VAL_QCDL_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT QCDL_NAME FROM 
    (SELECT QCDL_NAME,
                             DESCRIPTION,
                             --DISPLAY_ORDER,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM SBREXT.QC_DISPLAY_LOV_EXT
              UNION ALL
              SELECT OBJ_KEY_DESC QCDL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             --where is DISPLAY_ORDER,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
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
CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_VAL_REG_ST_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT REGISTRATION_STATUS FROM 
    (SELECT REGISTRATION_STATUS,
                             DESCRIPTION,
                             COMMENTS,
                             --DISPLAY_ORDER,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY,
                             DISPLAY_ORDER
                        FROM SBR.Reg_Status_Lov
              UNION ALL
              SELECT NCI_STUS REGISTRATION_STATUS,
                             STUS_DESC DESCRIPTION,
                             NCI_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY,
                             NCI_DISP_ORDR DISPLAY_ORDER
              FROM ONEDATA_WA.Stus_Mstr where STUS_TYP_ID = 1) t
      GROUP BY REGISTRATION_STATUS,
                     DESCRIPTION,
                     COMMENTS,
                     CREATED_BY,
                     DATE_CREATED,
                     DATE_MODIFIED,
                     MODIFIED_BY,
                     DISPLAY_ORDER
      HAVING COUNT (*) <> 2
      ORDER BY REGISTRATION_STATUS;
  RETURN c;
END;
/
GRANT EXECUTE ON ONEDATA_WA.SAG_FUNC_MIGR_VAL_REG_ST_LOV to SBREXT;
CREATE OR REPLACE FUNCTION SAG_FUNC_MIGR_UOM_LOV RETURN SYS_REFCURSOR
AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR SELECT UOML_NAME FROM 
    (SELECT UOML_NAME,
                             PRECISION,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY
                        FROM SBR.UNIT_OF_MEASURES_LOV
              UNION ALL
              SELECT UOM_NM UOML_NAME,
                             to_char(UOM_PREC) PRECISION,
                             UOM_DESC DESCRIPTION,
                             UOM_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
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








