CREATE OR REPLACE TRIGGER OD_TR_FORM_IMPORT_AUD
BEFORE INSERT OR UPDATE ON NCI_STG_FORM_IMPORT
for each row
BEGIN
:new.LST_UPD_DT_CHAR := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
:new.LST_UPD_DT := sysdate;
END;
/


alter table admin_item disable all triggers;

update admin_item set MTCH_TERM = regexp_replace(upper(item_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}',''),
MTCH_TERM_ADV = regexp_replace(upper(item_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
commit;

alter table admin_item enable all triggers;


alter table alt_nms disable all triggers;

update alt_nms set MTCH_TERM = regexp_replace(upper(nm_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}',''),
MTCH_TERM_ADV = regexp_replace(upper(nm_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
commit;

alter table alt_nms enable all triggers;


alter table ref disable all triggers;

update ref set MTCH_TERM = regexp_replace(upper(ref_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}',''),
MTCH_TERM_ADV = regexp_replace(upper(ref_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
commit;

alter table ref enable all triggers;
