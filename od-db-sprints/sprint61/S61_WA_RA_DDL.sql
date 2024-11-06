alter table sag_load_mt add (syn_match number(1));

alter table sag_load_mt add (item_id number, ver_nr number(4,2));

alter table nci_mec_map add (SRC_CDE_ITEM_ID number, SRC_CDE_VER_NR number(4,2), TGT_CDE_ITEM_ID number, TGT_CDE_VER_NR number(4,2));


