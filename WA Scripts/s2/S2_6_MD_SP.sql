create or replace procedure sp_create_user
as
v_cnt integer;
begin

select seq_obj.nextval into v_cnt from dual;
Insert into OD_MD_OBJ
 (CLNT_ID,PROJ_ID,SCHM_ID,OBJ_ID,OBJ_TYP_ID,OBJ_NM,OBJ_DEF,PRNT_OBJ_ID,STG_OBJ_ID,OBJ_MASK) 
values (1,1,1,v_cnt,2,'Test Account 2',null,null,-1,0);

Insert into OD_MD_OBJSECU (CLNT_ID,PROJ_ID,SCHM_ID,OBJ_ID,USR_PWD_UPD_DT,USR_PWD,USR_MASK,EMAIL_ID,USR_ID,USR_PGR_INFO,SPRVSR_SECU_ID) 
values (1,1,1,v_cnt,to_date('14-JUL-20','DD-MON-RR'),'96E79218965EB72C92A549DD5A330112',2,'d@d.com','TEST2',-1,-1);


Insert into OD_MD_OBJSECUREL (CLNT_ID,PROJ_ID,SCHM_ID,OBJ_SECU_ID,OBJ_DEPN_ID,REL_TYP_ID,AUTH_MASK) values 
(1,1,1,102,v_cnt,1,1);


Insert into OD_MD_OBJPROP (CLNT_ID,PROJ_ID,SCHM_ID,OBJ_ID,PROP_ID,PROP_VAL) 
values (1,1,1,v_cnt,100001,'96E79218965EB72C92A549DD5A330112');

commit;

insert into onedata_wa.cntct (CNTCT_ID,CNTCT_NM,CNTCT_SECU_ID) values (v_cnt, 'Test Account 2', 'TEST2');
commit;
insert into onedata_ra.cntct (CNTCT_ID,CNTCT_NM,CNTCT_SECU_ID) values (v_cnt, 'Test Account 2', 'TEST2');
commit;
end;