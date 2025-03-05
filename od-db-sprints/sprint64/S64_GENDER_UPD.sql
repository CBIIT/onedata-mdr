delete table temp_gender_report;

create table temp_gender_report
(CDE_ITEM_ID number,
 CDE_VER_NR number(4,2),
 PHRASE varchar2(100),
 WHERE_FOUND varchar2(255));



create table temp_concept (cncpt_cd varchar2(20), cncpt_item_id number, cncpt_ver_nr number(4,2));

REM INSERTING into ONEDATA_WA.TEMP_CONCEPT
SET DEFINE OFF;
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C165713',7058580,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C209374',15042392,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C93501',10102192,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C205469',14931800,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C180329',10052026,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C211615',15270524,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C172486',7351559,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C124705',6658686,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C93736',10103908,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C84364',3014711,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C92228',6658903,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C92229',6658905,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C37920',2739314,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C111120',6658907,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C19720',2413106,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C16229',10037393,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C15362',2430329,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C209289',15135070,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C200499',14114657,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C209555',15134727,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C209556',15134483,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C70730',2714927,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C83817',6650175,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C93418',10105822,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C110935',3863099,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C177622',10048612,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C16576',2204935,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C46110',2238730,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C205466',14905558,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C205464',14931548,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C204382',14825984,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C105443',6404292,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C124707',6658706,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C128757',10017073,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C128762',10017205,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C128763',10017206,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C128764',10017231,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C128758',10017074,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C128759',10017075,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C129604',10019021,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C129605',10019022,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C128765',10017232,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C128766',10017233,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C159043',14564676,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C159101',14567625,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C17357',2202402,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C205470',14931732,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C160940',6845829,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C200588',14235039,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C158277',6774019,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C164527',10038354,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C94362',10102482,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C160854',6770856,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C206415',15018270,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C180328',10052025,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C211617',15270354,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C19502',10056383,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C19593',10056668,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C154419',6423803,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C55718',10084225,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C164029',10040533,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C172488',7351555,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C84363',3014714,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C142581',10025524,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C87092',3693748,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C147385',6403975,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C20197',2204936,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C46109',2238729,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C205467',14905559,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C205465',14931587,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C204377',14825979,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C16880',2802953,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C172487',7351557,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C160941',6845831,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C205468',14905560,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C209263',15134818,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C180990',7764257,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C154420',6423804,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C180327',7678370,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C35721',10063969,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C171249',14568941,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C189172',11315482,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C165015',10038880,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C180989',7764256,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C17005',2202651,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C71034',2922869,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C107098',4170151,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C112402',6659156,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C107099',4363911,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C112403',6659159,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C155691',6429860,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C124708',6658739,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C166279',7223067,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C28421',2403944,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C44177',10069802,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C92202',10102548,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C62246',2538598,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C102709',6659175,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C119265',5741861,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C26923',2205006,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C111097',6659183,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C26889',2205010,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C111104',6659189,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C87122',14563551,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C203705',14735784,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C93397',3653280,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C94082',3370560,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C142704',10027915,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C71468',10091434,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C94290',10104249,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C15719',2204884,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C38029',2724632,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C111121',6659222,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C205471',14931778,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C154421',6423805,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C46121',2238737,1);
Insert into ONEDATA_WA.TEMP_CONCEPT (CNCPT_CD,CNCPT_ITEM_ID,CNCPT_VER_NR) values ('C46120',2238736,1);
commit;
create or replace PACKAGE nci_fixes AS

procedure            sp_gender_desc_upd;
procedure            sp_reverse_upd;
procedure sp_gender_concept;
procedure            sp_reverse_upd_suffix;

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
end;
/
 
exec nci_fixes.sp_reverse_upd;
exec nci_fixes.sp_gender_concept;
exec nci_fixes.sp_gender_desc_upd;

