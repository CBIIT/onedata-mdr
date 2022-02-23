alter table quest_attributes_ext drop constraint QAT_QC_FK;
drop index QAT_QC_VV_FK;
alter table quest_attributes_ext drop constraint QAT_QC_FK2;
alter table quest_vv_ext drop constraint QVT_QVT_FK;


create index od_quest_rep_seq on QUEST_VV_EXT (QUEST_IDSEQ, REPEAT_SEQUENCE);


create unique index od_quest_id_ver on QUEST_contents_EXT (qc_id,  version);

