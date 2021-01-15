--------------------------------------------------------
--  File created - Friday-January-15-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body NCI_CHNG_MGMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "ONEDATA_WA"."NCI_CHNG_MGMT" AS

v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
type       t_orgs is table of org_cntct.org_id%type;
type t_cncpt_id is table of admin_item.item_id%type;
v_t_cncpt_id  t_cncpt_id := t_cncpt_id();


function getDECCreateQuestion return t_question is
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
    QUESTION               := T_QUESTION('Create new DEC.', ANSWERS);

return question;
end;

function getVDCreateQuestion return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();

    ANSWER                     := T_ANSWER(1, 1, 'Create VD');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;

    QUESTION               := T_QUESTION('Create new VD.', ANSWERS);

return question;
end;

function getDECCreateForm (v_rowset in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('AI Creation With Concepts', 2,1);
    form1.rowset :=v_rowset;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;


function getDECreateQuestion return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Create CDE');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Create new CDE.', ANSWERS);

return question;
end;

function getDECreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('Administered Item (Data Element CO)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    form1                  := t_form('Data Element(hook creation)', 2,1);

    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;


function getVDCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('Administered Item (Data Element CO)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    form1                  := t_form('Value Domain', 2,1);

    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;

procedure createAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer, actions in out t_actions) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
row t_row;
rows t_rows;
 action t_actionRowset;
 v_cncpt_id  number;
 v_cncpt_ver_nr number(4,2);
 v_id integer;
 j integer;
i integer;
v_obj_nm  varchar2(100);
v_temp varchar2(4000);
begin
        v_id := nci_11179.getItemId;

       rows := t_rows();
   --     raise_application_error(-20000,'OC');
       v_nm := '';
       v_long_nm := '';
       v_def := '';
          j := 0;
          for i in reverse 0..10 loop

     --  raise_application_error(-20000, 'Test'  ||ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || 4));

          v_cncpt_id := ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i);
             v_cncpt_ver_nr :=  ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i);
          if( v_cncpt_id is not null) then
    --   raise_application_error(-20000, 'Test'  || i || v_cncpt_id);
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
            rows.extend;
            rows(rows.last) := row;
            v_nm := trim(cur.item_nm) || ' ' || v_nm ;
            v_long_nm := cur.item_long_nm || ':' || v_long_nm   ;
            v_def := substr( cur.item_desc || ' ' || v_def,1,4000);

            j := j+ 1;
        end loop;
        end if;
        end loop;
       action := t_actionrowset(rows, 'CNCPT_ADMIN_ITEM', 1,6,'insert');
        actions.extend;
        actions(actions.last) := action;

        rows := t_rows();
        row := t_row();
    -- raise_application_error (-20000, v_nm || '$$$' || v_long_nm);
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', v_item_typ_id);
        ihook.setColumnValue(row,'ADMIN_STUS_ID',66 );
        ihook.setColumnValue(row,'ITEM_LONG_NM', substr(v_long_nm,1, length(v_long_nm)-1));
        ihook.setColumnValue(row,'ITEM_DESC', v_def);
        ihook.setColumnValue(row,'ITEM_NM', trim(v_nm));
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        rows.extend;
        rows(rows.last) := row;
    -- raise_application_error(-20000, 'HEre ' || v_nm || v_long_nm || v_def);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM', substr(v_long_nm,1, length(v_long_nm)-1));
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_DEF', v_def);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_NM', trim(v_nm));
        ihook.setColumnValue(rowform, 'ITEM_' || idx || '_ID', v_id);
         ihook.setColumnValue(rowform, 'ITEM_' || idx || '_VER_NR', 1);

        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;

       case v_item_typ_id
       when 5 then v_obj_nm := 'Object Class';
       when 6 then v_obj_nm := 'Property';
        end case;
        action := t_actionrowset(rows, v_obj_nm, 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;


end;


procedure createDEC (rowform in t_row, actions in out t_actions, v_id out  number) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
row t_row;
rows t_rows;
 action t_actionRowset;
 --v_id number;
begin
   rows := t_rows();
   row := t_row();
     v_id := nci_11179.getItemId;
        ihook.setColumnValue(row,'ITEM_ID', v_id);
      --  raise_application_error (-20000, ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID')  || ihook.getColumnValue(rowform, 'ITEM_1_ID') || ihook.getColumnValue(rowform, 'ITEM_2_ID'));
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 2);
   --     ihook.setColumnValue(row,'ITEM_LONG_NM', ihook.getColumnValue(rowform, 'ITEM_1_LONG_NM')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_LONG_NM'));
        ihook.setColumnValue(row,'ITEM_LONG_NM', v_id || 'v1.0');
        ihook.setColumnValue(row,'ITEM_NM',  ihook.getColumnValue(rowform, 'ITEM_1_NM')  || ' ' || ihook.getColumnValue(rowform, 'ITEM_2_NM'));
        ihook.setColumnValue(row,'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000));
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'ADMIN_STUS_ID',66);
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

--r
end;

procedure createDE (rowform in t_row, actions in out t_actions, v_id out  number) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
row t_row;
rows t_rows;
 action t_actionRowset;
 --v_id number;
begin
   rows := t_rows();
   row := t_row();
     v_id := nci_11179.getItemId;
        ihook.setColumnValue(row,'ITEM_ID', v_id);
      --  raise_application_error (-20000, ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID')  || ihook.getColumnValue(rowform, 'ITEM_1_ID') || ihook.getColumnValue(rowform, 'ITEM_2_ID'));
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 2);
   --     ihook.setColumnValue(row,'ITEM_LONG_NM', ihook.getColumnValue(rowform, 'ITEM_1_LONG_NM')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_LONG_NM'));
        ihook.setColumnValue(row,'ITEM_LONG_NM', v_id || 'v1.0');
        ihook.setColumnValue(row,'ITEM_NM',  ihook.getColumnValue(rowform, 'ITEM_1_NM')  || ' ' || ihook.getColumnValue(rowform, 'ITEM_2_NM'));
        ihook.setColumnValue(row,'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000));
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'ADMIN_STUS_ID',66);
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

--r
end;

PROCEDURE spDEPrefQuestPost
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_add integer :=0;
  v_action_typ varchar2(30);
  v_item_id  number;
  v_ver_nr  number(4,2);
  v_nm_id number;
  v_cntxt_id number;
  v_cntxt_ver_nr number(4,2);
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();

    row_ori := hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');

    if (ihook.getColumnValue(row_ori, 'PREF_QUEST_TXT') is not null) then
    select cntxt_item_id, cntxt_ver_nr into v_cntxt_id, v_cntxt_ver_nr from admin_item where item_id = v_item_id and ver_nr = v_ver_nr;

        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID', v_item_id);
    ihook.setColumnValue(row,'VER_NR', v_ver_nr);
     ihook.setColumnValue(row,'REF_NM', substr(ihook.getColumnValue(row_ori, 'PREF_QUEST_TXT'),1,255));
     ihook.setColumnValue(row,'REF_DESC', ihook.getColumnValue(row_ori, 'PREF_QUEST_TXT'));
     ihook.setColumnValue(row,'LANG_ID', 1000);
     ihook.setColumnValue(row,'NCI_CNTXT_ITEM_ID',v_cntxt_id );
     ihook.setColumnValue(row,'NCI_CNTXT_VER_NR', v_cntxt_ver_nr );
     ihook.setColumnValue(row,'REF_TYP_ID', 80);

     ihook.setColumnValue(row,'REF_ID', -1);
     v_action_typ := 'insert';
     for cur in (select REF_id from  REF where item_id = v_item_id and ver_nr = v_ver_nr and ref_typ_id = 80) loop
     ihook.setColumnValue(row,'REF_ID', cur.ref_id);
     v_action_typ := 'update';

     end loop;

     rows.extend;
    rows(rows.last) := row;
    action := t_actionrowset(rows, 'References (for Edit)', 2,0,v_action_typ);
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;

    end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spClassificationNMDef ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2, v_typ in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_obj  varchar2(100);
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
forms     t_forms;
formGroup    t_form;
form1  t_form;
rowform t_row;
v_itemid     ADMIN_ITEM.ITEM_ID%TYPE;
v_vernr  ADMIN_ITEM.VER_NR%TYPE;
v_tbl_nm  varchar2(255);
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  v_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_itemid := ihook.getColumnValue(row_ori, 'ITEM_ID');
  v_VERNR := ihook.getColumnValue(row_ori, 'VER_NR');
    if (v_typ = 'DESIGNATION') then
         v_id := ihook.getColumnValue(row_ori, 'NM_ID');
         v_obj := 'Classification level Name/Definition';
    else
         v_id := ihook.getColumnValue(row_ori, 'DEF_ID');
         v_obj := 'Classification level Definition';
   end if;
    rows := t_rows();


    if hookInput.invocationNumber = 0  then

    rows := t_rows();
        for cur in (select NCI_PUB_ID, NCI_VER_NR from NCI_ADMIN_ITEM_REL_ALT_KEY where (CNTXT_CS_ITEM_ID, CNTXT_CS_VER_NR) in ( select item_id, ver_nr from admin_item ai, onedata_md.vw_usr_row_filter v
        where nvl(ai.fld_delete,0)= 0  and ai.cntxt_item_id = v.CNTXT_ITEM_ID and ai.CNTXT_VER_NR = v.cntxt_VER_NR and ai.admin_item_typ_id = 9 and  upper(v.USR_ID) = upper(v_usr_id) and v.ACTION_TYP = 'I') )loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'NCI_PUB_ID', cur.NCI_PUB_ID);
		   iHook.setcolumnvalue (ROW, 'NCI_VER_NR', cur.NCI_VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
      	   v_found := true;
	    end loop;

        if (v_found) then
             showrowset := t_showablerowset (rows, 'CSI Node', 2, 'single');
            hookoutput.showrowset := showrowset;
       	 answers := t_answers();
        answer := t_answer(1, 1, 'Add Classification');
        answers.extend;          answers(answers.last) := answer;
        answer := t_answer(2, 2, 'Delete Classification');
        answers.extend;          answers(answers.last) := answer;

	   	 question := t_question('Choose Option', answers);
       	 hookOutput.question := question;
        else
            hookoutput.message := 'No classification scheme found in your authorized context.';
         end if;

    end if;

  	if hookInput.invocationNumber = 1 then
      rows := t_rows();
      if (hookinput.answerid = 1) then --- add
      row_sel := hookInput.selectedRowset.rowset(1);
            row := t_row();
            select count(*) into v_temp from NCI_CSI_ALT_DEFNMS where NMDEF_id = v_id
            and NCI_VER_NR = ihook.getColumnValue(row_sel,'NCI_VER_NR') and NCI_PUB_ID = ihook.getColumnValue(row_sel,'NCI_PUB_ID') ;
            if (v_temp = 0) then
            ihook.setcolumnvalue(row,'NCI_VER_NR', ihook.getColumnValue(row_sel,'NCI_VER_NR'));
            ihook.setcolumnvalue(row,'NCI_PUB_ID', ihook.getColumnValue(row_sel,'NCI_PUB_ID'));
            ihook.setcolumnvalue(row,'NMDEF_ID', v_id);
            ihook.setcolumnvalue(row,'TYP_NM', v_typ);
            rows.extend;
            rows(rows.last) := row;
            end if;

        action := t_actionrowset(rows, v_obj, 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
  --     raise_application_error(-20000,v_typ || '!' ||  v_id || '!' ||  ihook.getColumnValue(row_sel,'NCI_PUB_ID'));
     end if;
      if (hookinput.answerid = 2 ) then --- delete
      row_sel := hookInput.selectedRowset.rowset(1);
            row := t_row();
            select count(*) into v_temp from NCI_CSI_ALT_DEFNMS where NMDEF_id = v_id
            and NCI_VER_NR = ihook.getColumnValue(row_sel,'NCI_VER_NR') and NCI_PUB_ID = ihook.getColumnValue(row_sel,'NCI_PUB_ID') ;
            if (v_temp = 1) then
            ihook.setcolumnvalue(row,'NCI_VER_NR', ihook.getColumnValue(row_sel,'NCI_VER_NR'));
            ihook.setcolumnvalue(row,'NCI_PUB_ID', ihook.getColumnValue(row_sel,'NCI_PUB_ID'));
            ihook.setcolumnvalue(row,'NMDEF_ID', v_id);
            ihook.setcolumnvalue(row,'TYP_NM', v_typ);
            rows.extend;
            rows(rows.last) := row;
            end if;

       action := t_actionrowset(rows, v_obj, 2,2,'delete');
        actions.extend;
        actions(actions.last) := action;
       action := t_actionrowset(rows, v_obj, 2,3,'purge');
        actions.extend;
        actions(actions.last) := action;
      end if;
      hookoutput.actions := actions;
  end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spClassification
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
form1  t_form;
rowform t_row;
v_itemid     ADMIN_ITEM.ITEM_ID%TYPE;
v_vernr  ADMIN_ITEM.VER_NR%TYPE;
v_tbl_nm  varchar2(255);
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_itemid := ihook.getColumnValue(row_ori, 'ITEM_ID');
  v_VERNR := ihook.getColumnValue(row_ori, 'VER_NR');

    rows := t_rows();


    if hookInput.invocationNumber = 0  then

    rows := t_rows();
        for cur in (select NCI_PUB_ID, NCI_VER_NR from NCI_ADMIN_ITEM_REL_ALT_KEY where (CNTXT_CS_ITEM_ID, CNTXT_CS_VER_NR) in ( select item_id, ver_nr from admin_item ai, onedata_md.vw_usr_row_filter v
        where nvl(ai.fld_delete,0)= 0  and ai.cntxt_item_id = v.CNTXT_ITEM_ID and ai.CNTXT_VER_NR = v.cntxt_VER_NR and ai.admin_item_typ_id = 9 and  upper(v.USR_ID) = upper(v_usr_id) and v.ACTION_TYP = 'I') )loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'NCI_PUB_ID', cur.NCI_PUB_ID);
		   iHook.setcolumnvalue (ROW, 'NCI_VER_NR', cur.NCI_VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
      	   v_found := true;
	    end loop;

        if (v_found) then
             showrowset := t_showablerowset (rows, 'CSI Node', 2, 'single');
            hookoutput.showrowset := showrowset;
       	 answers := t_answers();
        answer := t_answer(1, 1, 'Add Classification');
        answers.extend;          answers(answers.last) := answer;
        answer := t_answer(2, 2, 'Delete Classification');
        answers.extend;          answers(answers.last) := answer;

	   	 question := t_question('Choose Option', answers);
       	 hookOutput.question := question;
        else
            hookoutput.message := 'No classification scheme found in your authorized context.';
         end if;
    end if;

   if hookInput.invocationNumber = 1  then

        row_sel := hookInput.selectedRowset.rowset(1);

     if (hookinput.answerid = 1) then --- add
      for i in 1..hookinput.originalrowset.rowset.count loop
            row := t_row();
            row_ori := hookInput.originalRowset.rowset(i);
            select count(*) into v_temp from NCI_ALT_KEY_ADMIN_ITEM_REL where c_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and c_item_ver_nr = ihook.getColumnValue(row_ori,'VER_NR')
            and NCI_VER_NR = ihook.getColumnValue(row_sel,'NCI_VER_NR') and NCI_PUB_ID = ihook.getColumnValue(row_sel,'NCI_PUB_ID') and rel_typ_id = 65;
            if (v_temp = 0) then
            ihook.setcolumnvalue(row,'C_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
            ihook.setcolumnvalue(row,'C_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
            ihook.setcolumnvalue(row,'NCI_VER_NR', ihook.getColumnValue(row_sel,'NCI_VER_NR'));
            ihook.setcolumnvalue(row,'NCI_PUB_ID', ihook.getColumnValue(row_sel,'NCI_PUB_ID'));
            ihook.setcolumnvalue(row,'REL_TYP_ID', 65);
            rows.extend;
            rows(rows.last) := row;
            end if;
   end loop;
   v_tbl_nm := 'Classifications (Insert)';

        action := t_actionrowset(rows, v_tbl_nm, 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;
     end if;

     if hookInput.answerId =2  then -- Delete
        v_found := false;
        row := t_row();
        rows := t_rows();
      for i in 1..hookinput.originalrowset.rowset.count loop
            row := t_row();
            row_ori := hookInput.originalRowset.rowset(i);
            select count(*) into v_temp from NCI_ALT_KEY_ADMIN_ITEM_REL where c_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and c_item_ver_nr = ihook.getColumnValue(row_ori,'VER_NR')
            and NCI_VER_NR = ihook.getColumnValue(row_sel,'NCI_VER_NR') and NCI_PUB_ID = ihook.getColumnValue(row_sel,'NCI_PUB_ID') and rel_typ_id = 65;
            if (v_temp = 1) then
            ihook.setcolumnvalue(row,'C_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
            ihook.setcolumnvalue(row,'C_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
            ihook.setcolumnvalue(row,'NCI_VER_NR', ihook.getColumnValue(row_sel,'NCI_VER_NR'));
            ihook.setcolumnvalue(row,'NCI_PUB_ID', ihook.getColumnValue(row_sel,'NCI_PUB_ID'));
            ihook.setcolumnvalue(row,'REL_TYP_ID', 65);
            rows.extend;
            rows(rows.last) := row;
            end if;
   end loop;
   v_tbl_nm := 'Classifications (Insert)';

       action := t_actionrowset(rows, v_tbl_nm, 2,2,'delete');
        actions.extend;
        actions(actions.last) := action;
       action := t_actionrowset(rows, v_tbl_nm, 2,3,'purge');
        actions.extend;
        actions(actions.last) := action;
      end if;
      hookoutput.actions := actions;
  end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spDesignateNew
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
form1  t_form;
rowform t_row;
v_itemid     ADMIN_ITEM.ITEM_ID%TYPE;
v_vernr  ADMIN_ITEM.VER_NR%TYPE;
v_tbl_nm  varchar2(255);
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_itemid := ihook.getColumnValue(row_ori, 'ITEM_ID');
  v_VERNR := ihook.getColumnValue(row_ori, 'VER_NR');

    rows := t_rows();


    if hookInput.invocationNumber = 0  then

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Add Names');
        answers.extend;          answers(answers.last) := answer;
        answer := t_answer(4, 4, 'Delete Names');
        answers.extend;          answers(answers.last) := answer;
        answer := t_answer(2, 2, 'Add Ref Doc');
        answers.extend;          answers(answers.last) := answer;
        answer := t_answer(5, 5, 'Delete Ref Doc');
        answers.extend;          answers(answers.last) := answer;
	   	 question := t_question('Choose Option', answers);
       	 hookOutput.question := question;
  	elsif hookInput.invocationNumber = 1 then
      if hookInput.answerId < 4 then -- Add
      forms                  := t_forms();
      row := t_row();
      rows := t_rows();
      case hookInput.answerId
      when 1 then form1                  := t_form('Alternate Names for Designate (Hook)', 2,1);  ihook.setColumnValue(row, 'NM_ID', 1); rows.extend; rows(rows.last) := row;
                                          rowset := t_rowset(rows, 'Alternate Names for Designate (Hook)', 1, 'ALT_NMS');

      when 2 then form1                  := t_form('References for Designate (Hook)', 2,1); ihook.setColumnValue(row, 'REF_DOC_ID', 1);rows.extend; rows(rows.last) := row;
                                          rowset := t_rowset(rows, 'References for Designate (Hook)', 1, 'REF_DOC');

      else form1                  := t_form('Classification for Designate (Hook)', 2,1);
     end case;
        form1.rowset :=rowset;

    forms.extend;    forms(forms.last) := form1;
    hookoutput.forms := forms;

         answers := t_answers();
  	   	 answer := t_answer(hookinput.answerId, 1, 'Apply');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
  end if;

     if hookInput.answerId > 3 then -- Delete
      v_found := false;
      row := t_row();
      rows := t_rows();
      case hookInput.answerId
      when 4 then
        for cur in (select nm_Id from alt_nms a, onedata_md.vw_usr_row_filter v  where nvl(a.fld_delete,0)= 0  and a.item_id = ihook.getColumnValue(row_ori, 'ITEM_ID')
        and a.ver_nr = ihook.getColumnValue(row_ori, 'VER_NR') and a.CNTXT_ITEM_ID = v.CNTXT_ITEM_ID and a.CNTXT_VER_NR = v.CNTXT_VER_NR and upper(v.USR_ID) = upper(v_usr_id) and v.ACTION_TYP = 'I') loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'NM_ID', cur.NM_ID);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;

        if (v_found) then
       	 showrowset := t_showablerowset (rows, 'Alternate Names', 2, 'multi');
       	 hookoutput.showrowset := showrowset;
        else
         hookoutput.message := 'No names found in your authorized context to delete.';
         end if;

      when 5 then
        for cur in (select ref_Id from ref a , onedata_md.vw_usr_row_filter v  where nvl(a.fld_delete,0)= 0  and a.item_id = ihook.getColumnValue(row_ori, 'ITEM_ID')
        and a.ver_nr = ihook.getColumnValue(row_ori, 'VER_NR') and a.NCI_CNTXT_ITEM_ID = v.CNTXT_ITEM_ID and a.NCI_CNTXT_VER_NR = v.CNTXT_VER_NR and upper(v.USR_ID) = upper(v_usr_id) and v.ACTION_TYP = 'I') loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'REF_ID', cur.ref_ID);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;
     if (v_found) then
       	 showrowset := t_showablerowset (rows, 'References (for Edit)', 2, 'multi');
       	 hookoutput.showrowset := showrowset;
      else
         hookoutput.message := 'No reference docs found in your authorized context to delete.';
         end if;

    end case;
      if (v_found) then
         answers := t_answers();
  	   	 answer := t_answer(hookinput.answerId, 1, 'Delete');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
         end if;
  end if;
  	elsif hookInput.invocationNumber = 2 then
   row := t_row();
      rows := t_rows();
      if (hookinput.answerid < 4) then --- add
          forms              := hookInput.forms;
      form1              := forms(1);
      rowform := form1.rowset.rowset(1);
      ihook.setColumnValue(rowform,'ITEM_ID', v_itemid);
      ihook.setColumnValue(rowform,'VER_NR', v_vernr);

      case hookInput.answerId
          when 1 then ---- Add Alternate Names
                         ihook.setColumnValue(rowform,'NM_ID', -1);  v_tbl_nm := 'ALT_NMS';
          when 2 then ---- Add Ref Doc
                         ihook.setColumnValue(rowform,'REF_ID', -1); v_tbl_nm := 'REF';

      end case;
        rows.extend;
        rows(rows.last) := rowform;

        action := t_actionrowset(rows, v_tbl_nm, 1,1,'insert');
        actions.extend;
        actions(actions.last) := action;
     end if;
      if (hookinput.answerid > 3 ) then --- delete
            rows := t_rows();

            for i in 1..hookinput.selectedRowset.rowset.count loop
                    row := t_row();
                    row := hookInput.selectedRowset.rowset(i);
                    rows.extend;        rows(rows.last) := row;
            end loop;

            case hookInput.answerId
                when 4 then ---- Delete Alternate Names
                          v_tbl_nm := 'ALT_NMS';


                when 5 then ---- Add Ref Doc
                         v_tbl_nm := 'REF';
            end case;
       action := t_actionrowset(rows, v_tbl_nm, 1,2,'delete');
        actions.extend;
        actions(actions.last) := action;
        rows := t_rows();
        if (hookInput.answerId = 4)  then-- Delete classifications
            for i in 1..hookinput.selectedRowset.rowset.count loop
                    row_sel := t_row();
                    row_sel := hookInput.selectedRowset.rowset(i);
                        for csi_cur in (select nmdef_id, nci_pub_id, nci_ver_nr, typ_nm from NCI_CSI_ALT_DEFNMS where nmdef_id = ihook.getColumnValue(row_sel,'NM_ID')) loop
                            row:= t_row();
                            ihook.setColumnValue(row, 'nmdef_ID',csi_cur.nmdef_id);
                            ihook.setColumnValue(row, 'NCI_PUB_ID', csi_cur.NCI_PUB_ID);
            ihook.setColumnValue(row, 'NCI_VER_NR', csi_cur.NCI_VER_NR);
           ihook.setColumnValue(row, 'TYP_NM', csi_cur.TYP_NM);
           rows.extend; rows(rows.last) := row;
         end loop;
         end loop;
         action := t_actionRowset(rows, 'NCI_CSI_ALT_DEFNMS', 1,1, 'delete');
         actions.extend; actions(actions.last) := action;
    end if;



    end if;
       hookoutput.actions := actions;
  end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

END;

/
