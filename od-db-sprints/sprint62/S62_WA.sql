create or replace TRIGGER TR_MEC_MAP  BEFORE INSERT or UPDATE ON NCI_MEC_MAP for each row
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
