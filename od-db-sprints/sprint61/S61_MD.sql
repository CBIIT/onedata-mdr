
  CREATE OR REPLACE VIEW "ONEDATA_MD"."VW_USR_ROW_FILTER" ("USR_ID", "ACTION_TYP", "CNTXT_ITEM_ID", "CNTXT_VER_NR") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select s.usr_id, a.action_typ, a.CNTXT_ITEM_ID, a.CNTXT_VER_NR from 
(select obj_Secu_id, OBJ_ID, ACTION_TYP, SUM(decode(col_nm, 'CNTXT_ITEM_ID', COL_VAL)) CNTXT_ITEM_ID, SUM(decode(col_nm, 'CNTXT_VER_NR', col_Val)) CNTXT_VER_NR from od_md_rowfilter where obj_id = 
(select obj_id from od_md_obj where obj_nm = 'Administered Item' and schm_id = 1 and proj_id = 1)
AND UPPER(COL_NM) IN ('CNTXT_ITEM_ID', 'CNTXT_VER_NR')
group by obj_secu_id, OBJ_ID,  ACTION_TYP ) a,
od_md_objsecu s, 
od_md_objsecurel r
where r.obj_secu_id = a.obj_secu_id and r.obj_depn_id = s.obj_id
union
select s.usr_id, 'I', 100, 1  from 
od_md_objsecu s, 
od_md_objsecurel r
where r.obj_depn_id = s.obj_id and r.obj_secu_id = 100
union
select s.usr_id, 'I', 100, 1  from 
od_md_objsecu s, 
od_md_objsecurel r
where r.obj_depn_id = s.obj_id and r.obj_secu_id in (Select obj_id from od_md_obj where upper(obj_nm) = 'SUPER CURATOR ROLE');


  GRANT DELETE ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_WA";
  GRANT INSERT ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_WA";
  GRANT SELECT ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_WA";
  GRANT UPDATE ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_WA";
  GRANT REFERENCES ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_WA";
  GRANT READ ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_WA";
  GRANT ON COMMIT REFRESH ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_WA";
  GRANT QUERY REWRITE ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_WA";
  GRANT DEBUG ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_WA";
  GRANT FLASHBACK ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_WA";
  GRANT MERGE VIEW ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_WA";
  GRANT READ ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_RO";
  GRANT SELECT ON "ONEDATA_MD"."VW_USR_ROW_FILTER" TO "ONEDATA_RO";
