create or replace Procedure SAG_LOAD_CONCEPT_RETIRE
AS
v_end_date DATE := sysdate;
BEGIN
update admin_item set admin_stus_id = 77, --WFS to 'RETIRED ARCHIVED'
	LST_UPD_USR_ID = 'ONEDATA', 
	UNTL_DT = v_end_date
	where admin_item_typ_id = 49 and 
    admin_stus_id <> 77 and 
	item_long_nm in (
	select code from sag_load_concepts_evs where parents in(
'C176957',
'C167277',
'C157491',
'C83481',
'C83484',
'C83483', 
'C83482',
'C83479',
'C83480',
'C131742',
'C104171',
'C113462',
'C125190',
'C120167', 
'C85834', 
'C95421',
'C143136',
'C83485',
'C99526',
'C185140'
));
commit;
exception
 when OTHERS then
  rollback;
END;
/