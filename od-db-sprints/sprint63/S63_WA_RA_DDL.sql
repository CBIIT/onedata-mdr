update nci_mec_map set TGT_FUNC_PARAM = TGT_VAL where  tgt_val is not null and tgt_func_param is null;
commit;

alter table nci_mec_val_map add (MECM_ID_DESC varchar2(4000));
