-- Org/Contact - Internal ID
alter sequence NCI_SEQ_ENTTY restart start with 600000; -- 6 hundred thousand
-- AI Public ID
alter sequence  OD_SEQ_ADMIN_ITEM  restart start with 600000000;  -- 60 million
-- Definition - Internal ID
alter sequence  OD_SEQ_ALT_DEF  restart start with 600000000; -- 60 million
-- Designations - Internal ID
alter sequence  OD_SEQ_ALT_NMS  restart start with 600000000; -- 60 million
-- CDE Import - Internal ID
alter sequence  OD_SEQ_CDE_IMPORT  restart start with 600000000; -- 60 million
-- Reference table - character set - not used at NCI
alter sequence  OD_SEQ_CHARSET  restart start with 60000; -- 60 thousand
-- Named Users/Contacts for drop-down - internal ID
alter sequence  OD_SEQ_CNTCT  restart start with 600000; -- 6 hundred thousand
-- Download collection - Collection ID
alter sequence  OD_SEQ_DLOAD_HDR  restart start with 6000000; - 6 million
-- Matching - Internal ID
alter sequence  OD_SEQ_DS_HDR  restart start with 60000000; -- 60 milllion
-- Reference table - Data type LOV
alter sequence  OD_SEQ_DTTYP  restart start with 60000; -- 60 thousand
-- Reference table - Data type LOV
alter sequence  OD_SEQ_FMT  restart start with 60000; -- 60 thousand
-- DEC/VD Import table - Internal ID
alter sequence   OD_SEQ_IMPORT  restart start with 60000000; -- 60 milllion
-- Reference table - Language LOV
alter sequence    OD_SEQ_LANG  restart start with 60000; -- 60 thousand
-- Reverse job log - Internal ID
alter sequence    OD_SEQ_NCI_JOB_LOG  restart start with 60000000; -- 60 million
-- Reference table - ALL other LOV
alter sequence    OD_SEQ_OBJKEY  restart start with 6000000; --6 million
-- Permissible value - Internal ID
alter sequence    OD_SEQ_PERM_VAL  restart start with 60000000;  -- 60 million
-- Reference Document - Internal ID
alter sequence    OD_SEQ_REF  restart start with 60000000;  -- 60 million
-- Reference Document BLOB- Internal ID
alter sequence    OD_SEQ_REF_DOC  restart start with 60000000;  -- 60 million
-- Old Import Staging table - just in case- Internal ID
alter sequence    OD_SEQ_STG_AI  restart start with 60000000;  -- 60 million
-- Reference table - REgistration and workflow status
alter sequence     OD_SEQ_STUS_MSTR  restart start with 60000; -- 60 thousand
-- Reference table - UOM
alter sequence      OD_SEQ_UOM  restart start with 60000; -- 60 thousand
-- Concept- AI relationship - Internal ID
alter sequence  SEQ_CNCPT_AI   restart start with 60000000; -- 60 million
-- Form Repetition - Internal ID
alter sequence  SEQ_QUEST_VV_REP    restart start with 60000000; -- 60 million
-- Trigger Action - Internal ID
alter sequence  SEQ_TA   restart start with 60000000; -- 60 million
