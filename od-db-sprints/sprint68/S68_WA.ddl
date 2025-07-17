drop materialized view vw_Admin_item_with_ext;



  CREATE MATERIALIZED VIEW VW_ADMIN_ITEM_WITH_EXT
  AS select ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.ITEM_LONG_NM, ai.ITEM_NM, ai.CHNG_DESC_TXT, 
 'Value Meaning' ADMIN_ITEM_TYP_ID ,ai.CURRNT_VER_IND,
 ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, 
 ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, e.cncpt_concat_src_typ evs_src_ori,
decode(e.CNCPT_CONCAT,e.cncpt_concat_nm, null, e.cncpt_concat)  cncpt_concat, e.CNCPT_CONCAT_NM, e.CNCPT_CONCAT_DEF, syn.nm_desc SYN
from admin_item ai, nci_admin_item_Ext e,(select item_id, ver_nr, substr( LISTAGG(a.nm_desc, ' | ') WITHIN GROUP (ORDER by a.ITEM_ID),1,8000) nm_desc
from alt_nms a group by item_id, ver_nr) syn
where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr
and ai.item_id = syn.item_id (+) and ai.ver_nr = syn.ver_nr (+)
and ai.admin_item_typ_id in (53)
	  union
	  select ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.ITEM_LONG_NM, ai.ITEM_NM, '' CHNG_DESC_TXT, 
  'Concept' ADMIN_ITEM_TYP_ID ,ai.CURRNT_VER_IND,
 ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, 
 ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.EVS_SRC_ORI evs_src_ori,
ai.ITEM_LONG_NM cncpt_concat, ai.item_nm CNCPT_CONCAT_NM, ai.item_desc CNCPT_CONCAT_DEF, ai.syn
from vw_cncpt ai
union
	    select 0,1, 'No NCIt Concept Associated',  'NA', 'No NCIt Concept Associated', '',
'Concept' ,1, 
sysdate, 'ONEDATA', 'ONEDATA', 0,sysdate, sysdate ,sysdate,
 'NA', 'NA', 'Application', 'NA',
'NA'  , 'NA', 'NA' , 'NA' from dual;


create or replace TRIGGER TR_MEC_MAP_UPD  BEFORE UPDATE ON NCI_MEC_MAP for each row
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

if ((:old.tgt_mec_id is null or :old.src_mec_id is null) and :new.tgt_mec_id is not null and :new.src_mec_id is not null and :new.map_deg in ( 129, 130)) then
:new.map_deg := 120;
end if;
end;
/

create or replace TRIGGER TR_ALT_NMS_POST_ORI
  BEFORE INSERT
  on ALT_NMS
  for each row
BEGIN
if (:new.ORI_VER_CREAT_USR_ID is null) then
    :new.ORI_VER_CREAT_USR_ID := :new.CREAT_USR_ID;
    :new.ORI_VER_CREAT_DT := :new.CREAT_DT;
    
end if;
END;
/

create or replace TRIGGER TR_ALT_DEF_POST_ORI
  BEFORE INSERT
  on ALT_DEF
  for each row
BEGIN
if (:new.ORI_VER_CREAT_USR_ID is null) then
    :new.ORI_VER_CREAT_USR_ID := :new.CREAT_USR_ID;
    :new.ORI_VER_CREAT_DT := :new.CREAT_DT;
    
end if;
END;
/

create or replace TRIGGER TR_REF_POST_ORI
  BEFORE INSERT
  on REF
  for each row
BEGIN
if (:new.ORI_VER_CREAT_USR_ID is null) then
    :new.ORI_VER_CREAT_USR_ID := :new.CREAT_USR_ID;
    :new.ORI_VER_CREAT_DT := :new.CREAT_DT;
    
end if;
END;
/

create or replace TRIGGER TR_NCI_AI_REL_POST_ORI
  BEFORE INSERT
  on NCI_ADMIN_ITEM_REL
  for each row
BEGIN
if (:new.ORI_VER_CREAT_USR_ID is null) then
    :new.ORI_VER_CREAT_USR_ID := :new.CREAT_USR_ID;
    :new.ORI_VER_CREAT_DT := :new.CREAT_DT;
    
end if;
END;
/
