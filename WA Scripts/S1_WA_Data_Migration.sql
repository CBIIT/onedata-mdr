exec sp_preprocess;

alter trigger TR_NCI_ALT_NMS_DENORM_INS disable;
alter trigger TR_NCI_AI_DENORM_INS disable;
alter trigger TR_AI_AUD_TS disable;
alter trigger TR_AI_EXT_TAB_INS disable;
alter trigger TR_DE_AUD_TS disable;
alter trigger TR_VAL_DOM_AUD_TS disable;
alter trigger  NCI_TR_ENTTY_ORG disable;
alter trigger NCI_TR_ENTTY_PRSN disable;

truncate table NCI_CSI_ALT_DEFNMS;
truncate table NCI_ALT_KEY_ADMIN_ITEM_REL;
truncate table NCI_FORM_TA_REL;
truncate table REF_DOC;
truncate table NCI_CHANGE_HISTORY;
truncate table ADMIN_ITEM_AUDIT;
truncate table NCI_ADMIN_ITEM_EXT;
truncate table NCI_AI_TYP_VALID_STUS;
truncate table NCI_FORM_TA;
truncate table NCI_INSTR;
truncate table NCI_QUEST_VV_REP;
truncate table NCI_ADMIN_ITEM_REL_ALT_KEY;
truncate table NCI_QUEST_VALID_VALUE;
truncate table NCI_ADMIN_ITEM_REL;
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


exec onedata_wa.sp_migrate_lov;
exec onedata_wa.sp_create_ai_1;
exec onedata_wa.sp_create_ai_2;
exec onedata_wa.sp_create_ai_3;
exec onedata_wa.sp_create_ai_4;
analyze table admin_item compute statistics;
exec onedata_wa.sp_create_pv;
analyze table admin_item compute statistics;
exec onedata_wa.sp_create_pv_2;
exec onedata_wa.sp_create_csi;
analyze table nci_admin_item_rel_alt_key compute statistics;
exec onedata_wa.sp_create_ai_cncpt;
exec onedata_wa.sp_create_form_ext;
analyze table admin_item compute statistics;
exec onedata_wa.sp_create_form_rel;
analyze table nci_admin_item_rel compute statistics;
exec onedata_wa.sp_create_form_question_rel;
analyze table nci_admin_item_rel_alt_key compute statistics;
exec onedata_wa.sp_create_form_vv_inst;
exec onedata_wa.sp_create_form_vv_inst_2;
exec onedata_wa.sp_create_form_ta;
exec onedata_wa.sp_create_csi_2;
analyze table admin_item compute statistics;
exec onedata_wa.sp_create_ai_children;
exec onedata_wa.sp_org_contact;
exec onedata_wa.sp_migrate_change_log;

alter trigger TR_NCI_ALT_NMS_DENORM_INS enable;
alter trigger TR_NCI_AI_DENORM_INS enable;
alter trigger OD_TR_ADMIN_ITEM enable;
alter trigger TR_AI_AUD_TS enable;
alter trigger TR_AI_EXT_TAB_INS enable;
alter trigger TR_DE_AUD_TS enable;
alter trigger TR_VAL_DOM_AUD_TS enable;
alter trigger  NCI_TR_ENTTY_ORG enable;
alter trigger NCI_TR_ENTTY_PRSN enable;




analyze table admin_item compute statistics;
analyze table nci_admin_item_rel_alt_key compute statistics;
analyze table PERM_VAL compute statistics;

