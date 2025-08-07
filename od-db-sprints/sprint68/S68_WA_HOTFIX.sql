create or replace TRIGGER TR_REF_BEFORE
  BEFORE INSERT OR UPDATE
  on REF
  for each row
BEGIN

:new.MTCH_TERM := regexp_replace(upper(:new.ref_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.ref_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');  
END;
/

alter table ref disable all triggers;

update ref set  mtch_term = regexp_replace(upper(ref_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}',''),
mtch_term_adv = regexp_replace(upper(ref_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
commit;

alter table ref enable all triggers;

alter table nci_ds_rslt_dtl add (mtch_desc_txt varchar2(4000));
