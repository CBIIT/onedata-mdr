CREATE  OR REPLACE  TRIGGER TR_DEL_QUEST_VV
AFTER DELETE
   ON NCI_QUEST_VALID_VALUE
    FOR EACH ROW 
begin
delete from sbrext.valid_values_att_ext where qc_idseq = :old.nci_idseq;
delete from sbrext.quest_contents_ext where qc_idseq = :old.nci_idseq;
end;
/

CREATE  OR REPLACE  TRIGGER TR_REF_DOC_SIZE
BEFORE INSERT
   ON REF_DOC
    FOR EACH ROW 
begin
if (:new.nci_doc_size is null) then
select dbms_lob.getlength(:new.blob_col) into :new.nci_doc_size from dual; 
end if;
end;
/

CREATE  OR REPLACE  TRIGGER TR_DEL_AI_CLSFCTN
AFTER DELETE
   ON NCI_ADMIN_ITEM_REL
    FOR EACH ROW 
begin
if (:old.rel_typ_id = 65) then
delete from sbr.ac_csi where cs_csi_idseq = 
(select nvl(csi.cs_csi_idseq, csiai.nci_idseq) from admin_item csiai, nci_clsfctn_schm_item csi where csiai.item_id = csi.item_id and csiai.ver_nr = csi.ver_nr
 and csiai.item_id = :old.p_item_id and csiai.ver_nr = :old.p_item_ver_nr)
 and ac_idseq = (select nci_idseq from admin_item ai where ai.item_id = :old.c_item_id and ai.ver_nr = :old.c_item_ver_nr);

end if;
end;
/

CREATE OR REPLACE TRIGGER OD_TR_STG_ALT_NMS  BEFORE INSERT  on NCI_STG_ALT_NMS  for each row
     BEGIN    IF (:NEW.STG_AI_ID = -1  or :NEW.STG_AI_ID is null)  THEN select od_seq_CDE_IMPORT.nextval
 into :new.STG_AI_ID  from  dual ;   END IF;
 END;
/

CREATE OR REPLACE TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT ON ADMIN_ITEM for each row
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
if (:new.admin_item_typ_id  in (5,6)) then -- Set the default context
 :new.cntxt_item_id := 20000000024;
:new.cntxt_ver_nr := 1;
end if;
if (:new.ITEM_LONG_NM is null or ((:new.ITEM_LONG_NM = 'SYSGEN' or :new.ITEM_LONG_NM = 'Enter Text or Auto-Generated') and :new.admin_item_typ_id not in (3,4)) or :new.admin_item_typ_id = 53) then
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || trim(to_char(:new.ver_nr, '9999.99'));
end if;

:new.creat_usr_id_x := :new.creat_usr_id;
:new.lst_upd_usr_id_x := :new.lst_upd_usr_id;
if (:new.admin_item_typ_id = 53) then -- Value Meaning
:new.ITEM_NM_ID_VER := :new.ITEM_ID || ' | ' || :new.ver_nd || ' | ' || :new.item_nm;
else
:new.ITEM_NM_ID_VER :=  :new.item_nm;

end if;
if (:new.lst_upd_dt is null) then
:new.lst_upd_dt := sysdate;
end if;
END ;

