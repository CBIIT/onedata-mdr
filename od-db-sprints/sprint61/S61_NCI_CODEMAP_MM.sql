create or replace PACKAGE            nci_codemap_mm AS
procedure   getStdMMComment(row in out t_row,row_ori in t_row);
  procedure spGeneratePcode ( v_data_in in clob, v_data_out out clob);
procedure spCopyMM ( v_src_mm_id in number, v_src_mm_ver_nr in number, v_tgt_mm_id in number, v_tgt_mm_ver_nr in number,v_user_id in varchar2, v_chk_ind in integer);
  procedure spCopyVM ( v_src_mm_id in number, v_src_mm_ver_nr in number, v_tgt_mm_id in number, v_tgt_mm_ver_nr in number,v_user_id in varchar2, v_chk_ind in integer);

  procedure spGenerateMapIncrement ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spAddManualMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 
  procedure spCopyModelMapping ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCreateMapGroup ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);

  procedure spValidateModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 
 procedure spUpdateModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
   procedure spValDeriveModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure dervTgtMEC( v_data_in in clob, v_data_out out clob); 
 
 procedure spDeleteModelMap( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spDeleteModelMapRule( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2);
 
 procedure spPostHookUpdMM( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 
END;
/
create or replace PACKAGE BODY            nci_codemap_mm AS
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
--v_reg_str varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}';
--  v_reg_str_adv varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}|\s';
  v_reg_str_adv varchar2(255) := '[^A-Za-z0-9]';
v_reg_str varchar2(255) := '[^ A-Za-z0-9]';

procedure spCopyMM ( v_src_mm_id in number, v_src_mm_ver_nr in number, v_tgt_mm_id in number, v_tgt_mm_ver_nr in number, v_user_id in varchar2,v_chk_ind in integer)
as
i integer;
begin
if (v_chk_ind = 0) then -- no check
insert into nci_mec_Map (SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, TRNS_DESC_TXT, 
FLD_DELETE, SRC_MDL_ITEM_ID, SRC_MDL_VER_NR, TGT_MDL_ITEM_ID, TGT_MDL_VER_NR, MEC_MAP_NM, MAP_DEG, MEC_MAP_DESC, DIRECT_TYP, TRANS_RUL_NOT,
VALID_PLTFORM, PROV_ORG_ID, MEC_GRP_RUL_NBR, MEC_GRP_RUL_DESC, SRC_VAL, TGT_VAL, CRDNLITY_ID, MEC_MAP_NOTES, MEC_SUB_GRP_NBR, PROV_CNTCT_ID, 
PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, VAL_MAP_CREATE_IND, SRC_FUNC_ID, TGT_FUNC_ID, TGT_FUNC_PARAM, OP_ID, IMP_OP_NM, 
TGT_MEC_ID_DERV, RIGHT_OP, LEFT_OP, FLOW_CNTRL, OP_TYP, PAREN, CMNTS_DESC_TXT, PCODE_SYSGEN, MEC_MAP_NM_GEN,CREAT_USR_ID, LST_UPD_USR_ID)
select SRC_MEC_ID, TGT_MEC_ID, v_tgt_mm_id, v_tgt_mm_ver_nr, TRNS_DESC_TXT, 
FLD_DELETE, SRC_MDL_ITEM_ID, SRC_MDL_VER_NR, TGT_MDL_ITEM_ID, TGT_MDL_VER_NR, MEC_MAP_NM, MAP_DEG, MEC_MAP_DESC, DIRECT_TYP, TRANS_RUL_NOT, 
VALID_PLTFORM, PROV_ORG_ID, MEC_GRP_RUL_NBR, MEC_GRP_RUL_DESC, SRC_VAL, TGT_VAL, CRDNLITY_ID, MEC_MAP_NOTES, MEC_SUB_GRP_NBR, PROV_CNTCT_ID,
PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, VAL_MAP_CREATE_IND, SRC_FUNC_ID, TGT_FUNC_ID, TGT_FUNC_PARAM, OP_ID, IMP_OP_NM,
TGT_MEC_ID_DERV, RIGHT_OP, LEFT_OP, FLOW_CNTRL, OP_TYP, PAREN, CMNTS_DESC_TXT, PCODE_SYSGEN, MEC_MAP_NM_GEN, v_user_id, v_user_id
from nci_mec_map where mdl_map_item_id = v_src_mm_id and mdl_map_ver_nr = v_src_mm_ver_nr;
commit;

insert into onedata_Ra.nci_mec_map (MECM_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR,SRC_MEC_ID,
TGT_MEC_ID) 
select MECM_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR,SRC_MEC_ID,
TGT_MEC_ID from nci_mec_map where  mdl_map_item_id = v_tgt_mm_id and mdl_map_ver_nr = v_tgt_mm_ver_nr;
commit;
end if;


end;
  procedure spCopyVM ( v_src_mm_id in number, v_src_mm_ver_nr in number, v_tgt_mm_id in number, v_tgt_mm_ver_nr in number, v_user_id in varchar2,v_chk_ind in integer)
  as
i integer;
begin
if (v_chk_ind = 0) then -- no check
insert into nci_mec_val_Map (SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, 
SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
PROV_ORG_ID, PROV_CNTCT_ID, PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, SRC_LBL, TGT_LBL, PROV_NOTES, MAP_DEG,CREAT_USR_ID, LST_UPD_USR_ID)
select SRC_MEC_ID, TGT_MEC_ID, v_tgt_mm_id, v_tgt_mm_ver_nr, 
SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
PROV_ORG_ID, PROV_CNTCT_ID, PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, SRC_LBL, TGT_LBL, PROV_NOTES, MAP_DEg, v_user_id, v_user_id
from nci_mec_val_map where mdl_map_item_id = v_src_mm_id and mdl_map_ver_nr = v_src_mm_ver_nr;
commit;

insert into onedata_Ra.nci_mec_val_map (MECVM_ID,
SRC_MEC_ID,
TGT_MEC_ID,
MDL_MAP_ITEM_ID,
MDL_MAP_VER_NR) select MECVM_ID,
SRC_MEC_ID,
TGT_MEC_ID,
MDL_MAP_ITEM_ID,
MDL_MAP_VER_NR from onedata_wa.nci_mec_val_map where  mdl_map_item_id = v_tgt_mm_id and mdl_map_ver_nr = v_tgt_mm_ver_nr;
commit;
end if;
end;
  

-- Selected from Model Map AI level
procedure spDeleteModelMap  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    v_temp integer;
     row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 v_item_id number;
 v_ver_nr number(4,2);
  showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
 
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
  v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
 
 -- verify that this is either the only version or is not a current version
 
 
  if (hookinput.invocationnumber = 0) then 
        if (ihook.getColumnValue(row_Ori, 'CURRNT_VER_IND')=0) then
        for cur in (Select count(*) from admin_item where item_id= v_item_id group by item_id having count(*) > 1) loop
            hookoutput.message := 'Model mapping cannot be deleted as it is the latest version. Use ''Select Latest Version'' to change latest version first.';
            V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
            return;
        end loop;
        end if;
  
        hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'Please confirm deletion option: ' || ihook.getColumnValue (row_ori,'ITEM_NM') || ' (' ||v_item_id || 'v' || v_ver_nr || ')');
        rows := t_rows();        row := t_row();
        
        ihook.setColumnValue(row,'Option','Purge Model Mapping, All Rules and ALl Value Mappings');
        ihook.setColumnValue(row,'ID',1);
        rows.extend; rows(rows.last) := row;
        
        row := t_row();
        ihook.setColumnValue(row,'Option','Purge All Rules and All Value Mappings');
        ihook.setColumnValue(row,'ID',2);
        rows.extend; rows(rows.last) := row;
    
        row := t_row();
        ihook.setColumnValue(row,'Option','Purge All Value Mappings');
        ihook.setColumnValue(row,'ID',3);
        rows.extend; rows(rows.last) := row;
 
        showRowset := t_showableRowset(rows, 'Delete Option',4, 'single');
        hookOutput.showRowset := showRowset;
 end if; -- invocation number is 0

 if (hookinput.invocationnumber = 1 and hookinput.selectedRowset.rowset.count > 0) then -- only if an option is selected
     row_sel := hookinput.selectedRowset.rowset(1);
     v_temp := ihook.getColumnValue(row_sel,'ID');
     
     -- Delete value mapping in all cases
    delete from nci_mec_val_map where  mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr;
    delete from onedata_ra.nci_mec_val_map where  mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr;

-- Delete rules
    if (v_temp <3) then
        delete from nci_mec_map where  mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr;
        delete from onedata_ra.nci_mec_map where  mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr;
    end if;

-- Delete Model Mapping AI
    if (v_temp <2) then
        delete from nci_mdl_map where  item_id = v_item_id and ver_nr = v_ver_nr;
        delete from onedata_ra.nci_mdl_map where  item_id = v_item_id and ver_nr = v_ver_nr;

        delete from admin_item where  item_id = v_item_id and ver_nr = v_ver_nr;
        delete from onedata_ra.admin_item where  item_id = v_item_id and ver_nr = v_ver_nr;
    end if;
    commit;

    hookoutput.message :=  'Model Mapping option selected deleted successfully: ' || v_item_id || 'v'|| v_ver_Nr;
end if;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;



 procedure spPostHookUpdMM( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
 as 
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    v_item_id number;
    v_ver_nr number(4,2);
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   if ( ihook.getColumnValue(row_ori, 'MAP_DEG')  in (86,87) and ihook.getColumnValue(row_ori, 'MAP_DEG') <> ihook.getColumnOldValue(row_ori, 'MAP_DEG') ) then
      raise_application_error(-20000, 'Mapping type cannot be manually set to Semantically Equiv/Simiar .');
    return;
    end if;
    
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;
 
-- From Model Map Import
   procedure spUpdateModelMap( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowsadd  t_rows;
  rowsupd  t_rows;
  rows t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
  v_add boolean;
  v_temp integer;
  i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  rowsadd := t_rows();
  rowsupd := t_rows();
  rows := t_rows();
  
  for i in 1..hookinput.originalRowset.rowset.count loop
  row_ori :=  hookInput.originalRowset.rowset(i);
  
    if ( nvl(ihook.getColumnValue(row_ori, 'CTL_VAL_STUS'),'IMPORTED') = 'VALIDATED') then
  
        ihook.setcolumnValue(row_ori, 'MECM_ID', nvl(ihook.getColumnValue(row_ori,'IMP_RULE_ID'),ihook.getColumnValue(row_ori,'STG_MECM_ID')));
        Select count(*) into v_temp  from nci_mec_map where mecm_id = ihook.getcolumnValue(row_ori,'MECM_ID');
 
        for cur in (Select * from nci_mdl_elmnt_char where mec_id = nvl(ihook.getColumnValue(row_ori,'SRC_MEC_ID'),0)) loop
          ihook.setColumnValue(row_ori,'SRC_CDE_ITEM_ID', cur.CDE_ITEM_ID);
                 ihook.setColumnValue(row_ori,'SRC_CDE_VER_NR', cur.CDE_VER_NR);
    
        end loop;
           for cur in (Select * from nci_mdl_elmnt_char where mec_id = nvl(ihook.getColumnValue(row_ori,'TGT_MEC_ID'),0)) loop
          ihook.setColumnValue(row_ori,'TGT_CDE_ITEM_ID', cur.CDE_ITEM_ID);
                 ihook.setColumnValue(row_ori,'TGT_CDE_VER_NR', cur.CDE_VER_NR);
    
        end loop;
        if (v_temp= 0) then
            rowsadd.extend;   rowsadd(rowsadd.last) := row_ori;
 --   raise_application_error(-20000,' Add');
        else
        rowsupd.extend;   rowsupd(rowsupd.last) := row_ori;
    end if;
 
    ihook.setColumnValue(row_ori,'CTL_VAL_STUS','UPDATED');
     rows.extend;   rows(rows.last) := row_ori;
 
    end if; 
 end loop;
 
  if (rowsadd.count>0) then
   action := t_actionrowset(rowsadd, 'Model Map - Characteristics (Hook)', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;
    end if;
    
 if (rowsupd.count>0) then
   action := t_actionrowset(rowsupd, 'Model Map - Characteristics (Hook)', 2,1,'update');
        actions.extend;
        actions(actions.last) := action;
    end if;
  
  if (rows.count>0) then
   action := t_actionrowset(rows, 'Model Map Import', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    end if;
    
 hookoutput.message:= 'New mapping inserted: ' || rowsadd.count || ' Mapping updated: ' || rowsupd.count;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);
end;


   procedure spValidateModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
  v_valid boolean;
  v_val_stus_msg varchar2(2000);
 i integer;
 v_typ integer;
 v_dflt_typ integer;
 v_temp integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  rows := t_rows();

  for i in 1..hookinput.originalRowset.rowset.count loop
  row_ori :=  hookInput.originalRowset.rowset(i);
  v_valid := true;
  v_val_stus_msg := '';
  
 if ( nvl(ihook.getColumnValue(row_ori, 'CTL_VAL_STUS'),'IMPORTED') in ( 'IMPORTED','ERROR','VALIDATED')) then
  
  
  
  -- check if invalid Mapping degree/Mapping Type
  
 -- Derive Mapping cardinality
 -- for cur in (select * from obj_key where obj_typ_id = 47  and upper(obj_key_desc) = nvl(upper(ihook.getColumnValue(row_ori, 'IMP_CRDNLITY')),'XX')) loop
 --   ihook.setColumnValue(row_ori, 'CRDNLITY_ID', cur.obj_key_id);
-- end loop;

-- Validate that the source elemnt/char and target element/char belong to the current source and target model
-- validate that both ME and MEC are specified. May be blank.
if ((ihook.getColumnValue(row_ori, 'SRC_ME_PHY_NM') is null and  ihook.getColumnValue(row_ori, 'SRC_MEC_PHY_NM') is not null ) or
(ihook.getColumnValue(row_ori, 'SRC_ME_PHY_NM') is not null and  ihook.getColumnValue(row_ori, 'SRC_MEC_PHY_NM') is  null)) then
v_valid := false;
v_val_stus_msg := 'Both Source Element and Characteristics have to be specified; ';
end if;

if (((ihook.getColumnValue(row_ori, 'TGT_ME_PHY_NM') is null and  ihook.getColumnValue(row_ori, 'TGT_MEC_PHY_NM') is not null ) or
(ihook.getColumnValue(row_ori, 'TGT_ME_PHY_NM') is not null and  ihook.getColumnValue(row_ori, 'TGT_MEC_PHY_NM') is  null)) and v_valid= true) then
v_valid := false;
v_val_stus_msg := 'Both Target Element and Characteristics have to be specified; ';
end if;

if ( ihook.getColumnValue(row_ori, 'SRC_ME_PHY_NM') is not null and  ihook.getColumnValue(row_ori, 'SRC_MEC_PHY_NM') is not null) then 
ihook.setColumnValue(row_ori, 'SRC_MEC_ID','');
   for cur in (
    select mec.mec_id from  nci_mdl_elmnt me, nci_mdl_elmnt_char mec, nci_mdl_map mm where me.MDL_ITEM_ID = mm.src_mdl_item_id 
    and me.MDL_ITEM_VER_NR = mm.src_mdl_ver_Nr
    and mm.item_id  = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and mm.ver_nr = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and  me.ITEM_PHY_OBJ_NM =ihook.getColumnValue(row_ori, 'SRC_ME_PHY_NM')
    and MEC.MEC_PHY_NM=ihook.getColumnValue(row_ori, 'SRC_MEC_PHY_NM') and me.ITEM_ID = mec.MDL_ELMNT_ITEM_ID and me.ver_nr = mec.MDL_ELMNT_VER_NR) loop
      ihook.setColumnValue(row_ori, 'SRC_MEC_ID', cur.mec_id);
    end loop;
    if (ihook.getColumnValue(row_ori, 'SRC_MEC_ID') is null) then 
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg || 'Invalid Source Characteristics; '|| chr(13);
    end if;
end if;    

if ( ihook.getColumnValue(row_ori, 'TGT_ME_PHY_NM') is not null and  ihook.getColumnValue(row_ori, 'TGT_MEC_PHY_NM') is not null) then 
    for cur in (
    select mec.mec_id from  nci_mdl_elmnt me, nci_mdl_elmnt_char mec, nci_mdl_map mm where me.MDL_ITEM_ID = mm.tgt_mdl_item_id 
    and me.MDL_ITEM_VER_NR = mm.tgt_mdl_ver_Nr
    and mm.item_id  = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and mm.ver_nr = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and  me.ITEM_PHY_OBJ_NM =ihook.getColumnValue(row_ori, 'TGT_ME_PHY_NM')
    and MEC.MEC_PHY_NM=ihook.getColumnValue(row_ori, 'TGT_MEC_PHY_NM') and me.ITEM_ID = mec.MDL_ELMNT_ITEM_ID and me.ver_nr = mec.MDL_ELMNT_VER_NR) loop
      ihook.setColumnValue(row_ori, 'TGT_MEC_ID', cur.mec_id);
    end loop;
    if (ihook.getColumnValue(row_ori, 'TGT_MEC_ID') is null) then 
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg || 'Invalid Target Characteristics; '|| chr(13);
    end if;
end if;    

if (ihook.getColumnValue(row_ori, 'IMP_MAP_DEG') is not null and  ihook.getColumnValue(row_ori, 'MAP_DEG') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Mapping Type is incorrect; '|| chr(13);
else -- validate to make sure mapping type is not Semantically Equiv or Semantically Similar
for cur in (select * from nci_mec_map where mecm_id = ihook.getColumnValue(row_ori, 'MECM_ID') and 
ihook.getColumnValue(row_ori, 'MAP_DEG') <> map_deg and ihook.getColumnValue(row_ori, 'MAP_DEG')  in (86,87)) loop
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Cannot change the mapping type to Semntically Similar/Equivalent.'|| chr(13);
end loop;
end if;

if (ihook.getColumnValue(row_ori, 'IMP_CRDNLITY') is not null and  ihook.getColumnValue(row_ori, 'CRDNLITY_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Cardinaliy is incorrect; '|| chr(13);
end if;


if (ihook.getColumnValue(row_ori, 'IMP_SRC_FUNC') is not null and  ihook.getColumnValue(row_ori, 'SRC_FUNC_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Source Function is incorrect; '|| chr(13);
end if;

if (ihook.getColumnValue(row_ori, 'IMP_TGT_FUNC') is not null and  ihook.getColumnValue(row_ori, 'TGT_FUNC_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Target Function is incorrect; '|| chr(13);
end if;
 
if (ihook.getColumnValue(row_ori, 'IMP_TRANS_RUL_NOT') is not null and  ihook.getColumnValue(row_ori, 'TRANS_RUL_NOT') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Transformation Notation Type is incorrect; '|| chr(13);
end if;
 
if (ihook.getColumnValue(row_ori, 'IMP_OP_TYP') is not null and  ihook.getColumnValue(row_ori, 'OP_TYP') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Comparator is incorrect; '|| chr(13);
end if;
 
 
if (ihook.getColumnValue(row_ori, 'IMP_FLOW_CNTRL') is not null and  ihook.getColumnValue(row_ori, 'FLOW_CNTRL') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Condition is incorrect; '|| chr(13);
end if;
 
 
 
if (ihook.getColumnValue(row_ori, 'IMP_PAREN') is not null and  ihook.getColumnValue(row_ori, 'PAREN') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Parenthesis is incorrect; '|| chr(13);
end if;
 
 
if (ihook.getColumnValue(row_ori, 'IMP_PROV_ORG') is not null and  ihook.getColumnValue(row_ori, 'PROV_ORG_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Provenance Organization is incorrect; '|| chr(13);
end if;


 
if (ihook.getColumnValue(row_ori, 'IMP_PROV_CNTCT') is not null and  ihook.getColumnValue(row_ori, 'PROV_CNTCT_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Provenance Contact is incorrect; '|| chr(13);
end if;
 	
    
for cur in (select * from nci_mdl_map mm where mm.item_id  = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and mm.ver_nr = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR')) loop
    ihook.setColumnValue(row_ori, 'SRC_MDL_ITEM_ID', cur.SRC_MDL_ITEM_ID);
    ihook.setColumnValue(row_ori, 'TGT_MDL_ITEM_ID', cur.TGT_MDL_ITEM_ID);
    ihook.setColumnValue(row_ori, 'SRC_MDL_VER_NR', cur.SRC_MDL_VER_NR);
    ihook.setColumnValue(row_ori, 'TGT_MDL_VER_NR', cur.TGT_MDL_VER_NR);
    
    end loop;

-- Rules id provided is incorrect.
 
if (ihook.getColumnValue(row_ori, 'IMP_RULE_ID') is not null) then
    select count(*) into v_temp from NCI_MEC_MAP where  MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and MECM_ID=ihook.getColumnValue(row_ori, 'IMP_RULE_ID') and nvl(fld_Delete,0) = 0;
    if (v_temp = 0) then
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'Imported Rule ID is incorrect or does not exist; '|| chr(13);

    end if;    
end if;
 
 -- duplicae based on src/tgt/op/src func/tgt func/condition/operator
 if (v_valid = true) then -- check for duplicate
    for cur in (select * from nci_mec_map where mdl_map_item_id = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and mdl_map_ver_nr =  ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and nvl(src_mec_id,0) = nvl( ihook.getColumnValue(row_ori, 'SRC_MEC_ID'),0)
    and nvl(tgt_mec_id,0) = nvl( ihook.getColumnValue(row_ori, 'TGT_MEC_ID'),0)
    and nvl(OP_id,0) = nvl( ihook.getColumnValue(row_ori, 'OP_ID'),0)
     and nvl(PAREN,0) = nvl( ihook.getColumnValue(row_ori, 'PAREN'),0)
      and nvl(MEC_SUB_GRP_NBR,0) = nvl( ihook.getColumnValue(row_ori, 'MEC_SUB_GRP_NBR'),0)
     and nvl(MEC_MAP_NM,0) = nvl( ihook.getColumnValue(row_ori, 'MEC_MAP_NM'),0)
   and nvl(TGT_FUNC_id,0) = nvl( ihook.getColumnValue(row_ori, 'TGT_FUNC_ID'),0)
    and nvl(FLOW_CNTRL,0) = nvl( ihook.getColumnValue(row_ori, 'FLOW_CNTRL'),0)
    and  ihook.getColumnValue(row_ori, 'IMP_RULE_ID') is null) loop
       v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'Duplicate found with Rule ID: '|| cur.MECM_ID ||  chr(13);
   end loop;
 end if;
 
 

  if (v_valid = false) then 
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','ERROR');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',v_val_stus_msg);
  else
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','VALIDATED');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','Valid');
  end if;
     rows.extend;   rows(rows.last) := row_ori;
 end if;
 end loop;
 
   action := t_actionrowset(rows, 'Model Map Import', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
        
       hookoutput.actions := actions;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  -- nci_util.debugHook('GENERAL',v_data_out);
end;


   procedure spValDeriveModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    v_id integer;
    action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 v_item_id number;
 v_ver_nr number(4,2);
  v_valid boolean;
  v_val_stus_msg varchar2(2000);
 i integer;
 
 v_temp integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_valid := true;
  v_val_stus_msg := '';
  v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
  v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
  /*
  *..*	Many-To-Many
TBD 0..1	Zero-To-One. Used to show the default value of a target model characteristic.
1..0	One-To-Zero. Used to indicate that the source characteristic has no mapping in the target model, or must be ignored.
0..*	Zero-To-Many
1..1	One-To-One = 121
*..1	Many-To-One = 119
1..*	One-To-Many = 118
*/
  
 
  -- Derive Mapping cardinality
  
  update nci_mec_map set  CRDNLITY_ID = null where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr;
  commit;
  
 
  
  -- 1..0
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '1..0';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and 	SRC_MEC_ID is  not null and 
  TGT_MEC_ID is null and SRC_FUNC_ID is null and 	SRC_VAL is  null and 
  CRDNLITY_ID is null and upper(mec_map_nm) like '%IGNORE%';
  commit;
  
  -- 1..1
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '1..1';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and CRDNLITY_ID is null and ( MEC_MAP_NM) in
  (select  MEC_MAP_NM from nci_mec_map where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and 	SRC_MEC_ID is  not null and 
  TGT_MEC_ID is not null  and nvl(fld_Delete,0) = 0
  group by MEC_MAP_NM having count(*) =1)
;
  
  commit;
  
 -- 0..* 
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '0..*';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and 
  CRDNLITY_ID is null and ( MEC_MAP_NM) in
  (select  MEC_MAP_NM from nci_mec_map where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr  and nvl(fld_Delete,0) = 0 
  group by MEC_MAP_NM having count(distinct src_mec_id) =0 and count(distinct tgt_mec_id) > 0);
  commit;
  
  -- 1..*
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '1..*';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and CRDNLITY_ID is null  and ( MEC_MAP_NM) in (
  select MEC_MAP_NM from nci_mec_map where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr 
  --and 	SRC_MEC_ID is  not null and 
 -- TGT_MEC_ID is not null  
 and nvl(fld_Delete,0) = 0
  group by MEC_MAP_NM having count(distinct src_mec_id) =1 and count(distinct tgt_mec_id) > 1);
  
  commit;
  
  -- *..1
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '*..1';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and 	CRDNLITY_ID is null  and (MEC_MAP_NM) in (
  select MEC_MAP_NM from nci_mec_map where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr 
  --and 	SRC_MEC_ID is  not null and 
  --TGT_MEC_ID is not null  
  and nvl(fld_Delete,0) = 0
  group by MEC_MAP_NM having count(distinct src_mec_id) >1 and count(distinct tgt_mec_id) = 1);
  
  commit;
  
  -- *..1
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '*..*';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and 	 CRDNLITY_ID is null and 
   ( MEC_MAP_NM) in (
  select MEC_MAP_NM from nci_mec_map where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr 
  --and 	SRC_MEC_ID is  not null and 
  --TGT_MEC_ID is not null  
  and nvl(fld_Delete,0) = 0
  group by MEC_MAP_NM having count(distinct src_mec_id) >1 and count(distinct tgt_mec_id) > 1);
  
  commit;


hookoutput.message := 'Derivation of Cardinality completed.'; 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  -- nci_util.debugHook('GENERAL',v_data_out);
end;

 procedure spCreateMapGroup ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
 i integer;
 v_max integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
  row_ori :=  hookInput.originalRowset.rowset(1);
  
 select max(nvl(MEC_GRP_RUL_NBR,0))+1  into v_max from nci_mec_map where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') and MDL_MAP_VER_NR= ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR');
 
 for i in 1..hookinput.originalrowset.rowset.count loop 
  row_ori :=  hookInput.originalRowset.rowset(i);
  update nci_mec_map set MEC_GRP_RUL_NBR= v_max, DIRECT_TYP=119 where MECM_ID = ihook.getColumnValue(row_ori,'MECM_ID');
 end loop;
 commit;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  -- nci_util.debugHook('GENERAL',v_data_out);
end;

   procedure spCopyModelMapping ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
   v_item_id number;
   v_ver_nr number(4,2);
   v_src_mdl_id number;
   v_src_mdl_ver_nr number(4,2);
    v_to_src_ver_nr number(4,2);

   v_tgt_mdl_id number;
   v_tgt_mdl_ver_nr number(4,2);
   v_to_tgt_ver_nr number(4,2);
 
  rowset            t_rowset;
  actions t_actions := t_actions();
  action t_actionRowset;

 question    t_question;
answer     t_answer;
answers     t_answers;
  v_mdl_hdr_id number;
 i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
   v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
   v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
   for cur in (Select * from nci_mdl_map where item_id= v_item_id and ver_nr = v_ver_nr) loop
   v_src_mdl_id := cur.src_mdl_item_id;
   v_src_mdl_ver_nr :=cur.src_mdl_ver_nr;
   v_tgt_mdl_id := cur.tgt_mdl_item_id;
   v_tgt_mdl_ver_nr :=cur.tgt_mdl_ver_nr;
   
   end loop;
   if (hookinput.invocationnumber = 0) then -- first invocation
   
   row := t_row();
 /*  ihook.setColumnValue(row,'Version Selection','From');
     ihook.setColumnValue(row,'Model Name',cur.item_nm);
  ihook.setColumnValue(row,'Version',cur.ver_nr);
   ihook.setColumnValue(row,'Current Mapping',cur.curr_ind);  
    ihook.setColumnValue(row,'Model Id',cur.item_id);*/
    ihook.setColumnValue(row,'ITEM_ID', v_src_mdl_id);
   rows.extend;
		   rows (rows.last) := row;
   --end loop;
 	 showrowset := t_showablerowset (rows, 'Model AI', 2, 'single');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Next');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select Source Version. Current Version is: ' || v_src_mdl_ver_nr, answers);
       	 hookOutput.question := question;
end if;
  if (hookinput.invocationnumber = 1) then -- second invocation choose target version
  /*  for cur in (select ai.item_nm, ai.ver_nr, ai.item_id, decode(mm.tgt_mdl_ver_nr, ai.ver_nr, 'Current','') Curr_ind 
    from nci_mdl_map mm, admin_item ai where mm.item_id = v_item_id and mm.ver_nr = v_ver_nr
   and mm.tgt_mdl_item_id = ai.item_id ) loop*/
   row := t_row();
   if (hookinput.selectedRowset is not null) then 
        row_sel := hookinput.selectedRowset.rowset(1);
        v_to_src_ver_nr := ihook.getColumnValue(row_sel,'VER_NR');
    else
        v_to_src_ver_nr := v_src_mdl_ver_nr;
    end if;
        
  
 
    ihook.setColumnValue(row,'ITEM_ID', v_tgt_mdl_id);
   rows.extend;
		   rows (rows.last) := row;
   --end loop;
 	 showrowset := t_showablerowset (rows, 'Model AI', 2, 'single');
       	 hookoutput.showrowset := showrowset;


       	 answers := t_answers();
  	   	 answer := t_answer(v_to_src_ver_nr*100, 1, 'Copy Mapping');-- answer id holds the source to version number as there is no way to transfer selections
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select Target Model Version. Current Version is: ' || v_tgt_mdl_ver_nr, answers);
       	 hookOutput.question := question;
end if;
  if (hookinput.invocationnumber = 2) then -- Third invocation create copy
    -- get source and target model version
 if (hookinput.selectedRowset is not null) then 
        row_sel := hookinput.selectedRowset.rowset(1);
        v_to_tgt_ver_nr := ihook.getColumnValue(row_sel,'VER_NR');
    else
        v_to_tgt_ver_nr := v_tgt_mdl_ver_nr;
    end if;
    
    v_to_src_ver_nr := hookinput.answerid/100;-- answer id hols the version number from first iteration
 
  rows := t_rows();
  row := t_row();
  v_id := nci_11179.getItemId;
  nci_11179.spReturnAIRow(v_item_id, v_ver_nr, row);
  
  -- change parameters
  ihook.setColumnValue(row,'ITEM_ID',v_id);
  ihook.setColumnValue(row,'VER_NR',1);
  ihook.setColumnValue(row,'ADMIN_STUS_ID',66);
   ihook.setColumnValue(row,'REGSTR_STUS_ID',9);
   ihook.setColumnValue(row,'ITEM_LONG_NM', nci_11179_2.getStdShortName (v_id,1));
   ihook.setColumnValue(row,'SRC_MDL_VER_NR', v_to_src_ver_nr);
   ihook.setColumnValue(row,'TGT_MDL_VER_NR', v_to_tgt_ver_nr);
    ihook.setColumnValue(row,'SRC_MDL_ITEM_ID', v_src_mdl_id);
   ihook.setColumnValue(row,'TGT_MDL_ITEM_ID', v_tgt_mdl_id);
   
    rows.extend; rows(rows.last) := row;
    action := t_actionRowset(rows, 'Administered Item (No Sequence)',2, 10, 'insert');
    actions.extend; actions(actions.last) := action;

    action := t_actionRowset(rows, 'NCI_MDL_MAP', 11, 'insert');
    actions.extend; actions(actions.last) := action;
    hookoutput.actions := actions;
    hookoutput.message := 'Model Mapping created successfully. Please run Generate Semantic Mapping next.' || v_id;


insert into nci_mec_Map (SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, TRNS_DESC_TXT, 
 SRC_MDL_ITEM_ID, SRC_MDL_VER_NR, TGT_MDL_ITEM_ID, TGT_MDL_VER_NR, MEC_MAP_NM, MAP_DEG, MEC_MAP_DESC, DIRECT_TYP, TRANS_RUL_NOT,
VALID_PLTFORM, PROV_ORG_ID, MEC_GRP_RUL_NBR, MEC_GRP_RUL_DESC, SRC_VAL, TGT_VAL, CRDNLITY_ID, MEC_MAP_NOTES, MEC_SUB_GRP_NBR, PROV_CNTCT_ID, 
PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, VAL_MAP_CREATE_IND, SRC_FUNC_ID, TGT_FUNC_ID, TGT_FUNC_PARAM, OP_ID, IMP_OP_NM, 
TGT_MEC_ID_DERV, RIGHT_OP, LEFT_OP, FLOW_CNTRL, OP_TYP, PAREN, CMNTS_DESC_TXT, PCODE_SYSGEN, MEC_MAP_NM_GEN,CREAT_USR_ID, LST_UPD_USR_ID)
select nsmec.MEC_ID, ntmec.MEC_ID, v_id, 1, TRNS_DESC_TXT, 
 v_src_mdl_id, v_to_src_ver_nr, v_tgt_mdl_id, v_to_tgt_Ver_Nr, MEC_MAP_NM, MAP_DEG, MEC_MAP_DESC, DIRECT_TYP, TRANS_RUL_NOT, 
VALID_PLTFORM, PROV_ORG_ID, MEC_GRP_RUL_NBR, MEC_GRP_RUL_DESC, SRC_VAL, TGT_VAL, CRDNLITY_ID, MEC_MAP_NOTES, MEC_SUB_GRP_NBR, PROV_CNTCT_ID,
PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, VAL_MAP_CREATE_IND, SRC_FUNC_ID, TGT_FUNC_ID, TGT_FUNC_PARAM, OP_ID, IMP_OP_NM,
TGT_MEC_ID_DERV, RIGHT_OP, LEFT_OP, FLOW_CNTRL, OP_TYP, PAREN, CMNTS_DESC_TXT, PCODE_SYSGEN, MEC_MAP_NM_GEN, v_user_id, v_user_id
from nci_mec_map m, 	VW_NCI_MEC smec, 	VW_NCI_MEC tmec, 	VW_NCI_MEC nsmec, 	VW_NCI_MEC ntmec  where nvl(m.fld_delete,0) = 0 and m.mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr
and m.src_mec_id = smec.mec_id and m.tgt_mec_id = tmec.mec_id and smec.ME_PHY_NM = nsmec.ME_PHY_NM and smec.MEC_PHY_NM=nsmec.MEC_PHY_NM
and tmec.ME_PHY_NM = ntmec.ME_PHY_NM and tmec.MEC_PHY_NM=ntmec.MEC_PHY_NM and nsmec.MDL_ITEM_ID= v_src_mdl_id and nsmec.MDL_VER_NR = v_to_src_ver_nr
and  ntmec.MDL_ITEM_ID= v_tgt_mdl_id and ntmec.MDL_VER_NR = v_to_tgt_ver_nr and m.src_mec_id is not null and m.tgt_mec_id is not null;
commit;
insert into nci_mec_Map (SRC_MEC_ID,  MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, TRNS_DESC_TXT, 
 SRC_MDL_ITEM_ID, SRC_MDL_VER_NR, TGT_MDL_ITEM_ID, TGT_MDL_VER_NR, MEC_MAP_NM, MAP_DEG, MEC_MAP_DESC, DIRECT_TYP, TRANS_RUL_NOT,
VALID_PLTFORM, PROV_ORG_ID, MEC_GRP_RUL_NBR, MEC_GRP_RUL_DESC, SRC_VAL, TGT_VAL, CRDNLITY_ID, MEC_MAP_NOTES, MEC_SUB_GRP_NBR, PROV_CNTCT_ID, 
PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, VAL_MAP_CREATE_IND, SRC_FUNC_ID, TGT_FUNC_ID, TGT_FUNC_PARAM, OP_ID, IMP_OP_NM, 
TGT_MEC_ID_DERV, RIGHT_OP, LEFT_OP, FLOW_CNTRL, OP_TYP, PAREN, CMNTS_DESC_TXT, PCODE_SYSGEN, MEC_MAP_NM_GEN,CREAT_USR_ID, LST_UPD_USR_ID)
select nsmec.MEC_ID,  v_id, 1, TRNS_DESC_TXT, 
 v_src_mdl_id, v_to_src_ver_nr, v_tgt_mdl_id, v_to_tgt_Ver_Nr, MEC_MAP_NM, MAP_DEG, MEC_MAP_DESC, DIRECT_TYP, TRANS_RUL_NOT, 
VALID_PLTFORM, PROV_ORG_ID, MEC_GRP_RUL_NBR, MEC_GRP_RUL_DESC, SRC_VAL, TGT_VAL, CRDNLITY_ID, MEC_MAP_NOTES, MEC_SUB_GRP_NBR, PROV_CNTCT_ID,
PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, VAL_MAP_CREATE_IND, SRC_FUNC_ID, TGT_FUNC_ID, TGT_FUNC_PARAM, OP_ID, IMP_OP_NM,
TGT_MEC_ID_DERV, RIGHT_OP, LEFT_OP, FLOW_CNTRL, OP_TYP, PAREN, CMNTS_DESC_TXT, PCODE_SYSGEN, MEC_MAP_NM_GEN, v_user_id, v_user_id
from nci_mec_map m, 	VW_NCI_MEC smec, 		VW_NCI_MEC nsmec where nvl(m.fld_delete,0) = 0 and m.mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr
and m.src_mec_id = smec.mec_id  and smec.ME_PHY_NM = nsmec.ME_PHY_NM and smec.MEC_PHY_NM=nsmec.MEC_PHY_NM
and nsmec.MDL_ITEM_ID= v_src_mdl_id and nsmec.MDL_VER_NR = v_to_src_ver_nr
 and m.src_mec_id is not null and m.tgt_mec_id is null;
commit;
insert into nci_mec_Map (TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, TRNS_DESC_TXT, 
 SRC_MDL_ITEM_ID, SRC_MDL_VER_NR, TGT_MDL_ITEM_ID, TGT_MDL_VER_NR, MEC_MAP_NM, MAP_DEG, MEC_MAP_DESC, DIRECT_TYP, TRANS_RUL_NOT,
VALID_PLTFORM, PROV_ORG_ID, MEC_GRP_RUL_NBR, MEC_GRP_RUL_DESC, SRC_VAL, TGT_VAL, CRDNLITY_ID, MEC_MAP_NOTES, MEC_SUB_GRP_NBR, PROV_CNTCT_ID, 
PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, VAL_MAP_CREATE_IND, SRC_FUNC_ID, TGT_FUNC_ID, TGT_FUNC_PARAM, OP_ID, IMP_OP_NM, 
TGT_MEC_ID_DERV, RIGHT_OP, LEFT_OP, FLOW_CNTRL, OP_TYP, PAREN, CMNTS_DESC_TXT, PCODE_SYSGEN, MEC_MAP_NM_GEN,CREAT_USR_ID, LST_UPD_USR_ID)
select  ntmec.MEC_ID, v_id, 1, TRNS_DESC_TXT, 
 v_src_mdl_id, v_to_src_ver_nr, v_tgt_mdl_id, v_to_tgt_Ver_Nr, MEC_MAP_NM, MAP_DEG, MEC_MAP_DESC, DIRECT_TYP, TRANS_RUL_NOT, 
VALID_PLTFORM, PROV_ORG_ID, MEC_GRP_RUL_NBR, MEC_GRP_RUL_DESC, SRC_VAL, TGT_VAL, CRDNLITY_ID, MEC_MAP_NOTES, MEC_SUB_GRP_NBR, PROV_CNTCT_ID,
PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, VAL_MAP_CREATE_IND, SRC_FUNC_ID, TGT_FUNC_ID, TGT_FUNC_PARAM, OP_ID, IMP_OP_NM,
TGT_MEC_ID_DERV, RIGHT_OP, LEFT_OP, FLOW_CNTRL, OP_TYP, PAREN, CMNTS_DESC_TXT, PCODE_SYSGEN, MEC_MAP_NM_GEN, v_user_id, v_user_id
from nci_mec_map m, 	 	VW_NCI_MEC tmec, 		VW_NCI_MEC ntmec  where nvl(m.fld_delete,0) = 0 and m.mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr
and m.tgt_mec_id = tmec.mec_id 
and tmec.ME_PHY_NM = ntmec.ME_PHY_NM and tmec.MEC_PHY_NM=ntmec.MEC_PHY_NM 
and  ntmec.MDL_ITEM_ID= v_tgt_mdl_id and ntmec.MDL_VER_NR = v_to_tgt_ver_nr and m.src_mec_id is  null and m.tgt_mec_id is not null;
commit;
insert into onedata_Ra.nci_mec_map (MECM_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR,SRC_MEC_ID,
TGT_MEC_ID) 
select MECM_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR,SRC_MEC_ID,
TGT_MEC_ID from nci_mec_map where  mdl_map_item_id = v_id and mdl_map_ver_nr = 1;
commit;

  end if;
insert into nci_mec_val_Map (SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, 
SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
PROV_ORG_ID, PROV_CNTCT_ID, PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, SRC_LBL, TGT_LBL, PROV_NOTES, MAP_DEG,CREAT_USR_ID, LST_UPD_USR_ID)
select nsmec.mec_id, ntmec.MEC_ID, v_id, 1, 
SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
PROV_ORG_ID, PROV_CNTCT_ID, PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, SRC_LBL, TGT_LBL, PROV_NOTES, MAP_DEg, v_user_id, v_user_id
from nci_mec_val_map m, VW_NCI_MEC smec, 	VW_NCI_MEC nsmec ,VW_NCI_MEC tmec, 	VW_NCI_MEC ntmec 
where nvl(m.fld_delete,0) = 0 and m.mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr and m.src_mec_id = smec.mec_id 
and m.tgt_mec_id = tmec.mec_id and smec.ME_PHY_NM = nsmec.ME_PHY_NM and smec.MEC_PHY_NM=nsmec.MEC_PHY_NM
and tmec.ME_PHY_NM = ntmec.ME_PHY_NM and tmec.MEC_PHY_NM=ntmec.MEC_PHY_NM and nsmec.MDL_ITEM_ID= v_src_mdl_id and nsmec.MDL_VER_NR = v_to_src_ver_nr
and  ntmec.MDL_ITEM_ID= v_tgt_mdl_id and ntmec.MDL_VER_NR = v_to_tgt_ver_nr;
commit;
insert into onedata_Ra.nci_mec_val_map (mecvm_id, SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, 
SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
PROV_ORG_ID, PROV_CNTCT_ID, PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, SRC_LBL, TGT_LBL, PROV_NOTES, MAP_DEG,CREAT_USR_ID, LST_UPD_USR_ID) 
select mecvm_id, SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, 
SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
PROV_ORG_ID, PROV_CNTCT_ID, PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, SRC_LBL, TGT_LBL, PROV_NOTES, MAP_DEG,CREAT_USR_ID, LST_UPD_USR_ID
from nci_mec_val_map where  mdl_map_item_id = v_id and mdl_map_ver_nr = 1;
commit;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--nci_util.debugHook('GENERAL', v_data_out);    
end;

procedure   getStdMMComment(row in out t_row,row_ori in t_row)
as
i integer;
begin

ihook.setColumnValue(row, 'CMNTS_DESC_TXT','New generated mapping created on ' || sysdate||' due to a change in CDE assignment to either the source or target characteristic.');
      ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue (row_ori,'VER_NR'));
      ihook.setColumnValue(row,'MECM_ID',-1);
      
end;
            

procedure spGenerateMapIncrement ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_val_dom_typ integer;
    v_ver_nr number(4,2);
    v_temp integer;
    v_func integer;
    v_hdr_id number;
    v_already integer :=0;
    i integer := 0;
    v_flt_str  varchar2(1000);
    v_sql varchar2(4000);
    v_entty_nm varchar2(255);
    v_entty_nm_like varchar2(255);
    v_cntxt_str varchar2(255);
    v_cnt integer;
    v_str varchar2(255);
    v_minlen integer;
    v_entty_nm_with_space varchar2(255);
    v_nmtyp integer;
    v_nm_desc varchar2(4000);
    v_term_src  varchar2(255);
    v_src_nm_desc varchar2(4000);
    v_equals_func  integer;
    
--    v_reg_str varchar2(255);
 -- v_entty_nm varchar2(4000);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   
--hookoutput.message := 'Work in progress.';
        row_ori := hookInput.originalRowset.rowset(1);
  select obj_key_id into v_func from obj_key where obj_key_desc = 'QUERY' and obj_typ_id = 51;
  select obj_key_id into v_equals_func from obj_key where obj_key_desc = 'EQUALS' and obj_typ_id = 51;
  select obj_key_id into v_nmtyp from obj_key where obj_key_desc = 'Ref Term Short Name' and obj_typ_id = 11;
        -- no deletes
    rows := t_rows();
  
  --update Target Function if semantically similar
  
  rows := t_rows();
  for cur in ( select * from nci_mec_map mm 
  where mm.mdl_map_item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.mdl_map_ver_nr = ihook.getColumnValue (row_ori,'VER_NR') and
  map_Deg = 87 and mm.TGT_FUNC_PARAM like 'XWALK%') loop
  
     for cursrc in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and c.mec_id = cur.src_mec_id) loop

        for curtgt in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and c.mec_id = cur.tgt_mec_id) loop
                    row := t_row();
                ihook.setColumnValue(row,'MECM_ID',cur.mecm_id);

        if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 16 and cur.mec_sub_grp_nbr = 2) then

                -- get ref term name
                select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt CODE|' || v_nm_Desc); 
                                rows.extend;   rows(rows.last) := row;
               
        end if;
        
         -- enum/Enum by Ref
         if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 16) then
                -- get ref term name
                select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt CODE|' || v_nm_Desc); 
                                rows.extend;   rows(rows.last) := row;
            
        end if;
        
           -- Enum by Ref/Enum
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 17) then
            select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_nm_desc || '|NCIt CODE'); 
                                rows.extend;   rows(rows.last) := row;
               
        end if;
        
           -- Enum by Ref/non-enum
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 18) then
            select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc), upper(o.obj_key_Desc)  into v_nm_desc,  v_term_src from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            -- use case 8
                if (v_term_src= 'CODE') then
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_nm_desc || '|TERM'); 
                                rows.extend;   rows(rows.last) := row;
                end if;
                
        
        end if;
        
  
  end loop;
  end loop;
  end loop;

-- delete where NO CDE or NOT MAPPED

    delete from NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR')
     and nvl(MAP_DEG,1)  in (129,130);
    commit;
    delete from onedata_ra.NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR')
     and nvl(MAP_DEG,1) in (129,130);
    commit;
    
-- update CDE ID if changed.
update nci_mec_map m set (src_cde_item_id, src_cde_ver_nr) = (Select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char c where c.mec_id = m.src_mec_id
and m.src_cde_item_id <> c.cde_item_id and m.src_cde_ver_nr <> c.cde_ver_nr )
where 
src_mec_id is not null 
and mdl_map_item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and mdl_map_ver_nr = ihook.getColumnValue (row_ori,'VER_NR')
and (nvl(src_cde_item_id,0), nvl( src_cde_ver_nr,0)) <> (Select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char c1 where c1.mec_id = m.src_mec_id);
commit;

update nci_mec_map m set (tgt_cde_item_id, tgt_cde_ver_nr) = (Select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char c where c.mec_id = m.tgt_mec_id )
where 
tgt_mec_id is not null 
and mdl_map_item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and mdl_map_ver_nr = ihook.getColumnValue (row_ori,'VER_NR')
and (nvl(tgt_cde_item_id,0), nvl( tgt_cde_ver_nr,0)) <> (Select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char c1 where c1.mec_id = m.tgt_mec_id);
commit;

if (rows.count > 0) then
 action := t_actionrowset(rows, 'Model Map - Characteristics', 2,2,'update');
        actions.extend;
        actions(actions.last) := action;
        end if;
        
        rows := t_rows();
    -- Both source and target CDE are present
  
   for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID,
   mec2.MEC_LONG_NM TGT_MEC_LONG_NM, mec2.mec_id TGT_MEC_ID, me1.mdl_item_id src_mdl_item_id,
    me1.mdl_item_ver_nr src_mdl_ver_nr ,me2.mdl_item_id tgt_mdl_item_id, me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM,
    me2.mdl_item_ver_nr tgt_mdl_ver_nr ,me2.ITEM_LONG_NM TGT_ME_ITEM_LONG_NM,
    mec1.CDE_ITEM_ID SRC_CDE_ITEM_ID, mec1.CDE_VER_NR SRC_CDE_VER_NR, mec2.CDE_ITEM_ID TGT_CDE_ITEM_ID, mec2.CDE_VER_NR TGT_CDE_VER_NR
from nci_mdl_elmnt me1, nci_mdl_elmnt me2, nci_mdl_elmnt_char mec1, nci_mdl_elmnt_char mec2, NCI_MDL_MAP mm
where 
--nvl(me1.DOM_ITEM_ID,1) = nvl(me2.DOM_ITEM_ID,1)  and nvl(me1.DOM_VER_NR,1) = nvl(me2.DOM_VER_NR,1)
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR and me2.mdl_item_id = mm.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and mec1.CDE_ITEM_ID = mec2.CDE_ITEM_ID and mec1.CDE_VER_NR = mec2.CDE_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR')
and (mec1.mec_id , mec2.mec_id) not in (select src_mec_id, tgt_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and src_mec_id is not null 
and tgt_mec_id is not null)) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.tgt_mec_id);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MAP_DEG',86);
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
      --  ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.TGT_ME_ITEM_LONG_NM);
          ihook.setColumnValue(row,'SRC_CDE_ITEM_ID',cur.SRC_CDE_ITEM_ID);
        ihook.setColumnValue(row,'SRC_CDE_VER_NR',cur.SRC_CDE_VER_NR);
           ihook.setColumnValue(row,'TGT_CDE_ITEM_ID',cur.TGT_CDE_ITEM_ID);
        ihook.setColumnValue(row,'TGT_CDE_VER_NR',cur.TGT_CDE_VER_NR);
        
        getStdMMComment(row,row_ori);
            
               

                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
 -- Semantically similar
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mec2.MEC_LONG_NM TGT_MEC_LONG_NM, mec2.mec_id TGT_MEC_ID, me1.mdl_item_id src_mdl_item_id,
    me1.mdl_item_ver_nr src_mdl_ver_nr ,me2.mdl_item_id tgt_mdl_item_id, me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM,
    me2.mdl_item_ver_nr tgt_mdl_ver_nr ,me2.ITEM_LONG_NM TGT_ME_ITEM_LONG_NM,
    mec1.CDE_ITEM_ID SRC_CDE_ITEM_ID, mec1.CDE_VER_NR SRC_CDE_VER_NR, mec2.CDE_ITEM_ID TGT_CDE_ITEM_ID, mec2.CDE_VER_NR TGT_CDE_VER_NR

from nci_mdl_elmnt me1, nci_mdl_elmnt me2, nci_mdl_elmnt_char mec1, nci_mdl_elmnt_char mec2, NCI_MDL_MAP mm
where 
--nvl(me1.DOM_ITEM_ID,1) = nvl(me2.DOM_ITEM_ID,1)  and nvl(me1.DOM_VER_NR,1) = nvl(me2.DOM_VER_NR,1)
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR and me2.mdl_item_id = mm.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and mec1.CDE_ITEM_ID != mec2.CDE_ITEM_ID -- and nvl(mec1.CDE_VER_NR,1) != nvl(mec2.CDE_VER_NR,2)
and mec1.DE_CONC_ITEM_ID = mec2.DE_CONC_ITEM_ID and mec1.DE_CONC_VER_NR = mec2.DE_CONC_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR')
and (mec1.mec_id , mec2.mec_id) not in (select src_mec_id, tgt_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and src_mec_id is not null 
and tgt_mec_id is not null)) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.tgt_mec_id);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
       ihook.setColumnValue(row,'MAP_DEG',87);
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
      --  ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.TGT_ME_ITEM_LONG_NM);
          ihook.setColumnValue(row,'SRC_CDE_ITEM_ID',cur.SRC_CDE_ITEM_ID);
        ihook.setColumnValue(row,'SRC_CDE_VER_NR',cur.SRC_CDE_VER_NR);
           ihook.setColumnValue(row,'TGT_CDE_ITEM_ID',cur.TGT_CDE_ITEM_ID);
        ihook.setColumnValue(row,'TGT_CDE_VER_NR',cur.TGT_CDE_VER_NR);
              getStdMMComment(row,row_ori);
  
        --  Enumerated by Reference
        -- Set Target function to xlookup, source and target parameters
        for cursrc in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and c.mec_id = cur.src_mec_id) loop

        for curtgt in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and c.mec_id = cur.tgt_mec_id) loop

        --  src is enum, target is enum
        if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 17) then
             ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|SOURCE PV|TARGET PV'); 
           ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
     end if;
        --enum/non-enum
        if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 18) then
             ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|SOURCE PV|SOURCE LABEL'); 
           ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
     end if;
     -- non-enum/enum then 2 rows - use case 3
     
         if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 17) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
            --    ihook.setColumnValue(row,'TGT_FUNC_PARAM','NCIt|NCIt TERM|NCIt CODE'); 
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt TERM|NCIt CODE'); 
            
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|NCIt CODE|TARGET PV'); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
        -- non-enum/Enum by Ref - use case 4
         if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 16) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                     ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt TERM|NCIt CODE'); 
          -- ihook.setColumnValue(row,'TGT_FUNC_PARAM','NCIt|NCIt TERM|NCIt CODE'); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                -- get ref term name
                select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt CODE|' || v_nm_Desc); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
         -- enum/Enum by Ref
         if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 16) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|SOURCE PV|NCIt CODE'); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                -- get ref term name
                select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt CODE|' || v_nm_Desc); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
           -- Enum by Ref/Enum
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 17) then
            select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_nm_desc || '|NCIt CODE'); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                -- get ref term name
               
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|NCIt CODE|TARGET PV'); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
           -- Enum by Ref/non-enum
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 18) then
            select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc), upper(o.obj_key_Desc)  into v_nm_desc,  v_term_src from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            -- use case 8
                if (v_term_src= 'CODE') then
                    ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_nm_desc || '|TERM'); 
                    ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                end if;
                
                if (v_term_src= 'TERM') then
                    ihook.setColumnValue(row,'TGT_FUNC_ID',v_equals_func);
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','SOURCE'); 
                    ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                end if;
        
        end if;
        
        -- use case 5 - non-enum/non-enum
            if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 18) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_equals_func);
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','SOURCE'); 
                    ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
          end if;
            -- Enum by Ref/Enum by Ref
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 16) then
         select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_src_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
                
            select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_src_nm_desc || '|' || v_nm_desc); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
               
        end if;
        /*
            for curc in (select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) nm_desc from vw_cncpt c, alt_nms a, obj_key o 
            where o.obj_key_id = curvd.term_use_typ and c.item_id = curvd.TERM_CNCPT_ITEM_ID and c.ver_nr = curvd.TERM_CNCPT_VER_NR
            and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp)
             loop
              ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'SRC_VAL',curc.nm_desc);
            end loop;*/
            end loop;
            end loop;
        
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
  
  -- Not mapped
  
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, me1.mdl_item_id src_mdl_item_id,  
    me1.mdl_item_ver_nr src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR,
    mec1.CDE_ITEM_ID SRC_CDE_ITEM_ID, mec1.CDE_VER_NR SRC_CDE_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mec1.cde_item_id is not null
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and nvl(mec1.de_conc_item_id,333) not in (select distinct mec2.de_conc_item_id from 
nci_mdl_elmnt me2,  nci_mdl_elmnt_char mec2,  NCI_MDL_MAP mm2
where me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and me2.mdl_item_id = mm2.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm2.TGT_MDL_VER_NR 
and mm2.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm2.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') and mec2.de_conc_item_id is not null)
and (mec1.mec_id ) not in (select src_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and src_mec_id is not null )
) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
         ihook.setColumnValue(row,'MAP_DEG',130); -- not mapped
          ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
     --    ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.NOTMAPPED' ;
             getStdMMComment(row,row_ori);
               ihook.setColumnValue(row,'SRC_CDE_ITEM_ID',cur.SRC_CDE_ITEM_ID);
        ihook.setColumnValue(row,'SRC_CDE_VER_NR',cur.SRC_CDE_VER_NR);
       
    ihook.setColumnValue(row,'MEC_MAP_NOTES','No Matching Target DEC Found.');
       
        for curvd in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and vd.val_dom_typ_id = 16 and c.mec_id = cur.src_mec_id) loop

            for curc in (select nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc)  nm_desc from vw_cncpt c, alt_nms a, obj_key o 
            where o.obj_key_id = curvd.term_use_typ and c.item_id = curvd.TERM_CNCPT_ITEM_ID and c.ver_nr = curvd.TERM_CNCPT_VER_NR
            and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp)
             loop
              ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'SRC_VAL', curc.nm_desc);
            end loop;
            end loop;
           
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
    
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mm.src_mdl_item_id,  
    mm.src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR,
    mec1.CDE_ITEM_ID TGT_CDE_ITEM_ID, mec1.CDE_VER_NR TGT_CDE_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.TGT_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mec1.cde_item_id is not null
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and nvl(mec1.de_conc_item_id,333) not in (select distinct mec2.de_conc_item_id from 
nci_mdl_elmnt me2,  nci_mdl_elmnt_char mec2,  NCI_MDL_MAP mm2
where me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and me2.mdl_item_id = mm2.SRC_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm2.SRC_MDL_VER_NR 
and mm2.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm2.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') and mec2.de_conc_item_id is not null)
and (mec1.mec_id ) not in (select tgt_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and tgt_mec_id is not null )) loop

        row := t_row();
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MAP_DEG',130); -- not mapped
         ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
               getStdMMComment(row,row_ori);
                ihook.setColumnValue(row,'TGT_CDE_ITEM_ID',cur.TGT_CDE_ITEM_ID);
        ihook.setColumnValue(row,'TGT_CDE_VER_NR',cur.TGT_CDE_VER_NR);
        
      ihook.setColumnValue(row,'MEC_MAP_NOTES','No Matching Source DEC Found.');
        for curvd in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr  and vd.val_dom_typ_id = 16 and c.mec_id = cur.src_mec_id) loop

            for curc in (select nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc)  nm_desc from vw_cncpt c, alt_nms a, obj_key o 
            where o.obj_key_id = curvd.term_use_typ and c.item_id = curvd.TERM_CNCPT_ITEM_ID and c.ver_nr = curvd.TERM_CNCPT_VER_NR
            and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id   (+)= v_nmtyp)
            loop
              ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'TGT_FUNC_PARAM', curc.nm_desc);
              ihook.setColumnValue(row,'TGT_VAL',curc.nm_desc);
            end loop;
            end loop;
        
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;

-- no CDE moved to not mapped


    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, me1.mdl_item_id src_mdl_item_id,  
    me1.mdl_item_ver_nr src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and mec1.cde_item_id is null
and (mec1.mec_id ) not in (select src_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and src_mec_id is not null )
) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
         ihook.setColumnValue(row,'MAP_DEG',129); -- no CDE
          ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
            getStdMMComment(row,row_ori);
     ihook.setColumnValue(row,'MEC_MAP_NOTES','No CDE attached.');
       
      
           
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
    
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mm.src_mdl_item_id,  
    mm.src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.TGT_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and mec1.cde_item_id is null
and (mec1.mec_id ) not in (select tgt_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and tgt_mec_id is not null )
) loop

        row := t_row();
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
         ihook.setColumnValue(row,'MAP_DEG',129); -- no CDE
         ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
                getStdMMComment(row,row_ori);
    ihook.setColumnValue(row,'MEC_MAP_NOTES','No CDE attached.');
      
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;

 --  raise_application_error(-20000,rows.count);
            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
  hookoutput.actions := actions;
  hookoutput.message := 'Semantic mapping generated.';
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  --    nci_util.debugHook('GENERAL', v_data_out);

end;

PROCEDURE spAddManualMap (v_data_in IN CLOB,    v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    rowmap t_row;
    forms t_forms;
    form1 t_form;
    row t_row;
    rows  t_rows;
    rowset            t_rowset;
    rowsetmap            t_rowset;
  
    actions t_actions := t_actions();
    action t_actionRowset;
   row_ori t_row;
  
 question t_question;
  answer t_answer;
  answers t_answers;

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori := hookInput.originalRowset.rowset(1);
  
    if hookInput.invocationNumber = 0 then

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add New Mapping');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add Manual Mapping', ANSWERS);
HOOKOUTPUT.QUESTION    := question;

          row := t_row();
          rows := t_rows();
         
          ihook.setColumnValue(row, 'MDL_MAP_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
          ihook.setColumnValue(row, 'MDL_MAP_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
          
          for cur in ( select * from nci_mdl_map where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR')) loop
          ihook.setColumnValue(row, 'SRC_MDL_ITEM_ID', cur.src_mdl_item_id);
          ihook.setColumnValue(row, 'SRC_MDL_VER_NR', cur.src_mdl_ver_nr);
          ihook.setColumnValue(row, 'TGT_MDL_ITEM_ID', cur.tgt_mdl_item_id);
          ihook.setColumnValue(row, 'TGT_MDL_VER_NR', cur.tgt_mdl_ver_nr);
            ihook.setColumnValue(row, 'MECM_ID', -1);
          end loop;
          rows.extend;
          rows(rows.last) := row;
          rowsetmap := t_rowset(rows, 'Model Map - Characteristics', 1, 'NCI_MEC_MAP');
        forms                  := t_forms();
    form1                  := t_form('Model Map - Characteristics', 2,1);
    form1.rowset :=rowsetmap;
    forms.extend;    forms(forms.last) := form1;
 
    hookOutput.forms := forms;


  ELSE
      forms              := hookInput.forms;
      form1              := forms(1);
      rowmap := form1.rowset.rowset(1);
      
      ihook.setColumnValue(rowmap, 'MDL_MAP_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
          ihook.setColumnValue(rowmap, 'MDL_MAP_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
    
            rows := t_rows();
            rows.extend;    rows(rows.last) := rowmap;
            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,1,'insert');
            actions.extend;
            actions(actions.last) := action;

            hookoutput.message := 'Manual Map created successfully.';
                hookoutput.actions := actions;
    
 end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--  nci_util.debugHook('GENERAL', v_data_out);
END;
procedure dervTgtMEC(v_data_in IN CLOB,    v_data_out OUT CLOB)
as
v_temp integer;
   hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori t_row;
    v_item_id number;
    v_ver_nr number(4,2);
 begin
     hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

    execute immediate 'ALTER TABLE NCI_MEC_MAP DISABLE ALL TRIGGERS';
    row_ori :=  hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR');
    
update nci_mec_map set tgt_mec_id_derv = null where MDL_MAP_ITEM_ID=v_item_id and MDL_MAP_VER_NR=v_ver_nr;
commit;
update nci_mec_map set tgt_mec_id_derv = tgt_mec_id where src_mec_id is not null and tgt_mec_id is not null and MDL_MAP_ITEM_ID=v_item_id and MDL_MAP_VER_NR=v_ver_nr;
commit;
update nci_mec_map set tgt_mec_id_derv = tgt_mec_id where src_mec_id is null and tgt_mec_id is not null and (upper(TGT_VAL) <> 'NULL' or OP_ID is not null)
and MDL_MAP_ITEM_ID=v_item_id and MDL_MAP_VER_NR=v_ver_nr;
commit;
for cur in (Select * from nci_mec_map where MDL_MAP_ITEM_ID=v_item_id and MDL_MAP_VER_NR=v_ver_nr and 
tgt_mec_id is null and (src_func_id is not null or RIGHT_OP is not null or LEFT_OP is not null or 	FLOW_CNTRL is not null ) order by MEC_MAP_NM,MEC_SUB_GRP_NBR) loop
update nci_mec_map set tgt_mec_id_derv = (select min(tgt_mec_id) from nci_mec_map 
where mec_map_nm = cur.mec_map_nm and MDL_MAP_ITEM_ID=cur.MDL_MAP_ITEM_ID and MDL_MAP_VER_NR = cur.MDL_MAP_VER_NR
and tgt_mec_id is not null and mec_sub_grp_nbr < cur.mec_sub_grp_nbr )
where mecm_id = cur.mecm_id;

for cux in (Select * from nci_mec_map where mecm_id = cur.mecm_id and tgt_mec_id_derv is null and MDL_MAP_ITEM_ID=v_item_id and MDL_MAP_VER_NR=v_ver_nr) loop
update nci_mec_map set tgt_mec_id_derv = (select min(tgt_mec_id) from nci_mec_map where mec_map_nm = cur.mec_map_nm and MDL_MAP_ITEM_ID=cur.MDL_MAP_ITEM_ID and MDL_MAP_VER_NR = cur.MDL_MAP_VER_NR
and tgt_mec_id is not null and mec_sub_grp_nbr > cur.mec_sub_grp_nbr )
where mecm_id = cur.mecm_id;
end loop;

end loop;

update nci_mec_map set tgt_mec_id_derv =tgt_mec_id where tgt_mec_id_derv is null and tgt_mec_id is not null and MDL_MAP_ITEM_ID=v_item_id and MDL_MAP_VER_NR=v_ver_nr;
commit;

     execute immediate 'ALTER TABLE NCI_MEC_MAP ENABLE ALL TRIGGERS';
     
                 hookoutput.message := 'Derivation of Target Characteristic completed.';
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

     end;
     

procedure spGeneratePcode(v_data_in IN CLOB,    v_data_out OUT CLOB)
as
v_temp integer;
   hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori t_row;
    v_item_id number;
    v_ver_nr number(4,2);
    v_src_mdl_nm varchar2(255);
    v_tgt_mdl_nm varchar2(255);
    v_str varchar2(8000);
 begin
     hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori := hookInput.originalRowset.rowset(1);
  v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
  v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
  for cur in (select item_nm from admin_item ai, NCI_MDL_MAP mm where ai.item_id = mm.SRC_MDL_ITEM_ID 
  and ai.ver_nr = mm.SRC_MDL_VER_NR and mm.item_id = v_item_id and mm.ver_nr = v_ver_nr) loop
  v_src_mdl_nm := cur.item_nm || '.';
  end loop;
  for cur in (select item_nm from admin_item ai, NCI_MDL_MAP mm where ai.item_id = mm.TGT_MDL_ITEM_ID 
  and ai.ver_nr = mm.TGT_MDL_VER_NR and mm.item_id = v_item_id and mm.ver_nr = v_ver_nr) loop
  v_tgt_mdl_nm := cur.item_nm || '.';
  end loop;
  
    execute immediate 'ALTER TABLE NCI_MEC_MAP DISABLE ALL TRIGGERS';
   
update nci_mec_map set PCODE_SYSGEN = null where MDL_MAP_ITEM_ID= v_item_id and MDL_MAP_VER_NR = v_ver_nr;
commit;
-- Operations is null
for cur in (select map.mecm_id , map.src_mec_id, v_src_mdl_nm || map.SRC_ELMNT_PHY_NAME || '.' || map.SRC_PHY_NAME SMEC_NM,
 v_tgt_mdl_nm || map.TGT_ELMNT_PHY_NAME || '.'|| map.TGT_PHY_NAME TMEC_NM, SOURCE_FUNCTION, TARGET_FUNCTION, SOURCE_COMPARISON_VALUE,
 SET_TARGET_DEFAULT, OPERATOR, OPERAND_TYPE, FLOW_CONTROL, PARENTHESIS, RIGHT_OPERAND, LEFT_OPERAND from VW_MDL_MAP_IMP_TEMPLATE  map
where map.MODEL_MAP_ID= v_item_id and map.MODEL_MAP_VERSION = v_ver_nr
and map.FLOW_CONTROL is null and map.PARENTHESIS is null and map.OPERATOR is null and map.LEFT_OPERAND is null and map.RIGHT_OPERAND is null and map.OPERAND_TYPE is null and 
map.TGT_PHY_NAME is not null ) loop
if (cur.src_mec_id is null) then
update nci_mec_map set PCODE_SYSGEN =  upper( cur.tmec_nm || '=' || 
cur.SET_TARGET_DEFAULT)  where mecm_id = cur.mecm_id;
end if;
if (cur.src_mec_id is not null and cur.target_function = 'EQUALS') then
update nci_mec_map set PCODE_SYSGEN =  upper( cur.tmec_nm || '=' || 
cur.SMEC_NM)  where mecm_id = cur.mecm_id;
end if;
if (cur.src_mec_id is not null and cur.target_function <> 'EQUALS') then
update nci_mec_map set PCODE_SYSGEN =  upper( cur.tmec_nm || '=' || 
cur.TARGET_FUNCTION || '(' || cur.SMEC_NM || ')')  where mecm_id = cur.mecm_id;
end if;
end loop;
-- Operations is null
for curouter in (select  MAPPING_GROUP_NAME, min(DERIVATION_GROUP_ORDER) DERIVATION_GROUP_ORDER from VW_MDL_MAP_IMP_TEMPLATE  map
where map.MODEL_MAP_ID= v_item_id and map.MODEL_MAP_VERSION = v_ver_nr
and (map.FLOW_CONTROL is not null or map.PARENTHESIS is not null or map.OPERATOR is not null or map.LEFT_OPERAND is not null 
or map.RIGHT_OPERAND is not null or map.OPERAND_TYPE is not null) group by MAPPING_GROUP_NAME) loop
v_str := '';

for cur in (select map.mecm_id ,map.DERIVATION_GROUP_NBR, map.src_mec_id, v_src_mdl_nm || map.SRC_ELMNT_PHY_NAME || '.' || map.SRC_PHY_NAME SMEC_NM,
 v_tgt_mdl_nm || map.TGT_ELMNT_PHY_NAME || '.'|| map.TGT_PHY_NAME TMEC_NM, SOURCE_FUNCTION, TARGET_FUNCTION, SOURCE_COMPARISON_VALUE,
 SET_TARGET_DEFAULT, OPERATOR, OPERAND_TYPE, FLOW_CONTROL, PARENTHESIS, RIGHT_OPERAND, LEFT_OPERAND from VW_MDL_MAP_IMP_TEMPLATE  map
where map.MODEL_MAP_ID= v_item_id and map.MODEL_MAP_VERSION = v_ver_nr
and MAPPING_GROUP_NAME = curouter.MAPPING_GROUP_NAME order by DERIVATION_GROUP_ORDER) loop
-- if
if (cur.FLOW_CONTROL ='IF' or cur.OPERATOR in ('AND','OR')) then 
  v_str :=v_Str ||  cur.FLOW_CONTROL || ' ' ||  cur.OPERATOR || ' ' || case cur.parenthesis when '(' then '( ' else '' end || cur.SMEC_NM || ' ' || cur.OPERAND_TYPE || ' ' || cur.RIGHT_OPERAND || ' ' || case cur.parenthesis when ')' then ') ' else '' end ;
end if;
-- if
if (cur.FLOW_CONTROL is not null and cur.FLOW_CONTROL <> 'IF' ) then 
 v_str := v_str || cur.FLOW_CONTROL || ' ';
 if (cur.src_mec_id is null) then

 v_str := v_Str ||  cur.tmec_nm || '=' || cur.SET_TARGET_DEFAULT || ' ' ;
end if;
if (cur.src_mec_id is not null and cur.target_function = 'EQUALS') then
 v_str := v_str  || ' ' || cur.tmec_nm || '=' || cur.SMEC_NM || ' ' ;
end if;
if (cur.src_mec_id is not null and cur.target_function <> 'EQUALS') then
 v_str := v_str  || ' '|| cur.tmec_nm || '=' || 
cur.TARGET_FUNCTION || '(' || cur.SMEC_NM || ') ';
end if;
end if;

end loop;
--raise_application_error(-20000,v_str);
update nci_mec_map set PCODE_SYSGEN =  upper(v_str)  where MDL_MAP_ITEM_ID= v_item_id and MDL_MAP_VER_NR = v_ver_nr and MEC_MAP_NM=curouter.mapping_group_name
and mec_sub_grp_nbr=curouter.DERIVATION_GROUP_ORDER;
end loop;
commit;

     execute immediate 'ALTER TABLE NCI_MEC_MAP ENABLE ALL TRIGGERS';
     
                 hookoutput.message := 'Pseudocode generation complete.';
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

     end;
     
procedure spDeleteModelMapRule( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
--    actions t_actions := t_actions();
--    action t_actionRowset;
--    row t_row;
--     row_sel t_row;
--    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 v_item_id number;
 v_found boolean;
    v_str varchar2(4000);
 v_src number;
 v_tgt number;
  rowform t_row;


 
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  v_found := false;
  v_str := '';
    
  if (hookinput.invocationnumber = 0) then
    for i in 1..hookInput.originalRowset.rowset.count loop
        row_ori := hookInput.originalRowset.rowset(i);
        v_item_id := ihook.getColumnValue(row_ori, 'MECM_ID');
        v_src := ihook.getColumnValue(row_ori, 'SRC_MEC_ID');
        v_tgt := ihook.getColumnValue(row_ori, 'TGT_MEC_ID');
        for cur in (select * from nci_mec_val_map mecvm where (mecvm.src_mec_id = v_src or mecvm.tgt_mec_id = v_tgt)) loop
            v_found := true;
            --v_str := v_str || ' ' || cur.mecvm_id;
            --hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'WARNING: Value Mapping Exists. Click Confirm to proceed.');
        end loop;
    end loop;
        if (v_found = false) then
            hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'Please confirm deletion of Model Mapping Rule.');
        elsif (v_found = true) then
            hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'WARNING: Value Mapping Exists. Click Confirm to proceed.');
            --hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'WARNING: Value Mapping Exists:' || v_str || '. Click Confirm to proceed.');
        end if;
    end if;
if (hookinput.invocationnumber = 1) then
  
    for i in 1..hookInput.originalRowset.rowset.count loop
        row_ori :=  hookInput.originalRowset.rowset(i);
        v_item_id := ihook.getColumnValue(row_ori,'MECM_ID');

        delete from nci_mec_map where mecm_id = v_item_id; 
        delete from onedata_ra.nci_mec_map where mecm_id = v_item_id;
        commit;
    end loop;

hookoutput.message := hookInput.originalRowset.rowset.count ||  ' Model Mapping Rule(s) deleted.';
end if;

-- for i in 1..hookInput.originalRowset.rowset.count loop
-- row_ori :=  hookInput.originalRowset.rowset(i);
-- delete from nci_mec_map where mecm_id = ihook.getColumnValue(row_ori,'MECM_ID');
-- delete from onedata_ra.nci_mec_map where mecm_id = ihook.getColumnValue(row_ori,'MECM_ID');
-- 
--end loop;
--commit;
--hookoutput.message := hookInput.originalRowset.rowset.count ||  ' Model Mapping Rule(s) deleted.';
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);


END;
     

END;
/
