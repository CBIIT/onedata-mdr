/*create or replace TRIGGER TR_MEC_MAP  BEFORE INSERT or UPDATE ON NCI_MEC_MAP for each row
declare 
v_src_nm varchar2(1000);
v_param_Val varchar2(255);
BEGIN   

if (:new.src_mec_id is not null) then
select lower(me.item_phy_obj_nm) || '.' || upper(mec_phy_nm) into v_src_nm 
from nci_mdl_elmnt_char mec, nci_mdl_elmnt me where mec.mdl_elmnt_item_id = me.item_id and mec.mdl_elmnt_ver_nr = me.ver_nr and mec.mec_id = :new.src_mec_id;
if (:new.LEFT_OP = 'SOURCE') then
:new.left_op := v_src_nm;
end if;
if (:new.RIGHT_OP = 'SOURCE') then
:new.left_op := v_src_nm;
end if;
if (:new.TGT_FUNC_PARAM = 'SOURCE') then
:new.left_op := v_src_nm;
end if;
end if;
end;
/

*/
  create or replace TRIGGER TR_MEC_MAP_UPD  BEFORE UPDATE ON NCI_MEC_MAP for each row
declare 
v_src_nm varchar2(1000);
v_param_Val varchar2(255);
BEGIN   

if (nvl(:new.src_mec_id,0)<> nvl(:old.src_mec_id,0)) then
for cur in (select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char mec where mec_id = :new.src_mec_id) loop
:new.src_cde_item_id := cur.cde_item_id;
:new.src_cde_ver_nr := cur.cde_ver_nr;
end loop;
end if;
if (nvl(:new.tgt_mec_id,0) <> nvl(:old.tgt_mec_id,0)) then
--raise_application_error(-20000,'here');
for cur in (select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char mec where mec_id = :new.tgt_mec_id) loop
:new.tgt_cde_item_id := cur.cde_item_id;
:new.tgt_cde_ver_nr := cur.cde_ver_nr;
end loop;
end if;
end;
/

  CREATE OR REPLACE TRIGGER TR_NCI_MDL_MAP_SHORT_NM
  AFTER INSERT 
  on NCI_MDL_MAP
  for each row
BEGIN
   update ADMIN_ITEM set MDL_MAP_SNAME = (Select substr(s.item_nm || 'v' || :new.src_mdl_ver_nr || ' -> ' || t.item_nm || 'v' || :new.tgt_mdl_ver_nr ,1,255)
   from admin_item s, admin_item t where s.item_id = :new.src_mdl_item_id and s.ver_nr = :new.src_mdl_ver_nr and t.item_id = :new.tgt_mdl_item_id and t.ver_nr = :new.tgt_mdl_ver_nr)
   where item_id = :new.item_id and ver_nr = :new.ver_nr;
  -- commit;

END;
/
  create or replace TRIGGER TR_AI_END_EFF_DT
  BEFORE UPDATE or INSERT ON ADMIN_ITEM
  FOR EACH ROW
     WHEN (
     (DECODE(new.UNTL_DT, old.CREAT_DT,0,1)=0) and new.UNTL_DT is not null) --new End Date is same as create date
   BEGIN
RAISE_APPLICATION_ERROR( -20001,'!!!! The item is not saved. "End Date" must be set later than "Effective Date"  !!!!');
END TR_AI_END_EFF_DT;
/

alter table ADMIN_ITEM disable all triggers;
update ADMIN_ITEM x set MDL_MAP_SNAME =  (Select substr(s.item_nm || 'v' || map.src_mdl_ver_nr || ' -> ' || t.item_nm || 'v' || map.tgt_mdl_ver_nr  ,1,255)
   from admin_item s, admin_item t, nci_mdl_map map where s.item_id = map.src_mdl_item_id and s.ver_nr = map.src_mdl_ver_nr
  and t.item_id = map.tgt_mdl_item_id and t.ver_nr = map.tgt_mdl_ver_nr and map.item_id = x.item_id and map.ver_nr = x.ver_nr)
  where admin_item_typ_id = 58;
commit;
alter table ADMIN_ITEM enable all triggers;


CREATE OR REPLACE TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT ON ADMIN_ITEM for each row
declare 
v_item_typ_nm varchar2(100);
v_param_Val varchar2(255);
BEGIN    IF (:NEW.ITEM_ID = -1  or :NEW.ITEM_ID is null)  THEN select od_seq_ADMIN_ITEM.nextval
 into :new.ITEM_ID  from  dual ;   END IF;
 :new.nci_idseq := nci_11179.cmr_guid();
if (:new.admin_item_typ_id  in (4,3,2,1,54) and :new.ver_nr = 1 and :new.admin_stus_id is null) then -- draft new
:new.admin_stus_id := 66;
end if;
--if (:new.admin_item_typ_id  in (4,3,2) and :new.ver_nr = 1 and :new.regstr_stus_id is null) then -- default new reg status Application
--:new.regstr_stus_id := 9; -- not sure if rules are changed
--end if;
 -- Tracker 806
if (:new.regstr_stus_id is null) then -- default new reg status Application
:new.regstr_stus_id := 9; -- not sure if rules are changed
end if;

if (:new.admin_item_typ_id  in (4,3,2,1) and :new.ver_nr > 1) then -- draft mod
:new.admin_stus_id := 65;
end if;
if (:new.admin_item_typ_id  in (5,6,49,53,7)) then -- Released
:new.admin_stus_id := 75;
end if;
if (:new.admin_item_typ_id  in (49) and :new.cntxt_item_id is null) then -- Set the default context for concept if empty
 :new.cntxt_item_id := 20000000024;
 :new.cntxt_ver_nr := 1;
end if;
if (:new.admin_item_typ_id  in (49) and :new.ORIGIN_ID is null) then -- Set the default origin for concept if empty
 :new.ORIGIN_ID := get_origin_id_nci_thesaurus; --NCI Thesaurus DSRMWS-748
end if;

if (:new.admin_item_typ_id = 54) then -- Set Download URL
select param_val into v_param_val from NCI_MDR_CNTRL where PARAM_NM = 'DOWNLOAD_HOST';
:new.ITEM_RPT_URL := v_param_val || '/invoke/downloads.form/printerFriendly?item_id=' || :new.item_id ||  chr(38) || 'version=' || :new.ver_nr || '\Click_to_View';
select param_val into v_param_val from NCI_MDR_CNTRL where PARAM_NM = 'DEEP_LINK';
:new.ITEM_DEEP_LINK := v_param_val ||  '/CO/FRMDD?filter=FRMDD.ITEM_ID='  || :new.item_id ||  '%20and%20ver_nr=' || :new.ver_nr;

end if;
if (:new.admin_item_typ_id = 4) then -- Set Deep Link
select param_val into v_param_val from NCI_MDR_CNTRL where PARAM_NM = 'DEEP_LINK';
:new.ITEM_DEEP_LINK := v_param_val ||  '/CO/CDEDD?filter=CDEDD.ITEM_ID=' || :new.item_id ||  '%20and%20ver_nr=' || :new.ver_nr;

end if;

if (:new.admin_item_typ_id  in (5,6)) then -- Set the default context
 :new.cntxt_item_id := 20000000024;
:new.cntxt_ver_nr := 1;
end if;
if (:new.ITEM_LONG_NM is null or ((:new.ITEM_LONG_NM = 'SYSGEN' or :new.ITEM_LONG_NM = 'Enter Text or Auto-Generated') and :new.admin_item_typ_id not in (3,4)) or :new.admin_item_typ_id = 53) then
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || trim(to_char(:new.ver_nr, '9999.99'));
end if;

:new.creat_usr_id_x := :new.creat_usr_id;
:new.lst_upd_usr_id_x := :new.lst_upd_usr_id;
-- Tracker 1704 - make it for all AI
--if (:new.admin_item_typ_id = 53) then -- Value Meaning
select obj_key_desc into v_item_typ_nm from obj_key where obj_key_id = :new.admin_item_typ_id;

:new.ITEM_NM_ID_VER :=  :new.item_nm || '|' || :new.ITEM_ID || '|' || :new.ver_nr || '|' || v_item_typ_nm ;

if (:new.lst_upd_dt is null) then
:new.lst_upd_dt := sysdate;
end if;
:new.CREATION_DT := sysdate;

END ;

/
