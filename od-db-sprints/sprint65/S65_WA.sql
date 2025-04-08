-- Tracker
update nci_mdl_elmnt_char c set (de_conc_item_id, de_conc_ver_nr) = (select de.de_conc_item_id, de.de_conc_ver_nr from
 de where c.cde_item_id = de.item_id and c.cde_ver_nr = de.ver_nr and (c.de_conc_item_id <> de.de_conc_item_id 
or c.de_conc_ver_nr <> de.de_conc_ver_nr))
where (cde_item_id, cde_ver_nr, de_conc_item_id, de_conc_ver_nr) in (select 
x.cde_item_id, x.cde_ver_nr, x.de_conc_item_id, x.de_conc_ver_nr from nci_mdl_elmnt_char x, de where x.cde_item_id = de.item_id and x.cde_ver_nr = de.ver_nr and (x.de_conc_item_id <> de.de_conc_item_id 
or x.de_conc_ver_nr <> de.de_conc_ver_nr))
and c.cde_item_id is not null  and c.de_conc_item_id is not null;
commit;


create or replace procedure mv_refresh (v_view_nm varchar2) as
   pragma autonomous_transaction;
   i      number;
begin
 dbms_job.submit(i,
             'begin DBMS_MVIEW.REFRESH(''' || v_view_nm || '''); end;',
                 sysdate + 1/(24*60*60),
                 'null'
                );
  commit;
 end;
 /

  
create or replace TRIGGER TR_AI_AFTER_INS_UPD
  AFTER INSERT or UPDATE
  on ADMIN_ITEM
  for each row
BEGIN

if (:new.admin_item_typ_id = 8) then -- context
mv_refresh('VW_CNTXT');
end if;

if (:new.admin_item_typ_id = 1) then -- conc dom
mv_refresh('VW_CONC_DOM');
end if;

END;
/

--jira 3936
CREATE OR REPLACE TRIGGER TR_DLOAD_MM_INS_NEW 
AFTER INSERT ON NCI_DLOAD_MDL_MAP_DTL_NEW 
for each row
DECLARE
v_hdr_id number;
v_mm_id number;
v_mm_ver_nr number (4,2);
v_temp number;
BEGIN
v_hdr_id := :new.hdr_id;
select mml.mm_id, mml.mm_ver_nr into v_mm_id, v_mm_ver_nr from vw_mdl_map_list_dload_new mml where mml.mm_id_ver = :new.mm_id_ver;
select count(*) into v_temp from nci_dload_dtl where hdr_id = v_hdr_id and item_id = v_mm_id and ver_nr = v_mm_ver_nr;
if (v_temp = 0) then
    insert into nci_dload_dtl(hdr_id,item_id,ver_nr) values (v_hdr_id, v_mm_id, v_mm_ver_nr);
    insert into onedata_ra.nci_dload_dtl(hdr_id,item_id,ver_nr) values (v_hdr_id, v_mm_id, v_mm_ver_nr);
end if;
END;
/

CREATE OR REPLACE TRIGGER TR_DLOAD_MM_DEL_NEW 
AFTER DELETE ON NCI_DLOAD_MDL_MAP_DTL_NEW
for each row
DECLARE
v_hdr_id number;
v_mm_id number;
v_mm_ver_nr number (4,2);
BEGIN
v_hdr_id := :old.hdr_id;
select mml.mm_id, mml.mm_ver_nr into v_mm_id, v_mm_ver_nr from vw_mdl_map_list_dload_new mml where mml.mm_id_ver = :old.mm_id_ver;
delete from nci_dload_dtl where hdr_id = v_hdr_id and item_id = v_mm_id and ver_nr = v_mm_ver_nr;
delete from onedata_ra.nci_dload_dtl where hdr_id = v_hdr_id and item_id = v_mm_id and ver_nr = v_mm_ver_nr;
END;
/
alter table nci_dload_mdl_map_dtl_new enable all triggers;
