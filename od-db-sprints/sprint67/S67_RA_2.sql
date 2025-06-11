--jira 4114 RA, after WA
--drop primary key: replace primary key value per tier; QA: SYS_C0018500
alter table nci_ds_dtl drop constraint SYS_C0018500;

--create new primary key
alter table nci_ds_dtl add constraint SYS_C0018500 primary key (HDR_ID, PVVM_ID);
