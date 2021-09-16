alter table NCI_STG_AI_CNCPT_CREAT
 ADD ( CNCPT_INT_1_1 integer, CNCPT_INT_1_2 integer, CNCPT_INT_1_3 integer, CNCPT_INT_1_4 integer, CNCPT_INT_1_5 integer, 
 CNCPT_INT_1_6 integer, CNCPT_INT_1_7 integer, CNCPT_INT_1_8 integer, CNCPT_INT_1_9 integer, CNCPT_INT_1_10 integer, 
 CNCPT_INT_2_1 integer, CNCPT_INT_2_2 integer, CNCPT_INT_2_3 integer, CNCPT_INT_2_4 integer, CNCPT_INT_2_5 integer, 
 CNCPT_INT_2_6 integer, CNCPT_INT_2_7 integer, CNCPT_INT_2_8 integer, CNCPT_INT_2_9 integer, CNCPT_INT_2_10 integer);
 
 alter table 
 NCI_STG_PV_VM_BULK
 ADD ( CNCPT_INT_1_1 integer, CNCPT_INT_1_2 integer, CNCPT_INT_1_3 integer, CNCPT_INT_1_4 integer, CNCPT_INT_1_5 integer, 
 CNCPT_INT_1_6 integer, CNCPT_INT_1_7 integer, CNCPT_INT_1_8 integer, CNCPT_INT_1_9 integer, CNCPT_INT_1_10 integer, 
 STR_DESC_1  varchar2(4000),STR_DESC_2  varchar2(4000),STR_DESC_3  varchar2(4000),STR_DESC_4  varchar2(4000),STR_DESC_5  varchar2(4000),
     STR_DESC_6  varchar2(4000),STR_DESC_7  varchar2(4000),STR_DESC_8  varchar2(4000),STR_DESC_9  varchar2(4000),STR_DESC_10  varchar2(4000));
 
  alter table 
 NCI_STG_PV_VM_BULK
 ADD ( blank_1 char(1), blank_2 char(1), blank_3 char(1), blank_4 char(1), blank_5 char(1),
     blank_6 char(1), blank_7 char(1), blank_8 char(1), blank_9 char(1), blank_10 char(1) );
 
alter table nci_admin_item_ext add (CNCPT_CONCAT_WITH_INT varchar2(4000));

alter table nci_admin_item_rel_alt_key add (PREF_NM_MIGRATED varchar2(30));
