create or replace PACKAGE nci_11179_2 AS
function getGenericForm (v_obj_nm in varchar2) return t_forms ;
procedure spNCICompareDE (v_data_in in clob, v_data_out out clob);
procedure spNCIComparePV (v_data_in in clob, v_data_out out clob);
procedure spNCICompareVD (v_data_in in clob, v_data_out out clob);
procedure spNCICompareDEC (v_data_in in clob, v_data_out out clob);
procedure spShowDataAudit (v_data_in in clob, v_data_out out clob);
procedure spNCICompareVM (v_data_in in clob, v_data_out out clob);
procedure spCreateValueMap (input_rows in t_rows, output_rows in out t_rows, v_src_alt_nm_typ in integer, v_tgt_alt_nm_typ in integer);
procedure spNCIShowVMDependency (v_data_in in clob, v_data_out out clob);
procedure spNCIShowVMDependencyDS (v_data_in in clob, v_data_out out clob, v_mode in varchar2);
procedure spNCIShowVMDependencySubset (v_data_in in clob, v_data_out out clob, v_mode in varchar2);
procedure spNCIShowVMDependencyComb (v_data_in in clob, v_data_out out clob);
procedure spNCIShowPVDependencyComb (v_data_in in clob, v_data_out out clob);
function isUserAuth(v_item_id in number, v_ver_nr in number,v_user_id in varchar2) return boolean;
function isUserAdmin(v_user_id in varchar2) return boolean;
procedure spCheckUserAuth (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure setStdAttr(row in out t_row);
procedure setItemLongNm(row in out t_row, v_id in number);
procedure stdAIValidation(rowai in t_row,  v_item_typ_id in number, v_valid in out boolean, v_err_str out varchar2);
procedure stdCncptRowValidation(rowcncpt in t_row, v_idx in number, v_valid in out boolean, v_err_str in out varchar2);
function getStdShortName (v_item_id in number, v_ver_nr in number) return varchar2;
function getStdDataType (v_data_typ_id in number) return number;
function getLegacyDataType (v_data_typ_id in number) return number;
function getLangId (v_lang_nm in varchar2) return number;
function getCncptStrFromCncpt (v_item_id in number, v_ver_nr in number, v_admin_item_typ_id in number) return varchar2;
function getCncptStrFromForm (rowform in t_row, v_admin_item_typ_id in number, idx in integer) return varchar2;
PROCEDURE spShowVersionDependency (v_data_in in clob, v_data_out out clob, v_admin_item_typ in varchar2);

procedure spComparePVFromCDEMatchCDEList(v_data_in in clob, v_data_out out clob);

function getGenericQuestion (v_quest_str in varchar2, v_cmd_str in varchar2, v_id in integer)  return t_question ;

procedure copyDDEComponents (v_src_item_id in number, v_src_ver_nr in number, v_tgt_item_id in number, v_tgt_ver_nr in number, actions in out t_actions);
function getCollectionId return integer;
function getDloadItemTyp (v_fmt_id in integer) return integer;
procedure spBulkUpdateContext (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spBulkUpdateCSI (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
function isCSParentCSIValid(row in t_row) return boolean;
function isDDE(v_item_id in number, v_ver_nr in number) return boolean;
function isDDEparent(v_item_id in number, v_ver_nr in number) return boolean;
function isDDEchild(v_item_id in number, v_ver_nr in number) return boolean;

procedure spAddAIToCartID (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
procedure spShowCharCount (v_data_in in clob, v_data_out out clob);
procedure updCSIHier (row_ori in t_row ,actions in out t_actions);
procedure spDeleteLog ( v_data_in in clob, v_data_out out clob);
procedure AddItemToCart(v_item_id in number, v_ver_nr in number, v_usr_id in varchar2, v_cart_nm in varchar2, v_retain_ind in number,  rowscart in out t_rows) ;
procedure spDeleteObjKey (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
procedure spStdWIP (v_data_in in clob, v_data_out out clob);
function isDECnmSysGen (v_dec_id in number, v_dec_ver_nr in number, v_oc_id in number, v_oc_ver_nr in number, v_prop_id in number, v_prop_ver_nr in number) return boolean;
function isDECnmSysGenNew (v_in_str varchar2) return boolean;
function getItemTypeID (v_item_id in number, v_ver_nr in number) return number;
function isHookInputSelected (v_hookinput in t_hookinput, v_col_nm in varchar2) return boolean;
END;
/
create or replace PACKAGE BODY nci_11179_2 AS

c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
v_int_cncpt_id  number := 2433736;
v_deflt_cart_nm varchar2(255) := 'Default';

function getGenericForm (v_obj_nm in varchar2) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
   form1                  := t_form(v_obj_nm, 2,1);
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;

PROCEDURE spShowVersionDependency (v_data_in in clob, v_data_out out clob, v_admin_item_typ in varchar2)
as
cnt int;
row t_row;
rows t_rows;
row_cur t_row;
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    rows := t_rows();

if (v_admin_item_typ ='DEC') then

    /* Iterate through all the selected Data Elements */
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row := t_row();
        row_cur := hookInput.originalRowset.Rowset(i);
        ihook.setColumnValue(row,'DE_CONC_ITEM_ID', ihook.getColumnValue(row_cur,'DE_CONC_ITEM_ID'));
        ihook.setColumnValue(row,'DE_CONC_VER_NR', ihook.getColumnValue(row_cur,'DE_CONC_VER_NR'));
        rows.extend; rows(rows.last) := row;
    end loop;

    showRowset := t_showableRowset(rows, 'Data Elements (DEC Dependency)',2, 'unselectable');
  --  showRowset := t_showableRowset(rows, 'Data Element Concepts',2, 'unselectable');
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'Data Element Concept Dependency';
end if;

if (v_admin_item_typ ='VD') then

    /* Iterate through all the selected Data Elements */
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row := t_row();
        row_cur := hookInput.originalRowset.Rowset(i);
        ihook.setColumnValue(row,'VAL_DOM_ITEM_ID', ihook.getColumnValue(row_cur,'VAL_DOM_ITEM_ID'));
        ihook.setColumnValue(row,'VAL_DOM_VER_NR', ihook.getColumnValue(row_cur,'VAL_DOM_VER_NR'));
        rows.extend; rows(rows.last) := row;
    end loop;

    showRowset := t_showableRowset(rows, 'Data Elements (VD Dependency)',2, 'unselectable');
  --  showRowset := t_showableRowset(rows, 'Data Element Concepts',2, 'unselectable');
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'Value Domain Dependency';
end if;

    v_data_out := ihook.getHookOutput(hookOutput);

end;

function getCollectionId return integer is
v_out integer;
begin
select od_seq_DLOAD_HDR.nextval into v_out from dual;
return v_out;
end;

procedure spStdWIP (v_data_in in clob, v_data_out out clob)
as
i int;
begin
raise_application_error(-20000,'Work in Progress');

end;
procedure AddItemToCart(v_item_id in number, v_ver_nr in number, v_usr_id in varchar2, v_cart_nm in varchar2, v_retain_ind in number, rowscart in out t_rows) as
v_temp integer;
row t_row := t_row();
v_found boolean;
k integer;
row_sub t_row;
begin

            v_found := false;
                                    for k in 1..rowscart.count loop
                                        row_sub := rowscart(k);
                                        if ihook.getColumnValue(row_sub, 'ITEM_ID') = v_item_id and ihook.getColumnValue(row_sub, 'VER_NR') = v_ver_nr then
                                        v_found := true;
                                        end if;
                                    end loop;

      if (v_found = false) then                                    
       select count(*) into v_temp from nci_usr_cart where item_id  =v_item_id and ver_nr = v_ver_nr and cntct_secu_id = v_usr_id
      and cart_nm = v_cart_nm;
                if (v_temp = 0) then
                  ihook.setColumnvalue(row, 'ITEM_ID', v_item_id);
                  ihook.setColumnvalue(row, 'VER_NR', v_ver_nr);
                  ihook.setColumnvalue(row, 'CNTCT_SECU_ID', v_usr_id);
                  ihook.setColumnvalue(row, 'CART_NM', v_cart_nm);
                   ihook.setColumnvalue(row, 'RETAIN_IND', v_retain_ind);
                 if(v_usr_id <> 'GUEST') then
                        ihook.setColumnValue(row,'GUEST_USR_NM', 'NONE');
                    else
                    ihook.setColumnValue(row,'GUEST_USR_NM', v_cart_nm);
                    end if;
                     rowscart.extend;
                        rowscart (rowscart.last) := row;
                                           end if;
                    end if;
end;

function isHookInputSelected (v_hookinput in t_hookinput, v_col_nm in varchar2) return boolean
IS
    row_sel t_row;
    isSelected boolean := false;
BEGIN
    row_sel := v_hookinput.selectedRowset.rowset(1);
    if (ihook.getColumnValue(row_sel, v_col_nm) is not null) then
        isSelected := true;
        return isSelected;
    end if;
EXCEPTION
    WHEN OTHERS THEN
        isSelected := false;
        return isSelected;
END;

function getCncptStrFromCncpt (v_item_id in number, v_ver_nr in number, v_admin_item_typ_id in number) return varchar2 is
v_str varchar2(4000) := '';
i integer;
begin
if (v_admin_item_typ_id <> 7) then -- representation term
  for cur in (select cai.item_id, item_nm , item_long_nm , item_desc from admin_item ai, cncpt_admin_item cai
                        where cai.item_id = v_item_id and cai.ver_nr = v_ver_nr and cai.cncpt_item_id = ai.item_id and cai.cncpt_ver_nr = ai.ver_nr
                        order by cai.nci_ord ) loop
                                        v_Str := trim(cur.item_long_nm) || ' ' || trim(v_str);

                         end loop;
end if;
if (v_admin_item_typ_id = 7) then -- representation term
  for cur in (select cai.item_id, item_nm , item_long_nm , item_desc, nci_ord from admin_item ai, cncpt_admin_item cai
                        where cai.item_id = v_item_id and cai.ver_nr = v_ver_nr and cai.cncpt_item_id = ai.item_id and cai.cncpt_ver_nr = ai.ver_nr and nci_ord > 0
                        order by cai.nci_ord ) loop
                                        v_Str := trim(cur.item_long_nm) || ' ' || trim(v_str);

                         end loop;
/* for cur in (select cai.item_id, item_nm , item_long_nm , item_desc, nci_ord from admin_item ai, cncpt_admin_item cai
                        where cai.item_id = v_item_id and cai.ver_nr = v_ver_nr and cai.cncpt_item_id = ai.item_id and cai.cncpt_ver_nr = ai.ver_nr and nci_ord = 0
                        order by cai.nci_ord ) loop
                                        v_Str :=  trim(v_str) || ' ' || trim(cur.item_long_nm);

                         end loop;
*/
end if;
return v_str;
end;


function getCncptStrFromForm (rowform in t_row, v_admin_item_typ_id in number, idx in integer) return varchar2 is
v_str varchar2(4000) := '';
i integer;
begin
  --    raise_application_error(-20000,'HErer;' || ihook.getColumnValue(rowform,'CNCPT_' || idx || '_ITEM_ID_1'));

if (v_admin_item_typ_id <> 7) then -- representation term
for i in 1..10 loop
if (ihook.getColumnValue(rowform,'CNCPT_' || idx || '_ITEM_ID_' || i) is not null) then
             
  for cur in (select item_id, item_nm , item_long_nm , item_desc from admin_item c
                        where c.item_id = ihook.getColumnValue(rowform,'CNCPT_' || idx || '_ITEM_ID_' || i) 
                        and c.ver_nr = ihook.getColumnValue(rowform,'CNCPT_' || idx || '_VER_NR_' || i)
                         ) loop
                                        v_Str := trim(v_str) || ' '|| trim(cur.item_long_nm) ;
                     
                         end loop;
        end if;
                         end loop;
end if;
return v_str;
end;



procedure spDeleteLog ( v_data_in in clob, v_data_out out clob)
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

    row_ori := hookInput.originalRowset.rowset(1);
    
    delete from nci_job_log where log_id = ihook.getColumnValue(row_ori, 'LOG_ID');
    

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;


procedure spDeleteObjKey ( v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
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

    row_ori := hookInput.originalRowset.rowset(1);
    
    delete from obj_Key where obj_key_id = ihook.getColumnValue(row_ori, 'OBJ_KEY_ID');
      delete from onedata_Ra.obj_Key where obj_key_id = ihook.getColumnValue(row_ori, 'OBJ_KEY_ID');
  

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;


function getDloadItemTyp (v_fmt_id in integer) return integer is
begin
case v_fmt_id 

when 105 then return 54;
when 102 then return 54;
when 101 then return 54;
when  109 then return 54;
when  110 then return 54;
when 103 then return 4;
when 104 then return 4;
when 90 then return 4;
when 108 then return 4;
when 106 then return 3;
when 107 then return 2;
when 113 then return 54;
when 115 then return 54;
when 229 then return 58;
when 244 then return 58;
when 245 then return 2;
when 246 then return 3;

else return 4;
end case;

end;

function isDDE(v_item_id in number, v_ver_nr in number) return boolean is 
begin
for cur in (select * from de where nvl(derv_de_ind,0) = 1 ) loop
    return true;
end loop;

return false;
end;

function isDDEparent(v_item_id in number, v_ver_nr in number) return boolean is 
begin
for cur in (select * from nci_admin_item_rel where p_item_id = v_item_id and p_item_ver_nr = v_ver_nr and rel_typ_id = 66) loop
    return true;
end loop;

return false;
end;

function isDDEchild(v_item_id in number, v_ver_nr in number) return boolean is
begin
for cur in (select * from nci_admin_item_rel where c_item_id = v_item_id and c_item_ver_nr = v_ver_nr and rel_typ_id = 66) loop
    return true;
end loop;

return false;
end;

function isCSParentCSIValid(row in t_row) return boolean is
v_item_id  number;
v_ver_nr number(4,2);
begin
 v_item_id := ihook.getColumnValue(row, 'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row, 'VER_NR');


for cur in (select * from vw_clsfctn_schm_item where cs_item_id <>  ihook.getColumnValue(row, 'CS_ITEM_ID') and item_id = nvl(ihook.getColumnValue(row, 'P_ITEM_ID'), -1)) loop
    return false;
end loop;

return true;
end;

procedure updCSIHier (row_ori in t_row ,actions in out t_actions)
as
row t_row;
rows t_rows;
    action           t_actionRowset;
begin

rows := t_rows();
for cur in (select item_id, ver_nr  from nci_clsfctn_schm_item 
    START WITH p_item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and p_item_ver_nr =  ihook.getColumnValue(row_ori, 'VER_NR')
    CONNECT BY PRIOR item_id = p_item_id) loop
    if (cur.item_id <> ihook.getColumnValue(row_ori, 'ITEM_ID')) then
    row := t_row();
    nci_11179.spReturnSubtypeRow(cur.item_id, cur.ver_nr, 51, row);
    ihook.setColumnValue (row, 'CS_ITEM_ID', ihook.getColumnValue(row_ori, 'CS_ITEM_ID'));
    ihook.setColumnValue (row, 'CS_ITEM_VER_NR', ihook.getColumnValue(row_ori, 'CS_ITEM_VER_NR'));
    
 --   if (ihook.getColumnValue(row_ori, 'P_ITEM_ID') <> ihook.getColumnOldValue(row_ori, 'P_ITEM_ID')) then --Parent has changed. Change Full Path

        rows.EXTEND;
            rows (rows.LAST) := row;
    end if;   
    end loop;
    if (rows.count > 0) then
         action :=     t_actionrowset (rows,'CSI',  2,     0,        'update');
            actions.EXTEND;
            actions (actions.LAST) := action;
    end if;
            
            
end;
procedure spShowCharCount (v_data_in in clob, v_data_out out clob)
as
v_lname integer;
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori t_row;
begin
hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset(1);

hookoutput.message := 'Character Count - Long Name: ' || length(ihook.getColumnValue(row_ori, 'ITEM_NM')) || '. Short Name: ' || length(ihook.getColumnValue(row_ori, 'ITEM_LONG_NM'));
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;

procedure copyDDEComponents (v_src_item_id in number, v_src_ver_nr in number, v_tgt_item_id in number, v_tgt_ver_nr in number, actions in out t_actions) as
    action           t_actionRowset;
    action_rows              t_rows := t_rows();

    v_sql        varchar2(4000);
    v_cur        number;
    v_temp        number;
    v_col_val       varchar2(4000);

    v_meta_col_cnt      integer;
    v_meta_desc_tab      dbms_sql.desc_tab;
    v_table_name varchar2(100);
    row t_row;

begin

     v_table_name := 'NCI_ADMIN_ITEM_REL';
    action_rows := t_rows();

    v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);
      for de_cur in (select P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID from NCI_ADMIN_ITEM_REL where
        P_item_id = v_src_item_id and p_ITEM_ver_nr = v_src_ver_nr and rel_typ_id = 66 and nvl(fld_Delete,0) = 0) loop

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
         ihook.setColumnValue(row, 'P_ITEM_ID', v_tgt_item_id);

            ihook.setColumnValue(row, 'P_ITEM_VER_NR', v_tgt_ver_nr);
            action_rows.extend; action_rows(action_rows.last) := row;
        end loop;

        if (action_rows.count> 0) then
        action := t_actionRowset(action_rows, 'Derived CDE Component (Data Element CO)',2, 14, 'insert');
        actions.extend; actions(actions.last) := action;
        end if;



end;


procedure spAddAIToCartID (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
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
  v_cart_nm varchar2(255);
  v_card boolean;

begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    v_card := isHookInputSelected(hookinput, 'CART_NM');
    if v_card then
        row_ori := hookInput.originalRowset.rowset(1);
        v_cart_nm := nvl(ihook.getColumnValue(row_ori, 'CART_NM'),v_deflt_cart_nm);
    else
        v_cart_nm := v_deflt_cart_nm;
    end if;
    if (hookinput.invocationnumber = 0) then   -- First invocation
         forms                  := t_forms();
        form1                  := t_form('Add Item to Collection (Hook)', 2,1);
        forms.extend;    forms(forms.last) := form1;
        hookoutput.forms := forms;
       	 hookOutput.question := nci_dload.getCreateQuestionUsingID;
	end if;

    if hookInput.invocationNumber = 1  then  -- Second invocation

        forms              := hookInput.forms;
        form1              := forms(1);
        row_sel := form1.rowset.rowset(1);
        v_str := trim(ihook.getColumnValue(row_sel, 'VM_DESC_TXT'));
             cnt := nci_11179.getwordcount(v_str);

          rowscart := t_rows();
 --raise_application_error(-20000, ihook.getColumnValue(row_ori, 'CART_NM'));
         for i in  1..cnt loop
                        v_item_id := nci_11179.getWord(v_str, i, cnt);
--        for cur in (select * from admin_item where item_id = v_item_id and currnt_ver_ind = 1 and admin_item_typ_id in (4,52,54, 2, 3) and (item_id, ver_nr) not in
--        (select item_id, ver_nr from nci_usr_cart  where cntct_secu_id = v_usr_id)) loop
        
        --jira 4256: allow users to add items to default cart when already in named cart
        for cur in (select * from admin_item where item_id = v_item_id and currnt_ver_ind = 1 and admin_item_typ_id in (4,52,54, 2, 3) and (item_id, ver_nr) not in
        (select item_id, ver_nr from nci_usr_cart  where cntct_secu_id = v_usr_id and upper(cart_nm) = upper(v_deflt_cart_nm))) loop

        row := t_row();
            ihook.setColumnValue(row, 'ITEM_ID', cur.item_id);
            ihook.setColumnValue(row, 'VER_NR', cur.ver_nr);
           ihook.setColumnValue(row,'CNTCT_SECU_ID', v_usr_id);
            --   ihook.setColumnValue(row,'CNTCT_SECU_ID', 'DWARZEL');
            ihook.setColumnValue(row,'GUEST_USR_NM', 'NONE');
            ihook.setColumnValue(row,'CART_NM', v_cart_nm);
                	rowscart.extend;
                    rowscart (rowscart.last) := row;


 end loop;
end loop;
        -- If Item needs to be added.

            /*  If item not already in cart */
            if (rowscart.count  > 0) then
                action := t_actionrowset(rowscart, 'User Cart', 2,0,'insert');
                actions.extend;
                actions(actions.last) := action;
            end if;

        if (actions.count > 0) then
            hookoutput.actions := actions;
        end if;
             hookoutput.message := 'Number of items added to cart: ' || rowscart.count;
   end if;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spBulkUpdateContext (v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
as
 hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    rowform t_row;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
forms     t_forms;
v_itemid     integer;
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
  v_item_typ  integer;
 v_err_str  varchar2(4000) := '';
  form1 t_form;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;


  if(hookinput.originalrowset.rowset.count > 0) then
  raise_application_error(-20000, 'Bulk change applies to to all items in the caDSR and not the selected/filtered items. Please deselect items and re-select the command.');
  end if;

    if hookInput.invocationNumber = 0 then

    forms                  := t_forms();
    form1                  := t_form('Context Bulk Change (Hook)', 2,1);
    forms.extend;    forms(forms.last) := form1;
  hookoutput.forms := forms;
       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Reassign');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Reassign Item Context', answers);
       	 hookOutput.question := question;

	end if;

    if hookInput.invocationNumber = 1  then
            rows :=         t_rows();
             forms              := hookInput.forms;
           form1              := forms(1);
      rowform := form1.rowset.rowset(1);

    /*    if (nvl(ihook.getColumnValue(rowform,'IND_ALL_TYPES'),0) = 1) then
            update admin_item set cntxt_item_id = ihook.getColumnValue(rowform,'TO_CNTXT_ITEM_ID'), cntxt_ver_nr = ihook.getColumnValue(rowform,'TO_CNTXT_VER_NR')
            where cntxt_item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(rowform,'CNTXT_VER_NR') and
            (ITEM_LONG_NM, VER_NR, ADMIN_ITEM_TYP_ID) not in (select ITEM_LONG_NM, VER_NR, ADMIN_ITEM_TYP_ID from ADMIN_ITEM where 
            cntxt_item_id = ihook.getColumnValue(rowform,'TO_CNTXT_ITEM_ID') and cntxt_ver_nr =  ihook.getColumnValue(rowform,'TO_CNTXT_VER_NR'));
            commit;
            
            select substr(listagg(item_id,';'), 1, 4000) into v_err_str from admin_item where cntxt_item_id = ihook.getColumnValue(rowform,'TO_CNTXT_ITEM_ID') and cntxt_ver_nr =  ihook.getColumnValue(rowform,'TO_CNTXT_VER_NR');
      */      
    --    else
        for i in 1..60 loop
        if (nvl(ihook.getColumnValue(rowform,'IND_TYP_' || i),0) = 1 or nvl(ihook.getColumnValue(rowform,'IND_ALL_TYPES'),0) = 1) then
        update admin_item set cntxt_item_id = ihook.getColumnValue(rowform,'TO_CNTXT_ITEM_ID'), cntxt_ver_nr = ihook.getColumnValue(rowform,'TO_CNTXT_VER_NR')
            where cntxt_item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and cntxt_ver_nr =  ihook.getColumnValue(rowform,'CNTXT_VER_NR') and admin_item_typ_id = i
            and (ITEM_LONG_NM, VER_NR) not in (select ITEM_LONG_NM, VER_NR from ADMIN_ITEM where admin_item_typ_id = i and
            cntxt_item_id = ihook.getColumnValue(rowform,'TO_CNTXT_ITEM_ID') and cntxt_ver_nr =  ihook.getColumnValue(rowform,'TO_CNTXT_VER_NR'));
            commit;
          select substr(v_err_str || ';' || listagg(item_id,';'), 1, 4000) into v_err_str from admin_item 
       where cntxt_item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and cntxt_ver_nr =  ihook.getColumnValue(rowform,'CNTXT_VER_NR') and admin_item_typ_id = i;
    -- select listagg(item_id,';') into v_err_str from admin_item 
     --   where cntxt_item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and cntxt_ver_nr =  ihook.getColumnValue(rowform,'CNTXT_VER_NR') and admin_item_typ_id = i;
    -- raise_application_error(-20000,v_err_str);
          end if;
 
        end loop;
    --    end if;

        if (nvl(ihook.getColumnValue(rowform,'IND_ALL_TYPES'),0) = 1 or nvl(ihook.getColumnValue(rowform,'IND_ALT_NMS'),0) = 1 ) then
              update alt_nms set cntxt_item_id = ihook.getColumnValue(rowform,'TO_CNTXT_ITEM_ID'), cntxt_ver_nr = ihook.getColumnValue(rowform,'TO_CNTXT_VER_NR')
            where cntxt_item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and cntxt_ver_nr =  ihook.getColumnValue(rowform,'CNTXT_VER_NR') ;

        end if;
            if (nvl(ihook.getColumnValue(rowform,'IND_ALL_TYPES'),0) = 1 or nvl(ihook.getColumnValue(rowform,'IND_ALT_DEF'),0) = 1 ) then
              update alt_def set cntxt_item_id = ihook.getColumnValue(rowform,'TO_CNTXT_ITEM_ID'), cntxt_ver_nr = ihook.getColumnValue(rowform,'TO_CNTXT_VER_NR')
            where cntxt_item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and cntxt_ver_nr =  ihook.getColumnValue(rowform,'CNTXT_VER_NR') ;

        end if;
              if (nvl(ihook.getColumnValue(rowform,'IND_ALL_TYPES'),0) = 1 or nvl(ihook.getColumnValue(rowform,'IND_REF_DOC'),0) = 1 ) then
              update ref set nci_cntxt_item_id = ihook.getColumnValue(rowform,'TO_CNTXT_ITEM_ID'), nci_cntxt_ver_nr = ihook.getColumnValue(rowform,'TO_CNTXT_VER_NR')
            where nci_cntxt_item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and nci_cntxt_ver_nr =  ihook.getColumnValue(rowform,'CNTXT_VER_NR') ;

        end if;


if (v_err_str is null) then
        hookoutput.message := 'Context reassigned. ';
    else
        hookoutput.message := 'Item not reassigned due to short name duplication: ' || substr(v_err_str,2);
    end if;  
    end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 -- nci_util.debugHook('GENERAL',v_data_out);

END;


procedure spBulkUpdateCSI (v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
as
 hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    rowform t_row;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
forms     t_forms;
v_itemid     integer;
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
  v_item_typ  integer;
v_csi_to_item_id number;
v_csi_to_ver_nr number(4,2);
  form1 t_form;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  if(hookinput.originalrowset.rowset.count > 0) then
  raise_application_error(-20000, 'Bulk change applies to to all items in the caDSR and not the selected/filtered items. Please deselect items and re-select the command.');
  end if;

    if hookInput.invocationNumber = 0 then

    forms                  := t_forms();
    form1                  := t_form('CSI Bulk Change (Hook)', 2,1);
    forms.extend;    forms(forms.last) := form1;
  hookoutput.forms := forms;
       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Reclassify');
  	   	 answers.extend; answers(answers.last) := answer;
  	     answer := t_answer(2, 2, 'Unclassify');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Reclassify or Unclassify', answers);
       	 hookOutput.question := question;

	end if;

    if hookInput.invocationNumber = 1  then
            rows :=         t_rows();
             forms              := hookInput.forms;
             form1              := forms(1);
             rowform := form1.rowset.rowset(1);
            
            if (hookinput.answerid = 1 and ihook.getcolumnValue(rowform, 'TO_CNTXT_ITEM_ID') is null) then
                hookoutput.message := 'Please specify Reclassification To CSI';
                V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
                return;
            end if;
        
        v_csi_to_item_id := ihook.getColumnValue(rowform, 'TO_CNTXT_ITEM_ID');
        v_csi_to_ver_nr := ihook.getColumnValue(rowform, 'TO_CNTXT_VER_NR');
        
        if (hookinput.answerId = 1) then
        for cur in (select * from nci_admin_item_rel where rel_typ_id = 65 and  p_item_id = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID') and p_item_ver_nr =  ihook.getColumnValue(rowform, 'CNTXT_VER_NR')) loop
            select count(*) into v_temp from nci_admin_item_rel where rel_typ_id = 65 and p_item_id = v_csi_to_item_id and p_item_ver_nr = v_csi_to_ver_nr and 
            c_item_id = cur.c_item_id and c_item_ver_nr = cur.c_item_ver_nr;
            if (v_temp = 0) then
                insert into nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id) values
                (v_csi_to_item_id, v_csi_to_ver_nr, cur.c_item_id, cur.c_item_ver_nr, 65);
                insert into onedata_ra.nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id) values
                (v_csi_to_item_id, v_csi_to_ver_nr, cur.c_item_id, cur.c_item_ver_nr, 65);
                
            end if;
            end loop;
            commit;
         for cur in (select * from NCI_CSI_ALT_DEFNMS  where NCI_PUB_ID = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID') and NCI_VER_NR =  ihook.getColumnValue(rowform, 'CNTXT_VER_NR')) loop
            select count(*) into v_temp from NCI_CSI_ALT_DEFNMS where nmDef_id = cur.nmdef_id and typ_nm = cur.typ_nm and nci_pub_id = v_csi_to_item_id and nci_ver_nr = v_csi_to_ver_nr ;
            if (v_temp = 0) then
                insert into NCI_CSI_ALT_DEFNMS  (NMDEF_ID, TYP_NM, NCI_PUB_ID, NCI_VER_NR) values
                (cur.NMDEF_ID, cur.TYP_NM, v_csi_to_item_id, v_csi_to_ver_nr);
                insert into onedata_ra.NCI_CSI_ALT_DEFNMS  (NMDEF_ID, TYP_NM, NCI_PUB_ID, NCI_VER_NR) values
                (cur.NMDEF_ID, cur.TYP_NM, v_csi_to_item_id, v_csi_to_ver_nr);
                
            end if;
            end loop;
            commit;
        end if;
        
        delete from nci_admin_item_rel where rel_typ_id = 65 and  p_item_id = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID') and p_item_ver_nr =  ihook.getColumnValue(rowform, 'CNTXT_VER_NR');
        delete from onedata_ra.nci_admin_item_rel where rel_typ_id = 65 and  p_item_id = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID') and p_item_ver_nr =  ihook.getColumnValue(rowform, 'CNTXT_VER_NR');
        commit;
            
    
       delete from NCI_CSI_ALT_DEFNMS  where       NCI_PUB_ID = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID') and NCI_VER_NR =  ihook.getColumnValue(rowform, 'CNTXT_VER_NR');
       delete from onedata_ra.NCI_CSI_ALT_DEFNMS  where       NCI_PUB_ID = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID') and NCI_VER_NR =  ihook.getColumnValue(rowform, 'CNTXT_VER_NR');
       commit;

        if hookinput.answerId = 1 then
               hookoutput.message := 'Reclassified successfully.';
 
        elsif hookinput.answerId = 2 then
               hookoutput.message := 'Unclassifies successfully.';
 
        end if;
    end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 -- nci_util.debugHook('GENERAL',v_data_out);

END;

function getStdDataType (v_data_typ_id in number) return number
is
v_temp number;
begin
/*
select nvl(dttype_id,0) into v_temp from data_typ where nci_dttype_typ_id = 2 and
upper(dttype_nm) in ( select upper(nci_dttype_map) from data_typ where nci_dttype_typ_id = 1 and dttype_id = v_data_typ_id);*/

select nvl(dttype_id,0) into v_temp from data_typ where nci_dttype_typ_id = 2 and
dttype_id in ( select nci_dttype_map_id from data_typ where nci_dttype_typ_id = 1 and dttype_id = v_data_typ_id);

return v_temp;
end;


function getLegacyDataType (v_data_typ_id in number) return number
is
v_temp number;
begin
/*
select nvl(dttype_id,0) into v_temp from data_typ where nci_dttype_typ_id = 2 and
upper(dttype_nm) in ( select upper(nci_dttype_map) from data_typ where nci_dttype_typ_id = 1 and dttype_id = v_data_typ_id);*/

select nvl(nci_dflt_legcy_id,0) into v_temp from data_typ where nci_dttype_typ_id = 2 and dttype_id = v_data_typ_id;

return v_temp;
end;

function getLangId (v_lang_nm in varchar2) return number
is
v_temp number;
begin

v_temp := 1000;
for cur in (Select * from LANG where upper(LANG_NM) = upper(v_lang_nm)) loop
v_temp := cur.lang_id;
end loop;

return v_temp;
end;

procedure setItemLongNm(row in out t_row, v_id in number) as
begin
 ihook.setColumnValue(row,'ITEM_LONG_NM', v_id || c_ver_suffix);
end;

function getStdShortName (v_item_id in number, v_ver_nr in number) return varchar2
is
begin
return  v_item_id ||  'v' || trim(to_char(v_ver_nr, '9999.99'));
end;

function getItemTypeID (v_item_id in number, v_ver_nr in number) return number
is
v_typ_id number;
begin 
select admin_item_typ_id into v_typ_id from admin_item where item_id = v_item_id and ver_nr = v_ver_nr;
return v_typ_id;
end;

procedure stdAIValidation(rowai in t_row,  v_item_typ_id in number, v_valid in out boolean, v_err_str out varchar2) as
v_cntxt_id  number;
v_cntxt_ver_nr number;
begin

for cur in (select * from vw_admin_stus where stus_id = nvl(ihook.getColumnValue(rowai, 'ADMIN_STUS_ID'),-1) and upper(stus_nm) like '%RETIRED%'
and ihook.getColumnValue(rowai, 'UNTL_DT') is null) loop
    v_valid := false;
    v_err_str := 'Cannot retire an Administered Item without expiration date.';
    return;
end loop;
for cur in (select * from vw_admin_stus where ihook.getColumnValue(rowai, 'UNTL_DT') is not null and ihook.getColumnValue(rowai, 'UNTL_DT') < nvl(ihook.getColumnValue(rowai, 'EFF_DT'), sysdate) ) loop
    v_valid := false;
    v_err_str := 'Expiration date has to be the same or greater than Effective date.';
    return;
end loop;

for cur in (select ai.item_id item_id from admin_item ai
            where
            trim(ai.ITEM_LONG_NM)=trim(ihook.getColumnValue(rowai,'ITEM_LONG_NM'))
        --    and  ai.ver_nr =  ihook.getColumnValue(rowai, 'VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR')
            and ai.item_id <>  nvl(ihook.getColumnValue(rowai, 'ITEM_ID'),0)
            and ai.admin_item_typ_id = v_item_typ_id
            and ihook.getColumnValue(rowai,'ITEM_LONG_NM') <> v_dflt_txt)
            loop
                v_valid := false;
                v_err_str := 'Duplicate found based on context/short name: ' || cur.item_id || chr(13);
                return;
            end loop;

end;


procedure stdCncptRowValidation(rowcncpt in t_row,  v_idx in number, v_valid in out boolean, v_err_str in out varchar2) as
i  integer;

begin
for i in 1..10 loop
    if (ihook.getColumnValue(rowcncpt, 'CNCPT_' || v_idx  ||'_ITEM_ID_' || i) = v_int_cncpt_id and
    ihook.getColumnValue(rowcncpt,'CNCPT_INT_' || v_idx || '_' || i) is null) then
        v_valid := false;
    v_err_str := v_err_str || ' ' || 'Value for Integer Concept missing.';
    end if;
end loop;
end;

procedure setStdAttr(row in out t_row)
as
begin
       ihook.setColumnValue(row,'ADMIN_STUS_ID',66 );
               ihook.setColumnValue(row,'REGSTR_STUS_ID',9 );
       ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
       ihook.setColumnValue(row, 'VER_NR', 1);
     ihook.setColumnValue(row, 'EFF_DT', to_char(sysdate, DEFAULT_TS_FORMAT));
ihook.setColumnValue(row, 'UNTL_DT', '');
    -- ihook.setColumnValue(row, 'ADMIN_NOTES', '2001/1/1');



end;

function isUserAuth(v_item_id in number, v_ver_nr in number,v_user_id in varchar2) return boolean  iS
v_auth boolean := false;
v_temp integer;
v_temp1 integer;
begin
select count(*) into v_temp from  onedata_md.vw_usr_row_filter  v, admin_item ai
        where ( ( v.CNTXT_ITEM_ID = ai.CNTXT_ITEM_ID and v.cntxt_VER_NR  = ai.CNTXT_VER_NR) or v.CNTXT_ITEM_ID = 100) and upper(v.USR_ID) = upper(v_user_id) and v.ACTION_TYP = 'I'
        and ai.item_id =v_item_id and ai.ver_nr = v_ver_nr;

-- If the item id sent are context item id and version number
select count(*) into v_temp1 from  onedata_md.vw_usr_row_filter  v
        where  ( v.CNTXT_ITEM_ID = v_item_id and v.cntxt_VER_NR  = v_ver_nr) and upper(v.USR_ID) = upper(v_user_id) and v.ACTION_TYP = 'I';

if (v_temp = 0 and v_temp1 = 0) then return false; else return true; end if;
end;

function isUserAdmin(v_user_id in varchar2) return boolean  iS
v_auth boolean := false;
v_temp integer;
v_temp1 integer;
begin
select count(*) into v_temp from  onedata_md.vw_usr_admin where usr_id = v_user_id;

if (v_temp = 0) then return false; else return true; end if;
end;

procedure spCheckUserAuth (v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;

    row_ori t_row;
    row_cur t_row;
    v_item_id number;
    v_ver_nr number(4,2);
    is_form boolean;
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.rowset(1);

    if (hookinput.originalRowset.tablename  in ( 'ALT_DEF', 'ALT_NMS', 'REF')) then
        v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    elsif (hookinput.originalRowset.tablename = 'NCI_ADMIN_ITEM_REL' and ihook.getColumnValue(row_ori,'REL_TYP_ID') = 60) then   ---  protocol
        v_item_id := ihook.getColumnValue(row_ori, 'P_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');
   elsif (hookinput.originalRowset.tablename = 'NCI_ADMIN_ITEM_REL' and ihook.getColumnValue(row_ori,'REL_TYP_ID') = 65) then   ---  classification
       select cs_item_id, cs_item_ver_nr into v_item_id, v_ver_nr from nci_clsfctn_schm_item where item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and
       ver_nr= ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');
--raise_application_error(-20000, 'Here');
    elsif hookinput.originalRowset.tablename = 'PERM_VAL' then
        v_item_id := ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR');
    elsif hookinput.originalRowset.tablename = 'REF_DOC' then
        select nci_cntxt_item_id, nci_cntxt_ver_nr into v_item_id, v_ver_nr from ref where
        ref_id = ihook.getColumnValue(row_ori, 'NCI_REF_ID');
    elsif   (hookinput.originalRowset.tablename = 'NCI_ADMIN_ITEM_REL' and ihook.getColumnValue(row_ori,'REL_TYP_ID') = 61 ) then   --- Module
        v_item_id := ihook.getColumnValue(row_ori,'P_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori,'P_ITEM_VER_NR');
    elsif   (hookinput.originalRowset.tablename = 'NCI_ADMIN_ITEM_REL_ALT_KEY') then -- Question
        select p_item_id, p_item_ver_nr into v_item_id, v_ver_nr from nci_admin_item_rel where rel_typ_id = 61 and
        c_item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and c_item_ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');
    elsif   (hookinput.originalRowset.tablename = 'NCI_QUEST_VV_REP') then -- Question Repetision
        select frm_item_id, frm_ver_nr into v_item_id, v_ver_nr from vw_nci_module_de where
        nci_pub_id = ihook.getColumnValue(row_ori, 'QUEST_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'QUEST_VER_NR');
    elsif   (hookinput.originalRowset.tablename = 'NCI_QUEST_VALID_VALUE') then -- Question Repetision
        select aim.p_item_id, aim.p_item_ver_nr into v_item_id, v_ver_nr from nci_admin_item_rel_alt_key air,  nci_admin_item_rel aim where
                air.nci_pub_id = ihook.getColumnValue(row_ori, 'Q_PUB_ID') and air.nci_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR')
                and air.p_item_id = aim.c_item_id and air.p_item_ver_nr = aim.c_item_ver_nr;
   end if;

if (v_item_id is not null) then
     if (isUserAuth(v_item_id, v_ver_nr, v_user_id) = false) then
    -- raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ' || v_item_id || ' ' || v_user_id);
    raise_application_error(-20000, 'You are not authorized to insert/update or delete in this Context. ' );
        return;
    end if;
end if;
  /*  if (hookinput.originalRowset.tablename = 'NCI_ADMIN_ITEM_REL' and ihook.getColumnValue(row_ori,'REL_TYP_ID') = 60) then   ---  checked form before. Now check Protocol
        v_item_id := ihook.getColumnValue(row_ori, 'P_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');

        if (isUserAuth(v_item_id, v_ver_nr, v_user_id) = false) then
            raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
            return;
        end if;
    end if;
*/
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;

/*  Pop-up compare DE for selected rows */
procedure spNCICompareDE (v_data_in in clob, v_data_out out clob)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;

    v_found      boolean;

    v_val_mean_desc    val_mean.val_mean_desc%type;
    v_perm_val_nm    perm_val.perm_val_nm%type;
    v_item_id		 number;
    v_ver_nr		 number;
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    rows := t_rows();

    /* Iterate through all the selected Data Elements */
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row := t_row();
        row_cur := hookInput.originalRowset.Rowset(i);
        ihook.setColumnValue(row,'ITEM_ID', ihook.getColumnValue(row_cur,'ITEM_ID'));
        ihook.setColumnValue(row,'VER_NR', ihook.getColumnValue(row_cur,'VER_NR'));
        rows.extend; rows(rows.last) := row;
    end loop;

    showRowset := t_showableRowset(rows, 'NCI Data Element Details (for Compare)',2, 'unselectable');
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'Data Element Compare';
    v_data_out := ihook.getHookOutput(hookOutput);
end;



/*  Pop-up compare PV for selected CDEs */
procedure spNCIComparePV (v_data_in in clob, v_data_out out clob)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;

    v_found      boolean;
    v_admin_item_typ integer;
    v_item_id		 number;
    v_ver_nr		 number;
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    rows := t_rows();
       row_cur := hookInput.originalRowset.Rowset(1);
 
    v_admin_item_typ := ihook.getColumnValue(row_cur, 'ADMIN_ITEM_TYP_ID');
    /* Iterate through all the selected Data Elements */
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row := t_row();
        row_cur := hookInput.originalRowset.Rowset(i);
        ihook.setColumnValue(row,'DE_ITEM_ID', ihook.getColumnValue(row_cur,'ITEM_ID'));
        ihook.setColumnValue(row,'DE_VER_NR', ihook.getColumnValue(row_cur,'VER_NR'));
        ihook.setColumnValue(row,'VAL_DOM_ITEM_ID', ihook.getColumnValue(row_cur,'ITEM_ID'));
        ihook.setColumnValue(row,'VAL_DOM_VER_NR', ihook.getColumnValue(row_cur,'VER_NR'));
        rows.extend; rows(rows.last) := row;
    end loop;

if (v_admin_item_typ = 4) then
    showRowset := t_showableRowset(rows, 'NCI DE Permissible Values (for Compare)',2, 'unselectable');
else
    showRowset := t_showableRowset(rows, 'NCI VD Permissible Values (for Compare)',2, 'unselectable');
end if;
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'Permissible Values by CDE';
    v_data_out := ihook.getHookOutput(hookOutput);
end;


/*  Pop-up compare DE for selected rows */
procedure spNCICompareVM (v_data_in in clob, v_data_out out clob)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;

    v_found      boolean;

    v_val_mean_desc    val_mean.val_mean_desc%type;
    v_perm_val_nm    perm_val.perm_val_nm%type;
    v_item_id		 number;
    v_ver_nr		 number;
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    rows := t_rows();

    /* Iterate through all the selected Data Elements */
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row := t_row();
        row_cur := hookInput.originalRowset.Rowset(i);
        ihook.setColumnValue(row,'ITEM_ID', ihook.getColumnValue(row_cur,'ITEM_ID'));
        ihook.setColumnValue(row,'VER_NR', ihook.getColumnValue(row_cur,'VER_NR'));
        rows.extend; rows(rows.last) := row;
    end loop;

    showRowset := t_showableRowset(rows, 'Value Meanings (NCI)',2, 'unselectable');
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'Value Meaning Compare';
    v_data_out := ihook.getHookOutput(hookOutput);
end;


/*  Pop-up compare DE for selected rows */
procedure spShowDataAudit (v_data_in in clob, v_data_out out clob)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;

    v_found      boolean;

    v_val_mean_desc    val_mean.val_mean_desc%type;
    v_perm_val_nm    perm_val.perm_val_nm%type;
    v_item_id		 number;
    v_ver_nr		 number;
    v_item_typ integer;
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    rows := t_rows();
    row_cur := hookInput.originalRowset.Rowset(1);
    
    /* Iterate through all the selected Data Elements */
         row := t_row();
        ihook.setColumnValue(row,'ITEM_ID', ihook.getColumnValue(row_cur,'ITEM_ID'));
        ihook.setColumnValue(row,'VER_NR', ihook.getColumnValue(row_cur,'VER_NR'));
        rows.extend; rows(rows.last) := row;
   select admin_item_typ_id into v_item_typ from admin_item where item_id =  ihook.getColumnValue(row_cur,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_cur,'VER_NR');
   if (v_item_typ = 54) then
    showRowset := t_showableRowset(rows, 'Form Data Audit',2, 'unselectable');
   else
    showRowset := t_showableRowset(rows, 'Data Audit',2, 'unselectable');
   end if;
   
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'Data Audit';
    v_data_out := ihook.getHookOutput(hookOutput);
end;


/*  Pop-up compare DE for selected rows */
procedure spNCICompareDEC (v_data_in in clob, v_data_out out clob)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;

    v_found      boolean;

    v_val_mean_desc    val_mean.val_mean_desc%type;
    v_perm_val_nm    perm_val.perm_val_nm%type;
    v_item_id		 number;
    v_ver_nr		 number;
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    rows := t_rows();

    /* Iterate through all the selected Data Elements */
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row := t_row();
        row_cur := hookInput.originalRowset.Rowset(i);
        ihook.setColumnValue(row,'ITEM_ID', ihook.getColumnValue(row_cur,'ITEM_ID'));
        ihook.setColumnValue(row,'VER_NR', ihook.getColumnValue(row_cur,'VER_NR'));
        rows.extend; rows(rows.last) := row;
    end loop;

    showRowset := t_showableRowset(rows, 'Data Element Concepts  (For Compare)',2, 'unselectable');
  --  showRowset := t_showableRowset(rows, 'Data Element Concepts',2, 'unselectable');
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'Data Element Concept Compare';
    v_data_out := ihook.getHookOutput(hookOutput);
end;

/*  Pop-up compare VD for selected rows */
procedure spNCICompareVD (v_data_in in clob, v_data_out out clob)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;


    v_found      boolean;
    v_item_id		 number;
    v_ver_nr		 number;
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    rows := t_rows();

    /* Iterate through all the selected VALUE Domains */
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row := t_row();
        row_cur := hookInput.originalRowset.Rowset(i);
        if (ihook.getColumnValue(row_cur,'ADMIN_ITEM_TYP_ID') = 3) then
            ihook.setColumnValue(row,'ITEM_ID', ihook.getColumnValue(row_cur,'ITEM_ID'));
            ihook.setColumnValue(row,'VER_NR', ihook.getColumnValue(row_cur,'VER_NR'));
            rows.extend; rows(rows.last) := row;
        end if;
    end loop;

if (rows.count > 0) then
    showRowset := t_showableRowset(rows, 'Compare Value Domains',2, 'unselectable');
    hookOutput.showRowset := showRowset;
    hookOutput.message := 'Value Domain Compare';
else
    hookOutput.message := 'Select Value Domains for this command.';

end if;

    v_data_out := ihook.getHookOutput(hookOutput);
end;


/* PV Dependency called from NCI Data Elements */
procedure spNCIShowVMDependency (v_data_in in clob, v_data_out out clob)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;

    v_admin_item                admin_item%rowtype;
    v_tab_admin_item            tab_admin_item_pk;

    v_found      boolean;

    type t_val_mean_cd is table of nci_admin_item_ext.cncpt_concat%type;
    type t_val_mean_nm is table of nci_admin_item_ext.cncpt_concat_nm%type;

    v_tab_val_mean_cd  t_val_mean_cd := t_val_mean_cd();
    v_tab_val_mean_nm  t_val_mean_nm := t_val_mean_nm();

    v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

    type      t_admin_item_nm is table of admin_item.item_nm%type;
    v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();

    v_val_mean_desc    val_mean.val_mean_desc%type;
    v_perm_val_nm    perm_val.perm_val_nm%type;
    v_item_id		 number;
    v_ver_nr		 number;
    vd_id_nm     varchar2(300);
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

-- saving all unique val_mean_ids from submitted admin items into v_tab_val_mean_id
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row_cur := hookInput.originalRowset.Rowset(i);

        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm from perm_val pv, nci_admin_item_ext ext
        where val_dom_item_id=ihook.getColumnValue(row_cur,'VAL_DOM_ITEM_ID')
        and val_dom_ver_nr=ihook.getColumnValue(row_cur,'VAL_DOM_VER_NR') and pv.fld_delete=0 and
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr) loop
            v_found := false;
            for j in 1..v_tab_val_mean_cd.count loop
                    v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
            end loop;

            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
                v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.cncpt_concat_nm;
            end if;
    end loop;

     v_tab_admin_item_nm.extend();
     select ai.item_id || '-' || ai.item_nm into  vd_id_nm from admin_item ai, de where ai.item_id = de.val_dom_item_id and ai.ver_nr = de.val_dom_ver_nr and de.item_id =ihook.getColumnValue(row_cur,'ITEM_ID')
      and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR');

      v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'CDE:' || ihook.getColumnValue(row_cur,'ITEM_ID') --|| 'v' || ihook.getColumnValue(row_cur,'VER_NR') 
      || '-' || ihook.getColumnValue(row_cur,'ITEM_NM') || chr(13) || 'VD:' ||  vd_id_nm ;
    end loop;

    -- populating val means/perm vals
    rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop
        row := t_row();
        ihook.setColumnValue(row, 'Concept Code', v_tab_val_mean_cd(i));
        ihook.setColumnValue(row, 'Concept Name', nci_11179.replaceChar(v_tab_val_mean_nm(i)));

        for j in 1 .. hookInput.originalRowset.Rowset.count loop
            row_cur := hookInput.originalRowset.Rowset(j);
            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a, nci_admin_item_Ext ext
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and val_dom_item_id=ihook.getColumnValue(row_cur,'VAL_DOM_ITEM_ID')
            and val_dom_ver_nr=ihook.getColumnValue(row_cur,'VAL_DOM_VER_NR') and a.fld_delete=0) loop
                v_perm_val_nm := rec.perm_val_nm || ' ' || v_perm_val_nm;
            end loop;
            ihook.setColumnValue(row, v_tab_admin_item_nm(j), nci_11179.replaceChar(v_perm_val_nm));
        end loop;
        rows.extend; rows(rows.last) := row;
    end loop;

    showRowset := t_showableRowset(rows, 'Permissible Value Comparison',4, 'unselectable');
    
    hookOutput.showRowset := showRowset;

    v_data_out := ihook.getHookOutput(hookOutput);

end;

/*  Show PV comparison from ADministereds Item */

procedure spNCIShowVMDependencyDS (v_data_in in clob, v_data_out out clob, v_mode in varchar2)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;
    row_ori  t_row;
    v_hdr_id number;

    v_admin_item                admin_item%rowtype;
    v_tab_admin_item            tab_admin_item_pk;

    v_found      boolean;
    type t_val_mean_cd is table of nci_admin_item_ext.cncpt_concat%type;
    type t_val_mean_nm is table of nci_admin_item_ext.cncpt_concat_nm%type;

    v_tab_val_mean_cd  t_val_mean_cd := t_val_mean_cd();
    v_tab_val_mean_nm  t_val_mean_nm := t_val_mean_nm();

    v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

    type      t_admin_item_nm is table of admin_item.item_nm%type;
    v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();

    v_val_mean_desc    val_mean.val_mean_desc%type;
    v_perm_val_nm    perm_val.perm_val_nm%type;
    --jira 3977
    type t_perm_val_nm is table of perm_val.perm_val_nm%type;
    v_tab_perm_val_nm t_perm_val_nm := t_perm_val_nm();
    v_perm_val_nm_list varchar2(4000);
    
    v_item_id		 number;
    v_ver_nr		 number;
    vd_id_nm    varchar2(300);
    cde_id_nm varchar2(300);
    v_tmp number;
    v_pv_mtchd boolean;
    v_src_lbl varchar2(1000);
    v_src_col varchar2(1000);
    v_run_typ varchar2(1000);
    
    v_unmtch_cnt number;
    v_rule_desc varchar2(255);
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

 row_ori := hookInput.originalRowset.rowset (1);
 v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
 --jira 3978: add ability to CDE Match to match using Source VMs -- change column header to reflect update
 if (v_mode = 'CDE') then
    v_src_lbl := 'Source Value';
    -- get latest run to determine which column to query
    v_src_col := 'perm_val_nm';
else
    v_src_lbl := 'Source PV';
    v_src_col := 'val_mean_nm';
    end if;
v_unmtch_cnt := 0;
-- saving all unique val_mean_ids from submitted admin items into v_tab_val_mean_id

    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row_cur := hookInput.originalRowset.Rowset(i);

        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm from perm_val pv, nci_admin_item_ext ext, de
        where pv.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
        and pv.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and pv.fld_delete=0 and
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr) loop

            v_found := false;
            for j in 1..v_tab_val_mean_cd.count loop
                    v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
            end loop;
            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
               v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.cncpt_concat_nm;
               -- v_tab_val_mean_nm(v_tab_val_mean_nm.count) := 'mn test';
            end if;
        end loop;

        v_tab_admin_item_nm.extend();
        select ai.item_id || '-' || ai.item_nm into vd_id_nm from admin_item ai, de where ai.item_id = de.val_dom_item_id and ai.ver_nr = de.val_dom_ver_nr and de.item_id =ihook.getColumnValue(row_cur,'ITEM_ID')
        and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR');
        
        select ai.item_id || '-' || ai.item_nm into cde_id_nm from admin_item ai where ai.item_id = ihook.getColumnValue(row_cur,'ITEM_ID') and ai.ver_nr = ihook.getColumnValue(row_cur,'VER_NR');
        
-- last column header: matched CDE id + cde item nm + associated VD id + vd item name
       -- v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'CDE:' || ihook.getColumnValue(row_cur,'ITEM_ID') || '-' || nvl(ihook.getColumnValue(row_cur,'ITEM_NM'), 'test mn') || chr(13) || 'VD:' ||  vd_id_nm;
        v_tab_admin_item_nm(v_tab_admin_item_nm.count) := SUBSTR('PVs for CDE: ' || ihook.getColumnValue(row_cur,'ITEM_ID') || '-VD:' ||  vd_id_nm, 0,254);
    end loop;

--set Source value column header: either Source PV when match type is Form or Source Value when type is CDE Match
        v_tab_admin_item_nm.extend();

        v_tab_admin_item_nm(v_tab_admin_item_nm.count) := v_src_lbl ;

    -- populating val means/perm vals
    rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop

        row := t_row();
        if (v_tab_val_mean_cd(i) = v_tab_val_mean_nm(i)) then
         --   ihook.setColumnValue(row, 'Concept Code', 'No Concepts');
          ihook.setColumnValue(row, 'VM Concept Codes', '');
        else
        ihook.setColumnValue(row, 'VM Concept Codes', v_tab_val_mean_cd(i));
        end if;
        ihook.setColumnValue(row, 'VM Concept Names', nci_11179.replaceChar(v_tab_val_mean_nm(i)));
        ihook.setColumnValue(row, v_src_lbl,'');
        
        --populate PVs for last column
        for j in 1 .. hookInput.originalRowset.Rowset.count loop
           row_cur := hookInput.originalRowset.Rowset(j);

            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a, nci_admin_item_Ext ext, de
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and a.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
            and a.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and a.fld_delete=0) loop
            v_perm_val_nm :=  v_perm_val_nm || '|' || rec.perm_val_nm ;
            end loop;
            ihook.setColumnValue(row, v_tab_admin_item_nm(j), substr(nci_11179.replaceChar(v_perm_val_nm),2));
          
             if (v_mode = 'FORM') then -- if called from FORM
               for cur1 in (select src_perm_val,SRC_VM_NM from NCI_STG_FORM_VV_IMPORT where quest_imp_id = v_hdr_id) loop
                    if (upper(cur1.src_perm_Val) = upper(v_tab_val_mean_nm(i)) or upper(cur1.src_perm_Val) = upper(v_perm_val_nm) or
                    upper(cur1.src_vm_nm) = upper(v_tab_val_mean_nm(i)) or upper(cur1.src_vm_nm) = upper(v_perm_val_nm)) then
                    ihook.setColumnValue(row, v_src_lbl, cur1.src_perm_val);
                    end if;
                end loop;
            end if;
--raise_application_error(-20000,v_mode || v_perm_val_nm);

            if (v_mode = 'CDE') then -- if called from CDE Match
                SELECT lst_run_typ INTO v_run_typ FROM nci_ds_hdr WHERE hdr_id = v_hdr_id;
                v_rule_desc := ihook.getColumnValue(row_ori, 'RULE_DESC');
                if (instr(v_rule_desc, '(PV)') <> 0) then
                    if (v_run_typ LIKE '%PV%') then
                        for cur1 in (select perm_val_nm,entty_nm_usr from NCI_DS_DTL where hdr_id = v_hdr_id and excl_pv_ind = 0 and nvl(fld_delete,0) <> 1) loop
                            if (upper(nvl(cur1.entty_nm_usr,cur1.perm_Val_nm)) = upper(v_tab_val_mean_nm(i))  or upper(nvl(cur1.entty_nm_usr,cur1.perm_Val_nm)) = upper(substr(v_perm_val_nm,2))) then
                                ihook.setColumnValue(row, v_src_lbl, nvl(cur1.entty_nm_usr,cur1.perm_Val_nm));
                              --  ihook.setColumnValue(row, v_src_lbl, upper(v_tab_val_mean_nm(i)));
                                v_tab_perm_val_nm.extend();
                                v_tab_perm_val_nm(v_tab_perm_val_nm.count) := upper(nvl(cur1.entty_nm_usr,cur1.perm_Val_nm));
                            end if;
                        end loop; 
                    else
                        for cur1 in (select val_mean_nm,entty_nm_usr from NCI_DS_DTL where hdr_id = v_hdr_id and excl_pv_ind = 0 and nvl(fld_delete,0) <> 1) loop
                        --if (upper(nvl(cur1.entty_nm_usr,cur1.val_mean_nm)) in (upper(v_tab_val_mean_nm(j)),upper(v_tab_val_mean_nm(i))) or upper(nvl(cur1.entty_nm_usr,cur1.val_mean_nm)) = upper(substr(v_perm_val_nm,2))) then
                            if (upper(nvl(cur1.entty_nm_usr,cur1.val_mean_nm)) = upper(v_tab_val_mean_nm(j)) or upper(nvl(cur1.entty_nm_usr,cur1.val_mean_nm)) = upper(substr(v_perm_val_nm,2))) then
                                ihook.setColumnValue(row, v_src_lbl, nvl(cur1.entty_nm_usr,cur1.val_mean_nm));
                                v_tab_perm_val_nm.extend();
                                v_tab_perm_val_nm(v_tab_perm_val_nm.count) := upper(nvl(cur1.entty_nm_usr,cur1.val_mean_nm));
                            end if;
                        end loop; 
                    end if;    
                else -- matched to VM Concept names
                    if (v_run_typ LIKE '%PV%') then
                        for cur1 in (select perm_val_nm,entty_nm_usr from NCI_DS_DTL where hdr_id = v_hdr_id and excl_pv_ind = 0 and nvl(fld_delete,0) <> 1) loop
                           -- if (upper(nvl(cur1.entty_nm_usr,cur1.perm_Val_nm)) = upper(v_tab_val_mean_nm(i))  or upper(nvl(cur1.entty_nm_usr,cur1.perm_Val_nm)) = upper(substr(v_perm_val_nm,2))) then
                            if (upper(nvl(cur1.entty_nm_usr,cur1.perm_Val_nm)) = upper(v_tab_val_mean_nm(i)))  then
                                ihook.setColumnValue(row, v_src_lbl, nvl(cur1.entty_nm_usr,cur1.perm_Val_nm));
                                v_tab_perm_val_nm.extend();
                                v_tab_perm_val_nm(v_tab_perm_val_nm.count) := upper(nvl(cur1.entty_nm_usr,cur1.perm_Val_nm));
                            end if;
                        end loop; 
                    else
                        for cur1 in (select val_mean_nm,entty_nm_usr from NCI_DS_DTL where hdr_id = v_hdr_id and excl_pv_ind = 0 and nvl(fld_delete,0) <> 1) loop
                        --if (upper(nvl(cur1.entty_nm_usr,cur1.val_mean_nm)) in (upper(v_tab_val_mean_nm(j)),upper(v_tab_val_mean_nm(i))) or upper(nvl(cur1.entty_nm_usr,cur1.val_mean_nm)) = upper(substr(v_perm_val_nm,2))) then
                          --  if (upper(nvl(cur1.entty_nm_usr,cur1.val_mean_nm)) = upper(v_tab_val_mean_nm(i)) or upper(nvl(cur1.entty_nm_usr,cur1.val_mean_nm)) = upper(substr(v_perm_val_nm,2))) then
                            if (upper(nvl(cur1.entty_nm_usr,cur1.val_mean_nm)) = upper(v_tab_val_mean_nm(j))) then
                                ihook.setColumnValue(row, v_src_lbl, nvl(cur1.entty_nm_usr,cur1.val_mean_nm));
                                v_tab_perm_val_nm.extend();
                                v_tab_perm_val_nm(v_tab_perm_val_nm.count) := upper(nvl(cur1.entty_nm_usr,cur1.val_mean_nm));
                            end if;
                        end loop; 
                    end if;
                end if;
            end if;
        
        end loop;
      
        -- input
       /* for cur1 in (select perm_val_nm from NCI_DS_DTL where hdr_id = v_hdr_id) loop
        if upper(cur1.perm_Val_nm) = upper(v_tab_val_mean_nm(i)) or upper(cur1.perm_Val_nm) = upper(v_tab_val_mean_nm(i)) then
            ihook.setColumnValue(row, 'Input', cur1.perm_val_nm);
        end if;
        end loop; */
        rows.extend; rows(rows.last) := row;
    end loop;
--jira 3977: show unmatched pvs    
if v_tab_perm_val_nm.count > 0 then
    if (v_run_typ like '%PV%') then
        for cur2 in (select perm_val_nm, entty_nm_usr from NCI_DS_DTL where hdr_id = v_hdr_id and excl_pv_ind = 0 and nvl(fld_delete,0) <> 1) loop
            v_pv_mtchd := false;
            for p in 1..v_tab_perm_val_nm.count loop
                if upper(nvl(cur2.entty_nm_usr,cur2.perm_val_nm)) = v_tab_perm_val_nm(p) then
                    v_pv_mtchd := true;
                end if;
            end loop;
            if not v_pv_mtchd then
                if ((nvl(length(v_perm_val_nm_list),0) + length(nvl(cur2.entty_nm_usr,cur2.perm_val_nm))) < 1970) then
                    v_perm_val_nm_list := v_perm_val_nm_list || ', ' || nvl(cur2.entty_nm_usr,cur2.perm_val_nm);
                else
                    v_unmtch_cnt := v_unmtch_cnt + 1;
                    --raise_application_error(-20000, (nvl(length(v_perm_val_nm_list),0) + length(nvl(cur2.entty_nm_usr,cur2.perm_val_nm))));
                   -- raise_application_error(-20000, length(nvl(cur2.entty_nm_usr,cur2.perm_val_nm)));
                   -- raise_application_error(-20000, (nvl(length(v_perm_val_nm_list),0)));
                end if;
            end if;
        end loop;
    else
        for cur2 in (select val_mean_nm, entty_nm_usr from NCI_DS_DTL where hdr_id = v_hdr_id and excl_pv_ind = 0 and nvl(fld_delete,0) <> 1) loop
            v_pv_mtchd := false;
            for p in 1..v_tab_perm_val_nm.count loop
                if upper(nvl(cur2.entty_nm_usr, cur2.val_mean_nm)) = v_tab_perm_val_nm(p) then
                    v_pv_mtchd := true;
                end if;
            end loop;
            if not v_pv_mtchd then
            if ((nvl(length(v_perm_val_nm_list),0) + length(nvl(cur2.entty_nm_usr,cur2.val_mean_nm))) < 1970) then
                    v_perm_val_nm_list := v_perm_val_nm_list || ', ' || nvl(cur2.entty_nm_usr,cur2.val_mean_nm);
                else
                    v_unmtch_cnt := v_unmtch_cnt + 1;
                end if;
                --v_perm_val_nm_list := v_perm_val_nm_list || ', ' || nvl(cur2.entty_nm_usr,cur2.val_mean_nm);
            end if;
        end loop;
    end if;
--raise_application_error(-20000, length(v_perm_val_nm_list));
end if;
if (rows.count > 0) then
    --showRowset := t_showableRowset(rows, 'Permissible Value Comparison',4, 'unselectable');
    showRowset := t_showableRowset(rows, 'Value Comparison',4, 'unselectable');
    hookOutput.showRowset := showRowset;
    if (v_mode = 'CDE') then
        select count(*) into v_tmp from nci_ds_dtl where hdr_id = v_hdr_id and excl_pv_ind = 1;
        if (v_tmp = 0) then
            if (v_unmtch_cnt = 0) then
                hookoutput.message := '<p style="text-align:left"><strong>Excluded Values:</strong> ' || '<i>None</i>' || '<BR>' || '<strong>Unmatched Values: </strong>' || nvl(LTRIM(v_perm_val_nm_list, ', '), '<i>None</i>') || '</p>';
            else
                hookoutput.message := '<p style="text-align:left"><strong>Excluded Values:</strong> ' || '<i>None</i>' || '<BR>' || '<strong>Unmatched Values: </strong>' || nvl(LTRIM(v_perm_val_nm_list, ', ') || ',<i> and ' || v_unmtch_cnt || ' more...</i>', '<i>None</i>') || '</p>';
            end if;
        elsif (v_tmp > 0) then
            if (v_unmtch_cnt = 0) then
                hookoutput.message := '<p style="text-align:left"><strong>Excluded Values:</strong> ' || nci_ds.getPVExclusionList(v_hdr_id) || '<BR>' || '<strong>Unmatched Values: </strong>' || nvl(LTRIM(v_perm_val_nm_list, ', '), '<i>None</i>') || '</p>';
            --LTRIM(v_perm_val_nm_list, ', ')
            else
                hookoutput.message := SUBSTR('<p style="text-align:left"><strong>Excluded Values:</strong> ' || nci_ds.getPVExclusionList(v_hdr_id) || '<BR>' || '<strong>Unmatched Values: </strong>' || nvl(LTRIM(v_perm_val_nm_list, ', ') || ',<i> and ' || v_unmtch_cnt || ' more...</i>', '<i>None</i>') || '</p>', 0, 4000);
            end if;
        end if;
        hookoutput.message := SUBSTR('<p style="text-align:left"><strong>Last Run:</strong> ' || v_run_typ || hookoutput.message, 0, 4000);
    end if;
else
  hookoutput.message := 'Selected items are non-enumerated,';
end if;

    v_data_out := ihook.getHookOutput(hookOutput);
end;


/*  Show PV comparison from Subset relationship for CDE */

procedure spNCIShowVMDependencySubset (v_data_in in clob, v_data_out out clob, v_mode in varchar2)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;
    row_ori  t_row;
    v_hdr_id number;

    v_admin_item                admin_item%rowtype;
    v_tab_admin_item            tab_admin_item_pk;

    v_found      boolean;

    type t_val_mean_cd is table of nci_admin_item_ext.cncpt_concat%type;
    type t_val_mean_nm is table of nci_admin_item_ext.cncpt_concat_nm%type;

    v_tab_val_mean_cd  t_val_mean_cd := t_val_mean_cd();
    v_tab_val_mean_nm  t_val_mean_nm := t_val_mean_nm();

    v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

    type      t_admin_item_nm is table of admin_item.item_nm%type;
    v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();

    v_val_mean_desc    val_mean.val_mean_desc%type;
    v_perm_val_nm    perm_val.perm_val_nm%type;
    v_item_id		 number;
    v_ver_nr		 number;
    vd_id_nm    varchar2(300);
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

 row_ori := hookInput.originalRowset.rowset (1);
 v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
-- saving all unique val_mean_ids from submitted admin items into v_tab_val_mean_id

    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row_cur := hookInput.originalRowset.Rowset(i);

        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm from perm_val pv, nci_admin_item_ext ext, de
        where pv.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'C_ITEM_ID')
        and pv.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'C_ITEM_VER_NR') and pv.fld_delete=0 and
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr) loop

            v_found := false;
            for j in 1..v_tab_val_mean_cd.count loop
                    v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
            end loop;
            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
                v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.cncpt_concat_nm;
            end if;
        end loop;

        v_tab_admin_item_nm.extend();
        select ai.item_id || '-' || ai.item_nm into  vd_id_nm from admin_item ai, de where ai.item_id = de.val_dom_item_id and ai.ver_nr = de.val_dom_ver_nr and de.item_id =ihook.getColumnValue(row_cur,'C_ITEM_ID')
        and de.ver_nr = ihook.getColumnValue(row_cur,'C_ITEM_VER_NR');

        v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'CDE:' || ihook.getColumnValue(row_cur,'C_ITEM_ID') || '-' || ihook.getColumnValue(row_cur,'ITEM_NM') || chr(13) || 'VD:' ||  vd_id_nm ;
    end loop;

        row_cur := hookInput.originalRowset.Rowset(1);

        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm from perm_val pv, nci_admin_item_ext ext, de
        where pv.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'P_ITEM_ID')
        and pv.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'P_ITEM_VER_NR') and pv.fld_delete=0 and
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr) loop

            v_found := false;
            for j in 1..v_tab_val_mean_cd.count loop
                    v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
            end loop;
            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
                v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.cncpt_concat_nm;
            end if;
        end loop;

        v_tab_admin_item_nm.extend();
        select ai.item_id || '-' || ai.item_nm into  vd_id_nm from admin_item ai, de where ai.item_id = de.val_dom_item_id and ai.ver_nr = de.val_dom_ver_nr and de.item_id =ihook.getColumnValue(row_cur,'P_ITEM_ID')
        and de.ver_nr = ihook.getColumnValue(row_cur,'P_ITEM_VER_NR');

        v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'CDE:' || ihook.getColumnValue(row_cur,'ITEM_ID') || '-' || ihook.getColumnValue(row_cur,'ITEM_NM') || chr(13) || 'VD:' ||  vd_id_nm ;
   
    -- populating val means/perm vals
    rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop

        row := t_row();
        if (v_tab_val_mean_cd(i) = v_tab_val_mean_nm(i)) then
         --   ihook.setColumnValue(row, 'Concept Code', 'No Concepts');
          ihook.setColumnValue(row, 'VM Concept Codes', '');
        else
        ihook.setColumnValue(row, 'VM Concept Codes', v_tab_val_mean_cd(i));
        end if;
        ihook.setColumnValue(row, 'VM Concept Names', nci_11179.replaceChar(v_tab_val_mean_nm(i)));
        ihook.setColumnValue(row, 'Parent CDE','');
        for j in 1 .. hookInput.originalRowset.Rowset.count loop
           row_cur := hookInput.originalRowset.Rowset(j);

            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a, nci_admin_item_Ext ext, de
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and a.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'C_ITEM_ID')
            and a.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'C_ITEM_VER_NR') and a.fld_delete=0) loop
            v_perm_val_nm :=  v_perm_val_nm || '|' || rec.perm_val_nm ;
            end loop;
            ihook.setColumnValue(row, v_tab_admin_item_nm(j), substr(nci_11179.replaceChar(v_perm_val_nm),2));
          
--raise_application_error(-20000,v_mode || v_perm_val_nm);
                
        end loop;
          row_cur := hookInput.originalRowset.Rowset(1);

            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a, nci_admin_item_Ext ext, de
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and a.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'P_ITEM_ID')
            and a.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'P_ITEM_VER_NR') and a.fld_delete=0) loop
            v_perm_val_nm :=  v_perm_val_nm || '|' || rec.perm_val_nm ;
            end loop;
            ihook.setColumnValue(row, 'Parent CDE', substr(nci_11179.replaceChar(v_perm_val_nm),2));
          
--raise
        -- input
       /* for cur1 in (select perm_val_nm from NCI_DS_DTL where hdr_id = v_hdr_id) loop
        if upper(cur1.perm_Val_nm) = upper(v_tab_val_mean_nm(i)) or upper(cur1.perm_Val_nm) = upper(v_tab_val_mean_nm(i)) then
            ihook.setColumnValue(row, 'Input', cur1.perm_val_nm);
        end if;
        end loop; */
        rows.extend; rows(rows.last) := row;
    end loop;

if (rows.count > 0) then
    showRowset := t_showableRowset(rows, 'Permissible Value Comparison',4, 'unselectable');
    hookOutput.showRowset := showRowset;
else
  hookoutput.message := 'Selected items are non-enumerated,';
end if;

    v_data_out := ihook.getHookOutput(hookOutput);
end;


/*  Show PV comparison from ADministereds Item */

procedure spNCIShowVMDependencyComb (v_data_in in clob, v_data_out out clob)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;
    row_ori  t_row;

    v_admin_item                admin_item%rowtype;
    v_tab_admin_item            tab_admin_item_pk;

    v_found      boolean;

    type t_val_mean_cd is table of nci_admin_item_ext.cncpt_concat%type;
    type t_val_mean_nm is table of nci_admin_item_ext.cncpt_concat_nm%type;

    v_tab_val_mean_cd  t_val_mean_cd := t_val_mean_cd();
    v_tab_val_mean_nm  t_val_mean_nm := t_val_mean_nm();

    v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

    type      t_admin_item_nm is table of admin_item.item_nm%type;
    v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();
    k integer;
    v_val_mean_desc    val_mean.val_mean_desc%type;
    --v_perm_val_nm    perm_val.perm_val_nm%type;
    v_perm_val_nm varchar2(6000);
    v_item_id		 number;
    v_ver_nr		 number;
    v_cart boolean;
    vd_id_nm    varchar2(300);
    v_item_typ_id integer;
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
v_cart := false;
 row_ori := hookInput.originalRowset.rowset (1);
-- saving all unique val_mean_ids from submitted admin items into v_tab_val_mean_id
--raise_application_error(-20000, hookinput.originalrowset.tablename);
if (upper(hookinput.originalrowset.tablename) like '%CART%') then
    v_item_typ_id := 4;
    v_cart := true;
elsif (upper(hookinput.originalrowset.tablename)= 'VW_DE') then
    v_item_typ_id := 4;
    v_cart := true;
 else 
    v_item_typ_id := ihook.getColumnValue(row_ori,'ADMIN_ITEM_TYP_ID');
end if;

    if (v_item_typ_id not in (3, 4)) then
        raise_application_error(-20000,'!!!! This functionality is only applicable for CDE and VD !!!!');
    return;
    end if;

    if (v_item_typ_id = 4) then -- Data Element
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row_cur := hookInput.originalRowset.Rowset(i);
        if (ihook.getColumnValue(row_cur, 'ADMIN_ITEM_TYP_ID') = v_item_typ_id or v_cart) then
        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm, ai.item_nm from perm_val pv, nci_admin_item_ext ext, de, admin_item ai
        where pv.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
        and pv.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and pv.fld_delete=0 and
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr
        and pv.nci_val_mean_item_id=ai.item_id and pv.nci_val_mean_ver_nr = ai.ver_nr) loop

            v_found := false;
            for j in 1..v_tab_val_mean_cd.count loop
                    v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
            end loop;
            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
            --    v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.cncpt_concat_nm;
                v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.item_nm;
            end if;
        end loop;

        v_tab_admin_item_nm.extend();
         select decode(ai.VAL_DOM_TYP_ID,17,'Enumerated',18,'Non-enumerated',16, 'Enumerated by Reference','') || ' VD: ' || ai.item_id || '-' || ai.item_nm into  vd_id_nm from vw_value_dom ai, de where ai.item_id = de.val_dom_item_id and ai.ver_nr = de.val_dom_ver_nr and de.item_id =ihook.getColumnValue(row_cur,'ITEM_ID')
        and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR');

   --     v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'CDE:' || ihook.getColumnValue(row_cur,'ITEM_ID') || '-' || substr(ihook.getColumnValue(row_cur,'ITEM_NM'),1,75) || chr(13) || 'VD:' ||  substr(vd_id_nm,1,75) ;
        v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'CDE:' || ihook.getColumnValue(row_cur,'ITEM_ID') || '-' || ihook.getColumnValue(row_cur,'VER_NR') || '-' || substr(ihook.getColumnValue(row_cur,'ITEM_NM'),1,85) || '-' ||  substr(vd_id_nm,1,85) ;
     end if;
    end loop;
  end if;
  if (v_item_typ_id = 3) then --Value Domain

    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row_cur := hookInput.originalRowset.Rowset(i);
     if (ihook.getColumnValue(row_cur, 'ADMIN_ITEM_TYP_ID') = v_item_typ_id) then

        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm, ai.item_nm from perm_val pv, nci_admin_item_ext ext, admin_item ai
        where val_dom_item_id=ihook.getColumnValue(row_cur,'ITEM_ID')
        and val_dom_ver_nr=ihook.getColumnValue(row_cur,'VER_NR') and pv.fld_delete=0 and
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr
        and pv.nci_val_mean_item_id = ai.item_id and pv.nci_val_mean_ver_nr = ai.ver_nr) loop
            v_found := false;
            for j in 1..v_tab_val_mean_cd.count loop
                    v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
            end loop;

            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
                v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.item_nm;
            end if;
        end loop;
      v_tab_admin_item_nm.extend();
   select decode(ai.VAL_DOM_TYP_ID,17,'Enumerated',18,'Non-enumerated',16, 'Enumerated by Reference','') || ' VD: ' || ai.item_id || '-' ||  ihook.getColumnValue(row_cur,'VER_NR')  || '-' ||  ai.item_nm into  vd_id_nm from vw_value_dom ai
       where ai.item_id = ihook.getColumnValue(row_cur,'ITEM_ID') and ai.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') ;
       
      v_tab_admin_item_nm(v_tab_admin_item_nm.count) := substr(vd_id_nm,1,255);
      
    end if;
    end loop;
   end if;

    -- populating val means/perm vals

    if (v_item_typ_id = 4) then

    rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop

        row := t_row();
        if (v_tab_val_mean_cd(i) = v_tab_val_mean_nm(i)) then
         --   ihook.setColumnValue(row, 'Concept Code', 'No Concepts');
          ihook.setColumnValue(row, 'VM Concept Codes', '');
        else
        ihook.setColumnValue(row, 'VM Concept Codes', v_tab_val_mean_cd(i));
        end if;
        ihook.setColumnValue(row, 'VM Name', nci_11179.replaceChar(v_tab_val_mean_nm(i)));
    k := 1;
        for j in 1 .. hookInput.originalRowset.Rowset.count loop
           row_cur := hookInput.originalRowset.Rowset(j);
        if (ihook.getColumnValue(row_cur, 'ADMIN_ITEM_TYP_ID') = v_item_typ_id or v_cart) then

            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a, nci_admin_item_Ext ext, de
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and a.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
            and a.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and a.fld_delete=0) loop
                v_perm_val_nm :=  v_perm_val_nm || '|' || rec.perm_val_nm ;
            end loop;
           -- raise_application_error(-20000, nci_11179.replaceChar(v_perm_val_nm));
            ihook.setColumnValue(row, v_tab_admin_item_nm(k), substr(nci_11179.replaceChar(v_perm_val_nm),2));
            k := k + 1;
            end if;
        end loop;
        rows.extend; rows(rows.last) := row;
    end loop;
    end if;

    if (v_item_typ_id = 3) then

    rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop

        row := t_row();
        if (v_tab_val_mean_cd(i) = v_tab_val_mean_nm(i)) then
         --   ihook.setColumnValue(row, 'Concept Code', 'No Concepts');
          ihook.setColumnValue(row, 'VM Concept Codes', '');
        else
        ihook.setColumnValue(row, 'VM Concept Codes', v_tab_val_mean_cd(i));
        end if;
        ihook.setColumnValue(row, 'VM Name', nci_11179.replaceChar(v_tab_val_mean_nm(i)));
        k := 1;
        for j in 1 .. hookInput.originalRowset.Rowset.count loop
           row_cur := hookInput.originalRowset.Rowset(j);
        if (ihook.getColumnValue(row_cur, 'ADMIN_ITEM_TYP_ID') = v_item_typ_id) then

            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a, nci_admin_item_Ext ext
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and a.val_dom_item_id=ihook.getColumnValue(row_cur,'ITEM_ID')
            and a.val_dom_ver_nr= ihook.getColumnValue(row_cur,'VER_NR') and a.fld_delete=0) loop
               v_perm_val_nm :=  v_perm_val_nm || '|' || rec.perm_val_nm ;
             end loop;
            ihook.setColumnValue(row, v_tab_admin_item_nm(k), substr(nci_11179.replaceChar(v_perm_val_nm),2));
            k := k+1;
            end if;
        end loop;
        rows.extend; rows(rows.last) := row;

    end loop;
    end if;

if (rows.count > 0) then
    showRowset := t_showableRowset(rows, 'Permissible Value Comparison',4, 'unselectable');
    hookOutput.showRowset := showRowset;
else
  hookoutput.message := 'Selected items are non-enumerated,';
end if;
    v_data_out := ihook.getHookOutput(hookOutput);
end;


procedure spComparePVFromCDEMatchCDEList(v_data_in in clob, v_data_out out clob)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;
    row_ori  t_row;

    v_admin_item                admin_item%rowtype;
    v_tab_admin_item            tab_admin_item_pk;

    v_found      boolean;

    type t_val_mean_cd is table of nci_admin_item_ext.cncpt_concat%type;
    type t_val_mean_nm is table of nci_admin_item_ext.cncpt_concat_nm%type;

    v_tab_val_mean_cd  t_val_mean_cd := t_val_mean_cd();
    v_tab_val_mean_cd_disp  t_val_mean_cd := t_val_mean_cd();
    v_tab_val_mean_nm  t_val_mean_nm := t_val_mean_nm();

    v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

    type      t_admin_item_nm is table of admin_item.item_nm%type;
    v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();
    k integer;
    v_val_mean_desc    val_mean.val_mean_desc%type;
    --v_perm_val_nm    perm_val.perm_val_nm%type;
    v_perm_val_nm varchar2(6000);
    v_item_id		 number;
    v_ver_nr		 number;
    rows_ori t_rows;
    v_str varchar2(4000);
    nn integer;
    v_id varchar2(1000);
    vd_id_nm varchar2(1000);
    v_hdr_id number;
    v_test_str varchar(4000);
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
 row_ori := hookInput.originalRowset.rowset (1);
v_hdr_id := ihook.getColumnValue(row_ori,'HDR_ID');
v_str := ihook.getColumnValue(row_ori,'CMP_TO_AI');

rows_ori := t_rows();

nn:= nci_11179.getWordCountDelim(v_str,',');

for k in 1..nn loop
  v_id := nci_11179.getWordDelim(v_str,k,nn,',');
  for cur in (select * from admin_item where admin_item_typ_id = 4 and item_id = v_id and CURRNT_VER_IND = 1) loop
    row := t_row();
    ihook.setColumnValue(row,'ITEM_ID', cur.item_id);
    ihook.setColumnValue(row,'VER_NR', cur.ver_nr);
    rows_ori.extend; rows_ori(rows_ori.last) := row;
  end loop;
end loop;

      


    for i in 1 .. rows_ori.count loop
        row_cur := rows_ori(i);
        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm, ai.item_nm from perm_val pv, nci_admin_item_ext ext, de, admin_item ai
        where pv.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
        and pv.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and pv.fld_delete=0 and
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr
        and pv.nci_val_mean_item_id=ai.item_id and pv.nci_val_mean_ver_nr = ai.ver_nr) loop

            v_found := false;
            for j in 1..v_tab_val_mean_cd.count loop
                    v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
            end loop;
            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_cd_disp.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
                v_tab_val_mean_cd_disp(v_tab_val_mean_cd_disp.count) := rec.cncpt_concat;
            --    v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.cncpt_concat_nm;
                v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.item_nm;
            end if;
        end loop;

        v_tab_admin_item_nm.extend();
         select decode(ai.VAL_DOM_TYP_ID,17,'Enumerated',18,'Non-enumerated',16, 'Enumerated by Reference','') || ' VD: ' || ai.item_id || '-' || ai.item_nm into  vd_id_nm from vw_value_dom ai, de where ai.item_id = de.val_dom_item_id and ai.ver_nr = de.val_dom_ver_nr and de.item_id =ihook.getColumnValue(row_cur,'ITEM_ID')
        and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR');

   --     v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'CDE:' || ihook.getColumnValue(row_cur,'ITEM_ID') || '-' || substr(ihook.getColumnValue(row_cur,'ITEM_NM'),1,75) || chr(13) || 'VD:' ||  substr(vd_id_nm,1,75) ;
        v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'PVs For CDE:' || ihook.getColumnValue(row_cur,'ITEM_ID') || '-' || ihook.getColumnValue(row_cur,'VER_NR') || '-' || substr(ihook.getColumnValue(row_cur,'ITEM_NM'),1,85) || '-' ||  substr(vd_id_nm,1,85) ;
     
    end loop;
  
    -- populating val means/perm vals

-- Souuce value
    
  
    rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop

        row := t_row();
        if (v_tab_val_mean_cd(i) = v_tab_val_mean_nm(i)) then
         --   ihook.setColumnValue(row, 'Concept Code', 'No Concepts');
          ihook.setColumnValue(row, 'VM Concept Codes', '');
        else
        ihook.setColumnValue(row, 'VM Concept Codes', v_tab_val_mean_cd_disp(i));
        end if;
        ihook.setColumnValue(row, 'VM Name', nci_11179.replaceChar(v_tab_val_mean_nm(i)));
        ihook.setColumnValue(row, 'Source', '');
        
    k := 1;
     
        for j in 1 .. rows_ori.count loop
           row_cur := rows_ori(j);
        
            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a, nci_admin_item_Ext ext, de
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and a.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
            and a.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and a.fld_delete=0) loop
                v_perm_val_nm :=  v_perm_val_nm || '|' || rec.perm_val_nm ;
            end loop;
           -- raise_application_error(-20000, nci_11179.replaceChar(v_perm_val_nm));
            ihook.setColumnValue(row, v_tab_admin_item_nm(k), substr(nci_11179.replaceChar(v_perm_val_nm),2));
            k := k + 1;
        end loop;
     for rec in (select perm_val_nm,entty_nm_usr from NCI_DS_DTL where hdr_id = v_hdr_id and excl_pv_ind = 0 and nvl(fld_delete,0) <> 1) loop
        for j in 1 .. rows_ori.count loop
        v_test_str:= ihook.getColumnValue(row,v_tab_admin_item_nm(j));
       --    if  instr(ihook.getColumnValue(row,v_tab_admin_item_nm(j)),rec.perm_val_nm ) > 0 then
          if  v_test_str= rec.perm_val_nm or  v_test_str like rec.perm_val_nm || '|%' 
           or v_test_str like '%|' || rec.perm_val_nm || '|%' or v_test_str like '%|' || rec.perm_val_nm   then
           --or v_tab_val_mean_nm(i)= rec.perm_val_nm then
           
            ihook.setColumnValue(row, 'Source',rec.perm_val_nm);
           end if;
           end loop;
        end loop;
       rows.extend; rows(rows.last) := row;
    end loop;
    
    -- add source values not found
     for rec in (select perm_val_nm,entty_nm_usr from NCI_DS_DTL where hdr_id = v_hdr_id and excl_pv_ind = 0 and nvl(fld_delete,0) <> 1) loop
                            

            v_found := false;
            for j in 1..rows.count loop
                  row_ori := rows(j);
                  if (ihook.getCOlumnValue(row_ori,'Source') is not null) then
                    v_found := v_found or ihook.getCOlumnValue(row_ori,'Source')= rec.perm_val_nm ;
                    end if;
                    --or v_tab_val_mean_nm(j)= rec.perm_val_nm;
            end loop;
            if not v_found then
               row := t_row();
               ihook.setColumnValue(row,'Source', rec.perm_val_nm);
                  rows.extend; rows(rows.last) := row;
               -- v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.perm_val_nm;
            end if;
        end loop;


if (rows.count > 0) then
    showRowset := t_showableRowset(rows, 'Permissible Value Comparison',4, 'unselectable');
    hookOutput.showRowset := showRowset;
else
  hookoutput.message := 'Selected items are non-enumerated,';
end if;
    v_data_out := ihook.getHookOutput(hookOutput);
end;


procedure spCreateValueMap (input_rows in t_rows, output_rows in out t_rows, v_src_alt_nm_typ in integer, v_tgt_alt_nm_typ in integer)
as

    rows      t_rows;
    row          t_row;
    row_cur t_row;
    row_ori  t_row;

    v_admin_item                admin_item%rowtype;
    v_tab_admin_item            tab_admin_item_pk;

    v_found      boolean;
    v_str varchar2(8000);
    type t_val_mean_cd is table of nci_admin_item_ext.cncpt_concat%type;
    type t_val_mean_nm is table of nci_admin_item_ext.cncpt_concat_nm%type;

    v_tab_val_mean_cd  t_val_mean_cd := t_val_mean_cd();
    v_tab_val_mean_nm  t_val_mean_nm := t_val_mean_nm();

    v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

    type      t_admin_item_nm is table of admin_item.item_nm%type;
    v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();
    k integer;
    v_val_mean_desc    val_mean.val_mean_desc%type;
    --v_perm_val_nm    perm_val.perm_val_nm%type;
    v_perm_val_nm varchar2(6000);
    v_item_id		 number;
    v_ver_nr		 number;
    v_cart boolean;
    vd_id_nm    varchar2(300);
    v_item_typ_id integer;
    v_src_vd_id  number;
    v_tgt_vd_id number;
    v_src_vd_ver number(4,2);
    v_tgt_vd_ver number(4,2);
begin

        row_cur := input_rows(1);
        v_src_vd_id := ihook.getColumnValue(row_cur,'ITEM_ID');
           v_src_vd_ver := ihook.getColumnValue(row_cur,'VER_NR');
      row_cur := input_rows(2);
        v_tgt_vd_id := ihook.getColumnValue(row_cur,'ITEM_ID');
           v_tgt_vd_ver := ihook.getColumnValue(row_cur,'VER_NR');

--raise_application_error(-20000,'Here');
    for i in 1 .. input_rows.count loop
        row_cur := input_rows(i);
        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm--, ai.item_nm 
        from perm_val pv, nci_admin_item_ext ext--, admin_item ai
        where val_dom_item_id=ihook.getColumnValue(row_cur,'ITEM_ID')
        and val_dom_ver_nr=ihook.getColumnValue(row_cur,'VER_NR') and pv.fld_delete=0 and
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr
        --and pv.nci_val_mean_item_id = ai.item_id and pv.nci_val_mean_ver_nr = ai.ver_nr
        ) loop
            v_found := false;
            for j in 1..v_tab_val_mean_cd.count loop
                    v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
            end loop;

            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
                v_tab_val_mean_nm(v_tab_val_mean_nm.count) := nci_11179.get_name_from_concepts(rec.nci_val_mean_item_id, rec.nci_val_mean_ver_nr);
            end if;
        end loop;
  
          v_tab_admin_item_nm.extend();
  -- select decode(ai.VAL_DOM_TYP_ID,17,'Enumerated',18,'Non-enumerated',16, 'Enumerated by Reference','') || ' ' || ai.item_id || '-' ||  ihook.getColumnValue(row_cur,'VER_NR')  || '-' ||  ai.item_nm into  vd_id_nm from vw_value_dom ai
   --    where ai.item_id = ihook.getColumnValue(row_cur,'ITEM_ID') and ai.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') ;
       
     -- v_tab_admin_item_nm(v_tab_admin_item_nm.count) := substr(vd_id_nm,1,255);
      v_tab_admin_item_nm(v_tab_admin_item_nm.count) := i;
    end loop;

    -- populating val means/perm vals


    output_rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop

        row := t_row();
        if (v_tab_val_mean_cd(i) = v_tab_val_mean_nm(i)) then
         --   ihook.setColumnValue(row, 'Concept Code', 'No Concepts');
          ihook.setColumnValue(row, 'VM Concept Codes', '');
        else
        ihook.setColumnValue(row, 'VM Concept Codes', v_tab_val_mean_cd(i));
        end if;
        ihook.setColumnValue(row, 'VM Name', nci_11179.replaceChar(v_tab_val_mean_nm(i)));
        k := 1;
        for j in 1 .. input_rows.count loop
           row_cur := input_rows(j);
           ihook.setColumnValue(row,'MECM_ID',ihook.getColumnValue(row_cur,'MECM_ID'));
            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a, nci_admin_item_Ext ext
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and a.val_dom_item_id=ihook.getColumnValue(row_cur,'ITEM_ID')
            and a.val_dom_ver_nr= ihook.getColumnValue(row_cur,'VER_NR') and a.fld_delete=0 order by perm_val_nm) loop
               v_perm_val_nm :=  v_perm_val_nm || '|' || rec.perm_val_nm ;
               if (k = 1) then
                   ihook.setColumnValue(row, 'Source Concept Code', ihook.getColumnValue(row,'VM Concept Codes'));
                   ihook.setColumnValue(row, 'Source Concept Name', ihook.getColumnValue(row,'VM Name'));
                     ihook.setColumnValue(row, 'SRC_VD_ITEM_ID', v_src_vd_id);
                   ihook.setColumnValue(row, 'SRC_VD_VER_NR', v_src_vd_ver);
                      ihook.setColumnValue(row, 'TGT_VD_ITEM_ID', v_tgt_vd_id);
                   ihook.setColumnValue(row, 'TGT_VD_VER_NR', v_tgt_vd_ver);
                    ihook.setColumnValue(row, 'SRC_CDE_ITEM_ID', ihook.getColumnValue(row_cur,'CDE_ITEM_ID'));
                   ihook.setColumnValue(row, 'SRC_CDE_VER_NR', ihook.getColumnValue(row_cur,'CDE_VER_NR'));
              end if;
                    if (k = 2) then
                   ihook.setColumnValue(row, 'Target Concept Code', ihook.getColumnValue(row,'VM Concept Codes'));
                   ihook.setColumnValue(row, 'Target Concept Name', ihook.getColumnValue(row,'VM Name'));
                       ihook.setColumnValue(row, 'SRC_VD_ITEM_ID', v_src_vd_id);
                   ihook.setColumnValue(row, 'SRC_VD_VER_NR', v_src_vd_ver);
                      ihook.setColumnValue(row, 'TGT_VD_ITEM_ID', v_tgt_vd_id);
                   ihook.setColumnValue(row, 'TGT_VD_VER_NR', v_tgt_vd_ver);
               ihook.setColumnValue(row, 'TGT_CDE_ITEM_ID', ihook.getColumnValue(row_cur,'CDE_ITEM_ID'));
                   ihook.setColumnValue(row, 'TGT_CDE_VER_NR', ihook.getColumnValue(row_cur,'CDE_VER_NR'));end if;
             end loop;
            ihook.setColumnValue(row, v_tab_admin_item_nm(k), substr(v_perm_val_nm,2));
            if (v_src_alt_nm_typ is not null and v_src_alt_nm_typ > 0 and k=1) then
             for rec in   (select listagg(nm_desc, '|') nm_desc from (select distinct nm_Desc   from perm_val a, nci_admin_item_Ext ext, alt_nms an
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and a.val_dom_item_id=ihook.getColumnValue(row_cur,'ITEM_ID')
            and a.val_dom_ver_nr= ihook.getColumnValue(row_cur,'VER_NR') and a.fld_delete=0
            and an.nm_typ_id = v_src_alt_nm_typ and an.item_id =nci_val_mean_item_id and an.ver_nr = nci_val_mean_ver_nr ) a
            --order by an.lst_upd_dt desc fetch  first 1 rows only
            ) loop
            ihook.setColumnValue(row, 'LBL_1' , rec.nm_desc);
         --      raise_application_error(-20000,rec.nm_desc);
             end loop;
             end if;
             if (v_tgt_alt_nm_typ is not null and v_tgt_alt_nm_typ > 0 and k=2) then
             for rec in   (
             select listagg(nm_desc,'|')   nm_desc from (select distinct nm_Desc from perm_val a, nci_admin_item_Ext ext, alt_nms an
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and a.val_dom_item_id=ihook.getColumnValue(row_cur,'ITEM_ID')
            and a.val_dom_ver_nr= ihook.getColumnValue(row_cur,'VER_NR') and a.fld_delete=0
            and an.nm_typ_id = v_tgt_alt_nm_typ and an.item_id =nci_val_mean_item_id and an.ver_nr = nci_val_mean_ver_nr ) a
             ) loop
            ihook.setColumnValue(row, 'LBL_2' , rec.nm_desc);
             end loop;
             end if;
            k := k+1;
        end loop;
        output_rows.extend; output_rows(output_rows.last) := row;

    end loop;

end;

/*  Show PV Details */

procedure spNCIShowPVDependencyComb (v_data_in in clob, v_data_out out clob)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;
    row_ori  t_row;

    v_admin_item                admin_item%rowtype;
    v_tab_admin_item            tab_admin_item_pk;

    v_found      boolean;

    type t_val_mean_cd is table of nci_admin_item_ext.cncpt_concat%type;
    type t_val_mean_nm is table of nci_admin_item_ext.cncpt_concat_nm%type;
    type t_val_mean_item_id is table of admin_item.item_id%type;
   type t_val_mean_ver_nr is table of admin_item.ver_nr%type;
   type t_val_mean_def is table of admin_item.item_desc%type;

    v_tab_val_mean_cd  t_val_mean_cd := t_val_mean_cd();
    v_tab_val_mean_nm  t_val_mean_nm := t_val_mean_nm();
  v_tab_val_mean_item_id  t_val_mean_item_id := t_val_mean_item_id();
  v_tab_val_mean_ver_nr  t_val_mean_ver_nr := t_val_mean_ver_nr();
 v_tab_val_mean_def  t_val_mean_def := t_val_mean_def();

    v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

    type      t_admin_item_nm is table of admin_item.item_nm%type;
    v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();
    k integer;
    v_val_mean_desc    val_mean.val_mean_desc%type;
    --v_perm_val_nm    perm_val.perm_val_nm%type;
    v_perm_val_nm varchar2(6000);
    v_item_id		 number;
    v_ver_nr		 number;
    v_cart boolean;
    vd_id_nm    varchar2(300);
    v_item_typ_id integer;
    i1 integer; 
    i2 integer;
    temp_vm_nm admin_item.item_Desc%type; 
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
v_cart := false;
 row_ori := hookInput.originalRowset.rowset (1);
-- saving all unique val_mean_ids from submitted admin items into v_tab_val_mean_id
--raise_application_error(-20000, hookinput.originalrowset.tablename);
if (upper(hookinput.originalrowset.tablename) like '%CART%') then
    v_item_typ_id := 4;
    v_cart := true;
elsif (upper(hookinput.originalrowset.tablename)= 'VW_DE') then
    v_item_typ_id := 4;
    v_cart := true;
 else 
    v_item_typ_id := ihook.getColumnValue(row_ori,'ADMIN_ITEM_TYP_ID');
end if;

    if (v_item_typ_id not in (3, 4)) then
        raise_application_error(-20000,'!!!! This functionality is only applicable for CDE and VD !!!!');
    return;
    end if;

    if (v_item_typ_id = 4) then -- Data Element
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row_cur := hookInput.originalRowset.Rowset(i);
        if (ihook.getColumnValue(row_cur, 'ADMIN_ITEM_TYP_ID') = v_item_typ_id or v_cart) then
        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm, ai.item_nm, ai.item_desc from perm_val pv, nci_admin_item_ext ext, de, admin_item ai
        where pv.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
        and pv.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and pv.fld_delete=0 and
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr
        and pv.nci_val_mean_item_id = ai.item_id and pv.nci_val_mean_ver_nr = ai.ver_nr) loop

            v_found := false;
            for j in 1..v_tab_val_mean_item_id.count loop
                    v_found := v_found or v_tab_val_mean_item_id(j)=rec.nci_val_mean_item_id;
            end loop;
            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_item_id.extend();
                v_tab_val_mean_ver_nr.extend();
                v_tab_val_mean_def.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
                v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.item_nm;
                v_tab_val_mean_item_id(v_tab_val_mean_item_id.count) := rec.nci_val_mean_item_id;
               v_tab_val_mean_ver_nr(v_tab_val_mean_ver_nr.count) := rec.nci_val_mean_ver_nr;
               v_tab_val_mean_def(v_tab_val_mean_def.count) := rec.item_desc;
            end if;
        end loop;

        v_tab_admin_item_nm.extend();
    
        select decode(ai.VAL_DOM_TYP_ID,17,'Enumerated',18,'Non-enumerated',16, 'Enumerated by Reference','') || ' VD: ' || ai.item_id || '-' || ai.item_nm into  vd_id_nm from vw_value_dom ai, de where ai.item_id = de.val_dom_item_id and ai.ver_nr = de.val_dom_ver_nr and de.item_id =ihook.getColumnValue(row_cur,'ITEM_ID')
        and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR');

   --     v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'CDE:' || ihook.getColumnValue(row_cur,'ITEM_ID') || '-' || substr(ihook.getColumnValue(row_cur,'ITEM_NM'),1,75) || chr(13) || 'VD:' ||  substr(vd_id_nm,1,75) ;
        v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'CDE:' || ihook.getColumnValue(row_cur,'ITEM_ID') || '-' || ihook.getColumnValue(row_cur,'VER_NR') || '-' || substr(ihook.getColumnValue(row_cur,'ITEM_NM'),1,85) || chr(13) ||  substr(vd_id_nm,1,85) ;
     end if;
    end loop;
  end if;
  if (v_item_typ_id = 3) then --Value Domain

    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row_cur := hookInput.originalRowset.Rowset(i);
     if (ihook.getColumnValue(row_cur, 'ADMIN_ITEM_TYP_ID') = v_item_typ_id) then

        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm, ai.item_nm, ai.item_desc from perm_val pv, nci_admin_item_ext ext, admin_item ai
        where val_dom_item_id=ihook.getColumnValue(row_cur,'ITEM_ID')
        and val_dom_ver_nr=ihook.getColumnValue(row_cur,'VER_NR') and pv.fld_delete=0 and
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr
        and  pv.nci_val_mean_item_id = ai.item_id and pv.nci_val_mean_ver_nr = ai.ver_nr) loop
            v_found := false;
               for j in 1..v_tab_val_mean_item_id.count loop
                    v_found := v_found or v_tab_val_mean_item_id(j)=rec.nci_val_mean_item_id;
            end loop;
            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_item_id.extend();
                v_tab_val_mean_ver_nr.extend();
                v_tab_val_mean_def.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
                v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.cncpt_concat_nm;
                v_tab_val_mean_item_id(v_tab_val_mean_item_id.count) := rec.nci_val_mean_item_id;
                v_tab_val_mean_ver_nr(v_tab_val_mean_ver_nr.count) := rec.nci_val_mean_ver_nr;
               v_tab_val_mean_def(v_tab_val_mean_def.count) := rec.item_desc;
            end if;
        end loop;
      v_tab_admin_item_nm.extend();
       select decode(ai.VAL_DOM_TYP_ID,17,'Enumerated',18,'Non-enumerated',16, 'Enumerated by Reference','') || ' VD: ' || ai.item_id || '-' ||  ihook.getColumnValue(row_cur,'VER_NR')  || '-' ||  ai.item_nm into  vd_id_nm from vw_value_dom ai
       where ai.item_id = ihook.getColumnValue(row_cur,'ITEM_ID') and ai.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') ;
       
      v_tab_admin_item_nm(v_tab_admin_item_nm.count) := substr(vd_id_nm,1,255);
    end if;
    end loop;
   end if;

    -- sort v_tab_val_mean_nm
    for i1 in 1..v_tab_val_mean_nm.count loop
    for i2 in i1+1..v_tab_val_mean_nm.count loop
    if (v_tab_val_mean_nm(i1) > v_tab_val_mean_nm(i2)) then
      temp_vm_nm := v_tab_val_mean_nm(i2);
      v_tab_val_mean_nm(i2) := v_tab_val_mean_nm(i1);
      v_tab_val_mean_nm(i1) := temp_vm_nm;
        temp_vm_nm := v_tab_val_mean_cd(i2);
      v_tab_val_mean_cd(i2) := v_tab_val_mean_cd(i1);
      v_tab_val_mean_cd(i1) := temp_vm_nm;
        temp_vm_nm := v_tab_val_mean_item_id(i2);
      v_tab_val_mean_item_id(i2) := v_tab_val_mean_item_id(i1);
      v_tab_val_mean_item_id(i1) := temp_vm_nm;
        temp_vm_nm := v_tab_val_mean_ver_nr(i2);
      v_tab_val_mean_ver_nr(i2) := v_tab_val_mean_ver_nr(i1);
      v_tab_val_mean_ver_nr(i1) := temp_vm_nm;
        temp_vm_nm := v_tab_val_mean_def(i2);
      v_tab_val_mean_def(i2) := v_tab_val_mean_def(i1);
      v_tab_val_mean_def(i1) := temp_vm_nm;
      end if;
   end loop;
   end loop;
   

    if (v_item_typ_id = 4) then

    rows := t_rows();
    for i in 1 .. v_tab_val_mean_nm.count loop

        row := t_row();
        if (v_tab_val_mean_cd(i) = v_tab_val_mean_nm(i)) then
         --   ihook.setColumnValue(row, 'Concept Code', 'No Concepts');
          ihook.setColumnValue(row, 'VM Concept Codes', '');
        else
        ihook.setColumnValue(row, 'VM Concept Codes', v_tab_val_mean_cd(i));
        end if;
        ihook.setColumnValue(row, 'VM Name', nci_11179.replaceChar(v_tab_val_mean_nm(i)));
        ihook.setColumnValue(row, 'VM Definition', nci_11179.replaceChar(v_tab_val_mean_def(i)));
            ihook.setColumnValue(row, 'VM Item ID', v_tab_val_mean_item_id(i));
           ihook.setColumnValue(row, 'VM Version', v_tab_val_mean_ver_nr(i));
    
    k := 1;
        for j in 1 .. hookInput.originalRowset.Rowset.count loop
           row_cur := hookInput.originalRowset.Rowset(j);
        if (ihook.getColumnValue(row_cur, 'ADMIN_ITEM_TYP_ID') = v_item_typ_id or v_cart) then

            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a,  de
            where nci_val_mean_item_id=v_tab_val_mean_item_id(i)  and nci_val_mean_ver_nr = v_tab_val_mean_ver_nr(i)
            and a.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
            and a.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and a.fld_delete=0) loop
                v_perm_val_nm :=  v_perm_val_nm || '|' || rec.perm_val_nm ;
            end loop;
           -- raise_application_error(-20000, nci_11179.replaceChar(v_perm_val_nm));
            ihook.setColumnValue(row, v_tab_admin_item_nm(k), substr(nci_11179.replaceChar(v_perm_val_nm),2));
            k := k + 1;
            end if;
        end loop;
        rows.extend; rows(rows.last) := row;
    end loop;
    end if;

    if (v_item_typ_id = 3) then

    rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop

        row := t_row();
        if (v_tab_val_mean_cd(i) = v_tab_val_mean_nm(i)) then
         --   ihook.setColumnValue(row, 'Concept Code', 'No Concepts');
          ihook.setColumnValue(row, 'VM Concept Codes', '');
        else
        ihook.setColumnValue(row, 'VM Concept Codes', v_tab_val_mean_cd(i));
        end if;
        ihook.setColumnValue(row, 'VM Name', nci_11179.replaceChar(v_tab_val_mean_nm(i)));
        ihook.setColumnValue(row, 'VM Definition', nci_11179.replaceChar(v_tab_val_mean_def(i)));
                   ihook.setColumnValue(row, 'VM Item ID', v_tab_val_mean_item_id(i));
           ihook.setColumnValue(row, 'VM Version', v_tab_val_mean_ver_nr(i));
   
        k := 1;
        for j in 1 .. hookInput.originalRowset.Rowset.count loop
           row_cur := hookInput.originalRowset.Rowset(j);
        if (ihook.getColumnValue(row_cur, 'ADMIN_ITEM_TYP_ID') = v_item_typ_id) then

            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a
            where nci_val_mean_item_id=v_tab_val_mean_item_id(i)  and nci_val_mean_ver_nr = v_tab_val_mean_ver_nr(i)
            and a.val_dom_item_id=ihook.getColumnValue(row_cur,'ITEM_ID')
            and a.val_dom_ver_nr= ihook.getColumnValue(row_cur,'VER_NR') and a.fld_delete=0) loop
               v_perm_val_nm :=  v_perm_val_nm || '|' || rec.perm_val_nm ;
             end loop;
            ihook.setColumnValue(row, v_tab_admin_item_nm(k), substr(nci_11179.replaceChar(v_perm_val_nm),2));
            k := k+1;
            end if;
        end loop;
        rows.extend; rows(rows.last) := row;

    end loop;
    end if;

if (rows.count > 0) then
    showRowset := t_showableRowset(rows, 'Permissible Value Comparison',4, 'unselectable');
    hookOutput.showRowset := showRowset;
else
  hookoutput.message := 'Selected items are non-enumerated,';
end if;
    v_data_out := ihook.getHookOutput(hookOutput);
end;


function getGenericQuestion (v_quest_str in varchar2, v_cmd_str in varchar2, v_id in integer)   return t_question is

  question t_question;
  answer t_answer;
  answers t_answers;
begin

        ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(v_id, 1, v_cmd_str );
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION(v_quest_str , ANSWERS);


return question;
end;

function isDECnmSysGen (v_dec_id in number, v_dec_ver_nr in number, v_oc_id in number, v_oc_ver_nr in number, v_prop_id in number, v_prop_ver_nr in number) return boolean is
v_dec_nm varchar2(255);
v_oc_nm varchar2(255);
v_prop_nm varchar2(255);

begin
    select ai.item_long_nm, oc.item_nm, prop.item_nm into v_dec_nm, v_oc_nm, v_prop_nm 
    from admin_item ai, admin_item oc, admin_item prop 
    where ai.item_id = v_dec_id and ai.ver_nr = v_dec_ver_nr
    and oc.item_id = v_oc_id and oc.ver_nr = v_oc_ver_nr
    and prop.item_id = v_prop_id and prop.ver_nr = v_prop_ver_nr;
    
    if (v_dec_nm like substr(v_oc_nm || ' ' || v_prop_nm, 1,255)) then
        return true;
    elsif (v_dec_nm like substr(v_oc_nm || ':' || v_prop_nm, 1, 255)) then
        return true;
    else
        return false;
    end if;
end;

function isDECnmSysGenNew (v_in_str in varchar2) return boolean is
sysgen_ind boolean;
begin
    sysgen_ind := regexp_like(v_in_str, '[0-9][v]{1}[0-9].[0-9]{2}[:][0-9]');
    
    if (sysgen_ind = false) then
        sysgen_ind := regexp_like(v_in_str, '[0-9][v]{1}[0-9].[0-9]{1}[:][0-9]');
    end if;
    
    return sysgen_ind;

end;
end;
/
