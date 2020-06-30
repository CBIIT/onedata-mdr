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
BEGIN
    -- get the list of tables and their corresponding distinct columns from the table
    FOR Y
        IN (SELECT ITEMID_NAME,
                   IDSEQ_NAME,
                   TAB_NAME,
                   ITEM_TYPE,
                   ITEM_TYPE_CODE,
                   CONDITION
              FROM ONEDATA_WA.AI_INPUT_TAB)
    LOOP
        vSQL :=
               'BEGIN
           FOR X in (Select /*+ PARALLEL(12) */ DISTINCT NCI_IDSEQ, ITEM_LONG_NM,
ITEM_ID,VER_NR from 
(select NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
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
NVL(AC.LONG_NAME,AC.PREFERRED_NAME),AC.VERSION,
AC.CREATED_BY, AC.DATE_CREATED,
NVL(AC.DATE_MODIFIED, AC.DATE_CREATED), AC.MODIFIED_BY
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
            INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR VALUES
            (SBREXT.ERR_SEQ.NEXTVAL,X.NCI_IDSEQ,X.ITEM_ID,X.VER_NR,'''||Y.ITEM_TYPE||''',X.ITEM_LONG_NM,''DATA MISMATCH'',SYSDATE,USER,''ADMIN_ITEM'');
            COMMIT;
            END LOOP;
            END;';

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
                          FROM onedata_wa.admin_item    --11/8/2019 4:41:54 PM
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
                               created_by,
                               date_created,
                               NVL (date_modified, date_created),
                               modified_by
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
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
             VALUES (SBREXT.ERR_SEQ.NEXTVAL,
                     X.NCI_iDSEQ,
                     X.ITEM_DESC,
                     X.VER_NR,
                     'CONTEXT',
                     X.ITEM_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'ADMIN_ITEM');

        COMMIT;
    END LOOP;
END;
/
