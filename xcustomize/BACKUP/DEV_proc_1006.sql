DROP PROCEDURE ONEDATA_WA.CSCSI_XML444_GENER;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.CSCSI_XML444_GENER AS
BEGIN
  delete  from CSCSI_444_GENERATED_XML where CREATED_DATE<SYSDATE-7;
  commit;
  CSCSI_XML444_Insert;
  CSCSI_XML444_TRANSFORM;
END;
/


DROP PROCEDURE ONEDATA_WA.CSCSI_XML444_INSERT;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.CSCSI_XML444_Insert as
/*insert XML*/
P_file number;
l_file_name      VARCHAR2(100);
l_file_path      VARCHAR2(200);
l_result         CLOB:=null;
l_xmldoc          CLOB:=null; 
errmsg VARCHAR2(500):='Non';
  
BEGIN
 
select count(*) into P_file from CSCSI_444_GENERATED_XML;
IF P_file>0 then
 select max(NVL(SEQ_ID,0))+1 into P_file from CSCSI_444_GENERATED_XML;
end if;
        l_file_path := 'SBREXT_DIR';
       
         l_file_name := 'CS_CSI_XML_'||P_file||'.xml';

        SELECT dbms_xmlgen.getxml( 'select* from MDSR444XML_5CSI_LEVEL_VIEW_N')
        INTO l_result
        FROM DUAL ;
        insert into CSCSI_444_GENERATED_XML VALUES ( l_file_name ,l_result,SYSDATE,P_file);      

 commit;
 EXCEPTION
    WHEN OTHERS THEN
   errmsg := SQLERRM;
         dbms_output.put_line('errmsg  - '||errmsg);
        insert into SBREXT.MDSR_REPORTS_ERR_LOG VALUES (l_file_name,  errmsg, sysdate);
 commit;

END ;
/


DROP PROCEDURE ONEDATA_WA.CSCSI_XML444_TRANSFORM;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.CSCSI_XML444_TRANSFORM IS

P_file number;
l_file_name VARCHAR2(500) ;
 errmsg VARCHAR2(500):='Non';
 
BEGIN
select max(SEQ_ID) into P_file from CSCSI_444_GENERATED_XML;
select FILE_NAME into l_file_name from CSCSI_444_GENERATED_XML where SEQ_ID=P_file;


update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CS_L5_T','ClassificationScheme') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CSI_L1_T','CSI') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CSI_L2_T','CSI') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CSI_L3_T','CSI') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CSI_L4_T','CSI') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CSI_L5_T','CSI') where SEQ_ID=P_FILE;

UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'ROWSET','Classifications' ) where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'</ROW>','</Context>') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'<ROW>','<Context>') where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ChildCSIList>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'</ChildCSIList>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ChildCSIList/>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ClassificationItem_LIST>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ClassificationItem_LIST/>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'</ClassificationItem_LIST>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ClassificationList>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ClassificationList/>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'</ClassificationList>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'ParentIdseq','ParentChildIdseq' ) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<?xml version="1.0"?>','<?xml version="1.0" encoding="UTF-8"?>') where SEQ_ID=P_FILE;
--UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'2016-08-01 16:20:20',TO_CHAR(SYSDATE,'YYYY-MM-DD')||'T00:00:00.0') where SEQ_ID=P_FILE;
 commit;
 EXCEPTION
    WHEN OTHERS THEN
   errmsg := SQLERRM;
         dbms_output.put_line('errmsg  - '||errmsg);
        insert into CSCSI_444_REPORTS_ERR_LOG VALUES (l_file_name,  errmsg, sysdate);
 commit;

END ;
/


DROP PROCEDURE ONEDATA_WA.PROC_DSBL_ADPT_OPTMZR;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.PROC_DSBL_ADPT_OPTMZR
AS
	oracle_version PRODUCT_COMPONENT_VERSION.version%TYPE;
BEGIN
	SELECT version into oracle_version FROM PRODUCT_COMPONENT_VERSION where PRODUCT LIKE '%Oracle%';
		IF oracle_version LIKE '12%' THEN
            execute immediate 'CREATE OR REPLACE TRIGGER TAL_DSBL_ADPT_OPTMZR AFTER LOGON ON SCHEMA
            DECLARE
            BEGIN
                    execute immediate ''ALTER SESSION SET optimizer_features_enable = "11.2.0.3"'';
            END;';
        END IF;
END;
/


DROP PROCEDURE ONEDATA_WA.SAG_AI_VALIDATION;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.SAG_AI_VALIDATION
AS
    --DECLARE
    /*****************************************************
        Created By : Akhilesh Trikha
        Created on : 06/23/2020
        Version: 1.0
        Details: Validate ALL items in ADMIN_ITEM table.
        Update History:

        *****************************************************/
    -- Validate sbr.data_elements
    vSQL   VARCHAR2 (4000);
    ITEM_CODE NUMBER;
BEGIN
    -- get the list of tables and their corresponding distinct columns from the table
    FOR Y
        IN (SELECT ITEMID_NAME,
                   IDSEQ_NAME,
                   TAB_NAME,
                   ITEM_TYPE,
                   ITEM_TYPE_CODE,
                   CONDITION
              FROM AI_INPUT_TAB)
    LOOP
        ITEM_CODE:=Y.ITEM_TYPE_CODE;

        CASE
        WHEN ITEM_CODE=1 OR ITEM_CODE=7 OR ITEM_CODE=9 OR ITEM_CODE=56 THEN
        vSQL :=
               'BEGIN
           FOR X in (Select /*+ PARALLEL(12) */ DISTINCT NCI_IDSEQ, ITEM_LONG_NM,
ITEM_ID,VER_NR from
(select NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL
THEN ORIGIN
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID,ADMIN_STUS_NM_DN
 from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = '
            || Y.ITEM_TYPE_CODE
            || ' and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
 UNION ALL
 select '
            || Y.IDSEQ_NAME
            || ' , '
            || Y.ITEM_TYPE_CODE
            || ' ,SB.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),''YES'', 1,''NO'',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,SB.PREFERRED_DEFINITION, ' --Not to pick from SBR.ADMINISTERED_COMPONENTS
            || Y.ITEMID_NAME
            || ' ,
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(SB.CREATED_BY,''ONEDATA''), NVL(SB.DATE_CREATED,to_date(''8/18/2020'',''mm/dd/yyyy'')),
NVL(NVL(SB.DATE_MODIFIED, SB.DATE_CREATED),to_date(''8/18/2020'',''mm/dd/yyyy'')), NVL(SB.MODIFIED_BY,''ONEDATA''),AC.ASL_NAME
FROM '
            || Y.TAB_NAME
            || ' AC ' ||
Y.CONDITION || ')
 GROUP BY NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID,ADMIN_STUS_NM_DN
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
            LOOP
--            DBMS_OUTPUT.PUT_LINE(X.NCI_IDSEQ || '' | '' || X.ITEM_ID || '' | '' || X.VER_NR || '' | '' || X.ITEM_LONG_NM);
            INSERT INTO ONEDATA_MIGRATION_ERROR VALUES
            (ERR_SEQ.NEXTVAL,X.NCI_IDSEQ,X.ITEM_ID,X.VER_NR,'''||Y.ITEM_TYPE||''',SUBSTR(X.ITEM_LONG_NM,50),''DATA MISMATCH'',SYSDATE,USER,''ADMIN_ITEM'','''');
            COMMIT;
            END LOOP;
            END;';
WHEN ITEM_CODE=51 THEN -- CS_ITEMS exclude migrated as retired deleted from compare
            vSQL := SAG_AI_AI_CSI_COMPARE(Y.ITEM_TYPE_CODE, Y.IDSEQ_NAME, Y.ITEMID_NAME, Y.TAB_NAME, Y.CONDITION, Y.ITEM_TYPE);
ELSE

vSQL :=
               'BEGIN
           FOR X in (Select /*+ PARALLEL(12) */ DISTINCT NCI_IDSEQ, ITEM_LONG_NM,
ITEM_ID,VER_NR from
(select NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL
THEN ORIGIN
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID,ADMIN_STUS_NM_DN
 from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = '
            || Y.ITEM_TYPE_CODE
            || ' and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
 UNION ALL
 select '
            || Y.IDSEQ_NAME
            || ' , '
            || Y.ITEM_TYPE_CODE
            || ' ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),''YES'', 1,''NO'',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, '
            || Y.ITEMID_NAME
            || ' ,
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,''ONEDATA''), NVL(AC.DATE_CREATED,to_date(''8/18/2020'',''mm/dd/yyyy'')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date(''8/18/2020'',''mm/dd/yyyy'')), NVL(AC.MODIFIED_BY,''ONEDATA''),AC.ASL_NAME
FROM '
            || Y.TAB_NAME
            || ' AC ' ||
Y.CONDITION || ')
 GROUP BY NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID,ADMIN_STUS_NM_DN
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
            LOOP
--            DBMS_OUTPUT.PUT_LINE(X.NCI_IDSEQ || '' | '' || X.ITEM_ID || '' | '' || X.VER_NR || '' | '' || X.ITEM_LONG_NM);
            INSERT INTO ONEDATA_MIGRATION_ERROR VALUES
            (ERR_SEQ.NEXTVAL,X.NCI_IDSEQ,X.ITEM_ID,X.VER_NR,'''||Y.ITEM_TYPE||''',SUBSTR(X.ITEM_LONG_NM,50),''DATA MISMATCH'',SYSDATE,USER,''ADMIN_ITEM'','''');
            COMMIT;
            END LOOP;
            END;';
END CASE;
        --DBMS_OUTPUT.PUT_LINE(vSQL);
        EXECUTE IMMEDIATE vSQL;
    END LOOP;
    /* Validate Contexts*/
    FOR X IN (  SELECT /*+ PARALLEL(12) */
                       DISTINCT NCI_iDSEQ,
                                ITEM_DESC,
                                VER_NR,
                                ITEM_NM
                  FROM (SELECT admin_item_typ_id,
                               NCI_iDSEQ,
                               ITEM_DESC,
                               ITEM_NM,
                               ITEM_LONG_NM,
                               VER_NR,
                               CNTXT_NM_DN,
                               CREAT_USR_ID,
                               CREAT_DT,
                               LST_UPD_DT,
                               LST_UPD_USR_ID
                          FROM ADMIN_ITEM    --11/8/2019 4:41:54 PM
                         WHERE ADMIN_ITEM_TYP_ID = '8'
                        --and NCI_IDSEQ='B2C9F513-4346-6519-E034-0003BA12F5E7'
                        UNION ALL
                        SELECT 8,
                               TRIM (conte_idseq),
                               description,
                               name,
                               name,
                               version,
                               name,
                               NVL(created_by,'ONEDATA'),
                               NVL(date_created,to_date('8/18/2020','mm/dd/yyyy')),
                               NVL(NVL (date_modified, date_created),to_date('8/18/2020','mm/dd/yyyy')),
                               NVL(modified_by,'ONEDATA')
                          FROM SBR_M.CONTEXTS AC)
              GROUP BY admin_item_typ_id,
                       NCI_iDSEQ,
                       ITEM_DESC,
                       ITEM_NM,
                       ITEM_LONG_NM,
                       VER_NR,
                       CNTXT_NM_DN,
                       CREAT_USR_ID,
                       CREAT_DT,
                       LST_UPD_DT,
                       LST_UPD_USR_ID
                HAVING COUNT (*) <> 2
              ORDER BY ITEM_NM, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     X.NCI_iDSEQ,
                     NULL, --No ITEM_ID in caDSR for CONTEXTS
                     X.VER_NR,
                     'CONTEXTS',
                     SUBSTR(X.ITEM_NM,0,50),
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'ADMIN_ITEM',
                     '');

        COMMIT;
    END LOOP;
END;
/


DROP PROCEDURE ONEDATA_WA.SAG_AI_VALIDATION_MOD;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.SAG_AI_VALIDATION_MOD
AS
    --DECLARE
    /*****************************************************
        Created By : Akhilesh Trikha
        Created on : 06/23/2020
        Version: 1.0
        Details: Validate ALL items in ADMIN_ITEM table.
        Update History:

        *****************************************************/
    -- Validate sbr.data_elements
    vSQL   VARCHAR2 (4000);
    ITEM_CODE NUMBER;
BEGIN
    -- get the list of tables and their corresponding distinct columns from the table
    FOR Y
        IN (SELECT ITEMID_NAME,
                   IDSEQ_NAME,
                   TAB_NAME,
                   ITEM_TYPE,
                   ITEM_TYPE_CODE,
                   CONDITION
              FROM AI_INPUT_TAB)
    LOOP
        ITEM_CODE:=Y.ITEM_TYPE_CODE;

        CASE
        WHEN ITEM_CODE=1 OR ITEM_CODE=7 OR ITEM_CODE=9 OR ITEM_CODE=56 THEN
        vSQL :=
               'BEGIN
           FOR X in (Select /*+ PARALLEL(12) */ DISTINCT NCI_IDSEQ, ITEM_LONG_NM,
ITEM_ID,VER_NR from 
(select NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = '
            || Y.ITEM_TYPE_CODE
            || ' and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
 UNION ALL
 select '
            || Y.IDSEQ_NAME
            || ' , '
            || Y.ITEM_TYPE_CODE
            || ' ,SB.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),''YES'', 1,''NO'',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,SB.PREFERRED_DEFINITION, ' --Not to pick from SBR.ADMINISTERED_COMPONENTS
            || Y.ITEMID_NAME
            || ' ,
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(SB.CREATED_BY,''ONEDATA''), 
NVL(SB.DATE_CREATED,to_date(''8/18/2020'',''mm/dd/yyyy'')),
NVL(SB.DATE_MODIFIED, get_ai_modified_date_idseq('
  || Y.IDSEQ_NAME  
  || ', '
  || Y.ITEM_TYPE_CODE
  || ')), 
NVL(SB.MODIFIED_BY,''ONEDATA'')
FROM '
            || Y.TAB_NAME
            || ' AC ' ||
Y.CONDITION || ')
 GROUP BY NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
            LOOP
--            DBMS_OUTPUT.PUT_LINE(X.NCI_IDSEQ || '' | '' || X.ITEM_ID || '' | '' || X.VER_NR || '' | '' || X.ITEM_LONG_NM);
            INSERT INTO ONEDATA_MIGRATION_ERROR_MOD VALUES
            (ERR_SEQ.NEXTVAL,X.NCI_IDSEQ,X.ITEM_ID,X.VER_NR,'''||Y.ITEM_TYPE||''',SUBSTR(X.ITEM_LONG_NM,50),''DATA MISMATCH'',SYSDATE,USER,''ADMIN_ITEM'','''');
            COMMIT;
            END LOOP;
            END;';
ELSE

vSQL :=
               'BEGIN
           FOR X in (Select /*+ PARALLEL(12) */ DISTINCT NCI_IDSEQ, ITEM_LONG_NM,
ITEM_ID,VER_NR from 
(select NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = '
            || Y.ITEM_TYPE_CODE
            || ' and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
 UNION ALL
 select '
            || Y.IDSEQ_NAME
            || ' , '
            || Y.ITEM_TYPE_CODE
            || ' ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),''YES'', 1,''NO'',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, '
            || Y.ITEMID_NAME
            || ' ,
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,''ONEDATA''), NVL(AC.DATE_CREATED,to_date(''8/18/2020'',''mm/dd/yyyy'')),
NVL(AC.DATE_MODIFIED, get_ai_modified_date_idseq('
  || Y.IDSEQ_NAME
  || ', '
  || Y.ITEM_TYPE_CODE
  || ')), 
NVL(AC.MODIFIED_BY,''ONEDATA'')
FROM '
            || Y.TAB_NAME
            || ' AC ' ||
Y.CONDITION || ')
 GROUP BY NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
            LOOP
--            DBMS_OUTPUT.PUT_LINE(X.NCI_IDSEQ || '' | '' || X.ITEM_ID || '' | '' || X.VER_NR || '' | '' || X.ITEM_LONG_NM);
            INSERT INTO ONEDATA_MIGRATION_ERROR_MOD VALUES
            (ERR_SEQ.NEXTVAL,X.NCI_IDSEQ,X.ITEM_ID,X.VER_NR,'''||Y.ITEM_TYPE||''',SUBSTR(X.ITEM_LONG_NM,50),''DATA MISMATCH'',SYSDATE,USER,''ADMIN_ITEM'','''');
            COMMIT;
            END LOOP;
            END;';
END CASE;            
        DBMS_OUTPUT.PUT_LINE(vSQL);
        EXECUTE IMMEDIATE vSQL;
    END LOOP;

    /* Validate Contexts*/
    FOR X IN (  SELECT /*+ PARALLEL(12) */
                       DISTINCT NCI_iDSEQ,
                                ITEM_DESC,
                                VER_NR,
                                ITEM_NM
                  FROM (SELECT admin_item_typ_id,
                               NCI_iDSEQ,
                               ITEM_DESC,
                               ITEM_NM,
                               ITEM_LONG_NM,
                               VER_NR,
                               CNTXT_NM_DN,
                               CREAT_USR_ID,
                               CREAT_DT,
                               LST_UPD_DT,
                               LST_UPD_USR_ID
                          FROM ADMIN_ITEM    --11/8/2019 4:41:54 PM
                         WHERE ADMIN_ITEM_TYP_ID = '8'
                        --and NCI_IDSEQ='B2C9F513-4346-6519-E034-0003BA12F5E7'
                        UNION ALL
                        SELECT 8,
                               TRIM (conte_idseq),
                               description,
                               name,
                               name,
                               version,
                               name,
                               NVL(created_by,'ONEDATA'),
                               NVL(date_created,to_date('8/18/2020','mm/dd/yyyy')),
                               NVL(date_modified, get_ai_modified_date_idseq(conte_idseq, 8)),
                               NVL(modified_by,'ONEDATA')
                          FROM SBR.CONTEXTS AC)
              GROUP BY admin_item_typ_id,
                       NCI_iDSEQ,
                       ITEM_DESC,
                       ITEM_NM,
                       ITEM_LONG_NM,
                       VER_NR,
                       CNTXT_NM_DN,
                       CREAT_USR_ID,
                       CREAT_DT,
                       LST_UPD_DT,
                       LST_UPD_USR_ID
                HAVING COUNT (*) <> 2
              ORDER BY ITEM_NM, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR_MOD
             VALUES (ERR_SEQ.NEXTVAL,
                     X.NCI_iDSEQ,
                     NULL, --No ITEM_ID in caDSR for CONTEXTS
                     X.VER_NR,
                     'CONTEXTS',
                     SUBSTR(X.ITEM_NM,0,50),
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'ADMIN_ITEM',
                     '');

        COMMIT;
    END LOOP;
END;
/


DROP PROCEDURE ONEDATA_WA.SAG_CREATE_CONCEPT_ADMIN_ITEMS;

CREATE OR REPLACE Procedure ONEDATA_WA.SAG_CREATE_CONCEPT_ADMIN_ITEMS AS
--DECLARE
	v_concepts_loaded SAG_LOAD_CONCEPTS_EVS%ROWTYPE;
	v_eff_date DATE := sysdate;
	v_idseq CHAR(36);
    v_dflt_usr  varchar2(30) := 'ONEDATA';
	CURSOR concepts_raw_cur IS
	--find new concepts 
	select * from SAG_LOAD_CONCEPTS_EVS ld where CONCEPT_STATUS is NULL and CON_IDSEQ is NULL
	and ld.code not in (select distinct item_long_nm from ADMIN_ITEM where admin_item_typ_id = 49);
	BEGIN
	OPEN concepts_raw_cur;
	LOOP
		FETCH concepts_raw_cur INTO v_concepts_loaded;	
		EXIT WHEN concepts_raw_cur%NOTFOUND;
		v_idseq := nci_11179.cmr_guid();
		INSERT INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            --ADMIN_STUS_ID, default
                            --ADMIN_STUS_NM_DN, trigger
                            EFF_DT,
                            -- CHNG_DESC_TXT, N/A
                            -- CNTXT_ITEM_ID, trigger 20000000024
                            -- CNTXT_VER_NR,
                            -- CNTXT_NM_DN,
                            -- UNTL_DT,
                            -- CURRNT_VER_IND, default
                            ITEM_LONG_NM,
                            -- ORIGIN, trigger
                            ITEM_DESC, 
                            --ITEM_ID,
                            ITEM_NM,
                            --VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID,
                            DEF_SRC)
        VALUES(v_idseq,
               49, 
               v_eff_date,
               v_concepts_loaded.code,
               substr(v_concepts_loaded.definition, 1, 4000), --trim until length increases
               NVL (v_concepts_loaded.display_name, v_concepts_loaded.code),
               v_dflt_usr,
               v_eff_date,
               v_eff_date,
               v_dflt_usr,
               'NCI');
		update SAG_LOAD_CONCEPTS_EVS set CON_IDSEQ = v_idseq where code = v_concepts_loaded.code;
   		INSERT INTO cncpt (item_id,
                       ver_nr,
                       evs_src_id,
                       CREAT_USR_ID,
                       CREAT_DT,
                       LST_UPD_DT,
                       LST_UPD_USR_ID)
        SELECT item_id,
               ver_nr,
               218,
         	   CREAT_USR_ID,
               CREAT_DT,
               LST_UPD_DT,
               LST_UPD_USR_ID
 		FROM ADMIN_ITEM where
 		ADMIN_ITEM_TYP_ID = 49
 		and ITEM_LONG_NM = v_concepts_loaded.code
 		and FLD_DELETE = 0
        and admin_stus_id = 75 --RELEASED
        and CNTXT_ITEM_ID=20000000024;

    	COMMIT;

	END LOOP;
	CLOSE concepts_raw_cur;
END;
/


DROP PROCEDURE ONEDATA_WA.SAG_FK_VALIDATE;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.SAG_FK_VALIDATE AS
--DECLARE
/*****************************************************
        Created By : Akhilesh Trikha
        Created on : 06/30/2020
        Version: 1.0
        Details: Compare Referential Integrity constraints between OneData table and caDSR table.
        Update History:

        *****************************************************/
BEGIN

--Check DATA_ELEMENT_CONCEPT Relationship in DATA_ELEMENTS/DE
FOR X IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai1.Item_Id,
                ai1.Ver_Nr,
                ai1.NCI_IDSEQ,
                ai1.ITEM_LONG_NM
  FROM SBR_M.data_elements  dae
       INNER JOIN ADMIN_ITEM ai1 ON ai1.nci_idseq = DEC_IDSEQ
              --and ai1.Nci_Idseq = '99BA9DC8-44D9-4E69-E034-080020C9C0E0'
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN de de
                                      ON     De.Item_Id = ai2.Item_Id
                                         AND De.Ver_Nr = Ai2.Ver_Nr
                                         AND de.De_Conc_Item_Id = ai1.Item_Id
                                         AND de.De_Conc_Ver_Nr = ai1.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.DE_IDSEQ))
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     X.NCI_iDSEQ,
                     X.Item_Id,
                     X.VER_NR,
                     'DATA_ELEMENT_CONCEPT',
                     X.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'DE',
                     '');
        COMMIT;
END LOOP;

--Check VALUE_DOMAIN Relationship in DATA_ELEMENTS/DE
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR_M.data_elements  dae
       INNER JOIN ADMIN_ITEM ai3
           ON     ai3.nci_idseq = VD_IDSEQ
              --and ai1.Nci_Idseq = '99BA9DC8-44D9-4E69-E034-080020C9C0E0'
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN de de
                                      ON     De.Item_Id = ai2.Item_Id
                                         AND De.Ver_Nr = Ai2.Ver_Nr
                                         AND de.VAL_DOM_ITEM_ID = ai3.Item_Id
                                         AND de.VAL_DOM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.DE_IDSEQ))
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'VALUE_DOMAIN',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'DE',
                     '');
        COMMIT;
END LOOP;

--Check CONCEPTUAL DOMAIN relationship in DATA_ELEMENT_CONCEPTS/ DE_CONC
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR_M.DATA_ELEMENT_CONCEPTS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CD_IDSEQ
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN DE_CONC dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CONC_DOM_ITEM_ID = ai3.Item_Id
                                         AND dec.CONC_DOM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.DEC_IDSEQ))
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONCEPTUAL DOMAIN',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'DE_CONC',
                     '');
        COMMIT;
END LOOP;

--Check CONCEPTUAL DOMAIN relationship in VALUE_DOMAINS/ VALUE_DOM
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR_M.VALUE_DOMAINS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CD_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN VALUE_DOM dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CONC_DOM_ITEM_ID = ai3.Item_Id
                                         AND dec.CONC_DOM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.VD_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONCEPTUAL DOMAIN',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'VALUE_DOM',
                     '');
        COMMIT;
END LOOP;

--Check TRGT_OBJ_CLS relationship in OC_RECS_EXT/ NCI_OC_RECS
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBREXT_M.OC_RECS_EXT  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = T_OC_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_OC_RECS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.TRGT_OBJ_CLS_ITEM_ID = ai3.Item_Id
                                         AND dec.TRGT_OBJ_CLS_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.OCR_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'TRGT_OBJ_CLS',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_OC_RECS',
                     '');
        COMMIT;
END LOOP;

--Check SRC_OBJ_CLS relationship in OC_RECS_EXT/ NCI_OC_RECS
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBREXT_M.OC_RECS_EXT  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = S_OC_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_OC_RECS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.SRC_OBJ_CLS_ITEM_ID = ai3.Item_Id
                                         AND dec.SRC_OBJ_CLS_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.OCR_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'SRC_OBJ_CLS',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_OC_RECS',
                     '');
        COMMIT;
END LOOP;

--Check P_DE relationship in COMPLEX_DE_RELATIONSHIPS/ NCI_ADMIN_ITEM_REL
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR_M.COMPLEX_DE_RELATIONSHIPS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = P_DE_IDSEQ --FK 736 360
              WHERE NOT  EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON   dec.P_ITEM_ID = ai3.Item_Id
                                         AND dec.P_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.C_DE_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'P_DE',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;

--Check C_DE relationship in COMPLEX_DE_RELATIONSHIPS/ NCI_ADMIN_ITEM_REL
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR_M.COMPLEX_DE_RELATIONSHIPS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = C_DE_IDSEQ --FK 736 360
              WHERE NOT  EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON   dec.C_ITEM_ID = ai3.Item_Id
                                         AND dec.C_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.P_DE_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'C_DE',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;

--Check CONTE_IDSEQ relationship in DEFINITIONS/ ALT_DEF
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR_M.DEFINITIONS  dae, SBR_M.Administered_Components  ac, admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0
              AND NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN ALT_DEF dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CNTXT_ITEM_ID = ai3.Item_Id
                                         AND dec.CNTXT_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONTE_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'ALT_DEF',
                     '');
        COMMIT;
END LOOP;

--Check CONTE_IDSEQ relationship in DESIGNATIONS/ ALT_NMS
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR_M.DESIGNATIONS  dae, SBR_M.Administered_Components  ac, admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0
              AND NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN ALT_NMS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CNTXT_ITEM_ID = ai3.Item_Id
                                         AND dec.CNTXT_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONTE_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'ALT_NMS',
                     '');
        COMMIT;
END LOOP;

--Check CONTE_IDSEQ relationship in REFERENCE_DOCUMENTS/ REF
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR_M.REFERENCE_DOCUMENTS  dae, SBR_M.Administered_Components  ac, admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0
              AND NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN REF dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.NCI_CNTXT_ITEM_ID = ai3.Item_Id
                                         AND dec.NCI_CNTXT_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONTE_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'REF',
                     '');
        COMMIT;
END LOOP;

--Check VM_IDSEQ relationship in CD_VMS/ CONC_DOM_VAL_MEAN
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR_M.CD_VMS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = VM_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN CONC_DOM_VAL_MEAN dec
                                      ON     dec.CONC_DOM_ITEM_ID = ai2.Item_Id
                                         AND dec.CONC_DOM_VER_NR = Ai2.Ver_Nr
                                         AND dec.NCI_VAL_MEAN_ITEM_ID = ai3.Item_Id
                                         AND dec.NCI_VAL_MEAN_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.CD_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'VM_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'CONC_DOM_VAL_MEAN',
                     '');
        COMMIT;
END LOOP;

--Check CSI_IDSEQ relationship in CS_CSI/ NCI_CLSFCTN_SCHM_ITEM
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR_M.CS_CSI   dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CSI_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_CLSFCTN_SCHM_ITEM dec
                                      ON    dec.CS_ITEM_ID = ai2.Item_Id
                                         AND dec.CS_ITEM_VER_NR = ai2.Ver_Nr
                                         AND dae.CS_CSI_IDSEQ = dec.CS_CSI_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CS_CSI_FOR_CSI',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH CS/CSI for CSI',
                     SYSDATE,
                     USER,
                     'NCI_CLSFCTN_SCHM_ITEM',
                     '');
        COMMIT;
END LOOP;

--Check AC_IDSEQ relationship in AC_CSI/ NCI_CLSFCTN_SCHM_ITEM
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR_M.CS_CSI   dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CS_IDSEQ --FK
              WHERE  not EXISTS
                          (SELECT *
                             FROM admin_item  ai2
                                  INNER JOIN NCI_CLSFCTN_SCHM_ITEM dec
                                      ON    dec.CS_ITEM_ID = ai2.Item_Id
                                         AND dec.CS_ITEM_VER_NR = ai2.Ver_Nr
                                         AND dae.CS_CSI_IDSEQ = dec.CS_CSI_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CS_CSI_FOR_CS',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH CS/CSI for CS',
                     SYSDATE,
                     USER,
                     'NCI_CLSFCTN_SCHM_ITEM',
                     '');
        COMMIT;
END LOOP;

--Check AC_IDSEQ relationship in AC_CSI/ NCI_ADMIN_ITEM_REL (REL_TYP_ID/obj_key_id 65 AC>>CSI)
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.AC_CSI  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = AC_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON dec.C_ITEM_ID = ai3.Item_Id
                                         AND dec.C_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'AC_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH AC_CSI',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;

--Sprint 5 Tables

--Check PROTO_IDSEQ relationship in PROTOCOL_QC_EXT/ NCI_ADMIN_ITEM_REL

FOR Y IN (SELECT /*+ PARALEL(12)*/
           DISTINCT ai3.Item_Id,
                    ai3.Ver_Nr,
                    ai3.NCI_IDSEQ,
                    ai3.ITEM_LONG_NM
      FROM SBREXT_M.PROTOCOL_QC_EXT  dae
           INNER JOIN admin_item ai3
               ON     ai3.nci_idseq = proto_idseq --FK
               AND ai3.admin_item_typ_id = 50
                  WHERE NOT  EXISTS
                              (SELECT *
                                 FROM admin_item  ai2
                                      INNER JOIN NCI_ADMIN_ITEM_REL dec
                                          ON   dec.P_ITEM_ID = ai3.Item_Id
                                             AND dec.P_ITEM_VER_NR = ai3.Ver_Nr
                                             AND ai2.Nci_Idseq = dae.proto_idseq)) --PK
    LOOP
    INSERT INTO ONEDATA_MIGRATION_ERROR
                 VALUES (ERR_SEQ.NEXTVAL,
                         Y.NCI_iDSEQ,
                         Y.Item_Id,
                         Y.VER_NR,
                         'PROTO_IDSEQ',
                         Y.ITEM_LONG_NM,
                         'DATA MISMATCH',
                         SYSDATE,
                         USER,
                         'NCI_ADMIN_ITEM_REL',
                         '');
            COMMIT;
END LOOP;

--Check QC_IDSEQ relationship in PROTOCOL_QC_EXT/ NCI_ADMIN_ITEM_REL
FOR Y IN (SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBREXT_M.PROTOCOL_QC_EXT  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = qc_idseq --FK
           AND ai3.admin_item_typ_id = 54
              WHERE NOT  EXISTS
                          (SELECT *
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON   dec.C_ITEM_ID = ai3.Item_Id
                                         AND dec.C_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.qc_idseq)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'QC_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;

END;
/


DROP PROCEDURE ONEDATA_WA.SAG_FK_VALIDATE_REV;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.SAG_FK_VALIDATE_REV AS
--DECLARE
/*****************************************************
        Created By : Akhilesh Trikha
        Created on : 06/30/2020
        Version: 1.0
        Details: Compare Referential Integrity constraints between OneData table and caDSR table.
        Update History:

        *****************************************************/
BEGIN

--Check DATA_ELEMENT_CONCEPT Relationship in DATA_ELEMENTS/DE
FOR X IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai1.Item_Id,
                ai1.Ver_Nr,
                ai1.NCI_IDSEQ,
                ai1.ITEM_LONG_NM
  FROM sbr.data_elements  dae
       INNER JOIN ADMIN_ITEM ai1 ON ai1.nci_idseq = DEC_IDSEQ
              --and ai1.Nci_Idseq = '99BA9DC8-44D9-4E69-E034-080020C9C0E0'
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN de de
                                      ON     De.Item_Id = ai2.Item_Id
                                         AND De.Ver_Nr = Ai2.Ver_Nr
                                         AND de.De_Conc_Item_Id = ai1.Item_Id
                                         AND de.De_Conc_Ver_Nr = ai1.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.DE_IDSEQ))
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     X.NCI_iDSEQ,
                     X.Item_Id,
                     X.VER_NR,
                     'DATA_ELEMENT_CONCEPT',
                     X.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'DE',
                     '');
        COMMIT;
END LOOP;

--Check VALUE_DOMAIN Relationship in DATA_ELEMENTS/DE
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM sbr.data_elements  dae
       INNER JOIN ADMIN_ITEM ai3
           ON     ai3.nci_idseq = VD_IDSEQ
              --and ai1.Nci_Idseq = '99BA9DC8-44D9-4E69-E034-080020C9C0E0'
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN de de
                                      ON     De.Item_Id = ai2.Item_Id
                                         AND De.Ver_Nr = Ai2.Ver_Nr
                                         AND de.VAL_DOM_ITEM_ID = ai3.Item_Id
                                         AND de.VAL_DOM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.DE_IDSEQ))
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'VALUE_DOMAIN',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'DE',
                     '');
        COMMIT;
END LOOP;

--Check CONCEPTUAL DOMAIN relationship in DATA_ELEMENT_CONCEPTS/ DE_CONC
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.DATA_ELEMENT_CONCEPTS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CD_IDSEQ
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN DE_CONC dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CONC_DOM_ITEM_ID = ai3.Item_Id
                                         AND dec.CONC_DOM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.DEC_IDSEQ))
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONCEPTUAL DOMAIN',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'DE_CONC',
                     '');
        COMMIT;
END LOOP;

--Check CONCEPTUAL DOMAIN relationship in VALUE_DOMAINS/ VALUE_DOM
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.VALUE_DOMAINS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CD_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN VALUE_DOM dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CONC_DOM_ITEM_ID = ai3.Item_Id
                                         AND dec.CONC_DOM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.VD_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONCEPTUAL DOMAIN',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'VALUE_DOM',
                     '');
        COMMIT;
END LOOP;

--Check TRGT_OBJ_CLS relationship in OC_RECS_EXT/ NCI_OC_RECS
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBREXT.OC_RECS_EXT  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = T_OC_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_OC_RECS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.TRGT_OBJ_CLS_ITEM_ID = ai3.Item_Id
                                         AND dec.TRGT_OBJ_CLS_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.OCR_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'TRGT_OBJ_CLS',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_OC_RECS',
                     '');
        COMMIT;
END LOOP;

--Check SRC_OBJ_CLS relationship in OC_RECS_EXT/ NCI_OC_RECS
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBREXT.OC_RECS_EXT  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = S_OC_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_OC_RECS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.SRC_OBJ_CLS_ITEM_ID = ai3.Item_Id
                                         AND dec.SRC_OBJ_CLS_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.OCR_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'SRC_OBJ_CLS',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_OC_RECS',
                     '');
        COMMIT;
END LOOP;

--Check P_DE relationship in COMPLEX_DE_RELATIONSHIPS/ NCI_ADMIN_ITEM_REL
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.COMPLEX_DE_RELATIONSHIPS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = P_DE_IDSEQ --FK 736 360
              WHERE NOT  EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON   dec.P_ITEM_ID = ai3.Item_Id
                                         AND dec.P_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.C_DE_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'P_DE',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;

--Check C_DE relationship in COMPLEX_DE_RELATIONSHIPS/ NCI_ADMIN_ITEM_REL
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.COMPLEX_DE_RELATIONSHIPS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = C_DE_IDSEQ --FK 736 360
              WHERE NOT  EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON   dec.C_ITEM_ID = ai3.Item_Id
                                         AND dec.C_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.P_DE_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'C_DE',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;

--Check CONTE_IDSEQ relationship in DEFINITIONS/ ALT_DEF
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.DEFINITIONS  dae, sbr.Administered_Components  ac, admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0
              AND NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN ALT_DEF dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CNTXT_ITEM_ID = ai3.Item_Id
                                         AND dec.CNTXT_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONTE_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'ALT_DEF',
                     '');
        COMMIT;
END LOOP;

--Check CONTE_IDSEQ relationship in DESIGNATIONS/ ALT_NMS
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.DESIGNATIONS  dae, sbr.Administered_Components  ac, admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0
              AND NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN ALT_NMS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CNTXT_ITEM_ID = ai3.Item_Id
                                         AND dec.CNTXT_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONTE_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'ALT_NMS',
                     '');
        COMMIT;
END LOOP;

--Check CONTE_IDSEQ relationship in REFERENCE_DOCUMENTS/ REF
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.REFERENCE_DOCUMENTS  dae, sbr.Administered_Components  ac, admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0
              AND NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN REF dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.NCI_CNTXT_ITEM_ID = ai3.Item_Id
                                         AND dec.NCI_CNTXT_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONTE_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'REF',
                     '');
        COMMIT;
END LOOP;

--Check VM_IDSEQ relationship in CD_VMS/ CONC_DOM_VAL_MEAN
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.CD_VMS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = VM_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN CONC_DOM_VAL_MEAN dec
                                      ON     dec.CONC_DOM_ITEM_ID = ai2.Item_Id
                                         AND dec.CONC_DOM_VER_NR = Ai2.Ver_Nr
                                         AND dec.NCI_VAL_MEAN_ITEM_ID = ai3.Item_Id
                                         AND dec.NCI_VAL_MEAN_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.CD_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'VM_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'CONC_DOM_VAL_MEAN',
                     '');
        COMMIT;
END LOOP;

--Check CSI_IDSEQ relationship in CS_CSI/ NCI_CLSFCTN_SCHM_ITEM
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.CS_CSI   dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CSI_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_CLSFCTN_SCHM_ITEM dec
                                      ON    dec.CS_ITEM_ID = ai2.Item_Id
                                         AND dec.CS_ITEM_VER_NR = ai2.Ver_Nr
                                         AND dae.CS_CSI_IDSEQ = dec.CS_CSI_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CS_CSI_FOR_CSI',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH CS/CSI for CSI',
                     SYSDATE,
                     USER,
                     'NCI_CLSFCTN_SCHM_ITEM',
                     '');
        COMMIT;
END LOOP;

--Check AC_IDSEQ relationship in AC_CSI/ NCI_CLSFCTN_SCHM_ITEM
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.CS_CSI   dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CS_IDSEQ --FK
              WHERE  not EXISTS
                          (SELECT *
                             FROM admin_item  ai2
                                  INNER JOIN NCI_CLSFCTN_SCHM_ITEM dec
                                      ON    dec.CS_ITEM_ID = ai2.Item_Id
                                         AND dec.CS_ITEM_VER_NR = ai2.Ver_Nr
                                         AND dae.CS_CSI_IDSEQ = dec.CS_CSI_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CS_CSI_FOR_CS',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH CS/CSI for CS',
                     SYSDATE,
                     USER,
                     'NCI_CLSFCTN_SCHM_ITEM',
                     '');
        COMMIT;
END LOOP;

--Check AC_IDSEQ relationship in AC_CSI/ NCI_ADMIN_ITEM_REL (REL_TYP_ID/obj_key_id 65 AC>>CSI)
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.AC_CSI  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = AC_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON dec.C_ITEM_ID = ai3.Item_Id
                                         AND dec.C_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'AC_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH AC_CSI',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;

--Sprint 5 Tables

--Check PROTO_IDSEQ relationship in PROTOCOL_QC_EXT/ NCI_ADMIN_ITEM_REL

FOR Y IN (SELECT /*+ PARALEL(12)*/
           DISTINCT ai3.Item_Id,
                    ai3.Ver_Nr,
                    ai3.NCI_IDSEQ,
                    ai3.ITEM_LONG_NM
      FROM SBREXT.PROTOCOL_QC_EXT  dae
           INNER JOIN admin_item ai3
               ON     ai3.nci_idseq = proto_idseq --FK
               AND ai3.admin_item_typ_id = 50
                  WHERE NOT  EXISTS
                              (SELECT *
                                 FROM admin_item  ai2
                                      INNER JOIN NCI_ADMIN_ITEM_REL dec
                                          ON   dec.P_ITEM_ID = ai3.Item_Id
                                             AND dec.P_ITEM_VER_NR = ai3.Ver_Nr
                                             AND ai2.Nci_Idseq = dae.proto_idseq)) --PK
    LOOP
    INSERT INTO ONEDATA_MIGRATION_ERROR
                 VALUES (ERR_SEQ.NEXTVAL,
                         Y.NCI_iDSEQ,
                         Y.Item_Id,
                         Y.VER_NR,
                         'PROTO_IDSEQ',
                         Y.ITEM_LONG_NM,
                         'DATA MISMATCH',
                         SYSDATE,
                         USER,
                         'NCI_ADMIN_ITEM_REL',
                         '');
            COMMIT;
END LOOP;

--Check QC_IDSEQ relationship in PROTOCOL_QC_EXT/ NCI_ADMIN_ITEM_REL
FOR Y IN (SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBREXT.PROTOCOL_QC_EXT  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = qc_idseq --FK
           AND ai3.admin_item_typ_id = 54
              WHERE NOT  EXISTS
                          (SELECT *
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON   dec.C_ITEM_ID = ai3.Item_Id
                                         AND dec.C_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.qc_idseq)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'QC_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;

END;
/


DROP PROCEDURE ONEDATA_WA.SAG_ITEM_VALIDATION;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.SAG_ITEM_VALIDATION
AS
BEGIN
    /*****************************************************
    Created By : Akhilesh Trikha
    Created on : 06/24/2020
    Version: 1.0
    Details: Validate SBR and SBREXT tables
    Update History:

    *****************************************************/
    -- Validate sbr.DATA_ELEMENTS
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_DT,
                             CREAT_USR_ID,
                             LST_UPD_USR_ID,
                             TO_CHAR (REPLACE (FLD_DELETE, 0, 'No'))
                                 FLD_DELETE,
                             LST_UPD_DT
                        FROM DE
                       WHERE item_id <> -20005
                      UNION ALL
                      SELECT CDE_ID,
                             VERSION,
                             NVL (DATE_CREATED,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (CREATED_BY, 'ONEDATA'),
                             NVL (MODIFIED_BY, 'ONEDATA'),
                             DELETED_IND,
                             NVL (NVL (DATE_MODIFIED, DATE_CREATED),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy'))
                        FROM sbr_m.data_elements) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_DT,
                     CREAT_USR_ID,
                     LST_UPD_USR_ID,
                     FLD_DELETE,
                     LST_UPD_DT
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   DE_IDSEQ,
                   CDE_ID,
                   VERSION,
                   'DATAELEMENTS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'DE',
                   ''
              FROM sbr_m.data_elements
             WHERE CDE_id = x.ITEM_ID AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate CONTEXTS
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             LANG_ID,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM CNTXT
                       WHERE item_id <> -20005
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             1000,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr_m.contexts c, admin_item ai
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.conte_idseq)
                             AND ai.admin_item_typ_id = 8) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     LANG_ID,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   CONTE_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CONTEXTS',
                   NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CNTXT',
                   ''
              FROM sbr_m.contexts c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.conte_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate CONCEPTUAL_DOMAINS
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             DIMNSNLTY,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM CONC_DOM
                       WHERE item_id <> -20002
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             dimensionality,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr_m.conceptual_domains c, admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.cd_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     DIMNSNLTY,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   CONTE_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CONCEPTUAL_DOMAINS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CONC_DOM',
                   ''
              FROM sbr_m.conceptual_domains c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.cd_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate OBJECT_CLASSES_EXT
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM OBJ_CLS
                       WHERE item_id <> -20000
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext_m.OBJECT_CLASSES_EXT c,
                             admin_item    ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.oc_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   OC_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'OBJECT_CLASSES_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'OBJ_CLS',
                   ''
              FROM sbrext_m.object_classes_ext c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.oc_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate PROPERTIES_EXT
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM PROP
                       WHERE item_id <> -20001
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext_m.properties_ext c, admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.PROP_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   PROP_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'PROPERTIES_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'PROP',
                   ''
              FROM sbrext_m.properties_ext c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.PROP_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate CLASSIFICATION_SCHEMES
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CLSFCTN_SCHM_TYP_ID,
                             NCI_LABEL_TYP_FLG,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM CLSFCTN_SCHM
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             ok.obj_key_id,
                             label_type_flag,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr_m.classification_schemes c,
                             admin_item     ai,
                             obj_key        ok
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.CS_idseq)
                             AND TRIM (cstl_name) = ok.nci_cd
                             AND ok.obj_typ_id = 3) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CLSFCTN_SCHM_TYP_ID,
                     NCI_LABEL_TYP_FLG,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   CS_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CLASSIFICATION_SCHEMES',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CLSFCTN_SCHM',
                   ''
              FROM sbr_m.CLASSIFICATION_SCHEMES c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.cs_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate REPRESENTATIONS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM REP_CLS
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext_m.representations_ext c,
                             admin_item     ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.REP_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   REP_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'REPRESENTATIONS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'REP_CLS',
                   ''
              FROM sbrext_m.REPRESENTATIONS_EXT c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.REP_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate DATA_ELEMENT_CONCEPTS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             OBJ_CLS_QUAL,
                             PROP_QUAL,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM DE_CONC
                       WHERE item_id NOT IN -20003
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             c.version,
                             OBJ_CLASS_QUALIFIER,
                             PROPERTY_QUALIFIER,
                             NVL (c.created_by, 'ONEDATA'),
                             NVL (c.date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (c.date_modified, c.date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (c.modified_by, 'ONEDATA')
                        FROM sbr_m.DATA_ELEMENT_CONCEPTS  c,
                             admin_item      ai,
                             sbr_m.Administered_Components ac
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.dec_idseq)
                             AND c.CD_IDSEQ = ac_idseq
                             AND public_id > 0) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     OBJ_CLS_QUAL,
                     PROP_QUAL,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   DEC_IDSEQ,
                   ai.ITEM_ID,
                   c.VERSION,
                   'DATA_ELEMENT_CONCEPTS',
                   c.PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'DE_CONC',
                   ''
              FROM sbr_m.data_element_concepts    c,
                   admin_item        ai,
                   sbr_m.Administered_Components  ac
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.dec_idseq)
                   AND c.CD_IDSEQ = ac_idseq
                   AND public_id > 0
                   AND ai.ITEM_ID = x.ITEM_ID
                   AND c.VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate VALUE_DOMAINS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             NCI_DEC_PREC,
                             VAL_DOM_HIGH_VAL_NUM,
                             VAL_DOM_LOW_VAL_NUM,
                             VAL_DOM_MAX_CHAR,
                             VAL_DOM_MIN_CHAR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM VALUE_DOM
                       WHERE item_id <> -20004
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             decimal_place,
                             high_value_num,
                             low_value_num,
                             max_length_num,
                             min_length_num,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr_m.VALUE_DOMAINS c, admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.vd_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     NCI_DEC_PREC,
                     VAL_DOM_HIGH_VAL_NUM,
                     VAL_DOM_LOW_VAL_NUM,
                     VAL_DOM_MAX_CHAR,
                     VAL_DOM_MIN_CHAR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   vd_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'VALUE_DOMAINS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'VALUE_DOM',
                   ''
              FROM sbr_m.value_domains c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.vd_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate OC_RECS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             REL_TYP_NM,
                             SRC_ROLE,
                             TRGT_ROLE,
                             DRCTN,
                             SRC_LOW_MULT,
                             SRC_HIGH_MULT,
                             TRGT_LOW_MULT,
                             TRGT_HIGH_MULT,
                             DISP_ORD,
                             DIMNSNLTY,
                             ARRAY_IND
                        FROM NCI_OC_RECS
                      UNION ALL
                      SELECT ocr_id,
                             version,
                             rl_name,
                             source_role,
                             target_role,
                             direction,
                             source_low_multiplicity,
                             source_high_multiplicity,
                             target_low_multiplicity,
                             target_high_multiplicity,
                             display_order,
                             dimensionality,
                             array_ind
                        FROM sbrext_m.oc_recs_ext c, admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.t_oc_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     REL_TYP_NM,
                     SRC_ROLE,
                     TRGT_ROLE,
                     DRCTN,
                     SRC_LOW_MULT,
                     SRC_HIGH_MULT,
                     TRGT_LOW_MULT,
                     TRGT_HIGH_MULT,
                     DISP_ORD,
                     DIMNSNLTY,
                     ARRAY_IND
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   t_oc_idseq,
                   ITEM_ID,
                   VERSION,
                   'OC_RECS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_OC_RECS',
                   ''
              FROM sbrext_m.OC_RECS_EXT c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.t_oc_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate CONCEPTS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             evs_src_id,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM CNCPT
                      UNION ALL
                      SELECT con_id,
                             version,
                             ok.obj_key_id,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext_m.CONCEPTS_EXT c, obj_key ok
                       WHERE     c.evs_source = ok.obj_key_desc(+)
                             AND ok.obj_typ_id(+) = 23) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     evs_src_id,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   CON_IDSEQ,
                   con_id,
                   VERSION,
                   'CONCEPTS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CNCPT',
                   ''
              FROM sbrext_m.CONCEPTS_EXT c
             WHERE con_id = x.ITEM_ID AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate CS_ITEMS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CSI_DESC_TXT,
                             CSI_CMNTS,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM NCI_CLSFCTN_SCHM_ITEM
                      UNION ALL
                      SELECT item_id,
                             version,
                             description,
                             comments,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr_m.cs_items cd, admin_item ai
                       WHERE ai.NCI_IDSEQ = cd.CSI_IDSEQ) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CSI_DESC_TXT,
                     CSI_CMNTS,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   CSI_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CS_ITEMS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_CLSFCTN_SCHM_ITEM',
                   ''
              FROM sbr_m.CS_ITEMS cd, admin_item ai
             WHERE     ai.NCI_IDSEQ = cd.CSI_IDSEQ
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate VALUE_MEANINGS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             VM_DESC_TXT,
                             VM_CMNTS,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM NCI_VAL_MEAN
                      UNION ALL
                      SELECT item_id,
                             version,
                             description,
                             comments,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr_m.VALUE_MEANINGS cd, admin_item ai
                       WHERE ai.NCI_IDSEQ = cd.VM_IDSEQ) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     VM_DESC_TXT,
                     VM_CMNTS,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   VM_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'VALUE_MEANINGS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_VAL_MEAN',
                   ''
              FROM sbr_m.value_meanings cd, admin_item ai
             WHERE     ai.NCI_IDSEQ = cd.VM_IDSEQ
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate QUEST_CONTENTS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             catgry_id,
                             form_typ_id,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM NCI_FORM
                      UNION ALL
                      SELECT qc_id,
                             version,
                             ok.obj_key_id,
                             DECODE (qc.qtl_name,  'CRF', 70,  'TEMPLATE', 71),
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext_m.quest_contents_ext qc,
                             obj_key       ok
                       WHERE     qc.qcdl_name = ok.nci_cd(+)
                             AND ok.obj_typ_id(+) = 22
                             AND qc.qtl_name IN ('TEMPLATE', 'CRF')) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     catgry_id,
                     form_typ_id,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   QC_IDSEQ,
                   qc_id,
                   VERSION,
                   'QUEST_CONTENTS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_FORM',
                   ''
              FROM sbrext_m.QUEST_CONTENTS_EXT
             WHERE qc_id = x.ITEM_ID AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate PROTOCOLS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             PROTCL_TYP_ID,
                             PROTCL_ID,
                             LEAD_ORG,
                             PROTCL_PHASE,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID,
                             CHNG_TYP,
                             CHNG_NBR,
                             RVWD_DT,
                             RVWD_USR_ID,
                             APPRVD_DT,
                             APPRVD_USR_ID
                        FROM NCI_PROTCL
                      UNION ALL
                      SELECT ai.item_id,
                             version,
                             ok.obj_key_id,
                             protocol_id,
                             LEAD_ORG,
                             PHASE,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA'),
                                 CHANGE_TYPE,
                             CHANGE_NUMBER,
                             REVIEWED_DATE,
                             REVIEWED_BY,
                             APPROVED_DATE,
                             APPROVED_BY
                        FROM sbrext_m.PROTOCOLS_EXT cd,
                             admin_item ai,
                             obj_key   ok
                       WHERE     ai.NCI_IDSEQ = cd.proto_IDSEQ
                             AND TRIM (TYPE) = ok.nci_cd(+)
                             AND ok.obj_typ_id(+) = 19
                             AND ai.admin_item_typ_id = 50) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     PROTCL_TYP_ID,
                     PROTCL_ID,
                     LEAD_ORG,
                     PROTCL_PHASE,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID,
                     CHNG_TYP,
                     CHNG_NBR,
                     RVWD_DT,
                     RVWD_USR_ID,
                     APPRVD_DT,
                     APPRVD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   proto_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'PROTOCOLS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_PROTCL',
                   ''
              FROM sbrext_m.protocols_ext cd, admin_item ai
             WHERE     ai.NCI_IDSEQ = cd.proto_IDSEQ
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate VALID_QUESTION_VALUES
    FOR x
        IN (  SELECT DISTINCT NCI_PUB_ID,                       --Primary Keys
                                          Q_VER_NR
                FROM (SELECT NCI_PUB_ID,
                             Q_PUB_ID,
                             Q_VER_NR,
                             VM_NM,
                             VM_DEF,
                             VALUE,
                             NCI_IDSEQ,
                             DESC_TXT,
                             MEAN_TXT,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM NCI_QUEST_VALID_VALUE
                      UNION ALL
                      SELECT qc.qc_id,
                             qc1.qc_id,
                             qc1.VERSION,
                             qc.preferred_name,
                             qc.preferred_definition,
                             qc.long_name,
                             qc.qc_idseq,
                             vv.description_text,
                             vv.meaning_text,
                             NVL (qc.created_by, 'ONEDATA'),
                             NVL (qc.DATE_CREATED,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (qc.date_modified, qc.date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (qc.modified_by, 'ONEDATA')
                        FROM sbrext_m.QUEST_CONTENTS_EXT  qc,
                             sbrext_m.quest_contents_ext  qc1,
                             sbrext_m.valid_values_att_ext vv
                       WHERE     qc.qtl_name = 'VALID_VALUE'
                             AND qc1.qtl_name = 'QUESTION'
                             AND qc1.qc_idseq = qc.p_qst_idseq
                             AND qc.qc_idseq = vv.qc_idseq(+)) t
            GROUP BY NCI_PUB_ID,
                     Q_PUB_ID,
                     Q_VER_NR,
                     VM_NM,
                     VM_DEF,
                     VALUE,
                     NCI_IDSEQ,
                     DESC_TXT,
                     MEAN_TXT,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY NCI_PUB_ID, Q_VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   vv.qc_idseq,
                   qc_id,
                   VERSION,
                   'VALID_QUESTION_VALUES',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_QUEST_VALID_VALUE',
                   ''
              FROM sbrext_m.valid_values_att_ext  vv,
                   sbrext_m.quest_contents_ext    qc
             WHERE     qc.qc_idseq = vv.qc_idseq
                   AND qc_id = x.NCI_PUB_ID
                   AND VERSION = x.Q_VER_NR;

        COMMIT;
    END LOOP;

--Sprint 5 Tables

--Validate COMPLEX_DATA_ELEMENTS
FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (SELECT DISTINCT de.ITEM_ID,                          --Primary Keys
                                           de.VER_NR, DERV_MTHD,
                            DERV_RUL,
                            de.DERV_TYP_ID,
                            de.CONCAT_CHAR,
                            DERV_DE_IND
                            from de , admin_item ai, sbr_m.complex_data_elements  cdr
                            WHERE de.item_id = ai.item_id
                           AND de.ver_nr = ai.ver_nr
                           AND cdr.p_de_idseq = ai.nci_idseq
                          UNION ALL
                          SELECT DISTINCT ai.ITEM_ID,                          --Primary Keys
                                           ai.VER_NR, METHODS,
                           RULE,
                           o.obj_key_id,
                           cdr.CONCAT_CHAR,
                           1
                      FROM sbr_m.complex_data_elements  cdr,
                           obj_key                    o,
                           admin_item                 ai
                     WHERE     cdr.CRTL_NAME = o.nci_cd(+)
                           AND o.obj_typ_id(+) = 21
                           AND cdr.p_de_idseq = ai.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR
                  HAVING COUNT (*) <> 2
                  ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
		                   NCI_IDSEQ,
		                   de.ITEM_ID,
		                   de.VER_NR,
		                   'COMPLEX_DATA_ELEMENTS',
		                   ITEM_NM,
		                   'DATA MISMATCH',
		                   SYSDATE,
		                   USER,
		                   'DE',
		                   ''
		              FROM DE,admin_item ai
		             WHERE ai.ITEM_ID=de.ITEM_ID and ai.VER_NR=de.VER_NR
             AND de.ITEM_ID = x.ITEM_ID AND de.VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=5
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=5
    UNION ALL
    SELECT con.item_id,
                   con.ver_nr,
                   oc.item_id,
                   oc.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
               FROM sbrext_m.COMPONENT_CONCEPTS_EXT  cc,
                   sbrext_m.object_classes_ext      oce,
                   admin_item                     con,
                   admin_item                     oc
             WHERE     cc.CONDR_IDSEQ = oce.CONDR_IDSEQ
                   AND oce.oc_idseq = oc.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH OBJECT_CLASSES_EXT',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=6
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=6 --106,987
    UNION ALL
    SELECT con.item_id, --106,910
                   con.ver_nr,
                   prop.item_id,
                   prop.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext_m.COMPONENT_CONCEPTS_EXT  cc,
                   sbrext_m.properties_ext          prope,
                   admin_item                     con,
                   admin_item                     prop
             WHERE     cc.CONDR_IDSEQ = prope.CONDR_IDSEQ
                   AND prope.prop_idseq = prop.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH PROPERTIES_EXT',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=7
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=7 --28,142
    UNION ALL
    SELECT con.item_id,
                   con.ver_nr,
                   rep.item_id,
                   rep.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext_m.COMPONENT_CONCEPTS_EXT  cc,
                   sbrext_m.representations_ext     repe,
                   admin_item                     con,
                   admin_item                     rep
             WHERE     cc.CONDR_IDSEQ = repe.CONDR_IDSEQ
                   AND Repe.rep_idseq = rep.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH REPRESENTATIONS_EXT',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=53

    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=53 --85,641
    UNION ALL
    SELECT con.item_id,--85,641
                   con.ver_nr,
                   rep.item_id,
                   rep.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext_m.COMPONENT_CONCEPTS_EXT  cc,
                   sbr_m.value_meanings             vm,
                   admin_item                     con,
                   admin_item                     rep
             WHERE     cc.CONDR_IDSEQ = vm.CONDR_IDSEQ
                   AND vm.vm_idseq = rep.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH VALUE_MEANINGS',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=3
  FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (Select cncpt_item_id,
                                  cncpt_ver_nr,
                                  cai.item_id,
                                  cai.ver_nr,
                                  cai.nci_ord,
                                  cai.nci_prmry_ind,
                                  nci_cncpt_val,
                                  cai.CREAT_USR_ID,
                                  cai.CREAT_DT,
                                  cai.LST_UPD_DT,
                                  cai.LST_UPD_USR_ID
from cncpt_admin_item cai, admin_item ai
where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
and ADMIN_ITEM_TYP_ID=3 --85,641
UNION ALL
SELECT con.item_id,
               con.ver_nr,
               vd.item_id,
               vd.ver_nr,
               cc.DISPLAY_ORDER,
               DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
               concept_value,
        nvl(cc.created_by,'ONEDATA'),
               nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
               nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
               nvl(cc.modified_by,'ONEDATA')
          FROM sbrext_m.COMPONENT_CONCEPTS_EXT  cc,
               sbr_m.value_domains              vde,
               admin_item                     con,
               admin_item                     vd
         WHERE     cc.CONDR_IDSEQ = vde.CONDR_IDSEQ
               AND vde.vd_idseq = vd.nci_idseq
               AND cc.con_idseq = con.nci_idseq) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_DT,
                     CREAT_USR_ID,
                     LST_UPD_USR_ID,
                     LST_UPD_DT,
                     nci_ord
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   NCI_IDSEQ,
                   ITEM_ID,
                   VER_NR,
                   'COMPONENT_CONCEPTS_EXT',
                   ITEM_NM,
                   'DATA MISMATCH VALUE_DOMAINS',
                   SYSDATE,
                   USER,
                   'CNCPT_ADMIN_ITEM',
                   ''
              FROM ADMIN_ITEM
             WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

        COMMIT;
    END LOOP;

 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=1
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=1
    UNION ALL
    SELECT con.item_id,
                   con.ver_nr,
                   cd.item_id,
                   cd.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext_m.COMPONENT_CONCEPTS_EXT  cc,
                   sbr_m.conceptual_domains         cde,
                   admin_item                     con,
                   admin_item                     cd
             WHERE     cc.CONDR_IDSEQ = cde.CONDR_IDSEQ
                   AND cde.cd_idseq = cd.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH CONCEPTUAL_DOMAINS',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

--Validate  PERMISSIBLE_VALUES
    FOR x
            IN (  SELECT DISTINCT VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR
                    FROM (Select PERM_VAL_BEG_DT,
                              PERM_VAL_END_DT,
                              PERM_VAL_NM,
                              PERM_VAL_DESC_TXT,
                              VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR,
                              CREAT_DT,
                              CREAT_USR_ID,
                              LST_UPD_DT,
                              LST_UPD_USR_ID,
                              NCI_VAL_MEAN_ITEM_ID,
                              NCI_VAL_MEAN_VER_NR,
                              NCI_IDSEQ
    from PERM_VAL
    UNION ALL
    SELECT pvs.BEGIN_DATE,
                   pvs.END_DATE,
                   VALUE,
                   SHORT_MEANING,
                   vd.item_id,
                   vd.ver_nr,
                   nvl(pvs.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(pvs.created_by,'ONEDATA'),
                   nvl(NVL (pvs.date_modified, pvs.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(pvs.modified_by,'ONEDATA'),
                   vm.item_id,
                   vm.ver_nr,
                   pvs.vp_idseq
              FROM sbr_m.PERMISSIBLE_VALUES  pv,
                   admin_item              vm,
                   admin_item              vd,
                   sbr_m.vd_pvs              pvs
             WHERE     pv.pv_idseq = pvs.pv_idseq
                   AND pvs.vd_idseq = vd.nci_idseq
                   AND pv.vm_idseq = vm.nci_idseq) t
                GROUP BY PERM_VAL_BEG_DT,
                              PERM_VAL_END_DT,
                              PERM_VAL_NM,
                              PERM_VAL_DESC_TXT,
                              VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR,
                              CREAT_DT,
                              CREAT_USR_ID,
                              LST_UPD_DT,
                              LST_UPD_USR_ID,
                              NCI_VAL_MEAN_ITEM_ID,
                              NCI_VAL_MEAN_VER_NR,
                              NCI_IDSEQ
                  HAVING COUNT (*) <> 2
                ORDER BY VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'PERMISSIBLE_VALUES',
                       ITEM_NM,
                       'DATA MISMATCH',
                       SYSDATE,
                       USER,
                       'PERM_VAL',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.VAL_DOM_ITEM_ID AND VER_NR = x.VAL_DOM_VER_NR;

            COMMIT;
    END LOOP;

--Validate QUEST_VV_EXT
FOR x
        IN (  SELECT DISTINCT VV_PUB_ID,
                                  VV_VER_NR
                FROM (select DISTINCT VV_PUB_ID,
                                  VV_VER_NR,
                                  VAL,
                                  EDIT_IND,
                                  REP_SEQ
from NCI_QUEST_VV_REP
UNION ALL
SELECT   DISTINCT vv.NCI_PUB_ID,
               vv.NCI_VER_NR,
               qvv.VALUE,
               DECODE (editable_ind,  'Yes', 1,  'No', 0),
               repeat_sequence
          FROM sbrext_m.QUEST_VV_EXT         qvv,
               NCI_QUEST_VALID_VALUE       vv
         WHERE    qvv.vv_idseq = vv.NCI_IDSEQ(+)) t
            GROUP BY VV_PUB_ID,
                                  VV_VER_NR,
                                  VAL,
                                  EDIT_IND,
                                  REP_SEQ
              HAVING COUNT (*) <> 2
              ORDER BY VV_PUB_ID,
                                  VV_VER_NR)
LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   NCI_IDSEQ,
                   NCI_PUB_ID,
                   NCI_VER_NR,
                   'QUEST_VV_EXT',
                   VM_NM,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_QUEST_VV_REP',
                   ''
              FROM NCI_QUEST_VALID_VALUE
             WHERE NCI_PUB_ID = x.VV_PUB_ID AND NCI_VER_NR = x.VV_VER_NR;
        COMMIT;
    END LOOP;

  --Validate REFERENCE_BLOBS
    FOR x
            IN (  SELECT DISTINCT FILE_NM
                    FROM (select FILE_NM,
                             NCI_MIME_TYPE,
                             NCI_DOC_SIZE,
                             NCI_CHARSET,
                             NCI_DOC_LST_UPD_DT,
                             BLOB_COL,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_USR_ID,
                             LST_UPD_DT
    FROM ref_doc
    UNION ALL
            SELECT rb.NAME,
                   MIME_TYPE,
                   DOC_SIZE,
                   DAD_CHARSET,
                   LAST_UPDATED,
                   TO_BLOB(BLOB_CONTENT),
                   NVL (created_by, 'ONEDATA'),
                   NVL (date_created, TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                   NVL (modified_by, 'ONEDATA'),
                   NVL (NVL (date_modified, date_created),
                        TO_DATE ('8/18/2020', 'mm/dd/yyyy'))
              FROM  sbr_m.REFERENCE_BLOBS rb) t
                GROUP BY FILE_NM,
                             NCI_MIME_TYPE,
                             NCI_DOC_SIZE,
                             NCI_CHARSET,
                             NCI_DOC_LST_UPD_DT,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_USR_ID,
                             LST_UPD_DT
                  HAVING COUNT (*) <> 2
                  ORDER BY FILE_NM)
    LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NULL,
                       NULL,
                       NULL,
                       'REFERENCE_BLOBS',
                       x.FILE_NM,
                       'DATA MISMATCH',
                       SYSDATE,
                       USER,
                       'REF_DOC',
                       ''
                  FROM DUAL;
            COMMIT;
        END LOOP;

--Validate TA_PROTO_CSI_EXT
FOR x
        IN (  SELECT DISTINCT TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR
                FROM (select TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT from NCI_FORM_TA_REL
UNION ALL
        SELECT ta.ta_id,
               ai.item_id,
               ai.ver_nr,
               nvl(t.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
          nvl(t.created_by,'ONEDATA'),
               nvl(t.modified_by,'ONEDATA'),
             nvl(NVL (t.date_modified, t.date_created), to_date('8/18/2020','mm/dd/yyyy'))
          FROM nci_form_ta ta, sbrext_m.TA_PROTO_CSI_EXT t, admin_item ai
         WHERE     ta.ta_idseq = t.ta_idseq
               AND t.proto_idseq = ai.nci_idseq
               AND t.proto_idseq IS NOT NULL) t
            GROUP BY TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT
              HAVING COUNT (*) <> 2
              ORDER BY TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR)
LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   NCI_idseq,
                   item_id,
                   ver_nr,
                   'TA_PROTO_CSI_EXT',
                   ITEM_NM,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_FORM_TA_REL',
                   ''
              FROM  nci_form_ta ta, sbrext_m.ta_proto_csi_ext t, admin_item ai
         WHERE     ta.ta_idseq = t.ta_idseq
               AND t.proto_idseq = ai.nci_idseq
               AND t.proto_idseq IS NOT NULL and ta_ID=x.ta_ID;
        COMMIT;
    END LOOP;

--Validate  TRIGGERED_ACTIONS_EXT
    FOR x
            IN (  SELECT DISTINCT TA_IDSEQ
                    FROM (Select
                                 TA_INSTR,
                                 SRC_TYP_NM,
                                 TRGT_TYP_NM,
                                 TA_IDSEQ,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT From NCI_FORM_TA
    UNION ALL
     SELECT      TA_INSTRUCTION,
                   S_QTL_NAME,
                   T_QTL_NAME,
                   TA_IDSEQ,
                   nvl(ta.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
              nvl(ta.created_by,'ONEDATA'),
                   nvl(ta.modified_by,'ONEDATA'),
                 nvl(NVL (ta.date_modified, ta.date_created), to_date('8/18/2020','mm/dd/yyyy'))
              FROM sbrext_m.TRIGGERED_ACTIONS_EXT  ta) t
                GROUP BY TA_INSTR,
                                 SRC_TYP_NM,
                                 TRGT_TYP_NM,
                                 TA_IDSEQ,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT
                  HAVING COUNT (*) <> 2
                  ORDER BY TA_IDSEQ)
    LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       TA_IDSEQ,
                       ac1.public_id,
                       ac1.version,
                       'TRIGGERED_ACTIONS_EXT',
                       ac1.PREFERRED_NAME,
                       'DATA MISMATCH',
                       SYSDATE,
                       USER,
                       'NCI_FORM_TA',
                       ''
                  from sbrext_m.triggered_actions_ext,sbr_m.administered_components ac1, sbr_m.administered_components ac2
                    where ac1.ac_idseq = S_QC_IDSEQ
                    and ac2.ac_idseq = S_QC_IDSEQ
                    and TA_IDSEQ=x.TA_IDSEQ;
            COMMIT;
        END LOOP;

--Validate VD_PVS
FOR x
        IN (  SELECT DISTINCT VAL_DOM_ITEM_ID,VAL_DOM_VER_NR,NCI_IDSEQ
                FROM (select DISTINCT PERM_VAL_BEG_DT,
                          PERM_VAL_END_DT,
                          VAL_DOM_ITEM_ID,
                          VAL_DOM_VER_NR,
                          CREAT_USR_ID,
                          CREAT_DT,
                          LST_UPD_DT,
                          LST_UPD_USR_ID,
                          NCI_IDSEQ,NCI_ORIGIN from  PERM_VAL
UNION ALL
        SELECT DISTINCT pvs.BEGIN_DATE,
               pvs.END_DATE,
               vd.item_id,
               vd.ver_nr,
               nvl(pvs.created_by,'ONEDATA'),
               nvl(pvs.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
               nvl(NVL (pvs.date_modified, pvs.date_created), to_date('8/18/2020','mm/dd/yyyy')),
               nvl(pvs.modified_by,'ONEDATA'),
               pvs.vp_idseq, pvs.ORIGIN
          FROM sbr_m.PERMISSIBLE_VALUES  pv,
               admin_item              vd,
               sbr_m.vd_pvs              pvs
         WHERE     pv.pv_idseq = pvs.pv_idseq
               AND pvs.vd_idseq = vd.nci_idseq ) t
            GROUP BY VAL_DOM_ITEM_ID,VAL_DOM_VER_NR,PERM_VAL_BEG_DT,
                          PERM_VAL_END_DT,
                          CREAT_USR_ID,
                          CREAT_DT,
                          LST_UPD_DT,
                          LST_UPD_USR_ID,
                          NCI_IDSEQ
              HAVING COUNT (*) <> 2
              ORDER BY VAL_DOM_ITEM_ID,VAL_DOM_VER_NR,NCI_IDSEQ)
LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   x.NCI_IDSEQ,
                   x.VAL_DOM_ITEM_ID,
                   x.VAL_DOM_VER_NR,
                   'VD_PVS',
                   NULL,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'PERM_VAL',
                   ''
              from dual;
        COMMIT;
    END LOOP;

END;
/


DROP PROCEDURE ONEDATA_WA.SAG_ITEM_VALIDATION_REV;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.SAG_ITEM_VALIDATION_REV
AS
BEGIN
    /*****************************************************
    Created By : Akhilesh Trikha
    Created on : 06/24/2020
    Version: 1.0
    Details: Validate SBR and SBREXT tables
    Update History:

    *****************************************************/
    -- Validate sbr.DATA_ELEMENTS
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_DT,
                             CREAT_USR_ID,
                             LST_UPD_USR_ID,
                             TO_CHAR (REPLACE (FLD_DELETE, 0, 'No'))
                                 FLD_DELETE,
                             LST_UPD_DT
                        FROM DE
                       WHERE item_id <> -20005
                      UNION ALL
                      SELECT CDE_ID,
                             VERSION,
                             NVL (DATE_CREATED,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (CREATED_BY, 'ONEDATA'),
                             NVL (MODIFIED_BY, 'ONEDATA'),
                             DELETED_IND,
                             NVL (NVL (DATE_MODIFIED, DATE_CREATED),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy'))
                        FROM sbr.data_elements) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_DT,
                     CREAT_USR_ID,
                     LST_UPD_USR_ID,
                     FLD_DELETE,
                     LST_UPD_DT
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   DE_IDSEQ,
                   CDE_ID,
                   VERSION,
                   'DATAELEMENTS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'DE',
                   ''
              FROM sbr.data_elements
             WHERE CDE_id = x.ITEM_ID AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate CONTEXTS
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             LANG_ID,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM CNTXT
                       WHERE item_id <> -20005
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             1000,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.contexts c, admin_item ai
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.conte_idseq)
                             AND ai.admin_item_typ_id = 8) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     LANG_ID,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   CONTE_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CONTEXTS',
                   NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CNTXT',
                   ''
              FROM sbr.contexts c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.conte_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate CONCEPTUAL_DOMAINS
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             DIMNSNLTY,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM CONC_DOM
                       WHERE item_id <> -20002
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             dimensionality,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.conceptual_domains c, admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.cd_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     DIMNSNLTY,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   CONTE_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CONCEPTUAL_DOMAINS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CONC_DOM',
                   ''
              FROM sbr.conceptual_domains c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.cd_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate OBJECT_CLASSES_EXT
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM OBJ_CLS
                       WHERE item_id <> -20000
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.OBJECT_CLASSES_EXT c,
                             admin_item    ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.oc_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   OC_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'OBJECT_CLASSES_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'OBJ_CLS',
                   ''
              FROM sbrext.object_classes_ext c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.oc_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate PROPERTIES_EXT
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM PROP
                       WHERE item_id <> -20001
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.properties_ext c, admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.PROP_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   PROP_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'PROPERTIES_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'PROP',
                   ''
              FROM sbrext.properties_ext c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.PROP_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate CLASSIFICATION_SCHEMES
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CLSFCTN_SCHM_TYP_ID,
                             NCI_LABEL_TYP_FLG,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM CLSFCTN_SCHM
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             ok.obj_key_id,
                             label_type_flag,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.classification_schemes c,
                             admin_item     ai,
                             obj_key        ok
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.CS_idseq)
                             AND TRIM (cstl_name) = ok.nci_cd
                             AND ok.obj_typ_id = 3) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CLSFCTN_SCHM_TYP_ID,
                     NCI_LABEL_TYP_FLG,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   CS_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CLASSIFICATION_SCHEMES',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CLSFCTN_SCHM',
                   ''
              FROM sbr.CLASSIFICATION_SCHEMES c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.cs_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate REPRESENTATIONS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM REP_CLS
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.representations_ext c,
                             admin_item     ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.REP_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   REP_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'REPRESENTATIONS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'REP_CLS',
                   ''
              FROM sbrext.REPRESENTATIONS_EXT c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.REP_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate DATA_ELEMENT_CONCEPTS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             OBJ_CLS_QUAL,
                             PROP_QUAL,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM DE_CONC
                       WHERE item_id NOT IN -20003
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             c.version,
                             OBJ_CLASS_QUALIFIER,
                             PROPERTY_QUALIFIER,
                             NVL (c.created_by, 'ONEDATA'),
                             NVL (c.date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (c.date_modified, c.date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (c.modified_by, 'ONEDATA')
                        FROM sbr.DATA_ELEMENT_CONCEPTS  c,
                             admin_item      ai,
                             sbr.Administered_Components ac
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.dec_idseq)
                             AND c.CD_IDSEQ = ac_idseq
                             AND public_id > 0) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     OBJ_CLS_QUAL,
                     PROP_QUAL,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   DEC_IDSEQ,
                   ai.ITEM_ID,
                   c.VERSION,
                   'DATA_ELEMENT_CONCEPTS',
                   c.PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'DE_CONC',
                   ''
              FROM sbr.data_element_concepts    c,
                   admin_item        ai,
                   sbr.Administered_Components  ac
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.dec_idseq)
                   AND c.CD_IDSEQ = ac_idseq
                   AND public_id > 0
                   AND ai.ITEM_ID = x.ITEM_ID
                   AND c.VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate VALUE_DOMAINS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             NCI_DEC_PREC,
                             VAL_DOM_HIGH_VAL_NUM,
                             VAL_DOM_LOW_VAL_NUM,
                             VAL_DOM_MAX_CHAR,
                             VAL_DOM_MIN_CHAR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM VALUE_DOM
                       WHERE item_id <> -20004
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             decimal_place,
                             high_value_num,
                             low_value_num,
                             max_length_num,
                             min_length_num,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.VALUE_DOMAINS c, admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.vd_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     NCI_DEC_PREC,
                     VAL_DOM_HIGH_VAL_NUM,
                     VAL_DOM_LOW_VAL_NUM,
                     VAL_DOM_MAX_CHAR,
                     VAL_DOM_MIN_CHAR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   vd_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'VALUE_DOMAINS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'VALUE_DOM',
                   ''
              FROM sbr.value_domains c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.vd_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate OC_RECS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             REL_TYP_NM,
                             SRC_ROLE,
                             TRGT_ROLE,
                             DRCTN,
                             SRC_LOW_MULT,
                             SRC_HIGH_MULT,
                             TRGT_LOW_MULT,
                             TRGT_HIGH_MULT,
                             DISP_ORD,
                             DIMNSNLTY,
                             ARRAY_IND
                        FROM NCI_OC_RECS
                      UNION ALL
                      SELECT ocr_id,
                             version,
                             rl_name,
                             source_role,
                             target_role,
                             direction,
                             source_low_multiplicity,
                             source_high_multiplicity,
                             target_low_multiplicity,
                             target_high_multiplicity,
                             display_order,
                             dimensionality,
                             array_ind
                        FROM sbrext.oc_recs_ext c, admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.t_oc_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     REL_TYP_NM,
                     SRC_ROLE,
                     TRGT_ROLE,
                     DRCTN,
                     SRC_LOW_MULT,
                     SRC_HIGH_MULT,
                     TRGT_LOW_MULT,
                     TRGT_HIGH_MULT,
                     DISP_ORD,
                     DIMNSNLTY,
                     ARRAY_IND
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   t_oc_idseq,
                   ITEM_ID,
                   VERSION,
                   'OC_RECS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_OC_RECS',
                   ''
              FROM sbrext.OC_RECS_EXT c, admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.t_oc_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate CONCEPTS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             evs_src_id,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM CNCPT
                      UNION ALL
                      SELECT con_id,
                             version,
                             ok.obj_key_id,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.CONCEPTS_EXT c, obj_key ok
                       WHERE     c.evs_source = ok.obj_key_desc(+)
                             AND ok.obj_typ_id(+) = 23) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     evs_src_id,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   CON_IDSEQ,
                   con_id,
                   VERSION,
                   'CONCEPTS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CNCPT',
                   ''
              FROM sbrext.CONCEPTS_EXT c
             WHERE con_id = x.ITEM_ID AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate CS_ITEMS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CSI_DESC_TXT,
                             CSI_CMNTS,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM NCI_CLSFCTN_SCHM_ITEM
                      UNION ALL
                      SELECT item_id,
                             version,
                             description,
                             comments,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.cs_items cd, admin_item ai
                       WHERE ai.NCI_IDSEQ = cd.CSI_IDSEQ) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CSI_DESC_TXT,
                     CSI_CMNTS,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   CSI_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CS_ITEMS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_CLSFCTN_SCHM_ITEM',
                   ''
              FROM sbr.CS_ITEMS cd, admin_item ai
             WHERE     ai.NCI_IDSEQ = cd.CSI_IDSEQ
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate VALUE_MEANINGS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             VM_DESC_TXT,
                             VM_CMNTS,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM NCI_VAL_MEAN
                      UNION ALL
                      SELECT item_id,
                             version,
                             description,
                             comments,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.VALUE_MEANINGS cd, admin_item ai
                       WHERE ai.NCI_IDSEQ = cd.VM_IDSEQ) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     VM_DESC_TXT,
                     VM_CMNTS,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   VM_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'VALUE_MEANINGS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_VAL_MEAN',
                   ''
              FROM sbr.value_meanings cd, admin_item ai
             WHERE     ai.NCI_IDSEQ = cd.VM_IDSEQ
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate QUEST_CONTENTS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             catgry_id,
                             form_typ_id,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM NCI_FORM
                      UNION ALL
                      SELECT qc_id,
                             version,
                             ok.obj_key_id,
                             DECODE (qc.qtl_name,  'CRF', 70,  'TEMPLATE', 71),
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.quest_contents_ext qc,
                             obj_key       ok
                       WHERE     qc.qcdl_name = ok.nci_cd(+)
                             AND ok.obj_typ_id(+) = 22
                             AND qc.qtl_name IN ('TEMPLATE', 'CRF')) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     catgry_id,
                     form_typ_id,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   QC_IDSEQ,
                   qc_id,
                   VERSION,
                   'QUEST_CONTENTS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_FORM',
                   ''
              FROM sbrext.QUEST_CONTENTS_EXT
             WHERE qc_id = x.ITEM_ID AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate PROTOCOLS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             PROTCL_TYP_ID,
                             PROTCL_ID,
                             LEAD_ORG,
                             PROTCL_PHASE,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID,
                             CHNG_TYP,
                             CHNG_NBR,
                             RVWD_DT,
                             RVWD_USR_ID,
                             APPRVD_DT,
                             APPRVD_USR_ID
                        FROM NCI_PROTCL
                      UNION ALL
                      SELECT ai.item_id,
                             version,
                             ok.obj_key_id,
                             protocol_id,
                             LEAD_ORG,
                             PHASE,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA'),
                                 CHANGE_TYPE,
                             CHANGE_NUMBER,
                             REVIEWED_DATE,
                             REVIEWED_BY,
                             APPROVED_DATE,
                             APPROVED_BY
                        FROM sbrext.PROTOCOLS_EXT cd,
                             admin_item ai,
                             obj_key   ok
                       WHERE     ai.NCI_IDSEQ = cd.proto_IDSEQ
                             AND TRIM (TYPE) = ok.nci_cd(+)
                             AND ok.obj_typ_id(+) = 19
                             AND ai.admin_item_typ_id = 50) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     PROTCL_TYP_ID,
                     PROTCL_ID,
                     LEAD_ORG,
                     PROTCL_PHASE,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID,
                     CHNG_TYP,
                     CHNG_NBR,
                     RVWD_DT,
                     RVWD_USR_ID,
                     APPRVD_DT,
                     APPRVD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   proto_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'PROTOCOLS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_PROTCL',
                   ''
              FROM sbrext.protocols_ext cd, admin_item ai
             WHERE     ai.NCI_IDSEQ = cd.proto_IDSEQ
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate VALID_QUESTION_VALUES
    FOR x
        IN (  SELECT DISTINCT NCI_PUB_ID,                       --Primary Keys
                                          Q_VER_NR
                FROM (SELECT NCI_PUB_ID,
                             Q_PUB_ID,
                             Q_VER_NR,
                             VM_NM,
                             VM_DEF,
                             VALUE,
                             NCI_IDSEQ,
                             DESC_TXT,
                             MEAN_TXT,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM NCI_QUEST_VALID_VALUE
                      UNION ALL
                      SELECT qc.qc_id,
                             qc1.qc_id,
                             qc1.VERSION,
                             qc.preferred_name,
                             qc.preferred_definition,
                             qc.long_name,
                             qc.qc_idseq,
                             vv.description_text,
                             vv.meaning_text,
                             NVL (qc.created_by, 'ONEDATA'),
                             NVL (qc.DATE_CREATED,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (qc.date_modified, qc.date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (qc.modified_by, 'ONEDATA')
                        FROM sbrext.QUEST_CONTENTS_EXT  qc,
                             sbrext.quest_contents_ext  qc1,
                             sbrext.valid_values_att_ext vv
                       WHERE     qc.qtl_name = 'VALID_VALUE'
                             AND qc1.qtl_name = 'QUESTION'
                             AND qc1.qc_idseq = qc.p_qst_idseq
                             AND qc.qc_idseq = vv.qc_idseq(+)) t
            GROUP BY NCI_PUB_ID,
                     Q_PUB_ID,
                     Q_VER_NR,
                     VM_NM,
                     VM_DEF,
                     VALUE,
                     NCI_IDSEQ,
                     DESC_TXT,
                     MEAN_TXT,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY NCI_PUB_ID, Q_VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   vv.qc_idseq,
                   qc_id,
                   VERSION,
                   'VALID_QUESTION_VALUES',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_QUEST_VALID_VALUE',
                   ''
              FROM sbrext.valid_values_att_ext  vv,
                   sbrext.quest_contents_ext    qc
             WHERE     qc.qc_idseq = vv.qc_idseq
                   AND qc_id = x.NCI_PUB_ID
                   AND VERSION = x.Q_VER_NR;

        COMMIT;
    END LOOP;

--Sprint 5 Tables

--Validate COMPLEX_DATA_ELEMENTS
FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (SELECT DISTINCT de.ITEM_ID,                          --Primary Keys
                                           de.VER_NR, DERV_MTHD,
                            DERV_RUL,
                            de.DERV_TYP_ID,
                            de.CONCAT_CHAR,
                            DERV_DE_IND
                            from de , admin_item ai, sbr.complex_data_elements  cdr
                            WHERE de.item_id = ai.item_id
                           AND de.ver_nr = ai.ver_nr
                           AND cdr.p_de_idseq = ai.nci_idseq
                          UNION ALL
                          SELECT DISTINCT ai.ITEM_ID,                          --Primary Keys
                                           ai.VER_NR, METHODS,
                           RULE,
                           o.obj_key_id,
                           cdr.CONCAT_CHAR,
                           1
                      FROM sbr.complex_data_elements  cdr,
                           obj_key                    o,
                           admin_item                 ai
                     WHERE     cdr.CRTL_NAME = o.nci_cd(+)
                           AND o.obj_typ_id(+) = 21
                           AND cdr.p_de_idseq = ai.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR
                  HAVING COUNT (*) <> 2
                  ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
		                   NCI_IDSEQ,
		                   de.ITEM_ID,
		                   de.VER_NR,
		                   'COMPLEX_DATA_ELEMENTS',
		                   ITEM_NM,
		                   'DATA MISMATCH',
		                   SYSDATE,
		                   USER,
		                   'DE',
		                   ''
		              FROM DE,admin_item ai
		             WHERE ai.ITEM_ID=de.ITEM_ID and ai.VER_NR=de.VER_NR
             AND de.ITEM_ID = x.ITEM_ID AND de.VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=5
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=5
    UNION ALL
    SELECT con.item_id,
                   con.ver_nr,
                   oc.item_id,
                   oc.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
               FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
                   sbrext.object_classes_ext      oce,
                   admin_item                     con,
                   admin_item                     oc
             WHERE     cc.CONDR_IDSEQ = oce.CONDR_IDSEQ
                   AND oce.oc_idseq = oc.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH OBJECT_CLASSES_EXT',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=6
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=6 --106,987
    UNION ALL
    SELECT con.item_id, --106,910
                   con.ver_nr,
                   prop.item_id,
                   prop.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
                   sbrext.properties_ext          prope,
                   admin_item                     con,
                   admin_item                     prop
             WHERE     cc.CONDR_IDSEQ = prope.CONDR_IDSEQ
                   AND prope.prop_idseq = prop.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH PROPERTIES_EXT',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=7
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=7 --28,142
    UNION ALL
    SELECT con.item_id,
                   con.ver_nr,
                   rep.item_id,
                   rep.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
                   sbrext.representations_ext     repe,
                   admin_item                     con,
                   admin_item                     rep
             WHERE     cc.CONDR_IDSEQ = repe.CONDR_IDSEQ
                   AND Repe.rep_idseq = rep.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH REPRESENTATIONS_EXT',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=53

    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=53 --85,641
    UNION ALL
    SELECT con.item_id,--85,641
                   con.ver_nr,
                   rep.item_id,
                   rep.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
                   sbr.value_meanings             vm,
                   admin_item                     con,
                   admin_item                     rep
             WHERE     cc.CONDR_IDSEQ = vm.CONDR_IDSEQ
                   AND vm.vm_idseq = rep.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH VALUE_MEANINGS',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=3
  FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (Select cncpt_item_id,
                                  cncpt_ver_nr,
                                  cai.item_id,
                                  cai.ver_nr,
                                  cai.nci_ord,
                                  cai.nci_prmry_ind,
                                  nci_cncpt_val,
                                  cai.CREAT_USR_ID,
                                  cai.CREAT_DT,
                                  cai.LST_UPD_DT,
                                  cai.LST_UPD_USR_ID
from cncpt_admin_item cai, admin_item ai
where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
and ADMIN_ITEM_TYP_ID=3 --85,641
UNION ALL
SELECT con.item_id,
               con.ver_nr,
               vd.item_id,
               vd.ver_nr,
               cc.DISPLAY_ORDER,
               DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
               concept_value,
        nvl(cc.created_by,'ONEDATA'),
               nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
               nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
               nvl(cc.modified_by,'ONEDATA')
          FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               sbr.value_domains              vde,
               admin_item                     con,
               admin_item                     vd
         WHERE     cc.CONDR_IDSEQ = vde.CONDR_IDSEQ
               AND vde.vd_idseq = vd.nci_idseq
               AND cc.con_idseq = con.nci_idseq) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_DT,
                     CREAT_USR_ID,
                     LST_UPD_USR_ID,
                     LST_UPD_DT,
                     nci_ord
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   NCI_IDSEQ,
                   ITEM_ID,
                   VER_NR,
                   'COMPONENT_CONCEPTS_EXT',
                   ITEM_NM,
                   'DATA MISMATCH VALUE_DOMAINS',
                   SYSDATE,
                   USER,
                   'CNCPT_ADMIN_ITEM',
                   ''
              FROM ADMIN_ITEM
             WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

        COMMIT;
    END LOOP;

 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=1
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=1
    UNION ALL
    SELECT con.item_id,
                   con.ver_nr,
                   cd.item_id,
                   cd.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
                   sbr.conceptual_domains         cde,
                   admin_item                     con,
                   admin_item                     cd
             WHERE     cc.CONDR_IDSEQ = cde.CONDR_IDSEQ
                   AND cde.cd_idseq = cd.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH CONCEPTUAL_DOMAINS',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

            COMMIT;
    END LOOP;

--Validate  PERMISSIBLE_VALUES
    FOR x
            IN (  SELECT DISTINCT VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR
                    FROM (Select PERM_VAL_BEG_DT,
                              PERM_VAL_END_DT,
                              PERM_VAL_NM,
                              PERM_VAL_DESC_TXT,
                              VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR,
                              CREAT_DT,
                              CREAT_USR_ID,
                              LST_UPD_DT,
                              LST_UPD_USR_ID,
                              NCI_VAL_MEAN_ITEM_ID,
                              NCI_VAL_MEAN_VER_NR,
                              NCI_IDSEQ
    from PERM_VAL
    UNION ALL
    SELECT pvs.BEGIN_DATE,
                   pvs.END_DATE,
                   VALUE,
                   SHORT_MEANING,
                   vd.item_id,
                   vd.ver_nr,
                   nvl(pvs.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(pvs.created_by,'ONEDATA'),
                   nvl(NVL (pvs.date_modified, pvs.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(pvs.modified_by,'ONEDATA'),
                   vm.item_id,
                   vm.ver_nr,
                   pv.pv_idseq
              FROM sbr.PERMISSIBLE_VALUES  pv,
                   admin_item              vm,
                   admin_item              vd,
                   sbr.vd_pvs              pvs
             WHERE     pv.pv_idseq = pvs.pv_idseq
                   AND pvs.vd_idseq = vd.nci_idseq
                   AND pv.vm_idseq = vm.nci_idseq) t
                GROUP BY PERM_VAL_BEG_DT,
                              PERM_VAL_END_DT,
                              PERM_VAL_NM,
                              PERM_VAL_DESC_TXT,
                              VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR,
                              CREAT_DT,
                              CREAT_USR_ID,
                              LST_UPD_DT,
                              LST_UPD_USR_ID,
                              NCI_VAL_MEAN_ITEM_ID,
                              NCI_VAL_MEAN_VER_NR,
                              NCI_IDSEQ
                  HAVING COUNT (*) <> 2
                ORDER BY VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR)
        LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'PERMISSIBLE_VALUES',
                       ITEM_NM,
                       'DATA MISMATCH',
                       SYSDATE,
                       USER,
                       'PERM_VAL',
                       ''
                  FROM ADMIN_ITEM
                 WHERE ITEM_id = x.VAL_DOM_ITEM_ID AND VER_NR = x.VAL_DOM_VER_NR;

            COMMIT;
    END LOOP;

--Validate QUEST_VV_EXT
FOR x
        IN (  SELECT DISTINCT VV_PUB_ID,
                                  VV_VER_NR
                FROM (select DISTINCT VV_PUB_ID,
                                  VV_VER_NR,
                                  VAL,
                                  EDIT_IND,
                                  REP_SEQ
from NCI_QUEST_VV_REP
UNION ALL
SELECT   DISTINCT vv.NCI_PUB_ID,
               vv.NCI_VER_NR,
               qvv.VALUE,
               DECODE (editable_ind,  'Yes', 1,  'No', 0),
               repeat_sequence
          FROM sbrext.QUEST_VV_EXT         qvv,
               NCI_QUEST_VALID_VALUE       vv
         WHERE    qvv.vv_idseq = vv.NCI_IDSEQ(+)) t
            GROUP BY VV_PUB_ID,
                                  VV_VER_NR,
                                  VAL,
                                  EDIT_IND,
                                  REP_SEQ
              HAVING COUNT (*) <> 2
              ORDER BY VV_PUB_ID,
                                  VV_VER_NR)
LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   NCI_IDSEQ,
                   NCI_PUB_ID,
                   NCI_VER_NR,
                   'QUEST_VV_EXT',
                   VM_NM,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_QUEST_VV_REP',
                   ''
              FROM NCI_QUEST_VALID_VALUE
             WHERE NCI_PUB_ID = x.VV_PUB_ID AND NCI_VER_NR = x.VV_VER_NR;
        COMMIT;
    END LOOP;

  --Validate REFERENCE_BLOBS
    FOR x
            IN (  SELECT DISTINCT FILE_NM
                    FROM (select FILE_NM,
                             NCI_MIME_TYPE,
                             NCI_DOC_SIZE,
                             NCI_CHARSET,
                             NCI_DOC_LST_UPD_DT,
                             BLOB_COL,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_USR_ID,
                             LST_UPD_DT
    FROM ref_doc
    UNION ALL
            SELECT rb.NAME,
                   MIME_TYPE,
                   DOC_SIZE,
                   DAD_CHARSET,
                   LAST_UPDATED,
                   TO_BLOB(BLOB_CONTENT),
                   NVL (created_by, 'ONEDATA'),
                   NVL (date_created, TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                   NVL (modified_by, 'ONEDATA'),
                   NVL (NVL (date_modified, date_created),
                        TO_DATE ('8/18/2020', 'mm/dd/yyyy'))
              FROM  sbr.REFERENCE_BLOBS rb) t
                GROUP BY FILE_NM,
                             NCI_MIME_TYPE,
                             NCI_DOC_SIZE,
                             NCI_CHARSET,
                             NCI_DOC_LST_UPD_DT,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_USR_ID,
                             LST_UPD_DT
                  HAVING COUNT (*) <> 2
                  ORDER BY FILE_NM)
    LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       NULL,
                       NULL,
                       NULL,
                       'REFERENCE_BLOBS',
                       x.FILE_NM,
                       'DATA MISMATCH',
                       SYSDATE,
                       USER,
                       'REF_DOC',
                       ''
                  FROM DUAL;
            COMMIT;
        END LOOP;

--Validate TA_PROTO_CSI_EXT
FOR x
        IN (  SELECT DISTINCT TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR
                FROM (select TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT from NCI_FORM_TA_REL
UNION ALL
        SELECT ta.ta_id,
               ai.item_id,
               ai.ver_nr,
               nvl(t.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
          nvl(t.created_by,'ONEDATA'),
               nvl(t.modified_by,'ONEDATA'),
             nvl(NVL (t.date_modified, t.date_created), to_date('8/18/2020','mm/dd/yyyy'))
          FROM nci_form_ta ta, sbrext.TA_PROTO_CSI_EXT t, admin_item ai
         WHERE     ta.ta_idseq = t.ta_idseq
               AND t.proto_idseq = ai.nci_idseq
               AND t.proto_idseq IS NOT NULL) t
            GROUP BY TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT
              HAVING COUNT (*) <> 2
              ORDER BY TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR)
LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   NCI_idseq,
                   item_id,
                   ver_nr,
                   'TA_PROTO_CSI_EXT',
                   ITEM_NM,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_FORM_TA_REL',
                   ''
              FROM  nci_form_ta ta, sbrext.ta_proto_csi_ext t, admin_item ai
         WHERE     ta.ta_idseq = t.ta_idseq
               AND t.proto_idseq = ai.nci_idseq
               AND t.proto_idseq IS NOT NULL and ta_ID=x.ta_ID;
        COMMIT;
    END LOOP;

--Validate  TRIGGERED_ACTIONS_EXT
    FOR x
            IN (  SELECT DISTINCT TA_IDSEQ
                    FROM (Select
                                 TA_INSTR,
                                 SRC_TYP_NM,
                                 TRGT_TYP_NM,
                                 TA_IDSEQ,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT From NCI_FORM_TA
    UNION ALL
     SELECT      TA_INSTRUCTION,
                   S_QTL_NAME,
                   T_QTL_NAME,
                   TA_IDSEQ,
                   nvl(ta.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
              nvl(ta.created_by,'ONEDATA'),
                   nvl(ta.modified_by,'ONEDATA'),
                 nvl(NVL (ta.date_modified, ta.date_created), to_date('8/18/2020','mm/dd/yyyy'))
              FROM sbrext.TRIGGERED_ACTIONS_EXT  ta) t
                GROUP BY TA_INSTR,
                                 SRC_TYP_NM,
                                 TRGT_TYP_NM,
                                 TA_IDSEQ,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT
                  HAVING COUNT (*) <> 2
                  ORDER BY TA_IDSEQ)
    LOOP
            INSERT INTO ONEDATA_MIGRATION_ERROR
                SELECT ERR_SEQ.NEXTVAL,
                       TA_IDSEQ,
                       ac1.public_id,
                       ac1.version,
                       'TRIGGERED_ACTIONS_EXT',
                       ac1.PREFERRED_NAME,
                       'DATA MISMATCH',
                       SYSDATE,
                       USER,
                       'NCI_FORM_TA',
                       ''
                  from sbrext.triggered_actions_ext,sbr.administered_components ac1, sbr.administered_components ac2
                    where ac1.ac_idseq = S_QC_IDSEQ
                    and ac2.ac_idseq = S_QC_IDSEQ
                    and TA_IDSEQ=x.TA_IDSEQ;
            COMMIT;
        END LOOP;

--Validate VD_PVS
FOR x
        IN (  SELECT DISTINCT VAL_DOM_ITEM_ID,VAL_DOM_VER_NR,NCI_IDSEQ
                FROM (select DISTINCT PERM_VAL_BEG_DT,
                          PERM_VAL_END_DT,
                          VAL_DOM_ITEM_ID,
                          VAL_DOM_VER_NR,
                          CREAT_USR_ID,
                          CREAT_DT,
                          LST_UPD_DT,
                          LST_UPD_USR_ID,
                          NCI_IDSEQ,NCI_ORIGIN from  PERM_VAL
UNION ALL
        SELECT DISTINCT pvs.BEGIN_DATE,
               pvs.END_DATE,
               vd.item_id,
               vd.ver_nr,
               nvl(pvs.created_by,'ONEDATA'),
               nvl(pvs.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
               nvl(NVL (pvs.date_modified, pvs.date_created), to_date('8/18/2020','mm/dd/yyyy')),
               nvl(pvs.modified_by,'ONEDATA'),
               pv.pv_idseq, pvs.ORIGIN
          FROM sbr.PERMISSIBLE_VALUES  pv,
               admin_item              vd,
               sbr.vd_pvs              pvs
         WHERE     pv.pv_idseq = pvs.pv_idseq
               AND pvs.vd_idseq = vd.nci_idseq ) t
            GROUP BY VAL_DOM_ITEM_ID,VAL_DOM_VER_NR,PERM_VAL_BEG_DT,
                          PERM_VAL_END_DT,
                          CREAT_USR_ID,
                          CREAT_DT,
                          LST_UPD_DT,
                          LST_UPD_USR_ID,
                          NCI_IDSEQ
              HAVING COUNT (*) <> 2
              ORDER BY VAL_DOM_ITEM_ID,VAL_DOM_VER_NR,NCI_IDSEQ)
LOOP
        INSERT INTO ONEDATA_MIGRATION_ERROR
            SELECT ERR_SEQ.NEXTVAL,
                   x.NCI_IDSEQ,
                   x.VAL_DOM_ITEM_ID,
                   x.VAL_DOM_VER_NR,
                   'VD_PVS',
                   NULL,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'PERM_VAL',
                   ''
              from dual;
        COMMIT;
    END LOOP;

END;
/


DROP PROCEDURE ONEDATA_WA.SAG_LOAD_CONCEPT_ADMIN_ITEMS;

CREATE OR REPLACE Procedure ONEDATA_WA.SAG_LOAD_CONCEPT_ADMIN_ITEMS AS
--DECLARE
	v_concepts_loaded SAG_LOAD_CONCEPTS_EVS%ROWTYPE;
	v_eff_date DATE := sysdate;
	v_idseq CHAR(36);
    v_dflt_usr  varchar2(30) := 'ONEDATA';
	CURSOR concepts_raw_cur IS
	--find new concepts 
	select * from SAG_LOAD_CONCEPTS_EVS ld where CONCEPT_STATUS is NULL
	and ld.code not in (select distinct item_long_nm from ADMIN_ITEM where admin_item_typ_id = 49);
	BEGIN
	OPEN concepts_raw_cur;
	LOOP
		FETCH concepts_raw_cur INTO v_concepts_loaded;	
		EXIT WHEN concepts_raw_cur%NOTFOUND;
		v_idseq := nci_11179.cmr_guid();
		INSERT INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            --ADMIN_STUS_ID, default
                            --ADMIN_STUS_NM_DN, trigger
                            EFF_DT,
                            -- CHNG_DESC_TXT, N/A
                            -- CNTXT_ITEM_ID, trigger 20000000024
                            -- CNTXT_VER_NR,
                            -- CNTXT_NM_DN,
                            -- UNTL_DT,
                            -- CURRNT_VER_IND, default
                            ITEM_LONG_NM,
                            -- ORIGIN, trigger
                            ITEM_DESC, 
                            --ITEM_ID,
                            ITEM_NM,
                            --VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID,
                            DEF_SRC)
        VALUES(v_idseq,
               49, 
               v_eff_date,
               v_concepts_loaded.code,
               substr(v_concepts_loaded.definition, 1, 4000), --trim until length increases
               NVL (v_concepts_loaded.display_name, v_concepts_loaded.code),
               v_dflt_usr,
               v_eff_date,
               v_eff_date,
               v_dflt_usr,
               'NCI');
		update SAG_LOAD_CONCEPTS_EVS set CON_IDSEQ = v_idseq where code = v_concepts_loaded.code;
   		INSERT INTO cncpt (item_id,
                       ver_nr,
                       evs_src_id,
                       CREAT_USR_ID,
                       CREAT_DT,
                       LST_UPD_DT,
                       LST_UPD_USR_ID)
        SELECT item_id,
               ver_nr,
               218,
         	   CREAT_USR_ID,
               CREAT_DT,
               LST_UPD_DT,
               LST_UPD_USR_ID
 		FROM ADMIN_ITEM where
 		ADMIN_ITEM_TYP_ID = 49
 		and ITEM_LONG_NM = v_concepts_loaded.code
 		and FLD_DELETE = 0
        and admin_stus_id = 75 --RELEASED
        and CNTXT_ITEM_ID=20000000024;

    	COMMIT;

	END LOOP;
	CLOSE concepts_raw_cur;
END;
/


DROP PROCEDURE ONEDATA_WA.SAG_MIGR_VAL_LOV_FULL;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.SAG_MIGR_VAL_LOV_FULL
AS
    cur      SYS_REFCURSOR;
    curval   VARCHAR2 (500);
BEGIN

    DELETE FROM Sag_Migr_Lov_Err;
    COMMIT;

    cur := SAG_FUNC_MIGR_VAL_REG_ST_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'REGISTRATION_STATUS', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --AC_STATUS

    cur := SAG_FUNC_MIGR_VAL_AC_ST_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'AC_STATUS', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DESIGNATION_TYPE

    cur := SAG_FUNC_MIGR_VAL_DESIG_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DESIGNATION_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DEFINITION_TYPE

    cur := SAG_FUNC_MIGR_VAL_DEFIN_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DESIGNATION_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --ORIGIN

    cur := SAG_FUNC_MIGR_ORIGIN_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'ORIGIN', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DERIVATION_TYPE

    cur := SAG_FUNC_MIGR_DERIV_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DERIVATION_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --concept_sources_lov_ext

    cur := SAG_FUNC_MIGR_CONC_SOURC_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'CONCEPT_SOURCE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --CSI Type

    cur := SAG_FUNC_MIGR_CSI_TYPES_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'CSI_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --CS Type

    cur := SAG_FUNC_MIGR_CS_TYPES_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'CS_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --PA

    cur := SAG_FUNC_MIGR_VAL_PA_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'PA', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DOC_TYPE

    cur := SAG_FUNC_MIGR_VAL_DOC_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DOC_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --QCDL_TYPE

    cur := SAG_FUNC_MIGR_VAL_QCDL_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'QCDL_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --ORG

    cur := SAG_FUNC_MIGR_VAL_ORG_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'ORG', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --FORMAT

    cur := SAG_FUNC_MIGR_FORMAT_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'FORMAT', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --UOM
    cur := SAG_FUNC_MIGR_UOM_LOV(); -- Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'UOM', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;

    --DATA_TYPE

    cur := SAG_FUNC_MIGR_DATA_TP_LOV(); --Get ref cursor from function
    LOOP
        FETCH cur INTO curval;
        EXIT WHEN cur%NOTFOUND;
        INSERT INTO Sag_Migr_Lov_Err (Lov_Value, Lov_Name, ERROR_TEXT)
             VALUES (curval, 'DATA_TYPE', 'Migration error');
        COMMIT;
    END LOOP;
    CLOSE cur;
END;
/


DROP PROCEDURE ONEDATA_WA.SPAIINSERTPOST;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spAIInsertPost
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_add integer :=0;
  v_action_typ varchar2(30);
  v_item_id  number;
  v_ver_nr  number(4,2);
  v_nm_id number;
  v_cntxt_id number;
  v_cntxt_ver_nr number(4,2);
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

    row_ori := hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    
        row := t_row ();
        ihook.setColumnValue(row_ori,'ADMIN_STUS_ID',66 );  -- Draft new
         
     rows.extend;
    rows(rows.last) := row;
    action := t_actionrowset(rows, 'Administered Item', 2,0,'insert');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;

    end if;
/


DROP PROCEDURE ONEDATA_WA.SPAISTINSPOST;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spAISTInsPost
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_add integer :=0;
  v_action_typ varchar2(30);
  v_temp int;
  v_item_id  number;
  v_ver_nr  number(4,2);
  v_nm_id number;
  v_cntxt_id number;
  v_cntxt_ver_nr number(4,2);
  i integer := 0;
  column  t_column;
  v_item_nm   varchar2(255);
  v_item_def varchar2(4000);
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

    row_ori := hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    
    if (hookinput.originalRowset.tablename = 'DE') then
    
    
            for cur in (select  ai.item_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr and de.de_conc_item_id = ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') and de.de_conc_ver_nr =  ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR')
            and de.val_dom_item_id =  ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and de.val_dom_ver_nr =  ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') and de.item_id <> v_item_id 
                and (ai.cntxt_item_id, ai.cntxt_ver_nr) in (Select ai1.cntxt_item_id, ai1.cntxt_ver_nr from admin_item ai1 where item_id = v_item_id and ver_nr = v_ver_nr)) loop
               raise_application_error(-20000, 'Duplicate DE found. ' || cur.item_id);
                return;
            end loop;
    
            select substr(dec.item_nm || ' ' || vd.item_nm,1,255) ,substr(dec.item_desc || ' ' || vd.item_desc,  1, 4000) into v_item_nm, v_item_def from admin_item dec, admin_item vd
            where dec.item_id = ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') and dec.ver_nr =  ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR')
            and vd.item_id =  ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and vd.ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR');
        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID',v_item_id );  
        ihook.setColumnValue(row,'VER_NR',v_ver_nr );  
        ihook.setColumnValue(row,'ITEM_NM',v_item_nm );  
        ihook.setColumnValue(row,'ITEM_DESC',v_item_def );                                 
        rows.extend;
        rows(rows.last) := row;
        action := t_actionrowset(rows, 'Administered Item', 2,4,'update');
        actions.extend;
        actions(actions.last) := action;
       -- raise_application_error (-20000, 'Count 1 ' || v_item_id || '-' || actions.count);
    end if;
   
   if (hookinput.originalRowset.tablename = 'VALUE_DOM') then
       if ( ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') is not null) then
            select substr(vd.item_nm || ' ' || rc.item_nm,1,255)  into v_item_nm from admin_item vd, admin_item rc
            where vd.item_id = v_item_id and rc.ver_nr =  ihook.getColumnValue(row_ori, 'REP_CLS_VER_NR')
            and rc.item_id =  ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') and vd.ver_nr = v_ver_nr;
        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID',v_item_id );  
        ihook.setColumnValue(row,'VER_NR',v_ver_nr );  
        ihook.setColumnValue(row,'ITEM_NM',v_item_nm );  
        rows.extend;
        rows(rows.last) := row;
        action := t_actionrowset(rows, 'Administered Item', 2,0,'update');
        actions.extend;
        actions(actions.last) := action;
         end if;
        
    end if;
   if actions.count > 0 then      
 --  raise_application_error(-20000, 'Count' || actions.count);
    hookoutput.actions := actions;
  end if;
   -- end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/


DROP PROCEDURE ONEDATA_WA.SPAISTUPDPOST;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spAISTUpdPost (
    v_data_in    IN     CLOB,
    v_data_out      OUT CLOB,
    v_usr_id in varchar2)
AS
    hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    actions          t_actions := t_actions ();
    action           t_actionRowset;
    row              t_row;
    rows             t_rows;
    row_ori          t_row;
    action_rows      t_rows := t_rows ();
    action_row       t_row;
    rowset           t_rowset;
    v_add            INTEGER := 0;
    v_action_typ     VARCHAR2 (30);
    v_temp           VARCHAR2 (255);
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_nm_id          NUMBER;
    v_cntxt_id       NUMBER;
    v_cntxt_ver_nr   NUMBER (4, 2);
    i                INTEGER := 0;
    column           t_column;
    v_item_nm        VARCHAR2 (255);
    v_item_def       VARCHAR2 (4000);
    v_item_desc       VARCHAR2 (4000);
    msg              VARCHAR2 (4000);
BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;
    rows := t_rows ();

    row_ori := hookInput.originalRowset.rowset (1);
    v_item_id := ihook.getColumnValue (row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue (row_ori, 'VER_NR');

  if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;
    
    IF (hookinput.originalRowset.tablename = 'DE')
    THEN
        FOR cur
            IN (SELECT ai.item_id
                  FROM admin_item ai, de de
                 WHERE     ai.item_id = de.item_id
                       AND ai.ver_nr = de.ver_nr
                       AND de.de_conc_item_id =
                           ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID')
                       AND de.de_conc_ver_nr =
                           ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR')
                       AND de.val_dom_item_id =
                           ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID')
                       AND de.val_dom_ver_nr =
                           ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR')
                       AND de.item_id <> v_item_id
                       AND (ai.cntxt_item_id, ai.cntxt_ver_nr) IN
                               (SELECT ai1.cntxt_item_id, ai1.cntxt_ver_nr
                                  FROM admin_item ai1
                                 WHERE     item_id = v_item_id
                                       AND ver_nr = v_ver_nr))
        LOOP
            raise_application_error (-20000,
                                     'Duplicate DE found. ' || cur.item_id);
            RETURN;
        END LOOP;

        IF (   ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'DE_CONC_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'DE_CONC_VER_NR')
            OR ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'VAL_DOM_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'VAL_DOM_VER_NR'))
        THEN
            SELECT SUBSTR (dec.item_nm || ' ' || vd.item_nm, 1, 255),
                   SUBSTR (dec.item_desc || ':' || vd.item_desc, 1, 4000)
              INTO v_item_nm, v_item_def
              FROM admin_item dec, admin_item vd
             WHERE     dec.item_id =
                       ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID')
                   AND dec.ver_nr =
                       ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR')
                   AND vd.item_id =
                       ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID')
                   AND vd.ver_nr =
                       ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR');

            row := t_row ();
            ihook.setColumnValue (row, 'ITEM_ID', v_item_id);
            ihook.setColumnValue (row, 'VER_NR', v_ver_nr);
            ihook.setColumnValue (row, 'ITEM_NM', v_item_nm);
            ihook.setColumnValue (row, 'ITEM_DESC', v_item_def);
            rows.EXTEND;
            rows (rows.LAST) := row;
            action :=
                t_actionrowset (rows,
                                'Administered Item',
                                2,
                                0,
                                'update');
            actions.EXTEND;
            actions (actions.LAST) := action;
        END IF;

        spDEPrefQuestPost2 (row_ori, actions);
    END IF;

    IF (hookinput.originalRowset.tablename = 'DE_CONC')
    THEN
        FOR cur
            IN (SELECT ai.item_id
                  FROM admin_item ai, de_conc dec
                 WHERE     ai.item_id = dec.item_id
                       AND ai.ver_nr = dec.ver_nr
                       AND dec.obj_cls_item_id =
                           ihook.getColumnValue (row_ori, 'OBJ_CLS_ITEM_ID')
                       AND dec.obj_cls_ver_nr =
                           ihook.getColumnValue (row_ori, 'OBJ_CLS_VER_NR')
                       AND dec.prop_item_id =
                           ihook.getColumnValue (row_ori, 'PROP_ITEM_ID')
                       AND dec.prop_ver_nr =
                           ihook.getColumnValue (row_ori, 'PROP_VER_NR')
                       AND dec.item_id <> v_item_id
                       AND (ai.cntxt_item_id, ai.cntxt_ver_nr) IN
                               (SELECT ai1.cntxt_item_id, ai1.cntxt_ver_nr
                                  FROM admin_item ai1
                                 WHERE     item_id = v_item_id
                                       AND ver_nr = v_ver_nr))
        LOOP
            raise_application_error (-20000,
                                     'Duplicate DEC found. ' || cur.item_id);
            RETURN;
        END LOOP;

        IF (   ihook.getColumnValue (row_ori, 'OBJ_CLS_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'OBJ_CLS_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'OBJ_CLS_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'OBJ_CLS_VER_NR')
            OR ihook.getColumnValue (row_ori, 'PROP_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'PROP_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'PROP_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'PROP_VER_NR'))
        THEN
            SELECT SUBSTR (oc.item_nm || ' ' || prop.item_nm, 1, 255),
                   SUBSTR (oc.item_desc || ':' || prop.item_desc, 1, 4000)
              INTO v_item_nm, v_item_def
              FROM admin_item oc, admin_item prop
             WHERE     oc.item_id =
                       ihook.getColumnValue (row_ori, 'OBJ_CLS_ITEM_ID')
                   AND oc.ver_nr =
                       ihook.getColumnValue (row_ori, 'OBJ_CLS_VER_NR')
                   AND prop.item_id =
                       ihook.getColumnValue (row_ori, 'PROP_ITEM_ID')
                   AND prop.ver_nr =
                       ihook.getColumnValue (row_ori, 'PROP_VER_NR');

            row := t_row ();
            ihook.setColumnValue (row, 'ITEM_ID', v_item_id);
            ihook.setColumnValue (row, 'VER_NR', v_ver_nr);
            ihook.setColumnValue (row, 'ITEM_NM', v_item_nm);
            ihook.setColumnValue (row, 'ITEM_DESC', v_item_def);
            rows.EXTEND;
            rows (rows.LAST) := row;
            action :=
                t_actionrowset (rows,
                                'Administered Item',
                                2,
                                0,
                                'update');
            actions.EXTEND;
            actions (actions.LAST) := action;
        END IF;
    END IF;
 if (hookinput.originalRowset.tablename = 'VALUE_DOM') then
 
 select item_nm, cntxt_item_id, cntxt_ver_nr  into v_item_nm, v_cntxt_id, v_cntxt_ver_nr from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR');
            
          FOR cur
            IN (SELECT ai.item_id
                  FROM admin_item ai, VALUE_DOM vd
                 WHERE     ai.item_id = vd.item_id
                       AND ai.ver_nr = vd.ver_nr
                       AND ai.ITEM_NM = v_item_nm
               --        AND ai.VER_NR = ihook.getColumnValue (row_ori, 'VER_NR')
                       AND vd.item_id <> v_item_id
                       AND ai.cntxt_item_id = v_cntxt_id and ai.cntxt_ver_nr = v_cntxt_ver_nr)
        LOOP
            raise_application_error (-20000,
                                     'Duplicate VD found. ' || cur.item_id);
            RETURN;
        END LOOP; 
        
    if ( ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') is not null and 
         ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') <>  ihook.getColumnOldValue(row_ori, 'REP_CLS_ITEM_ID')) then
            
            select item_nm into v_temp from admin_item where item_id = ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') 
            and ver_nr = ihook.getColumnValue(row_ori, 'REP_CLS_VER_NR');
            --if ((trim(substr(v_item_nm, length(v_item_nm)-length(trim(v_temp)))) != v_temp) or
            --length(v_item_nm) < length(v_temp))then
            IF instr(v_item_nm,v_temp)=0 then                
                select substr(v_item_nm || ' ' || rc.item_nm,1,255) , 
                substr(v_item_desc || ' ' || rc.item_desc,1,3999) 
                into v_item_nm , v_item_desc
                from  admin_item rc
                where  rc.ver_nr =  ihook.getColumnValue(row_ori, 'REP_CLS_VER_NR')
                and rc.item_id =  ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') ;
            end if;  
        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID',v_item_id );  
        ihook.setColumnValue(row,'VER_NR',v_ver_nr );  
        ihook.setColumnValue(row,'ITEM_NM',v_item_nm ); 
        ihook.setColumnValue(row,'ITEM_DESC', v_item_desc); 
        rows.extend;
        rows(rows.last) := row;
        action := t_actionrowset(rows, 'Administered Item', 2,0,'update');
        actions.extend;
        actions(actions.last) := action;
     
        end if;
             --  raise_application_error (-20000,     ' VD error ' || v_item_id ||','||v_item_nm );
      
        
    
   END IF;

    IF actions.COUNT > 0
    THEN
        hookoutput.actions := actions;
    END IF;

    -- end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/


DROP PROCEDURE ONEDATA_WA.SPAIUPDPOST;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spAIUpdPost 
AS
    v_temp           INT;
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_entity      varchar2(255);
BEGIN
delete from ncI_ds_rslt_detl;
commit;


-- Rule id 1:  Entity preferred name exact match

insert into nci_ds_rslt_detl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score)
select hdr_id, item_id, ver_nr, 'NA', 1, 100 from admin_item ai, nci_ds_hdr h where upper(h.dload_obj_nm) = upper(ai.item_nm);
commit;

-- Rule id 2:  Entity alternate question text name exact match

insert into nci_ds_rslt_detl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score)
select hdr_id, item_id, ver_nr, 'NA', 2, 100 from ref r, nci_ds_hdr h where upper(h.dload_obj_nm) = upper(r.item_nm);
commit;


/*for cur in (select * from nci_ds_hdr) loop

v_entity := upper(cur.dload_obj_nm);


insert into ds_rslt_detl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score)
select cur.hdr_id, item_id, ver_nr, 'NA', 1, 100 from admin_item  


end loop;
*/


END;
/


DROP PROCEDURE ONEDATA_WA.SPCLASSIFICATION;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spClassification
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_usr_id  IN varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
forms     t_forms;
formGroup    t_form;
form1  t_form;
rowform t_row;
v_itemid     ADMIN_ITEM.ITEM_ID%TYPE;
v_vernr  ADMIN_ITEM.VER_NR%TYPE;
v_tbl_nm  varchar2(255);
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_itemid := ihook.getColumnValue(row_ori, 'ITEM_ID');
  v_VERNR := ihook.getColumnValue(row_ori, 'VER_NR');
  
    rows := t_rows();  


    if hookInput.invocationNumber = 0  then
      
       	 answers := t_answers();
        answer := t_answer(1, 1, 'Add Classification'); 
        answers.extend;          answers(answers.last) := answer;
        answer := t_answer(2, 2, 'Delete Classification'); 
        answers.extend;          answers(answers.last) := answer;
        
	   	 question := t_question('Choose Option', answers);
       	 hookOutput.question := question;
  	elsif hookInput.invocationNumber = 1 then
    rows := t_rows();
      if hookInput.answerId = 1 then -- Add
        for cur in (select NCI_PUB_ID, NCI_VER_NR from NCI_ADMIN_ITEM_REL_ALT_KEY where (CNTXT_CS_ITEM_ID, CNTXT_CS_VER_NR) in ( select item_id, ver_nr from admin_item ai, onedata_md.vw_usr_row_filter v  
        where nvl(ai.fld_delete,0)= 0  and ai.cntxt_item_id = v.CNTXT_ITEM_ID and ai.CNTXT_VER_NR = v.cntxt_VER_NR and ai.admin_item_typ_id = 9 and  upper(v.USR_ID) = upper(v_usr_id) and v.ACTION_TYP = 'I') )loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'NCI_PUB_ID', cur.NCI_PUB_ID);
		   iHook.setcolumnvalue (ROW, 'NCI_VER_NR', cur.NCI_VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
      	   v_found := true;
	    end loop;
   
        if (v_found) then
             showrowset := t_showablerowset (rows, 'CSI Node', 2, 'single');
            hookoutput.showrowset := showrowset;
        else
            hookoutput.message := 'No classification scheme found in your authorized context.';
         end if;
         
         answers := t_answers();
  	   	 answer := t_answer(hookinput.answerId, 1, 'Apply');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
    end if;
  
    if hookInput.answerId =2  then -- Delete
        v_found := false;
        row := t_row();
        rows := t_rows();
      for i in 1..hookinput.originalrowset.rowset.count loop
            row_ori := hookInput.originalRowset.rowset(i);
        
        for cur in (select r.NCI_PUB_ID, r.NCI_VER_NR, r.C_ITEM_ID, r.C_ITEM_VER_NR, r.REL_TYP_ID from nci_alt_key_admin_item_rel r , nci_admin_item_rel_alt_key a, admin_item cs, onedata_md.vw_usr_row_filter v  
        where nvl(r.fld_delete,0)= 0  and r.c_item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') 
        and r.C_ITEM_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR') and r.NCI_PUB_ID = a.NCI_PUB_ID and r.NCI_VER_NR = a.NCI_VER_NR and a.CNTXT_CS_ITEM_ID = cs.item_id
        and a.CNTXT_CS_VER_NR = cs.ver_nr and cs.admin_item_typ_id = 9 and  cs.CNTXT_VER_NR = v.CNTXT_VER_NR 
        and cs.CNTXT_ITEM_ID = v.CNTXT_ITEM_ID and upper(v.USR_ID) = upper(v_usr_id) and v.ACTION_TYP = 'I' ) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'NCI_PUB_ID', cur.nci_pub_ID);
		   iHook.setcolumnvalue (ROW, 'C_ITEM_ID', cur.C_ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'C_ITEM_VER_NR', cur.C_ITEM_VER_NR);
		   iHook.setcolumnvalue (ROW, 'NCI_VER_NR', cur.nci_VER_NR);
		   iHook.setcolumnvalue (ROW, 'REL_TYP_ID', cur.rel_typ_ID);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;
    end loop; 
     
     if (v_found) then
       	 showrowset := t_showablerowset (rows, 'NCI CSI - DE Relationship', 2, 'multi');
       	 hookoutput.showrowset := showrowset;
      else
         hookoutput.message := 'No classifications found in your authorized context to delete.';
         end if;
        
      if (v_found) then 
         answers := t_answers();
  	   	 answer := t_answer(hookinput.answerId, 2, 'Delete');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
         end if;
  end if;
  	elsif hookInput.invocationNumber = 2 then
      rows := t_rows();
      if (hookinput.answerid = 1) then --- add
      row_sel := hookInput.selectedRowset.rowset(1);   
      for i in 1..hookinput.originalrowset.rowset.count loop
            row := t_row();
            row_ori := hookInput.originalRowset.rowset(i);
            select count(*) into v_temp from NCI_ALT_KEY_ADMIN_ITEM_REL where c_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and c_item_ver_nr = ihook.getColumnValue(row_ori,'VER_NR')
            and NCI_VER_NR = ihook.getColumnValue(row_sel,'NCI_VER_NR') and NCI_PUB_ID = ihook.getColumnValue(row_sel,'NCI_PUB_ID') and rel_typ_id = 65;
            if (v_temp = 0) then 
            ihook.setcolumnvalue(row,'C_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
            ihook.setcolumnvalue(row,'C_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
            ihook.setcolumnvalue(row,'NCI_VER_NR', ihook.getColumnValue(row_sel,'NCI_VER_NR'));
            ihook.setcolumnvalue(row,'NCI_PUB_ID', ihook.getColumnValue(row_sel,'NCI_PUB_ID'));
            ihook.setcolumnvalue(row,'REL_TYP_ID', 65);
            rows.extend;
            rows(rows.last) := row;
            end if;
   end loop;
            v_tbl_nm := 'Classifications (Insert)';
             
        action := t_actionrowset(rows, v_tbl_nm, 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;
     end if;
      if (hookinput.answerid = 2 ) then --- delete
            rows := t_rows();
            v_tbl_nm := 'Classifications (Insert)';
            for i in 1..hookinput.selectedRowset.rowset.count loop
                    row := t_row();
                    row := hookInput.selectedRowset.rowset(i);
                    rows.extend;        rows(rows.last) := row;
            end loop;
        
       action := t_actionrowset(rows, v_tbl_nm, 2,2,'delete');
        actions.extend;
        actions(actions.last) := action;
      end if;
      hookoutput.actions := actions;
  end if;
	   
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/


DROP PROCEDURE ONEDATA_WA.SPCLASSIFICATIONSC;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spClassificationSC
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_usr_id  IN varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
forms     t_forms;
formGroup    t_form;
form1  t_form;
rowform t_row;
v_itemid     ADMIN_ITEM.ITEM_ID%TYPE;
v_vernr  ADMIN_ITEM.VER_NR%TYPE;
v_tbl_nm  varchar2(255);
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_itemid := ihook.getColumnValue(row_ori, 'ITEM_ID');
  v_VERNR := ihook.getColumnValue(row_ori, 'VER_NR');
  
    rows := t_rows();  


    if hookInput.invocationNumber = 0  then
      
       	 answers := t_answers();
        answer := t_answer(1, 1, 'Add Classification'); 
        answers.extend;          answers(answers.last) := answer;
        answer := t_answer(2, 2, 'Delete Classification'); 
        answers.extend;          answers(answers.last) := answer;
        
	   	 question := t_question('Choose Option', answers);
       	 hookOutput.question := question;
    end if;     
  	if hookInput.invocationNumber = 1 then
      --     raise_application_error(-20000,'Here 4');
       rows := t_rows();
        if hookInput.answerId = 1 then -- Add
            forms                  := t_forms();
            form1                  := t_form('Classification Form for SC', 2,1);
           --form1.rowset :=rowset;
            forms.extend;
            forms(forms.last) := form1;
            hookOutput.forms := forms;     
            answers := t_answers();
            answer := t_answer(hookinput.answerId, 1, 'Apply');
            answers.extend; answers(answers.last) := answer;

            question := t_question('Select option to proceed', answers);
            hookOutput.question := question;
        end if;
  
        if hookInput.answerId =2  then -- Delete
            v_found := false;
            row := t_row();        rows := t_rows();
            for i in 1..hookinput.originalrowset.rowset.count loop
                row_ori := hookInput.originalRowset.rowset(i);
        
                for cur in (select r.NCI_PUB_ID, r.NCI_VER_NR, r.C_ITEM_ID, r.C_ITEM_VER_NR, r.REL_TYP_ID from nci_alt_key_admin_item_rel r 
                where nvl(r.fld_delete,0)= 0  and r.c_item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') 
                and r.C_ITEM_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR') ) loop
                    row := t_row();
                    iHook.setcolumnvalue (ROW, 'NCI_PUB_ID', cur.nci_pub_ID);
                    iHook.setcolumnvalue (ROW, 'C_ITEM_ID', cur.C_ITEM_ID);
                    iHook.setcolumnvalue (ROW, 'C_ITEM_VER_NR', cur.C_ITEM_VER_NR);
                    iHook.setcolumnvalue (ROW, 'NCI_VER_NR', cur.nci_VER_NR);
                    iHook.setcolumnvalue (ROW, 'REL_TYP_ID', cur.rel_typ_ID);
                    rows.extend;
                    rows (rows.last) := row;
                    v_found := true;
                end loop;
            end loop; 
     
            if (v_found) then
                    showrowset := t_showablerowset (rows, 'NCI CSI - DE Relationship', 2, 'multi');
                    hookoutput.showrowset := showrowset;
                    answers := t_answers();
                    answer := t_answer(hookinput.answerId, 2, 'Delete');
                    answers.extend; answers(answers.last) := answer;

                    question := t_question('Select option to proceed', answers);
                    hookOutput.question := question;
            else
                    hookoutput.message := 'No classifications found in your authorized context to delete.';
            end if;
        end if;
    end if;
  	if hookInput.invocationNumber = 2 then
      
        rows := t_rows();
        if (hookinput.answerid = 1) then --- add
      
            forms              := hookInput.forms;
            form1              := forms(1);
    
            row_sel := form1.rowset.rowset(1);
    
            for i in 1..hookinput.originalrowset.rowset.count loop
                    row := t_row();
                    row_ori := hookInput.originalRowset.rowset(i);
                    select count(*) into v_temp from NCI_ALT_KEY_ADMIN_ITEM_REL where c_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and c_item_ver_nr = ihook.getColumnValue(row_ori,'VER_NR')
                    and NCI_VER_NR = ihook.getColumnValue(row_sel,'NCI_VER_NR') and NCI_PUB_ID = ihook.getColumnValue(row_sel,'NCI_PUB_ID') and rel_typ_id = 65;
                    if (v_temp = 0) then 
                        ihook.setcolumnvalue(row,'C_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
                        ihook.setcolumnvalue(row,'C_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
                        ihook.setcolumnvalue(row,'NCI_VER_NR', ihook.getColumnValue(row_sel,'NCI_VER_NR'));
                        ihook.setcolumnvalue(row,'NCI_PUB_ID', ihook.getColumnValue(row_sel,'NCI_PUB_ID'));
                        ihook.setcolumnvalue(row,'REL_TYP_ID', 65);
                        rows.extend;
                        rows(rows.last) := row;
                    end if;
            end loop;
            v_tbl_nm := 'Classifications (Insert)';
            action := t_actionrowset(rows, v_tbl_nm, 2,1,'insert');
            actions.extend;
            actions(actions.last) := action;
        end if;
        if (hookinput.answerid = 2 ) then --- delete
            rows := t_rows();
            v_tbl_nm := 'Classifications (Insert)';
            for i in 1..hookinput.selectedRowset.rowset.count loop
                    row := t_row();
                    row := hookInput.selectedRowset.rowset(i);
                    rows.extend;        rows(rows.last) := row;
            end loop;
        
            action := t_actionrowset(rows, v_tbl_nm, 2,2,'delete');
            actions.extend;
            actions(actions.last) := action;
        end if;
      hookoutput.actions := actions;
    end if;
    
	   delete from junk_debug; commit;
       
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  insert into junk_debug values (1, v_data_out);
  commit;
END;
/


DROP PROCEDURE ONEDATA_WA.SPCREATEDECSIMPLE_ITLOOK;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spCreateDECSimple_itlook
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  showRowset t_showableRowset;
  rowform t_row;
  forms t_forms;
  form1 t_form;

  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowset            t_rowset;
  v_oc_item_id number;
  v_oc_ver_nr number;
  v_oc_long_nm varchar2(255);
  v_oc_nm varchar2(255);
  v_prop_nm varchar2(255);
  v_oc_def  varchar2(2000);
  type t_cncpt_id is table of admin_item.item_id%type;
v_t_cncpt_id  t_cncpt_id := t_cncpt_id();

  v_prop_item_id number;
  v_prop_ver_nr number;
  v_prop_long_nm varchar2(255);
  v_prop_def  varchar2(2000);
  v_dec_item_id number;
 v_str  varchar2(255);
 v_nm  varchar2(255);
 v_item_id number;
 v_ver_nr number(4,2);
  cnt integer;
  
    actions t_actions := t_actions();
  action t_actionRowset;
  v_msg varchar2(1000);
  i integer := 0;
  v_err  integer;
  column  t_column;
  v_dec_nm varchar2(255);
  v_cncpt_nm varchar2(255);
  v_long_nm varchar2(255);
  v_def varchar2(4000);
  v_oc_id number;
  v_prop_id number;
  v_temp_id  number;
  v_temp_ver number(4,2);
  is_valid boolean;
 bEGIN
 
 
  
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    if hookInput.invocationNumber = 0 then
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECCreateQuestion();
          row := t_row();      
          rows := t_rows();
          ihook.setColumnValue(row, 'STG_AI_ID',1);
          ihook.setColumnValue(row, 'ADMIN_STUS_ID',66);
          ihook.setColumnValue(row, 'REGSTR_STUS_ID',9);
          rows.extend;
          rows(rows.last) := row;
          rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
          hookOutput.forms := nci_chng_mgmt.getDECCreateForm(rowset);
   
  ELSE
      forms              := hookInput.forms;
      form1              := forms(1);
      rowform := form1.rowset.rowset(1);
       row := t_row();
      rows := t_rows();
     is_valid := true;
     

    IF HOOKINPUT.ANSWERID = 2 or Hookinput.answerid = 4 THEN  -- Validate using drop-down
       
                v_nm := '';
                for i in 1..10 loop
                        v_temp_id := ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_' || i);
                        v_temp_ver := ihook.getColumnValue(rowform, 'CNCPT_1_VER_NR_' || i);
                 
                if (v_temp_id is not null) then
                        for cur in(select item_id, item_nm , item_long_nm from admin_item 
                        where admin_item_typ_id = 49 and item_id = v_temp_id and ver_nr = v_temp_ver) loop
                                 v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                                v_nm := trim(v_nm || ':' || cur.item_long_nm);
                        end loop;
                        end if;
         
          
                nci_11179.CncptCombExists(substr(v_nm,2),7,v_item_id, v_ver_nr,v_long_nm, v_def);
                ihook.setColumnValue(rowform, 'ITEM_1_ID',v_item_id);
                ihook.setColumnValue(rowform, 'ITEM_1_VER_NR', v_ver_nr);
                ihook.setColumnValue(rowform,'ITEM_1_LONG_NM', trim(substr(v_nm,2)));
                ihook.setColumnValue(rowform,'ITEM_1_DEF', v_def);
                ihook.setColumnValue(rowform,'ITEM_1_NM', v_long_nm);
       end loop;
    end if;
    
       ihook.setColumnValue(rowform, 'GEN_STR',v_dec_nm ) ;
       ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'VALIDATED');
       if (   ihook.getColumnValue(rowform, 'ITEM_1_ID') is not null ) then
              for cur in (select VALUE_DOM.* from VALUE_DOM, admin_item ai where REP_CLS_ITEM_ID =  ihook.getColumnValue(rowform, 'ITEM_1_ID') 
              and REP_CLS_VER_NR =  ihook.getColumnValue(rowform, 'ITEM_1_VER_NR') and
                 VALUE_DOM.item_id = ai.item_id and VALUE_DOM.ver_nr = ai.ver_nr 
                 and ai.cntxt_item_id = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID')
              and ai.cntxt_ver_nr = ihook.getColumnValue(rowform, 'CNTXT_VER_NR'))
               loop
                    ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'DUPLICATE VD');
                    is_valid := false;
              end loop;
        end if;
        if (   ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is null ) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'Rep Term missing.');
                  is_valid := false;
        end if;
     
         rows := t_rows();
        if (is_valid=false or hookinput.answerid = 1 or hookinput.answerid = 2) then
                rows.extend;
                rows(rows.last) := rowform;
                rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
                hookOutput.forms := nci_chng_mgmt.getDECCreateForm(rowset);
                HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECCreateQuestion();
        end if;
    
    IF HOOKINPUT.ANSWERID in ( 3,4)  and is_valid = true THEN  -- Create
        v_oc_id := ihook.getColumnValue(rowform, 'ITEM_1_ID');
        v_oc_ver_nr := ihook.getColumnValue(rowform, 'ITEM_1_VER_NR');
  
        if v_oc_id is null then
            nci_chng_mgmt.createAIWithConcept(rowform, 1,5, actions);
            v_oc_id := ihook.getColumnValue(rowform, 'ITEM_1_ID');
        end if;
 
--    raise_application_error(-20000, v_oc_id || 'Test' || v_prop_id);
        nci_chng_mgmt.createDEC(rowform, actions, v_item_id);
        hookoutput.message := 'VD Created Successfully with ID ' || v_item_id ;
        hookoutput.actions := actions;
    
    end if;
  
end if;
   
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 

END;
/


DROP PROCEDURE ONEDATA_WA.SPDECCONCEPTFROMTEMPLATE;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spDECConceptFromTemplate
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_temp integer;
  v_stg_ai_id number;
  v_nm  varchar2(255);
  v_oc_id number;
  v_oc_ver_nr number(4,2);
  v_prop_id  number;
  v_prop_ver_nr number(4,2);
  v_dec_id  number;
  v_dec_ver_nr  number(4,2);
  v_oc_nm   varchar2(255);
  v_prop_nm  varchar2(255);
  v_add integer :=0;
  v_word_cnt integer :=0;
  v_word  varchar2(100);
  i integer := 0;
  v_prmry_cncpt_nm varchar2(255);
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

   for i in 1..hookinput.originalrowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_stg_ai_id := ihook.getColumnValue(row_ori, 'STG_AI_ID');
    v_oc_id := ihook.getColumnValue(row_ori, 'STRT_OBJ_CLS_ITEM_ID');
    v_oc_ver_nr := ihook.getColumnValue(row_ori, 'STRT_OBJ_CLS_VER_NR');
    v_prop_id := ihook.getColumnValue(row_ori, 'STRT_PROP_ITEM_ID');
    v_prop_ver_nr := ihook.getColumnValue(row_ori, 'STRT_PROP_VER_NR');
    v_dec_id := ihook.getColumnValue(row_ori, 'STRT_DE_CONC_ITEM_ID');
    v_dec_ver_nr := ihook.getColumnValue(row_ori, 'STRT_DE_CONC_VER_NR');
       v_oc_nm := ihook.getColumnValue(row_ori, 'OBJ_CLS_LONG_NM');
    v_prop_nm := ihook.getColumnValue(row_ori, 'PROP_LONG_NM');
 
    delete from nci_stg_ai_cncpt where stg_ai_id = v_stg_ai_id;
    commit;
    
    
    delete from onedata_ra.nci_stg_ai_cncpt where stg_ai_id = v_stg_ai_id;
    commit;
    
    if v_dec_id is not null then
       select obj_cls_item_id, obj_cls_ver_nr into v_oc_id, v_oc_Ver_nr from de_conc where item_id = v_dec_id and ver_nr = v_dec_ver_nr;
       select prop_item_id, prop_ver_nr into v_prop_id, v_prop_Ver_nr from de_conc where item_id = v_dec_id and ver_nr = v_dec_ver_nr;
       
    end if;
     
    if v_oc_id is not null then
 --  raise_application_error(-20000, 'here');
     for cur in (select cncpt_item_id, cncpt_ver_nr,NCI_ORD from cncpt_admin_item where item_id = v_oc_id and ver_nr = v_oc_ver_nr) loop
        row := t_row ();
        ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
    ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
     ihook.setColumnValue(row,'STG_AI_ID', v_stg_ai_id);
     ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
     ihook.setColumnValue(row,'LVL_NM', 'OC');
     rows.extend;
    rows(rows.last) := row;
    v_add := v_add +1;
     end loop;
     end if;
     
  if v_oc_id is null and v_oc_nm is not null then -- No template selected but OC name specified. 
  v_prmry_cncpt_nm := nci_11179.getPrimaryConceptName (v_oc_nm);
       delete from NCI_STG_AI_REL where stg_ai_id = v_stg_ai_id and lvl_nm = 'OC';
       commit;
        insert into NCI_STG_AI_REL (stg_ai_id, lvl_nm, ITEM_ID, VER_NR) select 
        v_stg_ai_id, 'OC', item_id, ver_nr from admin_item  where admin_item_typ_id = 5 and upper(item_nm) like '%' || upper(v_prmry_cncpt_nm) and nvl(currnt_ver_ind,0) = 1 and nvl(fld_delete,0) = 0;
        commit;
  end if;
    if v_prop_id is not null then
    for cur in (select cncpt_item_id, cncpt_ver_nr,NCI_ORD from cncpt_admin_item where item_id = v_prop_id and ver_nr = v_prop_ver_nr) loop
        row := t_row ();
        ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
    ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
     ihook.setColumnValue(row,'STG_AI_ID', v_stg_ai_id);
     ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
     ihook.setColumnValue(row,'LVL_NM', 'PROP');
     rows.extend;
    rows(rows.last) := row;
    v_add := v_add +1;
     end loop;
     end if;
     
  if v_prop_id is null and v_prop_nm is not null then -- No template selected but OC name specified. 
  v_prmry_cncpt_nm := nci_11179.getPrimaryConceptName (v_prop_nm);
       delete from NCI_STG_AI_REL where stg_ai_id = v_stg_ai_id and lvl_nm = 'PROP';
       commit;
        insert into NCI_STG_AI_REL (stg_ai_id, lvl_nm, ITEM_ID, VER_NR) select 
        v_stg_ai_id, 'PROP', item_id, ver_nr from admin_item  where admin_item_typ_id = 6 and upper(item_nm) like '%' || upper(v_prmry_cncpt_nm) and nvl(currnt_ver_ind,0) = 1 and nvl(fld_delete,0) = 0;
        commit;
  end if;
     end loop;
     
  if (v_add > 0) then 
    --action := t_actionrowset(rows, 'NCI_STG_AI_CNCPT (Hook)', 2,0,'insert');
    action := t_actionrowset(rows, 'Stage Associated Concepts', 2,0,'insert');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;

   hookoutput.message := v_add || ' concepts added.';
   hookoutput.message := msg;
    end if;
    
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/


DROP PROCEDURE ONEDATA_WA.SPDECCONCEPTFROMTEMPLATEPOST;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spDECConceptFromTemplatePost
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_cnt integer;
  v_stg_ai_id number;
  v_oc_id number;
  v_oc_ver_nr number(4,2);
  v_prop_id  number;
  v_prop_ver_nr number(4,2);
  v_dec_id  number;
  v_dec_ver_nr  number(4,2);
  v_add integer :=0;
  v_dec_nm   varchar2(255);
  v_temp_nm  varchar2(255);
  v_prmry_cncpt_id number;
  v_oc_nm varchar2(255);
  v_prop_nm varchar2(255);
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

   for i in 1..hookinput.originalrowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_stg_ai_id := ihook.getColumnValue(row_ori, 'STG_AI_ID');
    v_oc_id := ihook.getColumnValue(row_ori, 'STRT_OBJ_CLS_ITEM_ID');
    v_oc_ver_nr := ihook.getColumnValue(row_ori, 'STRT_OBJ_CLS_VER_NR');
    v_prop_id := ihook.getColumnValue(row_ori, 'STRT_PROP_ITEM_ID');
    v_prop_ver_nr := ihook.getColumnValue(row_ori, 'STRT_PROP_VER_NR');
    v_dec_id := ihook.getColumnValue(row_ori, 'STRT_DE_CONC_ITEM_ID');
    v_dec_ver_nr := ihook.getColumnValue(row_ori, 'STRT_DE_CONC_VER_NR');
    v_oc_nm := ihook.getColumnValue(row_ori, 'OBJ_CLS_LONG_NM');
    v_prop_nm := ihook.getColumnValue(row_ori, 'PROP_LONG_NM');
   --- raise_application_error(-20000,'Test' || v_dec_id || v_dec_ver_nr);
    
    if v_dec_id is not null then
       select obj_cls_item_id, obj_cls_ver_nr into v_oc_id, v_oc_Ver_nr from de_conc where item_id = v_dec_id and ver_nr = v_dec_ver_nr;
       select prop_item_id, prop_ver_nr into v_prop_id, v_prop_Ver_nr from de_conc where item_id = v_dec_id and ver_nr = v_dec_ver_nr;
    end if;
    
    select count(*) into v_cnt from  NCI_STG_AI_CNCPT where stg_ai_id = v_stg_ai_id and lvl_nm = 'OC';

    if v_oc_id is not null and v_cnt = 0 then
 --  raise_application_error(-20000, 'here');
     for cur in (select cncpt_item_id, cncpt_ver_nr,NCI_ORD from cncpt_admin_item where item_id = v_oc_id and ver_nr = v_oc_ver_nr) loop
        row := t_row ();
        ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
    ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
     ihook.setColumnValue(row,'STG_AI_ID', v_stg_ai_id);
     ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
     ihook.setColumnValue(row,'LVL_NM', 'OC');
     rows.extend;
    rows(rows.last) := row;
    v_add := v_add +1;
     end loop;
     end if;
  
  if v_oc_id is null and v_oc_nm is not null and v_cnt = 0 then -- No template selected but OC name specified. 
    v_prmry_cncpt_id := nci_11179.getPrimaryConceptID (v_oc_nm);
    if v_prmry_cncpt_id is not null then
       delete from NCI_STG_AI_REL where stg_ai_id = v_stg_ai_id and lvl_nm = 'OC';
       commit;
        insert into NCI_STG_AI_REL (stg_ai_id, lvl_nm, ITEM_ID, VER_NR) select 
        v_stg_ai_id, 'OC', cai.item_id, cai.ver_nr from admin_item ai, cncpt_admin_item cai where cai.nci_ord = 0 and 
        ai.item_id = cai.item_id and ai.ver_nr = cai.ver_nr and ai.admin_item_typ_id = 5 and cai.cncpt_item_id = v_prmry_cncpt_id;
        commit;
    end if;
  end if;
    select count(*) into v_cnt from  NCI_STG_AI_CNCPT where stg_ai_id = v_stg_ai_id and lvl_nm = 'PROP';

    if v_prop_id is not null and v_cnt = 0 then
    for cur in (select cncpt_item_id, cncpt_ver_nr,NCI_ORD from cncpt_admin_item where item_id = v_prop_id and ver_nr =v_prop_ver_nr) loop
        row := t_row ();
        ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
    ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
     ihook.setColumnValue(row,'STG_AI_ID', v_stg_ai_id);
     ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
     ihook.setColumnValue(row,'LVL_NM', 'PROP');
     rows.extend;
    rows(rows.last) := row;
    v_add := v_add +1;
     end loop;
     end if;
     end loop;
     
     
  if (v_add > 0) then 
    --action := t_actionrowset(rows, 'NCI_STG_AI_CNCPT (Hook)', 2,0,'insert');
     action := t_actionrowset(rows, 'Stage Associated Concepts', 2,0,'insert');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;

   hookoutput.message := v_add || ' concepts added.';
   hookoutput.message := msg;
    end if;

--- DEC name generation


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/


DROP PROCEDURE ONEDATA_WA.SPDECCREATEUSEASTEMPLATE;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spDECCreateUseAsTemplate
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_temp integer;
  v_stg_ai_id number;
  v_item_id number;
  v_ver_nr number(4,2);
  v_lvl_nm  varchar2(10);
  v_nm  varchar2(255);
  v_add integer :=0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

    row_ori := hookInput.originalRowset.rowset(1);
    v_stg_ai_id := ihook.getColumnValue(row_ori, 'STG_AI_ID');
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_lvl_nm := ihook.getColumnValue(row_ori, 'LVL_NM');
   --  raise_application_error(-20000, 'here');
     for cur in (select cncpt_item_id, cncpt_ver_nr,NCI_ORD from cncpt_admin_item where item_id = v_item_id and ver_nr = v_ver_nr) loop
        row := t_row ();
        ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
    ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
     ihook.setColumnValue(row,'STG_AI_ID', v_stg_ai_id);
     ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
     ihook.setColumnValue(row,'LVL_NM',v_lvl_nm );
     rows.extend;
    rows(rows.last) := row;
    v_add := v_add +1;
     end loop;
     
     
  if (v_add > 0) then 
     delete from NCI_STG_AI_CNCPT where stg_ai_id = v_stg_ai_id and lvl_nm = v_lvl_nm;
     commit;
     delete from onedata_ra.NCI_STG_AI_CNCPT where stg_ai_id = v_stg_ai_id and lvl_nm = v_lvl_nm;
     commit;
    --action := t_actionrowset(rows, 'NCI_STG_AI_CNCPT (Hook)', 2,0,'insert');
    action := t_actionrowset(rows, 'Stage Associated Concepts', 2,0,'insert');
    actions.extend;
    actions(actions.last) := action;
   
       row := t_row();
       ihook.setColumnValue(row, 'STG_AI_ID', v_stg_ai_id);
       if (v_lvl_nm = 'OC') then
       ihook.setColumnValue(row, 'STRT_OBJ_CLS_ITEM_ID',  v_item_id);
       ihook.setColumnValue(row, 'STRT_OBJ_CLS_VER_NR',  v_ver_nr);
       else
       ihook.setColumnValue(row, 'STRT_PROP_ITEM_ID',  v_item_id);
       ihook.setColumnValue(row, 'STRT_PROP_VER_NR',  v_ver_nr);
      end if;   
       rows := t_rows();
        rows.extend;
        rows(rows.last) := row;
      action := t_actionrowset(rows, 'DEC Creation', 2,9,'update');
        actions.extend;
        actions(actions.last) := action;
    hookoutput.actions := actions;

   hookoutput.message := v_add || ' concepts added.';
   hookoutput.message := msg;
   
    end if;
    
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/


DROP PROCEDURE ONEDATA_WA.SPDEPREFQUESTPOST2;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spDEPrefQuestPost2 (
    row_ori   IN     t_row,
    actions   IN OUT t_actions)
AS
    action           t_actionRowset;
    row              t_row;
    rows             t_rows;
    action_rows      t_rows := t_rows ();
    action_row       t_row;
    rowset           t_rowset;
    v_add            INTEGER := 0;
    v_action_typ     VARCHAR2 (30);
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_nm_id          NUMBER;
    v_cntxt_id       NUMBER;
    long_nm          VARCHAR(200);
    v_cntxt_ver_nr   NUMBER (4, 2);
    i                INTEGER := 0;
    column           t_column;
    msg              VARCHAR2 (4000);
BEGIN
    v_item_id := ihook.getColumnValue (row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue (row_ori, 'VER_NR');
    rows := t_rows ();

    IF (ihook.getColumnValue (row_ori, 'PREF_QUEST_TXT') IS NOT NULL)
    THEN
        SELECT cntxt_item_id, cntxt_ver_nr
          INTO v_cntxt_id, v_cntxt_ver_nr
          FROM admin_item
         WHERE item_id = v_item_id AND ver_nr = v_ver_nr;

        row := t_row ();
        ihook.setColumnValue (row, 'ITEM_ID', v_item_id);
        ihook.setColumnValue (row, 'VER_NR', v_ver_nr);
        ihook.setColumnValue (
            row,
            'REF_NM',
            SUBSTR (ihook.getColumnValue (row_ori, 'PREF_QUEST_TXT'), 1, 255));
        ihook.setColumnValue (
            row,
            'REF_DESC',
            ihook.getColumnValue (row_ori, 'PREF_QUEST_TXT'));
        ihook.setColumnValue (row, 'LANG_ID', 1000);
        ihook.setColumnValue (row, 'NCI_CNTXT_ITEM_ID', v_cntxt_id);
        ihook.setColumnValue (row, 'NCI_CNTXT_VER_NR', v_cntxt_ver_nr);
        ihook.setColumnValue (row, 'REF_TYP_ID', 80);

        ihook.setColumnValue (row, 'REF_ID', -1);
        v_action_typ := 'insert';

        FOR cur
            IN (SELECT REF_ID
                  FROM REF
                 WHERE     item_id = v_item_id
                       AND ver_nr = v_ver_nr
                       AND ref_typ_id = 80)
        LOOP
            ihook.setColumnValue (row, 'REF_ID', cur.ref_id);
            v_action_typ := 'update';
        END LOOP;

        rows.EXTEND;
        rows (rows.LAST) := row;
        action :=
            t_actionrowset (rows,
                            'References (for Edit)',
                            2,
                            0,
                            v_action_typ);
        actions.EXTEND;
        actions (actions.LAST) := action;
        /*DSRMWS-455 PREF_QUEST_TXT IS NULL Start 01/08/2021 AT*/
        ELSE
        
        SELECT SUBSTR(ITEM_NM,1,195)
          INTO LONG_NM
          FROM admin_item
         WHERE item_id = v_item_id AND ver_nr = v_ver_nr;

        row := t_row ();
        ihook.setColumnValue (row, 'ITEM_ID', v_item_id);
        ihook.setColumnValue (row, 'VER_NR', v_ver_nr);
        
        ihook.setColumnValue (
            row,
            'REF_DESC',
            'Data Element ' || LONG_NM || ' does not have Preferred Question Text');
        
        FOR cur
            IN (SELECT REF_ID
                  FROM REF
                 WHERE     item_id = v_item_id
                       AND ver_nr = v_ver_nr
                       AND ref_typ_id = 80)
        LOOP
            ihook.setColumnValue (row, 'REF_ID', cur.ref_id);
            v_action_typ := 'update';
        END LOOP;

        rows.EXTEND;
        rows (rows.LAST) := row;
        action :=
            t_actionrowset (rows,
                            'References (for Edit)',
                            2,
                            0,
                            v_action_typ);
        actions.EXTEND;
        actions (actions.LAST) := action;
        /*DSRMWS-455 PREF_QUEST_TXT IS NULL END 01/08/2021 AT*/
        END IF;
END;
/


DROP PROCEDURE ONEDATA_WA.SPDSRULEENUM;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spDSRuleEnum
AS
    v_temp           INT;
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_entity      varchar2(255);
BEGIN



--delete from ncI_ds_rslt_dtl;
--commit;
delete from nci_ds_rslt;
commit;



--- Enumerated section

/*


for cur in (select * from nci_ds_hdr where (hdr_id)  in (select distinct hdr_id from nci_ds_dtl)) loop
-- Rule id 1:  Entity preferred name exact match

insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select cur.hdr_id, de.item_id, de.ver_nr, 'NA', 1, 100, 'Preferred Name Exact Match' from   vw_de de where  upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(de.item_nm)
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 17;
commit;

-- Rule id 2:  Entity alternate question text name exact match

insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr, 'NA', 2, 100, 'Question Text Exact Match' from ref r, obj_key ok, vw_de de  where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.ref_nm)
 and 
r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_detl) and de.val_dom_typ_id = 17;
commit;



-- Rule id 3:  Entity alternate  name exact match

insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr, 'NA', 3, 100, 'Alternate Name Exact Match' from alt_nms r, vw_de de  where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.nm_desc) 
and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17
and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_detl);
commit;


-- Rule id 4; Only for enumerated, Like 
insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select cur.hdr_id, de.item_id, de.ver_nr, 'NA', 4, 100, 'Preferred Name Like Match' from vw_de  de where  upper(de.item_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm))|| '%'  
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 17
and (cur.hdr_id, de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_detl) and de.val_dom_typ_id = 17;
commit;

*/

/*

-- Rule id 4; Only for enumerated, Like 
insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select cur.hdr_id, de.item_id, de.ver_nr, 'NA', 4, 100, 'Preferred Name Like Match' from vw_de  de where   
 upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(de.item_nm) || '%'
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 17
and (cur.hdr_id, de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_detl) and de.val_dom_typ_id = 17;
commit;
/*

insert into nci_ds_rslt_detl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr, 'NA', 5, 100, 'Question Text Like Match' from ref r, obj_key ok, vw_de de  where (upper(r.ref_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm))|| '%'  
or upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(r.ref_nm) || '%')  and 
r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and r.ref_nm != '%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
and (cur.hdr_id, de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_detl) and de.val_dom_typ_id = 17;
commit;



-- Rule id 6:  Entity alternate  name like match for non-enumerated

insert into nci_ds_rslt_detl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr, 'NA', 6, 100, 'Alternate Name Like Match' from alt_nms r, vw_de de  where upper(cur.entty_nm) like  '%' || upper(r.nm_desc) || '%' 
and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17
and (cur.hdr_id, de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_detl) and de.val_dom_typ_id = 17;
commit;
*/

--end loop;




for cur in (select hdr_id,count(*) cnt from nci_ds_dtl group by hdr_id) loop

insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR 
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id) 
and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
group by de_item_id,  de_ver_nr having count(*) = cur.cnt;
commit;

insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai 
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id) 
group by de_item_id, 
de_ver_nr having count(*) = cur.cnt
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
commit;


insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id) 
group by de_item_id, de_ver_nr having count(*) >= cur.cnt*0.5
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
commit;

insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select distinct cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  
from vw_nci_de_pv v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id) 
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id) 
group by de_item_id, de_ver_nr having count(*) > cur.cnt*0.5
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
commit;

/*
insert into nci_ds_rsult ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id) group by de_item_id, 
de_ver_nr having count(*) = cur.cnt
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSULT);

commit;

insert into nci_ds_rsult ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id) group by de_item_id, 
de_ver_nr having count(*) = cur.cnt
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSULT);
commit;

/*
insert into nci_ds_rsult ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id) group by de_item_id, 
de_ver_nr having count(*) >= cur.cnt*0.75
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSULT);
commit;

insert into nci_ds_rsult ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id) group by de_item_id, 
de_ver_nr having count(*) = cur.cnt*0.75
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSULT);
commit;
/* insert into nci_ds_rsult ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv where upper(item_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id = cur.hdr_id) group by de_item_id, 
de_ver_nr having count(*) >= cur.cnt/2
and ( de_item_id, de_ver_nr) not in (select  item_id,ver_nr from nci_ds_rsult where hdr_id = cur.hdr_id);
*/

commit;


end loop;



END;
/


DROP PROCEDURE ONEDATA_WA.SPDSRULENONENUM;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spDSRuleNonEnum
AS
    v_temp           INT;
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_entity      varchar2(255);
BEGIN


--- Non enumerated section

-- Rule id 1:  Entity preferred name exact match

for cur in (select * from nci_ds_hdr where (hdr_id) not in (select distinct hdr_id from nci_ds_dtl)) loop
--for cur in (select * from nci_ds_hdr where hdr_id = 1037) loop
insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select cur.hdr_id, de.item_id, de.ver_nr,  1, 100, 'Preferred Name Exact Match' from   vw_de de where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(de.item_nm)
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 18;
commit;

-- Rule id 2:  Entity alternate question text name exact match

insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr,  2, 100, 'Question Text Exact Match' from ref r, obj_key ok, vw_de de  where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.ref_nm) 
and 
r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt) and de.val_dom_typ_id = 18;
commit;



-- Rule id 3:  Entity alternate  name exact match

insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr, 3, 100, 'Alternate Name Exact Match' from alt_nms r, vw_de de where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.nm_desc) 
and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18
and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
commit;


-- Rule id 4; Only for non-enumerated, Like 
insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select distinct cur.hdr_id, de.item_id, de.ver_nr,  4, 100, 'Preferred Name Like Match' from vw_de  de where (upper(de.item_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or
upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(de.item_nm) || '%')
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 18
 and (cur.hdr_id) not in (select distinct hdr_id from nci_ds_rslt);
commit;



-- Rule id 5:  Entity alternate question text name like match for non-enumerated

insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr,  5, 100, 'Question Text Like Match' from ref r, obj_key ok, vw_de de 
where (upper(r.ref_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(r.ref_nm) || '%') and 
r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and r.ref_nm != '%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
and (cur.hdr_id) not in (select distinct hdr_id from nci_ds_rslt) and de.val_dom_typ_id = 18;
commit;


-- Rule id 6:  Entity alternate  name like match for non-enumerated

insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr,  6, 100, 'Alternate Name Like Match' from alt_nms r, vw_de de  
where (upper(r.nm_desc) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' ||  upper(r.nm_desc) || '%')
and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18
and (cur.hdr_id) not in (select distinct hdr_id from nci_ds_rslt);
commit;

end loop;


END;
/


DROP PROCEDURE ONEDATA_WA.SPPUSHAI;

CREATE OR REPLACE procedure ONEDATA_WA.spPushAI (vDays in integer)
as
--    1 - Conceptual Domain
--    2 - Data Element Concept
--    3 - Value Domain
--    4 - Data Element
--    5 - Object Class
--    6 - Property
--    7 - Representation Class
--    8 - Context
--    9 - Classification Scheme
--    49 - Concept
--    52 - Module
--    54 - Form
--    53 - Value Meaning
--    51 - Classification Scheme Item
--    50 - Protocol
--    56 - OCRecs
v_cnt integer;
ActionType char(1);
begin


for cur in (select nci_idseq, item_id, ver_nr, admin_item_typ_id from admin_item where  lst_upd_dt >= sysdate -vDays order by creat_dt) loop
select count(*) into v_cnt  from sbr.administered_components where ac_idseq = cur.nci_idseq;
if (v_cnt = 0) then ActionType := 'I';
else ActionType := 'U';
end if;

case cur.admin_item_typ_id
when 1 then --- Conceptual Domain
nci_cadsr_push_core.pushCD(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 2 then --- Data Element Concept
nci_cadsr_push_core.pushDEC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 3 then --- Value Domain
nci_cadsr_push_core.pushVD(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 4 then ---- Data Element
nci_cadsr_push_core.pushDE(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 5 then --- Object Class
nci_cadsr_push_core.pushOC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 6 then --- Property
nci_cadsr_push_core.pushProp(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 7 then ---Representation Class
nci_cadsr_push_core.pushRC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 8 then --- Context
nci_cadsr_push_core.pushContext(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 9 then --- Classification Scheme
nci_cadsr_push_core.pushCS(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 49 then ---Concept
nci_cadsr_push_core.pushConcept(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 52 then --- Module
nci_cadsr_push_core.pushModule(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 54 then --- Form
nci_cadsr_push_core.pushForm(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 53 then --- Value Meaning
nci_cadsr_push_core.pushVM(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 51 then  --- Classification Scheme Item
nci_cadsr_push_core.pushCSI(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 50 then --- Protocol
nci_cadsr_push_core.pushProt(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);


when 56 then --- Protocol
nci_cadsr_push_core.pushOCRecs(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

end case;
end loop;
commit;
end;
/


DROP PROCEDURE ONEDATA_WA.SP_CREATE_AI_CHILDREN_REV;

CREATE OR REPLACE procedure ONEDATA_WA.sp_create_ai_children_rev (vDays in integer)
as
v_cnt integer;
begin

--  Definitions
insert into sbr.definitions (DEFIN_IDSEQ, AC_IDSEQ, DEFINITION, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DEFL_NAME)
select ad.nci_idseq, ai.nci_idseq,  def_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
from alt_def ad, admin_item ai, admin_item c, obj_key ok
where ad.item_id = ai.item_id 
and   ad.ver_nr = ai.ver_nr
and   ai.cntxt_item_id = c.item_id 
and   ai.cntxt_ver_nr = c.ver_nr 
and   ad.nci_def_typ_id = ok.obj_key_id (+) 
and   ad.nci_idseq not in (select defin_idseq from sbr.definitions)
and   ad.lst_upd_dt >= sysdate - vDays;

for cur in (select nci_idseq from alt_def where lst_upd_dt >= sysdate - vDays and nci_idseq in (select defin_idseq from sbr.definitions)) loop
update sbr.definitions d set (DEFINITION, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DEFL_NAME) =
    (select  def_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
    from alt_def ad, admin_item ai, admin_item c, obj_key ok
    where ad.item_id = ai.item_id 
    and   ad.ver_nr = ai.ver_nr
    and   ai.cntxt_item_id = c.item_id 
    and   ai.cntxt_ver_nr = c.ver_nr 
    and   ad.nci_def_typ_id = ok.obj_key_id (+) 
    and   ad.nci_idseq = cur.nci_idseq)
where d.defin_idseq = cur.nci_idseq;
end loop; 
commit;

-- Designations
insert into sbr.designations (DEsig_IDSEQ, AC_IDSEQ, NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DETL_NAME)
select ad.nci_idseq, ai.nci_idseq,  nm_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
from alt_nms ad, admin_item ai, admin_item c, obj_key ok
where ad.item_id = ai.item_id 
and   ad.ver_nr = ai.ver_nr
and   ai.cntxt_item_id = c.item_id 
and   ai.cntxt_ver_nr = c.ver_nr 
and   ad.nm_typ_id = ok.obj_key_id (+) 
and   ad.nci_idseq not in (select desig_idseq from sbr.designations)
and   ad.lst_upd_dt >= sysdate - vDays;

for cur in (select nci_idseq from alt_nms where lst_upd_dt >= sysdate - vDays and nci_idseq in (select desig_idseq from sbr.designations)) loop
update sbr.designations d set (NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DETL_NAME) =
    (select  nm_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
    from alt_nms ad, admin_item ai, admin_item c, obj_key ok
    where ad.item_id = ai.item_id 
    and   ad.ver_nr = ai.ver_nr
    and   ai.cntxt_item_id = c.item_id 
    and   ai.cntxt_ver_nr = c.ver_nr 
    and   ad.nm_typ_id = ok.obj_key_id (+) 
    and   ad.nci_idseq = cur.nci_idseq)
where d.desig_idseq = cur.nci_idseq;
end loop;
commit;

-- Reference Documents
insert into sbr.reference_documents (RD_IDSEQ, AC_IDSEQ, NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DcTL_NAME,display_order, doc_text,URL)
select ad.nci_idseq, ai.nci_idseq,  ref_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd, ad.disp_ord, ad.ref_desc, ad.url
from ref ad, admin_item ai, admin_item c, obj_key ok
where ad.item_id = c.item_id 
and   ai.cntxt_ver_nr = c.ver_nr 
and   ad.ref_typ_id = ok.obj_key_id (+) 
and   ad.nci_idseq not in (select rd_idseq from sbr.reference_documents)
and   ad.lst_upd_dt >= sysdate - vDays;


for cur in (select nci_idseq from ref where lst_upd_dt >= sysdate - vDays and nci_idseq in (select rd_idseq from sbr.reference_documents)) loop
update sbr.reference_documents d set (NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DcTL_NAME,display_order, doc_text, url) =
    (select  ref_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd, ad.disp_ord, ad.ref_desc, ad.url
    from ref ad, admin_item ai, admin_item c, obj_key ok
    where ad.item_id = ai.item_id 
    and   ad.ver_nr = ai.ver_nr
    and   ai.cntxt_item_id = c.item_id 
    and   ai.cntxt_ver_nr = c.ver_nr 
    and   ad.ref_typ_id = ok.obj_key_id (+) 
    and   ad.nci_idseq = cur.nci_idseq)
where d.rd_idseq = cur.nci_idseq;
end loop;

-- Reference Blobs
insert into sbr.reference_blobs (RD_IDSEQ, NAME, DOC_SIZE, DAD_CHARSET, LAST_UPDATED, BLOB_CONTENT, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
select ad.nci_idseq, file_nm, nci_doc_size, nci_charset, nci_doc_lst_upd_dt, blob_col, ad.CREAT_DT, ad.CREAT_USR_ID, ad.LST_UPD_DT,ad.LST_UPD_USR_ID
from ref ad, ref_doc rd, admin_item ai, admin_item c, obj_key ok
where ad.item_id = ai.item_id 
and   ad.ver_nr = ai.ver_nr
and   ai.cntxt_item_id = c.item_id 
and   ai.cntxt_ver_nr = c.ver_nr 
and   ad.ref_typ_id = ok.obj_key_id (+) 
and   ad.nci_idseq not in (select rd_idseq from sbr.reference_blobs)
and ad.lst_upd_dt >= sysdate - vDays;


for cur in (select nci_idseq from ref where lst_upd_dt >= sysdate - vDays and nci_idseq in (select rd_idseq from sbr.reference_documents)) loop
update sbr.reference_blobs d set(RD_IDSEQ, NAME, DOC_SIZE, DAD_CHARSET, LAST_UPDATED, BLOB_CONTENT, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY) =
    (select ad.nci_idseq, file_nm, nci_doc_size, nci_charset, nci_doc_lst_upd_dt, blob_col, ad.CREAT_DT, ad.CREAT_USR_ID, ad.LST_UPD_DT,ad.LST_UPD_USR_ID
    from ref ad, ref_doc rd, admin_item ai, admin_item c, obj_key ok
    where ad.item_id = ai.item_id 
    and   ad.ver_nr = ai.ver_nr
    and   ai.cntxt_item_id = c.item_id 
    and   ai.cntxt_ver_nr = c.ver_nr 
    and   ad.ref_typ_id = ok.obj_key_id (+) 
    and   ad.nci_idseq not in (select rd_idseq from sbr.reference_blobs)
    and   ad.lst_upd_dt >= sysdate - vDays);
end loop;

commit;
    
end;
/


DROP PROCEDURE ONEDATA_WA.SP_CREATE_CSI_12_10;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.sp_create_csi_12_10
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM admin_item
          WHERE admin_item_typ_id = 51;

    COMMIT;

    DELETE FROM nci_clsfctn_schm_item;

    COMMIT;


    INSERT INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT ac.csi_idseq,
               51,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.csi_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
      nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
               nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr)
            FROM sbr.cs_items ac, admin_item cntxt, stus_mstr s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND --ac.end_date is not null and
                   cntxt.admin_item_typ_id = 8;

    COMMIT;

/*
    INSERT INTO NCI_CLSFCTN_SCHM_ITEM (item_id,
                                       ver_nr,
                                       CSI_TYP_ID,
                                       CSI_DESC_TXT,
                                       CSI_CMNTS,
                                       CREAT_USR_ID,
                                       CREAT_DT,
                                       LST_UPD_DT,
                                       LST_UPD_USR_ID,
                                       CS_ITEM_ID, CS_VER_NR, P_CSI_ITEM_ID, P_CSI_VER_NR)
        SELECT cd.CSI_id,
               cd.version,
               ok.obj_key_id,
               description,
               comments,
      nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created,v_dflt_date) ,
               nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr),
               cs.ITEM_ID, CS.VER_NR, pcsi.ITEM_ID, pcsi.VER_NR
          FROM sbr.cs_items cd, obj_key ok, sbr.cs_csi cscsi, vw_CLSFCTN_SCHM cs, vw_clsfctn_schm_item pcsi
         WHERE     TRIM (csitl_name) = ok.nci_cd
               AND ok.obj_typ_id = 20 and 
               cd.csi_idseq = cscsi.csi_idseq and 
               cscsi.cs_idseq = cs.nci_idseq and 
               cscsi.p_cs_csi_idseq = pcsi.nci_idseq (+);

    COMMIT;
*/

 INSERT INTO NCI_CLSFCTN_SCHM_ITEM (item_id,
                                       ver_nr,
                                       CSI_TYP_ID,
                                       CSI_DESC_TXT,
                                       CSI_CMNTS,
                                       CREAT_USR_ID,
                                       CREAT_DT,
                                       LST_UPD_DT,
                                       LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               ok.obj_key_id,
               description,
               comments,
       nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created, v_dflt_date) ,
               nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr)
          FROM sbr.cs_items cd, admin_item ai, obj_key ok
         WHERE     ai.NCI_IDSEQ = cd.CSI_IDSEQ
               AND TRIM (csitl_name) = ok.nci_cd
               AND ok.obj_typ_id = 20;

    COMMIT;

    -- cs_csi - give it an alternate key.
    DELETE FROM nci_admin_item_rel_alt_key
          WHERE rel_typ_id = 64;

    COMMIT;

    INSERT INTO nci_admin_item_rel_alt_key (CNTXT_CS_ITEM_ID,
                                            CNTXT_CS_VER_NR,
                                            P_ITEM_ID,
                                            P_ITEM_VER_NR,
                                            C_ITEM_ID,
                                            C_ITEM_VER_NR,
                                            DISP_ORD,
                                            DISP_LBL,
                                            NCI_VER_NR,
                                            REL_TYP_ID,
                                            NCI_IDSEQ,
                                            CREAT_USR_ID,
                                            CREAT_DT,
                                            LST_UPD_DT,
                                            LST_UPD_USR_ID)
        SELECT cs.item_id,
               cs.ver_nr,
               pcsi.item_id,
               pcsi.ver_nr,
               ccsi.item_id,
               ccsi.ver_nr,
               cscsi.DISPLAY_ORDER,
               cscsi.label,
               1,
               64,
               cscsi.CS_CSI_IDSEQ,
      nvl(cscsi.created_by,v_dflt_usr),
               nvl(cscsi.date_created,v_dflt_date) ,
               nvl(NVL (cscsi.date_modified, cscsi.date_created), v_dflt_date),
               nvl(cscsi.modified_by,v_dflt_usr)
            FROM admin_item  cs,
               admin_item  pcsi,
               admin_item  ccsi,
               sbr.cs_csi  cscsi,
               sbr.cs_csi  pcscsi
         WHERE     cscsi.cs_idseq = cs.nci_idseq
               AND cscsi.p_cs_csi_idseq IS NOT NULL
               AND pcscsi.cs_csi_idseq = cscsi.p_cs_csi_idseq
               AND pcscsi.csi_idseq = pcsi.nci_idseq
               AND cscsi.csi_idseq = ccsi.nci_idseq;

    COMMIT;


    INSERT INTO nci_admin_item_rel_alt_key (CNTXT_CS_ITEM_ID,
                                            CNTXT_CS_VER_NR,
                                            C_ITEM_ID,
                                            C_ITEM_VER_NR,
                                            DISP_ORD,
                                            DISP_LBL,
                                            NCI_VER_NR,
                                            REL_TYP_ID,
                                            NCI_IDSEQ,
                                            CREAT_USR_ID,
                                            CREAT_DT,
                                            LST_UPD_DT,
                                            LST_UPD_USR_ID)
        SELECT cs.item_id,
               cs.ver_nr,
               ccsi.item_id,
               ccsi.ver_nr,
               cscsi.DISPLAY_ORDER,
               cscsi.label,
               1,
               64,
               cscsi.CS_CSI_IDSEQ,
      nvl(cscsi.created_by,v_dflt_usr),
               nvl(cscsi.date_created,v_dflt_date) ,
               nvl(NVL (cscsi.date_modified, cscsi.date_created), v_dflt_date),
               nvl(cscsi.modified_by,v_dflt_usr)
          FROM admin_item cs, admin_item ccsi, sbr.cs_csi cscsi
         WHERE     cscsi.cs_idseq = cs.nci_idseq
               AND cscsi.p_cs_csi_idseq IS NULL
               AND cscsi.csi_idseq = ccsi.nci_idseq;

    COMMIT;
     update nci_admin_item_rel_alt_key k set (P_NCI_PUB_ID, P_NCI_VER_NR)
 = (select nci_pub_id, NCI_VER_NR from nci_admin_item_rel_alt_key a, sbr.cs_csi cscsi where k.nci_idseq = cscsi.cs_csi_idseq and cscsi.p_cs_csi_idseq = a.nci_idseq
 and cscsi.p_cs_csi_idseq is not null
 )
 where rel_typ_id = 64;
 commit;
END;
/


DROP PROCEDURE ONEDATA_WA.SP_CREATE_CSI_2_1210;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.sp_create_csi_2_1210
as
v_cnt integer;
begin

delete from NCI_ALT_KEY_ADMIN_ITEM_REL where rel_typ_id = 65;
commit;

insert into NCI_ALT_KEY_ADMIN_ITEM_REL (NCI_PUB_ID  ,  NCI_VER_NR  , C_ITEM_ID ,  C_ITEM_VER_NR ,  REL_TYP_ID,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ak.nci_pub_id, ak.nci_ver_nr, ai.item_id, ai.ver_nr, 65,
     nvl(accsi.created_by,v_dflt_usr),
               nvl(accsi.date_created,v_dflt_date) ,
               nvl(NVL (accsi.date_modified, accsi.date_created), v_dflt_date),
               nvl(accsi.modified_by,v_dflt_usr)
 from  sbr.ac_csi accsi, nci_admin_item_rel_alt_key ak, admin_item ai
where accsi.ac_idseq = ai.nci_idseq and
 accsi.cs_csi_idseq = ak.nci_idseq and ak.rel_typ_id = 64;
commit;


end;
/


DROP PROCEDURE ONEDATA_WA.SP_CREATE_CSI_REV;

CREATE OR REPLACE procedure ONEDATA_WA.sp_create_csi_rev (vDays in integer)
as
v_cnt integer;
begin

-- Classification Scheme Items 

update sbr.cs_csi set (cs_idseq, cs_csi_idseq, p_cs_csi_idseq, date_created,created_by,date_modified, modified_by, display_order, label) =
    (select cs.nci_idseq, csi.nci_idseq, pcsi.nci_idseq, rel.creat_dt, rel.CREAT_USR_ID, rel.LST_UPD_DT,rel.LST_UPD_USR_ID, disp_ord, disp_lbl
    from admin_item cs, admin_item csi, admin_item pcsi, nci_admin_item_rel_alt_key rel
    where rel.lst_upd_dt >= sysdate - vDays 
    and   rel.cntxt_cs_item_id = cs.item_id 
    and   cntxt_cs_ver_nr = cs.ver_nr
    and   rel.c_item_ver_nr = csi.ver_nr 
    and   rel.c_item_id = csi.item_id
    and   rel.p_item_ver_nr = pcsi.ver_nr (+) 
    and   rel.p_item_id = pcsi.item_id (+)
    and   rel.rel_typ_id = 64
    and   rel.nci_idseq in (select CS_CSI_IDSEQ from sbr.cs_csi));

insert into sbr.cs_csi (cs_idseq, cs_csi_idseq, p_cs_csi_idseq, date_created,created_by,date_modified, modified_by, display_order, label)
    select cs.nci_idseq, csi.nci_idseq, pcsi.nci_idseq, rel.creat_dt, rel.CREAT_USR_ID, rel.LST_UPD_DT,rel.LST_UPD_USR_ID, disp_ord, disp_lbl
    from admin_item cs, admin_item csi, admin_item pcsi, nci_admin_item_rel_alt_key rel
    where rel.lst_upd_dt >= sysdate - vDays 
    and   rel.cntxt_cs_item_id = cs.item_id 
    and   cntxt_cs_ver_nr = cs.ver_nr
    and   rel.c_item_ver_nr = csi.ver_nr 
    and   rel.c_item_id = csi.item_id
    and   rel.p_item_ver_nr = pcsi.ver_nr (+) 
    and   rel.p_item_id = pcsi.item_id (+)
    and   rel.rel_typ_id = 64
    and   rel.nci_idseq not in (select CS_CSI_IDSEQ from sbr.cs_csi);
commit;

-- Classification Scheme Items 

update sbr.ac_csi set (CS_CSI_IDSEQ,  AC_IDSEQ,  date_created,created_by,date_modified, modified_by) =
    (select csi.nci_idseq, ai.nci_idseq , rel.creat_dt, rel.CREAT_USR_ID, rel.LST_UPD_DT,rel.LST_UPD_USR_ID
    from nci_alt_key_admin_item_rel rel, nci_admin_item_rel_alt_key csi, admin_item ai
    where rel.lst_upd_dt >= sysdate - vDays 
    and   rel.c_item_id = ai.item_id 
    and   rel.c_item_ver_nr = ai.ver_nr
    and   rel.nci_pub_id = csi.nci_pub_id 
    and   rel.nci_ver_nr = csi.nci_ver_nr
    and   rel.rel_typ_id = 65
    and   (csi.nci_idseq, ai.nci_idseq) in (select cs_csi_idseq, ac_idseq from sbr.ac_csi));

insert into sbr.ac_csi (CS_CSI_IDSEQ,  AC_IDSEQ,  date_created,created_by,date_modified, modified_by)
    select csi.nci_idseq, ai.nci_idseq , rel.creat_dt, rel.CREAT_USR_ID, rel.LST_UPD_DT,rel.LST_UPD_USR_ID
    from nci_alt_key_admin_item_rel rel, nci_admin_item_rel_alt_key csi, admin_item ai
    where rel.lst_upd_dt >= sysdate - vDays 
    and   rel.c_item_id = ai.item_id 
    and   rel.c_item_ver_nr = ai.ver_nr
    and   rel.nci_pub_id = csi.nci_pub_id 
    and   rel.nci_ver_nr = csi.nci_ver_nr
    and   rel.rel_typ_id = 65
    and   (csi.nci_idseq, ai.nci_idseq) not in (select cs_csi_idseq, ac_idseq from sbr.ac_csi);
commit;
  
-- Classification Scheme Items - Alternate Designations

update sbrext.AC_ATT_CSCSI_EXT set (CS_CSI_IDSEQ,ATT_IDSEQ,ATL_NAME,date_created,created_by,date_modified, modified_by) =
    (select csi.nci_idseq, an.nci_idseq, 'DESIGNATION',  csian.CREAT_DT, csian.CREAT_USR_ID, csian.LST_UPD_DT,csian.LST_UPD_USR_ID
    from nci_admin_item_rel_alt_key csi, alt_nms an, nci_csi_alt_defnms csian
    where csi.nci_pub_id = csian.nci_pub_id 
    and   csi.nci_ver_nr = csian.nci_ver_nr 
    and   an.nm_id = nmdef_id
    and   csian.lst_upd_dt >= sysdate - vDays
    and   (csi.nci_idseq, an.nci_idseq) in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext));


insert into sbrext.AC_ATT_CSCSI_EXT (CS_CSI_IDSEQ,ATT_IDSEQ,ATL_NAME,date_created,created_by,date_modified, modified_by)
    select csi.nci_idseq, an.nci_idseq, 'DESIGNATION',  csian.CREAT_DT, csian.CREAT_USR_ID, csian.LST_UPD_DT,csian.LST_UPD_USR_ID
    from nci_admin_item_rel_alt_key csi, alt_nms an, nci_csi_alt_defnms csian
    where csi.nci_pub_id = csian.nci_pub_id 
    and   csi.nci_ver_nr = csian.nci_ver_nr 
    and   an.nm_id = nmdef_id
    and   csian.lst_upd_dt >= sysdate - vDays
    and   (csi.nci_idseq, an.nci_idseq) not in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext);
commit;

-- Classification Scheme Items - Alternate Definitions

update sbrext.AC_ATT_CSCSI_EXT set (CS_CSI_IDSEQ,ATT_IDSEQ,ATL_NAME,date_created,created_by,date_modified, modified_by) =
    (select csi.nci_idseq, an.nci_idseq, 'DEFINITION',  csian.CREAT_DT, csian.CREAT_USR_ID, csian.LST_UPD_DT,csian.LST_UPD_USR_ID
    from nci_admin_item_rel_alt_key csi, alt_def an, nci_csi_alt_defnms csian
    where csi.nci_pub_id = csian.nci_pub_id 
    and csi.nci_ver_nr = csian.nci_ver_nr 
    and an.def_id = nmdef_id
    and csian.lst_upd_dt >= sysdate - vDays
    and (csi.nci_idseq, an.nci_idseq) in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext));

insert into sbrext.AC_ATT_CSCSI_EXT (CS_CSI_IDSEQ,ATT_IDSEQ,ATL_NAME,date_created,created_by,date_modified, modified_by)
    select csi.nci_idseq, an.nci_idseq, 'DEFINITION',  csian.CREAT_DT, csian.CREAT_USR_ID, csian.LST_UPD_DT,csian.LST_UPD_USR_ID
    from nci_admin_item_rel_alt_key csi, alt_def an, nci_csi_alt_defnms csian
    where csi.nci_pub_id = csian.nci_pub_id 
    and   csi.nci_ver_nr = csian.nci_ver_nr 
    and   an.def_id = nmdef_id
    and   csian.lst_upd_dt >= sysdate - vDays
    and   (csi.nci_idseq, an.nci_idseq) not in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext);
commit;


end;
/


DROP PROCEDURE ONEDATA_WA.SP_CREATE_FORM_QUEST_REL_REV;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.sp_create_form_quest_rel_rev (
    vDays   IN INTEGER)
AS
    v_cnt   INTEGER;
BEGIN
    FOR cur IN (SELECT nci_idseq
                  FROM NCI_ADMIN_ITEM_REL_ALT_KEY
                 WHERE lst_upd_dt >= SYSDATE - vDays)
    LOOP
        SELECT COUNT (*)
          INTO v_cnt
          FROM sbrext.quest_contents_ext
         WHERE qc_idseq = cur.nci_idseq;

        IF (v_cnt = 0)
        THEN                                                            -- new
            INSERT INTO sbrext.quest_contents_ext (qc_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   dn_crf_idseq,
                                                   display_order,
                                                   asl_name,
                                                   begin_date,
                                                   change_note,
                                                   conte_idseq,
                                                   end_date,
                                                   latest_version_ind,
                                                   long_name,
                                                   preferred_definition,
                                                   preferred_name,
                                                   qc_id,
                                                   version,
                                                   created_by,
                                                   date_created,
                                                   date_modified,
                                                   modified_by)
                SELECT rel.NCI_IDSEQ,
                       MOD.nci_idseq,
                       'QUESTION',
                       frm.nci_idseq,
                       rel.disp_ord,
                       ai.ADMIN_STUS_NM_DN,
                       ai.EFF_DT,
                       ai.ADMIN_NOTES,
                       c.nci_idseq,
                       ai.UNTL_DT,
                       DECODE (ai.CURRNT_VER_IND,  1, 'Yes',  0, 'No'),
                       ai.ITEM_LONG_NM,
                       ai.ITEM_DESC,
                       rel.nci_pub_id,
                       rel.NCI_PUB_ID,
                       rel.NCI_VER_NR,
                       rel.CREAT_USR_ID,
                       rel.CREAT_DT,
                       rel.LST_UPD_DT,
                       rel.LST_UPD_USR_ID
                  FROM admin_item                  ai,
                       admin_item                  MOD,
                       admin_item                  frm,
                       NCI_ADMIN_ITEM_REL_ALT_KEY  rel,
                       nci_admin_item_rel          mf,
                       admin_item                  c
                 WHERE     ai.item_id = rel.c_item_id
                       AND ai.ver_nr = rel.c_item_ver_nr
                       AND ai.cntxt_item_id = c.item_id
                       AND ai.cntxt_ver_nr = c.ver_nr
                       AND c.admin_item_typ_id = 8
                       AND rel.rel_typ_id = 63
                       AND rel.p_item_id = MOD.item_id
                       AND rel.p_item_ver_nr = MOD.ver_nr
                       AND MOD.item_id = mf.c_item_id
                       AND MOD.ver_nr = mf.c_item_ver_nr
                       AND mf.p_item_id = frm.item_id
                       AND mf.p_item_ver_nr = frm.ver_nr
                       AND rel.c_item_id > 0
                       AND rel.nci_idseq = cur.nci_idseq;

            INSERT INTO sbrext.quest_contents_ext (qc_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   dn_crf_idseq,
                                                   display_order,
                                                   asl_name,
                                                   begin_date,
                                                   change_note,
                                                   conte_idseq,
                                                   end_date,
                                                   latest_version_ind,
                                                   long_name,
                                                   preferred_definition,
                                                   preferred_name,
                                                   qc_id,
                                                   version,
                                                   created_by,
                                                   date_created,
                                                   date_modified,
                                                   modified_by)
                SELECT rel.NCI_IDSEQ,
                       MOD.nci_idseq,
                       'QUESTION',
                       frm.nci_idseq,
                       rel.disp_ord,
                       frm.ADMIN_STUS_NM_DN,
                       frm.EFF_DT,
                       frm.ADMIN_NOTES,
                       c.nci_idseq,
                       frm.UNTL_DT,
                       DECODE (frm.CURRNT_VER_IND,  1, 'Yes',  0, 'No'),
                       rel.ITEM_LONG_NM,
                       frm.ITEM_DESC,
                       rel.nci_pub_id,
                       rel.NCI_PUB_ID,
                       rel.NCI_VER_NR,
                       rel.CREAT_USR_ID,
                       rel.CREAT_DT,
                       rel.LST_UPD_DT,
                       rel.LST_UPD_USR_ID
                  FROM admin_item                  MOD,
                       admin_item                  frm,
                       NCI_ADMIN_ITEM_REL_ALT_KEY  rel,
                       nci_admin_item_rel          mf,
                       admin_item                  c
                 WHERE     frm.cntxt_item_id = c.item_id
                       AND frm.cntxt_ver_nr = c.ver_nr
                       AND c.admin_item_typ_id = 8
                       AND rel.rel_typ_id = 63
                       AND rel.p_item_id = MOD.item_id
                       AND rel.p_item_ver_nr = MOD.ver_nr
                       AND MOD.item_id = mf.c_item_id
                       AND MOD.ver_nr = mf.c_item_ver_nr
                       AND mf.p_item_id = frm.item_id
                       AND mf.p_item_ver_nr = frm.ver_nr
                       AND rel.c_item_id < 0
                       AND rel.nci_idseq = cur.nci_idseq;

            INSERT INTO sbrext.QUEST_ATTRIBUTES_EXT (qc_idseq,
                                                     editable_ind,
                                                     mandatory_ind,
                                                     DEFAULT_VALUE,
                                                     created_by,
                                                     date_created,
                                                     date_modified,
                                                     modified_by)
                SELECT cur.nci_idseq,
                       DECODE (EDIT_IND,  1, 'Yes',  0, 'No'),
                       DECODE (REQ_IND,  1, 'Yes',  0, 'No'),
                       DEFLT_VAL,
                       rel.CREAT_USR_ID,
                       rel.CREAT_DT,
                       rel.LST_UPD_DT,
                       rel.LST_UPD_USR_ID
                  FROM NCI_ADMIN_ITEM_REL_ALT_KEY rel
                 WHERE nci_idseq = cur.nci_idseq;


            INSERT INTO sbrext.QUEST_ATTRIBUTES_EXT (qc_idseq,
                                                     editable_ind,
                                                     mandatory_ind,
                                                     DEFAULT_VALUE,
                                                     created_by,
                                                     date_created,
                                                     date_modified,
                                                     modified_by)
                SELECT cur.nci_idseq,
                       DECODE (EDIT_IND,  1, 'Yes',  0, 'No'),
                       DECODE (REQ_IND,  1, 'Yes',  0, 'No'),
                       DEFLT_VAL,
                       rel.CREAT_USR_ID,
                       rel.CREAT_DT,
                       rel.LST_UPD_DT,
                       rel.LST_UPD_USR_ID
                  FROM NCI_ADMIN_ITEM_REL_ALT_KEY rel
                 WHERE nci_idseq = cur.nci_idseq;
        ELSE
            UPDATE sbrext.quest_contents_ext
               SET (long_name,
                    display_order,
                    date_modified,
                    modified_by) =
                       (SELECT item_long_nm,
                               disp_ord,
                               LST_UPD_DT,
                               LST_UPD_USR_ID
                          FROM NCI_ADMIN_ITEM_REL_ALT_KEY
                         WHERE nci_idseq = cur.nci_idseq)
             WHERE qc_idseq = cur.nci_idseq;

            UPDATE sbrext.QUEST_ATTRIBUTES_EXT
               SET (editable_ind,
                    mandatory_ind,
                    DEFAULT_VALUE,
                    date_modified,
                    modified_by) =
                       (SELECT DECODE (EDIT_IND,  1, 'Yes',  0, 'No'),
                               DECODE (REQ_IND,  1, 'Yes',  0, 'No'),
                               DEFLT_VAL,
                               LST_UPD_DT,
                               LST_UPD_USR_ID
                          FROM NCI_ADMIN_ITEM_REL_ALT_KEY
                         WHERE nci_idseq = cur.nci_idseq)
             WHERE qc_idseq = cur.nci_idseq;
        END IF;
    END LOOP;

    COMMIT;

    FOR cur IN (SELECT nci_idseq
                  FROM NCI_QUEST_VALID_VALUE
                 WHERE lst_upd_dt >= SYSDATE - vDays)
    LOOP
        SELECT COUNT (*)
          INTO v_cnt
          FROM sbrext.quest_contents_ext
         WHERE qc_idseq = cur.nci_idseq;

        IF (v_cnt = 0)
        THEN                                                            -- new
            INSERT INTO sbrext.quest_contents_ext (qc_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   dn_crf_idseq, --display_order,
                                                   asl_name,
                                                   begin_date,
                                                   change_note,
                                                   conte_idseq,
                                                   end_date,
                                                   latest_version_ind,
                                                   long_name,
                                                   preferred_definition,
                                                   preferred_name,
                                                   qc_id,
                                                   version,
                                                   created_by,
                                                   date_created,
                                                   date_modified,
                                                   modified_by)
                SELECT vv.NCI_IDSEQ,
                       MOD.nci_idseq,
                       'VALID_VALUE',
                       frm.nci_idseq,                          --rel.disp_ord,
                       frm.ADMIN_STUS_NM_DN,
                       frm.EFF_DT,
                       frm.ADMIN_NOTES,
                       c.nci_idseq,
                       frm.UNTL_DT,
                       DECODE (frm.CURRNT_VER_IND,  1, 'Yes',  0, 'No'),
                       vv.VALUE,
                       vv.VM_DEF,
                       vv.nci_pub_id,
                       vv.NCI_PUB_ID,
                       vv.NCI_VER_NR,
                       vv.CREAT_USR_ID,
                       vv.CREAT_DT,
                       vv.LST_UPD_DT,
                       vv.LST_UPD_USR_ID
                  FROM admin_item                  MOD,
                       admin_item                  frm,
                       NCI_ADMIN_ITEM_REL_ALT_KEY  rel,
                       nci_admin_item_rel          mf,
                       admin_item                  c,
                       nci_quest_valid_value       vv
                 WHERE     vv.Q_PUB_ID = rel.NCI_PUB_ID
                       AND vv.q_ver_nr = rel.nci_ver_nr
                       AND frm.cntxt_item_id = c.item_id
                       AND frm.cntxt_ver_nr = c.ver_nr
                       AND c.admin_item_typ_id = 8
                       AND rel.rel_typ_id = 63
                       AND rel.p_item_id = MOD.item_id
                       AND rel.p_item_ver_nr = MOD.ver_nr
                       AND MOD.item_id = mf.c_item_id
                       AND MOD.ver_nr = mf.c_item_ver_nr
                       AND mf.p_item_id = frm.item_id
                       AND mf.p_item_ver_nr = frm.ver_nr
                       AND rel.c_item_id > 0
                       AND rel.nci_idseq = cur.nci_idseq;

            INSERT INTO sbrext.valid_values_att_ext (qc_idseq,
                                                     description_text,
                                                     meaning_text,
                                                     created_by,
                                                     date_created,
                                                     date_modified,
                                                     modified_by)
                SELECT nci_idseq,
                       desc_txt,
                       mean_txt,
                       vv.CREAT_USR_ID,
                       vv.CREAT_DT,
                       vv.LST_UPD_DT,
                       vv.LST_UPD_USR_ID
                  FROM nci_quest_valid_value vv
                 WHERE nci_idseq = cur.nci_idseq;
        END IF;
    END LOOP;

    COMMIT;
/*


insert into NCI_QUEST_VALID_VALUE
(NCI_PUB_ID, Q_PUB_ID, Q_VER_NR, VM_NM, VM_DEF, VALUE, NCI_IDSEQ, DESC_TXT, MEAN_TXT,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select qc.qc_id, qc1.qc_id, qc1.VERSION, qc.preferred_name, qc.preferred_definition ,qc.long_name, qc.qc_idseq, vv.description_text, vv.meaning_text,
qc.created_by, qc.date_created,
qc.date_modified, qc.modified_by
from  sbrext.quest_contents_ext qc, sbrext.quest_contents_ext qc1, sbrext.valid_values_att_ext vv
where qc.qtl_name = 'VALID_VALUE' and qc1.qtl_name = 'QUESTION' and qc1.qc_idseq = qc.p_qst_idseq and qc.qc_idseq = vv.qc_idseq (+);

commit;

delete from NCI_QUEST_VV_REP;
commit;

insert into NCI_QUEST_VV_REP
( QUEST_PUB_ID ,  QUEST_VER_NR ,
 VV_PUB_ID, VV_VER_NR,
 VAL,EDIT_IND , REP_SEQ,
   CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID )
select q.NCI_PUB_ID, q.NCI_VER_NR, vv.NCI_PUB_ID, vv.NCI_VER_NR,
qvv.value, decode(editable_ind,'Yes',1,'No',0), repeat_sequence,
qvv.created_by, qvv.date_created,
qvv.date_modified, qvv.modified_by
from sbrext.quest_vv_ext qvv, NCI_ADMIN_ITEM_REL_ALT_KEY q, NCI_QUEST_VALID_VALUE vv
where qvv.quest_idseq = q.NCI_IDSEQ and qvv.vv_idseq = vv.NCI_IDSEQ (+);
commit;
*/

END;
/


DROP PROCEDURE ONEDATA_WA.SP_CREATE_FORM_QUEST_REL_REV_TIM;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.sp_create_form_quest_rel_rev_tim (
    vDays   IN INTEGER)
AS
    v_cnt   INTEGER;
BEGIN


update sbrext.protocols_ext set (proto_idseq, proto_id, version, lead_org, phase, protocol_id, type, change_type, change_number, reviewed_date, reviewed_by, approved_date, approved_by, created_by, date_created, date_modified, modified_by) =
    (select ai.nci_idseq, prt.item_id, prt.ver_nr, prt.lead_org, prt.protcl_phase, prt.protcl_id, obj.nci_cd, prt.chng_typ, prt.chng_nbr, prt.rvwd_usr_id, prt.rvwd_dt, prt.apprvd_dt, 
    prt.apprvd_usr_id, prt.creat_usr_id, prt.creat_dt, prt.lst_upd_dt, prt.lst_upd_usr_id
    from admin_item ai, nci_protcl prt, obj_key obj
    where prt.lst_upd_dt >= sysdate - vDays
    and nci_idseq in (select proto_idseq from SBREXT.protocols_ext)); 
    
insert into sbrext.protocols_ext (proto_idseq, proto_id, version, lead_org, phase, protocol_id, type, change_type, change_number, reviewed_date, reviewed_by, approved_date, approved_by, created_by, date_created, date_modified, modified_by)
    select ai.nci_idseq, prt.item_id, prt.ver_nr, prt.lead_org, prt.protcl_phase, prt.protcl_id, obj.nci_cd, prt.chng_typ, prt.chng_nbr, prt.rvwd_usr_id, prt.rvwd_dt, prt.apprvd_dt, 
    prt.apprvd_usr_id, prt.creat_usr_id, prt.creat_dt, prt.lst_upd_dt, prt.lst_upd_usr_id
    from admin_item ai, nci_protcl prt, obj_key obj
    where prt.lst_upd_dt >= sysdate - vDays
    and nci_idseq not in (select proto_idseq from SBREXT.protocols_ext); 
    
update sbrext.quest_contents_ext set (qc_idseq,p_mod_idseq,qtl_name,dn_crf_idseq,display_order,asl_name,begin_date,change_note,conte_idseq,
end_date,latest_version_ind,long_name,preferred_definition,preferred_name,qc_id,version,created_by,date_created,date_modified,modified_by) =
    (SELECT rel.NCI_IDSEQ,MOD.nci_idseq,'QUESTION',frm.nci_idseq,rel.disp_ord,ai.ADMIN_STUS_NM_DN,ai.EFF_DT,ai.ADMIN_NOTES,c.nci_idseq,ai.UNTL_DT,
    DECODE (ai.CURRNT_VER_IND,  1, 'Yes',  0, 'No'),ai.ITEM_LONG_NM,ai.ITEM_DESC,rel.nci_pub_id,rel.NCI_PUB_ID,rel.NCI_VER_NR,rel.CREAT_USR_ID,rel.CREAT_DT,rel.LST_UPD_DT,rel.LST_UPD_USR_ID
    FROM admin_item ai, admin_item MOD, admin_item frm, NCI_ADMIN_ITEM_REL_ALT_KEY rel, nci_admin_item_rel mf, admin_item c
    WHERE ai.item_id = rel.c_item_id
    AND   ai.ver_nr = rel.c_item_ver_nr
    AND   ai.cntxt_item_id = c.item_id
    AND   ai.cntxt_ver_nr = c.ver_nr
    AND   c.admin_item_typ_id = 8
    AND   rel.rel_typ_id = 63
    AND   rel.p_item_id = MOD.item_id
    AND   rel.p_item_ver_nr = MOD.ver_nr
    AND   MOD.item_id = mf.c_item_id
    AND   MOD.ver_nr = mf.c_item_ver_nr
    AND   mf.p_item_id = frm.item_id
    AND   mf.p_item_ver_nr = frm.ver_nr
    AND   rel.c_item_id > 0
    AND   rel.nci_idseq in (select qc_idseq from sbrext.quest_contents_ext)
    AND   rel.lst_upd_dt >= sysdate - vDays);
    

INSERT INTO sbrext.quest_contents_ext (qc_idseq,p_mod_idseq,qtl_name,dn_crf_idseq,display_order,asl_name,begin_date,change_note,conte_idseq,
end_date,latest_version_ind,long_name,preferred_definition,preferred_name,qc_id,version,created_by,date_created,date_modified,modified_by)
    SELECT rel.NCI_IDSEQ,MOD.nci_idseq,'QUESTION',frm.nci_idseq,rel.disp_ord,frm.ADMIN_STUS_NM_DN,frm.EFF_DT,frm.ADMIN_NOTES,c.nci_idseq,
    frm.UNTL_DT,DECODE (frm.CURRNT_VER_IND,  1, 'Yes',  0, 'No'),rel.ITEM_LONG_NM,frm.ITEM_DESC,rel.nci_pub_id,rel.NCI_PUB_ID,rel.NCI_VER_NR,rel.CREAT_USR_ID,rel.CREAT_DT,rel.LST_UPD_DT,rel.LST_UPD_USR_ID
    FROM admin_item MOD, admin_item frm, NCI_ADMIN_ITEM_REL_ALT_KEY rel, nci_admin_item_rel mf, admin_item c
    WHERE frm.cntxt_item_id = c.item_id
    AND   frm.cntxt_ver_nr = c.ver_nr
    AND   c.admin_item_typ_id = 8
    AND   rel.rel_typ_id = 63
    AND   rel.p_item_id = MOD.item_id
    AND   rel.p_item_ver_nr = MOD.ver_nr
    AND   MOD.item_id = mf.c_item_id
    AND   MOD.ver_nr = mf.c_item_ver_nr
    AND   mf.p_item_id = frm.item_id
    AND   mf.p_item_ver_nr = frm.ver_nr
    AND   rel.c_item_id < 0
    AND   rel.nci_idseq not in (select qc_idseq from sbrext.quest_contents_ext)
    AND   rel.lst_upd_dt >= sysdate - vDays;

INSERT INTO sbrext.QUEST_ATTRIBUTES_EXT (qc_idseq,editable_ind,mandatory_ind,DEFAULT_VALUE,created_by,date_created,date_modified,modified_by)
    SELECT rel.nci_idseq,DECODE (EDIT_IND,  1, 'Yes',  0, 'No'),DECODE (REQ_IND,  1, 'Yes',  0, 'No'),DEFLT_VAL,rel.CREAT_USR_ID,rel.CREAT_DT,rel.LST_UPD_DT,rel.LST_UPD_USR_ID
    FROM NCI_ADMIN_ITEM_REL_ALT_KEY rel
    WHERE nci_idseq not in (select qc_idseq from sbrext.QUEST_ATTRIBUTES_EXT)
    AND   rel.lst_upd_dt >= sysdate - vDays;


UPDATE sbrext.QUEST_ATTRIBUTES_EXT set (qc_idseq,editable_ind,mandatory_ind,DEFAULT_VALUE,created_by,date_created,date_modified,modified_by) =
    (SELECT rel.nci_idseq,DECODE (EDIT_IND,  1, 'Yes',  0, 'No'),DECODE (REQ_IND,  1, 'Yes',  0, 'No'),DEFLT_VAL,rel.CREAT_USR_ID,rel.CREAT_DT,rel.LST_UPD_DT,rel.LST_UPD_USR_ID
    FROM NCI_ADMIN_ITEM_REL_ALT_KEY rel
    WHERE rel.nci_idseq in (select qc_idseq from sbrext.QUEST_ATTRIBUTES_EXT)
    AND   rel.lst_upd_dt >= sysdate - vDays);


COMMIT;

    FOR cur IN (SELECT nci_idseq
                  FROM NCI_QUEST_VALID_VALUE
                 WHERE lst_upd_dt >= SYSDATE - vDays)
    LOOP
        SELECT COUNT (*)
          INTO v_cnt
          FROM sbrext.quest_contents_ext
         WHERE qc_idseq = cur.nci_idseq;

        IF (v_cnt = 0)
        THEN                                                            -- new
            INSERT INTO sbrext.quest_contents_ext (qc_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   dn_crf_idseq, --display_order,
                                                   asl_name,
                                                   begin_date,
                                                   change_note,
                                                   conte_idseq,
                                                   end_date,
                                                   latest_version_ind,
                                                   long_name,
                                                   preferred_definition,
                                                   preferred_name,
                                                   qc_id,
                                                   version,
                                                   created_by,
                                                   date_created,
                                                   date_modified,
                                                   modified_by)
                SELECT vv.NCI_IDSEQ,
                       MOD.nci_idseq,
                       'VALID_VALUE',
                       frm.nci_idseq,                          --rel.disp_ord,
                       frm.ADMIN_STUS_NM_DN,
                       frm.EFF_DT,
                       frm.ADMIN_NOTES,
                       c.nci_idseq,
                       frm.UNTL_DT,
                       DECODE (frm.CURRNT_VER_IND,  1, 'Yes',  0, 'No'),
                       vv.VALUE,
                       vv.VM_DEF,
                       vv.nci_pub_id,
                       vv.NCI_PUB_ID,
                       vv.NCI_VER_NR,
                       vv.CREAT_USR_ID,
                       vv.CREAT_DT,
                       vv.LST_UPD_DT,
                       vv.LST_UPD_USR_ID
                  FROM admin_item                  MOD,
                       admin_item                  frm,
                       NCI_ADMIN_ITEM_REL_ALT_KEY  rel,
                       nci_admin_item_rel          mf,
                       admin_item                  c,
                       nci_quest_valid_value       vv
                 WHERE     vv.Q_PUB_ID = rel.NCI_PUB_ID
                       AND vv.q_ver_nr = rel.nci_ver_nr
                       AND frm.cntxt_item_id = c.item_id
                       AND frm.cntxt_ver_nr = c.ver_nr
                       AND c.admin_item_typ_id = 8
                       AND rel.rel_typ_id = 63
                       AND rel.p_item_id = MOD.item_id
                       AND rel.p_item_ver_nr = MOD.ver_nr
                       AND MOD.item_id = mf.c_item_id
                       AND MOD.ver_nr = mf.c_item_ver_nr
                       AND mf.p_item_id = frm.item_id
                       AND mf.p_item_ver_nr = frm.ver_nr
                       AND rel.c_item_id > 0
                       AND rel.nci_idseq = cur.nci_idseq;

            INSERT INTO sbrext.valid_values_att_ext (qc_idseq,
                                                     description_text,
                                                     meaning_text,
                                                     created_by,
                                                     date_created,
                                                     date_modified,
                                                     modified_by)
                SELECT nci_idseq,
                       desc_txt,
                       mean_txt,
                       vv.CREAT_USR_ID,
                       vv.CREAT_DT,
                       vv.LST_UPD_DT,
                       vv.LST_UPD_USR_ID
                  FROM nci_quest_valid_value vv
                 WHERE nci_idseq = cur.nci_idseq;
        END IF;
    END LOOP;

    COMMIT;
/*


insert into NCI_QUEST_VALID_VALUE
(NCI_PUB_ID, Q_PUB_ID, Q_VER_NR, VM_NM, VM_DEF, VALUE, NCI_IDSEQ, DESC_TXT, MEAN_TXT,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select qc.qc_id, qc1.qc_id, qc1.VERSION, qc.preferred_name, qc.preferred_definition ,qc.long_name, qc.qc_idseq, vv.description_text, vv.meaning_text,
qc.created_by, qc.date_created,
qc.date_modified, qc.modified_by
from  sbrext.quest_contents_ext qc, sbrext.quest_contents_ext qc1, sbrext.valid_values_att_ext vv
where qc.qtl_name = 'VALID_VALUE' and qc1.qtl_name = 'QUESTION' and qc1.qc_idseq = qc.p_qst_idseq and qc.qc_idseq = vv.qc_idseq (+);

commit;

delete from NCI_QUEST_VV_REP;
commit;

insert into NCI_QUEST_VV_REP
( QUEST_PUB_ID ,  QUEST_VER_NR ,
 VV_PUB_ID, VV_VER_NR,
 VAL,EDIT_IND , REP_SEQ,
   CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID )
select q.NCI_PUB_ID, q.NCI_VER_NR, vv.NCI_PUB_ID, vv.NCI_VER_NR,
qvv.value, decode(editable_ind,'Yes',1,'No',0), repeat_sequence,
qvv.created_by, qvv.date_created,
qvv.date_modified, qvv.modified_by
from sbrext.quest_vv_ext qvv, NCI_ADMIN_ITEM_REL_ALT_KEY q, NCI_QUEST_VALID_VALUE vv
where qvv.quest_idseq = q.NCI_IDSEQ and qvv.vv_idseq = vv.NCI_IDSEQ (+);
commit;
*/

END;
/


DROP PROCEDURE ONEDATA_WA.SP_CREATE_FORM_VV_REV;

CREATE OR REPLACE procedure ONEDATA_WA.sp_create_form_vv_rev
as
v_cnt integer;
begin

delete from NCI_QUEST_VALID_VALUE;
commit;

insert into NCI_QUEST_VALID_VALUE
(NCI_PUB_ID, Q_PUB_ID, Q_VER_NR, VM_NM, VM_DEF, VALUE, NCI_IDSEQ, DESC_TXT, MEAN_TXT,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select qc.qc_id, qc1.qc_id, qc1.VERSION, qc.preferred_name, qc.preferred_definition ,qc.long_name, qc.qc_idseq, vv.description_text, vv.meaning_text,
qc.created_by, qc.date_created,
qc.date_modified, qc.modified_by
from  sbrext.quest_contents_ext qc, sbrext.quest_contents_ext qc1, sbrext.valid_values_att_ext vv
where qc.qtl_name = 'VALID_VALUE' and qc1.qtl_name = 'QUESTION' and qc1.qc_idseq = qc.p_qst_idseq and qc.qc_idseq = vv.qc_idseq (+);

commit;

delete from NCI_QUEST_VV_REP;
commit;

insert into NCI_QUEST_VV_REP
(	QUEST_PUB_ID , 	QUEST_VER_NR ,
	VV_PUB_ID,	VV_VER_NR,
	VAL,EDIT_IND ,	REP_SEQ,
   CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID )
select q.NCI_PUB_ID, q.NCI_VER_NR, vv.NCI_PUB_ID, vv.NCI_VER_NR,
qvv.value, decode(editable_ind,'Yes',1,'No',0), repeat_sequence,
qvv.created_by, qvv.date_created,
qvv.date_modified, qvv.modified_by
from sbrext.quest_vv_ext qvv, NCI_ADMIN_ITEM_REL_ALT_KEY q, NCI_QUEST_VALID_VALUE vv
where qvv.quest_idseq = q.NCI_IDSEQ and qvv.vv_idseq = vv.NCI_IDSEQ (+);
commit;

end;
/


DROP PROCEDURE ONEDATA_WA.SP_CREATE_PERS_ORG_CONT_ADDR_REV;

CREATE OR REPLACE procedure ONEDATA_WA.sp_create_pers_org_cont_addr_rev 
    (vDays   IN INTEGER)
AS
    v_cnt   INTEGER;
BEGIN
-- Persons

update sbr.persons set (per_idseq, lname, fname, rank_order, org_idseq, mi, position, date_created, created_by, date_modified, modified_by) =
    (select ent.nci_idseq, per.last_nm, per.first_nm, per.rnk_ord, per.prnt_org_id, per.mi, per.pos, per.creat_dt, per.creat_usr_id, per.lst_upd_dt, per.lst_upd_usr_id
    from nci_entty ent, nci_prsn per
    where ent.entty_typ_id = 73
    and   per.lst_upd_dt >= sysdate - vDays
    and ent.nci_idseq in (select per_idseq from sbr.persons));
    
insert into sbr.persons (per_idseq, lname, fname, rank_order, org_idseq, mi, position, date_created, created_by, date_modified, modified_by)
    select ent.nci_idseq, per.last_nm, per.first_nm, per.rnk_ord, per.prnt_org_id, per.mi, per.pos, per.creat_dt, per.creat_usr_id, per.lst_upd_dt, per.lst_upd_usr_id
    from nci_entty ent, nci_prsn per
    where ent.entty_typ_id = 73
    and   per.lst_upd_dt >= sysdate - vDays
    and   ent.nci_idseq not in (select per_idseq from sbr.persons);
    
-- Organizations

update sbr.organizations set (org_idseq, rai, name, ra_ind, mail_address, created_by, date_created, modified_by, date_modified) =
    (select ent.nci_idseq, org.rai, org.org_nm, org.ra_ind, org.mail_addr, org.creat_usr_id, org.creat_dt, org.lst_upd_usr_id, org.lst_upd_dt
    from nci_entty ent, nci_org org
    where ent.entty_typ_id = 72
    and org.lst_upd_dt >= sysdate - vDays
    and ent.nci_idseq in (select org_idseq from sbr.organizations));
    
insert into sbr.organizations (org_idseq, rai, name, ra_ind, mail_address, created_by, date_created, modified_by, date_modified)
    select ent.nci_idseq, org.rai, org.org_nm, org.ra_ind, org.mail_addr, org.creat_usr_id, org.creat_dt, org.lst_upd_usr_id, org.lst_upd_dt
    from nci_entty ent, nci_org org
    where ent.entty_typ_id = 72
    and org.lst_upd_dt >= sysdate - vDays
    and ent.nci_idseq not in (select org_idseq from sbr.organizations);

-- Contact Communication (seems like ord_idseq and pers_idseq should not have the same value??)

update sbr.contact_comms set (org_idseq, per_idseq, ctl_name, rank_order, cyber_address, date_created, created_by, date_modified, modified_by) =
    (select ent.nci_idseq, ent.nci_idseq, obj.obj_key_desc, com.rnk_ord, com.cyb_addr, com.creat_dt, com.creat_usr_id, com.lst_upd_dt, com.lst_upd_usr_id
    from nci_entty ent, obj_key obj, nci_entty_comm com
    where com.comm_typ_id = obj.obj_key_id
    and   com.lst_upd_dt >= sysdate - vDays
    and   ent.nci_idseq in (select org_idseq from sbr.contact_comms));
  
insert into sbr.contact_comms (org_idseq, per_idseq, ctl_name, rank_order, cyber_address, date_created, created_by, date_modified, modified_by)
    select ent.nci_idseq, ent.nci_idseq, obj.obj_key_desc, com.rnk_ord, com.cyb_addr, com.creat_dt, com.creat_usr_id, com.lst_upd_dt, com.lst_upd_usr_id
    from nci_entty ent, obj_key obj, nci_entty_comm com
    where com.comm_typ_id = obj.obj_key_id
    and   com.lst_upd_dt >= sysdate - vDays
    and   ent.nci_idseq not in (select org_idseq from sbr.contact_comms);
    
-- Contact Addresses (again seems like the idseq fields are not correct, on this table it seems like the mapping isn't correct)

update sbr.contact_addresses set (org_idseq, per_idseq, atl_name, rank_order, addr_line1, addr_line2, city, state_prov, postal_code, country, date_created, created_by, date_modified, modified_by) =
    (select entty_id, entty_id, addr_typ_id, rnk_ord, addr_line1, addr_line2, city, state_prov, postal_code, country, creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id
    from nci_entty_addr
    where lst_upd_dt >= sysdate - vDays);

commit;
    
end sp_create_pers_org_cont_addr_rev;
/


DROP PROCEDURE ONEDATA_WA.SP_CREATE_PV_REV;

CREATE OR REPLACE procedure ONEDATA_WA.sp_create_pv_rev (vDays in integer)
as
v_cnt integer;
begin

--- CD-VM relationship

update sbr.cd_vms set (CD_IDSEQ, VM_IDSEQ,  SHORT_MEANING, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY) =  --- Check what needs to go into short-meaning
    (select cd.nci_idseq, vm.nci_idseq, vm.item_long_nm, cdvm.CREAT_DT,cdvm.CREAT_USR_ID, cdvm.LST_UPD_DT,cdvm.LST_UPD_USR_ID
    from conc_dom_val_mean cdvm, admin_item cd, admin_item vm
    where cdvm.conc_dom_item_id = cd.item_id 
    and   cdvm.conc_dom_ver_nr = cd.ver_nr
    and   cdvm.nci_val_mean_item_id = vm.item_id 
    and   cdvm.nci_val_mean_ver_nr = vm.ver_nr
    and   cdvm.lst_upd_dt >= sysdate - vDays
    and   (cd.nci_idseq, vm.nci_idseq) in (select cd_idseq, vm_idseq from sbr.cd_vms));


insert into sbr.cd_vms (CD_IDSEQ, VM_IDSEQ,  SHORT_MEANING, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)  --- Check what needs to go into short-meaning
select cd.nci_idseq, vm.nci_idseq, vm.item_long_nm, cdvm.CREAT_DT,cdvm.CREAT_USR_ID,  cdvm.LST_UPD_DT,cdvm.LST_UPD_USR_ID
from conc_dom_val_mean cdvm, admin_item cd, admin_item vm
where cdvm.conc_dom_item_id = cd.item_id 
and   cdvm.conc_dom_ver_nr = cd.ver_nr
and   cdvm.nci_val_mean_item_id = vm.item_id and cdvm.nci_val_mean_ver_nr = vm.ver_nr 
and   (cd.nci_idseq, vm.nci_idseq) not in (select cd_idseq, vm_idseq from sbr.cd_vms)
and   cdvm.lst_upd_dt >= sysdate - vDays;
commit;

-- Permissible Values

update sbr.permissible_Values set (BEGIN_DATE, END_DATE, VALUE, SHORT_MEANING, pv_idseq, vm_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY) =
    (select PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,pv.nci_idseq, vm.nci_idseq, pv.CREAT_DT,pv.CREAT_USR_ID,pv.LST_UPD_DT,pv.LST_UPD_USR_ID
    from perm_val pv, admin_item vm
    where pv.nci_val_mean_item_id = vm.item_id 
    and   pv.nci_val_mean_ver_nr = vm.ver_nr
    and   pv.lst_upd_dt >= sysdate - vDays
    and pv.nci_idseq in (select pv_idseq from sbr.permissible_Values));

insert into sbr.permissible_Values(BEGIN_DATE, END_DATE, VALUE, SHORT_MEANING, pv_idseq, vm_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
select PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,pv.nci_idseq, vm.nci_idseq, pv.CREAT_DT,pv.CREAT_USR_ID,pv.LST_UPD_DT,pv.LST_UPD_USR_ID
from perm_val pv, admin_item vm
where pv.nci_val_mean_item_id = vm.item_id 
and   pv.nci_val_mean_ver_nr = vm.ver_nr
and   pv.lst_upd_dt >= sysdate - vDays 
and   pv.nci_idseq not in (select pv_idseq from sbr.permissible_Values);
commit;

update sbr.vd_pvs set (BEGIN_DATE, END_DATE, pv_idseq, vd_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY) =
    (select PERM_VAL_BEG_DT, PERM_VAL_END_DT, pv.nci_idseq, vd.nci_idseq, pv.CREAT_DT,pv.CREAT_USR_ID, pv.LST_UPD_DT,pv.LST_UPD_USR_ID
    from perm_val pv, admin_item vd
    where pv.val_dom_item_id = vd.item_id 
    and   pv.val_dom_ver_nr = vd.ver_nr
    and   pv.lst_upd_dt >= sysdate - vDays 
    and   pv.nci_idseq in (select pv_idseq from sbr.vd_pvs));

insert into sbr.vd_pvs(BEGIN_DATE, END_DATE, pv_idseq, vd_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
select PERM_VAL_BEG_DT, PERM_VAL_END_DT, pv.nci_idseq, vd.nci_idseq, pv.CREAT_DT,pv.CREAT_USR_ID, pv.LST_UPD_DT,pv.LST_UPD_USR_ID
from perm_val pv, admin_item vd
where pv.val_dom_item_id = vd.item_id 
and   pv.val_dom_ver_nr = vd.ver_nr
and   pv.lst_upd_dt >= sysdate - vDays 
and   pv.nci_idseq not in (select pv_idseq from sbr.vd_pvs);
commit;


end;
/


DROP PROCEDURE ONEDATA_WA.SP_MIGRATE_LOV_ITTEST;

CREATE OR REPLACE procedure ONEDATA_WA.sp_migrate_lov_ITtest
as
v_cnt integer;
v_dflt_usr  varchar2(30) := 'ONEDATA';

v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
v_dflt_date date := to_date('8/18/2020','mm/dd/yyyy');
begin


--sp_load_status;

begin
      execute immediate 'DROP SEQUENCE od_seq_objkey';
      exception when others then
        null;
    end;
    execute immediate 'CREATE SEQUENCE od_seq_objkey INCREMENT BY 1 START WITH 1000 NOCYCLE CACHE 20 NOORDER';


delete from obj_key where obj_typ_id = 14;  -- Program Area
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 14, pal_name, description, pal_name, comments,               nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr)
 from sbr.PROGRAM_AREAS_LOV;
commit;


delete from obj_key where obj_typ_id = 11;  -- Name/designation
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 11, detl_name, description, detl_name, comments,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.DESIGNATION_TYPES_LOV;
commit;

-- DOcument type
delete from obj_key where obj_typ_id = 1;  --
commit;

-- Preferred Question Text ID needs to be static. Used in views.
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, NCI_CD) values (80,1,'Preferred Question Text', 'Preferred Question Text for Data Element','Preferred Question Text');
commit;

-- Added 12/17 for form management
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, NCI_CD) values (81,1,'Alternate Question Text', 'Alternate Question Text for Data Element','Alternate Question Text');
commit;

insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 1, DCTL_NAME, description, DCTL_NAME, comments,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.document_TYPES_LOV where DCTL_NAME not like 'Preferred Question Text'
               and DCTL_NAME not like 'Alternate Question Text';
commit;


-- Classification Scheme Type
delete from obj_key where obj_typ_id = 3;  --
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 3, CSTL_NAME, description, CSTL_NAME, comments,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.CS_TYPES_LOV;
commit;

-- Classification Scheme Item Type
delete from obj_key where obj_typ_id = 20;  --
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 20, CSITL_NAME, description, CSITL_NAME, comments,  nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.CSI_TYPES_LOV;
commit;

-- Protocol Type
delete from obj_key where obj_typ_id = 19;  --
commit;
insert into obj_key (obj_typ_id, obj_key_desc,  nci_cd)
select distinct 19, TYPE, TYPE from sbrext.protocols_ext where type is not null ;
commit;



-- Concept Source
delete from obj_key where obj_typ_id = 23;  --
commit;

nci_caDSR_PULL.SP_SOURCE_TYPE;

select max(obj_key_id)+1 into v_cnt  from OBJ_KEY where obj_typ_id = 23; 
/*Insirt new type ID*/
for cur in (
select CONCEPT_SOURCE,
DESCRIPTION, 
nvl(created_by,v_dflt_usr) created_by,
nvl(date_created,v_dflt_date) date_created,
nvl(NVL (date_modified, date_created), v_dflt_date) date_modified,
nvl(modified_by,v_dflt_usr) modified_by 
from sbrext.concept_sources_lov_ext c
where  NOT EXISTS (select*from obj_key where trim(NCI_CD)=trim(c.CONCEPT_SOURCE) and obj_typ_id=23)
)
loop
                
 insert into obj_key (obj_key_id,
 obj_typ_id, 
 obj_key_desc, 
 obj_key_def, 
 nci_cd,
 CREAT_USR_ID, 
 CREAT_DT, 
 LST_UPD_DT,
 LST_UPD_USR_ID)
VALUES( v_cnt, 23, 
cur.CONCEPT_SOURCE,
cur.DESCRIPTION, 
cur.CONCEPT_SOURCE,  
cur.created_by,            
cur.date_created ,
cur.date_modified, 
cur.date_created);
v_cnt := v_cnt + 1;
end loop;
COMMIT;   



-- NCI Derivation Type
delete from obj_key where obj_typ_id = 21;  --
commit;
insert into obj_key (obj_typ_id, obj_key_desc,  nci_cd, obj_key_def,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 21, CRTL_NAME,CRTL_NAME, DESCRIPTION ,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.complex_rep_type_lov ;
commit;

-- Definition type
delete from obj_key where obj_typ_id = 15;  --
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 15, DEFL_NAME, description, DEFL_NAME, comments,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbrext.definition_types_lov_ext;

commit;





-- Origin
delete from obj_key where obj_typ_id = 18;  --
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 18, SRC_NAME, description, SRC_NAME,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbrext.sources_ext;


commit;

-- Form Category
delete from obj_key where obj_typ_id = 22;  --
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, DISP_ORD)
select 22, QCDL_NAME, description, QCDL_NAME,    nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr), DISPLAY_ORDER from sbrext.QC_DISPLAY_LOV_EXT;


commit;





delete from obj_key where obj_typ_id = 25;  -- Address Type
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 25, ATL_NAME, description, ATL_NAME, comments,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.ADDR_TYPES_LOV	;
commit;

delete from obj_key where obj_typ_id = 26;  -- Communication Type
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 26, CTL_NAME, description, CTL_NAME, comments,  nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.COMM_TYPES_LOV;
 commit;


end;
/


DROP PROCEDURE ONEDATA_WA.SP_MIGRATE_LOV_REV;

CREATE OR REPLACE procedure ONEDATA_WA.sp_migrate_lov_rev (vDays in Integer)
as
v_cnt integer;
begin

v_cnt := 1;

---- Registration Status


update sbr.reg_status_lov set (description, comments, display_order, date_modified, modified_by) = 
    (select stus_Desc, nci_cmnts, nci_disp_ordr, lst_upd_dt, lst_upd_usr_id 
    from stus_mstr 
    where stus_typ_id = 1 
    and   lst_upd_dt >=  sysdate - vDays 
    and   upper(nci_stus) =upper(registration_status))
where upper(registration_status) in (select upper(nci_stus) from stus_mstr 
    where stus_typ_id =1 
    and   lst_upd_dt >=  sysdate - vDays );


insert into sbr.reg_status_lov (registration_status,description, comments,created_by, date_created, date_modified, modified_by, display_order)
select nci_stus, stus_desc, nci_cmnts,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, NCI_DISP_ORDR 
from stus_mstr 
where stus_typ_id = 1 
and   upper(nci_stus) not in (select upper(registration_status) from sbr.reg_status_lov) 
and   creat_dt >= sysdate - vDays;

--- Administrative Status

update sbr.ac_status_lov set (description, comments, display_order, date_modified, modified_by) = 
    (select  stus_Desc, nci_cmnts, nci_disp_ordr, lst_upd_dt, lst_upd_usr_id from stus_mstr 
    where stus_typ_id = 1 
    and   lst_upd_dt >=  sysdate - vDays 
    and   upper(nci_stus)= upper(asl_name))
where upper(asl_name) in 
    (select upper(nci_stus) from stus_mstr 
    where stus_typ_id =2 
    and   lst_upd_dt >=  sysdate - vDays );

insert into sbr.ac_status_lov (asl_name,description, comments,created_by, date_created, date_modified, modified_by, display_order)
select nci_stus, stus_desc, nci_cmnts,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, NCI_DISP_ORDR 
from stus_mstr 
where stus_typ_id = 2 
and upper(nci_stus) not in (select upper(asl_name) from sbr.ac_status_lov) 
and creat_dt >= sysdate - vDays;
commit;


--- Program Area 

update sbr.PROGRAM_AREAS_LOV  set (description, comments, date_modified, modified_by) = 
    (select  obj_key_def, obj_key_cmnts, LST_UPD_DT,LST_UPD_USR_ID
    from obj_key 
    where obj_typ_id = 14 
    and   lst_upd_dt >= sysdate - vDays 
    and   upper(nci_cd) = upper(pal_name))
where upper(pal_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 14 
    and   lst_upd_dt >=  sysdate - vDays );

insert into sbr.PROGRAM_AREAS_LOV( pal_name, description, comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 14 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(pal_name) from sbr.PROGRAM_AREAS_LOV);


--- Name/Designation Type

update sbr.DESIGNATION_TYPES_LOV set (description,comments, date_modified, modified_by) = 
    (select obj_key_def, obj_key_cmnts, LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 11 
    and   lst_upd_dt > sysdate - vdays 
    and   upper(detl_name) = upper(nci_cd))
where upper(detl_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 11 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbr.DESIGNATION_TYPES_LOV (detl_name, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 11 
and creat_dt > sysdate - vdays 
and upper(nci_cd) not in (select upper(detl_name) from sbr.DESIGNATION_TYPES_LOV);

-- DOcument type - Type ID 1

update sbr.document_TYPES_LOV set ( description,comments, date_modified, modified_by) = 
    (select  obj_key_def, obj_key_cmnts,  LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 1 
    and lst_upd_dt > sysdate - vdays
    and upper(dctl_name) = upper(nci_cd))
    where upper(dctl_name) in 
        (select upper(nci_cd) 
        from obj_key 
        where obj_typ_id = 1 
        and   lst_upd_dt >=  sysdate - vDays );

insert into sbr.document_TYPES_LOV (dctl_name, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 1 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(dctl_name) from sbr.document_TYPES_LOV);


-- Classification Scheme Type - Type Id 3

update sbr.CS_TYPES_LOV set ( description,comments, date_modified, modified_by) = 
    (select obj_key_def, obj_key_cmnts,  LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 3 
    and   lst_upd_dt > sysdate - vdays
    and   upper(CSTL_NAME) = upper(nci_cd))
    where upper(cstl_name) in 
        (select upper(nci_cd) 
        from obj_key 
        where obj_typ_id = 3 
        and   lst_upd_dt >=  sysdate - vDays );

insert into sbr.CS_TYPES_LOV (CSTL_NAME, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 3 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(cstl_name) from sbr.CS_TYPES_LOV);


-- Classification Scheme Item Type - Type ID 20

update sbr.CSI_TYPES_LOV set (description,comments, date_modified, modified_by) = 
    (select obj_key_def, obj_key_cmnts,  LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 20 
    and   lst_upd_dt > sysdate - vdays
    and   upper(CSITL_NAME) = upper(nci_cd))
where upper(csitl_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 20 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbr.CSI_TYPES_LOV (CSITL_NAME, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 20 
and creat_dt > sysdate - vdays 
and upper(nci_cd) not in (select upper(csitl_name) from sbr.CSI_TYPES_LOV);


-- Concept Source - Type ID 23

update sbrext.concept_sources_lov_ext set (description, date_modified, modified_by) = 
    (select obj_key_def,  LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 23 
    and lst_upd_dt > sysdate - vdays
    and upper(CONCEPT_SOURCE) = upper(nci_cd))
where upper(concept_source) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 23 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbrext.concept_sources_lov_ext (CONCEPT_SOURCE, description, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 23 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(CONCEPT_SOURCE) from sbrext.concept_sources_lov_ext);


-- NCI Derivation Type - Type 21

update sbr.complex_rep_type_lov set (description, date_modified, modified_by) = 
    (select obj_key_def, LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 21 
    and   lst_upd_dt > sysdate - vdays
    and   upper(CRTL_NAME) = upper(nci_cd))
where upper(crtl_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 21 
    and   lst_upd_dt >=  sysdate - vDays );


insert into sbr.complex_rep_type_lov (CRTL_NAME, description, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 21 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(CRTL_NAME) from sbr.complex_rep_type_lov);


--- Data type

update sbr.datatypes_lov set (DESCRIPTION,COMMENTS, date_modified, modified_by, SCHEME_REFERENCE, ANNOTATION) = 
    (select DTTYPE_DESC, NCI_DTTYPE_CMNTS, LST_UPD_DT,LST_UPD_USR_ID, DTTYPE_SCHM_REF, DTTYPE_ANNTTN 
    from data_typ 
    where lst_upd_Dt >= sysdate - vDays
    and   nci_dttype_typ_id = 1
    and   upper(dtl_name) = upper(NCI_CD))
where upper(dtl_name) in 
    (select upper(nci_cd) 
    from data_typ 
    where nci_dttype_typ_id=1 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbr.datatypes_lov (dtl_name, DESCRIPTION,COMMENTS, date_modified, modified_by, SCHEME_REFERENCE, ANNOTATION) 
select  NCI_CD, DTTYPE_DESC, NCI_DTTYPE_CMNTS, LST_UPD_DT,LST_UPD_USR_ID, DTTYPE_SCHM_REF, DTTYPE_ANNTTN 
from data_typ 
where lst_upd_Dt >= sysdate - vDays
and   nci_dttype_typ_id = 1
and   upper(nci_cd) not in (select upper(dtl_name) from sbr.datatypes_lov);


/*insert into data_typ ( DTTYPE_NM, NCI_CD, DTTYPE_DESC, NCI_DTTYPE_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
DTTYPE_SCHM_REF, DTTYPE_ANNTTN)
select DTL_NAME, DTL_NAME, DESCRIPTION,COMMENTS,
created_by, date_created,date_modified, modified_by,
SCHEME_REFERENCE, ANNOTATION from sbr.datatypes_lov;
*/
-- Format


insert into sbr.formats_lov (FORML_NAME,DESCRIPTION,COMMENTS, created_by, date_created,date_modified, modified_by)
select NCI_CD,FMT_DESC,FMT_CMNTS, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from fmt 
where creat_dt >= sysdate - vDays 
and upper(nci_cd) not in (select upper(forml_name) from sbr.formats_lov);

/*insert into FMT ( FMT_NM, NCI_CD,FMT_DESC,FMT_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select FORML_NAME, FORML_NAME,DESCRIPTION,COMMENTS,
created_by, date_created,date_modified, modified_by from sbr.formats_lov;
*/

-- UOM

insert into sbr.unit_of_measures_lov (UOML_NAME,PRECISION, DESCRIPTION,COMMENTS, created_by, date_created,date_modified, modified_by)
select NCI_CD, UOM_PREC,UOM_DESC,UOM_CMNTS, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from UOM 
where creat_dt >= sysdate - vDays 
and upper(NCI_CD) not in (select upper(UOML_NAME) from sbr.unit_of_measures_lov);


-- Definition type - type id 15

update sbrext.definition_types_lov_ext set (DEFL_NAME, description,comments, date_modified, modified_by) = 
    (select nci_cd, obj_key_def, obj_key_cmnts, LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 15 
    and   lst_upd_dt > sysdate - vdays
    and   upper(DEFL_NAME) = upper(nci_cd))
where upper(defl_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 15 
    and   lst_upd_dt >=  sysdate - vDays );



insert into sbrext.definition_types_lov_ext (DEFL_NAME, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 15 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(DEFL_NAME) from sbrext.definition_types_lov_ext);


/*insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 15, DEFL_NAME, description, DEFL_NAME, comments, created_by, date_created,
                    date_modified, modified_by from sbrext.definition_types_lov_ext;
*/                   

-- Origin - Type id 18

update sbrext.sources_ext set (SRC_NAME, description, date_modified, modified_by) = 
    (select nci_cd, obj_key_def, LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 18 
    and   lst_upd_dt > sysdate - vdays
    and   upper(SRC_NAME) = upper(nci_cd))
where upper(src_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 18 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbrext.sources_ext (SRC_NAME, description, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 18 
and creat_dt > sysdate - vdays 
and upper(nci_cd) not in (select upper(SRC_NAME) from sbrext.sources_ext);


/*insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 18, SRC_NAME, description, SRC_NAME,  created_by, date_created,
                    date_modified, modified_by from sbrext.sources_ext;

*/


-- Form Category - Type id 22

update sbrext.QC_DISPLAY_LOV_EXT set (QCDL_NAME, description, date_modified, modified_by) = 
    (select nci_cd, obj_key_def, LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 22 
    and   lst_upd_dt > sysdate - vdays
    and   upper(QCDL_NAME) = upper(nci_cd))
where upper(qcdl_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 22 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbrext.QC_DISPLAY_LOV_EXT (QCDL_NAME, description, created_by, date_created, date_modified, modified_by, display_order)
select nci_cd, obj_key_def, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, 1 
from obj_key 
where obj_typ_id = 22 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(QCDL_NAME) from sbrext.QC_DISPLAY_LOV_EXT);
commit;


/*insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 22, QCDL_NAME, description, QCDL_NAME,  created_by, date_created,
                    date_modified, modified_by from sbrext.QC_DISPLAY_LOV_EXT;
*/


/*
delete from org;
commit;

insert into org (NCI_IDSEQ, ORG_NM, RA_IND,ORG_MAIL_ADR,CREAT_USR_ID,CREAT_DT,
LST_UPD_USR_ID, LST_UPD_DT)
select ORG_IDSEQ,NAME,
decode(RA_IND, 'No',0,'Yes',1),
MAIL_ADDRESS,CREATED_BY,
DATE_CREATED,
MODIFIED_BY,
DATE_MODIFIED
from sbr.organizations;
commit;
*/

end;
/


DROP PROCEDURE ONEDATA_WA.SP_POSTPROCESS;

CREATE OR REPLACE procedure ONEDATA_WA.sp_postprocess
as
v_cnt integer;
begin

delete from NCI_ADMIN_ITEM_EXT;
commit;

delete from onedata_ra.NCI_ADMIN_ITEM_EXT;
commit;

--- Data Element
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR, USED_BY)
select ai.item_id, ai.ver_nr, a.used_by
from  admin_item ai,
(SELECT item_id, ver_nr, LISTAGG(item_nm, ',') WITHIN GROUP (ORDER by ITEM_ID) AS USED_BY
FROM (select distinct ub.item_id,ub.ver_nr, c.item_nm from vw_nci_used_by ub, vw_cntxt c where ub.cntxt_item_id = c.item_id and ub.cntxt_ver_nr = c.ver_nr and ub.owned_by=0 )
GROUP BY item_id, ver_nr) a
where ai.item_id = a.item_id (+) and ai.ver_nr = a.ver_nr(+)
and ai.admin_item_typ_id = 4;
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,  CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def, CNCPT_CONCAT_WITH_INT)
select ai.item_id, ai.ver_nr, b.cncpt_cd, b.CNCPT_nm, b.cncpt_def, b.cncpt_cd_int
from  admin_item ai,
(SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_long_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD ,
LISTAGG(ai.item_nm, ' ')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_NM ,
 LISTAGG(substr(ai.item_desc,1, 750), '_')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_DEF,
 LISTAGG(decode(ai.item_long_nm, 'C45255',decode( cai.nci_cncpt_val,null, ai.item_long_nm, ai.item_long_nm || '::' || cai.NCI_CNCPT_VAL),ai.item_long_nm), ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD_INT
from cncpt_admin_item cai, admin_item ai where ai.item_id = cai.cncpt_item_id and ai.ver_nr = cai.cncpt_ver_nr
group by cai.item_id, cai.ver_nr) b
where ai.item_id = b.item_id (+) and ai.ver_nr = b.ver_nr (+)
and ai.admin_item_typ_id in (1,2,3,5,6,7,53);
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,  CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select ai.item_id, ai.ver_nr, ai.item_long_nm, ai.item_nm, ai.item_desc
from admin_item ai where ai.admin_item_typ_id = 49;
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR)
select ai.item_id, ai.ver_nr from  admin_item ai
where ai.admin_item_typ_id in (8,9,50,51,52,54,56);
commit;


update nci_admin_item_ext e set (cncpt_concat, cncpt_concat_nm) = (select item_nm, item_nm from admin_item ai where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.admin_item_typ_id = 53)
where e.cncpt_concat is null and
(e.item_id, e.ver_nr) in (select item_id, ver_nr from admin_item where admin_item_typ_id= 53);

commit;

insert into onedata_ra.NCI_ADMIN_ITEM_EXT select * from NCI_ADMIN_ITEM_EXT;
commit;

delete from nci_usr_cart where CNTCT_SECU_ID = 'GUEST';
commit;

delete from onedata_ra.nci_usr_cart where CNTCT_SECU_ID = 'GUEST';
commit;
end;
/


DROP PROCEDURE ONEDATA_WA.SP_PREPROCESS;

CREATE OR REPLACE procedure ONEDATA_WA.sp_preprocess
as
v_cnt integer;
begin

update sbr.administered_components set version=2.99 where ac_idseq = 'AECD5F45-40DE-6F74-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = '99BA9DC8-2782-4E69-E034-080020C9C0E0';
update sbr.administered_components set version=3.99 where ac_idseq = 'B96A571D-FCFF-23B9-E034-0003BA12F5E7';
update sbr.administered_components set version=4.99 where ac_idseq = 'C2F74AAA-C66F-2D5B-E034-0003BA12F5E7';
update sbr.administered_components set version=4.99 where ac_idseq = 'BAD1CCE2-EEA3-09A9-E034-0003BA12F5E7';
update sbr.administered_components set version=3.99 where ac_idseq = '9B8825ED-D747-0817-E034-080020C9C0E0';
update sbr.administered_components set version=2.99 where ac_idseq = 'B2044F73-E974-68B8-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'BFF123A5-B223-1C5B-E034-0003BA12F5E7';
update sbr.administered_components set version=1.99 where ac_idseq = 'BFF123A5-B1F2-1C5B-E034-0003BA12F5E7';
update sbr.administered_components set version=3.99 where ac_idseq = 'DB67CC4F-54E4-474F-E034-0003BA12F5E7';
update sbr.administered_components set version=99.99 where ac_idseq = 'E063C484-B72A-4D2C-E034-0003BA12F5E7';
update sbr.administered_components set version=3.99 where ac_idseq = 'B30B7C1F-2DCF-1182-E034-0003BA12F5E7';
update sbr.administered_components set version=4.99 where ac_idseq = 'DDEAEB6E-32A1-3CD4-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'DBF67698-F1E1-675B-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'DB67CC4F-5242-474F-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'DBF67698-EE6F-675B-E034-0003BA12F5E7';

commit;



update sbr.value_domains set version=2.99 where vd_idseq = 'AECD5F45-40DE-6F74-E034-0003BA12F5E7';
update sbr.value_domains set version=2.99 where vd_idseq = '99BA9DC8-2782-4E69-E034-080020C9C0E0';
update sbr.value_domains set version=3.99 where vd_idseq = 'B96A571D-FCFF-23B9-E034-0003BA12F5E7';
update sbr.value_domains set version=4.99 where vd_idseq = 'C2F74AAA-C66F-2D5B-E034-0003BA12F5E7';
update sbr.value_domains set version=4.99 where vd_idseq = 'BAD1CCE2-EEA3-09A9-E034-0003BA12F5E7';
update sbr.value_domains set version=3.99 where vd_idseq = '9B8825ED-D747-0817-E034-080020C9C0E0';
update sbr.value_domains set version=2.99 where vd_idseq = 'B2044F73-E974-68B8-E034-0003BA12F5E7';
update sbr.value_domains set version=2.99 where vd_idseq = 'BFF123A5-B223-1C5B-E034-0003BA12F5E7';
update sbr.value_domains set version=1.99 where vd_idseq = 'BFF123A5-B1F2-1C5B-E034-0003BA12F5E7';
update sbr.value_domains set version=3.99 where vd_idseq = 'DB67CC4F-54E4-474F-E034-0003BA12F5E7';
update sbr.value_domains set version=99.99 where vd_idseq = 'E063C484-B72A-4D2C-E034-0003BA12F5E7';
update sbr.value_domains set version=3.99 where vd_idseq = 'B30B7C1F-2DCF-1182-E034-0003BA12F5E7';
update sbr.value_domains set version=4.99 where vd_idseq = 'DDEAEB6E-32A1-3CD4-E034-0003BA12F5E7';
update sbr.value_domains set version=2.99 where vd_idseq = 'DBF67698-F1E1-675B-E034-0003BA12F5E7';
update sbr.value_domains set version=2.99 where vd_idseq = 'DB67CC4F-5242-474F-E034-0003BA12F5E7';
update sbr.value_domains set version=2.99 where vd_idseq = 'DBF67698-EE6F-675B-E034-0003BA12F5E7';

commit;


update sbr.data_elements set version=2.99 where de_idseq = 'AECD5F45-40DE-6F74-E034-0003BA12F5E7';
update sbr.data_elements set version=2.99 where de_idseq = '99BA9DC8-2782-4E69-E034-080020C9C0E0';
update sbr.data_elements set version=3.99 where de_idseq = 'B96A571D-FCFF-23B9-E034-0003BA12F5E7';
update sbr.data_elements set version=4.99 where de_idseq = 'C2F74AAA-C66F-2D5B-E034-0003BA12F5E7';
update sbr.data_elements set version=4.99 where de_idseq = 'BAD1CCE2-EEA3-09A9-E034-0003BA12F5E7';
update sbr.data_elements set version=3.99 where de_idseq = '9B8825ED-D747-0817-E034-080020C9C0E0';
update sbr.data_elements set version=2.99 where de_idseq = 'B2044F73-E974-68B8-E034-0003BA12F5E7';
update sbr.data_elements set version=2.99 where de_idseq = 'BFF123A5-B223-1C5B-E034-0003BA12F5E7';
update sbr.data_elements set version=1.99 where de_idseq = 'BFF123A5-B1F2-1C5B-E034-0003BA12F5E7';
update sbr.data_elements set version=3.99 where de_idseq = 'DB67CC4F-54E4-474F-E034-0003BA12F5E7';
update sbr.data_elements set version=99.99 where de_idseq = 'E063C484-B72A-4D2C-E034-0003BA12F5E7';
update sbr.data_elements set version=3.99 where de_idseq = 'B30B7C1F-2DCF-1182-E034-0003BA12F5E7';
update sbr.data_elements set version=4.99 where de_idseq = 'DDEAEB6E-32A1-3CD4-E034-0003BA12F5E7';
update sbr.data_elements set version=2.99 where de_idseq = 'DBF67698-F1E1-675B-E034-0003BA12F5E7';
update sbr.data_elements set version=2.99 where de_idseq = 'DB67CC4F-5242-474F-E034-0003BA12F5E7';
update sbr.data_elements set version=2.99 where de_idseq = 'DBF67698-EE6F-675B-E034-0003BA12F5E7';

commit;

update sbr.contact_comms set rank_order = 3 where cyber_address = 'Help Desk' and per_idseq = '2D6163C0-33B6-24D0-E044-0003BA3F9857' and rank_order = 1;
commit;

update sbr.ac_contacts set rank_order = 2 where acc_idseq = 'B4C3ADBF-7881-0548-E034-0003BA12F5E7';
commit;


end;
/


DROP PROCEDURE ONEDATA_WA.SP_REVFORM;

CREATE OR REPLACE procedure ONEDATA_WA.sp_revform
as
v_cnt integer;
begin

nci_cadsr_push_core.spPushAIType(1,54);

nci_cadsr_push_form.PushModule(1);

nci_cadsr_push_form.PushQuestion(1);

nci_cadsr_push_form.PushQuestValidValue(1);

/*

nci_cadsr_push_core.spPushAIType(1,54);

exec nci_cadsr_push_form.PushModule(1);

exec nci_cadsr_push_form.PushQuestion(1);

exec nci_cadsr_push_form.PushQuestValidValue(1);

*/
raise_application_error(-20000, 'Completed');

end;
/


DROP PROCEDURE ONEDATA_WA.SP_REVPROCESS;

CREATE OR REPLACE procedure ONEDATA_WA.sp_revprocess
as
v_cnt integer;
begin

nci_cadsr_push_core.spPushAI(1);

nci_cadsr_push.spPushAIChildren(1);

nci_cadsr_push.spPushAISpecific(1);

/* 
exec nci_cadsr_push_core.spPushAI(1);

exec nci_cadsr_push.spPushAIChildren(1);

exec nci_cadsr_push.spPushAISpecific(1);
*/
raise_application_error(-20000, 'Completed');

end;
/


DROP PROCEDURE ONEDATA_WA.SP_TEST_ALL;

CREATE OR REPLACE procedure ONEDATA_WA.sp_test_all 
as
v_cnt integer;
begin

delete from test_results;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'DE', 
(select count(*)-1 from onedata_wa.de) WA_CNT,
(select count(*)-1 from onedata_ra.de) RA_CNT,
(select count(*) from sbr.data_elements) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'DE Concept', 
(select count(*)-1 from onedata_wa.de_conc) WA_CNT,
(select count(*)-1 from onedata_ra.de_conc) RA_CNT,
(select count(*) from sbr.data_element_concepts) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Format', 
(select count(*) from onedata_wa.fmt) WA_CNT,
(select count(*) from onedata_ra.fmt) RA_CNT,
(select count(*) from sbr.formats_lov) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Data type', 
(select count(*) from onedata_wa.data_typ where nci_dttype_typ_id = 1) WA_CNT,
(select count(*) from onedata_ra.data_typ where nci_dttype_typ_id = 1) RA_CNT,
(select count(*) from sbr.datatypes_lov) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Registration Status', 
(select count(*) from onedata_wa.stus_mstr where stus_typ_id = 1) WA_CNT,
(select count(*) from onedata_ra.stus_mstr where stus_typ_id = 1) RA_CNT,
(select count(*) from sbr.reg_status_lov) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Workflow Status', 
(select count(*) from onedata_wa.stus_mstr where stus_typ_id = 2) WA_CNT,
(select count(*) from onedata_ra.stus_mstr where stus_typ_id = 2) RA_CNT,
(select count(*) from sbr.ac_status_lov) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'UOM', 
(select count(*) from onedata_wa.UOM) WA_CNT,
(select count(*) from onedata_ra.UOM) RA_CNT,
(select count(*) from sbr.unit_of_measures_lov) caDSR_CNT
from dual;
commit;




insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'VV Repetition', 
(select count(*) from onedata_wa.NCI_QUEST_VV_REP) WA_CNT,
(select count(*) from onedata_ra.NCI_QUEST_VV_REP) RA_CNT,
(select count(*) from sbrext.quest_vv_ext ) caDSR_CNT
from dual;
commit;





insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Conceptual Domain', 
(select count(*)-1 from onedata_wa.conc_dom) WA_CNT,
(select count(*)-1 from onedata_ra.conc_dom) RA_CNT,
(select count(*) from sbr.conceptual_domains) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Object Class', 
(select count(*)-1 from onedata_wa.obj_cls) WA_CNT,
(select count(*)-1 from onedata_ra.obj_cls) RA_CNT,
(select count(*) from sbrext.object_classes_ext) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Property', 
(select count(*)-1 from onedata_wa.prop) WA_CNT,
(select count(*)-1 from onedata_ra.prop) RA_CNT,
(select count(*) from sbrext.properties_ext) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Value Domain', 
(select count(*)-1 from onedata_wa.value_dom) WA_CNT,
(select count(*)-1 from onedata_ra.value_dom) RA_CNT,
(select count(*) from sbr.value_domains) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Concept', 
(select count(*) from onedata_wa.CNCPT) WA_CNT,
(select count(*) from onedata_ra.CNCPT) RA_CNT,
(select count(*) from sbrext.concepts_ext) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'CSI', 
(select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM) WA_CNT,
(select count(*) from onedata_ra.NCI_CLSFCTN_SCHM_ITEM) RA_CNT,
(select count(*) from sbr.cs_items) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Classification Scheme', 
(select count(*) from onedata_wa.CLSFCTN_SCHM) WA_CNT,
(select count(*) from onedata_ra.CLSFCTN_SCHM) RA_CNT,
(select count(*) from sbr.classification_schemes) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Representation Class', 
(select count(*) from onedata_wa.REP_CLS) WA_CNT,
(select count(*) from onedata_ra.REP_CLS) RA_CNT,
(select count(*) from SBREXT.representations_ext) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Value Meaning', 
(select count(*) from onedata_wa.NCI_VAL_MEAN) WA_CNT,
(select count(*) from onedata_ra.NCI_VAL_MEAN) RA_CNT,
(select count(*) from SBR.value_meanings) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Protocol', 
(select count(*) from onedata_wa.NCI_PROTCL) WA_CNT,
(select count(*) from onedata_ra.NCI_PROTCL) RA_CNT,
(select count(*) from sbrext.protocols_ext) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'OC Recs', 
(select count(*) from onedata_wa.NCI_OC_RECS) WA_CNT,
(select count(*) from onedata_ra.NCI_OC_RECS) RA_CNT,
(select count(*) from SBREXT.oc_recs_ext) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Context', 
(select count(*) from onedata_wa.CNTXT) WA_CNT,
(select count(*) from onedata_ra.CNTXT) RA_CNT,
(select count(*) from sbr.contexts) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'CD-VM', 
(select count(*) from onedata_wa.conc_dom_val_mean) WA_CNT,
(select count(*) from onedata_ra.conc_dom_val_mean) RA_CNT,
(select count(*) from sbr.cd_vms) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'PV', 
(select count(*) from onedata_wa.PERM_VAL) WA_CNT,
(select count(*) from onedata_ra.PERM_VAL) RA_CNT,
(select count(*) from sbr.vd_pvs) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Concept - AI', 
(select count(*) from onedata_wa.CNCPT_ADMIN_ITEM) WA_CNT,
(select count(*) from onedata_ra.CNCPT_ADMIN_ITEM) RA_CNT,
(select count(*) from sbrext.COMPONENT_CONCEPTS_EXT) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Designations', 
(select count(*) from onedata_wa.ALT_NMS) WA_CNT,
(select count(*) from onedata_ra.ALT_NMS) RA_CNT,
(select count(*) from sbr.designations) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Definitions', 
(select count(*) from onedata_wa.ALT_DEF) WA_CNT,
(select count(*) from onedata_ra.ALT_DEF) RA_CNT,
(select count(*) from sbr.definitions) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Reference Documents', 
(select count(*) from onedata_wa.REF) WA_CNT,
(select count(*) from onedata_ra.REF) RA_CNT,
(select count(*) from SBR.reference_documents) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Trigger Actions', 
(select count(*) from onedata_wa.NCI_FORM_TA) WA_CNT,
(select count(*) from onedata_ra.NCI_FORM_TA) RA_CNT,
(select count(*) from sbrext.triggered_actions_ext) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Trigger Actions Protocol/CSI', 
(select count(*) from onedata_wa.NCI_FORM_TA_REL) WA_CNT,
(select count(*) from onedata_ra.NCI_FORM_TA_REL) RA_CNT,
(select count(*) from sbrext.ta_proto_csi_ext) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Organization', 
(select count(*) from onedata_wa.NCI_ORG) WA_CNT,
(select count(*) from onedata_ra.NCI_ORG) RA_CNT,
(select count(*) from sbr.ORGANIZATIONS) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Person', 
(select count(*) from onedata_wa.NCI_PRSN) WA_CNT,
(select count(*) from onedata_ra.NCI_PRSN) RA_CNT,
(select count(*) from sbr.persons) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Addresses', 
(select count(*) from onedata_wa.NCI_ENTTY_ADDR) WA_CNT,
(select count(*) from onedata_ra.NCI_ENTTY_ADDR) RA_CNT,
(select count(*) from sbr.contact_addresses) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Communications', 
(select count(*) from onedata_wa.NCI_ENTTY_COMM) WA_CNT,
(select count(*) from onedata_ra.NCI_ENTTY_COMM) RA_CNT,
(select count(*) from sbr.contact_comms) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Form', 
(select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 54) WA_CNT,
(select count(*) from onedata_ra.ADMIN_ITEM where admin_item_typ_id = 54) RA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE')) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Module', 
(select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 52) WA_CNT,
(select count(*) from onedata_ra.ADMIN_ITEM where admin_item_typ_id = 52) RA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'MODULE') caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Question', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63) WA_CNT,
(select count(*) from onedata_ra.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63) RA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'QUESTION') caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Question VV', 
(select count(*) from onedata_wa.NCI_QUEST_VALID_VALUE ) WA_CNT,
(select count(*) from onedata_ra.NCI_QUEST_VALID_VALUE ) RA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'VALID_VALUE') caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'CS CSI', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 64) WA_CNT,
(select count(*) from onedata_ra.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 64 ) RA_CNT,
(select count(*) from sbr.cs_csi) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'CS CSI DE Relationship', 
(select count(*) from onedata_wa.NCI_ALT_KEY_ADMIN_ITEM_REL) WA_CNT,
(select count(*) from onedata_ra.NCI_ALT_KEY_ADMIN_ITEM_REL ) RA_CNT,
(select count(*) from sbr.ac_csi) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Program Area', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 14) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 14 ) RA_CNT,
(select count(*) from sbr.PROGRAM_AREAS_LOV) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Designation Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 11) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 11 ) RA_CNT,
(select count(*) from sbr.DESIGNATION_TYPES_LOV) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Address Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 25) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 25 ) RA_CNT,
(select count(*) from sbr.ADDR_TYPES_LOV) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Communication Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 26) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 26 ) RA_CNT,
(select count(*) from sbr.COMM_TYPES_LOV) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Status-Admin Type Relationship', 
(select count(*) from onedata_wa.NCI_AI_TYP_VALID_STUS ) WA_CNT,
(select count(*) from onedata_ra.NCI_AI_TYP_VALID_STUS  ) RA_CNT,
(select count(*) from sbrext.ASL_ACTL_EXT) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Derivation Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 21) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 21 ) RA_CNT,
(select count(*) from sbr.complex_rep_type_lov) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Document Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 1) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 1 ) RA_CNT,
(select count(*) from sbr.document_TYPES_LOV) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Classification Scheme Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 3) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 3 ) RA_CNT,
(select count(*) from sbr.CS_TYPES_LOV) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'CSI Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 20) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 20 ) RA_CNT,
(select count(*) from sbr.CSI_TYPES_LOV ) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Definition Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 15) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 15 ) RA_CNT,
(select count(*) from sbrext.definition_types_lov_ext) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Origin', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 18) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 18 ) RA_CNT,
(select count(*) from sbrext.sources_ext) caDSR_CNT
from dual;
commit;


end;
/


DROP PROCEDURE ONEDATA_WA.TEMP;

CREATE OR REPLACE procedure ONEDATA_WA.temp as
i integer;
v_found boolean;
v_max_rep integer;

v_dflt_usr  varchar2(30) := 'ONEDATA';

v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
v_dflt_date date := to_date('8/18/2020','mm/dd/yyyy');

begin

delete from nci_protcl;
commit;

  INSERT INTO nci_protcl (item_id,
                            ver_nr,
                            PROTCL_TYP_ID,
                            PROTCL_ID,
                            LEAD_ORG,
                            PROTCL_PHASE,
                            creat_usr_id,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID,
                            CHNG_TYP,
                            CHNG_NBR,
                            RVWD_DT,
                            RVWD_USR_ID,
                            APPRVD_DT,
                            APPRVD_USR_ID,
                            LEAD_ORG_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               ok.obj_key_id,
               protocol_id,
               LEAD_ORG,
               PHASE,
nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created,v_dflt_date) ,
               nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr),
                    CHANGE_TYPE,
               CHANGE_NUMBER,
               REVIEWED_DATE,
               REVIEWED_BY,
               APPROVED_DATE,
               APPROVED_BY,
               ORG.ENTTY_ID
          FROM sbrext.protocols_ext cd, admin_item ai, obj_key ok, nci_org org
         WHERE     ai.NCI_IDSEQ = cd.proto_IDSEQ
               AND TRIM (TYPE) = ok.nci_cd(+)
               AND ok.obj_typ_id(+) = 19
               AND ai.admin_item_typ_id = 50
               and cd.LEAD_ORG =org.ORG_NM(+);

    COMMIT;
end;
/


DROP PROCEDURE ONEDATA_WA.TEST_SEQUENCE;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.Test_sequence AS
v_de_idseq CHAR(36);
l_curr number := 0;
BEGIN
 execute immediate
  'select test_SEQ.nextval from dual' INTO l_curr;
execute immediate
'alter sequence test_SEQ increment by 1 minvalue ' || l_curr;
END Test_sequence;
/


DROP PROCEDURE ONEDATA_WA.TEST_SEQ_DC;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.test_SEQ_DC AS
begin
  begin
      execute immediate 'DROP SEQUENCE test_SEQ';
      exception when others then
        null;
    end;
    execute immediate 'CREATE SEQUENCE test_SEQ INCREMENT BY 1 START WITH 1000 NOCYCLE CACHE 20 NOORDER';
 
end;
/


DROP PROCEDURE ONEDATA_WA.TEST_SEQ_DC_NV;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.test_SEQ_DC_NV AS
begin
  begin
      execute immediate 'DROP SEQUENCE test_SEQ';
      exception when others then
        null;
    end;
    execute immediate 'CREATE SEQUENCE test_SEQ INCREMENT BY 1 START WITH 1000 NOCYCLE CACHE 20 NOORDER';
insert into obj_key (obj_key_id,obj_typ_id, obj_key_desc, obj_key_def, nci_cd)
select  test_SEQ.nextval,23, CONCEPT_SOURCE,DESCRIPTION, CONCEPT_SOURCE from sbrext.concept_sources_lov_ext ;
commit;
end;
/
