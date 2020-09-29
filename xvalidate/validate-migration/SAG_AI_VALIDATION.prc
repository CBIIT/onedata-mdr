CREATE OR REPLACE PROCEDURE SAG_AI_VALIDATION
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
NVL(SB.CREATED_BY,''ONEDATA''), NVL(SB.DATE_CREATED,to_date(''8/18/2020'',''mm/dd/yyyy'')),
NVL(NVL(SB.DATE_MODIFIED, SB.DATE_CREATED),to_date(''8/18/2020'',''mm/dd/yyyy'')), NVL(SB.MODIFIED_BY,''ONEDATA'')
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
            INSERT INTO ONEDATA_MIGRATION_ERROR VALUES
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
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date(''8/18/2020'',''mm/dd/yyyy'')), NVL(AC.MODIFIED_BY,''ONEDATA'')
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
