create or replace PACKAGE nci_dload AS
  procedure spCreateDloadProfile (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
  procedure spTriggerDload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
  procedure spAddComponentToDload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
   procedure spAddComponentToDloadID (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
   function getAddComponentCreateQuestion return t_question;
function getALSCreateQuestion return t_question;
function getALSCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;

END;
/
create or replace PACKAGE BODY nci_dload AS

c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';


-- Generic create question
function getAddComponentCreateQuestion return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Select and click on Add.', ANSWERS);

return question;
end;

    -- Not used at this time.
procedure spCreateDloadProfile (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    forms t_forms;
    form1 t_form;
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowsethdr            t_rowset;
    rowsetals            t_rowset;

    rows  t_rows;
    rowhdr t_row;
    rowals t_row;
    v_item_id  number;
    v_ver_nr number(4,2);
    v_temp integer;
    v_add integer :=0;
    v_already integer :=0;
    i integer := 0;
    v_id number;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    if (hookinput.invocationnumber = 0) then -- show create form
        rows := t_rows();
        row := t_row();
        ihook.setColumnValue(row, 'HDR_ID', -1);
        ihook.setColumnValue(row, 'DLOAD_FMT_ID',90 );
        rows.extend;          rows(rows.last) := row;
          rowsethdr := t_rowset(rows, 'Download Header', 1, 'NCI_DLOAD_HDR');
        rows := t_rows();
        row := t_row();
            ihook.setColumnValue(row, 'HDR_ID', -1);
        rows.extend;          rows(rows.last) := row;
          rowsetals := t_rowset(rows, 'ALS Specific', 1, 'NCI_DLOAD_HDR');
          
          hookOutput.forms := getALSCreateForm(rowsethdr, rowsetals);
          HOOKOUTPUT.QUESTION    := getALSCreateQuestion;
    else --- Second invocation
         forms              := hookInput.forms;
 
           form1              := forms(1);
      rowhdr := form1.rowset.rowset(1);
      form1              := forms(2);
      rowals := form1.rowset.rowset(1);
        v_id := nci_11179_2.getCollectionId;
        ihook.setColumnValue(rowhdr, 'HDR_ID', v_id);
        ihook.setColumnValue(rowals, 'HDR_ID', v_id);
           ihook.setColumnValue(rowhdr, 'DLOAD_FMT_ID',90 );
     
       rows := t_rows();
    rows.extend;
    rows(rows.last) := rowhdr;
    action := t_actionrowset(rows, 'Download Header (Hook)', 2,1,'insert');
    actions.extend;
    actions(actions.last) := action;
      rows := t_rows();
    rows.extend;
    rows(rows.last) := rowals;
    action := t_actionrowset(rows,'ALS Specific', 2,2,'insert');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    hookoutput.message := 'Collection Successfully Created with ID ' || v_id;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     nci_util.debugHook('GENERAL', v_data_out);
END;

-- This is to call Irina's program.
procedure spTriggerDload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_item_id  number;
    v_ver_nr number(4,2);
    v_temp integer;
    v_add integer :=0;
    v_already integer :=0;
    i integer := 0;

begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        hookoutput.message := 'Work in progress.';
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

-- Add from Cart.
procedure spAddComponentToDload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
    v_item_id  number;
    v_ver_nr number(4,2);
    v_temp integer;
    v_add integer :=0;
    v_already integer :=0;
    i integer := 0;
    v_item_typ_id integer;
    v_found boolean;

    showrowset	t_showablerowset;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset(1);
    -- 92 - FOrm, 93 - CDE
    -- Depending on the type of collection, show either Forms or CDE's

    if (hookinput.invocationnumber = 0) then
        if (ihook.getColumnValue(row_ori,'DLOAD_TYP_ID') = 92) then
            v_item_typ_id := 54;
            else v_item_typ_id := 4;
        end if;
        rows := t_rows();

        -- Get items from user cart based on type
        for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_usr_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id = v_item_typ_id order by admin_item_typ_id) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   iHook.setcolumnvalue (ROW, 'CNTCT_SECU_ID', v_usr_id);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'User Cart', 2, 'multi');
       	 hookoutput.showrowset := showrowset;
        hookOutput.question := getAddComponentCreateQuestion;
     else
        hookoutput.message := 'Please add forms or CDE to your cart.';
     end if;
	end if; -- First invocation

    if hookInput.invocationNumber = 1  then -- Items selected from cart. Second invocation
       rows := t_rows();
       for i in 1..hookInput.selectedRowset.rowset.count loop -- Loop thru all the selected items.
          row_sel := hookInput.selectedRowset.rowset(i);

          ihook.setColumnValue(row_sel, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));

          -- Add only if not already in collection.
          select count(*) into v_temp from nci_dload_dtl where hdr_id = ihook.getColumnValue(row_ori,'HDR_ID') and item_id = ihook.getColumnValue(row_sel,'ITEM_ID')
          and ver_nr = ihook.getColumnValue(row_sel,'VER_NR');
          if (v_temp = 0) then
          	   rows.extend;
                rows (rows.last) := row_sel;
           end if;
        end loop;

        -- If something to add.
        if (rows.count > 0) then
            action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
            actions.extend;
            actions(actions.last) := action;
            hookoutput.actions := actions;
      --  hookoutput.message := v_add || ' item(s) added successfully to cart. ' || v_already || ' item(s) selected already in yout cart';
        end if;
    end if;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;



procedure spAddComponentToDloadID (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    row_sel t_row;
    rows  t_rows;
    rowscart  t_rows;
    row_ori t_row;
    v_item_id  number;
    v_ver_nr number(4,2);
    v_temp integer;
    v_add integer :=0;
    v_already integer :=0;
    i integer := 0;
    v_item_typ_id integer;
    v_found boolean;
    v_str varchar2(4000);
    cnt integer;
 forms t_forms;
  form1 t_form;

begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);
        -- 92 - FOrm, 93 - CDE
      -- Depending on the type of collection, show either Forms or CDE's
  if (ihook.getColumnValue(row_ori,'DLOAD_TYP_ID') = 92) then
        v_item_typ_id := 54;
        else v_item_typ_id := 4;
    end if;

    if (hookinput.invocationnumber = 0) then   -- First invocation
         forms                  := t_forms();
        form1                  := t_form('Add Item to Collection (Hook)', 2,1);
        forms.extend;    forms(forms.last) := form1;
        hookoutput.forms := forms;
       	 hookOutput.question := getAddComponentCreateQuestion;
	end if;

    if hookInput.invocationNumber = 1  then  -- Seconf invocation
       rows := t_rows();
       row := t_row();

        forms              := hookInput.forms;
        form1              := forms(1);
        row_sel := form1.rowset.rowset(1);
        v_str := trim(ihook.getColumnValue(row_sel, 'VM_DESC_TXT'));
             cnt := nci_11179.getwordcount(v_str);

        row := t_row();
        rows := t_rows();
        rowscart := t_rows();
        ihook.setColumnValue(row, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));

         for i in  1..cnt loop
                        v_item_id := nci_11179.getWord(v_str, i, cnt);

        -- Only add if item is of the right type and not currently in collection.
        for cur in (select * from admin_item where item_id = v_item_id and currnt_ver_ind = 1 and admin_item_typ_id = v_item_typ_id and (item_id, ver_nr) not in
        (select item_id, ver_nr from nci_dload_dtl where hdr_id = ihook.getColumnValue(row_ori,'HDR_ID'))) loop
            ihook.setColumnValue(row, 'ITEM_ID', cur.item_id);
            ihook.setColumnValue(row, 'VER_NR', cur.ver_nr);
            ihook.setColumnValue(row,'CNTCT_SECU_ID', v_usr_id);
            ihook.setColumnValue(row,'GUEST_USR_NM', 'NONE');
          	rows.extend;
            rows (rows.last) := row;
            -- Add to user cart as well as per curator.
            select count(*) into v_temp from nci_usr_cart where item_id  =cur.item_id and ver_nr = cur.ver_nr and cntct_secu_id = v_usr_id;
              if (v_temp = 0) then
                	rowscart.extend;
                    rowscart (rowscart.last) := row;
              end if;

 end loop;
end loop;
        -- If Item needs to be added.
        if (rows.count > 0) then
            action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
            actions.extend;
            actions(actions.last) := action;
        end if;
            /*  If item not already in cart */
            if (rowscart.count  > 0) then
                action := t_actionrowset(rows, 'User Cart', 2,0,'insert');
                actions.extend;
                actions(actions.last) := action;
            end if;

        if (actions.count > 0) then
            hookoutput.actions := actions;
        end if;
             hookoutput.message := 'Number of items added to collection: ' || rows.count;
   end if;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


function getALSCreateQuestion return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin
    ANSWERS                    := T_ANSWERS();

    ANSWER                     := T_ANSWER(1, 1, 'Create');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;

    QUESTION               := T_QUESTION('Create New Collection', ANSWERS);
return question;
end;

function getALSCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('Download Header (Hook)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    form1                  := t_form('ALS Specific', 2,1);

    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;

END;
/
