alter table nci_ds_rslt add ITEM_ID_2 number;
alter table nci_ds_rslt add VER_NR_2 number(4,2);
alter table nci_ds_rslt add RANK number;

alter table nci_ds_rslt disable all triggers;
update nci_ds_rslt set ITEM_ID_2 = ITEM_ID, VER_NR_2 = VER_NR;
commit;
alter table nci_ds_rslt modify cde_pref_ind number default null;
update nci_ds_rslt set cde_pref_ind = null where cde_pref_ind = 0;
commit;
alter table nci_ds_rslt enable all triggers;
