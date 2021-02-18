1.craete QA_OBJECTS_TEMP.csv from QA tiers using following SQL
select distinct OBJECT_TYPE ,OBJECT_NAME,STATUS from ALL_OBJECTS where owner='ONEDATA_WA'
and OBJECT_TYPE in ('PACKAGE','VIEW','TRIGGER','TABLE','PROCEDURE','MATERIALIZED VIEW')
and status ='VALID' ;

2.create QA_OBJ_SQL_TEMP.csv from QA tiers using following SQL
select distinct s.OWNER,s.NAME ,s.TYPE,to_char(s.LINE) , regexp_replace(s.TEXT, '(^([[:space:]]|[[:cntrl:]])+)|(([[:space:]]|[[:cntrl:]])+$)',null) 
   from all_source s,ALL_OBJECTS o
 where type in ('PACKAGE BODY','PACKAGE','TRIGGER','PROCEDURE') 
 and s.owner='ONEDATA_WA' 
 and instr(s.name,'BIN$um')=0
 and o.object_name=s.Name
 and s.owner=o.owner
and o.status ='VALID'
order by 2,3,4

3. truncate DEV tables QA_OBJ_SQL_TEMP and QA_OBJECTS_TEMP
4.use following control files in step 5:
QA_OBJ_SQL_TEMP.ctl.
QA_OBJECTS_TEMP.ctl

5. Using CSV files and control files upload data into truncated tables Via  SQL LOADER  into tables
QA_OBJ_SQL_TEMP and QA_OBJECTS_TEMP

6. Find DB objects which are used in ONEDATA UI and missing from QA. If no records found – all necessary DB were moved to QA.

select distinct OBJECT_TYPE ,OBJECT_NAME,STATUS from ALL_OBJECTS where owner='ONEDATA_WA'
and OBJECT_TYPE in ('PACKAGE','VIEW','TRIGGER','TABLE','PROCEDURE','MATERIALIZED VIEW')
and status ='VALID' 
and instr(object_name,'TEMP')=0
and instr(object_name,'_OLD')=0
and instr(object_name,'_33')=0
and instr(object_name,'MDSR')=0
and instr(object_name,'_N')=0
and instr(object_name,'ASL_ACTL_EX')=0
and instr(object_name,'JUNK')=0 
and instr(object_name,'PC_CS_CSI')=0
and instr(object_name,'CDEBROWSER_')=0
and instr(object_name,'DATA_ELEMENT')=0
and instr(object_name,'ONEDATA_CLASS_SCHEME_ITEM_VW')=0
and instr(object_name,'SAG_MIGR_')=0
and instr(object_name,'CONTEXTS_VIEW')=0
and instr(object_name,'VALUE_DOMAINS_VIEW')=0
and instr(object_name,'_BCK')=0
and instr(object_name,'_KEY1')=0
and instr(object_name,'SPALTDEFPOST')=0
and instr(object_name,'SP_')=0
and instr(object_name,'TOAD')=0
and instr(object_name,'CMPNNTVNT_RBI')=0
and instr(object_name,'NCI_CADSR_PUSH')=0
and instr(object_name,'NCI_UTIL')=0
and instr(object_name,'NCI_CURRENT')=0
and instr(object_name,'TAL_DSBL_ADPT_OPTMZR')=0
and instr(object_name,'NCI_MDR_CNTRL')=0
and instr(object_name,'SPPUSHAI')=0
and instr(object_name,'INSTALLED_COMPONENT')=0
and instr(object_name,'COMPONENT_EVENT')=0
and instr(object_name,'NCI_MDR_DEBUG')=0

MINUS
select OBJECT_TYPE ,OBJECT_NAME,STATUS from QA_OBJECTS_TEMP order by 1,2

7. Find PACKAGE BODY','PACKAGE','TRIGGER','PROCEDURE' which are used and not under development in DEV but have difference in code.
There is good when no difference is found.

select distinct OBJECT_TYPE ,OBJECT_NAME,STATUS from ALL_OBJECTS where owner='ONEDATA_WA'
and OBJECT_TYPE in ('PACKAGE','VIEW','TRIGGER','TABLE','PROCEDURE','MATERIALIZED VIEW')
and status ='VALID' 
and instr(object_name,'TEMP')=0
and instr(object_name,'_OLD')=0
and instr(object_name,'_33')=0
and instr(object_name,'MDSR')=0
and instr(object_name,'_N')=0
and instr(object_name,'ASL_ACTL_EX')=0
and instr(object_name,'JUNK')=0 
and instr(object_name,'PC_CS_CSI')=0
and instr(object_name,'CDEBROWSER_')=0
and instr(object_name,'DATA_ELEMENT')=0
and instr(object_name,'ONEDATA_CLASS_SCHEME_ITEM_VW')=0
and instr(object_name,'SAG_MIGR_')=0
and instr(object_name,'CONTEXTS_VIEW')=0
and instr(object_name,'VALUE_DOMAINS_VIEW')=0
and instr(object_name,'_BCK')=0
and instr(object_name,'_KEY1')=0
and instr(object_name,'SPALTDEFPOST')=0
and instr(object_name,'SP_')=0
and instr(object_name,'TOAD')=0
and instr(object_name,'CMPNNTVNT_RBI')=0
and instr(object_name,'NCI_CADSR_PUSH')=0
and instr(object_name,'NCI_UTIL')=0
and instr(object_name,'NCI_CURRENT')=0
and instr(object_name,'TAL_DSBL_ADPT_OPTMZR')=0
and instr(object_name,'NCI_MDR_CNTRL')=0
and instr(object_name,'SPPUSHAI')=0
and instr(object_name,'INSTALLED_COMPONENT')=0
and instr(object_name,'COMPONENT_EVENT')=0
and instr(object_name,'NCI_MDR_DEBUG')=0

MINUS
select OBJECT_TYPE ,OBJECT_NAME,STATUS from QA_OBJECTS_TEMP order by 1,2



select distinct mis.OWNER,mis.NAME ,mis.TYPE,mis.LINE , REGEXP_REPLACE(dev_text,' {2,}', ' ')dev_text ,  REGEXP_REPLACE(UPPER(text) ,' {2,}', ' ') QA_text
from QA_OBJ_SQL_TEMP qa,
(select distinct s.OWNER,s.NAME ,s.TYPE,s.LINE , REGEXP_REPLACE(regexp_replace(UPPER(s.TEXT), '(^([[:space:]]|[[:cntrl:]])+)|(([[:space:]]|[[:cntrl:]])+$)',null),' {2,}', ' ')  dev_text
 from all_source s,ALL_OBJECTS o
 where type in ('PACKAGE BODY','PACKAGE','TRIGGER','PROCEDURE') 
 and s.owner='ONEDATA_WA' 
 and instr(s.name,'BIN$um')=0
 and o.object_name=s.Name
 and s.owner=o.owner
and o.status ='VALID'
 and o.object_type=type
and instr(o.object_name,'TEMP')=0
and s.name<>'NCI_CADSR_PUSH'
and s.name<>'NCI_CURRENT'
and s.NAME<>'NCI_CADSR_PULL'
and instr(s.NAME,'SAG_MIGR_')=0
and instr(s.NAME,'SPALTDEFPOST')=0
and instr(s.NAME,'SP_')=0
and instr(s.NAME,'CMPNNTVNT_RBI')=0
and instr(s.NAME,'NCI_UTIL')=0
and instr(s.NAME,'NCI_CURRENT')=0
and instr(s.NAME,'NCI_MDR_CNTRL')=0
and instr(s.NAME,'SPPUSHAI')=0
and instr(s.NAME,'METAMAP')=0
and s.NAME not in('TAL_DSBL_ADPT_OPTMZR','NCI_CHNG_MGMT','NCI_11179','TR_AI_AUD_TS',
'TR_NCI_STG_AI_CNCPT_AUD_TS','OD_TR_SYS_TBL_COL_NM','OD_TR_SYS_TBL_NM','OD_TR_QUEST_VV')
minus 
select s.OWNER,s.NAME ,s.TYPE,s.LINE , 
regexp_replace(regexp_replace(UPPER(s.TEXT), '(^([[:space:]]|[[:cntrl:]])+)|(([[:space:]]|[[:cntrl:]])+$)',null) ,' {2,}', ' ') 
   from QA_OBJ_SQL_TEMP s
   
   ) mis
where mis.NAME = qa.NAME
and mis.LINE = qa.LINE(+)
and mis.TYPE = qa.TYPE
and mis.dev_text is not null
and mis.dev_text<>'NULL'
order by 3 desc,2,4;
