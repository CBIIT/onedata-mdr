
drop trigger TR_NCI_STG_MEC_MAP;

create or replace TRIGGER OD_TR_NCI_STG_MEC_MAP_UPD 
BEFORE INSERT or UPDATE ON NCI_STG_MEC_MAP
for each row
BEGIN
  :new.DT_SORT := systimestamp();
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
  :new.lst_upd_dt := sysdate();
END;
/

alter table NCI_STG_MEC_MAP disable all triggers;

update nci_STG_MEC_MAP set DT_LAST_MODIFIED =TO_CHAR(DT_SORT, 'MM/DD/YY HH24:MI:SS');

alter table NCI_STG_MEC_MAP enable all triggers;

alter table SAG_LOAD_MT add (
	CREAT_USR_ID VARCHAR2(50 BYTE)  DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50 BYTE) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate);


exec nci_ext_import.load_MT;
exec nci_ext_import.load_ICDO;
exec nci_ext_import.load_ICDO_External_Codes (3.1);


alter table SAG_LOAD_ICDO add ( CREAT_DT date default sysdate,
	CREAT_USR_ID VARCHAR2(50 BYTE)  DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50 BYTE) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate);


alter table SAG_LOAD_ICDO_RAW add ( CREAT_DT date default sysdate,
	CREAT_USR_ID VARCHAR2(50 BYTE)  DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50 BYTE) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate);


insert into obj_key (obj_typ_Id, obj_key_desc) values (54, 'AND');
insert into obj_key (obj_typ_Id, obj_key_desc) values (54, 'OR');
insert into obj_key (obj_typ_Id, obj_key_desc) values (54, 'IF');
insert into obj_key (obj_typ_Id, obj_key_desc) values (54, 'END');
insert into obj_key (obj_typ_Id, obj_key_desc) values (54, 'IGNORE');
insert into obj_key (obj_typ_Id, obj_key_desc) values (54, 'DEFAULT');

commit;

create or replace TRIGGER TR_NCI_MDL_MAP_NM
  AFTER INSERT or update
  on NCI_MDL_MAP
  for each row
BEGIN
   update ADMIN_ITEM set ITEM_NM_CURATED = item_nm || ' | ' || (Select s.item_nm || 'v' || :new.src_mdl_ver_nr || ' -> ' || t.item_nm || 'v' || :new.tgt_mdl_ver_nr || ' | ' || :new.item_id || '|' || :new.ver_nr
   from admin_item s, admin_item t where s.item_id = :new.src_mdl_item_id and s.ver_nr = :new.src_mdl_ver_nr and t.item_id = :new.tgt_mdl_item_id and t.ver_nr = :new.tgt_mdl_ver_nr)
   where item_id = :new.item_id and ver_nr = :new.ver_nr;
  -- commit;

END;
/


update ADMIN_ITEM set ITEM_NM_CURATED = item_nm ||' | ' || (Select s.item_nm || 'v' || s.ver_nr || ' mapped to ' || t.item_nm || 'v' || t.ver_nr || ' | ' || m.item_id || '|' || m.ver_nr
   from admin_item s, admin_item t, nci_mdl_map m where s.item_id = m.src_mdl_item_id and s.ver_nr = m.src_mdl_ver_nr and t.item_id = m.tgt_mdl_item_id 
   and t.ver_nr = m.tgt_mdl_ver_nr and m.item_id = admin_item.item_id and m.ver_nr = admin_item.ver_nr)
   where admin_item_typ_id = 58;
   commit;
