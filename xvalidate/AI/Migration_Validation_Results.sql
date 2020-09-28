/*Run below queries in ONEDATA_WA
Identify the ACTL_NAME and DESTINATION from the SBREXT.SBREXT.ONEDATA_MIGRATION_ERROR 
and run one of the below queries to identify the difference between ONEDATA and SBR/SBREXT row values*/

/*Validation for SAG_AI_VALIDATION rejections*/

--REPRESENTATION CLASS
select 'ONEDATA' TIER, NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 7 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
 and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='REPRESENTATION CLASS' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBR',AC_IDSEQ , 7 ,SB.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, PUBLIC_ID ,
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(SB.CREATED_BY,'ONEDATA'), NVL(SB.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(SB.DATE_MODIFIED, SB.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(SB.MODIFIED_BY,'ONEDATA')
FROM SBR.ADMINISTERED_COMPONENTS AC , SBREXT.REPRESENTATIONS_EXT SB WHERE AC.AC_IDSEQ=SB.REP_IDSEQ AND ACTL_NAME = 'REPRESENTATION'
and ac_idseq IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='REPRESENTATION CLASS' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;

--OCRECS
select 'ONEDATA' TIER,NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 56 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
 and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='OCRECS' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBR',AC_IDSEQ , 56 ,SB.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, PUBLIC_ID ,
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(SB.CREATED_BY,'ONEDATA'), NVL(SB.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(SB.DATE_MODIFIED, SB.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(SB.MODIFIED_BY,'ONEDATA')
FROM SBR.ADMINISTERED_COMPONENTS AC , SBREXT.OC_RECS_EXT SB WHERE AC.AC_IDSEQ=SB.OCR_IDSEQ AND ACTL_NAME = 'OBJECTRECS'
and ac_idseq IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='OCRECS' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;

--CLASSIFICATION SCHEME
select 'ONEDATA' TIER,NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 9 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
 and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CLASSIFICATION SCHEME' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBR',AC_IDSEQ , 9 ,SB.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, PUBLIC_ID ,
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(SB.CREATED_BY,'ONEDATA'), NVL(SB.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(SB.DATE_MODIFIED, SB.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(SB.MODIFIED_BY,'ONEDATA')
FROM SBR.ADMINISTERED_COMPONENTS AC , SBR.CLASSIFICATION_SCHEMES SB WHERE AC.AC_IDSEQ=SB.CS_IDSEQ AND ACTL_NAME = 'CLASSIFICATION'
and ac_idseq IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CLASSIFICATION SCHEME' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;

--CONCEPTUAL DOMAIN
select 'ONEDATA' TIER,NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 1 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
 and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CONCEPTUAL DOMAIN' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBR',AC_IDSEQ , 1 ,SB.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, PUBLIC_ID ,
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(SB.CREATED_BY,'ONEDATA'), NVL(SB.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(SB.DATE_MODIFIED, SB.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(SB.MODIFIED_BY,'ONEDATA')
FROM SBR.ADMINISTERED_COMPONENTS AC , SBR.CONCEPTUAL_DOMAINS SB WHERE AC.AC_IDSEQ=SB.CD_IDSEQ AND ACTL_NAME = 'CONCEPTUALDOMAIN'
and ac_idseq IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CONCEPTUAL DOMAIN' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;

--DATA ELEMENT
select 'ONEDATA' TIER,NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 4 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
  and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='DATA ELEMENT' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBR',DE_IDSEQ --Change
 , 4 ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, 
CDE_ID, --Change
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,'ONEDATA'), NVL(AC.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(AC.MODIFIED_BY,'ONEDATA')
FROM SBR.DATA_ELEMENTS AC
WHERE DE_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='DATA ELEMENT' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;

--DATA ELEMENT CONCEPT
select 'ONEDATA' TIER, NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 2 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
  and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='DATA ELEMENT CONCEPT' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBR',DEC_IDSEQ --Change
 , 2 ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, 
DEC_ID, --Change
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,'ONEDATA'), NVL(AC.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(AC.MODIFIED_BY,'ONEDATA')
FROM SBR.DATA_ELEMENT_CONCEPTS AC
WHERE DEC_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='DATA ELEMENT CONCEPT' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;


--VALUE DOMAIN
select 'ONEDATA' TIER, NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 3 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
  and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='VALUE DOMAIN' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBR',VD_IDSEQ --Change
 , 3 ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, 
VD_ID, --Change
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,'ONEDATA'), NVL(AC.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(AC.MODIFIED_BY,'ONEDATA')
FROM SBR.VALUE_DOMAINS AC
WHERE VD_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='VALUE DOMAIN' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;


--OBJECT CLASS
select 'ONEDATA' TIER, NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 5 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
  and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='OBJECT CLASS' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBREXT',OC_IDSEQ --Change
 , 5 ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, 
OC_ID, --Change
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,'ONEDATA'), NVL(AC.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(AC.MODIFIED_BY,'ONEDATA')
FROM SBREXT.OBJECT_CLASSES_EXT AC
WHERE OC_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='OBJECT CLASS' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;


--PROPERTY
select 'ONEDATA' TIER, NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 6 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
  and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='PROPERTY' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBREXT',PROP_IDSEQ --Change
 , 6 ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, 
PROP_ID, --Change
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,'ONEDATA'), NVL(AC.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(AC.MODIFIED_BY,'ONEDATA')
FROM SBREXT.PROPERTIES_EXT AC
WHERE PROP_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='PROPERTY' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;


--CONCEPT
select 'ONEDATA' TIER, NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 49 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
  and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CONCEPT' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBREXT',CON_IDSEQ --Change
 , 49 ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, 
CON_ID, --Change
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,'ONEDATA'), NVL(AC.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(AC.MODIFIED_BY,'ONEDATA')
FROM SBREXT.CONCEPTS_EXT AC
WHERE CON_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CONCEPT' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;


--CLASSIFICATION SCHEME ITEM
select 'ONEDATA' TIER, NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 51 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
  and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CLASSIFICATION SCHEME ITEM' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBR',CSI_IDSEQ --Change
 , 51 ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, 
CSI_ID, --Change
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,'ONEDATA'), NVL(AC.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(AC.MODIFIED_BY,'ONEDATA')
FROM SBR.CS_ITEMS AC
WHERE CSI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CLASSIFICATION SCHEME ITEM' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;


--FORM
select 'ONEDATA' TIER, NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 54 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
  and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='FORM' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBREXT',AC_IDSEQ --Change
 , 54 ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, 
PUBLIC_ID, --Change
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,'ONEDATA'), NVL(AC.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(AC.MODIFIED_BY,'ONEDATA')
FROM SBREXT.QUEST_CONTENTS_EXT	AC, SBR.ADMINISTERED_COMPONENTS SB WHERE AC_IDSEQ = QC_IDSEQ AND ACTL_NAME = 'QUEST_CONTENT' AND QTL_NAME IN ('TEMPLATE', 'CRF')
AND AC_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='FORM' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;


--MODULE
select 'ONEDATA' TIER, NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 52 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
  and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='MODULE' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBREXT',AC_IDSEQ --Change
 , 52 ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, 
PUBLIC_ID, --Change
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,'ONEDATA'), NVL(AC.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(AC.MODIFIED_BY,'ONEDATA')
FROM SBREXT.QUEST_CONTENTS_EXT	AC,  SBR.ADMINISTERED_COMPONENTS SB WHERE AC_IDSEQ = QC_IDSEQ AND ACTL_NAME = 'QUEST_CONTENT' AND QTL_NAME IN ('MODULE')
AND AC_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='MODULE' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;


--PROTOCOL
select 'ONEDATA' TIER, NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 50 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
  and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='PROTOCOL' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBREXT',AC_IDSEQ --Change
 , 50 ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, 
PUBLIC_ID, --Change
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,'ONEDATA'), NVL(AC.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(AC.MODIFIED_BY,'ONEDATA')
FROM SBREXT.PROTOCOLS_EXT	AC,  SBR.ADMINISTERED_COMPONENTS  SB WHERE AC_IDSEQ = PROTO_IDSEQ AND ACTL_NAME = 'PROTOCOL'
AND AC_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='PROTOCOL' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;


--VALUE MEANING
select 'ONEDATA' TIER, NCI_IDSEQ, ADMIN_ITEM_TYP_ID,EFF_DT,CHNG_DESC_TXT,UNTL_DT,CURRNT_VER_IND,ITEM_LONG_NM,
CASE WHEN ORIGIN_ID IS NULL 
THEN ORIGIN 
ELSE ORIGIN_ID_DN END ORIGIN,
ITEM_DESC,ITEM_ID,ITEM_NM,VER_NR,CREAT_USR_ID,CREAT_DT,LST_UPD_DT,LST_UPD_USR_ID
 from ONEDATA_WA.ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 53 and item_id not in (-20000,-20001,-20002,-20005,-20004,-20003)
  and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='VALUE MEANING' and DESTINATION='ADMIN_ITEM')
 UNION ALL
 select 'SBR',VM_IDSEQ --Change
 , 53 ,AC.BEGIN_DATE,AC.CHANGE_NOTE,AC.END_DATE,
DECODE(UPPER(AC.LATEST_VERSION_IND),'YES', 1,'NO',0) LATEST_VERSION_IND,AC.PREFERRED_NAME,
AC.ORIGIN,AC.PREFERRED_DEFINITION, 
VM_ID, --Change
SUBSTR(NVL(AC.LONG_NAME,AC.PREFERRED_NAME),0,255),AC.VERSION,
NVL(AC.CREATED_BY,'ONEDATA'), NVL(AC.DATE_CREATED,to_date('8/18/2020','mm/dd/yyyy')),
NVL(NVL(AC.DATE_MODIFIED, AC.DATE_CREATED),to_date('8/18/2020','mm/dd/yyyy')), NVL(AC.MODIFIED_BY,'ONEDATA')
FROM SBR.VALUE_MEANINGS AC
WHERE VM_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='VALUE MEANING'  and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;


    /* Validate Contexts*/
SELECT 'ONEDATA' TIER, admin_item_typ_id,
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
                          FROM ONEDATA_WA.ADMIN_ITEM    --11/8/2019 4:41:54 PM
                         WHERE ADMIN_ITEM_TYP_ID = '8'
                        and NCI_IDSEQ IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CONTEXTS' and DESTINATION='ADMIN_ITEM')
                        UNION ALL
                        SELECT 'SBR' TIER, 8,
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
                          FROM SBR.CONTEXTS AC
                          WHERE conte_idseq IN (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CONTEXTS' and DESTINATION='ADMIN_ITEM')
order by NCI_IDSEQ;

/*Validation for SAG_ITEM_VALIDATION*/

 -- Validate sbr.DATA_ELEMENTS
SELECT 'ONEDATA' TIER,ITEM_ID,
                             VER_NR,
                             CREAT_DT,
                             CREAT_USR_ID,
                             LST_UPD_USR_ID,
                             TO_CHAR (REPLACE (FLD_DELETE, 0, 'No'))
                                 FLD_DELETE,
                             LST_UPD_DT
                        FROM ONEDATA_WA.DE
                       WHERE item_id <> -20005
                       and (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='DATAELEMENTS'  and DESTINATION='DE')
                      UNION ALL
                      SELECT 'SBR' TIER,CDE_ID,
                             VERSION,
                             NVL (DATE_CREATED,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (CREATED_BY, 'ONEDATA'),
                             NVL (MODIFIED_BY, 'ONEDATA'),
                             DELETED_IND,
                             NVL (NVL (DATE_MODIFIED, DATE_CREATED),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy'))
                        FROM sbr.data_elements
                        WHERE (CDE_ID,
                             VERSION) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='DATAELEMENTS' and DESTINATION='DE')
order by ITEM_ID;

--Validate CONTEXTS
SELECT 'ONEDATA' TIER, ITEM_ID,
                             VER_NR,
                             LANG_ID,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM ONEDATA_WA.CNTXT
                       WHERE item_id <> -20005
                       and (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CONTEXTS' AND DESTINATION='CNTXT')
                      UNION ALL
                      SELECT 'SBR' TIER,ai.ITEM_ID,
                             version,
                             1000,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.contexts c, ONEDATA_WA.admin_item ai
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.conte_idseq)
                             AND ai.admin_item_typ_id = 8
                             and (ai.ITEM_ID,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CONTEXTS' AND DESTINATION='CNTXT')
order by ITEM_ID;

 -- Validate CONCEPTUAL_DOMAINS
 SELECT 'ONEDATA' TIER,ITEM_ID,
                             VER_NR,
                             DIMNSNLTY,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.CONC_DOM
                       WHERE item_id <> -20002
                       and (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CONCEPTUAL_DOMAINS' and DESTINATION='CONC_DOM')
                      UNION ALL
                      SELECT 'SBR' TIER, ai.ITEM_ID,
                             version,
                             dimensionality,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.conceptual_domains c, ONEDATA_WA.admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.cd_idseq)
                       and (ai.ITEM_ID,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CONCEPTUAL_DOMAINS' and DESTINATION='CONC_DOM')
order by ITEM_ID;

 -- Validate OBJECT_CLASSES_EXT
 SELECT 'ONEDATA' TIER,ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.OBJ_CLS
                       WHERE item_id <> -20000
                       and (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='OBJECT_CLASSES_EXT' and DESTINATION='OBJ_CLS')
                      UNION ALL
                      SELECT 'SBR' TIER,ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.OBJECT_CLASSES_EXT c,
                             ONEDATA_WA.admin_item    ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.oc_idseq)
                       and (ai.ITEM_ID,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='OBJECT_CLASSES_EXT' and DESTINATION='OBJ_CLS')
order by ITEM_ID;

  --Validate PROPERTIES_EXT
  
  SELECT 'ONE_DATA' TIER,ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.PROP
                       WHERE item_id <> -20001
                       and (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='PROPERTIES_EXT' and DESTINATION='PROP')
                      UNION ALL
                      SELECT 'SBREXT' TIER,ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.properties_ext c, ONEDATA_WA.admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.PROP_idseq)
                       and (ai.ITEM_ID,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='PROPERTIES_EXT' and DESTINATION='PROP')
order by ITEM_ID;

--VALIDATE CLASSIFICATION_SCHEMES
SELECT 'ONE_DATA' TIER,ITEM_ID,
                             VER_NR,
                             CLSFCTN_SCHM_TYP_ID,
                             NCI_LABEL_TYP_FLG,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.CLSFCTN_SCHM
                        WHERE (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='CLASSIFICATION_SCHEMES' and DESTINATION='CLSFCTN_SCHM')
                      UNION ALL
                      SELECT 'SBR' TIER, ai.ITEM_ID,
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
                             ONEDATA_WA.admin_item     ai,
                             ONEDATA_WA.obj_key        ok
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.CS_idseq)
                             AND TRIM (cstl_name) = ok.nci_cd
                             AND ok.obj_typ_id = 3
                             and (ai.ITEM_ID,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='PROPERTIES_EXT' and DESTINATION='PROP')
order by ITEM_ID;


--Validate REPRESENTATIONS CLASS
SELECT 'ONE_DATA' TIER,ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.REP_CLS
                        WHERE (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='REPRESENTATIONS_EXT' and DESTINATION='REP_CLS')
                      UNION ALL
                      SELECT 'SBREXT' TIER,ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.representations_ext c,
                             ONEDATA_WA.admin_item     ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.REP_idseq)
                       and (ai.ITEM_ID,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='REPRESENTATIONS_EXT' and DESTINATION='REP_CLS')
order by ITEM_ID,VER_NR;

--Validate DATA_ELEMENT_CONCEPTS

SELECT 'ONE_DATA' TIER,ITEM_ID,
                             VER_NR,
                             OBJ_CLS_QUAL,
                             PROP_QUAL,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.DE_CONC
                       WHERE item_id NOT IN -20003
                       AND (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='DATA_ELEMENT_CONCEPTS' and DESTINATION='DE_CONC')
                      UNION ALL
                      SELECT 'SBR' TIER,ai.ITEM_ID,
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
                             ONEDATA_WA.admin_item      ai,
                             sbr.Administered_Components ac
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.dec_idseq)
                             AND c.CD_IDSEQ = ac_idseq
                             AND public_id > 0
                             and (ai.ITEM_ID, c.version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='DATA_ELEMENT_CONCEPTS' and DESTINATION='DE_CONC')
order by ITEM_ID,VER_NR;

--Validate VALUE_DOMAINS
SELECT 'ONE_DATA' TIER,ITEM_ID,
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
                        FROM onedata_wa.VALUE_DOM
                       WHERE item_id <> -20004
                       AND (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='VALUE_DOMAINS' and DESTINATION='VALUE_DOM')
                      UNION ALL
                      SELECT 'SBR' TIER,ai.ITEM_ID,
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
                        FROM sbr.VALUE_DOMAINS c, ONEDATA_WA.admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.vd_idseq)
                       AND (ai.ITEM_ID,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='VALUE_DOMAINS' and DESTINATION='VALUE_DOM')
order by ITEM_ID,VER_NR;

--Validate OC_RECS_EXT

SELECT 'ONE_DATA' TIER,ITEM_ID,
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
                        FROM onedata_wa.NCI_OC_RECS
                        WHERE (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='OC_RECS_EXT' and DESTINATION='NCI_OC_RECS')
                      UNION ALL
                      SELECT 'SBREXT' TIER,ocr_id,
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
                        FROM sbrext.OC_RECS_EXT c, ONEDATA_WA.admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.t_oc_idseq)
                       AND (OCR_ID,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='OC_RECS_EXT' and DESTINATION='NCI_OC_RECS')
order by ITEM_ID,VER_NR;

--Validate CONCEPTS_EXT
SELECT 'ONE_DATA' TIER,ITEM_ID,
                             VER_NR,
                             evs_src_id,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.CNCPT
                        WHERE (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='CONCEPTS_EXT' and DESTINATION='CNCPT')
                      UNION ALL
                      SELECT 'SBREXT' TIER,con_id,
                             version,
                             ok.obj_key_id,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.CONCEPTS_EXT c, ONEDATA_WA.obj_key ok
                       WHERE     c.evs_source = ok.obj_key_desc(+)
                             AND ok.obj_typ_id(+) = 23
                             AND (con_id,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='CONCEPTS_EXT' and DESTINATION='CNCPT')
order by ITEM_ID,VER_NR;

--Validate CS_ITEM

SELECT 'ONE_DATA' TIER,ITEM_ID,
                             VER_NR,
                             CSI_DESC_TXT,
                             CSI_CMNTS,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.NCI_CLSFCTN_SCHM_ITEM
                        WHERE (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='CS_ITEMS' and DESTINATION='NCI_CLSFCTN_SCHM_ITEM')
                      UNION ALL
                      SELECT 'SBR' TIER,item_id,
                             version,
                             description,
                             comments,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.CS_ITEMS cd, ONEDATA_WA.admin_item ai
                       WHERE ai.NCI_IDSEQ = cd.CSI_IDSEQ
                       AND (ITEM_ID,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='CS_ITEMS' and DESTINATION='NCI_CLSFCTN_SCHM_ITEM')
order by ITEM_ID,VER_NR;

--Validate VALUE_MEANINGS

SELECT 'ONE_DATA' TIER,ITEM_ID,
                             VER_NR,
                             VM_DESC_TXT,
                             VM_CMNTS,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.NCI_VAL_MEAN
                        WHERE (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='VALUE_MEANINGS' and DESTINATION='NCI_VAL_MEAN')
                      UNION ALL
                      SELECT 'SBR' TIER,item_id,
                             version,
                             description,
                             comments,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.VALUE_MEANINGS cd, ONEDATA_WA.admin_item ai
                       WHERE ai.NCI_IDSEQ = cd.VM_IDSEQ
                       AND (ITEM_ID,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='VALUE_MEANINGS' and DESTINATION='NCI_VAL_MEAN')
order by ITEM_ID,VER_NR;

--Validate QUEST_CONTENTS_EXT
SELECT 'ONE_DATA' TIER,ITEM_ID,
                             VER_NR,
                             catgry_id,
                             form_typ_id,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.NCI_FORM
                        WHERE (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='QUEST_CONTENTS_EXT' and DESTINATION='NCI_FORM')
                      UNION ALL
                      SELECT 'SBREXT' TIER,qc_id,
                             version,
                             ok.obj_key_id,
                             DECODE (qc.qtl_name,  'CRF', 70,  'TEMPLATE', 71),
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.QUEST_CONTENTS_EXT qc,
                             ONEDATA_WA.obj_key       ok
                       WHERE     qc.qcdl_name = ok.nci_cd(+)
                             AND ok.obj_typ_id(+) = 22
                             AND qc.qtl_name IN ('TEMPLATE', 'CRF')
                             AND (qc_id,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='QUEST_CONTENTS_EXT' and DESTINATION='NCI_FORM')
order by ITEM_ID,VER_NR;  

--Validate PROTOCOLS_EXT

SELECT 'ONE_DATA' TIER,ITEM_ID,
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
                        FROM onedata_wa.NCI_PROTCL
                        WHERE (ITEM_ID,VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='PROTOCOLS_EXT' and DESTINATION='NCI_PROTCL')
                      UNION ALL
                      SELECT 'SBREXT' TIER,ai.item_id,
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
                             ONEDATA_WA.admin_item ai,
                             ONEDATA_WA.obj_key   ok
                       WHERE     ai.NCI_IDSEQ = cd.proto_IDSEQ
                             AND TRIM (TYPE) = ok.nci_cd(+)
                             AND ok.obj_typ_id(+) = 19
                             AND ai.admin_item_typ_id = 50
                             AND (ai.ITEM_ID,version) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
                        where ACTL_NAME='PROTOCOLS_EXT' and DESTINATION='NCI_PROTCL')
            ORDER BY ITEM_ID, VER_NR;

--Validate VALID_QUESTION_VALUES
SELECT 'ONE_DATA'     TIER,
       NCI_PUB_ID,
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
  FROM onedata_wa.NCI_QUEST_VALID_VALUE
 WHERE (NCI_PUB_ID, Q_VER_NR) IN
           (SELECT public_id, version
              FROM SBREXT.ONEDATA_MIGRATION_ERROR
             WHERE     ACTL_NAME = 'VALID_QUESTION_VALUES'
                   AND DESTINATION = 'NCI_QUEST_VALID_VALUE')
UNION ALL
SELECT 'SBREXT'
           TIER,
       qc.qc_id,
       qc1.qc_id,
       qc1.VERSION,
       qc.preferred_name,
       qc.preferred_definition,
       qc.long_name,
       qc.qc_idseq,
       vv.description_text,
       vv.meaning_text,
       NVL (qc.created_by, 'ONEDATA'),
       NVL (qc.DATE_CREATED, TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
       NVL (NVL (qc.date_modified, qc.date_created),
            TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
       NVL (qc.modified_by, 'ONEDATA')
  FROM sbrext.QUEST_CONTENTS_EXT    qc,
       sbrext.quest_contents_ext    qc1,
       sbrext.valid_values_att_ext  vv
 WHERE     qc.qtl_name = 'VALID_VALUE'
       AND qc1.qtl_name = 'QUESTION'
       AND qc1.qc_idseq = qc.p_qst_idseq
       AND qc.qc_idseq = vv.qc_idseq(+)
       AND (qc.qc_id, qc1.VERSION) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'VALID_QUESTION_VALUES'
                       AND DESTINATION = 'NCI_QUEST_VALID_VALUE')
ORDER BY NCI_PUB_ID, Q_VER_NR;

--Validate COMPLEX_DATA_ELEMENTS
SELECT DISTINCT 'ONE_DATA' TIER,de.ITEM_ID,                                   
                de.VER_NR,
                DERV_MTHD,
                DERV_RUL,
                de.DERV_TYP_ID,
                de.CONCAT_CHAR,
                DERV_DE_IND
  FROM de, admin_item ai, sbr.complex_data_elements cdr
 WHERE     de.item_id = ai.item_id
       AND de.ver_nr = ai.ver_nr
       AND cdr.p_de_idseq = ai.nci_idseq
       AND (de.ITEM_ID, de.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPLEX_DATA_ELEMENTS'
                       AND DESTINATION = 'DE')
UNION ALL
SELECT DISTINCT 'SBR' TIER,ai.ITEM_ID,                                     --Primary Keys
                ai.VER_NR,
                METHODS,
                RULE,
                o.obj_key_id,
                cdr.CONCAT_CHAR,
                1
  FROM sbr.complex_data_elements cdr, obj_key o, admin_item ai
 WHERE     cdr.CRTL_NAME = o.nci_cd(+)
       AND o.obj_typ_id(+) = 21
       AND cdr.p_de_idseq = ai.nci_idseq
       AND (ai.ITEM_ID, ai.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPLEX_DATA_ELEMENTS'
                       AND DESTINATION = 'DE')
ORDER BY ITEM_ID, VER_NR;


--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=5
SELECT 'ONE_DATA'     TIER,
       cncpt_item_id,
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
  FROM CNCPT_ADMIN_ITEM cai, admin_item ai
 WHERE     cai.ITEM_ID = ai.ITEM_ID
       AND cai.VER_NR = ai.VER_NR
       AND ADMIN_ITEM_TYP_ID = 5
       AND (cai.ITEM_ID, cai.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH OBJECT_CLASSES_EXT')
UNION ALL
SELECT 'SBREXT'
           TIER,
       con.item_id,
       con.ver_nr,
       oc.item_id,
       oc.ver_nr,
       cc.DISPLAY_ORDER,
       DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
       concept_value,
       NVL (cc.created_by, 'ONEDATA'),
       NVL (cc.date_created, TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
       NVL (NVL (cc.date_modified, cc.date_created),
            TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
       NVL (cc.modified_by, 'ONEDATA')
  FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
       sbrext.object_classes_ext      oce,
       admin_item                     con,
       admin_item                     oc
 WHERE     cc.CONDR_IDSEQ = oce.CONDR_IDSEQ
       AND oce.oc_idseq = oc.nci_idseq
       AND cc.con_idseq = con.nci_idseq
       AND (oc.ITEM_ID, oc.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH OBJECT_CLASSES_EXT')
ORDER BY ITEM_ID, VER_NR;

--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=6
Select 'ONE_DATA'     TIER,cncpt_item_id,
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
    and ADMIN_ITEM_TYP_ID=6 
           AND (cai.ITEM_ID, cai.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH PROPERTIES_EXT')
    UNION ALL                                  
    SELECT 'SBREXT'     TIER,con.item_id, --106,910
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
                   AND cc.con_idseq = con.nci_idseq
        AND (prop.ITEM_ID, prop.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH PROPERTIES_EXT')
ORDER BY ITEM_ID, VER_NR;

--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=7
Select 'ONE_DATA'     TIER,cncpt_item_id,
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
    and ADMIN_ITEM_TYP_ID=7 
    AND (cai.ITEM_ID, cai.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH REPRESENTATIONS_EXT')
    UNION ALL                                  
    SELECT 'SBREXT'     TIER,con.item_id,
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
                   AND cc.con_idseq = con.nci_idseq
                   AND (rep.ITEM_ID, rep.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH REPRESENTATIONS_EXT')
ORDER BY ITEM_ID, VER_NR;

--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=53   
Select 'ONE_DATA'     TIER,cncpt_item_id,
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
    and ADMIN_ITEM_TYP_ID=53
    AND (cai.ITEM_ID, cai.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH VALUE_MEANINGS')
    UNION ALL                                  
    SELECT 'SBREXT'     TIER,con.item_id,--85,641
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
                   AND cc.con_idseq = con.nci_idseq
                   AND (rep.ITEM_ID, rep.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH VALUE_MEANINGS')
ORDER BY ITEM_ID, VER_NR;

--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=3   
Select 'ONE_DATA'     TIER,cncpt_item_id,
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
and ADMIN_ITEM_TYP_ID=3
AND (cai.ITEM_ID, cai.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH VALUE_DOMAINS')
UNION ALL                                  
SELECT 'SBREXT'     TIER,con.item_id,
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
               AND cc.con_idseq = con.nci_idseq
               AND (vd.ITEM_ID, vd.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH VALUE_DOMAINS')
ORDER BY ITEM_ID, VER_NR;


--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=1   
Select 'ONE_DATA'     TIER,cncpt_item_id,
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
AND (cai.ITEM_ID, cai.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH CONCEPTUAL_DOMAINS')    
    UNION ALL                                  
    SELECT 'SBREXT'     TIER,con.item_id,
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
                   AND cc.con_idseq = con.nci_idseq
                   AND (cd.ITEM_ID, cd.VER_NR) IN
               (SELECT public_id, version
                  FROM SBREXT.ONEDATA_MIGRATION_ERROR
                 WHERE     ACTL_NAME = 'COMPONENT_CONCEPTS_EXT'
                       AND DESTINATION = 'CNCPT_ADMIN_ITEM'
                       AND ERROR_DESC = 'DATA MISMATCH CONCEPTUAL_DOMAINS')
ORDER BY ITEM_ID, VER_NR;


--PERMISSIBLE_VALUES
--Check number of VAL_DOM_ITEM_ID in both tiers
Select 'ONE_DATA' TIER, PERM_VAL_BEG_DT,
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
from ONEDATA_WA.PERM_VAL
where (VAL_DOM_ITEM_ID,VAL_DOM_VER_NR) in (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='PERMISSIBLE_VALUES' and DESTINATION='PERM_VAL')
UNION ALL                                 
SELECT 'SBR' TIER, pvs.BEGIN_DATE,
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
          FROM sbr.permissible_Values  pv,
               admin_item              vm,
               admin_item              vd,
               sbr.vd_pvs              pvs
         WHERE     pv.pv_idseq = pvs.pv_idseq
               AND pvs.vd_idseq = vd.nci_idseq
               AND pv.vm_idseq = vm.nci_idseq
               and (vd.item_Id,vd.ver_nr) in (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='PERMISSIBLE_VALUES' and DESTINATION='PERM_VAL')
order by VAL_DOM_ITEM_ID,VAL_DOM_VER_NR,NCI_IDSEQ;


--Validate QUEST_VV_EXT
select DISTINCT 'ONE_DATA' TIER,VV_PUB_ID,
                                  VV_VER_NR,
                                  VAL,
                                  EDIT_IND,
                                  REP_SEQ,
                                  CREAT_USR_ID,
                                  CREAT_DT,
                                  LST_UPD_DT,
                                  LST_UPD_USR_ID
from NCI_QUEST_VV_REP      
WHERE (VV_PUB_ID,VV_VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='QUEST_VV_EXT' and DESTINATION='NCI_QUEST_VV_REP')
UNION ALL                                      
SELECT   DISTINCT 'SBREXT' TIER,vv.NCI_PUB_ID,
               vv.NCI_VER_NR,
               qvv.VALUE,
               DECODE (editable_ind,  'Yes', 1,  'No', 0),
               repeat_sequence,
          nvl(qvv.created_by,'ONEDATA'),
               nvl(qvv.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
             nvl(NVL (qvv.date_modified, qvv.date_created), to_date('8/18/2020','mm/dd/yyyy')),
               nvl(qvv.modified_by,'ONEDATA')
          FROM sbrext.QUEST_VV_EXT         qvv,
               NCI_QUEST_VALID_VALUE       vv
         WHERE    qvv.vv_idseq = vv.NCI_IDSEQ(+)
         AND (vv.NCI_PUB_ID, vv.NCI_VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='QUEST_VV_EXT' and DESTINATION='NCI_QUEST_VV_REP')


--Validate REFERENCE_BLOBS
select 'ONE_DATA' TIER,FILE_NM,
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
WHERE FILE_NM IN (select PREFERRED_NAME from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='REFERENCE_BLOBS' and DESTINATION='REF_DOC')
UNION ALL                         
        SELECT 'SBR' TIER,rb.NAME,
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
          FROM  sbr.REFERENCE_BLOBS rb
          WHERE rb.NAME IN (select PREFERRED_NAME from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='REFERENCE_BLOBS' and DESTINATION='REF_DOC')


--Validate TA_PROTO_CSI_EXT
select 'ONE_DATA' TIER,TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT from NCI_FORM_TA_REL
WHERE (NCI_PUB_ID, NCI_VER_NR) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='TA_PROTO_CSI_EXT' and DESTINATION='NCI_FORM_TA_REL')                                 
UNION ALL                                 
        SELECT 'SBREXT' TIER,ta.ta_id,
               ai.item_id,
               ai.ver_nr,
               nvl(t.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
          nvl(t.created_by,'ONEDATA'),
               nvl(t.modified_by,'ONEDATA'),
             nvl(NVL (t.date_modified, t.date_created), to_date('8/18/2020','mm/dd/yyyy'))
          FROM nci_form_ta ta, sbrext.ta_proto_csi_ext t, admin_item ai
         WHERE     ta.ta_idseq = t.ta_idseq
               AND t.proto_idseq = ai.nci_idseq
               AND t.proto_idseq IS NOT NULL
               AND (ai.item_id, ai.ver_nr) IN (select public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='TA_PROTO_CSI_EXT' and DESTINATION='NCI_FORM_TA_REL')


--Validate TRIGGERED_ACTIONS_EXT
Select 'ONE_DATA' TIER,
                             TA_INSTR,
                             SRC_TYP_NM,
                             TRGT_TYP_NM,
                             TA_IDSEQ,
                             CREAT_DT,
                             CREAT_USR_ID,
                             LST_UPD_USR_ID,
                             LST_UPD_DT From NCI_FORM_TA
                             WHERE TA_IDSEQ in (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='TRIGGERED_ACTIONS_EXT' and DESTINATION='NCI_FORM_TA')
UNION ALL                             
 SELECT     'SBREXT' TIER, TA_INSTRUCTION,
               S_QTL_NAME,
               T_QTL_NAME,
               TA_IDSEQ,
               nvl(ta.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
          nvl(ta.created_by,'ONEDATA'),
               nvl(ta.modified_by,'ONEDATA'),
             nvl(NVL (ta.date_modified, ta.date_created), to_date('8/18/2020','mm/dd/yyyy'))
          FROM sbrext.TRIGGERED_ACTIONS_EXT  ta
          WHERE TA_IDSEQ in (select IDSEQ from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='TRIGGERED_ACTIONS_EXT' and DESTINATION='NCI_FORM_TA')


--Validate VD_PVS
select DISTINCT 'ONE_DATA' TIER,PERM_VAL_BEG_DT, 
                          PERM_VAL_END_DT,
                          VAL_DOM_ITEM_ID,
                          VAL_DOM_VER_NR,
                          CREAT_USR_ID,                          
                          CREAT_DT,
                          LST_UPD_DT,
                          LST_UPD_USR_ID,
                          NCI_IDSEQ from  perm_val
                          WHERE (NCI_IDSEQ,VAL_DOM_ITEM_ID,VAL_DOM_VER_NR) in (select IDSEQ,public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
where ACTL_NAME='VD_PVS' and DESTINATION='PERMVAL') 
UNION ALL                          
        SELECT DISTINCT 'SBR' TIER,pvs.BEGIN_DATE,
               pvs.END_DATE,
               vd.item_id,
               vd.ver_nr,
               nvl(pvs.created_by,'ONEDATA'),
               nvl(pvs.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
               nvl(NVL (pvs.date_modified, pvs.date_created), to_date('8/18/2020','mm/dd/yyyy')),
               nvl(pvs.modified_by,'ONEDATA'),
               pv.pv_idseq
          FROM sbr.PERMISSIBLE_VALUES  pv,
               admin_item              vd,
               sbr.vd_pvs              pvs
         WHERE     pv.pv_idseq = pvs.pv_idseq
               AND pvs.vd_idseq = vd.nci_idseq
               AND (pv.pv_idseq,vd.item_id,vd.ver_nr) in (select IDSEQ,public_id,version from SBREXT.ONEDATA_MIGRATION_ERROR
        where ACTL_NAME='VD_PVS' and DESTINATION='PERMVAL') 
        ORDER BY VAL_DOM_ITEM_ID,VAL_DOM_VER_NR;
        
/*Validate Foriegn Key relationship in ONEDATA_WA.SAG_FK_VALIDATE*/
/*Rows returned are missing on ONEDATA*/

--Check DATA_ELEMENT_CONCEPT Relationship in DATA_ELEMENTS/DE  
SELECT /*+ PARALEL(12)*/
       DISTINCT ai1.Item_Id DEC_Item_Id, ai1.Ver_Nr DEC_Ver_Nr, dae.DE_IDSEQ
  FROM sbr.data_elements  dae
       INNER JOIN ONEDATA_WA.ADMIN_ITEM ai1
           ON     ai1.nci_idseq = DEC_IDSEQ
              AND ai1.Nci_Idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'DATA_ELEMENT_CONCEPT'
                              AND DESTINATION = 'DE')
MINUS
SELECT de.De_Conc_Item_Id, de.De_Conc_Ver_Nr, ai2.Nci_Idseq
  FROM ONEDATA_WA.admin_item  ai2
       INNER JOIN ONEDATA_WA.de de
           ON     De.Item_Id = ai2.Item_Id
              AND De.Ver_Nr = Ai2.Ver_Nr
              AND (de.De_Conc_Item_Id, de.De_Conc_Ver_Nr) IN
                      (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'DATA_ELEMENT_CONCEPT'
                              AND DESTINATION = 'DE')
ORDER BY DEC_Item_Id, DEC_Ver_Nr;         


--Check VALUE_DOMAIN Relationship in DATA_ELEMENTS/DE 
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id VD_Item_Id, ai3.Ver_Nr VD_Ver_Nr, dae.DE_IDSEQ
  FROM sbr.data_elements  dae
       INNER JOIN ONEDATA_WA.ADMIN_ITEM ai3
           ON     ai3.nci_idseq = VD_IDSEQ
              AND ai3.Nci_Idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'VALUE_DOMAIN'
                              AND DESTINATION = 'DE')
MINUS
SELECT DISTINCT de.VAL_DOM_ITEM_ID, de.VAL_DOM_VER_NR, ai2.Nci_Idseq
  FROM ONEDATA_WA.admin_item  ai2
       INNER JOIN ONEDATA_WA.de de
           ON     De.Item_Id = ai2.Item_Id
              AND De.Ver_Nr = Ai2.Ver_Nr
              AND (de.VAL_DOM_ITEM_ID, de.VAL_DOM_VER_NR) IN
                      (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'VALUE_DOMAIN'
                              AND DESTINATION = 'DE')
ORDER BY VD_Item_Id, VD_Ver_Nr;

--Check CONCEPTUAL DOMAIN relationship in DATA_ELEMENT_CONCEPTS/ DE_CONC  
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id CONC_DOM_ITEM_ID,
                ai3.Ver_Nr CONC_DOM_VER_NR,
                dae.DEC_IDSEQ
  FROM SBR.DATA_ELEMENT_CONCEPTS  dae
       INNER JOIN ONEDATA_WA.admin_item ai3
           ON     ai3.nci_idseq = CD_IDSEQ
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CONCEPTUAL DOMAIN'
                              AND DESTINATION = 'DE_CONC')
              MINUS
                          SELECT dec.CONC_DOM_ITEM_ID, dec.CONC_DOM_VER_NR,ai2.Nci_Idseq
                             FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.DE_CONC dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND (dec.CONC_DOM_ITEM_ID ,dec.CONC_DOM_VER_NR)
                                         IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CONCEPTUAL DOMAIN'
                              AND DESTINATION = 'DE_CONC')
ORDER BY CONC_DOM_ITEM_ID, CONC_DOM_VER_NR;                              
                              
--Check CONCEPTUAL DOMAIN relationship in VALUE_DOMAINS/ VALUE_DOM  
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id CONC_DOM_ITEM_ID,
                ai3.Ver_Nr CONC_DOM_VER_NR,
                dae.VD_IDSEQ
  FROM SBR.VALUE_DOMAINS  dae
       INNER JOIN ONEDATA_WA.admin_item ai3
           ON     ai3.nci_idseq = CD_IDSEQ --FK
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CONCEPTUAL DOMAIN'
                              AND DESTINATION = 'VALUE_DOM')
MINUS
                          SELECT dec.CONC_DOM_ITEM_ID, dec.CONC_DOM_VER_NR,ai2.Nci_Idseq
                             FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.VALUE_DOM dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND (dec.CONC_DOM_ITEM_ID ,dec.CONC_DOM_VER_NR) 
                                         IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CONCEPTUAL DOMAIN'
                              AND DESTINATION = 'VALUE_DOM')  
ORDER BY CONC_DOM_ITEM_ID, CONC_DOM_VER_NR;  


--Check TRGT_OBJ_CLS relationship in OC_RECS_EXT/ NCI_OC_RECS  
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id TRGT_OBJ_CLS_ITEM_ID,
                ai3.Ver_Nr TRGT_OBJ_CLS_VER_NR,
                dae.OCR_IDSEQ
  FROM SBREXT.OC_RECS_EXT  dae
       INNER JOIN ONEDATA_WA.admin_item ai3
           ON     ai3.nci_idseq = T_OC_IDSEQ --FK        
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'TRGT_OBJ_CLS'
                              AND DESTINATION = 'NCI_OC_RECS')
MINUS
                          SELECT dec.TRGT_OBJ_CLS_ITEM_ID,dec.TRGT_OBJ_CLS_VER_NR,ai2.Nci_Idseq
                             FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.NCI_OC_RECS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND (dec.TRGT_OBJ_CLS_ITEM_ID ,dec.TRGT_OBJ_CLS_VER_NR)
                                         IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'TRGT_OBJ_CLS'
                              AND DESTINATION = 'NCI_OC_RECS')  
ORDER BY TRGT_OBJ_CLS_ITEM_ID ,TRGT_OBJ_CLS_VER_NR; 


--Check SRC_OBJ_CLS relationship in OC_RECS_EXT/ NCI_OC_RECS  
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id SRC_OBJ_CLS_ITEM_ID,
                ai3.Ver_Nr SRC_OBJ_CLS_VER_NR,
                dae.OCR_IDSEQ
  FROM SBREXT.OC_RECS_EXT  dae
       INNER JOIN ONEDATA_WA.admin_item ai3
           ON     ai3.nci_idseq = S_OC_IDSEQ --FK      
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'SRC_OBJ_CLS'
                              AND DESTINATION = 'NCI_OC_RECS')
MINUS
                          SELECT dec.SRC_OBJ_CLS_ITEM_ID ,dec.SRC_OBJ_CLS_VER_NR,ai2.Nci_Idseq
                             FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.NCI_OC_RECS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND (dec.SRC_OBJ_CLS_ITEM_ID ,dec.SRC_OBJ_CLS_VER_NR)
                                         IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'SRC_OBJ_CLS'
                              AND DESTINATION = 'NCI_OC_RECS')
ORDER BY SRC_OBJ_CLS_ITEM_ID ,SRC_OBJ_CLS_VER_NR;    

--Check P_DE relationship in COMPLEX_DE_RELATIONSHIPS/ NCI_ADMIN_ITEM_REL                                                                                                                 
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id P_ITEM_ID,
                ai3.Ver_Nr P_ITEM_VER_NR,
                dae.C_DE_IDSEQ
  FROM SBR.COMPLEX_DE_RELATIONSHIPS  dae
       INNER JOIN ONEDATA_WA.admin_item ai3
           ON     ai3.nci_idseq = P_DE_IDSEQ --FK 736 360                  
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'P_DE'
                              AND DESTINATION = 'NCI_ADMIN_ITEM_REL')
MINUS
                          SELECT dec.P_ITEM_ID , dec.P_ITEM_VER_NR, ai2.nci_idseq
                             FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.NCI_ADMIN_ITEM_REL dec
                                      ON ai2.item_id=dec.C_ITEM_ID
                                         AND ai2.VER_NR	= dec.C_ITEM_VER_NR
                                        AND (dec.P_ITEM_ID ,dec.P_ITEM_VER_NR)
                                         IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'P_DE'
                              AND DESTINATION = 'NCI_ADMIN_ITEM_REL')
ORDER BY P_ITEM_ID ,P_ITEM_VER_NR;    

--Check C_DE relationship in COMPLEX_DE_RELATIONSHIPS/ NCI_ADMIN_ITEM_REL  
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id C_ITEM_ID,
                ai3.Ver_Nr C_ITEM_VER_NR,
                dae.P_DE_IDSEQ
  FROM SBR.COMPLEX_DE_RELATIONSHIPS  dae
       INNER JOIN ONEDATA_WA.admin_item ai3
           ON     ai3.nci_idseq = C_DE_IDSEQ --FK 736 360                  
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'C_DE'
                              AND DESTINATION = 'NCI_ADMIN_ITEM_REL')
MINUS
                          SELECT dec.C_ITEM_ID , dec.C_ITEM_VER_NR, ai2.nci_idseq
                             FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.NCI_ADMIN_ITEM_REL dec
                                      ON ai2.item_id=dec.P_ITEM_ID
                                         AND ai2.VER_NR	= dec.P_ITEM_VER_NR
                                        AND (dec.C_ITEM_ID ,dec.C_ITEM_VER_NR)
                                         IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'C_DE'
                              AND DESTINATION = 'NCI_ADMIN_ITEM_REL')
ORDER BY C_ITEM_ID ,C_ITEM_VER_NR;  


--Check CONTE_IDSEQ relationship in DEFINITIONS/ ALT_DEF  
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id CNTXT_ITEM_ID,
                ai3.Ver_Nr CNTXT_VER_NR,
                dae.AC_IDSEQ
  FROM SBR.DEFINITIONS  dae, sbr.Administered_Components  ac, ONEDATA_WA.admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0            
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CONTE_IDSEQ'
                              AND DESTINATION = 'ALT_DEF')
MINUS
                          SELECT dec.CNTXT_ITEM_ID,dec.CNTXT_VER_NR,ai2.nci_idseq
                             FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.ALT_DEF dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND (dec.CNTXT_ITEM_ID,dec.CNTXT_VER_NR)
                                         IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CONTE_IDSEQ'
                              AND DESTINATION = 'ALT_DEF')
ORDER BY CNTXT_ITEM_ID ,CNTXT_VER_NR; 


--Check CONTE_IDSEQ relationship in DESIGNATIONS/ ALT_NMS                                                                                        
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id CNTXT_ITEM_ID,
                ai3.Ver_Nr CNTXT_VER_NR,
                dae.AC_IDSEQ
  FROM SBR.DESIGNATIONS  dae, sbr.Administered_Components  ac, ONEDATA_WA.admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0           
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CONTE_IDSEQ'
                              AND DESTINATION = 'ALT_NMS')
MINUS
                          SELECT dec.CNTXT_ITEM_ID,dec.CNTXT_VER_NR,ai2.nci_idseq
                             FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.ALT_NMS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND (dec.CNTXT_ITEM_ID,dec.CNTXT_VER_NR)
                                         IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CONTE_IDSEQ'
                              AND DESTINATION = 'ALT_NMS')
ORDER BY CNTXT_ITEM_ID ,CNTXT_VER_NR;   


--Check CONTE_IDSEQ relationship in REFERENCE_DOCUMENTS/ REF  
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id NCI_CNTXT_ITEM_ID,
                ai3.Ver_Nr NCI_CNTXT_VER_NR,
                dae.AC_IDSEQ
  FROM SBR.REFERENCE_DOCUMENTS  dae, sbr.Administered_Components  ac, ONEDATA_WA.admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0           
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CONTE_IDSEQ'
                              AND DESTINATION = 'REF')
MINUS
                          SELECT dec.NCI_CNTXT_ITEM_ID,dec.NCI_CNTXT_VER_NR,ai2.nci_idseq
                                  FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.REF dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND (dec.NCI_CNTXT_ITEM_ID ,dec.NCI_CNTXT_VER_NR)
                                         IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CONTE_IDSEQ'
                              AND DESTINATION = 'REF')
ORDER BY NCI_CNTXT_ITEM_ID ,NCI_CNTXT_VER_NR;


--Check VM_IDSEQ relationship in CD_VMS/ CONC_DOM_VAL_MEAN  
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id NCI_VAL_MEAN_ITEM_ID,
                ai3.Ver_Nr NCI_VAL_MEAN_VER_NR,
                dae.CD_IDSEQ
  FROM SBR.CD_VMS  dae
       INNER JOIN ONEDATA_WA.admin_item ai3
           ON     ai3.nci_idseq = VM_IDSEQ          
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'VM_IDSEQ'
                              AND DESTINATION = 'CONC_DOM_VAL_MEAN')
MINUS
                          SELECT dec.NCI_VAL_MEAN_ITEM_ID,dec.NCI_VAL_MEAN_VER_NR,ai2.nci_idseq
                                  FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.CONC_DOM_VAL_MEAN dec
                                      ON     dec.CONC_DOM_ITEM_ID = ai2.Item_Id
                                         AND dec.CONC_DOM_VER_NR = Ai2.Ver_Nr
                                         AND (dec.NCI_VAL_MEAN_ITEM_ID ,dec.NCI_VAL_MEAN_VER_NR)
                                         IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'VM_IDSEQ'
                              AND DESTINATION = 'CONC_DOM_VAL_MEAN')
ORDER BY NCI_VAL_MEAN_ITEM_ID ,NCI_VAL_MEAN_VER_NR;                               


--Check CSI_IDSEQ relationship in CS_CSI/ NCI_ADMIN_ITEM_REL_ALT_KEY  
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id C_ITEM_ID,
                ai3.Ver_Nr C_ITEM_VER_NR,
                dae.CS_IDSEQ
FROM SBR.CS_CSI  dae
       INNER JOIN ONEDATA_WA.admin_item ai3
           ON     ai3.nci_idseq = CSI_IDSEQ --FK      
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CSI_IDSEQ'
                              AND DESTINATION = 'NCI_ADMIN_ITEM_REL_ALT_KEY')
MINUS
                          SELECT dec.C_ITEM_ID,dec.C_ITEM_VER_NR,ai2.nci_idseq
                                  FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.NCI_ADMIN_ITEM_REL_ALT_KEY dec
                                      ON     dec.CNTXT_CS_ITEM_ID = ai2.Item_Id
                                         AND dec.CNTXT_CS_VER_NR = Ai2.Ver_Nr
                                         AND (dec.C_ITEM_ID,dec.C_ITEM_VER_NR)
                                         IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'CSI_IDSEQ'
                              AND DESTINATION = 'NCI_ADMIN_ITEM_REL_ALT_KEY')
ORDER BY C_ITEM_ID ,C_ITEM_VER_NR;   

--Check AC_IDSEQ relationship in AC_CSI/ NCI_ALT_KEY_ADMIN_ITEM_REL  
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id C_ITEM_ID,
                ai3.Ver_Nr C_ITEM_VER_NR,
                dae.AC_IDSEQ
  FROM SBR.AC_CSI  dae
       INNER JOIN ONEDATA_WA.admin_item ai3
           ON     ai3.nci_idseq = AC_IDSEQ  
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'AC_IDSEQ'
                              AND DESTINATION = 'NCI_ALT_KEY_ADMIN_ITEM_REL')
MINUS
                          SELECT dec.C_ITEM_ID,dec.C_ITEM_VER_NR,ai2.nci_idseq
                                  FROM ONEDATA_WA.admin_item  ai2
                                  INNER JOIN ONEDATA_WA.NCI_ALT_KEY_ADMIN_ITEM_REL dec
                                      ON (dec.C_ITEM_ID,dec.C_ITEM_VER_NR)
                                        IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'AC_IDSEQ'
                              AND DESTINATION = 'NCI_ADMIN_ITEM_REL_ALT_KEY')
ORDER BY C_ITEM_ID ,C_ITEM_VER_NR;  

--Check PROTO_IDSEQ relationship in PROTOCOL_QC_EXT/ NCI_ADMIN_ITEM_REL
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id P_ITEM_ID,
                ai3.Ver_Nr P_ITEM_VER_NR,
                dae.PROTO_IDSEQ
  FROM SBREXT.PROTOCOL_QC_EXT  dae
           INNER JOIN ONEDATA_WA.admin_item ai3
               ON     ai3.nci_idseq = proto_idseq --FK 
               AND ai3.admin_item_typ_id = 50
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'PROTO_IDSEQ'
                              AND DESTINATION = 'NCI_ADMIN_ITEM_REL')
MINUS
                          SELECT dec.P_ITEM_ID,dec.P_ITEM_VER_NR,ai2.nci_idseq
                                  FROM ONEDATA_WA.admin_item  ai2
                                      INNER JOIN ONEDATA_WA.NCI_ADMIN_ITEM_REL dec
                                          ON   (dec.P_ITEM_ID,dec.P_ITEM_VER_NR)
                                        IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'PROTO_IDSEQ'
                              AND DESTINATION = 'NCI_ADMIN_ITEM_REL')
ORDER BY P_ITEM_ID,P_ITEM_VER_NR;

--Check QC_IDSEQ relationship in PROTOCOL_QC_EXT/ NCI_ADMIN_ITEM_REL
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id C_ITEM_ID,
                ai3.Ver_Nr C_ITEM_VER_NR,
                dae.QC_IDSEQ
  FROM SBREXT.PROTOCOL_QC_EXT  dae
           INNER JOIN ONEDATA_WA.admin_item ai3
               ON     ai3.nci_idseq = QC_IDSEQ --FK 
               AND ai3.admin_item_typ_id = 54
           AND ai3.nci_idseq IN
                      (SELECT idseq
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'QC_IDSEQ'
                              AND DESTINATION = 'NCI_ADMIN_ITEM_REL')
MINUS
                          SELECT dec.C_ITEM_ID,dec.C_ITEM_VER_NR,ai2.nci_idseq
                                  FROM ONEDATA_WA.admin_item  ai2
                                      INNER JOIN ONEDATA_WA.NCI_ADMIN_ITEM_REL dec
                                          ON   (dec.C_ITEM_ID,dec.C_ITEM_VER_NR)
                                        IN (SELECT public_id, version
                         FROM SBREXT.ONEDATA_MIGRATION_ERROR
                        WHERE     ACTL_NAME = 'QC_IDSEQ'
                              AND DESTINATION = 'NCI_ADMIN_ITEM_REL')
ORDER BY C_ITEM_ID,C_ITEM_VER_NR;                                                                                                                    
