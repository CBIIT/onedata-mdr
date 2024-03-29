CREATE OR REPLACE PACKAGE nci_import AS
procedure spValCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spValCDEImportCons (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spCreateCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spCreateCDEImportCons (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostDECImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spValPVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spCreatePVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostPVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPVVMValidate (row_ori in out t_row);
procedure spCreateValDECImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2);
procedure spCreateValVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2);
procedure spCreateValDesigImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);

END;
/

CREATE OR REPLACE PACKAGE BODY nci_import AS

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
        
        nci_chng_mgmt.spDEValCreateImport(row_ori, 'V', actions, v_val_ind);

   --   raise_application_error(-20000, 'Import');
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


procedure spCreateValDesigImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    rowins  t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_item_id number;
    v_ver_nr number(4,2);
 action t_actionRowset;
 v_temp integer;
 v_val_ind  boolean;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
  rowins := t_rows();

for i in 1..hookinput.originalRowset.rowset.count loop

    row_ori := hookInput.originalRowset.rowset(i);
    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','' );                      
    v_val_ind := true;
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
    
        if (ihook.getColumnValue(row_ori, 'NM_TYP_ID')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'Designation Type is null.' || chr(13) );                      
                v_val_ind := false;   
        end if;
        
              if (ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'Context is null.' || chr(13) );                      
                v_val_ind := false;   
        end if;
        
      select count(*) into v_temp from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr =      ihook.getColumnValue(row_ori, 'VER_NR')  
      and admin_item_typ_id = ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') ;
      if (v_temp = 0) then
           ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'Item ID/Type do not match.' || chr(13) );                      
                v_val_ind := false;   
        end if;
     
        
   --   raise_application_error(-20000, 'Import');
        if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else
          select count(*) into v_temp from alt_nms where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr =      ihook.getColumnValue(row_ori, 'VER_NR')  
         and nm_desc = ihook.getColumnValue(row_ori, 'NM_DESC') and nm_typ_id = ihook.getColumnValue(row_ori, 'NM_TYP_ID') and cntxt_item_id  = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')
         and cntxt_ver_nr = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')  ;
         if (v_temp = 1) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'DUPLICATE');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'Alternate name already exists.');                      
        end if;
        if (v_temp = 0) then
             ihook.setColumnValue(row_ori, 'NM_ID', -1);
              ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'PROCESSED');
               rowins.extend; rowins(rowins.last) := row_ori;
        end if;
        end if;
    rows.extend; rows(rows.last) := row_ori;
   end if; -- only if not processed     
end loop;
    action := t_actionrowset(rows, 'Designation Import', 2,11,'update');
        actions.extend;
        actions(actions.last) := action;
         action := t_actionrowset(rowins, 'Alternate Names (All Types for Hook)', 2,10,'insert');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

end;

procedure spValCDEImportCons (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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

procedure spCreateValDECImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2)
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
 v_batch_nbr number;
   actions t_actions := t_actions();
   row_to_comp t_row;
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();

for i in 1..hookinput.originalRowset.rowset.count loop

    row_ori := hookInput.originalRowset.rowset(i);

   -- if (ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID_CREAT') is null and ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID') is null and v_mode='V')    then
    if (ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID_CREAT') is null  and v_mode='V')    then
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '');
        v_val_ind := true;
        nci_dec_mgmt.createValAIWithConcept(row_ori, 1,5,'V', 'DROP-DOWN', actions) ;
        nci_dec_mgmt.createValAIWithConcept(row_ori, 2,6,'V', 'DROP-DOWN', actions) ;
  --      nci_vd.createValAIWithConcept(row_ori, 3,7,'V', 'DROP-DOWN', actions) ;

        nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind);
   --     nci_vd.spVDValCreateImport(row_ori, 'V', actions, v_val_ind);
   --     nci_chng_mgmt.spDEValCreateImport(row_ori, 'V', actions, v_val_ind);
   
   

        if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'No Errors');                      
        end if;
    end if;
    --    if (ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID_CREAT') is null and ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID') is null and  ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID_FND') is null
   --     and v_mode = 'C') then
        if (ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID_CREAT') is null and  ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID_FND') is null        and v_mode = 'C') then

        --and v_val_ind = true)    then
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '');
        v_val_ind := true;
   --     nci_dec_mgmt.createValAIWithConcept(row_ori, 1,5,'C', 'DROP-DOWN', actions) ;
     --   nci_dec_mgmt.createValAIWithConcept(row_ori, 2,6,'C', 'DROP-DOWN', actions) ;
    --  raise_application_error(-20000, 'HEre  9');

-- Validate to see if the same row is not already selected
   for k in 1..rows.count loop
    row_to_comp := rows(k);
    if (ihook.getColumnValue(row_to_comp, 'ITEM_1_NM') = ihook.getColumnValue(row_ori, 'ITEM_1_NM') and ihook.getColumnValue(row_to_comp, 'ITEM_2_NM') = ihook.getColumnValue(row_ori, 'ITEM_2_NM')) then
    v_val_ind := false;
    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
   end if;
   end loop;
       if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
              ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'Duplicate found in the same import file. Batch Number: ' || v_batch_nbr );                
        else
        nci_dec_mgmt.spDECValCreateImport(row_ori, 'C', actions, v_val_ind);
        end if;
      end if;
    rows.extend; rows(rows.last) := row_ori;
 --  end if; -- only if not processed     
end loop;
--raise_application_error(-20000,'heddddrereffffrter');

    action := t_actionrowset(rows, 'DEC Import', 2,10,'update');
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


procedure spPostDECImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
 if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
    if (ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then
      nci_dec_mgmt.createValAIWithConcept(row_ori, 1,5,'V', 'STRING', actions) ;
    end if;
    if (ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_2') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then  
    nci_dec_mgmt.createValAIWithConcept(row_ori, 2,6,'V', 'STRING', actions) ;
    end if;
     ihook.setColumnValue(row_ori, 'MOD_NM', 'F') ;
 --   nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind);

   --    raise_application_error(-20000, ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR_FND'));
  /*  if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
    else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'No Errors');                      

    end if;
   -- end of validation
*/
    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;

    action := t_actionrowset(rows, 'DEC Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL',v_data_out);


end;


procedure spPostVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
    
    
    
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
 
     ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','');

    
    if (ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_3') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then
      nci_vd.VDImportPost(row_ori, 3,7,'V', 'STRING', actions) ;
   --nci_vd.createValAIWithConcept (row_ori, 3,7,'V', 'STRING', actions);
   --   raise_application_error(-20000, 'here');
    end if;
    ihook.setColumnValue(row_ori, 'MOD_NM', 'F') ;
    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;

    action := t_actionrowset(rows, 'VD Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
 end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL',v_data_out);


end;

procedure spCreatePVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
      rows := t_rows();
 
for i in 1..hookinput.originalRowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_val_ind := true;
    ihook.setColumnValue(row_ori,'CTL_VAL_MSG', '');

    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'VALIDATED') then
       nci_pv_vm.spPVVMImport ( row_ori,actions );
    rows.extend; rows(rows.last) := row_ori;
     end if;
end loop;
   action := t_actionrowset(rows, 'PV VM Import', 2,10,'update');

        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);
end;

--  PV/VM


procedure spValPVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
        spPVVMValidate(row_ori);
        rows.extend; rows(rows.last) := row_ori;
   end if; -- only if not processed     
end loop;
    action := t_actionrowset(rows, 'PV VM Import', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

end;


procedure spPostPVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();

    rows      t_rows;
    row          t_row;
    row_ori t_row;

  action t_actionRowset;
   actions t_actions := t_actions();
begin

-- ITEM_2_ID : Value Domain public Id; ITEM_2_VER_NR: Value Domain Version; ITEM_2_LONG_NM: Used to see if Concept or String - VM String Type

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.rowset(1);
   
    spPVVMValidate(row_ori);
    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;

    action := t_actionrowset(rows, 'PV VM Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL',v_data_out);


end;


procedure spPVVMValidate (row_ori in out t_row)
as
  actions t_actions := t_actions();

    rows      t_rows;
    row          t_row;
    v_val_ind boolean;
    v_item_id number;
    v_ver_nr number(4,2);
    v_temp integer;
 begin

-- ITEM_2_ID : Value Domain public Id; ITEM_2_VER_NR: Value Domain Version; ITEM_2_LONG_NM: Used to see if Concept or String - VM String Type
    v_val_ind := true;
   ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','');
-- If string type is CONCEPTS, then decompose and check to make sure atleast one concept is valid
   if (upper(ihook.getColumnValue(row_ori, 'VM_STR_TYP')) = 'CONCEPTS') then
--   raise_application_error(-20000, 'TEst');
       nci_dec_mgmt.createValAIWithConcept(row_ori, 1,53,'V', 'STRING', actions) ;
       if (ihook.getColumnValue(row_ori, 'CNCPT_1_ITEM_ID_1') is null) then
             ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',   'No valid concepts specified for Value Meaning.' || chr(13));                      
        v_val_ind := false;
       end if;
    end if;

    -- If string type is ID, make sure ID is valid.
    if (upper(ihook.getColumnValue(row_ori, 'VM_STR_TYP')) = 'ID') then
     select count(*) into v_temp from admin_item where item_id = ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') and currnt_ver_ind = 1 and admin_item_typ_id = 53;
     if (v_temp = 0) then
             ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'Specified VM ID is not found.' || chr(13));                      
        v_val_ind := false;
       end if;
    end if;
if (upper(ihook.getColumnValue(row_ori, 'VM_STR_TYP'))  = 'TEXT') then
        nci_dec_mgmt.createAIWithoutConcept(row_ori , 1, 53, ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'),nvl(ihook.getColumnValue(row_ori, 'ITEM_1_DEF'), ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1')),'C',
        actions);
         v_item_id := ihook.getColumnValue(row_ori,'ITEM_1_ID');
        v_ver_nr :=  ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR');
        ihook.setColumnValue(row_ori, 'GEN_STR', ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'));
    end if;
    -- check if value already exists for the VD
    for cur in (select * from perm_val where val_dom_item_id= ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID')
    and val_dom_ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') and upper(perm_val_nm) = upper(ihook.getColumnValue(row_ori, 'PERM_VAL_NM'))) loop
       ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',       ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') ||  'Value already exists in the specified Value Domain.' || chr(13));                      
        v_val_ind := false;
    end loop;

   -- nci_pv_vm.spValCreateImport(row_ori, 'V', actions, v_val_ind);
           if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
    else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','No Errors' ||  chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') );                      

    end if;
   -- end of validation

   for cur in (select * from value_dom where item_id = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')
   and ihook.getColumnValue(row_ori, 'CONC_DOM_ITEM_ID') is null) loop
        ihook.setColumnValue(row_ori, 'CONC_DOM_ITEM_ID', cur.CONC_DOM_ITEM_ID);
        ihook.setColumnValue(row_ori, 'CONC_DOM_VER_NR', cur.CONC_DOM_VER_NR);
   end loop;

 /*  for cur in (select * from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_2_ID') and ver_nr = ihook.getColumnValue(row_ori, 'ITEM_2_VER_NR')) loop
        ihook.setColumnValue(row_ori, 'CNTXT_ITEM_ID', cur.CNTXT_ITEM_ID);
        ihook.setColumnValue(row_ori, 'CNTXT_VER_NR', cur.CNTXT_VER_NR);
   end loop;*/
      ihook.setColumnValue(row_ori, 'CNTXT_ITEM_ID', 20000000024); -- NCIP
        ihook.setColumnValue(row_ori, 'CNTXT_VER_NR', 1);
 

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
    k integer;
    row_to_comp t_row;
    v_batch_nbr integer;
    v_val_ind  boolean;
 action t_actionRowset;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
   rows := t_rows();
 
for i in 1..hookinput.originalRowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_val_ind := true;
    ihook.setColumnValue(row_ori,'CTL_VAL_MSG', '');
  if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
        for k in 1..rows.count loop
            row_to_comp := rows(k);
            
    if ((ihook.getColumnValue(row_to_comp, 'DE_CONC_ITEM_ID') = ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') 
    and ihook.getColumnValue(row_to_comp, 'DE_CONC_VER_NR') = ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR')
    and ihook.getColumnValue(row_to_comp, 'VAL_DOM_ITEM_ID') = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') 
    and ihook.getColumnValue(row_to_comp, 'VAL_DOM_VER_NR') = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')
    and ihook.getColumnValue(row_to_comp, 'CNTXT_ITEM_ID') = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') 
    and ihook.getColumnValue(row_to_comp, 'CNTXT_VER_NR') = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR') ) or
    (ihook.getColumnValue(row_to_comp, 'CDE_ITEM_LONG_NM') = ihook.getColumnValue(row_ori, 'CDE_ITEM_LONG_NM') 
    and ihook.getColumnValue(row_to_comp, 'CNTXT_ITEM_ID') = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') 
    and ihook.getColumnValue(row_to_comp, 'CNTXT_VER_NR') = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')) ) 
     then
    v_val_ind := false;
    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
   end if;
   end loop;
    if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
              ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'Duplicate found in the same import file. Batch Number: ' || v_batch_nbr );  
    else
       nci_chng_mgmt.spDEValCreateImport(row_ori, 'C', actions, v_val_ind);
        if (v_val_ind = true) then
        iHook.setColumnValue (row_ori, 'CTL_VAL_STUS', 'PROCESSED');
        end if;
    end if;
    rows.extend; rows(rows.last) := row_ori;
    end if;
end loop;
  action := t_actionrowset(rows, 'CDE Import', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);
end;


procedure spCreateCDEImportCons (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
 --nci_util.debugHook('GENERAL',v_data_out);
end;

procedure spCreateValVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2)
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
  rows := t_rows();
  
for i in 1..hookinput.originalRowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    if (ihook.getColumNValue(row_ori, 'CTL_VAL_STUS')<> 'PROCESSED') then
    v_val_ind := true;
    ihook.setColumnValue(row_ori,'CTL_VAL_MSG', '');
            nci_vd.spVDValCreateImport(row_ori, 'V', actions, v_val_ind);
  
        if (ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') is null and v_val_ind = true and v_mode = 'C') then -- only go thru creating new if not specified
            nci_vd.spVDValCreateImport(row_ori, 'C', actions, v_val_ind);
            if (v_val_ind = true) then
                iHook.setColumnValue (row_ori, 'CTL_VAL_STUS', 'PROCESSED');
            end if;
        end if;

      if ( v_val_ind = true and v_mode = 'V') then -- only go thru creating new if not specified
                iHook.setColumnValue (row_ori, 'CTL_VAL_STUS', 'VALIDATED');
        end if;

      if ( v_val_ind = false and v_mode = 'V') then -- only go thru creating new if not specified
                iHook.setColumnValue (row_ori, 'CTL_VAL_STUS', 'ERRORS');
        end if;
    rows.extend; rows(rows.last) := row_ori;
   
end if;    
end loop;
 action := t_actionrowset(rows, 'VD Import', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);
end;

end;
/
