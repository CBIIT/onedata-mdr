create or replace PACKAGE            nci_DEC_MGMT AS

procedure valUsingStr (rowform in out t_row, k in integer, v_item_typ in integer) ;

-- Common procedure for all AI with concept.
-- DO NOT TOUCH the 2 below
procedure createValAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer, v_mode in varchar2,v_cncpt_src in varchar2,  actions in out t_actions);
procedure createAIWithoutConcept(rowform in out t_row, idx in integer, v_item_typ_id in integer, v_long_nm in varchar2, v_desc in varchar2, v_mode in varchar2, actions in out t_actions);

-- New procedures for DEC Create, Create from Existing and Edit.

PROCEDURE spDECCreateNew (v_data_in in clob, v_data_out out clob);
PROCEDURE spDECCreateFrom (v_data_in in clob, v_data_out out clob);
PROCEDURE spDECEdit (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);

-- Common procedure called by new, create from existing or edit

procedure spDECCommon ( v_init in t_rowset, v_init_cncpt in t_rowset, v_op  in varchar2, v_src in integer, hookInput in t_hookInput, hookOutput in out t_hookOutput);
procedure spDECCommonEdit ( v_init in t_rowset, v_init_cncpt in t_rowset, v_op  in varchar2, v_src in integer, hookInput in t_hookInput, hookOutput in out t_hookOutput);

--Used in Import  v_op - 'V'  validate, 'C' create
procedure spDECValCreateImport ( rowform in out t_row,  v_op  in varchar2, actions in out t_actions, v_val_ind in out boolean);

procedure CncptCombExistsNew (rowform in out t_row, v_item_nm in varchar2, v_item_typ in integer, v_idx in number, v_item_id out number, v_item_ver_nr out number);
-- use getDECQUestion with INSERT or UPDATE as the v_op
function getDECCreateQuestion (v_src in integer) return t_question;
function getDECEditQuestionReleased  return t_question;
function getDECEditQuestion return t_question;
function getDECQuestion (v_op in varchar2, v_src in integer) return t_question;


procedure createDEC (rowai in t_row, rowform in t_row, actions in out t_actions, v_id out number);

procedure createDECImport (rowform in out t_row, actions in out t_actions);

-- Get the form for DEC Create
function getDECCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;

procedure spBulkUpdateDEC ( v_data_in IN CLOB,    v_data_out OUT CLOB,    v_usr_id  IN varchar2);

END;
/
create or replace PACKAGE BODY nci_DEC_MGMT AS

-- All DEC creation and import routines.
-- Standard concept-related entity creation

c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';

v_int_cncpt_id  number := 2433736;


PROCEDURE spBulkUpdateDEC
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_usr_id  IN varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();

  actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
  rowscd t_rows;
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
    v_item_id number;
    v_ver_nr number(4,2);
  v_temp integer;
  v_nm_typ_id integer;

  v_cnt integer;
    v_found boolean;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;


  if hookInput.invocationNumber = 0  then
     	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Bulk Update');
         answers.extend;          answers(answers.last) := answer;
         question := t_question('Choose Option', answers);
       	 hookOutput.question := question;
         row := t_row();
        rows := t_rows();

        ihook.setColumnValue(row, 'ITEM_ID', -1);
        ihook.setColumnValue(row, 'VER_NR',-1); -- Default values
     rows.extend;               rows(rows.last) := row;
        rowset := t_rowset(rows, 'Data Element Concept (Bulk Update Hook)', 1, 'DE_CONC'); -- Default values for form

        forms                  := t_forms();
        form1                  := t_form('Data Element Concept (Bulk Update Hook)', 2,1);
        form1.rowset :=rowset;
        forms.extend;    forms(forms.last) := form1;
        hookoutput.forms := forms;
  	elsif hookInput.invocationNumber = 1 then
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);  -- entered values from user
        rows := t_rows();
        rowscd := t_rows();
        for i in 1..hookinput.originalrowset.rowset.count loop
                row_ori :=  hookInput.originalRowset.rowset(i);
                if (ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') = 2) then
                    v_item_id :=ihook.getColumnValue(row_ori, 'ITEM_ID');
                    v_ver_nr :=ihook.getColumnValue(row_ori, 'VER_NR');
                      if (ihook.getColumnValue(rowform, 'ADMIN_STUS_ID') is not null or ihook.getColumnValue(rowform, 'REGSTR_STUS_ID') is not null or
                   ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID') is not null ) then
                        row := row_ori;
                        ihook.setColumnValue(row, 'ADMIN_STUS_ID', nvl(ihook.getColumnValue(rowform, 'ADMIN_STUS_ID'), ihook.getColumnValue(row_ori, 'ADMIN_STUS_ID')));
                        ihook.setColumnValue(row, 'REGSTR_STUS_ID', nvl(ihook.getColumnValue(rowform, 'REGSTR_STUS_ID'), ihook.getColumnValue(row_ori, 'REGSTR_STUS_ID')));
                        ihook.setColumnValue(row, 'CNTXT_ITEM_ID', nvl(ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID'), ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')));
                       ihook.setColumnValue(row, 'CNTXT_VER_NR', nvl(ihook.getColumnValue(rowform, 'CNTXT_VER_NR'), ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')));
                   rows.extend;               rows(rows.last) := row;
                    end if;
                    if (ihook.getColumnValue(rowform, 'CONC_DOM_ITEM_ID') is not null ) then
                        row := t_row();
                        nci_11179.spReturnSubTypeRow(v_item_id, v_ver_nr,2, row);
                        ihook.setColumnValue(row, 'CONC_DOM_ITEM_ID', ihook.getColumnValue(rowform, 'CONC_DOM_ITEM_ID'));
                        ihook.setColumnValue(row, 'CONC_DOM_VER_NR', ihook.getColumnValue(rowform, 'CONC_DOM_VER_NR'));
                            rowscd.extend;               rowscd(rowscd.last) := row;
                    end if;
                end if;
        end loop;

               if (rows.count > 0) then
                    action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'update');
                        actions.extend;
                        actions(actions.last) := action;
                end if;
                 if (rowscd.count > 0) then
                    action := t_actionrowset(rowscd, 'Data Element Concept', 2,1,'update');
                        actions.extend;
                        actions(actions.last) := action;
                end if;
    end if;



if (actions.count > 0) then
  hookoutput.actions := actions;
       hookoutput.message := 'Data Element Concepts updated: ' || greatest(rowscd.count, rows.count);

else
       hookoutput.message := 'Only Data Element Concept will be updated.';

end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL',v_data_out);
END;



-- Utility procedure to parse the Concept string and update the drop-downs.
-- k is the index 1 - OC, 2 - Prop; For all other item types always 1.

procedure valUsingStr (rowform in out t_row, k in integer, v_item_typ in integer) as
i integer;
v_str varchar2(255);
cnt integer;
v_nm varchar2(255);
v_cncpt_nm varchar2(255);
v_def varchar2(255);
v_item_id number;
v_ver_nr number;
v_long_nm varchar2(255);
begin

    -- Set all the concept drop-down to null

           for i in  1..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
            end loop;

    --  Only parse if string is not null

            if (ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_' || k) is not null) then
                v_str := trim(ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_'|| k));
                cnt := nci_11179.getwordcount(v_str);
                v_nm := '';
                for i in  1..cnt loop
                        v_cncpt_nm := nci_11179.getWord(v_str, i, cnt);
                        ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                        for cur in(select item_id, item_nm , item_long_nm from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
                                ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,cur.item_id);
                                ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, 1);
                                v_nm := trim(v_nm || ':' || cur.item_long_nm);
                        end loop;
                end loop;

  -- Check if concept combination esits. If it sodes, set the ITEM_k_ID and ITEM_k_VER_NR.

                nci_11179.CncptCombExists(substr(v_nm,2),v_item_typ,v_item_id, v_ver_nr,v_long_nm, v_def);
                ihook.setColumnValue(rowform, 'ITEM_' || k  ||'_ID',v_item_id);
                ihook.setColumnValue(rowform, 'ITEM_' || k || '_VER_NR', v_ver_nr);
                ihook.setColumnValue(rowform,'ITEM_' || k || '_LONG_NM', trim(substr(v_nm,2)));
                ihook.setColumnValue(rowform,'ITEM_' || k || '_DEF', v_def);
                ihook.setColumnValue(rowform,'ITEM_' || k || '_NM', v_long_nm);
            end if;

            end;


-- Create from existing. Only the start point is different. Else - everything the same as New.

PROCEDURE spDECCreateFrom ( v_data_in IN CLOB, v_data_out OUT CLOB) as
  hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_item_id  number;
    v_ver_nr  number(4,2);
    v_ori_rep_cls number;
    v_item_type_id number;
    v_oc_item_id number;
    v_prop_item_id number;
    v_oc_ver_nr number(4,2);
    v_prop_ver_nr number(4,2);
    v_conc_dom_item_id number;
    v_conc_dom_ver_nr number(4,2);
    rowsetai  t_rowset;
    rowsetcncpt  t_rowset;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    -- Get the selected row
    row_ori :=  hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_item_type_id := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');

    -- check that a selected AI is DEC type
    if (v_item_type_id <> 2) then
        raise_application_error(-20000,'!!! This functionality is only applicable for DEC !!!');
    end if;


    row := row_ori;
    ihook.setColumnValue(row, 'ITEM_ID', -1);
      nci_11179_2.setStdAttr(row);
                 ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 2);
                        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);

   --       ihook.setColumnValue(row, 'ITEM_NM', v_dflt_txt);
    --      ihook.setColumnValue(row, 'ITEM_DESC', v_dflt_txt);
       --   ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);
    rows := t_rows();    rows.extend;    rows(rows.last) := row;
     rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for AI form

     row := t_row();

    select obj_cls_item_id, obj_cls_ver_nr, prop_item_id, prop_ver_nr, conc_dom_item_id, conc_dom_ver_nr into v_oc_item_id, v_oc_ver_nr, v_prop_item_id, v_prop_ver_nr ,
    v_conc_dom_item_id, v_conc_dom_ver_nr
    from de_conc where item_id = v_item_id and ver_nr = v_ver_nr;

     -- Copy subtype specific attributes into concept drop-down
    nci_11179.spReturnConceptRow (v_oc_item_id, v_oc_ver_nr, 5, 1, row );
    nci_11179.spReturnConceptRow (v_prop_item_id, v_prop_ver_nr, 6, 2, row );

    --  Set the conceptual domain and default for dummy internal ID.
    ihook.setColumnValue(row, 'STG_AI_ID', 1);
    ihook.setColumnValue(row, 'CONC_DOM_ITEM_ID', v_conc_dom_item_id);
    ihook.setColumnValue(row, 'CONC_DOM_VER_NR', v_conc_dom_ver_nr);

    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowsetcncpt := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT'); -- Default values for form

    spDECCommon(rowsetai,rowsetcncpt ,'insert',2, hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  --  nci_util.debugHook('GENERAL',v_data_out);

end;


-- Create new DEC
PROCEDURE spDECCreateNew ( v_data_in IN CLOB, v_data_out OUT CLOB)
as
  hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
     rowsetai  t_rowset;
     rowsetcncpt t_rowset;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;


    -- Default for new row. Dummy Identifier has to be set else error.
    row := t_row();
          row := t_row();
          nci_11179_2.setStdAttr(row);
          ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 2);
 --         ihook.setColumnValue(row, 'ITEM_NM', v_dflt_txt);
          ihook.setColumnValue(row, 'ITEM_DESC', v_dflt_txt);
          ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);

    rows := t_rows(); rows.extend;    rows(rows.last) := row;
    rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for AI form
     row := t_row();
        ihook.setColumnValue(row, 'STG_AI_ID', 1);

    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowsetcncpt := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT'); -- Default values for form

    spDECCommon(rowsetai,rowsetcncpt, 'insert',1, hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  --  nci_util.debugHook('GENERAL',v_data_out);
end;

-- Edit an existing DEC

PROCEDURE spDECEdit ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_item_id  number;
    v_ver_nr  number(4,2);
    v_ori_rep_cls number;
    v_item_type_id number;
    v_oc_item_id number;
    v_prop_item_id number;
    v_oc_ver_nr number(4,2);
    v_prop_ver_nr number(4,2);
      v_conc_dom_item_id number;
    v_conc_dom_ver_nr number(4,2);
    v_str varchar2(255);
    rowsetai  t_rowset;
    rowsetcncpt  t_rowset;


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


    -- Check if user is authorized to edit
    if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;

    -- check that a selected AI is DEC type
    if (v_item_type_id <> 2) then
        raise_application_error(-20000,'!!! This functionality is only applicable for DEC !!!');
    end if;

    row := row_ori;

    rows := t_rows();    rows.extend;    rows(rows.last) := row;
     rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for AI form

    --  Only AI row is submitted with the hook. We need to get the sub-type details and populate the OC/Prop concepts
    row := t_row();

    select obj_cls_item_id, obj_cls_ver_nr, prop_item_id, prop_ver_nr, conc_dom_item_id, conc_dom_ver_nr into v_oc_item_id, v_oc_ver_nr, v_prop_item_id, v_prop_ver_nr ,
    v_conc_dom_item_id, v_conc_dom_ver_nr
    from de_conc where item_id = v_item_id and ver_nr = v_ver_nr;

     -- Copy OC and Prop concepts
    nci_11179.spReturnConceptRow (v_oc_item_id, v_oc_ver_nr, 5, 1, row );
    nci_11179.spReturnConceptRow (v_prop_item_id, v_prop_ver_nr, 6, 2, row );

    -- Internal dummy is is set to 1. Existing CD is populated.
    ihook.setColumnValue(row, 'STG_AI_ID', 1);
    ihook.setColumnValue(row, 'CONC_DOM_ITEM_ID', v_conc_dom_item_id);
    ihook.setColumnValue(row, 'CONC_DOM_VER_NR', v_conc_dom_ver_nr);
    
    v_str := nci_11179_2.getCncptStrFromCncpt (v_oc_item_id, v_oc_ver_nr, 5) ;
   ihook.setColumnValue(row, 'CNCPT_CONCAT_STR_1', v_str);
   ihook.setColumnValue(row, 'CNCPT_CONCAT_STR_1_ORI', v_str);
   v_str := nci_11179_2.getCncptStrFromCncpt (v_prop_item_id, v_prop_ver_nr, 6) ;
   ihook.setColumnValue(row, 'CNCPT_CONCAT_STR_2', v_str);
   ihook.setColumnValue(row, 'CNCPT_CONCAT_STR_2_ORI', v_str);
 

    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowsetcncpt := t_rowset(rows, 'DEC Create Edit (Hook)', 1, 'NCI_STG_AI_CNCPT_CREAT');

    spDECCommonEdit(rowsetai,rowsetcncpt,  'update',3, hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

nci_util.debugHook('GENERAL', v_data_out);
--raise_application_error(-20000,'HEre');
end;


-- Common routine for DEC - Create or Update
-- v_init is the initial rowset to populate.
-- v_op is insert or update
PROCEDURE       spDECCommon ( v_init in t_rowset,  v_init_cncpt in t_rowset, v_op  in varchar2, v_src in integer, hookInput in t_hookInput, hookOutput in out t_hookOutput)
AS
rowform t_row;
forms t_forms;
form1 t_form;

row t_row;
rows  t_rows;
row_ori t_row;
rowai t_row;
rowset            t_rowset;
v_oc_item_id number;
v_oc_ver_nr number;
v_prop_item_id number;
v_prop_ver_nr number;
v_dec_item_id number;
v_str  varchar2(255);
v_nm  varchar2(255);
v_item_id number;
v_ver_nr number(4,2);
cnt integer;

actions t_actions := t_actions();
action t_actionRowset;
i integer := 0;
v_dec_nm varchar2(255);
v_cncpt_nm varchar2(255);
v_long_nm varchar2(255);
v_def varchar2(4000);
v_oc_id number;
v_prop_id number;
v_temp_id  number;
v_temp_ver number(4,2);
v_oc_str varchar2(4000);
v_prop_str varchar2(4000);
rowsetcncpt t_rowset;
v_err_str  varchar2(4000);
v_answer integer;
is_valid boolean;
begin
    if hookInput.invocationNumber = 0 then

            --  Get question. Either create or edit
          HOOKOUTPUT.QUESTION    := getDECQuestion(v_op, v_src);

   row := t_row();

    -- Send initial rowset to create the form.
          hookOutput.forms :=getDECCreateForm(v_init, v_init_cncpt);
    else
        forms              := hookInput.forms;
        form1              := forms(1);
        rowai := form1.rowset.rowset(1);
        form1              := forms(2);
        rowform := form1.rowset.rowset(1);
        -- Copy context from AI row to be used in OC and Prop creation
        ihook.setColumnValue(rowform, 'CNTXT_ITEM_ID', ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID'));
         ihook.setColumnValue(rowform, 'CNTXT_VER_NR', ihook.getColumnValue(rowai, 'CNTXT_VER_MR'));

        row := t_row();        rows := t_rows();
        is_valid := true;


v_answer := 0;
-- Changing the logic to determine use of string or dropdown. rather than changing the entire logic, changing the code here to reduce regression testing
 if (lower(v_op) <> 'update') then -- Insert
if (hookinput.answerid = 5 and ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') is not null ) then
    v_answer:= 1; -- Validate using string
elsif (hookinput.answerid = 5 and ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') is null) then
    v_answer := 2;  -- Validate using dd
elsif(hookinput.answerid = 6 and ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') is not null) then
    v_answer := 3; -- create using string
else
    v_answer := 4;  -- create using dd
end if;    
end if;

 if (lower(v_op) = 'update') then -- update
if (hookinput.answerid = 5 and ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') is not null
and (ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') <> ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1_ORI')
or ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2') <> ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2_ORI'))) then
    v_answer:= 1; -- Validate using string
elsif (hookinput.answerid = 5 and ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') is not null and (ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') = ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1_ORI')
or ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2') = ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2_ORI'))) then
    v_answer := 2;  -- Validate using dd
elsif(hookinput.answerid = 6 and ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') is not null
and (ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') <> ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1_ORI')
or ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2') <> ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2_ORI'))) then
    v_answer := 3; -- create using string
else
    v_answer := 4;  -- create using dd
end if;    
end if;

--raise_application_error(-20000, hookinput.answerid || v_answer);
        if v_answer= 1 or v_answer = 3 then  -- Validate using string
            for k in  1..2  loop
                    for i in  1..10 loop
                            ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                            ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                    end loop;
            end loop;
            for k in  1..2  loop -- both OC and Prop
                createValAIWithConcept(rowform , k,4+k,'V','STRING',actions);
            end loop;
        end if;

        if v_answer = 2 or v_answer = 4 then  -- Validate using drop-down
            for k in  1..2  loop -- Both OC and prop
               createValAIWithConcept(rowform , k,4+k,'V','DROP-DOWN',actions);
            end loop;
        end if;

    -- Show generated name
       ihook.setColumnValue(rowform, 'GEN_STR',replace(ihook.getColumnValue(rowform,'ITEM_1_NM') ||  ' ' || ihook.getColumnValue(rowform,'ITEM_2_NM'),'Integer::','') ) ;
       ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'VALIDATED');
   -- ihook.setColumnValue(row,'ITEM_NM', v_nm, 'Integer::',''));

    -- Check if DEC is a duplicate. Removed Context from the test as per Denise.
       v_item_id := -1;

  -- If update, then need to get the Item_id to exclude from duplicate check
       if (lower(v_op) = 'update') then
            row_ori :=  hookInput.originalRowset.rowset(1);
            v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
            v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
       end if;


         if (   ihook.getColumnValue(rowform, 'ITEM_1_ID') is not null and ihook.getColumnValue(rowform, 'ITEM_2_ID') is not null) then
            select cncpt_concat into v_oc_str from nci_admin_item_ext where item_id = ihook.getColumnValue(rowform, 'ITEM_1_ID') and ver_nr= ihook.getColumnValue(rowform, 'ITEM_1_VER_NR');
            select cncpt_concat into v_prop_str from nci_admin_item_ext where item_id = ihook.getColumnValue(rowform, 'ITEM_2_ID') and ver_nr= ihook.getColumnValue(rowform, 'ITEM_2_VER_NR');
            for oc_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_oc_str and ai.admin_item_typ_id = 5) loop
            for prop_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_prop_str and ai.admin_item_typ_id = 6) loop
               for cur in (select de_conc.* from de_conc, admin_item ai where obj_cls_item_id =  oc_cur.item_id and obj_cls_ver_nr =  oc_cur.ver_nr and
               prop_item_id = prop_cur.item_id and prop_ver_nr =  prop_cur.ver_nr and
               cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR') and
              de_conc.item_id = ai.item_id and de_conc.ver_nr = ai.ver_nr and de_conc.item_id <> v_item_id
             ) loop
                    ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'DUPLICATE DEC found:' || cur.item_id || 'v' || cur.ver_nr);
                    is_valid := false;
              end loop;
              end loop;
              end loop;
        end if;

        if (   ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is null or ihook.getColumnValue(rowform, 'CNCPT_2_ITEM_ID_1') is null) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'OC or PROP missing.');
                  is_valid := false;
        end if;

          v_err_str := '';
        nci_11179_2.stdAIValidation(rowai, 2,is_valid, v_err_str );
    --    nci_11179_2.stdCncptRowValidation(rowform, 1,is_valid, v_err_str );
     --   nci_11179_2.stdCncptRowValidation(rowform, 2,is_valid, v_err_str );
        if (v_err_str is not null) then
            ihook.setColumnValue(rowform, 'CTL_VAL_MSG', v_err_Str);
        end if;


         -- If any of the test fails or if the user has triggered validation, then go back to the screen.
        if (is_valid=false or v_answer = 1 or v_answer = 2) then

                hookoutput.message := ihook.getColumnValue(rowform, 'CTL_VAL_MSG');
                ihook.setColumnValue(rowai, 'ITEM_NM', ihook.getColumnValue(rowform, 'GEN_STR'));
       --         ihook.setColumnValue(rowform, 'CNTXT_VER_NR', ihook.getColumnValue(rowai, 'CNTXT_VER_MR'));
                ihook.setColumnValue(rowai, 'ADMIN_ITEM_TYP_ID', 2);

                rows := t_rows();
                rows.extend;
                rows(rows.last) := rowai;
                rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');


                rows := t_rows();
                rows.extend;
                rows(rows.last) := rowform;
                rowsetcncpt := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
                hookOutput.forms := getDECCreateForm(rowset, rowsetcncpt);
                HOOKOUTPUT.QUESTION    := getDECQuestion(v_op, v_src);
        end if;

    -- If all the tests have passed and the user has asked for create, then create DEC and optionally OC and Prop.
    IF v_answer in ( 3,4)  and is_valid = true THEN  -- Create
        createValAIWithConcept(rowform , 1,5,'C','DROP-DOWN',actions); -- OC
        createValAIWithConcept(rowform , 2,6,'C','DROP-DOWN',actions); -- Property

    --If Create DEC
    if (upper(v_op) = 'INSERT') then

        createDEC(rowai, rowform, actions, v_item_id);
        hookoutput.message := 'DEC Created Successfully with ID ' || v_item_id ;
    else
    -- Update DEC. Get the selected row, update name, definition, context.
        row := t_row();
        row_ori :=  hookInput.originalRowset.rowset(1);

        v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');

        --- Update name, definition, context
            row := rowai;

               ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 2);
     ihook.setColumnValue(row, 'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000));
         ihook.setColumnValue(row,'ITEM_NM',  replace(ihook.getColumnValue(rowform, 'ITEM_1_NM')  || ' ' || ihook.getColumnValue(rowform, 'ITEM_2_NM'),'Integer::',''));

    if (ihook.getColumnValue(rowai, 'ITEM_NM_CURATED') is not null) then
        ihook.setColumnValue(row,'ITEM_NM', ihook.getColumnValue(rowai, 'ITEM_NM_CURATED'));
       end if;

            --  ihook.setColumnValue(row, 'ADMIN_STUS_ID', ihook.getColumnValue(rowform,'ADMIN_STUS_ID'));
           -- ihook.setColumnValue(row, 'REGSTR_STUS_ID', ihook.getColumnValue(rowform,'REGSTR_STUS_ID'));
      --      raise_application_error(-20000,  ihook.getColumnValue(rowform,'ITEM_LONG_NM'));
          --  ihook.setColumnValue(row, 'ITEM_LONG_NM', ihook.getColumnValue(rowform,'ITEM_LONG_NM'));
           rows := t_rows();    rows.extend;    rows(rows.last) := row;
             action := t_actionrowset(rows, 'Administered Item', 2,10,'update',hookinput.originalrowset.conceptualobjectname);
            actions.extend;
            actions(actions.last) := action;

           row := t_row();

           -- Get the current DEC row. Update OC, Prop, CD.
            nci_11179.spReturnSubtypeRow (v_item_id, v_ver_nr, 2, row );
            ihook.setColumnValue(row, 'OBJ_CLS_ITEM_ID', ihook.getColumnValue(rowform,'ITEM_1_ID'));
            ihook.setColumnValue(row, 'OBJ_CLS_VER_NR', ihook.getColumnValue(rowform,'ITEM_1_VER_NR'));
            ihook.setColumnValue(row, 'PROP_ITEM_ID', ihook.getColumnValue(rowform,'ITEM_2_ID'));
            ihook.setColumnValue(row, 'PROP_VER_NR', ihook.getColumnValue(rowform,'ITEM_2_VER_NR'));
            ihook.setColumnValue(row, 'CONC_DOM_ITEM_ID', ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID'));
            ihook.setColumnValue(row, 'CONC_DOM_VER_NR', ihook.getColumnValue(rowform,'CONC_DOM_VER_NR'));

             rows := t_rows();    rows.extend;    rows(rows.last) := row;
             action := t_actionrowset(rows, 'Data Element Concept', 2,11,'update',hookinput.originalrowset.conceptualobjectname);
            actions.extend;
            actions(actions.last) := action;
    end if;  -- End update if
    if (actions.count > 0) then
        hookoutput.actions := actions;
    end if;
end if; -- End creation if.
     -- raise_application_error(-20000,'Inside');

end if; -- not first invocation if

END;

PROCEDURE       spDECCommonEdit ( v_init in t_rowset,  v_init_cncpt in t_rowset, v_op  in varchar2, v_src in integer, hookInput in t_hookInput, hookOutput in out t_hookOutput)
AS
rowform t_row;
forms t_forms;
form1 t_form;

row t_row;
rows  t_rows;
row_ori t_row;
rowai t_row;
rowset            t_rowset;
v_oc_item_id number;
v_oc_ver_nr number;
v_prop_item_id number;
v_prop_ver_nr number;
v_dec_item_id number;
v_str  varchar2(255);
v_nm  varchar2(255);
v_item_id number;
v_ver_nr number(4,2);
cnt integer;

actions t_actions := t_actions();
action t_actionRowset;
i integer := 0;
v_dec_nm varchar2(255);
v_cncpt_nm varchar2(255);
v_long_nm varchar2(255);
v_def varchar2(4000);
v_oc_id number;
v_prop_id number;
v_temp_id  number;
v_temp_ver number(4,2);
v_oc_str varchar2(4000);
v_prop_str varchar2(4000);
rowsetcncpt t_rowset;
v_err_str  varchar2(4000);
v_answer integer;
is_valid boolean;
begin
            row_ori :=  hookInput.originalRowset.rowset(1);
    if hookInput.invocationNumber = 0 then

-- Tracker 
           if (ihook.getColumnValue(row_ori,'ADMIN_STUS_ID') = 75) then -- REleased DEC
              hookoutput.question := getDECEditQuestionReleased;
              hookoutput.message := 'This is a RELEASED DEC. Are you sure you want to edit?';
            else            
            --  Get question. Either create or edit
            HOOKOUTPUT.QUESTION    := getDECQuestion(v_op, v_src);
                     hookOutput.forms :=getDECCreateForm(v_init, v_init_cncpt);

            end if;
   row := t_row();

    -- Send initial rowset to create the form.
     else
if (hookinput.answerid = 10) then -- proceed
                rows := t_rows();
                rows.extend;
                rows(rows.last) := rowform;
                rowsetcncpt := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
--                hookOutput.forms := getDECCreateForm(rowset, rowsetcncpt);
            hookOutput.forms :=getDECCreateForm(v_init, v_init_cncpt);
              HOOKOUTPUT.QUESTION    := getDECQuestion(v_op, v_src);
    return;
    end if;

        forms              := hookInput.forms;
        form1              := forms(1);
        rowai := form1.rowset.rowset(1);
        form1              := forms(2);
        rowform := form1.rowset.rowset(1);
        -- Copy context from AI row to be used in OC and Prop creation
        ihook.setColumnValue(rowform, 'CNTXT_ITEM_ID', ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID'));
         ihook.setColumnValue(rowform, 'CNTXT_VER_NR', ihook.getColumnValue(rowai, 'CNTXT_VER_MR'));

        row := t_row();        rows := t_rows();
        is_valid := true;


v_answer := 0;
    
if (hookinput.answerid = 5 and ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') is not null
and (ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') <> ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1_ORI')
or ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2') <> ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2_ORI'))) then
    v_answer:= 1; -- Validate using string
elsif (hookinput.answerid = 5 and ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') is not null and (ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') = ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1_ORI')
or ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2') = ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2_ORI'))) then
    v_answer := 2;  -- Validate using dd
elsif(hookinput.answerid = 6 and ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') is not null
and (ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1') <> ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_1_ORI')
or ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2') <> ihook.getColumnValue(rowform,'CNCPT_CONCAT_STR_2_ORI'))) then
    v_answer := 3; -- create using string
else
    v_answer := 4;  -- create using dd
end if;    

--raise_application_error(-20000, hookinput.answerid || v_answer);
        if v_answer= 1 or v_answer = 3 then  -- Validate using string
            for k in  1..2  loop
                    for i in  1..10 loop
                            ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                            ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                    end loop;
            end loop;
            for k in  1..2  loop -- both OC and Prop
                createValAIWithConcept(rowform , k,4+k,'V','STRING',actions);
            end loop;
        end if;

        if v_answer = 2 or v_answer = 4 then  -- Validate using drop-down
            for k in  1..2  loop -- Both OC and prop
               createValAIWithConcept(rowform , k,4+k,'V','DROP-DOWN',actions);
            end loop;
        end if;

    -- Show generated name
       ihook.setColumnValue(rowform, 'GEN_STR',replace(ihook.getColumnValue(rowform,'ITEM_1_NM') ||  ' ' || ihook.getColumnValue(rowform,'ITEM_2_NM'),'Integer::','') ) ;
       ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'VALIDATED');
   -- ihook.setColumnValue(row,'ITEM_NM', v_nm, 'Integer::',''));

    -- Check if DEC is a duplicate. Removed Context from the test as per Denise.
       v_item_id := -1;

  -- If update, then need to get the Item_id to exclude from duplicate check
       if (lower(v_op) = 'update') then
            row_ori :=  hookInput.originalRowset.rowset(1);
            v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
            v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
       end if;


         if (   ihook.getColumnValue(rowform, 'ITEM_1_ID') is not null and ihook.getColumnValue(rowform, 'ITEM_2_ID') is not null) then
            select cncpt_concat into v_oc_str from nci_admin_item_ext where item_id = ihook.getColumnValue(rowform, 'ITEM_1_ID') and ver_nr= ihook.getColumnValue(rowform, 'ITEM_1_VER_NR');
            select cncpt_concat into v_prop_str from nci_admin_item_ext where item_id = ihook.getColumnValue(rowform, 'ITEM_2_ID') and ver_nr= ihook.getColumnValue(rowform, 'ITEM_2_VER_NR');
            for oc_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_oc_str and ai.admin_item_typ_id = 5) loop
            for prop_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_prop_str and ai.admin_item_typ_id = 6) loop
               for cur in (select de_conc.* from de_conc, admin_item ai where obj_cls_item_id =  oc_cur.item_id and obj_cls_ver_nr =  oc_cur.ver_nr and
               prop_item_id = prop_cur.item_id and prop_ver_nr =  prop_cur.ver_nr and
               cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR') and
              de_conc.item_id = ai.item_id and de_conc.ver_nr = ai.ver_nr and de_conc.item_id <> v_item_id
             ) loop
                    ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'DUPLICATE DEC found:' || cur.item_id || 'v' || cur.ver_nr);
                    is_valid := false;
              end loop;
              end loop;
              end loop;
        end if;

        if (   ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is null or ihook.getColumnValue(rowform, 'CNCPT_2_ITEM_ID_1') is null) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'OC or PROP missing.');
                  is_valid := false;
        end if;

          v_err_str := '';
        nci_11179_2.stdAIValidation(rowai, 2,is_valid, v_err_str );
    --    nci_11179_2.stdCncptRowValidation(rowform, 1,is_valid, v_err_str );
     --   nci_11179_2.stdCncptRowValidation(rowform, 2,is_valid, v_err_str );
        if (v_err_str is not null) then
            ihook.setColumnValue(rowform, 'CTL_VAL_MSG', v_err_Str);
        end if;


         -- If any of the test fails or if the user has triggered validation, then go back to the screen.
        if (is_valid=false or v_answer = 1 or v_answer = 2) then

                hookoutput.message := ihook.getColumnValue(rowform, 'CTL_VAL_MSG');
                ihook.setColumnValue(rowai, 'ITEM_NM', ihook.getColumnValue(rowform, 'GEN_STR'));
       --         ihook.setColumnValue(rowform, 'CNTXT_VER_NR', ihook.getColumnValue(rowai, 'CNTXT_VER_MR'));
                ihook.setColumnValue(rowai, 'ADMIN_ITEM_TYP_ID', 2);

                rows := t_rows();
                rows.extend;
                rows(rows.last) := rowai;
                rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');


                rows := t_rows();
                rows.extend;
                rows(rows.last) := rowform;
                rowsetcncpt := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
                hookOutput.forms := getDECCreateForm(rowset, rowsetcncpt);
                HOOKOUTPUT.QUESTION    := getDECQuestion(v_op, v_src);
        end if;

    -- If all the tests have passed and the user has asked for create, then create DEC and optionally OC and Prop.
    IF v_answer in ( 3,4)  and is_valid = true THEN  -- Create
        createValAIWithConcept(rowform , 1,5,'C','DROP-DOWN',actions); -- OC
        createValAIWithConcept(rowform , 2,6,'C','DROP-DOWN',actions); -- Property

    --If Create DEC
    if (upper(v_op) = 'INSERT') then

        createDEC(rowai, rowform, actions, v_item_id);
        hookoutput.message := 'DEC Created Successfully with ID ' || v_item_id ;
    else
    -- Update DEC. Get the selected row, update name, definition, context.
        row := t_row();
        row_ori :=  hookInput.originalRowset.rowset(1);

        v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');

        --- Update name, definition, context
            row := rowai;

               ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 2);
     ihook.setColumnValue(row, 'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000));
         ihook.setColumnValue(row,'ITEM_NM',  replace(ihook.getColumnValue(rowform, 'ITEM_1_NM')  || ' ' || ihook.getColumnValue(rowform, 'ITEM_2_NM'),'Integer::',''));

    if (ihook.getColumnValue(rowai, 'ITEM_NM_CURATED') is not null) then
        ihook.setColumnValue(row,'ITEM_NM', ihook.getColumnValue(rowai, 'ITEM_NM_CURATED'));
       end if;

            --  ihook.setColumnValue(row, 'ADMIN_STUS_ID', ihook.getColumnValue(rowform,'ADMIN_STUS_ID'));
           -- ihook.setColumnValue(row, 'REGSTR_STUS_ID', ihook.getColumnValue(rowform,'REGSTR_STUS_ID'));
      --      raise_application_error(-20000,  ihook.getColumnValue(rowform,'ITEM_LONG_NM'));
          --  ihook.setColumnValue(row, 'ITEM_LONG_NM', ihook.getColumnValue(rowform,'ITEM_LONG_NM'));
           rows := t_rows();    rows.extend;    rows(rows.last) := row;
             action := t_actionrowset(rows, 'Administered Item', 2,10,'update', hookinput.originalrowset.conceptualObjectName);
            actions.extend;
            actions(actions.last) := action;

           row := t_row();

           -- Get the current DEC row. Update OC, Prop, CD.
            nci_11179.spReturnSubtypeRow (v_item_id, v_ver_nr, 2, row );
            ihook.setColumnValue(row, 'OBJ_CLS_ITEM_ID', ihook.getColumnValue(rowform,'ITEM_1_ID'));
            ihook.setColumnValue(row, 'OBJ_CLS_VER_NR', ihook.getColumnValue(rowform,'ITEM_1_VER_NR'));
            ihook.setColumnValue(row, 'PROP_ITEM_ID', ihook.getColumnValue(rowform,'ITEM_2_ID'));
            ihook.setColumnValue(row, 'PROP_VER_NR', ihook.getColumnValue(rowform,'ITEM_2_VER_NR'));
            ihook.setColumnValue(row, 'CONC_DOM_ITEM_ID', ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID'));
            ihook.setColumnValue(row, 'CONC_DOM_VER_NR', ihook.getColumnValue(rowform,'CONC_DOM_VER_NR'));

             rows := t_rows();    rows.extend;    rows(rows.last) := row;
             action := t_actionrowset(rows, 'Data Element Concept', 2,11,'update',hookinput.originalrowset.conceptualObjectName);
            actions.extend;
            actions(actions.last) := action;
    end if;  -- End update if
    if (actions.count > 0) then
        hookoutput.actions := actions;
    end if;
end if; -- End creation if.
     -- raise_application_error(-20000,'Inside');

end if; -- not first invocation if

END;

--Used in Import  v_op - 'V'  validate, 'C' create
procedure spDECValCreateImport ( rowform in out t_row,  v_op  in varchar2, actions in out t_actions, v_val_ind in out boolean)
AS
  forms t_forms;
  form1 t_form;

  row t_row;
  rows  t_rows;
  row_ori t_row;

  rowset            t_rowset;
  v_oc_item_id number;
  v_oc_ver_nr number;
  v_oc_long_nm varchar2(255);
  v_oc_nm varchar2(255);
  v_prop_nm varchar2(255);
  v_oc_def  varchar2(2000);

  v_prop_item_id number;
  v_prop_ver_nr number;
  v_prop_long_nm varchar2(255);
  v_prop_def  varchar2(2000);
  v_dec_item_id number;
 v_str  varchar2(255);
 v_nm  varchar2(255);
 v_item_id number;
 v_ver_nr number(4,2);
  cnt integer;

  v_msg varchar2(1000);
  i integer := 0;
  v_err  integer;
  column  t_column;
  v_dec_nm varchar2(255);
  v_cncpt_nm varchar2(255);
  v_long_nm varchar2(255);
  v_def varchar2(4000);
  v_oc_id number;
  v_prop_id number;
  v_temp_id  number;
  v_temp_ver number(4,2);
  is_valid boolean;
  v_oc_str varchar2(4000);
v_prop_str varchar2(4000);
begin
    -- Show generated name
    if (ihook.getColumnValue(rowform, 'DE_CONC_ITEM_ID') is null) then --- only execute if not specified
       ihook.setColumnValue(rowform, 'GEN_DE_CONC_NM',ihook.getColumnValue(rowform,'ITEM_1_NM') ||  ' ' || ihook.getColumnValue(rowform,'ITEM_2_NM') ) ;
    -- Check if DEC is a duplicate. Removed Context from the test as per Denise.

        ihook.setColumnValue(rowform, 'DE_CONC_ITEM_ID_FND', '');
        ihook.setColumnValue(rowform, 'DE_CONC_VER_NR_FND', '' );

  if (   ihook.getColumnValue(rowform, 'ITEM_1_ID') is not null and ihook.getColumnValue(rowform, 'ITEM_2_ID') is not null) then
  
            select cncpt_concat into v_oc_str from nci_admin_item_ext where item_id = ihook.getColumnValue(rowform, 'ITEM_1_ID') and ver_nr= ihook.getColumnValue(rowform, 'ITEM_1_VER_NR');
            select cncpt_concat into v_prop_str from nci_admin_item_ext where item_id = ihook.getColumnValue(rowform, 'ITEM_2_ID') and ver_nr= ihook.getColumnValue(rowform, 'ITEM_2_VER_NR');
            for oc_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_oc_str and ai.admin_item_typ_id = 5) loop
            for prop_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_prop_str and ai.admin_item_typ_id = 6) loop
               for cur in (select de_conc.* , ai.cntxt_nm_dn from de_conc, admin_item ai where obj_cls_item_id =  oc_cur.item_id and obj_cls_ver_nr =  oc_cur.ver_nr and
               prop_item_id = prop_cur.item_id and prop_ver_nr =  prop_cur.ver_nr and
               cntxt_item_id = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(rowform, 'CNTXT_VER_NR') and
              de_conc.item_id = ai.item_id and de_conc.ver_nr = ai.ver_nr 
             ) loop
     --    raise_application_error(-20000, 'Here');
                    ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'ERROR: Duplicate DEC found in same context: ' || cur.item_id || 'v' || cur.ver_nr ||  ' '||  cur.cntxt_nm_dn || chr(13));
                    ihook.setColumnValue(rowform, 'DE_CONC_ITEM_ID_FND',  cur.item_id );
                    ihook.setColumnValue(rowform, 'DE_CONC_VER_NR_FND',  cur.ver_nr );
                    
                                      v_val_ind:= false;

              end loop;
              end loop;
              end loop;
              -- warning if in another context
              if (v_val_ind = true) then
                    for oc_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_oc_str and ai.admin_item_typ_id = 5) loop
            for prop_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_prop_str and ai.admin_item_typ_id = 6) loop
               for cur in (select de_conc.*, ai.cntxt_nm_dn from de_conc, admin_item ai where obj_cls_item_id =  oc_cur.item_id and obj_cls_ver_nr =  oc_cur.ver_nr and
               prop_item_id = prop_cur.item_id and prop_ver_nr =  prop_cur.ver_nr and             de_conc.item_id = ai.item_id and de_conc.ver_nr = ai.ver_nr 
             ) loop
     --    raise_application_error(-20000, 'Here');
     --     Jira 1669.3
                    ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'WARNING: Duplicate DEC found in other Context: ' || cur.item_id || 'v' || cur.ver_nr || ' '||  cur.cntxt_nm_dn || chr(13));
                    ihook.setColumnValue(rowform, 'DE_CONC_ITEM_ID_FND',  cur.item_id );
                    ihook.setColumnValue(rowform, 'DE_CONC_VER_NR_FND',  cur.ver_nr );
                                     -- v_val_ind:= false;

              end loop;
              end loop;
              end loop;
                end if;
        end if;
        
     
        if (   ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is null or ihook.getColumnValue(rowform, 'CNCPT_2_ITEM_ID_1') is null) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'ERROR: OC or PROP missing.' || chr(13));
                  v_val_ind:= false;
        end if;

            if (   ihook.getColumnValue(rowform, 'CONC_DOM_ITEM_ID') is null ) then
                ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'ERROR: DEC CD is missing.' || chr(13));
                  v_val_ind:= false;
        end if;

         rows := t_rows();

    IF v_val_ind = true and v_op = 'C'  THEN  -- Create
 --   raise_application_error(-20000, 'here 1');
        createValAIWithConcept(rowform , 1,5,'C','DROP-DOWN',actions); -- OC
        createValAIWithConcept(rowform , 2,6,'C','DROP-DOWN',actions); -- Property
        createDECImport(rowform, actions);

    end if;
end if;
     -- raise_application_error(-20000,'Inside');


END;


--- Used to create VM with no concepts. Can be used for any Admin Item Type where there are no concepts but a string is to be used for comparison.
procedure createAIWithoutConcept(rowform in out t_row, idx in integer, v_item_typ_id in integer, v_long_nm in varchar2, v_desc in varchar2, v_mode in varchar2,  actions in out t_actions) as
v_def  varchar2(4000);
row t_row;
rows t_rows;
 action t_actionRowset;

 v_temp_id  number;
 v_temp_ver number(4,2);
 v_item_id  number;
 v_ver_nr number(4,2);
 v_id integer;

v_obj_nm  varchar2(100);
v_temp varchar2(4000);
begin


if (nvl(v_mode,'C') <> 'O' or v_mode = 'V') then
    for cur in (select ai.item_id, ai.ver_nr from nci_admin_item_ext e, admin_item ai where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr
    and upper(cncpt_concat_nm) = upper(v_long_nm) and ai.admin_item_typ_id = v_item_typ_id) loop
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_ID',cur.item_id);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_VER_NR',cur.ver_nr);
         ihook.setColumnValue(rowform,'CTL_VAL_MSG', 'WARNING: Reusing Existing VM: ' || cur.item_id);
        return;
    end loop;
end if;
if (v_mode = 'V') then
return;
end if;

        v_id := nci_11179.getItemId;
        rows := t_rows();
        row := t_row();

        ihook.setColumnValue(rowform,'CTL_VAL_MSG', 'VM Created: ' || v_id);

     -- to return values to calling program
       ihook.setColumnValue(rowform,'ITEM_' || idx || '_ID', v_id);
       ihook.setColumnValue(rowform,'ITEM_' || idx || '_VER_NR', 1);

        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', v_item_typ_id);
        nci_11179_2.setStdAttr(row);
        nci_11179_2.setItemLongNm (row, v_id);
        ihook.setColumnValue(row,'ITEM_DESC',v_desc);
        ihook.setColumnValue(row,'ITEM_NM', v_long_nm);
          ihook.setColumnValue(row,'CNTXT_ITEM_ID', nvl(ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'),20000000024 ));  --- NCIP
        ihook.setColumnValue(row,'CNTXT_VER_NR', nvl(ihook.getColumnValue(rowform,'CNTXT_VER_NR'),1));
     ihook.setColumnValue(row,'CNCPT_CONCAT', v_long_nm);
        ihook.setColumnValue(row,'CNCPT_CONCAT_DEF',v_long_nm);
        ihook.setColumnValue(row,'CNCPT_CONCAT_NM', v_long_nm);
        ihook.setColumnValue(row,'CNCPT_CONCAT_NM_WITH_INT', v_long_nm);
          ihook.setColumnValue(row,'LST_UPD_DT',sysdate );

        rows.extend;
        rows(rows.last) := row;
    -- raise_application_error(-20000, 'HEre ' || v_nm || v_long_nm || v_def);


        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;


        action := t_actionrowset(rows, 'NCI AI Extension (Hook)', 2,3,'insert');
        actions.extend;
        actions(actions.last) := action;

       case v_item_typ_id
       when 5 then v_obj_nm := 'Object Class';
       when 6 then v_obj_nm := 'Property';
       when 53 then v_obj_nm := 'Value Meaning';
       when 7 then v_obj_nm := 'Representation Class';

        end case;
        action := t_actionrowset(rows, v_obj_nm, 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;

end;

-- v_mode : V - Validate, C - Validation and Create;  v_cncpt_src:  STRING: String; DROP-DOWN: Drop-downs
procedure createValAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer,v_mode in varchar2, v_cncpt_src in varchar2, actions in out t_actions) as
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
 v_long_nm_suf_int  varchar2(255);
 v_long_nm_suf_int_ori  varchar2(255);
 j integer;
i integer;
cnt integer;
z integer;
v_str varchar2(255);
v_obj_nm  varchar2(100);
v_temp varchar2(4000);
v_cncpt_nm varchar2(255);
v_invalid_ind boolean;
v_retired_ind boolean;
v_invalid_concepts  varchar2(4000);
v_retired_concepts  varchar2(4000);
begin

-- If use string to create concept drop-down

             v_nm := '';
                v_long_nm := '';
                v_def := '';
        v_long_nm_suf := '';
                v_long_nm_suf_int := '';

if (v_cncpt_src ='STRING') then
      if (ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_' || idx) is not null) then
                v_str := trim(ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_'|| idx));
                cnt := nci_11179.getwordcount(v_str);

                for i in  1..cnt loop
                        v_cncpt_nm := nci_11179.getWord(v_str, i, cnt);
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, '');
                        v_invalid_ind := false;
                        v_retired_ind := false;
                        for cur in(select item_id, item_nm , item_long_nm, item_desc, admin_stus_nm_dn from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
                        --and admin_item.admin_stus_nm_dn = 'RELEASED') loop
                                if (cur.admin_stus_nm_dn = 'RELEASED') then
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,cur.item_id);
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, 1);
                                    v_long_nm_suf := trim(v_long_nm_suf || ':' || cur.item_long_nm);
                                     v_long_nm_suf_int := trim(v_long_nm_suf_int || ':' || cur.item_long_nm);
                                v_nm := trim(v_nm || ' ' || cur.item_nm);
                                           v_def := substr( v_def || '_' ||cur.item_desc  ,1,4000);
                                           v_invalid_ind := true;
                                else
                                     v_retired_ind := true;
                                end if;
                       end loop;
                       if (v_invalid_ind = false and v_retired_ind = false) then -- not valid concept code
                            v_invalid_concepts := v_invalid_concepts || ' ' || v_cncpt_nm;
                       end if;
                       if (v_invalid_ind = false and v_retired_ind = true) then -- not valid concept code
                            v_retired_concepts := v_retired_concepts || ' ' || v_cncpt_nm;
                       end if;
                       
                end loop;
                for i in  cnt+1..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, '');
                end loop;
            end if;
            -- Jira 1669.7 - separated out invalid and retired concepts; Jira 1669.5 - may need to set v_val_ind to false if there is an invalid or retired concept
            if (v_invalid_concepts is not null) then
            ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') ||  'WARNING: Invalid Concepts: ' ||  nvl(v_invalid_concepts,'') || chr(13));
            end if;
            if (v_retired_concepts is not null) then
            ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'WARNING: Retired Concepts: ' || nvl(v_retired_concepts,'') || chr(13));
            end if;
end if;

-- If drop-downs to be used to check existing or new

if (v_cncpt_src ='DROP-DOWN') then
                for i in 1..10 loop
                        v_temp_id := ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i);
                        v_temp_ver := ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i);
                        if (v_temp_id is not null) then
                        for cur in(select item_id, item_nm , item_long_nm , item_desc from admin_item where admin_item_typ_id = 49 and item_id = v_temp_id and ver_nr = v_temp_ver) loop
                          --       v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                                  v_def := substr( v_def || '_' ||cur.item_desc  ,1,4000);
                              if (cur.item_id = v_int_cncpt_id and trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i) ) is not null) then --- integer concept
                                        v_long_nm_suf_int := trim(v_long_nm_suf_int || ':' || cur.item_long_nm) || '::' || trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i));
                                         v_nm := trim(v_nm || ' ' || cur.item_nm) || '::' ||  trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) ;
                                         v_def := v_def || '::' ||  trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i));
                                else
                                      v_nm := trim(v_nm || ' ' || cur.item_nm);
                                        v_long_nm_suf_int := trim(v_long_nm_suf_int || ':' || cur.item_long_nm);

                                end if;
                                   v_long_nm_suf := trim(v_long_nm_suf || ':' || cur.item_long_nm);


                         end loop;
                        end if;
                end loop;

  end if;

                    ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM', substr(v_long_nm_suf,2));
                     if (v_item_typ_id = 53) then
                            ihook.setColumnValue(rowform,'ITEM_' || idx || '_NM', replace(v_nm, 'Integer::',''));
                    else
                            ihook.setColumnValue(rowform,'ITEM_' || idx || '_NM', v_nm);
                    end if;

           --     ihook.setColumnValue(rowform,'ITEM_' || idx || '_NM', v_nm);
             ihook.setColumnValue(rowform,'ITEM_' || idx || '_DEF', substr(v_def,2));
            ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM_INT', substr(v_long_nm_suf_int,2));

-- Check if combo exists. If it does, then v_item_id will be set.

    CncptCombExistsNew (rowform , substr(v_long_nm_suf_int,2), v_item_typ_id, idx , v_item_id, v_ver_nr);

    -- for VM, set the duplicate section
    if (v_item_typ_id = 53) then
    z := 1;
    for cur in (select ext.* from nci_admin_item_ext ext,admin_item a
                where nvl(a.fld_delete,0) = 0 and a.item_id = ext.item_id and a.ver_nr = ext.ver_nr and cncpt_concat_with_int =substr(v_long_nm_suf_int,2) and a.admin_item_typ_id = v_item_typ_id
                 ) loop
                 ihook.setColumnValue(rowform, 'CNCPT_2_ITEM_ID_' || z,cur.item_id);
                 ihook.setColumnValue(rowform, 'CNCPT_2_VER_NR_' || z,cur.ver_nr);
                        z := z+ 1;
                   end loop;
        end if;

-- If not existing and mode is Create, then create the actions.

    if ((v_mode = 'C' AND V_ITEM_ID  is null) or (v_mode = 'O'))  then --- Create; O is override. Create a duplicate
        v_id := nci_11179.getItemId;
     --   raise_application_error(-20000, v_long_nm_suf_int);
        rows := t_rows();
        j := 0;
    --    v_nm := '';
     --   v_long_nm := '';
      --  v_def := '';
        for i in reverse 0..10 loop
            v_cncpt_id := ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i);
             v_cncpt_ver_nr :=  ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i);
            if( v_cncpt_id is not null) then
                for cur in (select item_nm, item_long_nm, item_desc from admin_item where item_id = v_cncpt_id and ver_nr = v_cncpt_ver_nr) loop
                        row := t_row();
                        ihook.setColumnValue(row,'ITEM_ID', v_id);
                        ihook.setColumnValue(row,'VER_NR', 1);
                        ihook.setColumnValue(row,'CNCPT_ITEM_ID',v_cncpt_id);
                        ihook.setColumnValue(row,'CNCPT_VER_NR', v_cncpt_ver_nr);
                        ihook.setColumnValue(row,'NCI_ORD', j);
                        v_temp := v_temp || i || ':' ||  v_cncpt_id;

                        if j = 0 then
                            ihook.setColumnValue(row,'NCI_PRMRY_IND', 1);
                        else ihook.setColumnValue(row,'NCI_PRMRY_IND', 0);
                        end if;
                         if (v_cncpt_id = v_int_cncpt_id and trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) is not null) then
                       --     v_nm := trim(cur.item_nm) ||  '::' || trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) || ' ' || v_nm ;
                            ihook.setColumnValue(row,'NCI_CNCPT_VAL',ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i));
                      --      v_def := substr(cur.item_desc || '::' || trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) || '_' || v_def,1,4000);
                                           v_long_nm := trim(v_long_nm || ':' || cur.item_long_nm) || '::' || trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i));
                   --   else
                        --    v_nm := trim(cur.item_nm) || ' ' || v_nm ;
                        --            v_def := substr( cur.item_desc || '_' || v_def,1,4000);
                         --              v_long_nm := trim(v_long_nm || ':' || cur.item_long_nm);
                         end if;
                        rows.extend;
                        rows(rows.last) := row;


                         j := j+ 1;
                end loop;
            end if;
        end loop;

        -- Insert into CNCPT_ADMIN_ITEM
       action := t_actionrowset(rows, 'Items under Concept (Hook)', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;

        rows := t_rows();
        --row := rowform;
        row := t_row();
        v_long_nm := substr(v_long_nm,2);
        v_nm := substr(trim(v_nm),1, c_nm_len);

        -- if lenght of short name is greater than 30, then use IDv1.00
        v_long_nm_suf_int_ori := v_long_nm_suf_int;
        if (length(v_long_nm_suf_int) > 30) then
            v_long_nm_suf_int := '1' || v_id || c_ver_suffix;  -- putting dummy 1 as later we are doing a sub-string
        end if;

    -- Administered Item Row
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', v_item_typ_id);
        nci_11179_2.setStdAttr(row);
        ihook.setColumnValue(row,'ITEM_LONG_NM', substr(v_long_nm_suf_int,2));
        ihook.setColumnValue(row,'ITEM_DESC', substr(v_def, 2));
     --   ihook.setColumnValue(row,'ITEM_DESC', v_def);
       if (v_item_typ_id = 53) then
        v_nm := replace(v_nm, 'Integer::', '');
       end if;
        ihook.setColumnValue(row,'ITEM_NM', v_nm);
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', nvl(ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'),20000000024 ));  --- NCIP
        ihook.setColumnValue(row,'CNTXT_VER_NR', nvl(ihook.getColumnValue(rowform,'CNTXT_VER_NR'),1));
        ihook.setColumnValue(row,'CNCPT_CONCAT', substr(v_long_nm_suf,2));
       ihook.setColumnValue(row,'CNCPT_CONCAT_DEF', substr(v_def, 1, length(v_def)-1));
       -- ihook.setColumnValue(row,'CNCPT_CONCAT_DEF', v_def);
        ihook.setColumnValue(row,'CNCPT_CONCAT_NM', v_nm);
        ihook.setColumnValue(row,'CNCPT_CONCAT_WITH_INT', substr(v_long_nm_suf_int_ori,2));
        ihook.setColumnValue(row,'LST_UPD_DT',sysdate );

        rows.extend;
        rows(rows.last) := row;

        -- Update form Name/Long Name/Definition so uer can see.
       ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM', v_long_nm);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_DEF', substr(v_def, 2));
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_NM', v_nm);
        ihook.setColumnValue(rowform, 'ITEM_' || idx || '_ID', v_id);
         ihook.setColumnValue(rowform, 'ITEM_' || idx || '_VER_NR', 1);

        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;

      action := t_actionrowset(rows, 'NCI AI Extension (Hook)', 2,3,'insert');
        actions.extend;
        actions(actions.last) := action;

       case v_item_typ_id
            when 5 then v_obj_nm := 'Object Class';
            when 6 then v_obj_nm := 'Property';
            when 53 then v_obj_nm := 'Value Meaning';
            when 7 then v_obj_nm := 'Representation Class';
        end case;
        action := t_actionrowset(rows, v_obj_nm, 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
end if;

end;

procedure CncptCombExistsNew (rowform in out t_row, v_item_nm in varchar2, v_item_typ in integer, v_idx in number, v_item_id out number, v_item_ver_nr out number)
as
v_out integer;
v_long_nm  varchar2(30);
v_nm varchar2(255);
v_def varchar2(4000);

begin

            ihook.setColumnValue(rowform, 'ITEM_' || v_idx  ||'_ID','');
                ihook.setColumnValue(rowform, 'ITEM_' || v_idx || '_VER_NR', '');

    for cur in (select ext.* from nci_admin_item_ext ext,admin_item a
    where nvl(a.fld_delete,0) = 0 and a.item_id = ext.item_id and a.ver_nr = ext.ver_nr and cncpt_concat_with_int = v_item_nm and a.admin_item_typ_id = v_item_typ) loop
                 ihook.setColumnValue(rowform, 'ITEM_' || v_idx  ||'_ID',cur.item_id);
                 v_item_id := cur.item_id;
                 v_item_ver_nr := cur.ver_nr;
                ihook.setColumnValue(rowform, 'ITEM_' || v_idx || '_VER_NR', cur.ver_nr);
                ihook.setColumnValue(rowform,'ITEM_' || v_idx || '_LONG_NM', cur.cncpt_concat);
                ihook.setColumnValue(rowform,'ITEM_' || v_idx || '_DEF',  cur.CNCPT_CONCAT_DEF);
                ihook.setColumnValue(rowform,'ITEM_' || v_idx || '_NM', cur.CNCPT_CONCAT_NM);

    end loop;
 --   if (v_item_typ = 6) then
  --raise_application_error(-20000, v_item_nm || '  ' || v_item_id);

--end if;
end;


function getDECQuestion (v_op in varchar2, v_src in integer) return t_question
is
  question t_question;
begin
    if (upper(v_op) = 'INSERT') then
        question := getDECCreateQuestion(v_src);
    else
        question := getDECEditQuestion();
    end if;
return question;
end;

function getDECEditQuestion return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin
--- If Edit DEC
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(5, 5, 'Validate');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    ANSWER                     := T_ANSWER(6, 6, 'Update');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Edit DEC', ANSWERS);

return question;
end;

function getDECEditQuestionReleased return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin
--- If Edit DEC
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(10, 10, 'Proceed with Edit');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Edit DEC', ANSWERS);

return question;
end;
function getDECCreateQuestion (v_src in integer) return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin
-- IF create or Create from Existing DEC
 ANSWERS                    := T_ANSWERS();
  --  ANSWER                     := T_ANSWER(1, 1, 'Validate Using String');
   -- ANSWERS.EXTEND;
  --  ANSWERS(ANSWERS.LAST) := ANSWER;
  --  ANSWERS                    := T_ANSWERS();
   -- ANSWER                     := T_ANSWER(2, 2, 'Validate Using Drop-Down');
  --  ANSWERS.EXTEND;
  --  ANSWERS(ANSWERS.LAST) := ANSWER;
  --  ANSWER                     := T_ANSWER(3, 3, 'Create Using String');
   -- ANSWERS.EXTEND;
   -- ANSWERS(ANSWERS.LAST) := ANSWER;
   -- ANSWER                     := T_ANSWER(4, 4, 'Create Using Drop-Down');
  --  ANSWERS.EXTEND;
    ANSWER                     := T_ANSWER(5, 5, 'Validate');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
   -- ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(6, 6, 'Create');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
  
  
    ANSWERS(ANSWERS.LAST) := ANSWER;
    if (v_src = 1) then -- Create new
    QUESTION               := T_QUESTION('Create New DEC', ANSWERS);
    else
    QUESTION               := T_QUESTION('Create DEC from Existing', ANSWERS);
    end if;

return question;
end;



procedure createDEC (rowai in t_row, rowform in t_row, actions in out t_actions, v_id out  number) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
row t_row;
rows t_rows;
 action t_actionRowset;
 --v_id number;
begin
   rows := t_rows();
   row := rowai;
     v_id := nci_11179.getItemId;
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 2);
   /*     v_long_nm := trim(ihook.getColumnValue(rowform, 'ITEM_1_LONG_NM_INT')  || ' ' || ihook.getColumnValue(rowform, 'ITEM_2_LONG_NM_INT'));
       if (    trim(ihook.getColumnValue(rowai, 'ITEM_LONG_NM')) = v_dflt_txt and length(v_long_nm) <= 30 ) then
       ihook.setColumnValue(row,'ITEM_LONG_NM', v_long_nm);
       elsif  (upper(trim(ihook.getColumnValue(rowai, 'ITEM_LONG_NM')))='SYSGEN' or (  trim(ihook.getColumnValue(rowai, 'ITEM_LONG_NM')) = v_dflt_txt and length(v_long_nm) > 30) ) then
            ihook.setColumnValue(row,'ITEM_LONG_NM', v_id || c_ver_suffix);
        else
            ihook.setColumnValue(row,'ITEM_LONG_NM', ihook.getColumnValue(rowai, 'ITEM_LONG_NM'));
        end if;
        */
       if (    trim(ihook.getColumnValue(rowai, 'ITEM_LONG_NM')) = v_dflt_txt or upper(trim(ihook.getColumnValue(rowai, 'ITEM_LONG_NM')))='SYSGEN'  ) then
            ihook.setColumnValue(row,'ITEM_LONG_NM', nci_11179_2.getStdShortName(ihook.getColumnValue(rowform,'ITEM_1_ID'), ihook.getColumnValue(rowform,'ITEM_1_VER_NR')) || ':' ||
          nci_11179_2.getStdShortName(ihook.getColumnValue(rowform,'ITEM_2_ID'), ihook.getColumnValue(rowform,'ITEM_2_VER_NR')))  ;
        else
            ihook.setColumnValue(row,'ITEM_LONG_NM', ihook.getColumnValue(rowai, 'ITEM_LONG_NM'));
        end if;

       --     raise_application_error(-20000, ihook.getColumnValue(row,'ITEM_LONG_NM') || length(v_long_nm));
        ihook.setColumnValue(row,'ITEM_NM',  replace(ihook.getColumnValue(rowform, 'ITEM_1_NM')  || ' ' || ihook.getColumnValue(rowform, 'ITEM_2_NM'),'Integer::',''));

       -- use manually curated name if not null
       if (ihook.getColumnValue(rowai, 'ITEM_NM_CURATED') is not null) then
        ihook.setColumnValue(row,'ITEM_NM', ihook.getColumnValue(rowai, 'ITEM_NM_CURATED'));
       end if;

        --ihook.setColumnValue(row,'ITEM_NM',  replace(ihook.getColumnValue(rowai, 'ITEM_NM') ,'Integer::',''));
        ihook.setColumnValue(row,'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000));

        -- replace INTEGER :: from name
      --  v_nm := ihook.getColumnValue(row,'ITEM_NM');
      -- ihook.setColumnValue(row,'ITEM_NM', replace(v_nm, 'Integer::',''));
       ihook.setColumnValue(row,'CONC_DOM_ITEM_ID',nvl(ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID'),1) );
        ihook.setColumnValue(row,'CONC_DOM_VER_NR',nvl(ihook.getColumnValue(rowform,'CONC_DOM_VER_NR'),1) );
        ihook.setColumnValue(row,'OBJ_CLS_ITEM_ID',nvl(ihook.getColumnValue(rowform, 'ITEM_1_ID'),1) );
        ihook.setColumnValue(row,'OBJ_CLS_VER_NR',nvl(ihook.getColumnValue(rowform, 'ITEM_1_VER_NR'),1) );
        ihook.setColumnValue(row,'PROP_ITEM_ID',nvl(ihook.getColumnValue(rowform, 'ITEM_2_ID'),1));
        ihook.setColumnValue(row,'PROP_VER_NR',nvl(ihook.getColumnValue(rowform, 'ITEM_2_VER_NR'),1));
        ihook.setColumnValue(row,'LST_UPD_DT',sysdate );
        rows.extend;
        rows(rows.last) := row;

        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,7,'insert');
        actions.extend;
        actions(actions.last) := action;

      action := t_actionrowset(rows, 'Data Element Concept', 2,8,'insert');
       actions.extend;
        actions(actions.last) := action;


end;


procedure createDECImport (rowform in out t_row, actions in out t_actions) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
v_short_nm varchar2(30);
row t_row;
rows t_rows;
 action t_actionRowset;
 v_id number;
begin
   rows := t_rows();
   row := t_row();
     v_id := nci_11179.getItemId;
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(rowform,'DE_CONC_ITEM_ID_CREAT', v_id);
        ihook.setColumnValue(rowform,'DE_CONC_VER_NR_CREAT',1);

      --  raise_application_error (-20000, ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID')  || ihook.getColumnValue(rowform, 'ITEM_1_ID') || ihook.getColumnValue(rowform, 'ITEM_2_ID'));
        ihook.setColumnValue(row,'VER_NR', 1);

        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 2);
            
            
            --ihook.setColumnValue(row,'ITEM_LONG_NM', nvl(ihook.getColumnValue(rowform,'DEC_ITEM_LONG_NM'),v_id || c_ver_suffix));
            if (trim(ihook.getColumnValue(rowform,'DEC_ITEM_LONG_NM')) is null or upper(ihook.getColumnValue(rowform,'DEC_ITEM_LONG_NM')) = 'SYSGEN') then
             v_short_nm := nci_11179_2.getStdShortName(ihook.getColumnValue(rowform, 'ITEM_1_ID'), ihook.getColumnValue(rowform, 'ITEM_1_VER_NR')) || ':' ||
             nci_11179_2.getStdShortName(ihook.getColumnValue(rowform, 'ITEM_2_ID'), ihook.getColumnValue(rowform, 'ITEM_2_VER_NR'));
            else
                v_short_nm := ihook.getColumnValue(rowform,'DEC_ITEM_LONG_NM');
            end if;
         ihook.setColumnValue(row,'ITEM_LONG_NM', v_short_nm);

        ihook.setColumnValue(row,'ITEM_NM',  nvl(ihook.getColumnValue(rowform,'DEC_ITEM_NM'), ihook.getColumnValue(rowform, 'GEN_DE_CONC_NM')));
        ihook.setColumnValue(row,'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000));
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'ADMIN_STUS_ID',66);
         ihook.setColumnValue(row,'REGSTR_STUS_ID',9);
       ihook.setColumnValue(row,'CONC_DOM_ITEM_ID',nvl(ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID'),1) );
        ihook.setColumnValue(row,'CONC_DOM_VER_NR',nvl(ihook.getColumnValue(rowform,'CONC_DOM_VER_NR'),1) );
        ihook.setColumnValue(row,'OBJ_CLS_ITEM_ID',nvl(ihook.getColumnValue(rowform, 'ITEM_1_ID'),1) );
        ihook.setColumnValue(row,'OBJ_CLS_VER_NR',nvl(ihook.getColumnValue(rowform, 'ITEM_1_VER_NR'),1) );
        ihook.setColumnValue(row,'PROP_ITEM_ID',nvl(ihook.getColumnValue(rowform, 'ITEM_2_ID'),1));
        ihook.setColumnValue(row,'PROP_VER_NR',nvl(ihook.getColumnValue(rowform, 'ITEM_2_VER_NR'),1));
        ihook.setColumnValue(row,'LST_UPD_DT',sysdate );
        rows.extend;
        rows(rows.last) := row;
--raise_application_error(-20000, 'Deep' || ihook.getColumnValue(row,'CNTXT_ITEM_ID') || 'ggg'|| ihook.getColumnValue(row,'ADMIN_STUS_ID') || 'GGGG' || ihook.getColumnValue(row,'ITEM_ID'));

        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,7,'insert');
        actions.extend;
        actions(actions.last) := action;

      action := t_actionrowset(rows, 'Data Element Concept', 2,8,'insert');
       actions.extend;
        actions(actions.last) := action;
        --Jira 1669.2
 ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || chr(13) || 'DEC Created Successfully.' || chr(13)) ;
  --ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'DEC Created Successfully with ID ' || v_id||c_ver_suffix || chr(13)) ;
ihook.setColumnValue(rowform, 'CTL_VAL_STUS', 'PROCESSED') ;

--r
end;
-- Create form for DEC.
function getDECCreateForm (v_rowset1 in t_rowset,v_rowset2 in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    forms                  := t_forms();
    form1                  := t_form('Administered Item (DEC Create)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    form1                  := t_form('DEC Create Edit (Hook)', 2,1);
    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;

END;
/
