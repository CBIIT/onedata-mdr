create table SAG_LOAD_NCIt_TERM
(
 Subset_Code	varchar2(100) not null,
 Subset_Name	varchar2(4000) null,
 Concept_Code	varchar2(100) null,
 NCIT_PT	varchar2(4000) null,
 Rel_to_Target  varchar2(100) null,
 Target_Code	varchar2(100) not null,
 Target_Term	varchar2(4000) null,
 Target_Term_type	varchar2(100) null,
 Target_Terminology  	varchar2(100) not null,
 Target_Terminology_Version  	varchar2(100) null,Target_term_Definition varchar2(8000),
 Target_Synonym varchar2(8000));

delete from nci_admin_item_xmap where dt_src='ICDO';
commit;


delete from onedata_Ra.NCI_MDL_ELMNT_CHAR;
commit;

insert into onedata_Ra.NCI_MDL_ELMNT_CHAR select * from NCI_MDL_ELMNT_CHAR;
commit;

create or replace TRIGGER TR_VAL_DOM_AUD_TS
  BEFORE UPDATE
  on VALUE_DOM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
if (:new.VAL_DOM_TYP_ID <> 16 and :new.TERM_CNCPT_ITEM_ID is not null) then -- nullify Ref Term and Ref Term Usage
   :new.term_cncpt_item_id := null;
   :new.term_cncpt_ver_nr := null;
   :new.TERM_USE_TYP:=null;
 end if;
END TR_VAL_DOM_AUD_TS;
/




insert into obj_key (obj_typ_id, obj_key_desc) values (56,'IF');

insert into obj_key (obj_typ_id, obj_key_desc) values (56,'THEN');

insert into obj_key (obj_typ_id, obj_key_desc) values (56,'ELSE');

insert into obj_key (obj_typ_id, obj_key_desc) values (56,'ENDIF');

insert into obj_key (obj_typ_id, obj_key_desc) values (57,'EQUAL TO');

insert into obj_key (obj_typ_id, obj_key_desc) values (57,'NOT EQUAL TO');

insert into obj_key (obj_typ_id, obj_key_desc) values (57,'GREATER THAN');

insert into obj_key (obj_typ_id, obj_key_desc) values (57,'LESS THAN');

insert into obj_key (obj_typ_id, obj_key_desc) values (57,'GREATER THAN OR EQUAL TO');

insert into obj_key (obj_typ_id, obj_key_desc) values (57,'LESS THAN OR EQUAL TO');

insert into obj_key (obj_typ_id, obj_key_desc) values (58,'(');

insert into obj_key (obj_typ_id, obj_key_desc) values (58,')');

insert into obj_key (obj_typ_id, obj_key_desc) values (58,'NULL');
commit;

