
  CREATE OR REPLACE  VIEW VW_USR_ADmIN ("USR_ID")   AS 
select s.usr_id from 
od_md_objsecu s, 
od_md_objsecurel r
where r.obj_depn_id = s.obj_id and r.obj_secu_id = 100;

grant select on vw_user_admin to onedata_wa;
