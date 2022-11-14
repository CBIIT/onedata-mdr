create or replace PACKAGE            nci_form_curator AS
procedure spAddRef (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spAddProt (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spSAModPropChange (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spSAModPropAdd (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spClassify (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spAddRefBlob (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spDeleteForm (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spDeleteMod (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spDeleteQuest (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure DeleteQuest (v_id in number, v_ver_nr in number, v_idseq in char, v_user_id in varchar2);
procedure DeleteModule (v_id in number, v_ver_nr in number, v_idseq in char, v_user_id in varchar2);
procedure DeleteCommonChildren (v_id in number, v_ver_nr in number, v_idseq in char);
procedure DeleteVV (v_idseq in char, v_user_id in varchar2);
function getProceedQuestion (v_hdr in varchar2) return t_question;
PROCEDURE spCopyModuleUsingID  (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2) ;
END;
/
create or replace PACKAGE BODY            nci_form_curator AS
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
v_deflt_cart_nm varchar2(255) := 'Default';



function getProceedQuestion (v_hdr in varchar2) return t_question
is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Submit');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION(v_hdr, ANSWERS);

return question;
end;

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


procedure spSAModPropChange  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;

i integer;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_sql  varchar2(4000);
  v_msg_str varchar2(255) := '';
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);

-- select frm_item_id, frm_ver_nr into v_frm_id, v_frm_ver_nr from vw_nci_module_de where
--nci_pub_id = ihook.getColumnValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'NCI_VER_NR');
--else
 
 if (hookinput.invocationNUmber = 0) then
 for i in 1..hookinput.originalrowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);
   v_msg_str := substr(v_msg_str || ',' || ihook.getColumnValue(row_ori, 'C_ITEM_ID') || 'v' || ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR'),1,255);
   end loop;
 hookoutput.question := getProceedQuestion ('Confirm. Modules will be deleted and recopied: ' ||substr(v_msg_str,2));
 else
for i in 1..hookinput.originalrowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);
 for cur1 in (select ai.nci_idseq, ai.item_id, ai.ver_nr, r.p_item_id, r.p_item_ver_nr, r.disp_ord, ai.cntxt_item_id, ai.cntxt_ver_nr from admin_item ai,
 nci_admin_item_rel r where ai.item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and ai.ver_nr = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR')
 and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr and r.rel_typ_id = 61) loop
 DeleteModule(cur1.item_id,cur1.ver_nr, cur1.nci_idseq,v_user_id);
 nci_11179.spCopyModuleNCI(actions, ihook.getColumnValue(row_ori,'CPY_MOD_ITEM_ID'), ihook.getColumnValue(row_ori, 'CPY_MOD_VER_NR'),
 -1,1,cur1.p_item_id, cur1.p_item_ver_nr, cur1.disp_ord,'C',cur1.cntxt_item_id, cur1.cntxt_ver_nr, v_user_id);
 
 end loop;
end loop;
   hookoutput.actions:= actions;
  end if;  
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

procedure spSAModPropAdd  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;

i integer;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_sql  varchar2(4000);
  v_msg_str varchar2(255) := '';

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);

-- select frm_item_id, frm_ver_nr into v_frm_id, v_frm_ver_nr from vw_nci_module_de where
--nci_pub_id = ihook.getColumnValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'NCI_VER_NR');
--else
 
 if (hookinput.invocationNUmber = 0) then
 for i in 1..hookinput.originalrowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);
   v_msg_str := substr(v_msg_str || ',' || ihook.getColumnValue(row_ori, 'C_ITEM_ID') || 'v' || ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR'),1,255);
   end loop;
 hookoutput.question := getProceedQuestion ('Confirm. Modules will be added to forms with following modules: ' ||substr(v_msg_str,2));
 else
for i in 1..hookinput.originalrowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);
 for cur1 in (select ai.nci_idseq, ai.item_id, ai.ver_nr, r.p_item_id, r.p_item_ver_nr, ai.cntxt_item_id, ai.cntxt_ver_nr from admin_item ai,
 nci_admin_item_rel r where ai.item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and ai.ver_nr = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR')
 and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr and r.rel_typ_id = 61) loop
 select max(disp_ord)+1 into v_disp_ord from nci_admin_item_rel where rel_typ_id = 61 and p_item_id = cur1.p_item_id and p_item_ver_nr = cur1.p_item_ver_nr;
nci_11179.spCopyModuleNCI(actions, ihook.getColumnValue(row_ori,'CPY_MOD_ITEM_ID'), ihook.getColumnValue(row_ori, 'CPY_MOD_VER_NR'),
 -1,1,cur1.p_item_id, cur1.p_item_ver_nr, v_disp_ord,'C',cur1.cntxt_item_id, cur1.cntxt_ver_nr, v_user_id);
 
 end loop;
end loop;
   hookoutput.actions:= actions;
  end if;  
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spDeleteQuest  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;

i integer;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_sql  varchar2(4000);
  v_msg_str varchar2(255) := '';
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);

-- select frm_item_id, frm_ver_nr into v_frm_id, v_frm_ver_nr from vw_nci_module_de where
--nci_pub_id = ihook.getColumnValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'NCI_VER_NR');
--else
 select m.p_item_id, m.p_item_ver_nr into v_frm_id, v_frm_ver_nr from nci_admin_item_rel m where
 m.c_item_id = ihook.getColumnValue(row_ori,'P_ITEM_ID') and m.c_item_ver_nr = ihook.getColumnValue(row_ori,'P_ITEM_VER_NR');
 

 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to delete questions on this form.');
 end if;
 
 if (hookinput.invocationNUmber = 0) then
 for i in 1..hookinput.originalrowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);
   v_msg_str := substr(v_msg_str || ',' || ihook.getColumnValue(row_ori, 'NCI_PUB_ID') || 'v' || ihook.getColumnValue(row_ori, 'NCI_VER_NR'),1,255);
   end loop;
 hookoutput.question := getProceedQuestion ('Permanently Delete Question(s): ' ||substr(v_msg_str,2));
 else
for i in 1..hookinput.originalrowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);
 for cur1 in (select * from nci_admin_item_rel_alt_key where nci_pub_id  = ihook.getCOlumnValue(row_ori,'NCI_PUB_ID') and 
 nci_ver_nr =  ihook.getColumnValue(row_ori,'NCI_VER_NR')) loop
 DeleteQuest(cur1.nci_pub_id, cur1.nci_ver_nr, cur1.nci_idseq,v_user_id);
 end loop;
end loop;

 i := 0;
    for cur in (select * from NCI_ADMIN_ITEM_REL_ALT_KEY where nvl(fld_delete,0) = 0 and p_item_id =   ihook.getColumnValue(row_ori, 'P_ITEM_ID') and p_item_ver_nr =
             ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') and rel_typ_id = 63 order by disp_ord) loop
                if (i <> cur.disp_ord) then
                    row := t_row();
                    v_sql := 'select * from NCI_ADMIN_ITEM_REL_ALT_KEY where  p_item_id = ' ||  cur.p_item_id || ' and p_item_ver_nr = ' || cur.p_item_ver_nr || ' and disp_ord = ' || cur.disp_ord ;
                    nci_11179.ReturnRow(v_sql, 'NCI_ADMIN_ITEM_REL_ALT_KEY', row);
                    ihook.setColumnValue(row, 'DISP_ORD', i);
                    rows.extend;                    rows(rows.last) := row;
                end if;
                i := i+1;
    end loop;

    action := t_actionRowset(rows, 'Questions (Base Object)', 2, 1000, 'update');
    actions.extend; actions(actions.last) := action;
    hookoutput.actions:= actions;
  end if;  
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spDeleteMod  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;

  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  i integer;
  v_sql varchar2(4000);
v_msg_str varchar2(255) := '';
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to delete modules on this form.');
 end if;
 
 if (hookinput.invocationNUmber = 0) then
 for i in 1..hookinput.originalrowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);
   v_msg_str := substr(v_msg_str || ',' || ihook.getColumnValue(row_ori, 'P_ITEM_ID') || 'v' || ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR'),1,255);
   end loop;
 hookoutput.question := getProceedQuestion ('Permanently Delete Module(s): ' || substr(v_msg_str,2));
 else
for i in 1..hookinput.originalrowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);
 for cur1 in (select * from admin_item where item_id  = ihook.getCOlumnValue(row_ori,'C_ITEM_ID') and 
 ver_nr =  ihook.getColumnValue(row_ori,'C_ITEM_VER_NR')) loop
 DeleteModule(cur1.item_id, cur1.ver_nr, cur1.nci_idseq,v_user_id);
 end loop;
end loop;

 i := 0;
    for cur in (select * from NCI_ADMIN_ITEM_REL where nvl(fld_delete,0) = 0 and p_item_id =   ihook.getColumnValue(row_ori, 'P_ITEM_ID') and p_item_ver_nr =
             ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') and rel_typ_id = 61 order by disp_ord) loop
                if (i <> cur.disp_ord) then
                    row := t_row();
                    v_sql := 'select * from NCI_ADMIN_ITEM_REL where  p_item_id = ' ||  cur.p_item_id || ' and p_item_ver_nr = ' || cur.p_item_ver_nr || ' and disp_ord = ' || cur.disp_ord ;
                    nci_11179.ReturnRow(v_sql, 'NCI_ADMIN_ITEM_REL', row);
                    ihook.setColumnValue(row, 'DISP_ORD', i);
                    rows.extend;                    rows(rows.last) := row;
                end if;
                i := i+1;
    end loop;

    action := t_actionRowset(rows, 'Generic AI Relationship', 2, 1000, 'update');
    actions.extend; actions(actions.last) := action;
    hookoutput.actions:= actions;
  end if;  
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

procedure spDeleteForm  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;

  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_id number;
  v_ver_nr number(4,2);
    v_idseq  char(36);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);
 v_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
 v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
 
 if (nci_form_mgmt.isUserAuth(v_id, v_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to delete  this form.');
 end if;
 
 if (hookinput.invocationNUmber = 0) then
 hookoutput.question := getProceedQuestion ('Permanently Delete Form: ' || v_id || 'v' || v_ver_nr);
 else
 for cur1 in (select ai.* from admin_item ai, nci_admin_item_rel r where ai.item_id  = r.c_item_id
 and ai.ver_nr = r.c_item_ver_nr and r.p_item_id = v_id and r.p_item_ver_nr = v_ver_nr and
 r.rel_typ_id = 61) loop
 DeleteModule(cur1.item_id, cur1.ver_nr, cur1.nci_idseq,v_user_id);
 end loop;
 
 select nci_idseq into v_idseq from admin_item where item_id = v_id and ver_nr = v_ver_nr;
 
DeleteCommonChildren(v_id, v_ver_nr, v_idseq);
 commit;
 
 --raise_application_error(-20000, v_idseq);
delete from sbrext.protocol_qc_ext where qc_idseq = v_idseq; 
delete from sbr.administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where dn_crf_idseq =  v_idseq);
delete from sbr.administered_components where ac_idseq =  v_idseq;
delete from sbrext.qc_recs_ext where p_qc_idseq = v_idseq ;--and rl_name  = 'ELEMENT_INSTRUCTION';
delete from sbrext.qc_recs_ext where c_qc_idseq = v_idseq ;--and rl_name  = 'ELEMENT_INSTRUCTION';
delete from sbrext.quest_contents_ext where dn_crf_idseq =  v_idseq;
delete from sbrext.quest_contents_ext where qc_idseq =  v_idseq;

delete from nci_admin_item_rel where p_item_id = v_id and p_item_ver_nr = v_ver_nr;
delete from nci_form where item_id = v_id and ver_nr = v_ver_nr;

delete from admin_item where item_id = v_id and ver_nr = v_ver_nr;

commit;
end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure DeleteQuest (v_id in number, v_ver_nr in number, v_idseq in char, v_user_id in varchar2)
AS
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  i integer;
BEGIN

--raise_application_error(-20000,v_id || ' '|| v_ver_nr ||  ' ' || v_idseq);
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM,  CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT, 
LVL_1_ITEM_ID, LVL_1_VER_NR, LVL_1_ITEM_NM, LVL_1_DISP_ORD,
LVL_2_ITEM_ID, LVL_2_VER_NR, LVL_2_ITEM_NM, LVL_2_DISP_ORD)
select m.p_item_id,m.p_item_ver_nr, 'M', 'Form Question', v_id,'QUESTION',
   v_user_id, v_user_id, sysdate, sysdate,
 m.c_item_id, m.c_item_ver_nr, ai.item_nm,m.DISP_ORD,
 q.c_item_id, q.c_item_ver_nr, q.item_long_nm, q.DISP_ORD
from  NCI_ADMIN_ITEM_REL_ALT_KEY q, NCI_ADMIN_ITEM_REL m, admin_item ai where 
 q.NCI_PUB_ID=v_id and  q.NCI_VER_NR=v_ver_nr and q.P_ITEM_ID = m.c_item_id and q.p_item_ver_nr = m.c_item_ver_nr
 and m.c_item_id = ai.item_id and m.c_item_ver_nr = ai.ver_nr; 
commit;

-- delete from question vv-rep
delete from nci_quest_vv_rep where quest_pub_id = v_id and quest_ver_nr = v_ver_nr;
delete from onedata_ra.nci_quest_vv_rep where quest_pub_id = v_id and quest_ver_nr = v_ver_nr;

insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM,  CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT, 
LVL_1_ITEM_ID, LVL_1_VER_NR, LVL_1_ITEM_NM, LVL_1_DISP_ORD,
LVL_2_ITEM_ID, LVL_2_VER_NR, LVL_2_ITEM_NM, LVL_2_DISP_ORD,
LVL_3_ITEM_ID, LVL_3_VER_NR, LVL_3_ITEM_NM, LVL_3_DISP_ORD
)
select m.p_item_id,m.p_item_ver_nr, 'M', 'Form Question Valid Values', vv.nci_pub_id,'VALID VALUE',
v_user_id, v_user_id, sysdate, sysdate,
 m.c_item_id, m.c_item_ver_nr, ai.item_nm,m.DISP_ORD,
 q.c_item_id, q.c_item_ver_nr, q.item_long_nm,q.DISP_ORD,
 vv.nci_pub_id, vv.nci_ver_nr, vv.value, vv.DISP_ORD
from NCI_QUEST_VALID_VALUE vv, NCI_ADMIN_ITEM_REL_ALT_KEY q, NCI_ADMIN_ITEM_REL m , admin_item ai where 
  vv.q_PUB_ID =v_id and vv.q_VER_NR =v_ver_nr and q.P_ITEM_ID = m.c_item_id and q.p_item_ver_nr = m.c_item_ver_nr
 and vv.Q_PUB_ID = q.NCI_PUB_ID and vv.q_VER_NR = q.NCI_VER_NR and m.c_item_id = ai.item_id and m.c_item_ver_nr = ai.ver_nr
 ; 
commit;

--delete vv
delete from nci_quest_valid_value where q_pub_id = v_id and q_ver_nr = v_ver_nr;
delete from onedata_ra.nci_quest_valid_value where q_pub_id = v_id and q_ver_nr = v_ver_nr;

delete from nci_admin_item_rel_alt_key where nci_pub_id = v_id and nci_ver_nr = v_ver_nr;
delete from onedata_ra.nci_admin_item_rel_alt_key where nci_pub_id = v_id and nci_ver_nr = v_ver_nr;

-- SBR repetitions

delete from sbrext.quest_vv_ext  where quest_idseq =v_idseq;

delete from sbrext.valid_values_att_ext where qc_idseq in (select qc_idseq from  sbrext.quest_contents_ext where p_qst_idseq = v_idseq and 
qtl_name = 'VALID_VALUE');

delete from sbrext.qc_recs_ext where p_qc_idseq in (select qc_idseq from  sbrext.quest_contents_ext where p_qst_idseq = v_idseq and 
qtl_name = 'VALID_VALUE');


delete from QUEST_ATTRIBUTES_EXT where quest_idseq = v_idseq;

delete from sbr.administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_qst_idseq =  v_idseq);
delete from sbr.administered_components where ac_idseq  =  v_idseq;
delete from sbrext.qc_recs_ext where p_qc_idseq = v_idseq ;--and rl_name  = 'ELEMENT_INSTRUCTION';
delete from sbrext.qc_recs_ext where c_qc_idseq = v_idseq ;--and rl_name  = 'ELEMENT_INSTRUCTION';
delete from sbrext.quest_contents_ext where p_qst_idseq =  v_idseq;
delete from sbrext.quest_contents_ext where qc_idseq =  v_idseq;
commit;
-- delete vv

end;



procedure DeleteVV ( v_idseq in char, v_user_id in varchar2)
AS
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  i integer;
BEGIN

--raise_application_error(-20000,v_id || ' '|| v_ver_nr ||  ' ' || v_idseq);

/***************Queries #2,3 and 4 were slit in order to improve the SP performance ***************/


--1.select *from sbrext.valid_values_att_ext where qc_idseq = v_idseq ;
----delete VV and INST relation records and VV/QUESTION relation records
--2.delete from sbrext.qc_recs_ext where p_qc_idseq = v_idseq or c_qc_idseq = v_idseq;
----delete VV and theyer INST  records
--3.delete from sbr.administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_val_idseq =  v_idseq)
--or ac_idseq = v_idseq;
----delete VV and theyer INST  records
--4.delete from sbrext.quest_contents_ext where qc_idseq = v_idseq or p_val_idseq =  v_idseq;

--raise_application_Error(-20000,v_idseq);

insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM,  CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT, 
LVL_1_ITEM_ID, LVL_1_VER_NR, LVL_1_ITEM_NM, LVL_1_DISP_ORD,
LVL_2_ITEM_ID, LVL_2_VER_NR, LVL_2_ITEM_NM, LVL_2_DISP_ORD,
LVL_3_ITEM_ID, LVL_3_VER_NR, LVL_3_ITEM_NM, LVL_3_DISP_ORD
)
select m.p_item_id,m.p_item_ver_nr, 'M', 'Form Question Valid Values', vv.nci_pub_id,'VALID VALUE',
v_user_id, v_user_id, sysdate, sysdate,
 m.c_item_id, m.c_item_ver_nr, ai.item_nm,m.DISP_ORD,
 q.c_item_id, q.c_item_ver_nr, q.item_long_nm,q.DISP_ORD,
 vv.nci_pub_id, vv.nci_ver_nr, vv.value, vv.DISP_ORD
from NCI_QUEST_VALID_VALUE vv, NCI_ADMIN_ITEM_REL_ALT_KEY q, NCI_ADMIN_ITEM_REL m , admin_item ai where 
  vv.nci_idseq = v_idseq and q.P_ITEM_ID = m.c_item_id and q.p_item_ver_nr = m.c_item_ver_nr
 and vv.Q_PUB_ID = q.NCI_PUB_ID and vv.q_VER_NR = q.NCI_VER_NR and m.c_item_id = ai.item_id and m.c_item_ver_nr = ai.ver_nr
 ; 
commit;

delete from sbrext.valid_values_att_ext where qc_idseq = v_idseq ;
--delete VV and INST relation records 
delete from sbrext.qc_recs_ext where p_qc_idseq = v_idseq ;
--delete VV/QUESTION relation records
delete from sbrext.qc_recs_ext where c_qc_idseq = v_idseq;
--delete INST of VV relation records 
delete from sbr.administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_val_idseq =  v_idseq);
--delete VV and INST relation records 
delete from sbr.administered_components where ac_idseq = v_idseq;
--delete INST of VV records 
delete from sbrext.quest_contents_ext where p_val_idseq =  v_idseq;
--delete VV  records 
delete from sbrext.quest_contents_ext where qc_idseq = v_idseq ;

commit;


end;


procedure DeleteCommonChildren (v_id in number, v_ver_nr in number, v_idseq in char)
AS
  i integer;
BEGIN

delete from sbrext.AC_ATT_CSCSI_EXT e where 
att_idseq  in 
(select  nci_idseq from alt_nms where item_id = v_id and ver_nr = v_ver_nr)
and atl_name = 'DESIGNATION';

delete from sbrext.AC_ATT_CSCSI_EXT e where 
att_idseq  in 
(select  nci_idseq from alt_def where item_id = v_id and ver_nr = v_ver_nr)
and atl_name = 'DEFINITION';

delete from NCI_CSI_ALT_DEFNMS where NMDEF_ID in (select nm_id from alt_nms where item_id = v_id and ver_nr = v_ver_nr)
and TYP_NM = 'DESIGNATION';

delete from NCI_CSI_ALT_DEFNMS where NMDEF_ID in (select def_id from alt_def where item_id = v_id and ver_nr = v_ver_nr)
and TYP_NM = 'DEFINITION';


delete from alt_nms where item_id = v_id and ver_nr = v_ver_nr;
delete from onedata_ra.alt_nms where item_id = v_id and ver_nr = v_ver_nr;

delete from sbr.designations where ac_idseq =  v_idseq;
delete from alt_def where item_id = v_id and ver_nr = v_ver_nr;
delete from onedata_ra.alt_def where item_id = v_id and ver_nr = v_ver_nr;

delete from sbr.definitions where ac_idseq =  v_idseq;
-- Classifications
--delete from sbrext.AC_ATT_CSCSI_EXT e where 
--( cs_csi_idseq, att_idseq ) in 
--(select  cur.cs_csi_idseq, cur.att_idseq from dual where cur.fld_delete = 1);

delete from sbr.ac_csi where  ac_idseq = v_idseq;

-- Reference documents

delete from sbr.reference_blobs where rd_idseq in (select rd_idseq from sbr.reference_documents d  where d.ac_idseq = v_idseq);
delete from sbr.reference_documents d  where d.ac_idseq = v_idseq;
delete from ref_doc where nci_ref_id in (Select ref_id from ref where item_id = v_id and ver_nr = v_ver_nr);
delete from ref where item_id = v_id and ver_nr = v_ver_nr;
delete from nci_admin_item_rel where rel_typ_id = 65 and c_item_id = v_id and c_item_ver_nr = v_ver_nr; 

end;

procedure DeleteModule (v_id in number, v_ver_nr in number, v_idseq in char, v_user_id in varchar2)
AS
  i integer;
BEGIN

insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM,  CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT,
LVL_1_ITEM_ID,LVL_1_VER_NR,LVL_1_ITEM_NM, LVL_1_DISP_ORD)
select an.p_item_id,an.p_item_ver_nr, 'M', 'Form-Module', an.c_item_id, 
'MODULE',
--decode(TRNS_TYP, 'U', UPD_COL_NM, 'REF_NM'), 
--decode(TRNS_TYP, 'U', UPD_COL_NEW_VAL,REF_NM), 
v_user_id,v_user_id, sysdate , sysdate,
ai.item_id, ai.ver_nr,  ai.item_nm, an.DISP_ORD
from NCI_ADMIN_ITEM_REL an, ADMIN_ITEM ai where 
an.REL_TYP_ID = 61 and an.c_item_id = v_id and an.c_item_ver_nr = v_ver_Nr  and ai.item_id=v_id and  ai.ver_nr=v_ver_nr;
commit;

-- delete questions
for cur in (select * from nci_admin_item_rel_alt_key where p_item_id  = v_id and p_item_ver_nr = v_ver_nr) loop
DeleteQuest(cur.nci_pub_id, cur.nci_ver_nr, cur.nci_idseq,v_user_id);
end loop;


delete from sbr.administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_mod_idseq =  v_idseq);
delete from sbr.administered_components where ac_idseq =  v_idseq;
delete from sbrext.qc_recs_ext where p_qc_idseq = v_idseq ;--and rl_name  = 'ELEMENT_INSTRUCTION';
delete from sbrext.qc_recs_ext where c_qc_idseq = v_idseq ;--and rl_name  = 'ELEMENT_INSTRUCTION';
delete from sbrext.quest_contents_ext where p_mod_idseq =  v_idseq;
delete from sbrext.quest_contents_ext where qc_idseq =  v_idseq;
delete from nci_admin_item_rel where c_item_id = v_id and c_item_ver_nr = v_ver_nr;
DeleteCommonChildren(v_id, v_ver_nr, v_idseq);
delete from nci_module where item_id = v_id and ver_nr = v_ver_nr;

delete from admin_item where item_id = v_id and ver_nr = v_ver_nr;

commit;

end;

PROCEDURE spCopyModuleUsingID
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2) ---D Default cart ; N - Named cart
AS
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
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
forms     t_forms;
formGroup    t_form;
form1   t_form;
v_itemid     integer;
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
  v_item_typ  integer;
  v_mod_specified boolean;
  v_cart_nm varchar2(255);
  v_item_id number;
  v_disp_ord integer;
  rowscart t_rows := t_rows();
  cnt integer;
  v_added integer := 0;
  v_str varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);

    rows := t_rows();
if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a module to this form.');
 end if;


 if (hookInput.invocationNumber = 0) then
          forms                  := t_forms();
        form1                  := t_form('Add Item to Collection (Hook)', 2,1);
        forms.extend;    forms(forms.last) := form1;
        hookoutput.forms := forms;
        	 hookOutput.question := nci_dload.getCreateQuestionUsingID;
       --	 hookOutput.question := nci_dload.getAddComponentCreateQuestion;
  
  end if; 
   -- if (hookInput.invocationNumber = 2 or v_mod_specified = true) then -- copy module
 if (hookInput.invocationNumber = 1) then

 forms              := hookInput.forms;
        form1              := forms(1);
        row_sel := form1.rowset.rowset(1);
        v_str := trim(ihook.getColumnValue(row_sel, 'VM_DESC_TXT'));
             cnt := nci_11179.getwordcount(v_str);
                  select nvl(max(disp_ord)+ 1,0) into v_disp_ord from nci_admin_item_rel where
     p_item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and p_item_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR');

              for i in  1..cnt loop
                        v_item_id := nci_11179.getWord(v_str, i, cnt);
        for cur in (select * from admin_item where item_id = v_item_id and currnt_ver_ind = 1 and admin_item_typ_id =52 ) loop

    v_added := v_added + 1;
--spCopyModuleNCI - 
--procedure spCopyModuleNCI (actions in out t_actions, v_from_module_id in number,v_from_module_ver in number,
--v_from_form_id in number, v_from_form_ver number, v_to_form_id number, v_to_form_ver number, v_disp_ord number, v_src in varchar2, v_cntxt_item_id in number, v_cntxt_ver_nr in number, v_user_id in varchar2) as

for cur1 in (select p_item_id, p_item_ver_nr from nci_admin_item_rel where c_item_id = cur.item_id and c_item_ver_nr = cur.ver_nr and rel_typ_id = 61) loop
    nci_11179.spCopyModuleNCI (actions, cur.item_id,cur.ver_nr,
    cur1.p_item_id, cur1.p_item_ver_nr,
    ihook.getColumnValue(row_ori,'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_disp_ord,'C',
    ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID'),ihook.getColumnValue(row_ori, 'CNTXT_VER_NR'), v_user_id);
                               nci_11179_2.AddItemToCart(cur.item_id, cur.ver_nr, v_user_id, v_deflt_cart_nm, rowscart);

    v_disp_ord := v_disp_ord + 1;
    end loop;
    end loop;
    end loop;

     if (rowscart.count  > 0) then
                action := t_actionrowset(rowscart, 'User Cart', 2,0,'insert');
                actions.extend;
                actions(actions.last) := action;
            end if;
            if actions.count > 0 then
          hookoutput.actions := actions;
        hookoutput.message := v_added || ' module(s) copied successfully.';
 else
    hookoutput.message := 'Please specify valid Module ID(s).';
    end if;
    --hookoutput.message := v_add || ' concepts added.';
    end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--  nci_util.debugHook('GENERAL',v_data_out);

END;

end;
/
