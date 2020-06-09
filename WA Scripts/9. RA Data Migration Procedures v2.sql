Data migration into RA Schema

create or replace procedure sp_truncate_all
as
v_cnt integer;
begin

delete from NCI_CSI_ALT_DEFNMS;
commit;
delete from NCI_ALT_KEY_ADMIN_ITEM_REL;
commit;

delete from NCI_FORM_TA_REL;
commit;

delete from NCI_FORM_TA;
commit;
delete from NCI_INSTR;
commit;
delete from NCI_QUEST_VV_REP;
commit;
delete from NCI_ADMIN_ITEM_REL_ALT_KEY;
commit;
delete from NCI_QUEST_VALID_VALUE;
commit;
delete from NCI_ADMIN_ITEM_REL;
commit;

delete from NCI_ADMIN_ITEM_EXT;
commit;

delete from NCI_CLSFCTN_SCHM_ITEM;
commit;
delete from NCI_OC_RECS;
commit;
delete from NCI_FORM;
commit;
delete from NCI_PROTCL;
commit;
delete from NCI_VAL_MEAN;
commit;


delete from perm_val;
commit;
delete from conc_dom_val_mean;
commit;
delete from cncpt_admin_item;
commit;

delete from nci_val_mean;
commit;

delete from de;
commit;
delete from de_conc;
commit;
delete from value_dom;
commit;
delete from conc_dom;
commit;
delete from rep_cls;
commit;
delete from clsfctn_schm;
commit;
delete from obj_cls;
commit;
delete from prop;
commit;
delete from alt_nms;
commit;
delete from alt_def;
commit;
delete from ref;
commit;
delete from cncpt;
commit;
delete from cntxt;
commit;
delete from admin_item;
commit;
delete from obj_key;
commit;
delete from obj_typ;
commit;

end;

create or replace procedure sp_insert_all 
as
v_cnt integer;
begin


insert into obj_typ select * from onedata_wa.obj_typ;
commit;

insert into obj_key select * from onedata_wa.obj_key;
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

insert into NCI_CSI_ALT_DEFNMS select * from onedata_wa.NCI_CSI_ALT_DEFNMS;


insert into NCI_FORM_TA select * from onedata_wa.NCI_FORM_TA;
commit;
insert into NCI_INSTR select * from onedata_wa.NCI_INSTR;
commit;
insert into NCI_QUEST_VV_REP select * from onedata_wa.NCI_QUEST_VV_REP;
commit;
insert into NCI_FORM_TA_REL select * from onedata_wa.NCI_FORM_TA_REL;
commit;



end;