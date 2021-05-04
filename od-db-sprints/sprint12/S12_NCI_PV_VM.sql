create or replace PACKAGE            nci_PV_VM AS

PROCEDURE spPVVMCreateNew (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
PROCEDURE spPVVMCreateNewBulk (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
PROCEDURE spVMEdit (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);

procedure spPVVMCommon ( v_init in t_rowset,  v_op  in varchar2, hookInput in t_hookInput, hookOutput in out t_hookOutput);
procedure createPVVMBulk ( rowform in t_row,  hookInput in t_hookInput, hookOutput in out t_hookOutput);

procedure setDefaultParamPVVM (row_ori in t_row, row in out t_row);
procedure chkPVVMActionValid ( row_ori in t_row, v_usr_id in varchar2);


function getPVVMQuestion return t_question;
function getVMEditQuestion (v_src_tbl_nm in varchar2) return t_question;
function getPVVMQuestionBulk return t_question;
function getPVVMCreateFormBulk (v_rowset in t_rowset) return t_forms;


function getPVVMCreateForm (v_rowset in t_rowset) return t_forms;
function getVMEditForm (v_rowset in t_rowset) return t_forms;
procedure spVMCommon ( v_init in t_rowset,  hookInput in t_hookInput, hookOutput in out t_hookOutput);
procedure createVMConcept (rowform in out t_row, v_cncpt_src in varchar2, v_mode in varchar2,  actions in out t_actions);

END;
/
create or replace PACKAGE BODY            nci_PV_VM AS

c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';



procedure setDefaultParamPVVM ( row_ori in t_row, row in out t_row)
as
begin
    ihook.setColumnValue(row, 'STG_AI_ID', 1);
    ihook.setColumnValue(row, 'ITEM_2_NM', ihook.getColumnValue(row_ori, 'ITEM_NM')); --Using not used attribute ITEM_2_NM to show selected VD.
   -- Set default Conc Dom 
    for cur in (select * from value_dom where item_id =ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR') )loop
           ihook.setColumnValue(row, 'CONC_DOM_ITEM_ID', cur.CONC_DOM_ITEM_ID);
         ihook.setColumnValue(row, 'CONC_DOM_VER_NR', cur.CONC_DOM_VER_NR);
     end loop;
     
     -- Set default context to NCIP
    ihook.setColumnValue(row, 'CNTXT_ITEM_ID',20000000024 );
    ihook.setColumnValue(row, 'CNTXT_VER_NR', 1);
    
end;



procedure chkPVVMActionValid ( row_ori in t_row, v_usr_id in varchar2)
as
begin
    
  -- Raise error if not authorized
     if (nci_11179_2.isUserAuth(ihook.getColumnValue(row_ori,'ITEM_ID'),ihook.getColumnValue(row_ori,'VER_NR') , v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;
    
    if (ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') <> 3) then
        raise_application_error(-20000, 'This action is only applicable for Value Domains.');
        return;
    end if;
    
    for cur in (select * from value_dom where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR')
    and VAL_DOM_TYP_ID <> 17) loop
        raise_application_error(-20000, 'PV/VM cannot be added - Selected Value Domain is non-enumerated. ');
        return;
   end loop;
   
end;

-- Create new PV/VM with multiple concepts in VM
PROCEDURE spPVVMCreateNew ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as
  hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
    rowsetai  t_rowset;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    
    row_ori :=  hookInput.originalRowset.rowset(1);

    chkPVVMActionValid ( row_ori, v_usr_id );
    -- Default for new row. Dummy Identifier has to be set else error.
    row := t_row();
    setDefaultParamPVVM (row_ori, row);
      
    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowsetai := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT'); -- Default values for form

    spPVVMCommon(rowsetai, 'insert', hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     nci_util.debugHook('GENERAL',v_data_out);
end;

-- Create new PV/VM with  concepts in VM
PROCEDURE spPVVMCreateNewBulk ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as
  hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
    rowsetai  t_rowset;
    forms t_forms;
  form1 t_form;
 rowform  t_row;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    
    row_ori :=  hookInput.originalRowset.rowset(1);
    chkPVVMActionValid ( row_ori, v_usr_id );

    if (hookinput.invocationnumber = 0) then
    -- Default for new row. Dummy Identifier has to be set else error.
    row := t_row();
    setDefaultParamPVVM (row_ori, row);
    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowsetai := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT'); -- Default values for form
    hookoutput.question := getPVVMQuestionBulk;
        -- Send initial rowset to create the form.
    hookOutput.forms :=getPVVMCreateFormBulk(rowsetai);

    else -- second invocation
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);
        createPVVMBulk(rowform,hookInput,hookOutput);
        
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     nci_util.debugHook('GENERAL',v_data_out);
end;


-- Edit an existing DEC

PROCEDURE spVMEdit ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_item_nm varchar2(255);
    v_item_def varchar2(4000);
    v_item_id  number;
    v_ver_nr  number(4,2);
    v_item_type_id number;
   rowset  t_rowset;
    v_tbl_nm varchar2(100);
begin
    -- Standard header
    hookInput                    := Ihook.gethookinput (v_data_in);
    hookOutput.invocationnumber  := hookInput.invocationnumber;
    hookOutput.originalrowset    := hookInput.originalrowset;

    -- Get the selected row
    row_ori :=  hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_item_type_id := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');
    v_tbl_nm := hookinput.originalRowset.tablename;

  --  raise_application_error(-20000, v_tbl_nm);
    
    if (v_tbl_nm = 'Administered Item') then
        v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
        v_item_nm := ihook.getColumnValue(row_ori, 'ITEM_NM');
        v_item_def := ihook.getColumnValue(row_ori, 'ITEM_DESC');
    else
        v_item_id := ihook.getColumnValue(row_ori, 'NCI_VAL_MEAN_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'NCI_VAL_MEAN_VER_NR');
        select item_nm, item_desc into v_item_nm, v_item_def from admin_item where item_id = v_item_id and ver_nr = v_ver_nr;
    end if ;
    -- Check if user is authorized to edit
    if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;

    -- If called from Admin Item
    if (v_item_type_id <> 53 and upper(hookinput.originalRowset.tablename) like 'ADMIN%') then
        raise_application_error(-20000,'!!! This functionality is only applicable for VM !!!');
    end if;

    row := row_ori;


     -- Copy VM concepts
    nci_11179.spReturnConceptRow (v_item_id, v_ver_nr, 53, 1, row );
    
    -- Internal dummy is is set to 1. 
    ihook.setColumnValue(row, 'STG_AI_ID', 1);
    ihook.setColumnValue(row, 'ITEM_2_ID', v_item_id);  --- Used in update later
    ihook.setColumnValue(row, 'ITEM_2_VER_NR', v_ver_nr);   --- Used in update later
    
  --  raise_application_error(-20000, ihook.getColumnValue(row, 'CNCPT_1_ITEM_ID_1'));
        ihook.setColumnValue(row, 'ITEM_2_NM',  v_item_nm);
        ihook.setColumnValue(row, 'ITEM_2_DEF',  v_item_def);
    
    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowset := t_rowset(rows, 'VM Edit (Hook)', 1, 'NCI_STG_AI_CNCPT_CREAT');

    nci_pv_vm.spVMCommon(rowset, hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

nci_util.debugHook('GENERAL', v_data_out);

end;


procedure createPVVMBulk ( rowform in t_row,  hookInput in t_hookInput, hookOutput in out t_hookOutput)
AS
  forms t_forms;
  form1 t_form;

  row t_row;
  row_ori t_row;
  rowset            t_rowset;
 v_cncpt_long_nm  varchar2(255);
 v_cncpt_nm  varchar2(255);
 v_cncpt_def varchar2(4000);
 v_item_id number;
 v_ver_nr number(4,2);
  cnt integer;
    actions t_actions := t_actions();
  action t_actionRowset;
  i integer := 0;
  v_cncpt_id number;
  v_cncpt_ver_nr number(4,2);
 v_temp integer;
  v_item_typ_glb integer;
  v_pv  varchar2(255);
  v_vd_item_id number;
  v_vd_ver_nr number(4,2);
  v_vm_rows t_rows;
  v_vm_cd_rows t_rows;
  v_pv_rows  t_rows;
begin
    v_item_typ_glb := 53;
    row_ori :=  hookInput.originalRowset.rowset(1);
    v_vm_rows := t_rows();
    v_vm_cd_rows := t_rows();
    v_pv_rows := t_rows();
    
      v_vd_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
      v_vd_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
      
      for i in 1..10 loop  -- Max of 10 pairs
        v_cncpt_id := ihook.getColumnValue(rowform,'CNCPT_1_ITEM_ID_' || i );
        v_cncpt_ver_nr := ihook.getColumnValue(rowform,'CNCPT_1_VER_NR_' || i );
        v_pv :=  trim(ihook.getColumnValue(rowform,'PV_' || i));
        
        -- If all values specified
        if (v_cncpt_id is not null and v_cncpt_ver_nr is not null and v_pv is not null) then
            -- check if VM already exists
                select item_nm, item_long_nm, item_desc into v_cncpt_nm, v_cncpt_long_nm, v_cncpt_def 
                from admin_item where item_id = v_cncpt_id and ver_nr = v_cncpt_ver_nr;
                
                v_item_id := null;
                v_ver_nr := 1;
                -- Check if VM exists
                for cur in (select ai.item_id , ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.admin_item_typ_id = 53 and
                ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_cncpt_long_nm) loop
                  v_item_id := cur.item_id;
                  v_ver_nr :=cur.ver_nr;
                end loop;
                
                if (v_item_id is null) then -- create new VM
                    v_ver_nr := 1;
                
                        row := t_row();
                        v_item_id := nci_11179.getItemId;
                        ihook.setColumnValue(row,'ITEM_ID', v_item_id);
                        ihook.setColumnValue(row,'VER_NR', 1);
                        ihook.setColumnValue(row,'CNCPT_ITEM_ID',v_cncpt_id);
                        ihook.setColumnValue(row,'CNCPT_VER_NR', v_cncpt_ver_nr);
                        ihook.setColumnValue(row,'NCI_ORD', 1);
                        ihook.setColumnValue(row,'NCI_PRMRY_IND', 1);
                        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
                        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 53);
                        ihook.setColumnValue(row,'ADMIN_STUS_ID',66 );
                        ihook.setColumnValue(row,'REGSTR_STUS_ID',9 );
                        ihook.setColumnValue(row,'ITEM_LONG_NM', v_cncpt_long_nm);
                        ihook.setColumnValue(row,'ITEM_DESC', v_cncpt_def);
                        ihook.setColumnValue(row,'ITEM_NM', v_cncpt_nm);
                        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
                        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
                        ihook.setColumnValue(row,'CNCPT_CONCAT', v_cncpt_long_nm);
                        ihook.setColumnValue(row,'CNCPT_CONCAT_DEF', v_cncpt_def);
                        ihook.setColumnValue(row,'CNCPT_CONCAT_NM', v_cncpt_nm);
                        ihook.setColumnValue(row,'LST_UPD_DT',sysdate );
                        
                          v_vm_rows.extend;            v_vm_rows(v_vm_rows.last) := row;
                        

                end if;
                
                -- Check if VM-CD exists
                select count(*) into v_temp from CONC_DOM_VAL_MEAN where CONC_DOM_ITEM_ID = ihook.getColumnValue(rowform, 'CONC_DOM_ITEM_ID') and 
                CONC_DOM_VER_NR = ihook.getColumnValue(rowform, 'CONC_DOM_VER_NR') and NCI_VAL_MEAN_ITEM_ID = v_item_id and NCI_VAL_MEAN_VER_NR =v_ver_nr;

                if (v_temp = 0) then
                    row := t_row();
                    ihook.setColumnValue(row,'CONC_DOM_ITEM_ID', ihook.getColumnValue(rowform, 'CONC_DOM_ITEM_ID'));
                    ihook.setColumnValue(row,'CONC_DOM_VER_NR', ihook.getColumnValue(rowform, 'CONC_DOM_VER_NR'));
                    ihook.setColumnValue(row,'NCI_VAL_MEAN_ITEM_ID',  v_item_id);
                    ihook.setColumnValue(row,'NCI_VAL_MEAN_VER_NR', v_ver_nr);
        
                    v_vm_cd_rows.extend;            v_vm_cd_rows(v_vm_cd_rows.last) := row;
                end if;
                
                -- Check if PV exists
                select count(*) into v_temp from PERM_VAL where VAL_DOM_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and 
                VAL_DOM_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR') and NCI_VAL_MEAN_ITEM_ID = v_item_id and NCI_VAL_MEAN_VER_NR = v_ver_nr
                and upper(PERM_VAL_NM) = upper(v_pv);
        
                if (v_temp = 0) then
                    row := t_row();
                    ihook.setColumnValue(row,'PERM_VAL_NM', v_pv);
                    ihook.setColumnValue(row,'VAL_DOM_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
                    ihook.setColumnValue(row,'VAL_DOM_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
                    ihook.setColumnValue(row,'NCI_VAL_MEAN_ITEM_ID',  v_item_id);
                    ihook.setColumnValue(row,'NCI_VAL_MEAN_VER_NR', v_ver_nr);
                    ihook.setColumnValue(row,'VAL_ID',-1);
                    v_pv_rows.extend;   v_pv_rows(v_pv_rows.last) := row;
            end if;
           end if;  -- all values needed are not null 
          end loop; -- i 1 to 10


        if (v_vm_rows.count > 0) then
                action := t_actionrowset(v_vm_rows, 'Administered Item (No Sequence)', 2,1,'insert');
                actions.extend;
                actions(actions.last) := action;

                action := t_actionrowset(v_vm_rows, 'NCI AI Extension (Hook)', 2,3,'insert');
                actions.extend;
                actions(actions.last) := action;
              
                action := t_actionrowset(v_vm_rows, 'Value Meaning', 2,2,'insert');
                actions.extend;
                actions(actions.last) := action;
                              
                action := t_actionrowset(v_vm_rows, 'Items under Concept', 2,6,'insert');
                actions.extend;
                actions(actions.last) := action;
         end if;
         
          if (v_vm_cd_rows.count > 0) then
            action := t_actionrowset(v_vm_cd_rows, 'Value Meanings', 2,10,'insert');
            actions.extend;
            actions(actions.last) := action;
         end if;
         
          if (v_pv_rows.count > 0) then
            action := t_actionrowset(v_pv_rows, 'Permissible Values (Edit AI)', 2,11,'insert');
            actions.extend;
            actions(actions.last) := action;
         end if;
         
  
    if (actions.count > 0) then
        hookoutput.actions := actions;
        hookoutput.message := v_vm_rows.count || ' Value Meanings created. ' || v_pv_rows.count || ' permissible values created. ';
    end if;

END;


-- Common routine for DEC - Create or Update
-- v_init is the initial rowset to populate.
-- v_op is insert or update
PROCEDURE       spPVVMCommon ( v_init in t_rowset,  v_op  in varchar2,  hookInput in t_hookInput, hookOutput in out t_hookOutput)
AS
  rowform t_row;
  forms t_forms;
  form1 t_form;

  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowset            t_rowset;
 v_str  varchar2(255);
 v_nm  varchar2(255);
 v_item_id number;
 v_ver_nr number(4,2);
  cnt integer;
k integer;
    actions t_actions := t_actions();
  action t_actionRowset;
  v_msg varchar2(1000);
  i integer := 0;
  v_err  integer;
  column  t_column;
  v_dec_nm varchar2(255);
  v_cncpt_nm varchar2(255);
  v_long_nm varchar2(255);
  v_def varchar2(4000);
  v_temp integer;
  is_valid boolean;
  v_item_typ_glb integer;
  v_pv  varchar2(255);
begin
    v_item_typ_glb := 53;
    row_ori :=  hookInput.originalRowset.rowset(1);

   if hookInput.invocationNumber = 0 then
        --  Get question. Either create or edit
          HOOKOUTPUT.QUESTION    := getPVVMQuestion;

        -- Send initial rowset to create the form.
          hookOutput.forms :=getPVVMCreateForm(v_init);

    else
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);
        row := t_row();        rows := t_rows();
        is_valid := true;
        k := 1;

        if HOOKINPUT.ANSWERID = 1 or Hookinput.answerid = 3 then  -- Validate using string
                     for i in  1..10 loop
                            ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                            ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                    end loop;
                nci_dec_mgmt.createValAIWithConcept(rowform , k,v_item_typ_glb ,'V','STRING',actions);
            end if;

        if HOOKINPUT.ANSWERID = 2 or Hookinput.answerid = 4 then  -- Validate using drop-down
          --  for k in  1..2  loop
               nci_dec_mgmt.createValAIWithConcept(rowform , k,v_item_typ_glb ,'V','DROP-DOWN',actions);
         --   end loop;
        end if;

    if (hookinput.answerid < 5) then
    -- Show generated name
       ihook.setColumnValue(rowform, 'GEN_STR',ihook.getColumnValue(rowform,'ITEM_1_NM') ) ;
       ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'VALIDATED');
   
        if (   ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is null) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'Concept missing');
                  is_valid := false;
        end if;
    else
        if (   ihook.getColumnValue(rowform, 'ITEM_2_LONG_NM') is null) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'No specified VM name');
                  is_valid := false;
        end if;
    end if;
         rows := t_rows();

         -- If any of the test fails or if the user has triggered validation, then go back to the screen.
        if (is_valid=false or hookinput.answerid = 1 or hookinput.answerid = 2) then
                rows.extend;
                rows(rows.last) := rowform;
                rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
                hookOutput.forms := getPVVMCreateForm(rowset);
                HOOKOUTPUT.QUESTION    := getPVVMQuestion;
                return;
        end if;

    -- If all the tests have passed and the user has asked for create, then create DEC and optionally OC and Prop.

    IF HOOKINPUT.ANSWERID in ( 3,4)  and is_valid = true THEN  -- Create
        nci_dec_mgmt.createValAIWithConcept(rowform , 1,v_item_typ_glb ,'C','DROP-DOWN',actions); -- Vm
    elsif (hookinput.answerid = 5 and is_Valid = true) then 
        nci_dec_mgmt.createAIWithoutConcept(rowform , 1, 53, ihook.getColumnValue(rowform, 'ITEM_2_LONG_NM'),nvl(ihook.getColumnValue(rowform, 'ITEM_2_DEF'), ihook.getColumnValue(rowform, 'ITEM_2_LONG_NM')),
        actions);
    end if;
      -- Create PV
      
      v_item_id := ihook.getColumnValue(rowform,'ITEM_1_ID');
      if (hookinput.answerid = 5) then -- use specified value
        v_pv :=  nvl(ihook.getColumnValue(rowform,'PERM_VAL_NM'),ihook.getColumnValue(rowform,'ITEM_2_LONG_NM') );
      else
        v_pv :=  nvl(ihook.getColumnValue(rowform,'PERM_VAL_NM'),ihook.getColumnValue(rowform,'ITEM_1_NM') );
      end if;
      hookoutput.message := 'Value Meaning ID: ' || v_item_id;
      
        select count(*) into v_temp from CONC_DOM_VAL_MEAN where CONC_DOM_ITEM_ID = ihook.getColumnValue(rowform, 'CONC_DOM_ITEM_ID') and 
        CONC_DOM_VER_NR = ihook.getColumnValue(rowform, 'CONC_DOM_VER_NR') and NCI_VAL_MEAN_ITEM_ID = v_item_id and NCI_VAL_MEAN_VER_NR = ihook.getColumnValue(rowform, 'ITEM_1_VER_NR');

        if (v_temp = 0) then
        rows := t_rows();
        row := t_row();
        ihook.setColumnValue(row,'CONC_DOM_ITEM_ID', ihook.getColumnValue(rowform, 'CONC_DOM_ITEM_ID'));
        ihook.setColumnValue(row,'CONC_DOM_VER_NR', ihook.getColumnValue(rowform, 'CONC_DOM_VER_NR'));
        ihook.setColumnValue(row,'NCI_VAL_MEAN_ITEM_ID',  v_item_id);
        ihook.setColumnValue(row,'NCI_VAL_MEAN_VER_NR', ihook.getColumnValue(rowform, 'ITEM_1_VER_NR'));
        
            rows.extend;
            rows(rows.last) := row;
          action := t_actionrowset(rows, 'Value Meanings', 2,10,'insert');
           actions.extend;
           actions(actions.last) := action;
 
      end if;
      if (v_pv is not null) then
        select count(*) into v_temp from PERM_VAL where VAL_DOM_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and 
        VAL_DOM_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR') and NCI_VAL_MEAN_ITEM_ID = v_item_id and NCI_VAL_MEAN_VER_NR = ihook.getColumnValue(rowform, 'ITEM_1_VER_NR')
        and upper(PERM_VAL_NM) = upper(v_pv);
        
        if (v_temp = 0) then
        rows := t_rows();
        row := t_row();
        ihook.setColumnValue(row,'PERM_VAL_NM', v_pv);
        ihook.setColumnValue(row,'VAL_DOM_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row,'VAL_DOM_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
        ihook.setColumnValue(row,'NCI_VAL_MEAN_ITEM_ID',  v_item_id);
        ihook.setColumnValue(row,'NCI_VAL_MEAN_VER_NR', 1);
    
        ihook.setColumnValue(row,'VAL_ID',-1);
            rows.extend;
            rows(rows.last) := row;
          action := t_actionrowset(rows, 'Permissible Values (Edit AI)', 2,19,'insert');
           actions.extend;
           actions(actions.last) := action;

        end if;
        
      end if;
     end if; 
        
    
    if (actions.count > 0) then
        hookoutput.actions := actions;
         --   raise_application_error(-20000,'Inside 1' || v_item_id);

    end if;

END;

-- Only called from VM Edit
PROCEDURE       spVMCommon ( v_init in t_rowset,  hookInput in t_hookInput, hookOutput in out t_hookOutput)
AS
  rowform t_row;
  forms t_forms;
  form1 t_form;

  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowset            t_rowset;
 v_str  varchar2(255);
 v_nm  varchar2(255);
 v_item_id number;
 v_ver_nr number(4,2);
  cnt integer;
k integer;
    actions t_actions := t_actions();
  action t_actionRowset;
  v_msg varchar2(1000);

  v_dec_nm varchar2(255);
  v_cncpt_nm varchar2(255);
  v_long_nm varchar2(255);
  v_def varchar2(4000);
  v_temp integer;
  is_valid boolean;
  v_item_typ_glb integer;
  v_pv  varchar2(255);
begin
    v_item_typ_glb := 53;
    row_ori :=  hookInput.originalRowset.rowset(1);

   if hookInput.invocationNumber = 0 then
        --  Get question. Either create or edit
          HOOKOUTPUT.QUESTION    := getVMEditQuestion(hookinput.originalrowset.tablename);

          hookOutput.forms :=getVMEditForm(v_init);

    else
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);
        row := t_row();        rows := t_rows();
        is_valid := true;
        k := 1;

        
        if (HOOKINPUT.ANSWERID = 2 and ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is not null) then  -- Validate using drop-down
               nci_dec_mgmt.createValAIWithConcept(rowform , k,v_item_typ_glb ,'V','DROP-DOWN',actions);
               rows := t_rows();  rows.extend;  rows(rows.last) := rowform;      
               rowset := t_rowset(rows, 'VM Edit (Hook)', 1, 'NCI_STG_AI_CNCPT_CREAT');
                HOOKOUTPUT.QUESTION    := getVMEditQuestion(hookinput.originalrowset.tablename);

          hookOutput.forms :=getVMEditForm(rowset);
          return;

        end if;

        if (HOOKINPUT.ANSWERID = 4 and is_Valid = true) then
              nci_pv_vm.createVMConcept(rowform ,'DROP-DOWN', 'C', actions);
         --   end loop;
        end if;
        

    if (actions.count > 0) then
        hookoutput.actions := actions;
    end if;


end if;

END;



function getPVVMQuestion return t_question
is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Validate using String');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
  --  ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(2, 2, 'Validate using drop-down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    ANSWER                     := T_ANSWER(3, 3, 'Create using String');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    ANSWER                     := T_ANSWER(4, 4, 'Create using drop-down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
      ANSWER                     := T_ANSWER(5, 5, 'Create using specified');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Create VM and/or PV.', ANSWERS);

return question;
end;


function getPVVMQuestionBulk return t_question
is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Create');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
  QUESTION               := T_QUESTION('Create PV and/or VM.', ANSWERS);

return question;
end;

function getVMEditQuestion (v_src_tbl_nm in varchar2) return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin
--- If Edit DEC
 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(2, 2, 'Validate using drop-down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    ANSWER                     := T_ANSWER(4, 4, 'Update');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
   -- if (v_src_tbl_nm like '%Per%') then
   --     ANSWER                     := T_ANSWER(3, 3, 'Replace with found VM.');
    --    ANSWERS.EXTEND;
    --    ANSWERS(ANSWERS.LAST) := ANSWER;
    --end if;
    QUESTION               := T_QUESTION('Edit VM.', ANSWERS);

return question;
end;

-- Create form for Multi-concept VM
function getPVVMCreateForm (v_rowset in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('PV VM Creation (Hook)', 2,1);
    form1.rowset :=v_rowset;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;

function getVMEditForm (v_rowset in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('VM Edit (Hook)', 2,1);
    form1.rowset :=v_rowset;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;

-- Create form for single concept VM
function getPVVMCreateFormBulk (v_rowset in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('PV VM Creation Single (Hook)', 2,1);
    form1.rowset :=v_rowset;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;


-- v_mode : V - Validate, C - Validation and Create;  v_cncpt_src:  STRING: String; DROP-DOWN: Drop-downs
procedure createVMConcept(rowform in out t_row, v_cncpt_src in varchar2, v_mode in varchar2,  actions in out t_actions) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
row t_row;
rows t_rows;
 action t_actionRowset;
 v_cncpt_id  number;
 v_cncpt_ver_nr number(4,2);
 v_temp_id  number;
 v_temp_ver number(4,2);
 v_item_id  number;
 v_ver_nr number(4,2);
 v_id integer;
 v_long_nm_suf  varchar2(255);
 j integer;
i integer;
cnt integer;
v_str varchar2(255);
v_obj_nm  varchar2(100);
v_temp varchar2(4000);
v_cncpt_nm varchar2(255);
idx integer;
v_item_typ_id integer;
begin

idx := 1;
v_item_typ_id := 53;

/*
3 possible scenarios

1. Clicked on update without changing anything. Do nothing.
2. Only updated specified name. No concepts. In this case, only update the name. 
3.  Updated concepts. Delete existing concepts and add new concepts. 

Only drop-downs allowed.

GEN_STR holds current VM name
ITEM_2_ID holds Item ID of VM and ITEM_2_VER_NR holds Version number
*/

-- Initialize variables if something has changed
        rows := t_rows();
        row := t_row();
        j := 0;
        v_item_id := ihook.getColumnValue(rowform, 'ITEM_2_ID'); 
        v_ver_nr := ihook.getColumnValue(rowform, 'ITEM_2_VER_NR');

-- If only name specified
            nci_11179.spReturnAIRow (v_item_id, v_ver_nr, row);
            nci_11179.spReturnAIExtRow (v_item_id, v_ver_nr,  row);
            ihook.setColumnValue(row,'ITEM_NM', ihook.getColumnValue(rowform, 'ITEM_2_NM'));
            ihook.setColumnValue(row,'ITEM_DESC', nvl(ihook.getColumnValue(rowform, 'ITEM_2_DEF'), ihook.getColumnValue(rowform, 'ITEM_2_NM')));
            ihook.setColumnValue(row,'CNCPT_CONCAT', ihook.getColumnValue(rowform, 'ITEM_2_NM'));
            ihook.setColumnValue(row,'CNCPT_CONCAT_NM', ihook.getColumnValue(rowform, 'ITEM_2_NM'));
            ihook.setColumnValue(row,'CNCPT_CONCAT_DEF', ihook.getColumnValue(row, 'ITEM_DESC'));
                 
            rows.extend;     rows(rows.last) := row;
            
            action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'update');
            actions.extend;
            actions(actions.last) := action;

            action := t_actionrowset(rows, 'NCI AI Extension (Hook)', 2,3,'update');
            actions.extend;
            actions(actions.last) := action;
            
            
-- Scenario 3 - first delete current concepts and then insert
        rows := t_rows();
        row := t_row();

        for cur in (select CNCPT_AI_ID from cncpt_admin_item where item_id = v_item_id and ver_nr = v_ver_nr) loop
                row := t_row();
                ihook.setColumnValue (row, 'CNCPT_AI_ID', cur.CNCPT_AI_ID);
                rows.extend;     rows(rows.last) := row;
        end loop;
        
        if rows.count > 0 then
            action := t_actionrowset(rows, 'Items under Concept', 2,1,'delete');
            actions.extend;
            actions(actions.last) := action;
            
            action := t_actionrowset(rows, 'Items under Concept', 2,2,'purge');
            actions.extend;
            actions(actions.last) := action;
        end if;
        
        rows := t_rows();
        
        if (ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is not null) then  --- If drop-down specified, manually entered text is overwritten.
            for i in reverse 0..10 loop
                    v_cncpt_id := ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i);
                    v_cncpt_ver_nr :=  ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i);
                    if( v_cncpt_id is not null) then
                        for cur in (select item_nm, item_long_nm, item_desc from admin_item where item_id = v_cncpt_id and ver_nr = v_cncpt_ver_nr) loop
                                row := t_row();
                                ihook.setColumnValue(row,'ITEM_ID', v_item_id);
                                ihook.setColumnValue(row,'VER_NR', v_ver_nr);
                                ihook.setColumnValue(row,'CNCPT_ITEM_ID',v_cncpt_id);
                                ihook.setColumnValue(row,'CNCPT_VER_NR', v_cncpt_ver_nr);
                                ihook.setColumnValue(row,'NCI_ORD', j);
                                ihook.setColumnValue(row,'CNCPT_AI_ID', -1);
                
                                v_temp := v_temp || i || ':' ||  v_cncpt_id;
                                if j = 0 then
                                    ihook.setColumnValue(row,'NCI_PRMRY_IND', 1);
                                else ihook.setColumnValue(row,'NCI_PRMRY_IND', 0);
                                end if;
                                rows.extend;
                                rows(rows.last) := row;
                                j := j+ 1;
                        end loop;
                    end if;
            end loop;
            action := t_actionrowset(rows, 'Items under Concept', 2,6,'insert');
            actions.extend;
            actions(actions.last) := action;
        end if;
        

end;


END;
/
