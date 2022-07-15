-- DSRMWS-1257 Trademark is not Displayed/Represented properly in Forms and Modules fixes
update admin_item set item_nm =  replace (item_nm, chr(49817), chr(14845090)),
lst_upd_dt = sysdate, lst_upd_usr_id = 'ONEDATA', lst_upd_usr_id_x = 'ONEDATA',
CHNG_DESC_TXT =
substrb('Trademark symbol, not displayed properly in Long Name in UI, is fixed on ' || to_char(sysdate, 'MON DD, YYYY HH:MI AM') || '. Updated by ONEDATA.' || DECODE(CHNG_DESC_TXT, NULL, '', ' ' || CHNG_DESC_TXT), 1, 2000)
where admin_item_typ_id in (52, 54) and instr(item_nm, chr(49817)) > 0;
commit;