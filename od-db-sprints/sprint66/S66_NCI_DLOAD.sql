create or replace PACKAGE nci_dload AS
function isUserAuth(v_hdr_id in number, v_user_id in varchar2) return boolean;
  procedure spCreateDloadProfile (v_data_in in clob, v_data_out out clob, v_coll_typ in varchar2, v_usr_id  IN varchar2);
  procedure spCreateDloadProfileNew (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
    procedure spCreateDloadProfileGuest (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
 -- procedure spEditDloadProfileGuest (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
  procedure spTriggerDload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
  procedure spAddComponentToDload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
  procedure spAddComponentToDloadByCartName (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
   procedure spAddComponentToDloadID (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
   procedure spAddComponentToDloadName (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
   procedure spAddComponentToDloadIDGuest (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
   function getAddComponentCreateQuestion return t_question;
   function getAddComponentCreateQuestionNamedCart return t_question;
   function getCreateQuestionUsingID return t_question;
function getALSCreateQuestion ( v_initial in boolean) return t_question;
function getValidCollectionName (v_coll_nm in varchar2) return varchar2;
function getALSCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset, v_coll_typ in integer) return t_forms;
function getCollectionCreateFormGuest (v_rowset1 in t_rowset, v_rowset2 in t_rowset, v_dload_typ in integer) return t_forms;
procedure spDeleteDloadItem  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDloadHdrPostHook  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDeleteDloadItemGuest  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
function validatePin(v_hdr_id in number, v_pin in number) return boolean;
procedure RemoveDloadBlob  ( v_hdr_id IN number, actions in out t_actions);
procedure spCreateCustomDownload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
procedure spResetCstmColOrder  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2);
procedure spReorderColumns  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2);
procedure spInitCstmColOrder(hdr_id in number, v_mode IN varchar2);
procedure spAppendColumn(hdr_id in number, col_id in number);
procedure spRemoveGaps  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2, v_mode in varchar2);
function validateDataColl (v_hdr_id in number) return varchar2;
procedure spDloadPostHookExt  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spAddModelMappingToDload (v_data_in in clob, v_data_out out clob, v_usr_id IN varchar2);
procedure spInitMMRCollection (v_hdr_id in number);
END;
/
create or replace PACKAGE BODY nci_dload AS

c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
v_deflt_cart_nm varchar2(255) := 'Default';

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

    QUESTION               := T_QUESTION('Please select Items to Add.' || chr(13) || '*Add All* from Cart can take a several seconds per item to load. Please try not to click *Add All* twice
    or you may get a unique constraint violation. Items will have been added only once. Check Details to see if they look correct.' , ANSWERS);

return question;
end;

function isUserAuth(v_hdr_id in number, v_user_id in varchar2) return boolean is
v_auth boolean := false;
v_usr_id varchar2(255);
begin

select creat_usr_id into v_usr_id from nci_dload_hdr where HDR_ID = v_hdr_id;
 if (upper(v_usr_id) <> upper(v_user_id) and nci_11179_2.isUserAdmin(v_user_id) = false) then return false; else return true; end if;
end;

/*function isUserAuth(v_dload_item_id in number, v_dload_ver_nr in number, v_user_id in varchar2) return boolean  is
v_auth boolean := false;
v_temp integer;
begin

select count(*) into v_temp from  onedata_md.vw_usr_row_filter  v, admin_item ai
        where ( ( v.CNTXT_ITEM_ID = ai.CNTXT_ITEM_ID and v.cntxt_VER_NR  = ai.CNTXT_VER_NR) or v.CNTXT_ITEM_ID = 100) and upper(v.USR_ID) = upper(v_user_id) and v.ACTION_TYP = 'I'
        and ai.item_id =v_dload_item_id and ai.ver_nr = v_dload_ver_nr;
if (v_temp = 0) then return false; else return true; end if;
end;
*/
-- Generic create question
function getAddComponentCreateQuestionNamedCart return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;

--	   	 answer := t_answer(2, 2, 'Add All');
 -- 	   	 answers.extend; answers(answers.last) := answer;

 --   QUESTION               := T_QUESTION('Please select Items to Add.' || chr(13) || '*Add All* from Cart can take a several seconds per item to load. Please try not to click *Add All* twice
 --   or you may get a unique constraint violation. Items will have been added only once. Check Details to see if they look correct.' , ANSWERS);
   QUESTION               := T_QUESTION('Please select Items to Add.'  , ANSWERS);

return question;
end;

function getCreateQuestionUsingID return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;

    QUESTION               := T_QUESTION('Please specify Item ID with spaces in between to Add.' , ANSWERS);

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


-- Generic create question
function getAddComponentCreateQuestionNameS1 return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Next');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Please specify string to search.', ANSWERS);

return question;
end;


-- Generic create question
function getAddComponentCreateQuestionNameS2 return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Select Items to add.', ANSWERS);

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
  v_is_usr_auth boolean;
  v_cde_lbl_id number;
  v_alt_nm_typ_id number;
  v_alt_nm_cntxt_id number;
  v_fmt_id number;
  
    actions t_actions := t_actions();
    action t_actionRowset;
  BEGIN
   hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;
   row_ori := hookInput.originalRowset.rowset (1);
    v_coll_nm := ihook.getColumnValue(row_ori, 'DLOAD_HDR_NM');

 v_err_str := validateDataColl(ihook.getColumnValue(row_ori, 'HDR_ID'));
 if (v_err_str is not null) then
    raise_application_error(-20000, v_err_str);
    return;
 end if;
 v_is_usr_auth := isUserAuth(ihook.getColumnValue(row_ori, 'HDR_ID'), v_usr_id);
 if (v_is_usr_auth != true) then
     raise_application_error(-20000,'You are not authorized to update this collection.');
    return;
 end if;
 
 --TEST getting hookoutput from other hook
--select dload_fmt_id into v_fmt_id from nci_dload_hdr where hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
-- if (v_fmt_id = 229) then
--    --update mdl map or dtl tables
--    raise_application_error(-20000,'Test stop');
--    
--    return;
-- end if;
--  SELECT
--    creat_usr_id
--INTO v_usr_hdr
--FROM
--    nci_dload_hdr
--WHERE
--    hdr_id = ihook.getcolumnvalue(row_ori, 'HDR_ID');
--
--IF ( upper(v_usr_hdr) <> upper(v_usr_id) ) THEN
--    raise_application_error(-20000, 'You are not authorized to update this collection.');
--    return;
--END IF;

--- Doanload collection name - restrictions
v_err_str := getValidCollectionName(trim(v_coll_nm));

--raise_application_error (-20000, 'here' || v_err_str);
if (v_err_str  is not null) then

 raise_application_error(-20000,'Collection Name was not saved. ' || v_err_str);
 return;
 
elsif (ihook.getColumnValue(row_ori, 'FILE_NM') is not null) then
    RemoveDloadBlob(ihook.getColumnValue(row_ori, 'HDR_ID'), actions);
    hookoutput.actions := actions;
end if;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spDloadPostHookExt  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as
    hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    v_hdr_id number;
  
    actions t_actions := t_actions();
    action t_actionRowset;
BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;
    row_ori := hookInput.originalRowset.rowset (1);

    v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
 --   raise_application_error(-20000, v_hdr_id);
    RemoveDloadBlob(v_hdr_id, actions);
 --   raise_application_error(-20000, v_hdr_id);
    hookoutput.actions := actions;
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
instr(v_coll_nm, '''') > 0 or 
instr(v_coll_nm, '"') > 0 or 
instr(v_coll_nm, '@') > 0 or 
instr(v_coll_nm, '$') > 0 or 
instr(v_coll_nm, '{') > 0 or 
instr(v_coll_nm, '|') > 0 or 
instr(v_coll_nm, '}') > 0 then

 v_err_str :='Retricted characters in collection name: [     ]     \     /     ;     :     %     #     @     $     {     }     |     ''    "';
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
    v_fmt_id number;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_obj varchar2(100) := 'Download Detail';
    v_mdl_nm varchar2(1000);

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);

 select creat_usr_id, dload_fmt_id into v_usr_hdr, v_fmt_id from nci_dload_hdr where  hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
 if (upper(v_usr_hdr) <> upper(v_usr_id) and nci_11179_2.isUserAdmin(v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to delete in this collection.');
 end if;
 
for i in 1..hookinput.originalrowset.rowset.count loop
    row_ori :=  hookInput.originalRowset.rowset(i);
    if (v_fmt_id = 229) then --only delete model mapping from filter
--        select MM_CURATED_NM into v_mdl_nm from vw_mdl_map_list_dload where mm_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR');
--        delete from nci_dload_mdl_map_dtl where mm_nm_curated = v_mdl_nm and hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
--        delete from onedata_ra.nci_dload_mdl_map_dtl where mm_nm_curated = v_mdl_nm and hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
--        commit;
        
        select MM_ID_VER into v_mdl_nm from vw_mdl_map_list_dload_new where mm_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR');
        delete from nci_dload_mdl_map_dtl_new where mm_id_ver = v_mdl_nm and hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
        delete from onedata_ra.nci_dload_mdl_map_dtl_new where mm_id_ver = v_mdl_nm and hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
        commit;
        
   -- raise_application_error(-20000, 'Please use Model Mapping Rules Specific section to manage your selection.');
    else
            rows.extend;
            rows(rows.last) := row_ori;
    end if;
    end loop;
    if (v_fmt_id <> 229) then
            action             := t_actionrowset(rows, v_obj, 2, 0,'delete');
            actions.extend;
            actions(actions.last) := action;

  action             := t_actionrowset(rows, v_obj, 2, 1,'purge');
            actions.extend;
            actions(actions.last) := action;
    end if;

      RemoveDloadBlob (ihook.getColumnValue(row_ori, 'HDR_ID'), actions);

            hookoutput.actions    := actions;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure RemoveDloadBlob  ( v_hdr_id IN number, actions in out t_actions)
AS
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    v_usr_hdr  varchar2(255);
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;


BEGIN

rows := t_rows();
row := t_row();
ihook.setColumnValue(row,'HDR_ID', v_hdr_id);

ihook.setColumnValue(row, 'FILE_BLOB', '');
ihook.setColumnValue(row, 'FILE_NM', '');
ihook.setColumnValue(row, 'LST_GEN_DT', '');
            rows.extend;
            rows(rows.last) := row;
  action             := t_actionrowset(rows, 'Download Header', 2, 2,'update');
            actions.extend;
            actions(actions.last) := action;

END;

function validatePin(v_hdr_id in number, v_pin in number) return boolean is
v_return boolean :=false;
begin
for cur in (select * from nci_dload_hdr where hdr_id = v_hdr_id and GUEST_USR_PWD = v_pin) loop
    v_return := true;
end loop;
return v_return;
end;
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


procedure spCreateCustomDownload (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
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

    v_coll_typ integer;
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
    rowsel t_row;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;


    if (hookinput.invocationnumber = 0) then -- Get Collection Type
        rows := t_rows();
        row := t_row();


        forms                  := t_forms();
    form1                  := t_form('Download Format Selection (Hook)', 2,1);
    forms.extend;    forms(forms.last) := form1;
     hookOutput.forms  := forms;
          HOOKOUTPUT.QUESTION    := getALSCreateQuestion( true);
    end if;

    if (hookinput.invocationnumber = 1) then -- show create form
       forms              := hookInput.forms;
           form1              := forms(1);
      rowsel := form1.rowset.rowset(1);
      v_coll_typ := ihook.getColumnValue(rowsel, 'DLOAD_FMT_ID');
        rows := t_rows();
        row := t_row();
        ihook.setColumnValue(row, 'HDR_ID', v_coll_typ);
        ihook.setColumnValue(row, 'DLOAD_FMT_ID',v_coll_typ );
        rows.extend;          rows(rows.last) := row;
          rowsethdr := t_rowset(rows, 'Download Header', 1, 'NCI_DLOAD_HDR');
        rows := t_rows();
        row := t_row();
            ihook.setColumnValue(row, 'HDR_ID', -1);
        rows.extend;          rows(rows.last) := row;
          rowsetals := t_rowset(rows, 'ALS Specific', 1, 'NCI_DLOAD_HDR');

          hookOutput.forms := getALSCreateForm(rowsethdr, rowsetals, v_coll_typ);
          HOOKOUTPUT.QUESTION    := getALSCreateQuestion(false);
    end if;

    if (hookinput.invocationNumber = 2) then 
         forms              := hookInput.forms;

           form1              := forms(1);
      rowhdr := form1.rowset.rowset(1);
    -- Non-eitable lookup values are lost. So workaround.
      v_coll_typ := ihook.getColumnValue(rowhdr, 'HDR_ID');
    ihook.setColumnValue (rowhdr, 'DLOAD_FMT_ID', v_coll_typ);

      if (v_coll_typ in (90, 110)) then
      form1              := forms(2);
      rowals := form1.rowset.rowset(1);
      else
      rowals := t_row();
      end if;
        v_id := nci_11179_2.getCollectionId;
        ihook.setColumnValue(rowhdr, 'HDR_ID', v_id);
        ihook.setColumnValue(rowals, 'HDR_ID', v_id);
        --   ihook.setColumnValue(rowhdr, 'DLOAD_FMT_ID',90 );
v_err_str := getValidCollectionName(trim(ihook.getColumnValue(rowhdr,'DLOAD_HDR_NM')));

if (v_err_str is not null) then

 raise_application_error(-20000,v_err_str);
 return;
end if;
       rows := t_rows();
    rows.extend;
    rows(rows.last) := rowhdr;
    action := t_actionrowset(rows, 'Download Header (Base Object)', 2,1,'insert');
    actions.extend;
    actions(actions.last) := action;

    if (ihook.getColumnValue(rowhdr, 'DLOAD_FMT_ID' ) in (90, 110)) then
      rows := t_rows();
    rows.extend;   rows(rows.last) := rowals;

    if (ihook.getColumnValue(rowhdr, 'DLOAD_FMT_ID' )= 90 ) then 
    action := t_actionrowset(rows,'ALS Specific', 2,2,'insert');
    else
        action := t_actionrowset(rows,'ALS Specific for Form', 2,2,'insert');

    end if;
    actions.extend;
    actions(actions.last) := action;
    end if;
    hookoutput.actions := actions;
    hookoutput.message := 'Collection Successfully Created with ID ' || v_id;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     nci_util.debugHook('GENERAL', v_data_out);
END;
   --v_coll_typ - ALS A, Other O

procedure spCreateDloadProfile (v_data_in in clob, v_data_out out clob, v_coll_typ in varchar2, v_usr_id  IN varchar2)
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

          hookOutput.forms := getALSCreateForm(rowsethdr, rowsetals, v_coll_typ);
          HOOKOUTPUT.QUESTION    := getALSCreateQuestion(false);
    else --- Second invocation
         forms              := hookInput.forms;

           form1              := forms(1);
      rowhdr := form1.rowset.rowset(1);
      if (v_coll_typ = 'A') then
      form1              := forms(2);
      rowals := form1.rowset.rowset(1);
      else
      rowals := t_row();
      end if;
        v_id := nci_11179_2.getCollectionId;
        ihook.setColumnValue(rowhdr, 'HDR_ID', v_id);
        ihook.setColumnValue(rowals, 'HDR_ID', v_id);
        --   ihook.setColumnValue(rowhdr, 'DLOAD_FMT_ID',90 );
v_err_str := getValidCollectionName(trim(ihook.getColumnValue(rowhdr,'DLOAD_HDR_NM')));

if (v_err_str is not null) then

 raise_application_error(-20000,v_err_str);
 return;
end if;
 v_err_str := validateDataColl(v_id);
 if (v_err_str is not null) then
    raise_application_error(-20000, v_err_str);
    return;
 end if;
       rows := t_rows();
    rows.extend;
    rows(rows.last) := rowhdr;
    action := t_actionrowset(rows, 'Download Header (Base Object)', 2,1,'insert');
    actions.extend;
    actions(actions.last) := action;

    if (ihook.getColumnValue(rowhdr, 'DLOAD_FMT_ID' ) in (90, 110)) then
      rows := t_rows();
    rows.extend;   rows(rows.last) := rowals;

    if (ihook.getColumnValue(rowhdr, 'DLOAD_FMT_ID' )= 90 ) then 
    action := t_actionrowset(rows,'ALS Specific', 2,2,'insert');
    else
        action := t_actionrowset(rows,'ALS Specific for Form', 2,2,'insert');

    end if;
    actions.extend;
    actions(actions.last) := action;
    end if;
    hookoutput.actions := actions;
    hookoutput.message := 'Collection Successfully Created with ID ' || v_id;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--     nci_util.debugHook('GENERAL', v_data_out);
END;


procedure spCreateDloadProfileNew (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
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
    rowsetcstm           t_rowset;
    rowsetmdlmap         t_rowset;
    rowsetdatacoll       t_rowset;
    rowsetnihsub         t_rowset;

    v_coll_typ integer;
    rows  t_rows;
    rowhdr t_row;
    rowals t_row;
    rowcstm t_row;
    rowmdlmap t_row;
    rowdatacoll t_row;
    rownihsub t_row;
    v_item_id  number;
    v_ver_nr number(4,2);
    v_temp integer;
    v_add integer :=0;
    v_already integer :=0;
    i integer := 0;
    v_err_str varchar2(255);
    v_id number;
    rowsel t_row;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;


    if (hookinput.invocationnumber = 0) then -- Get Collection Type
        rows := t_rows();
        row := t_row();


        forms                  := t_forms();
    form1                  := t_form('Download Format Selection (Hook)', 2,1);
    forms.extend;    forms(forms.last) := form1;
     hookOutput.forms  := forms;
          HOOKOUTPUT.QUESTION    := getALSCreateQuestion( true);
    end if;

    if (hookinput.invocationnumber = 1) then -- show create form
       forms              := hookInput.forms;
           form1              := forms(1);
      rowsel := form1.rowset.rowset(1);
      v_coll_typ := ihook.getColumnValue(rowsel, 'DLOAD_FMT_ID');
        rows := t_rows();
        row := t_row();
        ihook.setColumnValue(row, 'HDR_ID', v_coll_typ);
        ihook.setColumnValue(row, 'DLOAD_FMT_ID',v_coll_typ );
        rows.extend;          rows(rows.last) := row;
          rowsethdr := t_rowset(rows, 'Download Header', 1, 'NCI_DLOAD_HDR');
        rows := t_rows();
        row := t_row();
            ihook.setColumnValue(row, 'HDR_ID', -1);
        rows.extend;          rows(rows.last) := row;
          rowsetals := t_rowset(rows, 'ALS Specific', 1, 'NCI_DLOAD_HDR');
          rowsetcstm := t_rowset(rows, 'Custom CDE Subtype', 1, 'NCI_DLOAD_HDR');
          --rowsetmdlmap := t_rowset(rows, 'Model Mapping Rules Specific (New)', 1, 'NCI_DLOAD_HDR');
          rowsetdatacoll := t_rowset(rows, 'Custom Data Collection Excel', 1, 'NCI_DLOAD_HDR');
          rowsetnihsub := t_rowset(rows, 'NIH Submission Template Specific', 1, 'NCI_DLOAD_HDR');
        if (v_coll_typ in (224)) then
          hookOutput.forms := getALSCreateForm(rowsethdr, rowsetcstm, v_coll_typ);
--        elsif (v_coll_typ = 229) then
--            hookOutput.forms := getALSCreateForm(rowsethdr, rowsetmdlmap, v_coll_typ);
        elsif (v_coll_typ = 230) then
            hookOutput.forms := getALSCreateForm(rowsethdr, rowsetdatacoll, v_coll_typ);
        elsif (v_coll_typ = 223) then
            hookOutput.forms := getALSCreateForm(rowsethdr, rowsetnihsub, v_coll_typ);
        else
          hookOutput.forms := getALSCreateForm(rowsethdr, rowsetals, v_coll_typ);
        end if;
          HOOKOUTPUT.QUESTION    := getALSCreateQuestion(false);
    end if;

    if (hookinput.invocationNumber = 2) then 
        forms              := hookInput.forms;
        form1              := forms(1);
        rowhdr := form1.rowset.rowset(1);
    -- Non-eitable lookup values are lost. So workaround.
     --   v_coll_typ := ihook.getColumnValue(rowhdr, 'DLOAD_FMT_ID');
            v_coll_typ := ihook.getColumnValue(rowhdr, 'HDR_ID');
        ihook.setColumnValue (rowhdr, 'DLOAD_FMT_ID', v_coll_typ);

--            rowals := t_row();
--            rowcstm := t_row();
--            rowmdlmap := t_row();
      --     rowdatacoll := t_row();
        if (v_coll_typ in (90, 110)) then
            form1              := forms(2);
            rowals := form1.rowset.rowset(1);
            rowcstm := t_row();
            rowmdlmap := t_row();
            rowdatacoll := t_row();
            rownihsub := t_row();
        elsif (v_coll_typ in (224)) then
            form1 := forms(2);
            rowcstm := form1.rowset.rowset(1);
            rowmdlmap := t_row();
            rowals := t_row();
            rowdatacoll := t_row();
            rownihsub := t_row();
--        elsif (v_coll_typ in (229)) then
--            form1 := forms(2);
--            rowmdlmap := form1.rowset.rowset(1);
--            rowals := t_row();
--            rowcstm := t_row();
--            rowdatacoll := t_row();
--            rownihsub := t_row();
        elsif( v_coll_typ in (230)) then
            form1:= forms(2);
            rowdatacoll := form1.rowset.rowset(1);
            rowals := t_row();
            rowmdlmap := t_row();
            rowcstm := t_row();
            rownihsub := t_row();
        elsif( v_coll_typ in (223)) then
            form1:= forms(2);
            rownihsub := form1.rowset.rowset(1);
            rowals := t_row();
            rowmdlmap := t_row();
            rowcstm := t_row();
            rowdatacoll := t_row();            
        else
            rowals := t_row();
            rowcstm := t_row();
            rowmdlmap := t_row();
            rowdatacoll := t_row();
            rownihsub := t_row();
      end if;
        v_id := nci_11179_2.getCollectionId;
   --     raise_application_error(-20000, v_id);
        ihook.setColumnValue(rowhdr, 'HDR_ID', v_id);
        ihook.setColumnValue(rowals, 'HDR_ID', v_id);
        ihook.setColumnValue(rowcstm, 'HDR_ID', v_id);
        --ihook.setColumnValue(rowmdlmap, 'HDR_ID', v_id);
        ihook.setColumnValue(rowdatacoll, 'HDR_ID', v_id);
        ihook.setColumnValue(rownihsub, 'HDR_ID', v_id);
        --   ihook.setColumnValue(rowhdr, 'DLOAD_FMT_ID',90 );
v_err_str := getValidCollectionName(trim(ihook.getColumnValue(rowhdr,'DLOAD_HDR_NM')));

if (v_err_str is not null) then

 raise_application_error(-20000,v_err_str);
 return;
end if;
-- v_err_str := validateDataColl(v_id);
-- if (v_err_str is not null) then
--    raise_application_error(-20000, v_err_str);
--    return;
-- end if;
--jira 3
       rows := t_rows();
    rows.extend;
    rows(rows.last) := rowhdr;
    action := t_actionrowset(rows, 'Download Header (Base Object)', 2,1,'insert');
    actions.extend;
    actions(actions.last) := action;

    if (ihook.getColumnValue(rowhdr, 'DLOAD_FMT_ID' ) in (90, 110)) then
        rows := t_rows();
        rows.extend;   rows(rows.last) := rowals;

        if (ihook.getColumnValue(rowhdr, 'DLOAD_FMT_ID' )= 90 ) then 
            action := t_actionrowset(rows,'ALS Specific', 2,2,'insert');
        else
            action := t_actionrowset(rows,'ALS Specific for Form', 2,2,'insert');
        end if;
        actions.extend;
        actions(actions.last) := action;
    end if;

    if (ihook.getColumnValue(rowhdr, 'DLOAD_FMT_ID') = 229) then
--        rows := t_rows();
--        rows.extend;   rows(rows.last) := rowmdlmap;
--
--        action := t_actionrowset(rows, 'Model Mapping Rules Specific (New)', 2, 2, 'insert');
--        actions.extend;
--        actions(actions.last) := action;
        
        insert into nci_dload_mdl_map_spec (hdr_id) values (v_id);
        insert into onedata_ra.nci_dload_mdl_map_spec (hdr_id) values (v_id);
        commit;
    end if;
    if (ihook.getColumnValue(rowhdr, 'DLOAD_FMT_ID') = 230) then
        rows := t_rows();
        rows.extend;   rows(rows.last) := rowdatacoll;

--       if (ihook.getColumnValue(rowdatacoll, 'CNTXT_ID') is null) then
--           raise_application_error(-20000, 'Alternate Name Context and Type must be selected when column heading is set to CDE Alternate Name.');
--           return;
--        end if;
       if (ihook.getColumnValue(rowdatacoll, 'ALT_NM_TYP_ID') is null and ihook.getColumnValue(rowdatacoll, 'COL_ID') = 91) then
           -- v_err_str := 'Alternate Name Type must be selected when column heading is set to CDE Alternate Name.';
           raise_application_error(-20000, 'Alternate Name Type must be selected when column heading is set to CDE Alternate Name.');
           return;
       end if;
        action := t_actionrowset(rows, 'Custom Data Collection Excel', 2, 2, 'insert');
        actions.extend;
        actions(actions.last) := action;
    end if;

    if (ihook.getColumnValue(rowhdr, 'DLOAD_FMT_ID') in (224)) then
        rows:= t_rows();
        rows.extend; rows(rows.last) := rowcstm;

        action := t_actionrowset(rows,'Custom CDE Subtype', 2, 2, 'insert');
        actions.extend; actions(actions.last) := action;

--        rows.extend; rows(rows.last) := rowcstm;
--        action := t_actionrowset(rows,'Custom CDE Download - Column Relationship', 2, 2, 'insert');
--        actions.extend; actions(actions.last) := action;
    end if;
    
    if (ihook.getColumnValue(rowhdr, 'DLOAD_FMT_ID') in (223)) then
        rows:= t_rows();
        rows.extend; rows(rows.last) := rownihsub;
        
        action := t_actionrowset(rows, 'NIH Submission Template Specific', 2, 2, 'insert');
        actions.extend; actions(actions.last) := action;
    end if;
    --jira    :catch any errors  
    if (v_err_str is not null) then
        raise_application_error(-20000,v_err_str);
        return;
    end if;
    
    hookoutput.actions := actions;
    hookoutput.message := 'Collection Successfully Created with ID ' || v_id;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     --nci_util.debugHook('GENERAL', v_data_out);
END;

    -- Not used at this time.
procedure spCreateDloadProfileGuest (v_data_in in clob, v_data_out out clob,  v_usr_id  IN varchar2)
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
     --   ihook.setColumnValue(row, 'HDR_ID', -1);
           ihook.setColumnValue(row, 'HDR_ID', v_fmt);
       ihook.setColumnValue(row, 'DLOAD_FMT_ID',v_fmt );
        rows.extend;          rows(rows.last) := row;
          rowsethdr := t_rowset(rows, 'Download Header (Base Object)', 1, 'NCI_DLOAD_HDR');

                rows := t_rows();
                row := t_row();
                 ihook.setColumnValue(row, 'HDR_ID', -1);
                rows.extend;          rows(rows.last) := row;
                rowsetals := t_rowset(rows, 'ALS Specific', 1, 'NCI_DLOAD_HDR');

                hookOutput.forms := getCollectionCreateFormGuest(rowsethdr, rowsetals,v_fmt);

          HOOKOUTPUT.QUESTION    := getALSCreateQuestion ( false);
      end if;
    if  hookinput.invocationnumber = 2 then--- Second invocation
         forms              := hookInput.forms;
         form1              := forms(1);
        rowhdr := form1.rowset.rowset(1);
        v_als := false;
    --    raise_application_error(-20000, hookinput.answerid);
       v_fmt := ihook.getColumnValue(rowhdr, 'HDR_ID');

        if (v_fmt  in (90, 110)) then
            form1              := forms(2);
            rowals := form1.rowset.rowset(1);
            v_als := true;
        end if;
       v_id := nci_11179_2.getCollectionId;
        ihook.setColumnValue(rowhdr, 'HDR_ID', v_id);
           ihook.setColumnValue(rowhdr, 'DLOAD_FMT_ID',v_fmt );

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
    if (v_fmt in ( 90,110) ) then 
    action := t_actionrowset(rows,'ALS Specific', 2,2,'insert');
    else
        action := t_actionrowset(rows,'ALS Specific for Form', 2,2,'insert');

    end if;
    actions.extend;
    actions(actions.last) := action;
    end if;
    hookoutput.actions := actions;
    hookoutput.message := 'Collection Successfully Created with ID ' || v_id;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     nci_util.debugHook('GENERAL', v_data_out);
END;



procedure spEditDloadProfileGuest (v_data_in in clob, v_data_out out clob,v_coll_typ in varchar2, v_usr_id  IN varchar2)
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

          hookOutput.forms := getALSCreateForm(rowsethdr, rowsetals,v_coll_typ);
          HOOKOUTPUT.QUESTION    := getALSCreateQuestion( false);
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
    v_mm_id_ver varchar2(32);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset(1);
    -- 92 - FOrm, 93 - CDE
    -- Depending on the type of collection, show either Forms or CDE's

--jira 2321 add authorization check
 if (nci_dload.isUserAuth(ihook.getColumnValue(row_ori, 'HDR_ID'), v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a component to this collection.');
 end if;
 -- end 2321
v_item_typ_id := nci_11179_2.getDloadItemTyp (ihook.getColumnValue(row_ori,'DLOAD_FMT_ID'));

    if (hookinput.invocationnumber = 0) then
        rows := t_rows();

        -- Get items from user cart based on type
        for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_usr_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id = v_item_typ_id and cart_nm = v_deflt_cart_nm order by admin_item_typ_id) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   iHook.setcolumnvalue (ROW, 'CNTCT_SECU_ID', v_usr_id);
		   iHook.setcolumnvalue (ROW, 'CART_NM', v_deflt_cart_nm);
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
        hookoutput.message := 'Please add items to your cart.';
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
            if (v_item_typ_id = 58) then
                select mm_id_ver into v_mm_id_ver from vw_mdl_map_list_dload_new where mm_id = ihook.getColumnValue(row_sel, 'ITEM_ID') and mm_ver_nr = ihook.getColumnValue(row_sel, 'VER_NR');
                ihook.setColumnValue(row_sel, 'MM_ID_VER', v_mm_id_ver);
            else
                ihook.setColumnValue(row_sel, 'ITEM_ID', ihook.getColumnValue(row_sel, 'ITEM_ID'));
                ihook.setColumnValue(row_sel, 'VER_NR', ihook.getColumnValue(row_sel, 'VER_NR'));
            end if;
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
     for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_usr_id and ai.item_id = c.item_id 
     and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id = v_item_typ_id and cart_nm = v_Deflt_cart_nm order by admin_item_typ_id) loop

          ihook.setColumnValue(row_sel, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));
          v_cart_ttl := v_cart_ttl + 1;
          -- Add only if not already in collection.
          select count(*) into v_temp from nci_dload_dtl where hdr_id = ihook.getColumnValue(row_ori,'HDR_ID') and item_id = cur.ITEM_ID
          and ver_nr = cur.VER_NR;
          if (v_temp = 0) then
            if (v_item_typ_id = 58) then --mm insert
                select mm_id_ver into v_mm_id_ver from vw_mdl_map_list_dload_new where mm_id = cur.ITEM_ID and mm_ver_nr = cur.VER_NR;
                
                ihook.setColumnValue(row_sel, 'MM_ID_VER', v_mm_id_ver);
                --raise_application_error(-20000, 'here');
            else
                ihook.setColumnValue(row_sel, 'ITEM_ID', cur.ITEM_ID);
                ihook.setColumnValue(row_sel, 'VER_NR', cur.VER_NR);
            end if;
            
            rows.extend;
            rows (rows.last) := row_sel;
            
        else 
                 v_dup_str := substr(v_dup_str || ';' || ihook.getColumnValue(row_sel,'ITEM_ID'), 1, 4000);

           end if;
        end loop;
        end if;


        -- If something to add.
        if (rows.count > 0) then
            if (v_item_typ_id = 58) then --mm insert
                action := t_actionrowset(rows, 'Model Mapping Detail (New)', 2,0,'insert');
            else --all other download types
                action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
            end if;
                
            actions.extend;
            actions(actions.last) := action;

            RemoveDloadBlob (ihook.getColumnValue(row_ori, 'HDR_ID'), actions);

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
procedure spAddComponentToDloadByCartName (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
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
    v_cart_nm  varchar2(255);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset(1);
    -- 92 - FOrm, 93 - CDE
    -- Depending on the type of collection, show either Forms or CDE's
    --jira 2321 add authorization check
 if (nci_dload.isUserAuth(ihook.getColumnValue(row_ori, 'HDR_ID'), v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a component to this collection.');
 end if;
 -- end 2321

v_item_typ_id := nci_11179_2.getDloadItemTyp (ihook.getColumnValue(row_ori,'DLOAD_FMT_ID'));
    if (hookinput.invocationnumber = 0) then
nci_11179.getCartNameSelectionForm (hookOutput, v_usr_id);
	end if; -- First invocation



    if (hookinput.invocationnumber = 1) then
        rows := t_rows();
          row_sel := hookInput.selectedRowset.rowset(1);
          v_cart_nm := ihook.getColumnValue(row_sel, 'CART_NM');
--raise_application_error(-20000, v_cart_nm);
        -- Get items from user cart based on type
        for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_usr_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id = v_item_typ_id and cart_nm = v_cart_nm order by admin_item_typ_id) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   iHook.setcolumnvalue (ROW, 'CNTCT_SECU_ID', v_usr_id);
    	   iHook.setcolumnvalue (ROW, 'CART_NM', v_cart_nm);

		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'User Cart', 2, 'multi');
       	 hookoutput.showrowset := showrowset;
        hookOutput.question := getAddComponentCreateQuestionNamedCart;
        hookOutput.message :=  'Number of items in your cart: ' || rows.count;
     else
        hookoutput.message := 'Please add items to your cart.';
     end if;
	end if; -- First invocation

    if hookInput.invocationNumber = 2  then -- Items selected from cart. Second invocation
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

        /*if (hookinput.answerid = 2) then -- selected all from cart
      --  raise_application_error(-20000,hookinput.message);
     for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 
     and cntct_secu_id = v_usr_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and --CART_NM 
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

*/
        -- If something to add.
        if (rows.count > 0) then
            action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
            actions.extend;
            actions(actions.last) := action;
                RemoveDloadBlob (ihook.getColumnValue(row_ori, 'HDR_ID'), actions);

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
    v_mm_nm varchar2(255);
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
        elsif (ihook.getColumnValue(row_ori, 'DLOAD_TYP_ID') = 229) then
            v_item_typ_id := 58;
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
        hookoutput.message := 'Please add items to your cart.';
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
            if (v_item_typ_id = 58) then
                select mm_curated_nm into v_mm_nm from vw_mdl_map_list_dload where mm_id = ihook.getColumnValue(row_sel, 'ITEM_ID') and mm_ver_nr = ihook.getColumnValue(row_sel, 'VER_NR');
                insert into nci_dload_dtl (hdr_id, item_id, ver_nr) values (ihook.getColumnValue(row_ori, 'HDR_ID'),ihook.getColumnValue(row_sel, 'ITEM_ID'), ihook.getColumnValue(row_sel, 'VER_NR'));
                insert into onedata_ra.nci_dload_dtl (hdr_id, item_id, ver_nr) values (ihook.getColumnValue(row_ori, 'HDR_ID'),ihook.getColumnValue(row_sel, 'ITEM_ID'), ihook.getColumnValue(row_sel, 'VER_NR'));
                commit;
                insert into nci_dload_mdl_map_dtl(hdr_id,mm_nm_curated) values (ihook.getColumnValue(row_ori, 'HDR_ID'), v_mm_nm);
                insert into onedata_ra.nci_dload_mdl_map_dtl(hdr_id,mm_nm_curated) values (ihook.getColumnValue(row_ori, 'HDR_ID'), v_mm_nm);
                commit;
                
            else
            action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
            actions.extend;
            actions(actions.last) := action;
            hookoutput.actions := actions;
            end if;
        hookoutput.message := rows.count || ' item(s) added successfully to collection. ' ;
        end if;
    end if;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

procedure spAddModelMappingToDload (v_data_in in clob, v_data_out out clob, v_usr_id IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows t_rows;
    row_ori t_row;
    
    v_item_typ_id integer;
    
    forms t_forms;
    form1 t_form;
    row_sel t_row;
    v_found boolean;
    showrowset	t_showablerowset;
    v_temp number;
    v_dup_str varchar2(4000) := '';
    v_temp_str varchar2(81);
    v_hdr_id number;

BEGIN
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset(1);
    v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
    --raise_application_error(-20000, 'test successful');
    --auth check
    if (nci_dload.isUserAuth(ihook.getColumnValue(row_ori, 'HDR_ID'), v_usr_id) = false) then
        raise_application_error(-20000,'You are not authorized to add a component to this collection.');
    end if;
    
    v_item_typ_id := nci_11179_2.getDloadItemTyp (ihook.getColumnValue(row_ori,'DLOAD_FMT_ID'));
    
    if (ihook.getColumnValue(row_ori,'DLOAD_FMT_ID') <> 229) then
        --raise_application_error(-20000, v_item_typ_id);
        raise_application_error(-20000, 'You cannot add a model mapping to this collection type.');
    else
        if (hookinput.invocationnumber = 0) then   -- First invocation
            rows := t_rows();
            row_sel := hookInput.originalRowset.rowset(1);

--raise_application_error(-20000, v_cart_nm);
        -- Get items from user cart based on type
        v_found := false;
            for cur in (select c.mm_id, c.mm_ver_nr, c.mm_nm from vw_mdl_map_list_dload_new c, admin_item ai where ai.item_id = c.mm_id and ai.ver_nr = c.mm_ver_nr and
            ai.admin_item_typ_id = 58 ) loop
                row := t_row();
                iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.MM_ID);
                iHook.setcolumnvalue (ROW, 'VER_NR', cur.MM_VER_NR);
                ihook.setColumnValue( ROW, 'MM_NM', cur.mm_nm);

                rows.extend;
                rows (rows.last) := row;
                v_found := true;
            end loop;

            if (v_found) then
                showrowset := t_showablerowset (rows, 'Model Map List (DLoad) (New)', 2, 'multi');
                hookoutput.showrowset := showrowset;
                hookOutput.question := getAddComponentCreateQuestionNamedCart;
                hookOutput.message :=  'Number of Model Mappings ' || rows.count;
             else
                hookoutput.message := 'Please add items to your cart.';
            end if;
	end if; -- First invocation

    if hookInput.invocationNumber = 1  then -- Items selected from cart. Second invocation
       rows := t_rows();
       if (hookinput.answerid = 1) then
       for i in 1..hookInput.selectedRowset.rowset.count loop -- Loop thru all the selected items.

          
          row_sel := hookInput.selectedRowset.rowset(i);
          v_temp_str := ihook.getColumnValue(row_sel, 'MM_ID') || 'v' || ihook.getColumnValue(row_sel, 'MM_VER_NR');
            insert into nci_dload_mdl_map_dtl_new (hdr_id, mm_id_ver) values (v_hdr_id, v_temp_str);
            insert into onedata_ra.nci_dload_mdl_map_dtl_new (hdr_id, mm_id_ver) values (v_hdr_id, v_temp_str);
          --ihook.setColumnValue(row_sel, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));

          -- Add only if not already in collection.
          select count(*) into v_temp from nci_dload_dtl where hdr_id = v_hdr_id and item_id = ihook.getColumnValue(row_sel,'MM_ID')
          and ver_nr = ihook.getColumnValue(row_sel,'MM_VER_NR');
--          if (v_temp = 0) then
--          	   rows.extend;
--                rows (rows.last) := row_sel;
--        else -- duplicate
--            v_dup_str := substr(v_dup_str || ';' || ihook.getColumnValue(row_sel,'ITEM_ID'), 1, 4000);
--        --    v_dup_str := v_dup_str || ';' || ihook.getColumnValue(row_sel,'ITEM_ID');
--           end if;
        end loop;
        end if;

    row_sel := t_row();
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
    row_mm t_row;
    rows  t_rows;
    rowscart  t_rows;
    rows_mm t_rows;
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
  v_retain_ind number(1);
  v_mm_nm varchar2(255);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);
        -- 92 - FOrm, 93 - CDE
      -- Depending on the type of collection, show either Forms or CDE's
      --jira 2321 add authorization check
 if (nci_dload.isUserAuth(ihook.getColumnValue(row_ori, 'HDR_ID'), v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a component to this collection.');
 end if;
 -- end 2321

v_item_typ_id := nci_11179_2.getDloadItemTyp (ihook.getColumnValue(row_ori,'DLOAD_FMT_ID'));

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
---raise_application_error(-20000, v_item_typ_id);

        v_cnt_valid_fmt := 0;
        v_cnt_valid_type := 0;

select max(nvl(retain_ind,0)) into v_retain_ind from nci_usr_cart where cart_nm = v_deflt_cart_nm and cntct_secu_id = v_usr_id and upper(guest_usr_nm) = 'NONE';

        forms              := hookInput.forms;
        form1              := forms(1);
        row_sel := form1.rowset.rowset(1);
        v_str := trim(ihook.getColumnValue(row_sel, 'VM_DESC_TXT'));
             cnt := nci_11179.getwordcount(v_str);

        row := t_row();
        rows := t_rows();
        rowscart := t_rows();
        rows_mm := t_rows();
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
                      	   iHook.setcolumnvalue (ROW, 'CART_NM', v_deflt_cart_nm);
                rows.extend;
                            rows (rows.last) := row;
                            v_found := false;
                            if (v_item_typ_id = 58) then 
                            row_mm := row;-- model map insert
                                ihook.setColumnValue(row_mm, 'HDR_ID', ihook.getColumnValue(row_ori, 'HDR_ID'));
                                select mm_id_ver into v_mm_nm from vw_mdl_map_list_dload_new where mm_id = cur.item_id and mm_ver_nr = cur.ver_nr;
                                ihook.setColumnValue(row_mm, 'MM_ID_VER', v_mm_nm);
                                rows_mm.extend;
                                rows_mm(rows_mm.last) := row_mm;
                            end if;
                            -- Add to user cart as well as per curator.

                        nci_11179_2.AddItemToCart(cur.item_id, cur.ver_nr, v_usr_id, v_deflt_cart_nm, v_retain_ind, rowscart);
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
--            action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
--            actions.extend;
--            actions(actions.last) := action;           
            if (v_item_typ_id = 58) then -- insert into mdl map rules details            
                action := t_actionrowset(rows_mm, 'Model Mapping Detail (New)', 2, 0, 'insert');
                actions.extend;
                actions(actions.last) := action;
            else --all other download types
                action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
                actions.extend;
                actions(actions.last) := action;
            end if;
        end if;
            /*  If item not already in cart */
            if (rowscart.count  > 0) then
                action := t_actionrowset(rowscart, 'User Cart', 2,0,'insert');
                actions.extend;
                actions(actions.last) := action;
            end if;

        if (actions.count > 0) then
         RemoveDloadBlob (ihook.getColumnValue(row_ori, 'HDR_ID'), actions);
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



procedure spAddComponentToDloadName (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
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
  question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
 v_cnt_already integer;
  v_invalid_fmt varchar2(50) := '';
  v_invalid_typ varchar2(100) := '';
  v_dup_str  varchar2(50) := '';
  v_none_str varchar2(8) := 'none';
  
  rows_mm t_rows;
  row_mm t_row;
  v_mm_id_ver varchar2(32);

begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);
        -- 92 - FOrm, 93 - CDE
      -- Depending on the type of collection, show either Forms or CDE's
      --jira 2321 add authorization check
 if (nci_dload.isUserAuth(ihook.getColumnValue(row_ori, 'HDR_ID'), v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a component to this collection.');
 end if;
 -- end 2321

v_item_typ_id := nci_11179_2.getDloadItemTyp (ihook.getColumnValue(row_ori,'DLOAD_FMT_ID'));

    if (hookinput.invocationnumber = 0) then   -- First invocation
         forms                  := t_forms();
        form1                  := t_form('Specify Name to Add Item to Collection (Hook)', 2,1);
        forms.extend;    forms(forms.last) := form1;
        hookoutput.forms := forms;
       	 hookOutput.question := getAddComponentCreateQuestionNameS1;
	end if;


    if (hookinput.invocationnumber = 1) then   -- First invocation
        forms              := hookInput.forms;
        form1              := forms(1);
        row_sel := form1.rowset.rowset(1);
        v_str := upper(trim(ihook.getColumnValue(row_sel, 'VM_DESC_TXT')));
       rows := t_rows();

       for cur in (Select * from admin_item where admin_item_typ_id = v_item_typ_id and upper(item_nm) like '%' || v_str || '%') loop
        row := t_row();

         ihook.setColumnValue(row, 'ITEM_ID', cur.item_id);
         ihook.setColumnValue(row, 'VER_NR', cur.ver_nr);
                            rows.extend;
                            rows (rows.last) := row;

       end loop;

    if (rows.count > 0) then
	   	 showrowset := t_showablerowset (rows, 'Administered Item', 2, 'multi');
       	 hookoutput.showrowset := showrowset;

       	 hookOutput.question := getAddComponentCreateQuestionNameS2;
	end if;
    end if;
    if hookInput.invocationNumber = 2  then  -- Second invocation
       rows := t_rows();
       row := t_row();
---raise_application_error(-20000, v_item_typ_id);

        row := t_row();
        rows := t_rows();
        rowscart := t_rows();
        rows_mm := t_rows();
        ihook.setColumnValue(row, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));

          for i in 1..hookinput.selectedRowset.rowset.count loop

        row_sel := hookinput.selectedRowset.rowset(i);

         v_item_id := ihook.getcolumnvalue(row_sel,'ITEM_ID');
         v_ver_nr := ihook.getColumnValue(row_sel,'VER_NR');
         
        -- Only add if item is of the right type and not currently in collection.
                        for cur in (select * from admin_item where item_id = v_item_id and ver_nr =v_ver_nr and (item_id, ver_nr) not in
                        (select item_id, ver_nr from nci_dload_dtl where hdr_id = ihook.getColumnValue(row_ori,'HDR_ID'))) loop
                            ihook.setColumnValue(row, 'ITEM_ID', cur.item_id);
                            ihook.setColumnValue(row, 'VER_NR', cur.ver_nr);
                            ihook.setColumnValue(row,'CNTCT_SECU_ID', v_usr_id);
                            ihook.setColumnValue(row,'GUEST_USR_NM', 'NONE');
                            iHook.setcolumnvalue (ROW, 'CART_NM', v_deflt_cart_nm);
                            rows.extend;
                            rows (rows.last) := row;
                            -- Add to user cart as well as per curator.
                            select count(*) into v_temp from nci_usr_cart where item_id  =cur.item_id and ver_nr = cur.ver_nr and cntct_secu_id = v_usr_id
                            and cart_nm = v_deflt_cart_nm;
                              if (v_temp = 0) then
                                    rowscart.extend;
                                    rowscart (rowscart.last) := row;
                              end if;
                            if (v_item_typ_id = 58) then --mm insert
                                row_mm := t_row();
                                ihook.setColumnValue(row_mm, 'HDR_ID', ihook.getColumnValue(row_ori,'HDR_ID'));
                                select mm_id_ver into v_mm_id_ver from vw_mdl_map_list_dload_new where mm_id = v_item_id and mm_ver_nr = v_ver_nr;
                                ihook.setColumnValue(row_mm, 'MM_ID_VER',v_mm_id_ver);
                                rows_mm.extend;
                                rows_mm(rows_mm.last) := row_mm;
                            end if;
                end loop;

    end loop;
        -- If Item needs to be added.
        if (rows.count > 0) then
            if (v_item_typ_id = 58) then --model map insert
                action := t_actionrowset(rows_mm, 'Model Mapping Detail (New)', 2,0,'insert');
                actions.extend;
                actions(actions.last) := action;
            else --all other download types
                action := t_actionrowset(rows, 'Download Detail', 2,0,'insert');
                actions.extend;
                actions(actions.last) := action;
            end if;
        end if;
            /*  If item not already in cart */
            if (rowscart.count  > 0) then
                action := t_actionrowset(rowscart, 'User Cart', 2,0,'insert');
                actions.extend;
                actions(actions.last) := action;
            end if;

        if (actions.count > 0) then
         RemoveDloadBlob (ihook.getColumnValue(row_ori, 'HDR_ID'), actions);
            hookoutput.actions := actions;
        end if;
             hookoutput.message := 'Total Items: ' || hookinput.selectedRowset.rowset.count ||  '    Items added: ' || nvl(rows.count,0) ;

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
              --jira 2321 add authorization check
 if (nci_dload.isUserAuth(ihook.getColumnValue(row_ori, 'HDR_ID'), v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a component to this collection.');
 end if;
 -- end 2321

v_item_typ_id := nci_11179_2.getDloadItemTyp (ihook.getColumnValue(row_ori,'DLOAD_FMT_ID'));

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
          --  hookoutput.message := 'Invalid Pin. Please check and try again.';
        --    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
        raise_application_error(-20000,'Invalid Pin. Please check and try again.');
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

function getALSCreateQuestion ( v_initial in boolean) return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin
    ANSWERS                    := T_ANSWERS();
   -- raise_application_error(-20000, v_typ);
    if (v_initial = true) then
    ANSWER                     := T_ANSWER(1,1,  'Next');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;

    QUESTION               := T_QUESTION('Select Collection Type', ANSWERS);
  else
  ANSWER                     := T_ANSWER(1,1,  'Create');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;

    QUESTION               := T_QUESTION('Create New Collection', ANSWERS);
end if;
return question;
end;



function getALSCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset, v_coll_typ in integer) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('Download Header (Hook)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;

    if (v_coll_typ = 90) then
    form1                  := t_form('ALS Specific', 2,1);

    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
    elsif (v_coll_typ = 110 ) then
    form1                  := t_form('ALS Specific for Form', 2,1);

    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
    elsif (v_coll_typ = 224) then
    form1 := t_form('Custom CDE Subtype', 2, 1);

    form1.rowset :=v_rowset2;
    forms.extend;   forms(forms.last) :=form1;
--    elsif (v_coll_typ = 229) then
--    form1 := t_form('Model Mapping Rules Specific (New)', 2,1);
--
--    form1.rowset :=v_rowset2;
--    forms.extend;   forms(forms.last) :=form1;
    elsif (v_coll_typ = 230) then
    form1 := t_form('Custom Data Collection Excel', 2, 1);

    form1.rowset := v_rowset2;
    forms.extend;   forms(forms.last) := form1;
    elsif (v_coll_typ = 223) then
    form1 := t_form('NIH Submission Template Specific', 2, 1);
    
    form1.rowset := v_rowset2;
    forms.extend;   forms(forms.last) := form1;
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
    elsif (v_dload_typ = 110 ) then
    form1                  := t_form('ALS Specific for Form', 2,1);

    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
    end if;
  return forms;
end;

procedure spInitCstmColOrder(hdr_id in number, v_mode in varchar2)
AS
    v_hdr_id number;
    v_cnt number;
    j number;
BEGIN

    v_hdr_id := hdr_id;
    j := 2;
    select count(*) into v_cnt from nci_dload_cstm_col_dtl where hdr_id = v_hdr_id;
   -- raise_application_error(-20000, v_cnt);
    if (v_cnt > 0) then
        if (v_mode = 'I') then
            for i in (select col_id from nci_dload_cstm_col_dtl where hdr_id = v_hdr_id) LOOP
                update nci_dload_cstm_col_dtl set col_pos = j where hdr_id = v_hdr_id and col_id = i.col_id;
                j := j+1;
            END LOOP;
        elsif (v_mode = 'R') then
     --   raise_application_error(-20000, v_mode);
            j := 1;
            for i in (select col_id from nci_dload_cstm_col_dtl where hdr_id = v_hdr_id order by col_pos asc) LOOP
                update nci_dload_cstm_col_dtl set col_pos = j where hdr_id = v_hdr_id and col_id = i.col_id;
              --  raise_application_error(-20000, v_hdr_id);
                j := j+1;
            END LOOP;
        end if;
    end if;
END;

procedure spAppendColumn(hdr_id in number, col_id in number)
AS
    v_hdr_id number;
    v_col_id number;
    v_cnt number;
    j number;
BEGIN
    v_hdr_id := hdr_id;
    v_col_id := col_id;
    select max(col_pos) into v_cnt from nci_dload_cstm_col_dtl where hdr_id = v_hdr_id;
    j := v_cnt + 1;
    update nci_dload_cstm_col_dtl set col_pos = j where hdr_id = v_hdr_id and col_id = v_col_id;
 --  raise_application_error(-20000, v_hdr_id);
END;

procedure spResetCstmColOrder  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
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
    i integer;

     v_sql  varchar2(4000);
BEGIN
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    row_ori :=  hookInput.originalRowset.rowset(1);

    rows := t_rows();
--if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = false) then
-- raise_application_error(-20000,'You are not authorized to edit module to this form.');
-- end if;
    i := 0;
 --   raise_application_error(-20000, ihook.getColumnValue(row_ori, 'HDR_ID'));
    for cur in (select * from nci_dload_cstm_col_dtl where nvl(fld_delete,0) = 0 and hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID') order by col_pos) loop
                if (i <> cur.col_pos) then
                    row := t_row();
                    v_sql := 'select * from nci_dload_cstm_col_dtl where  col_id = ' ||  cur.col_id || ' and hdr_id = ' || cur.hdr_id || ' and col_pos = ' || cur.col_pos ;
                    nci_11179.ReturnRow(v_sql, 'NCI_DLOAD_CSTM_COL_DTL', row);
                    ihook.setColumnValue(row, 'COL_POS', i);
                    rows.extend;                    rows(rows.last) := row;
                end if;
                i := i+1;
    end loop;

    action := t_actionRowset(rows, 'Custom CDE Download - Column Relationship', 2, 1000, 'update');
    actions.extend; actions(actions.last) := action;
    hookoutput.actions:= actions;

    v_data_out := ihook.getHookOutput(hookOutput);
    --nci_util.debugHook('FORM',v_data_out);

END;

procedure spReorderColumns  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  j integer;
 question    t_question;
answer     t_answer;
answers     t_answers;
 forms t_forms;
    form1 t_form;
    v_cur_disp_ord number;
    v_new_disp_ord number;
    v_max_disp_ord number;
     rowform t_row;
     v_sql  varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);
 v_cur_disp_ord := ihook.getColumnValue(row_ori, 'COL_POS');

--if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
-- raise_application_error(-20000,'You are not authorized to edit module to this form.');
-- end if;
   if hookInput.invocationNumber = 0 then  -- If first invocation, prompt for version number

        hookOutput.forms := nci_form_mgmt.getReorderForm;
        hookoutput.question := nci_form_mgmt.getReorderQuestion(v_cur_disp_ord);
	elsif hookInput.invocationNumber = 1 then  -- Position specified...
            forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);
            v_new_disp_ord := ihook.getColumnValue(rowform,'ITEM_ID');

            select least(max(col_pos), count(col_pos))  into v_max_disp_ord from nci_dload_cstm_col_dtl where hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID') and nvl(fld_Delete,0) = 0;

            if (v_new_disp_ord < 0) then
                raise_application_error(-20000, 'Invalid Display Order.');
                return;
            end if;

            if (v_new_disp_ord > v_max_disp_ord) then
                v_new_disp_ord := v_max_disp_ord;
            end if;

 --  if current position is greater than new position

            rows := t_rows();

            if (v_cur_disp_ord > v_new_disp_ord) then
                j := v_new_disp_ord;
                for i in v_new_disp_ord..v_cur_disp_ord-1 loop
                    row := t_row();
             --       v_sql := 'select hdr_id, fmt_nm, col_id, col_pos, dt_last_modified, creat_dt, creat_usr, retain_ind, creat_usr_id, lst_upd_usr_id, fld_delete, lst_del_dt, s2p_trn_dt, lst_upd_dt from nci_dload_cstm_col_dtl where nvl(fld_delete,0) = 0 and hdr_id = ' ||  ihook.getColumnValue(row_ori, 'HDR_ID') || ' and col_pos = ' || i ;
                    v_sql := 'select * from nci_dload_cstm_col_dtl where nvl(fld_delete,0) = 0 and hdr_id = ' ||  ihook.getColumnValue(row_ori, 'HDR_ID') || ' and col_pos = ' || i ; 
                    nci_11179.ReturnRow(v_sql, 'NCI_DLOAD_CSTM_COL_DTL', row);
                    if (ihook.getColumnValue(row, 'COL_ID') is not null) then
                        j := j+1;
                        ihook.setColumnValue(row, 'col_pos', j);
                        rows.extend;                    rows(rows.last) := row;
                    end if;
                end loop;
            end if;
 -- if current position is less than new position

            if (v_cur_disp_ord < v_new_disp_ord) then
                j := v_cur_disp_ord + 1;
                for i in v_cur_disp_ord+1..v_new_disp_ord loop
                    row := t_row();
                    v_sql := 'select * from nci_dload_cstm_col_dtl where nvl(fld_delete,0) = 0 and hdr_id = ' ||  ihook.getColumnValue(row_ori, 'HDR_ID') ||  ' and col_pos = ' || i ;
                    nci_11179.ReturnRow(v_sql, 'NCI_DLOAD_CSTM_COL_DTL', row);
                    if (ihook.getColumnValue(row, 'COL_ID') is not null) then
                        ihook.setColumnValue(row, 'col_pos', j-1);
                        j := j+1;
                        rows.extend;                    rows(rows.last) := row;
                    end if;
                end loop;
            end if;
     -- update current row
            row := t_row();
            v_sql := 'select * from nci_dload_cstm_col_dtl where nvl(fld_delete,0) = 0 and hdr_id = ' ||  ihook.getColumnValue(row_ori, 'HDR_ID') ||  ' and col_pos = ' || v_cur_disp_ord ;
            nci_11179.ReturnRow(v_sql, 'NCI_DLOAD_CSTM_COL_DTL', row);

            ihook.setColumnValue(row, 'col_pos', v_new_disp_ord);
            rows.extend;            rows(rows.last) := row;

            action := t_actionRowset(rows, 'Custom CDE Download - Column Relationship', 2, 1000, 'update');
            actions.extend; actions(actions.last) := action;
            hookoutput.actions:= actions;
    end if;
     v_data_out := ihook.getHookOutput(hookOutput);
--    nci_util.debugHook('FORM',v_data_out);

END;

procedure spRemoveGaps  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2, v_mode in varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_hdr_id number;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);
v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
spInitCstmColOrder(v_hdr_id, 'R');

v_data_out := ihook.getHookOutput(hookOutput);

END;

function validateDataColl (v_hdr_id in number) return varchar2 is
  v_err_str varchar2(255):= '';
  v_cnt number;
  v_fmt_id number;
  v_cde_lbl_id number;
  v_alt_nm_typ_id number;
  v_alt_nm_cntxt_id number;
BEGIN
select count(*) into v_cnt from nci_dload_hdr where hdr_id = v_hdr_id;
--if (v_cnt < 1) then
--    v_err_str := 'The collection does not exist.';
--else
    select dload_fmt_id into v_fmt_id from nci_dload_hdr where hdr_id = v_hdr_id;

    if (v_fmt_id = 230) then
        select col_id, alt_nm_typ_id, cntxt_id into v_cde_lbl_id, v_alt_nm_typ_id, v_alt_nm_cntxt_id from nci_dload_cstm_data_coll where hdr_id = v_hdr_id;
    --raise_application_error(-20000, v_cde_lbl_id);
        if (v_cde_lbl_id = 91) then
            if (v_alt_nm_typ_id is null) then
                v_err_str := 'Alternate Name Type must be selected when column heading is set to CDE Alternate Name.';
            end if;
--            if (v_alt_nm_cntxt_id is null) then
--                v_err_str := 'Alternate Name Context must be selected when column heading is set to CDE Alternate Name.';
--            end if;
        end if;
    end if;
--end if;
return v_err_str;

END;

procedure spInitMMRCollection (v_hdr_id in number) is
BEGIN
    for cur in (select item_id, ver_nr, item_nm, item_long_nm from admin_item where admin_item_typ_id = 58) loop
        insert into nci_dload_mdl_map_sel (item_id, ver_nr, item_nm, item_long_nm, hdr_id) values (cur.item_id, cur.ver_nr, cur.item_nm, cur.item_long_nm, v_hdr_id);
        insert into onedata_ra.nci_dload_mdl_map_sel (item_id, ver_nr, item_nm, item_long_nm, hdr_id) values (cur.item_id, cur.ver_nr, cur.item_nm, cur.item_long_nm, v_hdr_id);
        commit;
    end loop;
end;

END;
/
