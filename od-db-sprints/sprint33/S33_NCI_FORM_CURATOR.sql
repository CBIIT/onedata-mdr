create or replace PACKAGE            nci_form_curator AS
procedure spAddRef (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spAddProt (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spClassify (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spAddRefBlob (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);

END;
/
create or replace PACKAGE BODY            nci_form_curator AS
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';

procedure spAddRef (v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowrel t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a Reference Document this form.');
 end if;

 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add Reference Document', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

    rows := t_rows();
    row := t_row();
        ihook.setColumnValue(row, 'REF_ID', -1);
        ihook.setColumnValue(row, 'ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row, 'VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
       ihook.setColumnValue(row, 'LANG_ID', 1000);
    

        rows.extend; rows(rows.last) := row;
        rowset := t_rowset(rows, 'Reference Documents (Form CO)', 1,'REF');

    forms                  := t_forms();
    form1                  := t_form('Reference Documents (Form CO)', 2,1);
    form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
 ELSE
        forms              := hookInput.forms;
        form1              := forms(1);

        rowform := form1.rowset.rowset(1);
   ihook.setColumnValue(rowform, 'ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(rowform, 'VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
    
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := rowform;

            action             := t_actionrowset(rows, 'Reference Documents (Form CO)', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;
    hookoutput.actions    := actions;
    hookoutput.message := 'Reference Document created successfully.';

  END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spAddRefBlob (v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowrel t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a Reference Document Blob this form.');
 end if;

 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add Reference Document', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

    rows := t_rows();
    row := t_row();
        ihook.setColumnValue(row, 'REF_DOC_ID', -1);
        ihook.setColumnValue(row, 'ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row, 'VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
   --    ihook.setColumnValue(row, 'LANG_ID', 1000);
    

        rows.extend; rows(rows.last) := row;
        rowset := t_rowset(rows, 'Reference Document Blobs (Form CO)', 1,'REF');

    forms                  := t_forms();
    form1                  := t_form('Reference Document Blobs (Form CO)', 2,1);
 --   form1                  := t_form('Reference Document Blobs (Form Curator Hook)', 2,1);
    form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
 ELSE
        forms              := hookInput.forms;
        form1              := forms(1);

        rowform := form1.rowset.rowset(1);
   ihook.setColumnValue(rowform, 'NCI_REF_ID', ihook.getColumnValue(row_ori, 'REF_ID'));
   ihook.setColumnValue(rowform, 'FILE_NM', 'TEST' || ihook.getColumnValue(row_ori, 'REF_ID') );
   
    ihook.setColumnValue(rowform, 'REF_DOC_ID', -1);
      -- ihook.setColumnValue(rowform, 'VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
   raise_application_error (-20000, dbms_lob.getlength(ihook.getColumnValue(row_ori, 'BLOB_COL')));
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := rowform;

            action             := t_actionrowset(rows, 'Reference Document Blobs (Form CO)', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;
    hookoutput.actions    := actions;
    hookoutput.message := 'Reference Document created successfully.';

  END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

procedure spAddProt (v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowrel t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_temp integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add Protocol to this form.');
 end if;

 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add Protocol', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

    rows := t_rows();
    row := t_row();
   --     ihook.setColumnValue(row, 'REF_ID', -1);
        ihook.setColumnValue(row, 'C_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row, 'C_ITEM_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
          ihook.setColumnValue(row, 'REL_TYP_ID',60);
  

        rows.extend; rows(rows.last) := row;
        rowset := t_rowset(rows, 'Protocol-Form Relationship (Form View)', 1,'NCI_ADMIN_ITEM_REL');

    forms                  := t_forms();
    form1                  := t_form('Protocol-Form Relationship (Form View)', 2,1);
    form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
 ELSE
        forms              := hookInput.forms;
        form1              := forms(1);

        rowform := form1.rowset.rowset(1);

 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(rowform, 'P_ITEM_ID'), ihook.getColumnValue(rowform,'P_ITEM_VER_NR'), v_user_id) = false) then
-- raise_application_error(-20000,'Protocol not in your authorized contexts.');
hookoutput.message := 'Protocol not in your authorized Context and was not added.';
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
return;
 end if;
 
   ihook.setColumnValue(rowform, 'C_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(rowform, 'C_ITEM_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
          ihook.setColumnValue(rowform, 'REL_TYP_ID',60);
 

select count(*) into v_temp from nci_admin_item_rel where rel_typ_id = 60 and c_item_id =  ihook.getColumnValue(row_ori, 'ITEM_ID') and 
c_item_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR') and p_item_id = ihook.getColumnValue(rowform, 'P_ITEM_ID') and p_item_ver_nr = ihook.getColumnValue(rowform,'P_ITEM_VER_NR');
if (v_temp = 0) then
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := rowform;

            action             := t_actionrowset(rows, 'Protocol-Form Relationship (Form View)', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;
    hookoutput.actions    := actions;
    hookoutput.message := 'Protocol relationship created successfully.';
else
 hookoutput.message := 'Protocol relationship already exists.';
 end if;
  END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

-- Classify/Unclassify for Super Curators
PROCEDURE spClassify
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id  IN varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();

  actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowform t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;

  question    t_question;
  answer     t_answer;
  answers     t_answers;

  forms     t_forms;
  form1  t_form;

  v_temp integer;
  v_cnt integer;
  v_item_id number;
  v_ver_nr number(4,2);
  v_default_txt varchar2(30) := 'Default is Context Name.' ;

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

    if hookInput.invocationNumber = 0  then
            answers := t_answers();
            answer := t_answer(1, 1, 'Classify');
            answers.extend;          answers(answers.last) := answer;

            question := t_question('Choose Option', answers);

            hookOutput.question := question;

        -- Form only has only pop-up to select Classification
            forms                  := t_forms();
            form1                  := t_form('Unclassify (Hook for Form Curator)', 2,1);
            forms.extend;    forms(forms.last) := form1;

            hookoutput.forms := forms;
  	elsif hookInput.invocationNumber = 1 then
            forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);  -- entered values from user
            rows := t_rows();
            ihook.setColumnValue(rowform, 'REL_TYP_ID', 65);

            v_cnt := 0;   -- Count of total added rows
select cs_item_id, cs_item_ver_nr into v_item_id, v_ver_nr from nci_clsfctn_schm_item where item_id = ihook.getColumnValue(rowform,'P_ITEM_ID') and ver_nr = ihook.getColumnValue(rowform,'P_ITEM_VER_NR');

      
            for i in 1..hookinput.originalrowset.rowset.count loop

                row_ori :=  hookInput.originalRowset.rowset(i);
                row := rowform;

                ihook.setColumnValue(row,'C_ITEM_ID',ihook.getColumnValue(row_ori,'ITEM_ID'));
                ihook.setColumnValue(row,'C_ITEM_VER_NR',ihook.getColumnValue(row_ori,'VER_NR'));
if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = true) then
            -- check if row exists if unclassify and not exists if classify
-- Check context of Classification Scheme
if (nci_form_mgmt.isUserAuth(v_item_id, v_ver_nr, v_user_id) = true) then

                    select count(*) into v_temp from nci_admin_item_rel where
                    p_item_id =  ihook.getColumnValue(rowform,'P_ITEM_ID') and
                    p_item_ver_nr = ihook.getColumnValue(rowform,'P_ITEM_VER_NR') and
                    c_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and
                    c_item_ver_nr = ihook.getColumnValue(row_ori,'VER_NR') and
                    rel_typ_id = 65;
                    if (v_temp = 0) then
                        rows.extend;  rows(rows.last) := row;
                        v_cnt := v_cnt + 1;
                     end if;
                     end if;
                     end if;
            end loop;

            if rows.count > 0 then
                        action := t_actionrowset(rows, 'NCI CSI - DE Relationship', 2,1,'insert');
                        actions.extend; actions(actions.last) := action;
                        hookoutput.message := rows.count || ' items classified. You can only classify Forms and Classifications that are in your authorized contexts.';
       hookoutput.actions := actions;
       else
         hookoutput.message := 'Classification not in your authorized Context and was not added.';
 
            end if;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

end;
/
