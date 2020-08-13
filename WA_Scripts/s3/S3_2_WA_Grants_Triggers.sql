drop trigger TR_AI_AUDIT_TAB_INS;


create or replace TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT  on ADMIN_ITEM  for each row
     BEGIN    IF (:NEW.ITEM_ID = -1  or :NEW.ITEM_ID is null)  THEN select od_seq_ADMIN_ITEM.nextval
 into :new.ITEM_ID  from  dual ;   END IF;
if (:new.nci_idseq is null) then 
 :new.nci_idseq := nci_11179.cmr_guid();
end if; 
if (:new.ITEM_LONG_NM is null) then
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || :new.ver_nr;
end if;
:new.creat_usr_id_x := :new.creat_usr_id;
:new.lst_upd_usr_id_x := :new.lst_upd_usr_id;
if (:new.lst_upd_dt is null) then
:new.lst_upd_dt := sysdate;
end if;
END ;
/
 
create or replace trigger TR_CONC_DOM_VAL_MEAN_AUD_TS
  BEFORE  UPDATE
  on CONC_DOM_VAL_MEAN
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_CSI_AUD_TS
  BEFORE  UPDATE
  on NCI_CLSFCTN_SCHM_ITEM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/



create or replace trigger TR_NCI_VAL_MEAN_AUD_TS
  BEFORE  UPDATE
  on NCI_VAL_MEAN
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/



create or replace trigger TR_NCI_PROTCL_AUD_TS
  BEFORE  UPDATE
  on NCI_PROTCL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create or replace trigger TR_NCI_FORM_AUD_TS
  BEFORE  UPDATE
  on NCI_FORM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_TEMPLATE_AUD_TS
  BEFORE  UPDATE
  on NCI_PROTCL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_STG_AI_AUD_TS
  BEFORE  UPDATE
  on NCI_STG_ADMIN_ITEM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_STG_AI_CNCPT_AUD_TS
  BEFORE UPDATE
  on NCI_STG_AI_CNCPT
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create or replace trigger TR_NCI_ADMIN_ITEM_REL_AUD_TS
  BEFORE  UPDATE
  on NCI_ADMIN_ITEM_REL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create or replace trigger TR_NCI_ADMIN_ITEM_REL_AK_AUD_TS
  BEFORE  UPDATE
  on NCI_ADMIN_ITEM_REL_ALT_KEY
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_AK_ADMIN_ITEM_REL_AUD_TS
  BEFORE  UPDATE
  on NCI_ALT_KEY_ADMIN_ITEM_REL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_QUEST_VV_AUD_TS
  BEFORE  UPDATE
  on NCI_QUEST_VALID_VALUE
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_CSI_ALT_DEFNMS_AUD_TS
  BEFORE  UPDATE
  on NCI_CSI_ALT_DEFNMS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/



create or replace trigger TR_NCI_INSTR_AUD_TS
  BEFORE  UPDATE
  on NCI_INSTR
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/



create or replace trigger TR_NCI_QUEST_VV_REP_AUD_TS
  BEFORE UPDATE
  on NCI_QUEST_VV_REP
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create or replace trigger TR_NCI_FORM_TA_AUD_TS
  BEFORE UPDATE
  on NCI_FORM_TA
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_USR_CART_AUD_TS
  BEFORE UPDATE
  on NCI_USR_CART
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

SET DEFINE OFF;
create or replace trigger TR_AI_AUD_TS
  BEFORE UPDATE
  on ADMIN_ITEM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_AI_AUD_TS;
/


create or replace trigger TR_AI_ALT_KEY
  BEFORE INSERT
  on ADMIN_ITEM
  for each row
BEGIN
:new.ALT_KEY := :new.ITEM_ID || '-' || :new.VER_NR;

END TR_AI_ALT_KEY;
/


create or replace trigger TR_AI_AUDIT_AUD_TS
  BEFORE UPDATE
  on ADMIN_ITEM_AUDIT
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_AI_AUDIT_AUD_TS;
/


create or replace trigger TR_AI_CSI_AUD_TS
  BEFORE UPDATE
  on ADMIN_ITEM_CLSFCTN_SCHM_ITEM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_AI_CSI_AUD_TS;
/


create or replace trigger TR_AI_REF_DOC_AUD_TS
  BEFORE UPDATE
  on ADMIN_ITEM_REF_DOC
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_AI_REF_DOC_AUD_TS;
/


create or replace trigger TBIU_ALT_DEF
  BEFORE UPDATE
  on ALT_DEF
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TBIU_ALT_DEF;
/


create or replace trigger TRU_ALT_NMS
  BEFORE UPDATE
  on ALT_NMS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TRU_ALT_NMS;
/


create or replace trigger TR_CASE_FILES_AUD_TS
  BEFORE UPDATE
  on CASE_FILES
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CASE_FILES_AUD_TS;
/


create or replace trigger TR_CHAR_SET_AUD_TS
  BEFORE UPDATE
  on CHAR_SET
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CHAR_SET_AUD_TS;
/


create or replace trigger TR_CS_AUDIT_TS
  BEFORE UPDATE
  on CLSFCTN_SCHM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CS_AUDIT_TS;
/


create or replace trigger TR_CSI_AUD_TS
  BEFORE UPDATE
  on CLSFCTN_SCHM_ITEM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CSI_AUD_TS;
/


create or replace trigger TR_CSI_REL_AUD_TS
  BEFORE UPDATE
  on CLSFCTN_SCHM_ITEM_REL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CSI_REL_AUD_TS;
/



create or replace trigger TR_CNTCT_AUD_TS
  BEFORE UPDATE
  on CNTCT
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CNTCT_AUD_TS;
/


create or replace trigger TR_CNTXT_AUD_TS
  BEFORE UPDATE
  on CNTXT
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CNTXT_AUD_TS;
/


create or replace trigger TR_CONC_DOM_AUD_TS
  BEFORE UPDATE
  on CONC_DOM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CONC_DOM_AUD_TS;
/


create or replace trigger TR_CONC_DOM_REL_AUD_TS
  BEFORE UPDATE
  on CONC_DOM_REL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CONC_DOM_REL_AUD_TS;
/


create or replace trigger TR_DATA_TYP_AUD_TS
  BEFORE UPDATE
  on DATA_TYP
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_DATA_TYP_AUD_TS;
/


create or replace trigger TR_DE_AUD_TS
  BEFORE UPDATE
  on DE
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_DE_AUD_TS;
/


create or replace trigger TR_DE_CONC_AUD_TS
  BEFORE UPDATE
  on DE_CONC
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_DE_CONC_AUD_TS;
/


create or replace trigger TR_DE_CONC_REL_AUD_TS
  BEFORE UPDATE
  on DE_CONC_REL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_DE_CONC_REL_AUD_TS;
/


create or replace trigger TR_DE_DERV_AUD_TS
  BEFORE UPDATE
  on DE_DERV
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_DE_DERV_AUD_TS;
/


create or replace trigger TR_DE_REL_AUD_TS
  BEFORE UPDATE
  on DE_REL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_DE_REL_AUD_TS;
/


create or replace trigger TR_DERV_RUL_AUD_TS
  BEFORE UPDATE
  on DERV_RUL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_DERV_RUL_AUD_TS;
/


create or replace trigger TR_FMT_AUD_TS
  BEFORE UPDATE
  on FMT
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_FMT_AUD_TS;
/


create or replace trigger TR_GLSRY_AUD_TS
  BEFORE UPDATE
  on GLSRY
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_GLSRY_AUD_TS;
/


create or replace trigger TR_IMPORT_PARAM_AUD_TS
  BEFORE UPDATE
  on IMPORT_MAPPING_PARAM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_IMPORT_PARAM_AUD_TS;
/


create or replace trigger TR_LANG_AUD_TS
  BEFORE UPDATE
  on LANG
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_LANG_AUD_TS;
/


create or replace trigger TR_OBJ_CLS_AUD_TS
  BEFORE UPDATE
  on OBJ_CLS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_OBJ_CLS_AUD_TS;
/


create or replace trigger TR_OBJ_KEY_AUD_TS
  BEFORE UPDATE
  on OBJ_KEY
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_OBJ_KEY_AUD_TS;
/


create or replace trigger TR_OBJ_TYP_AUD_TS
  BEFORE UPDATE
  on OBJ_TYP
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_OBJ_TYP_AUD_TS;
/


create or replace trigger TR_ORG_AUD_TS
  BEFORE UPDATE
  on ORG
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_ORG_AUD_TS;
/


create or replace trigger TR_PERM_VAL_AUD_TS
  BEFORE UPDATE
  on PERM_VAL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_PERM_VAL_AUD_TS;
/


create or replace trigger TR_PROP_AUD_TS
  BEFORE UPDATE
  on PROP
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_PROP_AUD_TS;
/


create or replace trigger TR_REF_AUD_TS
  BEFORE UPDATE
  on REF
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_REF_AUD_TS;
/


create or replace trigger TR_REF_DOC_AUD_TS
  BEFORE UPDATE
  on REF_DOC
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_REF_DOC_AUD_TS;
/


create or replace trigger TR_REGIST_RUL_AUD_TS
  BEFORE UPDATE
  on REGIST_RUL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_REGIST_RUL_AUD_TS;
/


create or replace trigger TR_REGIST_RUL_REQ_COL_AUD_TS
  BEFORE UPDATE
  on REGIST_RUL_REQ_COLMNS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_REGIST_RUL_REQ_COL_AUD_TS;
/


create or replace trigger TR_REP_CLS_AUD_TS
  BEFORE UPDATE
  on REP_CLS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_REP_CLS_AUD_TS;
/


create or replace trigger TR_STUS_MSTR_AUD_TS
  BEFORE UPDATE
  on STUS_MSTR
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_STUS_MSTR_AUD_TS;
/

create or replace trigger TR_STUS_TYP_AUD_TS
  BEFORE UPDATE
  on STUS_TYP
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_STUS_TYP_AUD_TS;
/

create or replace trigger TR_UOM_AUD_TS
  BEFORE UPDATE
  on UOM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_UOM_AUD_TS;
/


create or replace trigger TR_USR_GRP_AUD_TS
  BEFORE UPDATE
  on USR_GRP
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_USR_GRP_AUD_TS;
/


create or replace trigger TR_VAL_DOM_REL_AUD_TS
  BEFORE UPDATE
  on VAL_DOM_REL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_VAL_DOM_REL_AUD_TS;
/

create or replace trigger TR_VAL_MEAN_AUD_TS
  BEFORE UPDATE
  on VAL_MEAN
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_VAL_MEAN_AUD_TS;
/

create or replace trigger TR_VAL_DOM_AUD_TS
  BEFORE UPDATE
  on VALUE_DOM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_VAL_DOM_AUD_TS;
/

create or replace trigger OD_TR_SYS_CNSTRNT_AUD_TS
  BEFORE UPDATE
  on SYSTEM_CONSTRAINTS
  
  for each row
BEGIN :new.LST_UPD_DT := SYSDATE ; END;
/

create or replace trigger TR_SYSTEM_COLUMNS_DE_AUD_TS
  BEFORE UPDATE
  on SYSTEM_COLUMN_DE
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_SYSTEM_COLUMNS_DE_AUD_TS;
/

create or replace trigger TR_SYSTEM_COLUMNS_AUD_TS
  BEFORE UPDATE
  on SYSTEM_COLUMNS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_SYSTEM_COLUMNS_AUD_TS;
/


create or replace trigger TR_SYSTEM_TABLES_AUD_TS
  BEFORE UPDATE
  on SYSTEM_TABLES
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_SYSTEM_TABLES_AUD_TS;
/

create or replace trigger TR_SYSTEM_APPLICATION_AUD_TS
  BEFORE UPDATE
  on SYSTEM_APPLICATION
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_SYSTEM_APPLICATION_AUD;
/

create or replace trigger TR_ADMIN_ITEM_LANG_VAR_AUD_TS
  BEFORE UPDATE
  on ADMIN_ITEM_LANG_VAR
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_ADMIN_ITEM_LANG_VAR_AUD_TS;
/

create or replace trigger TR_CNCPT_AUD_TS
  BEFORE UPDATE
  on CNCPT
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CNCPT_AUD_TS;
/

create or replace trigger TR_CNCPT_ADMIN_ITEM_AUD_TS
  BEFORE UPDATE
  on CNCPT_ADMIN_ITEM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CNCPT_ADMIN_ITEM_AUD_TS;
/

create or replace trigger TR_CNCPT_CSI_AUD_TS
  BEFORE UPDATE
  on CNCPT_CSI
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CNCPT_CSI_AUD_TS;
/

create or replace trigger TR_CNCPT_VAL_MEAN_AUD_TS
  BEFORE UPDATE
  on CNCPT_VAL_MEAN
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_CNCPT_VAL_MEAN_AUD_TS;
/





create or replace trigger TR_SYSTEM_COLUMNS_DATA_AUD_TS
  BEFORE UPDATE
  on SYSTEM_COLUMNS_DATA
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_SYSTEM_COLUMNS_DATA_AUD_TS;
/



create or replace trigger TR_OD_CNSTRNT_TYP_AUD_TS
  BEFORE UPDATE
  on OD_CNSTRNT_TYP
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END TR_OD_CNSTRNT_TYP_AUD_TS;
/
