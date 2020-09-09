create or replace PACKAGE nci_chng_mgmt AS
function getDECCreateQuestion return t_question;
function getDECCreateForm (v_rowset in t_rowset) return t_forms;
procedure createAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer, actions in out t_actions);
procedure createDEC (rowform in t_row, actions in out t_actions, v_id out number);
END;
/
create or replace PACKAGE BODY nci_CHNG_MGMT AS

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
    ANSWER                     := T_ANSWER(1, 1, 'Validate DEC');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
  --  ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(2, 2, 'Create DEC');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add new DEC.', ANSWERS);
   
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
            v_nm := v_nm || ' ' || cur.item_nm;
            v_long_nm := v_long_nm || ':' || cur.item_long_nm;
            v_def := substr(v_def || ' ' || cur.item_desc,1,4000);
            
            j := j+ 1;
        end loop;
        end if;
        end loop;
       action := t_actionrowset(rows, 'CNCPT_ADMIN_ITEM', 1,6,'insert');
        actions.extend;
        actions(actions.last) := action;
        
        rows := t_rows();
        row := t_row();
            
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', v_item_typ_id);
        ihook.setColumnValue(row,'ADMIN_STUS_ID',ihook.getColumnValue(rowform,'ADMIN_STUS_ID') );
        ihook.setColumnValue(row,'ITEM_LONG_NM', substr(v_long_nm,2));
        ihook.setColumnValue(row,'ITEM_DESC', v_def);
        ihook.setColumnValue(row,'ITEM_NM', trim(v_nm));
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        rows.extend;
        rows(rows.last) := row;
    -- raise_application_error(-20000, 'HEre ' || v_nm || v_long_nm || v_def);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM', substr(v_long_nm,2));
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
        ihook.setColumnValue(row,'ITEM_LONG_NM', ihook.getColumnValue(rowform, 'ITEM_1_LONG_NM')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_LONG_NM'));
        ihook.setColumnValue(row,'ITEM_NM',  ihook.getColumnValue(rowform, 'ITEM_1_NM')  || ' ' || ihook.getColumnValue(rowform, 'ITEM_2_NM'));
        ihook.setColumnValue(row,'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000));
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'ADMIN_STUS_ID',ihook.getColumnValue(rowform,'ADMIN_STUS_ID') );
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


END;
/
create or replace PROCEDURE spCreateDECSimple
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  showRowset t_showableRowset;
  rowform t_row;
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
  type t_cncpt_id is table of admin_item.item_id%type;
v_t_cncpt_id  t_cncpt_id := t_cncpt_id();

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
  v_oc_id number;
  v_prop_id number;
 bEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    if hookInput.invocationNumber = 0 then
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECCreateQuestion();
          row := t_row();      
          rows := t_rows();
          ihook.setColumnValue(row, 'STG_AI_ID',1);
          ihook.setColumnValue(row, 'ADMIN_STUS_ID',66);
          rows.extend;
          rows(rows.last) := row;
          rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
          hookOutput.forms := nci_chng_mgmt.getDECCreateForm(rowset);
  ELSE
   
    IF HOOKINPUT.ANSWERID = 1 THEN  -- Validate
      forms              := hookInput.forms;
      form1              := forms(1);
      rowform := form1.rowset.rowset(1);
       row := t_row();
      rows := t_rows();
  -- raise_application_error(-20000, 'here');
    for k in 1..2 loop
       if (ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_' || k) is not null) then
       v_str := trim(ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_'|| k));
       cnt := nci_11179.getwordcount(v_str);
       v_nm := '';
       for i in  1..cnt loop
          v_cncpt_nm := nci_11179.getWord(v_str, i, cnt);
           for cur in(select item_id, item_nm , item_long_nm from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
              ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,cur.item_id);
              ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, 1);
              v_dec_nm := trim(cur.item_nm || ' ' || v_dec_nm);
                  v_nm := trim(cur.item_long_nm || ':' || v_nm);
            end loop;
              
     end loop;
               nci_11179.CncptCombExists(substr(v_nm,1, length(v_nm)-1),4+k,v_item_id, v_ver_nr,v_long_nm, v_def);
              ihook.setColumnValue(rowform, 'ITEM_' || k  ||'_ID',v_item_id);
              ihook.setColumnValue(rowform, 'ITEM_' || k || '_VER_NR', v_ver_nr);
       end if;
       end loop;
              ihook.setColumnValue(rowform, 'GEN_STR',v_dec_nm ) ;
              ihook.setColumnValue(rowform, 'ADMIN_STUS_ID',66);
              ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'VALIDATED');
              if (   ihook.getColumnValue(rowform, 'ITEM_1_ID') is not null and ihook.getColumnValue(rowform, 'ITEM_2_ID') is not null) then
              ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'DUPLICATE DEC');
              end if;
              if (   ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is null or ihook.getColumnValue(rowform, 'CNCPT_2_ITEM_ID_1') is null) then
              ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'OC or PROP missing.');
              end if;
        rows.extend;
      rows(rows.last) := rowform;
     rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
     hookOutput.forms := nci_chng_mgmt.getDECCreateForm(rowset);
     HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECCreateQuestion();
  end if;
   
   
    IF HOOKINPUT.ANSWERID = 2 THEN  -- Create
      forms              := hookInput.forms;
      form1              := forms(1);
    
      rowform := form1.rowset.rowset(1);
    
    if (ihook.getColumnValue(rowform, 'CTL_VAL_MSG') <> 'VALIDATED') then
      rows := t_rows();
      rows.extend;
    rows(rows.last) := rowform;
     rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
     
    hookOutput.forms := nci_chng_mgmt.getDECCreateForm(rowset);
    HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECCreateQuestion();
    else -- Validated
  -- Create OC if new
     v_oc_id := ihook.getColumnValue(rowform, 'ITEM_1_ID');
     v_oc_ver_nr := ihook.getColumnValue(rowform, 'ITEM_1_VER_NR');
     if v_oc_id is null then
      nci_chng_mgmt.createAIWithConcept(rowform, 1,5, actions);
          v_oc_id := ihook.getColumnValue(rowform, 'ITEM_1_ID');
     end if;
     v_prop_id := ihook.getColumnValue(rowform, 'ITEM_2_ID');
     v_prop_ver_nr := ihook.getColumnValue(rowform, 'ITEM_2_VER_NR');
     if v_prop_id is null then
      nci_chng_mgmt.createAIWithConcept(rowform, 2,6,  actions);
     v_prop_id := ihook.getColumnValue(rowform, 'ITEM_2_ID');
    end if;
--    raise_application_error(-20000, v_oc_id || 'Test' || v_prop_id);
      nci_chng_mgmt.createDEC(rowform, actions, v_item_id);
     hookoutput.message := 'DEC Created Successfully with ID ' || v_item_id ;
       hookoutput.actions := actions;
    
  -- Create DEC
  
  end if;
  
   end if;
   end if;
   


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/
