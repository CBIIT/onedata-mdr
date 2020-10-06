  
create trigger TR_S2P_CONC_DOM_VAL_MEAN
  BEFORE INSERT or UPDATE
  on CONC_DOM_VAL_MEAN
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_CSI
  BEFORE INSERT or UPDATE
  on NCI_CLSFCTN_SCHM_ITEM
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/



create trigger TR_S2P_NCI_STG_AI_CNCPT
  BEFORE INSERT or UPDATE
  on NCI_STG_AI_CNCPT
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_VAL_MEAN
  BEFORE INSERT or UPDATE
  on NCI_VAL_MEAN
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/



create trigger TR_S2P_NCI_PROTCL
  BEFORE INSERT or UPDATE
  on NCI_PROTCL
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_FORM
  BEFORE INSERT or UPDATE
  on NCI_FORM
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/




create trigger TR_S2P_NCI_ADMIN_ITEM_REL
  BEFORE INSERT or UPDATE
  on NCI_ADMIN_ITEM_REL
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_ADMIN_ITEM_REL_AK
  BEFORE INSERT or UPDATE
  on NCI_ADMIN_ITEM_REL_ALT_KEY
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_AK_ADMIN_ITEM_REL
  BEFORE INSERT or UPDATE
  on NCI_ALT_KEY_ADMIN_ITEM_REL
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_QUEST_VV
  BEFORE INSERT or UPDATE
  on NCI_QUEST_VALID_VALUE
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_CSI_ALT_DEFNMS
  BEFORE INSERT or UPDATE
  on NCI_CSI_ALT_DEFNMS
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/



create trigger TR_S2P_NCI_INSTR_S2P
  BEFORE INSERT or UPDATE
  on NCI_INSTR
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/



create trigger TR_S2P_NCI_QUEST_VV_REP
  BEFORE INSERT or UPDATE
  on NCI_QUEST_VV_REP
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_FORM_TA
  BEFORE INSERT or UPDATE
  on NCI_FORM_TA
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_USR_CART
  BEFORE INSERT or UPDATE
  on NCI_USR_CART
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


 
  CREATE OR REPLACE TRIGGER TR_AI_EXT_TAB_INS
  AFTER INSERT ON ADMIN_ITEM
  REFERENCING FOR EACH ROW
  BEGIN

if (:new.admin_item_typ_id in (5,6)) then
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def )
select :new.item_id, :new.ver_nr, :new.item_long_nm, :new.item_nm, :new.item_desc from dual;
else
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR)
select :new.ITEM_ID, :new.VER_NR from dual;
end if;
END;
/

 
create trigger TR_S2P_NCI_ENTTY
  BEFORE INSERT or UPDATE
  on NCI_ENTTY
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_ENTTY_COMM
  BEFORE INSERT or UPDATE
  on NCI_ENTTY_COMM
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_ENTTY_ADDR
  BEFORE INSERT or UPDATE
  on NCI_ENTTY_ADDR
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_ORG
  BEFORE INSERT or UPDATE
  on NCI_ORG
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_PRSN
  BEFORE INSERT or UPDATE
  on NCI_PRSN
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


drop trigger TR_AI_AUDIT_TAB_INS_PRD;

create or replace procedure sp_insert_all 
as
v_cnt integer;
begin


insert into obj_typ select * from onedata_wa.obj_typ;
commit;

insert into obj_key select * from onedata_wa.obj_key;
commit;

insert into NCI_ENTTY select * from onedata_wa.nci_entty;
commit;
insert into NCI_org select * from onedata_wa.nci_org;
commit;
insert into NCI_prsn select * from onedata_wa.nci_prsn;
commit;
insert into NCI_ENTTY_addr select * from onedata_wa.nci_entty_addr;
commit;
insert into NCI_ENTTY_comm select * from onedata_wa.nci_entty_comm;
commit;
insert into admin_item select * from onedata_wa.admin_item;
commit;
insert into cntxt select * from onedata_wa.cntxt;
commit;
insert into alt_nms select * from onedata_wa.alt_nms;
commit;
insert into alt_def select * from onedata_wa.alt_def;
commit;
insert into ref select * from onedata_wa.ref
commit;
insert into cncpt select * from onedata_wa.cncpt;
commit;
insert into prop select * from onedata_wa.prop;
commit;
insert into obj_cls select * from onedata_wa.obj_cls;
commit;
insert into rep_cls select * from onedata_wa.rep_cls;
commit;
insert into clsfctn_schm select * from onedata_wa.clsfctn_schm;
commit;
insert into conc_dom select * from onedata_wa.conc_dom;
commit;
insert into value_dom select * from onedata_wa.value_dom;
commit;
insert into nci_form select * from onedata_wa.nci_form;
commit;
insert into de_conc select * from onedata_wa.de_conc;
commit;
insert into de select * from onedata_wa.de;
commit;

insert into perm_val select * from onedata_wa.perm_val;
commit;
insert into conc_dom_val_mean select * from onedata_wa.conc_dom_val_mean;
commit;
insert into cncpt_admin_item select * from onedata_wa.cncpt_admin_item;
commit;




insert into NCI_CLSFCTN_SCHM_ITEM select * from onedata_wa.NCI_CLSFCTN_SCHM_ITEM;
commit;
insert into NCI_OC_RECS select * from onedata_wa.NCI_OC_RECS;
commit;
insert into NCI_PROTCL select * from onedata_wa.NCI_PROTCL;
commit;
insert into NCI_VAL_MEAN select * from onedata_wa.NCI_VAL_MEAN;
commit;

insert into NCI_ADMIN_ITEM_REL select * from onedata_wa.NCI_ADMIN_ITEM_REL;
commit;
insert into ref_Doc select * from onedata_wa.ref_doc;
commit;
insert into NCI_ADMIN_ITEM_EXT select * from onedata_wa.NCI_ADMIN_ITEM_EXT;
commit;

insert into NCI_ADMIN_ITEM_REL_ALT_KEY select * from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY;
commit;
insert into NCI_QUEST_VALID_VALUE select * from onedata_wa.NCI_QUEST_VALID_VALUE;
commit;
insert into NCI_ALT_KEY_ADMIN_ITEM_REL select * from onedata_wa.NCI_ALT_KEY_ADMIN_ITEM_REL;
commit;

insert into NCI_CSI_ALT_DEFNMS select * from onedata_wa.NCI_CSI_ALT_DEFNMS;


insert into NCI_FORM_TA select * from onedata_wa.NCI_FORM_TA;
commit;
insert into NCI_INSTR select * from onedata_wa.NCI_INSTR;
commit;
insert into NCI_QUEST_VV_REP select * from onedata_wa.NCI_QUEST_VV_REP;
commit;
insert into NCI_FORM_TA_REL select * from onedata_wa.NCI_FORM_TA_REL;
commit;
insert into  NCI_AI_TYP_VALID_STUS select * from onedata_wa. NCI_AI_TYP_VALID_STUS;
commit;


end;
/


