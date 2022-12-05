truncate table NCI_STG_FORM_IMPORT;
truncate table NCI_STG_FORM_QUEST_IMPORT;
truncate table NCI_STG_FORM_VV_IMPORT;

alter table NCI_STG_FORM_IMPORT
add (BTCH_USR_NM varchar2(100) not null, BTCH_NM varchar2(100) not null, CREATED_FORM_ITEM_ID number);

alter table NCI_STG_FORM_IMPORT
add PROCESS_DT_CHAR  varchar2(20);

alter table NCI_STG_FORM_QUEST_IMPORT
add (BTCH_SEQ_NBR number not null);


alter table NCI_STG_FORM_QUEST_IMPORT
add (SRC_REQ_IND varchar2(10));
