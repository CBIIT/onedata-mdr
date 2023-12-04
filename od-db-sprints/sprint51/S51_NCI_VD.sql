create or replace PACKAGE            nci_vd AS
  function getVDCreateForm (v_rowset1 in t_rowset,v_rowset2 in t_rowset, v_op in varchar2) return t_forms;
  function getVDcreateQuestion(v_first in Boolean,V_from in number) return t_question;
  procedure createVD(rowai in t_row, rowvd in t_row, actions in out t_actions, v_id out  number);
  procedure createSART(rowai in t_row, rowcncpt in t_row, v_item_typ_id in integer, actions in out t_actions, v_id out  number);
  procedure createSAVM(rowai in t_row, rowcncpt in t_row, v_item_typ_id in integer, actions in out t_actions, v_id out  number);
  procedure spVDCommon ( v_init_ai in t_rowset,v_init_vd in t_rowset,v_from in number,  v_op  in varchar2,  hookInput in t_hookInput, hookOutput in out t_hookOutput);
  PROCEDURE spVDCreateNew (v_data_in in clob, v_data_out out clob);
    procedure createValAIWithConcept(rowform in out t_row,   idx in integer,v_item_typ_id in integer, v_mode in varchar2,v_cncpt_src in varchar2,  actions in out t_actions);
    procedure VDImportPost(rowform in out t_row,   idx in integer,v_item_typ_id in integer, v_mode in varchar2,v_cncpt_src in varchar2,  actions in out t_actions);
  PROCEDURE spVDCreateFrom (v_data_in in clob, v_data_out out clob);
 PROCEDURE spVDEdit (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
---  PROCEDURE spVDEdit (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
 PROCEDURE spCreateRTSA (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
 PROCEDURE spCreateVMSA (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
 procedure SACommonRT ( v_init_ai in t_rowset,  v_item_typ_id in integer, hookInput in t_hookInput, hookOutput in out t_hookOutput);
 procedure SACommonVM ( v_init_ai in t_rowset,  v_item_typ_id in integer, hookInput in t_hookInput, hookOutput in out t_hookOutput);
  function getSACreateQuestionRT(v_first in Boolean,v_item_typ_id in integer) return t_question;
  function getSACreateForm (v_rowset1 in t_rowset,v_rowset2 in t_rowset,v_item_typ_id in integer) return t_forms;
 function getSACreateQuestionVM(v_first in Boolean,v_item_typ_id in integer) return t_question;

procedure spVDValCreateImport ( rowform in out t_row , v_op  in varchar2, actions in out t_actions,  v_val_ind in out boolean);
  procedure createVDImport(rowform in out t_row, actions in out t_actions);
  procedure val_data_typ (imp_dttype in varchar2, out_dttype out number);

END;
/
create or replace PACKAGE BODY            nci_vd AS
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';

v_int_cncpt_id  number := 2433736;

function getVDCreateForm (v_rowset1 in t_rowset,v_rowset2 in t_rowset, v_op in varchar2) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
  --  if (v_op = 'insert') then
   -- form1                  := t_form('Administered Item (DEC Create)', 2,1);
   -- else
        form1                  := t_form('Administered Item (VD Edit)', 2,1);
   -- end if;

    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;

    form1                  := t_form('Rep Term (Hook Creation)', 2,1);
    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;

  return forms;

end;

function getVDcreateQuestion(v_first in Boolean,V_from in number) return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
  /*  ANSWER                     := T_ANSWER(1, 1, 'Validate Using String');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
  --  ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(2, 2, 'Validate Using Drop-Down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    IF v_first=false then
    ANSWER                     := T_ANSWER(3, 3, 'Create/Edit Using String');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    ANSWER                     := T_ANSWER(4, 4, 'Create/Edit Using Drop-Down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    end IF;*/
    ANSWER                     := T_ANSWER(5, 5, 'Validate');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
     IF v_first=false then
    ANSWER                     := T_ANSWER(6, 6, 'Create/Edit');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    end if;
    If V_from=1 then
    QUESTION               := T_QUESTION('Create New VD', ANSWERS);
    elsif V_from=2 then
    QUESTION               := T_QUESTION('Create VD from Existing', ANSWERS);
    else
    QUESTION               := T_QUESTION('Edit VD', ANSWERS);
    end if;
return question;
end;

procedure createVD (rowai in t_row, rowvd in t_row, actions in out t_actions, v_id out  number) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
v_dtype_id integer;
row t_row;
rows t_rows;
 action t_actionRowset;
 --v_id number;
begin
   rows := t_rows();
   row := rowai;
     v_id := nci_11179.getItemId;
        ihook.setColumnValue(row,'ITEM_ID', v_id);
      --  raise_application_error (-20000, ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID')  || ihook.getColumnValue(rowform, 'ITEM_1_ID') || ihook.getColumnValue(rowform, 'ITEM_2_ID'));
      if (ihook.getColumnValue(rowai, 'ITEM_LONG_NM') = v_dflt_txt or upper(ihook.getColumnValue(rowai, 'ITEM_LONG_NM')) = 'SYSGEN') then
         ihook.setColumnValue(row,'ITEM_LONG_NM', v_id || c_ver_suffix);
      end if;

    -- Create New.
         ihook.setColumnValue(row,'ITEM_NM', replace(ihook.getColumnValue(rowvd, 'ITEM_1_NM'),'Integer::','')  );

    -- Remove INteger::
    -- ihook.setColumnValue(row,'ITEM_NM', replace(ihook.getColumnValue(row, 'ITEM_NM'),'Integer::','')  );

    if (ihook.getColumnValue(rowai, 'ITEM_NM_CURATED') is not null) then
            ihook.setColumnValue(row,'ITEM_NM', ihook.getColumnValue(rowai, 'ITEM_NM_CURATED')  );
    end if;
      if (ihook.getColumnValue(rowai, 'ITEM_DESC') = v_dflt_txt) then
        ihook.setColumnValue(row,'ITEM_DESC',substr(ihook.getColumnValue(rowvd, 'ITEM_1_DEF')  ,1,4000));
     end if;

     ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 3);

        rows.extend;
        rows(rows.last) := row;
--raise_application_error(-20000, 'Deep' || ihook.getColumnValue(row,'CNTXT_ITEM_ID') || 'ggg'|| ihook.getColumnValue(row,'ADMIN_STUS_ID') || 'GGGG' || ihook.getColumnValue(row,'ITEM_ID'));

        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,7,'insert');
        actions.extend;
        actions(actions.last) := action;
--Rep Term (Hook Creation)
        rows := t_rows();
        row := rowvd;
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'REP_CLS_ITEM_ID',  ihook.getColumnValue(rowvd,'ITEM_1_ID'));
        ihook.setColumnValue(row,'REP_CLS_VER_NR',  ihook.getColumnValue(rowvd,'ITEM_1_VER_NR'));
            if (ihook.getColumnValue(row, 'DTTYPE_ID') is null) then 
        ihook.setColumnValue(row, 'DTTYPE_ID', nci_11179_2.getLegacyDataType(ihook.getColumnValue(row, 'NCI_STD_DTTYPE_ID')));
        end if;
--         if (ihook.getColumnValue(row, 'DTTYPE_ID') is null and  ihook.getColumnValue(row,'NCI_STD_DTTYPE_ID') is not null) then --- Tracker 667
--            select NCI_DFLT_LEGCY_ID into v_dtype_id from data_typ where DTTYPE_ID = ihook.getColumnValue(row,'NCI_STD_DTTYPE_ID');
--            ihook.setColumnValue(row, 'DTTYPE_ID', v_dtype_id);
--        end if;
        rows.extend;
        rows(rows.last) := row;
       action := t_actionrowset(rows, 'Value Domain', 2,8,'insert');
       actions.extend;
       actions(actions.last) := action;


end;


procedure createSART (rowai in t_row, rowcncpt in t_row, v_item_typ_id in integer, actions in out t_actions, v_id out  number) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
v_dtype_id integer;
row t_row;
rows t_rows;
v_obj_nm varchar2(100);
v_cncpt_id number;
v_cncpt_ver_nr number(4,2);
j integer;
idx integer;
 action t_actionRowset;
 --v_id number;
begin
    rows := t_rows();
    row := rowai;
    v_id := nci_11179.getItemId;
    idx := 1;

    ihook.setColumnValue(row,'ITEM_ID', v_id);
    if (ihook.getColumnValue(rowai, 'ITEM_LONG_NM') = v_dflt_txt) then
         ihook.setColumnValue(row,'ITEM_LONG_NM',nci_11179_2.getStdShortName(v_id, 1));
    end if;
    ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', v_item_typ_id);

    -- Remove Integer++ from VM only
    if (v_item_typ_id = 53) then
        ihook.setColumnValue(row, 'ITEM_NM', replace(ihook.getColumnValue(rowai, 'ITEM_NM'), 'Integer::',''));
    end if;
    ihook.setColumnValue(row,'CNCPT_CONCAT', ihook.getColumnValue(rowcncpt, 'ITEM_1_LONG_NM'));
    ihook.setColumnValue(row,'CNCPT_CONCAT_DEF', ihook.getColumnValue(rowai, 'ITEM_DESC'));
    ihook.setColumnValue(row,'CNCPT_CONCAT_NM', ihook.getColumnValue(rowai, 'ITEM_NM'));
  ihook.setColumnValue(row,'CNCPT_CONCAT_WITH_INT', ihook.getColumnValue(rowcncpt, 'ITEM_1_LONG_NM_INT'));

    rows.extend;
    rows(rows.last) := row;

    action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,7,'insert');
    actions.extend;
    actions(actions.last) := action;
    action := t_actionrowset(rows, 'NCI AI Extension (Hook)', 2,3,'insert');
    actions.extend;        actions(actions.last) := action;

    if v_item_typ_id = 7 then
            v_obj_nm := 'Representation Class';
    else
          v_obj_nm := 'Value Meaning';
    end if;
    action := t_actionrowset(rows, v_obj_nm, 2,8,'insert');
    actions.extend;       actions(actions.last) := action;

    rows := t_rows();

        if (v_item_typ_id = 7) then
             j := 1;
        for i in reverse 2..10 loop

          v_cncpt_id := ihook.getColumnValue(rowcncpt, 'CNCPT_' || idx  ||'_ITEM_ID_' || i);
             v_cncpt_ver_nr :=  ihook.getColumnValue(rowcncpt, 'CNCPT_' || idx || '_VER_NR_' || i);
          if( v_cncpt_id is not null) then
    --   raise_application_error(-20000, 'Test'  || i || v_cncpt_id);
            row := t_row();
            ihook.setColumnValue(row,'ITEM_ID', v_id);
            ihook.setColumnValue(row,'VER_NR', 1);
            ihook.setColumnValue(row,'CNCPT_ITEM_ID',v_cncpt_id);
            ihook.setColumnValue(row,'CNCPT_VER_NR', v_cncpt_ver_nr);
            ihook.setColumnValue(row,'NCI_ORD', j);
                   ihook.setColumnValue(row,'NCI_PRMRY_IND', 0);
       if (v_cncpt_id = v_int_cncpt_id and trim(ihook.getColumnValue(rowcncpt,'CNCPT_INT_' || idx || '_' || i)) is not null) then
                            ihook.setColumnValue(row,'NCI_CNCPT_VAL',ihook.getColumnValue(rowcncpt,'CNCPT_INT_' || idx || '_' || i));
                        end if;

            rows.extend;
            rows(rows.last) := row;
            j := j+ 1;
        end if;
        end loop;


          v_cncpt_id := ihook.getColumnValue(rowcncpt, 'CNCPT_' || idx  ||'_ITEM_ID_1' );
             v_cncpt_ver_nr :=  ihook.getColumnValue(rowcncpt, 'CNCPT_' || idx || '_VER_NR_1' );
            row := t_row();
            ihook.setColumnValue(row,'ITEM_ID', v_id);
            ihook.setColumnValue(row,'VER_NR', 1);
            ihook.setColumnValue(row,'CNCPT_ITEM_ID',v_cncpt_id);
            ihook.setColumnValue(row,'CNCPT_VER_NR', v_cncpt_ver_nr);
            ihook.setColumnValue(row,'NCI_ORD', 0);
            ihook.setColumnValue(row,'NCI_PRMRY_IND', 1);
             if (v_cncpt_id = v_int_cncpt_id and trim(ihook.getColumnValue(rowcncpt,'CNCPT_INT_' || idx || '_1' )) is not null) then
                            ihook.setColumnValue(row,'NCI_CNCPT_VAL',ihook.getColumnValue(rowcncpt,'CNCPT_INT_' || idx || '_1'));
                end if;

            rows.extend;
            rows(rows.last) := row;

        end if;
     action := t_actionrowset(rows, 'Items under Concept (Hook)', 2,50,'insert');
        actions.extend;
        actions(actions.last) := action;


end;


procedure createSAVM (rowai in t_row, rowcncpt in t_row, v_item_typ_id in integer, actions in out t_actions, v_id out  number) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
v_dtype_id integer;
row t_row;
rows t_rows;
v_obj_nm varchar2(100);
v_cncpt_id number;
v_cncpt_ver_nr number(4,2);
j integer;
idx integer;
 action t_actionRowset;
 --v_id number;
begin
    rows := t_rows();
    row := rowai;
    v_id := nci_11179.getItemId;
    idx := 1;

    ihook.setColumnValue(row,'ITEM_ID', v_id);
         ihook.setColumnValue(row,'ITEM_LONG_NM',nci_11179_2.getStdShortName(v_id, 1));
    ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', v_item_typ_id);

    if (ihook.getColumnValue(rowai, 'ITEM_DESC') = v_dflt_txt) then
        ihook.setColumnValue(row,'ITEM_DESC', ihook.getColumnValue(rowai,'ITEM_NM'));
    end if;
    ihook.setColumnValue(row, 'ITEM_NM', replace(ihook.getColumnValue(rowai, 'ITEM_NM'), 'Integer::',''));
    ihook.setColumnValue(row,'CNCPT_CONCAT', nvl(ihook.getColumnValue(rowcncpt, 'ITEM_1_LONG_NM'), ihook.getColumnValue(rowai, 'ITEM_NM')));
    ihook.setColumnValue(row,'CNCPT_CONCAT_DEF', ihook.getColumnValue(rowai, 'ITEM_DESC'));
    ihook.setColumnValue(row,'CNCPT_CONCAT_NM', ihook.getColumnValue(rowai, 'ITEM_NM'));
   ihook.setColumnValue(row,'CNCPT_CONCAT_WITH_INT', nvl(ihook.getColumnValue(rowcncpt, 'ITEM_1_LONG_NM_INT'), ihook.getColumnValue(rowai, 'ITEM_NM')));

    rows.extend;
    rows(rows.last) := row;

    action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,7,'insert');
    actions.extend;
    actions(actions.last) := action;
    action := t_actionrowset(rows, 'NCI AI Extension (Hook)', 2,3,'insert');
    actions.extend;        actions(actions.last) := action;

          v_obj_nm := 'Value Meaning';

    action := t_actionrowset(rows, v_obj_nm, 2,8,'insert');
    actions.extend;       actions(actions.last) := action;

-- Vm-CD relationship
    rows := t_rows();
    row := t_row();
     ihook.setColumnValue(row,'NCI_VAL_MEAN_ITEM_ID', v_id);
      ihook.setColumnValue(row,'NCI_VAL_MEAN_VER_NR', 1);
     ihook.setColumnValue(row,'CONC_DOM_ITEM_ID',ihook.getColumnValue(rowcncpt, 'CONC_DOM_ITEM_ID') );
      ihook.setColumnValue(row,'CONC_DOM_VER_NR',ihook.getColumnValue(rowcncpt, 'CONC_DOM_VER_NR') );
 rows.extend;
    rows(rows.last) := row;

    action := t_actionrowset(rows, 'Value Meanings', 2,10,'insert');
    actions.extend;
    actions(actions.last) := action;


    rows := t_rows();
        j := 0;
        for i in reverse 1..10 loop
            v_cncpt_id := ihook.getColumnValue(rowcncpt, 'CNCPT_' || idx  ||'_ITEM_ID_' || i);
             v_cncpt_ver_nr :=  ihook.getColumnValue(rowcncpt, 'CNCPT_' || idx || '_VER_NR_' || i);
            if( v_cncpt_id is not null) then
                        row := t_row();
                        ihook.setColumnValue(row,'ITEM_ID', v_id);
                        ihook.setColumnValue(row,'VER_NR', 1);
                        ihook.setColumnValue(row,'CNCPT_ITEM_ID',v_cncpt_id);
                        ihook.setColumnValue(row,'CNCPT_VER_NR', v_cncpt_ver_nr);
                        ihook.setColumnValue(row,'NCI_ORD', j);
                        if j = 0 then
                            ihook.setColumnValue(row,'NCI_PRMRY_IND', 1);
                        else ihook.setColumnValue(row,'NCI_PRMRY_IND', 0);
                        end if;
                        if (v_cncpt_id = v_int_cncpt_id and trim(ihook.getColumnValue(rowcncpt,'CNCPT_INT_' || idx || '_' || i)) is not null) then
                            ihook.setColumnValue(row,'NCI_CNCPT_VAL',ihook.getColumnValue(rowcncpt,'CNCPT_INT_' || idx || '_' || i));
                        end if;

                        rows.extend;
                        rows(rows.last) := row;
                        j := j+ 1;
            end if;
        end loop;
    action := t_actionrowset(rows, 'Items under Concept (Hook)', 2,50,'insert');
        actions.extend;
        actions(actions.last) := action;


end;

procedure spVDValCreateImport ( rowform in out t_row , v_op  in varchar2, actions in out t_actions,  v_val_ind in out boolean)
AS

    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_id number;
    v_ver_nr number(4,2);
    v_nm  varchar2(255);
    action t_actionRowset;
    v_msg varchar2(1000);
    i integer := 0;
    v_item_nm varchar2(255);
    v_item_id number;
    v_rep_id number;
    v_rep_ver number(4,2);
    v_item_desc varchar2(4000);
    v_count number;
    v_valid boolean;
    v_temp varchar2(100);
    v_substr  varchar2(100);
    v_temp_id number;
    v_temp_ver number(4,2);
    rowsetvd t_rowset;
    rowsetai t_rowset;
    rowsetrp t_rowset;
    rowset            t_rowset;
     v_rep_nm varchar2(255);
    v_cncpt_nm varchar2(255);
    v_long_nm varchar2(255);
    v_def varchar2(4000);
    v_dtype_id integer;
 BEGIN

 if (ihook.getColumnValue(rowform, 'VAL_DOM_ITEM_ID') is null and ihook.getColumNValue(rowform, 'CTL_VAL_STUS')<> 'PROCESSED') then --- only if Value Domain not specified
        if (   ihook.getColumnValue(rowform, 'CNCPT_3_ITEM_ID_1') is null and ihook.getColumnValue(rowform, 'REP_CLS_ITEM_ID') is null ) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'ERROR: Primary Rep Term missing.' || chr(13));
                  v_val_ind  := false;
        end if;

        if (   ihook.getColumnValue(rowform, 'VAL_DOM_TYP_ID') is null ) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'ERROR: VD Type is missing or invalid.' || chr(13));
                  v_val_ind  := false;
        end if;

        if (   ihook.getColumnValue(rowform, 'DTTYPE_ID') is null ) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'ERROR: Source Data Type is missing or invalid.' || chr(13));
                  v_val_ind  := false;
        end if; 
          if (   ihook.getColumnValue(rowform, 'VD_CNTXT_ITEM_ID') is null ) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'ERROR: Context is missing or invalid.' || chr(13));
                  v_val_ind  := false;
        end if; 

          if (   ihook.getColumnValue(rowform, 'VD_CONC_DOM_ITEM_ID') is null) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'ERROR: VD CD is missing or invalid.' || chr(13));
                  v_val_ind  := false;
        end if;
        if (nci_import.ParseGaps (rowform , 3) > 0 and ihook.getColumnValue(rowform, 'CNCPT_3_ITEM_ID_1') is not null ) then
                    ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'ERROR: Gaps in concept drop-downs.' || chr(13));                      
                    v_val_ind := false;
        end if;
       
  /*    if (   ihook.getColumnValue(rowform, 'UOM_ID') is null ) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'UOM is missing or invalid.' || chr(13));
                  v_val_ind  := false;
        end if; 
 if (   ihook.getColumnValue(rowform, 'VAL_DOM_FMT_ID') is null ) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'Format is missing or invalid.' || chr(13));
                  v_val_ind  := false;
        end if; 

*/
      if (ihook.getColumnValue(rowform, 'DTTYPE_ID') is not null ) then
      ihook.setColumnValue(rowform, 'NCI_STD_DTTYPE_ID', nci_11179_2.getStdDataType(ihook.getColumnValue(rowform, 'DTTYPE_ID')));

        end if;
-- jira 1670.1 change status to Errors if validated indicator is false
    if (v_val_ind = false) then 
    ihook.setColumnValue(rowform, 'CTL_VAL_STUS', 'ERRORS');
    end if;
    if (v_val_ind = true and ihook.getColumnValue(rowform, 'REP_CLS_ITEM_ID') is null ) then
    createValAIWithConcept(rowform , 3,7,'V','DROP-DOWN',actions); -- Rep
else
for currt in (Select item_nm from admin_item where item_id = ihook.getColumnValue(rowform, 'REP_CLS_ITEM_ID')
and ver_nr = ihook.getColumnValue(rowform, 'REP_CLS_VER_NR')) loop
ihook.setColumnValue(rowform ,'ITEM_3_NM',currt.item_nm);
end loop;

    end if;

    IF v_op  = 'C'  and v_val_ind = true THEN  -- Create

if (ihook.getColumnValue(rowform, 'REP_CLS_ITEM_ID') is null) then 
        createValAIWithConcept(rowform , 3,7,'C','DROP-DOWN',actions); -- Rep
end if;
                createVDImport(rowform, actions);

        end if;

 /*else -- if VD specified
        for cur in (select item_nm from admin_item where item_id = ihook.getColumnValue(rowform, 'VAL_DOM_ITEM_ID') and ver_nr = ihook.getColumnValue(rowform, 'VAL_DOM_VER_NR')) loop
       ihook.setColumnValue(rowform, 'VAL_DOM_NM',cur.item_nm ) ;
        end loop; */
end if;


--V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);


END;


  procedure createVDImport(rowform in out t_row, actions in out t_actions)
   as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
v_dtype_id integer;
row t_row;
rows t_rows;
 action t_actionRowset;
 v_id number;
begin
   rows := t_rows();
   row := rowform;
     v_id := nci_11179.getItemId;
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(rowform,'VAL_DOM_ITEM_ID_CREAT', v_id);
     ihook.setColumnValue(rowform,'VAL_DOM_VER_NR_CREAT', 1);

         ihook.setColumnValue(row,'ITEM_LONG_NM',  nvl(ihook.getColumnValue(rowform, 'VD_ITEM_LONG_NM'), v_id || c_ver_suffix));

 if ihook.getColumnValue(rowform,'REP_CLS_ITEM_ID') is not null then  -- Rep Term specified
 
 for cur in (select item_nm, item_desc from admin_item where item_id = ihook.getColumnValue(rowform,'REP_CLS_ITEM_ID') and ver_nr = ihook.getColumnValue(rowform,'REP_CLS_VER_NR')) loop
        ihook.setColumnValue(row,'ITEM_NM',  nvl(ihook.getColumnValue(rowform, 'VAL_DOM_NM'),cur.item_nm)  );
        ihook.setColumnValue(row,'ITEM_DESC',cur.item_desc);
 
 end loop;
     
 else
     ihook.setColumnValue(row,'ITEM_NM',  nvl(ihook.getColumnValue(rowform, 'VAL_DOM_NM'),ihook.getColumnValue(rowform, 'ITEM_3_NM'))  );
        ihook.setColumnValue(row,'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_3_DEF')  ,1,4000));

 end if;
 
     ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 3);
        ihook.setColumnValue(row,'REP_CLS_ITEM_ID', nvl(ihook.getColumnValue(rowform,'REP_CLS_ITEM_ID'), ihook.getColumnValue(rowform,'ITEM_3_ID')));
        ihook.setColumnValue(row,'REP_CLS_VER_NR',  nvl(ihook.getColumnValue(rowform,'REP_CLS_VER_NR'),ihook.getColumnValue(rowform,'ITEM_3_VER_NR')));
        ihook.setColumnValue(row,'CONC_DOM_ITEM_ID',  nvl(ihook.getColumnValue(rowform,'VD_CONC_DOM_ITEM_ID'),ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID')));
        ihook.setColumnValue(row,'CONC_DOM_VER_NR',  nvl(ihook.getColumnValue(rowform,'VD_CONC_DOM_VER_NR'),ihook.getColumnValue(rowform,'CONC_DOM_VER_NR')));
          nci_11179_2.setStdAttr(row);
      ihook.setColumnValue(row,'CNTXT_ITEM_ID',  nvl(ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'),ihook.getColumnValue(rowform,'VD_CNTXT_ITEM_ID')));
      ihook.setColumnValue(row,'CNTXT_VER_NR',  nvl(ihook.getColumnValue(rowform,'CNTXT_VER_NR'),ihook.getColumnValue(rowform,'VD_CNTXT_VER_NR')));
  

        rows.extend;
        rows(rows.last) := row;
--raise_application_error(-20000, 'Deep' || ihook.getColumnValue(row,'CNTXT_ITEM_ID') || 'ggg'|| ihook.getColumnValue(row,'ADMIN_STUS_ID') || 'GGGG' || ihook.getColumnValue(row,'ITEM_ID'));

        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,7,'insert');
        actions.extend;
        actions(actions.last) := action;

--Rep Term (Hook Creation)
        action := t_actionrowset(rows, 'Value Domain', 2,8,'insert');
       actions.extend;
       actions(actions.last) := action;
       -- jira 1670.5 remove new vd id
   ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'VD Created Successfully' || chr(13)) ;


end;




  PROCEDURE       spVDCommon ( v_init_ai in t_rowset,v_init_vd in t_rowset,v_from in number,  v_op  in varchar2,  hookInput in t_hookInput, hookOutput in out t_hookOutput)
AS

  showRowset t_showableRowset;
    rowform t_row;
    rowai t_row;
    rowvd t_row;
    forms t_forms;
    form1 t_form;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_id number;
    v_ver_nr number(4,2);
    v_nm  varchar2(255) := '';
    actions t_actions := t_actions();
    action t_actionRowset;
    v_msg varchar2(1000);
    i integer := 0;
    v_item_nm varchar2(255);
    v_item_id number;
    v_rep_id number;
    v_rep_ver number(4,2);
    v_item_desc varchar2(4000);
    v_count number;
    v_valid boolean;
    v_temp varchar2(100);
    v_substr  varchar2(100);
    v_temp_id number;
    v_temp_ver number(4,2);
    rowsetvd t_rowset;
    rowsetai t_rowset;
    rowsetrp t_rowset;
    rowvdold t_row;
    rowset            t_rowset;
     v_rep_nm varchar2(255);
    v_cncpt_nm varchar2(255);
    v_long_nm varchar2(255);
    v_new_nm varchar2(255) :='';
    v_new_def varchar2(6000) :='';
    v_def varchar2(4600) :='';
    is_valid boolean;
    v_dtype_id integer;
    v_err_str varchar2(4000);
    v_answer int;
 BEGIN


    if hookInput.invocationNumber = 0 then
        --  Get question. Either create or edit
        hookOutput.question    := getVDCreateQuestion(true,v_from);

        -- Send initial rowset to create the form.
        hookOutput.forms := getVDCreateForm(v_init_ai,v_init_vd, v_op);

  ELSE
 --          raise_application_error(-20000, 'Here 1');
        forms              := hookInput.forms;
        form1              := forms(1);
        rowai := form1.rowset.rowset(1);
        form1              := forms(2);
        rowvd := form1.rowset.rowset(1);
        row := t_row();
        rows := t_rows();
        is_valid := true;

        if (v_op ='update') then
            row_ori :=  hookInput.originalRowset.rowset(1);

                    v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
                    v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
if (hookinput.answerid = 5 ) then
if ( ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1') is not null
and nvl(ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1'),'X') <> nvl(ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1_ORI'),'X')) then
    v_answer:= 1; -- Validate using string
else
v_answer := 2;
end if;
end if;
if(hookinput.answerid = 6 ) then
if (ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1') is not null
and (nvl(ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1'),'X') <> nvl(ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1_ORI'), 'X'))) then
    v_answer := 3; -- create using string
else
    v_answer := 4;  -- create using dd
end if;    
        end if;
      end if;  
       -- raise_application_error(-20000,v_answer);
        if (lower(v_op) <> 'update') then -- Insert
if (hookinput.answerid = 5 and ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1') is not null ) 
and (nvl(ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1'),'X') <> nvl(ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1_ORI'), 'X')) then
    v_answer:= 1; -- Validate using string
elsif (hookinput.answerid = 5 and (ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1') is null or
 nvl(ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1'),'X') = nvl(ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1_ORI'), 'X'))) then
    v_answer := 2;  -- Validate using dd
elsif(hookinput.answerid = 6 and ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1') is not null
and nvl(ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1'),'X') <> nvl(ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1_ORI'), 'X')) then
    v_answer := 3; -- create using string
else
    v_answer := 4;  -- create using dd
end if;    
end if;
    IF v_answer = 1 or v_answer = 3 THEN  -- Validate using string

                for i in  2..10 loop
                        ihook.setColumnValue(rowvd, 'CNCPT_1_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowvd, 'CNCPT_1_VER_NR_' || i, '');
                end loop;
           --     raise_application_error(-20000, 'Here');

               createValAIWithConcept(rowvd ,  1,7,'V','STRING',actions);
     ihook.setColumnValue(rowvd, 'CNCPT_CONCAT_STR_1_ORI', ihook.getColumnValue(rowvd, 'CNCPT_CONCAT_STR_1'));


    end if;

    IF v_answer = 2 or v_answer = 4 THEN  -- Validate using drop-down
               createValAIWithConcept(rowvd , 1,7,'V','DROP-DOWN',actions);
    end if;


--ihook.setColumnValue(rowai, 'ITEM_NM_CURATED',v_op || ' ' || hookinput.answerid || ' ' || v_answer || ' ' || ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1') || ' ' || ihook.getColumnValue(rowvd,'CNCPT_CONCAT_STR_1_ORI'));

      --ihook.setColumnValue(rowform, 'GEN_STR',v_dec_nm ) ;
       ihook.setColumnValue(rowvd, 'GEN_STR',replace(ihook.getColumnValue(rowvd,'ITEM_1_NM'),'Integer::','')  ) ;
       ihook.setColumnValue(rowvd, 'CTL_VAL_MSG', 'VALIDATED');
--- Validete if Standard Data Type and Source Data Type are in sync.
     


        if (   ihook.getColumnValue(rowvd, 'CNCPT_1_ITEM_ID_1') is null ) then
                  ihook.setColumnValue(rowvd, 'CTL_VAL_MSG', 'Rep Term missing.');
                  is_valid := false;
        end if;

-- Create new
        if (   ihook.getColumnValue(rowai, 'ADMIN_STUS_ID') = 75 and  ihook.getColumnValue(rowvd, 'VAL_DOM_TYP_ID') =  17
        and v_op = 'insert' and v_from <> 2) then -- Status cannot be released if VD is enumerated
                  ihook.setColumnValue(rowvd, 'CTL_VAL_MSG', 'An Enumerated VD WFS cannot be Released if there are no permissible values.');
                  is_valid := false;
        end if;
-- Edit
       if (   ihook.getColumnValue(rowai, 'ADMIN_STUS_ID') = 75 and  ihook.getColumnValue(rowvd, 'VAL_DOM_TYP_ID') =  17
        and v_op = 'update' ) then -- Status cannot be released if VD is enumerated
            select count(*) into v_temp from perm_val where val_dom_item_id = v_item_id and val_dom_Ver_nr = v_ver_nr and nvl(fld_delete,0) = 0;
            if v_temp = 0 then
                  ihook.setColumnValue(rowvd, 'CTL_VAL_MSG', 'An Enumerated VD WFS cannot be Released if there are no permissible values.');
                  is_valid := false;
                end if;
        end if;

-- Create from Existing
         if (   ihook.getColumnValue(rowai, 'ADMIN_STUS_ID') = 75 and  ihook.getColumnValue(rowvd, 'VAL_DOM_TYP_ID') =  17
        and v_op = 'insert' and v_from = 2) then -- Status cannot be released if VD is enumerated
         row_ori :=  hookInput.originalRowset.rowset(1);
            select count(*) into v_temp from perm_val where val_dom_item_id = ihook.getColumnValue(row_ori,'ITEM_ID')
            and val_dom_Ver_nr = ihook.getColumnValue(row_ori,'VER_NR') and nvl(fld_delete,0) = 0;
            if v_temp = 0 then
                  ihook.setColumnValue(rowvd, 'CTL_VAL_MSG', 'An Enumerated VD WFS cannot be Released if there are no permissible values.');
                  is_valid := false;
                end if;

        end if;


        if (ihook.getColumnValue(rowvd, 'NCI_STD_DTTYPE_ID') is not null and ihook.getColumnValue(rowvd, 'DTTYPE_ID') is not null )  then 
            if (ihook.getColumnValue(rowvd, 'NCI_STD_DTTYPE_ID') <> nci_11179_2.getStdDataType(ihook.getColumnValue(rowvd, 'DTTYPE_ID'))) then
                  ihook.setColumnValue(rowvd, 'CTL_VAL_MSG', 'Standard Data Type/Source Data Type are not in sync.');
                  is_valid := false;
            end if;
        --    raise_application_error(-20000, v_dtype_id);
        end if;

      if (ihook.getColumnValue(rowvd, 'NCI_STD_DTTYPE_ID') is not null and ihook.getColumnValue(rowvd, 'DTTYPE_ID') is null )  then --- Tracker 667
           ihook.setColumnValue(rowvd, 'DTTYPE_ID', nci_11179_2.getLegacyDataType(ihook.getColumnValue(rowvd, 'NCI_STD_DTTYPE_ID')));
        end if;



--raise_application_error(-20000, ihook.getColumnValue(rowai,'ITEM_LONG_NM'));
-- Short name uniqueness
--raise_application_error(-20000, ihook.getColumnValue(rowai,'ITEM_LONG_NM'));
   v_err_str := '';
    nci_11179_2.stdAIValidation(rowai, 3,is_valid, v_err_str );
  --  nci_11179_2.stdCncptRowValidation(rowvd, 1,is_valid, v_err_str );

        if (v_err_str is not null) then
        ihook.setColumnValue(rowvd, 'CTL_VAL_MSG', v_err_Str);
        end if;
         rows := t_rows();

              if (v_op = 'insert') then -- create from existing then update name and definition
                    ihook.setColumnValue(rowai,'ITEM_NM', replace(ihook.getColumnValue(rowvd,'ITEM_1_NM' ),'Integer::',''));
                    ihook.setColumnValue(rowai,'ITEM_DESC', ihook.getColumnValue(rowvd,'ITEM_1_DEF'));

                end if;
             -- If any of the test fails or if the user has triggered validation, then go back to the screen.
        if is_valid=false or v_answer in (1, 2) then
                rows := t_rows();
                rows.extend;

            --- Add Concept to name if edit and concepts changed. Tracker 866
           if (v_op = 'update') then
                    rowvdold := v_init_vd.rowset(1); -- only append if changed.
                v_nm := ihook.getColumnValue(rowai, 'ITEM_NM'); -- current name
                v_def := ihook.getColumnValue(rowai, 'ITEM_DESC'); -- current def
                for i in 2..10 loop
                      for cur in (select item_nm, item_desc from admin_item  where item_id = ihook.getColumnValue(rowvd, 'CNCPT_1_ITEM_ID_' || i) and ver_nr = ihook.getColumnValue(rowvd, 'CNCPT_1_VER_NR_' || i)) loop
                       if (ihook.getColumnValue(rowvd, 'CNCPT_1_ITEM_ID_' || i) <> nvl(ihook.getColumnValue(rowvdold, 'CNCPT_1_ITEM_ID_' || i),0) ) then
                           v_nm := substr(v_nm || ' ' || cur.item_nm,1,255);
                          v_def := substr(v_def || '_' || cur.item_desc,1,6000);
                        end if;
                         v_new_nm := v_new_nm || ' ' || cur.item_nm;
                        v_new_def := v_new_def || '_' || cur.item_desc;
                  
                       end loop;
                end loop;
                    for cur in (select item_nm, item_desc from admin_item  where item_id = ihook.getColumnValue(rowvd, 'CNCPT_1_ITEM_ID_1') and ver_nr = ihook.getColumnValue(rowvd, 'CNCPT_1_VER_NR_1')) loop
                       if (ihook.getColumnValue(rowvd, 'CNCPT_1_ITEM_ID_1') <> nvl(ihook.getColumnValue(rowvdold, 'CNCPT_1_ITEM_ID_1'),0) ) then
                              v_nm := substr(v_nm || ' ' || cur.item_nm,1,255);
                          v_def := substr(v_def || '_' || cur.item_desc,1,6000);
                      end if;
                            v_new_nm := v_new_nm || ' ' || cur.item_nm;
                        v_new_def := v_new_def || '_' || cur.item_desc;
                  
                       end loop;
         -- if SYSGEN - then do not append.
               
          if (upper(nvl(ihook.getColumnValue(rowai, 'ITEM_NM_CURATED'),'XX')) <> 'SYSGEN') then
                ihook.setColumnValue (rowai, 'ITEM_NM', v_nm);
            else
                ihook.setColumnValue (rowai, 'ITEM_NM', v_new_nm);
                ihook.setColumnValue (rowai, 'ITEM_NM_CURATED', '');
                
            end if;
        
            if (upper(nvl(ihook.getColumnValue(rowai, 'ITEM_DESC'),'XX')) <> 'SYSGEN') then
                   ihook.setColumnValue (rowai, 'ITEM_DESC', v_def);
            else
                   ihook.setColumnValue (rowai, 'ITEM_DESC', substr(v_new_def,2));
        end if;
     
           end if;

                ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 3);

                rows(rows.last) := rowai;
                rowsetai := t_rowset(rows, 'Administered Item (Hook Creation)', 1, 'ADMIN_ITEM');
                rows := t_rows();
                rows.extend;
                rows(rows.last) := rowvd;
                rowset := t_rowset(rows, 'Rep Term (Hook Creation)', 1, 'NCI_STG_AI_CNCPT_CREAT');
                hookoutput.message := ihook.getColumnValue(rowvd, 'CTL_VAL_MSG');
                      hookOutput.forms := getVDCreateForm(rowsetai,rowset, v_op);
                HOOKOUTPUT.QUESTION    := getVDCreateQuestion(false,v_from);
        end if;

     -- If all the tests have passed and the user has asked for create, then create VD and Repp.
    -- raise_application_error(-20000, 'Here2');
    IF v_answer in ( 3,4)  and is_valid = true THEN  -- Create

        ihook.setColumnValue(rowvd, 'CNTXT_ITEM_ID', ihook.getColumnValue(rowai,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(rowvd, 'CNTXT_VER_NR', ihook.getColumnValue(rowai,'CNTXT_VER_NR'));

        createValAIWithConcept(rowvd , 1,7,'C','DROP-DOWN',actions); -- Rep

              if (v_op = 'insert') then
                createVD(rowai, rowvd, actions, v_item_id);
                hookoutput.message := 'VD Created Successfully with ID ' || v_item_id ;

              else
                -- Update VD. Get the selected row, update name, definition, context.
                    row := t_row();
                    row_ori :=  hookInput.originalRowset.rowset(1);

                    v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
                    v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');

                     --- Update name, definition, context
                    row := rowai;
                      if (ihook.getColumnValue(rowai, 'ITEM_NM_CURATED') is not null) then
                    ihook.setColumnValue(row,'ITEM_NM', ihook.getColumnValue(rowai, 'ITEM_NM_CURATED')  );
                    end if;
                         ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 3);
            rows := t_rows();    rows.extend;    rows(rows.last) := row;
                action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,10,'update');
                actions.extend;
                actions(actions.last) := action;
                row := rowvd;
           -- Get the Sub-type row. Update REP CD.

         --   nci_11179.spReturnSubtypeRow (v_item_id, v_ver_nr, 2, row );
            ihook.setColumnValue(row, 'REP_CLS_ITEM_ID', ihook.getColumnValue(rowvd,'ITEM_1_ID'));
            ihook.setColumnValue(row, 'REP_CLS_VER_NR', ihook.getColumnValue(rowvd,'ITEM_1_VER_NR'));
            ihook.setColumnValue(row, 'ITEM_ID', v_item_id);
            ihook.setColumnValue(row, 'VER_NR', v_ver_nr);


             rows := t_rows();    rows.extend;    rows(rows.last) := row;
             action := t_actionrowset(rows, 'Value Domain', 2,11,'update');
        actions.extend;
        actions(actions.last) := action;
        end if;

        if (v_from = 2 and v_op = 'insert') then --- create from existing and enumerated copy Perm Val
             rows := t_rows();
               row_ori := hookinput. originalrowset.rowset(1);

-- Tracker 2078 - do not copy PV if new VD is non-enumerated
        if (ihook.getcolumnValue(rowvd,'VAL_DOM_TYP_ID') = 17) then -- enumerated only
            nci_11179.CopyPermVal (actions, ihook.getColumnValue(row_ori,'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_item_id, 1);
        end if;
        end if;


        hookoutput.actions := actions;

    end if;

end if;

--V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);


END;
--

 procedure SACommonRT ( v_init_ai in t_rowset, v_item_typ_id in integer, hookInput in t_hookInput, hookOutput in out t_hookOutput)
 AS

  showRowset t_showableRowset;
    rowform t_row;
    rowai t_row;
    rowst t_row;
    rowcncpt t_row;
    forms t_forms;
    form1 t_form;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_id number;
    v_ver_nr number(4,2);
    v_nm  varchar2(255);
    actions t_actions := t_actions();
    action t_actionRowset;
    v_msg varchar2(1000);
    i integer := 0;
    v_item_nm varchar2(255);
    v_item_id number;
    v_rep_id number;
    v_rep_ver number(4,2);
    v_item_desc varchar2(4000);
    v_count number;
    v_valid boolean;
    v_temp varchar2(100);
    v_substr  varchar2(100);
    v_temp_id number;
    v_temp_ver number(4,2);
     rowsetai t_rowset;
    rowsetcncpt t_rowset;
    rowset            t_rowset;
     v_rep_nm varchar2(255);
    v_cncpt_nm varchar2(255);
    v_long_nm varchar2(255);
    v_def varchar2(4000);
    is_valid boolean;
    v_err_str varchar2(4000);
    v_answer integer := 0;
 BEGIN


    if hookInput.invocationNumber = 0 then
        --  Get question. Either create or edit
        hookOutput.question    := getSACreateQuestionRT(true,v_item_typ_id);
  row := t_row();
    ihook.setColumnValue(row, 'STG_AI_ID', 1);
    rows := t_rows(); rows.extend;    rows(rows.last) := row;
    rowsetcncpt := t_rowset(rows, 'Rep Term (Stand Alone)', 1, 'NCI_STG_AI_CNCPT_CREAT'); -- Default values for cncpt form

        -- Send initial rowset to create the form.
        hookOutput.forms := getSACreateForm(v_init_ai, rowsetcncpt, v_item_typ_id);

  ELSE
 --          raise_application_error(-20000, 'Here 1');
        forms              := hookInput.forms;
        form1              := forms(1);
        rowai := form1.rowset.rowset(1);
        form1              := forms(2);
        rowcncpt := form1.rowset.rowset(1);
        row := t_row();
        rows := t_rows();
        is_valid := true;

-- Context is always going to be NCIP for VM and RT
        ihook.setColumnValue(rowai,'CNTXT_ITEM_ID',20000000024); -- NCIP
        ihook.setColumnValue(rowai,'CNTXT_VER_NR', 1);
        -- Changing the logic to determine use of string or dropdown. rather than changing the entire logic, changing the code here to reduce regression testing
if (hookinput.answerid = 5 and ihook.getColumnValue(rowcncpt,'CNCPT_CONCAT_STR_1') is not null) then
    v_answer:= 1; -- Validate using string
elsif (hookinput.answerid = 5 and ihook.getColumnValue(rowcncpt,'CNCPT_CONCAT_STR_1') is null) then
    v_answer := 2;  -- Validate using dd
elsif(hookinput.answerid = 6 and ihook.getColumnValue(rowcncpt,'CNCPT_CONCAT_STR_1') is not null) then
    v_answer := 3; -- create using string
else
    v_answer := 4;  -- create using dd
end if;    
        
    IF v_answer = 1 or v_answer = 3 THEN  -- Validate using string
               for i in  2..10 loop
                        ihook.setColumnValue(rowcncpt, 'CNCPT_1_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowcncpt, 'CNCPT_1_VER_NR_' || i, '');
                end loop;
               createValAIWithConcept(rowcncpt ,  1,v_item_typ_id,'V','STRING',actions);
    end if;

    IF v_answer = 2 or v_answer = 4 THEN  -- Validate using drop-down
               createValAIWithConcept(rowcncpt , 1,v_item_typ_id,'V','DROP-DOWN',actions);
    end if;

      --ihook.setColumnValue(rowform, 'GEN_STR',v_dec_nm ) ;
       ihook.setColumnValue(rowcncpt, 'GEN_STR',ihook.getColumnValue(rowcncpt,'ITEM_1_NM')  ) ;
       ihook.setColumnValue(rowcncpt, 'CTL_VAL_MSG', 'VALIDATED');


        if (   ihook.getColumnValue(rowcncpt, 'CNCPT_1_ITEM_ID_1') is null ) then
                  ihook.setColumnValue(rowcncpt, 'CTL_VAL_MSG', 'At least one concept has to be specified.');
                  is_valid := false;
        end if;

   if (   ihook.getColumnValue(rowcncpt, 'ITEM_1_ID') is  not null ) then
                  ihook.setColumnValue(rowcncpt, 'CTL_VAL_MSG', 'Duplicate found based on concepts: ' || ihook.getColumnValue(rowcncpt, 'ITEM_1_ID') );
                  is_valid := false;
        end if;

   v_err_str := '';
    nci_11179_2.stdAIValidation(rowai, v_item_typ_id,is_valid, v_err_str );
     --  nci_11179_2.stdCncptRowValidation(rowcncpt, 1,is_valid, v_err_str );

        if (v_err_str is not null) then
        ihook.setColumnValue(rowcncpt, 'CTL_VAL_MSG', v_err_Str);
        end if;
         rows := t_rows();
             if (ihook.getColumnValue(rowcncpt,'ITEM_1_NM') is not null) then
        ihook.setColumnValue(rowai,'ITEM_NM', ihook.getColumnValue(rowcncpt,'ITEM_1_NM'));
              ihook.setColumnValue(rowai,'ITEM_DESC', ihook.getColumnValue(rowcncpt,'ITEM_1_DEF'));
        end if;

             -- If any of the test fails or if the user has triggered validation, then go back to the screen.
        if is_valid=false or v_answer in (1, 2) then
                rows := t_rows();
                rows.extend;
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', v_item_typ_id);
                rows(rows.last) := rowai;
                rowsetai := t_rowset(rows, 'Administered Item (Hook Creation)', 1, 'ADMIN_ITEM');
                rows := t_rows();
                rows.extend;
                rows(rows.last) := rowcncpt;
                rowset := t_rowset(rows, 'Rep Term (Hook Creation)', 1, 'NCI_STG_AI_CNCPT_CREAT');
                hookoutput.message := ihook.getColumnValue(rowcncpt, 'CTL_VAL_MSG');
                      hookOutput.forms := getSACreateForm(rowsetai,rowset,v_item_typ_id);
                HOOKOUTPUT.QUESTION    := getSACreateQuestionRT(false,v_item_typ_id);
        end if;


     -- If all the tests have passed and the user has asked for create, then create VD and Repp.
    -- raise_application_error(-20000, 'Here2');
    IF v_answer in ( 3,4)  and is_valid = true THEN  -- Create

                createSART(rowai, rowcncpt, v_item_typ_id, actions, v_item_id);
                hookoutput.message := 'Rep Term Created Successfully with ID ' || v_item_id ;
         hookoutput.actions := actions;

    end if;

end if;

--V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);


END;


 procedure SACommonVM ( v_init_ai in t_rowset, v_item_typ_id in integer, hookInput in t_hookInput, hookOutput in out t_hookOutput)
 AS

    rowform t_row;
    rowai t_row;
    rowst t_row;
    rowcncpt t_row;
    forms t_forms;
    form1 t_form;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_id number;
    v_ver_nr number(4,2);
    v_nm  varchar2(255);
    actions t_actions := t_actions();
    action t_actionRowset;
    v_msg varchar2(1000);
    i integer := 0;
    v_item_nm varchar2(255);
    v_item_id number;
    v_rep_id number;
    v_rep_ver number(4,2);
    v_item_desc varchar2(4000);
    v_count number;
    v_valid boolean;
    v_temp varchar2(100);
    v_substr  varchar2(100);
    v_temp_id number;
    v_temp_ver number(4,2);
     rowsetai t_rowset;
    rowsetcncpt t_rowset;
    rowset            t_rowset;
     v_rep_nm varchar2(255);
    v_cncpt_nm varchar2(255);
    v_long_nm varchar2(255);
    v_def varchar2(4000);
    is_valid boolean;
    v_err_str varchar2(4000);
    is_dup boolean;
    v_opt integer;
    v_answer integer;
 BEGIN

    if hookInput.invocationNumber = 0 then
        hookOutput.question    := getSACreateQuestionVM(true,v_item_typ_id);
        row := t_row();
        ihook.setColumnValue(row, 'STG_AI_ID', 1);
        rows := t_rows(); rows.extend;    rows(rows.last) := row;
        rowsetcncpt := t_rowset(rows, 'Rep Term (Stand Alone)', 1, 'NCI_STG_AI_CNCPT_CREAT'); -- Default values for cncpt form

        -- Send initial rowset to create the form.
        hookOutput.forms := getSACreateForm(v_init_ai, rowsetcncpt, v_item_typ_id);

    else
        forms              := hookInput.forms;
        form1              := forms(1);
        rowai := form1.rowset.rowset(1);

        form1              := forms(2);
        rowcncpt := form1.rowset.rowset(1);

if (hookinput.answerid = 5 and ihook.getColumnValue(rowcncpt,'CNCPT_CONCAT_STR_1') is not null) then
    v_answer:= 1; -- Validate using string
elsif (hookinput.answerid = 5 and ihook.getColumnValue(rowcncpt,'CNCPT_CONCAT_STR_1') is null) then
    v_answer := 2;  -- Validate using dd
elsif(hookinput.answerid = 6 and ihook.getColumnValue(rowcncpt,'CNCPT_CONCAT_STR_1') is not null) then
    v_answer := 3; -- create using string
else
    v_answer := 4;  -- create using dd
end if; 

        row := t_row();
        rows := t_rows();
        is_valid := true;
        v_opt := 0;

        if (ihook.getColumnValue(rowai, 'ITEM_NM') <> v_dflt_txt and ihook.getColumnValue(rowcncpt, 'CNCPT_1_ITEM_ID_1') is null) then
            v_opt := 1;
            hookoutput.message := 'String VM will be created using name and definition.';
        elsif   ihook.getColumnValue(rowcncpt, 'CNCPT_CONCAT_STR_1') is not null then
            v_opt := 2;
            hookoutput.message := 'VM Concept String will be used.';
        elsif   ihook.getColumnValue(rowcncpt, 'CNCPT_1_ITEM_ID_1') is not null then
            v_opt := 3;
            hookoutput.message := 'VM Concepts will be used.';
        else
            hookoutput.message := 'Please specify name, concept string or concept(s).';
        end if;

-- Context is always going to be NCIP for VM and RT
        ihook.setColumnValue(rowai,'CNTXT_ITEM_ID',20000000024); -- NCIP
        ihook.setColumnValue(rowai,'CNTXT_VER_NR', 1);
        -- v_opt - 1 is string; 2 - string concepts, 3 - drop-down

        if v_opt = 2 THEN  -- Validate using string
                for i in 1..10 loop
                        ihook.setColumnValue(rowcncpt, 'CNCPT_1_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowcncpt, 'CNCPT_1_VER_NR_' || i, '');
                end loop;
               nci_dec_mgmt.createValAIWithConcept(rowcncpt ,  1,v_item_typ_id,'V','STRING',actions);
        end if;

      if v_opt = 3 THEN  -- Validate using drop-down
               nci_dec_mgmt.createValAIWithConcept(rowcncpt , 1,v_item_typ_id,'V','DROP-DOWN',actions);
        end if;

        if v_opt = 1 THEN  -- String
               nci_pv_vm.createVMWithoutConcept(rowcncpt ,  'V',ihook.getColumnValue(rowai, 'ITEM_NM'), ihook.getColumnValue(rowai, 'ITEM_DESC'),actions);
        end if;

       -- raise_application_error(-20000, v_opt);

       ihook.setColumnValue(rowcncpt, 'GEN_STR',replace(ihook.getColumnValue(rowcncpt,'ITEM_1_NM'),'Integer::','')  ) ;
       --ihook.setColumnValue(rowcncpt, 'CTL_VAL_MSG', 'VALIDATED');

        if (v_opt > 1 and    ihook.getColumnValue(rowcncpt, 'CNCPT_1_ITEM_ID_1') is null ) then
                  ihook.setColumnValue(rowcncpt, 'CTL_VAL_MSG', 'At least one concept has to be specified.');
                  is_valid := false;
        end if;

        if (   ihook.getColumnValue(rowcncpt, 'CNCPT_2_ITEM_ID_1') is  not null ) then
                  ihook.setColumnValue(rowcncpt, 'CTL_VAL_MSG', 'WARNING: Duplicate found based on concepts.  See duplicate section. ' );
        end if;

        v_err_str := '';
        nci_11179_2.stdAIValidation(rowai, v_item_typ_id,is_valid, v_err_str );
      --  nci_11179_2.stdCncptRowValidation(rowcncpt, 1,is_valid, v_err_str );

        if (v_err_str is not null) then
            ihook.setColumnValue(rowcncpt, 'CTL_VAL_MSG', v_err_Str);
        end if;

                   if (ihook.getColumnValue(rowcncpt,'ITEM_1_NM') is not null and v_opt > 1) then
                    ihook.setColumnValue(rowai,'ITEM_NM', ihook.getColumnValue(rowcncpt,'ITEM_1_NM'));
                    ihook.setColumnValue(rowai,'ITEM_DESC', ihook.getColumnValue(rowcncpt,'ITEM_1_DEF'));
                end if;

                    ihook.setColumnValue(rowai, 'ITEM_NM', replace(ihook.getColumnValue(rowai, 'ITEM_NM'), 'Integer::',''));

             -- If any of the test fails or if the user has triggered validation, then go back to the screen.
        if is_valid=false or hookinput.answerid in (1) or v_opt = 0 then
                rows := t_rows();
                rows.extend;
                ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', v_item_typ_id);
                 rows(rows.last) := rowai;
                rowsetai := t_rowset(rows, 'Administered Item (Hook Creation)', 1, 'ADMIN_ITEM');
                rows := t_rows();
                rows.extend;
                rows(rows.last) := rowcncpt;
                rowset := t_rowset(rows, 'Rep Term (Hook Creation)', 1, 'NCI_STG_AI_CNCPT_CREAT');
         --       hookoutput.message := ihook.getColumnValue(rowcncpt, 'CTL_VAL_MSG');
                if (ihook.getColumnValue(rowcncpt, 'CNCPT_2_ITEM_ID_1') is not null) then
                    hookoutput.message := hookoutput.message || ' Duplicate(s) found';
                end if;
                hookOutput.forms := getSACreateForm(rowsetai,rowset,v_item_typ_id);
                HOOKOUTPUT.QUESTION    := getSACreateQuestionVM(false,v_item_typ_id);
        end if;


     -- If all the tests have passed and the user has asked for create, then create VD and Repp.
    -- raise_application_error(-20000, 'Here2');
        if HOOKINPUT.ANSWERID in (3)  and is_valid = true and v_opt > 0 THEN  -- Create
                createSAVM(rowai, rowcncpt, v_item_typ_id, actions, v_item_id);
                hookoutput.message := 'Value Meaning Created Successfully with ID ' || v_item_id ;
            hookoutput.actions := actions;
        end if;

    end if;

--V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);


END;

function getSACreateQuestionRT(v_first in Boolean,v_item_typ_id in integer) return t_question
  is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
  /*  ANSWER                     := T_ANSWER(1, 1, 'Validate Using String');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    ANSWER                     := T_ANSWER(2, 2, 'Validate Using Drop-Down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER; */
    ANSWER                     := T_ANSWER(5, 5, 'Validate');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
   IF v_first=false then
   /* ANSWER                     := T_ANSWER(3, 3, 'Create/Edit Using String');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    ANSWER                     := T_ANSWER(4, 4, 'Create/Edit Using Drop-Down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER; */
    ANSWER                     := T_ANSWER(6, 6, 'Create/Edit');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER; 
    
    end IF;
   if (v_item_typ_id =7) then
    QUESTION               := T_QUESTION('Create New Rep Term', ANSWERS);
    else
       QUESTION               := T_QUESTION('Create New Value Meaning', ANSWERS);
end if;
return question;
end;


function getSACreateQuestionVM(v_first in Boolean,v_item_typ_id in integer) return t_question
  is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Validate');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
  --  ANSWERS                    := T_ANSWERS();
    --ANSWER                     := T_ANSWER(2, 2, 'Validate Using Drop-Down');
    --ANSWERS.EXTEND;
    --ANSWERS(ANSWERS.LAST) := ANSWER;
    IF v_first=false then
    ANSWER                     := T_ANSWER(3, 3, 'Create');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    --ANSWER                     := T_ANSWER(4, 4, 'Create/Edit Using Drop-Down');
    --ANSWERS.EXTEND;
    --ANSWERS(ANSWERS.LAST) := ANSWER;
    end IF;
       QUESTION               := T_QUESTION('Create New Value Meaning', ANSWERS);
return question;
end;

  function getSACreateForm (v_rowset1 in t_rowset,v_rowset2 in t_rowset,v_item_typ_id in integer) return t_forms is
   forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();

  form1                  := t_form('Administered Item (No Short Name)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
if (v_item_typ_id = 7) then -- Rep term

    form1                  := t_form('Rep Term (Stand Alone)', 2,1);
else

   form1                  := t_form('VM (Stand Alone)', 2,1);
end if;
    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;

  return forms;

end;


PROCEDURE spVDCreateFrom ( v_data_in IN CLOB, v_data_out OUT CLOB) as
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_item_id  number;
    v_rc_item_id number;
    v_rc_ver_nr number(4,2);
    v_ver_nr  number(4,2);
    v_ori_rep_cls number;
    v_item_type_id number;
    rowai t_row;
    rowvd t_row;
    rowset  t_rowset;
    rowsetst  t_rowset;
    rowsetai  t_rowset;
    rowsetrp  t_rowset;
    v_str varchar2(1000);
begin
--    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    -- Get the selected row
    row_ori :=  hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_item_type_id := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');
--

    if (hookinput.invocationnumber = 0) then
--    -- check that a selected AI is VD type
    if (v_item_type_id <> 3) then -- 3 - VALUE DOMAIN in table OBJ_KEY
        raise_application_error(-20000,'!!! This functionality is only applicable for VD !!!');
    end if;
--
--
    rowai := row_ori;
    rowvd := t_row();

select rep_cls_item_id, rep_cls_ver_nr into v_rc_item_id, v_rc_ver_nr
from value_dom where item_id = v_item_id and ver_nr = v_ver_nr;
--
    nci_11179.spReturnSubtypeRow (v_item_id, v_ver_nr, 3,  rowvd );

--     -- Copy subtype specific attributes
    nci_11179.spReturnRTConceptRow (v_rc_item_id, v_rc_ver_nr, 7, 1, rowvd );
  v_str := nci_11179_2.getCncptStrFromCncpt (v_rc_item_id, v_rc_ver_nr, 7) ;
   ihook.setColumnValue(rowvd, 'CNCPT_CONCAT_STR_1', v_str);
   ihook.setColumnValue(rowvd, 'CNCPT_CONCAT_STR_1_ORI', v_str);
--
     ihook.setColumnValue(rowai, 'ITEM_ID', -1);
    ihook.setColumnValue(rowvd, 'STG_AI_ID', 1);
    nci_11179_2.setStdAttr(rowai);
           ihook.setColumnValue(rowai, 'ITEM_LONG_NM', v_dflt_txt);
  -- Tracker 2505
        ihook.setColumnValue(rowai,'ADMIN_NOTES','');
        ihook.setColumnValue(rowai,'CHNG_DESC_TXT','');

     rows := t_rows();    rows.extend;    rows(rows.last) := rowai;
     rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
--
     rows := t_rows();    rows.extend;    rows(rows.last) := rowvd;

    rowsetst := t_rowset(rows, 'Rep Term (Hook Creation)', 1, 'NCI_STG_AI_CNCPT_CREAT');
--
    end if;

   spVDCommon(rowsetai, rowsetst, 2, 'insert', hookinput, hookoutput);

--
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --  nci_util.debugHook('GENERAL',v_data_out);
end;
--

PROCEDURE spVDEdit ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id in varchar2) as
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_item_id  number;
    v_rc_item_id number;
    v_rc_ver_nr number(4,2);
    v_ver_nr  number(4,2);
    v_ori_rep_cls number;
    v_item_type_id number;
    rowai t_row;
    rowvd t_row;
    rowset  t_rowset;
    rowsetst  t_rowset;
    rowsetai  t_rowset;
    rowsetrp  t_rowset;
    v_str varchar2(1000);
begin
--    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    -- Get the selected row
    row_ori :=  hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_item_type_id := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');
--

 --   if (hookinput.invocationnumber = 0) then
--    -- check that a selected AI is VD type
    if (v_item_type_id <> 3) then -- 3 - VALUE DOMAIN in table OBJ_KEY
        raise_application_error(-20000,'!!! This functionality is only applicable for VD !!!');
    end if;
--
--  user authorization
   if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;

    rowai := row_ori;
    rowvd := t_row();

select rep_cls_item_id, rep_cls_ver_nr into v_rc_item_id, v_rc_ver_nr
from value_dom where item_id = v_item_id and ver_nr = v_ver_nr;
--
    nci_11179.spReturnSubtypeRow (v_item_id, v_ver_nr, 3,  rowvd );

--     -- Copy subtype specific attributes
    nci_11179.spReturnRTConceptRow (v_rc_item_id, v_rc_ver_nr, 7, 1, rowvd );
    
    v_str := nci_11179_2.getCncptStrFromCncpt (v_rc_item_id, v_rc_ver_nr, 7) ;
   ihook.setColumnValue(rowvd, 'CNCPT_CONCAT_STR_1', v_str);
   ihook.setColumnValue(rowvd, 'CNCPT_CONCAT_STR_1_ORI', v_str);
   
--
--


    ihook.setColumnValue(rowvd, 'STG_AI_ID', 1);

     rows := t_rows();    rows.extend;    rows(rows.last) := rowai;
     rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
--
     rows := t_rows();    rows.extend;    rows(rows.last) := rowvd;

    rowsetst := t_rowset(rows, 'Rep Term (Hook Creation)', 1, 'NCI_STG_AI_CNCPT_CREAT');
--
 --   end if;

   spVDCommon(rowsetai, rowsetst, 3, 'update', hookinput, hookoutput);

--
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

end;

--
PROCEDURE spVDCreateNew ( v_data_in IN CLOB, v_data_out OUT CLOB)
as
  hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    rowsetai  t_rowset;
    rowsetst  t_rowset;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;


    -- Default for new row. Dummy Identifier has to be set else error.
    row := t_row();
    ihook.setColumnValue(row, 'STG_AI_ID', 1);
       nci_11179_2.setStdAttr(row);
          ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 3);
     --     ihook.setColumnValue(row, 'ITEM_NM', v_dflt_txt);
          ihook.setColumnValue(row, 'ITEM_DESC', v_dflt_txt);
          ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);

    rows := t_rows(); rows.extend;    rows(rows.last) := row;
    rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for AI form
    rowsetst := t_rowset(rows, 'Value Domain', 1, 'VALUE_DOM'); -- Default values for VD form

    spVDCommon(rowsetai,rowsetst,1, 'insert', hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --  nci_util.debugHook('GENERAL',v_data_out);
end;



PROCEDURE spCreateVMSA ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id in varchar2)
as
  hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    rowsetai  t_rowset;
    rowsetst  t_rowset;
    v_item_typ_id integer;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

      v_item_typ_id := 53;
      row := t_row();
    -- Default for new row. Dummy Identifier has to be set else error.
      nci_11179_2.setStdAttr(row);
              ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', v_item_typ_id);
          ihook.setColumnValue(row, 'ITEM_NM', v_dflt_txt);
          ihook.setColumnValue(row, 'ITEM_DESC', v_dflt_txt);
          ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);

    rows := t_rows(); rows.extend;    rows(rows.last) := row;


    rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for AI form

    SACommonVM(rowsetai,v_item_typ_id, hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

  --  nci_util.debugHook('GENERAL',v_data_out);
end;


PROCEDURE spCreateRTSA ( v_data_in IN CLOB, v_data_out OUT CLOB,  v_usr_id in varchar2)
as
  hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    rowsetai  t_rowset;
    rowsetst  t_rowset;
    v_item_typ_id integer;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    row := t_row();
    v_item_typ_id := 7;
    -- Default for new row. Dummy Identifier has to be set else error.
       nci_11179_2.setStdAttr(row);
             ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', v_item_typ_id);
          ihook.setColumnValue(row, 'ITEM_NM', v_dflt_txt);
          ihook.setColumnValue(row, 'ITEM_DESC', v_dflt_txt);
          ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);

    rows := t_rows(); rows.extend;    rows(rows.last) := row;


    rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for AI form

    SACommonRT(rowsetai,v_item_typ_id, hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --  nci_util.debugHook('GENERAL',v_data_out);
end;
--
--PROCEDURE spVDEdit ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
--as
--    hookInput t_hookInput;
--    hookOutput t_hookOutput := t_hookOutput();
--    row_ori  t_row;
--    row  t_row;
--    rows t_rows;
--    v_item_id  number;
--    v_ver_nr  number(4,2);
--    v_ori_rep_cls number;
--    v_item_type_id number;
--    v_oc_item_id number;
--    v_prop_item_id number;
--    v_oc_ver_nr number(4,2);
--    v_prop_ver_nr number(4,2);
--      v_conc_dom_item_id number;
--    v_conc_dom_ver_nr number(4,2);
--    rowsetrp  t_rowset;
--    rowsetai  t_rowset;
--    rowsetst  t_rowset;
--    rowset  t_rowset;
--
--begin
--    -- Standard header
--    hookInput                    := Ihook.gethookinput (v_data_in);
--    hookOutput.invocationnumber  := hookInput.invocationnumber;
--    hookOutput.originalrowset    := hookInput.originalrowset;
--
--    -- Get the selected row
--    row_ori :=  hookInput.originalRowset.rowset(1);
--    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
--    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
--    v_item_type_id := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');
--
--
--    -- Check if user is authorized to edit
--    if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
--        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
--        return;
--    end if;
--
--    -- check that a selected AI is VD type
--    if (v_item_type_id <> 3) then -- 3 - VALUE DOMAIN in table OBJ_KEY
--        raise_application_error(-20000,'!!! This functionality is only applicable for VD !!!');
--    end if;
--
--
--    row := row_ori;
--
--select obj_cls_item_id, obj_cls_ver_nr, prop_item_id, prop_ver_nr, conc_dom_item_id, conc_dom_ver_nr into v_oc_item_id, v_oc_ver_nr, v_prop_item_id, v_prop_ver_nr ,
--v_conc_dom_item_id, v_conc_dom_ver_nr
--from de_conc where item_id = v_item_id and ver_nr = v_ver_nr;
--
--     -- Copy subtype specific attributes
--    nci_11179.spReturnConceptRow (v_oc_item_id, v_oc_ver_nr, 7, 1, row );
--
--    ihook.setColumnValue(row, 'STG_AI_ID', 1);
--     ihook.setColumnValue(row, 'CONC_DOM_ITEM_ID', v_conc_dom_item_id);
--    ihook.setColumnValue(row, 'CONC_DOM_VER_NR', v_conc_dom_ver_nr);
--
--
--rows := t_rows();    rows.extend;    rows(rows.last) := row;
--     rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
--
--    --spVDCommon(rowset, 'update', hookinput, hookoutput);
--spVDCommon(rowsetai, rowsetst, rowsetrp, 2, 'update', hookinput, hookoutput);
--
--    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--
--end;
--
--
--
-- v_mode : V - Validate, C - Validation and Create;  v_cncpt_src:  STRING: String; DROP-DOWN: Drop-downs
procedure createValAIWithConcept(rowform in out t_row,  idx in integer,v_item_typ_id in integer,v_mode in varchar2, v_cncpt_src in varchar2, actions in out t_actions) as
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
 v_long_nm_suf_int varchar2(255);
 j integer;
i integer;
cnt integer;
v_str varchar2(255);
v_obj_nm  varchar2(100);
v_temp varchar2(4000);
v_cncpt_nm varchar2(255);
v_interim boolean;
v_invalid_concepts varchar2(4000);
begin

if (v_cncpt_src ='STRING') then
      if (ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_' || idx) is not null) then
                v_str := trim(ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_'|| idx));
                cnt := nci_11179.getwordcount(v_str);
                v_nm := '';
                v_long_nm := '';
                v_long_nm_suf := '';
                v_long_nm_suf_int := '';
                v_def := '';
                for i in  1..cnt loop
                if (v_item_typ_id = 7) then
                        j := i+1;
                else
                        j :=i;
                end if;
                        v_cncpt_nm := nci_11179.getWord(v_str, i, cnt);
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || j,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || j, '');
                        v_interim := false;
                        for cur in(select item_id, item_nm , item_long_nm, item_desc from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || j,cur.item_id);
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || j, 1);
                               -- v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                                v_long_nm_suf := trim(v_long_nm_suf || ':' || cur.item_long_nm);
                                v_long_nm_suf_int := trim(v_long_nm_suf_int || ':' || cur.item_long_nm);
                                v_nm := trim(v_nm || ' ' || cur.item_nm);
                              v_def := substr( v_def || '_' ||cur.item_desc  ,1,4000);
                                v_interim := true;
                        end loop;
                           if (v_interim = false) then -- not valid concept code
                                v_invalid_concepts := v_invalid_concepts || ' ' || v_cncpt_nm;
                            end if;
               
                end loop;
                   if (v_item_typ_id = 7) then
                for i in  cnt+2..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, '');
                end loop;
                end if;
                   if (v_item_typ_id = 53) then
                for i in  cnt+1..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, '');
                end loop;
                end if;

            if (v_invalid_concepts is not null) then
            ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || '; Warning: Invalid concept codes: ' ||  v_invalid_concepts);
            end if;
    --            ihook.setColumnValue(rowform, 'ITEM_' || idx || '_NM', v_nm);
  --
            end if;

end if;

if (v_cncpt_src ='DROP-DOWN') then
        v_nm := '';
        v_long_nm_suf :='';
        v_def := '';
        v_long_nm_suf_int:= '';
                for i in 2..10 loop
                        v_temp_id := ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i);
                        v_temp_ver := ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i);
                        if (v_temp_id is not null) then
                        for cur in(select item_id, item_nm , item_long_nm, item_desc from admin_item where admin_item_typ_id = 49 and item_id = v_temp_id and ver_nr = v_temp_ver) loop
                     --            v_def := substr( v_def || '_' ||cur.item_desc  ,1,4000);
                         v_def := substr( v_def || '_' ||cur.item_desc  ,1,4000);

                                if (cur.item_id = v_int_cncpt_id and trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) is not null) then --- integer concept

                                        v_long_nm_suf_int := trim(v_long_nm_suf_int || ':' || cur.item_long_nm) || '::' || trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i));
                                        v_nm := trim(v_nm || ' ' || cur.item_nm) || '::' ||  trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) ;
                                      v_def := v_def || '::' ||  trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i));
                             else
                                    v_long_nm_suf_int := trim(v_long_nm_suf_int || ':' || cur.item_long_nm);
                                v_nm := trim(v_nm || ' ' || cur.item_nm);

                                end if;
                            v_long_nm_suf := trim(v_long_nm_suf || ':' || cur.item_long_nm);

                         end loop;
                        end if;
                end loop;

  end if;
        --- Primary Concept
             for cur in (select item_id, item_nm , item_long_nm, item_desc from admin_item where admin_item_typ_id = 49 and item_id = ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_ITEM_ID_1')
             and ver_nr  = ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_1')) loop
                          --       v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                              v_long_nm_suf := trim(v_long_nm_suf || ':' || cur.item_long_nm);
                                                  v_def := substr( v_def || '_' ||cur.item_desc  ,1,4000);
                               if (cur.item_id = v_int_cncpt_id and trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) is not null) then --- integer concept
                                        v_long_nm_suf_int := trim(v_long_nm_suf_int || ':' || cur.item_long_nm) || '::' || trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_1')) ;
                                        v_nm := trim(v_nm || ' ' || cur.item_nm) || '::' ||  trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_1' )) ;
                          --      v_def := substr(cur.item_desc || '::' || trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) || '_' || v_def,1,4000);
                                                               v_def := v_def || '::' ||  trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i));

                     else
                                    v_long_nm_suf_int := trim(v_long_nm_suf_int || ':' || cur.item_long_nm);
                                v_nm := trim(v_nm || ' ' || cur.item_nm);
                                --                  v_def := substr( cur.item_desc || '_' || v_def,1,4000);
          end if;

                                --raise_application_error(-20000, 'In HEre' || cur.item_long_nm);
             end loop;
            v_long_nm_suf := substr(v_long_nm_suf,2);

     --  raise_application_error(-20000, v_long_nm_suf || '  Long name: ' || v_nm);
                ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM', v_long_nm_suf);
                ihook.setColumnValue(rowform,'ITEM_' || idx || '_NM', v_nm);
               ihook.setColumnValue(rowform,'ITEM_' || idx || '_DEF', substr(v_def,2));
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM_INT', substr(v_long_nm_suf_int,2));

            nci_DEC_MGMT.CncptCombExistsNew (rowform , substr(v_long_nm_suf_int,2), v_item_typ_id, idx , v_item_id, v_ver_nr);
      --      raise_application_error(-20000, 'HErer ' || v_item_id);
 
if (v_mode = 'C') AND V_ITEM_ID  is null then --- Create


        v_id := nci_11179.getItemId;

       rows := t_rows();
   --     raise_application_error(-20000,'OC');
          j := 1;
 --     v_nm := '';
       v_long_nm := '';
  --     v_def := '';
          for i in reverse 2..10 loop

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
                  ihook.setColumnValue(row,'NCI_PRMRY_IND', 0);

            v_temp := v_temp || i || ':' ||  v_cncpt_id;
                --   v_def := substr( cur.item_desc || '_' || v_def,1,4000);

                  if (v_cncpt_id = v_int_cncpt_id and trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) is not null) then
                        --    v_nm := trim(cur.item_nm) ||  '::' || trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) || ' ' || v_nm ;
                            ihook.setColumnValue(row,'NCI_CNCPT_VAL',ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i));
      
                        end if;
            rows.extend;
            rows(rows.last) := row;

            v_long_nm := cur.item_long_nm || ':' || v_long_nm   ;
            j := j+ 1;
        end loop;
        end if;
        end loop;


          v_cncpt_id := ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_1' );
             v_cncpt_ver_nr :=  ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_1' );
           for cur in (select item_nm, item_long_nm, item_desc from admin_item where item_id = v_cncpt_id and ver_nr = v_cncpt_ver_nr) loop
            row := t_row();
            ihook.setColumnValue(row,'ITEM_ID', v_id);
            ihook.setColumnValue(row,'VER_NR', 1);
            ihook.setColumnValue(row,'CNCPT_ITEM_ID',v_cncpt_id);
            ihook.setColumnValue(row,'CNCPT_VER_NR', v_cncpt_ver_nr);
            ihook.setColumnValue(row,'NCI_ORD', 0);
            ihook.setColumnValue(row,'NCI_PRMRY_IND', 1);
               --      v_def := substr( v_def  || cur.item_desc,1,4000 ) ;

            v_temp := v_temp || i || ':' ||  v_cncpt_id;
                 if (v_cncpt_id = v_int_cncpt_id and trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) is not null) then
                    --        v_nm := trim(cur.item_nm) ||  '::' || trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) || ' ' || v_nm ;
                            ihook.setColumnValue(row,'NCI_CNCPT_VAL',ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i));
                --                  v_def := substr(cur.item_desc || '::' || trim(ihook.getColumnValue(rowform,'CNCPT_INT_' || idx || '_' || i)) || '_' || v_def,1,4000);

                   --     else
                     --       v_nm := trim(cur.item_nm) || ' ' || v_nm ;
               --                     v_def := substr( cur.item_desc || '_' || v_def,1,4000);
                end if;

            rows.extend;
            rows(rows.last) := row;
            v_long_nm := v_long_nm  || cur.item_long_nm    ;
        end loop;


       action := t_actionrowset(rows, 'Items under Concept (Hook)', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;

        rows := t_rows();
        row := t_row();
        v_long_nm := substr(v_long_nm,1, length(v_long_nm)-1);
        v_nm := substr(trim(v_nm),1, c_nm_len);
        -- if lenght of short name is greater than 30, then use IDv1.00
        if (length(v_long_nm) > 30) then
            v_long_nm := v_id || c_ver_suffix;
        end if;

    -- raise_application_error (-20000, v_nm || '$$$' || v_long_nm);
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', v_item_typ_id);
        ihook.setColumnValue(row,'ADMIN_STUS_ID',66 );
               ihook.setColumnValue(row,'REGSTR_STUS_ID',9 );
               -- Context is NCIP for RT
                  ihook.setColumnValue(row,'CNTXT_ITEM_ID',20000000024); -- NCIP
        ihook.setColumnValue(row,'CNTXT_VER_NR', 1);

   --     ihook.setColumnValue(row,'ITEM_LONG_NM', v_long_nm);
   -- REp Term short name change to IDvVersion
    ihook.setColumnValue(row,'ITEM_LONG_NM', nci_11179_2.getStdShortName(v_id, 1));
        ihook.setColumnValue(row,'ITEM_DESC', substr(v_def, 2));
        ihook.setColumnValue(row,'ITEM_NM', v_nm);
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', 20000000024);
        ihook.setColumnValue(row,'CNTXT_VER_NR', 1);
        ihook.setColumnValue(row,'CNCPT_CONCAT', v_long_nm_suf);
        ihook.setColumnValue(row,'CNCPT_CONCAT_DEF', substr(v_def,2));
        ihook.setColumnValue(row,'CNCPT_CONCAT_NM', v_nm);
        ihook.setColumnValue(row,'CNCPT_CONCAT_WITH_INT', substr(v_long_nm_suf_int,2));

        rows.extend;
        rows(rows.last) := row;
    -- raise_application_error(-20000, 'HEre ' || v_nm || v_long_nm || v_def);
     /*   ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM', v_long_nm);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_DEF', substr(v_def, 1, length(v_def)-1));
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_NM', v_nm); */
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
	   when 7 then v_obj_nm := 'Representation Class';

        end case;
        action := t_actionrowset(rows, v_obj_nm, 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
end if;

end;

procedure val_data_typ (imp_dttype in varchar2, out_dttype out number) as
v_dttype number;
begin
    select dttype_id into out_dttype from data_typ where dttype_nm = imp_dttype and nci_dttype_typ_id = 1;
    exception
    when NO_DATA_FOUND
    then out_dttype := null;
    
end;

-- v_mode : V - Validate, C - Validation and Create;  v_cncpt_src:  STRING: String; DROP-DOWN: Drop-downs
procedure VDImportPost(rowform in out t_row,  idx in integer,v_item_typ_id in integer,v_mode in varchar2, v_cncpt_src in varchar2, actions in out t_actions) as
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
 v_long_nm_suf_int varchar2(255);
 j integer;
i integer;
cnt integer;
v_str varchar2(255);
v_str1 varchar2(255);
v_obj_nm  varchar2(100);
v_temp varchar2(4000);
v_cncpt_nm varchar2(255);
v_interim boolean;
v_invalid_concepts  varchar2(4000);
v_found boolean;
v_prmry_rep_term_cncpt varchar2(32);
v_count integer;
v_match_ct integer;

begin

if (v_cncpt_src ='STRING') then
      if (ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_' || idx) is not null) then
                v_str := trim(ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_'|| idx));
                v_str1 := replace(v_str,chr(9),'');
                cnt := nci_11179.getwordcount(v_str1);
                v_nm := '';
                v_long_nm := '';
                v_long_nm_suf := '';
                v_long_nm_suf_int := '';
                v_def := '';
                 for i in 1..10 loop
                           ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                            ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, ''); 
                   
  end loop;
                for i in  1..cnt loop
          --      if (v_item_typ_id = 7) then
           --             j := i+1;
            --    else
            if (i = cnt) then
                      j :=1;
                    else j := i+1;
                end if;
                
 
                       v_cncpt_nm := trim(nci_11179.getWord(v_str1, i, cnt));
                        -- jira 1939- make sure the query returns something- if not, return the invalid concept in the validation message
                        select count(*) into v_count from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm));
                          -- and admin_stus_nm_dn = 'RELEASED';
                        if (v_count = 0) then
                            ihook.setColumnValue(rowform, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_IMPORT_VAL_MSG') || 'ERROR: Invalid or No Concepts: ' || v_cncpt_nm || chr(13));
                        end if; 
                           for cur in(select item_id, ver_nr, item_nm , item_long_nm, item_desc, admin_stus_nm_dn 
                           from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
                      --     and admin_stus_nm_dn = 'RELEASED') loop
                    -- raise_application_error(-20000, cur.item_id);
                            if (cur.admin_stus_nm_dn = 'RELEASED') then
                            ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || j,cur.item_id);
                            ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || j, cur.ver_nr); 
                            end if;
                            if (cur.admin_stus_nm_dn like '%RETIRED%') then
                                          ihook.setColumnValue(rowform, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_IMPORT_VAL_MSG') || 'ERROR: Retired Concept: ' || v_cncpt_nm 
                                          || ' ' || cur.item_nm  || chr(13));
                            end if;
                 end loop;
      
                /*
                        v_interim := false;
                        v_cncpt_nm := nci_11179.getWord(v_str, i, cnt);
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || j,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || j, '');
                     if (j > 1) then   for cur in (select item_id, item_nm , item_long_nm, item_desc from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm)) and admin_item.admin_stus_nm_dn = 'RELEASED') loop
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || j,cur.item_id);
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || j, 1);
                               -- v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                                v_long_nm_suf := trim(v_long_nm_suf || ':' || cur.item_long_nm);
                                v_long_nm_suf_int := trim(v_long_nm_suf_int || ':' || cur.item_long_nm);
                                v_nm := trim(v_nm || ' ' || cur.item_nm);
                              v_def := substr( v_def || '_' ||cur.item_desc  ,1,4000);
                        v_interim := true;
                        end loop;   
                        end if;
                     if (j = 1) then   
                     for cur in (select ai.item_id, item_nm , item_long_nm, item_desc from admin_item ai, cncpt c where admin_item_typ_id = 49 
                     and upper(item_long_nm) = upper(trim(v_cncpt_nm)) and ai.admin_stus_nm_dn = 'RELEASED' and nvl(PRMRY_CNCPT_IND,0)=1
                     and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr) loop
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || j,cur.item_id);
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || j, 1);
                               -- v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                                v_long_nm_suf := trim(v_long_nm_suf || ':' || cur.item_long_nm);
                                v_long_nm_suf_int := trim(v_long_nm_suf_int || ':' || cur.item_long_nm);
                                v_nm := trim(v_nm || ' ' || cur.item_nm);
                              v_def := substr( v_def || '_' ||cur.item_desc  ,1,4000);
                        v_interim := true;
                        end loop;   
                        end if;
                        
                        if (v_interim = false) then -- not valid concept code
                            v_invalid_concepts := v_invalid_concepts || ' ' || v_cncpt_nm;
                       end if;
                end loop;
                   if (v_item_typ_id = 7) then
                for i in  cnt+2..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, '');*/


                    
                
                end loop;
                -- jira 2288
                v_match_ct := 0;
                v_found := false;
                
                for cur in (select ITEM_NM, ITEM_LONG_NM from VW_CNCPT_RT_PRMRY) loop
                    if (cur.ITEM_LONG_NM = ihook.getColumnValue(rowform, 'PRMRY_REP_TERM')) then
                        v_found := true;
                        if (cur.ITEM_NM = ihook.getColumnValue(rowform, 'PRMRY_REP_TERM_NM')) then
                            v_match_ct := v_match_ct + 1;
                        end if;
                    end if;
                end loop;
                if (v_found = false) then
                    ihook.setColumnValue(rowform, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_IMPORT_VAL_MSG') || chr(13) || 'ERROR: Invalid Primary Rep Term Concept: ' || ihook.getColumnValue(rowform, 'PRMRY_REP_TERM'));
                end if;
               -- if (v_match_ct < 1) then
                --    ihook.setColumnValue(rowform, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_IMPORT_VAL_MSG') || chr(13) || 'ERROR: Primary Rep Term Code and Name do not match.');
                --end if;
 
                -- jira 2288
                if (ihook.getColumnValue(rowform, 'UOM_ID') is null and ihook.getColumnValue(rowform, 'IMP_UOM') is not null) then
                    ihook.setColumnValue(rowform, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_IMPORT_VAL_MSG' ) || chr(13) || 'ERROR: Invalid Unit of Measure: ' || ihook.getColumnValue(rowform, 'IMP_UOM'));
                end if;
                if (ihook.getColumnValue(rowform, 'VAL_DOM_FMT_ID') is null and ihook.getColumnValue(rowform, 'IMP_DISP_FMT') is not null) then
                    ihook.setColumnValue(rowform, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_IMPORT_VAL_MSG' ) || chr(13) || 'ERROR: Invalid Display Format: ' || ihook.getColumnValue(rowform, 'IMP_DISP_FMT'));
                end if;
                   -- val_data_typ(ihook.getColumnValue(rowform, 'IMP_DTTYPE'), v_dttype);
--                    v_imp_dttype := ihook.getColumnValue(rowform, 'IMP_DTTYPE');
--                    v_dttype := null;
--                    select dttype_id into v_dttype from data_typ where dttype_nm = v_imp_dttype and nci_dttype_typ_id = 1;
                if (ihook.getColumnValue(rowform, 'DTTYPE_ID') is null and ihook.getColumnValue(rowform, 'IMP_DTTYPE' ) is not null) then
                    ihook.setColumnValue(rowform, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_IMPORT_VAL_MSG' ) || chr(13) || 'ERROR: Invalid Source Data Type: ' || ihook.getColumnValue(rowform, 'IMP_DTTYPE'));
                end if;

                if (ihook.getColumnValue(rowform, 'VAL_DOM_TYP_ID') is null and ihook.getColumnValue(rowform, 'IMP_VD_TYP') is not null) then
                    ihook.setColumnValue(rowform, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_IMPORT_VAL_MSG' ) || chr(13) || 'ERROR: Invalid VD Type: ' || ihook.getColumnValue(rowform, 'IMP_VD_TYP'));
                end if;
                
                
            end if;
                if (ihook.getColumnValue(rowform, 'DTTYPE_ID') is not null and ihook.getColumnValue(rowform, 'NCI_STD_DTTYPE_ID' ) is null) then
              ihook.setColumnValue(rowform, 'NCI_STD_DTTYPE_ID', nci_11179_2.getStdDataType(ihook.getColumnValue(rowform, 'DTTYPE_ID')));
            end if;
                
    --            ihook.setColumnValue(rowform, 'ITEM_' || idx || '_NM', v_nm);
  --
       --     end if;
  /*if (v_invalid_concepts is not null) then
  -- jira 1670.1 change warning to error and specify Primary Rep term concept
            ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'Error: Invalid Rep Term Concept code: ' ||  v_invalid_concepts);
            end if;*/
end if;
end;
END;
/
