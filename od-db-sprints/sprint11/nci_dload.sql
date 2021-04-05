create or replace PACKAGE nci_dload AS
  procedure spCreateDloadProfile (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
  procedure spTriggerDload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
  procedure spAddComponentToDload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
   procedure spAddComponentToDloadID (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
   function getAddComponentCreateQuestion return t_question;

END;
/
create or replace PACKAGE BODY nci_dload AS

c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';


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

    
procedure spCreateDloadProfile (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    forms t_forms;
    form1 t_form;
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

    rows := t_rows();
    if (hookinput.invocationnumber = 0) then -- show create form
         forms                  := t_forms();
         form1                  := t_form('Download Header', 2,1);
        forms.extend;    forms(forms.last) := form1;
        
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

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
    
    if (hookinput.invocationnumber = 0) then
    if (ihook.getColumnValue(row_ori,'DLOAD_TYP_ID') = 92) then
        v_item_typ_id := 54;
        else v_item_typ_id := 4;
    end if;
    rows := t_rows();
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

	end if;
  
    if hookInput.invocationNumber = 1  then
       rows := t_rows();
       for i in 1..hookInput.selectedRowset.rowset.count loop
          row_sel := hookInput.selectedRowset.rowset(i);
          ihook.setColumnValue(row_sel, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));
          select count(*) into v_temp from nci_dload_dtl where hdr_id = ihook.getColumnValue(row_ori,'HDR_ID') and item_id = ihook.getColumnValue(row_sel,'ITEM_ID')
          and ver_nr = ihook.getColumnValue(row_sel,'VER_NR');
          if (v_temp = 0) then
          	   rows.extend;
            rows (rows.last) := row_sel;
           end if;
        end loop;
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
    row_ori t_row;
    v_item_id  number;
    v_ver_nr number(4,2);
    v_temp integer;
    v_add integer :=0;
    v_already integer :=0;
    i integer := 0;
    v_item_typ_id integer;
    v_found boolean;
    
 forms t_forms;
  form1 t_form;
    
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);
    -- 92 - FOrm, 93 - CDE
    if (ihook.getColumnValue(row_ori,'DLOAD_TYP_ID') = 92) then
        v_item_typ_id := 54;
        else v_item_typ_id := 4;
    end if;
    
    if (hookinput.invocationnumber = 0) then
    
         forms                  := t_forms();
        form1                  := t_form('Add Item to Collection (Hook)', 2,1);
        forms.extend;    forms(forms.last) := form1;
        hookoutput.forms := forms;
      	 
       	 hookOutput.question := getAddComponentCreateQuestion;

	end if;
  
    if hookInput.invocationNumber = 1  then
       rows := t_rows();
       row := t_row();
        
        forms              := hookInput.forms;
        form1              := forms(1);
        row := form1.rowset.rowset(1);
        ihook.setColumnValue(row, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));
        
        for cur in (select * from admin_item where item_id = ihook.getColumnValue(row,'ITEM_ID') and currnt_ver_ind = 1 and admin_item_typ_id = v_item_typ_id and (item_id, ver_nr) not in 
        (select item_id, ver_nr from nci_dload_dtl where hdr_id = ihook.getColumnValue(row_ori,'HDR_ID'))) loop
        ihook.setColumnValue(row, 'VER_NR', cur.ver_nr);
                 ihook.setColumnValue(row,'CNTCT_SECU_ID', v_usr_id);
            ihook.setColumnValue(row,'GUEST_USR_NM', 'NONE');
          	   rows.extend;
            rows (rows.last) := row;
         select count(*) into v_temp from nci_usr_cart where item_id  =cur.item_id and ver_nr = cur.ver_nr and cntct_secu_id = v_usr_id;
 end loop;
        if (rows.count > 0) then
            action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
        actions.extend;
        actions(actions.last) := action;
    
        /*  If not already in cart */
        if (v_temp = 0) then
        
         action := t_actionrowset(rows, 'User Cart', 2,0,'insert');
        actions.extend;
        actions(actions.last) := action;
        end if;
        hookoutput.actions := actions;
        else 
        
       hookoutput.message := 'Please check the item type or item already in collection. Selected Item not added.';
        end if;
    end if;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
 


END;
/
