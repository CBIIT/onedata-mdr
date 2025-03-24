
create table admin_item_gender_upd as select * from admin_item where admin_item_typ_id in (5,6,7);

create table temp_concept (cncpt_cd varchar2(20), cncpt_item_id number, cncpt_ver_nr number(4,2));
truncate table temp_concept;

Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C19502');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C19593');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C177622');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C102709');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C105443');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C107098');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C107099');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C110935');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C111097');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C111104');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C111120');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C111121');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C112402');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C112403');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C119265');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C124705');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C124707');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C124708');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C142581');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C142704');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C147385');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C15362');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C15719');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C16229');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C164029');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C165713');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C16576');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C16880');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C17005');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C172486');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C172487');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C172488');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C189172');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C19720');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C20197');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C203705');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C204377');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C204382');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C211615');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C26889');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C26923');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C35721');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C37920');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C38029');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C62246');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C70730');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C71034');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C71468');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C83817');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C84364');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C87092');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C92228');
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD) values ('C92229');

commit;

create or replace PACKAGE nci_fixes AS

procedure            sp_gender_desc_upd;
procedure            sp_reverse_upd;
procedure sp_gender_concept;
procedure            sp_reverse_upd_suffix;
procedure            sp_stg2_upd;

END;
/
create or replace PACKAGE BODY nci_fixes AS

--v_str varchar2(1000) := 'This content is being reviewed for compliance with Executive Order 14168 which mandates that gender should not be used as a replacement for sex and gender identity shall not be requested. ';
v_str varchar2(1000) := 'This content is being reviewed for compliance with Executive Order 14168 which mandates that gender should not be used as a replacement for sex. ';

procedure            sp_gender_concept
as
v_cnt integer;
v_phrase varchar2(20);
begin
/*
update temp_concept t set (cncpt_item_id, cncpt_ver_nr) = (Select item_id, ver_nr from admin_item where 
t.cncpt_cd = item_long_nm and admin_item_typ_id = 49);

commit;
*/
execute immediate 'truncate table temp_gender_report';
for cur in (select * from temp_concept) loop

insert into temp_gender_report (CDE_ITEM_ID, CDE_VER_NR, PHRASE)
select distinct de_item_id, de_ver_nr,cur.cncpt_cd from 
vw_nci_de_cncpt where cncpt_item_id = cur.cncpt_item_id and cncpt_ver_nr = cur.cncpt_ver_nr and
(de_item_id, de_ver_nr) not in (select cde_item_id, cde_ver_nr from temp_gender_report);
commit;
end loop;
end;

 procedure            sp_gender_desc_upd
as
v_cnt integer;

v_def_typ integer;
begin


--sp_gender_concept;
select obj_key_id into v_def_typ from obj_key where obj_typ_id = 15 and obj_key_desc = 'Prior Preferred Definition';



insert into alt_def (item_id, ver_nr, nci_def_typ_id, DEF_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR)
select item_id, ver_nr, v_def_Typ, item_desc, cntxt_item_id, cntxt_ver_nr from admin_item where 
admin_item_typ_id = 4 and (item_id,ver_nr) in (select cde_item_id, cde_ver_nr from temp_gender_report);
commit;



insert into alt_def (item_id, ver_nr, nci_def_typ_id, DEF_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR)
select item_id, ver_nr, v_def_Typ, item_desc, cntxt_item_id, cntxt_ver_nr from admin_item where 
admin_item_typ_id = 54 
and (item_id, Ver_nr) in 
(select distinct FRM_ITEM_ID, FRM_VER_NR from vw_nci_module_de where FRM_ADMIN_STUS_NM_DN not like '%RETIRED%'
and (de_item_id) in (select cde_item_id from temp_gender_report));
commit;


insert into onedata_ra.alt_def select * from alt_def where 
creat_dt > sysdate - 1 and nci_def_typ_id = v_def_typ;
commit;

-- update cde definition
update admin_item set item_desc = substr(item_Desc || ' ' || v_str, 1, 4000) where admin_item_typ_id = 4
and (item_id, ver_nr) in (select cde_item_id, cde_ver_nr from temp_gender_report);
commit;


-- update module instructions

update nci_admin_item_rel set instr = substr(instr || ' ' || v_str, 1, 4000)
where rel_typ_id = 61
and (p_item_id, p_item_Ver_nr, c_item_id, c_item_ver_nr) in 
(select distinct FRM_ITEM_ID, FRM_VER_NR, MOD_ITEM_ID, MOD_VER_NR from vw_nci_module_de where FRM_ADMIN_STUS_NM_DN not like '%RETIRED%'
and (de_item_id) in (select cde_item_id from temp_gender_report));
commit;

-- update form

update admin_item set item_desc = substr(item_Desc || ' ' || v_str, 1, 4000)
where admin_item_typ_id = 54 and admin_stus_nm_dn not like '%RETIRED%'
and (item_id, Ver_nr) in 
(select distinct FRM_ITEM_ID, FRM_VER_NR from vw_nci_module_de where (de_item_id) in (select cde_item_id from temp_gender_report));
commit;


end;


 procedure            sp_reverse_upd
as
v_cnt integer;

v_def_typ integer;
begin


select obj_key_id into v_def_typ from obj_key where obj_typ_id = 15 and obj_key_desc = 'Prior Preferred Definition';

-- delete alternate definition

delete from alt_def where nci_def_typ_id= v_def_typ and (item_id, ver_nr) in 
(select item_id, ver_nr from admin_item where item_desc like  v_str || '%' and admin_item_typ_id in (4,54));
commit;

-- remove prefix from description
update admin_item set item_desc = replace(item_desc, v_str,'') where
item_desc like  v_str || '%';
commit;

-- remove prefix from module instructions

update nci_admin_item_rel set instr = replace(instr, v_str,'') where 
 rel_typ_id = 61
and instr like v_str || '%';
commit;



end;


 procedure            sp_reverse_upd_suffix
as
v_cnt integer;

v_def_typ integer;
begin


select obj_key_id into v_def_typ from obj_key where obj_typ_id = 15 and obj_key_desc = 'Prior Preferred Definition';

-- delete alternate definition

delete from alt_def where nci_def_typ_id= v_def_typ and (item_id, ver_nr) in 
(select item_id, ver_nr from admin_item where trim(item_desc) like '%'|| trim(v_str)  and admin_item_typ_id in (4,54));
commit;

-- remove prefix from description
update admin_item set item_desc = replace(item_desc, v_str,'') where
item_desc like  '%' ||v_str ;
commit;

-- remove prefix from module instructions

update nci_admin_item_rel set instr = replace(instr, v_str,'') where 
 rel_typ_id = 61
and instr like  '%' ||v_str;
commit;



end;

procedure sp_stg2_upd
as
i integer;
v_desc varchar2(4000);
v_nm varchar2(255);
begin

update temp_concept t set (cncpt_item_id, cncpt_ver_nr) = (Select item_id, ver_nr from admin_item where 
t.cncpt_cd = item_long_nm and admin_item_typ_id = 49);

commit;

DBMS_MVIEW.REFRESH('VW_CNCPT');


-- OC/Prop
for cur in (select item_id, ver_nr from admin_item where admin_item_typ_id in (5,6,7) 
and (item_id,ver_nr) in (select item_id, ver_nr from cncpt_admin_item ac, temp_concept c where c.cncpt_item_id = ac.cncpt_item_id 
and c.cncpt_ver_nr = ac.cncpt_ver_nr)) loop
v_desc := '';
v_nm := '';

for cur1 in (select c.item_desc, c.item_nm from vw_cncpt c, cncpt_admin_item ac
where c.item_id = ac.cncpt_item_id and c.ver_nr = ac.cncpt_ver_nr and ac.item_id = cur.item_id
and ac.ver_nr = cur.ver_nr order by nci_ord desc) loop
v_desc := v_desc || '_' || cur1.item_desc;
v_nm := v_nm || ' ' || cur1.item_nm;
--raise_application_error(-20000,'here');
end loop;
--raise_application_error(-20000,'Test' || v_desc || cur.item_id);
--update admin_item set item_desc = substr(v_desc,2), item_nm = trim(v_nm) where item_id = cur.item_id and ver_nr = cur.ver_nr;
update admin_item set item_desc = substr(v_desc,2)
--, item_nm = trim(v_nm) 
where item_id = cur.item_id and ver_nr = cur.ver_nr;
end loop;
commit;
end;
end;
/



exec nci_fixes.sp_stg2_upd;
/

