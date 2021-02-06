 select distinct OBJECT_TYPE ,trim(OBJECT_NAME)--,STATUS 
 from ALL_OBJECTS where owner='ONEDATA_WA'
and OBJECT_TYPE in ('PACKAGE BODY','PACKAGE','VIEW','TRIGGER','TABLE','PROCEDURE','MATERIALIZED VIEW')
and status ='VALID' 
and instr(object_name,'_TEMP')=0
MINUS
 select OBJECT_TYPE ,OBJECT_NAME--,STATUS 
 from QA_OBJECTS_TEMP 
 order by 1,2 ; 
 WHERE OBJECT_NAME='NCI_CADSR_PUSH'


truncate table QA_OBJECTS_TEMP;

 select distinct t.table_name ,c. column_name,to_char(c.DATA_LENGTH),c.DATA_TYPE--,c.COLUMN_ID,c.NULLABLE
from ALL_tables t, all_tab_columns c,ALL_OBJECTS o
where t.table_name=c.table_name
and t.table_name=o.object_name
and t.owner='ONEDATA_WA' 
and t.owner=c.owner
and t.owner=o.owner
and o.status ='VALID'
and instr(o.object_name,'TEMP')=0
and t.table_name not in 
(select distinct trim(OBJECT_NAME)
 from ALL_OBJECTS where owner='ONEDATA_WA'
and OBJECT_TYPE in ('PACKAGE BODY','PACKAGE','VIEW','TRIGGER','TABLE','PROCEDURE','MATERIALIZED VIEW')
and status ='VALID' 
and instr(object_name,'TEMP')=0
MINUS
 select OBJECT_NAME--,STATUS 
 from QA_OBJECTS_TEMP )
minus 
select c.table_name ,c. column_name,to_char(c.DATA_LENGTH),c.DATA_TYPE--,c.COLUMN_ID,c.NULLABLE 
from QA_TABLE_MTVW_TEMP c
order by 1,2


order by 1,2 ; 
--select count(*) from QA_TABLE_MTVW_TEMP;1738
--drop table QA_TABLE_MTVW_TEMP;
truncate table QA_TABLE_MTVW_TEMP;
select * from QA_TABLE_MTVW_TEMP;

select 
v.owner , v.view_name,  v.text_vc as definition
from  all_views v,ALL_OBJECTS o
 where  v.owner = 'ONEDATA_WA'
 and v.owner=o.owner
 and v.view_name=o.object_name
and o.status ='VALID'
minus
select owner , view_name, definition from QA_VIEW_TEMP
order by 1,2;
--select count(*) from QA_VIEW_TEMP;
--drop table QA_VIEW_TEMP;--94
truncate table QA_VIEW_TEMP;

 select distinct s.* from all_source s,ALL_OBJECTS o
 where type in ('PACKAGE BODY','PACKAGE','TRIGGER','PROCEDURE') 
 and s.owner='ONEDATA_WA' 
 and instr(s.name,'BIN$um')=0
 and o.object_name=s.Name
 and s.owner=o.owner
and o.status ='VALID';
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
and s.name<>'NCI_CADSR_PUSH'
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
 --where type = 'PACKAGE BODY'and owner='ONEDATA_WA' 
--select count(*) from QA_OBJ_SQL_TEMP;22893 17662
truncate table QA_OBJ_SQL_TEMP;
drop table  QA_OBJ_SQL;
desc QA_OBJ_SQL

select*from QA_OBJ_SQL_TEMP where text  IS NULL;--='NULL';
 --where type = 'PACKAGE BODY'and owner='ONEDATA_WA' 
--select count(*) from QA_OBJ_SQL;22893
truncate table QA_OBJ_SQL_TEMP;
drop table  QA_OBJ_SQL;
desc QA_OBJ_SQL
