-- DSRMWS-2343 DSRMWS-2425 After data refresh from Pro to lower tier, update Deep Links and Printer Friendly Links
alter table admin_item disable all triggers;

update ADMIN_ITEM set ITEM_DEEP_LINK = (Select param_val || '/CO/CDEDD?filter=CDEDD.ITEM_ID=' || item_id ||  '%20and%20ver_nr=' || ver_nr
from NCI_MDR_CNTRL where PARAM_NM = 'DEEP_LINK')
where admin_item_typ_id = 4 ;
commit;

update ADMIN_ITEM set ITEM_DEEP_LINK = (Select param_val || '/CO/FRMDD?filter=FRMDD.ITEM_ID=' || item_id || '%20and%20ver_nr=' || ver_nr
from NCI_MDR_CNTRL where PARAM_NM = 'DEEP_LINK')
where admin_item_typ_id = 54 ;
commit;

update ADMIN_ITEM set ITEM_RPT_URL = concat(
	(select PARAM_VAL from NCI_MDR_CNTRL where PARAM_NM = 'DOWNLOAD_HOST'),
	substr (ITEM_RPT_URL, REGEXP_instr(ITEM_RPT_URL, '/invoke')))
where ADMIN_ITEM_TYP_ID = 54;
commit;

alter table admin_item enable all triggers;
