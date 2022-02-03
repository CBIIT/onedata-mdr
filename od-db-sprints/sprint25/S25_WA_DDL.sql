CREATE OR REPLACE EDITIONABLE TRIGGER OD_TR_PV_VM_IMP BEFORE INSERT  on NCI_STG_PV_VM_IMPORT for each row
     BEGIN    IF (:NEW.STG_AI_ID = -1  or :NEW.STG_AI_ID is null)  THEN select od_seq_IMPORT.nextval
 into :new.STG_AI_ID  from  dual ;   END IF;
 END;
/

CREATE OR REPLACE EDITIONABLE TRIGGER TR_PV_VM_IMPORT_AUD_TS
  BEFORE UPDATE
  on NCI_STG_PV_VM_IMPORT
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END ;
/

CREATE OR REPLACE EDITIONABLE  TRIGGER TR_CSI_FORM_POST
  AFTER INSERT OR UPDATE
  on
NCI_ADMIN_ITEM_REL
  for each row
BEGIN
if (:new.rel_typ_id = 65 ) then
   for cur in (select * from admin_item where item_id = :new.c_item_id and ver_nr = :new.c_item_Ver_nr and admin_item_typ_id = 54) loop
 insert into nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id, CREAT_USR_ID, LST_UPD_USR_ID )
 select distinct :new.p_item_id ,:new.p_item_ver_nr,v.de_item_id, v.de_ver_nr, 65, :new.creat_usr_id, :new.creat_usr_id
 from VW_NCI_MODULE_DE v where v.frm_item_id = :new.c_item_id and v.frm_ver_nr = :new.c_item_ver_nr 
 and ( v.de_item_id, v.de_ver_nr) not in (select  c_item_id, c_item_ver_nr from
 nci_admin_item_rel where rel_typ_id = 65 and p_item_id = :new.p_item_id and p_item_ver_nr = :new.p_item_ver_nr);
 commit;


 insert into onedata_ra.nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id, CREAT_USR_ID, LST_UPD_USR_ID )
 select distinct :new.p_item_id ,:new.p_item_ver_nr,v.de_item_id, v.de_ver_nr, 65, :new.creat_usr_id, :new.creat_usr_id
 from VW_NCI_MODULE_DE v where v.frm_item_id = :new.c_item_id and v.frm_ver_nr = :new.c_item_ver_nr 
 and ( v.de_item_id, v.de_ver_nr) not in (select  c_item_id, c_item_ver_nr from
 onedata_ra.nci_admin_item_rel where rel_typ_id = 65 and p_item_id = :new.p_item_id and p_item_ver_nr = :new.p_item_ver_nr);
 commit;
 end loop;
  end if;
 end;
 /
 
