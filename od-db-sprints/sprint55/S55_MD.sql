
update od_md_cnstrnt set cnstrnt_nm = 'FK_VD_VD_TYP' where col_nm = 'VAL_DOM_TYP_ID' and obj_id in (select obj_id from od_md_obj where obj_nm = 'Value Domains');
commit;
