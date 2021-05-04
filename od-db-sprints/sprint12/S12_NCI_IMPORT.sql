create or replace PACKAGE            nci_import AS
procedure spValCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spCreateCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);

END;
/
create or replace PACKAGE BODY            nci_import AS

procedure spValCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_item_id number;
    v_ver_nr number(4,2);
 action t_actionRowset;
 v_val_ind  boolean;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
  
for i in 1..hookinput.originalRowset.rowset.count loop

    row_ori := hookInput.originalRowset.rowset(i);
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '');
        v_val_ind := true;
        nci_dec_mgmt.createValAIWithConcept(row_ori, 1,5,'V', 'DROP-DOWN', actions) ;
        nci_dec_mgmt.createValAIWithConcept(row_ori, 2,6,'V', 'DROP-DOWN', actions) ;
        nci_vd.createValAIWithConcept(row_ori, 3,7,'V', 'DROP-DOWN', actions) ;
    
        nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind);
        nci_vd.spVDValCreateImport(row_ori, 'V', actions, v_val_ind);
        nci_chng_mgmt.spDEValCreateImport(row_ori, 'V', actions, v_val_ind);
       
   --    raise_application_error(-20000, ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR_FND'));
        if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'No Errors');                      
                
        end if;
    rows.extend; rows(rows.last) := row_ori;
   end if; -- only if not processed     
end loop;
    action := t_actionrowset(rows, 'CDE Import', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);
    
end;


procedure spPostCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_val_ind boolean;
    v_item_id number;
    v_ver_nr number(4,2);
 action t_actionRowset;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.rowset(1);
    v_val_ind := true;
    if (ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') is null) then
      nci_dec_mgmt.createValAIWithConcept(row_ori, 1,5,'V', 'STRING', actions) ;
    nci_dec_mgmt.createValAIWithConcept(row_ori, 2,6,'V', 'STRING', actions) ;
    end if;
    
    if (ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') is null) then
    
    nci_vd.createValAIWithConcept(row_ori, 3,7,'V', 'STRING', actions) ;
    end if;
    
    -- Added to combine decompose and validation in one step
    nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind);
    nci_vd.spVDValCreateImport(row_ori, 'V', actions, v_val_ind);
    nci_chng_mgmt.spDEValCreateImport(row_ori, 'V', actions, v_val_ind);
       
   --    raise_application_error(-20000, ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR_FND'));
    if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
    else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'No Errors');                      
                
    end if;
   -- end of validation
   
    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;
    
    action := t_actionrowset(rows, 'CDE Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL',v_data_out);
    
  
end;

procedure spCreateCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_item_id number;
    v_ver_nr number(4,2);
    v_val_ind  boolean;
 action t_actionRowset;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

for i in 1..hookinput.originalRowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_val_ind := true;
    ihook.setColumnValue(row_ori,'CTL_VAL_MSG', '');
    
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'VALIDATED') then
        if (ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') is null and ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID_FND') is null) then -- only go thru creating new if not specified and not existing
            nci_dec_mgmt.spDECValCreateImport(row_ori, 'C', actions, v_val_ind);
        end if;
        if (ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') is null) then -- only go thru creating new if not specified
            nci_vd.spVDValCreateImport(row_ori, 'C', actions, v_val_ind);
        end if;
        
       nci_chng_mgmt.spDEValCreateImport(row_ori, 'C', actions, v_val_ind);
        if (v_val_ind = true) then
        iHook.setColumnValue (row_ori, 'CTL_VAL_STUS', 'PROCESSED');
        end if;
    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;
    action := t_actionrowset(rows, 'CDE Import', 2,10,'update');
    end if;
end loop;
    
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 nci_util.debugHook('GENERAL',v_data_out);
end;

end;
/
