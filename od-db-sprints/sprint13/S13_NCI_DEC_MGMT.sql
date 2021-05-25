create or replace PACKAGE            nci_DEC_MGMT AS

procedure valUsingStr (rowform in out t_row, k in integer, v_item_typ in integer) ;

-- Common procedure for all AI with concept.

procedure createValAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer, v_mode in varchar2,v_cncpt_src in varchar2,  actions in out t_actions);
procedure createAIWithoutConcept(rowform in out t_row, idx in integer, v_item_typ_id in integer, v_long_nm in varchar2, v_desc in varchar2, actions in out t_actions);

-- New procedures for DEC Create, Create from Existing and Edit.

PROCEDURE spDECCreateNew (v_data_in in clob, v_data_out out clob);
PROCEDURE spDECCreateFrom (v_data_in in clob, v_data_out out clob);
PROCEDURE spDECEdit (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);

-- Common procedure called by new, create from existing or edit

procedure spDECCommon ( v_init in t_rowset,  v_op  in varchar2, v_src in integer, hookInput in t_hookInput, hookOutput in out t_hookOutput);

--Used in Import  v_op - 'V'  validate, 'C' create
procedure spDECValCreateImport ( rowform in out t_row,  v_op  in varchar2, actions in out t_actions, v_val_ind in out boolean);

procedure CncptCombExistsNew (rowform in out t_row, v_item_nm in varchar2, v_item_typ in integer, v_idx in number, v_item_id out number, v_item_ver_nr out number);
-- use getDECQUestion with INSERT or UPDATE as the v_op
function getDECCreateQuestion (v_src in integer) return t_question;
function getDECEditQuestion return t_question;
function getDECQuestion (v_op in varchar2, v_src in integer) return t_question;


procedure createDEC (rowform in t_row, actions in out t_actions, v_id out number);

procedure createDECImport (rowform in out t_row, actions in out t_actions);

-- Get the form for DEC Create
function getDECCreateForm (v_rowset in t_rowset) return t_forms;


END;
/
create or replace PACKAGE BODY            nci_DEC_MGMT AS

-- All DEC creation and import routines.
-- Standard concept-related entity creation

c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';


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
    rowset  t_rowset;
    rowsetst  t_rowset;
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
    ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);
    

    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');

    spDECCommon(rowset, 'insert',2, hookinput, hookoutput);

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
    v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
    rowsetai  t_rowset;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;


    -- Default for new row. Dummy Identifier has to be set else error.
    row := t_row();
    ihook.setColumnValue(row, 'STG_AI_ID', 1);
    ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);
    ihook.setColumnValue(row,'ADMIN_STUS_ID',66);
    ihook.setColumnValue(row,'REGSTR_STUS_ID',9);
        
    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowsetai := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT'); -- Default values for form

    spDECCommon(rowsetai, 'insert',1, hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  --   nci_util.debugHook('GENERAL',v_data_out);
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

    -- check that a selected AI is DEC type
    if (v_item_type_id <> 2) then
        raise_application_error(-20000,'!!! This functionality is only applicable for DEC !!!');
    end if;

    row := row_ori;

    --  Only AI row is submitted with the hook. We need to get the sub-type details and populate the OC/Prop concepts

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


    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');

    spDECCommon(rowset, 'update',3, hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

--nci_util.debugHook('GENERAL', v_data_out);

end;


-- Common routine for DEC - Create or Update
-- v_init is the initial rowset to populate.
-- v_op is insert or update
PROCEDURE       spDECCommon ( v_init in t_rowset,  v_op  in varchar2, v_src in integer, hookInput in t_hookInput, hookOutput in out t_hookOutput)
AS
rowform t_row;
forms t_forms;
form1 t_form;

row t_row;
rows  t_rows;
row_ori t_row;
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

is_valid boolean;
begin
    if hookInput.invocationNumber = 0 then
        --  Get question. Either create or edit
          HOOKOUTPUT.QUESTION    := getDECQuestion(v_op, v_src);

        -- Send initial rowset to create the form.
          hookOutput.forms :=getDECCreateForm(v_init);
    else
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);
        row := t_row();        rows := t_rows();
        is_valid := true;

        if HOOKINPUT.ANSWERID = 1 or Hookinput.answerid = 3 then  -- Validate using string
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

        if HOOKINPUT.ANSWERID = 2 or Hookinput.answerid = 4 then  -- Validate using drop-down
            for k in  1..2  loop -- Both OC and prop
               createValAIWithConcept(rowform , k,4+k,'V','DROP-DOWN',actions);
            end loop;
        end if;

    -- Show generated name
       ihook.setColumnValue(rowform, 'GEN_STR',ihook.getColumnValue(rowform,'ITEM_1_NM') ||  ' ' || ihook.getColumnValue(rowform,'ITEM_2_NM') ) ;
       ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'VALIDATED');
  
    -- Check if DEC is a duplicate. Removed Context from the test as per Denise.
       v_item_id := -1;
  
  -- If update, then need to get the Item_id to exclude from duplicate check
       if (lower(v_op) = 'update') then 
            row_ori :=  hookInput.originalRowset.rowset(1);
            v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
            v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');  
       end if;
       
       if (   ihook.getColumnValue(rowform, 'ITEM_1_ID') is not null and ihook.getColumnValue(rowform, 'ITEM_2_ID') is not null) then
              for cur in (select de_conc.* from de_conc, admin_item ai where obj_cls_item_id =  ihook.getColumnValue(rowform, 'ITEM_1_ID') and obj_cls_ver_nr =  ihook.getColumnValue(rowform, 'ITEM_1_VER_NR') and
               prop_item_id = ihook.getColumnValue(rowform, 'ITEM_2_ID') and prop_ver_nr =  ihook.getColumnValue(rowform, 'ITEM_2_VER_NR') and
              de_conc.item_id = ai.item_id and de_conc.ver_nr = ai.ver_nr and de_conc.item_id <> v_item_id
             ) loop
                    ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'DUPLICATE DEC found:' || cur.item_id || 'v' || cur.ver_nr);
                    is_valid := false;
              end loop;
        end if;
        
        if (   ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is null or ihook.getColumnValue(rowform, 'CNCPT_2_ITEM_ID_1') is null) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'OC or PROP missing.');
                  is_valid := false;
        end if;
        
        -- Short name uniqueness
         for cur in (select ai.* from  admin_item ai where 
             trim(ai.ITEM_LONG_NM)=trim(ihook.getColumnValue(rowform,'ITEM_LONG_NM'))
            and  ai.ver_nr =  NVL(ihook.getColumnValue(rowform, 'VER_NR'),1)            
            and ai.cntxt_item_id = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID') 
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowform, 'CNTXT_VER_NR'))            loop
             ihook.setColumnValue(rowform, 'CTL_VAL_MSG','Unique constraint violated. The DEC '||nci_chng_mgmt.get_AI_id(cur.item_id ,cur.ver_nr )||' with the same Short Name and Context is found.');
                is_valid := false;
           end loop;

         rows := t_rows();

         -- If any of the test fails or if the user has triggered validation, then go back to the screen.
        if (is_valid=false or hookinput.answerid = 1 or hookinput.answerid = 2) then
                rows.extend;
                rows(rows.last) := rowform;
                rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
                hookOutput.forms := getDECCreateForm(rowset);
                HOOKOUTPUT.QUESTION    := getDECQuestion(v_op, v_src);
        end if;

    -- If all the tests have passed and the user has asked for create, then create DEC and optionally OC and Prop.

    IF HOOKINPUT.ANSWERID in ( 3,4)  and is_valid = true THEN  -- Create
        createValAIWithConcept(rowform , 1,5,'C','DROP-DOWN',actions); -- OC
        createValAIWithConcept(rowform , 2,6,'C','DROP-DOWN',actions); -- Property

    --If Create DEC
    if (upper(v_op) = 'INSERT') then
        createDEC(rowform, actions, v_item_id);
        hookoutput.message := 'DEC Created Successfully with ID ' || v_item_id ;
    else
    -- Update DEC. Get the selected row, update name, definition, context.
        row := t_row();
        row_ori :=  hookInput.originalRowset.rowset(1);

        v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');

        --- Update name, definition, context
            row := row_ori;
            ihook.setColumnValue(row, 'ITEM_NM', ihook.getColumnValue(rowform,'GEN_STR'));
            ihook.setColumnValue(row, 'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
            ihook.setColumnValue(row, 'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
            ihook.setColumnValue(row, 'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000));
             rows := t_rows();    rows.extend;    rows(rows.last) := row;
             action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,10,'update');
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
             action := t_actionrowset(rows, 'Data Element Concept', 2,11,'update');
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
begin
    -- Show generated name
    if (ihook.getColumnValue(rowform, 'DE_CONC_ITEM_ID') is null) then --- only execute if not specified
       ihook.setColumnValue(rowform, 'GEN_DE_CONC_NM',ihook.getColumnValue(rowform,'ITEM_1_NM') ||  ' ' || ihook.getColumnValue(rowform,'ITEM_2_NM') ) ;
    -- Check if DEC is a duplicate. Removed Context from the test as per Denise.

        ihook.setColumnValue(rowform, 'DE_CONC_ITEM_ID_FND', '');
        ihook.setColumnValue(rowform, 'DE_CONC_VER_NR_FND', '' );
     --       raise_application_error(-20000, 'Front' ||  ihook.getColumnValue(rowform, 'ITEM_1_ID'));
            
       if (   ihook.getColumnValue(rowform, 'ITEM_1_ID') is not null and ihook.getColumnValue(rowform, 'ITEM_2_ID') is not null) then
              for cur in (select de_conc.* from de_conc, admin_item ai where obj_cls_item_id =  ihook.getColumnValue(rowform, 'ITEM_1_ID') and obj_cls_ver_nr =  ihook.getColumnValue(rowform, 'ITEM_1_VER_NR') and
               prop_item_id = ihook.getColumnValue(rowform, 'ITEM_2_ID') and prop_ver_nr =  ihook.getColumnValue(rowform, 'ITEM_2_VER_NR') and
              de_conc.item_id = ai.item_id and de_conc.ver_nr = ai.ver_nr and ai.currnt_ver_ind = 1
             ) loop
                    ihook.setColumnValue(rowform, 'DE_CONC_ITEM_ID_FND', cur.item_id );
                    ihook.setColumnValue(rowform, 'DE_CONC_VER_NR_FND', cur.ver_nr );
               end loop;
              return;
        end if;
        if (   ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is null or ihook.getColumnValue(rowform, 'CNCPT_2_ITEM_ID_1') is null) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'OC or PROP missing.' || chr(13));
                  v_val_ind:= false;
        end if;
        
            if (   ihook.getColumnValue(rowform, 'CONC_DOM_ITEM_ID') is null ) then
                ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'DEC Conceptual Domain is missing.' || chr(13));
                  v_val_ind:= false;
        end if;

         rows := t_rows();
  
    IF v_val_ind = true and v_op = 'C' and ihook.getColumnValue(rowform, 'DE_CONC_ITEM_ID_FND') is null THEN  -- Create
   -- raise_application_error(-20000, 'here');
        createValAIWithConcept(rowform , 1,5,'C','DROP-DOWN',actions); -- OC
        createValAIWithConcept(rowform , 2,6,'C','DROP-DOWN',actions); -- Property
        createDECImport(rowform, actions);

    end if;
end if;
     -- raise_application_error(-20000,'Inside');


END;


--- Used to create VM with no concepts. Can be used for any Admin Item Type where there are no concepts but a string is to be used for comparison.
procedure createAIWithoutConcept(rowform in out t_row, idx in integer, v_item_typ_id in integer, v_long_nm in varchar2, v_desc in varchar2, actions in out t_actions) as
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


    for cur in (select ai.item_id, ai.ver_nr from nci_admin_item_ext e, admin_item ai where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr 
    and upper(cncpt_concat_nm) = upper(v_long_nm) and ai.admin_item_typ_id = v_item_typ_id) loop
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_ID',cur.item_id);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_VER_NR',cur.ver_nr);
        
        return;
    end loop;        
        v_id := nci_11179.getItemId;
        rows := t_rows();       
        row := t_row();
     
     -- to return values to calling program 
       ihook.setColumnValue(rowform,'ITEM_1_ID', v_id);
       ihook.setColumnValue(rowform,'ITEM_1_VER_NR', 1);
        
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', v_item_typ_id);
        nci_11179_2.setStdAttr(row);
        nci_11179_2.setItemLongNm (row, v_id);
        ihook.setColumnValue(row,'ITEM_DESC',v_desc);
        ihook.setColumnValue(row,'ITEM_NM', v_long_nm);
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'CNCPT_CONCAT', v_long_nm);
        ihook.setColumnValue(row,'CNCPT_CONCAT_DEF',v_long_nm);
        ihook.setColumnValue(row,'CNCPT_CONCAT_NM', v_long_nm);
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
 j integer;
i integer;
cnt integer;
v_str varchar2(255);
v_obj_nm  varchar2(100);
v_temp varchar2(4000);
v_cncpt_nm varchar2(255);
begin

-- If use string to create concept drop-down
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
                        for cur in(select item_id, item_nm , item_long_nm, item_desc from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,cur.item_id);
                                ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, 1);
                               -- v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                                v_long_nm_suf := trim(v_long_nm_suf || ':' || cur.item_long_nm);
                                v_nm := trim(v_nm || ' ' || cur.item_nm);
                                           v_def := substr( v_def || '_' ||cur.item_desc  ,1,4000);
             end loop;
                end loop;
                for i in  cnt+1..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i, '');
                end loop;
            end if;

end if;

-- If drop-downs to be used to check existing or new

if (v_cncpt_src ='DROP-DOWN') then
        v_nm := '';
                for i in 1..10 loop
                        v_temp_id := ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i);
                        v_temp_ver := ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i);
                        if (v_temp_id is not null) then
                        for cur in(select item_id, item_nm , item_long_nm , item_desc from admin_item where admin_item_typ_id = 49 and item_id = v_temp_id and ver_nr = v_temp_ver) loop
                          --       v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                              v_long_nm_suf := trim(v_long_nm_suf || ':' || cur.item_long_nm);
                                v_nm := trim(v_nm || ' ' || cur.item_nm);
                                v_def := substr( v_def || '_' ||cur.item_desc  ,1,4000);
      
                         end loop;
                        end if;
                end loop;

  end if;

                ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM', v_long_nm);
                ihook.setColumnValue(rowform,'ITEM_' || idx || '_NM', v_nm);
             ihook.setColumnValue(rowform,'ITEM_' || idx || '_DEF', v_def);

-- Check if combo exists. If it does, then v_item_id will be set.

    CncptCombExistsNew (rowform , substr(v_long_nm_suf,2), v_item_typ_id, idx , v_item_id, v_ver_nr);

-- If not existing and mode is Create, then create the actions.

    if (v_mode = 'C') AND V_ITEM_ID  is null then --- Create
        v_id := nci_11179.getItemId;
        rows := t_rows();
        j := 0;
        v_nm := '';
        v_long_nm := '';
        v_def := '';
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
                        rows.extend;
                        rows(rows.last) := row;
                        v_nm := trim(cur.item_nm) || ' ' || v_nm ;
                        v_long_nm := cur.item_long_nm || ':' || v_long_nm   ;
                        v_def := substr( cur.item_desc || '_' || v_def,1,4000);
                        j := j+ 1;
                end loop;
            end if;
        end loop;
        
        -- Insert into CNCPT_ADMIN_ITEM
       action := t_actionrowset(rows, 'Items under Concept', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;

        rows := t_rows();        row := rowform;
        v_long_nm := substr(v_long_nm,1, length(v_long_nm)-1);
        v_nm := substr(trim(v_nm),1, c_nm_len);

        -- if lenght of short name is greater than 30, then use IDv1.00
        if (length(v_long_nm) > 30) then
            v_long_nm := v_id || c_ver_suffix;
        end if;
        
    -- Administered Item Row
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', v_item_typ_id);
        nci_11179_2.setStdAttr(row);
        ihook.setColumnValue(row,'ITEM_LONG_NM', v_long_nm);
        ihook.setColumnValue(row,'ITEM_DESC', substr(v_def, 1, length(v_def)-1));
        ihook.setColumnValue(row,'ITEM_NM', v_nm);
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'CNCPT_CONCAT', substr(v_long_nm_suf,2));
        ihook.setColumnValue(row,'CNCPT_CONCAT_DEF', substr(v_def, 1, length(v_def)-1));
        ihook.setColumnValue(row,'CNCPT_CONCAT_NM', v_nm);
          ihook.setColumnValue(row,'LST_UPD_DT',sysdate );

        rows.extend;
        rows(rows.last) := row;
 
        -- Update form Name/Long Name/Definition so uer can see. 
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
    where nvl(a.fld_delete,0) = 0 and a.item_id = ext.item_id and a.ver_nr = ext.ver_nr and cncpt_concat = v_item_nm and a.admin_item_typ_id = v_item_typ) loop
                 ihook.setColumnValue(rowform, 'ITEM_' || v_idx  ||'_ID',cur.item_id);
                 v_item_id := cur.item_id;
                 v_item_ver_nr := cur.ver_nr;
                ihook.setColumnValue(rowform, 'ITEM_' || v_idx || '_VER_NR', cur.ver_nr);
                ihook.setColumnValue(rowform,'ITEM_' || v_idx || '_LONG_NM', cur.cncpt_concat);
                ihook.setColumnValue(rowform,'ITEM_' || v_idx || '_DEF',  cur.CNCPT_CONCAT_DEF);
                ihook.setColumnValue(rowform,'ITEM_' || v_idx || '_NM', cur.CNCPT_CONCAT_NM);

    end loop;
  --raise_application_error(-20000, v_item_nm || '  ' || v_item_id);


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
    ANSWER                     := T_ANSWER(2, 2, 'Validate Using Drop-down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    ANSWER                     := T_ANSWER(4, 4, 'Update Using Drop-down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Edit DEC.', ANSWERS);

return question;
end;

function getDECCreateQuestion (v_src in integer) return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin
-- IF create or Create from Existing DEC
 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Validate Using String');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
  --  ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(2, 2, 'Validate Using Drop-Down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    ANSWER                     := T_ANSWER(3, 3, 'Create Using String');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    ANSWER                     := T_ANSWER(4, 4, 'Create Using Drop-Down');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    if (v_src = 1) then -- Create new
    QUESTION               := T_QUESTION('Create new DEC.', ANSWERS);
    else
    QUESTION               := T_QUESTION('Create DEC from Existing.', ANSWERS);
    end if;

return question;
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
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 2);
   
        if (    ihook.getColumnValue(rowform, 'ITEM_LONG_NM') = v_dflt_txt) then
            ihook.setColumnValue(row,'ITEM_LONG_NM', v_id || c_ver_suffix);
        else
            ihook.setColumnValue(row,'ITEM_LONG_NM', ihook.getColumnValue(rowform, 'ITEM_LONG_NM'));    
        end if;
        
        ihook.setColumnValue(row,'ITEM_NM',  ihook.getColumnValue(rowform, 'ITEM_1_NM')  || ' ' || ihook.getColumnValue(rowform, 'ITEM_2_NM'));
        ihook.setColumnValue(row,'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000));
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'ADMIN_STUS_ID',ihook.getColumnValue(rowform,'ADMIN_STUS_ID'));
         ihook.setColumnValue(row,'REGSTR_STUS_ID',ihook.getColumnValue(rowform,'REGSTR_STUS_ID'));
         
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

--r
end;


procedure createDECImport (rowform in out t_row, actions in out t_actions) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
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
        
      --  raise_application_error (-20000, ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID')  || ihook.getColumnValue(rowform, 'ITEM_1_ID') || ihook.getColumnValue(rowform, 'ITEM_2_ID'));
        ihook.setColumnValue(row,'VER_NR', 1);
        
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 2);
   --     ihook.setColumnValue(row,'ITEM_LONG_NM', ihook.getColumnValue(rowform, 'ITEM_1_LONG_NM')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_LONG_NM'));
            ihook.setColumnValue(row,'ITEM_LONG_NM', v_id || c_ver_suffix);
  
        ihook.setColumnValue(row,'ITEM_NM',  ihook.getColumnValue(rowform, 'GEN_DE_CONC_NM'));
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
 ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'DEC Created Successfully with ID ' || v_id||c_ver_suffix || chr(13)) ;
   
--r
end;
-- Create form for DEC.
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


END;
/
