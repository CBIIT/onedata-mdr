alter table ADMIN_ITEM DISABLE ALL TRIGGERS;

update admin_item set ITEM_NM_ID_VER =  (select item_nm || '|' || ITEM_ID || '|' || ver_nr || '|' || obj_key_desc  from obj_key where obj_Key_id = admin_item.admin_item_typ_id);
commit;

alter table ADMIN_ITEM ENABLE ALL TRIGGERS;

-- Tracker 1859

insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid, p_val_idseq, qc_idseq, display_order,  'VALUE_INSTRUCTION', CREATED_BY, DATE_CREATED, DATE_MODIFiED,MODIFIED_BY
from SBREXT.quest_contents_ext where QTL_NAME = 'VALUE_INSTR'
and qc_idseq not in
(select C_QC_IDSEQ from sbrext.QC_RECS_EXT where RL_NAME= 'VALUE_INSTRUCTION');
commit;
