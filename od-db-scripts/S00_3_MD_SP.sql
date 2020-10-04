create or replace procedure sp_create_user
as
v_cnt integer;
v_pass varchar2(100) ;
v_cntct_id integer;
begin

v_pass :=  'E10ADC3949BA59ABBE56E057F20F883E';  --- Password 123456

for cur in ((select distinct modified_by user_name from sbr.administered_components
where date_modified is not null and modified_by is not null and date_modified > to_date ('2018-01-01', 'YYYY-MM-DD'))
union
(select distinct created_by from sbr.administered_components
where date_created > to_date ('2018-01-01', 'YYYY-MM-DD'))
union
(select distinct upper(created_by) from sbr.definitions where Date_created > to_date ('2018-01-01', 'YYYY-MM-DD'))
union
select distinct upper(modified_by) from sbr.definitions where Date_Modified is not null and modified_by is not null and date_modified > to_date ('2018-01-01', 'YYYY-MM-DD')
union
select distinct upper(created_by) from sbr.designations where Date_created > to_date ('2018-01-01', 'YYYY-MM-DD')
union
select distinct upper(modified_by) from sbr.designations where Date_Modified is not null and modified_by is not null and date_modified > to_date ('2018-01-01', 'YYYY-MM-DD')
) loop
  for cur1 in (select * from sbr.user_accounts where ua_name = cur.user_name and name not in (select obj_nm from od_md_obj where obj_typ_id = 2) and
  cur.user_name not in (select usr_id from od_md_objsecu)) loop
        select seq_obj.nextval into v_cnt from dual;
        Insert into OD_MD_OBJ
        (CLNT_ID,PROJ_ID,SCHM_ID,OBJ_ID,OBJ_TYP_ID,OBJ_NM,OBJ_DEF,PRNT_OBJ_ID,STG_OBJ_ID,OBJ_MASK) 
        values (1,1,1,v_cnt,2,cur1.name,null,null,-1,0);

Insert into OD_MD_OBJSECU (CLNT_ID,PROJ_ID,SCHM_ID,OBJ_ID,USR_PWD_UPD_DT,USR_PWD,USR_MASK,EMAIL_ID,USR_ID,USR_PGR_INFO,SPRVSR_SECU_ID) 
values (1,1,1,v_cnt,sysdate,v_pass,2,nvl(cur1.electronic_mail_address,'d@d.com'),cur1.ua_name,-1,-1);


Insert into OD_MD_OBJSECUREL (CLNT_ID,PROJ_ID,SCHM_ID,OBJ_SECU_ID,OBJ_DEPN_ID,REL_TYP_ID,AUTH_MASK) values 
(1,1,1,102,v_cnt,1,1);


Insert into OD_MD_OBJPROP (CLNT_ID,PROJ_ID,SCHM_ID,OBJ_ID,PROP_ID,PROP_VAL) 
values (1,1,1,v_cnt,100001,v_pass);

commit;
end loop;
end loop;

for cur in (select * from sbr.user_accounts where ua_name not in (select cntct_secu_id from onedata_wa.cntct)) loop 
select onedata_wa.od_seq_cntct.nextval into v_cntct_id from dual;

insert into onedata_wa.cntct (CNTCT_ID,CNTCT_NM,CNTCT_SECU_ID) values (v_cntct_id, cur.name, cur.ua_name);
commit;
insert into onedata_ra.cntct (CNTCT_ID,CNTCT_NM,CNTCT_SECU_ID) values (v_cntct_id, cur.name, cur.ua_name);
commit;
end loop;

for cur in (select o.obj_nm, s.usr_id from od_md_objsecu s, od_md_obj o  where o.obj_id = s.obj_id and o.schm_id = s.schm_id and o.obj_typ_id = 2 and usr_id not in (select cntct_secu_id from onedata_wa.cntct)
 and o.obj_nm not like 'DELETED%') loop 
select onedata_wa.od_seq_cntct.nextval into v_cntct_id from dual;

insert into onedata_wa.cntct (CNTCT_ID,CNTCT_NM,CNTCT_SECU_ID) values (v_cntct_id, cur.obj_nm, cur.usr_id);
commit;
insert into onedata_ra.cntct (CNTCT_ID,CNTCT_NM,CNTCT_SECU_ID) values (v_cntct_id, cur.obj_nm, cur.usr_id);
commit;
end loop;


select count(*) into v_cnt from onedata_wa.cntct where cntct_nm = 'ONEDATA';

if (v_cnt = 0 ) then
select onedata_wa.od_seq_cntct.nextval into v_cntct_id from dual;
insert into onedata_wa.cntct (CNTCT_ID,CNTCT_NM,CNTCT_SECU_ID) values (v_cntct_id, 'ONEDATA', 'ONEDATA');
commit;
insert into onedata_ra.cntct (CNTCT_ID,CNTCT_NM,CNTCT_SECU_ID) values (v_cntct_id, 'ONEDATA', 'ONEDATA');
commit;
end if;

end;
/

create or replace procedure sp_create_rowfilter
as
type objarray IS VARRAY(10) OF VARCHAR2(50); 
   objnames objarray; 
   prefixnames objarray;
   cnt integer; 
   i integer;
   v_obj_id integer;
   v_fk_nm  varchar2(255);
BEGIN 
   objnames := objarray('Alternate Names', 'Alternate Definitions', 'AI Creation With Concepts', 'References (for Edit)', 'Alternate Names for Designate (Hook)', 	'References for Designate (Hook)',
   'Alternate Definitions (Data Element CO)', 'Administered Item (Data Element CO)','Alternate Names (Data Element CO)','Reference Documents (Data Element CO)' ); 
   prefixnames := objarray('', '', '','NCI_', '', 	'NCI_','','','','NCI_'); 
   cnt := objnames.count; 
   dbms_output.put_line('Total '|| cnt || ' Objects'); 
   FOR i in 1 .. cnt LOOP 
      select obj_id into v_obj_id from od_md_obj where upper(obj_nm) = upper( objnames(i)) and schm_id =1 and proj_id = 1;
       select fk_nm into v_fk_nm from od_mdv_objcolhort where obj_id = v_obj_id and col_nm = trim(prefixnames(i) || 'CNTXT_ITEM_ID');
       if v_fk_nm is not null then
   dbms_output.put_line('Obj ID DK '|| v_obj_id || v_fk_nm); 
       delete from od_md_rowfilter where obj_id = v_obj_id and cnstrnt_nm = v_fk_nm and  UPPER(COL_NM) IN (trim(prefixnames(i) || 'CNTXT_ITEM_ID'), trim(prefixnames(i) || 'CNTXT_VER_NR'));
       commit;
insert into od_md_rowfilter (action_typ, obj_id, obj_secu_id, cnstrnt_nm, val_id, col_nm, col_typ, col_val, clnt_id, proj_id, schm_id)
select action_typ, v_obj_id, obj_secu_id, v_fk_nm, val_id, trim(prefixnames(i) || col_nm), col_typ, col_val, clnt_id, proj_id, schm_id
from od_md_rowfilter where obj_id in (select obj_id from od_md_obj where obj_nm = 'Administered Item' and schm_id = 1) 
AND UPPER(COL_NM) IN ('CNTXT_ITEM_ID', 'CNTXT_VER_NR');
commit;
       
       end if;
   END LOOP; 


end;
/

create or replace view vw_usr_row_filter as 
select s.usr_id, a.action_typ, a.CNTXT_ITEM_ID, a.CNTXT_VER_NR from 
(select obj_Secu_id, OBJ_ID, ACTION_TYP, SUM(decode(col_nm, 'CNTXT_ITEM_ID', COL_VAL)) CNTXT_ITEM_ID, SUM(decode(col_nm, 'CNTXT_VER_NR', col_Val)) CNTXT_VER_NR from od_md_rowfilter where obj_id = 
(select obj_id from od_md_obj where obj_nm = 'Administered Item' and schm_id = 1)
AND UPPER(COL_NM) IN ('CNTXT_ITEM_ID', 'CNTXT_VER_NR')
group by obj_secu_id, OBJ_ID,  ACTION_TYP ) a,
od_md_objsecu s, 
od_md_objsecurel r
where r.obj_secu_id = a.obj_secu_id and r.obj_depn_id = s.obj_id
union
select s.usr_id, 'I', 100, 1  from 
od_md_objsecu s, 
od_md_objsecurel r
where r.obj_depn_id = s.obj_id and r.obj_secu_id = 100;


grant select on vw_usr_row_filter to onedata_wa;

grant select on vw_usr_row_filter to onedata_ra;
