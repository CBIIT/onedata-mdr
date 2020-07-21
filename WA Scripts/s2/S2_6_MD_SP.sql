create or replace procedure sp_create_user_2
as
v_cnt integer;
v_pass varchar2(100) ;
v_cntct_id integer;
begin

v_pass :=  'E10ADC3949BA59ABBE56E057F20F883E';  --- Password 123456

for cur in (select distinct creat_usr_id from onedata_wa.admin_item) loop
  for cur1 in (select * from sbr.user_accounts where ua_name = cur.creat_usr_id and name not in (select obj_nm from od_md_obj where obj_typ_id = 2) and
  cur.creat_usr_id not in (select usr_id from od_md_objsecu)) loop
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

select onedata_wa.od_seq_cntct.nextval into v_cntct_id from dual;

insert into onedata_wa.cntct (CNTCT_ID,CNTCT_NM,CNTCT_SECU_ID) values (v_cntct_id, cur1.name, cur1.ua_name);
commit;
insert into onedata_ra.cntct (CNTCT_ID,CNTCT_NM,CNTCT_SECU_ID) values (v_cntct_id, cur1.name, cur1.ua_name);
commit;
end loop;
end loop;
end;