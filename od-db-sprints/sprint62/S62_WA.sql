/*create or replace TRIGGER TR_MEC_MAP  BEFORE INSERT or UPDATE ON NCI_MEC_MAP for each row
declare 
v_src_nm varchar2(1000);
v_param_Val varchar2(255);
BEGIN   

if (:new.src_mec_id is not null) then
select lower(me.item_phy_obj_nm) || '.' || upper(mec_phy_nm) into v_src_nm 
from nci_mdl_elmnt_char mec, nci_mdl_elmnt me where mec.mdl_elmnt_item_id = me.item_id and mec.mdl_elmnt_ver_nr = me.ver_nr and mec.mec_id = :new.src_mec_id;
if (:new.LEFT_OP = 'SOURCE') then
:new.left_op := v_src_nm;
end if;
if (:new.RIGHT_OP = 'SOURCE') then
:new.left_op := v_src_nm;
end if;
if (:new.TGT_FUNC_PARAM = 'SOURCE') then
:new.left_op := v_src_nm;
end if;
end if;
end;
/

*/
  create or replace TRIGGER TR_MEC_MAP_UPD  BEFORE UPDATE ON NCI_MEC_MAP for each row
declare 
v_src_nm varchar2(1000);
v_param_Val varchar2(255);
BEGIN   

if (nvl(:new.src_mec_id,0)<> nvl(:old.src_mec_id,0)) then
for cur in (select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char mec where mec_id = :new.src_mec_id) loop
:new.src_cde_item_id := cur.cde_item_id;
:new.src_cde_ver_nr := cur.cde_ver_nr;
end loop;
end if;
if (nvl(:new.tgt_mec_id,0) <> nvl(:old.tgt_mec_id,0)) then
--raise_application_error(-20000,'here');
for cur in (select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char mec where mec_id = :new.tgt_mec_id) loop
:new.tgt_cde_item_id := cur.cde_item_id;
:new.tgt_cde_ver_nr := cur.cde_ver_nr;
end loop;
end if;
end;
/

  CREATE OR REPLACE TRIGGER TR_NCI_MDL_MAP_SHORT_NM
  AFTER INSERT 
  on NCI_MDL_MAP
  for each row
BEGIN
   update ADMIN_ITEM set MDL_MAP_SNAME = (Select substr(s.item_nm || 'v' || :new.src_mdl_ver_nr || ' -> ' || t.item_nm || 'v' || :new.tgt_mdl_ver_nr ,1,30)
   from admin_item s, admin_item t where s.item_id = :new.src_mdl_item_id and s.ver_nr = :new.src_mdl_ver_nr and t.item_id = :new.tgt_mdl_item_id and t.ver_nr = :new.tgt_mdl_ver_nr)
   where item_id = :new.item_id and ver_nr = :new.ver_nr;
  -- commit;

END;
/

alter table ADMIN_ITEM disable all triggers;
update ADMIN_ITEM x set MDL_MAP_SNAME =  (Select substr(s.item_nm || 'v' || map.src_mdl_ver_nr || ' -> ' || t.item_nm || 'v' || map.tgt_mdl_ver_nr  ,1,30)
   from admin_item s, admin_item t, nci_mdl_map map where s.item_id = map.src_mdl_item_id and s.ver_nr = map.src_mdl_ver_nr
  and t.item_id = map.tgt_mdl_item_id and t.ver_nr = map.tgt_mdl_ver_nr and map.item_id = x.item_id and map.ver_nr = x.ver_nr)
  where admin_item_typ_id = 58;
commit;
alter table ADMIN_ITEM enable all triggers;
