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
if (:new.tgt_mec_id is null) then
:new.tgt_cde_item_id := null;
:new.tgt_cde_ver_nr := null;
else
for cur in (select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char mec where mec_id = :new.tgt_mec_id) loop
:new.tgt_cde_item_id := cur.cde_item_id;
:new.tgt_cde_ver_nr := cur.cde_ver_nr;
end loop;
end if;
end if;

end;
/
  
create or replace TRIGGER TR_MEC_MAP_INS  BEFORE INSERT ON NCI_MEC_MAP for each row
declare 
v_src_nm varchar2(1000);
v_param_Val varchar2(255);
BEGIN   


if (:new.src_mec_id is not null )  then
for cur in (select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char mec where mec_id = :new.src_mec_id) loop
:new.src_cde_item_id := cur.cde_item_id;
:new.src_cde_ver_nr := cur.cde_ver_nr;
end loop;
else
    :new.src_cde_item_id := null;
:new.src_cde_ver_nr := null;
end if;

if (:new.tgt_mec_id is not null )  then
for cur in (select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char mec where mec_id = :new.tgt_mec_id) loop
:new.tgt_cde_item_id := cur.cde_item_id;
:new.tgt_cde_ver_nr := cur.cde_ver_nr;
end loop;
else
    :new.tgt_cde_item_id := null;
:new.tgt_cde_ver_nr := null;
end if;

end;
/
--jira 3658 
 CREATE OR REPLACE EDITIONABLE TRIGGER "ONEDATA_WA"."TR_NCI_DLOAD_NIH_SUB_TS" 
  BEFORE  UPDATE
  on NCI_DLOAD_NIH_SUB_TEMP
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  update NCI_DLOAD_HDR set LST_UPD_DT = sysdate, lst_upd_usr_id =:new.lst_upd_usr_id where hdr_id = :new.hdr_id;

END;
/
ALTER TRIGGER "ONEDATA_WA"."TR_NCI_DLOAD_NIH_SUB_TS" ENABLE;

CREATE OR REPLACE TRIGGER TR_DLOAD_MM_INS 
AFTER INSERT ON NCI_DLOAD_MDL_MAP_DTL 
for each row
DECLARE
v_hdr_id number;
v_mm_id number;
v_mm_ver_nr number (4,2);
v_temp number;
BEGIN
v_hdr_id := :new.hdr_id;
select mml.mm_id, mml.mm_ver_nr into v_mm_id, v_mm_ver_nr from vw_mdl_map_list_dload mml where mml.mm_curated_nm = :new.mm_nm_curated;
select count(*) into v_temp from nci_dload_dtl where hdr_id = v_hdr_id and item_id = v_mm_id and ver_nr = v_mm_ver_nr;
if (v_temp = 0) then
    insert into nci_dload_dtl(hdr_id,item_id,ver_nr) values (v_hdr_id, v_mm_id, v_mm_ver_nr);
    insert into onedata_ra.nci_dload_dtl(hdr_id,item_id,ver_nr) values (v_hdr_id, v_mm_id, v_mm_ver_nr);
end if;
END;
/
alter trigger tr_dload_mm_ins enable;

CREATE OR REPLACE TRIGGER TR_DLOAD_MM_DEL 
AFTER DELETE ON NCI_DLOAD_MDL_MAP_DTL 
for each row
DECLARE
v_hdr_id number;
v_mm_id number;
v_mm_ver_nr number (4,2);
BEGIN
v_hdr_id := :old.hdr_id;
select mml.mm_id, mml.mm_ver_nr into v_mm_id, v_mm_ver_nr from vw_mdl_map_list_dload mml where mml.mm_curated_nm = :old.mm_nm_curated;
delete from nci_dload_dtl where hdr_id = v_hdr_id and item_id = v_mm_id and ver_nr = v_mm_ver_nr;
delete from onedata_ra.nci_dload_dtl where hdr_id = v_hdr_id and item_id = v_mm_id and ver_nr = v_mm_ver_nr;
END;
/
alter trigger tr_dload_mm_del enable;
