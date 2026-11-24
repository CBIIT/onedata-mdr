
-- S79_MD in QA only. Not for Stage and PRod.

update od_md_objsecu set email_id = 'rui.chen@nih.gov' where usr_id in (
'VERHOEFW',
'SCHAEFERH',
'CHARLESY', 'DWARZEL','LSCHICK','DMANATHARA');
commit;
