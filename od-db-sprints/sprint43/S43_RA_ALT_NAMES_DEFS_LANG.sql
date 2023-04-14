--on ONEDATA_RA
--DSRMWS-2436 Concepts Synonym and Prior Preferred Name English Language
alter table ALT_NMS disable all triggers;
MERGE INTO ALT_NMS t1
USING
(
SELECT item_id, ver_nr FROM ADMIN_ITEM where
ADMIN_ITEM_TYP_ID = 49 --Concept
and cntxt_item_id = 20000000024 -- context NCIP
and cntxt_ver_nr = 1
)t2
ON (t1.item_id = t2.item_id
and t1.ver_nr = t2.ver_nr)
WHEN MATCHED THEN UPDATE SET
t1.LANG_ID = 1000 --ENGLISH
where t1.LANG_ID is null
and t1.NM_TYP_ID in (1064, 1049) --Synonym or Prior Preferred Name
and t1.CNTXT_ITEM_ID = 20000000024
and t1.CNTXT_VER_NR = 1
;
commit;
alter table ALT_NMS enable all triggers;
--DSRMWS-2436 Concepts Prior Preferred Definition English Language
alter table ALT_DEF disable all triggers;
MERGE INTO ALT_DEF t1
USING
(
SELECT item_id, ver_nr FROM ADMIN_ITEM where
ADMIN_ITEM_TYP_ID = 49 --Concept
and cntxt_item_id = 20000000024 -- context NCIP
and cntxt_ver_nr = 1
)t2
ON (t1.item_id = t2.item_id
and t1.ver_nr = t2.ver_nr)
WHEN MATCHED THEN UPDATE SET
t1.LANG_ID = 1000 --ENGLISH
where t1.LANG_ID is null
and t1.NCI_DEF_TYP_ID = 1357 -- Prior Preferred Definition
;
commit;
alter table ALT_DEF enable all triggers;