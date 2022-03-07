create or replace FUNCTION SAG_FUNC_MIGR_LONG_NAME (LONG_NAME VARCHAR2, AI_TYPE_ID number) RETURN VARCHAR2
IS
V_LONG_NAME VARCHAR2(255) := LONG_NAME;
BEGIN
-- Migration processing related changes: MODULES long names are trimmed and tab character removed
IF (AI_TYPE_ID = 52) THEN -- MODULE type
V_LONG_NAME:= replace(trim(V_LONG_NAME),chr(9),''); -- this is the code used in migration sp_create_form_ext
END IF;
RETURN V_LONG_NAME;
END;
/
create or replace PROCEDURE SAG_AI_VALIDATION
AS
   --DECLARE

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
AC.ORIGIN,SB.PREFERRED_DEFINITION, ' --Not to pick from ADMINISTERED_COMPONENTS
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
SUBSTR(NVL(SAG_FUNC_MIGR_LONG_NAME(AC.LONG_NAME,' || Y.ITEM_TYPE_CODE || '),AC.PREFERRED_NAME),0,255),AC.VERSION,
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
create or replace PROCEDURE SAG_AI_VALIDATION_REV
AS
    --DECLARE

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
              FROM AI_INPUT_TAB_REV)
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
nci_cadsr_push.getShortDef(ITEM_DESC) ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID,ADMIN_STUS_NM_DN
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
AC.ORIGIN,SB.PREFERRED_DEFINITION, ' --Not to pick from ADMINISTERED_COMPONENTS
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
            INSERT INTO ONEDATA_REVERSE_ERROR VALUES
            (ERR_SEQ.NEXTVAL,X.NCI_IDSEQ,X.ITEM_ID,X.VER_NR,'''||Y.ITEM_TYPE||''',SUBSTR(X.ITEM_LONG_NM,50),''DATA MISMATCH'',SYSDATE,USER,''ADMIN_ITEM'','''');
            COMMIT;
            END LOOP;
            END;';
WHEN ITEM_CODE=51 THEN -- CS_ITEMS exclude migrated as retired deleted from compare
            vSQL := SAG_AI_AI_CSI_COMPARE(Y.ITEM_TYPE_CODE, Y.IDSEQ_NAME, Y.ITEMID_NAME, Y.TAB_NAME, Y.CONDITION, Y.ITEM_TYPE, 'REVERSE');
ELSE

vSQL :=
               'BEGIN
           FOR X in (Select /*+ PARALLEL(12) */ DISTINCT NCI_IDSEQ, ITEM_LONG_NM,
ITEM_ID,VER_NR from 
(select NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
nci_cadsr_push.getShortDef(ITEM_DESC) ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID,ADMIN_STUS_NM_DN
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
SUBSTR(NVL(SAG_FUNC_MIGR_LONG_NAME(AC.LONG_NAME,' || Y.ITEM_TYPE_CODE || '),AC.PREFERRED_NAME),0,255),AC.VERSION,
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
            INSERT INTO ONEDATA_REVERSE_ERROR VALUES
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
                               nci_cadsr_push.getShortDef(ITEM_DESC)  ITEM_DESC,
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
        INSERT INTO ONEDATA_REVERSE_ERROR
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