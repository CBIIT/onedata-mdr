--Run as MD
S30_MD.sql

-- Run as ONEDATA_WA DDL scripts
S30_WA_DDL_SAG_LOAD_CONCEPTS.sql
S30_NCI_11179.sql
S30_NCI_11179_2.sql
S30_NCI_POST_HOOK.sql
S30_NCI_CADSR_PUSH_CORE.sql
S30_NCI_CADSR_PUSH_FORM.sql
S30_NCI_CADSR_PUSH.sql

--Check that materialized views are valid in ONEDATA_WA schema
--Check that all the packages and procedures are compiled (no error) in ONEDATA_WA, ONEDATA_RA

---- Run as ONEDATA_WA
truncate table SAG_LOAD_CONCEPTS_EVS

-- ! Attention DBAs: import the table SAG_LOAD_CONCEPTS_EVS data from DEV tier to deployment tier before running the next scripts

-- Concepts Loading steps below
-- ! Attention DBAs: import the table SAG_LOAD_CONCEPTS_EVS data from DEV tier to your deployment tier before running the next script

-- Run as ONEDATA_WA DM scripts
S22_WA_EXEC_LOAD_CONCEPTS.sql
EXECUTE DBMS_MVIEW.REFRESH('VW_CNCPT'); 
EXECUTE DBMS_MVIEW.REFRESH('VW_CNTXT');
EXECUTE DBMS_MVIEW.REFRESH('VW_CLSFCTN_SCHM_ITEM');
EXECUTE DBMS_MVIEW.REFRESH('VW_CLSFCTN_SCHM');
EXECUTE DBMS_MVIEW.REFRESH('VW_REP_CLS');

-- Run as ONEDATA_RA DM scripts
exec SAG_LOAD_CONCEPTS_SYN_RA;
EXECUTE DBMS_MVIEW.REFRESH('VW_CNCPT');
EXECUTE DBMS_MVIEW.REFRESH('VW_CNTXT');
EXECUTE DBMS_MVIEW.REFRESH('VW_CLSFCTN_SCHM_ITEM');
EXECUTE DBMS_MVIEW.REFRESH('VW_CLSFCTN_SCHM');
EXECUTE DBMS_MVIEW.REFRESH('VW_REP_CLS');

-- Run as ONEDATA_MD
exec sp_create_cntct;

-- Run as ONEDATA_WA initial Reverse from OD to caDSR schemas
exec nci_cadsr_push.spPushInitial;

