
alter table quest_vv_ext drop constraint QVT_QC_FK

alter table sbrext.triggered_actions_ext drop constraint TAT_QC_FK;
alter table sbrext.triggered_actions_ext drop constraint TAT_QC_FK2;
alter table sbrext.triggered_actions_ext drop constraint TAT_QVT_FK;
alter table sbrext.triggered_actions_ext drop constraint TAT_QVT_FK2;

alter table sbrext.VALID_VALUES_ATT_EXT drop constraint VVT_QC_FK;

