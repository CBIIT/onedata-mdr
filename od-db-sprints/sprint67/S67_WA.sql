
create or replace TRIGGER TR_NCI_MDL_MAP_SHORT_NM
  AFTER INSERT 
  on NCI_MDL_MAP
  for each row
BEGIN
   update ADMIN_ITEM set MDL_MAP_SNAME = (Select substr(s.item_nm ||' '|| :new.src_mdl_item_id || 'v' || :new.src_mdl_ver_nr || ' -> ' || t.item_nm || ' ' || :new.tgt_mdl_item_id || 'v' || :new.tgt_mdl_ver_nr ,1,255)
   from admin_item s, admin_item t where s.item_id = :new.src_mdl_item_id and s.ver_nr = :new.src_mdl_ver_nr and t.item_id = :new.tgt_mdl_item_id and t.ver_nr = :new.tgt_mdl_ver_nr)
   where item_id = :new.item_id and ver_nr = :new.ver_nr;
  -- commit;

END;
/

CREATE OR REPLACE TRIGGER OD_TR_MEC_VAL_MAP_UPD 
BEFORE INSERT OR UPDATE ON NCI_STG_MEC_VAL_MAP
for each row
BEGIN
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
:new.DT_SORT := systimestamp();
  :new.LST_UPD_DT := SYSDATE;

END;
/

  
  alter table admin_item disable all triggers;

 update ADMIN_ITEM set MDL_MAP_SNAME = (Select substr(s.item_nm ||' '|| mm.src_mdl_item_id || 'v' || mm.src_mdl_ver_nr || ' -> ' || t.item_nm || ' ' || mm.tgt_mdl_item_id || 'v' || mm.tgt_mdl_ver_nr ,1,255)
   from admin_item s, admin_item t, nci_mdl_Map mm where s.item_id = mm.src_mdl_item_id and s.ver_nr = mm.src_mdl_ver_nr and t.item_id = mm.tgt_mdl_item_id and t.ver_nr = mm.tgt_mdl_ver_nr
   and mm.item_id = admin_item.item_id and mm.ver_nr = admin_item.ver_nr)
   where admin_item_typ_id = 58;
commit;
alter table admin_item enable all triggers;

--jira 4091,4092
create or replace TRIGGER TR_NCI_DLOAD_DEC_INIT_COL 
BEFORE INSERT ON NCI_DLOAD_CSTM_COL_DTL_DEC
for each row
DECLARE
v_cnt number;
v_pos number;
BEGIN
select count(*), max(col_pos) into v_cnt, v_pos from nci_dload_cstm_col_dtl_dec where hdr_id = :new.hdr_id;
if (v_cnt < 1) then
  nci_dload.spInitCstmColOrder(:new.hdr_id, 'DECI');
  else
 -- nci_dload.spAppendColumn(:new.hdr_id, :new.col_id);
  :new.col_pos := v_pos + 1;
  end if;

END;
/
create or replace TRIGGER TR_NCI_DLOAD_VD_INIT_COL 
BEFORE INSERT ON NCI_DLOAD_CSTM_COL_DTL_VD
for each row
DECLARE
v_cnt number;
v_pos number;
BEGIN
select count(*), max(col_pos) into v_cnt, v_pos from nci_dload_cstm_col_dtl_vd where hdr_id = :new.hdr_id;
if (v_cnt < 1) then
  nci_dload.spInitCstmColOrder(:new.hdr_id, 'VDI');
  else
 -- nci_dload.spAppendColumn(:new.hdr_id, :new.col_id);
  :new.col_pos := v_pos + 1;
  end if;

END;
/
--create sequence
create sequence SEQ_DS_ENTTY_PVVM_ID
start with 1
increment by 1;

--update onedata_wa.nci_ds_dtl.PVVM_ID with new sequence values
update nci_ds_dtl set PVVM_ID = SEQ_DS_ENTTY_PVVM_ID.nextval;
commit;

--drop primary key: replace primary key value per tier; Dev: SYS_C00117472, QA: SYS_C0028116
alter table nci_ds_dtl drop constraint SYS_C0028116;

--create new primary key; Dev: SYS_C00117472, QA: SYS_C0028116 
alter table nci_ds_dtl add constraint SYS_C0028116 primary key (HDR_ID, PVVM_ID);

delete from onedata_ra.nci_ds_dtl;
insert into onedata_ra.nci_ds_dtl 
select * from nci_ds_dtl;

CREATE OR REPLACE TRIGGER TR_DS_ENTTY_PVVM_ID_INS
BEFORE INSERT ON NCI_DS_DTL
FOR EACH ROW
BEGIN
    IF (:NEW.PVVM_ID<= 0  or :NEW.PVVM_ID is null)  THEN 

        SELECT SEQ_DS_ENTTY_PVVM_ID.NEXTVAL
        INTO :new.PVVM_ID
        FROM dual;
    END IF;
END;
/
