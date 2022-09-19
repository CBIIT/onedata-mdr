UPDATE NCI_MDR_CNTRL 
set PARAM_VAL = 'https://cadsrapi-qa.cancer.gov' 
where PARAM_NM = 'DOWNLOAD_HOST';
commit;

alter table admin_item disable all triggers;
 
update ADMIN_ITEM set ITEM_RPT_URL = (select PARAM_VAL || '/invoke/FormDownload/printerFriendly?item_id=' || item_id ||  chr(38) || 'version=' || ver_nr || '\Click_to_View'
from NCI_MDR_CNTRL where PARAM_NM = 'DOWNLOAD_HOST') where ADMIN_ITEM_TYP_ID = 54;
commit;
 
alter table admin_item enable all triggers;