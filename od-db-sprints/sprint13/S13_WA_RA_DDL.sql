alter table 	NCI_STG_CDE_CREAT add (
VD_CNTXT_ITEM_ID  number, 
VD_CNTXT_VER_NR number(4,2));

alter table NCI_STG_AI_CNCPT_CREAT add (CTL_VAL_STUS varchar2(100));
                                                              
 drop view vw_perm_values;
                                                              
alter NCI_DLOAD_HDR add (EMAIL_ADDR  varchar2(255));
                                              
