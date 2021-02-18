delete from onedata_md.od_md_hookmap where hook_id in(

select obj_id from onedata_md.od_md_obj where obj_nm 
in('spFormRelatedPost','spModUpdPost','spInsRefBlobPost','spDelRefBlobPost','spUpdRefBlobPost','spAltDefPost')
);
commit;

