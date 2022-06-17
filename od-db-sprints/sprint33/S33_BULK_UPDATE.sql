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

alter table PERM_VAL DISABLE ALL TRIGGERS;

update PERM_VAL pv set NCI_ORIGIN_ID =  (select obj_key_id from sbr_m.vd_pvs pvs, obj_key ok where ok.obj_typ_id = 18 and ok.nci_cd = pvs.origin and pvs.vp_idseq = pv.nci_idseq);
commit;

update PERM_VAL pv set NCI_ORIGIN =  (select ORIGIN from sbr_m.vd_pvs pvs where pvs.vp_idseq = pv.nci_idseq);
commit;

alter table PERM_VAL  ENABLE ALL TRIGGERS;

--- reconciling initial reverse

insert into sbr.ac_registrations (ar_idseq, ac_idseq, registration_status, date_created, created_by)
select nci_11179.cmr_guid,nci_idseq, nci_stus, ai.creat_dt, ai.creat_usr_id from stus_mstr, admin_item ai where admin_item_typ_id <> 8 and
stus_typ_id = 1 and stus_id = ai.regstr_stus_id
and ai.regstr_stus_id is not null  and nci_idseq not in (select ac_idseq from sbr.ac_registrations);
commit;

-- Module order

update sbrext.quest_contents_ext e set display_order = (select rel.disp_ord from  admin_item ai, nci_admin_item_rel rel
where rel.c_item_id = ai.item_id and rel.c_item_ver_nr = ai.ver_nr and ai.nci_idseq = e.qc_idseq and ai.admin_item_typ_id = 52
and rel.rel_typ_id = 61 and e.display_order <> rel.disp_ord)
where qc_idseq in (select qc_idseq from sbrext.quest_contents_ext e1, admin_item ai, nci_admin_item_rel rel
where rel.c_item_id = ai.item_id and rel.c_item_ver_nr = ai.ver_nr and ai.nci_idseq = e1.qc_idseq and ai.admin_item_typ_id = 52
and rel.rel_typ_id = 61 and e.display_order <> rel.disp_ord)
commit;

-- CSI with no CS - set Workflow status to Retired Withdrawn.


update sbr.cs_items  set asl_name = 'RETIRED ARCHIVED' where csi_idseq in (select csi_idseq from admin_item ai, sbr.cs_items csi
where csi.csi_idseq = ai.nci_idseq and ai.admin_stus_nm_dn <> csi.asl_name and ai.admin_stus_nm_dn = 'RETIRED ARCHIVED')
commit;

update sbr.administered_components  set asl_name = 'RETIRED ARCHIVED' where ac_idseq in (select csi_idseq from  sbr.cs_items csi
where csi.asl_name= 'RETIRED ARCHIVED')
and actl_name = 'CS_ITEM';
commit;
