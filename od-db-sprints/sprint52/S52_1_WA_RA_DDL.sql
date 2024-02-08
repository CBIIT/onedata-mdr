
update nci_ds_rslt set xmap_cd = 'NA' where xmap_cd is null;
commit;
alter table nci_ds_rslt modify (xmap_cd default 'NA');
alter table nci_ds_rslt modify (xmap_cd not null);

alter table nci_ds_rslt drop primary key;
alter table nci_ds_rslt add primary key (item_id, ver_nr, hdr_id, xmap_cd);
