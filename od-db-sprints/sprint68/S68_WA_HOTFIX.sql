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


create or replace TRIGGER OD_TR_DS_UPD 
BEFORE UPDATE ON NCI_DS_HDR
for each row
BEGIN
  :new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
  :new.DT_SORT := systimestamp();
  :new.LST_UPD_DT := SYSDATE;

if (:new.cde_item_id is null and :new.rule_desc is not null) then
:new.rule_desc := null;
:new.mtch_desc_txt := null;
  end if;


END;
/

