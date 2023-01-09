-- update legacy PV origin


alter table perm_val disable all triggers;

update perm_val pv set nci_origin = (select max(SRC_NAME) from  sbrext.vd_pvs_sources_ext e where e.vp_idseq =  pv.nci_idseq and date_created < sysdate - 365 group by vp_idseq
)
where nci_idseq in (Select vp_idseq from  sbrext.vd_pvs_sources_ext);
commit;
update perm_val pv set nci_origin_id = (select obj_key_id from obj_key where nci_cd = pv.nci_origin and obj_typ_id = 18)
where nci_origin is not null and nci_origin_id is null;
commit;


alter table perm_val enable all triggers;

alter table NCI_STG_FORM_QUEST_IMPORT add SRC_LOGIC_INSTR varchar2(4000);

-- Tracker 2306

alter table NCI_ADMIN_ITEM_REL add (CPY_MIG_UPD_DT date, CPY_MIG_TYP varchar2(50));
