
update od_md_objcol set prop_val= 100 where prop_id = 812 and (obj_id, schm_id, col_id) in 
(select obj_id, schm_id, col_id from od_mdv_objcolhort where col_nm = 'CREAT_USR_ID')
and prop_val <> 100;


update od_md_objcol set prop_val= 101 where prop_id = 812 and (obj_id, schm_id, col_id) in 
(select obj_id, schm_id, col_id from od_mdv_objcolhort where col_nm = 'CREAT_DT')
and prop_val <> 101;


update od_md_objcol set prop_val= 102 where prop_id = 812 and (obj_id, schm_id, col_id) in 
(select obj_id, schm_id, col_id from od_mdv_objcolhort where col_nm = 'LST_UPD_USR_ID')
and prop_val <> 102;


update od_md_objcol set prop_val= 103 where prop_id = 812 and (obj_id, schm_id, col_id) in 
(select obj_id, schm_id, col_id from od_mdv_objcolhort where col_nm = 'LST_UPD_DT')
and prop_val <> 103;
commit;


update od_md_objcol set prop_val= 'Created By' where prop_id = 802 and (obj_id, schm_id, col_id) in 
(select obj_id, schm_id, col_id from od_mdv_objcolhort where col_nm = 'CREAT_USR_ID')
and prop_val <> 'Created By';


update od_md_objcol set prop_val= 'Date Created' where prop_id = 802 and (obj_id, schm_id, col_id) in 
(select obj_id, schm_id, col_id from od_mdv_objcolhort where col_nm = 'CREAT_DT')
and prop_val <> 'Date Created';


update od_md_objcol set prop_val= 'Last Modified By' where prop_id = 802 and (obj_id, schm_id, col_id) in 
(select obj_id, schm_id, col_id from od_mdv_objcolhort where col_nm = 'LST_UPD_USR_ID')
and prop_val <> 'Last Modified By';


update od_md_objcol set prop_val= 'Date Last Modified' where prop_id = 802 and (obj_id, schm_id, col_id) in 
(select obj_id, schm_id, col_id from od_mdv_objcolhort where col_nm = 'LST_UPD_DT')
and prop_val <> 'Date Last Modified';
commit;


update od_md_objcol set prop_val = 1000 where prop_id = 807 and (obj_id,proj_id, schm_id, col_id) in 
(select obj_id, proj_id, schm_id, col_id from od_mdv_objcolhort where col_nm = 'LANG_ID'
and nvl(pk_ind,0)<> 1)
;
commit;

insert into od_md_objcol (obj_id,proj_id, schm_id, col_id, clnt_id, prop_id, prop_val)
select  obj_id, proj_id, schm_id, col_id,clnt_id, 807, 1000 from od_mdv_objcolhort where col_nm = 'LANG_ID'
and nvl(pk_ind,0)<> 1
and ( obj_id, proj_id, schm_id, col_id) not in (select obj_id, proj_id, schm_id, col_id from od_md_objcol where prop_id = 807);
commit;
