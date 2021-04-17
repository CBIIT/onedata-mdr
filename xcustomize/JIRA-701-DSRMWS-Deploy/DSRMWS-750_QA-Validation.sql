--1.delit data from temp tables
truncate table QA_OBJECTS_TEMP;
truncate table QA_TABLE_MTVW_TEMP;
truncate table QA_OBJ_SQL_TEMP;

--2.create csv fore temp tables from QA
select distinct OBJECT_TYPE ,trim(OBJECT_NAME),STATUS 
from ALL_OBJECTS where owner='ONEDATA_WA'
and OBJECT_TYPE in ('PACKAGE','VIEW','TRIGGER','TABLE','PROCEDURE','MATERIALIZED VIEW','INDEX');

 select distinct c.table_name ,c. column_name,to_char(c.DATA_LENGTH),c.DATA_TYPE--,c.COLUMN_ID,c.NULLABLE
from  all_tab_columns c,ALL_OBJECTS o
where t.table_name=c.table_name
and c.owner='ONEDATA_WA' 
and c.owner=o.owner;

select distinct s.OWNER,s.NAME ,s.TYPE,s.LINE , s.TEXT,ORIGIN_CON_ID
--select count(*)
 from all_source s,ALL_OBJECTS o
 where type in ('PACKAGE BODY','PACKAGE','TRIGGER','PROCEDURE') 
 and s.owner='ONEDATA_WA' 
 and instr(s.name,'BIN$um')=0
 and o.object_name=s.Name
 and s.owner=o.owner;
 
--3.upload data viaSQL Loader into tables
QA_OBJECTS_TEMP;
QA_TABLE_MTVW_TEMP;
QA_OBJ_SQL_TEMP;
--4 compare metadata
select distinct OBJECT_TYPE ,trim(OBJECT_NAME),STATUS 
from ALL_OBJECTS where owner='ONEDATA_WA'
and OBJECT_TYPE in ('PACKAGE','VIEW','TRIGGER','TABLE','PROCEDURE','MATERIALIZED VIEW','INDEX')
and status ='VALID' 
and instr(object_name,'_TEMP')=0
MINUS
 select OBJECT_TYPE ,OBJECT_NAME,STATUS 
 from QA_OBJECTS_TEMP 
 order by 1,2 ; 
-- WHERE OBJECT_NAME='NCI_CADSR_PUSH'
 
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

MINUS
 select OBJECT_TYPE ,OBJECT_NAME,STATUS from QA_OBJECTS_TEMP order by 1,2;





 select distinct c.table_name ,c. column_name,to_char(c.DATA_LENGTH),c.DATA_TYPE--,c.COLUMN_ID,c.NULLABLE
from  all_tab_columns c,ALL_OBJECTS o
where t.table_name=c.table_name
and c.owner='ONEDATA_WA' 
and c.owner=o.owner
and o.status ='VALID'
and instr(o.object_name,'TEMP')=0
and t.table_name not in 
(select distinct trim(OBJECT_NAME)
 from ALL_OBJECTS where owner='ONEDATA_WA'
and OBJECT_TYPE in ('VIEW','TABLE','MATERIALIZED VIEW')
and status ='VALID' 
and instr(object_name,'TEMP')=0
MINUS
select OBJECT_NAME--,STATUS 
from QA_OBJECTS_TEMP )
minus 
select c.table_name ,c. column_name,to_char(c.DATA_LENGTH),c.DATA_TYPE--,c.COLUMN_ID,c.NULLABLE 
from QA_TABLE_MTVW_TEMP c
order by 1,2;




select * from QA_TABLE_MTVW_TEMP;

--select 
--v.owner , v.view_name,  v.text_vc as definition
--from  all_views v,ALL_OBJECTS o
-- where  v.owner = 'ONEDATA_WA'
-- and v.owner=o.owner
-- and v.view_name=o.object_name
--and o.status ='VALID'
--minus
--select owner , view_name, definition from QA_VIEW_TEMP

/******************************************/
--REGEXP_REPLACE(STR,'(.*)(.*)\1','\1\2') 



select distinct mis.OWNER,mis.NAME ,mis.TYPE,mis.LINE , REGEXP_REPLACE(dev_text,' {2,}', ' ')dev_text ,  REGEXP_REPLACE(UPPER(text) ,' {2,}', ' ') QA_text
from QA_OBJ_SQL_TEMP qa,
(select distinct s.OWNER,s.NAME ,s.TYPE,s.LINE , REGEXP_REPLACE(regexp_replace(UPPER(s.TEXT), '(^([[:space:]]|[[:cntrl:]])+)|(([[:space:]]|[[:cntrl:]])+$)',null),' {2,}', ' ')  dev_text
--select count(*)
   from all_source s,ALL_OBJECTS o
 where type in ('PACKAGE BODY','PACKAGE','TRIGGER','PROCEDURE') 
 and s.owner='ONEDATA_WA' 
 and instr(s.name,'BIN$um')=0
 and o.object_name=s.Name
 and s.owner=o.owner
and o.status ='VALID'
 and o.object_type=type
and instr(o.object_name,'TEMP')=0
--and s.name<>'NCI_CADSR_PUSH'
and s.name<>'NCI_CURRENT'
--and s.NAME<>'NCI_CADSR_PULL'
and o.OBJECT_TYPE ||','||o.OBJECT_NAME not in
(
  select distinct OBJECT_TYPE ||','||trim(OBJECT_NAME) object
 from ALL_OBJECTS where owner='ONEDATA_WA'
and OBJECT_TYPE in ('PACKAGE BODY','PACKAGE','VIEW','TRIGGER','TABLE','PROCEDURE','MATERIALIZED VIEW')
and status ='VALID' 
and instr(object_name,'_TEMP')=0
MINUS
 select OBJECT_TYPE ||','||OBJECT_NAME--,STATUS 
 from QA_OBJECTS_TEMP 
 
)

minus 
select s.OWNER,s.NAME ,s.TYPE,s.LINE , 
regexp_replace(regexp_replace(UPPER(s.TEXT), '(^([[:space:]]|[[:cntrl:]])+)|(([[:space:]]|[[:cntrl:]])+$)',null) ,' {2,}', ' ') 
   from QA_OBJ_SQL_TEMP s
   
   ) mis
where mis.NAME = qa.NAME(+)
and mis.LINE = qa.LINE(+)
and mis.TYPE = qa.TYPE(+)
and mis.dev_text is not null
order by 3 desc,2,4;


select*from QA_OBJ_SQL_TEMP where text  IS NULL;
