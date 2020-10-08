update OD_MD_OBJTYPPROP set PROP_VAL = CONCAT((Select PROP_VAL from OD_MD_OBJTYPPROP where PROP_ID = 3037), ',customHtml') 
where PROP_ID = 3037 and PROP_VAL not like '%customHtml';
commit;
select PROP_VAL from OD_MD_OBJTYPPROP where PROP_ID = 3037 and PROP_VAL not like '%,customHtml';
