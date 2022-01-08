set serveroutput on size 1000000
SPOOL S18_WA_DATA_MIGRATION.log
--create index SBREXT.AC_CHANGE_HISTORY_IDX on SBREXT.AC_CHANGE_HISTORY_EXT (AC_IDSEQ);


--drop sequence od_seq_ADMIN_ITEM;
   
--create sequence od_seq_ADMIN_ITEM MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 start with 10000000 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;

alter trigger TRG_NCI_QVV_POST disable;
alter trigger TRG_NCI_QS_MOD_POST disable;
alter trigger TRG_NCI_MOD_PROT_POST disable;
alter trigger TR_NCI_ALT_NMS_DENORM_INS disable;
alter trigger TR_NCI_AI_DENORM_INS disable;
alter trigger TR_AI_AUD_TS disable;
alter trigger OD_TR_ADMIN_ITEM disable;
alter trigger TR_AI_EXT_TAB_INS disable;
alter trigger TR_DE_AUD_TS disable;
alter trigger TR_VAL_DOM_AUD_TS disable;
alter trigger  NCI_TR_ENTTY_ORG disable;
alter trigger NCI_TR_ENTTY_PRSN disable;
alter trigger TR_DATA_TYP_AUD_TS disable;
alter trigger TR_PERM_VAL_AUD_TS disable;
alter trigger TR_NCI_FORM_AUD_TS disable;
alter trigger TR_NCI_ADMIN_ITEM_REL_AK_AUD_TS disable;
alter trigger TR_NCI_ADMIN_ITEM_REL_AUD_TS disable;
alter trigger TR_NCI_QUEST_VV_AUD_TS disable;
alter trigger TR_NCI_CSI_AUD_TS disable;
alter trigger TR_NCI_QUEST_VV_REP_AUD_TS disable;
alter trigger TR_AI_WFS disable;
alter trigger TR_STUS_MSTR_AUD_TS disable;
alter trigger TR_CNTXT_AUD_TS disable;
alter trigger TR_NCI_ALT_NMS disable;
alter trigger TR_NCI_ALT_DEF disable;
alter trigger OD_TR_ALT_KEY disable;
alter trigger OD_TR_QUEST_VV disable;
-- Added
alter trigger TR_ALT_DEF_POST disable;
alter trigger TR_ALT_NMS_POST disable;
alter trigger TR_CLSFCTN_SCHM_POST disable;
alter trigger TR_CNCPT_POST disable;
alter trigger TR_CONC_DOM_POST disable;
alter trigger TR_DE_POST disable;
alter trigger TR_DEC_POST disable;
alter trigger TR_CSI_DE_POST disable;
alter trigger TR_NCI_CSI_POST disable;
alter trigger TR_NCI_FORM_POST disable;
alter trigger TR_NCI_PROTCL_POST disable;
alter trigger TR_REF_POST disable;
alter trigger TR_VD_POST disable;
alter trigger TR_PERM_VAL_POST disable;
alter trigger TR_NCI_OC_RECS_POST disable;
alter trigger TR_NCI_VAL_MEAN_POST disable;
alter trigger TR_CNCPT_AUD_TS disable;
alter trigger TR_NCI_CSI_AUD_TS disable;
alter trigger TR_NCI_CSI_POST disable;

--drop index idxNCiAIRelUni;
drop index idx_Admin_item_nci_uni;

truncate table cs_csi_copy;

insert into cs_csi_copy 
select *  from sbr_m.cs_csi;

truncate table cs_items_copy;

insert into cs_items_copy
select *  from sbr_m.cs_items;

exec nci_cadsr_pull.spCreateNewNode;


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
truncate table nci_module;
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
truncate table NCI_USR_CART;

begin
dbms_output.put_line('tables truncated!!!');
end;
/
exec nci_caDSR_Pull.sp_migrate_lov;
begin
dbms_output.put_line('sp_migrate_lov are completed!!!!');
end;
/
exec nci_caDSR_Pull.sp_org_contact;
begin
dbms_output.put_line('sp_org_contact are completed!!!!');
end;
/
exec nci_caDSR_Pull.sp_create_ai_1;
begin
dbms_output.put_line('sp_create_ai_1 are completed!!!!');
end;
/
exec nci_caDSR_Pull.sp_create_ai_2;
begin
dbms_output.put_line('sp_create_ai_2 are completed!!!!');
end;
/
exec nci_caDSR_Pull.sp_create_ai_3;
begin
dbms_output.put_line('sp_create_ai_3 are completed!!!!');
end;
/
exec nci_caDSR_Pull.sp_create_ai_4;
begin
dbms_output.put_line('sp_create_ai_4 are completed!!!!');
end;
/
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_WA', 'ADMIN_ITEM');
exec nci_caDSR_Pull.sp_create_pv;
begin
dbms_output.put_line('sp_create_pv are completed!!!!');
end;
/
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_WA', 'ADMIN_ITEM');
exec nci_caDSR_Pull.sp_create_pv_2;
begin
dbms_output.put_line('sp_create_pv_2 are completed!!!!');
end;
/
exec nci_caDSR_Pull.sp_create_csi;
begin
dbms_output.put_line('sp_create_csi are completed!!!!');
end;
/
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_WA', 'NCI_ADMIN_ITEM_REL_ALT_KEY');
exec nci_caDSR_Pull.sp_create_ai_cncpt;
begin
dbms_output.put_line('sp_create_ai_cncpt are completed!!!!');
end;
/
exec nci_caDSR_Pull.sp_create_form_ext;
begin
dbms_output.put_line('sp_create_form_ext are completed!!!!');
end;
/
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_WA', 'ADMIN_ITEM');
exec nci_caDSR_Pull.sp_create_form_rel;
begin
dbms_output.put_line('sp_create_form_rel are completed!!!!');
end;
/
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_WA', 'NCI_ADMIN_ITEM_REL');
exec nci_caDSR_Pull.sp_create_form_question_rel;
begin
dbms_output.put_line('sp_create_form_question_rel are completed!!!');
end;
/
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_WA', 'NCI_ADMIN_ITEM_REL_ALT_KEY');
exec nci_caDSR_Pull.sp_create_form_vv_inst;
begin
dbms_output.put_line('sp_create_form_vv_inst are completed!!!!');
end;
/
--exec nci_caDSR_Pull.sp_create_form_vv_inst_2;
exec nci_caDSR_Pull.sp_create_form_vv_inst_new;
begin
dbms_output.put_line('sp_create_form_vv_inst_new are completed!!!!');
end;
/
exec nci_caDSR_Pull.sp_create_form_ta;
begin
dbms_output.put_line('sp_create_form_ta are completed!!!!');
end;
/
exec nci_caDSR_Pull.sp_create_csi_2;
begin
dbms_output.put_line('sp_create_csi_2 are completed!!!!');
end;
/
exec nci_caDSR_Pull.sp_reorder_mod;
begin
dbms_output.put_line('sp_reorder_mod are completed!!!!');
end;
/
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_WA', 'ADMIN_ITEM');
exec nci_caDSR_Pull.sp_create_ai_children;
begin
dbms_output.put_line('sp_create_ai_children are completed!!!!');
end;
/
exec nci_caDSR_Pull.sp_post_upd;
begin
dbms_output.put_line('sp_post_upd are completed!!!!');
end;
/
exec nci_cadsr_pull.sp_quest_rep;
--exec nci_caDSR_Pull.sp_migrate_change_log;
begin
dbms_output.put_line('sp_quest_rep are completed!!!!');
end;
/
exec sp_postprocess;
begin
dbms_output.put_line('all sps are completed!!!!');
end;
/
alter trigger TR_NCI_ALT_NMS_DENORM_INS enable;
alter trigger TR_NCI_AI_DENORM_INS enable;
alter trigger OD_TR_ADMIN_ITEM enable;
alter trigger TR_AI_AUD_TS enable;
alter trigger TR_AI_EXT_TAB_INS enable;
alter trigger TR_DE_AUD_TS enable;
alter trigger TR_VAL_DOM_AUD_TS enable;
alter trigger OD_TR_ADMIN_ITEM enable;
alter trigger  NCI_TR_ENTTY_ORG enable;
alter trigger NCI_TR_ENTTY_PRSN enable;
alter trigger TR_DATA_TYP_AUD_TS enable;
alter trigger TR_PERM_VAL_AUD_TS enable;
alter trigger TR_NCI_FORM_AUD_TS enable;
alter trigger TR_NCI_ADMIN_ITEM_REL_AK_AUD_TS enable;
alter trigger TR_NCI_ADMIN_ITEM_REL_AUD_TS enable;
alter trigger TR_NCI_QUEST_VV_AUD_TS enable;
alter trigger TR_NCI_CSI_AUD_TS enable;
alter trigger TR_NCI_QUEST_VV_REP_AUD_TS enable;
alter trigger TR_AI_WFS enable;
alter trigger TR_STUS_MSTR_AUD_TS enable;
alter trigger TR_CNTXT_AUD_TS enable;
alter trigger TR_NCI_ALT_NMS enable;
alter trigger TR_NCI_ALT_DEF enable;
alter trigger OD_TR_ALT_KEY enable;
alter trigger OD_TR_QUEST_VV enable;
-- Added
alter trigger TR_ALT_DEF_POST enable;
alter trigger TR_ALT_NMS_POST enable;
alter trigger TR_CLSFCTN_SCHM_POST enable;
alter trigger TR_CNCPT_POST enable;
alter trigger TR_CONC_DOM_POST enable;
alter trigger TR_DE_POST enable;
alter trigger TR_DEC_POST enable;
alter trigger TR_CSI_DE_POST enable;
alter trigger TR_NCI_CSI_POST enable;
alter trigger TR_NCI_FORM_POST enable;
alter trigger TR_NCI_PROTCL_POST enable;
alter trigger TR_REF_POST enable;
alter trigger TR_VD_POST enable;
alter trigger TRG_NCI_QVV_POST enable;
alter trigger TRG_NCI_QS_MOD_POST enable;
alter trigger TRG_NCI_MOD_PROT_POST enable;
alter trigger TR_PERM_VAL_POST enable;
alter trigger TR_NCI_OC_RECS_POST enable;
alter trigger TR_NCI_VAL_MEAN_POST enable;
alter trigger TR_CNCPT_AUD_TS enable;
alter trigger TR_NCI_CSI_AUD_TS enable;
alter trigger TR_NCI_CSI_POST enable;

---create unique index idxNCiAIRelUni on nci_admin_item_rel 
--( P_ITEM_ID, P_ITEM_VER_NR,decode(REL_TYP_ID, 61, 1,C_ITEM_ID), C_ITEM_VER_NR,  REL_TYP_ID, DISP_ORD);


create unique index idx_Admin_item_nci_uni on admin_item (ADMIN_ITEM_TYP_ID, ITEM_LONG_NM, CNTXT_ITEM_ID, CNTXT_VER_NR, VER_NR);


EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_WA', 'ADMIN_ITEM');
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_WA', 'NCI_ADMIN_ITEM_REL_ALT_KEY');
EXEC DBMS_STATS.GATHER_TABLE_STATS ('ONEDATA_WA', 'PERM_VAL');

EXECUTE DBMS_MVIEW.REFRESH('VW_CNTXT');
EXECUTE DBMS_MVIEW.REFRESH('VW_CONC_DOM');
EXECUTE DBMS_MVIEW.REFRESH('VW_CNCPT');

--drop  index SBREXT.AC_CHANGE_HISTORY_IDX;
SPOOL OFF;

