# Validate Migration LoVs
These are scripts related to data migration validation caDSR to OneData List of Values.
These scripts shall be run in ONEDATA_WA schema.

## create sequence and table
SBREXT-MIGR-VAL-DDL.sql

## onedata_wa.stus_mstr where stus_typ_id = 2 sbr.ac_status_lov 'AC_STATUS'
SAG-MIGR-VAL-AC-ST-LOV.sql

## onedata_wa.OBJ_KEY where obj_typ_id = 18 sbrext.sources_ext 'CONCEPT_SOURCE'
SAG-MIGR-VAL-CONCEPT-SOURCE-LOV.sql

## Classification Scheme Type sbr.CS_TYPES_LOV onedata_wa.OBJ_KEY obj_typ_id = 3 'CS_TYPE'
SAG-MIGR-VAL-CS-TYPES-LOV.sql

## CSI Type sbr.CSI_TYPES_LOV onedata_wa.OBJ_KEY where obj_typ_id = 20 'CSI_TYPE'
SAG-MIGR-VAL-CSI-TYPES-LOV.sql

##onedata_wa.data_typ sbr.datatypes_lov 'DATA_TYPE'
SAG-MIGR-VAL-DATA-TYPE-LOV.sql

## onedata_wa.OBJ_KEY OBJ_TYP_ID=15 SBREXT.definition_types_lov_ext 'DEFINITION_TYPE'
SAG-MIGR-VAL-DEFIN-LOV.sql

## Derivation Type onedata_wa.OBJ_KEY obj_typ_id = 21 'DERIVATION_TYPE'
SAG-MIGR-VAL-DERIV-LOV.sql

## onedata_wa.OBJ_KEY obj_typ_id = 11 sbr.DESIGNATION_TYPES_LOV 'DESIGNATION_TYPE'
SAG-MIGR-VAL-DESIG-LOV.sql

## onedata_wa.OBJ_KEY where obj_typ_id = 1 sbr.document_TYPES_LOV 'DOC_TYPE'
SAG-MIGR-VAL-DOC-LOV.sql

## sbr.FORMATS_LOV FORMATS onedata_wa.fmt 'FORMATS'
SAG-MIGR-VAL-FORMAT-LOV.sql

## Languages LANG "BR.LANGUAGES_LOV 'LANGUAGE'
SAG-MIGR-VAL-LANG-LOV.sql

## ORGANIZATIONS onedata_wa.ORG 'ORG'
SAG-MIGR-VAL-ORG-LOV.sql

## onedata_wa.OBJ_KEY where obj_typ_id = 18 sbrext.sources_ext
SAG-MIGR-VAL-ORIGIN-LOV.sql

## Program Area  onedata_wa.OBJ_KEY where obj_typ_id = 14 sbr.PROGRAM_AREAS_LOV PA'
SAG-MIGR-VAL-PA-LOV.sql

## Form Category display onedata_wa.OBJ_KEY OBJ_TYP_ID=22 SBREXT.QC_DISPLAY_LOV_EXT  'QCDL_TYPE'
SAG-MIGR-VAL-QCDL-LOV.sql

## onedata_wa.stus_mstr where stus_typ_id = 1 sbr.reg_status_lov 'REGISTRATION_STATUS'
SAG-MIGR-VAL-REG-ST-LOV.sql

## UOM 'UOM'
SAG-MIGR-VAL-UOM-LOV.sql

## call all DDLs LoV Validation
SBREXT-MIGR-VAL-LOV-FULL.sql

## perform validation block
This script shall be run in SBREXT schema.
SBREXT-SAG-MIGR-VAL-LOV.sql




