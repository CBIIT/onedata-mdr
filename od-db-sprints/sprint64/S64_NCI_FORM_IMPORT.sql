create or replace PACKAGE            nci_form_import AS

procedure spParseForm (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spValidateForm (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spValidateQuestion (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spMatchQuestion (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2);
procedure spCreateImportedForm (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure ParseModuleQuestion (row_ori in t_row, actions in out t_actions);
FUNCTION getVVCount (v_nm IN varchar2) RETURN integer;
function getVV(v_nm in varchar2, v_idx in integer, v_max in integer) return varchar2 ;
END;
/
create or replace PACKAGE BODY            nci_form_import AS
c_ver_suffix varchar2(5) := 'v1.00';

procedure spParseForm (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
   hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_item_id number;
    i integer;
     actions t_actions := t_actions();
    action t_actionRowset;
  
begin
   hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
        -- Parse Form Name
        
  if (ihook.getColumnValue(row_ori,'CTL_VAL_STUS') = 'PROCESSED') then
  raise_application_Error(-20000,'Form already processed.');
  return;
  end if;
  if (substr(ihook.getColumnValue(row_ori, 'SRC_FORM_NM'),1,2) = 'PX') then -- For PhenX forms, do not change PX to Px
        ihook.setColumnValue(row_ori, 'FORM_NM', 'PX' || initcap(replace(substr(ihook.getColumnValue(row_ori, 'SRC_FORM_NM'),3),'_',' ')));
  else
        ihook.setColumnValue(row_ori, 'FORM_NM', initcap(replace(ihook.getColumnValue(row_ori, 'SRC_FORM_NM'),'_',' ')));
  end if;
  -- Protocol
  if (ihook.getColumnValue(row_ori,'IMP_PRTCL_NM') is not null) then
  for curprot in (Select * from admin_item where admin_item_typ_id = 50 and upper(item_long_nm) = upper(ihook.getColumnValue(row_ori,'IMP_PRTCL_NM'))) loop
        ihook.setColumnValue(row_ori, 'PRTCL_ITEM_ID', curprot.item_id);
        ihook.setColumnValue(row_ori, 'PRTCL_VER_NR', curprot.ver_nr);
        
  end loop;
  end if;
        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'PARSED');
        rows.extend;    rows(rows.last) := row_ori;
        ParseModuleQuestion(row_ori, actions);
     
    end loop;
        action := t_actionrowset(rows, 'Form Import Header', 2,1,'update');
    --     action := t_actionrowset(rows, 'NCI_USR_CART', 1,1,'insert');
     actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
               hookoutput.message := 'Form Parsed';
          
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);    
 -- nci_util.debugHook('GENERAL', v_data_out);
       
 -- raise_application_error(-20000,'Work in Progress');
  
end;

procedure ParseModuleQuestion (row_ori in t_row, actions in out t_actions)
as
    rows      t_rows;
    row          t_row;
    row_cur t_row;
      action t_actionRowset;
  j integer;
  i integer;
  v_Str varchar2(4000);
  v_temp number;
  v_cde_nm varchar2(4000);
begin

rows := t_rows();
for cur in (select * from NCI_STG_FORM_QUEST_IMPORT where FORM_IMP_ID = ihook.getColumnValue(row_ori, 'FORM_IMP_ID')) loop
    row := t_row();
    ihook.setColumnValue(row,'QUEST_IMP_ID', cur.QUEST_IMP_ID);
    -- Derive module name with Initial Captial and removing _
    ihook.setColumnValue(row,'MOD_NM', initcap(replace(cur.SRC_MOD_NM,'_',' ')));
    -- Parse SRC_CDE_NM (Variable Annotation
    if (cur.SRC_CDE_NM is not null and cur.SRC_CDE_NM like '%v%') then -- 3655869_v1_0 "cadsrcde_"+publicID+"_v"+major version+"_"+minor version

    v_cde_nm := replace(cur.src_cde_nm,'cadsrcde_','');
    v_cde_nm := replace(v_cde_nm,'cadsrcde','');
   -- raise_application_error(-20000,substr(v_cde_nm, 1, instr(v_cde_nm,'v')-1));
    if (REGEXP_LIKE(substr(v_cde_nm, 1, instr(v_cde_nm,'v')-2), '^[[:digit:]]+$')=true) then
        ihook.setColumnValue(row,'CDE_ITEM_ID',to_number(substr(v_cde_nm, 1, instr(v_cde_nm,'v')-2)));
        v_cde_nm := replace(substr(v_cde_nm, instr(v_cde_nm,'v')+1),'_','.');
       ihook.setColumnValue(row,'CDE_VER_NR',to_number(v_cde_nm));
    end if;
    --    raise_application_error(-20000,ihook.getColumnValue(row,'CDE_ITEM_ID') || '  Version ' || ihook.getColumnValue(row,'CDE_VER_NR'));
    end if;
    ihook.setColumnValue(row,'CTL_VAL_STUS', 'PARSED');
    rows.extend;    rows(rows.last) := row;
    delete from NCI_STG_FORM_VV_IMPORT where quest_imp_id = cur.quest_imp_id;
    commit;
    delete from onedata_ra.NCI_STG_FORM_VV_IMPORT where quest_imp_id = cur.quest_imp_id;
    commit;
    if (cur.src_vv is not null) then
    j := getVVCount(cur.SRC_VV);
 --   raise_application_error(-20000, j || cur.src_vv);
    for i in 1..j loop
    
  --  raise_application_error(-20000,getVV(cur.src_vv,i,j));
  v_str := getVV(cur.src_vv,i,j);
  select od_seq_FORM_IMPORT.nextval into v_temp from dual;
  
    insert into NCI_STG_FORM_VV_IMPORT (VAL_IMP_ID,QUEST_IMP_ID,SRC_PERM_VAL,SRC_VM_NM)
    values (v_temp, cur.QUEST_IMP_ID, trim(substr( v_str,1,instr(v_str,',')-1)), trim(substr(v_str, instr(v_str,',')+1)));
 
    insert into onedata_ra.NCI_STG_FORM_VV_IMPORT (VAL_IMP_ID,QUEST_IMP_ID,SRC_PERM_VAL,SRC_VM_NM)
    values (v_temp, cur.QUEST_IMP_ID, trim(substr( v_str,1,instr(v_str,',')-1)), trim(substr(v_str, instr(v_str,',')+1)));
    end loop;
    commit;
    end if;
    end loop;
        action := t_actionrowset(rows, 'Form Module-Question Import', 2,1,'update');
      actions.extend;
        actions(actions.last) := action;
  
end;


/* Used when parsing user input during creation of concept-related AI entities like DEC, Rep Term, VM */
FUNCTION getVVCount (v_nm IN varchar2) RETURN integer IS
    V_OUT   Integer;
  BEGIN
  v_out := REGEXP_COUNT( v_nm, '[|]');

    RETURN V_OUT+1;
  END;
  
  
/* Get the string in position v_idx within string v_nm */
function getVV(v_nm in varchar2, v_idx in integer, v_max in integer) return varchar2 is
   v_word  varchar2(4000);
begin
  if (v_idx = 1 and v_idx = v_max)then
    v_word := v_nm;
  elsif  (v_idx = 1 and v_idx < v_max)then
    v_word := substr(v_nm, 1, instr(v_nm, '|',1,1)-1);
  elsif (v_idx = v_max) then
     v_word := substr(v_nm, instr(v_nm, '|',1,v_idx-1)+1);
  else
     v_word := substr(v_nm, instr(v_nm, '|',1,v_idx-1)+1,instr(v_nm, '|',1,v_idx)-instr(v_nm, '|',1,v_idx-1));
  end if;
  return trim(replace(v_word,'|',''));
end;

procedure spValidateForm (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
   hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_item_id number;
     actions t_actions := t_actions();
    action t_actionRowset;
    v_temp integer;
    v_found boolean;
    v_ctl_val_stus varchar2(100);
    v_ctl_val_msg varchar2(1000);
    v_ctl_vv_stus varchar2(100);
begin
   hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  --actions := t_actions();
  
  rows := t_rows();
        row_ori := hookInput.originalRowset.rowset(1);
  
  if (ihook.getColumnValue(row_ori,'CTL_VAL_STUS') is null) then
  raise_application_Error(-20000,'Please parse the form first.');
  return;
  end if;
  
  if (ihook.getColumnValue(row_ori,'CTL_VAL_STUS')='PROCESSED') then
  raise_application_Error(-20000,'Form already processed.');
  return;
  end if;
  
  -- validate form - Missing Context or duplicate form name.
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '' || chr(13));
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED' || chr(13));
  if (ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID') is null) then
    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Context missing.' || chr(13));
    ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERROR');
  else -- protocol check
  if ( ihook.getColumnValue(row_ori, 'PRTCL_ITEM_ID') is null and ihook.getColumnValue(row_ori, 'IMP_PRTCL_NM') is not null) then
    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'WARNING: Protocol is not found.' || chr(13));
    ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'WARNING');
  end if;
       
  end if;
  

  -- Validate Questions Validate if CDE ITEM ID exists. Match if not
  for curq in (select * from NCI_STG_FORM_QUEST_IMPORT where form_imp_id = ihook.getColumnValue(row_ori, 'FORM_IMP_ID')) loop
        v_ctl_val_stus := 'VALIDATED';
        v_ctl_vv_stus := 'VALIDATED';
        v_ctl_val_msg := '';
        if (curq.MOD_NM is null or curq.mod_nm = '') then
            v_ctl_val_stus := 'ERROR';
            v_ctl_val_msg := 'ERROR: Module name is null.';
        else
            if (curq.CDE_ITEM_ID is not null) then -- Validate
            v_ctl_val_msg := '';
        -- Validate question - Question text has to be the name of the CDE or an alternate name
                select sum(cnt) into v_temp from 
                (select count(*) cnt from admin_item where item_id = curq.CDE_ITEM_ID and ver_nr = curq.CDE_VER_NR and upper(item_nm) = upper(curq.SRC_QUEST_LBL) 
                union
                select count(*) cnt from ref where item_id = curq.CDE_ITEM_ID and ver_nr = curq.CDE_VER_NR and upper(ref_desc) = upper(curq.SRC_QUEST_LBL) );
        
                if (v_temp = 0) then
                    v_ctl_val_stus := 'WARNING';
                    v_ctl_val_msg := 'Question label does not match.';
                end if;
             
        --if enumerated -- then validate valid values
        -- for each VV, make sure PV exists. If it does, then VM Name is either the VM name or alternate name
                for curvv in (Select * from  NCI_STG_FORM_VV_IMPORT where quest_imp_id = curq.quest_imp_id) loop
                    v_found := false;
                         for cur1 in (select * from  VW_NCI_DE_PV_VM_ALL_NMS where 	(upper(PERM_VAL_NM)= upper(curvv.SRC_PERM_VAL)
                    and upper(ALT_NM) = upper(curvv.SRC_VM_NM) ) and DE_ITEM_ID = curq.CDE_ITEM_ID
                    and DE_VER_NR = curq.CDE_VER_NR) loop
        
                        update  NCI_STG_FORM_VV_IMPORT  set CTL_VAL_STUS = 'VALIDATED' ,CTL_VAL_MSG = '' ,
                        vv_alt_def = cur1.item_desc, val_mean_item_id =cur1.NCI_VAL_MEAN_ITEM_ID, val_mean_ver_nr = cur1.NCI_VAL_MEAN_VER_NR, vm_long_nm = cur1.item_nm where VAL_IMP_ID=curvv.val_imp_id;
                        commit;
                        v_found := true;
               end loop;
               if (v_found = false) then
                        update  NCI_STG_FORM_VV_IMPORT  set  CTL_VAL_STUS = 'WARNING', CTL_VAL_MSG = 'PV/VM not found. CDE will not be used.' where VAL_IMP_ID=curvv.val_imp_id;
                        commit;
                        v_ctl_vv_stus := 'WARNING';
                    end if;
            
                end loop;
        if (v_ctl_vv_stus = 'WARNING') then 
         v_ctl_val_msg := v_ctl_val_msg || ' ' || 'PV/VM combination not found.';
          v_ctl_val_stus:= 'WARNING';
        end if;
        if (v_ctl_vv_stus = 'WARNING' or v_ctl_val_stus = 'WARNING') then -- Prefix message
         v_ctl_val_msg := 'CDE will not be used. ' || v_ctl_val_msg;
        end if;
        else -- No CDE Attached
             v_ctl_val_stus := 'WARNING';
            v_ctl_val_msg := 'WARNING: No CDE attached.';
       
        end if;
    end if;-- no module name
    update NCI_STG_FORM_QUEST_IMPORT  set CTL_VAL_STUS  = v_ctl_val_stus, CTL_VAL_MSG = v_ctl_val_msg where
            QUEST_IMP_ID = curq.quest_imp_id;
        commit;
    if ((v_ctl_val_stus = 'WARNING' or v_ctl_vv_stus = 'WARNING') and ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'ERROR') then
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'WARNING: Please see Question/VV validation warnings.' || chr(13));
        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'WARNING');
        end if;
    end loop;-- Question end loop
    rows := t_rows();
        rows.extend;    rows(rows.last) := row_ori;
        action := t_actionrowset(rows, 'Form Import Header', 2,1,'update');
          actions.extend;
        actions(actions.last) := action;
  --     raise_application_error(-20000,'Error');
        hookoutput.actions := actions;
        hookoutput.message := 'Form Validation completed.';
          
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);    

  end;


procedure spValidateQuestion (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
   hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_item_id number;
     actions t_actions := t_actions();
    action t_actionRowset;
    v_temp integer;
    v_found boolean;
    v_ctl_val_stus varchar2(100);
    v_ctl_val_msg varchar2(1000);
    v_ctl_vv_stus varchar2(100);
begin
   hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  --actions := t_actions();
  
  rows := t_rows();

     
 for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
     for curq in (select * from NCI_STG_FORM_QUEST_IMPORT where quest_imp_id = ihook.getColumnValue(row_ori, 'QUEST_IMP_ID')) loop
        v_ctl_val_stus := 'VALIDATED';
        v_ctl_vv_stus := 'VALIDATED';
        v_ctl_val_msg := '';
        if (curq.MOD_NM is null or curq.mod_nm = '') then
            v_ctl_val_stus := 'ERROR';
            v_ctl_val_msg := 'ERROR: Module name is null.';
        else
            if (curq.CDE_ITEM_ID is not null) then -- Validate
        -- Validate question - Question text has to be the name of the CDE or an alternate name
                select sum(cnt) into v_temp from 
                (select count(*) cnt from admin_item where item_id = curq.CDE_ITEM_ID and ver_nr = curq.CDE_VER_NR and upper(item_nm) = upper(curq.SRC_QUEST_LBL) 
                union
                select count(*) cnt from ref where item_id = curq.CDE_ITEM_ID and ver_nr = curq.CDE_VER_NR and upper(ref_desc) = upper(curq.SRC_QUEST_LBL) );
        
                if (v_temp = 0) then
                    v_ctl_val_stus := 'WARNING';
                    v_ctl_val_msg := 'WARNING: Question label does not match.';
                end if;
        --if enumerated -- then validate valid values
        -- for each VV, make sure PV exists. If it does, then VM Name is either the VM name or alternate name
                for curvv in (Select * from  NCI_STG_FORM_VV_IMPORT where quest_imp_id = curq.quest_imp_id) loop
                        v_found := false;
                         for cur1 in (select * from  VW_NCI_DE_PV_VM_ALL_NMS where 	(upper(PERM_VAL_NM)= upper(curvv.SRC_PERM_VAL)
                    and upper(ALT_NM) = upper(curvv.SRC_VM_NM) ) and DE_ITEM_ID = curq.CDE_ITEM_ID
                    and DE_VER_NR = curq.CDE_VER_NR) loop
    --    raise_application_error(-20000,curvv.val_imp_id);
                        update  NCI_STG_FORM_VV_IMPORT  set CTL_VAL_STUS = 'VALIDATED' ,CTL_VAL_MSG = '' ,
                        vv_alt_def = cur1.item_desc, val_mean_item_id =cur1.NCI_VAL_MEAN_ITEM_ID, val_mean_ver_nr = cur1.NCI_VAL_MEAN_VER_NR, vm_long_nm = cur1.item_nm where VAL_IMP_ID=curvv.val_imp_id;
                        commit;
                        v_found := true;
               end loop;
               if (v_found = false) then
                        update  NCI_STG_FORM_VV_IMPORT  set  CTL_VAL_STUS = 'WARNING', CTL_VAL_MSG = 'PV/VM not found. CDE will not be used.' where VAL_IMP_ID=curvv.val_imp_id;
                        commit;
                        v_ctl_vv_stus := 'WARNING';
                    end if;
            
            
                end loop;
        
        else -- No CDE Attached
             v_ctl_val_stus := 'WARNING';
            v_ctl_val_msg := 'WARNING: No CDE attached.';
       
        end if;
    end if;-- no module name
    update NCI_STG_FORM_QUEST_IMPORT  set CTL_VAL_STUS  = v_ctl_val_stus, CTL_VAL_MSG = v_ctl_val_msg where
            QUEST_IMP_ID = curq.quest_imp_id;
        commit;
    if (v_ctl_val_stus = 'WARNING' or v_ctl_vv_stus = 'WARNING') then
        v_ctl_val_msg := 'WARNING: Please see Question/VV validation warnings.' || chr(13);
        v_ctl_val_Stus := 'WARNING';
        end if;
         update NCI_STG_FORM_QUEST_IMPORT  set CTL_VAL_STUS  = v_ctl_val_stus, CTL_VAL_MSG = v_ctl_val_msg where
            QUEST_IMP_ID = curq.quest_imp_id;
        commit;
    end loop;-- Question end loop
   end loop;
        hookoutput.message := 'Question Validation completed.';
          
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);    

  end;



procedure spMatchQuestion (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2)
as
   hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
  v_suffix varchar2(100);
    rows      t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_item_id number;
     actions t_actions := t_actions();
    action t_actionRowset;
    v_temp integer;
    v_str varchar2(2000);
    i integer;
 
 begin
   hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
    
  for curq in (select * from NCI_STG_FORM_QUEST_IMPORT where quest_imp_id = ihook.getColumnValue(row_ori, 'QUEST_IMP_ID')) loop
        -- If enum, then call enum match
        select count(*) into v_temp from NCI_STG_FORM_VV_IMPORT where quest_imp_id = curq.quest_imp_id;
        case v_mode 
        when 'L' then 
        v_str := nvl(curq.USER_TIPS,curq.SRC_QUEST_LBL);
        v_suffix := 'Label';
        when 'V' then 
        v_str := nvl(curq.USER_TIPS,curq.SRC_QUESTION_ID);
        v_suffix := 'Variable';
       end case ;
        if (curq.user_tips is not null) then
        v_suffix :='User Tips';
        end if;
        if (v_temp = 0) then -- non-enumerated
        nci_ds.spDSMatchNonEnum(curq.quest_imp_id, v_usr_id, '1=1', 'QUESTION_MATCH',v_str,v_suffix );
        else
        nci_ds.spDSMatchEnum(curq.quest_imp_id, v_usr_id, '1=1', 'QUESTION_MATCH',v_str,v_suffix, 'N');
        end if;

        
  end loop;
  update nci_stg_form_quest_import set (CTL_VAL_STUS, num_cde_mtch) = (select 'MATCHED', count(*) from nci_ds_rslt where hdr_id = ihook.getColumnValue(row_ori,'QUEST_IMP_ID'))
  where quest_imp_id = ihook.getColumnValue(row_ori,'QUEST_IMP_ID');
  commit;
   update nci_ds_rslt r set NUM_PV_IN_CDE = (select count(*) from vw_nci_de_pv_lean where de_item_id = r.item_id and de_ver_nr = r.ver_nr)
  where hdr_id = ihook.getColumnValue(row_ori,'QUEST_IMP_ID');
  
end loop;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);    

  end;

procedure spCreateImportedForm (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
   hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    f_row t_row;
    f_rows t_rows;
    rowform t_row;
    row_ori t_row;
    v_form_id number;
    v_mod_id number;
    v_mod_id_desc number;
    v_prev_mod_nm varchar2(255);
    v_id number;
    v_disp_ord integer;
    v_quest_disp_ord integer;
    v_vv_disp_ord integer;
     actions t_actions := t_actions();
    action t_actionRowset;
    v_vv_id number;
v_req_ind integer;
v_instr varchar2(4000);
v_long_nm  varchar2(30);
v_temp integer;
v_desc_txt_cnt integer; --jira 2906
v_img_cnt integer; --jira 2906
type array_t is table of varchar2(255);
array array_t := array_t();
array_cnt integer;
mod_nm_toComp integer;
temp_max integer;
temp_typ varchar2(255);
temp_lbl varchar2(4000);
temp_quest varchar2(4000);
row_cnt integer;
begin
   hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
     row_ori := hookInput.originalRowset.rowset(1);
     
     if (ihook.getColumnValue(row_ori,'CTL_VAL_STUS') =  'PROCESSED') then
     raise_application_error(-20000,'Form already processed');
     end if;
     
     if (ihook.getColumnValue(row_ori,'CTL_VAL_STUS') <> 'VALIDATED' and ihook.getColumnValue(row_ori,'CTL_VAL_STUS') <> 'WARNING') then
     raise_application_error(-20000,'Please validate Form first');
     end if;
    
     
   rows := t_rows();
  --raise_application_error(-20000,'Work in Progress');
  row := t_row();
  array_cnt := 1;
  row_cnt :=1;
       for cur in (select * from NCI_STG_FORM_QUEST_IMPORT where FORM_IMP_ID = ihook.getColumnValue(row_ori,'FORM_IMP_ID') order by BTCH_SEQ_NBR asc) loop
       array.extend();
       array(array_cnt) := cur.mod_nm;
       array_cnt := array_cnt + 1;
        if (LOWER(cur.src_quest_typ) = 'descriptive') then
       -- raise_application_error(-20000,cur.src_quest_typ);
            if (row_cnt = 1) then
                ihook.setColumnValue(row, 'HDR_INSTR', cur.src_quest_lbl);
                
            elsif (LOWER(cur.src_question_id) like '%footer%') then
                ihook.setColumnValue(row, 'FTR_INSTR', cur.src_quest_lbl);
                
            end if;
        end if;
        row_cnt := row_cnt + 1;
     end loop;
    array.extend();
    array(array_cnt) := 'YYYYYYYYY';
    -- raise_application_error(-20000,array(2));

  ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
         ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);
        ihook.setColumnValue(row, 'FORM_TYP_ID', 70);
        v_form_id :=  nci_11179.getItemId;

        ihook.setColumnValue(row, 'ITEM_ID', v_form_id);
        ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row, 'VER_NR', 1);
        ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 54);
        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_form_id || c_ver_suffix);
    ihook.setColumnValue(row, 'ITEM_NM', ihook.getColumnValue(row_ori,'FORM_NM'));
    ihook.setColumnValue(row, 'ITEM_DESC', ihook.getColumnValue(row_ori,'FORM_NM'));
    ihook.setColumnValue(row, 'CNTXT_ITEM_ID', ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID'));
    ihook.setColumnValue(row, 'CNTXT_VER_NR', ihook.getColumnValue(row_ori,'CNTXT_VER_NR'));
        ihook.setColumnValue(row, 'CHNG_DESC_TXT', 'Created via Form Import');
       rows:= t_rows();
        rows.extend;
        rows(rows.last) := row;

        -- Insert super-type
        action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'insert');
        actions.extend;
        actions(actions.last) := action;
        -- Insert sub-type
        action             := t_actionrowset(rows, 'Form AI', 2, 1,'insert');
        actions.extend;
        actions(actions.last) := action;
        
        if (ihook.getColumnValue(row_ori, 'PRTCL_ITEM_ID') is not null) then --- insert Protocol-Form Rel
        ihook.setColumnValue(row, 'C_ITEM_ID', v_form_id);
       ihook.setColumnValue(row, 'P_ITEM_ID', ihook.getColumnValue(row_ori, 'PRTCL_ITEM_ID'));
        ihook.setColumnValue(row, 'P_ITEM_VER_NR', ihook.getColumnValue(row_ori, 'PRTCL_VER_NR'));
        ihook.setColumnValue(row, 'C_ITEM_VER_NR', 1);
       ihook.setColumnValue(row, 'REL_TYP_ID', 60);
       rows:= t_rows();
        rows.extend;
        rows(rows.last) := row;

        -- Insert super-type
        action             := t_actionrowset(rows, 'Protocol-Form Relationship (Form View)', 2, 5,'insert');
        actions.extend;
        actions(actions.last) := action;
      end if;    
        
        
       v_disp_ord := 0;
       v_quest_disp_ord := 1;
       v_prev_mod_nm := 'XXXXX';
       v_desc_txt_cnt := 1;
       v_img_cnt := 1;
        array_cnt :=2;
        mod_nm_toComp :=1;
        temp_max :=0;
        temp_typ := '';
        temp_lbl := '';
        temp_quest := '';
        row_cnt := 1;
for cur in (select * from NCI_STG_FORM_QUEST_IMPORT where FORM_IMP_ID = ihook.getColumnValue(row_ori,'FORM_IMP_ID') order by BTCH_SEQ_NBR asc) loop
    mod_nm_toComp := mod_nm_toComp + 1;
    if (cur.mod_nm <> v_prev_mod_nm) then --new module, see if last row is descriptive
    
        select max(BTCH_SEQ_NBR) into temp_max from NCI_STG_FORM_QUEST_IMPORT where FORM_IMP_ID = ihook.getColumnValue(row_ori,'FORM_IMP_ID') and mod_nm = cur.mod_nm;
        select src_quest_typ, src_quest_lbl, src_question_id into temp_typ, temp_lbl, temp_quest from NCI_STG_FORM_QUEST_IMPORT where FORM_IMP_ID = ihook.getColumnValue(row_ori,'FORM_IMP_ID') and BTCH_SEQ_NBR = temp_max;
        if (temp_typ = 'descriptive' and lower(temp_quest) not like '%footer%' and LOWER(temp_quest) not like '%image%') then
            ihook.setColumnValue(row, 'INSTR', temp_lbl);
        else
            ihook.setColumnValue(row, 'INSTR', cur.SRC_MOD_INSTR);
        end if;
        
        v_mod_id :=  nci_11179.getItemId;
        ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 52);
        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_mod_id || c_ver_suffix);
        ihook.setColumnValue(row, 'ITEM_NM', cur.mod_nm);
        ihook.setColumnValue(row, 'ITEM_DESC', cur.mod_nm);
        ihook.setColumnValue(row, 'ITEM_ID', v_mod_id);

        ihook.setColumnValue(row, 'REL_TYP_ID', 61);
        ihook.setColumnValue(row, 'C_ITEM_ID', v_mod_id);
        ihook.setColumnValue(row, 'C_ITEM_VER_NR', 1);
        ihook.setColumnValue(row, 'P_ITEM_ID', v_form_id);
        ihook.setColumnValue(row, 'P_ITEM_VER_NR', 1);
        ihook.setColumnValue(row, 'DISP_ORD', v_disp_ord);
        ihook.setColumnValue(row, 'REP_NO', 0);
        
        rows:= t_rows();
        rows.extend;
        rows(rows.last) := row;

        action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 10,'insert');
        actions.extend;
        actions(actions.last) := action;

        action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 12,'insert');
        actions.extend;
        actions(actions.last) := action;
    
        v_disp_ord := v_disp_ord + 1;
        v_quest_disp_ord := 1;
        v_prev_mod_nm := cur.mod_nm;
        
    elsif (lower(cur.src_quest_typ) = 'descriptive' and (lower(cur.src_question_id) not like '%footer%') and (cur.BTCH_SEQ_NBR <> temp_max or lower(cur.src_question_id) like '%image%')) then --create empty module
        
        v_mod_id_desc :=  nci_11179.getItemId;
        ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 52);
        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_mod_id_desc || c_ver_suffix);
        ihook.setColumnValue(row, 'ITEM_ID', v_mod_id_desc);
        ihook.setColumnValue(row, 'REL_TYP_ID', 61);
        ihook.setColumnValue(row, 'C_ITEM_ID', v_mod_id_desc);
        ihook.setColumnValue(row, 'C_ITEM_VER_NR', 1);
        ihook.setColumnValue(row, 'P_ITEM_ID', v_form_id);
        ihook.setColumnValue(row, 'P_ITEM_VER_NR', 1);
        ihook.setColumnValue(row, 'DISP_ORD', v_disp_ord);
        ihook.setColumnValue(row, 'REP_NO', 0);
        ihook.setColumnValue(row, 'INSTR', cur.SRC_QUEST_LBL);
        
        if (LOWER(cur.src_question_id) like '%image%') then
            ihook.setColumnValue(row, 'INSTR', cur.src_quest_lbl);
            ihook.setColumnValue(row, 'ITEM_NM', cur.src_question_id);
          --  ihook.setColumnValue(row, 'ITEM_NM', 'Image ' || v_img_cnt);
          --  v_img_cnt := v_img_cnt + 1;
        else
            ihook.setColumnValue(row, 'ITEM_NM', 'Descriptive ' || v_desc_txt_cnt);
            v_desc_txt_cnt := v_desc_txt_cnt + 1;            -- raise_application_error(-20000,cur.src_question_id);
        end if;      
       
        rows:= t_rows();
        rows.extend;
        rows(rows.last) := row;

        action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 10,'insert');
        actions.extend;
        actions(actions.last) := action;

        action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 12,'insert');
        actions.extend;
        actions(actions.last) := action;
        
        v_disp_ord := v_disp_ord + 1;
       end if;

        
        -------------------------------------------------------start module processing
--       for cur in (select * from NCI_STG_FORM_QUEST_IMPORT where FORM_IMP_ID = ihook.getColumnValue(row_ori,'FORM_IMP_ID') order by BTCH_SEQ_NBR asc) loop 
--      --  raise_application_error(-20000,cur.mod_nm);
--        mod_nm_toComp := mod_nm_toComp + 1;
--      -- jira 2906: create new, empty module when field type = descriptive and is not footer or header and is not the last row of a section header
--         if (LOWER(cur.src_quest_typ) = 'descriptive' and (lower(cur.src_question_id) <> 'footer') and cur.mod_nm = array(mod_nm_toComp)) then
--       -- raise_application_error(-20000,cur.src_quest_typ);
--
----create module
--        v_mod_id_desc :=  nci_11179.getItemId;
--        ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 52);
--        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_mod_id_desc || c_ver_suffix);
--        if (cur.BTCH_SEQ_NBR <> 1) then
--        ihook.setColumnValue(row, 'ITEM_NM', 'Descriptive Text ' || v_desc_txt_cnt);
--        else
--         ihook.setColumnValue(row, 'ITEM_NM', cur.mod_nm);
--        end if;
--        ihook.setColumnValue(row, 'ITEM_ID', v_mod_id_desc);
--        
--        ihook.setColumnValue(row, 'REL_TYP_ID', 61);
--        ihook.setColumnValue(row, 'C_ITEM_ID', v_mod_id_desc);
--        ihook.setColumnValue(row, 'C_ITEM_VER_NR', 1);
--        ihook.setColumnValue(row, 'P_ITEM_ID', v_form_id);
--        ihook.setColumnValue(row, 'P_ITEM_VER_NR', 1);
--        ihook.setColumnValue(row, 'DISP_ORD', v_disp_ord);
--        ihook.setColumnValue(row, 'REP_NO', 0);
--        ihook.setColumnValue(row, 'INSTR', cur.SRC_QUEST_LBL);
--        
--        if (LOWER(cur.src_question_id) like 'image%') then
--            ihook.setColumnValue(row, 'ITEM_NM', 'Image ' || v_img_cnt);
--            ihook.setColumnValue(row, 'INSTR', cur.SRC_QUEST_LBL);
--            v_img_cnt := v_img_cnt + 1;
--            -- raise_application_error(-20000,cur.src_question_id);
--        end if;
--       
--       
--        rows:= t_rows();
--        rows.extend;
--        rows(rows.last) := row;
--
--        action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 10,'insert');
--        actions.extend;
--        actions(actions.last) := action;
--
--        action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 12,'insert');
--        actions.extend;
--        actions(actions.last) := action;
--        v_desc_txt_cnt := v_desc_txt_cnt + 1;
--        v_disp_ord := v_disp_ord + 1;
--       end if;
--
--    -- end jira 2906 changes
--      
--   --    if (cur.mod_nm <> v_prev_mod_nm and (lower(cur.src_question_id) <> 'footer') and cur.BTCH_SEQ_NBR <> 1) then -- create new module unless footer/header
--   if (cur.mod_nm <> array(mod_nm_toComp) and cur.BTCH_SEQ_NBR <> 1) then -- create new module unless footer/header
--        v_mod_id :=  nci_11179.getItemId;
--        ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 52);
--        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_mod_id || c_ver_suffix);
--        ihook.setColumnValue(row, 'ITEM_NM', cur.mod_nm);
--        ihook.setColumnValue(row, 'ITEM_DESC', cur.mod_nm);
--       ihook.setColumnValue(row, 'ITEM_ID', v_mod_id);
--  
--        ihook.setColumnValue(row, 'REL_TYP_ID', 61);
--        ihook.setColumnValue(row, 'C_ITEM_ID', v_mod_id);
--        ihook.setColumnValue(row, 'C_ITEM_VER_NR', 1);
--        ihook.setColumnValue(row, 'P_ITEM_ID', v_form_id);
--        ihook.setColumnValue(row, 'P_ITEM_VER_NR', 1);
--       ihook.setColumnValue(row, 'DISP_ORD', v_disp_ord);
--          ihook.setColumnValue(row, 'REP_NO', 0);
--        ihook.setColumnValue(row, 'INSTR', cur.SRC_MOD_INSTR);
----start 2906 changes
-- 
--        if (LOWER(cur.src_quest_typ) = 'descriptive') then --update instr
--            ihook.setColumnValue(row, 'INSTR', cur.SRC_QUEST_LBL);
--        end if;
--    
--            rows:= t_rows();
--            rows.extend;
--            rows(rows.last) := row;
--
--            action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 10,'insert');
--            actions.extend;
--            actions(actions.last) := action;
--
--    action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 12,'insert');
--            actions.extend;
--            actions(actions.last) := action;
--            v_disp_ord := v_disp_ord + 1;
--
--
----v_disp_ord := v_disp_ord + 1;
--
--v_quest_disp_ord := 1;
--v_prev_mod_nm := cur.mod_nm;
--    end if;        
--------------------------------------------------------------------------------------------------end module processing        

v_id := nci_11179.getItemId;


--raise_application_error(-20000,'HEre');
v_req_ind := 0;
if (nvl(cur.src_req_ind,'N') = 'Y') then
v_req_ind := 1;
end if;

-- INstructions - messy code bu the easiet to understand
--v_instr :=cur.SRC_QUEST_INSTR;
v_instr := '';
if (cur.SRC_QUEST_INSTR is not null) then
v_instr := 'Field Note=' ||cur.SRC_QUEST_INSTR || '; ';
end if;

if (cur.SRC_LOGIC_INSTR is not null) then 
v_instr :=  v_instr || 'Branching Logic=' || cur.SRC_LOGIC_INSTR || '; ';
end if;


if (cur.SRC_CDE_NM is not null and cur.cde_item_id is null) then 
v_instr :=  substr( v_instr || 'Field Annotation=' || cur.SRC_CDE_NM || '; ',1,4000);
end if;

if (cur.SRC_VAL_TYP is not null) then 
v_instr :=  substr( v_instr || 'Text Validation Type=' || cur.SRC_VAL_TYP || '; ',1,4000);
end if;

if (cur.SRC_VAL_MIN_VAL is not null) then 
v_instr := substr(  v_instr || 'Text Validation Min=' || cur.SRC_VAL_MIN_VAL || '; ',1,4000);
end if;

if (cur.SRC_VAL_MAX_VAL is not null) then 
v_instr := substr(  v_instr || 'Text Validation Max=' || cur.SRC_VAL_MAX_VAL || '; ',1,4000);
end if;
-- Tracker 2867 - if question short name > 30, make it the first term.
--if (length(cur.SRC_QUESTION_ID) > 30) then
v_instr := substr('Variable=' || cur.SRC_QUESTION_ID || ';' ||  v_instr,1,4000);
--end if;

v_long_nm := null;

if (cur.CTL_VAL_STUS= 'WARNING') and cur.cde_item_id is not null then

v_instr :=  v_instr  || 'CDE ' || cur.cde_item_id || ' v' || cur.cde_ver_nr || ' was not attached due to: ' || substr(cur.CTL_VAL_MSG,23);
else

   -- Question short name
             if (cur.cde_item_id is not null) then
                select sum(cnt) into v_temp from 
                (select count(*) cnt from admin_item where item_id = cur.CDE_ITEM_ID and ver_nr = cur.CDE_VER_NR and upper(item_long_nm) = upper(cur.SRC_QUESTION_ID) 
                union
                select count(*) cnt from alt_nms where item_id = cur.CDE_ITEM_ID and ver_nr = cur.CDE_VER_NR and upper(nm_desc) = upper(cur.SRC_QUESTION_ID) );
        
              if (v_temp = 0) then
                   v_instr :=  v_instr  || 'Invalid Question Short Name - used CDE Short Name.';
                   select item_long_nm into v_long_nm from admin_item  where item_id = cur.CDE_ITEM_ID and ver_nr = cur.CDE_VER_NR;
                end if;
                end if;
  end if;
  
  if ((lower(cur.src_question_id) not like '%footer%') and row_cnt <> 1 and (cur.BTCH_SEQ_NBR <> temp_max or LOWER(cur.src_question_id) like '%image%') or lower(cur.src_quest_typ) <> 'descriptive') then --jira 2906: add condition to not create questions for footer,header, last row of section header
  insert into nci_admin_item_rel_alt_key (NCI_PUB_ID, NCI_VER_NR, P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, CNTXT_CS_ITEM_ID, CNTXT_CS_VER_NR,
  ITEM_LONG_NM, ITEM_NM, REL_TYP_ID, DISP_ORD,req_ind, 	
  --REQ_IND, 
  INSTR,  creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id)
  values (v_id, 1, v_mod_id,1, 
  decode(cur.CTL_VAL_STUS, 'WARNING', null, cur.cde_item_id), 
   decode(cur.CTL_VAL_STUS, 'WARNING', null,cur.cde_ver_nr), ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID'), ihook.getColumnValue(row_ori,'CNTXT_VER_NR'), 
  cur.SRC_QUEST_LBL,nvl(v_long_nm,substr(cur.SRC_QUESTION_ID,1,30)),
   63, v_quest_disp_ord, v_req_ind, 
  --cur.req_ind, 
  trim(v_instr), 
  sysdate, v_usr_id, sysdate, v_usr_id );
 -- commit;

  insert into onedata_ra.nci_admin_item_rel_alt_key (NCI_PUB_ID, NCI_VER_NR, P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, CNTXT_CS_ITEM_ID, CNTXT_CS_VER_NR,
  ITEM_LONG_NM, ITEM_NM, REL_TYP_ID, DISP_ORD,req_ind,
  --REQ_IND, 
  INSTR,  creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id)
  values (v_id, 1, v_mod_id,1, decode(cur.CTL_VAL_STUS, 'ERROR', null, cur.cde_item_id), 
  decode(cur.CTL_VAL_STUS, 'ERROR', null,cur.cde_ver_nr), ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID'), ihook.getColumnValue(row_ori,'CNTXT_VER_NR'), 
  cur.SRC_QUEST_LBL,
 v_id, 63, v_quest_disp_ord, v_req_ind,
  --cur.req_ind, 
  decode(cur.CTL_VAL_STUS, 'ERROR',  'CDE selected was not attached due to errors; ' || nvl(cur.SRC_QUEST_INSTR ,''),cur.SRC_QUEST_INSTR),  sysdate, v_usr_id, sysdate, v_usr_id );
--  commit;
v_quest_disp_ord := v_quest_disp_ord + 1;

v_vv_disp_ord := 1;

    for cur1 in (select * from  NCI_STG_FORM_VV_IMPORT where quest_imp_id = cur.quest_imp_id) loop
  v_vv_id := nci_11179.getItemId;
  insert into nci_quest_valid_value (Q_PUB_ID, Q_VER_NR, 
  --VM_NM, VM_LNM, VM_DEF, DESC_TXT, 
  VALUE, MEAN_TXT, VM_DEF,DESC_TXT,
  --VAL_MEAN_ITEM_ID, VAL_MEAN_VER_NR,  
  NCI_PUB_ID, NCI_VER_NR,
   DISP_ORD, creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id, VAL_MEAN_ITEM_ID, VAL_MEAN_VER_NR)
  values (v_id, 1, 
  --cur1.vm_nm, cur1.vm_lnm, cur1.vm_def, cur1.desc_txt, 
  cur1.SRC_PERM_VAL,  cur1.src_vm_nm,nvl(cur1.VV_ALT_DEF, cur1.SRC_VM_NM),nvl(cur1.VV_ALT_DEF, cur1.SRC_VM_NM),
  --cur1.VAL_MEAN_ITEM_ID, cur1.VAL_MEAN_VER_NR,
  v_vv_id, 1, v_vv_disp_ord, 
  --cur1.disp_ord,
  
  sysdate, v_usr_id, sysdate, v_usr_id, cur1.VAL_MEAN_ITEM_ID, cur1.VAL_MEAN_VER_NR);
insert into onedata_ra.nci_quest_valid_value (Q_PUB_ID, Q_VER_NR, 
  --VM_NM, VM_LNM, VM_DEF, DESC_TXT, 
  VALUE, MEAN_TXT, VM_DEF,DESC_TXT,
  --VAL_MEAN_ITEM_ID, VAL_MEAN_VER_NR,  
  NCI_PUB_ID, NCI_VER_NR,
   DISP_ORD, creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id, VAL_MEAN_ITEM_ID, VAL_MEAN_VER_NR)
  values (v_id, 1, 
  --cur1.vm_nm, cur1.vm_lnm, cur1.vm_def, cur1.desc_txt, 
  cur1.SRC_PERM_VAL, cur1.SRC_VM_NM,nvl(cur1.VV_ALT_DEF, cur1.SRC_VM_NM),nvl(cur1.VV_ALT_DEF, cur1.SRC_VM_NM),
  --cur1.VAL_MEAN_ITEM_ID, cur1.VAL_MEAN_VER_NR,
  v_vv_id, 1, v_vv_disp_ord, 
  --cur1.disp_ord,
  
  sysdate, v_usr_id, sysdate, v_usr_id, cur1.VAL_MEAN_ITEM_ID, cur1.VAL_MEAN_VER_NR);

v_vv_disp_ord := v_vv_disp_ord + 1;
end loop;
end if;

row_cnt := row_cnt + 1;
   end loop;
commit;
 
rows := t_rows();
row := row_ori;
ihook.setColumnValue(row,'CTL_VAL_STUS','PROCESSED');
ihook.setColumnValue(row,'CREATED_FORM_ITEM_ID', v_form_id);
--ihook.setColumnValue(row,'PROCESS_DT', TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS'));

            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Form Import Header', 2, 5,'update');
            actions.extend;
            actions(actions.last) := action;

     
    hookoutput.actions    := actions;
    hookoutput.message := 'Form Created Successfully with ID : ' || v_form_id;
--raise_application_error(-20000,'HdddrrrrddddEre');
      V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --    raise_application_error(-20000, 'Hegggre' || v_id);

--nci_util.debugHook('GENERAL',v_data_out);

end;


end;
/