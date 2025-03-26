alter table nci_mec_map add (CTL_VAL_MSG varchar2(4000));

alter table nci_stg_mec_val_map add (UPD_TYP char(1));

alter table obj_key add (min_cnt integer, max_cnt integer);
