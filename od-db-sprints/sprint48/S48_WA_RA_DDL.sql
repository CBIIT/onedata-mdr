alter table NCI_STG_MDL_ELMNT add ME_TYP_ID integer;

alter table NCI_MEC_MAP add (SRC_MDL_ITEM_ID number, SRC_MDL_VER_NR number(4,2),TGT_MDL_ITEM_ID number, TGT_MDL_VER_NR number(4,2));

alter table nci_mec_map disable all triggers;

update nci_mec_map set (src_mdl_item_id, src_mdl_ver_nr) = (select mdl_item_id, mdl_item_ver_nr from nci_mdl_elmnt me, nci_mdl_elmnt_char mec where mec.mdl_elmnt_item_id = me.item_id and
mec.mdl_elmnt_ver_nr = me.ver_nr and mec.mec_id = nci_mec_map.src_mec_id);
commit;

update nci_mec_map set (tgt_mdl_item_id, tgt_mdl_ver_nr) = (select mdl_item_id, mdl_item_ver_nr from nci_mdl_elmnt me, nci_mdl_elmnt_char mec where mec.mdl_elmnt_item_id = me.item_id and
mec.mdl_elmnt_ver_nr = me.ver_nr and mec.mec_id = nci_mec_map.tgt_mec_id);
commit;

alter table nci_mec_map enable all triggers;

