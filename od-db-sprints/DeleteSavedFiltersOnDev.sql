-- caution: this script when used "as is" deletes all search filters, and to be used on DEV tier only.
-- to delete specific filters modify by adding constraints.
delete from od_md_objrel where obj_depn_id in
(select obj_id from od_md_obj where obj_typ_id = 71);
commit;

delete from od_md_objprop where obj_id  in (
select obj_id from od_md_obj where obj_typ_id = 71  );
commit;

delete from od_md_obj where obj_id  in (
select obj_id from od_md_obj where obj_typ_id = 71  );
commit;
