set serveroutput on size 1000000
SPOOL S12_RA_DATA_MIGRATION.log
--- Run in Release Area
truncate table ONEDATA_RA.NCI_CSI_ALT_DEFNMS;
truncate table ONEDATA_RA.NCI_ALT_KEY_ADMIN_ITEM_REL;
truncate table ONEDATA_RA.NCI_FORM_TA_REL;
truncate table ONEDATA_RA.ADMIN_ITEM_AUDIT;
truncate table ONEDATA_RA.NCI_ADMIN_ITEM_EXT;
truncate table ONEDATA_RA.REF_DOC;
truncate table ONEDATA_RA.NCI_FORM_TA;
truncate table ONEDATA_RA.NCI_INSTR;
truncate table ONEDATA_RA.NCI_QUEST_VV_REP;
truncate table ONEDATA_RA.NCI_ADMIN_ITEM_REL_ALT_KEY;
truncate table ONEDATA_RA.NCI_QUEST_VALID_VALUE;
truncate table ONEDATA_RA.NCI_ADMIN_ITEM_REL;
truncate table ONEDATA_RA.NCI_AI_TYP_VALID_STUS;
truncate table ONEDATA_RA.NCI_CLSFCTN_SCHM_ITEM;
truncate table ONEDATA_RA.NCI_OC_RECS;
truncate table ONEDATA_RA.NCI_FORM;
truncate table ONEDATA_RA.NCI_PROTCL;
truncate table ONEDATA_RA.NCI_VAL_MEAN;
truncate table ONEDATA_RA.perm_val;
truncate table ONEDATA_RA.conc_dom_val_mean;
truncate table ONEDATA_RA.cncpt_admin_item;
truncate table ONEDATA_RA.nci_val_mean;
truncate table ONEDATA_RA.de;
truncate table ONEDATA_RA.de_conc;
truncate table ONEDATA_RA.value_dom;
truncate table ONEDATA_RA.conc_dom;
truncate table ONEDATA_RA.rep_cls;
truncate table ONEDATA_RA.clsfctn_schm;
truncate table ONEDATA_RA.obj_cls;
truncate table ONEDATA_RA.prop;
truncate table ONEDATA_RA.alt_nms;
truncate table ONEDATA_RA.alt_def;
truncate table ONEDATA_RA.ref;
truncate table ONEDATA_RA.cncpt;
truncate table ONEDATA_RA.cntxt;
truncate table ONEDATA_RA.admin_item;
truncate table ONEDATA_RA.NCI_ENTTY_ADDR;
truncate table ONEDATA_RA.NCI_ENTTY_COMM;
truncate table ONEDATA_RA.NCI_PRSN;
truncate table ONEDATA_RA.NCI_ORG;
truncate table ONEDATA_RA.NCI_ENTTY;
truncate table ONEDATA_RA.obj_key;
truncate table ONEDATA_RA.obj_typ;
truncate table ONEDATA_RA.NCI_USR_CART;
/
begin
dbms_output.put_line('ONEDATA_RA tables truncated');
end;
/
exec sp_insert_all;
/
begin
dbms_output.put_line('ONEDATA_RA sp_insert_all is completed');
end;
/
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_RA', 'ADMIN_ITEM');
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_RA', 'NCI_ADMIN_ITEM_REL_ALT_KEY');
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_RA', 'PERM_VAL');
SPOOL OFF
