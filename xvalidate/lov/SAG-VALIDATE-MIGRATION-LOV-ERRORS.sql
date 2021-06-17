--Run in ONEDATA_WA
--ORG
SELECT 'SBR' schema, ORG_IDSEQ,
                             NAME,
                             RA_IND,
                             MAIL_ADDRESS,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY
                        FROM SBR.ORGANIZATIONS where NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'ORG')
              UNION ALL
              SELECT 'WA' schema, en.NCI_IDSEQ ORG_IDSEQ,
                             norg.ORG_NM NAME,
                             norg.RA_IND,
                             norg.MAIL_ADDR MAIL_ADDRESS,
                             en.CREAT_USR_ID CREATED_BY,
                             en.CREAT_DT DATE_CREATED,
                             en.LST_UPD_DT DATE_MODIFIED,
                             en.LST_UPD_USR_ID MODIFIED_BY
                        FROM ONEDATA_WA.NCI_ORG norg inner join ONEDATA_WA.NCI_ENTTY en on Norg.Entty_Id = En.Entty_Id where En.Entty_Typ_Id = 72
                        and norg.ORG_NM in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'ORG')
ORDER BY NAME, schema;

--CS_TYPE

SELECT 'SBR' schema, CSTL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY
                        FROM sbr.CS_TYPES_LOV where CSTL_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'CS_TYPE')
              UNION ALL
              SELECT 'WA' schema, OBJ_KEY_DESC CSTL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=3 and OBJ_KEY_DESC in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'CS_TYPE')
ORDER BY CSTL_NAME, schema;

-- CSI_TYPE 
SELECT 'SBR' schema, CSITL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY
                        FROM sbr.CSI_TYPES_LOV where CSITL_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'CSI_TYPE')
              UNION ALL
              SELECT 'WA' schema, OBJ_KEY_DESC CSITL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=20 and OBJ_KEY_DESC in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'CSI_TYPE')
ORDER BY CSITL_NAME, schema;

--CONCEPT_SOURCE
SELECT 'SBR' schema, CONCEPT_SOURCE,
                             DESCRIPTION,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY
                        FROM concept_sources_lov_ext where CONCEPT_SOURCE in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'CONCEPT_SOURCE')
              UNION ALL
              SELECT 'WA' schema, OBJ_KEY_DESC CONCEPT_SOURCE,
                             OBJ_KEY_DEF DESCRIPTION,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=23 and OBJ_KEY_DESC in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'CONCEPT_SOURCE')
ORDER BY CONCEPT_SOURCE, schema;

--AC_STATUS
SELECT 'SBR' schema, ASL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY,
                             DISPLAY_ORDER
                        FROM SBR.AC_STATUS_LOV where ASL_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'AC_STATUS')
              UNION ALL
              SELECT 'WA' schema, NCI_STUS ASL_NAME,
                             STUS_DESC DESCRIPTION,
                             NCI_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY,
                             NCI_DISP_ORDR DISPLAY_ORDER
              FROM ONEDATA_WA.Stus_Mstr where STUS_TYP_ID = 2 and NCI_STUS in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'AC_STATUS')
ORDER BY ASL_NAME, schema;

--DEFINITION_TYPE
SELECT 'SBR' schema, DEFL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY
                        FROM definition_types_lov_ext where DEFL_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'DEFINITION_TYPE')
              UNION ALL
              SELECT 'WA' schema, OBJ_KEY_DESC DEFL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=15 and OBJ_KEY_DESC in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'DEFINITION_TYPE')
ORDER BY DEFL_NAME, schema;

--DERIVATION_TYPE
SELECT 'SBR' schema, CRTL_NAME,
                             DESCRIPTION,
                             CREATED_BY,
                             DATE_CREATED,
                             Nvl (DATE_MODIFIED, DATE_CREATED) DATE_MODIFIED,
                             MODIFIED_BY
                        FROM SBR.complex_rep_type_lov where CRTL_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'DERIVATION_TYPE')
              UNION ALL
              SELECT 'WA' schema, OBJ_KEY_DESC CRTL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             Nvl (LST_UPD_DT, CREAT_DT) DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=18 and OBJ_KEY_DESC in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'DERIVATION_TYPE')
ORDER BY CRTL_NAME, schema;

--DESIGNATION_TYPE
SELECT 'SBR' schema, DETL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY
                        FROM SBR.designation_types_lov where DETL_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'DESIGNATION_TYPE')
              UNION ALL
              SELECT 'WA' schema, OBJ_KEY_DESC DETL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=11 and OBJ_KEY_DESC in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'DESIGNATION_TYPE')
ORDER BY DETL_NAME, schema;

--DOC_TYPE
SELECT 'SBR' schema, DCTL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             Nvl (DATE_MODIFIED, DATE_CREATED) DATE_MODIFIED,
                             MODIFIED_BY
                        FROM sbr.DOCUMENT_TYPES_LOV where DCTL_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'DOC_TYPE')
              UNION ALL
              SELECT 'WA' schema, OBJ_KEY_DESC DCTL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             Nvl (LST_UPD_DT, CREAT_DT) DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=1 and OBJ_KEY_DESC in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'DOC_TYPE')
ORDER BY DCTL_NAME, schema;

--FORMATS
SELECT 'SBR' schema, FORML_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY
                        FROM SBR.FORMATS_LOV where FORML_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'FORMATS')
              UNION ALL
              SELECT 'WA' schema, FMT_NM FORML_NAME,
                             FMT_DESC DESCRIPTION,
                             FMT_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY 
              FROM ONEDATA_WA.FMT where FMT_NM in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'FORMATS')
ORDER BY FORML_NAME, schema;

--ORIGIN
SELECT 'SBR' schema, SRC_NAME,
                             DESCRIPTION,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY
                        FROM sources_ext where SRC_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'ORIGIN')
              UNION ALL
              SELECT 'WA' schema, OBJ_KEY_DESC SRC_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=18 and OBJ_KEY_DESC in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'ORIGIN')
ORDER BY SRC_NAME, schema;

--PA
SELECT 'SBR' schema, PAL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY
                        FROM sbr.PROGRAM_AREAS_LOV where PAL_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'PA')
              UNION ALL
              SELECT 'WA' schema, OBJ_KEY_DESC PAL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             OBJ_KEY_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=14 and OBJ_KEY_DESC in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'PA')
ORDER BY PAL_NAME, schema;

--QCDL_TYPE
SELECT 'SBR' schema, QCDL_NAME,
                             DESCRIPTION,
                             --DISPLAY_ORDER,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY
                        FROM QC_DISPLAY_LOV_EXT where QCDL_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'QCDL_TYPE')
              UNION ALL
              SELECT 'WA' schema, OBJ_KEY_DESC QCDL_NAME,
                             OBJ_KEY_DEF DESCRIPTION,
                             --where is DISPLAY_ORDER,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.OBJ_KEY where OBJ_TYP_ID=22 and OBJ_KEY_DESC in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'QCDL_TYPE')
ORDER BY QCDL_NAME, schema;

--REGISTRATION_STATUS
SELECT 'SBR' schema, REGISTRATION_STATUS,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY,
                             DISPLAY_ORDER
                        FROM SBR.Reg_Status_Lov where REGISTRATION_STATUS in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'REGISTRATION_STATUS')
              UNION ALL
              SELECT 'WA' schema, NCI_STUS REGISTRATION_STATUS,
                             STUS_DESC DESCRIPTION,
                             NCI_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY,
                             NCI_DISP_ORDR DISPLAY_ORDER
              FROM ONEDATA_WA.Stus_Mstr where STUS_TYP_ID = 1 and NCI_STUS in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'REGISTRATION_STATUS')
ORDER BY REGISTRATION_STATUS, schema;

--UOM
SELECT 'SBR' schema,  UOML_NAME,
                             PRECISION,
                             DESCRIPTION,
                             COMMENTS,
                             CREATED_BY,
                             DATE_CREATED,
                             DATE_MODIFIED,
                             MODIFIED_BY
                        FROM SBR.UNIT_OF_MEASURES_LOV where UOML_NAME in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'UOM')
              UNION ALL
              SELECT 'WA' schema, UOM_NM UOML_NAME,
                             to_char(UOM_PREC) PRECISION,
                             UOM_DESC DESCRIPTION,
                             UOM_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY
              FROM ONEDATA_WA.UOM where UOM_NM in (SELECT LOV_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'UOM')
ORDER BY UOML_NAME, schema;

--DATA_TYPE
SELECT 'SBR' schema, DTL_NAME,
                             DESCRIPTION,
                             COMMENTS,
                             NVL (CREATED_BY, 'ONEDATA') CREATED_BY,
                             NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD')) DATE_CREATED,
                             Nvl (DATE_MODIFIED, NVL (DATE_CREATED, TO_DATE('2020-08-18', 'YYYY-MM-DD'))) DATE_MODIFIED,
                             NVL (MODIFIED_BY, 'ONEDATA') MODIFIED_BY,
                             SCHEME_REFERENCE,
                             ANNOTATION
                             --,CODEGEN_COMPATIBILITY_IND
                        FROM SBR.DATATYPES_LOV where DTL_NAME in (SELECT Lov_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'DATA_TYPE')
              UNION ALL
              SELECT 'WA' schema, NCI_CD DTL_NAME,
                             DTTYPE_DESC DESCRIPTION,
                             NCI_DTTYPE_CMNTS COMMENTS,
                             CREAT_USR_ID CREATED_BY,
                             CREAT_DT DATE_CREATED,
                             LST_UPD_DT DATE_MODIFIED,
                             LST_UPD_USR_ID MODIFIED_BY,
                             DTTYPE_SCHM_REF SCHEME_REFERENCE,
                             DTTYPE_ANNTTN ANNOTATION
                             --, where is CODEGEN_COMPATIBILITY_IND
              FROM ONEDATA_WA.DATA_TYP where NCI_CD in (SELECT Lov_VALUE FROM Sag_Migr_Lov_Err WHERE Lov_Name = 'DATA_TYPE')
 ORDER BY DTL_NAME, schema;   
