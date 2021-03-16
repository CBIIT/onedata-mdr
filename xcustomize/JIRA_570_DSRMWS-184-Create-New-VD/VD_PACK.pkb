CREATE OR REPLACE PACKAGE BODY ONEDATA_WA.VD_PACK AS
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
function getVDCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset,v_rowset3 in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    -- v_temp_rep_ver_nr :='0';
    -- v_temp_rep_id:='0';
    forms                  := t_forms();
    form1                  := t_form('Administered Item (Data Element CO)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    form1                  := t_form('Value Domain (Create Hook)', 2,1);
    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;

   
    form1                  := t_form('Rep Term (Hook Creation)', 2,1); 
    form1.rowset :=v_rowset3;
    forms.extend;    forms(forms.last) := form1;

  return forms; 

end;
function getVDcreateQuestion(v_first in Boolean,V_from in number) return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Review/Validate using String');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
  --  ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(2, 2, 'Review/Validate using drop-down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    IF v_first=false then
    ANSWER                     := T_ANSWER(3, 3, 'Create/Edit using String');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    ANSWER                     := T_ANSWER(4, 4, 'Create/Edit using drop-down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    end IF;
    If V_from=1 then
    QUESTION               := T_QUESTION('Create new VD', ANSWERS);
    elsif V_from=2 then
    QUESTION               := T_QUESTION('Create VD from Existing', ANSWERS);
    else
    QUESTION               := T_QUESTION('Edit VD', ANSWERS);
    end if;
return question;
end;

  PROCEDURE       spVDCommon ( v_init_ai in t_rowset, v_init_vd in t_rowset,v_init_rp in t_rowset,v_from in number,  v_op  in varchar2,  hookInput in t_hookInput, hookOutput in out t_hookOutput)
AS
  
  showRowset t_showableRowset;
    rowform t_row;
    forms t_forms;
    form1 t_form;
    rowai t_row;
    rowvd t_row;
    rowrp t_row;  
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
    rowsetvd t_rowset;
    rowsetai t_rowset;
    rowsetrp t_rowset;
    rowset            t_rowset;
     v_rep_nm varchar2(255);
    v_cncpt_nm varchar2(255);
    v_long_nm varchar2(255);
    v_def varchar2(4000);
    is_valid boolean;
    v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
 BEGIN
 
 IF hookInput.invocationNumber = 0 then
          
        hookOutput.question    := getVDCreateQuestion(true,v_from);        
           
        hookOutput.forms := getVDCreateForm(v_init_ai,v_init_vd, v_init_rp);
   
  ELSE
 --          raise_application_error(-20000, 'Here 1');
        forms              := hookInput.forms;
        form1              := forms(1);
        rowai := form1.rowset.rowset(1);
        form1              := forms(2);
        rowvd := form1.rowset.rowset(1);
        form1              := forms(3);
        rowrp := form1.rowset.rowset(1);
        row := t_row();
        rows := t_rows();
        is_valid := true;

     
    IF HOOKINPUT.ANSWERID = 1 or Hookinput.answerid = 3 THEN  -- Validate using string
        
                for i in  1..10 loop
                        ihook.setColumnValue(rowrp, 'CNCPT_1_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowrp, 'CNCPT_1_VER_NR_' || i, '');
                end loop;        
   --     raise_application_error(-20000, 'Here');      
                createValAIWithConcept(rowrp , 1,7,'V','STRING',actions);
     
    end if;
    
    IF HOOKINPUT.ANSWERID = 2 or Hookinput.answerid = 4 THEN  -- Validate using drop-down       
                  createValAIWithConcept(rowrp , 1,7,'V','DROP-DOWN',actions);          
    end if;

      
       ihook.setColumnValue(rowrp, 'GEN_STR',ihook.getColumnValue(rowrp,'ITEM_1_NM')  ) ;
       ihook.setColumnValue(rowrp, 'CTL_VAL_MSG', 'VALIDATED');  
       
       if (   ihook.getColumnValue(rowrp, 'ITEM_1_ID') is not null ) then
              for cur in (select VALUE_DOM.* from VALUE_DOM, admin_item ai 
              where REP_CLS_ITEM_ID =  ihook.getColumnValue(rowrp, 'ITEM_1_ID') 
              and REP_CLS_VER_NR =  ihook.getColumnValue(rowrp, 'ITEM_1_VER_NR') 
              and VALUE_DOM.item_id = ai.item_id and VALUE_DOM.ver_nr = ai.ver_nr 
              and ai.cntxt_item_id = ihook.getColumnValue(rowrp, 'CNTXT_ITEM_ID')
              and ai.cntxt_ver_nr = ihook.getColumnValue(rowrp, 'CNTXT_VER_NR'))
             loop
                    ihook.setColumnValue(rowrp, 'CTL_VAL_MSG', 'DUPLICATE VD');
                    is_valid := false;
              end loop;
             
        end if; 
     
        if (   ihook.getColumnValue(rowrp, 'CNCPT_1_ITEM_ID_1') is null ) then
                  ihook.setColumnValue(rowrp, 'CTL_VAL_MSG', 'Rep Term missing.');
                  is_valid := false;
        end if;

         rows := t_rows();
        if is_valid=false or hookinput.answerid in (1, 2) then
                
                rows.extend;
                rows(rows.last) := rowform;
                rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
                rows.extend;
                rows(rows.last) := rowform;
                rowsetvd := t_rowset(rows, 'Value Domain', 1, 'VALUE_DOM'); 
                rows.extend;
                rows(rows.last) := rowform;
                rowsetrp := t_rowset(rows, 'Rep Term', 1, 'NCI_STG_AI_CNCPT_CREAT');
                hookOutput.forms := getVDCreateForm(rowsetai, rowsetvd,rowsetrp);             
                HOOKOUTPUT.QUESTION    := getVDCreateQuestion(false,v_from);
        end if;
    -- raise_application_error(-20000, 'Here2');    
    IF HOOKINPUT.ANSWERID in ( 3,4)  and is_valid = true THEN  -- Create
        createValAIWithConcept(rowrp , 1,7,'C','DROP-DOWN',actions); -- Rep
       
        if (v_op = 'insert') then
             v_id := nci_11179.getItemId;
             ihook.setColumnValue(rowai,'ITEM_ID', v_id);
              ihook.setColumnValue(rowai,'VER_NR', 1);
        end if;
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 3);
        ihook.setColumnValue(rowai,'ITEM_NM', v_item_nm);
        ihook.setColumnValue(rowai,'ITEM_DESC', v_item_desc);

        rows := t_rows();        rows.extend;        rows(rows.last) := rowai;
        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,v_op);
        actions(actions.last) := action;

        ihook.setColumnValue(rowvd,'ITEM_ID',  ihook.getColumnValue(rowai,'ITEM_ID'));
        ihook.setColumnValue(rowvd,'VER_NR', ihook.getColumnValue(rowai,'VER_NR'));
        rows := t_rows();        rows.extend;        rows(rows.last) := rowvd;
        action := t_actionrowset(rows, 'Value Domain', 2,2,v_op);
        actions.extend;
        actions(actions.last) := action;
        --nci_chng_mgmt.createDEC(rowform, actions, v_item_id);
        hookoutput.message := 'VD Created Successfully with ID ' || v_item_id ;
        hookoutput.actions := actions;
    
    end if;
  
end if;
   
 --V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 

END;  

PROCEDURE spVDCreateFrom ( v_data_in IN CLOB, v_data_out OUT CLOB) as
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
    rowset  t_rowset;
    rowsetst  t_rowset;
    rowsetai  t_rowset;
    rowsetrp  t_rowset;
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

    -- check that a selected AI is VD type
    if (v_item_type_id <> 3) then -- 3 - VALUE DOMAIN in table OBJ_KEY
        raise_application_error(-20000,'!!! This functionality is only applicable for VD !!!');
    end if;


    row := row_ori;
 
select obj_cls_item_id, obj_cls_ver_nr, prop_item_id, prop_ver_nr, conc_dom_item_id, conc_dom_ver_nr into v_oc_item_id, v_oc_ver_nr, v_prop_item_id, v_prop_ver_nr ,
v_conc_dom_item_id, v_conc_dom_ver_nr
from de_conc where item_id = v_item_id and ver_nr = v_ver_nr;

     -- Copy subtype specific attributes
    nci_11179.spReturnConceptRow (v_oc_item_id, v_oc_ver_nr, 7, 1, row );
   
    ihook.setColumnValue(row, 'STG_AI_ID', 1);
     ihook.setColumnValue(row, 'CONC_DOM_ITEM_ID', v_conc_dom_item_id);
    ihook.setColumnValue(row, 'CONC_DOM_VER_NR', v_conc_dom_ver_nr);
   
    
     rows := t_rows();    rows.extend;    rows(rows.last) := row;
     rowset := t_rowset(rows, 'Rep Term With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
     
   spVDCommon(rowsetai, rowsetst, rowsetrp, 3, 'insert', hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;


PROCEDURE spVDCreateNew ( v_data_in IN CLOB, v_data_out OUT CLOB)
as
  hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_item_id  number;
    v_ver_nr  number(4,2);
    v_ori_rep_cls number;
    v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
    rowsetai  t_rowset;
    rowsetst  t_rowset;
    rowsetrp  t_rowset;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;


  --raise_application_error(-20000,'Herer2');
         row := t_row();      
          rows := t_rows();
     
    ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
    ihook.setColumnValue(row, 'VER_NR', 1.0);
    ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
    ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);  
    ihook.setColumnValue(row, 'ITEM_DESC',v_dflt_txt); -- Default values
    ihook.setColumnValue(row, 'ITEM_NM', v_dflt_txt); -- Default values
    ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt); -- Default values
    rows := t_rows(); rows.extend;    rows(rows.last) := row; 
 
    rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for  AI from
    rows := t_rows(); rows.extend;    rows(rows.last) := row;
    rowsetst := t_rowset(rows, 'Value Domain', 1, 'VALUE_DOM'); -- Default values VD for from
    rows := t_rows(); rows.extend;    rows(rows.last) := row;
    row := t_row();   
    ihook.setColumnValue(row, 'STG_AI_ID', 1);
    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowsetrp := t_rowset(rows, 'Rep Term', 1, 'NCI_STG_AI_CNCPT_CREAT'); -- Default values for form
 
 --if (hookInput.invocationNumber = 1) Then
 --raise_application_error(-20000,'Herer2');
 
 --end if;
 
  --  spVDCommon(rowsetai, 'insert', hookinput, hookoutput);
  spVDCommon(rowsetai,rowsetst,rowsetrp,1, 'insert', hookinput, hookoutput);


    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;

PROCEDURE spVDEdit ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
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
    rowsetrp  t_rowset;
    rowsetai  t_rowset;
    rowsetst  t_rowset;
    rowset  t_rowset;

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

    -- check that a selected AI is VD type
    if (v_item_type_id <> 3) then -- 3 - VALUE DOMAIN in table OBJ_KEY
        raise_application_error(-20000,'!!! This functionality is only applicable for VD !!!');
    end if;


    row := row_ori;
 
select obj_cls_item_id, obj_cls_ver_nr, prop_item_id, prop_ver_nr, conc_dom_item_id, conc_dom_ver_nr into v_oc_item_id, v_oc_ver_nr, v_prop_item_id, v_prop_ver_nr ,
v_conc_dom_item_id, v_conc_dom_ver_nr
from de_conc where item_id = v_item_id and ver_nr = v_ver_nr;

     -- Copy subtype specific attributes
    nci_11179.spReturnConceptRow (v_oc_item_id, v_oc_ver_nr, 7, 1, row );
    
    ihook.setColumnValue(row, 'STG_AI_ID', 1);
     ihook.setColumnValue(row, 'CONC_DOM_ITEM_ID', v_conc_dom_item_id);
    ihook.setColumnValue(row, 'CONC_DOM_VER_NR', v_conc_dom_ver_nr);
   
    
rows := t_rows();    rows.extend;    rows(rows.last) := row;
     rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
     
    --spVDCommon(rowset, 'update', hookinput, hookoutput);
spVDCommon(rowsetai, rowsetst, rowsetrp, 2, 'update', hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

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
 j integer;
i integer;
cnt integer;
v_str varchar2(255);
v_obj_nm  varchar2(100);
v_temp varchar2(4000);
v_cncpt_nm varchar2(255);
begin

if (v_cncpt_src ='STRING') then
      if (ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_' || idx) is not null) then
                v_str := trim(ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_'|| idx));
                cnt := nci_11179.getwordcount(v_str);
                v_nm := '';
                v_long_nm := '';
                for i in  1..cnt loop
                        v_cncpt_nm := nci_11179.getWord(v_str, i, cnt);
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, '');
                        for cur in(select item_id, item_nm , item_long_nm from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,cur.item_id);
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, 1);
                               -- v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                                v_long_nm_suf := trim(v_long_nm_suf || '_' || cur.item_long_nm);
                                v_nm := trim(v_nm || ' ' || cur.item_nm);
                        end loop;
                end loop;
                for i in  cnt+1..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, '');
                end loop;
    --            ihook.setColumnValue(rowform, 'ITEM_' || idx || '_NM', v_nm);
  --
            end if;
      
end if;


if (v_cncpt_src ='DROP-DOWN') then
        v_nm := '';
                for i in 1..10 loop
                        v_temp_id := ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i);
                        v_temp_ver := ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i);
                        if (v_temp_id is not null) then
                        for cur in(select item_id, item_nm , item_long_nm from admin_item where admin_item_typ_id = 49 and item_id = v_temp_id and ver_nr = v_temp_ver) loop
                          --       v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                              v_long_nm_suf := trim(v_long_nm_suf || '_' || cur.item_long_nm);
                                v_nm := trim(v_nm || ' ' || cur.item_nm);
                         end loop;
                        end if;
                end loop;
          
  end if;
        
      --  raise_application_error(-20000, v_long_nm);
                ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM', v_long_nm);
                ihook.setColumnValue(rowform,'ITEM_' || idx || '_NM', v_nm);
        
            CncptCombExistsNew (rowform , substr(v_long_nm_suf,2), v_item_typ_id, idx , v_item_id, v_ver_nr);

       
if (v_mode = 'C') AND V_ITEM_ID  is null then --- Create


        v_id := nci_11179.getItemId;

       rows := t_rows();
   --     raise_application_error(-20000,'OC');
          j := 0;
      v_nm := '';
       v_long_nm := '';
       v_def := '';
          for i in reverse 0..10 loop
 
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
            v_def := substr( cur.item_desc || '_' || v_def,1,4000);
            j := j+ 1;
        end loop;
        end if;
        end loop;
       action := t_actionrowset(rows, 'Items under Concept', 2,6,'insert');
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
        ihook.setColumnValue(row,'ITEM_LONG_NM', v_long_nm);
        ihook.setColumnValue(row,'ITEM_DESC', substr(v_def, 1, length(v_def)-1));
        ihook.setColumnValue(row,'ITEM_NM', v_nm);
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'CNCPT_CONCAT', substr(v_long_nm_suf,2));
        ihook.setColumnValue(row,'CNCPT_CONCAT_DEF', substr(v_def, 1, length(v_def)-1));
        ihook.setColumnValue(row,'CNCPT_CONCAT_NM', v_nm);
     
        rows.extend;
        rows(rows.last) := row;
    -- raise_application_error(-20000, 'HEre ' || v_nm || v_long_nm || v_def);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM', v_long_nm);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_DEF', substr(v_def, 1, length(v_def)-1));
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
	   when 7 then v_obj_nm := 'Representation Term';
       
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

    for cur in (select ext.* from nci_admin_item_ext ext,admin_item a 
    where nvl(a.fld_delete,0) = 0 and a.item_id = ext.item_id and a.ver_nr = ext.ver_nr and cncpt_concat = v_item_nm and a.admin_item_typ_id = v_item_typ) loop
                 ihook.setColumnValue(rowform, 'ITEM_' || v_idx  ||'_ID',cur.item_id);
                 v_item_id := cur.item_id;
                 v_item_ver_nr := cur.ver_nr;
                ihook.setColumnValue(rowform, 'ITEM_' || v_idx || '_VER_NR', cur.ver_nr);
                ihook.setColumnValue(rowform,'ITEM_' || v_idx || '_LONG_NM', cur.cncpt_concat);
                ihook.setColumnValue(rowform,'ITEM_' || v_idx || '_DEF',  cur.CNCPT_CONCAT_DEF);
                ihook.setColumnValue(rowform,'ITEM_' || v_idx || '_NM', cur.CNCPT_CONCAT_NM);
          
    end loop;
    
    
              
end;



procedure valUsingStr (rowform in out t_row, k in integer, v_item_typ in integer) as
i integer;
v_str varchar2(255);
cnt integer;
v_nm varchar2(255);
v_cncpt_nm varchar2(255);
v_def varchar2(255);
v_dec_nm varchar2(255);
v_item_id number;
v_ver_nr number;
v_long_nm varchar2(255);
begin

           for i in  1..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                end loop;
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
                                v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                                v_nm := trim(v_nm || ':' || cur.item_long_nm);
                        end loop;
                end loop;
                for i in  cnt+1..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                end loop;
     
                nci_11179.CncptCombExists(substr(v_nm,2),v_item_typ,v_item_id, v_ver_nr,v_long_nm, v_def);
                ihook.setColumnValue(rowform, 'ITEM_' || k  ||'_ID',v_item_id);
                ihook.setColumnValue(rowform, 'ITEM_' || k || '_VER_NR', v_ver_nr);
                ihook.setColumnValue(rowform,'ITEM_' || k || '_LONG_NM', trim(substr(v_nm,2)));
                ihook.setColumnValue(rowform,'ITEM_' || k || '_DEF', v_def);
                ihook.setColumnValue(rowform,'ITEM_' || k || '_NM', v_long_nm);
            end if;
            
            end;



END;
/