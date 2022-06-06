create or replace Procedure SAG_LOAD_CONCEPT_RETIRE (p_END_DATE IN date default sysdate)
AS
v_end_date DATE;
BEGIN
	v_end_date := p_END_DATE;
update admin_item set admin_stus_id = 77, --WFS to 'RETIRED ARCHIVED'
	LST_UPD_USR_ID = 'ONEDATA', 
	UNTL_DT = v_end_date,
	REGSTR_STUS_ID = 11 -- 'Retired'
	where admin_item_typ_id = 49 and -- Concept
	admin_stus_id <> 77 and 
	item_long_nm in ( -- EVS provided list - parents of retired concepts
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