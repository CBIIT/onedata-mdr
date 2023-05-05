create or replace TRIGGER TR_AI_WFS
  BEFORE UPDATE or INSERT ON ADMIN_ITEM
  FOR EACH ROW
    WHEN ( -- WFS is like retired requires End Date --
  ((DECODE(new.ADMIN_STUS_ID,old.ADMIN_STUS_ID,0,1)=1 and (new.ADMIN_STUS_ID > 76 and new.ADMIN_STUS_ID < 82)) and --WFS is changed to like Retired
   (new.UNTL_DT is null)) --new End Date is null error
    or --WFS was like Retired and is not changed, End Date shall not be removed
  (DECODE(new.ADMIN_STUS_ID,old.ADMIN_STUS_ID,0,1)=0 and (old.ADMIN_STUS_ID is not null and old.ADMIN_STUS_ID > 76 and old.ADMIN_STUS_ID < 82) and
  (DECODE(new.UNTL_DT, old.UNTL_DT,0,1)=1 and new.UNTL_DT is null) ---changed End Data to n errorull
  )) BEGIN
RAISE_APPLICATION_ERROR( -20001,
'!!!! The item is not saved. "RETIRED" Workflow Status requires "End Date" value to be set !!!!');

:new.MTCH_TERM := regexp_replace(upper(:new.item_nm),'\(|\)|\;|\-|\_|\|','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.item_nm),'\(|\)|\;|\-|\_|\|','');

END TR_AI_WFS;
/

create or replace TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT ON ADMIN_ITEM for each row
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
:new.ITEM_RPT_URL := v_param_val || '/invoke/downloads.form/printerFriendly?item_id=' || :new.item_id ||  chr(38) || 'version=' || :new.ver_nr;
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


END ;
/
