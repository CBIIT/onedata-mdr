update admin_item set item_nm =  replace (item_nm, chr(49817), chr(14845090)),
lst_upd_dt = sysdate, lst_upd_usr_id = 'ONEDATA', lst_upd_usr_id_x = 'ONEDATA'
where admin_item_typ_id in (52, 54) and  instr(item_nm, chr(49817)) > 0;
commit;