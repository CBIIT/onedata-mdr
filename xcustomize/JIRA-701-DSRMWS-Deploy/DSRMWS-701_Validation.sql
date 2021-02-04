CREATE table QA_OBJECTS_TEMP as select OBJECT_TYPE ,OBJECT_NAME,SUBOBJECT_NAME,STATUS from ALL_OBJECTS where owner='ONEDATA_WA'
and OBJECT_TYPE in ('PACKAGE BODY','PACKAGE','VIEW','TRIGGER','TABLE','PROCEDURE','MATERIALIZED VIEW')
and status ='VALID' 
and instr(object_name,'_TEMP')=0 order by 1,2 ; 


truncate table QA_OBJECTS_TEMP;

CREATE table QA_TABLE_MTVW_TEMP as select distinct t.table_name ,c. column_name,c.DATA_LENGTH,c.DATA_TYPE,c.COLUMN_ID,c.NULLABLE
from ALL_tables t, all_tab_columns c,ALL_OBJECTS o
where t.table_name=c.table_name
and t.table_name=o.object_name
and t.owner='ONEDATA_WA' 
and t.owner=c.owner
and t.owner=o.owner
and o.status ='VALID'
order by 1,2 ; 
--select count(*) from QA_TABLE_MTVW_TEMP;1738
--drop table QA_TABLE_MTVW_TEMP;
truncate table QA_TABLE_MTVW_TEMP;

CREATE table QA_VIEW_TEMP as select 
v.owner , v.view_name,  v.text_vc as definition
from  all_views v,ALL_OBJECTS o
 where  v.owner = 'ONEDATA_WA'
 and v.owner=o.owner
 and v.view_name=o.object_name
and o.status ='VALID'
order by 1,2;
--select count(*) from QA_VIEW_TEMP;
--drop table QA_VIEW_TEMP;--94
truncate table QA_VIEW_TEMP;

CREATE table QA_OBJ_SQL_TEMP as select distinct s.* from all_source s,ALL_OBJECTS o
 where type in ('PACKAGE BODY','PACKAGE','TRIGGER','PROCEDURE') 
 and s.owner='ONEDATA_WA' 
 and instr(s.name,'BIN$um')=0
 and o.object_name=s.Name
 and s.owner=o.owner
and o.status ='VALID'
order by 3,2,4;
 --where type = 'PACKAGE BODY'and owner='ONEDATA_WA' 
--select count(*) from QA_OBJ_SQL;22893
truncate table QA_OBJ_SQL_TEMP;
drop table  QA_OBJ_SQL;
desc QA_OBJ_SQL
