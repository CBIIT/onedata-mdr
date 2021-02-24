set serveroutput on size 1000000
SPOOL S3_RA_DATA_MIGRATION.log
--- Run in Release Area
alter trigger TR_AI_EXT_TAB_INS disable;
truncate table NCI_CSI_ALT_DEFNMS;
truncate table NCI_ALT_KEY_ADMIN_ITEM_REL;
truncate table NCI_FORM_TA_REL;
truncate table ADMIN_ITEM_AUDIT;
truncate table NCI_ADMIN_ITEM_EXT;
truncate table REF_DOC;
truncate table NCI_FORM_TA;
truncate table NCI_INSTR;
truncate table NCI_QUEST_VV_REP;
truncate table NCI_ADMIN_ITEM_REL_ALT_KEY;
truncate table NCI_QUEST_VALID_VALUE;
truncate table NCI_ADMIN_ITEM_REL;
truncate table NCI_AI_TYP_VALID_STUS;
truncate table NCI_CLSFCTN_SCHM_ITEM;
truncate table NCI_OC_RECS;
truncate table NCI_FORM;
truncate table NCI_PROTCL;
truncate table NCI_VAL_MEAN;
truncate table perm_val;
truncate table conc_dom_val_mean;
truncate table cncpt_admin_item;
truncate table nci_val_mean;
truncate table de;
truncate table de_conc;
truncate table value_dom;
truncate table conc_dom;
truncate table rep_cls;
truncate table clsfctn_schm;
truncate table obj_cls;
truncate table prop;
truncate table alt_nms;
truncate table alt_def;
truncate table ref;
truncate table cncpt;
truncate table cntxt;
truncate table admin_item;
truncate table NCI_ENTTY_ADDR;
truncate table NCI_ENTTY_COMM;
truncate table NCI_PRSN;
truncate table NCI_ORG;
truncate table NCI_ENTTY;
truncate table obj_key;
truncate table obj_typ;
truncate table NCI_USR_CART;
/
begin
dbms_output.put_line('tables truncated');
end;
/
exec sp_insert_all;
/
begin
dbms_output.put_line('sp_insert_all is completed');
end;
/
alter trigger TR_AI_EXT_TAB_INS enable;
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_RA', 'ADMIN_ITEM');
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_RA', 'NCI_ADMIN_ITEM_REL_ALT_KEY');
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_RA', 'PERM_VAL');
SPOOL OFF
