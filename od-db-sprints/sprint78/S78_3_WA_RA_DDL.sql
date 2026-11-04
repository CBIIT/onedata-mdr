alter table nci_ds_hdr disable all triggers;
alter table nci_ds_hdr modify VARIANT_2 number default 265;
update nci_ds_hdr set VARIANT_2 = 265;
commit;
alter table nci_ds_hdr enable all triggers;

alter table nci_ds_btch_hdr disable all triggers;
alter table nci_ds_btch_hdr add VARIANT_2 number default 265;
update nci_ds_btch_hdr set VARIANT_2 = 265;
commit;
alter table nci_ds_btch_hdr enable all triggers;
