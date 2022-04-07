
alter table quest_vv_ext drop constraint QVT_QC_FK

alter table sbrext.triggered_actions_ext drop constraint TAT_QC_FK;
alter table sbrext.triggered_actions_ext drop constraint TAT_QC_FK2;
alter table sbrext.triggered_actions_ext drop constraint TAT_QVT_FK;
alter table sbrext.triggered_actions_ext drop constraint TAT_QVT_FK2;
alter table sbrext.quest_contents_ext drop constraint QC_VPV_FK;

alter table sbrext.VALID_VALUES_ATT_EXT drop constraint VVT_QC_FK;

create index nci_const_vv on sbrext.quest_contents_ext (p_val_idseq);

create index nci_const_qst on sbrext.quest_contents_ext (p_qst_idseq);

create index nci_const_mod on sbrext.quest_contents_ext (p_mod_idseq);



