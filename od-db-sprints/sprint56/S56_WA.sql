 CREATE INDEX IDX2_PERM_VAL_SUBSET on PERM_VAL_SUBSET ("VAL_DOM_ITEM_ID", "VAL_DOM_VER_NR", "NCI_VAL_MEAN_ITEM_ID", "NCI_VAL_MEAN_VER_NR") ;

CREATE UNIQUE INDEX UX_PERM_VAL_SUBSET ON PERM_VAL_SUBSET ("VAL_DOM_ITEM_ID", "VAL_DOM_VER_NR", "PERM_VAL_NM", "NCI_VAL_MEAN_ITEM_ID", "NCI_VAL_MEAN_VER_NR") ;

  CREATE OR REPLACE EDITIONABLE TRIGGER OD_TR_PERM_VAL_SUBSET BEFORE INSERT  on PERM_VAL_SUBSET  for each row
       BEGIN    IF (:NEW.VAL_ID<= 0  or :NEW.VAL_ID is null)  THEN 
       select od_seq_PERM_VAL.nextval
  into :new.VAL_ID  from  dual ;   END IF; END ;

/
 
create or replace TRIGGER TR_NCI_DLOAD_INIT_COL 
BEFORE INSERT ON NCI_DLOAD_CSTM_COL_DTL
for each row
DECLARE
v_cnt number;
v_pos number;
BEGIN
select count(*), max(col_pos) into v_cnt, v_pos from nci_dload_cstm_col_dtl where hdr_id = :new.hdr_id;
if (v_cnt < 1) then
  nci_dload.spInitCstmColOrder(:new.hdr_id, 'I');
  else
 -- nci_dload.spAppendColumn(:new.hdr_id, :new.col_id);
  :new.col_pos := v_pos + 1;
  end if;

END;
/

update nci_dload_cstm_col_key set is_visible = 1;
commit;

insert into nci_dload_cstm_col_key (col_id, col_nm, dload_typ,xpath, data_object, is_visible) values (131, 'Deep Link', 'CDE', '/dataElements/deepLink', 'DATA_ELEMENT', 1);
insert into nci_dload_cstm_col_key (col_id, col_nm, dload_typ, xpath, data_object, is_visible) values (132, 'Representation Term Concept ID','CDE','/dataElements/valueDomain/representation/concepts/publicId', 'REPRESENTATION_CONCEPT', 1);
commit;

update nci_dload_cstm_col_key set xpath = '/dataElements/property/concepts/shortName' where col_id = 36;
update nci_dload_cstm_col_key set xpath = '/dataElements/objectClass/concepts/shortName' where col_id = 25;
update nci_dload_cstm_col_key set xpath = '/dataElements/valueDomain/representation/concepts/shortName' where col_id = 67;
update nci_dload_cstm_col_key set xpath = '/dataElements/valueDomain/concepts/shortName' where col_id = 56;
update nci_dload_cstm_col_key set is_visible = 1 where col_id = 56;
update nci_dload_cstm_col_key set col_nm = 'Value Domain Min Value' where col_id = 51;
commit;

update nci_dload_cstm_col_key set is_visible = 0 where col_id in (select col_id from nci_dload_cstm_col_key where xpath is null);
update nci_dload_cstm_col_key set is_visible = 0 where col_id in (113, 115,132,118,119);
commit;

