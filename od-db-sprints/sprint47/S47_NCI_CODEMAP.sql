create or replace PACKAGE            nci_codemap AS
  procedure spGenerateMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spGenerateValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
    procedure spGenerateModelView ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCreateEntityRel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure getModelAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in out number);
  procedure spCreateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCompareModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure getModelElementAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in number, v_mdl_elmnt_id in out number);
 procedure getModelElementCharAction ( row_ori in out t_row, rowschar in out t_rows, v_mdl_elmnt_id in number);


END;
/
create or replace PACKAGE BODY            nci_codemap AS
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
  v_reg_str varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}';
  v_reg_str_adv varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}|\s';
  
  procedure getModelAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in out number)
  as
  action t_actionRowset;
  row t_row;
  rows  t_rows;
 v_temp integer;
  begin
 

select count(*) into v_temp from admin_item where admin_item_typ_id = 57 and upper(item_nm) = upper(ihook.getColumnvalue(row_ori, 'SRC_MDL_NM') )
and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
rows := t_rows();
if (v_temp = 0) then -- new model
row := t_row();
nci_11179_2.setStdAttr(row);
v_mdl_hdr_id := nci_11179.getItemId;
ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 57);
ihook.setColumnValue(row,'VER_NR',ihook.getColumnvalue(row_ori, 'SRC_VER_NR'));
ihook.setColumnValue(row,'ITEM_NM',ihook.getColumnvalue(row_ori, 'SRC_MDL_NM'));
ihook.setColumnValue(row,'ITEM_ID',v_mdl_hdr_id);
ihook.setColumnValue(row,'CNTXT_ITEM_ID',20000000011);
ihook.setColumnValue(row,'CNTXT_VER_NR',1);
     rows.extend;
                                            rows(rows.last) := row;

 
            action := t_actionrowset(rows, 'Model AI', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
      action := t_actionrowset(rows, 'Model', 2,4,'insert');
        actions.extend;
        actions(actions.last) := action;


else
select item_id into v_mdl_hdr_id from admin_item where admin_item_typ_id = 57 and upper(item_nm) = upper(ihook.getColumnvalue(row_ori, 'SRC_MDL_NM') );
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
end if;

 
 end;
 
  procedure getModelElementCharAction ( row_ori in out t_row, actions in out t_actions, v_mdl_elmnt_id in number)
  as
  action t_actionRowset;
  row t_row;
  rows  t_rows;
 v_temp integer;
  begin
 

select count(*) into v_temp from admin_item where admin_item_typ_id = 57 and upper(item_nm) = upper(ihook.getColumnvalue(row_ori, 'SRC_MDL_NM') );
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
rows := t_rows();
if (v_temp = 0) then -- new model
row := t_row();
nci_11179_2.setStdAttr(row);
end if;

 
 end;
 
  
 procedure getModelElementAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in number, v_mdl_elmnt_id in out number)
  as
  action t_actionRowset;
  row t_row;
  rows  t_rows;
 v_temp integer;
  rowschar  t_rows;
  begin
 

for cur in (select * from NCI_STG_MDL_ELMNT where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') ) loop

select count(*) into v_temp from NCI_MDL_ELMNT where upper(item_LONG_nm) = upper(cur.ITEM_LONG_NM) and mdl_item_id = v_mdl_hdr_id and mdl_item_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
rows := t_rows();
rowschar := t_rows();
if (v_temp = 0) then -- new characteristics
v_mdl_elmnt_id := nci_11179.getItemId;
row := t_row();
ihook.setColumnValue(row,'ITEM_ID', 57);
ihook.setColumnValue(row,'VER_NR',ihook.getColumnvalue(row_ori, 'SRC_VER_NR'));
ihook.setColumnValue(row,'MDL_ITEM_ID',v_mdl_hdr_id);
ihook.setColumnValue(row,'MDL_ITEM_VER_NR',ihook.getColumnvalue(row_ori, 'SRC_VER_NR'));
ihook.setColumnValue(row,'ITEM_LONG_NM',cur.ITEM_LONG_NM);
ihook.setColumnValue(row,'ITEM_PHY_OBJ_NM',cur.ITEM_PHY_OBJ_NM);
ihook.setColumnValue(row,'ITEM_DESC',cur.ITEM_DESC);
     rows.extend;
                                            rows(rows.last) := row;


else
select item_id into v_mdl_elmnt_id from NCI_MDL_ELMNT where upper(item_LONG_nm) = upper(cur.ITEM_LONG_NM) and mdl_item_id = v_mdl_hdr_id and mdl_item_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');

end if;

end loop;

 
            action := t_actionrowset(rows, 'Model AI', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
      action := t_actionrowset(rows, 'Model', 2,4,'insert');
        actions.extend;
        actions(actions.last) := action;
 
 end;
 
   procedure spCreateEntityRel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
 i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  getModelAction(row_ori,actions, v_mdl_hdr_id);
--  raise_application_error(-20000,v_mdl_hdr_id);
 
  for cur in (select p.item_id prnt_item_id, p.ver_nr prnt_item_ver_nr, c.item_id chld_item_id, c.ver_nr  chld_item_ver_nr, r.PRNT_MDL_ELMNT_LONG_NM,
  r.CHLD_MDL_ELMNT_LONG_NM from NCI_STG_MDL_ELMNT_REL r, nci_mdl_elmnt p,  nci_mdl_elmnt c
  where r.mdl_imp_id = ihook.getColumnValue(row_ori,'MDL_IMP_ID') and p.mdl_item_id = v_mdl_hdr_id and c.mdl_item_id = v_mdl_hdr_id 
 -- and p.mdl_item_ver_nr  = ihook.getColumnValue(row_ori,'SRC_VER_NR')and c.mdl_item_ver_nr  = ihook.getColumnValue(row_ori,'SRC_VER_NR')
  and p.ITEM_LONG_NM=r.PRNT_MDL_ELMNT_LONG_NM and c.item_long_nm = r.chld_MDL_ELMNT_LONG_NM
  and (p.item_id , p.ver_nr , c.item_id , c.ver_nr) not in (select prnt_item_id, prnt_item_ver_nr, chld_item_id, chld_item_ver_nr from NCI_MDL_ELMNT_REL)) loop
    row := t_row();
    ihook.setColumnValue(row,'REL_TYP_ID',77);
    ihook.setColumnValue(row,'PRNT_ITEM_ID',cur.PRNT_ITEM_ID);
    ihook.setColumnValue(row,'PRNT_ITEM_VER_NR',cur.PRNT_ITEM_VER_NR);
     ihook.setColumnValue(row,'CHLD_ITEM_ID',cur.CHLD_ITEM_ID);
    ihook.setColumnValue(row,'CHLD_ITEM_VER_NR',cur.CHLD_ITEM_VER_NR);
    ihook.setColumnValue(row,'REL_ID',-1);
    
    rows.extend;   rows(rows.last) := row;
  end loop;
 -- raise_application_error (-20000,'Here');
  if (rows.count>0) then
   action := t_actionrowset(rows, 'Model Element Relationship', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    end if;

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


   procedure spCreateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
 i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  getModelAction(row_ori,actions, v_mdl_hdr_id);
--  raise_application_error(-20000,v_mdl_hdr_id);
 
  for cur in (select p.item_id prnt_item_id, p.ver_nr prnt_item_ver_nr, c.item_id chld_item_id, c.ver_nr  chld_item_ver_nr, r.PRNT_MDL_ELMNT_LONG_NM,
  r.CHLD_MDL_ELMNT_LONG_NM from NCI_STG_MDL_ELMNT_REL r, nci_mdl_elmnt p,  nci_mdl_elmnt c
  where r.mdl_imp_id = ihook.getColumnValue(row_ori,'MDL_IMP_ID') and p.mdl_item_id = v_mdl_hdr_id and c.mdl_item_id = v_mdl_hdr_id 
 -- and p.mdl_item_ver_nr  = ihook.getColumnValue(row_ori,'SRC_VER_NR')and c.mdl_item_ver_nr  = ihook.getColumnValue(row_ori,'SRC_VER_NR')
  and p.ITEM_LONG_NM=r.PRNT_MDL_ELMNT_LONG_NM and c.item_long_nm = r.chld_MDL_ELMNT_LONG_NM
  and (p.item_id , p.ver_nr , c.item_id , c.ver_nr) not in (select prnt_item_id, prnt_item_ver_nr, chld_item_id, chld_item_ver_nr from NCI_MDL_ELMNT_REL)) loop
    row := t_row();
    ihook.setColumnValue(row,'REL_TYP_ID',77);
    ihook.setColumnValue(row,'PRNT_ITEM_ID',cur.PRNT_ITEM_ID);
    ihook.setColumnValue(row,'PRNT_ITEM_VER_NR',cur.PRNT_ITEM_VER_NR);
     ihook.setColumnValue(row,'CHLD_ITEM_ID',cur.CHLD_ITEM_ID);
    ihook.setColumnValue(row,'CHLD_ITEM_VER_NR',cur.CHLD_ITEM_VER_NR);
    ihook.setColumnValue(row,'REL_ID',-1);
    
    rows.extend;   rows(rows.last) := row;
  end loop;
 -- raise_application_error (-20000,'Here');
  if (rows.count>0) then
   action := t_actionrowset(rows, 'Model Element Relationship', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    end if;

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


   procedure spCompareModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
 i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  getModelAction(row_ori,actions, v_mdl_hdr_id);
--  raise_application_error(-20000,v_mdl_hdr_id);
 
  for cur in (select p.item_id prnt_item_id, p.ver_nr prnt_item_ver_nr, c.item_id chld_item_id, c.ver_nr  chld_item_ver_nr, r.PRNT_MDL_ELMNT_LONG_NM,
  r.CHLD_MDL_ELMNT_LONG_NM from NCI_STG_MDL_ELMNT_REL r, nci_mdl_elmnt p,  nci_mdl_elmnt c
  where r.mdl_imp_id = ihook.getColumnValue(row_ori,'MDL_IMP_ID') and p.mdl_item_id = v_mdl_hdr_id and c.mdl_item_id = v_mdl_hdr_id 
 -- and p.mdl_item_ver_nr  = ihook.getColumnValue(row_ori,'SRC_VER_NR')and c.mdl_item_ver_nr  = ihook.getColumnValue(row_ori,'SRC_VER_NR')
  and p.ITEM_LONG_NM=r.PRNT_MDL_ELMNT_LONG_NM and c.item_long_nm = r.chld_MDL_ELMNT_LONG_NM
  and (p.item_id , p.ver_nr , c.item_id , c.ver_nr) not in (select prnt_item_id, prnt_item_ver_nr, chld_item_id, chld_item_ver_nr from NCI_MDL_ELMNT_REL)) loop
    row := t_row();
    ihook.setColumnValue(row,'REL_TYP_ID',77);
    ihook.setColumnValue(row,'PRNT_ITEM_ID',cur.PRNT_ITEM_ID);
    ihook.setColumnValue(row,'PRNT_ITEM_VER_NR',cur.PRNT_ITEM_VER_NR);
     ihook.setColumnValue(row,'CHLD_ITEM_ID',cur.CHLD_ITEM_ID);
    ihook.setColumnValue(row,'CHLD_ITEM_VER_NR',cur.CHLD_ITEM_VER_NR);
    ihook.setColumnValue(row,'REL_ID',-1);
    
    rows.extend;   rows(rows.last) := row;
  end loop;
 -- raise_application_error (-20000,'Here');
  if (rows.count>0) then
   action := t_actionrowset(rows, 'Model Element Relationship', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    end if;

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

  PROCEDURE spGenerateModelView
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
  v_item_typ  integer;
  v_mod_specified boolean;
  v_cart_nm varchar2(255);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);


	    rows :=         t_rows();
		v_found := false;

	/*    for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id in (52, 54 ) and cart_nm = v_cart_nm order by admin_item_typ_id) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   iHook.setcolumnvalue (ROW, 'CNTCT_SECU_ID', v_user_id);
		   iHook.setcolumnvalue (ROW, 'CART_NM', v_cart_nm);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;
*/

row := t_row();
ihook.setColumnValue(row, 'Level 1','Test');

 rows.extend;
		   rows (rows.last) := row;
row := t_row();
ihook.setColumnValue(row, 'Level 1','Test');
ihook.setColumnValue(row, 'Level 2','Test Level 2');

 rows.extend;
		   rows (rows.last) := row;
row := t_row();
ihook.setColumnValue(row, 'Level 1','Test');
ihook.setColumnValue(row, 'Level 2','Test Level 2');
ihook.setColumnValue(row, 'Level 3','Test Level 3');

 rows.extend;
		   rows (rows.last) := row;

	      showRowset := t_showableRowset(rows, 'Model View',4, 'unselectable');
    hookOutput.showRowset := showRowset;

   V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end; 

procedure spGenerateMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_val_dom_typ integer;
    v_ver_nr number(4,2);
    v_temp integer;
    v_hdr_id number;
    v_already integer :=0;
    i integer := 0;
    v_flt_str  varchar2(1000);
    v_sql varchar2(4000);
    v_entty_nm varchar2(255);
    v_entty_nm_like varchar2(255);
    v_cntxt_str varchar2(255);
    v_cnt integer;
    v_str varchar2(255);
    v_minlen integer;
    v_entty_nm_with_space varchar2(255);
--    v_reg_str varchar2(255);
 -- v_entty_nm varchar2(4000);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   
--hookoutput.message := 'Work in progress.';
        row_ori := hookInput.originalRowset.rowset(1);
  
    delete from NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR');
    commit;
    delete from onedata_ra.NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR');
    commit;
    
    rows := t_rows();
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mec2.MEC_LONG_NM TGT_MEC_LONG_NM, mec2.mec_id TGT_MEC_ID
from nci_mdl_elmnt me1, nci_mdl_elmnt me2, nci_mdl_elmnt_char mec1, nci_mdl_elmnt_char mec2, NCI_MDL_MAP mm
where 
--nvl(me1.DOM_ITEM_ID,1) = nvl(me2.DOM_ITEM_ID,1) and nvl(me1.DOM_VER_NR,1) = nvl(me2.DOM_VER_NR,1)
--and 
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR and me2.mdl_item_id = mm.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and mec1.DE_CONC_ITEM_ID = mec2.DE_CONC_ITEM_ID and mec1.DE_CONC_VER_NR = mec2.DE_CONC_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR')) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.tgt_mec_id);
        ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue (row_ori,'VER_NR'));
        ihook.setColumnValue(row,'MECM_ID',-1);
        
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
    
            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
  hookoutput.actions := actions;
  
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


procedure spGenerateValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    input_rows t_rows;
    output_rows t_rows;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);
    
    input_rows := t_rows();
    output_rows := t_rows();
    
    for cur in (select val_dom_item_id, val_dom_ver_nr from nci_mdl_elmnt_char where mec_id = ihook.getColumnValue(row_ori,'SRC_MEC_ID')) loop
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
      input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;
    
    for cur in (select val_dom_item_id, val_dom_ver_nr from nci_mdl_elmnt_char where mec_id = ihook.getColumnValue(row_ori,'TGT_MEC_ID')) loop
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
      input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;
    
  --  raise_application_error(-20000, 'Test' || input_rows.count);
   
    nci_11179_2.spCreateValueMap(input_rows, output_rows);
    
    delete from NCI_MEC_VAL_MAP where src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID');
    commit;
    delete from onedata_ra.NCI_MEC_VAL_MAP where src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID');
    commit;
    
    rows := t_rows();
    for i in 1..output_rows.count loop
        row := row_ori;
        ihook.setColumnValue(row,'SRC_PV',ihook.getColumnValue(output_rows(i),'1'));
        ihook.setColumnValue(row,'TGT_PV',ihook.getColumnValue(output_rows(i),'2'));
        ihook.setColumnValue(row,'VM_CNCPT_CD',ihook.getColumnValue(output_rows(i),'VM Concept Codes'));
        ihook.setColumnValue(row,'VM_CNCPT_NM',ihook.getColumnValue(output_rows(i),'VM Name'));
        ihook.setColumnValue(row,'MECVM_ID',-1);
        
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
            action := t_actionrowset(rows, 'Model Map Characteristic Values', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
  hookoutput.actions := actions;
  
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  
end;

END;
/
