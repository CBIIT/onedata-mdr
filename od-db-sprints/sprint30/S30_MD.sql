create or replace procedure sp_create_cntct
as
v_cnt integer;
v_pass varchar2(100) ;
v_cntct_id integer;
begin

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