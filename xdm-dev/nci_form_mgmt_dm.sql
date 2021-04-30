create or replace PACKAGE            nci_form_mgmt AS
procedure spAddForm (v_data_in in clob, v_data_out out clob);
procedure spAddModule (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spEditModule (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spAddQuestion (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spCopyModule (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
function isUserAuth(v_frm_item_id in number, v_frm_ver_nr in number,v_user_id in varchar2) return boolean  ;
procedure spSetModRep (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spChngQuestText (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spChngQuestShortText (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spSetDefltVal (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spAddQuestionNoDE (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spChngQuestTextVV (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spChngQuestDefVV (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spAddQuestionRep (rep in integer, row_ori in t_row, rows in out t_rows);
procedure spAddQuestionRepNew (rep in integer, v_quest_id in integer, rows in out t_rows);
PROCEDURE spQuestRemoveDE ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDelModRep  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDeleteQuestVV  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spAddQuestVV  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);

END;
/
create or replace PACKAGE BODY            nci_form_mgmt AS
c_ver_suffix varchar2(5) := 'v1.00';

function isUserAuth(v_frm_item_id in number, v_frm_ver_nr in number,v_user_id in varchar2) return boolean  iS
v_auth boolean := false;
v_temp integer;
begin
select count(*) into v_temp from  onedata_md.vw_usr_row_filter  v, admin_item ai
        where ( ( v.CNTXT_ITEM_ID = ai.CNTXT_ITEM_ID and v.cntxt_VER_NR  = ai.CNTXT_VER_NR) or v.CNTXT_ITEM_ID = 100) and upper(v.USR_ID) = upper(v_user_id) and v.ACTION_TYP = 'I'
        and ai.item_id =v_frm_item_id and ai.ver_nr = v_frm_ver_nr;
if (v_temp = 0) then return false; else return true; end if;
end;



PROCEDURE spAddQuestVV
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_usr_id in varchar2)
    AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_add integer;
  i integer := 0;
  j integer;
  v_temp integer;
  rep integer;
  v_item_id number;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 
 
 select p_item_id, p_item_ver_nr into v_frm_id, v_frm_ver_nr from nci_admin_item_rel where
  c_item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and c_item_ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to add any valid value on this form.');
 end if;
 
 if (ihook.getColumnValue(row_ori, 'C_ITEM_ID') is null) then
 raise_application_error(-20000,'No CDE attached to this question.');
 end if;
 
 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Question Valid Values', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
    
    rows := t_rows();
    for cur in (select upper(PERM_VAL_NM) PERM_VAL_NM from vw_nci_de_pv where de_item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID') and de_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') minus
                select upper(VALUE) from nci_quest_valid_value where Q_PUB_ID = ihook.getColumnValue(row_ori, 'NCI_PUB_ID') and Q_VER_NR =ihook.getColumnValue(row_ori, 'NCI_VER_NR')) loop
                for cur1 in (select * from vw_nci_de_pv where upper(PERM_VAL_NM) = cur.PERM_VAL_NM and de_item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID') and de_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR')) loop
                     row := t_row();
                    iHook.setcolumnvalue (row, 'DE_ITEM_ID', cur1.DE_ITEM_ID);
                    iHook.setcolumnvalue (row, 'DE_VER_NR', cur1.DE_VER_NR);
                    iHook.setcolumnvalue (row, 'PERM_VAL_NM', cur1.PERM_VAL_NM);
                    rows.extend;
                    rows (rows.last) := row;
            
                end loop;
    end loop;
    
	   	 
	--    end loop;

	   	 showrowset := t_showablerowset (rows, 'NCI DE Permissible Values', 2, 'multi');
       	 hookoutput.showrowset := showrowset;


  ELSE -- hook invocation = 1
       rows := t_rows();

    select max(nvl(disp_ord,0))+1 into j from nci_quest_valid_value where q_pub_id =    ihook.getColumnValue(row_ori, 'NCI_PUB_ID') 
    and q_ver_nr = ihook.getColumnValue(row_ori, 'NCI_VER_NR'); 
    raise_application_error(-20000, j);
  for i in 1..hookinput.selectedRowset.rowset.count loop
        
        row_sel := hookinput.selectedRowset.rowset(i);
        row := t_row();
            ihook.setColumnValue (row, 'Q_PUB_ID',ihook.getColumnValue(row_ori, 'NCI_PUB_ID') );
                ihook.setColumnValue (row, 'Q_VER_NR', ihook.getColumnValue(row_ori, 'NCI_VER_NR'));
                ihook.setColumnValue (row, 'VM_NM', ihook.getColumnValue(row_sel, 'ITEM_NM'));
                ihook.setColumnValue (row, 'VM_LNM', ihook.getColumnValue(row_sel, 'ITEM_LONG_NM'));
                ihook.setColumnValue (row, 'VM_DEF', ihook.getColumnValue(row_sel, 'ITEM_DESC'));
                ihook.setColumnValue (row, 'VALUE', ihook.getColumnValue(row_sel, 'PERM_VAL_NM'));
                ihook.setColumnValue (row, 'MEAN_TXT', ihook.getColumnValue(row_sel, 'ITEM_NM'));
                ihook.setColumnValue (row, 'DESC_TXT', ihook.getColumnValue(row_sel, 'ITEM_DESC'));
                ihook.setColumnValue (row, 'VAL_MEAN_ITEM_ID', ihook.getColumnValue(row_sel, 'NCI_VAL_MEAN_ITEM_ID'));
                ihook.setColumnValue (row, 'VAL_MEAN_VER_NR', ihook.getColumnValue(row_sel, 'NCI_VAL_MEAN_VER_NR'));
                v_item_id := nci_11179.getItemId;
                ihook.setColumnValue (row, 'NCI_PUB_ID', v_item_id);
                ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                ihook.setColumnValue (row, 'DISP_ORD', j);
            j := j + 1;
                    rows.extend;
                    rows (rows.last) := row;
            
   end loop;
   
 
        if (rows.count > 0) then
        action             := t_actionrowset(rows, 'Question Valid Values', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;
           hookoutput.actions    := actions;
 end if;
            
     END IF;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--  nci_util.debugHook('GENERAL',v_data_out);

END;

procedure spDeleteQuestVV  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
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
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(255);
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);

 select frm_item_id, frm_ver_nr into v_frm_id, v_frm_ver_nr from vw_nci_module_de where
nci_pub_id = ihook.getColumnValue(row_ori, 'Q_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any valid value on this form.');
 end if;
for i in 1..hookinput.originalrowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);



            rows.extend;
            rows(rows.last) := row_ori;
    end loop;
            action             := t_actionrowset(rows, 'Question Valid Values (Hook)', 2, 0,'delete');
            actions.extend;
            actions(actions.last) := action;

  action             := t_actionrowset(rows, 'Question Valid Values (Hook)', 2, 1,'purge');
            actions.extend;
            actions(actions.last) := action;

            hookoutput.actions    := actions;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spAddForm  ( v_data_in IN CLOB,    v_data_out OUT CLOB)
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
    v_form_id integer;
    i integer := 0;
BEGIN
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    -- First invocation - show the Add Form
    if hookInput.invocationNumber = 0 then
        ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(1, 1, 'Create Form.');
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION('Add new form/template.', ANSWERS);
        HOOKOUTPUT.QUESTION    := QUESTION;

        forms                  := t_forms();
        form1                  := t_form('Forms (Hook)', 2,1);  -- Forms (Hook) is a custom object for this purpose.
        action_row := t_row();

        -- Set the default workflow status and Form Type; attach to Add Form.

        ihook.setColumnValue(action_row, 'ADMIN_STUS_ID', 66);
        ihook.setColumnValue(action_row, 'FORM_TYP_ID', 70);
        action_rows.extend; action_rows(action_rows.last) := action_row;
        rowset := t_rowset(action_rows, 'Form (Hook)', 1,'NCI_FORM');

        form1.rowset :=rowset;
        forms.extend;
        forms(forms.last) := form1;
        hookOutput.forms := forms;
  ELSE -- Second invocation
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);

        v_form_id :=  nci_11179.getItemId;
        row := t_row();
        row := rowform;

        ihook.setColumnValue(row, 'ITEM_ID', v_form_id);
        ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row, 'VER_NR', 1);
        ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 54);
        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_form_id || c_ver_suffix);

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

        -- Insert form-protocol relationship if protocol specified
        if (ihook.getColumnValue(rowform,'P_ITEM_ID') > 0) then
            rows:= t_rows();
            rowrel := t_row();
            ihook.setColumnValue(rowrel, 'P_ITEM_ID', ihook.getColumnValue(rowform,'P_ITEM_ID'));
            ihook.setColumnValue(rowrel, 'P_ITEM_VER_NR', ihook.getColumnValue(rowform,'P_ITEM_VER_NR'));
            ihook.setColumnValue(rowrel, 'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
            ihook.setColumnValue(rowrel, 'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
            ihook.setColumnValue(rowrel, 'C_ITEM_ID', v_form_id);
            ihook.setColumnValue(rowrel, 'C_ITEM_VER_NR', 1);
            ihook.setColumnValue(rowrel, 'REL_TYP_ID', 60);

            rows.extend;
            rows(rows.last) := rowrel;
            action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 2,'insert');
            actions.extend;
            actions(actions.last) := action;
        end if;
        hookoutput.actions    := actions;
        hookoutput.message := 'Form created successfully. Public Id:' || v_form_id;
    END IF;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spAddModule  (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
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
 raise_application_error(-20000,'You are not authorized to add a module to this form.');
 end if;

 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Create Module.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add new module.', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

    rows := t_rows();
    row := t_row();
        ihook.setColumnValue(row, 'P_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row, 'P_ITEM_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
        ihook.setColumnValue(row, 'ITEM_LONG_NM', ihook.getColumnValue(row_ori, 'ITEM_NM'));
        rows.extend; rows(rows.last) := row;
        rowset := t_rowset(rows, 'Module (Hook)', 1,'NCI_ADMIN_ITEM_REL');

    forms                  := t_forms();
    form1                  := t_form('Modules (Hook)', 2,1);
    form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
 ELSE
    IF HOOKINPUT.ANSWERID = 1 THEN
        forms              := hookInput.forms;
        form1              := forms(1);

        rowform := form1.rowset.rowset(1);

        v_module_id :=  nci_11179.getItemId;
        row := t_row();


   -- raise_application_error(-20000, ihook.getColumnValue(rowform,'INSTR'));

        for cur in (select cntxt_item_id, cntxt_ver_nr, admin_stus_id from admin_item where item_id =ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr =  ihook.getColumnValue(row_ori,'VER_NR')) loop
            ihook.setColumnValue(row, 'ITEM_ID', v_module_id);
            ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
            ihook.setColumnValue(row, 'VER_NR',ihook.getColumnValue(row_ori,'VER_NR') );
            ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 52);
            ihook.setColumnValue(row, 'CNTXT_ITEM_ID', cur.CNTXT_ITEM_ID);
            ihook.setColumnValue(row, 'CNTXT_VER_NR', cur.CNTXT_VER_NR);
            ihook.setColumnValue(row, 'ITEM_LONG_NM', v_module_id ||  c_ver_suffix);
            ihook.setColumnValue(row, 'ITEM_NM', ihook.getColumnValue(rowform,'ITEM_NM'));
            ihook.setColumnValue(row, 'ITEM_DESC', ihook.getColumnValue(rowform,'ITEM_DESC'));
            ihook.setColumnValue(row, 'ADMIN_STUS_ID', cur.ADMIN_STUS_ID);

            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;

            rows:= t_rows();
          select nvl(max(disp_ord)+ 1,0) into v_disp_ord from nci_admin_item_rel where p_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and p_item_ver_nr = ihook.getColumnValue(row_ori,'VER_NR');
      --   raise_application_error(-20000, v_disp_ord);

            rowrel := t_row();
            ihook.setColumnValue(rowrel, 'P_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
            ihook.setColumnValue(rowrel, 'P_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
            ihook.setColumnValue(rowrel, 'C_ITEM_ID', v_module_id);
            ihook.setColumnValue(rowrel, 'C_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
            ihook.setColumnValue(rowrel, 'CNTXT_ITEM_ID', cur.CNTXT_ITEM_ID);
            ihook.setColumnValue(rowrel, 'CNTXT_VER_NR', cur.CNTXT_VER_NR);
            ihook.setColumnValue(rowrel, 'DISP_ORD', v_disp_ord);
            ihook.setColumnValue(rowrel, 'REL_TYP_ID', 61);
            ihook.setColumnValue(rowrel, 'REP_NO', ihook.getColumnValue(rowform,'REP_NO'));
            ihook.setColumnValue(rowrel, 'INSTR', ihook.getColumnValue(rowform,'INSTR'));

            rows.extend;
            rows(rows.last) := rowrel;
     -- raise_application_error(-20000,  ihook.getColumnValue(row_ori,'ITEM_ID'));
            action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 2,'insert');
            actions.extend;
            actions(actions.last) := action;
    end loop;
    hookoutput.actions    := actions;
    END IF;
  END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spEditModule  (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
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
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit module to this form.');
 end if;

 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Edit Name.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Save.', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
    rows := t_rows();
    row := t_row();
    for cur in (select item_nm, item_desc from admin_item where item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR')) loop
        ihook.setColumnValue(row, 'ITEM_NM', cur.item_nm);
        ihook.setColumnValue(row, 'ITEM_DESC', cur.item_desc);
    end loop;
       rows.extend; rows(rows.last) := row;
        rowset := t_rowset(rows, 'Edit Module (Hook)', 1,'ADMIN_ITEM');

    forms                  := t_forms();
    form1                  := t_form('Edit Module (Hook)', 2,1);
    form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
 ELSE
    IF HOOKINPUT.ANSWERID = 1 THEN
        forms              := hookInput.forms;
        form1              := forms(1);

        rowform := form1.rowset.rowset(1);

       row := t_row();


            ihook.setColumnValue(row, 'ITEM_ID', ihook.getColumnValue(row_ori,'C_ITEM_ID'));
            ihook.setColumnValue(row, 'VER_NR', ihook.getColumnValue(row_ori,'C_ITEM_VER_NR'));
            ihook.setColumnValue(row, 'ITEM_NM', ihook.getColumnValue(rowform,'ITEM_NM'));
            ihook.setColumnValue(row, 'ITEM_DESC', ihook.getColumnValue(rowform,'ITEM_DESC'));

            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
      hookoutput.actions    := actions;
    END IF;
  END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spAddQuestionRep (rep in integer, row_ori in t_row, rows in out t_rows)
AS
  i integer;
  v_temp integer;
  row t_row;
  v_ori_rep integer;

begin
        v_ori_rep := nvl(ihook.getColumnValue(row_ori, 'REP_NO'),0);
        for i in v_ori_rep+1..rep loop
        for cur in (select nci_pub_id, nci_ver_nr, edit_ind, req_ind from nci_admin_item_rel_alt_key where p_item_id =ihook.getColumnValue(row_ori,'C_ITEM_ID') and
        P_item_ver_nr =  ihook.getColumnValue(row_ori,'C_ITEM_VER_NR')) loop

        select count(*) into v_temp from nci_quest_vv_rep where quest_pub_id =cur.nci_pub_id and quest_ver_nr = cur.nci_ver_nr and rep_seq = i ;

            if v_temp = 0 then
            row := t_row();
            ihook.setColumnValue(row, 'QUEST_PUB_ID', cur.nci_pub_id);
            ihook.setColumnValue(row, 'QUEST_VER_NR', cur.nci_ver_nr);
            ihook.setColumnValue(row, 'REP_SEQ', i);
            ihook.setColumnValue(row, 'EDIT_IND', cur.edit_ind);
            ihook.setColumnValue(row, 'QUEST_VV_REP_ID',-1);
        --    raise_application_error(-20000,i);
            rows.extend;
            rows(rows.last) := row;
          end if;
       end loop;
       end loop;
end;


procedure spAddQuestionRepNew (rep in integer, v_quest_id in integer, rows in out t_rows)
AS
  i integer;
  v_temp integer;
  row t_row;

begin
        for i in 1..rep loop
            row := t_row();
            ihook.setColumnValue(row, 'QUEST_PUB_ID',v_quest_id );
            ihook.setColumnValue(row, 'QUEST_VER_NR', 1);
            ihook.setColumnValue(row, 'REP_SEQ', i);
         --   ihook.setColumnValue(row, 'EDIT_IND',1);
            ihook.setColumnValue(row, 'QUEST_VV_REP_ID',-1);
        --    raise_application_error(-20000,i);
            rows.extend;
            rows(rows.last) := row;

       end loop;
end;

PROCEDURE spSetModRep
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
    AS
forms t_forms;
  form1 t_form;
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
showrowset	t_showablerowset;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  v_temp integer;
  v_ori_rep integer;
  rep integer;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit module to this form.');
 end if;

v_ori_rep := nvl(ihook.getColumnValue(row_ori, 'REP_NO'),0);

 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Set Module Repetition. Current Repetitions: ' || v_ori_rep, ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
	  /*  for i in 1..20 loop

		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'Repetition', i);
		   rows.extend;
		   rows (rows.last) := row;

	    end loop;

	   	 showrowset := t_showablerowset (rows, 'Repetition', 4, 'single');
       	 hookoutput.showrowset := showrowset;
*/

    forms                  := t_forms();
    form1                  := t_form('Question Repetition Set (Hook)', 2,1);
    forms.extend;    forms(forms.last) := form1;
    hookoutput.forms :=     forms;
    
  ELSE -- hook invocation = 1
     forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);
        
        rows := t_rows();
        rep := nvl(ihook.getColumnValue(rowform, 'VER_NR'),0);
        if (rep < v_ori_rep) then
            hookoutput.message := 'Specify a number larger than the current number of repetition  - ' || v_ori_rep;
            V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
            return;
      end if;    
    --    raise_application_error(-20000,rep);
        spAddQuestionRep (rep, row_ori, rows);
        if (rows.count > 0) then
        action             := t_actionrowset(rows, 'Question Repetition', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;
         end if;
            rows := t_rows();
            row := t_row();
             ihook.setColumnValue(row_ori, 'REP_NO', rep);

     rows.extend;
            rows(rows.last) := row_ori;
            action             := t_actionrowset(rows, 'Form-Module Relationship', 2, 1,'update');
            actions.extend;
            actions(actions.last) := action;

    hookoutput.actions    := actions;
    END IF;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--  nci_util.debugHook('GENERAL',v_data_out);
--  insert into junk_debug values (sysdate, v_data_out);
 -- commit;

END;


PROCEDURE spDelModRep
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_usr_id in varchar2)
    AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  v_temp integer;
  v_rep integer;
  v_rep_sel integer;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit module to this form.');
 end if;

  v_rep :=  nvl(ihook.getColumnValue(row_ori, 'REP_NO'),0);
 if (v_rep = 0) then
 raise_application_error(-20000,'This module does not have any repetitions.');
 end if;
 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Delete Repetition.', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

	    for i in 1..v_rep loop

		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'Repetition', i);
		   rows.extend;
		   rows (rows.last) := row;

	    end loop;

	   	 showrowset := t_showablerowset (rows, 'Repetition', 4, 'single');
       	 hookoutput.showrowset := showrowset;


  ELSE
        row_sel := hookinput.selectedRowset.rowset(1);
        rows := t_rows();
        v_rep_sel := ihook.getColumnValue(row_sel, 'Repetition');
        rows := t_rows();
        for cur in (select r.quest_vv_rep_id from nci_admin_item_rel_alt_key ak, nci_quest_vv_rep r
        where ak.p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
        ak.p_item_ver_nr = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and
        r.quest_pub_id = ak.nci_pub_id and r.quest_ver_nr = ak.nci_ver_nr and r.rep_seq = v_rep_sel) loop
        row := t_row();
        ihook.setColumnValue(row,'QUEST_VV_REP_ID', cur.QUEST_VV_REP_ID);
        rows.extend;            rows(rows.last) := row;
        end loop;

        if (rows.count > 0) then
        action             := t_actionrowset(rows, 'Question Repetition', 2, 0,'delete');
            actions.extend;
            actions(actions.last) := action;
        action             := t_actionrowset(rows, 'Question Repetition', 2, 1,'purge');
            actions.extend;
            actions(actions.last) := action;
         end if;
         rows := t_rows();
         for i in v_rep_sel+1..v_rep loop
            for cur in (select r.* from nci_admin_item_rel_alt_key ak, nci_quest_vv_rep r
            where ak.p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
            ak.p_item_ver_nr = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and
            r.quest_pub_id = ak.nci_pub_id and r.quest_ver_nr = ak.nci_ver_nr and r.rep_seq = i) loop
                row := t_row();
                ihook.setColumnValue(row,'QUEST_VV_REP_ID', cur.QUEST_VV_REP_ID);
                           ihook.setColumnValue(row, 'QUEST_PUB_ID', cur.quest_pub_id);
            ihook.setColumnValue(row, 'QUEST_VER_NR', cur.quest_ver_nr);
            ihook.setColumnValue(row, 'REP_SEQ', i-1);
            ihook.setColumnValue(row, 'EDIT_IND', cur.edit_ind);

                rows.extend;            rows(rows.last) := row;
            end loop;
        end loop;
        if (rows.count > 0) then
        action             := t_actionrowset(rows, 'Question Repetition', 2, 3,'update');
            actions.extend;
            actions(actions.last) := action;
         end if;
         rows := t_rows();

           ihook.setColumnValue(row_ori, 'REP_NO', v_rep-1);

     rows.extend;
            rows(rows.last) := row_ori;
            action             := t_actionrowset(rows, 'Form-Module Relationship', 2, 4,'update');
            actions.extend;
            actions(actions.last) := action;

    hookoutput.actions    := actions;
    END IF;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

END;


PROCEDURE spSetDefltVal
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
    AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowrel t_row;
  rows  t_rows;
  rows0 t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
 row_sel t_row;
 rep integer;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_mod_id number;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_mod_ver_nr number(4,2);
  v_disp_ord integer;
  v_add integer;
  v_rep integer;
  i integer := 0;
  v_temp number;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 -- Get form and module ID

 select r.P_ITEM_ID, r.P_ITEM_VER_NR into v_frm_id, v_frm_Ver_nr from NCI_ADMIN_ITEM_REL_ALT_KEY k, NCI_ADMIN_ITEM_REL r where k.nci_pub_id = ihook.getColumNValue(row_ori, 'Q_PUB_ID')
 and k.nci_ver_nr = ihook.getColumNValue(row_ori, 'Q_VER_NR') and k.P_ITEM_ID = r.C_ITEM_ID and k.P_ITEM_VER_NR = r.C_ITEM_VER_NR and r.rel_typ_id = 61;
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;

 if hookInput.invocationNumber = 0 then

   v_found := false;
   rows := t_rows();
   row := t_row();


   ihook.setColumnValue(row, 'Level', 'Question Default');
   ihook.setColumnValue(row, 'Sequence', 0);
   
            rows.extend;
            rows(rows.last) := row;
   for cur in (Select rep_seq  from nci_quest_vv_rep where QUEST_PUB_ID=ihook.getColumNValue(row_ori, 'Q_PUB_ID')  and quest_ver_nr = ihook.getColumNValue(row_ori, 'Q_VER_NR')) loop
   row := t_row();

    ihook.setColumnValue(row, 'Level', 'Repetition: '|| cur.rep_seq);
   ihook.setColumnValue(row, 'Sequence', cur.rep_seq);
   
            rows.extend;
            rows(rows.last) := row;
  -- raise_application_error (-20000, 'In here');

      v_found := true;
   end loop;

  -- if (v_found) then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Set default');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Set', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
          	 showrowset := t_showablerowset (rows, 'Repetition', 4, 'multi');
       	 hookoutput.showrowset := showrowset;

--else

/*rows := t_rows();
row := t_row();
           ihook.setColumnValue(row, 'NCI_PUB_ID', ihook.getColumnValue(row_ori,'Q_PUB_ID'));
           ihook.setColumnValue(row, 'NCI_VER_NR', ihook.getColumnValue(row_ori,'Q_VER_NR'));
           ihook.setColumnValue(row, 'DEFLT_VAL_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
    rows.extend;
            rows(rows.last) := row;

     -- raise_application_error(-20000,  ihook.getColumnValue(row_ori,'ITEM_ID'));
            action             := t_actionrowset(rows, 'Question (Edit)', 2, 2,'update');
            actions.extend;
            actions(actions.last) := action;
    hookoutput.actions    := actions;
  */
 --  hookoutput.message := 'No repetition for this module';
 --end if;
 ELSE


        rows := t_rows();

      for i in 1..hookinput.selectedRowset.rowset.count loop

       row_sel := hookinput.selectedRowset.rowset(i);

        rep := ihook.getColumnValue(row_sel, 'Sequence');

        if (rep = 0) then -- main question default


          row := t_row();
          rows0 := t_rows();
           ihook.setColumnValue(row, 'NCI_PUB_ID', ihook.getColumnValue(row_ori,'Q_PUB_ID'));
           ihook.setColumnValue(row, 'NCI_VER_NR', ihook.getColumnValue(row_ori,'Q_VER_NR'));
           ihook.setColumnValue(row, 'DEFLT_VAL_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
     ihook.setColumnValue(row, 'QUEST_REF_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));


    rows0.extend;
            rows0(rows0.last) := row;
     -- raise_application_error(-20000,  ihook.getColumnValue(row_ori,'ITEM_ID'));
            action             := t_actionrowset(rows0, 'Question (Base Object)', 2, 2,'update');
            actions.extend;
            actions(actions.last) := action;
        end if;
        if (rep>0) then
        select 	QUEST_VV_REP_ID into v_temp from nci_quest_vv_rep where quest_pub_id = ihook.getColumnValue(row_ori,'Q_PUB_ID')
        and quest_ver_nr = ihook.getColumnValue(row_ori,'Q_VER_NR') and rep_seq = rep;
          row := t_row();
            ihook.setColumnValue(row, 'QUEST_VV_REP_ID', v_temp);
            ihook.setColumnValue(row, 'DEFLT_VAL_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Question Repetition', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;

          end if;
  end loop;
    hookoutput.actions    := actions;

  END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 -- insert into junk_debug values (sysdate, v_data_out);
 -- commit;
END;


PROCEDURE spChngQuestText
  (

    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
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
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(255);
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

 select frm_item_id, frm_ver_nr into v_frm_id, v_frm_Ver_nr from VW_NCI_MODULE_DE where nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;

 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select Question Text');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Question Text', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

	    for cur in (select ref_id from ref r, obj_key ok where r.fld_delete= 0 and item_id = ihook.getColumNValue(row_ori, 'C_ITEM_ID')  and
        ver_nr = ihook.getColumNValue(row_ori, 'C_ITEM_VER_NR' ) and r.ref_typ_id = ok.obj_key_id and ok.obj_typ_id = 1 and upper(ok.obj_key_desc) like '%QUESTION TEXT%') loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'REF_ID', cur.ref_id);
		   rows.extend;
		   rows (rows.last) := row;

 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'References (for hook insert)', 2, 'single');
       	 hookoutput.showrowset := showrowset;
     end if;
 ELSE
            row_sel := hookinput.selectedRowset.rowset(1);

            select ref_desc into v_ref from ref where ref_id = ihook.getColumnValue(row_sel, 'REF_ID');

            ihook.setColumnValue(row_ori, 'ITEM_LONG_NM', v_ref);
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row_ori;

            action             := t_actionrowset(rows, 'Questions (Edit)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;


    hookoutput.actions    := actions;
    END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spChngQuestShortText
  (

    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
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
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(255);
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

 select frm_item_id, frm_ver_nr into v_frm_id, v_frm_Ver_nr from VW_NCI_MODULE_DE where nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;

 if ( ihook.getColumNValue(row_ori, 'C_ITEM_ID') is null) then
 raise_application_error(-20000,'No CDE attached to this question.');
 end if;
 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select Question Short Name');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
     QUESTION               := T_QUESTION('Question Short Name', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

	    for cur in (select nm_id from alt_nms a where a.fld_delete= 0 and item_id = ihook.getColumNValue(row_ori, 'C_ITEM_ID')  and
        ver_nr = ihook.getColumNValue(row_ori, 'C_ITEM_VER_NR' ) and nm_typ_id not in (select obj_key_id from obj_key where upper(obj_key_desc) = 'HISTORICAL_CDE_ID')
        order by cntxt_nm_dn, nm_typ_id) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'NM_ID', cur.nm_id);
		   rows.extend;
		   rows (rows.last) := row;

 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'Alternate Names', 2, 'single');
       	 hookoutput.showrowset := showrowset;
     end if;
 ELSE
            row_sel := hookinput.selectedRowset.rowset(1);

            select nm_desc into v_ref from alt_nms where nm_id = ihook.getColumnValue(row_sel, 'NM_ID');

            ihook.setColumnValue(row_ori, 'ITEM_NM', substr(v_ref,1,30));
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row_ori;

            action             := t_actionrowset(rows, 'Questions (Edit)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;


    hookoutput.actions    := actions;
    END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spAddQuestion
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
  rowsvv t_rows;
  rowsrep  t_rows;
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
v_itemid     integer;
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  v_add integer := 0;
  i integer := 0;
  j integer;
  v_disp_ord integer;
  column  t_column;
  msg varchar2(4000);
    type t_item_id is table of admin_item.item_id%type;
    type t_ver_nr is table of admin_item.ver_nr%type;

    v_tab_item_id  t_item_id := t_item_id();
    v_tab_ver_nr  t_ver_nr := t_ver_nr();
rep integer;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori :=  hookInput.originalRowset.rowset(1);

    rows := t_rows();


 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a question to this module.');
 end if;

    if hookInput.invocationNumber = 0 then

	    rows :=         t_rows();
		v_found := false;

	    for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id = 4 ) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   iHook.setcolumnvalue (ROW, 'CNTCT_SECU_ID', v_user_id);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'User Cart', 2, 'multi');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select CDE to add..');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
      else
        hookoutput.message := 'Please add Data Elements to your cart.';
	   end if;

	elsif hookInput.invocationNumber = 1 then

          select nvl(max(disp_ord)+1,0) into v_disp_ord from NCI_ADMIN_ITEM_REL_ALT_KEY where P_ITEM_ID =ihook.getColumnValue(row_ori,'C_ITEM_ID')  and
          P_ITEM_VER_NR = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and rel_typ_id = 63;
                        rep := ihook.getColumnValue(row_ori, 'REP_NO');

            for i in 1..hookInput.selectedRowset.rowset.count loop
                    row_sel := hookInput.selectedRowset.rowset(i);
                v_tab_item_id.extend();
                v_tab_ver_nr.extend();
                v_tab_item_id(v_tab_item_id.count) := ihook.getColumnValue(row_sel,'ITEM_ID');
                v_tab_ver_nr(v_tab_ver_nr.count) := ihook.getColumnValue(row_sel,'VER_NR');
                -- Add component Item id
                    for cur in (select c_item_id, c_item_ver_nr from nci_admin_item_rel where rel_typ_id = 65 and p_item_id = ihook.getColumnValue(row_sel,'ITEM_ID')
                    and p_item_ver_nr = ihook.getColumnValue(row_sel,'VER_NR') order by disp_ord) loop
                        v_tab_item_id.extend();
                        v_tab_ver_nr.extend();
                        v_tab_item_id(v_tab_item_id.count) := cur.c_item_id;
                        v_tab_ver_nr(v_tab_ver_nr.count) := cur.c_item_ver_nr;
                    end loop;
            end loop;
          rows := t_rows();
          rowsvv := t_rows();
                        rowsrep := t_rows();
        --      for i in 1..hookInput.selectedRowset.rowset.count loop
          --          row_sel := hookInput.selectedRowset.rowset(i);
    --      raise_application_error(-20000, 'herere ' || v_tab_item_id.count);
              for i in 1..v_tab_item_id.count loop

                    for cur in (select ai.item_id, ai.ver_nr, ai.cntxt_item_id, ai.cntxt_ver_nr, item_long_nm item_long_nm, nvl(r.ref_desc, item_long_nm) QUEST_TEXT
                    from admin_item ai, ref r where
                    ai.item_id = v_tab_item_id(i) and ai.ver_nr = v_tab_ver_nr(i) and ai.item_id = r.item_id (+) and ai.ver_nr = r.ver_nr (+)
                    and r.ref_typ_id (+) = 80) loop
              --      and (ai.item_id, ai.ver_nr) not in (select c_item_id, c_item_ver_nr from nci_admin_item_rel_alt_key where p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
               --             p_item_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') and rel_typ_id = 63 )) loop
                        row := t_row();
             --   raise_application_error(-20000, 'herere ' || cur.item_id);

                        v_id := nci_11179.getItemId;
                        ihook.setColumnValue (row, 'NCI_PUB_ID', v_id);
                        ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                        ihook.setColumnValue (row, 'P_ITEM_ID', ihook.getColumnValue(row_ori,'C_ITEM_ID'));
                        ihook.setColumnValue (row, 'P_ITEM_VER_NR', ihook.getColumnValue(row_ori,'C_ITEM_VER_NR'));
                        ihook.setColumnValue (row, 'C_ITEM_ID', cur.item_id);
                        ihook.setColumnValue (row, 'C_ITEM_VER_NR', cur.ver_nr);
                        ihook.setColumnValue (row, 'CNTXT_CS_ITEM_ID', cur.cntxt_item_id);
                        ihook.setColumnValue (row, 'CNTXT_CS_VER_NR', cur.cntxt_ver_nr);
                        ihook.setColumnValue (row, 'ITEM_LONG_NM', cur.QUEST_TEXT );

                        ihook.setColumnValue (row, 'REL_TYP_ID', 63);
                        ihook.setColumnValue (row, 'DISP_ORD', v_disp_ord);
                        v_disp_ord := v_disp_ord + 1;

                        v_add := v_add + 1;
                        rows.extend;
                        rows(rows.last) := row;


                        if nvl(rep,0) > 0 then
                            spAddQuestionRepNew (rep, v_id, rowsrep);
                        end if;
                        j := 0;
                for cur1 in (select * from  VW_NCI_DE_PV where de_item_id = cur.item_id and de_ver_nr = cur.ver_nr order by PERM_VAL_NM) loop
                  row := t_row();
                ihook.setColumnValue (row, 'Q_PUB_ID', v_id);
                ihook.setColumnValue (row, 'Q_VER_NR', 1);
                ihook.setColumnValue (row, 'VM_NM', cur1.item_nm);
                ihook.setColumnValue (row, 'VM_LNM', cur1.item_long_nm);
                ihook.setColumnValue (row, 'VM_DEF', cur1.item_desc);
                ihook.setColumnValue (row, 'VALUE', cur1.perm_val_nm);
                ihook.setColumnValue (row, 'MEAN_TXT', cur1.item_nm);
                ihook.setColumnValue (row, 'DESC_TXT', cur1.item_desc);
                ihook.setColumnValue (row, 'VAL_MEAN_ITEM_ID', cur1.NCI_VAL_MEAN_ITEM_ID);
                ihook.setColumnValue (row, 'VAL_MEAN_VER_NR', cur1.NCI_VAL_MEAN_VER_NR);
                v_itemid := nci_11179.getItemId;
                ihook.setColumnValue (row, 'NCI_PUB_ID', v_itemid);
                ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                ihook.setColumnValue (row, 'DISP_ORD', j);
                 rowsvv.extend;
                rowsvv(rowsvv.last) := row;
                j := j+ 1;
                end loop;
                 end loop;
   end loop;

--DESC_TXT
   -- raise_application_error(-20000, v_add);
        if (rows.count > 0) then
                        action := t_actionrowset(rows, 'Question (Base Object)', 2,0,'insert');
                        actions.extend;
                        actions(actions.last) := action;
        end if;

    if (rowsvv.count > 0) then
    action := t_actionrowset(rowsvv, 'Question Valid Values (Hook)', 2,2,'insert');
    actions.extend;
    actions(actions.last) := action;
    end if;

       if (rowsrep.count > 0) then
        action             := t_actionrowset(rowsrep, 'Question Repetition', 2, 4,'insert');
            actions.extend;
            actions(actions.last) := action;
         end if;

  if ( rows.count > 0 ) then  hookoutput.actions := actions;
  end if;
    hookoutput.message := v_add || ' questions added.';

--raise_application_error(-20000,hookoutput.message);
    end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 -- insert into junk_debug values (sysdate, v_data_out);
 -- commit;
END;

PROCEDURE spCopyModule
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
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
v_itemid     integer;
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
  v_item_typ  integer;
  v_mod_specified boolean;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);

    rows := t_rows();
if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a module to this form.');
 end if;

    if hookInput.invocationNumber = 0 then

	    rows :=         t_rows();
		v_found := false;

	    for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id in (52, 54 ) order by admin_item_typ_id) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   iHook.setcolumnvalue (ROW, 'CNTCT_SECU_ID', v_user_id);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'User Cart', 2, 'single');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
     else
               hookoutput.message := 'Please add forms or modules to your cart.';

	   end if;

	end if;

    if hookInput.invocationNumber = 1  then
          v_mod_specified := false;
          row_sel := hookInput.selectedRowset.rowset(1);
          select admin_item_typ_id into v_item_typ from admin_item where  item_id = ihook.getColumnValue(row_sel,'ITEM_ID')
          and ver_nr = ihook.getColumnValue(row_sel,'VER_NR');
          if (v_item_typ = 54) then--- Form
            rows :=         t_rows();
		v_found := false;
	    for cur in (select c.item_id, c.ver_nr from VW_NCI_FORM_MODULE c where c.fld_delete= 0  and c.p_item_id = ihook.getColumnValue(row_sel,'ITEM_ID') and c.p_item_ver_nr =  ihook.getColumnValue(row_sel,'VER_NR') ) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
--raise_application_error(-20000, ihook.getColumnValue(row_sel,'ITEM_ID'));
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'Modules', 2, 'single');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select Module..');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
	   end if;
    else
        v_mod_specified := true;
    end if;
    end if;
    if (hookInput.invocationNumber = 2 or v_mod_specified = true) then -- copy module

	row_sel := hookInput.selectedRowset.rowset(1);
    nci_11179.spCopyModuleNCI (actions, ihook.getColumnValue(row_sel,'ITEM_ID'),ihook.getColumnValue(row_sel,'VER_NR'),
    ihook.getColumnValue(row_sel,'P_ITEM_ID'), ihook.getColumnValue(row_sel,'P_ITEM_VER_NR'), ihook.getColumnValue(row_ori,'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), -1);


    hookoutput.actions := actions;
    hookoutput.message := 'Module copied successfully.';
    --hookoutput.message := v_add || ' concepts added.';
    end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  nci_util.debugHook('GENERAL',v_data_out);

END;


PROCEDURE spAddQuestionNoDE
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
  rowsvv t_rows;
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
v_itemid     integer;
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  v_add integer := 0;
  i integer := 0;
  v_disp_ord integer;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);

    rows := t_rows();


 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a question to this module.');
 end if;

    if hookInput.invocationNumber = 0 then

	    rows :=         t_rows();
		v_found := false;

	    for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id = 4 ) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'User Cart', 2, 'multi');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select CDE to add..');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
	   end if;

	elsif hookInput.invocationNumber = 1 then
		  if hookInput.answerId = 1 then -- Add Question

          select nvl(max(disp_ord)+1,0) into v_disp_ord from NCI_ADMIN_ITEM_REL_ALT_KEY where P_ITEM_ID =ihook.getColumnValue(row_ori,'C_ITEM_ID')  and
          P_ITEM_VER_NR = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and rel_typ_id = 63;

          rows := t_rows();
          rowsvv := t_rows();
              for i in 1..hookInput.selectedRowset.rowset.count loop
                    row_sel := hookInput.selectedRowset.rowset(i);
                    for cur in (select ai.item_id, ai.ver_nr, ai.cntxt_item_id, ai.cntxt_ver_nr, item_long_nm item_long_nm, nvl(r.ref_desc, item_long_nm) QUEST_TEXT from admin_item ai, ref r where
                    ai.item_id = ihook.getColumnValue(row_sel,'ITEM_ID') and ai.ver_nr = ihook.getColumnValue(row_sel,'VER_NR') and ai.item_id = r.item_id (+) and ai.ver_nr = r.ver_nr (+)
                    and r.ref_typ_id (+) = 80
                    and (ai.item_id, ai.ver_nr) not in (select c_item_id, c_item_ver_nr from nci_admin_item_rel_alt_key where p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
                            p_item_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') and rel_typ_id = 63 )) loop
                        row := t_row();

                        v_id := nci_11179.getItemId;
                        ihook.setColumnValue (row, 'NCI_PUB_ID', v_id);
                        ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                        ihook.setColumnValue (row, 'P_ITEM_ID', ihook.getColumnValue(row_ori,'C_ITEM_ID'));
                        ihook.setColumnValue (row, 'P_ITEM_VER_NR', ihook.getColumnValue(row_ori,'C_ITEM_VER_NR'));
                        ihook.setColumnValue (row, 'C_ITEM_ID', cur.item_id);
                        ihook.setColumnValue (row, 'C_ITEM_VER_NR', cur.ver_nr);
                        ihook.setColumnValue (row, 'CNTXT_CS_ITEM_ID', cur.cntxt_item_id);
                        ihook.setColumnValue (row, 'CNTXT_CS_VER_NR', cur.cntxt_ver_nr);
                        ihook.setColumnValue (row, 'ITEM_LONG_NM', cur.QUEST_TEXT );

                        ihook.setColumnValue (row, 'REL_TYP_ID', 63);
                        ihook.setColumnValue (row, 'DISP_ORD', v_disp_ord);
                        v_disp_ord := v_disp_ord + 1;

                        v_add := v_add + 1;
                        rows.extend;
                        rows(rows.last) := row;


                for cur1 in (select PERM_VAL_NM, PERM_VAL_DESC_TXT, item_nm, item_long_nm from  VW_NCI_DE_PV where de_item_id = cur.item_id and de_ver_nr = cur.ver_nr) loop
                  row := t_row();
                ihook.setColumnValue (row, 'Q_PUB_ID', v_id);
                ihook.setColumnValue (row, 'Q_VER_NR', 1);
                ihook.setColumnValue (row, 'VM_NM', cur1.item_nm);
                ihook.setColumnValue (row, 'VM_LNM', cur1.item_long_nm);
                ihook.setColumnValue (row, 'VM_DEF', cur1.item_nm);
                ihook.setColumnValue (row, 'VALUE', cur1.perm_val_nm);
                ihook.setColumnValue (row, 'MEAN_TXT', cur1.item_long_nm);
                v_itemid := nci_11179.getItemId;
                ihook.setColumnValue (row, 'NCI_PUB_ID', v_itemid);
                ihook.setColumnValue (row, 'NCI_VER_NR', 1);

                 rowsvv.extend;
                rowsvv(rowsvv.last) := row;
                v_found := true;
              --  raise_application_error(-20000, 'Inside');
                end loop;
                 end loop;
   end loop;

--DESC_TXT
   -- raise_application_error(-20000, v_add);
        if (v_add > 0) then
                        action := t_actionrowset(rows, 'Question (Base Object)', 2,0,'insert');
                        actions.extend;
                        actions(actions.last) := action;
        end if;

    if (v_found) then
    action := t_actionrowset(rowsvv, 'Question Valid Values (Hook)', 2,2,'insert');
    actions.extend;
    actions(actions.last) := action;
    end if;

    hookoutput.actions := actions;
    hookoutput.message := v_add || ' questions added.';
    end if;
end if;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  --insert into junk_debug values (sysdate, v_data_out);
  --commit;
END;



PROCEDURE spChngQuestTextVV (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
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
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(255);
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

 /*select frm_item_id, frm_ver_nr into v_frm_id, v_frm_Ver_nr from VW_NCI_MODULE_DE where nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
 */
 select frm_item_id, frm_ver_nr into v_frm_id, v_frm_ver_nr from vw_nci_module_de where
nci_pub_id = ihook.getColumnValue(row_ori, 'Q_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any valid value on this form.');
 end if;

 if hookInput.invocationNumber = 0 then


	    for cur in (select nm_id from alt_nms r where r.fld_delete= 0 and
        (item_id, ver_nr) in (select NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR from VW_NCI_DE_PV pv,
        NCI_ADMIN_ITEM_REL_ALT_KEY q where pv.DE_ITEM_ID = q.C_ITEM_id and pv.DE_VER_NR = q.c_ITEM_VER_NR and q.NCI_PUB_ID = ihook.getColumnValue(row_ori,'Q_PUB_ID')
        and q.NCI_VER_NR= ihook.getColumnValue(row_ori, 'Q_VER_NR') and pv.PERM_VAL_NM = ihook.getColumnValue(row_ori, 'VALUE'))) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'NM_ID', cur.NM_id);
		   rows.extend;
		   rows (rows.last) := row;

 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;

	  if (v_found) then
      ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select alternate.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
   --  ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(2, 2, 'Set to default.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Value Meaning Text', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
       	 showrowset := t_showablerowset (rows, 'Alternate Names', 2, 'single');
       	 hookoutput.showrowset := showrowset;
        else
        hookoutput.message := 'No alternate names found.';
     end if;
 ELSE

            if (hookinput.answerId = 1) then
            row_sel := hookinput.selectedRowset.rowset(1);
            select nm_desc into v_ref from alt_nms where nm_id = ihook.getColumnValue(row_sel, 'NM_ID');
            else   -- 2 means set default


           select pv.item_nm into v_ref from VW_NCI_DE_PV pv,
        NCI_ADMIN_ITEM_REL_ALT_KEY q where pv.DE_ITEM_ID = q.C_ITEM_id and pv.DE_VER_NR = q.c_ITEM_VER_NR and q.NCI_PUB_ID = ihook.getColumnValue(row_ori,'Q_PUB_ID')
        and q.NCI_VER_NR= ihook.getColumnValue(row_ori, 'Q_VER_NR') and pv.PERM_VAL_NM = ihook.getColumnValue(row_ori, 'VALUE');
           -- select nm_desc into v_ref from alt_nms where nm_id = ihook.getColumnValue(row_sel, 'NM_ID');

            end if;
            ihook.setColumnValue(row_ori, 'MEAN_TXT', v_ref);

            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row_ori;

            action             := t_actionrowset(rows, 'Question Valid Values (Hook)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
     hookoutput.actions    := actions;
    END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spChngQuestDefVV (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
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
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(255);
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

 /*select frm_item_id, frm_ver_nr into v_frm_id, v_frm_Ver_nr from VW_NCI_MODULE_DE where nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
 */
  select frm_item_id, frm_ver_nr into v_frm_id, v_frm_ver_nr from vw_nci_module_de where
nci_pub_id = ihook.getColumnValue(row_ori, 'Q_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any valid value on this form.');
 end if;
 if hookInput.invocationNumber = 0 then


	    for cur in (select def_id from alt_def r where r.fld_delete= 0 and
        (item_id, ver_nr) in (select NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR from VW_NCI_DE_PV pv,
        NCI_ADMIN_ITEM_REL_ALT_KEY q where pv.DE_ITEM_ID = q.C_ITEM_id and pv.DE_VER_NR = q.c_ITEM_VER_NR and q.NCI_PUB_ID = ihook.getColumnValue(row_ori,'Q_PUB_ID')
        and q.NCI_VER_NR= ihook.getColumnValue(row_ori, 'Q_VER_NR') and pv.PERM_VAL_NM = ihook.getColumnValue(row_ori, 'VALUE'))) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'DEF_ID', cur.DEF_id);
		   rows.extend;
		   rows (rows.last) := row;

 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;

	  if (v_found) then
      ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select alternate.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('VM Alternate Description', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
       	 showrowset := t_showablerowset (rows, 'Alternate Definitions', 2, 'single');
       	 hookoutput.showrowset := showrowset;
        else
        hookoutput.message := 'No alternate definitions found.';
     end if;
 ELSE
            row_sel := hookinput.selectedRowset.rowset(1);

            select def_desc into v_ref from alt_def where def_id = ihook.getColumnValue(row_sel, 'DEF_ID');

            ihook.setColumnValue(row_ori, 'VM_DEF', v_ref);

            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row_ori;

            action             := t_actionrowset(rows, 'Question Valid Values (Hook)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;


    hookoutput.actions    := actions;
    END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spQuestRemoveDE ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2) as
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_item_id  number;
    v_ver_nr  number(4,2);
begin
    -- Standard header
    hookInput                    := Ihook.gethookinput (v_data_in);
    hookOutput.invocationnumber  := hookInput.invocationnumber;
    hookOutput.originalrowset    := hookInput.originalrowset;

    -- Get the selected row
    row_ori :=  hookInput.originalRowset.rowset(1);

    -- if no DE already, give an error message
    if (ihook.getColumnValue(row_ori, 'C_ITEM_ID') is null) then
        raise_application_error(-20000,'No CDE attached..');
        return;
    end if;

      select p_item_id, p_item_ver_nr into v_item_id, v_ver_nr from nci_admin_item_rel where rel_typ_id = 61 and
       c_item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and c_item_ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');

    -- Check if user is authorized to edit
    if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;

   ihook.setColumnValue(row_ori,'C_ITEM_ID','');
   ihook.setColumnValue(row_ori,'C_ITEM_VER_NR','');

    rows := t_rows();    rows.extend;    rows(rows.last) := row_ori;
    action := t_actionrowset(rows, 'Question (Base Object)', 2,2,'update');
        actions.extend;
        actions(actions.last) := action;


        hookoutput.message := 'CDE removed.' ;
        hookoutput.actions := actions;
            V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

--insert into junk_debug (id, test) values (sysdate, v_data_out);
--commit;

end;

end;
/
