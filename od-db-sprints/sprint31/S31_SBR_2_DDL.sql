-- Remove constraints and indexes on an old table that is no long er used but needs to stay for history
-- Indexes and constraints deleted so that if the ref doc is deleted, it does not cause an issue.

alter table sbrext.match_results_ext DISABLE CONSTRAINT MRT_ASV_FK;
alter table sbrext.match_results_ext DISABLE CONSTRAINT MRT_DET_FK;
alter table sbrext.match_results_ext DISABLE CONSTRAINT MRT_RDT_FK;
alter table sbrext.match_results_ext DISABLE CONSTRAINT MRT_VDN_FK;

drop index sbrext.MRT_ASV_FK;
drop index sbrext.MRT_DET_FK;
drop index sbrext.MRT_PVE_FK;
drop index sbrext.MRT_RDT_FK;
drop index sbrext.MRT_VDN_FK;
drop index sbrext.MRT_QC_CRF_FK;
drop index sbrext.MRT_QC_MATCH_FK;
drop index sbrext.MRT_QC_SUBMIT_FK;


