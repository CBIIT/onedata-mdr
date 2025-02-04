CREATE OR REPLACE TRIGGER TR_MEC_MAP_UPD  BEFORE UPDATE ON NCI_MEC_MAP for each row
declare 
v_src_nm varchar2(1000);
v_param_Val varchar2(255);
BEGIN   

if (nvl(:new.src_mec_id,0)<> nvl(:old.src_mec_id,0)) then
if (:new.src_mec_id is null) then
:new.src_cde_item_id := null;
:new.src_cde_ver_nr := null;
else
for cur in (select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char mec where mec_id = :new.src_mec_id) loop
:new.src_cde_item_id := cur.cde_item_id;
:new.src_cde_ver_nr := cur.cde_ver_nr;
end loop;
end if;

end if;
if (nvl(:new.tgt_mec_id,0) <> nvl(:old.tgt_mec_id,0)) then
--raise_application_error(-20000,'here');
for cur in (select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char mec where mec_id = :new.tgt_mec_id) loop
if (:new.tgt_mec_id is null) then
:new.tgt_cde_item_id := null;
:new.tgt_cde_ver_nr := null;
else
:new.tgt_cde_item_id := cur.cde_item_id;
:new.tgt_cde_ver_nr := cur.cde_ver_nr;
end loop;
end if;
end if;

end;
/

/
