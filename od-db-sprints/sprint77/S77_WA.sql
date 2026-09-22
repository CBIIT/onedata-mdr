drop index idx_ref_mtch_term_adv;
drop index idx_altnms_mtch_term_adv;

CREATE INDEX "ONEDATA_WA"."IDX_REF_MTCH_TERM_ADV" ON "ONEDATA_WA"."REF" ("MTCH_TERM_ADV")

  PCTFREE 10 INITRANS 2 MAXTRANS 167 COMPUTE STATISTICS

  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645

  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1

  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

  TABLESPACE "USERS" ;

commit work;

 

CREATE INDEX "ONEDATA_WA"."IDX_ALTNMS_MTCH_TERM_ADV" ON "ONEDATA_WA"."ALT_NMS" ("MTCH_TERM_ADV")

  PCTFREE 10 INITRANS 2 MAXTRANS 167 COMPUTE STATISTICS

  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645

  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1

  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)

  TABLESPACE "USERS" ;

commit work;


create index idx_nci_mec_val_map_mm
on nci_mec_val_map (mdl_map_item_id, mdl_map_ver_nr, fld_delete);


analyze table nci_mec_val_map compute statistics;


create index idx_nci_mec_map_mm
on nci_mec_map (mdl_map_item_id, mdl_map_ver_nr, fld_delete);


analyze table nci_mec_map compute statistics;


create index idx_admin_item_fld
on admin_Item (item_id, ver_nr, fld_delete);


analyze table admin_item compute statistics;


create or replace TRIGGER TR_REF_BEFORE
  BEFORE INSERT OR UPDATE
  on REF
  for each row
BEGIN


:new.MTCH_TERM := regexp_replace(upper(:new.ref_desc),'[^ A-Za-z0-9]','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.ref_desc),'[^A-Za-z0-9]','');  
END;
/

alter table ref disable all triggers;

update ref set mtch_term = regexp_replace(upper(ref_desc),'[^ A-Za-z0-9]',''),
mtch_term_adv =  regexp_replace(upper(ref_desc),'[^A-Za-z0-9]','');
commit;

alter table ref enable all triggers;


