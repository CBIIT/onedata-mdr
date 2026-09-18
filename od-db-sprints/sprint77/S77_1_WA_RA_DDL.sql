ALTER TABLE ALT_NMS MODIFY MTCH_SCR DEFAULT 1;
ALTER TABLE REF MODIFY MTCH_SCR DEFAULT 1;

alter table nci_ds_hdr disable all triggers;
update nci_ds_hdr set threshold_1 = null, threshold_2 = null;
commit;
alter table nci_ds_hdr modify THRESHOLD_1 number(4,2) default .5;
alter table nci_ds_hdr modify THRESHOLD_2 number(4,2) default .5;
update nci_ds_hdr set threshold_1 = .5, threshold_2 = .5;
commit;
alter table nci_ds_hdr enable all triggers;

alter table nci_ds_prmtr disable all triggers;
alter table nci_ds_prmtr_temp disable all triggers;
update nci_ds_prmtr_temp set threshold_1 = null, threshold_2 =null;
commit;
alter table nci_ds_prmtr_temp modify threshold_1 number(4,2);
alter table nci_ds_prmtr_temp modify threshold_2 number(4,2);
update nci_ds_prmtr set threshold_1 = null, threshold_2 =null;
commit;
alter table nci_ds_prmtr modify threshold_1 number(4,2);
alter table nci_ds_prmtr modify threshold_2 number(4,2);

alter table nci_ds_prmtr enable all triggers;
alter table nci_ds_prmtr_temp enable all triggers;
