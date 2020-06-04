create or replace PACKAGE nci_11179 AS
function getWordCount(v_nm in varchar2) return integer;
function getWord(v_nm in varchar2, v_idx in integer, v_max in integer) return varchar2;
FUNCTION get_concepts(v_item_id in number, v_ver_nr in number) return varchar2;
 Function get_concept_order(v_item_id in number, v_ver_nr in number) return varchar2 ;
 function cmr_guid return varchar2;
procedure spAddToCart ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spRemoveFromCart (v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spAddConceptRel (v_data_in in clob, v_data_out out clob);
procedure spCreateVerNCI (v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure getConcatNmDef(v_item_id in number, v_ver_nr in number, v_nm out varchar2, v_long_nm out varchar2,v_def out varchar2);
procedure spCopyModuleNCI (actions in out t_actions, v_from_module_id in number,v_from_module_ver in number,  v_from_form_id in number, v_from_form_ver number, v_to_form_id number, v_to_form_ver number);

function getItemId return integer;
procedure CncptCombExists (v_nm in varchar2, v_item_typ in integer, v_item_id out number, v_item_ver_nr out number, v_long_nm out varchar2, v_def out varchar2);

END;

create or replace PACKAGE BODY nci_11179 AS

v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
type       t_orgs is table of org_cntct.org_id%type;

/***********************************************/
FUNCTION CMR_GUID RETURN VARCHAR2 IS
  /*
  ** Name: CMR_GUID
  ** Parameters: None
  ** Description: Wrapper function to format output from
  **              built-in function sys.standard.sys_guid
  ** Change History:
  ** SAlred   4/25/2000   Initial Version; final format is TBD
  ** SAlred   4/28/2000   Added formatting according to standard
  **                      referenced on Microsoft web site.
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

function getItemId return integer is
v_out integer;
begin
select od_seq_ADMIN_ITEM.nextval  into v_out from dual;
return v_out;
end;

FUNCTION getWordCount (v_nm IN varchar2) RETURN integer IS
    V_OUT   Integer;
  BEGIN
  v_out := REGEXP_COUNT( v_nm, '\s');
  
    RETURN V_OUT;
  END;

procedure CncptCombExists (v_nm in varchar2, v_item_typ in integer, v_item_id out number, v_item_ver_nr out number, v_long_nm out varchar2, v_def out varchar2)
as
v_out integer;
begin

for cur in (select ext.* from nci_admin_item_ext ext,admin_item a where nvl(a.fld_delete,0) = 0 and a.item_id = ext.item_id and a.ver_nr = ext.ver_nr and cncpt_concat = v_nm and a.admin_item_typ_id = v_item_typ) loop
 v_item_id := cur.item_id;
 v_item_ver_nr := cur.ver_nr;
v_long_nm := cur.cncpt_concat_nm;
v_def := cur.cncpt_concat_def;
  end loop;


end;


function getWord(v_nm in varchar2, v_idx in integer, v_max in integer) return varchar2 is
   v_word  varchar2(100);
  BEGIN
  
  if (v_idx = 1) then
   v_word := substr(v_nm, 1, instr(v_nm, ' ',1,1)-1);
  elsif (v_idx = v_max) then
     v_word := substr(v_nm, instr(v_nm, ' ',1,v_idx-1)+1);
  else
     v_word := substr(v_nm, instr(v_nm, ' ',1,v_idx-1)+1,instr(v_nm, ' ',1,v_idx)-instr(v_nm, ' ',1,v_idx-1));

  end if;
  
    RETURN trim(upper(v_word));
  END;


procedure getConcatNmDef(v_item_id in number, v_ver_nr in number, v_nm out varchar2, v_long_nm out varchar2,v_def out varchar2) as
begin
for cur in (select cncpt_concat , cncpt_concat_nm , cncpt_concat_def  from nci_admin_item_ext where item_id = v_item_id and ver_nr = v_ver_nr and fld_delete <> 0) loop
v_nm := cur.cncpt_concat;
v_long_nm := cur.cncpt_concat_nm;
v_def := cur.cncpt_concat_def;
end loop;
end;


FUNCTION get_concepts(v_item_id in number, v_ver_nr in number) return varchar2 is
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


 Function get_concept_order(v_item_id in number, v_ver_nr in number) return varchar2 is

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

end get_concept_order;

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


PROCEDURE spAddToCart
  (
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
    select count(*) into v_temp from nci_usr_cart where item_id  = v_item_id and ver_nr = v_ver_nr and cntct_secu_id = v_user_id;
 --   raise_application_error(-20000, v_temp);

    if (v_temp = 0) then
    row := t_row();
    v_add := v_add + 1;
    ihook.setColumnValue(row,'ITEM_ID', v_item_id);
    ihook.setColumnValue(row,'VER_NR', v_ver_nr);
     ihook.setColumnValue(row,'CNTCT_SECU_ID', v_user_id);
    rows.extend;
    rows(rows.last) := row;
    else v_already := v_already + 1;
    end if;
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

PROCEDURE spRemoveFromCart
  (
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
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_temp integer;
  v_item_id varchar2(50);
  v_ver_nr varchar2(50);

  i integer := 0;
  column  t_column;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  rows := t_rows();

   for i in 1..hookinput.originalrowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);

    if (v_user_id <> ihook.getColumnValue(row_ori,'CNTCT_SECU_ID')) then
    raise_application_error(-20000, 'You are not authorized to delete from another user cart');
    end if;

    rows.extend;
    rows(rows.last) := row_ori;


end loop;
    action := t_actionrowset(rows, 'NCI_USR_CART', 1,0,'delete');
    actions.extend;
    actions(actions.last) := action;

    action := t_actionrowset(rows, 'NCI_USR_CART', 1,1,'purge');
    actions.extend;
    actions(actions.last) := action;

    hookoutput.actions := actions;
hookoutput.message := 'Item(s) successfully deleted from cart';    




  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spAddConceptRel
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
    action := t_actionrowset(rowsvv, 'NCI_QUEST_VALID_VALUE', 1,16,'insert');
   -- actions.extend;
   -- actions(actions.last) := action;
  end if;
   
end;


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
    ihook.setColumnValue(row, 'ITEM_NM',v_to_module_id);
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
    ihook.setColumnValue(row, 'disp_ord',0);

     action_rows := t_rows();
    
    action_rows.extend; action_rows(action_rows.last) := row;
    action := t_actionRowset(action_rows, 'Form-Module Relationship', 2, 12, 'insert');
    actions.extend; actions(actions.last) := action;


-- Questions
  spCopyQuestion(actions, v_from_module_id, v_from_module_ver, v_to_module_id, v_to_form_ver);
 
--raise_application_error(-20000,'Here'|| v_from_module_id || '   ' || v_to_module_id || '  ' || actions.count);



end;
/***********************************************/

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


--Alt names

 action_rows := t_rows();
 action_rows_csi := t_rows();
  v_table_name := 'ALT_NMS';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

  for an_cur in
  (select nm_id from alt_nms where 
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
      action_rows.extend; action_rows(action_rows.last) := row;
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

-- Alternate Definitions

 action_rows := t_rows();

  v_table_name := 'ALT_DEF';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

  for ad_cur in
  (select def_id from alt_def where 
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

--- Reference Documents

 action_rows := t_rows();

  v_table_name := 'REF';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

  for ref_cur in
  (select ref_id from ref where 
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
      ihook.setColumnValue(row, 'VER_NR', v_version);
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 14, 'insert');
     actions.extend; actions(actions.last) := action;


 action_rows := t_rows();

-- Concepts

  v_table_name := 'CNCPT_ADMIN_ITEM';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

  for ref_cur in
  (select CNCPT_AI_ID from CNCPT_ADMIN_ITEM where 
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



--- Classifications

 action_rows := t_rows();

  v_table_name := 'NCI_ALT_KEY_ADMIN_ITEM_REL';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

  for ref_cur in
  (select NCI_PUB_ID,NCI_VER_NR, REL_TYP_ID from NCI_ALT_KEY_ADMIN_ITEM_REL where 
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
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, 'NCI_ALT_KEY_ADMIN_ITEM_REL (Hook)',2, 15, 'insert');
    actions.extend; actions(actions.last) := action;

end;
/***********************************************/


procedure spCreateSubtypeVerNCI (actions in out t_actions, v_admin_item admin_item%rowtype, v_version number) as

/*

creates version for subtype - called from spCreateVer

*/

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

    action_rows.extend; action_rows(action_rows.last) := row;
    action := t_actionRowset(action_rows, v_table_name, 10, 'insert');
    actions.extend; actions(actions.last) := action;



 if v_admin_item.admin_item_typ_id = 3 then -- Add Perm Val

  action_rows := t_rows();

  v_table_name := 'PERM_VAL';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

   for pv_cur in
  (select val_id from perm_val where 
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
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 11, 'insert');
     actions.extend; actions(actions.last) := action;

 end if;

 
 
 if v_admin_item.admin_item_typ_id = 1 then -- Conceptual Domain then add CD-VM relationship

  action_rows := t_rows();

  v_table_name := 'CONC_DOM_VAL_MEAN';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

   for cdvm_cur in
  (select CONC_DOM_VER_NR, CONC_DOM_ITEM_ID, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR from conc_dom_val_mean where 
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
 

if v_admin_item.admin_item_typ_id = 4 then -- DE then add Derived DE components

  action_rows := t_rows();

  v_table_name := 'NCI_ADMIN_ITEM_REL';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

   for de_cur in
  (select P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID from NCI_ADMIN_ITEM_REL where 
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

 if v_admin_item.admin_item_typ_id = 54 then -- Add Modules
     for cur2 in (select c_item_id, c_item_ver_nr from nci_admin_item_rel where p_item_id = v_admin_item.item_id and p_item_ver_nr = v_admin_item.item_id) loop
        nci_11179.spCopyModuleNCI(actions, cur2.c_item_id, cur2.c_item_ver_nr, v_admin_item.item_id, v_admin_item.item_id, v_admin_item.item_id, v_version);   
     end loop;
     
end if;
end;

procedure spCreateVerNCI (v_data_in in clob, v_data_out out clob, v_user_id varchar2) as

/*

1. if latest_ver is 0 then "Cannot create version if the Administered Item is not the latest version."
2. if registration is not "Standardized" then "Cannot create version for non-standard Administered Item."
3. create a new admin_item with ver_nr=ver_nr+1, registration status = RECORDED (2), and same values for other columns
4. update current admin_item to latest_version=0 and retire it

testing:

begin
spchangestatus('<ITEM_ID><![CDATA[1]]></ITEM_ID><VER_NR><![CDATA[1]]></VER_NR>');
end;

*/

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
 
 v_tab_admin_item := template_11179.getParsedAdminItemsData(hookInput.originalRowset);

        select * into v_admin_item from admin_item
        where item_id=v_tab_admin_item(1).item_id and ver_nr=v_tab_admin_item(1).ver_nr
  for update nowait;

     if v_admin_item.currnt_ver_ind = 0 then
            hookOutput.message := 'Cannot create version if the Administered Item is not the latest version.';
            v_data_out := ihook.getHookOutput(hookOutput);
   return;
     end if;

        if (v_admin_item.regstr_stus_id is null) then
      hookOutput.message := 'Cannot create version for Administered Items with no Registration Status assigned.';
            v_data_out := ihook.getHookOutput(hookOutput);
   return;
   
     end if;
    if hookInput.invocationNumber = 0 then
    if (v_admin_item.admin_item_typ_id in (50,51,52,53,56)) then
     raise_application_error(-20000, 'Administered Item of this type cannot be versioned.');
    end if;
    
            ANSWERS                    := T_ANSWERS();
            ANSWER                     := T_ANSWER(1, 1, 'Create Version.' );
            ANSWERS.EXTEND;
            ANSWERS(ANSWERS.LAST) := ANSWER;
            QUESTION               := T_QUESTION('Specify Version. Current version is:' || ihook.getColumnValue(row_ori,'VER_NR' ) , ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
    --start
    --action_row := t_row();
    --ihook.setColumnValue(action_row, 'ITEM_TYP', 5);
    --ihook.setColumnValue(action_row, 'NAME', 'Name_5');
    --ihook.setColumnValue(action_row, 'ADDRESS', 'ADDRESS_5');
    --action_rows.extend; action_rows(action_rows.last) := action_row;  
    --rowset := t_rowset(action_rows, hookInput.originalRowset.objectName, 1, hookInput.originalRowset.tableName);
    
    --end
    forms                  := t_forms();
    form1                  := t_form('Version Creation', 2,1);
    --form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;	   
	elsif hookInput.invocationNumber = 1 then
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

     ihook.setColumnValue(row, 'VER_NR', v_version);
  ihook.setColumnValue(row, 'CREAT_USR_ID', hookInput.userId);
  ihook.setColumnValue(row, 'LST_UPD_USR_ID', hookInput.userId);

        ai_insert_action_rows.extend; ai_insert_action_rows(ai_insert_action_rows.last) := row;

     row := t_row();
     ihook.setColumnValue(row, 'ITEM_ID', v_admin_item.item_id);
     ihook.setColumnValue(row, 'VER_NR', v_admin_item.ver_nr);
--     ihook.setColumnValue(row, 'REGSTR_STUS_ID', 5); -- removed for FAA
     ihook.setColumnValue(row, 'CURRNT_VER_IND', 0);
        ai_update_action_rows.extend; ai_update_action_rows(ai_update_action_rows.last) := row;

        row := t_row();
     ihook.setColumnValue(row, 'LOG_ID', -1); -- sequence column
     ihook.setColumnValue(row, 'ITEM_ID', v_admin_item.item_id);
     ihook.setColumnValue(row, 'VER_NR', v_admin_item.ver_nr);
     ihook.setColumnValue(row, 'CHNG_TYP_ID', 48);
     ihook.setColumnValue(row, 'CHNG_DESC', 'Version ' || v_version || ' created.');
     ihook.setColumnValue(row, 'LST_UPD_USR_ID', v_user_id);
        ai_audit_action_rows.extend; ai_audit_action_rows(ai_audit_action_rows.last) := row;

  spCreateSubtypeVerNCI(actions, v_admin_item, v_version);
  spCreateCommonChildrenNCI(actions, v_admin_item, v_version);

 action := t_actionRowset(ai_insert_action_rows, 'ADMIN_ITEM', 0, 'insert');
    actions.extend; actions(actions.last) := action;

 action := t_actionRowset(ai_update_action_rows, 'ADMIN_ITEM', 0, 'update');
    actions.extend; actions(actions.last) := action;

    action := t_actionRowset(ai_audit_action_rows, 'ADMIN_ITEM_AUDIT', 0, 'insert');
    actions.extend; actions(actions.last) := action;

 hookOutput.actions := actions;

    hookOutput.message := 'Version created successfully.';
    end if;
end if;

    v_data_out := ihook.getHookOutput(hookOutput);
end;


END;
/

