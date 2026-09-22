grant all on nci_ds_btch_hdr to onedata_wa;
alter table nci_ds_rslt disable all triggers;
alter table nci_ds_rslt modify score number(38,4);
alter table nci_ds_rslt enable all triggers;
