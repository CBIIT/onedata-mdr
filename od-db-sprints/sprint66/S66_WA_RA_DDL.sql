alter table nci_mec_map add (MEC_SUB_GRP_NBR_DUP number(6,2));
alter table nci_mec_map disable all triggers;
update nci_mec_map set MEC_SUB_GRP_NBR_DUP= MEC_SUB_GRP_NBR;
commit;
alter table nci_mec_map enable all triggers;
alter table nci_mec_Map drop column  MEC_SUB_GRP_NBR;
alter table nci_mec_map rename column mec_sub_grp_nbr_dup to MEC_SUB_GRP_NBR;

alter table nci_stg_mec_map add (MEC_SUB_GRP_NBR_DUP number(6,2));
alter table nci_stg_mec_map disable all triggers;
update nci_stg_mec_map set MEC_SUB_GRP_NBR_DUP= MEC_SUB_GRP_NBR;
commit;
alter table nci_stg_mec_map enable all triggers;
alter table nci_stg_mec_Map drop column  MEC_SUB_GRP_NBR;
alter table nci_stg_mec_map rename column mec_sub_grp_nbr_dup to MEC_SUB_GRP_NBR;
