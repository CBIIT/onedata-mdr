CREATE TABLE ONEDATA_REVERSE_ERROR
(	ERR_ID NUMBER, 
	IDSEQ VARCHAR2(50 BYTE) , 
	PUBLIC_ID NUMBER, 
	VERSION NUMBER(4,2), 
	ACTL_NAME VARCHAR2(50 BYTE) , 
	PREFERRED_NAME VARCHAR2(400 BYTE) , 
	ERROR_DESC VARCHAR2(50 BYTE) , 
	DATE_CREATED DATE DEFAULT Sysdate, 
	CREATED_BY VARCHAR2(50 BYTE) , 
	DESTINATION VARCHAR2(50 BYTE) , 
	TIER VARCHAR2(50 BYTE) 
);
create or replace FUNCTION SAG_AI_AI_CSI_COMPARE (Y_ITEM_TYPE_CODE VARCHAR2,
Y_IDSEQ_NAME VARCHAR2, Y_ITEMID_NAME VARCHAR2, Y_TAB_NAME VARCHAR2, Y_CONDITION VARCHAR2,
Y_ITEM_TYPE VARCHAR2, VALIDATION_TYPE VARCHAR2 DEFAULT 'MIGRATE') RETURN VARCHAR2
IS
vSQL VARCHAR2 (4000);
vCOND VARCHAR2 (8);
vSBR VARCHAR2(16);
BEGIN
	CASE
	WHEN Y_CONDITION IS NULL THEN
	vCOND := ' WHERE';
	ELSE
	vCOND := ' AND';
	END CASE;
	CASE
	WHEN VALIDATION_TYPE = 'MIGRATE' THEN
	vSBR := 'SBR_M';
	ELSE
	vSBR := 'SBR';
	END CASE;
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
            || Y_ITEM_TYPE_CODE
            || ' and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
                 and NCI_IDSEQ in (select CSI_IDSEQ from ' || vSBR || '.cs_CSI)
 UNION ALL
 select '
            || Y_IDSEQ_NAME
            || ' , '
            || Y_ITEM_TYPE_CODE
            || ' ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),''YES'', 1,''NO'',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, '
            || Y_ITEMID_NAME
            || ' ,
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,''ONEDATA''), NVL(AC.DATE_CREATED,to_date(''8/18/2020'',''mm/dd/yyyy'')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date(''8/18/2020'',''mm/dd/yyyy'')), NVL(AC.MODIFIED_BY,''ONEDATA''),AC.ASL_NAME
FROM '
            || Y_TAB_NAME
            || ' AC ' ||
Y_CONDITION || vCOND || ' CSI_IDSEQ in (select CSI_IDSEQ from ' || vSBR || '.cs_CSI))
 GROUP BY NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID,ADMIN_STUS_NM_DN
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
            LOOP
--            DBMS_OUTPUT.PUT_LINE(X.NCI_IDSEQ || '' | '' || X.ITEM_ID || '' | '' || X.VER_NR || '' | '' || X.ITEM_LONG_NM);
            INSERT INTO ONEDATA_MIGRATION_ERROR VALUES
            (ERR_SEQ.NEXTVAL,X.NCI_IDSEQ,X.ITEM_ID,X.VER_NR,'''||Y_ITEM_TYPE||''',SUBSTR(X.ITEM_LONG_NM,50),''DATA MISMATCH'',SYSDATE,USER,''ADMIN_ITEM'','''');
            COMMIT;
            END LOOP;
            END;';
   return vSQL;
END;
/