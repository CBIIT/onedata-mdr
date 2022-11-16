create or replace PACKAGE            nci_form_import AS

procedure spParseForm (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spValidateForm (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spValidateQuestion (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spMatchQuestion (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
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
        ihook.setColumnValue(row_ori, 'FORM_NM', initcap(replace(ihook.getColumnValue(row_ori, 'SRC_FORM_NM'),'_',' ')));
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
begin

rows := t_rows();
for cur in (select * from NCI_STG_FORM_QUEST_IMPORT where FORM_IMP_ID = ihook.getColumnValue(row_ori, 'FORM_IMP_ID')) loop
    row := t_row();
    ihook.setColumnValue(row,'QUEST_IMP_ID', cur.QUEST_IMP_ID);
    ihook.setColumnValue(row,'MOD_NM', initcap(replace(cur.SRC_MOD_NM,'_',' ')));
    ihook.setColumnValue(row,'CTL_VAL_STUS', 'PARSED');
    rows.extend;    rows(rows.last) := row;
    delete from NCI_STG_FORM_VV_IMPORT where quest_imp_id = cur.quest_imp_id;
    commit;
    if (cur.src_vv is not null) then
    j := getVVCount(cur.SRC_VV);
 --   raise_application_error(-20000, j || cur.src_vv);
    for i in 1..j loop
    
  --  raise_application_error(-20000,getVV(cur.src_vv,i,j));
  v_str := getVV(cur.src_vv,i,j);
    insert into NCI_STG_FORM_VV_IMPORT (VAL_IMP_ID,QUEST_IMP_ID,SRC_PERM_VAL,SRC_VM_NM)
    values (-1, cur.QUEST_IMP_ID, trim(substr( v_str,1,instr(v_str,',')-1)), trim(substr(v_str, instr(v_str,',')+1)));
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
  v_out := REGEXP_COUNT( v_nm, '\|');

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
  return trim(upper(replace(v_word,'|','')));
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
    v_ctl_val_stus varchar2(100);
    v_ctl_val_msg varchar2(1000);
    v_ctl_vv_stus varchar2(100);
begin
   hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
        row_ori := hookInput.originalRowset.rowset(1);
  
  if (ihook.getColumnValue(row_ori,'CTL_VAL_STUS') is null) then
  raise_application_Error(-20000,'Please parse the form first.');
  return;
  end if;
  
  -- validate form - Missing Context or duplicate form name.
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '' || chr(13));
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED' || chr(13));
  if (ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID') is null) then
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Context missing.' || chr(13));
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERROR' || chr(13));
  end if;
 /* for cur in (select * from admin_item where admin_item_typ_id = 54 and upper(item_nm) = upper(ihook.getColumnValue(row_ori, 'FORM_NM'))) loop
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', nvl(ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'),'') || 'ERROR: Form Name is duplicate.' || chr(13));
  end loop;
  */
  -- Validate Questions Validate if CDE ITEM ID exists. Match if not
  for curq in (select * from NCI_STG_FORM_QUEST_IMPORT where form_imp_id = ihook.getColumnValue(row_ori, 'FORM_IMP_ID')) loop
        v_ctl_val_stus := 'VALIDATED';
        v_ctl_vv_stus := 'VALIDATED';
        v_ctl_val_msg := '';
        if (curq.CDE_ITEM_ID is not null) then -- Validate
        -- Validate question - Question text has to be the name of the CDE or an alternate name
        select sum(cnt) into v_temp from 
        (select count(*) cnt from admin_item where item_id = curq.CDE_ITEM_ID and ver_nr = curq.CDE_VER_NR and upper(item_nm) = upper(curq.SRC_QUEST_LBL) 
        union
        select count(*) cnt from ref where item_id = curq.CDE_ITEM_ID and ver_nr = curq.CDE_VER_NR and upper(ref_desc) = upper(curq.SRC_QUEST_LBL) );
        
if (v_temp = 0) then
     v_ctl_val_stus := 'ERROR';
        v_ctl_val_msg := 'ERROR: Question label does not match CDE name or any question texts.';
        end if;
        --if enumerated -- then validate valid values
        -- for each VV, make sure PV exists. If it does, then VM Name is either the VM name or alternate name
         for curvv in (Select * from  NCI_STG_FORM_VV_IMPORT where quest_imp_id = curq.quest_imp_id) loop
            select count(*) into v_temp from VW_NCI_DE_PV where 	(upper(PERM_VAL_NM)= upper(curvv.SRC_PERM_VAL)
            or upper(ITEM_NM) = upper(curvv.SRC_VM_NM) ) and DE_ITEM_ID = curq.CDE_ITEM_ID
            and DE_VER_NR = curq.CDE_VER_NR;
            if (v_temp=1) then
                update  NCI_STG_FORM_VV_IMPORT  set CTL_VAL_STUS = 'VALIDATED' ,CTL_VAL_MSG = '' where VAL_IMP_ID=curvv.val_imp_id;
                commit;
            else
                update  NCI_STG_FORM_VV_IMPORT  set  CTL_VAL_STUS = 'ERROR', CTL_VAL_MSG = 'ERROR: PV/VM not found in the specified CDE,' where VAL_IMP_ID=curvv.val_imp_id;
                commit;
                v_ctl_vv_stus := 'ERROR';
            end if;
            
        end loop;
        
        else -- Error
       
        
     v_ctl_val_stus := 'WARNING';
        v_ctl_val_msg := 'WARNING: No CDE attached.';
       
        end if;
         update NCI_STG_FORM_QUEST_IMPORT  set CTL_VAL_STUS  = v_ctl_val_stus, CTL_VAL_MSG = v_ctl_val_msg where
        QUEST_IMP_ID = curq.quest_imp_id;
        commit;
    if (v_ctl_val_stus = 'ERROR' or v_ctl_vv_stus = 'ERROR') then
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Please see Question/VV Validation Errors.' || chr(13));
        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERROR');
        end if;
     end loop;
    rows := t_rows();
        rows.extend;    rows(rows.last) := row_ori;
        action := t_actionrowset(rows, 'Form Import Header', 2,1,'update');
    --     action := t_actionrowset(rows, 'NCI_USR_CART', 1,1,'insert');
     actions.extend;
        actions(actions.last) := action;
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
    i integer;
begin
   hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
   
  for curq in (select * from NCI_STG_FORM_QUEST_IMPORT where quest_imp_id = ihook.getColumnValue(row_ori, 'QUEST_IMP_ID')) loop
    
    if (curq.CDE_ITEM_ID is not null) then -- Validate
        update NCI_STG_FORM_QUEST_IMPORT  set CTL_VAL_MSG = 'ERROR: No CDE attached.' where
        QUEST_IMP_ID = curq.quest_imp_id;
        commit;
    else
        -- Validate question - Question text has to be the name of the CDE or an alternate name
        select sum(cnt) into v_temp from 
        (select count(*) cnt from admin_item where item_id = curq.CDE_ITEM_ID and ver_nr = curq.CDE_VER_NR and upper(item_nm) = upper(curq.SRC_QUEST_LBL) 
        union
        select count(*) cnt from ref where item_id = curq.CDE_ITEM_ID and ver_nr = curq.CDE_VER_NR and upper(ref_desc) = upper(curq.SRC_QUEST_LBL) );
        
        if (nvl(v_temp,0) = 0 ) then
        update NCI_STG_FORM_QUEST_IMPORT  set CTL_VAL_MSG = 'ERROR: Question label does not match CDE name or any question texts.' where
        QUEST_IMP_ID = curq.quest_imp_id;
        commit;
        end if;
        
        --if enumerated -- then validate valid values
        -- for each VV, make sure PV exists. If it does, then VM Name is either the VM name or alternate name
        for curvv in (Select * from  NCI_STG_FORM_VV_IMPORT where quest_imp_id = curq.quest_imp_id) loop
            for curpv in (select * from VW_NCI_DE_PV where 	(upper(PERM_VAL_NM)= upper(curvv.SRC_PERM_VAL)
            or upper(ITEM_NM) = upper(curvv.SRC_VM_NM) ) and DE_ITEM_ID = curq.CDE_ITEM_ID
            and DE_VER_NR = curq.CDE_VER_NR) loop
                update  NCI_STG_FORM_VV_IMPORT  set VV_ALT_NM =  curpv.item_nm, CTL_VAL_MSG = 'VALIDATED' where VAL_IMP_ID=curvv.val_imp_id;
                commit;
            end loop;
        end loop;
      end if;  
    
  end loop;
  update nci_stg_form_quest_import set num_cde_mtch = (select count(*) from nci_ds_rslt where hdr_id = ihook.getColumnValue(row_ori,'QUEST_IMP_ID'))
  where quest_imp_id = ihook.getColumnValue(row_ori,'QUEST_IMP_ID');
  commit;
end loop;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);    

  end;


procedure spMatchQuestion (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
        if (v_temp = 0) then -- non-enumerated
        nci_ds.spDSMatchNonEnum(curq.quest_imp_id, v_usr_id, '1=1', 'QUESTION_MATCH',nvl(curq.USER_TIPS,curq.SRC_QUEST_LBL));
        else
        nci_ds.spDSMatchEnum(curq.quest_imp_id, v_usr_id, '1=1', 'QUESTION_MATCH',nvl(curq.user_tips,curq.SRC_QUEST_LBL));
        end if;

        
  end loop;
  update nci_stg_form_quest_import set num_cde_mtch = (select count(*) from nci_ds_rslt where hdr_id = ihook.getColumnValue(row_ori,'QUEST_IMP_ID'))
  where quest_imp_id = ihook.getColumnValue(row_ori,'QUEST_IMP_ID');
  commit;
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
    rowform t_row;
    row_ori t_row;
    v_form_id number;
    v_mod_id number;
    v_prev_mod_nm varchar2(255);
    v_id number;
    v_disp_ord integer;
    v_quest_disp_ord integer;
     actions t_actions := t_actions();
    action t_actionRowset;
    
begin
   hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
     row_ori := hookInput.originalRowset.rowset(1);
   rows := t_rows();
  --raise_application_error(-20000,'Work in Progress');
  row := t_row();
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
       v_disp_ord := 1;
       v_quest_disp_ord := 1;
       v_prev_mod_nm := 'XXXXX';
       for cur in (select * from NCI_STG_FORM_QUEST_IMPORT where FORM_IMP_ID = ihook.getColumnValue(row_ori,'FORM_IMP_ID') order by mod_nm) loop 
        raise_application_error(-20000,cur.mod_nm);
       if (cur.mod_nm <> v_prev_mod_nm) then -- create new module
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
          ihook.setColumnValue(row, 'REP_NO', nvl(ihook.getColumnValue(rowform,'REP_NO'),0));
        --    ihook.setColumnValue(rowrel, 'INSTR', ihook.getColumnValue(rowform,'INSTR'));

     
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;

    action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 2,'insert');
            actions.extend;
            actions(actions.last) := action;

v_disp_ord := v_disp_ord + 1;

v_quest_disp_ord := 1;
v_prev_mod_nm := cur.mod_nm;
    end if;        
        

  v_id := nci_11179.getItemId;


--raise_application_error(-20000, 'Here' || v_id);

  insert into nci_admin_item_rel_alt_key (NCI_PUB_ID, NCI_VER_NR, P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, CNTXT_CS_ITEM_ID, CNTXT_CS_VER_NR,
  ITEM_LONG_NM, ITEM_NM, REL_TYP_ID, DISP_ORD,
  --REQ_IND, 
  INSTR,  creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id)
  values (v_id, 1, v_mod_id,1, cur.cde_item_id, cur.cde_ver_nr, ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID'), ihook.getColumnValue(row_ori,'CNTXT_VER_NR'), 
  cur.SRC_QUEST_LBL,
  substr(cur.SRC_QUEST_LBL,1,30), 63, v_quest_disp_ord, 
  --cur.req_ind, 
  cur.SRC_QUEST_INSTR,  sysdate, v_usr_id, sysdate, v_usr_id );
  commit;



    for cur1 in (select * from  NCI_STG_FORM_VV_IMPORT where quest_imp_id = cur.quest_imp_id) loop
  
  insert into nci_quest_valid_value (Q_PUB_ID, Q_VER_NR, 
  --VM_NM, VM_LNM, VM_DEF, DESC_TXT, 
  VALUE, MEAN_TXT, 
  --VAL_MEAN_ITEM_ID, VAL_MEAN_VER_NR,  
  NCI_PUB_ID, NCI_VER_NR,
   DISP_ORD, creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id)
  values (v_id, 1, 
  --cur1.vm_nm, cur1.vm_lnm, cur1.vm_def, cur1.desc_txt, 
  cur1.SRC_PERM_VAL, cur1.SRC_VM_NM,
  --cur1.VAL_MEAN_ITEM_ID, cur1.VAL_MEAN_VER_NR,
  nci_11179.getItemId, 1, 
  --cur1.disp_ord,
  1,
  sysdate, v_usr_id, sysdate, v_usr_id);


end loop;


commit;
   end loop;
  

     
    hookoutput.actions    := actions;
      V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
nci_util.debugHook('GENERAL',v_data_out);

end;


end;
/
