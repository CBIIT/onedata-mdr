create or replace procedure            sp_insert_all
as
v_cnt integer;
begin


insert into obj_typ select * from onedata_wa.obj_typ;
commit;

insert into obj_key select * from onedata_wa.obj_key;
commit;
insert into STUS_MSTR select * from onedata_wa.STUS_MSTR;
commit;
insert into DATA_TYP select * from onedata_wa.DATA_TYP;
commit;
insert into FMT select * from onedata_wa.FMT;
commit;
insert into UOM select * from onedata_wa.UOM;
commit;
insert into NCI_ENTTY select * from onedata_wa.nci_entty;
commit;
insert into NCI_org select * from onedata_wa.nci_org;
commit;
insert into NCI_prsn select * from onedata_wa.nci_prsn;
commit;
insert into NCI_ENTTY_addr select * from onedata_wa.nci_entty_addr;
commit;
insert into NCI_ENTTY_comm select * from onedata_wa.nci_entty_comm;
commit;
insert into admin_item select * from onedata_wa.admin_item;
commit;
insert into cntxt select * from onedata_wa.cntxt;
commit;
insert into alt_nms select * from onedata_wa.alt_nms;
commit;
insert into alt_def select * from onedata_wa.alt_def;
commit;
insert into ref select * from onedata_wa.ref
commit;
insert into cncpt select * from onedata_wa.cncpt;
commit;
insert into prop select * from onedata_wa.prop;
commit;
insert into obj_cls select * from onedata_wa.obj_cls;
commit;
insert into rep_cls select * from onedata_wa.rep_cls;
commit;
insert into nci_module select * from onedata_wa.nci_module;
commit;
insert into clsfctn_schm select * from onedata_wa.clsfctn_schm;
commit;
insert into conc_dom select * from onedata_wa.conc_dom;
commit;
insert into value_dom select * from onedata_wa.value_dom;
commit;
insert into nci_form select * from onedata_wa.nci_form;
commit;
insert into de_conc select * from onedata_wa.de_conc;
commit;
insert into de select * from onedata_wa.de;
commit;

insert into perm_val select * from onedata_wa.perm_val;
commit;
insert into conc_dom_val_mean select * from onedata_wa.conc_dom_val_mean;
commit;
insert into cncpt_admin_item select * from onedata_wa.cncpt_admin_item;
commit;




insert into NCI_CLSFCTN_SCHM_ITEM select * from onedata_wa.NCI_CLSFCTN_SCHM_ITEM;
commit;
insert into NCI_OC_RECS select * from onedata_wa.NCI_OC_RECS;
commit;
insert into NCI_PROTCL select * from onedata_wa.NCI_PROTCL;
commit;
insert into NCI_VAL_MEAN select * from onedata_wa.NCI_VAL_MEAN;
commit;

insert into NCI_ADMIN_ITEM_REL select * from onedata_wa.NCI_ADMIN_ITEM_REL;
commit;

insert into NCI_ADMIN_ITEM_EXT select * from onedata_wa.NCI_ADMIN_ITEM_EXT;
commit;

insert into NCI_ADMIN_ITEM_REL_ALT_KEY select * from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY;
commit;
insert into NCI_QUEST_VALID_VALUE select * from onedata_wa.NCI_QUEST_VALID_VALUE;
commit;
insert into NCI_ALT_KEY_ADMIN_ITEM_REL select * from onedata_wa.NCI_ALT_KEY_ADMIN_ITEM_REL;
commit;
insert into ref_Doc select * from onedata_wa.ref_doc;
commit;
insert into NCI_CSI_ALT_DEFNMS select * from onedata_wa.NCI_CSI_ALT_DEFNMS;


insert into NCI_FORM_TA select * from onedata_wa.NCI_FORM_TA;
commit;
insert into NCI_INSTR select * from onedata_wa.NCI_INSTR;
commit;
insert into NCI_QUEST_VV_REP select * from onedata_wa.NCI_QUEST_VV_REP;
commit;
insert into NCI_FORM_TA_REL select * from onedata_wa.NCI_FORM_TA_REL;
commit;
insert into  NCI_AI_TYP_VALID_STUS select * from onedata_wa. NCI_AI_TYP_VALID_STUS;
commit;


end;
/
