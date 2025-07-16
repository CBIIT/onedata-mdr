create or replace PACKAGE            nci_codemap_mm AS
procedure   getStdMMComment(row in out t_row,row_ori in t_row);
  procedure spGeneratePcode ( v_data_in in clob, v_data_out out clob);
procedure spCopyMM ( v_src_mm_id in number, v_src_mm_ver_nr in number, v_tgt_mm_id in number, v_tgt_mm_ver_nr in number,v_user_id in varchar2, v_chk_ind in integer);
  procedure spCopyVM ( v_src_mm_id in number, v_src_mm_ver_nr in number, v_tgt_mm_id in number, v_tgt_mm_ver_nr in number,v_user_id in varchar2, v_chk_ind in integer);


procedure    execDeriveTarget (v_item_id in number, v_ver_nr in number);
  procedure spGenerateMapIncrement ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spAddManualMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure updStatsModelMap (v_item_id in number, v_ver_nr in number) ;
  procedure spCopyModelMapping ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCreateMapGroup ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spUpdateModelCDEAssocFromMM ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spReorderModelMap( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2);
  procedure spValidateModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2); -- Validate Model Map import

 procedure spUpdateModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
   procedure spValDeriveModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);-- Validate Model Map
procedure dervTgtMEC( v_data_in in clob, v_data_out out clob); 

 procedure spDeleteModelMap( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spDeleteModelMapRule( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2);
 procedure spRegenerateMMGroup( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2);

 procedure spUpdStatsModelMap( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 
 procedure spPostHookUpdMM( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spGeneratePcodeNew ( v_data_in in clob, v_data_out out clob);
  procedure    spModelMapFuncValidation(v_item_id in number, v_ver_nr in number, v_open_paren in integer, v_close_paren in integer, rows in out t_rows);
  
function getFuncPcode (v_mm_id in number, v_mm_ver in number, v_grp_nm in varchar2, v_init_tgt_func_param in varchar2, v_cur_idx in out integer, v_max_idx in integer,
v_func_id in integer,v_open_paren_id in integer, v_close_paren_id in integer,  v_err in out integer)  return varchar2;
procedure spPostHookMMImport(v_data_in in clob, v_data_out out clob, v_user_id in varchar2);

function getSemanticMapQuestion (v_msg in varchar2) return t_question;
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

procedure spRegenerateMMGroup( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();

  row t_row;
  rows  t_rows;
  row_ori t_row;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori :=  hookInput.originalRowset.rowset(1);
raise_application_error (-20000, 'Work in progress.');
end;

 procedure spUpdateModelCDEAssocFromMM ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
 as

   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();

  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_cnt integer :=0;
    v_mdl_id number;
    v_mdl_ver_nr number(4,2);
    showRowset     t_showableRowset;
    v_msg varchar2(4000); 
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori :=  hookInput.originalRowset.rowset(1);

  if (hookinput.invocationnumber = 0) then
  -- showable rowset
    rows := t_rows();
    for cur in (Select * from nci_mdl_map where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR')) loop
        row := t_row();
        ihook.setColumnValue(row, 'Model Type','Source');
       ihook.setColumnValue(row, 'Model Public Id',cur.src_mdl_item_id);
       ihook.setColumnValue(row, 'Model Version',cur.src_mdl_ver_nr);
       for curname in (select item_nm from admin_item where item_id = cur.src_mdl_item_id and ver_nr = cur.src_mdl_ver_nr) loop
            ihook.setColumnValue(row, 'Model Name',curname.item_nm);
        end loop;   
         rows.extend; rows(rows.last) := row;
        ihook.setColumnValue(row, 'Model Type','Target');
       ihook.setColumnValue(row, 'Model Public Id',cur.tgt_mdl_item_id);
       ihook.setColumnValue(row, 'Model Version',cur.tgt_mdl_ver_nr);
       for curname in (select item_nm from admin_item where item_id = cur.tgt_mdl_item_id and ver_nr = cur.tgt_mdl_ver_nr) loop
            ihook.setColumnValue(row, 'Model Name',curname.item_nm);
        end loop;  
         rows.extend; rows(rows.last) := row;
        showrowset := t_showablerowset (rows, 'Model Selection', 4, 'single');
       	 hookoutput.showrowset := showrowset;
        hookoutput.question := nci_11179.getQuestionGeneric ('Please select model to refresh.', 'Proceed') ;
    end loop;
  end if;
  if (hookinput.invocationnumber = 1) then
   row_sel := hookInput.selectedRowset.rowset(1);

  v_mdl_id := ihook.getColumnValue(row_sel,'Model Public Id');
  v_mdl_ver_nr := ihook.getColumnValue(row_sel,'Model Version');
  nci_codemap.spUpdateModelCDEAssocSub (v_mdl_id,v_mdl_ver_nr, v_cnt,'F', v_msg);

 hookoutput.message := 'CDE refresh complete. ' || v_cnt || ' characteristics updated.' || v_msg;
 end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


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

        hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'Please confirm deletion option: ' || ihook.getColumnValue (row_ori,'ITEM_NM') || ' (' ||v_item_id || 'v' || v_ver_nr || ')');
        rows := t_rows();        row := t_row();


        ihook.setColumnValue(row,'Option','Delete the Model Mapping, including all Rules and all Value Mappings');
        ihook.setColumnValue(row,'ID',1);
        rows.extend; rows(rows.last) := row;

        row := t_row();
        ihook.setColumnValue(row,'Option','Delete only all Rules and Value Mappings');
        ihook.setColumnValue(row,'ID',2);
        rows.extend; rows(rows.last) := row;

        row := t_row();
        ihook.setColumnValue(row,'Option','Delete only Value Mappings ');
        ihook.setColumnValue(row,'ID',3);
        rows.extend; rows(rows.last) := row;

        showRowset := t_showableRowset(rows, 'Delete Option',4, 'single');
        hookOutput.showRowset := showRowset;
 end if; -- invocation number is 0

 if (hookinput.invocationnumber = 1 and hookinput.selectedRowset.rowset.count > 0) then -- only if an option is selected
     row_sel := hookinput.selectedRowset.rowset(1);
     v_temp := ihook.getColumnValue(row_sel,'ID');

       if (ihook.getColumnValue(row_Ori, 'CURRNT_VER_IND')=1 and v_temp<2) then
        for cur in (Select count(*) from admin_item where item_id= v_item_id group by item_id having count(*) > 1) loop
            hookoutput.message := 'Model mapping cannot be deleted as it is the latest version. Use ''Select Latest Version'' to change latest version first.';
            V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
            return;
        end loop;
        end if;


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

  delete from nci_admin_item_ext where  item_id = v_item_id and ver_nr = v_ver_nr;
        delete from onedata_ra.nci_admin_item_ext where  item_id = v_item_id and ver_nr = v_ver_nr;

        delete from admin_item where  item_id = v_item_id and ver_nr = v_ver_nr;
        delete from onedata_ra.admin_item where  item_id = v_item_id and ver_nr = v_ver_nr;
    end if;
    commit;

    hookoutput.message :=  'Model Mapping option selected deleted successfully: ' || v_item_id || 'v'|| v_ver_Nr;
end if;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spPostHookMMImport(v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
as
    hookInput   t_hookInput;
    hookOutput  t_hookOutput := t_hookOutput();
    row_ori     t_row;
    row         t_row;
    v_cnt       number;
    v_val_ind   boolean;

    action      t_actionRowset;
    actions     t_actions := t_actions();
    rows        t_rows;
BEGIN
    hookinput := ihook.getHookInput(v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;
    
    row_ori := hookinput.originalrowset.rowset(1);
    v_val_ind := true;
    if (ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID') is null or ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') is null) then
        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'Model Map ID/Version not specified.');
        v_val_ind := true;
           -- raise_application_error(-20000, 'test inside first if');
    else
        select count(*) into v_cnt from admin_item where item_id = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and admin_item_typ_id = 58;
        if (v_cnt < 1) then
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'Model Mapping not found.');
            v_val_ind := true;
            --raise_application_error(-20000, v_cnt);
        end if;
    end if;
    
    if (v_val_ind = true) then
    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'test post hook update');
        row := row_ori;
        rows := t_rows();
        rows.EXTEND;            
        rows (rows.LAST) := row;
   --     raise_application_error(-20000, v_cnt);
        action := t_actionrowset (rows, 'Model Map Import',     2,      5,       'update');
        actions.EXTEND;
        actions (actions.LAST) := action;

        hookoutput.actions := actions;
    end if;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

 procedure spPostHookUpdMM( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
 as 
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    row   t_row;
    v_item_id number;
    v_ver_nr number(4,2);
    action t_actionRowset;
   actions t_actions := t_actions();
      rows      t_rows;
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   if ( ihook.getColumnValue(row_ori, 'MAP_DEG')  in (86,87) and ihook.getColumnValue(row_ori, 'MAP_DEG') <> ihook.getColumnOldValue(row_ori, 'MAP_DEG') ) then
      raise_application_error(-20000, 'Mapping type cannot be manually set to Semantically Equivalent/Similar.');
    return;
    end if;

    row := row_ori;
   /*  if ( nvl( ihook.getColumnValue(row_ori, 'SRC_MEC_ID') ,0) <> nvl(ihook.getColumnOldValue(row_ori, 'SRC_MEC_ID') ,0)) then
     for cur in (select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char where mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID')) loop
     ihook.setcolumnValue(row,'SRC_CDE_ITEM_ID',cur.cde_item_id);
     ihook.setcolumnValue(row,'SRC_CDE_VER_NR',cur.cde_VER_NR);
     ihook.setcolumnValue(row,'SRC_MEC_ID',ihook.getColumnValue(row_ori, 'SRC_MEC_ID'));

     end loop;
  ihook.setcolumnValue(row,'MECM_ID',ihook.getColumnValue(row_ori,'MECM_ID'));
     rows := t_rows();
  rows.EXTEND;            rows (rows.LAST) := row;
            action :=                t_actionrowset (rows, 'Model Map - Characteristics',     2,      5,       'update');
            actions.EXTEND;
            actions (actions.LAST) := action;


    end if;
     if (  nvl(ihook.getColumnValue(row_ori, 'TGT_MEC_ID'),0) <> nvl(ihook.getColumnOldValue(row_ori, 'TGT_MEC_ID'),0) ) then
     for cur in (select cde_item_id, cde_ver_nr from nci_mdl_elmnt_char where mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID')) loop
     ihook.setcolumnValue(row,'TGT_CDE_ITEM_ID',cur.cde_item_id);
     ihook.setcolumnValue(row,'TGT_CDE_VER_NR',cur.cde_VER_NR);
        ihook.setcolumnValue(row,'TGT_MEC_ID',ihook.getColumnValue(row_ori, 'TGT_MEC_ID'));
     end loop;
  ihook.setcolumnValue(row,'MECM_ID',ihook.getColumnValue(row_ori,'MECM_ID'));
  rows := t_rows();
  rows.EXTEND;            rows (rows.LAST) := row_ori;
            action :=                t_actionrowset (rows, 'Model Map - Characteristics',     2,      5,       'update');
            actions.EXTEND;
            actions (actions.LAST) := action;

 -- raise_application_error(-20000,actions.count);

    end if;
    if (actions.count > 0) then
      hookoutput.actions := actions;
      end if;*/
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
  v_st_ts timestamp;
 v_end_ts timestamp;
  v_add boolean;
  v_temp integer;
  i integer;
  v_mm_id number;
  v_mm_ver number(4,2);
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  rowsadd := t_rows();
  rowsupd := t_rows();
  rows := t_rows();

  v_st_ts := systimestamp();
   row_ori :=  hookInput.originalRowset.rowset(1);
   v_mm_id := ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID');
   v_mm_ver := ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR');


  for cur1 in (Select * from nci_stg_mec_map where mdl_map_item_id = v_mm_id and mdl_map_ver_nr = v_mm_ver and BTCH_NM = ihook.getColumnValue(row_ori, 'BTCH_NM')
  and CTL_VAL_STUS in ('VALIDATED') and fld_Delete = 0) loop
  row_ori:= t_row();
 nci_11179.ReturnRow ('select * from nci_stg_mec_map where stg_mecm_id = ' || cur1.stg_mecm_id, 'NCI_STG_MEC_MAP', row_ori); 
        ihook.setcolumnValue(row_ori, 'MECM_ID', nvl(cur1.IMP_RULE_ID,cur1.STG_MECM_ID));
       -- ihook.setcolumnValue(row_ori, 'IMP_SEQ_NBR', cur1.BTCH_SEQ_NBR);
        
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

 v_end_ts := systimestamp();

 hookoutput.message:= 'New mapping inserted: ' || rowsadd.count || ' Mapping updated: ' || rowsupd.count || chr(13) ||
 ' Execution time in seconds: ' ||  extract( day from(v_end_ts - v_st_ts)*24*60*60);
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 nci_util.debugHook('GENERAL',v_data_out);
end;

-- From Model Map Import
 procedure spUpdateModelMapOld( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
 v_st_ts timestamp;
 v_end_ts timestamp;
 v_mm_id number;
 v_mm_ver number(4,2);
 v_btch_nm varchar2(255);
 v_query_func integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
select obj_key_id into v_query_func from obj_key where obj_key_desc = 'QUERY' and obj_typ_id = 51;
  rows := t_rows();
  v_st_ts := systimestamp();
  row_ori :=  hookInput.originalRowset.rowset(1);
   v_mm_id := ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID');
   v_mm_ver := ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR');
    v_btch_nm := ihook.getColumnValue(row_ori, 'BTCH_NM');
for cur in (select * from nci_mdl_map mm where mm.item_id  = v_mm_id
    and mm.ver_nr = v_mm_ver) loop
    ihook.setColumnValue(row_ori, 'SRC_MDL_ITEM_ID', cur.SRC_MDL_ITEM_ID);
    ihook.setColumnValue(row_ori, 'TGT_MDL_ITEM_ID', cur.TGT_MDL_ITEM_ID);
    ihook.setColumnValue(row_ori, 'SRC_MDL_VER_NR', cur.SRC_MDL_VER_NR);
    ihook.setColumnValue(row_ori, 'TGT_MDL_VER_NR', cur.TGT_MDL_VER_NR);

    end loop; --raise_application_error(-20000,ihook.getColumnValue(row_ori, 'BTCH_NM'));

  for cur1 in (Select * from nci_stg_mec_map where mdl_map_item_id = v_mm_id and mdl_map_ver_nr = v_mm_ver and BTCH_NM = v_btch_nm
  and CTL_VAL_STUS in ( 'IMPORTED','ERROR','VALIDATED')) loop
  --and CTL_VAL_STUS in ( 'IMPORTED')) loop
  --raise_application_error(-20000,'here');
  v_valid := true;
  v_val_stus_msg := '';

-- Validate that the source elemnt/char and target element/char belong to the current source and target model
-- validate that both ME and MEC are specified. May be blank.
if ((cur1.SRC_ME_PHY_NM is null and cur1.SRC_MEC_PHY_NM is not null ) or
(cur1.SRC_ME_PHY_NM is not null and  cur1.SRC_MEC_PHY_NM is  null)) then
v_valid := false;
v_val_stus_msg := 'Both Source Element and Characteristics have to be specified; ';
end if;

if (((cur1.TGT_ME_PHY_NM is null and  cur1.TGT_MEC_PHY_NM is not null ) or
(cur1.TGT_ME_PHY_NM is not null and  cur1.TGT_MEC_PHY_NM is  null)) and v_valid= true) then
v_valid := false;
v_val_stus_msg := 'Both Target Element and Characteristics have to be specified; ';
end if;

ihook.setColumnValue(row_ori, 'SRC_MEC_ID','');

if ( cur1.SRC_ME_PHY_NM  is not null and  cur1.SRC_MEC_PHY_NM is not null) then 
   for cur in (
    select mec.mec_id from  nci_mdl_elmnt me, nci_mdl_elmnt_char mec, nci_mdl_map mm where me.MDL_ITEM_ID = mm.src_mdl_item_id 
    and me.MDL_ITEM_VER_NR = mm.src_mdl_ver_Nr
    and mm.item_id  = v_mm_id
    and mm.ver_nr = v_mm_ver and  upper(me.ITEM_PHY_OBJ_NM) =upper(cur1.SRC_ME_PHY_NM)
    and upper(MEC.MEC_PHY_NM)=upper(cur1.SRC_MEC_PHY_NM) and me.ITEM_ID = mec.MDL_ELMNT_ITEM_ID and me.ver_nr = mec.MDL_ELMNT_VER_NR) loop
      ihook.setColumnValue(row_ori, 'SRC_MEC_ID', cur.mec_id);
    end loop;
    if (ihook.getColumnValue(row_ori, 'SRC_MEC_ID') is null) then 
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg || 'Invalid Source Characteristics; '|| chr(13);
    end if;
end if;    

ihook.setColumnValue(row_ori, 'TGT_MEC_ID','');

if ( cur1.TGT_ME_PHY_NM is not null and  cur1.TGT_MEC_PHY_NM is not null) then 
    for cur in (
    select mec.mec_id from  nci_mdl_elmnt me, nci_mdl_elmnt_char mec, nci_mdl_map mm where me.MDL_ITEM_ID = mm.tgt_mdl_item_id 
    and me.MDL_ITEM_VER_NR = mm.tgt_mdl_ver_Nr
    and mm.item_id  = v_mm_id
    and mm.ver_nr = v_mm_ver and  upper(me.ITEM_PHY_OBJ_NM) =upper(cur1.TGT_ME_PHY_NM)
    and upper(MEC.MEC_PHY_NM)=upper(cur1.TGT_MEC_PHY_NM) and me.ITEM_ID = mec.MDL_ELMNT_ITEM_ID and me.ver_nr = mec.MDL_ELMNT_VER_NR) loop
      ihook.setColumnValue(row_ori, 'TGT_MEC_ID', cur.mec_id);
    end loop;
    if (ihook.getColumnValue(row_ori, 'TGT_MEC_ID') is null) then 
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg || 'Invalid Target Characteristics; '|| chr(13);
    end if;
end if;    

if (cur1.IMP_MAP_DEG is not null and cur1.MAP_DEG is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Mapping Type is incorrect; '|| chr(13);
else -- validate to make sure mapping type is not Semantically Equiv or Semantically Similar
for cur in (select * from nci_mec_map where mecm_id = cur1.STG_MECM_ID and 
cur1.MAP_DEG <> map_deg and cur1.MAP_DEG in (86,87)) loop
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Cannot change the mapping type to Semntically Similar/Equivalent.'|| chr(13);
end loop;
end if;
/*
if (cur1.IMP_CRDNLITY is not null and  cur1.CRDNLITY_ID is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Cardinaliy is incorrect; '|| chr(13);
end if;



if (ihook.getColumnValue(row_ori, 'IMP_SRC_FUNC') is not null and  ihook.getColumnValue(row_ori, 'SRC_FUNC_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Source Function is incorrect; '|| chr(13);
end if;
*/
if (cur1.IMP_TGT_FUNC is not null and  cur1.TGT_FUNC_ID is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Target Function is incorrect; '|| chr(13);
end if;
 /*
if (cur1.IMP_TRANS_RUL_NOT is not null and  cur1.TRANS_RUL_NOT is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Transformation Notation Type is incorrect; '|| chr(13);
end if;
 */
if (cur1.IMP_OP_TYP is not null and cur1.OP_TYP is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Comparator is incorrect; '|| chr(13);
end if;


if (cur1.IMP_FLOW_CNTRL is not null and  cur1.FLOW_CNTRL is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Condition is incorrect; '|| chr(13);
end if;



if (cur1.IMP_PAREN is not null and  cur1.PAREN is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Parenthesis is incorrect; '|| chr(13);
end if;


if (cur1.IMP_PROV_ORG is not null and  cur1.PROV_ORG_ID is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Provenance Organization is incorrect; '|| chr(13);
end if;



if (cur1.IMP_PROV_CNTCT is not null and cur1.PROV_CNTCT_ID is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Provenance Contact is incorrect; '|| chr(13);
end if;



-- Rules id provided is incorrect.

if (cur1.IMP_RULE_ID is not null) then
    select count(*) into v_temp from NCI_MEC_MAP where  MDL_MAP_ITEM_ID  = v_mm_id
    and MDL_MAP_VER_NR = v_mm_ver and MECM_ID=cur1.IMP_RULE_ID and nvl(fld_Delete,0) = 0;
    if (v_temp = 0) then
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'Imported Rule ID is incorrect or does not exist; '|| chr(13);

    end if;    
end if;

 -- duplicae based on src/tgt/op/src func/tgt func/condition/operator
 /*if (v_valid = true) then -- check for duplicate
    for cur in (select * from nci_mec_map where mdl_map_item_id = v_mm_id
    and mdl_map_ver_nr = v_mm_ver and src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID')
    and tgt_mec_id =  ihook.getColumnValue(row_ori, 'TGT_MEC_ID')
    and OP_id =  cur1.op_id
     and PAREN = cur1.paren
      and MEC_SUB_GRP_NBR =  cur1.MEC_SUB_GRP_NBR
     and MEC_MAP_NM = cur1.MEC_MAP_NM
   and TGT_FUNC_id =  cur1.TGT_FUNC_ID
    and FLOW_CNTRL = cur1.FLOW_CNTRL
    and  cur1.IMP_RULE_ID is null) loop
       v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'Duplicate found with Rule ID: '|| cur.MECM_ID ||  chr(13);
   end loop;
 end if;*/
-- QUERY function
-- First parameter is always VALUE_MAP or XWALK
if (cur1.TGT_FUNC_ID = v_query_func  ) then -- check for first and second parameters
 if( cur1.TGT_FUNC_PARAM not in ('VALUE_MAP','XWALK')) then
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'First parameter of QUERY function has to be VALUE_MAP or XWALK. '|| chr(13);
 else -- check second parameter
for cur2 in (select * from  nci_stg_mec_map where mdl_map_item_id = v_mm_id and mdl_map_ver_nr = v_mm_ver and BTCH_NM = v_btch_nm
  and   MEC_MAP_NM= cur1.MEC_MAP_NM and MEC_SUB_GRP_NBR = cur1.MEC_SUB_GRP_NBR+1) loop
     if (nvl(cur2.TGT_FUNC_PARAM,'X') <> 'SOURCE' and nvl(cur2.tgt_func_id,0) <> v_query_func ) then
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'Second parameter of QUERY function has to be SOURCE '|| chr(13);
     end if;
end loop;
end if;
end if;

 if (v_valid = true) then -- check for duplicate
    for cur in (select * from nci_mec_map where mdl_map_item_id = v_mm_id
    and mdl_map_ver_nr = v_mm_ver and nvl(src_mec_id,0) = nvl(ihook.getColumnValue(row_ori, 'SRC_MEC_ID'),0)
    and nvl(tgt_mec_id,0) = nvl( ihook.getColumnValue(row_ori, 'TGT_MEC_ID'),0)
    and nvl(OP_id,0) = nvl( cur1.op_id,0)
     and nvl(PAREN,0) = nvl( cur1.paren,0)
      and nvl(MEC_SUB_GRP_NBR,0) = nvl( cur1.MEC_SUB_GRP_NBR,0)
     and MEC_MAP_NM = cur1.MEC_MAP_NM
   and nvl(TGT_FUNC_id,0) = nvl( cur1.TGT_FUNC_ID,0)
    and nvl(FLOW_CNTRL,0) = nvl(cur1.FLOW_CNTRL,0)
    and  cur1.IMP_RULE_ID is null) loop
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
   update nci_stg_mec_map set CTL_VAL_STUS= ihook.getColumnValue(row_ori,'CTL_VAL_STUS'),
   CTL_VAL_MSG= ihook.getColumnValue(row_ori,'CTL_VAL_MSG'),
   SRC_MDL_ITEM_ID =  ihook.getColumnValue(row_ori, 'SRC_MDL_ITEM_ID'),
   SRC_MDL_VER_NR =  ihook.getColumnValue(row_ori, 'SRC_MDL_VER_NR'),
   TGT_MDL_ITEM_ID =  ihook.getColumnValue(row_ori, 'TGT_MDL_ITEM_ID'),
   TGT_MDL_VER_NR =  ihook.getColumnValue(row_ori, 'TGT_MDL_VER_NR'),
   SRC_MEC_ID = ihook.getColumnValue(row_ori, 'SRC_MEC_ID'), 
   TGT_MEC_ID = ihook.getColumnValue(row_ori, 'TGT_MEC_ID')
    where STG_MECM_ID = cur1.STG_MECM_ID;
   --  rows.extend;   rows(rows.last) := row_ori;
 --end if;
 end loop;

  /* action := t_actionrowset(rows, 'Model Map Import', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;

       hookoutput.actions := actions;*/
      
       
       -- Wrong model map
for cur1 in (Select * from nci_stg_mec_map where (mdl_map_item_id <> v_mm_id or mdl_map_ver_nr = v_mm_ver) and BTCH_NM = v_btch_nm
and btch_usr_nm = ihook.getColumnValue(row_ori, 'BTCH_USR_NM')
  and CTL_VAL_STUS in ( 'IMPORTED')) loop
  update nci_stg_mec_map set CTL_VAL_STUS='ERROR', CTL_VAL_MSG = 'Invalid Model Mapping ID or Version specified. ' || cur1.mdl_map_item_id || 'v' || cur1.mdl_map_ver_nr where STG_MECM_ID = cur1.STG_MECM_ID;
end loop;
 commit;
  v_end_ts := systimestamp();
 hookoutput.message := 'Validation completed. Execution time in seconds: ' ||  extract( day from(v_end_ts - v_st_ts)*24*60*60);
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  -- nci_util.debugHook('GENERAL',v_data_out);
end;


   procedure spValidateModelMapOld ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
    and mm.ver_nr = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and  upper(me.ITEM_PHY_OBJ_NM) =upper(ihook.getColumnValue(row_ori, 'SRC_ME_PHY_NM'))
    and upper(MEC.MEC_PHY_NM)=upper(ihook.getColumnValue(row_ori, 'SRC_MEC_PHY_NM')) and me.ITEM_ID = mec.MDL_ELMNT_ITEM_ID and me.ver_nr = mec.MDL_ELMNT_VER_NR) loop
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
    and mm.ver_nr = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and  upper(me.ITEM_PHY_OBJ_NM) =upper(ihook.getColumnValue(row_ori, 'TGT_ME_PHY_NM'))
    and upper(MEC.MEC_PHY_NM)=upper(ihook.getColumnValue(row_ori, 'TGT_MEC_PHY_NM')) and me.ITEM_ID = mec.MDL_ELMNT_ITEM_ID and me.ver_nr = mec.MDL_ELMNT_VER_NR) loop
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

/*

if (ihook.getColumnValue(row_ori, 'IMP_SRC_FUNC') is not null and  ihook.getColumnValue(row_ori, 'SRC_FUNC_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Source Function is incorrect; '|| chr(13);
end if;
*/
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
 /*
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

 */

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


-- Validation model map as a whole
   procedure spValDeriveModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
   showRowset     t_showableRowset;

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
  row_sel t_row;
 i integer;
 v_open_paren integer;
 v_close_paren integer;
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

rows := t_rows();
 select obj_key_id into v_open_paren from obj_key where obj_typ_id = 58 and obj_key_Desc = '(';
   select obj_key_id into v_close_paren from obj_key where obj_typ_id = 58 and obj_key_Desc = ')';

update nci_mec_map set ctl_val_msg = null where ctl_val_msg is not null and mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr;
commit;

for cur in (
select map1.mec_Map_nm,  x.SRC_item_phy_obj_nm, x.SRC_MEC_PHY_NM,  x.TGT_ITEM_PHY_OBJ_NM
from 
(
select    sme.item_phy_obj_nm SRC_ITEM_PHY_OBJ_NM, smec.MEC_PHY_NM SRC_MEC_PHY_NM,  tme.ITEM_PHY_OBJ_NM TGT_ITEM_PHY_OBJ_NM
from NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT sme,
                NCI_MDL_ELMNT_CHAR tmec,   nci_MEC_MAP map
where  map.SRC_MEC_ID = smec.MEC_ID (+)
    and smec.MDL_ELMNT_ITEM_ID = sme.item_id
    and smec.MDL_ELMNT_VER_NR = sme.ver_nr
    and map.TGT_MEC_ID = tmec.MEC_ID
    and tmec.MDL_ELMNT_ITEM_ID = tme.item_id
    and tmec.MDL_ELMNT_VER_NR = tme.ver_nr 
    and map.MAP_DEG in (86,87,120)
    and map.MDL_MAP_ITEM_ID = v_item_id
    and map.MDL_MAP_VER_NR = v_ver_nr
    and smec.pk_ind = 1
group by sme.item_phy_obj_nm, smec.MEC_PHY_NM, tme.ITEM_PHY_OBJ_NM having count (distinct map.mec_map_nm ) > 1
and count(distinct tmec.mec_phy_nm) > 1) x, nci_mec_map map1,
NCI_MDL_ELMNT_CHAR smec1, NCI_MDL_ELMNT tme1,NCI_MDL_ELMNT sme1,NCI_MDL_ELMNT_CHAR tmec1
where 
map1.MDL_MAP_ITEM_ID = v_item_id
    and map1.MDL_MAP_VER_NR = v_ver_nr
   and map1.SRC_MEC_ID = smec1.MEC_ID (+)
    and smec1.MDL_ELMNT_ITEM_ID = sme1.item_id
    and smec1.MDL_ELMNT_VER_NR = sme1.ver_nr
    and map1.TGT_MEC_ID = tmec1.MEC_ID
    and tmec1.MDL_ELMNT_ITEM_ID = tme1.item_id
    and tmec1.MDL_ELMNT_VER_NR = tme1.ver_nr 
   and smec1.mec_phy_nm = x.SRC_MEC_PHY_NM
   and sme1.ITEM_PHY_OBJ_NM = x.SRC_ITEM_PHY_OBJ_NM
   and tme1.ITEM_PHY_OBJ_NM = x.TGT_ITEM_PHY_OBJ_NM
 ) loop
 row := t_row();
 ihook.setColumnValue(row,'Rule Type','Code Generation');
 ihook.setColumnValue(row, 'Rule Description','Consolidate groups where the Source and Target Elements are the same.');
 ihook.setColumnValue(row, 'Source Element', cur.src_item_phy_obj_nm);
 ihook.setColumnValue(row, 'Source Characteristic', cur.src_mec_phy_nm);
 ihook.setColumnValue(row, 'Target Element', cur.tgt_item_phy_obj_nm);
 ihook.setColumnValue(row, 'Characteristic Group', cur.mec_map_nm);
   rows.extend;     rows(rows.last) := row;
      end loop;


for cur in (
select    map.mec_map_nm,  count(*) 
from NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT sme,
                NCI_MDL_ELMNT_CHAR tmec,   nci_MEC_MAP map
where  map.SRC_MEC_ID = smec.MEC_ID (+)
    and smec.MDL_ELMNT_ITEM_ID = sme.item_id
    and smec.MDL_ELMNT_VER_NR = sme.ver_nr
    and map.TGT_MEC_ID = tmec.MEC_ID
    and tmec.MDL_ELMNT_ITEM_ID = tme.item_id
    and tmec.MDL_ELMNT_VER_NR = tme.ver_nr 
    and map.MAP_DEG in (86,87,120)
    and map.MDL_MAP_ITEM_ID = v_item_id
    and map.MDL_MAP_VER_NR = v_ver_nr
group by map.mec_map_nm having count (distinct tme.ITEM_PHY_OBJ_NM  ) > 1
 ) loop
 row := t_row();
 ihook.setColumnValue(row,'Rule Type','Code Generation');
 ihook.setColumnValue(row, 'Rule Description','Multiple target elements in the same group.');
 --ihook.setColumnValue(row, 'Source Element', cur.src_item_phy_obj_nm);
 --ihook.setColumnValue(row, 'Source Characteristic', cur.src_mec_phy_nm);
 --ihook.setColumnValue(row, 'Target Element', cur.tgt_item_phy_obj_nm);
 ihook.setColumnValue(row, 'Characteristic Group', cur.mec_map_nm);
   rows.extend;     rows(rows.last) := row;
      end loop;
for cur in (
select    map.mec_map_nm, sum(decode(map.paren ,v_open_paren,1,0) ) v_open, sum(decode(map.paren ,v_close_paren,1,0))  v_close, count(*) 
from  nci_MEC_MAP map
where   map.MAP_DEG in (86,87,120)
    and map.MDL_MAP_ITEM_ID = v_item_id
    and map.MDL_MAP_VER_NR = v_ver_nr
group by map.mec_map_nm having sum(decode(map.paren ,v_open_paren,1,0)  ) <> sum(decode(map.paren ,v_close_paren,1,0)  )
 ) loop
 row := t_row();
 ihook.setColumnValue(row,'Rule Type','Consistency');
 ihook.setColumnValue(row, 'Rule Description','Open/close parenthesis do not match. ' || cur.v_open || '/' || cur.v_close);
 --ihook.setColumnValue(row, 'Source Element', cur.src_item_phy_obj_nm);
 --ihook.setColumnValue(row, 'Source Characteristic', cur.src_mec_phy_nm);
 --ihook.setColumnValue(row, 'Target Element', cur.tgt_item_phy_obj_nm);
 ihook.setColumnValue(row, 'Characteristic Group', cur.mec_map_nm);
   rows.extend;     rows(rows.last) := row;
      end loop;



for cur in (
select    map.mecm_id , map.mec_map_nm
from  nci_MEC_MAP map
where   map.MAP_DEG in (86,87,120)
    and map.MDL_MAP_ITEM_ID = v_item_id
    and map.MDL_MAP_VER_NR = v_ver_nr
    and map.FLOW_CNTRL is not null and map.OP_ID is not null
 ) loop
 row := t_row();
 ihook.setColumnValue(row,'Rule Type','Consistency');
 ihook.setColumnValue(row, 'Rule Description','IF/THEN/ELSE and AND/OR cannot be specified in the same rule.');
 --ihook.setColumnValue(row, 'Source Element', cur.src_item_phy_obj_nm);
 --ihook.setColumnValue(row, 'Source Characteristic', cur.src_mec_phy_nm);
 --ihook.setColumnValue(row, 'Target Element', cur.tgt_item_phy_obj_nm);
 ihook.setColumnValue(row, 'Rule ID', cur.mecm_id);
 ihook.setColumnValue(row, 'Characteristic Group', cur.mec_map_nm);

   rows.extend;     rows(rows.last) := row;
      end loop;


for cur in (
select    map.mecm_id , map.mec_map_nm
from  nci_MEC_MAP map
where   map.MAP_DEG in (86,87,120)
    and map.MDL_MAP_ITEM_ID = v_item_id
    and map.MDL_MAP_VER_NR = v_ver_nr
    and nvl(map.PAREN,0) <> v_open_paren  and map.TGT_FUNC_ID is not null
 ) loop
 row := t_row();
 ihook.setColumnValue(row,'Rule Type','Consistency');
 ihook.setColumnValue(row, 'Rule Description','Function does not have an open parenthesis on the same row.');
 ihook.setColumnValue(row, 'Rule ID', cur.mecm_id);
 ihook.setColumnValue(row, 'Characteristic Group', cur.mec_map_nm);

   rows.extend;     rows(rows.last) := row;
      end loop;
/*
for cur in (select a.mecm_id, a.mec_map_nm
    from nci_mec_map a, nci_mec_map b
    where a.mdl_map_item_id = v_item_id and a.mdl_map_ver_nr = v_ver_nr and a.mdl_map_item_id = b.mdl_map_item_id and a.mdl_map_ver_nr = b.mdl_map_ver_nr
    and a.src_mec_id = b.src_mec_id and a.tgt_mec_id = b.tgt_mec_id and a.mecm_id <> b.mecm_id) loop
        row := t_row();
        ihook.setColumnValue(row,'Rule Type','Uniqueness');
        ihook.setColumnValue(row, 'Rule Description','More than one rule exists for the Source/Target Characteristic');
        ihook.setColumnValue(row, 'Rule ID', cur.mecm_id);
        ihook.setColumnValue(row, 'Characteristic Group', cur.mec_map_nm);
            rows.extend;     rows(rows.last) := row;
    end loop;
*/

--- new rule check for PK of Source. Should be mapped once.
for cur in (
select    sme.item_phy_obj_nm src_me_nm, tme.item_phy_obj_nm tgt_me_nm 
from NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT sme,
                NCI_MDL_ELMNT_CHAR tmec,   nci_MEC_MAP map
where  map.SRC_MEC_ID = smec.MEC_ID
    and smec.MDL_ELMNT_ITEM_ID = sme.item_id
    and smec.MDL_ELMNT_VER_NR = sme.ver_nr
    and map.TGT_MEC_ID = tmec.MEC_ID
    and tmec.MDL_ELMNT_ITEM_ID = tme.item_id
    and tmec.MDL_ELMNT_VER_NR = tme.ver_nr 
    and map.MAP_DEG in (86,87,120)
    and map.MDL_MAP_ITEM_ID = v_item_id
    and map.MDL_MAP_VER_NR = v_ver_nr
group by sme.item_phy_obj_nm , tme.item_phy_obj_nm having sum (decode(smec.pk_ind,1,1,0) ) = 0
 ) loop
 row := t_row();
 ihook.setColumnValue(row,'Rule Type','Code Generation');
 ihook.setColumnValue(row, 'Rule Description','Required key not mapped.');
 ihook.setColumnValue(row, 'Source Element', cur.src_me_nm);
 --ihook.setColumnValue(row, 'Source Characteristic', cur.src_mec_phy_nm);
ihook.setColumnValue(row, 'Target Element', cur.tgt_me_nm);
 --ihook.setColumnValue(row, 'Characteristic Group', cur.mec_map_nm);
   rows.extend;     rows(rows.last) := row;
      end loop;
      

for cur in (select  a.mec_map_nm
    from nci_mec_map a
    where a.mdl_map_item_id = v_item_id and a.mdl_map_ver_nr = v_ver_nr and src_mec_id is not null and tgt_mec_id is not null group by a.mec_map_nm, a.src_mec_id , a.tgt_mec_id having count(*) > 1 ) loop
        row := t_row();
        ihook.setColumnValue(row,'Rule Type','Duplicate');
        ihook.setColumnValue(row, 'Rule Description','More than one rule exists for the Source/Target Characteristic');
      --  ihook.setColumnValue(row, 'Rule ID', cur.mecm_id);
        ihook.setColumnValue(row, 'Characteristic Group', cur.mec_map_nm);
            rows.extend;     rows(rows.last) := row;
    end loop;
for cur in (
select    map.mecm_id , map.mec_map_nm
from  nci_MEC_MAP map
where   map.MAP_DEG in (86,87,120)
    and map.MDL_MAP_ITEM_ID = v_item_id
    and map.MDL_MAP_VER_NR = v_ver_nr
    and nvl(map.PAREN,0)  = v_close_paren  and 
    (map.TGT_FUNC_ID is not null or map.op_id is not null or map.FLOW_CNTRL is not null or map.TGT_FUNC_PARAM is not null or map.LEFT_OP is not null or map.right_op is not null)
 ) loop
 row := t_row();
 ihook.setColumnValue(row,'Rule Type','Consistency');
 ihook.setColumnValue(row, 'Rule Description','Close parenthesis should be in its own row.');

 ihook.setColumnValue(row, 'Rule ID', cur.mecm_id);
 ihook.setColumnValue(row, 'Characteristic Group', cur.mec_map_nm);

   rows.extend;     rows(rows.last) := row;
      end loop;
         spModelMapFuncValidation(v_item_id, v_ver_nr, v_open_paren, v_close_paren, rows);
      for i in 1..rows.count loop
       row_sel := rows(i);
       if (ihook.getColumnValue(row_sel, 'Rule ID' ) is not null) then
         update nci_mec_map set ctl_val_msg =   ihook.getColumnValue (row_sel, 'Rule Type') || ': ' ||ihook.getColumnValue (row_sel, 'Rule Description')  where mecm_id =ihook.getColumnValue(row_sel, 'Rule ID' )  ;
         else
         update nci_mec_map set ctl_val_msg =  ihook.getColumnValue (row_sel, 'Rule Type') || ': ' ||ihook.getColumnValue (row_sel, 'Rule Description')  where mdl_map_item_id =v_item_id and mdl_map_ver_nr = v_ver_nr and
         mec_map_nm = ihook.getColumnValue(row_sel, 'Characteristic Group' )  ;
         
         end if;
      
      end loop;
      commit;
      -- Function Validation
     -- spModelMapFuncValidation(v_item_id, v_ver_nr, v_open_paren, v_close_paren, rows);
if hookinput.invocationnumber = 0 then
--jira 4041
if (rows.count > 0) then
showRowset := t_showableRowset(rows, 'Issues with Model Map Validation for: ' || ihook.getColumnValue(row_ori, 'ITEM_NM') || ',  ' || ihook.getColumnValue(row_ori,'ITEM_ID') || 'v' || ihook.getColumnValue(row_ori,'VER_NR') || ',  ' || to_char(systimestamp, 'yyyy-mm-dd HH:mm:ss'),4, 'unselectable');
 --showrowset := t_showablerowset (rows, 'Validation Results', 4, 'unselectable');
       	 hookoutput.showrowset := showrowset;
   hookoutput.question := nci_11179_2.getGenericQuestion('Please address issues mentioned.', 'Close',1);
else
hookoutput.message:= 'No issues found.';
end if;
end if;


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
   ihook.setColumnValue(row,'ITEM_NM', 'Copy of ' || ihook.getColumnValue(row_ori,'ITEM_NM'));--Ravi
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
insert into nci_mec_Map (MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, TRNS_DESC_TXT, 
 SRC_MDL_ITEM_ID, SRC_MDL_VER_NR, TGT_MDL_ITEM_ID, TGT_MDL_VER_NR, MEC_MAP_NM, MAP_DEG, MEC_MAP_DESC, DIRECT_TYP, TRANS_RUL_NOT,
VALID_PLTFORM, PROV_ORG_ID, MEC_GRP_RUL_NBR, MEC_GRP_RUL_DESC, SRC_VAL, TGT_VAL, CRDNLITY_ID, MEC_MAP_NOTES, MEC_SUB_GRP_NBR, PROV_CNTCT_ID, 
PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, VAL_MAP_CREATE_IND, SRC_FUNC_ID, TGT_FUNC_ID, TGT_FUNC_PARAM, OP_ID, IMP_OP_NM, 
 RIGHT_OP, LEFT_OP, FLOW_CNTRL, OP_TYP, PAREN, CMNTS_DESC_TXT, PCODE_SYSGEN, MEC_MAP_NM_GEN,CREAT_USR_ID, LST_UPD_USR_ID)
select  v_id, 1, TRNS_DESC_TXT, 
 v_src_mdl_id, v_to_src_ver_nr, v_tgt_mdl_id, v_to_tgt_Ver_Nr, MEC_MAP_NM, MAP_DEG, MEC_MAP_DESC, DIRECT_TYP, TRANS_RUL_NOT, 
VALID_PLTFORM, PROV_ORG_ID, MEC_GRP_RUL_NBR, MEC_GRP_RUL_DESC, SRC_VAL, TGT_VAL, CRDNLITY_ID, MEC_MAP_NOTES, MEC_SUB_GRP_NBR, PROV_CNTCT_ID,
PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, VAL_MAP_CREATE_IND, SRC_FUNC_ID, TGT_FUNC_ID, TGT_FUNC_PARAM, OP_ID, IMP_OP_NM,
 RIGHT_OP, LEFT_OP, FLOW_CNTRL, OP_TYP, PAREN, CMNTS_DESC_TXT, PCODE_SYSGEN, MEC_MAP_NM_GEN, v_user_id, v_user_id
from nci_mec_map m  where nvl(m.fld_delete,0) = 0 and m.mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr
 and m.src_mec_id is  null and m.tgt_mec_id is null;
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

 procedure generateQueryRows(v_map_nm in varchar2,v_param_1 varchar2, v_param_2 varchar2, v_param_3 varchar2,
 v_param_4 varchar2, v_param_5 varchar2, v_param_6 varchar2,
 v_func in integer, v_open_paren in integer, v_close_paren in integer,
 row in out t_row, rows in out t_rows) 
 as
   i integer;
   begin
                    ihook.setColumnValue(row,'MEC_MAP_NM',v_map_nm);
         ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
               ihook.setColumnValue(row,'PAREN',v_open_paren); 
              ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
         rows.extend;   rows(rows.last) := row;

         --     ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|SOURCE PV|TARGET PV'); 
              ihook.setColumnValue(row,'TGT_FUNC_ID','');
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',v_param_1); 
            ihook.setColumnValue(row,'PAREN',''); 
            rows.extend;   rows(rows.last) := row;

            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',3);
            ihook.setColumnValue(row,'TGT_FUNC_ID','');
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',v_param_2); 
             rows.extend;   rows(rows.last) := row;

            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',4);
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',v_param_3); 
            rows.extend;   rows(rows.last) := row;

           if (v_param_4 is null) then 
               ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',5);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM',''); 
                ihook.setColumnValue(row,'PAREN',v_close_paren); 
            else -- 3more rows
                     ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',5);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM',''); 
                     ihook.setColumnValue(row,'PAREN',v_open_paren); 

         rows.extend;   rows(rows.last) := row;
                 ihook.setColumnValue(row,'PAREN',''); 
                ihook.setColumnValue(row,'TGT_FUNC_ID','');

               ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',6);
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',v_param_4); 
            rows.extend;   rows(rows.last) := row;
               ihook.setColumnValue(row,'PAREN',''); 

             ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',7);
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',v_param_5); 
            rows.extend;   rows(rows.last) := row;
             ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',8);
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',v_param_6); 
            rows.extend;   rows(rows.last) := row;
                  ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',9);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM',''); 
                ihook.setColumnValue(row,'PAREN',v_close_paren); 
                 rows.extend;   rows(rows.last) := row;
                  ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',10);
                end if;
      end;


 procedure generateQueryRowSingle(v_map_nm in varchar2,v_param varchar2, v_func in integer, v_paren in integer, v_nbr in integer,
 row in out t_row, rows in out t_rows) 
 as
   i integer;
   begin
                    ihook.setColumnValue(row,'MEC_MAP_NM',v_map_nm);
         ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',v_param); 
               ihook.setColumnValue(row,'PAREN',v_paren); 
              ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',v_nbr);
         rows.extend;   rows(rows.last) := row;

      end;

procedure setRowMECNull(row in out t_row, v_typ in varchar) as
    i integer;
begin

    ihook.setColumnValue(row,'MEC_MAP_NOTES','');
           if (v_typ in ('S','B') ) then
           ihook.setColumnValue(row,'SRC_MEC_ID','');
          ihook.setColumnValue(row,'SRC_CDE_ITEM_ID','');
        ihook.setColumnValue(row,'SRC_CDE_VER_NR','');
        end if;
                 if (v_typ in ('T','B') ) then

          ihook.setColumnValue(row,'TGT_MEC_ID','');
         ihook.setColumnValue(row,'TGT_CDE_ITEM_ID','');
        ihook.setColumnValue(row,'TGT_CDE_VER_NR','');
        end if;

end;


function getSemanticMapQuestion (v_msg in varchar2)  return t_question is

  question t_question;
  answer t_answer;
  answers t_answers;
begin

        ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(1, 1, 'Generate for All Elements' );
        ANSWERS.EXTEND;        ANSWERS(ANSWERS.LAST) := ANSWER;
           ANSWER                     := T_ANSWER(2, 2, 'Generate for Selected Element(s)' );
        ANSWERS.EXTEND;        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION('All rules except Mapping Type "Derived From" and "Ignore" will be regenerated.', ANSWERS);


return question;
end;



procedure spGenerateMapIncrement ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
showrowset	t_showablerowset;

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_val_dom_typ integer;
    v_ver_nr number(4,2);
    v_temp integer;
    v_func integer;
 
    i integer := 0;
    v_src_data_typ varchar2(255);
    v_tgt_data_typ varchar2(255);
    
    v_cnt integer;
    v_str varchar2(255);
    v_minlen integer;
    v_entty_nm_with_space varchar2(255);
    v_nmtyp integer;
    v_nm_desc varchar2(4000);
    v_term_src  varchar2(255);
    v_src_nm varchar2(255);
    v_src_desc varchar2(255);
    v_equals_func  integer;
    v_open_paren integer;
    v_close_paren integer;
    v_grp_nm varchar2(1000);
    v_nm varchar2(255);
    v_desc varchar2(255);
      v_id number;
--    v_reg_str varchar2(255);
 -- v_entty_nm varchar2(4000);
 k integer;
 v_prev_grp_nm varchar2(1000);
 v_cur_grp_nm varchar2(1000);
v_temp_func integer;
row_sel t_row;
v_fltr_str varchar2(1000);
v_sel_id number;
v_sel_ver_nr number(4,2);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
       row_ori := hookInput.originalRowset.rowset(1);
  v_id := ihook.getColumnValue(row_ori,'ITEM_ID') ;
  v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR') ;

 if (hookinput.invocationNUmber = 0) then
 --hookoutput.question := nci_form_curator.getProceedQuestion ('Proceed', 'All rules except Mapping Type "Derived From" and "Ignore" will be regenerated. Please confirm semantic map generation for: ' || v_id || 'v' || v_ver_nr);
 hookoutput.question := getSemanticMapQuestion( 'All rules except Mapping Type "Derived From" and "Ignore" will be regenerated. Please confirm semantic map generation for: ' || v_id || 'v' || v_ver_nr) ;
 
 rows := t_rows();
 row := t_row();
 for cur in (Select * from nci_mdl_map where item_id = v_Id and ver_nr = v_ver_nr) loop
 ihook.setColumnValue(row, 'MDL_ITEM_ID',cur.SRC_MDL_ITEM_ID);
 ihook.setColumnValue(row, 'MDL_ITEM_VER_NR',cur.SRC_MDL_VER_NR);
 end loop;
 rows.extend;                    rows (rows.last) := row;
	   	 showrowset := t_showablerowset (rows, 'Model Element', 2, 'single');
       	 hookoutput.showrowset := showrowset;

else
   select obj_key_id into v_open_paren from obj_key where obj_typ_id = 58 and obj_key_Desc = '(';
   select obj_key_id into v_close_paren from obj_key where obj_typ_id = 58 and obj_key_Desc = ')';


--hookoutput.message := 'Work in progress.';

  select obj_key_id into v_func from obj_key where obj_key_desc = 'QUERY' and obj_typ_id = 51;
  select obj_key_id into v_equals_func from obj_key where obj_key_desc = 'EQUALS' and obj_typ_id = 51;
  select obj_key_id into v_nmtyp from obj_key where obj_key_desc = 'Ref Term Short Name' and obj_typ_id = 11;
        -- no deletes
    rows := t_rows();
    if (hookinput.answerid = 2) then
      if(hookinput.selectedRowset is null) then -- raise error
        hookoutput.message := 'No element was selected.';
           V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
        return;
      else
      --v_fltr_str := ' and ' ;
  --    for i in 1..hookinput.selectedRowset.rowset.count loop

       row_sel := hookinput.selectedRowset.rowset(1);
       v_sel_id := ihook.GetColumnValue(row_sel,'ITEM_ID');
          v_sel_ver_nr := ihook.GetColumnValue(row_sel,'VER_NR');
        --v_fltr_str :=  v_fltr_str  || ' ( me.item_id = ' || ihook.getColumnValue(row_sel, 'ITEM_ID') || ' and me.ver_nr = ' || ihook.getColumnValue(row_sel, 'VER_NR') ||' )';
        --if (i <> hookinput.selectedRowset.rowset.count) then
       -- v_fltr_str := v_fltr_str || ' or ' ;
       -- end if;
    --    end loop;
      end if;
   -- else
   --  v_fltr_str := '';
    end if;
-- delete where NO CDE or NOT MAPPED
  if (v_sel_id is null) then
    delete from NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR')
     and nvl(MAP_DEG,1) not in (120,131) ;--and v_fltr_str;
    commit;
    delete from onedata_ra.NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR')
     and nvl(MAP_DEG,1) not in (120,131);
    commit;
end if;

  if (v_sel_id is not null) then
    delete from NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR')
     and nvl(MAP_DEG,1) not in (120,131) and MEC_MAP_NM in (Select distinct MEC_MAP_NM from nci_mec_map where 
     mdl_map_item_id = v_id and mdl_map_ver_nr = v_ver_nr and src_mec_id in (select mec_id from nci_mdl_elmnt_char where mdl_elmnt_item_id = v_sel_id and mdl_elmnt_ver_nr = v_sel_ver_nr)) ;--and v_fltr_str;
    commit;
    delete from onedata_ra.NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR')
     and nvl(MAP_DEG,1) not in (120,131) and MEC_MAP_NM in (Select distinct MEC_MAP_NM from nci_mec_map where 
     mdl_map_item_id = v_id and mdl_map_ver_nr = v_ver_nr and src_mec_id in (select mec_id from nci_mdl_elmnt_char where mdl_elmnt_item_id = v_sel_id and mdl_elmnt_ver_nr = v_sel_ver_nr)) ;--and v_fltr_str;
    commit;
end if;

-- update CDE ID if changed.
update nci_mec_map m set (src_cde_item_id, src_cde_ver_nr,CMNTS_DESC_TXT) = (Select cde_item_id, cde_ver_nr,cmnts_desc_txt || ' Source CDE changed on: ' || sysdate from nci_mdl_elmnt_char c where c.mec_id = m.src_mec_id)
where 
src_mec_id is not null 
and mdl_map_item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and mdl_map_ver_nr = ihook.getColumnValue (row_ori,'VER_NR')
and (nvl(src_cde_item_id,0), nvl( src_cde_ver_nr,0)) <> (Select nvl(cde_item_id,0), nvl(cde_ver_nr,0) from nci_mdl_elmnt_char c1 where c1.mec_id = m.src_mec_id);
commit;

update nci_mec_map m set (tgt_cde_item_id, tgt_cde_ver_nr,CMNTS_DESC_TXT) = (Select cde_item_id, cde_ver_nr ,cmnts_desc_txt || ' Target CDE changed on: ' || sysdate from nci_mdl_elmnt_char c where c.mec_id = m.tgt_mec_id )
where 
tgt_mec_id is not null 
and mdl_map_item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and mdl_map_ver_nr = ihook.getColumnValue (row_ori,'VER_NR')
and (nvl(tgt_cde_item_id,0), nvl( tgt_cde_ver_nr,0)) <> (Select nvl(cde_item_id,0), nvl(cde_ver_nr,0) from nci_mdl_elmnt_char c1 where c1.mec_id = m.tgt_mec_id);
commit;

if (rows.count > 0) then
 action := t_actionrowset(rows, 'Model Map - Characteristics', 2,2,'update');
        actions.extend;
        actions(actions.last) := action;
        end if;

        rows := t_rows();
    -- Both source and target CDE are present
  k := 1;
  v_prev_grp_nm := '';
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
and me1.item_id = nvl(v_sel_id, me1.item_id) and me1.ver_nr = nvl(v_sel_ver_nr, me1.ver_nr)
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR')
and (mec1.mec_id , mec2.mec_id) not in (select src_mec_id, tgt_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and src_mec_id is not null 
and tgt_mec_id is not null) order by me1.ITEM_LONG_NM,me2.ITEM_LONG_NM ) loop

        v_cur_grp_nm := cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.TGT_ME_ITEM_LONG_NM;
        if (v_cur_grp_nm <> nvl(v_prev_grp_nm ,'XX') or v_prev_grp_nm = '') then
        v_prev_grp_nm := v_cur_grp_nm;
        k := 1;
        else
        k := k+2;
        end if;
        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.tgt_mec_id);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MAP_DEG',86);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);

        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',k);
      --  ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
        ihook.setColumnValue(row,'MEC_MAP_NM',v_cur_grp_nm);
          ihook.setColumnValue(row,'SRC_CDE_ITEM_ID',cur.SRC_CDE_ITEM_ID);
        ihook.setColumnValue(row,'SRC_CDE_VER_NR',cur.SRC_CDE_VER_NR);
           ihook.setColumnValue(row,'TGT_CDE_ITEM_ID',cur.TGT_CDE_ITEM_ID);
        ihook.setColumnValue(row,'TGT_CDE_VER_NR',cur.TGT_CDE_VER_NR);
           ihook.setColumnValue(row,'TGT_FUNC_ID',v_equals_func);
            ihook.setColumnValue(row,'TGT_FUNC_PARAM','SOURCE'); 
               ihook.setColumnValue(row,'PAREN',v_open_paren); 

        getStdMMComment(row,row_ori);



                                     rows.extend;
                                            rows(rows.last) := row;

  ihook.setColumnValue(row,'TGT_FUNC_ID','');
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',''); 
               ihook.setColumnValue(row,'PAREN',v_close_paren); 
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',k+1);
        ihook.setColumnValue(row,'SRC_MEC_ID','');
        ihook.setColumnValue(row,'TGT_MEC_ID','');
          ihook.setColumnValue(row,'SRC_CDE_ITEM_ID','');
        ihook.setColumnValue(row,'SRC_CDE_VER_NR','');
           ihook.setColumnValue(row,'TGT_CDE_ITEM_ID','');
        ihook.setColumnValue(row,'TGT_CDE_VER_NR','');

                        rows.extend;
                                            rows(rows.last) := row;
    end loop;

 -- Semantically similar/equivivalent
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
and me1.item_id = nvl(v_sel_id, me1.item_id) and me1.ver_nr = nvl(v_sel_ver_nr, me1.ver_nr)
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

       v_grp_nm := cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.TGT_ME_ITEM_LONG_NM ||'.'|| cur.SRC_MEC_LONG_NM || '.'|| cur.TGT_MEC_LONG_NM;
        --  Enumerated by Reference
        -- Set Target function to xlookup, source and target parameters
        for cursrc in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP ,
        	NCI_STD_DTTYPE_ID, VAL_DOM_MAX_CHAR, VAL_DOM_MIN_CHAR
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and c.mec_id = cur.src_mec_id) loop

        for curtgt in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  ,
        NCI_STD_DTTYPE_ID, VAL_DOM_MAX_CHAR, VAL_DOM_MIN_CHAR
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and c.mec_id = cur.tgt_mec_id) loop

        --  src is enum, target is enum
        if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 17) then
        -- generateQueryRowSingle(v_grp_nm,'', v_func, v_open_paren, 1, row, rows);
         generateQueryRowSingle(v_grp_nm,'VALUE_MAP', v_func, v_open_paren ,1, row, rows);
         setRowMECNull(row,'T');
         generateQueryRowSingle(v_grp_nm,'SOURCE', null, null, 2, row, rows);
          setRowMECNull(row,'B');
       generateQueryRowSingle(v_grp_nm,'SOURCE_PV', null, null, 3, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_PV', null, null, 4, row, rows);
         generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 5, row, rows);
     end if;
        --enum/non-enum
        if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 18) then
         generateQueryRowSingle(v_grp_nm,'VALUE_MAP', v_func, v_open_paren, 1, row, rows);
         setRowMECNull(row,'T');
         generateQueryRowSingle(v_grp_nm,'SOURCE', null, null, 2, row, rows);
            setRowMECNull(row,'B');
      generateQueryRowSingle(v_grp_nm,'SOURCE_PV', null, null, 3, row, rows);
         generateQueryRowSingle(v_grp_nm,'SOURCE_LABEL', null, null, 4, row, rows);
         generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 5, row, rows);

     end if;
     -- non-enum/enum then 2 rows - use case 3

         if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 17) then
     /*    generateQueryRowSingle(v_grp_nm,'VALUE_MAP', v_func, v_open_paren ,1, row, rows);
         setRowMECNull(row,'T');
         generateQueryRowSingle(v_grp_nm,'SOURCE', null, null, 2, row, rows);
            setRowMECNull(row,'B');
     generateQueryRowSingle(v_grp_nm,'SOURCE_LABEL', null, null, 3, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_PV', null, null, 4, row, rows);
         generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 5, row, rows); */
--VALUE_MAP|(QUERY|NCIT|SOURCE|PREF_TERM_SYN|NCIT_CODE)|TARGET_CODE|TARGET_PV
    generateQueryRowSingle(v_grp_nm,'VALUE_MAP', v_func, v_open_paren ,1, row, rows);
         setRowMECNull(row,'T');
      generateQueryRowSingle(v_grp_nm,'NCIT', v_func, v_open_paren ,2, row, rows);
         generateQueryRowSingle(v_grp_nm,'SOURCE', null, null, 3, row, rows);
            setRowMECNull(row,'B');
     generateQueryRowSingle(v_grp_nm,'PREF_TERM_SYN', null, null, 4, row, rows);
     generateQueryRowSingle(v_grp_nm,'NCIT_CODE', null, null, 5, row, rows);
         generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 6, row, rows); 
     generateQueryRowSingle(v_grp_nm,'TARGET_CODE', null, null, 7, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_PV', null, null, 8, row, rows);
         generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 9, row, rows); 

        end if;

        -- non-enum/Enum by Ref - use case 4
         if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 16) then
                -- ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt TERM|NCIt CODE'); 
                 select  nvl(a.nm_desc,c.item_nm) ,upper(o.obj_key_desc) into v_nm, v_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;

         generateQueryRowSingle(v_grp_nm,'XWALK', v_func, v_open_paren ,1, row, rows);
         setRowMECNull(row,'T');
         generateQueryRowSingle(v_grp_nm,'SOURCE', null, null, 2, row, rows);
           setRowMECNull(row,'B');
       generateQueryRowSingle(v_grp_nm,'SOURCE_TERMINOLOGY: NCIt', null, null, 3, row, rows);
         generateQueryRowSingle(v_grp_nm,'SOURCE_TERM', null, null, 4, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_TERMINOLOGY: ' || v_nm, null, null, 5, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_' ||v_desc, null, null, 6, row, rows);
         generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 7, row, rows);

            /*
                 generateQueryRows(v_grp_nm,'XWALK','NCIt TERM','NCIt CODE',
     'XWALK','NCIt CODE',v_nm_desc,
    v_func, v_open_paren, v_close_paren, row, rows); */


        end if;

         -- enum/Enum by Ref
         if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 16) then
         --       ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|SOURCE PV|NCIt CODE');

           select  nvl(a.nm_desc,c.item_nm) , upper(o.obj_key_desc) into v_nm, v_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;


         generateQueryRowSingle(v_grp_nm,'XWALK', v_func, v_open_paren ,1, row, rows);
          setRowMECNull(row,'T');

         generateQueryRowSingle(v_grp_nm,'VALUE_MAP', v_func, v_open_paren ,2, row, rows);
            generateQueryRowSingle(v_grp_nm,'SOURCE', null, null ,3, row, rows);
                    setRowMECNull(row,'B');

          generateQueryRowSingle(v_grp_nm,'SOURCE_PV', null, null,4, row, rows);
         generateQueryRowSingle(v_grp_nm,'NCIT_CODE', null, null,5, row, rows);
         generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 6, row, rows);

         generateQueryRowSingle(v_grp_nm,'SOURCE_TERMINOLOGY: NCIt', null, null, 7, row, rows);
         generateQueryRowSingle(v_grp_nm,'SOURCE_CODE', null, null, 8, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_TERMINOLOGY: ' || v_nm, null, null, 9, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_' ||v_desc, null, null, 10, row, rows);
         generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 11, row, rows);



        end if;

           -- Enum by Ref/Enum
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 17) then
            select  nvl(a.nm_desc,c.item_nm) , upper(o.obj_key_desc) into v_nm, v_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;


         generateQueryRowSingle(v_grp_nm,'VALUE_MAP', v_func, v_open_paren ,1, row, rows);
        setRowMECNull(row,'T');
         generateQueryRowSingle(v_grp_nm,'XWALK', v_func, v_open_paren ,2, row, rows);
         generateQueryRowSingle(v_grp_nm,'SOURCE', null, null,3, row, rows);
               setRowMECNull(row,'B');

         generateQueryRowSingle(v_grp_nm,'SOURCE_TERMINOLOGY: ' || v_nm, null, null, 4, row, rows);
         generateQueryRowSingle(v_grp_nm,'SOURCE_' ||v_desc, null, null, 5, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_TERMINOLOGY: NCIt', null, null,6, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_CODE', null, null,7, row, rows);
          generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 8, row, rows);
         generateQueryRowSingle(v_grp_nm,'SOURCE_NCIT_CODE', null, null, 9, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_PV', null, null, 10, row, rows);
         generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 11, row, rows);


        end if;

           -- Enum by Ref/non-enum
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 18) then




            select  nvl(a.nm_desc,c.item_nm) ,upper(o.obj_key_Desc)  into v_nm,  v_term_src from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            -- use case 8


         generateQueryRowSingle(v_grp_nm,'XWALK', v_func, v_open_paren ,1, row, rows);
               setRowMECNull(row,'T');

         generateQueryRowSingle(v_grp_nm,'SOURCE', null, null,2, row, rows);
               setRowMECNull(row,'B');

         generateQueryRowSingle(v_grp_nm,'SOURCE_TERMINOLOGY: ' ||v_nm, null, null, 3, row, rows);
         generateQueryRowSingle(v_grp_nm,'SOURCE_' ||v_term_src, null, null, 4, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_TERMINOLOGY: NCIt', null, null,5, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_CODE', null, null,6, row, rows);
             generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 7, row, rows);

        end if;

        -- use case 5 - non-enum/non-enum
            if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 18) then
            
            -- get data types and then do function conversion
            select upper(DTTYPE_NM) into v_src_Data_typ from data_typ where DTTYPE_ID= cursrc.NCI_STD_DTTYPE_ID;
            select upper(DTTYPE_NM) into v_tgt_Data_typ from data_typ where DTTYPE_ID= curtgt.NCI_STD_DTTYPE_ID;

    -- Equals            
            if (v_src_data_typ = v_tgt_data_typ or 
            v_tgt_data_typ ='CHARACTER' or
            (v_src_data_typ='INTEGER' and v_tgt_data_typ = 'REAL')) then 
              generateQueryRowSingle(v_grp_nm,'SOURCE', v_equals_func, v_open_paren, 1, row, rows);
                     setRowMECNull(row,'B');
                             generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 2, row, rows);
            end if;
-- Equals with warning
            if ((v_tgt_data_typ in ('INTEGER','REAL') and v_src_data_typ in ('TIME','DATE','DATA-AND-TIME')) or 
                 (v_tgt_data_typ='TIME' and v_src_data_typ in ('REAL','DATE','INTEGER')) or 
                 (v_tgt_data_typ='DATE-AND-TIME' and v_src_data_typ in ('REAL','TIME','INTEGER')) or 
                 (v_tgt_data_typ in ('DATE','DATE-AND-TIME') and v_src_data_typ in ('REAL','TIME','INTEGER')) )      then 
                 ihook.setColumnValue(row, 'MEC_MAP_NOTES', 'Data Type mismatch. Source Data Type: ' || v_src_Data_typ || ';  Target Data Type: ' || v_tgt_data_typ || '.');
              generateQueryRowSingle(v_grp_nm,'SOURCE', v_equals_func, v_open_paren, 1, row, rows);
                     setRowMECNull(row,'B');
                             generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 2, row, rows);
            end if;
--CAST
            if ((v_tgt_data_typ <> 'CHARACTER' and v_src_data_typ ='CHARACTER') or 
                 (v_tgt_data_typ='DATE' and v_src_data_typ ='DATE-AND-TIME') ) then
           --      ihook.setColumnValue(row, 'MEC_MAP_NOTES', 'Data Type mismatch. Source Data Type: ' || v_src_Data_typ || ';  Target Data Type: ' || v_tgt_data_typ || '.');
           
           select obj_key_id into v_temp_func from obj_key where obj_typ_id = 51 and obj_key_desc = 'CAST';
           
              generateQueryRowSingle(v_grp_nm,'SOURCE', v_temp_func, v_open_paren, 1, row, rows);
                     setRowMECNull(row,'B');
              generateQueryRowSingle(v_grp_nm,v_tgt_data_typ, '','', 2, row, rows);
                     
                             generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 3, row, rows);
            end if;
-- ROUND

            if ((v_tgt_data_typ = 'INTEGER' and v_src_data_typ ='REAL')) then 
           select obj_key_id into v_temp_func from obj_key where obj_typ_id = 51 and obj_key_desc = 'ROUND';
           
              generateQueryRowSingle(v_grp_nm,'SOURCE', v_temp_func, v_open_paren, 1, row, rows);
                     setRowMECNull(row,'B');          
                             generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 2, row, rows);
            end if;
-- TIME

            if ((v_tgt_data_typ = 'TIME' and v_src_data_typ ='DATE-AND-TIME')) then 
           select obj_key_id into v_temp_func from obj_key where obj_typ_id = 51 and obj_key_desc = 'TIME';
           
              generateQueryRowSingle(v_grp_nm,'SOURCE', v_temp_func, v_open_paren, 1, row, rows);
                     setRowMECNull(row,'B');          
                             generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 2, row, rows);
            end if;
            
          end if;
            -- Enum by Ref/Enum by Ref
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 16) then
         select  nvl(a.nm_desc,c.item_nm) , upper(o.obj_key_desc) into v_src_nm, v_Src_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;

            select  nvl(a.nm_desc,c.item_nm), upper(o.obj_key_desc) into v_nm, v_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;

         generateQueryRowSingle(v_grp_nm,'XWALK', v_func, v_open_paren ,1, row, rows);
         setRowMECNull(row,'T');
         generateQueryRowSingle(v_grp_nm,'SOURCE', null, null,2, row, rows);
         setRowMECNull(row,'B');
         generateQueryRowSingle(v_grp_nm,'SOURCE_TERMINOLOGY: ' ||v_src_nm, null, null, 3, row, rows);
         generateQueryRowSingle(v_grp_nm,'SOURCE_' ||v_src_desc, null, null, 4, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_TERMINOLOGY: ' || v_nm, null, null,5, row, rows);
         generateQueryRowSingle(v_grp_nm,'TARGET_'|| v_desc, null, null,6, row, rows);
         generateQueryRowSingle(v_grp_nm,'', null, v_close_paren, 7, row, rows);

          --         ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_src_nm_desc || '|' || v_nm_desc); 



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
and me1.item_id = nvl(v_sel_id, me1.item_id) and me1.ver_nr = nvl(v_sel_ver_nr, me1.ver_nr)
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and mec1.de_conc_item_id not in (select distinct mec2.de_conc_item_id from 
nci_mdl_elmnt me2,  nci_mdl_elmnt_char mec2,  NCI_MDL_MAP mm2
where me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and me2.mdl_item_id = mm2.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm2.TGT_MDL_VER_NR 
and mm2.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm2.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') and mec2.de_conc_item_id is not null)
and (mec1.mec_id ) not in (select src_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and src_mec_id is not null )
) loop

        row := t_row();
        ihook.setColumnValue(row,'MECM_ID',-1);
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
         ihook.setColumnValue(row,'TGT_FUNC_ID','');
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',''); 
       ihook.setColumnValue(row,'PAREN','');

    ihook.setColumnValue(row,'MEC_MAP_NOTES','No Matching Target DEC Found.');

     /*   for curvd in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and vd.val_dom_typ_id = 16 and c.mec_id = cur.src_mec_id) loop

            for curc in (select nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc)  nm_desc from vw_cncpt c, alt_nms a, obj_key o 
            where o.obj_key_id = curvd.term_use_typ and c.item_id = curvd.TERM_CNCPT_ITEM_ID and c.ver_nr = curvd.TERM_CNCPT_VER_NR
            and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp)
             loop
              ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'SRC_VAL', curc.nm_desc);
            end loop;
            end loop;*/

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
and me1.item_id = nvl(v_sel_id, me1.item_id) and me1.ver_nr = nvl(v_sel_ver_nr, me1.ver_nr)
and nvl(mec1.de_conc_item_id,333) not in (select distinct mec2.de_conc_item_id from 
nci_mdl_elmnt me2,  nci_mdl_elmnt_char mec2,  NCI_MDL_MAP mm2
where me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and me2.mdl_item_id = mm2.SRC_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm2.SRC_MDL_VER_NR 
and mm2.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm2.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') and mec2.de_conc_item_id is not null)
and (mec1.mec_id ) not in (select tgt_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and tgt_mec_id is not null )) loop

        row := t_row();
        ihook.setColumnValue(row,'MECM_ID',-1);
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
          ihook.setColumnValue(row,'TGT_FUNC_ID','');
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',''); 
       ihook.setColumnValue(row,'PAREN','');
      ihook.setColumnValue(row,'MEC_MAP_NOTES','No Matching Source DEC Found.');

                                     rows.extend;
                                            rows(rows.last) := row;


end loop;
-- no CDE moved to not mapped


    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, me1.mdl_item_id src_mdl_item_id,  
    me1.mdl_item_ver_nr src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR 
and me1.item_id = nvl(v_sel_id, me1.item_id) and me1.ver_nr = nvl(v_sel_ver_nr, me1.ver_nr)
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and mec1.cde_item_id is null
and (mec1.mec_id ) not in (select src_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and src_mec_id is not null )
) loop

        row := t_row();
        ihook.setColumnValue(row,'MECM_ID',-1);
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
         ihook.setColumnValue(row,'TGT_FUNC_ID','');
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',''); 
       ihook.setColumnValue(row,'PAREN','');


                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
if (v_sel_id is null) then
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
        ihook.setColumnValue(row,'MECM_ID',-1);
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
        ihook.setColumnValue(row,'TGT_FUNC_ID','');
            ihook.setColumnValue(row,'TGT_FUNC_PARAM',''); 
       ihook.setColumnValue(row,'PAREN','');
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
end if;
 --  raise_application_error(-20000,rows.count);
            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
  hookoutput.actions := actions;
  hookoutput.message := 'Semantic mapping generated.';
  end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     nci_util.debugHook('GENERAL', v_data_out);

end;

function getManualMapForm (row in out t_row) return t_forms
is
  forms t_forms;
  form1 t_form;
  rows t_rows;
  rowsetmap t_rowset;
begin

          rows := t_rows();

          for cur in ( select * from nci_mdl_map where item_id = ihook.getColumnValue(row,'MDL_MAP_ITEM_ID') and ver_nr = ihook.getColumnValue(row,'MDL_MAP_VER_NR')) loop
          ihook.setColumnValue(row, 'SRC_MDL_ITEM_ID', cur.src_mdl_item_id);
          ihook.setColumnValue(row, 'SRC_MDL_VER_NR', cur.src_mdl_ver_nr);
          ihook.setColumnValue(row, 'TGT_MDL_ITEM_ID', cur.tgt_mdl_item_id);
          ihook.setColumnValue(row, 'TGT_MDL_VER_NR', cur.tgt_mdl_ver_nr);
            ihook.setColumnValue(row, 'MECM_ID', -1);
          end loop;

          rows.extend;
          rows(rows.last) := row;
          rowsetmap := t_rowset(rows, 'Model Map Characteristics (Insert)', 1, 'NCI_MEC_MAP');
        forms                  := t_forms();
    form1                  := t_form('Model Map Characteristics (Insert)', 2,1);
    form1.rowset :=rowsetmap;
    forms.extend;    forms(forms.last) := form1;

 return forms;
 end;

function getAddManualMapQuestion return t_question 
 is
  question t_question;
  answer t_answer;
  answers t_answers;
  begin
 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add New Mapping');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add Manual Mapping', ANSWERS);
    return question;
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
  v_Valid boolean;
  v_temp integer;
  v_err_str varchar2(1000);

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori := hookInput.originalRowset.rowset(1);

    if hookInput.invocationNumber = 0 then

    row := t_row();
          rows := t_rows();

          ihook.setColumnValue(row, 'MDL_MAP_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
          ihook.setColumnValue(row, 'MDL_MAP_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
           ihook.setColumnValue(row, 'MAP_DEG', 120);

    HOOKOUTPUT.QUESTION    := getAddManualMapQuestion;
    hookoutput.forms := getManualMapForm(row);

  ELSE
      forms              := hookInput.forms;
      form1              := forms(1);
      rowmap := form1.rowset.rowset(1);

      ihook.setColumnValue(rowmap, 'MDL_MAP_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
          ihook.setColumnValue(rowmap, 'MDL_MAP_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
    ihook.setColumnValue(rowmap, 'MEC_SUB_GRP_NBR',1);
    for x in (select * from nci_mdl_map where item_id =  ihook.getColumnValue(row_ori,'ITEM_ID')
    and ver_nr =  ihook.getColumnValue(row_ori,'VER_NR')) loop
     ihook.setColumnValue(rowmap, 'SRC_MDL_ITEM_ID', x.SRC_MDL_ITEM_ID);
          ihook.setColumnValue(rowmap, 'SRC_MDL_VER_NR', x.SRC_MDL_VER_NR);
        ihook.setColumnValue(rowmap, 'TGT_MDL_ITEM_ID', x.TGT_MDL_ITEM_ID);
          ihook.setColumnValue(rowmap, 'TGT_MDL_VER_NR', x.TGT_MDL_VER_NR);

    end loop;
        -- check if the source and target char are from the correct models
        if (ihook.getColumnValue(rowmap,'SRC_MEC_ID') is not null) then
        v_valid := false;
       for cur in (select *  from VW_NCI_MEC_NO_CDE where  mec_id = ihook.getColumnValue(rowmap,'SRC_MEC_ID') and 
        mdl_item_id =ihook.getColumnValue(rowmap,'SRC_MDL_ITEM_ID')  and mdl_ver_nr = ihook.getColumnValue(rowmap,'SRC_MDL_VER_NR')) loop
        v_valid := true;
        ihook.setColumnValue(rowmap, 'SRC_CDE_ITEM_ID', cur.cde_item_id);
             ihook.setColumnValue(rowmap, 'SRC_CDE_VER_NR', cur.cde_ver_nr);

        end loop;
     --   raise_application_error(-20000,ihook.getColumnValue(rowmap,'SRC_MDL_ITEM_ID') );
        if (v_valid = false) then
            v_err_Str := 'Source Characteristic is not from the correct model;';

            end if;

        end if;
      
      if (ihook.getColumnValue(rowmap,'TGT_MEC_ID') is not null) then
          v_Valid := false;
           for cur in (select *  from  VW_NCI_MEC_NO_CDE where  mec_id = ihook.getColumnValue(rowmap,'TGT_MEC_ID') and 
        mdl_item_id =ihook.getColumnValue(rowmap,'TGT_MDL_ITEM_ID')  and mdl_ver_nr = ihook.getColumnValue(rowmap,'TGT_MDL_VER_NR')) loop
          v_valid := true;
        ihook.setColumnValue(rowmap, 'TGT_CDE_ITEM_ID', cur.cde_item_id);
             ihook.setColumnValue(rowmap, 'TGT_CDE_VER_NR', cur.cde_ver_nr);
        end loop;
         if (v_valid = false) then
           v_err_Str := v_err_Str || ' Target Characteristic is not from the correct model;';
         end if;
    end if;
        --check if they are duplicates
        if (v_valid = false) then

HOOKOUTPUT.QUESTION    := getAddManualMapQuestion;
         hookoutput.forms := getManualMapForm(rowmap);
         hookoutput.message := v_err_str;
        end if;
        if (v_valid = true) then
            rows := t_rows();
            rows.extend;    rows(rows.last) := rowmap;
            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,1,'insert');
            actions.extend;
            actions(actions.last) := action;

            hookoutput.message := 'Manual Map created successfully.';
                hookoutput.actions := actions;
       end if;
 end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  nci_util.debugHook('GENERAL', v_data_out);
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
row_ori :=  hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR');

    execDeriveTarget (v_item_id, v_ver_nr);
             hookoutput.message := 'Derivation of Target Characteristic completed.';
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

     end;


procedure    execDeriveTarget (v_item_id in number, v_ver_nr in number) as
i integer;
begin

    execute immediate 'ALTER TABLE NCI_MEC_MAP DISABLE ALL TRIGGERS';
    --    raise_application_Error(-20000, v_item_id || v_ver_nr);
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
commit;
for cux in (Select * from nci_mec_map where mecm_id = cur.mecm_id and tgt_mec_id_derv is null and MDL_MAP_ITEM_ID=v_item_id and MDL_MAP_VER_NR=v_ver_nr) loop
update nci_mec_map set tgt_mec_id_derv = (select min(tgt_mec_id) from nci_mec_map where mec_map_nm = cur.mec_map_nm and MDL_MAP_ITEM_ID=cur.MDL_MAP_ITEM_ID and MDL_MAP_VER_NR = cur.MDL_MAP_VER_NR
and tgt_mec_id is not null and mec_sub_grp_nbr > cur.mec_sub_grp_nbr )
where mecm_id = cur.mecm_id and tgt_mec_id_derv is null ;
end loop;
commit;
end loop;

update nci_mec_map set tgt_mec_id_derv =tgt_mec_id where tgt_mec_id_derv is null and tgt_mec_id is not null and MDL_MAP_ITEM_ID=v_item_id and MDL_MAP_VER_NR=v_ver_nr;
commit;


for curx in (Select * from nci_mec_map where  MDL_MAP_ITEM_ID=v_item_id and MDL_MAP_VER_NR=v_ver_nr order by mec_map_nm, mec_sub_grp_nbr) loop
update nci_mec_map set tgt_mec_id_derv = (select min(tgt_mec_id_derv) from nci_mec_map where mec_map_nm = curx.mec_map_nm and MDL_MAP_ITEM_ID=v_item_id and MDL_MAP_VER_NR = v_ver_nr
and tgt_mec_id_derv is not null )
where mecm_id = curx.mecm_id and tgt_mec_id_derv is null ;
end loop;
commit;

     execute immediate 'ALTER TABLE NCI_MEC_MAP ENABLE ALL TRIGGERS';
     --  raise_application_Error(-20000, v_item_id || v_ver_nr);
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
 v_tgt_mdl_nm || map.TGT_ELMNT_PHY_NAME || '.'|| map.TGT_PHY_NAME TMEC_NM, upper(ob.obj_key_Desc) TARGET_FUNCTION, 
 SET_TARGET_DEFAULT, OPERATOR, OPERAND_TYPE, FLOW_CONTROL, PARENTHESIS, RIGHT_OPERAND, LEFT_OPERAND from VW_MDL_MAP_IMP_TEMPLATE  map, obj_key ob
where map.MODEL_MAP_ID= v_item_id and map.MODEL_MAP_VERSION = v_ver_nr
and map.FLOW_CONTROL is null and map.PARENTHESIS is null 
and map.OPERATOR is null and map.LEFT_OPERAND is null and map.RIGHT_OPERAND is null and map.OPERAND_TYPE is null and 
map.TGT_PHY_NAME is not null and map.target_function_id = ob.obj_key_id (+)) loop
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

for cur in (select map.mecm_id , map.src_mec_id, v_src_mdl_nm || map.SRC_ELMNT_PHY_NAME || '.' || map.SRC_PHY_NAME SMEC_NM,
 v_tgt_mdl_nm || map.TGT_ELMNT_PHY_NAME || '.'|| map.TGT_PHY_NAME TMEC_NM, upper(ob.obj_key_Desc) TARGET_FUNCTION, 
 SET_TARGET_DEFAULT, OPERATOR, OPERAND_TYPE, FLOW_CONTROL, PARENTHESIS, RIGHT_OPERAND, LEFT_OPERAND from VW_MDL_MAP_IMP_TEMPLATE  map, obj_key ob
where map.MODEL_MAP_ID= v_item_id and map.MODEL_MAP_VERSION = v_ver_nr
and MAPPING_GROUP_NAME = curouter.MAPPING_GROUP_NAME 
and map.target_function_id = ob.obj_key_id (+) order by DERIVATION_GROUP_ORDER) loop
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

-- v_cur_idx is the line that the function was found
function getFuncPcode (v_mm_id in number, v_mm_ver in number, v_grp_nm in varchar2, v_init_tgt_func_param in  varchar2, v_cur_idx in out integer, v_max_idx in integer,
v_func_id in integer, v_open_paren_id in integer, v_close_paren_id in integer,  v_err in out integer)  return varchar2
is
i integer;
v_open_found boolean := false;
v_close_fond boolean := false;
v_rtn_str varchar2(1000);
v_func_nm varchar2(255);
v_found boolean;
begin


select obj_key_Desc into v_func_nm from obj_key where obj_key_id = v_func_id;

i := v_cur_idx;
v_found := false;
v_rtn_str := ' ' || v_func_nm || '(' ;

if ( v_init_tgt_func_param  is not null) then 
v_rtn_str := v_rtn_str ||  v_init_tgt_func_param || ',' ; 
end if;


while i <= v_max_idx and v_found = false loop
i := i+1;
for cur in (select tgt_func_id , paren, decode(upper(tgt_func_param), 'SOURCE', smec.ME_MEC_PHY_NM, tgt_func_param) tgt_func_param from  nci_mec_Map map, VW_NCI_MEC_NO_CDE smec where map.mdl_map_item_id = v_mm_id 
and map.mdl_map_ver_nr = v_mm_ver and upper(MEC_MAP_NM) = v_grp_nm and map.src_mec_id = smec.mec_id (+)
and MEC_SUB_GRP_NBR =i ) loop

-- looking for open parenthesis first

   if (cur.tgt_func_id is not null) then -- another function found
      if (cur.paren <> v_open_paren_id) then
          v_rtn_str := v_rtn_str || 'Target function found with no open parenthesis.' ;
          return replace(v_rtn_str,',,',',');
      else
       /*   if (cur.TGT_FUNC_PARAM is not null) then
      --  v_rtn_str := v_rtn_str || cur.TGT_FUNC_PARAM || ',';
              if(substr(trim(v_rtn_str),length(trim(v_rtn_str)),1) in ( '(',',')) then
                     v_rtn_str := v_rtn_str ||  cur.TGT_FUNC_PARAM ;
              else
                     v_rtn_str := v_rtn_str || ',' || cur.TGT_FUNC_PARAM ;
              end if;
          end if;*/
         v_rtn_str := v_rtn_str  ||',' || getFuncPcode (v_mm_id, v_mm_ver, v_grp_nm, cur.tgt_func_param, i, v_max_idx,
         cur.tgt_func_id,v_open_paren_id, v_close_paren_id, v_err) ;
         exit;
--  v_rtn_str := v_rtn_str  ||',' || getFuncPcode (v_mm_id, v_mm_ver, v_grp_nm, '', i, v_max_idx,
 --   cur.tgt_func_id,v_open_paren_id, v_close_paren_id, v_err) ;
      end if;
   else
       if (cur.TGT_FUNC_PARAM is not null) then
    --    v_rtn_str := v_rtn_str || cur.TGT_FUNC_PARAM || ',';
        if(substr(trim(v_rtn_str),length(trim(v_rtn_str)),1)  in ( '(',',')) then
              v_rtn_str := v_rtn_str ||  cur.TGT_FUNC_PARAM ;
        else
             v_rtn_str := v_rtn_str || ',' || cur.TGT_FUNC_PARAM ;
        end if;
   end if;
  -- look for close paren
  if cur.paren = v_close_paren_id  then
     --   v_rtn_str := substr(v_rtn_str,2) || ' ) ' ;
     if (substr(trim(v_rtn_str),length(trim(v_rtn_Str)),1) = ',') then
        v_rtn_str := substr(trim(v_rtn_str),1,length(trim(v_rtn_str))-1);
     end if;
     v_rtn_str := v_rtn_str || ' ) ' ;
     v_found := true;
 -- return v_rtn_str;
  end if;


 end if;

 --if (i = v_max_idx ) then
  --v_err := 1;
  --  v_rtn_str := 'Inconsistent Rule Found';

  --end if;
  v_cur_idx := i;
end loop;
end loop;

 return replace(v_rtn_str,',,',',');
end ;


procedure spGeneratePcodeNew(v_data_in IN CLOB,    v_data_out OUT CLOB)
as
v_temp integer;
   hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori t_row;
    v_item_id number;
    v_ver_nr number(4,2);
  --  v_src_mdl_nm varchar2(255);
  --  v_tgt_mdl_nm varchar2(255);
    v_str varchar2(8000);
    v_open_paren integer;
    v_close_paren integer;
    v_err integer := 0;
    j integer;
    v_assign boolean;
    v_min_grp integer;
    inif boolean;
 begin
     hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  select obj_key_id into v_open_paren from obj_key where obj_typ_id = 58 and obj_key_Desc = '(';
   select obj_key_id into v_close_paren from obj_key where obj_typ_id = 58 and obj_key_Desc = ')';


  row_ori := hookInput.originalRowset.rowset(1);
  v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
  v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
   execDeriveTarget (v_item_id, v_ver_nr);
 /* for cur in (select item_nm from admin_item ai, NCI_MDL_MAP mm where ai.item_id = mm.SRC_MDL_ITEM_ID 
  and ai.ver_nr = mm.SRC_MDL_VER_NR and mm.item_id = v_item_id and mm.ver_nr = v_ver_nr) loop
  v_src_mdl_nm := cur.item_nm || '.';
  end loop;
  for cur in (select item_nm from admin_item ai, NCI_MDL_MAP mm where ai.item_id = mm.TGT_MDL_ITEM_ID 
  and ai.ver_nr = mm.TGT_MDL_VER_NR and mm.item_id = v_item_id and mm.ver_nr = v_ver_nr) loop
  v_tgt_mdl_nm := cur.item_nm || '.';
  end loop;
  */
    execute immediate 'ALTER TABLE NCI_MEC_MAP DISABLE ALL TRIGGERS';

update nci_mec_map set PCODE_SYSGEN = null where MDL_MAP_ITEM_ID= v_item_id and MDL_MAP_VER_NR = v_ver_nr;
commit;
-- Straight assignment
--raise_application_error(-20000,'HEre');
/*
for cur in (select map.mecm_id , map.src_mec_id, map.tgt_mec_id,  map.SRC_ELMNT_PHY_NAME || '.' || map.SRC_PHY_NAME SMEC_NM,
  trim(map.TGT_ELMNT_PHY_NAME || '.'|| map.TGT_PHY_NAME) TMEC_NM, TARGET_FUNCTION, 
 SET_TARGET_DEFAULT, OPERATOR, OPERAND_TYPE, FLOW_CONTROL, PARENTHESIS, RIGHT_OPERAND, LEFT_OPERAND from VW_MDL_MAP_IMP_TEMPLATE  map
where map.MODEL_MAP_ID= v_item_id and map.MODEL_MAP_VERSION = v_ver_nr
and map.FLOW_CONTROL is null and map.PARENTHESIS is null 
and map.OPERATOR is null and map.LEFT_OPERAND is null 
and map.RIGHT_OPERAND is null and map.OPERAND_TYPE is null and 
map.TGT_PHY_NAME is not null
and map.map_deg in (86,87,120)) loop
if (cur.src_mec_id is null) then
update nci_mec_map set PCODE_SYSGEN =   cur.tmec_nm || ' = ' || 
cur.SET_TARGET_DEFAULT  where mecm_id = cur.mecm_id;
end if;
--if (cur.src_mec_id is not null and cur.target_function = 'EQUALS') then
if (cur.src_mec_id is not null and cur.tgt_mec_id is not null) then
update nci_mec_map set PCODE_SYSGEN =  cur.tmec_nm || ' = ' || 
cur.SMEC_NM where mecm_id = cur.mecm_id;
end if;

end loop;
commit;
*/

-- go by mapping group
for curouter in (select  MAPPING_GROUP_NAME, min(DERIVATION_GROUP_ORDER) min_grp_ord, max(derivation_group_order) max_grp_ord from VW_MDL_MAP_IMP_TEMPLATE  map
where map.MODEL_MAP_ID= v_item_id and map.MODEL_MAP_VERSION = v_ver_nr
and (map.FLOW_CONTROL is not null or map.PARENTHESIS is not null or map.OPERATOR is not null or map.LEFT_OPERAND is not null 
or map.RIGHT_OPERAND is not null or map.OPERAND_TYPE is not null) and map.map_deg in (86,87,120)
and pcode_sysgen is null
--and upper(MAPPING_GROUP_NAME) like '%RECUR%' 
group by MAPPING_GROUP_NAME) loop
v_str := '';
v_assign := false;
inIf := false;
v_min_grp := curouter.min_grp_ord;
j := curouter.min_grp_ord;
while j <= curouter.max_grp_ord loop
v_assign := false;
for cur in (select map.mecm_id ,map.DERIVATION_GROUP_ORDER, map.src_mec_id,  map.SRC_ELMNT_PHY_NAME || '.' || map.SRC_PHY_NAME SMEC_NM,
trim(map.SRC_ELMNT_PHY_NAME || '.' || map.SRC_PHY_NAME) SRC_PHY_NAME,trim(map.TGT_ELMNT_PHY_NAME || '.'|| map.TGT_PHY_NAME) TGT_PHY_NAME,
  map.TGT_ELMNT_NAME || '.'|| map.TGT_MEC_NAME TMEC_NM, target_function_id, upper(ob.obj_key_desc) TARGET_FUNCTION, map.tgt_mec_id,
 decode(upper(TARGET_FUNCTION_PARAM),'SOURCE',trim(map.SRC_ELMNT_PHY_NAME || '.' || map.SRC_PHY_NAME),TARGET_FUNCTION_PARAM) TARGET_FUNCTION_PARAM,
 decode(upper(SET_TARGET_DEFAULT),'SOURCE',trim(map.SRC_ELMNT_PHY_NAME || '.' || map.SRC_PHY_NAME),SET_TARGET_DEFAULT) SET_TARGET_DEFAULT, OPERATOR, OPERAND_TYPE, FLOW_CONTROL, PARENTHESIS, 
 decode(upper(RIGHT_OPERAND),'SOURCE',trim(map.SRC_ELMNT_PHY_NAME || '.' || map.SRC_PHY_NAME),right_operand) right_operand,
 decode(upper(LEFT_OPERAND),'SOURCE',trim(map.SRC_ELMNT_PHY_NAME || '.' || map.SRC_PHY_NAME),LEFT_operand) LEFT_OPERAND 
 from VW_MDL_MAP_IMP_TEMPLATE  map, obj_key ob
where map.MODEL_MAP_ID= v_item_id and map.MODEL_MAP_VERSION = v_ver_nr and map.target_function_id = ob.obj_key_id (+)
and MAPPING_GROUP_NAME = curouter.MAPPING_GROUP_NAME and  map.DERIVATION_GROUP_ORDER = j order by DERIVATION_GROUP_ORDER) loop


  if (cur.FLOW_CONTROL ='IF' or cur.OPERATOR in ('AND','OR')) then
    if (cur.FLOW_CONTROL ='IF') then
        inif := true;
    end if;
    v_str := v_str ||   nvl(cur.FLOW_CONTROL,'') || ' ' ||  nvl(cur.OPERATOR,'') || ' ';
  -- if function
     if (cur.target_function is not null) then
          v_str :=v_Str || nvl(getFuncPcode (v_item_id, v_ver_nr, upper(curouter.MAPPING_GROUP_NAME), cur.target_function_param, j, curouter.max_grp_ord,
            cur.target_function_id,v_open_paren, v_close_paren, v_err),'Error') || ' ';
            j := j-1;
    else
       v_str := v_Str || cur.left_operand || ' ' ;
    end if;

    end if;

    if (inif = true and cur.operand_type is not null) then 
    v_str := v_str ||     ' ' || cur.OPERAND_TYPE || ' ' || cur.RIGHT_OPERAND || ' '  ;
    end if;
    if (inif = true and (cur.FLOW_CONTROL = 'THEN' or cur.FLOW_CONTROL = 'ELSE')) then 
    v_str :=   v_str  ||' ' || nvl(cur.FLOW_CONTROL,'') || ' '  ;
    end if;


    if ( cur.target_function ='EQUALS' and cur.tgt_mec_id is not null
    and (cur.TARGET_FUNCTION_PARAM is not null or cur.src_mec_id is not null)) then 
      v_str := v_str ||  ' ' || cur.TGT_PHY_NAME || ' = ' ||  nvl(cur.TARGET_FUNCTION_PARAM,cur.SMEC_NM) || ' '  ; 
      if (cur.flow_control is null and inif = false) then
        v_assign := true;
        j:= j+1;  -- accounting for the close bracket.
      end if;
      end if;
   --   if (upper(curouter.MAPPING_GROUP_NAME) like '%RISK%') then
    --  raise_application_error(-20000, 'Here' || cur.tgt_phy_name || j);
     -- end if;
 --   end if;


    if (cur.FLOW_CONTROL = 'ENDIF')  then 
      v_str := v_str  ||' ' || ' ENDIF;' ; 
      inIf := false;
      v_Assign := true;

    end if;
  if ( cur.target_function <> 'EQUALS' and cur.target_function is not null and cur.tgt_mec_id is not null) then
        if (cur.parenthesis <> '(') then
            v_Str := v_str || 'Function found with no open parenthesis.';
            v_assign := true;
        else
            v_str := v_str || cur.TGT_PHY_NAME || ' = ' || getFuncPcode (v_item_id, v_ver_nr, upper(curouter.MAPPING_GROUP_NAME), cur.target_function_param, j, curouter.max_grp_ord,
            cur.target_function_id,v_open_paren, v_close_paren, v_err) || ' ';
-- raise_application_error(-20000, upper(curouter.MAPPING_GROUP_NAME) || j);
            v_assign := true;
        end if;
    end if;


end loop;
if (v_assign = true and inIf = false) then
update nci_mec_map set PCODE_SYSGEN =  trim(v_str)  where MDL_MAP_ITEM_ID= v_item_id and MDL_MAP_VER_NR = v_ver_nr and MEC_MAP_NM=curouter.mapping_group_name
and mec_sub_grp_nbr=v_min_grp;
update nci_mec_map set PCODE_SYSGEN =  ''  where MDL_MAP_ITEM_ID= v_item_id and MDL_MAP_VER_NR = v_ver_nr and MEC_MAP_NM=curouter.mapping_group_name
and mec_sub_grp_nbr>v_min_grp and mec_sub_grp_nbr <j;
commit;
v_Assign := false;
v_min_grp := j+1;
v_str := '';
end if;
j:= j+1;
end loop;
--raise_application_error(-20000,v_str);

--update nci_mec_map set PCODE_SYSGEN =  upper(v_str)  where MDL_MAP_ITEM_ID= v_item_id and MDL_MAP_VER_NR = v_ver_nr and MEC_MAP_NM=curouter.mapping_group_name
--and mec_sub_grp_nbr=curouter.min_grp_ord;
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
        for cur in (select * from nci_mec_val_map mecvm where (mecvm.src_mec_id = v_src or mecvm.tgt_mec_id = v_tgt) and 
        mdl_map_item_id = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID') and  mdl_map_ver_nr = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR')) loop
            v_found := true;
            --v_str := v_str || ' ' || cur.mecvm_id;
            --hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'WARNING: Value Mapping Exists. Click Confirm to proceed.');
        end loop;
    end loop;
        if (v_found = false) then
            hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'Please confirm deletion of Model Mapping Rule.');
        elsif (v_found = true) then
            hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'WARNING: Value Mappings exist and must be deleted manually');
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


procedure spUpdStatsModelMap( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    row_ori t_row;
 v_item_id number;
v_ver_nr number(4,2);


BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    for i in 1..hookInput.originalRowset.rowset.count loop
        row_ori :=  hookInput.originalRowset.rowset(i);
        v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
-- INT_1 - total rules, INT_2 - Semantica, INT_3 - Derived from, INT_4 - no CDE, INT_5 - not mapped yet, INT_6 - Ignore - Int_7 - # groups, INT_8 - With transformation rules
          updStatsModelMap(v_item_id, v_ver_nr);
      
    end loop;
hookoutput.message :=  'Model Mapping Statistics updated.';


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);


END;


procedure spReorderModelMap( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    row_ori t_row;
 v_item_id number;
v_ver_nr number(4,2);
i integer;

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
        row_ori :=  hookInput.originalRowset.rowset(1);
        v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
    for cur in (select mec_map_nm from nci_mec_Map where mdl_map_item_id = v_item_id and mdl_map_ver_nr= v_ver_nr group by mec_map_nm having count(*) > 1) loop
    i:= 1;
      for curinner in (select * from nci_mec_map where mdl_map_item_id = v_item_id and mdl_map_ver_nr= v_ver_nr and mec_map_nm = cur.mec_map_nm order by mec_sub_grp_nbr) loop
       if (curinner.mec_sub_grp_nbr <> i) then
         update nci_mec_map set mec_sub_grp_nbr = i where mecm_id = curinner.mecm_id;
        end if;
        i := i+1;
      end loop;
    end loop;
    commit;
hookoutput.message :=  'Model Mapping reordered.';


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);


END;

procedure updStatsModelMap (v_item_id in number, v_ver_nr in number) 
as
i integer;
begin

  update ADMIN_ITEM set (INT_1, INT_2, INT_3, INT_4, INT_5, INT_6, INT_7, INT_8) =
        (Select count(*), 
        sum(decode(map_deg, 86,1 ,decode(map_deg, 87, 1,0))) ,
        sum(decode(map_deg, 120,1,0)),
        sum(decode(map_deg, 129,1,0)),
        sum(decode(map_deg, 130,1,0)),
        sum(decode(map_deg, 131,1,0)),
        count(distinct mec_map_nm),
        sum(decode(TRNS_DESC_TXT,null,0,1))
        from nci_mec_Map where mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr)
        where item_id = v_item_id and ver_nr = v_ver_nr;
    commit;
    end;
    
-- Function Validation
  procedure    spModelMapFuncValidation(v_item_id in number, v_ver_nr in number, v_open_paren in integer, v_close_paren in integer, rows in out t_rows)
AS
row t_row;
v_min_param integer;
v_max_param integer;
v_cur_param integer;
v_num_open integer;
v_num_close integer;
v_func_query integer;
v_cur_func varchar2(255);
BEGIN
 
 select obj_key_id into v_func_query from obj_key where obj_key_desc = 'QUERY' and obj_typ_id = 51;
 
 
 for curfunc in (select distinct tgt_func_id from nci_mec_map where mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr 
 and tgt_func_id is not null and tgt_func_id in (select obj_key_id from obj_key where 
 obj_typ_id = 51 and (min_cnt is not null or max_cnt is not null))) loop
 select nvl(min_cnt,0) , nvl(max_cnt,0) into  v_min_param,v_max_param from obj_key where obj_key_id = curfunc.tgt_func_id;
 select obj_key_desc into v_cur_func from obj_key where obj_key_Id = curfunc.tgt_func_id;
 -- choose all groups and rule number where the functions in found and correcsponding open paren is found and there is no error
 for curgrp in (select mec_map_nm, mecm_id, tgt_func_param, mec_sub_grp_nbr, tgt_func_id from nci_mec_map where mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr 
 and tgt_func_id = curfunc.tgt_func_id and paren = v_open_paren  and ctl_val_msg is null ) loop
 --and  mec_map_nm = 'CONDITION_OCCURRENCE.CONDITION.condition_type_concept_id.CONDITION_SOURCE') loop
 v_num_open := 1;
 v_cur_param :=0;
 v_num_close := 0;
 if (curgrp.tgt_func_param is not null) then -- function parameters specified in the same row as ( 
 v_cur_param :=1;
 if (curgrp.tgt_func_id = v_func_query and curgrp.tgt_func_param = 'XWALK') then -- v_min changes
 v_min_param := 6;
 v_max_param := 6;
 end if;
 if (curgrp.tgt_func_id = v_func_query and curgrp.tgt_func_param = 'VALUE_MAP') then -- v_max changes
 v_min_param := 4;
 v_max_param := 4;
 end if;
  if (curgrp.tgt_func_id = v_func_query and curgrp.tgt_func_param not in('XWALK', 'VALUE_MAP')) then -- Parameter value is incored     
        row :=     t_row();
        ihook.setColumnValue(row,'Rule Type','Function Parameter');
 ihook.setColumnValue(row, 'Rule Description','Function QUERY first parameter is incorrect. Expected Parameters: XWALK, VALUE_MAP. Current Paramter: ' || curgrp.tgt_func_param );
 ihook.setColumnValue(row, 'Rule ID', curgrp.mecm_id);
 ihook.setColumnValue(row, 'Characteristic Group', curgrp.mec_map_nm);
  rows.extend;    rows(rows.last) := row;
  end if;
 end if;
 -- choose specific group
 
 for cursubgrp in (select * from nci_mec_map where mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr and mec_sub_grp_nbr > curgrp.mec_sub_grp_nbr and
 mec_map_nm = curgrp.mec_map_nm order by MEC_SUB_GRP_NBR) loop
    if (cursubgrp.paren = v_close_paren) then 
        v_num_close := v_num_close +1;
    elsif (cursubgrp.paren = v_open_paren) then 
            v_num_open := v_num_open +1;
            v_cur_param := v_cur_param + 1;
    else -- null
        if (v_num_open = v_num_close + 1) then 
            v_cur_param := v_cur_param + 1;
        end if;
    end if;
    if (v_num_open = v_num_close) then
    exit;
    end if;
 end loop;
 
-- raise_application_error(-20000,v_num_open || '-'|| v_num_close || '-' || v_min_param || '-' || v_max_param || '-' || v_cur_param);
 
    
    if (v_cur_param < v_min_param or v_cur_param > v_max_param) then -- reached end-- determine param count        
        row :=     t_row();
        ihook.setColumnValue(row,'Rule Type','Function Parameter');
 ihook.setColumnValue(row, 'Rule Description','Function does not have the right number of parameters. Function: ' || v_cur_func || '; Min/Max/Current: ' || v_min_param || '/' || v_max_param || '/' || v_cur_param );
 ihook.setColumnValue(row, 'Rule ID', curgrp.mecm_id);
 ihook.setColumnValue(row, 'Characteristic Group', curgrp.mec_map_nm);
  rows.extend;    rows(rows.last) := row;
  end if;
   if (v_num_open <> v_num_close) then
        row :=     t_row();
        ihook.setColumnValue(row,'Rule Type','Function Parameter');
 ihook.setColumnValue(row, 'Rule Description','Function does not have close parathesis. Function: ' || v_cur_func || '; Open/Close Parenthesis count: ' || v_num_open || '/' ||v_num_close );
 ihook.setColumnValue(row, 'Rule ID', curgrp.mecm_id);
 ihook.setColumnValue(row, 'Characteristic Group', curgrp.mec_map_nm);
  rows.extend;    rows(rows.last) := row;
  
   end if;
 end loop; -- group
 end loop;

  
  
  end;
      
END;
/
