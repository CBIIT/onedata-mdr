create or replace PACKAGE nci_dload AS
  procedure spCreateDloadProfile (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
  procedure spCreateDloadProfileGuest (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
  procedure spEditDloadProfileGuest (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
  procedure spTriggerDload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
  procedure spAddComponentToDload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
   procedure spAddComponentToDloadID (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
   procedure spAddComponentToDloadIDGuest (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
   function getAddComponentCreateQuestion return t_question;
function getALSCreateQuestion (v_typ in integer) return t_question;
function getValidCollectionName (v_coll_nm in varchar2) return varchar2;
function getALSCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset, v_dload_typ in integer) return t_forms;
function getCollectionCreateFormGuest (v_rowset1 in t_rowset, v_rowset2 in t_rowset, v_dload_typ in integer) return t_forms;
procedure spDeleteDloadItem  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDloadHdrPostHook  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDeleteDloadItemGuest  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
function validatePin(v_hdr_id in number, v_pin in number) return boolean;
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

	   	 answer := t_answer(2, 2, 'Add All');
  	   	 answers.extend; answers(answers.last) := answer;

    QUESTION               := T_QUESTION('Please select Items to Add.', ANSWERS);

return question;
end;


-- Generic create question
function getAddComponentCreateQuestionID return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Please separate items with a single space between ids in order for total count of items to be correct. Select and click on Add.', ANSWERS);

return question;
end;

procedure spDloadHdrPostHook  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as
 hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
  v_coll_nm varchar2(255);
  v_usr_hdr varchar2(100);
  v_err_str varchar2(255);
  BEGIN
   hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;
   row_ori := hookInput.originalRowset.rowset (1);
    v_coll_nm := ihook.getColumnValue(row_ori, 'DLOAD_HDR_NM');

 select creat_usr_id into v_usr_hdr from nci_dload_hdr where
hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
 if (upper(v_usr_hdr) <> upper(v_usr_id)) then
 raise_application_error(-20000,'You are not authorized to update this collection.');
return;
 end if;

--- Doanload collection name - restrictions
v_err_str := getValidCollectionName(trim(v_coll_nm));

--raise_application_error (-20000, 'here' || v_err_str);
if (v_err_str  is not null) then

 raise_application_error(-20000,v_err_str);
 return;
end if;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

function getValidCollectionName (v_coll_nm in varchar2) return varchar2 is
v_err_str varchar2(255):= '';
begin

if (trim(length(v_coll_nm)) > 118) then
 v_err_str :='Collection name is longer than 118 characters.';
end if;


if (substr(v_coll_nm,1,1) >='0' and substr(v_coll_nm,1,1) <='9') then
 v_err_str :='Collection name cannot start with a digit.';
end if;

if (instr(v_coll_nm, ';') > 0) or instr(v_coll_nm, ':') > 0  or
instr(v_coll_nm, ':') > 0 or 
instr(v_coll_nm, '[') > 0 or 
instr(v_coll_nm, ']') > 0 or 
instr(v_coll_nm, '\') > 0 or 
instr(v_coll_nm, '/') > 0 or 
instr(v_coll_nm, '%') > 0 or 
instr(v_coll_nm, '#') > 0 or 
instr(v_coll_nm, '@') > 0 or 
instr(v_coll_nm, '$') > 0 or 
instr(v_coll_nm, '(') > 0 or 
instr(v_coll_nm, '}') > 0 then

 v_err_str :='Retricted characters in collection name: [     ]     \     /     ;     :     %     #     @     $     {     }     |';
end if;
return v_err_str;
end;
procedure spDeleteDloadItem  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_usr_hdr  varchar2(255);
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;


BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);

 select creat_usr_id into v_usr_hdr from nci_dload_hdr where
hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
 if (upper(v_usr_hdr) <> upper(v_usr_id)) then
 raise_application_error(-20000,'You are not authorized to delete in this collection.');
 end if;
for i in 1..hookinput.originalrowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);

            rows.extend;
            rows(rows.last) := row_ori;
    end loop;
            action             := t_actionrowset(rows, 'Download Detail', 2, 0,'delete');
            actions.extend;
            actions(actions.last) := action;

  action             := t_actionrowset(rows, 'Download Detail', 2, 1,'purge');
            actions.extend;
            actions(actions.last) := action;

            hookoutput.actions    := actions;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spDeleteDloadItemGuest  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_usr_hdr  varchar2(255);
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  row_dtl t_row;
  forms t_forms;
  form1 t_form;
  rowform t_row;
  v_err_str varchar2(255);

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);

 select creat_usr_id into v_usr_hdr from nci_dload_hdr where
hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
 if (upper(v_usr_hdr) <> 'GUEST') then
 raise_application_error(-20000,'You are not authorized to delete in this collection.');
 end if;

 if (hookinput.invocationNumber = 0) then
       rows := t_rows();
        row := t_row();
        nci_11179.spGetCartPin (hookoutput,'P');
    end if;

    if hookinput.invocationnumber = 1 then -- show create form
         forms              := hookInput.forms;
           form1              := forms(1);
        rowform := form1.rowset.rowset(1);
v_err_str := getValidCollectionName(trim(ihook.getColumnValue(rowform,'DLOAD_HDR_NM')));

if (v_err_str is not null) then

 raise_application_error(-20000,v_err_str);
 return;
end if;
          --  raise_application_error(-20000, ihook.getColumnValue(rowform, 'HDR_ID'));
        if (validatePin(ihook.getColumnValue(row_ori, 'HDR_ID'), ihook.getColumnValue(rowform, 'GUEST_USR_PWD')) = false) then
            raise_application_error(-20000, 'Invalid Pin. Please check and try again.');
            return;
        end if;

for i in 1..hookinput.originalrowset.rowset.count loop


 row_dtl :=  hookInput.originalRowset.rowset(i);

            rows.extend;
            rows(rows.last) := row_dtl;
    end loop;
            action             := t_actionrowset(rows, 'Download Detail', 2, 0,'delete');
            actions.extend;
            actions(actions.last) := action;

  action             := t_actionrowset(rows, 'Download Detail', 2, 1,'purge');
            actions.extend;
            actions(actions.last) := action;

            hookoutput.actions    := actions;

end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


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
    v_err_str varchar2(255);
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

          hookOutput.forms := getALSCreateForm(rowsethdr, rowsetals, 90);
          HOOKOUTPUT.QUESTION    := getALSCreateQuestion(90);
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
v_err_str := getValidCollectionName(trim(ihook.getColumnValue(rowhdr,'DLOAD_HDR_NM')));

if (v_err_str is not null) then

 raise_application_error(-20000,v_err_str);
 return;
end if;
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
--     nci_util.debugHook('GENERAL', v_data_out);
END;

function validatePin(v_hdr_id in number, v_pin in number) return boolean is
v_return boolean :=false;
begin
for cur in (select * from nci_dload_hdr where hdr_id = v_hdr_id and GUEST_USR_PWD = v_pin) loop
    v_return := true;
end loop;
return v_return;
end;
    -- Not used at this time.
procedure spCreateDloadProfileGuest (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
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
    v_als boolean;
    v_fmt integer;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    if (hookinput.invocationnumber = 0) then -- show create form
        rows := t_rows();
        row := t_row();
    nci_11179.spGetCartPin(hookoutput, 'I');
    end if;

    if hookinput.invocationnumber = 1 then -- show create form
        forms              := hookInput.forms;
          form1              := forms(1);
      row := form1.rowset.rowset(1);
      --row := t_row();
      rows := t_rows();
  v_fmt :=  ihook.getColumnValue(row, 'DLOAD_FMT_ID');
        ihook.setColumnValue(row, 'HDR_ID', -1);
      --  ihook.setColumnValue(row, 'DLOAD_FMT_ID',90 );
        rows.extend;          rows(rows.last) := row;
          rowsethdr := t_rowset(rows, 'Download Header (Base Object)', 1, 'NCI_DLOAD_HDR');

                rows := t_rows();
                row := t_row();
                 ihook.setColumnValue(row, 'HDR_ID', -1);
                rows.extend;          rows(rows.last) := row;
                rowsetals := t_rowset(rows, 'ALS Specific', 1, 'NCI_DLOAD_HDR');

                hookOutput.forms := getCollectionCreateFormGuest(rowsethdr, rowsetals,v_fmt);

          HOOKOUTPUT.QUESTION    := getALSCreateQuestion (v_fmt);
      end if;
    if  hookinput.invocationnumber = 2 then--- Second invocation
         forms              := hookInput.forms;
         form1              := forms(1);
        rowhdr := form1.rowset.rowset(1);
        v_als := false;
    --    raise_application_error(-20000, hookinput.answerid);

        if (hookinput.answerid = 90) then
            form1              := forms(2);
            rowals := form1.rowset.rowset(1);
            v_als := true;
        end if;
        v_id := nci_11179_2.getCollectionId;
        ihook.setColumnValue(rowhdr, 'HDR_ID', v_id);
           ihook.setColumnValue(rowhdr, 'DLOAD_FMT_ID',hookinput.answerid );

       rows := t_rows();
    rows.extend;
    rows(rows.last) := rowhdr;
    action := t_actionrowset(rows, 'Download Header (Base Object)', 2,1,'insert');
    actions.extend;
    actions(actions.last) := action;

    if v_als then
      ihook.setColumnValue(rowals, 'HDR_ID', v_id);

      rows := t_rows();
    rows.extend;
    rows(rows.last) := rowals;
    action := t_actionrowset(rows,'ALS Specific', 2,2,'insert');
    actions.extend;
    actions(actions.last) := action;
    end if;
    hookoutput.actions := actions;
    hookoutput.message := 'Collection Successfully Created with ID ' || v_id;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     nci_util.debugHook('GENERAL', v_data_out);
END;



procedure spEditDloadProfileGuest (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
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

    rowform t_row;
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
    v_als boolean :=false;
    row_ori t_row;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset(1);

   if (ihook.getColumnValue(row_ori, 'DLOAD_FMT_ID') = 90) then
    v_als := true;
    end if;
    if (hookinput.invocationnumber = 0) then -- show create form
        rows := t_rows();
        row := t_row();
        nci_11179.spGetCartPin (hookoutput,'P');
    end if;

    if hookinput.invocationnumber = 1 then -- show create form
         forms              := hookInput.forms;
           form1              := forms(1);
        rowform := form1.rowset.rowset(1);

          --  raise_application_error(-20000, ihook.getColumnValue(rowform, 'HDR_ID'));
        if (validatePin(ihook.getColumnValue(row_ori, 'HDR_ID'), ihook.getColumnValue(rowform, 'GUEST_USR_PWD')) = false) then
            raise_application_error(-20000, 'Invalid Pin. Please check and try again.');
            return;
        end if;
        rows := t_rows();
        row := row_ori;
            rows.extend;          rows(rows.last) := row;
          rowsethdr := t_rowset(rows, 'Download Header (Base Object)', 1, 'NCI_DLOAD_HDR');

        rows := t_rows();
        row := t_row();
            nci_11179.ReturnRow('select * from NCI_DLOAD_ALS where hdr_id = ' ||  ihook.getColumnValue(row_ori, 'HDR_ID'), 'NCI_DLOAD_ALS', row);
            rows.extend;          rows(rows.last) := row;

          rowsetals := t_rowset(rows, 'ALS Specific', 1, 'NCI_DLOAD_ALS');

          hookOutput.forms := getALSCreateForm(rowsethdr, rowsetals,ihook.getColumnValue(row_ori, 'DLOAD_FMT_ID'));
          HOOKOUTPUT.QUESTION    := getALSCreateQuestion(ihook.getColumnValue(row_ori, 'DLOAD_FMT_ID'));
      end if;
    if  hookinput.invocationnumber = 2 then--- Second invocation
         forms              := hookInput.forms;
         form1              := forms(1);

          rowhdr := form1.rowset.rowset(1);

        if (v_als = true) then
            form1              := forms(2);
            rowals := form1.rowset.rowset(1);
        end if;
        --ihook.setColumnValue(rowhdr, 'HDR_ID', ihook.getColumnValue);
           ihook.setColumnValue(rowhdr, 'DLOAD_FMT_ID',ihook.getColumNValue(row_ori, 'DLOAD_FMT_ID') );

       rows := t_rows();
    rows.extend;
    rows(rows.last) := rowhdr;
    action := t_actionrowset(rows, 'Download Header (Base Object)', 2,1,'update');
    actions.extend;
    actions(actions.last) := action;

    if v_als then
      ihook.setColumnValue(rowals, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));
      rows := t_rows();
    rows.extend;
    rows(rows.last) := rowals;
    action := t_actionrowset(rows,'ALS Specific', 2,2,'update');
    actions.extend;
    actions(actions.last) := action;
    end if;
    hookoutput.actions := actions;
    hookoutput.message := 'Collection successfully updated.';
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
    v_cart_ttl integer := 0;
    v_dup_str varchar2(4000) := '';
    showrowset	t_showablerowset;
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
        hookOutput.message := 'Number of items in your cart: ' || rows.count;
     else
        hookoutput.message := 'Please add forms or CDE to your cart.';
     end if;
	end if; -- First invocation

    if hookInput.invocationNumber = 1  then -- Items selected from cart. Second invocation
       rows := t_rows();
       if (hookinput.answerid = 1) then
       for i in 1..hookInput.selectedRowset.rowset.count loop -- Loop thru all the selected items.
          row_sel := hookInput.selectedRowset.rowset(i);

          ihook.setColumnValue(row_sel, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));

          -- Add only if not already in collection.
          select count(*) into v_temp from nci_dload_dtl where hdr_id = ihook.getColumnValue(row_ori,'HDR_ID') and item_id = ihook.getColumnValue(row_sel,'ITEM_ID')
          and ver_nr = ihook.getColumnValue(row_sel,'VER_NR');
          if (v_temp = 0) then
          	   rows.extend;
                rows (rows.last) := row_sel;
        else -- duplicate
            v_dup_str := substr(v_dup_str || ';' || ihook.getColumnValue(row_sel,'ITEM_ID'), 1, 4000);
        --    v_dup_str := v_dup_str || ';' || ihook.getColumnValue(row_sel,'ITEM_ID');
           end if;
        end loop;
        end if;

    row_sel := t_row();

        if (hookinput.answerid = 2) then -- selected all from cart
     for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_usr_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id = v_item_typ_id order by admin_item_typ_id) loop

          ihook.setColumnValue(row_sel, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));
          v_cart_ttl := v_cart_ttl + 1;
          -- Add only if not already in collection.
          select count(*) into v_temp from nci_dload_dtl where hdr_id = ihook.getColumnValue(row_ori,'HDR_ID') and item_id = cur.ITEM_ID
          and ver_nr = cur.VER_NR;
          if (v_temp = 0) then
                ihook.setColumnValue(row_sel, 'ITEM_ID', cur.ITEM_ID);
                ihook.setColumnValue(row_sel, 'VER_NR', cur.VER_NR);
                rows.extend;
                rows (rows.last) := row_sel;
        else 
                 v_dup_str := substr(v_dup_str || ';' || ihook.getColumnValue(row_sel,'ITEM_ID'), 1, 4000);
   
           end if;
        end loop;
        end if;

        
        -- If something to add.
        if (rows.count > 0) then
            action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
            actions.extend;
            actions(actions.last) := action;
            hookoutput.actions := actions;
            if (hookinput.answerid = 1) then
             v_already := hookInput.selectedRowset.rowset.count - rows.count;
        elsif hookinput.answerid = 2 then
             v_already := v_cart_ttl - rows.count;
        end if;
         --   hookoutput.message := rows.count || ' item(s) added successfully to collection. ' || v_already || ' item(s) selected already in your collection.';
           hookoutput.message := rows.count || ' item(s) added successfully to collection. Duplicates: ' || nvl(substr(v_dup_str,2), 'None');
        
        else
            hookoutput.message := 'All item(s) selected already in your collection.';
        end if;
    end if;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;



-- Add from Cart.
procedure spAddComponentToDloadNew (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
forms t_forms;
  form1 t_form;
  rowform t_row;
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
    v_usr_typ char(1);
    showrowset	t_showablerowset;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset(1);
    -- Check if called from Guest User or Logged in user
    if ( ihook.getColumnValue(row_ori, 'CREAT_USR_ID') = 'GUEST' or v_usr_id = 'GUEST') then
        v_usr_typ := 'G';
    else v_usr_typ := 'L' ;
    end if;

    if (hookinput.invocationnumber = 0) then
        if (v_usr_typ = 'L') then
            nci_11179.spGetCartPin(hookoutput, 'C');
        elsif (v_usr_typ ='G') then
            nci_11179.spGetCartPin(hookoutput, 'B');
        end if;

    end if;


     if (hookinput.invocationnumber = 1)  then
       forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);

        if (ihook.getColumnValue(row_ori,'CREAT_USR_ID') ='GUEST') then
            if(validatePin(ihook.getColumnValue(row_ori,'HDR_ID'), ihook.getColumnValue(rowform,'GUEST_USR_PWD'))= false) then
                raise_application_error(-20000, 'You are not authorized. Wrong Pin.');
            end if;
        end if;

        if (ihook.getColumnValue(row_ori,'DLOAD_TYP_ID') = 92) then
            v_item_typ_id := 54;
            else v_item_typ_id := 4;
        end if;

        rows := t_rows();

        -- Get items from user cart based on type
        for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_usr_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id = v_item_typ_id and upper(guest_usr_nm) = upper(ihook.getColumnValue(rowform, 'GUEST_USR_NM')) order by admin_item_typ_id) loop
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

    if hookInput.invocationNumber = 2  then -- Items selected from cart. Second invocation
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
        hookoutput.message := rows.count || ' item(s) added successfully to collection. ' ;
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
    i integer := 0;
    v_item_typ_id integer;
    v_found boolean;
    v_str varchar2(4000);
    cnt integer;
 forms t_forms;
  form1 t_form;
  v_cnt_valid_fmt integer;
  v_cnt_valid_type integer;
  v_cnt_already integer;
  v_invalid_fmt varchar2(50) := '';
  v_invalid_typ varchar2(100) := '';
  v_dup_str  varchar2(50) := '';
  v_none_str varchar2(8) := 'none';
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
       	 hookOutput.question := getAddComponentCreateQuestionID;
	end if;

    if hookInput.invocationNumber = 1  then  -- Seconf invocation
       rows := t_rows();
       row := t_row();

        v_cnt_valid_fmt := 0;
        v_cnt_valid_type := 0;

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
          IF (VALIDATE_CONVERSION(nci_11179.getWord(v_str, i, cnt) AS NUMBER) = 1) THEN
                        v_item_id := nci_11179.getWord(v_str, i, cnt);
                    v_cnt_valid_fmt := v_cnt_valid_fmt + 1;

        -- Only add if item is of the right type and not currently in collection.
                select count(*) into v_temp from admin_item where item_id = v_item_id and currnt_ver_ind = 1 and admin_item_typ_id = v_item_typ_id ;
                if (v_temp = 1) then
                        v_cnt_valid_type := v_cnt_valid_type + 1;
                        v_found := true;
                        for cur in (select * from admin_item where item_id = v_item_id and currnt_ver_ind = 1 and (item_id, ver_nr) not in
                        (select item_id, ver_nr from nci_dload_dtl where hdr_id = ihook.getColumnValue(row_ori,'HDR_ID'))) loop
                            ihook.setColumnValue(row, 'ITEM_ID', cur.item_id);
                            ihook.setColumnValue(row, 'VER_NR', cur.ver_nr);
                            ihook.setColumnValue(row,'CNTCT_SECU_ID', v_usr_id);
                            ihook.setColumnValue(row,'GUEST_USR_NM', 'NONE');
                            rows.extend;
                            rows (rows.last) := row;
                            v_found := false;
                            -- Add to user cart as well as per curator.
                            select count(*) into v_temp from nci_usr_cart where item_id  =cur.item_id and ver_nr = cur.ver_nr and cntct_secu_id = v_usr_id;
                              if (v_temp = 0) then
                                    rowscart.extend;
                                    rowscart (rowscart.last) := row;
                              end if;
                        end loop;
                        if (v_found = true) then  --- Duplcicate
                        v_dup_str := substr(v_dup_str || ' ' || nci_11179.getWord(v_str, i, cnt),1,50);
                        end if;
                else -- not the right type
                v_invalid_typ := substr(v_invalid_typ || ' ' || nci_11179.getWord(v_str, i, cnt),1,50);
                end if;
 else
    -- invalid format
  --  v_invalid_fmt := substr(v_invalid_fmt || ' ' || nci_11179.getWord(v_str, i, cnt),1,50);
        v_invalid_typ := substr(v_invalid_typ || ' ' || nci_11179.getWord(v_str, i, cnt),1,50);

 end if;
end loop;
        -- If Item needs to be added.
        if (rows.count > 0) then
            action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
            actions.extend;
            actions(actions.last) := action;
        end if;
            /*  If item not already in cart */
            if (rowscart.count  > 0) then
                action := t_actionrowset(rowscart, 'User Cart', 2,0,'insert');
                actions.extend;
                actions(actions.last) := action;
            end if;

        if (actions.count > 0) then
            hookoutput.actions := actions;
        end if;
  --      v_cnt_valid_fmt := cnt-v_cnt_valid_fmt;
  --      v_cnt_valid_type :=
        v_cnt_already :=  v_cnt_valid_type - nvl(rows.count,0) ;
         /*    hookoutput.message := 'Total Items: ' || cnt ||  ';    Valid format: ' || v_cnt_valid_fmt || ';    Valid Item type: ' || v_cnt_valid_type ||  ';     Already in Collection: ' || v_cnt_already || ';    Items added: ' || nvl(rows.count,0) ;
            if (v_invalid_fmt is not null) then
                hookoutput.message := hookoutput.message || ';             Invalid format sample: ' || v_invalid_fmt ;
            end if;
            if (v_invalid_typ is not null) then
                hookoutput.message := hookoutput.message || ';    Invalid type sample: ' || v_invalid_typ ;
            end if;
*/
             v_invalid_typ := NVL(trim(v_invalid_typ), v_none_str);
             v_dup_str := NVL(trim(v_dup_str), v_none_str);
             hookoutput.message := 'Total Items: ' || cnt ||  ';    Invalid Format/Type: ' || v_invalid_typ || ';     Duplicate: ' || v_dup_str || ';    Items added: ' || nvl(rows.count,0) ;

   end if;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spAddComponentToDloadIDGuest (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
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
    i integer := 0;
    v_item_typ_id integer;
    v_found boolean;
    v_str varchar2(4000);
    cnt integer;
 forms t_forms;
  form1 t_form;
  v_cnt_valid_fmt integer;
  v_cnt_valid_type integer;
  v_cnt_already integer;
  v_invalid_fmt varchar2(50) := '';
  v_invalid_typ varchar2(100) := '';
  v_dup_str  varchar2(50) := '';
  v_none_str varchar2(8) := 'none';
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
        form1                  := t_form('Add Item to Collection Guest (Hook)', 2,1);
        forms.extend;    forms(forms.last) := form1;
        hookoutput.forms := forms;
       	 hookOutput.question := getAddComponentCreateQuestionID;
	end if;

    if hookInput.invocationNumber = 1  then  -- Seconf invocation
       rows := t_rows();
       row := t_row();

        v_cnt_valid_fmt := 0;
        v_cnt_valid_type := 0;

        forms              := hookInput.forms;
        form1              := forms(1);
        row_sel := form1.rowset.rowset(1);

          --  raise_application_error(-20000, ihook.getColumnValue(rowform, 'HDR_ID'));
        if (validatePin(ihook.getColumnValue(row_ori, 'HDR_ID'), ihook.getColumnValue(row_sel, 'ITEM_ID')) = false) then
            raise_application_error(-20000, 'Invalid Pin. Please check and try again.');
            return;
        end if;

        v_str := trim(ihook.getColumnValue(row_sel, 'VM_DESC_TXT'));
             cnt := nci_11179.getwordcount(v_str);

        row := t_row();
        rows := t_rows();
        rowscart := t_rows();
        ihook.setColumnValue(row, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));

         for i in  1..cnt loop
          IF (VALIDATE_CONVERSION(nci_11179.getWord(v_str, i, cnt) AS NUMBER) = 1) THEN
                        v_item_id := nci_11179.getWord(v_str, i, cnt);
                    v_cnt_valid_fmt := v_cnt_valid_fmt + 1;

        -- Only add if item is of the right type and not currently in collection.
                select count(*) into v_temp from admin_item where item_id = v_item_id and currnt_ver_ind = 1 and admin_item_typ_id = v_item_typ_id ;
                if (v_temp = 1) then
                        v_cnt_valid_type := v_cnt_valid_type + 1;
                        v_found := true;
                        for cur in (select * from admin_item where item_id = v_item_id and currnt_ver_ind = 1 and (item_id, ver_nr) not in
                        (select item_id, ver_nr from nci_dload_dtl where hdr_id = ihook.getColumnValue(row_ori,'HDR_ID'))) loop
                            ihook.setColumnValue(row, 'ITEM_ID', cur.item_id);
                            ihook.setColumnValue(row, 'VER_NR', cur.ver_nr);
                            ihook.setColumnValue(row,'CNTCT_SECU_ID', v_usr_id);
                            ihook.setColumnValue(row,'GUEST_USR_NM', 'NONE');
                            rows.extend;
                            rows (rows.last) := row;
                            v_found := false;
                            -- Add to user cart as well as per curator.
          /*                  select count(*) into v_temp from nci_usr_cart where item_id  =cur.item_id and ver_nr = cur.ver_nr and cntct_secu_id = v_usr_id;
                              if (v_temp = 0) then
                                    rowscart.extend;
                                    rowscart (rowscart.last) := row;
                              end if;*/
                        end loop;
                        if (v_found = true) then  --- Duplcicate
                        v_dup_str := substr(v_dup_str || ' ' || nci_11179.getWord(v_str, i, cnt),1,50);
                        end if;
                else -- not the right type
                v_invalid_typ := substr(v_invalid_typ || ' ' || nci_11179.getWord(v_str, i, cnt),1,50);
                end if;
 else
    -- invalid format
  --  v_invalid_fmt := substr(v_invalid_fmt || ' ' || nci_11179.getWord(v_str, i, cnt),1,50);
        v_invalid_typ := substr(v_invalid_typ || ' ' || nci_11179.getWord(v_str, i, cnt),1,50);

 end if;
end loop;
        -- If Item needs to be added.
        if (rows.count > 0) then
            action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
            actions.extend;
            actions(actions.last) := action;
        end if;
            /*  If item not already in cart */
           /* if (rowscart.count  > 0) then
                action := t_actionrowset(rowscart, 'User Cart', 2,0,'insert');
                actions.extend;
                actions(actions.last) := action;
            end if;
*/
        if (actions.count > 0) then
            hookoutput.actions := actions;
        end if;
  --      v_cnt_valid_fmt := cnt-v_cnt_valid_fmt;
  --      v_cnt_valid_type :=
        v_cnt_already :=  v_cnt_valid_type - nvl(rows.count,0) ;
         /*    hookoutput.message := 'Total Items: ' || cnt ||  ';    Valid format: ' || v_cnt_valid_fmt || ';    Valid Item type: ' || v_cnt_valid_type ||  ';     Already in Collection: ' || v_cnt_already || ';    Items added: ' || nvl(rows.count,0) ;
            if (v_invalid_fmt is not null) then
                hookoutput.message := hookoutput.message || ';             Invalid format sample: ' || v_invalid_fmt ;
            end if;
            if (v_invalid_typ is not null) then
                hookoutput.message := hookoutput.message || ';    Invalid type sample: ' || v_invalid_typ ;
            end if;
*/
             v_invalid_typ := NVL(trim(v_invalid_typ), v_none_str);
             v_dup_str := NVL(trim(v_dup_str), v_none_str);
             hookoutput.message := 'Total Items: ' || cnt ||  ';    Invalid Format/Type: ' || v_invalid_typ || ';     Duplicate: ' || v_dup_str || ';    Items added: ' || nvl(rows.count,0) ;

   end if;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

function getALSCreateQuestion (v_typ in integer) return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin
    ANSWERS                    := T_ANSWERS();
   -- raise_application_error(-20000, v_typ);
    ANSWER                     := T_ANSWER(v_typ, v_typ,  'Create');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;

    if (v_typ = 90) then
    QUESTION               := T_QUESTION('Create New RAVE ALS Collection', ANSWERS);
    else
    QUESTION               := T_QUESTION('Create New Collection', ANSWERS);

    end if;
return question;
end;

function getALSCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset, v_dload_typ in integer) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('Download Header (Hook)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    if (v_dload_typ = 90) then
    form1                  := t_form('ALS Specific', 2,1);

    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
    end if;
  return forms;
end;

function getCollectionCreateFormGuest (v_rowset1 in t_rowset, v_rowset2 in t_rowset, v_dload_typ in integer) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('Download Header (Base Object)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    if (v_dload_typ = 90) then
    form1                  := t_form('ALS Specific', 2,1);

    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
    end if;
  return forms;
end;

END;
/
