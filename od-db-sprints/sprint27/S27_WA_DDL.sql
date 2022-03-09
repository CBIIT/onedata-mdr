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
if (:old.rel_typ_id - 65) then
delete from sbrext.ac_csi where cs_csi_idseq = 
(select nvl(csi.cs_csi_idseq, csiai.nci_idseq) from admin_item csiai, nci_clsfctn_schm_item csi where csiai.item_id = csi.item_id and csiai.ver_nr = csi.ver_nr
 and csiai.item_id = :old.p_item_id and csiai.ver_nr = :old.p_item_ver_nr)
 and ac_idseq = (select nci_idseq from admin_item ai where ai.item_id = :old.c_item_id and ai.ver_nr = :old.c_item_ver_nr));

end if;
end;
/

