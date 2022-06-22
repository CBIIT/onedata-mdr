CREATE OR REPLACE PACKAGE NCI_11179 AS
function getWordCount(v_nm in varchar2) return integer;
function getWord(v_nm in varchar2, v_idx in integer, v_max in integer) return varchar2;
FUNCTION get_concepts(v_item_id in number, v_ver_nr in number) return varchar2;
Function get_concept_order(v_item_id in number, v_ver_nr in number) return varchar2 ;
function cmr_guid return varchar2;
procedure spGetCartPin  ( hookoutput in out t_hookoutput,v_typ in char);

FUNCTION getPrimaryConceptName(v_nm in varchar2) return varchar2;
procedure spAddToCart ( v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_src varchar2);
procedure spAddToCartGuest ( v_data_in in clob, v_data_out out clob);
procedure spRemoveFromCart (v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spNCIChangeLatestVer (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
procedure spNCIChangeLatestVerAll (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
procedure spCreateCommonChildrenNCI (actions in out t_actions, v_from_item_id in number, v_from_ver_nr in number, v_to_item_id in number, v_to_ver_nr in number);
procedure spAddConceptRel (v_data_in in clob, v_data_out out clob);
procedure spCreateVerNCI (v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spCreateCSVerNCI (v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure getConcatNmDef(v_item_id in number, v_ver_nr in number, v_nm out varchar2, v_long_nm out varchar2,v_def out varchar2);
procedure spCopyModuleNCI (actions in out t_actions, v_from_module_id in number,v_from_module_ver in number,  v_from_form_id in number, v_from_form_ver number, v_to_form_id number,
v_to_form_ver number, v_disp_ord number, v_src in varchar2, v_cntxt_item_id in number, v_cntxt_ver_nr in number, v_user_id in varchar2);
procedure spReturnSubtypeRow (v_item_id in number, v_ver_nr in number, v_type in number, row in out t_row);
procedure spReturnAIRow (v_item_id in number, v_ver_nr in number,  row in out t_row);
procedure spRefreshViews (v_data_in in clob, v_data_out out clob);

procedure spReturnAIExtRow (v_item_id in number, v_ver_nr in number,  row in out t_row);
procedure spReturnRow (v_item_id in number, v_ver_nr in number,  v_table_name in varchar2, row in out t_row);
procedure spReturnConceptRow (v_item_id in number, v_ver_nr in number, v_item_typ_id in integer, v_idx in integer, row in out t_row);
procedure spReturnRTConceptRow (v_item_id in number, v_ver_nr in number, v_item_typ_id in integer, v_idx in integer, row in out t_row);
function getItemId return integer;
procedure CncptCombExists (v_nm in varchar2, v_item_typ in integer, v_item_id out number, v_item_ver_nr out number, v_long_nm in out varchar2, v_def in out varchar2);
function replaceChar(v_str in varchar2) return varchar2;
procedure CopyPermVal (actions in out t_actions, v_from_id in number, v_from_ver_nr in number, v_to_id in number, v_to_ver_nr in number);
procedure ReturnRow (v_sql varchar2,  v_table_name in varchar2, row in out t_row);
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


CREATE OR REPLACE PACKAGE BODY NCI_11179 AS

v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
type       t_orgs is table of org_cntct.org_id%type;
v_int_cncpt_id  number := 2433736;

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


procedure spGetCartPin  ( hookoutput in out t_hookoutput, v_typ in char)  -- v_typ C - Cart only, P - Pin only, B - Both, I - Initial
as
 question t_question;
  answer t_answer;
  answers t_answers;
   forms t_forms;
  form1 t_form;
begin
    ANSWERS                    := T_ANSWERS();

    ANSWER                     := T_ANSWER(1, 1, 'Next');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    forms                  := t_forms();

    if (v_typ = 'C') then -- cart
        QUESTION               := T_QUESTION('Specify Cart Name.', ANSWERS);
        form1                  := t_form('User Cart (Hook)', 2,1);
    elsif (v_typ = 'P') then
       QUESTION               := T_QUESTION('Specify Pin.', ANSWERS);
        form1                  := t_form('Pin Only (hook)', 2,1);
    elsif     (v_typ = 'B') then
          QUESTION               := T_QUESTION('Specify Cart Name and Pin.', ANSWERS);
        form1                  := t_form('Cart Name And Pin (hook)', 2,1);
     elsif     (v_typ = 'I') then
            form1                  := t_form('Guest User Create Collection Initial (hook)', 2,1);
            QUESTION               := T_QUESTION('Specify Your Name, 6 digit Pin and Collection Type.', ANSWERS);
    end if;
 --   form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    hookoutput.forms := forms;
    hookoutput.question := question;

end;


procedure spRefreshViews ( v_data_in in clob, v_data_out out clob)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    row t_row;
    rows  t_rows;
    v_item_id number;
    v_ver_nr number(4,2);
       actions          t_actions := t_actions ();
       v_ful_path varchar2(4000) := '';
    action           t_actionRowset;
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;


DBMS_MVIEW.REFRESH('VW_CLSFCTN_SCHM');
DBMS_MVIEW.REFRESH('VW_CLSFCTN_SCHM_ITEM');
DBMS_MVIEW.REFRESH('VW_CNTXT');
DBMS_MVIEW.REFRESH('VW_CNCPT');
DBMS_MVIEW.REFRESH('VW_CONC_DOM');


    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;


procedure ReturnRow (v_sql varchar2,  v_table_name in varchar2, row in out t_row) as
    action           t_actionRowset;
    action_rows              t_rows := t_rows();

   -- v_sql        varchar2(4000);
    v_cur        number;
    v_temp        number;
    v_col_val       varchar2(4000);

    v_meta_col_cnt      integer;
    v_meta_desc_tab      dbms_sql.desc_tab;
begin


    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

  --  v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where rel_typ_id = 61 and p_item_id=:p_item_id and p_item_ver_nr=:p_item_ver_nr and disp_ord=:disp_ord';

    v_cur := dbms_sql.open_cursor;
    dbms_sql.parse(v_cur, v_sql, dbms_sql.native);


    for i in 1..v_meta_col_cnt loop
        dbms_sql.define_column(v_cur, i, '', 4000);
    end loop;

    v_temp := dbms_sql.execute_and_fetch(v_cur);
    dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);


    for i in 1..v_meta_col_cnt loop
        dbms_sql.column_value(v_cur, i, v_col_val);
        ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
    end loop;

    dbms_sql.close_cursor(v_cur);
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
procedure CncptCombExists (v_nm in varchar2, v_item_typ in integer, v_item_id out number, v_item_ver_nr out number, v_long_nm in out varchar2, v_def in out varchar2)
as
v_out integer;
begin

    for cur in (select ext.* from nci_admin_item_ext ext,admin_item a
    where nvl(a.fld_delete,0) = 0 and a.item_id = ext.item_id and a.ver_nr = ext.ver_nr and cncpt_concat = v_nm and a.admin_item_typ_id = v_item_typ) loop
            v_item_id := cur.item_id;
            v_item_ver_nr := cur.ver_nr;
            v_long_nm := cur.cncpt_concat;
            v_def := cur.cncpt_concat_def;
    end loop;
end;


/* Get the string in position v_idx within string v_nm */
function getWord(v_nm in varchar2, v_idx in integer, v_max in integer) return varchar2 is
   v_word  varchar2(4000);
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
procedure spNCIChangeLatestVer (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
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
v_version number(4,2);
begin
    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    /*  Current row that the user selected. cardinality is always 1 for this hook */
    row_cur := hookInput.originalRowset.Rowset(1);
    rows := t_rows();

    if hookInput.invocationNumber = 0 then  -- First invocation - show all the versions for the select Item ID
        for cur in ( select item_id, ver_nr from admin_item where item_id = ihook.getColumnValue(row_cur,'ITEM_ID')) loop
            if (nci_11179_2.isUserAuth(cur.item_id, cur.ver_nr, v_usr_id) = false) then
                raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
                return;
            end if;
            row := t_row();
            ihook.setColumnValue(row, 'ITEM_ID', cur.item_id);
            ihook.setColumnValue(row, 'VER_NR', cur.ver_nr);
            rows.extend; rows(rows.last) := row;
        end loop;

        showRowset := t_showableRowset(rows, 'Administered Item (Steward Assignment)',2, 'single');
        hookOutput.showRowset := showRowset;  -- Show rowset

        answers := t_answers();
  	   	answer := t_answer(1, 1, 'Select Latest Version');
  	   	answers.extend; answers(answers.last) := answer;
	   	question := t_question('Set Latest Version', answers);
       	hookOutput.question := question;  -- Ask the question

	elsif hookInput.invocationNumber = 1 then  -- Second invocation - set the actions
		  if hookInput.answerId = 1 then -- selected form
               row_sel := hookInput.selectedRowset.rowset(1);  -- Row selected to be the latest version
               v_version := ihook.getColumnValue(row_sel, 'VER_NR');
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
                    
                    if (ihook.getColumnValue(row_cur, 'ADMIN_ITEM_TYP_ID') = 9) then -- Classification Scheme
                    rows :=         t_rows();
                    for curcsi in (select item_id csi_item_id, ver_nr csi_ver_nr from nci_clsfctn_schm_item where cs_item_id =  ihook.getColumnValue(row_sel, 'ITEM_ID')) loop
                            row := t_row();
                            ihook.setColumnValue(row, 'ITEM_ID', curcsi.csi_item_id);
                            ihook.setColumnValue(row, 'VER_NR', curcsi.csi_ver_nr);
                        if (curcsi.csi_ver_nr = v_version) then
                            ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);  -- unselect current version for the original latest version
                        else
                          ihook.setColumnValue(row, 'CURRNT_VER_IND', 0);  -- unselect current version for the original latest version
                        end if;
                            rows.extend; rows(rows.last) := row;
                    end loop;
                    action := t_actionRowset(rows, 'Administered Item', 2, 1,'update');
                    actions.extend; actions(actions.last) := action;
                    end if;
                    hookOutput.actions := actions;
                    hookOutput.message := 'Successfully changed latest version.';
                end if;
        end if;
    end if;
    v_data_out := ihook.getHookOutput(hookOutput);
end;


/* Change Latest version for select Item Id. Command hook */
procedure spNCIChangeLatestVerAll (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
as
hookInput           t_hookInput;
hookOutput           t_hookOutput := t_hookOutput();
showRowset     t_showableRowset;

rows      t_rows;
row          t_row;
row_cur t_row;
row_ori t_row;
question    t_question;
answer     t_answer;
answers     t_answers;
v_cnt integer;
actions           t_actions := t_actions();
action           t_actionRowset;
v_found      boolean;
v_item_id		 number;
v_ver_nr		 number;

begin
    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    rows := t_rows();
    v_cnt := 0;

        for i in 1..hookinput.originalrowset.rowset.count loop

                row_ori :=  hookInput.originalRowset.rowset(i);

                if (ihook.getColumnValue(row_ori,'CURRNT_VER_IND') = 0) then --- proceed only if the selected row is not already latest
                    row := t_row();
                    ihook.setColumnValue(row, 'ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
                    ihook.setColumnValue(row, 'VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
                    ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);   --- Set current version for selected row
                    v_cnt := v_cnt + 1;
                    rows.extend; rows(rows.last) := row;
                    for cur in (select item_id, ver_nr from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and currnt_ver_ind = 1) loop
                            row := t_row();
                            ihook.setColumnValue(row, 'ITEM_ID', cur.item_id);
                            ihook.setColumnValue(row, 'VER_NR', cur.ver_nr);
                            ihook.setColumnValue(row, 'CURRNT_VER_IND', 0);  -- unselect current version for the original latest version
                            rows.extend; rows(rows.last) := row;
                    end loop;
                end if;
    end loop;
            action := t_actionRowset(rows, 'Administered Item', 2, 1,'update');
                    actions.extend; actions(actions.last) := action;
                    hookOutput.actions := actions;
                    hookOutput.message := 'Successfully changed latest version for: ' || v_cnt;

    v_data_out := ihook.getHookOutput(hookOutput);
end;

/*  Command hook to add selected items to cart. Cardinality - 1 or more */
PROCEDURE spAddToCart (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id  varchar2,
    v_src varchar2)
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
    v_item_typ integer;

begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   -- raise_application_error(-20000,v_user_id);

    rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
        if (v_src = 'AI') then
        v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
        v_item_typ := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');
        elsif (v_src ='MODULE') then
        v_item_id := ihook.getColumnValue(row_ori, 'C_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR');
        v_item_typ := 52;
    
        end if;
        if (v_item_typ in (3,4,2,52,54)) then
        select count(*) into v_temp from nci_usr_cart where item_id  = v_item_id and ver_nr = v_ver_nr and cntct_secu_id = v_user_id;
        /*  If not already in cart */
        if (v_temp = 0) then
         --   row := t_row();
            v_add := v_add + 1;
           insert into nci_usr_cart (item_id, ver_nr, cntct_secu_id, guest_usr_nm, creat_usr_id, lst_upd_usr_id)
           values (v_item_id, v_ver_nr, v_user_id, 'NONE', v_user_id, v_user_id);
           insert into onedata_ra.nci_usr_cart (item_id, ver_nr, cntct_secu_id, guest_usr_nm, creat_usr_id, lst_upd_usr_id)
           values (v_item_id, v_ver_nr, v_user_id, 'NONE', v_user_id, v_user_id);
           commit;
           else
            v_already := v_already + 1;
        end if;
        end if;
    end loop;
    if (v_add > 0) then   -- IF there are items to add to cart
        hookoutput.message := v_add || ' item(s) added successfully to cart. ' || v_already || ' item(s) selected already in your cart';
    else
        hookoutput.message := v_already || ' item(s) selected already in your cart';
    end if;
--raise_application_error(-20000,hookoutput.message);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --      nci_util.debugHook('GENERAL',v_data_out);

END;


/*  Command hook to add selected items to cart. Cardinality - 1 or more */
PROCEDURE spAddToCartOld (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id  varchar2,
    v_src varchar2)
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
    v_item_typ integer;

begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   -- raise_application_error(-20000,v_user_id);

    rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
        if (v_src = 'AI') then
        v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
        v_item_typ := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');
        elsif (v_src ='MODULE') then
        v_item_id := ihook.getColumnValue(row_ori, 'C_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR');
        v_item_typ := 52;
    
        end if;
        if (v_item_typ in (3,4,2,52,54)) then
        select count(*) into v_temp from nci_usr_cart where item_id  = v_item_id and ver_nr = v_ver_nr and cntct_secu_id = v_user_id;
        /*  If not already in cart */
        if (v_temp = 0) then
            row := t_row();
            v_add := v_add + 1;
            ihook.setColumnValue(row,'ITEM_ID', v_item_id);
            ihook.setColumnValue(row,'VER_NR', v_ver_nr);
      --      ihook.setColumnValue(row,'CNTCT_SECU_ID', v_user_id);
             ihook.setColumnValue(row,'CNTCT_SECU_ID', v_user_id);

            ihook.setColumnValue(row,'GUEST_USR_NM', 'NONE');
            rows.extend;    rows(rows.last) := row;
        else
            v_already := v_already + 1;
        end if;
        end if;
    end loop;
    if (v_add > 0) then   -- IF there are items to add to cart
        action := t_actionrowset(rows, 'User Cart', 2,1,'insert');
    --     action := t_actionrowset(rows, 'NCI_USR_CART', 1,1,'insert');
     actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
        hookoutput.message := v_add || ' item(s) added successfully to cart. ' || v_already || ' item(s) selected already in your cart';
    else
        hookoutput.message := v_already || ' item(s) selected already in your cart';
    end if;
--raise_application_error(-20000,hookoutput.message);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --      nci_util.debugHook('GENERAL',v_data_out);

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
            ANSWER                     := T_ANSWER(1, 1, 'Add to Guest User Cart' );
            ANSWERS.EXTEND;
            ANSWERS(ANSWERS.LAST):= ANSWER;
            QUESTION             := T_QUESTION('Specify a name that is easily remembered to store selections in your user cart. Please use the same cart name each time you want to add items to the same cart during your daily use. Guest user carts and their contents are deleted at 11:00 PM ET each day.' , ANSWERS);            HOOKOUTPUT.QUESTION    := QUESTION;
            forms                := t_forms();
            form1                := t_form('User Cart (Hook)', 2,1);
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
                hookoutput.message := v_add || ' item(s) added successfully to cart. ' || v_already || ' item(s) selected already in your cart';
            else
                hookoutput.message := v_already || ' item(s) selected already in your cart';
            end if;
         end if;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

/*  Command hook for Guest Add to Cart functionality */
PROCEDURE spAddToCartGuestOld
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
            ANSWER                     := T_ANSWER(1, 1, 'Add to Guest User Cart' );
            ANSWERS.EXTEND;
            ANSWERS(ANSWERS.LAST):= ANSWER;
            QUESTION             := T_QUESTION('Specify a name that is easily remembered to store selections in your user cart. Please use the same cart name each time you want to add items to the same cart during your daily use. Guest user carts and their contents are deleted at 11:00 PM ET each day.' , ANSWERS);            HOOKOUTPUT.QUESTION    := QUESTION;
            forms                := t_forms();
            form1                := t_form('User Cart (Hook)', 2,1);
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
                hookoutput.message := v_add || ' item(s) added successfully to cart. ' || v_already || ' item(s) selected already in your cart';
            else
                hookoutput.message := v_already || ' item(s) selected already in your cart';
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
        delete from nci_usr_cart where CNTCT_SECU_ID = v_user_id and item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR');
        delete from onedata_ra.nci_usr_cart where CNTCT_SECU_ID = v_user_id and item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR');
        commit;
    end loop;
    hookoutput.message := 'Item(s) successfully deleted from cart';

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

PROCEDURE spRemoveFromCartOld  (
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
    hookoutput.message := v_add || ' item(s) added successfully to cart. ' || v_already || ' item(s) selected already in your cart';
    else
    hookoutput.message := v_already || ' item(s) selected already in your cart';
    end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


/* Work in Progress */
procedure spCopyQuestion (actions in out t_actions, v_from_module_id in integer, v_from_module_ver in integer, v_to_module_id in integer, v_to_module_ver in integer, v_disp_ord number, v_src in varchar2) as
v_id integer;
v_found boolean;
v_itemid integer;
row  t_row;
rows t_rows;
rowsvv t_rows;
rowsrep t_rows;
action t_actionRowset;
k integer;
rowx t_row;
rowq t_row;
begin

 rowsvv:= t_rows();

 rowsrep := t_rows();
 rows:= t_rows();
for cur in (select * from nci_admin_item_rel_alt_key where p_item_id = v_from_module_id and
        p_item_ver_nr = v_from_module_ver and rel_typ_id = 63 and nvl(fld_delete,0) = 0) loop
    rowq := t_row();

  v_id := nci_11179.getItemId;
ihook.setColumnValue (rowq, 'NCI_PUB_ID', v_id);
ihook.setColumnValue (rowq, 'NCI_VER_NR', v_to_module_ver);
ihook.setColumnValue (rowq, 'P_ITEM_ID', v_to_module_id);
ihook.setColumnValue (rowq, 'P_ITEM_VER_NR', v_to_module_ver);
ihook.setColumnValue (rowq, 'C_ITEM_ID', cur.c_item_id);
ihook.setColumnValue (rowq, 'C_ITEM_VER_NR', cur.c_item_ver_nr);
ihook.setColumnValue (rowq, 'CNTXT_CS_ITEM_ID', cur.cntxt_cs_item_id);
ihook.setColumnValue (rowq, 'CNTXT_CS_VER_NR', cur.cntxt_cs_ver_nr);
ihook.setColumnValue (rowq, 'ITEM_LONG_NM', cur.ITEM_LONG_NM );
ihook.setColumnValue (rowq, 'ITEM_NM', cur.ITEM_NM );
ihook.setColumnValue (rowq, 'REL_TYP_ID', 63);
ihook.setColumnValue (rowq, 'DISP_ORD', cur.disp_ord);
ihook.setColumnValue (rowq, 'EDIT_IND', cur.EDIT_IND);
ihook.setColumnValue (rowq, 'REQ_IND', cur.REQ_IND);
ihook.setColumnValue (rowq, 'INSTR', cur.INSTR);
ihook.setColumnValue (rowq, 'DEFLT_VAL', cur.DEFLT_VAL);



    for cur1 in (select * from  NCI_QUEST_VALID_VALUE where q_pub_id = cur.nci_pub_id and q_ver_nr = cur.nci_ver_nr) loop
      row := t_row();
    ihook.setColumnValue (row, 'Q_PUB_ID', v_id);
    ihook.setColumnValue (row, 'Q_VER_NR', v_to_module_ver);
    ihook.setColumnValue (row, 'VM_NM', cur1.vm_nm);
    ihook.setColumnValue (row, 'VM_LNM', cur1.vm_lnm);
    ihook.setColumnValue (row, 'VM_DEF', cur1.vm_def);
      ihook.setColumnValue (row, 'DESC_TXT', cur1.desc_txt);
  ihook.setColumnValue (row, 'VALUE', cur1.value);
    ihook.setColumnValue (row, 'MEAN_TXT', cur1.mean_txt);
     ihook.setColumnValue (row, 'VAL_MEAN_ITEM_ID', cur1.VAL_MEAN_ITEM_ID);
     ihook.setColumnValue (row, 'VAL_MEAN_VER_NR', cur1.VAL_MEAN_VER_NR);
    v_itemid := nci_11179.getItemId;
    ihook.setColumnValue (row, 'NCI_PUB_ID', v_itemid);
    ihook.setColumnValue (row, 'NCI_VER_NR', 1);
ihook.setColumnValue (row, 'INSTR', cur1.INSTR);
ihook.setColumnValue (row, 'DISP_ORD', cur1.disp_ord);
ihook.setColumnValue (row, 'OLD_NCI_PUB_ID', cur1.NCI_PUB_ID);  -- to set question and repetition default

     rowsvv.extend;
    rowsvv(rowsvv.last) := row;
    v_found := true;
    -- Question default value
    if (cur.DEFLT_VAL_ID is not null and cur.DEFLT_VAL_ID = cur1.NCI_PUB_ID) then  -- Set question default
        ihook.setColumnValue (rowq, 'DEFLT_VAL_ID', v_itemid);
    end if;
  --  raise_application_error(-20000, 'Inside');
    end loop;


     rows.extend;
    rows(rows.last) := rowq;


if (v_src = 'V') then
  -- Question Repetition

    for cur2 in (select * from  NCI_QUEST_vv_rep where quest_pub_id = cur.nci_pub_id and quest_ver_nr = cur.nci_ver_nr) loop
      row := t_row();
    ihook.setColumnValue (row, 'Quest_PUB_ID', v_id);
    ihook.setColumnValue (row, 'Quest_VER_NR', v_to_module_ver);
    ihook.setColumnValue (row, 'REP_SEQ', cur2.REP_SEQ);
    ihook.setColumnValue (row, 'EDIT_IND', cur2.EDIT_IND);
    ihook.setColumnValue (row, 'VAL', cur2.VAL);

    if (cur2.DEFLT_VAL_ID is not null) then  -- find the new val id
        for k in 1..rowsvv.count loop
        rowx := rowsvv(k);
        if (ihook.getColumnValue(rowx,'OLD_NCI_PUB_ID') = cur2.DEFLT_VAL_ID) then
            ihook.setColumnValue (row, 'DEFLT_VAL_ID', ihook.getColumnValue(rowx,'NCI_PUB_ID'));
        end if;
        end loop;
    end if;
    ihook.setColumnValue (row, 'QUEST_VV_REP_ID',-1);

     rowsrep.extend;
    rowsrep(rowsrep.last) := row;
  --  raise_application_error(-20000, 'Inside');
    end loop;
end if;


   end loop;
   if (rows.count > 0) then
    action := t_actionrowset(rows, 'Questions (Base Object)', 2,14,'insert');
    actions.extend;
    actions(actions.last) := action;
  end if;
    if (rowsvv.count > 0) then
    action := t_actionrowset(rowsvv, 'Question Valid Values (Hook)', 2,16,'insert');
    actions.extend;
    actions(actions.last) := action;
  end if;

  if (rowsrep.count > 0) then
    action := t_actionrowset(rowsrep, 'Question Repetition', 2,17,'insert');
    actions.extend;
    actions(actions.last) := action;
  end if;

end;



/* Work in Progress */
procedure spCopyQuestionDirect ( v_from_module_id in integer, v_from_module_ver in integer, v_to_module_id in integer, v_to_module_ver in integer, v_disp_ord number, v_src in varchar2, v_user_id in varchar2) as
v_id integer;
v_found boolean;
v_itemid integer;
row  t_row;
rows t_rows;
rowsvv t_rows;
rowsrep t_rows;
action t_actionRowset;
k integer;
rowx t_row;
rowq t_row;
v_dflt number;
v_vv_id number;
begin

 rowsvv:= t_rows();

 rowsrep := t_rows();
 rows:= t_rows();
for cur in (select * from nci_admin_item_rel_alt_key where p_item_id = v_from_module_id and
        p_item_ver_nr = v_from_module_ver and rel_typ_id = 63 and nvl(fld_delete,0) = 0) loop
    rowq := t_row();

  v_id := nci_11179.getItemId;


--raise_application_error(-20000, 'Here' || v_id);

  insert into nci_admin_item_rel_alt_key (NCI_PUB_ID, NCI_VER_NR, P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, CNTXT_CS_ITEM_ID, CNTXT_CS_VER_NR,
  ITEM_LONG_NM, ITEM_NM, REL_TYP_ID, DISP_ORD, EDIT_IND, REQ_IND, INSTR, DEFLT_VAL, creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id)
  values (v_id, v_to_module_ver, v_to_module_id, v_to_module_ver, cur.c_item_id, cur.c_item_ver_nr, cur.cntxt_cs_item_id, cur.cntxt_cs_ver_nr, cur.item_long_nm,
  cur.item_nm, 63, cur.disp_ord, cur.edit_ind, cur.req_ind, cur.instr, cur.deflt_val, sysdate, v_user_id, sysdate, v_user_id );
  commit;

  insert into onedata_ra.nci_admin_item_rel_alt_key (NCI_PUB_ID, NCI_VER_NR, P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, CNTXT_CS_ITEM_ID, CNTXT_CS_VER_NR,
  ITEM_LONG_NM, ITEM_NM, REL_TYP_ID, DISP_ORD, EDIT_IND, REQ_IND, INSTR, DEFLT_VAL, creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id)
  values (v_id, v_to_module_ver, v_to_module_id, v_to_module_ver, cur.c_item_id, cur.c_item_ver_nr, cur.cntxt_cs_item_id, cur.cntxt_cs_ver_nr, cur.item_long_nm,
  cur.item_nm, 63, cur.disp_ord, cur.edit_ind, cur.req_ind, cur.instr, cur.deflt_val, sysdate, v_user_id, sysdate, v_user_id);
  commit;


    for cur1 in (select * from  NCI_QUEST_VALID_VALUE where q_pub_id = cur.nci_pub_id and q_ver_nr = cur.nci_ver_nr) loop
   v_itemid := nci_11179.getItemId;

  insert into nci_quest_valid_value (Q_PUB_ID, Q_VER_NR, VM_NM, VM_LNM, VM_DEF, DESC_TXT, VALUE, MEAN_TXT, VAL_MEAN_ITEM_ID, VAL_MEAN_VER_NR,   NCI_PUB_ID, NCI_VER_NR,
  INSTR, DISP_ORD, OLD_NCI_PUB_ID, creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id)
  values (v_id, v_to_module_ver, cur1.vm_nm, cur1.vm_lnm, cur1.vm_def, cur1.desc_txt, cur1.value, cur1.mean_txt, cur1.VAL_MEAN_ITEM_ID, cur1.VAL_MEAN_VER_NR,
  v_itemid, 1, cur1.INSTR, cur1.disp_ord, cur1.NCI_PUB_ID, sysdate, v_user_id, sysdate, v_user_id);


  insert into onedata_ra.nci_quest_valid_value (Q_PUB_ID, Q_VER_NR, VM_NM, VM_LNM, VM_DEF, DESC_TXT, VALUE, MEAN_TXT, VAL_MEAN_ITEM_ID, VAL_MEAN_VER_NR,   NCI_PUB_ID, NCI_VER_NR,
  INSTR, DISP_ORD, OLD_NCI_PUB_ID, creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id)
  values (v_id, v_to_module_ver, cur1.vm_nm, cur1.vm_lnm, cur1.vm_def, cur1.desc_txt, cur1.value, cur1.mean_txt, cur1.VAL_MEAN_ITEM_ID, cur1.VAL_MEAN_VER_NR,
  v_itemid, 1, cur1.INSTR, cur1.disp_ord, cur1.NCI_PUB_ID, sysdate, v_user_id, sysdate, v_user_id);

      row := t_row();
    ihook.setColumnValue (row, 'Q_PUB_ID', v_id);
    ihook.setColumnValue (row, 'Q_VER_NR', v_to_module_ver);
    ihook.setColumnValue (row, 'VM_NM', cur1.vm_nm);
    ihook.setColumnValue (row, 'VM_LNM', cur1.vm_lnm);
    ihook.setColumnValue (row, 'VM_DEF', cur1.vm_def);
      ihook.setColumnValue (row, 'DESC_TXT', cur1.desc_txt);
  ihook.setColumnValue (row, 'VALUE', cur1.value);
    ihook.setColumnValue (row, 'MEAN_TXT', cur1.mean_txt);
     ihook.setColumnValue (row, 'VAL_MEAN_ITEM_ID', cur1.VAL_MEAN_ITEM_ID);
     ihook.setColumnValue (row, 'VAL_MEAN_VER_NR', cur1.VAL_MEAN_VER_NR);
    ihook.setColumnValue (row, 'NCI_PUB_ID', v_itemid);
    ihook.setColumnValue (row, 'NCI_VER_NR', 1);
ihook.setColumnValue (row, 'INSTR', cur1.INSTR);
ihook.setColumnValue (row, 'DISP_ORD', cur1.disp_ord);
ihook.setColumnValue (row, 'OLD_NCI_PUB_ID', cur1.NCI_PUB_ID);  -- to set question and repetition default

     rowsvv.extend;
    rowsvv(rowsvv.last) := row;
  --    raise_application_error(-20000, 'Inside');



  if (cur.DEFLT_VAL_ID is not null and cur.DEFLT_VAL_ID = cur1.NCI_PUB_ID) then  -- Set question default
 update nci_admin_item_rel_alt_key set deflt_val_id = v_itemid where nci_pub_id = v_id;
 end if;
 commit;
    end loop;

    for cur2 in (select * from  NCI_QUEST_vv_rep where quest_pub_id = cur.nci_pub_id and quest_ver_nr = cur.nci_ver_nr) loop


    if (cur2.DEFLT_VAL_ID is not null) then  -- find the new val id
        for k in 1..rowsvv.count loop
        rowx := rowsvv(k);
        if (ihook.getColumnValue(rowx,'OLD_NCI_PUB_ID') = cur2.DEFLT_VAL_ID) then
            v_dflt := ihook.getColumnValue(rowx,'NCI_PUB_ID');
        end if;
        end loop;
    end if;

    select seq_QUEST_VV_REP.nextval into v_vv_id from dual;

      insert into NCI_QUEST_VV_REP (QUEST_VV_REP_ID, QUEST_PUB_ID, QUEST_VER_NR, REP_SEQ, EDIT_IND, VAL, DEFLT_VAL_ID, creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id)
    values ( v_vv_id, v_id, v_to_module_ver, cur2.rep_seq, cur2.edit_ind, cur2.val, v_dflt, sysdate, v_user_id, sysdate, v_user_id);

      insert into onedata_ra.NCI_QUEST_VV_REP (QUEST_VV_REP_ID, QUEST_PUB_ID, QUEST_VER_NR, REP_SEQ, EDIT_IND, VAL, DEFLT_VAL_ID, creat_dt, creat_usr_id, lst_upd_dt, lst_upd_usr_id)
    values ( v_vv_id, v_id, v_to_module_ver, cur2.rep_seq, cur2.edit_ind, cur2.val, v_dflt, sysdate, v_user_id, sysdate, v_user_id);

  --  raise_application_error(-20000, 'Inside');
    end loop;

commit;
   end loop;

end;

/* Work in Progress */
procedure spCopyModuleNCI (actions in out t_actions, v_from_module_id in number,v_from_module_ver in number,
v_from_form_id in number, v_from_form_ver number, v_to_form_id number, v_to_form_ver number, v_disp_ord number, v_src in varchar2, v_cntxt_item_id in number, v_cntxt_ver_nr in number, v_user_id in varchar2) as


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
v_disp_ord1 integer;
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
    ihook.setColumnValue(row, 'ITEM_LONG_NM',v_to_module_id || 'v' ||  trim(to_char(v_to_form_ver, '9999.99')));
    if (v_cntxt_item_id is not null) then
    ihook.setColumnValue(row, 'CNTXT_ITEM_ID',v_cntxt_item_id);
    ihook.setColumnValue(row, 'CNTXT_VER_NR',v_cntxt_ver_nr);
    end if;
    -- Only from Copy.
    if (v_src = 'C') then
    ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
    end if;
    action_rows := t_rows();

    action_rows.extend; action_rows(action_rows.last) := row;
    action := t_actionRowset(action_rows, 'Administered Item (No Sequence)',2, 10, 'insert');
    actions.extend; actions(actions.last) := action;
  --  action := t_actionRowset(action_rows, 'Module',2, 11, 'insert');
  --  actions.extend; actions(actions.last) := action;


    row := t_row();

    ihook.setColumnValue(row, 'P_ITEM_VER_NR',v_to_form_ver);
    ihook.setColumnValue(row, 'P_ITEM_ID',v_to_form_id);
    ihook.setColumnValue(row, 'C_ITEM_ID',v_to_module_id);
    ihook.setColumnValue(row, 'C_ITEM_VER_NR',v_to_form_ver);
    ihook.setColumnValue(row, 'REL_TYP_ID',61);
   --ihook.setColumnValue(row, 'REP_NO',61);
   --ihook.setColumnValue(row, 'INSTR',61);

if (v_disp_ord < 0) then  -- calling from Copy Hodule hook
     select nvl(max(disp_ord)+ 1,0) into v_disp_ord1 from nci_admin_item_rel where
     p_item_id = v_to_form_id and p_item_ver_nr = v_to_form_ver;
      --   raise_application_error(-2000
    ihook.setColumnValue(row, 'DISP_ORD',v_disp_ord1);
else -- called from version hook
    ihook.setColumnValue(row, 'DISP_ORD',v_disp_ord);
end if;
        --ise_application_error(-20000, v_from_module_id || 'A' || v_from_form_id || 'B' || v_from_module_ver || 'C' || v_from_form_ver);

for curmod in (select * from nci_admin_item_rel where c_item_id = v_from_module_id and c_item_ver_nr = v_from_module_ver and rel_typ_id = 61 ) loop
       ihook.setColumnValue(row, 'REP_NO', curmod.rep_no);
       if (v_src = 'C') then  -- on Copy, rep number is 0
        ihook.setColumnValue(row, 'REP_NO', 0);
       end if;

        ihook.setColumnValue(row, 'INSTR',curmod.instr);
    --    raise_application_error(-20000, curmod.instr);
   end loop;


     action_rows := t_rows();

    action_rows.extend; action_rows(action_rows.last) := row;
    action := t_actionRowset(action_rows, 'Generic AI Relationship', 2, 12, 'insert');
    actions.extend; actions(actions.last) := action;

--raise_application_error(-20000,'HErer');
-- Questions
 if (v_src = 'C') then  -- on Copy, rep number is 0
    spCopyQuestion(actions, v_from_module_id, v_from_module_ver, v_to_module_id, v_to_form_ver,v_disp_ord, v_src);
 end if;
  if (v_src = 'V') then  -- on Copy, rep number is 0
   spCopyQuestionDirect(v_from_module_id, v_from_module_ver, v_to_module_id, v_to_form_ver,v_disp_ord, v_src, v_user_id);
 end if;
--raise_application_error(-20000,'Here'|| v_from_module_id || '   ' || v_to_module_id || '  ' || actions.count);



end;



/*  Common children copy when creating a version */
procedure spCreateCommonChildrenNCI (actions in out t_actions, v_from_item_id in number, v_from_ver_nr in number, v_to_item_id in number, v_to_ver_nr in number) as
    action           t_actionRowset;
    action_rows              t_rows := t_rows();
    action_rows_csi              t_rows := t_rows();
    action_rows_blob    t_rows := t_rows();

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
    item_id = v_from_item_id and ver_nr = v_from_ver_nr and nvl(fld_delete,0) = 0) loop
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
        ihook.setColumnValue(row, 'ITEM_ID', v_to_item_id);
        ihook.setColumnValue(row, 'VER_NR', v_to_ver_nr);
        ihook.setColumnValue(row, 'NCI_IDSEQ', '');

        action_rows.extend; action_rows(action_rows.last) := row;
        /*  Alternate Name - Classification */
        for csi_cur in (select nci_pub_id, nci_ver_nr, typ_nm from NCI_CSI_ALT_DEFNMS where nmdef_id = an_cur.nm_id and nvl(fld_delete,0)=0) loop
            row:= t_row();
            ihook.setColumnValue(row, 'nmdef_ID',v_temp);
            ihook.setColumnValue(row, 'NCI_PUB_ID', csi_cur.NCI_PUB_ID);
            ihook.setColumnValue(row, 'NCI_VER_NR', csi_cur.NCI_VER_NR);
            ihook.setColumnValue(row, 'TYP_NM', csi_cur.TYP_NM);
            action_rows_csi.extend; action_rows_csi(action_rows_Csi.last) := row;
         end loop;
    end loop;

   -- action := t_actionRowset(action_rows, v_table_name, 12, 'insert');
     action := t_actionRowset(action_rows, 'Alternate Names',2, 12, 'insert');


    actions.extend; actions(actions.last) := action;
---  End of Alternate Names

-- Alternate Definitions

    action_rows := t_rows();

    v_table_name := 'ALT_DEF';
    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    for ad_cur in  (select def_id from alt_def where
    item_id = v_from_item_id and ver_nr = v_from_ver_nr and nvl(fld_delete,0) = 0) loop
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
        ihook.setColumnValue(row, 'DEF_ID', v_temp);
        ihook.setColumnValue(row, 'ITEM_ID', v_to_item_id);
        ihook.setColumnValue(row, 'VER_NR', v_to_ver_nr);
        ihook.setColumnValue(row, 'NCI_IDSEQ', '');
        action_rows.extend; action_rows(action_rows.last) := row;

        for csi_cur in (select nci_pub_id, nci_ver_nr, typ_nm from NCI_CSI_ALT_DEFNMS where nmdef_id = ad_cur.def_id and nvl(fld_delete,0) = 0) loop
            row:= t_row();
            ihook.setColumnValue(row, 'NMDEF_ID',v_temp);
            ihook.setColumnValue(row, 'NCI_PUB_ID', csi_cur.NCI_PUB_ID);
            ihook.setColumnValue(row, 'NCI_VER_NR', csi_cur.NCI_VER_NR);
            ihook.setColumnValue(row, 'TYP_NM', csi_cur.TYP_NM);
            action_rows_csi.extend; action_rows_csi(action_rows_Csi.last) := row;
         end loop;
    end loop;

    action := t_actionRowset(action_rows, 'Alternate Definitions',2, 13, 'insert');
    actions.extend; actions(actions.last) := action;

    action := t_actionRowset(action_rows_csi, 'Classification level Name/Definition 2',2, 25, 'insert');
    actions.extend; actions(actions.last) := action;

-- End of Alternate Definition

--- Reference Documents

    action_rows := t_rows();

    v_table_name := 'REF';
    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    for ref_cur in  (select ref_id from ref where
    item_id = v_from_item_id and ver_nr = v_from_ver_nr and nvl(fld_delete,0) = 0) loop

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

        select od_seq_REF.nextval into v_temp from dual;
        ihook.setColumnValue(row, 'ref_ID', v_temp);
        ihook.setColumnValue(row, 'NCI_IDSEQ', '');
        ihook.setColumnValue(row, 'ITEM_ID', v_to_item_id);
        ihook.setColumnValue(row, 'VER_NR', v_to_ver_nr);
        action_rows.extend; action_rows(action_rows.last) := row;

        -- Blobs are not supported in iHooks. Copying blobs as direct sql. No other option

        insert into ref_doc (nci_ref_id, file_nm, blob_col, nci_mime_type, nci_doc_size, NCI_DOC_LST_UPD_DT, ref_doc_id)
        select v_temp, file_nm ||'-' ||  v_to_item_id || '-' || v_to_ver_nr, blob_col, nci_mime_type, nci_doc_size, NCI_DOC_LST_UPD_DT,-1 from ref_doc where
        nci_ref_id = ref_cur.ref_id and  nvl(fld_delete,0)=0;
        commit;
        insert into onedata_ra.ref_doc select * from ref_doc where nci_ref_id = v_temp;
        commit;

        /* for blob_cur in (select * from ref_doc where nci_ref_id = ref_cur.ref_id and nvl(fld_delete,0)=0) loop
            row:= t_row();
            ihook.setColumnValue(row, 'nci_ref_id',v_temp);
            ihook.setColumnValue(row, 'FILE_NM', blob_cur.FILE_NM);
            ihook.setColumnValue(row, 'BLOB_COL', blob_cur.BLOB_COL);
            ihook.setColumnValue(row, 'NCI_MIME_TYPE', blob_cur.NCI_MIME_TYPE);
            ihook.setColumnValue(row, 'NCI_DOC_SIZE', blob_cur.NCI_DOC_SIZE);
            ihook.setColumnValue(row, 'NCI_DOC_LST_UPD_DT', blob_cur.NCI_DOC_LST_UPD_DT);
            ihook.setColumnValue(row, 'REF_DOC_ID', -1);
            action_rows_blob.extend; action_rows_blob(action_rows_blob.last) := row;
         end loop;

         */
    end loop;

    action := t_actionRowset(action_rows, 'References (for Edit)',2, 14, 'insert');
    actions.extend; actions(actions.last) := action;

  --  action := t_actionRowset(action_rows_blob,'Ref Documents',2 ,15, 'insert');
  --  actions.extend; actions(actions.last) := action;

   -- raise_application_error(-20000, 'herer');
-- End of Reference Documents
-- Concepts

    action_rows := t_rows();

    v_table_name := 'CNCPT_ADMIN_ITEM';
    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    for ref_cur in  (select CNCPT_AI_ID from CNCPT_ADMIN_ITEM where
    item_id = v_from_item_id and ver_nr = v_from_ver_nr) loop
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
        ihook.setColumnValue(row, 'ITEM_ID', v_to_item_id);
        ihook.setColumnValue(row, 'VER_NR', v_to_ver_nr);
        action_rows.extend; action_rows(action_rows.last) := row;
    end loop;

    action := t_actionRowset(action_rows, v_table_name, 14, 'insert');
    actions.extend; actions(actions.last) := action;

-- End of concepts

--- Begin of Classifications

    action_rows := t_rows();

    v_table_name := 'NCI_ADMIN_ITEM_REL';
    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    for ref_cur in  (select P_ITEM_ID,P_ITEM_VER_NR, REL_TYP_ID from NCI_ADMIN_ITEM_REL where
    c_item_id = v_from_item_id and c_item_ver_nr = v_from_ver_nr and rel_typ_id = 65 and nvl(fld_Delete,0) = 0) loop

        v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where P_ITEM_ID = :P_ITEM_ID and P_ITEM_VER_NR = :P_ITEM_VER_NR and c_item_id = :c_item_id and c_item_ver_nr = :c_item_ver_nr and rel_typ_id = :rel_typ_id';
        v_cur := dbms_sql.open_cursor;
        dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
        dbms_sql.bind_variable(v_cur, ':P_ITEM_ID', ref_cur.P_ITEM_ID);
        dbms_sql.bind_variable(v_cur, ':P_ITEM_VER_NR', ref_cur.P_ITEM_VER_NR);
        dbms_sql.bind_variable(v_cur, ':c_item_id', v_from_item_id);
        dbms_sql.bind_variable(v_cur, ':c_item_ver_nr', v_from_ver_nr);
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

       ihook.setColumnValue(row, 'C_ITEM_ID', v_to_item_id);
       ihook.setColumnValue(row, 'C_ITEM_VER_NR', v_to_ver_nr);
        ihook.setColumnValue(row, 'NCI_IDSEQ', '');
        action_rows.extend; action_rows(action_rows.last) := row;
    end loop;

    action := t_actionRowset(action_rows, 'NCI CSI - DE Relationship',2, 15, 'insert');
    actions.extend; actions(actions.last) := action;

end;


procedure spReturnConceptRow (v_item_id in number, v_ver_nr in number, v_item_typ_id in integer, v_idx in integer, row in out t_row) as
    i   integer;

begin
    i := 1;
     for cur in (select cai.cncpt_item_id item_id, cai.cncpt_ver_nr ver_nr, cai.NCI_CNCPT_VAL nci_cncpt_val from  cncpt_admin_item cai where
      cai.item_id = v_item_id and cai.ver_nr = v_ver_nr order by nci_ord desc ) loop
                                ihook.setColumnValue(row, 'CNCPT_' || v_idx  ||'_ITEM_ID_' || i,cur.item_id);
                                ihook.setColumnValue(row, 'CNCPT_' || v_idx || '_VER_NR_' || i, cur.ver_nr);
                                if (cur.item_id = v_int_cncpt_id) then
                                    ihook.setColumnValue(row, 'CNCPT_INT_' || v_idx || '_' || i, cur.nci_cncpt_val);
                                end if;
                                i := i+1;
                        end loop;
end;



procedure spReturnRTConceptRow (v_item_id in number, v_ver_nr in number, v_item_typ_id in integer, v_idx in integer, row in out t_row) as
    i   integer;

begin
    i := 1;
     for cur in (select cai.cncpt_item_id item_id, cai.cncpt_ver_nr ver_nr, nci_ord , cai.nci_cncpt_val from  cncpt_admin_item cai where
      cai.item_id = v_item_id and cai.ver_nr = v_ver_nr order by nci_ord desc ) loop

      if (cur.nci_ord = 0) then
                                ihook.setColumnValue(row, 'CNCPT_' || v_idx  ||'_ITEM_ID_1' ,cur.item_id);
                                ihook.setColumnValue(row, 'CNCPT_' || v_idx || '_VER_NR_1' , cur.ver_nr);
      else
                                i := i+1;
                                ihook.setColumnValue(row, 'CNCPT_' || v_idx  ||'_ITEM_ID_' || i,cur.item_id);
                                ihook.setColumnValue(row, 'CNCPT_' || v_idx || '_VER_NR_' || i, cur.ver_nr);
                                   if (cur.item_id = v_int_cncpt_id) then
                                    ihook.setColumnValue(row, 'CNCPT_INT_' || v_idx || '_' || i, cur.nci_cncpt_val);
                                end if;
      end if;

                        end loop;
end;


procedure spReturnSubtypeRow (v_item_id in number, v_ver_nr in number, v_type in number, row in out t_row) as
    action           t_actionRowset;
    action_rows              t_rows := t_rows();

    v_table_name      varchar2(30);
    v_sql        varchar2(4000);
    v_cur        number;
    v_temp        number;
    v_col_val       varchar2(4000);

    v_meta_col_cnt      integer;
    v_meta_desc_tab      dbms_sql.desc_tab;
begin
    if v_type= 1 then
        v_table_name := 'CONC_DOM';
    elsif v_type = 2 then
        v_table_name := 'DE_CONC';
    elsif v_type = 3 then
        v_table_name := 'VALUE_DOM';
    elsif v_type = 4 then
        v_table_name := 'DE';
    elsif v_type = 5 then
        v_table_name := 'OBJ_CLS';
    elsif v_type = 6 then
        v_table_name := 'PROP';
    elsif v_type = 7 then
        v_table_name := 'REP_CLS';
    elsif v_type = 8 then
        v_table_name := 'CNTXT';
    elsif v_type = 9 then
        v_table_name := 'CLSFCTN_SCHM';
    elsif v_type = 10 then
        v_table_name := 'DERV_RUL';
    elsif v_type = 49 then
        v_table_name := 'CNCPT';
    elsif v_type = 54 then
        v_table_name := 'NCI_FORM';
    elsif v_type = 51 then
        v_table_name := 'NCI_CLSFCTN_SCHM_ITEM';
    end if;

    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where item_id=:item_id and ver_nr=:ver_nr';

    v_cur := dbms_sql.open_cursor;
    dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
    dbms_sql.bind_variable(v_cur, ':item_id',v_item_id);
    dbms_sql.bind_variable(v_cur, ':ver_nr', v_ver_nr);

    for i in 1..v_meta_col_cnt loop
        dbms_sql.define_column(v_cur, i, '', 4000);
    end loop;

    v_temp := dbms_sql.execute_and_fetch(v_cur);
    dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);


    for i in 1..v_meta_col_cnt loop
        dbms_sql.column_value(v_cur, i, v_col_val);
        ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
    end loop;
    ihook.setColumnValue(row,'ITEM_ID', v_item_id);
    ihook.setColumnValue(row,'VER_NR', v_ver_nr);

    dbms_sql.close_cursor(v_cur);
end;


procedure spReturnAIRow (v_item_id in number, v_ver_nr in number,row in out t_row) as

    v_table_name      varchar2(30);

begin

    v_table_name := 'ADMIN_ITEM';
    spReturnRow (v_item_id, v_ver_nr, v_table_name, row);
end;


procedure spReturnAIExtRow (v_item_id in number, v_ver_nr in number,row in out t_row) as

    v_table_name      varchar2(30);

begin

    v_table_name := 'NCI_ADMIN_ITEM_EXT';
    spReturnRow (v_item_id, v_ver_nr, v_table_name, row);
end;

procedure spReturnRow (v_item_id in number, v_ver_nr in number,  v_table_name in varchar2, row in out t_row) as
    action           t_actionRowset;
    action_rows              t_rows := t_rows();

    v_sql        varchar2(4000);
    v_cur        number;
    v_temp        number;
    v_col_val       varchar2(4000);

    v_meta_col_cnt      integer;
    v_meta_desc_tab      dbms_sql.desc_tab;
begin


    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where item_id=:item_id and ver_nr=:ver_nr';

    v_cur := dbms_sql.open_cursor;
    dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
    dbms_sql.bind_variable(v_cur, ':item_id',v_item_id);
    dbms_sql.bind_variable(v_cur, ':ver_nr', v_ver_nr);

    for i in 1..v_meta_col_cnt loop
        dbms_sql.define_column(v_cur, i, '', 4000);
    end loop;

    v_temp := dbms_sql.execute_and_fetch(v_cur);
    dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);


    for i in 1..v_meta_col_cnt loop
        dbms_sql.column_value(v_cur, i, v_col_val);
        ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
    end loop;
    ihook.setColumnValue(row,'ITEM_ID', v_item_id);
    ihook.setColumnValue(row,'VER_NR', v_ver_nr);

    dbms_sql.close_cursor(v_cur);
end;


procedure CopyPermVal (actions in out t_actions, v_from_id in number, v_from_ver_nr in number, v_to_id in number, v_to_ver_nr in number)
as
 v_table_name      varchar2(30);
    v_sql        varchar2(4000);
    v_cur        number;
    v_temp        number;
    v_col_val       varchar2(4000);

    v_meta_col_cnt      integer;
    v_meta_desc_tab      dbms_sql.desc_tab;
    row t_row;
    action_rows t_rows;
    action  t_actionRowset;
begin

action_rows := t_rows();
   v_table_name := 'PERM_VAL';
        v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);
        for pv_cur in  (select val_id from perm_val where
        val_dom_item_id = v_from_id and val_dom_ver_nr = v_from_ver_nr and nvl(fld_delete,0) = 0) loop

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
            ihook.setColumnValue(row, 'VAL_DOM_VER_NR', v_to_ver_nr);
            ihook.setColumnValue(row, 'VAL_DOM_ITEM_ID', v_to_id);
            ihook.setColumnValue(row, 'NCI_IDSEQ', '');
            action_rows.extend; action_rows(action_rows.last) := row;

        end loop;

         action := t_actionRowset(action_rows, 'Permissible Values (Version)',2, 11, 'insert');
        actions.extend; actions(actions.last) := action;
end;

/*  Create sub-type row for version. Called from spCreateVer */

procedure spCreateSubtypeVerNCI (actions in out t_actions, v_admin_item admin_item%rowtype, v_version number, v_user_id in varchar2) as
    action           t_actionRowset;
    action_rows              t_rows := t_rows();
    row          t_row;
    v_found boolean;
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
         CopyPermVal ( actions, v_admin_item.item_id, v_admin_item.ver_nr, v_admin_item.item_id, v_version);
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
        P_item_id = v_admin_item.item_id and p_ITEM_ver_nr = v_admin_item.ver_nr and rel_typ_id = 66 and nvl(fld_Delete,0) = 0) loop

            v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where P_ITEM_ID = :P_ITEM_ID and P_ITEM_VER_NR = :P_ITEM_VER_NR and C_ITEM_ID = :C_ITEM_ID and C_ITEM_VER_NR = :C_ITEM_VER_NR and REL_TYP_ID=66';

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

        action := t_actionRowset(action_rows, 'Derived CDE Component (Data Element CO)',2, 12, 'insert');
        actions.extend; actions(actions.last) := action;
    end if;

/*  If Form  */
    if v_admin_item.admin_item_typ_id = 54 then
    -- Add Modules
     for cur2 in (select c_item_id, c_item_ver_nr, disp_ord from nci_admin_item_rel where p_item_id = v_admin_item.item_id and p_item_ver_nr = v_admin_item.ver_nr
     and nvl(fld_delete,0) = 0) loop
        nci_11179.spCopyModuleNCI(actions, cur2.c_item_id, cur2.c_item_ver_nr, v_admin_item.item_id, v_admin_item.item_id, v_admin_item.item_id, v_version, cur2.disp_ord, 'V', null, null, v_user_id);
     end loop;
     -- Add protocols

        action_rows := t_rows();
        v_table_name := 'NCI_ADMIN_ITEM_REL';
        v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);
        v_found := false;

        for pro_cur in (select P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID from NCI_ADMIN_ITEM_REL where
        c_item_id = v_admin_item.item_id and c_ITEM_ver_nr = v_admin_item.ver_nr and rel_typ_id = 60 and nvl(fld_delete,0) = 0) loop
          --    raise_application_error(-20000,'Herer');

            row := t_row();
            ihook.setColumnValue(row, 'P_ITEM_ID', pro_cur.P_ITEM_ID);
          ihook.setColumnValue(row, 'P_ITEM_VER_NR', pro_cur.P_ITEM_VER_NR);
          ihook.setColumnValue(row, 'C_ITEM_ID', pro_cur.C_ITEM_ID);
          ihook.setColumnValue(row, 'REL_TYP_ID', pro_cur.rel_typ_id);
            ihook.setColumnValue(row, 'C_ITEM_VER_NR', v_version);

            v_found  := true;
            action_rows.extend; action_rows(action_rows.last) := row;
        end loop;
      if (v_found) then
        action := t_actionRowset(action_rows, 'Protocol-Form Relationship (Form View)',2, 22, 'insert');
        actions.extend; actions(actions.last) := action;
        end if;
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

     if (v_admin_item.admin_item_typ_id not in (2,3,4,54)) then -- changed based on new rules from DW 2/3/2021
        hookOutput.message := 'Administered Item of this type cannot be versioned.';
        v_data_out := ihook.getHookOutput(hookOutput);
        return;
    end if;

   if (v_admin_item.admin_item_typ_id = 3) then -- Tracker 1568 - VD without RT cannot be versioned
   for cur in (select * from value_dom where item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr and REP_CLS_ITEM_ID is null) loop
        hookOutput.message := 'Value Domain without Rep Term cannot be versioned.';
        v_data_out := ihook.getHookOutput(hookOutput);
        return;
    end loop;
    end if;
      /*  if (v_admin_item.regstr_stus_id is null) then
      hookOutput.message := 'Cannot create version for Administered Items with no Registration Status assigned.';
            v_data_out := ihook.getHookOutput(hookOutput);
            return;
        end if;  */

    if hookInput.invocationNumber = 0 then  -- If first invocation, prompt for version number

        ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(1, 1, 'Create Version' );
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION('Specify New Version, Current Version is: ' || trim(to_char(ihook.getColumnValue(row_ori,'VER_NR' ), '9999.99')) , ANSWERS);
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
            ihook.setColumnValue(row, 'REGSTR_STUS_ID',9 );
            
            -- if VD, then change the short name only if short name has ID in it
            if (ihook.getColumnValue(row, 'ADMIN_ITEM_TYP_ID') = 3 and instr(ihook.getColumnValue(row, 'ITEM_LONG_NM'),ihook.getColumnValue(row,'ITEM_ID')) > 0) then
                ihook.setColumnValue(row, 'ITEM_LONG_NM',ihook.getColumnValue(row, 'ITEM_ID' || 'v' || trim(to_char(v_version, '9999.99'))  ));

            end if;
            
            if (v_admin_item.admin_item_typ_id in (54)) then -- Form needs to Draft NEw
                ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66 );
                ihook.setColumnValue(row, 'REGSTR_STUS_ID','' );
            end if;
            ihook.setColumnValue(row, 'NCI_IDSEQ', '');

            ai_insert_action_rows.extend; ai_insert_action_rows(ai_insert_action_rows.last) := row;

            /* set latest version to 0 for current row */
            row := t_row();
            ihook.setColumnValue(row, 'ITEM_ID', v_admin_item.item_id);
            ihook.setColumnValue(row, 'VER_NR', v_admin_item.ver_nr);
            ihook.setColumnValue(row, 'CURRNT_VER_IND', 0);
            ai_update_action_rows.extend; ai_update_action_rows(ai_update_action_rows.last) := row;

            /* Call sub-type creation function */
            spCreateSubtypeVerNCI(actions, v_admin_item, v_version, v_user_id);

            /* Copy all common children */
            spCreateCommonChildrenNCI(actions, v_admin_item.item_id,v_admin_item.ver_nr, v_admin_item.item_id, v_version);

            action := t_actionRowset(ai_insert_action_rows, 'Administered Item (No Sequence)',2, 0, 'insert');
            actions.extend; actions(actions.last) := action;

            action := t_actionRowset(ai_update_action_rows, 'ADMIN_ITEM', 0, 'update');
            actions.extend; actions(actions.last) := action;

            hookOutput.actions := actions;

            hookOutput.message := 'Version created successfully.';
        end if;
    end if;

    v_data_out := ihook.getHookOutput(hookOutput);

  --   nci_util.debugHook('GENERAL',v_data_out);
    -- insert into junk_debug (id, test) values (sysdate, v_data_out);
    -- commit;

end;


/*  Command Hook - Create Version */
procedure spCreateCSVerNCI (v_data_in in clob, v_data_out out clob, v_user_id varchar2) as

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
    action_rows t_rows;
    row_ori t_row;
    action_rows_csi  t_rows;
    rowst t_row;
    v_meta_col_cnt      integer;
    v_meta_desc_tab      dbms_sql.desc_tab;
   action_rows_upd  t_rows;
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

     if v_admin_item.admin_item_typ_id <> 9 then
        hookOutput.message := 'Please select a CS to version.';
        v_data_out := ihook.getHookOutput(hookOutput);
        return;
     end if;
    
    if hookInput.invocationNumber = 0 then  -- If first invocation, prompt for version number

        ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(1, 1, 'Create Version' );
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION('Specify New Version, Current Version is: ' || trim(to_char(ihook.getColumnValue(row_ori,'VER_NR' ), '9999.99')) , ANSWERS);
        HOOKOUTPUT.QUESTION    := QUESTION;
        forms                  := t_forms();
        form1                  := t_form('CS Create Version (Hook)', 2,1);
        forms.extend;
        forms(forms.last) := form1;
        hookOutput.forms := forms;
	elsif hookInput.invocationNumber = 1 then  -- Version number specified...
		  if hookInput.answerId = 1 then
            forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);
            v_version := ihook.getColumnValue(rowform,'TO_CNTXT_VER_NR');

            v_table_name := 'ADMIN_ITEM';
            row := t_row();
            
            spReturnAIRow ( v_admin_item.item_id, v_admin_item.ver_nr, row);
            
            /*  Change values of the new version row */
            ihook.setColumnValue(row, 'VER_NR', v_version);
            ihook.setColumnValue(row, 'CREAT_USR_ID', hookInput.userId);
            ihook.setColumnValue(row, 'LST_UPD_USR_ID', hookInput.userId);
            ihook.setColumnValue(row, 'ADMIN_STUS_ID', 65 );
            ihook.setColumnValue(row, 'REGSTR_STUS_ID',9 );
            if (v_admin_item.admin_item_typ_id in (54)) then -- Form needs to Draft NEw
                ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66 );
                ihook.setColumnValue(row, 'REGSTR_STUS_ID','' );
            end if;
            ihook.setColumnValue(row, 'NCI_IDSEQ', '');

            ai_insert_action_rows.extend; ai_insert_action_rows(ai_insert_action_rows.last) := row;

            /* set latest version to 0 for current row */
            row := t_row();
            ihook.setColumnValue(row, 'ITEM_ID', v_admin_item.item_id);
            ihook.setColumnValue(row, 'VER_NR', v_admin_item.ver_nr);
            ihook.setColumnValue(row, 'CURRNT_VER_IND', 0);


            ai_update_action_rows.extend; ai_update_action_rows(ai_update_action_rows.last) := row;

            action := t_actionRowset(ai_insert_action_rows, 'Administered Item (No Sequence)',2, 1, 'insert');
            actions.extend; actions(actions.last) := action;

            action := t_actionRowset(ai_update_action_rows, 'Administered Item (No Sequence)',2, 2 , 'update');
            actions.extend; actions(actions.last) := action;
            
            /* Call sub-type creation function */
            spCreateSubtypeVerNCI(actions, v_admin_item, v_version, v_user_id);

            /* Copy all common children */
            spCreateCommonChildrenNCI(actions, v_admin_item.item_id,v_admin_item.ver_nr, v_admin_item.item_id, v_version);

            /* Copy CSI */
            
/*   Classification Scheme  Item */
        action_rows := t_rows();
        action_rows_csi := t_rows();
        action_rows_upd := t_rows();
        for csi_cur in  (select * from nci_clsfctn_schm_item where
        cs_item_id = v_admin_item.item_id and cs_item_ver_nr = v_admin_item.ver_nr) loop
            row := t_row();
            rowst := t_row();
            nci_11179.spReturnAIRow(csi_cur.item_id, csi_cur.ver_nr, row);
            nci_11179.spReturnSubtypeRow(csi_cur.item_id, csi_cur.ver_nr, 51, rowst);
            
            ihook.setColumnValue(row, 'CURRNT_VER_IND', 0);
            action_rows_upd.extend; action_rows_upd(action_rows_upd.last) := row;
        
            ihook.setColumnValue(row, 'VER_NR', v_version);
            ihook.setColumnValue(rowst, 'VER_NR', v_version);
            ihook.setColumnValue(rowst, 'CS_ITEM_VER_NR', v_version);
            ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
            
            action_rows.extend; action_rows(action_rows.last) := row;
            action_rows_csi.extend; action_rows_csi(action_rows_Csi.last) := rowst;

        end loop;
        action := t_actionRowset(action_rows_upd, 'Administered Item (No Sequence)',2, 24, 'update');
        actions.extend; actions(actions.last) := action;
        
        action := t_actionRowset(action_rows, 'Administered Item (No Sequence)',2, 25, 'insert');
        actions.extend; actions(actions.last) := action;
        action := t_actionRowset(action_rows_csi, 'CSI For Version (Hook)',2, 27, 'insert');
        actions.extend; actions(actions.last) := action;
        
        if (nvl(ihook.getColumnValue (rowform, 'IND_TYP_4'),0) = 1) then
        
        insert into nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id, creat_usr_id, lst_upd_usr_id)
        select rel.p_item_id, v_version, c_item_id, c_item_ver_nr, rel_typ_id, v_user_id, v_user_id
        from nci_admin_item_rel rel, nci_clsfctn_schm_item csi, admin_item ai where rel.rel_typ_id = 65 and
        rel.p_item_id = csi.item_id and rel.p_item_ver_nr = csi.ver_nr and csi.cs_item_id = v_admin_item.item_id and csi.cs_item_ver_nr = v_admin_item.ver_nr
        and ai.item_id = rel.c_item_id and ai.ver_nr = rel.c_item_ver_nr and ai.admin_item_typ_id = 4;
        
        insert into onedata_ra.nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id, creat_usr_id, lst_upd_usr_id)
        select rel.p_item_id, v_version, c_item_id, c_item_ver_nr, rel_typ_id, v_user_id, v_user_id
        from onedata_ra.nci_admin_item_rel rel, onedata_ra.nci_clsfctn_schm_item csi, onedata_ra.admin_item ai where rel.rel_typ_id = 65 and
        rel.p_item_id = csi.item_id and rel.p_item_ver_nr = csi.ver_nr and csi.cs_item_id = v_admin_item.item_id and csi.cs_item_ver_nr = v_admin_item.ver_nr
        and ai.item_id = rel.c_item_id and ai.ver_nr = rel.c_item_ver_nr and ai.admin_item_typ_id = 4;
        --commit;
        end if;
        
        
        if (nvl(ihook.getColumnValue (rowform, 'IND_TYP_3'),0) = 1) then
        insert into nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id, creat_usr_id, lst_upd_usr_id)
        select rel.p_item_id, v_version, c_item_id, c_item_ver_nr, rel_typ_id, v_user_id, v_user_id
        from nci_admin_item_rel rel, nci_clsfctn_schm_item csi, admin_item ai where rel.rel_typ_id = 65 and
        rel.p_item_id = csi.item_id and rel.p_item_ver_nr = csi.ver_nr and csi.cs_item_id = v_admin_item.item_id and csi.cs_item_ver_nr = v_admin_item.ver_nr
        and ai.item_id = rel.c_item_id and ai.ver_nr = rel.c_item_ver_nr and ai.admin_item_typ_id = 3;
        
        insert into onedata_ra.nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id, creat_usr_id, lst_upd_usr_id)
        select rel.p_item_id, v_version, c_item_id, c_item_ver_nr, rel_typ_id, v_user_id, v_user_id
        from onedata_ra.nci_admin_item_rel rel, onedata_ra.nci_clsfctn_schm_item csi, onedata_ra.admin_item ai where rel.rel_typ_id = 65 and
        rel.p_item_id = csi.item_id and rel.p_item_ver_nr = csi.ver_nr and csi.cs_item_id = v_admin_item.item_id and csi.cs_item_ver_nr = v_admin_item.ver_nr
        and ai.item_id = rel.c_item_id and ai.ver_nr = rel.c_item_ver_nr and ai.admin_item_typ_id = 3;
      --  commit;
        end if;
        
        
        if (nvl(ihook.getColumnValue (rowform, 'IND_TYP_2'),0) = 1) then
        insert into nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id, creat_usr_id, lst_upd_usr_id)
        select rel.p_item_id, v_version, c_item_id, c_item_ver_nr, rel_typ_id, v_user_id, v_user_id
        from nci_admin_item_rel rel, nci_clsfctn_schm_item csi, admin_item ai where rel.rel_typ_id = 65 and
        rel.p_item_id = csi.item_id and rel.p_item_ver_nr = csi.ver_nr and csi.cs_item_id = v_admin_item.item_id and csi.cs_item_ver_nr = v_admin_item.ver_nr
        and ai.item_id = rel.c_item_id and ai.ver_nr = rel.c_item_ver_nr and ai.admin_item_typ_id = 2;
        
        insert into onedata_ra.nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id, creat_usr_id, lst_upd_usr_id)
        select rel.p_item_id, v_version, c_item_id, c_item_ver_nr, rel_typ_id, v_user_id, v_user_id
        from onedata_ra.nci_admin_item_rel rel, onedata_ra.nci_clsfctn_schm_item csi, onedata_ra.admin_item ai where rel.rel_typ_id = 65 and
        rel.p_item_id = csi.item_id and rel.p_item_ver_nr = csi.ver_nr and csi.cs_item_id = v_admin_item.item_id and csi.cs_item_ver_nr = v_admin_item.ver_nr
        and ai.item_id = rel.c_item_id and ai.ver_nr = rel.c_item_ver_nr and ai.admin_item_typ_id = 2;
       -- commit;
        end if;
       commit; 
         
        
    end if;


            hookOutput.actions := actions;
            hookOutput.message := 'Version created successfully.';
        end if;
    
    v_data_out := ihook.getHookOutput(hookOutput);

     nci_util.debugHook('GENERAL',v_data_out);

end;

END;
/
