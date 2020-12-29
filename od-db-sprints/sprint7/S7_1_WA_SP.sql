create or replace PACKAGE nci_11179 AS
function getWordCount(v_nm in varchar2) return integer;
function getWord(v_nm in varchar2, v_idx in integer, v_max in integer) return varchar2;
FUNCTION get_concepts(v_item_id in number, v_ver_nr in number) return varchar2;
 Function get_concept_order(v_item_id in number, v_ver_nr in number) return varchar2 ;
 function cmr_guid return varchar2;
FUNCTION getPrimaryConceptName(v_nm in varchar2) return varchar2;
procedure spAddToCart ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spAddToCartGuest ( v_data_in in clob, v_data_out out clob);
procedure spRemoveFromCart (v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spNCIChangeLatestVer (v_data_in in clob, v_data_out out clob);
procedure spAddConceptRel (v_data_in in clob, v_data_out out clob);
procedure spCreateVerNCI (v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure getConcatNmDef(v_item_id in number, v_ver_nr in number, v_nm out varchar2, v_long_nm out varchar2,v_def out varchar2);
procedure spCopyModuleNCI (actions in out t_actions, v_from_module_id in number,v_from_module_ver in number,  v_from_form_id in number, v_from_form_ver number, v_to_form_id number, v_to_form_ver number);

function getItemId return integer;
procedure CncptCombExists (v_nm in varchar2, v_item_typ in integer, v_item_id out number, v_item_ver_nr out number, v_long_nm out varchar2, v_def out varchar2);
function replaceChar(v_str in varchar2) return varchar2;

/*  This package includes generic functions as well as versioning related procedures for NCI 

geWordCOunt - gets the word count of a string separated by spaces. Used to parse the string the user provides in DEC creation 
getWord - get the specific word in v_idx position from a string
cmr_guid - generatest he NCI_IDSEQ
spAddToCart , spRemoveFromCart - add selected administered Items to user cart - called from command hook
spAddToCartGuest - Add to cart for Guest user. 
spNCIChangeLatestVer - Change latest version for a selected AI 
spCreateVerNCI - Create new version customized

*/
END;
/
create or replace PACKAGE BODY            nci_11179 AS

v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
type       t_orgs is table of org_cntct.org_id%type; 

/*  This package includes generic functions as well as versioning related procedures for NCI */
/***********************************************/
FUNCTION CMR_GUID RETURN VARCHAR2 IS
  /*
  ** generate NCI_IDSEQ for reverse caDSR functionality.
  */
    V_GUID  CHAR(32);
    V_OUT   VARCHAR2(36);
  BEGIN
    V_GUID := RAWTOHEX(SYS.STANDARD.SYS_GUID);
    V_OUT := SUBSTR(V_GUID,1,8)||'-';
    V_OUT := V_OUT||SUBSTR(V_GUID,9,4)||'-';
    V_OUT := V_OUT||SUBSTR(V_GUID,13,4)||'-';
    V_OUT := V_OUT||SUBSTR(V_GUID,17,4)||'-';
    V_OUT := V_OUT||SUBSTR(V_GUID,21);
    RETURN V_OUT;
  END CMR_GUID;

/*  This function usage is on hold */
FUNCTION getPrimaryConceptName(v_nm in varchar2) return varchar2 is
v_out number;
v_temp varchar2(255);
i integer;
begin
i := getWordCount(v_nm);
v_temp := getWord(v_nm, i+1,i+1);
return v_temp;
end;

/*  Generate Public ID for Asminiteres Item */
function getItemId return integer is
v_out integer;
begin
select od_seq_ADMIN_ITEM.nextval  into v_out from dual;
return v_out;
end;

/* Used when parsing user input during creation of concept-related AI entities like DEC, Rep Term, VM */
FUNCTION getWordCount (v_nm IN varchar2) RETURN integer IS
    V_OUT   Integer;
  BEGIN
  v_out := REGEXP_COUNT( v_nm, '\s');

    RETURN V_OUT+1;
  END;

/*  This function is used in Compare PV. Due to the old OD mode not showing some characters correctly, we call this procedure before displaying the result */
function replaceChar(v_str in varchar2) return varchar2 IS
    V_OUT  varchar2(255);
  BEGIN
  v_out := replace(v_str, '''','`');
  v_out := replace(v_out, '"','`');
    RETURN V_OUT;
  END;


/* Function returns the Item ID and associated inforamtion if the concept combination found. */
procedure CncptCombExists (v_nm in varchar2, v_item_typ in integer, v_item_id out number, v_item_ver_nr out number, v_long_nm out varchar2, v_def out varchar2)
as
v_out integer;
begin

    for cur in (select ext.* from nci_admin_item_ext ext,admin_item a 
    where nvl(a.fld_delete,0) = 0 and a.item_id = ext.item_id and a.ver_nr = ext.ver_nr and cncpt_concat = v_nm and a.admin_item_typ_id = v_item_typ) loop
            v_item_id := cur.item_id;
            v_item_ver_nr := cur.ver_nr;
            v_long_nm := cur.cncpt_concat_nm;
            v_def := cur.cncpt_concat_def;
    end loop;
end;


/* Get the string in position v_idx within string v_nm */
function getWord(v_nm in varchar2, v_idx in integer, v_max in integer) return varchar2 is
   v_word  varchar2(100);
begin  
  if (v_idx = 1 and v_idx = v_max)then
    v_word := v_nm;
  elsif  (v_idx = 1 and v_idx < v_max)then
    v_word := substr(v_nm, 1, instr(v_nm, ' ',1,1)-1);
  elsif (v_idx = v_max) then
     v_word := substr(v_nm, instr(v_nm, ' ',1,v_idx-1)+1);
  else
     v_word := substr(v_nm, instr(v_nm, ' ',1,v_idx-1)+1,instr(v_nm, ' ',1,v_idx)-instr(v_nm, ' ',1,v_idx-1));
  end if;
  return trim(upper(v_word));
end;


/* Usage on hold */
procedure getConcatNmDef(v_item_id in number, v_ver_nr in number, v_nm out varchar2, v_long_nm out varchar2,v_def out varchar2) as
begin
    for cur in (select cncpt_concat , cncpt_concat_nm , cncpt_concat_def  from nci_admin_item_ext where item_id = v_item_id and ver_nr = v_ver_nr and fld_delete = 0) loop
        v_nm := cur.cncpt_concat;
        v_long_nm := cur.cncpt_concat_nm;
        v_def := cur.cncpt_concat_def;
    end loop;
end;


/* Used in deployment view. Not in any hooks */
function get_concepts(v_item_id in number, v_ver_nr in number) return varchar2 is
cursor con is
select c.item_nm, cai.NCI_CNCPT_VAL
from cncpt_admin_item cai, admin_item c
where cai.item_id = v_item_id and cai.ver_nr = v_ver_nr 
and cai.cncpt_item_id = c.item_id and cai.cncpt_ver_nr = c.ver_nr and c.admin_item_typ_id = 49
order by  nci_ord desc;

v_name varchar2(255);

begin
    for c_rec in con loop
        if v_name is null then
            v_name := c_rec.item_nm;

            /* Check if Integer Concept */
            if c_rec.item_nm = 'C45255' then
                v_name := v_name||'::'||c_rec.nci_cncpt_val;
            end if;
        else
            v_name := v_name||','||c_rec.item_nm;

            /* Check if Integer Concept */
            if c_rec.item_nm = 'C45255' then
                v_name := v_name||'::'||c_rec.nci_cncpt_val;
            end if;
        end if;

    end loop;
return v_name;
end;


/* Used in deployment view. Not in hooks */
function get_concept_order(v_item_id in number, v_ver_nr in number) return varchar2 is

cursor con is
select nci_ord
from cncpt_admin_item cai
where cai.item_id = v_item_id and cai.ver_nr = v_ver_nr 
order by  nci_ord desc;

v_order_sq varchar2(4000):= null;

begin
    for c_rec in con loop
        if v_order_sq is null then
            v_order_sq := c_rec.nci_ord;
        else
            v_order_sq := v_order_sq||','||c_rec.nci_ord;
        end if;
    end loop;
    return v_order_sq;
end;

/*FUNCTION get_concept_origin(v_item_id in number, v_ver_nr in number) return varchar2 is
cursor con is
select origin,display_order
from sbrext.component_Concepts_ext m, sbrext.concepts_ext c
where condr_idseq = p_condr_idseq
and m.con_idseq = c.con_idseq
order by display_order desc;

v_origin varchar2(2000):=null;

begin


for c_rec in con loop

if c_rec.display_order>0 then
  v_origin := v_origin||c_rec.origin||',';
else
  v_origin := v_origin||c_rec.origin;
end if;

end loop;

return v_origin;
end;
*/

/* Change Latest version for select Item Id. Command hook */
procedure spNCIChangeLatestVer (v_data_in in clob, v_data_out out clob)
as
hookInput           t_hookInput;
hookOutput           t_hookOutput := t_hookOutput();
showRowset     t_showableRowset;

rows      t_rows;
row          t_row;
row_cur t_row;
row_sel t_row;
question    t_question;
answer     t_answer;
answers     t_answers;

actions           t_actions := t_actions();
action           t_actionRowset;
v_found      boolean;
v_item_id		 number;
v_ver_nr		 number;

begin
    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    /*  Current row that the user selected. cardinality is always 1 for this hook */
    row_cur := hookInput.originalRowset.Rowset(1);
    rows := t_rows();

    if hookInput.invocationNumber = 0 then  -- First invocation - show all the versions for the select Item ID
        for cur in ( select item_id, ver_nr from admin_item where item_id = ihook.getColumnValue(row_cur,'ITEM_ID')) loop
            row := t_row();
            ihook.setColumnValue(row, 'ITEM_ID', cur.item_id);
            ihook.setColumnValue(row, 'VER_NR', cur.ver_nr);
            rows.extend; rows(rows.last) := row;
        end loop;

        showRowset := t_showableRowset(rows, 'Administered Item (Steward Assignment)',2, 'single');
        hookOutput.showRowset := showRowset;  -- Show rowset

        answers := t_answers();
  	   	answer := t_answer(1, 1, 'Select new latest version.');
  	   	answers.extend; answers(answers.last) := answer;
	   	question := t_question('Select option to proceed', answers);
       	hookOutput.question := question;  -- Ask the question

	elsif hookInput.invocationNumber = 1 then  -- Second invocation - set the actions 
		  if hookInput.answerId = 1 then -- selected form
               row_sel := hookInput.selectedRowset.rowset(1);  -- Row selected to be the latest version
                rows :=         t_rows();
                hookOutput.message := 'Already latest version.';

                if (ihook.getColumnValue(row_sel,'CURRNT_VER_IND') = 0) then --- oproceed only if the selected row is not already latest
                    row := t_row();
                    ihook.setColumnValue(row, 'ITEM_ID', ihook.getColumnValue(row_sel, 'ITEM_ID'));
                    ihook.setColumnValue(row, 'VER_NR', ihook.getColumnValue(row_sel, 'VER_NR'));
                    ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);   --- Set current version for selected row
                    rows.extend; rows(rows.last) := row;
                    for cur in (select item_id, ver_nr from admin_item where item_id = ihook.getColumnValue(row_sel, 'ITEM_ID') and currnt_ver_ind = 1) loop
                            row := t_row();
                            ihook.setColumnValue(row, 'ITEM_ID', cur.item_id);
                            ihook.setColumnValue(row, 'VER_NR', cur.ver_nr);
                            ihook.setColumnValue(row, 'CURRNT_VER_IND', 0);  -- unselect current version for the original latest version
                            rows.extend; rows(rows.last) := row;
                    end loop;
                    action := t_actionRowset(rows, 'Administered Item', 2, 1,'update');
                    actions.extend; actions(actions.last) := action;
                    hookOutput.actions := actions;
                    hookOutput.message := 'Successfully changed latest version.';
                end if;
        end if;
    end if;	   
    v_data_out := ihook.getHookOutput(hookOutput);
end;


/*  Command hook to add selected items to cart. Cardinality - 1 or more */
PROCEDURE spAddToCart (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id  varchar2)
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

    rows := t_rows();  
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);    
        v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
        select count(*) into v_temp from nci_usr_cart where item_id  = v_item_id and ver_nr = v_ver_nr and cntct_secu_id = v_user_id;
        /*  If not already in cart */
        if (v_temp = 0) then
            row := t_row();
            v_add := v_add + 1;
            ihook.setColumnValue(row,'ITEM_ID', v_item_id);
            ihook.setColumnValue(row,'VER_NR', v_ver_nr);
            ihook.setColumnValue(row,'CNTCT_SECU_ID', v_user_id);
            ihook.setColumnValue(row,'GUEST_USR_NM', 'NONE');
            rows.extend;    rows(rows.last) := row;
        else 
            v_already := v_already + 1;
        end if;
    end loop;
    if (v_add > 0) then   -- IF there are items to add to cart
        action := t_actionrowset(rows, 'User Cart', 2,0,'insert');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
        hookoutput.message := v_add || ' item(s) added successfully to cart. ' || v_already || ' item(s) selected already in yout cart';
    else
        hookoutput.message := v_already || ' item(s) selected already in yout cart';
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

/*  Command hook for Guest Add to Cart functionality */
PROCEDURE spAddToCartGuest
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
    v_temp integer;
    v_item_id varchar2(50);
    v_ver_nr varchar2(50);
    v_user_nm varchar2(255);

    v_add integer :=0;
    v_already integer :=0;
    i integer := 0;
    question    t_question;
    answer     t_answer;
    answers     t_answers;
    showrowset	t_showablerowset;
    forms t_forms;
    form1 t_form;
    rowform t_row;
begin
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  
    if hookInput.invocationNumber = 0 then  ---First invocation of the hook - prompt for user name
            ANSWERS                    := T_ANSWERS();
            ANSWER                     := T_ANSWER(1, 1, 'Add to cart.' );
            ANSWERS.EXTEND;
            ANSWERS(ANSWERS.LAST) := ANSWER;
            QUESTION               := T_QUESTION('Specify a name that will be used to store your selection in cart. Please use the same name everytime you add to cart. Your cart will be deleted end of day.' , ANSWERS);
            HOOKOUTPUT.QUESTION    := QUESTION;
            forms                  := t_forms();
            form1                  := t_form('User Cart (Hook)', 2,1);
            forms.extend;
            forms(forms.last) := form1;
            hookOutput.forms := forms;	   
	elsif hookInput.invocationNumber = 1 then  -- Second invocation - we now have the user name 
		  if hookInput.answerId = 1 then 
            forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);
            v_user_nm := ihook.getColumnValue(rowform, 'GUEST_USR_NM');

            for i in 1..hookinput.originalrowset.rowset.count loop -- Iterate throu all selected rows.
                row_ori := hookInput.originalRowset.rowset(i);
                v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
                v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
                select count(*) into v_temp from nci_usr_cart where item_id  = v_item_id and ver_nr = v_ver_nr  and guest_usr_nm = v_user_nm;

                if (v_temp = 0) then  -- Add to cart only if it does not already exist
                    row := t_row();
                    v_add := v_add + 1;
                    ihook.setColumnValue(row,'ITEM_ID', v_item_id);
                    ihook.setColumnValue(row,'VER_NR', v_ver_nr);
                    ihook.setColumnValue(row,'CNTCT_SECU_ID', 'GUEST');
                    ihook.setColumnValue(row,'GUEST_USR_NM', v_user_nm);
                    rows.extend;    rows(rows.last) := row;
                else v_already := v_already + 1;
                end if;
            end loop;
            if (v_add > 0) then -- If items avaiable to add
                action := t_actionrowset(rows, 'User Cart', 2,0,'insert');
                actions.extend;
                actions(actions.last) := action;
                hookoutput.actions := actions;
                hookoutput.message := v_add || ' item(s) added successfully to cart. ' || v_already || ' item(s) selected already in yout cart';
            else
                hookoutput.message := v_already || ' item(s) selected already in yout cart';
            end if;
         end if; 
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spRemoveFromCart  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id  varchar2)
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
    v_temp integer;
    v_item_id varchar2(50);
    v_ver_nr varchar2(50);
    i integer := 0;
begin
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();

    for i in 1..hookinput.originalrowset.rowset.count loop -- Iterate throu selected rows
        row_ori := hookInput.originalRowset.rowset(i);

        /* check to make sure the user is deleting from their cart */
        if (v_user_id <> ihook.getColumnValue(row_ori,'CNTCT_SECU_ID')) then 
            raise_application_error(-20000, 'You are not authorized to delete from another user cart');
        end if;

        rows.extend;
        rows(rows.last) := row_ori;
    end loop;
    /* Logically delete row first */
    action := t_actionrowset(rows, 'User Cart', 2,0,'delete');
    actions.extend;
    actions(actions.last) := action;
    /* Physically delete row after logical delete */
    action := t_actionrowset(rows, 'User Cart', 2,1,'purge');
    actions.extend;
    actions(actions.last) := action;

    hookoutput.actions := actions;
    hookoutput.message := 'Item(s) successfully deleted from cart';    

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


/*  Not sure if used */
PROCEDURE spAddConceptRel  (
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
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_temp integer;
  v_item_id varchar2(50);
  v_ver_nr varchar2(50);
  v_add integer :=0;
  v_already integer :=0;
  i integer := 0;
  column  t_column;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

   for i in 1..hookinput.originalrowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');

    row := t_row();
    v_add := v_add + 1;
    ihook.setColumnValue(row,'ITEM_ID', v_item_id);
    ihook.setColumnValue(row,'VER_NR', v_ver_nr);
    rows.extend;
    rows(rows.last) := row;
 end loop;
  if (v_add > 0) then 
    action := t_actionrowset(rows, 'NCI_USR_CART', 1,0,'insert');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    hookoutput.message := v_add || ' item(s) added successfully to cart. ' || v_already || ' item(s) selected already in yout cart';
    else
    hookoutput.message := v_already || ' item(s) selected already in yout cart';
    end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


/* Work in Progress */
procedure spCopyQuestion (actions in out t_actions, v_from_module_id in integer, v_from_module_ver in integer, v_to_module_id in integer, v_to_module_ver in integer) as
v_id integer;
v_found boolean;
v_itemid integer;
row  t_row;
rows t_rows;
rowsvv t_rows;
action t_actionRowset;

begin


 rowsvv:= t_rows();

 rows:= t_rows();
for cur in (select * from nci_admin_item_rel_alt_key where p_item_id = v_from_module_id and
        p_item_ver_nr = v_from_module_ver and rel_typ_id = 63) loop
    row := t_row();

  v_id := nci_11179.getItemId;
ihook.setColumnValue (row, 'NCI_PUB_ID', v_id);
ihook.setColumnValue (row, 'NCI_VER_NR', v_to_module_ver);
ihook.setColumnValue (row, 'P_ITEM_ID', v_to_module_id);
ihook.setColumnValue (row, 'P_ITEM_VER_NR', v_to_module_ver);
ihook.setColumnValue (row, 'C_ITEM_ID', cur.c_item_id);
ihook.setColumnValue (row, 'C_ITEM_VER_NR', cur.c_item_ver_nr);
ihook.setColumnValue (row, 'CNTXT_CS_ITEM_ID', cur.cntxt_cs_item_id);
ihook.setColumnValue (row, 'CNTXT_CS_VER_NR', cur.cntxt_cs_ver_nr);
ihook.setColumnValue (row, 'ITEM_LONG_NM', cur.ITEM_LONG_NM );
ihook.setColumnValue (row, 'REL_TYP_ID', 63);
ihook.setColumnValue (row, 'DISP_ORD', 1);


     rows.extend;
    rows(rows.last) := row;


    for cur1 in (select * from  NCI_QUEST_VALID_VALUE where q_pub_id = cur.nci_pub_id and q_ver_nr = cur.nci_ver_nr) loop
      row := t_row();
    ihook.setColumnValue (row, 'Q_PUB_ID', v_id);
    ihook.setColumnValue (row, 'Q_VER_NR', v_to_module_ver);
    ihook.setColumnValue (row, 'VM_NM', cur1.vm_nm);
    ihook.setColumnValue (row, 'VM_LNM', cur1.vm_lnm);
    ihook.setColumnValue (row, 'VM_DEF', cur1.vm_def);
    ihook.setColumnValue (row, 'VALUE', cur1.value);
    ihook.setColumnValue (row, 'MEAN_TXT', cur1.mean_txt);
    ihook.setColumnValue (row, 'DESC_TXT', cur1.desc_txt);
    v_itemid := nci_11179.getItemId;
    ihook.setColumnValue (row, 'NCI_PUB_ID', v_itemid);
    ihook.setColumnValue (row, 'NCI_VER_NR', 1);

     rowsvv.extend;
    rowsvv(rowsvv.last) := row;
    v_found := true;
  --  raise_application_error(-20000, 'Inside');
    end loop;   
--DESC_TXT
  --  raise_application_error(-20000, rows.count);
   end loop;
    action := t_actionrowset(rows, 'Questions (Edit)', 2,14,'insert');
    actions.extend;
    actions(actions.last) := action;

    if (v_found) then 
    action := t_actionrowset(rowsvv, 'Question Valid Values (Hook)', 2,16,'insert');
    actions.extend;
    actions(actions.last) := action;
  end if;

end;

/* Work in Progress */
procedure spCopyModuleNCI (actions in out t_actions, v_from_module_id in number,v_from_module_ver in number,  v_from_form_id in number, v_from_form_ver number, v_to_form_id number, v_to_form_ver number) as


action           t_actionRowset;
action_rows              t_rows := t_rows();
action_rows_csi              t_rows := t_rows();
row          t_row;
v_table_name varchar2(30);
v_sql        varchar2(4000);
v_to_module_id number;

v_cur        number;
v_temp        number;

v_col_val       varchar2(4000);

v_meta_col_cnt      integer;
v_meta_desc_tab      dbms_sql.desc_tab;

begin


-- Module
-- Module Rel
--Questions
-- Question VV
-- Question Repetition


v_table_name := 'ADMIN_ITEM';

 v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);
 v_to_module_id := nci_11179.getItemId;

    v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where item_id=:item_id and ver_nr=:ver_nr';

 v_cur := dbms_sql.open_cursor;
 dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
 dbms_sql.bind_variable(v_cur, ':item_id', v_from_module_id);
 dbms_sql.bind_variable(v_cur, ':ver_nr', v_from_module_ver);


 for i in 1..v_meta_col_cnt loop
     dbms_sql.define_column(v_cur, i, '', 4000);
 end loop;

    v_temp := dbms_sql.execute_and_fetch(v_cur);
    dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

    row := t_row();

 for i in 1..v_meta_col_cnt loop
  dbms_sql.column_value(v_cur, i, v_col_val);
  ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
 end loop;

 dbms_sql.close_cursor(v_cur);

    ihook.setColumnValue(row, 'VER_NR',v_to_form_ver);
    ihook.setColumnValue(row, 'ITEM_ID',v_to_module_id);
    ihook.setColumnValue(row, 'ITEM_LONG_NM',v_to_module_id);
    action_rows := t_rows();

    action_rows.extend; action_rows(action_rows.last) := row;
    action := t_actionRowset(action_rows, 'Administered Item (No Sequence)',2, 10, 'insert');
    actions.extend; actions(actions.last) := action;


    row := t_row();

    ihook.setColumnValue(row, 'P_item_VER_NR',v_to_form_ver);
    ihook.setColumnValue(row, 'p_ITEM_ID',v_to_form_id);
    ihook.setColumnValue(row, 'c_ITEM_ID',v_to_module_id);
    ihook.setColumnValue(row, 'c_ITEM_ver_nr',v_to_form_ver);
    ihook.setColumnValue(row, 'rel_typ_id',61);
    -- need to change this to max display order?
    ihook.setColumnValue(row, 'disp_ord',0);

     action_rows := t_rows();

    action_rows.extend; action_rows(action_rows.last) := row;
    action := t_actionRowset(action_rows, 'Form-Module Relationship', 2, 12, 'insert');
    actions.extend; actions(actions.last) := action;


-- Questions
  spCopyQuestion(actions, v_from_module_id, v_from_module_ver, v_to_module_id, v_to_form_ver);

--raise_application_error(-20000,'Here'|| v_from_module_id || '   ' || v_to_module_id || '  ' || actions.count);



end;



/*  Common children copy when creating a version */
procedure spCreateCommonChildrenNCI (actions in out t_actions, v_admin_item admin_item%rowtype, v_version number) as
    action           t_actionRowset;
    action_rows              t_rows := t_rows();
    action_rows_csi              t_rows := t_rows();
    row          t_row;
    v_table_name varchar2(30);
    v_sql        varchar2(4000);

    v_cur        number;
    v_temp        number;
    v_col_val       varchar2(4000);

    v_meta_col_cnt      integer;
    v_meta_desc_tab      dbms_sql.desc_tab;

begin

/*  Copy Alternate Names */
    action_rows := t_rows();
    action_rows_csi := t_rows();
    v_table_name := 'ALT_NMS';
    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    for an_cur in (select nm_id from alt_nms where 
    item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop
        v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where nm_id = :nm_id';
        v_cur := dbms_sql.open_cursor;
        dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
        dbms_sql.bind_variable(v_cur, ':nm_id', an_cur.nm_id);

        for i in 1..v_meta_col_cnt loop
            dbms_sql.define_column(v_cur, i, '', 4000);
        end loop;

        v_temp := dbms_sql.execute_and_fetch(v_cur);
        dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

        row := t_row();
        for i in 1..v_meta_col_cnt loop
            dbms_sql.column_value(v_cur, i, v_col_val);
            ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
        end loop;
        dbms_sql.close_cursor(v_cur);

        select od_seq_ALT_NMS.nextval into v_temp from dual;
        ihook.setColumnValue(row, 'nm_ID',v_temp);
        ihook.setColumnValue(row, 'VER_NR', v_version);
        ihook.setColumnValue(row, 'NCI_IDSEQ', '');

        action_rows.extend; action_rows(action_rows.last) := row;
        /*  Alternate Name - Classification */
        for csi_cur in (select nci_pub_id, nci_ver_nr, typ_nm from NCI_CSI_ALT_DEFNMS where nmdef_id = an_cur.nm_id) loop
            row:= t_row();
            ihook.setColumnValue(row, 'nmdef_ID',v_temp);
            ihook.setColumnValue(row, 'NCI_PUB_ID', csi_cur.NCI_PUB_ID);
            ihook.setColumnValue(row, 'NCI_VER_NR', csi_cur.NCI_VER_NR);
            ihook.setColumnValue(row, 'TYP_NM', csi_cur.TYP_NM);
            action_rows_csi.extend; action_rows_csi(action_rows_Csi.last) := row;
         end loop;
    end loop;

    action := t_actionRowset(action_rows, v_table_name, 12, 'insert');
    actions.extend; actions(actions.last) := action;
---  End of Alternate Names

-- Alternate Definitions

    action_rows := t_rows();

    v_table_name := 'ALT_DEF';
    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    for ad_cur in  (select def_id from alt_def where 
    item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop
        v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where def_id = :def_id';
        v_cur := dbms_sql.open_cursor;
        dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
        dbms_sql.bind_variable(v_cur, ':def_id', ad_cur.def_id);

        for i in 1..v_meta_col_cnt loop
            dbms_sql.define_column(v_cur, i, '', 4000);
        end loop;

        v_temp := dbms_sql.execute_and_fetch(v_cur);
        dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

        row := t_row();
        for i in 1..v_meta_col_cnt loop
            dbms_sql.column_value(v_cur, i, v_col_val);
            ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
        end loop;

        dbms_sql.close_cursor(v_cur);
        select od_seq_ALT_DEF.nextval into v_temp from dual;
        ihook.setColumnValue(row, 'def_ID', v_temp);
        ihook.setColumnValue(row, 'VER_NR', v_version);
        ihook.setColumnValue(row, 'NCI_IDSEQ', '');
        action_rows.extend; action_rows(action_rows.last) := row;

        for csi_cur in (select nci_pub_id, nci_ver_nr, typ_nm from NCI_CSI_ALT_DEFNMS where nmdef_id = ad_cur.def_id) loop
            row:= t_row();
            ihook.setColumnValue(row, 'nmdef_ID',v_temp);
            ihook.setColumnValue(row, 'NCI_PUB_ID', csi_cur.NCI_PUB_ID);
            ihook.setColumnValue(row, 'NCI_VER_NR', csi_cur.NCI_VER_NR);
            ihook.setColumnValue(row, 'TYP_NM', csi_cur.TYP_NM);
            action_rows_csi.extend; action_rows_csi(action_rows_Csi.last) := row;
         end loop;
    end loop;

    action := t_actionRowset(action_rows, v_table_name, 13, 'insert');
    actions.extend; actions(actions.last) := action;

    action := t_actionRowset(action_rows_csi, 'Classification level Name/Definition 2',2, 25, 'insert');
    actions.extend; actions(actions.last) := action;

-- End of Alternate Definition

--- Reference Documents

    action_rows := t_rows();

    v_table_name := 'REF';
    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    for ref_cur in  (select ref_id from ref where 
    item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop

        v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where ref_id = :ref_id';
        v_cur := dbms_sql.open_cursor;
        dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
        dbms_sql.bind_variable(v_cur, ':ref_id', ref_cur.ref_id);

        for i in 1..v_meta_col_cnt loop
            dbms_sql.define_column(v_cur, i, '', 4000);
        end loop;

        v_temp := dbms_sql.execute_and_fetch(v_cur);
        dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

        row := t_row();

        for i in 1..v_meta_col_cnt loop
            dbms_sql.column_value(v_cur, i, v_col_val);
            ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
        end loop;

        dbms_sql.close_cursor(v_cur);

        ihook.setColumnValue(row, 'ref_ID', -1);
        ihook.setColumnValue(row, 'NCI_IDSEQ', '');
        ihook.setColumnValue(row, 'VER_NR', v_version);
        action_rows.extend; action_rows(action_rows.last) := row;
    end loop;

    action := t_actionRowset(action_rows, v_table_name, 14, 'insert');
    actions.extend; actions(actions.last) := action;

-- End of Reference Documents
-- Concepts

    action_rows := t_rows();

    v_table_name := 'CNCPT_ADMIN_ITEM';
    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    for ref_cur in  (select CNCPT_AI_ID from CNCPT_ADMIN_ITEM where 
    item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop
        v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where CNCPT_AI_ID = :CNCPT_AI_ID';
        v_cur := dbms_sql.open_cursor;
        dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
        dbms_sql.bind_variable(v_cur, ':CNCPT_AI_ID', ref_cur.CNCPT_AI_ID);

        for i in 1..v_meta_col_cnt loop
            dbms_sql.define_column(v_cur, i, '', 4000);
        end loop;

        v_temp := dbms_sql.execute_and_fetch(v_cur);
        dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);
        row := t_row();

        for i in 1..v_meta_col_cnt loop
            dbms_sql.column_value(v_cur, i, v_col_val);
            ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
        end loop;

        dbms_sql.close_cursor(v_cur);

        ihook.setColumnValue(row, 'CNCPT_AI_ID', -1);
        ihook.setColumnValue(row, 'VER_NR', v_version);
        action_rows.extend; action_rows(action_rows.last) := row;
    end loop;

    action := t_actionRowset(action_rows, v_table_name, 14, 'insert');
    actions.extend; actions(actions.last) := action;

-- End of concepts

--- Begin of Classifications

    action_rows := t_rows();

    v_table_name := 'NCI_ALT_KEY_ADMIN_ITEM_REL';
    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    for ref_cur in  (select NCI_PUB_ID,NCI_VER_NR, REL_TYP_ID from NCI_ALT_KEY_ADMIN_ITEM_REL where 
    c_item_id = v_admin_item.item_id and c_item_ver_nr = v_admin_item.ver_nr) loop

        v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where NCI_PUB_ID = :NCI_PUB_ID and NCI_VER_NR = :NCI_VER_NR and c_item_id = :c_item_id and c_item_ver_nr = :c_item_ver_nr and rel_typ_id = :rel_typ_id';
        v_cur := dbms_sql.open_cursor;
        dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
        dbms_sql.bind_variable(v_cur, ':nci_pub_id', ref_cur.nci_pub_id);
        dbms_sql.bind_variable(v_cur, ':nci_ver_nr', ref_cur.nci_ver_nr);
        dbms_sql.bind_variable(v_cur, ':c_item_id', v_admin_item.item_id);
        dbms_sql.bind_variable(v_cur, ':c_item_ver_nr', v_admin_item.ver_nr);
        dbms_sql.bind_variable(v_cur, ':rel_typ_id', ref_cur.rel_typ_id);

        for i in 1..v_meta_col_cnt loop
            dbms_sql.define_column(v_cur, i, '', 4000);
        end loop;

        v_temp := dbms_sql.execute_and_fetch(v_cur);
        dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

        row := t_row();

        for i in 1..v_meta_col_cnt loop
            dbms_sql.column_value(v_cur, i, v_col_val);
            ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
        end loop;

        dbms_sql.close_cursor(v_cur);

       ihook.setColumnValue(row, 'c_item_VER_NR', v_version);
        ihook.setColumnValue(row, 'NCI_IDSEQ', '');
        action_rows.extend; action_rows(action_rows.last) := row;
    end loop;

    action := t_actionRowset(action_rows, 'NCI CSI - DE Relationship',2, 15, 'insert');
    actions.extend; actions(actions.last) := action;

end;



/*  Create sub-type row for version. Called from spCreateVer */

procedure spCreateSubtypeVerNCI (actions in out t_actions, v_admin_item admin_item%rowtype, v_version number) as
    action           t_actionRowset;
    action_rows              t_rows := t_rows();
    row          t_row;

    v_table_name      varchar2(30);
    v_sql        varchar2(4000);
    v_cur        number;
    v_temp        number;
    v_col_val       varchar2(4000);

    v_meta_col_cnt      integer;
    v_meta_desc_tab      dbms_sql.desc_tab;
begin
    if v_admin_item.admin_item_typ_id = 1 then
        v_table_name := 'CONC_DOM';
    elsif v_admin_item.admin_item_typ_id = 2 then
        v_table_name := 'DE_CONC';
    elsif v_admin_item.admin_item_typ_id = 3 then
        v_table_name := 'VALUE_DOM';
    elsif v_admin_item.admin_item_typ_id = 4 then
        v_table_name := 'DE';
    elsif v_admin_item.admin_item_typ_id = 5 then
        v_table_name := 'OBJ_CLS';
    elsif v_admin_item.admin_item_typ_id = 6 then
        v_table_name := 'PROP';
    elsif v_admin_item.admin_item_typ_id = 7 then
        v_table_name := 'REP_CLS';
    elsif v_admin_item.admin_item_typ_id = 8 then
        v_table_name := 'CNTXT';
    elsif v_admin_item.admin_item_typ_id = 9 then
        v_table_name := 'CLSFCTN_SCHM';
    elsif v_admin_item.admin_item_typ_id = 10 then
        v_table_name := 'DERV_RUL';
    elsif v_admin_item.admin_item_typ_id = 49 then
        v_table_name := 'CNCPT';
    elsif v_admin_item.admin_item_typ_id = 54 then
        v_table_name := 'NCI_FORM';
    end if;

    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where item_id=:item_id and ver_nr=:ver_nr';

    v_cur := dbms_sql.open_cursor;
    dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
    dbms_sql.bind_variable(v_cur, ':item_id', v_admin_item.item_id);
    dbms_sql.bind_variable(v_cur, ':ver_nr', v_admin_item.ver_nr);

    for i in 1..v_meta_col_cnt loop
        dbms_sql.define_column(v_cur, i, '', 4000);
    end loop;

    v_temp := dbms_sql.execute_and_fetch(v_cur);
    dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

    row := t_row();

    for i in 1..v_meta_col_cnt loop
        dbms_sql.column_value(v_cur, i, v_col_val);
        ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
    end loop;

    dbms_sql.close_cursor(v_cur);

    ihook.setColumnValue(row, 'VER_NR',v_version);
    ihook.setColumnValue(row, 'LST_UPD_DT',sysdate);

    action_rows.extend; action_rows(action_rows.last) := row;
    action := t_actionRowset(action_rows, v_table_name, 10, 'insert');
    actions.extend; actions(actions.last) := action;

/* Value Domains - then add Permissible Values */
    if v_admin_item.admin_item_typ_id = 3 then -- Add Perm Val
        action_rows := t_rows();
        v_table_name := 'PERM_VAL';
        v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);
        for pv_cur in  (select val_id from perm_val where 
        val_dom_item_id = v_admin_item.item_id and val_dom_ver_nr = v_admin_item.ver_nr) loop

            v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where val_id = :val_id';
            v_cur := dbms_sql.open_cursor;
            dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
            dbms_sql.bind_variable(v_cur, ':val_id', pv_cur.val_id);

            for i in 1..v_meta_col_cnt loop
                dbms_sql.define_column(v_cur, i, '', 4000);
            end loop;

            v_temp := dbms_sql.execute_and_fetch(v_cur);
            dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

            row := t_row();

            for i in 1..v_meta_col_cnt loop
                dbms_sql.column_value(v_cur, i, v_col_val);
                ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
            end loop;

            dbms_sql.close_cursor(v_cur);

            ihook.setColumnValue(row, 'VAL_ID', -1);
            ihook.setColumnValue(row, 'VAL_DOM_VER_NR', v_version);
            ihook.setColumnValue(row, 'NCI_IDSEQ', '');
            action_rows.extend; action_rows(action_rows.last) := row;

        end loop;

        action := t_actionRowset(action_rows, v_table_name, 11, 'insert');
        actions.extend; actions(actions.last) := action;
 end if;

/*   Conceptual Domain  */ 
 if v_admin_item.admin_item_typ_id = 1 then -- Conceptual Domain then add CD-VM relationship
        action_rows := t_rows();

        v_table_name := 'CONC_DOM_VAL_MEAN';
        v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

        for cdvm_cur in  (select CONC_DOM_VER_NR, CONC_DOM_ITEM_ID, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR from conc_dom_val_mean where 
        conc_dom_item_id = v_admin_item.item_id and conc_dom_ver_nr = v_admin_item.ver_nr) loop

            v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where CONC_DOM_VER_NR = :conc_dom_ver_nr and CONC_DOM_ITEM_ID = :conc_dom_item_id and NCI_VAL_MEAN_ITEM_ID = :nci_val_mean_item_id and NCI_VAL_MEAN_VER_NR = :nci_val_mean_ver_nr';
            v_cur := dbms_sql.open_cursor;
            dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
            dbms_sql.bind_variable(v_cur, ':conc_dom_ver_nr', cdvm_cur.conc_dom_ver_nr);
            dbms_sql.bind_variable(v_cur, ':conc_dom_item_id', cdvm_cur.conc_dom_item_id);
            dbms_sql.bind_variable(v_cur, ':nci_val_mean_ver_nr', cdvm_cur.nci_val_mean_ver_nr);
            dbms_sql.bind_variable(v_cur, ':nci_val_mean_item_id', cdvm_cur.nci_val_mean_item_id);

            for i in 1..v_meta_col_cnt loop
                dbms_sql.define_column(v_cur, i, '', 4000);
            end loop;

            v_temp := dbms_sql.execute_and_fetch(v_cur);
            dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

            row := t_row();

            for i in 1..v_meta_col_cnt loop
                dbms_sql.column_value(v_cur, i, v_col_val);
                ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
            end loop;

            dbms_sql.close_cursor(v_cur);

            ihook.setColumnValue(row, 'CONC_DOM_VER_NR', v_version);
            action_rows.extend; action_rows(action_rows.last) := row;

        end loop;

        action := t_actionRowset(action_rows, v_table_name, 12, 'insert');
        actions.extend; actions(actions.last) := action;
    end if;


    /*  DE then copy Derived Components */
    if v_admin_item.admin_item_typ_id = 4 then 

        action_rows := t_rows();
        v_table_name := 'NCI_ADMIN_ITEM_REL';
        v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

        for de_cur in (select P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID from NCI_ADMIN_ITEM_REL where 
        P_item_id = v_admin_item.item_id and p_ITEM_ver_nr = v_admin_item.ver_nr and rel_typ_id = 65) loop

            v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where P_ITEM_ID = :P_ITEM_ID and P_ITEM_VER_NR = :P_ITEM_VER_NR and C_ITEM_ID = :C_ITEM_ID and C_ITEM_VER_NR = :C_ITEM_VER_NR and REL_TYP_ID=65';

            v_cur := dbms_sql.open_cursor;
            dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
            dbms_sql.bind_variable(v_cur, ':P_ITEM_ID', de_cur.P_ITEM_ID);
            dbms_sql.bind_variable(v_cur, ':P_ITEM_VER_NR', de_cur.P_ITEM_VER_NR);
            dbms_sql.bind_variable(v_cur, ':C_ITEM_ID', de_cur.C_ITEM_ID);
            dbms_sql.bind_variable(v_cur, ':C_ITEM_VER_NR', de_cur.C_ITEM_VER_NR);

            for i in 1..v_meta_col_cnt loop
                dbms_sql.define_column(v_cur, i, '', 4000);
            end loop;

            v_temp := dbms_sql.execute_and_fetch(v_cur);
            dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

            row := t_row();

            for i in 1..v_meta_col_cnt loop
                dbms_sql.column_value(v_cur, i, v_col_val);
                ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
            end loop;

            dbms_sql.close_cursor(v_cur);

            ihook.setColumnValue(row, 'P_ITEM_VER_NR', v_version);
            action_rows.extend; action_rows(action_rows.last) := row;
        end loop;

        action := t_actionRowset(action_rows, v_table_name, 12, 'insert');
        actions.extend; actions(actions.last) := action;
    end if;

/*  If Form  */
    if v_admin_item.admin_item_typ_id = 54 then -- Add Modules
     for cur2 in (select c_item_id, c_item_ver_nr from nci_admin_item_rel where p_item_id = v_admin_item.item_id and p_item_ver_nr = v_admin_item.item_id) loop
        nci_11179.spCopyModuleNCI(actions, cur2.c_item_id, cur2.c_item_ver_nr, v_admin_item.item_id, v_admin_item.item_id, v_admin_item.item_id, v_version);   
     end loop; 
    end if;
end;

/*  Command Hook - Create Version */
procedure spCreateVerNCI (v_data_in in clob, v_data_out out clob, v_user_id varchar2) as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    actions           t_actions := t_actions();
    action           t_actionRowset;
    ai_insert_action_rows  t_rows := t_rows();
    ai_update_action_rows  t_rows := t_rows();
    ai_audit_action_rows     t_rows := t_rows();
    row          t_row;

    v_admin_item     admin_item%rowtype;
    v_tab_admin_item   tab_admin_item_pk;

    v_creat_ver     number;
    v_stus_nm     varchar2(100);

    v_table_name      varchar2(30);
    v_sql        varchar2(4000);

    v_cur        number;
    v_temp        number;

    v_version  number(4,2);

    v_col_val       varchar2(4000);
    question    t_question;
    answer     t_answer;
    answers     t_answers;
    showrowset	t_showablerowset;
    forms t_forms;
    form1 t_form;
    rowform t_row;

    row_ori t_row;

    v_meta_col_cnt      integer;
    v_meta_desc_tab      dbms_sql.desc_tab;

begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori :=  hookInput.originalRowset.rowset(1);

    /* Check with user has privilege to create version for the context */
    select count(*) into v_temp from  onedata_md.vw_usr_row_filter  v 
        where ( ( v.CNTXT_ITEM_ID = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') and v.cntxt_VER_NR  = ihook.getColumnValue(row_ori,'CNTXT_VER_NR')) or v.CNTXT_ITEM_ID = 100) and upper(v.USR_ID) = upper(v_user_id) and v.ACTION_TYP = 'I';

    if v_temp = 0 then
                   hookOutput.message := 'Not authorized to create version in the current context.';
                   v_data_out := ihook.getHookOutput(hookOutput);
                   return;
    end if; 

    v_tab_admin_item := template_11179.getParsedAdminItemsData(hookInput.originalRowset);

    select * into v_admin_item from admin_item
    where item_id=v_tab_admin_item(1).item_id and ver_nr=v_tab_admin_item(1).ver_nr
    for update nowait;

     if v_admin_item.currnt_ver_ind = 0 then
        hookOutput.message := 'Cannot create version if the Administered Item is not the latest version.';
        v_data_out := ihook.getHookOutput(hookOutput);
        return;
     end if;

     if (v_admin_item.admin_item_typ_id in (50,51,52,53,56)) then
        hookOutput.message := 'Administered Item of this type cannot be versioned.';
        v_data_out := ihook.getHookOutput(hookOutput);
        return;
    end if;

      /*  if (v_admin_item.regstr_stus_id is null) then
      hookOutput.message := 'Cannot create version for Administered Items with no Registration Status assigned.';
            v_data_out := ihook.getHookOutput(hookOutput);
            return;
        end if;  */

    if hookInput.invocationNumber = 0 then  -- If first invocation, prompt for version number

        ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(1, 1, 'Create Version.' );
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION('Specify Version. Current version is:' || ihook.getColumnValue(row_ori,'VER_NR' ) , ANSWERS);
        HOOKOUTPUT.QUESTION    := QUESTION;
        forms                  := t_forms();
        form1                  := t_form('Version Creation', 2,1);
        forms.extend;
        forms(forms.last) := form1;
        hookOutput.forms := forms;	   
	elsif hookInput.invocationNumber = 1 then  -- Version number specified...
		  if hookInput.answerId = 1 then 
            forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);
            v_version := ihook.getColumnValue(rowform,'VER_NR');

            v_table_name := 'ADMIN_ITEM';

            v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

            v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where item_id=:item_id and ver_nr=:ver_nr';
            v_cur := dbms_sql.open_cursor;
            dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
            dbms_sql.bind_variable(v_cur, ':item_id', v_admin_item.item_id);
            dbms_sql.bind_variable(v_cur, ':ver_nr', v_admin_item.ver_nr);

            for i in 1..v_meta_col_cnt loop
                dbms_sql.define_column(v_cur, i, '', 4000);
            end loop;

            v_temp := dbms_sql.execute_and_fetch(v_cur);
            dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

            row := t_row();

            for i in 1..v_meta_col_cnt loop
                dbms_sql.column_value(v_cur, i, v_col_val);
                ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
            end loop;

            dbms_sql.close_cursor(v_cur);
            /*  Change values of the new version row */
            ihook.setColumnValue(row, 'VER_NR', v_version);
            ihook.setColumnValue(row, 'CREAT_USR_ID', hookInput.userId);
            ihook.setColumnValue(row, 'LST_UPD_USR_ID', hookInput.userId);
            ihook.setColumnValue(row, 'ADMIN_STUS_ID', 65 );
            ihook.setColumnValue(row, 'REGSTR_STUS_ID','' );
            ihook.setColumnValue(row, 'NCI_IDSEQ', '');

            ai_insert_action_rows.extend; ai_insert_action_rows(ai_insert_action_rows.last) := row;

            /* set latest version to 0 for current row */
            row := t_row();
            ihook.setColumnValue(row, 'ITEM_ID', v_admin_item.item_id);
            ihook.setColumnValue(row, 'VER_NR', v_admin_item.ver_nr);
            ihook.setColumnValue(row, 'CURRNT_VER_IND', 0);
            ai_update_action_rows.extend; ai_update_action_rows(ai_update_action_rows.last) := row;

            /* Call sub-type creation function */
            spCreateSubtypeVerNCI(actions, v_admin_item, v_version);

            /* Copy all common children */
            spCreateCommonChildrenNCI(actions, v_admin_item, v_version);

            action := t_actionRowset(ai_insert_action_rows, 'Administered Item (No Sequence)',2, 0, 'insert');
            actions.extend; actions(actions.last) := action;

            action := t_actionRowset(ai_update_action_rows, 'ADMIN_ITEM', 0, 'update');
            actions.extend; actions(actions.last) := action;

            hookOutput.actions := actions;

            hookOutput.message := 'Version created successfully.';
        end if;
    end if;

    v_data_out := ihook.getHookOutput(hookOutput);
end;

END;
/


create or replace PACKAGE nci_form_mgmt AS
procedure spAddForm (v_data_in in clob, v_data_out out clob);
procedure spAddModule (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spEditModule (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spAddQuestion (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spCopyModule (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spModUpdPost (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
function isUserAuth(v_frm_item_id in number, v_frm_ver_nr in number,v_user_id in varchar2) return boolean  ;
procedure spSetModRep (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2); 
procedure spChngQuestText (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2); 
procedure spSetDefltVal (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2); 
procedure spAddQuestionNoDE (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spChngQuestTextVV (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2); 
procedure spChngQuestDefVV (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2); 
procedure spAddQuestionRep (rep in integer, row_ori in t_row, rows in out t_rows);
procedure spAddQuestionRepNew (rep in integer, v_quest_id in integer, rows in out t_rows);
END;
/

create or replace PACKAGE BODY nci_form_mgmt AS

function isUserAuth(v_frm_item_id in number, v_frm_ver_nr in number,v_user_id in varchar2) return boolean  iS
v_auth boolean := false;
v_temp integer;
begin
select count(*) into v_temp from  onedata_md.vw_usr_row_filter  v, admin_item ai 
        where ( ( v.CNTXT_ITEM_ID = ai.CNTXT_ITEM_ID and v.cntxt_VER_NR  = ai.CNTXT_VER_NR) or v.CNTXT_ITEM_ID = 100) and upper(v.USR_ID) = upper(v_user_id) and v.ACTION_TYP = 'I'
        and ai.item_id =v_frm_item_id and ai.ver_nr = v_frm_ver_nr;
if (v_temp = 0) then return false; else return true; end if;
end;


PROCEDURE spAddForm  ( v_data_in IN CLOB,    v_data_out OUT CLOB)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    rows  t_rows;
    row_ori t_row;
    action_rows       t_rows := t_rows();
    action_row		    t_row;
    rowset            t_rowset;
    question    t_question;
    answer     t_answer;
    answers     t_answers;
    showrowset	t_showablerowset;
    forms t_forms;
    form1 t_form;
    rowform t_row;
    v_found boolean;
    v_form_id integer;
    i integer := 0;
BEGIN
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    -- First invocation - show the Add Form  
    if hookInput.invocationNumber = 0 then
        ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(1, 1, 'Create Form.');
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION('Add new form/template.', ANSWERS);
        HOOKOUTPUT.QUESTION    := QUESTION;
        
        forms                  := t_forms();
        form1                  := t_form('Forms (Hook)', 2,1);  -- Forms (Hook) is a custom object for this purpose.
        action_row := t_row();
        
        -- Set the default workflow status and Form Type; attach to Add Form.
        
        ihook.setColumnValue(action_row, 'ADMIN_STUS_ID', 66);
        ihook.setColumnValue(action_row, 'FORM_TYP_ID', 70);
        action_rows.extend; action_rows(action_rows.last) := action_row;  
        rowset := t_rowset(action_rows, 'Form (Hook)', 1,'NCI_FORM');
        
        form1.rowset :=rowset;
        forms.extend;
        forms(forms.last) := form1;
        hookOutput.forms := forms;
  ELSE -- Second invocation
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);
        
        v_form_id :=  nci_11179.getItemId;
        row := t_row();
        row := rowform;
        
        ihook.setColumnValue(row, 'ITEM_ID', v_form_id);
        ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row, 'VER_NR', 1);
        ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 54);
        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_form_id || 'v1.0');
        
        rows:= t_rows();
        rows.extend;
        rows(rows.last) := row;
    
        -- Insert super-type
        action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'insert');
        actions.extend;
        actions(actions.last) := action;
        -- Insert sub-type        
        action             := t_actionrowset(rows, 'Form AI', 2, 1,'insert');
        actions.extend;
        actions(actions.last) := action;
     
        -- Insert form-protocol relationship if protocol specified
        if (ihook.getColumnValue(rowform,'P_ITEM_ID') > 0) then
            rows:= t_rows();
            rowrel := t_row();
            ihook.setColumnValue(rowrel, 'P_ITEM_ID', ihook.getColumnValue(rowform,'P_ITEM_ID'));
            ihook.setColumnValue(rowrel, 'P_ITEM_VER_NR', ihook.getColumnValue(rowform,'P_ITEM_VER_NR'));
            ihook.setColumnValue(rowrel, 'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
            ihook.setColumnValue(rowrel, 'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
            ihook.setColumnValue(rowrel, 'C_ITEM_ID', v_form_id);
            ihook.setColumnValue(rowrel, 'C_ITEM_VER_NR', 1);
            ihook.setColumnValue(rowrel, 'REL_TYP_ID', 60);
        
            rows.extend;
            rows(rows.last) := rowrel;
            action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 2,'insert');
            actions.extend;
            actions(actions.last) := action;
        end if;
        hookoutput.actions    := actions;
    END IF;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spAddModule  (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowrel t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();  
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a module to this form.');
 end if;
 
 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Create Module.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add new module.', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
 
    forms                  := t_forms();
    form1                  := t_form('Modules (Hook)', 2,1);
    --form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
 ELSE
    IF HOOKINPUT.ANSWERID = 1 THEN
        forms              := hookInput.forms;
        form1              := forms(1);
   
        rowform := form1.rowset.rowset(1);
    
        v_module_id :=  nci_11179.getItemId;
        row := t_row();
    
    
   -- raise_application_error(-20000, ihook.getColumnValue(rowform,'INSTR'));
    
        for cur in (select cntxt_item_id, cntxt_ver_nr, admin_stus_id from admin_item where item_id =ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr =  ihook.getColumnValue(row_ori,'VER_NR')) loop
            ihook.setColumnValue(row, 'ITEM_ID', v_module_id);
            ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
            ihook.setColumnValue(row, 'VER_NR', 1);
            ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 52);
            ihook.setColumnValue(row, 'CNTXT_ITEM_ID', cur.CNTXT_ITEM_ID);
            ihook.setColumnValue(row, 'CNTXT_VER_NR', cur.CNTXT_VER_NR);
            ihook.setColumnValue(row, 'ITEM_LONG_NM', ihook.getColumnValue(rowform,'ITEM_NM'));
            ihook.setColumnValue(row, 'ITEM_NM', ihook.getColumnValue(rowform,'ITEM_NM'));
            ihook.setColumnValue(row, 'ITEM_DESC', ihook.getColumnValue(rowform,'ITEM_DESC'));
            ihook.setColumnValue(row, 'ADMIN_STUS_ID', cur.ADMIN_STUS_ID);
            
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;
    
            action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;
     
            rows:= t_rows();
          select nvl(max(disp_ord)+ 1,0) into v_disp_ord from nci_admin_item_rel where p_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and p_item_ver_nr = ihook.getColumnValue(row_ori,'VER_NR');
      --   raise_application_error(-20000, v_disp_ord);
            
            rowrel := t_row();
            ihook.setColumnValue(rowrel, 'P_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
            ihook.setColumnValue(rowrel, 'P_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
            ihook.setColumnValue(rowrel, 'C_ITEM_ID', v_module_id);
            ihook.setColumnValue(rowrel, 'C_ITEM_VER_NR', 1);
            ihook.setColumnValue(rowrel, 'CNTXT_ITEM_ID', cur.CNTXT_ITEM_ID);
            ihook.setColumnValue(rowrel, 'CNTXT_VER_NR', cur.CNTXT_VER_NR);
            ihook.setColumnValue(rowrel, 'DISP_ORD', v_disp_ord);
            ihook.setColumnValue(rowrel, 'REL_TYP_ID', 61);
            ihook.setColumnValue(rowrel, 'REP_NO', ihook.getColumnValue(rowform,'REP_NO'));
            ihook.setColumnValue(rowrel, 'INSTR', ihook.getColumnValue(rowform,'INSTR'));
            
            rows.extend;
            rows(rows.last) := rowrel;
     -- raise_application_error(-20000,  ihook.getColumnValue(row_ori,'ITEM_ID'));
            action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 2,'insert');
            actions.extend;
            actions(actions.last) := action;
    end loop;
    hookoutput.actions    := actions;
    END IF;
  END IF;
     
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;



PROCEDURE spEditModule  (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowrel t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();  
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit module to this form.');
 end if;
 
 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Edit Name.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Save.', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
    rows := t_rows();
    row := t_row();
    for cur in (select item_nm, item_desc from admin_item where item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR')) loop
        ihook.setColumnValue(row, 'ITEM_NM', cur.item_nm);
        ihook.setColumnValue(row, 'ITEM_DESC', cur.item_desc);
    end loop;
       rows.extend; rows(rows.last) := row;  
        rowset := t_rowset(rows, 'Edit Module (Hook)', 1,'ADMIN_ITEM');
        
    forms                  := t_forms();
    form1                  := t_form('Edit Module (Hook)', 2,1);
    form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
 ELSE
    IF HOOKINPUT.ANSWERID = 1 THEN
        forms              := hookInput.forms;
        form1              := forms(1);
   
        rowform := form1.rowset.rowset(1);
    
       row := t_row();
    
    
            ihook.setColumnValue(row, 'ITEM_ID', ihook.getColumnValue(row_ori,'C_ITEM_ID'));
            ihook.setColumnValue(row, 'VER_NR', ihook.getColumnValue(row_ori,'C_ITEM_VER_NR'));
            ihook.setColumnValue(row, 'ITEM_NM', ihook.getColumnValue(rowform,'ITEM_NM'));
            ihook.setColumnValue(row, 'ITEM_DESC', ihook.getColumnValue(rowform,'ITEM_DESC'));
            
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;
    
            action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
      hookoutput.actions    := actions;
    END IF;
  END IF;
     
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spAddQuestionRep (rep in integer, row_ori in t_row, rows in out t_rows)
AS
  i integer;
  v_temp integer;
  row t_row;
  
begin
        for i in 1..rep loop
        for cur in (select nci_pub_id, nci_ver_nr, edit_ind, req_ind from nci_admin_item_rel_alt_key where p_item_id =ihook.getColumnValue(row_ori,'C_ITEM_ID') and 
        P_item_ver_nr =  ihook.getColumnValue(row_ori,'C_ITEM_VER_NR')) loop
        
        select count(*) into v_temp from nci_quest_vv_rep where quest_pub_id =cur.nci_pub_id and quest_ver_nr = cur.nci_ver_nr and rep_seq = i ;
        
            if v_temp = 0 then
            row := t_row();
            ihook.setColumnValue(row, 'QUEST_PUB_ID', cur.nci_pub_id);
            ihook.setColumnValue(row, 'QUEST_VER_NR', cur.nci_ver_nr);
            ihook.setColumnValue(row, 'REP_SEQ', i);
            ihook.setColumnValue(row, 'EDIT_IND', cur.edit_ind);
            ihook.setColumnValue(row, 'QUEST_VV_REP_ID',-1);
        --    raise_application_error(-20000,i);
            rows.extend;
            rows(rows.last) := row;
          end if;
       end loop;
       end loop;
end;


procedure spAddQuestionRepNew (rep in integer, v_quest_id in integer, rows in out t_rows)
AS
  i integer;
  v_temp integer;
  row t_row;
  
begin
        for i in 1..rep loop
            row := t_row();
            ihook.setColumnValue(row, 'QUEST_PUB_ID',v_quest_id );
            ihook.setColumnValue(row, 'QUEST_VER_NR', 1);
            ihook.setColumnValue(row, 'REP_SEQ', i);
         --   ihook.setColumnValue(row, 'EDIT_IND',1);
            ihook.setColumnValue(row, 'QUEST_VV_REP_ID',-1);
        --    raise_application_error(-20000,i);
            rows.extend;
            rows(rows.last) := row;
          
       end loop;
end;

PROCEDURE spSetModRep
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
    AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  v_temp integer;
  rep integer;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();  
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit module to this form.');
 end if;
 
 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Module Repetition.', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
	    for i in 1..20 loop
        
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'Repetition', i);
		   rows.extend;
		   rows (rows.last) := row;
		   
	    end loop;

	   	 showrowset := t_showablerowset (rows, 'Repetition', 4, 'single');
       	 hookoutput.showrowset := showrowset;
 
 
  ELSE -- hook invocation = 1
        row_sel := hookinput.selectedRowset.rowset(1);
        rows := t_rows();
        rep := ihook.getColumnValue(row_sel, 'Repetition');
    --    raise_application_error(-20000,rep);
        spAddQuestionRep (rep, row_ori, rows);
        if (rows.count > 0) then
        action             := t_actionrowset(rows, 'Question Repetition', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;
         end if;   
            rows := t_rows();
            row := t_row();
             ihook.setColumnValue(row_ori, 'REP_NO', rep);
             
     rows.extend;
            rows(rows.last) := row_ori;
            action             := t_actionrowset(rows, 'Form-Module Relationship', 2, 1,'update');
            actions.extend;
            actions(actions.last) := action;
            
    hookoutput.actions    := actions;
    END IF;

     
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--  insert into junk_debug values (sysdate, v_data_out);
 -- commit;
  
END;


PROCEDURE spSetDefltVal
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
    AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowrel t_row;
  rows  t_rows;
  rows0 t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
 row_sel t_row;
 rep integer;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_mod_id number;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_mod_ver_nr number(4,2);
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  v_temp number;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 -- Get form and module ID
 
 select r.P_ITEM_ID, r.P_ITEM_VER_NR into v_frm_id, v_frm_Ver_nr from NCI_ADMIN_ITEM_REL_ALT_KEY k, NCI_ADMIN_ITEM_REL r where k.nci_pub_id = ihook.getColumNValue(row_ori, 'Q_ITEM_ID') 
 and k.nci_ver_nr = ihook.getColumNValue(row_ori, 'Q_ITEM_VER_NR') and k.P_ITEM_ID = r.C_ITEM_ID and k.P_ITEM_VER_NR = r.C_ITEM_VER_NR and r.rel_typ_id = 61;
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
 
 if hookInput.invocationNumber = 0 then

   v_found := false;
   rows := t_rows();
   row := t_row();
   
   for cur in (Select rep_seq from nci_quest_vv_rep where QUEST_PUB_ID=ihook.getColumNValue(row_ori, 'Q_PUB_ID')  and quest_ver_nr = ihook.getColumNValue(row_ori, 'Q_VER_NR')) loop
   row := t_row();
   
   ihook.setColumnValue(row, 'REP_SEQ', cur.rep_seq);
            rows.extend;
            rows(rows.last) := row;
  -- raise_application_error (-20000, 'In here');
   
      v_found := true;
   end loop;
   
   if (v_found) then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Set default');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Set', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
          	 showrowset := t_showablerowset (rows, 'Repetition', 4, 'multi');
       	 hookoutput.showrowset := showrowset;

else

/*rows := t_rows();
row := t_row();
           ihook.setColumnValue(row, 'NCI_PUB_ID', ihook.getColumnValue(row_ori,'Q_PUB_ID'));
           ihook.setColumnValue(row, 'NCI_VER_NR', ihook.getColumnValue(row_ori,'Q_VER_NR'));
           ihook.setColumnValue(row, 'DEFLT_VAL_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
    rows.extend;
            rows(rows.last) := row;
            	
     -- raise_application_error(-20000,  ihook.getColumnValue(row_ori,'ITEM_ID'));
            action             := t_actionrowset(rows, 'Question (Edit)', 2, 2,'update');
            actions.extend;
            actions(actions.last) := action;
    hookoutput.actions    := actions;
  */
   hookoutput.message := 'No repetition for this module';
 end if;
 ELSE
    
    
        rows := t_rows();
   
      for i in 1..hookinput.selectedRowset.rowset.count loop
      
       row_sel := hookinput.selectedRowset.rowset(i);
   
        rep := ihook.getColumnValue(row_sel, 'REP_SEQ');
       
        /*if (rep = 0) then -- main question default
     
     
          row := t_row();
          rows0 := t_rows();
           ihook.setColumnValue(row, 'NCI_PUB_ID', ihook.getColumnValue(row_ori,'Q_PUB_ID'));
           ihook.setColumnValue(row, 'NCI_VER_NR', ihook.getColumnValue(row_ori,'Q_VER_NR'));
         --  ihook.setColumnValue(row, 'DEFLT_VAL_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
     ihook.setColumnValue(row, 'QUEST_REF_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
   
   
    rows0.extend;
            rows0(rows0.last) := row;
     -- raise_application_error(-20000,  ihook.getColumnValue(row_ori,'ITEM_ID'));
            action             := t_actionrowset(rows0, 'Question (Edit)', 2, 2,'update');
            actions.extend;
            actions(actions.last) := action; 
        end if;*/
        if (rep>0) then
        select 	QUEST_VV_REP_ID into v_temp from nci_quest_vv_rep where quest_pub_id = ihook.getColumnValue(row_ori,'Q_PUB_ID')
        and quest_ver_nr = ihook.getColumnValue(row_ori,'Q_VER_NR') and rep_seq = rep;
          row := t_row();
            ihook.setColumnValue(row, 'QUEST_VV_REP_ID', v_temp);
            ihook.setColumnValue(row, 'DEFLT_VAL_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
            rows.extend;
            rows(rows.last) := row;
    
            action             := t_actionrowset(rows, 'Question Repetition', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
     
          end if;
  end loop;
    hookoutput.actions    := actions;
    
  END IF;
     
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 -- insert into junk_debug values (sysdate, v_data_out);
 -- commit;
END;


PROCEDURE spChngQuestText
  (
  
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
    AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowrel t_row;
  row_sel t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(255);
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();  
 
 select frm_item_id, frm_ver_nr into v_frm_id, v_frm_Ver_nr from VW_NCI_MODULE_DE where nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
 
 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select alternate.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Alternate Question Text', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
 
	    for cur in (select ref_id from ref r, obj_key ok where r.fld_delete= 0 and item_id = ihook.getColumNValue(row_ori, 'C_ITEM_ID')  and 
        ver_nr = ihook.getColumNValue(row_ori, 'C_ITEM_VER_NR' ) and r.ref_typ_id = ok.obj_key_id and ok.obj_typ_id = 1 and upper(ok.obj_key_desc) like '%QUESTION TEXT%') loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'REF_ID', cur.ref_id);
		   rows.extend;
		   rows (rows.last) := row;
		
 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;

	  if (v_found) then 
       	 showrowset := t_showablerowset (rows, 'References (for hook insert)', 2, 'single');
       	 hookoutput.showrowset := showrowset;
     end if;
 ELSE
            row_sel := hookinput.selectedRowset.rowset(1);

            select ref_desc into v_ref from ref where ref_id = ihook.getColumnValue(row_sel, 'REF_ID');
            
            ihook.setColumnValue(row_ori, 'ITEM_LONG_NM', v_ref);
            
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row_ori;
    
            action             := t_actionrowset(rows, 'Questions (Edit)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
     
    
    hookoutput.actions    := actions;
    END IF;
     
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spAddQuestion
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
  rowsvv t_rows;
  rowsrep  t_rows;
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
v_itemid     integer;
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  v_add integer := 0;
  i integer := 0;
  v_disp_ord integer;
  column  t_column;
  msg varchar2(4000);
    type t_item_id is table of admin_item.item_id%type;
    type t_ver_nr is table of admin_item.ver_nr%type;

    v_tab_item_id  t_item_id := t_item_id();
    v_tab_ver_nr  t_ver_nr := t_ver_nr();
rep integer;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);
 
    rows := t_rows();  


 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a question to this module.');
 end if;

    if hookInput.invocationNumber = 0 then

	    rows :=         t_rows();
		v_found := false;

	    for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and 
        ai.admin_item_typ_id = 4 ) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   iHook.setcolumnvalue (ROW, 'CNTCT_SECU_ID', v_user_id);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;

	  if (v_found) then 
       	 showrowset := t_showablerowset (rows, 'User Cart', 2, 'multi');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select CDE to add..');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
      else
        hookoutput.message := 'Please add Data Elements to your cart.';
	   end if;
	   
	elsif hookInput.invocationNumber = 1 then
		  if hookInput.answerId = 1 then -- Add Question
          
          select nvl(max(disp_ord)+1,0) into v_disp_ord from NCI_ADMIN_ITEM_REL_ALT_KEY where P_ITEM_ID =ihook.getColumnValue(row_ori,'C_ITEM_ID')  and
          P_ITEM_VER_NR = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and rel_typ_id = 63;
                        rep := ihook.getColumnValue(row_ori, 'REP_NO');
          
            for i in 1..hookInput.selectedRowset.rowset.count loop
                    row_sel := hookInput.selectedRowset.rowset(i);
                v_tab_item_id.extend();
                v_tab_ver_nr.extend();
                v_tab_item_id(v_tab_item_id.count) := ihook.getColumnValue(row_sel,'ITEM_ID');
                v_tab_ver_nr(v_tab_ver_nr.count) := ihook.getColumnValue(row_sel,'VER_NR');
                -- Add component Item id
                    for cur in (select c_item_id, c_item_ver_nr from nci_admin_item_rel where rel_typ_id = 65 and p_item_id = ihook.getColumnValue(row_sel,'ITEM_ID')
                    and p_item_ver_nr = ihook.getColumnValue(row_sel,'VER_NR') order by disp_ord) loop
                        v_tab_item_id.extend();
                        v_tab_ver_nr.extend();
                        v_tab_item_id(v_tab_item_id.count) := cur.c_item_id;
                        v_tab_ver_nr(v_tab_ver_nr.count) := cur.c_item_ver_nr;
                    end loop;    
            end loop;
          rows := t_rows();
          rowsvv := t_rows();
                        rowsrep := t_rows();
        --      for i in 1..hookInput.selectedRowset.rowset.count loop
          --          row_sel := hookInput.selectedRowset.rowset(i);
              for i in 1..v_tab_item_id.count loop
                    
                    for cur in (select ai.item_id, ai.ver_nr, ai.cntxt_item_id, ai.cntxt_ver_nr, item_long_nm item_long_nm, nvl(r.ref_desc, item_long_nm) QUEST_TEXT from admin_item ai, ref r where 
                    ai.item_id = v_tab_item_id(i) and ai.ver_nr = v_tab_ver_nr(i) and ai.item_id = r.item_id (+) and ai.ver_nr = r.ver_nr (+)
                    and r.ref_typ_id (+) = 80
                    and (ai.item_id, ai.ver_nr) not in (select c_item_id, c_item_ver_nr from nci_admin_item_rel_alt_key where p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
                            p_item_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') and rel_typ_id = 63 )) loop
                        row := t_row();
                                               
                        v_id := nci_11179.getItemId;
                        ihook.setColumnValue (row, 'NCI_PUB_ID', v_id);
                        ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                        ihook.setColumnValue (row, 'P_ITEM_ID', ihook.getColumnValue(row_ori,'C_ITEM_ID'));
                        ihook.setColumnValue (row, 'P_ITEM_VER_NR', ihook.getColumnValue(row_ori,'C_ITEM_VER_NR'));
                        ihook.setColumnValue (row, 'C_ITEM_ID', cur.item_id);
                        ihook.setColumnValue (row, 'C_ITEM_VER_NR', cur.ver_nr);
                        ihook.setColumnValue (row, 'CNTXT_CS_ITEM_ID', cur.cntxt_item_id);
                        ihook.setColumnValue (row, 'CNTXT_CS_VER_NR', cur.cntxt_ver_nr);
                        ihook.setColumnValue (row, 'ITEM_LONG_NM', cur.QUEST_TEXT );
                        
                        ihook.setColumnValue (row, 'REL_TYP_ID', 63);
                        ihook.setColumnValue (row, 'DISP_ORD', v_disp_ord);
                        v_disp_ord := v_disp_ord + 1;
                        
                        v_add := v_add + 1;
                        rows.extend;
                        rows(rows.last) := row;
                            
    
                        if nvl(rep,0) > 0 then 
                            spAddQuestionRepNew (rep, v_id, rowsrep);
                        end if;
                        
                for cur1 in (select PERM_VAL_NM, PERM_VAL_DESC_TXT, item_nm, item_long_nm , item_desc from  VW_NCI_DE_PV where de_item_id = cur.item_id and de_ver_nr = cur.ver_nr) loop
                  row := t_row();
                ihook.setColumnValue (row, 'Q_PUB_ID', v_id);
                ihook.setColumnValue (row, 'Q_VER_NR', 1);
                ihook.setColumnValue (row, 'VM_NM', cur1.item_nm);
                ihook.setColumnValue (row, 'VM_LNM', cur1.item_long_nm);
                ihook.setColumnValue (row, 'VM_DEF', cur1.item_nm);
                ihook.setColumnValue (row, 'VALUE', cur1.perm_val_nm);
                ihook.setColumnValue (row, 'MEAN_TXT', cur1.item_nm);
                ihook.setColumnValue (row, 'DESC_TXT', cur1.item_desc);
                v_itemid := nci_11179.getItemId;
                ihook.setColumnValue (row, 'NCI_PUB_ID', v_itemid);
                ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                
                 rowsvv.extend;
                rowsvv(rowsvv.last) := row;
                end loop;   
                 end loop;
   end loop;
                
--DESC_TXT
   -- raise_application_error(-20000, v_add);
        if (rows.count > 0) then
                        action := t_actionrowset(rows, 'Question (Base Object)', 2,0,'insert');
                        actions.extend;
                        actions(actions.last) := action;
        end if;                    
                            
    if (rowsvv.count > 0) then 
    action := t_actionrowset(rowsvv, 'Question Valid Values (Hook)', 2,2,'insert');
    actions.extend;
    actions(actions.last) := action;
    end if;
    
       if (rowsrep.count > 0) then
        action             := t_actionrowset(rowsrep, 'Question Repetition', 2, 4,'insert');
            actions.extend;
            actions(actions.last) := action;
         end if;   
   
    hookoutput.actions := actions;
    hookoutput.message := v_add || ' questions added.';
    end if;
end if;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--  insert into junk_debug values (sysdate, v_data_out);
 -- commit;
END;

PROCEDURE spCopyModule
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
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
v_itemid     integer;
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
 
    rows := t_rows();  
if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a module to this form.');
 end if;
 
    if hookInput.invocationNumber = 0 then

	    rows :=         t_rows();
		v_found := false;

	    for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and 
        ai.admin_item_typ_id = 54 ) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;

	  if (v_found) then 
       	 showrowset := t_showablerowset (rows, 'User Cart', 2, 'single');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select Form..');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
     else
               hookoutput.message := 'Please add forms to your cart.';
	   
	   end if;
	   
	elsif hookInput.invocationNumber = 1 then
		  if hookInput.answerId = 1 then -- selected form
    row_sel := hookInput.selectedRowset.rowset(1);
      
            rows :=         t_rows();
		v_found := false;
	    for cur in (select c.item_id, c.ver_nr from VW_NCI_FORM_MODULE c where c.fld_delete= 0  and c.p_item_id = ihook.getColumnValue(row_sel,'ITEM_ID') and c.p_item_ver_nr =  ihook.getColumnValue(row_sel,'VER_NR') ) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
--raise_application_error(-20000, ihook.getColumnValue(row_sel,'ITEM_ID'));
	    end loop;
    
	  if (v_found) then 
       	 showrowset := t_showablerowset (rows, 'Modules', 2, 'single');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select Module..');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
	   end if;
       end if;
    elsif hookInput.invocationNumber = 2 then -- copy module
    
	row_sel := hookInput.selectedRowset.rowset(1);
    nci_11179.spCopyModuleNCI (actions, ihook.getColumnValue(row_sel,'ITEM_ID'),ihook.getColumnValue(row_sel,'VER_NR'), 
    ihook.getColumnValue(row_sel,'P_ITEM_ID'), ihook.getColumnValue(row_sel,'P_ITEM_VER_NR'), ihook.getColumnValue(row_ori,'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'));
    
    
    hookoutput.actions := actions;
    hookoutput.message := 'Module copied successfully.';
    --hookoutput.message := v_add || ' concepts added.';
    end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE            spModUpdPost (v_data_in    IN     CLOB,
                                                    v_data_out      OUT CLOB,
                                                    v_user_id in varchar2)
AS
    hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    actions          t_actions := t_actions ();
    action           t_actionRowset;
    row              t_row;
    rows             t_rows;
    row_ori          t_row;
    action_rows      t_rows := t_rows ();
    action_row       t_row;
    rowset           t_rowset;
    v_add            INTEGER := 0;
    v_action_typ     VARCHAR2 (30);
    v_temp           INT;
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_nm_id          NUMBER;
    v_cntxt_id       NUMBER;
    v_cntxt_ver_nr   NUMBER (4, 2);
    i                INTEGER := 0;
    column           t_column;
    v_item_nm        VARCHAR2 (255);
    v_item_def       VARCHAR2 (4000);
    msg              VARCHAR2 (4000);
BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;
    rows := t_rows ();

    row_ori := hookInput.originalRowset.rowset (1);
    v_item_id := ihook.getColumnValue (row_ori, 'C_ITEM_ID');
    v_ver_nr := ihook.getColumnValue (row_ori, 'C_ITEM_VER_NR');
if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to update this module.');
 end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spAddQuestionNoDE
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
  rowsvv t_rows;
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
v_itemid     integer;
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  v_add integer := 0;
  i integer := 0;
  v_disp_ord integer;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);
 
    rows := t_rows();  


 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a question to this module.');
 end if;

    if hookInput.invocationNumber = 0 then

	    rows :=         t_rows();
		v_found := false;

	    for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and 
        ai.admin_item_typ_id = 4 ) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;

	  if (v_found) then 
       	 showrowset := t_showablerowset (rows, 'User Cart', 2, 'multi');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select CDE to add..');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select option to proceed', answers);
       	 hookOutput.question := question;
	   end if;
	   
	elsif hookInput.invocationNumber = 1 then
		  if hookInput.answerId = 1 then -- Add Question
          
          select nvl(max(disp_ord)+1,0) into v_disp_ord from NCI_ADMIN_ITEM_REL_ALT_KEY where P_ITEM_ID =ihook.getColumnValue(row_ori,'C_ITEM_ID')  and
          P_ITEM_VER_NR = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and rel_typ_id = 63;
          
          rows := t_rows();
          rowsvv := t_rows();
              for i in 1..hookInput.selectedRowset.rowset.count loop
                    row_sel := hookInput.selectedRowset.rowset(i);
                    for cur in (select ai.item_id, ai.ver_nr, ai.cntxt_item_id, ai.cntxt_ver_nr, item_long_nm item_long_nm, nvl(r.ref_desc, item_long_nm) QUEST_TEXT from admin_item ai, ref r where 
                    ai.item_id = ihook.getColumnValue(row_sel,'ITEM_ID') and ai.ver_nr = ihook.getColumnValue(row_sel,'VER_NR') and ai.item_id = r.item_id (+) and ai.ver_nr = r.ver_nr (+)
                    and r.ref_typ_id (+) = 80
                    and (ai.item_id, ai.ver_nr) not in (select c_item_id, c_item_ver_nr from nci_admin_item_rel_alt_key where p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
                            p_item_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') and rel_typ_id = 63 )) loop
                        row := t_row();
                                               
                        v_id := nci_11179.getItemId;
                        ihook.setColumnValue (row, 'NCI_PUB_ID', v_id);
                        ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                        ihook.setColumnValue (row, 'P_ITEM_ID', ihook.getColumnValue(row_ori,'C_ITEM_ID'));
                        ihook.setColumnValue (row, 'P_ITEM_VER_NR', ihook.getColumnValue(row_ori,'C_ITEM_VER_NR'));
                        ihook.setColumnValue (row, 'C_ITEM_ID', cur.item_id);
                        ihook.setColumnValue (row, 'C_ITEM_VER_NR', cur.ver_nr);
                        ihook.setColumnValue (row, 'CNTXT_CS_ITEM_ID', cur.cntxt_item_id);
                        ihook.setColumnValue (row, 'CNTXT_CS_VER_NR', cur.cntxt_ver_nr);
                        ihook.setColumnValue (row, 'ITEM_LONG_NM', cur.QUEST_TEXT );
                        
                        ihook.setColumnValue (row, 'REL_TYP_ID', 63);
                        ihook.setColumnValue (row, 'DISP_ORD', v_disp_ord);
                        v_disp_ord := v_disp_ord + 1;
                        
                        v_add := v_add + 1;
                        rows.extend;
                        rows(rows.last) := row;
                            
                
                for cur1 in (select PERM_VAL_NM, PERM_VAL_DESC_TXT, item_nm, item_long_nm from  VW_NCI_DE_PV where de_item_id = cur.item_id and de_ver_nr = cur.ver_nr) loop
                  row := t_row();
                ihook.setColumnValue (row, 'Q_PUB_ID', v_id);
                ihook.setColumnValue (row, 'Q_VER_NR', 1);
                ihook.setColumnValue (row, 'VM_NM', cur1.item_nm);
                ihook.setColumnValue (row, 'VM_LNM', cur1.item_long_nm);
                ihook.setColumnValue (row, 'VM_DEF', cur1.item_nm);
                ihook.setColumnValue (row, 'VALUE', cur1.perm_val_nm);
                ihook.setColumnValue (row, 'MEAN_TXT', cur1.item_long_nm);
                v_itemid := nci_11179.getItemId;
                ihook.setColumnValue (row, 'NCI_PUB_ID', v_itemid);
                ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                
                 rowsvv.extend;
                rowsvv(rowsvv.last) := row;
                v_found := true;
              --  raise_application_error(-20000, 'Inside');
                end loop;   
                 end loop;
   end loop;
                
--DESC_TXT
   -- raise_application_error(-20000, v_add);
        if (v_add > 0) then
                        action := t_actionrowset(rows, 'Question (Base Object)', 2,0,'insert');
                        actions.extend;
                        actions(actions.last) := action;
        end if;                    
                            
    if (v_found) then 
    action := t_actionrowset(rowsvv, 'Question Valid Values (Hook)', 2,2,'insert');
    actions.extend;
    actions(actions.last) := action;
    end if;
    
    hookoutput.actions := actions;
    hookoutput.message := v_add || ' questions added.';
    end if;
end if;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  --insert into junk_debug values (sysdate, v_data_out);
  --commit;
END;



PROCEDURE spChngQuestTextVV (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(255);
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();  
 
 /*select frm_item_id, frm_ver_nr into v_frm_id, v_frm_Ver_nr from VW_NCI_MODULE_DE where nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
 */
 
 if hookInput.invocationNumber = 0 then
   
 
	    for cur in (select nm_id from alt_nms r where r.fld_delete= 0 and 
        (item_id, ver_nr) in (select NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR from VW_NCI_DE_PV pv,
        NCI_ADMIN_ITEM_REL_ALT_KEY q where pv.DE_ITEM_ID = q.C_ITEM_id and pv.DE_VER_NR = q.c_ITEM_VER_NR and q.NCI_PUB_ID = ihook.getColumnValue(row_ori,'Q_PUB_ID')
        and q.NCI_VER_NR= ihook.getColumnValue(row_ori, 'Q_VER_NR') and pv.PERM_VAL_NM = ihook.getColumnValue(row_ori, 'VALUE'))) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'NM_ID', cur.NM_id);
		   rows.extend;
		   rows (rows.last) := row;
		
 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;

	  if (v_found) then 
      ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select alternate.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Alternate Question Text', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
       	 showrowset := t_showablerowset (rows, 'Alternate Names', 2, 'single');
       	 hookoutput.showrowset := showrowset;
        else 
        hookoutput.message := 'No alternate names found.';
     end if;
 ELSE
            row_sel := hookinput.selectedRowset.rowset(1);

            select nm_desc into v_ref from alt_nms where nm_id = ihook.getColumnValue(row_sel, 'NM_ID');
            
            ihook.setColumnValue(row_ori, 'MEAN_TXT', v_ref);
            
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row_ori;
    
            action             := t_actionrowset(rows, 'Question Valid Values (Hook)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
     
    
    hookoutput.actions    := actions;
    END IF;
     
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spChngQuestDefVV (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(255);
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();  
 
 /*select frm_item_id, frm_ver_nr into v_frm_id, v_frm_Ver_nr from VW_NCI_MODULE_DE where nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
 */
 
 if hookInput.invocationNumber = 0 then
   
 
	    for cur in (select def_id from alt_def r where r.fld_delete= 0 and 
        (item_id, ver_nr) in (select NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR from VW_NCI_DE_PV pv,
        NCI_ADMIN_ITEM_REL_ALT_KEY q where pv.DE_ITEM_ID = q.C_ITEM_id and pv.DE_VER_NR = q.c_ITEM_VER_NR and q.NCI_PUB_ID = ihook.getColumnValue(row_ori,'Q_PUB_ID')
        and q.NCI_VER_NR= ihook.getColumnValue(row_ori, 'Q_VER_NR') and pv.PERM_VAL_NM = ihook.getColumnValue(row_ori, 'VALUE'))) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'DEF_ID', cur.DEF_id);
		   rows.extend;
		   rows (rows.last) := row;
		
 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;

	  if (v_found) then 
      ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select alternate.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Alternate Question Text', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
       	 showrowset := t_showablerowset (rows, 'Alternate Definitions', 2, 'single');
       	 hookoutput.showrowset := showrowset;
        else 
        hookoutput.message := 'No alternate definitions found.';
     end if;
 ELSE
            row_sel := hookinput.selectedRowset.rowset(1);

            select def_desc into v_ref from alt_def where def_id = ihook.getColumnValue(row_sel, 'DEF_ID');
            
            ihook.setColumnValue(row_ori, 'VM_DEF', v_ref);
            
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row_ori;
    
            action             := t_actionrowset(rows, 'Question Valid Values (Hook)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
     
    
    hookoutput.actions    := actions;
    END IF;
     
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

end;
/
