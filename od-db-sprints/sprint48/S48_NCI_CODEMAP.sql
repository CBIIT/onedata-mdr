create or replace PACKAGE            nci_codemap AS
  procedure spGenerateMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spAddManualMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spGenerateValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
    procedure spGenerateModelView ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCreateEntityRel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure getModelAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in out number);
  procedure spCreateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spValidateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spVersionModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spVersionModelMapping ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCompareModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCreateMapGroup ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure getModelElementAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in number, v_mdl_elmnt_id in out number);
 procedure getModelElementCharAction ( row_ori in out t_row, rowschar in out t_rows, v_mdl_elmnt_id in number, v_mdl_elmnt_long_nm in varchar2);


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
and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_MDL_VER') ;
rows := t_rows();
row := t_row();
nci_11179_2.setStdAttr(row);
ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 57);
ihook.setColumnValue(row,'VER_NR',ihook.getColumnvalue(row_ori, 'SRC_MDL_VER'));
ihook.setColumnValue(row,'ITEM_NM',ihook.getColumnvalue(row_ori, 'SRC_MDL_NM'));
ihook.setColumnValue(row,'PRMRY_MDL_LANG_ID',ihook.getColumnvalue(row_ori, 'PRMRY_MDL_LANG_ID'));
ihook.setColumnValue(row,'MDL_TYP_ID',ihook.getColumnvalue(row_ori, 'MDL_TYP_ID'));
ihook.setColumnValue(row,'ITEM_LONG_NM',v_mdl_hdr_id);
ihook.setColumnValue(row,'CNTXT_ITEM_ID',20000000011);
ihook.setColumnValue(row,'CNTXT_VER_NR',1);
ihook.setColumnValue(row,'ITEM_DESC',nvl(ihook.getColumnvalue(row_ori, 'SRC_MDL_DESC'),ihook.getColumnvalue(row_ori, 'SRC_MDL_NM')));

if (v_temp = 0) then -- new model
v_mdl_hdr_id := nci_11179.getItemId;
ihook.setColumnValue(row,'ITEM_ID',v_mdl_hdr_id);
     rows.extend;
                                            rows(rows.last) := row;
            action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
      action := t_actionrowset(rows, 'Model', 2,4,'insert');
        actions.extend;
        actions(actions.last) := action;

else
select max(item_id) into v_mdl_hdr_id from admin_item where admin_item_typ_id = 57 and upper(item_nm) = upper(ihook.getColumnvalue(row_ori, 'SRC_MDL_NM'))
and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_MDL_VER') ;
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
ihook.setColumnValue(row, 'ITEM_ID', v_mdl_hdr_id);
     rows.extend;
                                            rows(rows.last) := row;
     action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,2,'update');
        actions.extend;
        actions(actions.last) := action;
      action := t_actionrowset(rows, 'Model', 2,4,'update');
        actions.extend;
        actions(actions.last) := action;

end if;

 
 end;
 
 procedure getModelElementCharAction ( row_ori in out t_row, rowschar in out t_rows,   v_mdl_elmnt_id in number, v_mdl_elmnt_long_nm in varchar2)
 as
  action t_actionRowset;
  row t_row;
  rows  t_rows;
 v_temp integer;
 v_mdl_elmnt_char_id number;
  begin
 


for cur in (select * from NCI_STG_MDL_ELMNT_CHAR where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and upper(me_item_long_nm) = upper(v_mdl_elmnt_long_nm)) loop

select count(*) into v_temp from NCI_MDL_ELMNT_CHAR where upper(mec_LONG_nm) = upper(cur.MEC_LONG_NM) and mdl_elmnt_item_id = v_mdl_elmnt_id and mdl_elmnt_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
if (v_temp = 0) then -- new characteristics
row := t_row();
ihook.setColumnValue(row,'MEC_ID', -1);
--ihook.setColumnValue(row,'MDL_ITEM_ID',v_mdl_hdr_id);
ihook.setColumnValue(row,'MDL_ELMNT_ITEM_ID',v_mdl_elmnt_id);
ihook.setColumnValue(row,'MDL_ELMNT_VER_NR',ihook.getColumnvalue(row_ori, 'SRC_MDL_VER'));
--ihook.setColumnValue(row,'MEC_TYP_ID',v_mdl_elmnt_id);
ihook.setColumnValue(row,'SRC_DTTYPE',cur.SRC_DTTYPE);
ihook.setColumnValue(row,'STD_DTTYPE_ID',cur.STD_DTTYPE_ID);
ihook.setColumnValue(row,'SRC_MAX_CHAR',cur.SRC_MAX_CHAR);
ihook.setColumnValue(row,'SRC_MIN_CHAR',cur.SRC_MIN_CHAR);
ihook.setColumnValue(row,'SRC_UOM',cur.SRC_UOM);
ihook.setColumnValue(row,'UOM_ID',cur.UOM_ID);
ihook.setColumnValue(row,'SRC_DEFLT_VAL',cur.SRC_DEFLT_VAL);
ihook.setColumnValue(row,'SRC_ENUM_SRC',cur.SRC_ENUM_SRC);
ihook.setColumnValue(row,'MEC_LONG_NM',cur.MEC_LONG_NM);
ihook.setColumnValue(row,'MEC_PHY_NM',cur.MEC_PHY_NM);
ihook.setColumnValue(row,'MEC_DESC',cur.MEC_DESC);
ihook.setColumnValue(row,'CDE_ITEM_ID',cur.CDE_ITEM_ID);
ihook.setColumnValue(row,'CDE_VER_NR',cur.CDE_VER_NR);
ihook.setColumnValue(row,'DE_CONC_ITEM_ID',cur.DE_CONC_ITEM_ID);
ihook.setColumnValue(row,'DE_CONC_VER_NR',cur.DE_CONC_VER_NR);
ihook.setColumnValue(row,'VAL_DOM_ITEM_ID',cur.VAL_DOM_ITEM_ID);
ihook.setColumnValue(row,'VAL_DOM_VER_NR',cur.VAL_DOM_VER_NR);
  rowschar.extend;
                                           rowschar(rowschar.last) := row;

end if;
end loop;
 
 end;
 
  
 procedure getModelElementAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in number, v_mdl_elmnt_id in out number)
  as
  action t_actionRowset;
  row t_row;
  rowsme  t_rows;
 v_temp integer;
  rowschar  t_rows;
  begin
 

rowschar := t_rows();
rowsme := t_rows();

for cur in (select * from NCI_STG_MDL_ELMNT where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') ) loop

select count(*) into v_temp from NCI_MDL_ELMNT where upper(item_LONG_nm) = upper(cur.ITEM_LONG_NM) and mdl_item_id = v_mdl_hdr_id and mdl_item_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
if (v_temp = 0) then -- new characteristics
v_mdl_elmnt_id := nci_11179.getItemId;
row := t_row();
ihook.setColumnValue(row,'ITEM_ID', v_mdl_elmnt_id);
ihook.setColumnValue(row,'VER_NR',ihook.getColumnvalue(row_ori, 'SRC_MDL_VER'));
ihook.setColumnValue(row,'MDL_ITEM_ID',v_mdl_hdr_id);
ihook.setColumnValue(row,'MDL_ITEM_VER_NR',ihook.getColumnvalue(row_ori, 'SRC_MDL_VER'));
ihook.setColumnValue(row,'ITEM_LONG_NM',cur.ITEM_LONG_NM);
ihook.setColumnValue(row,'DOM_ITEM_ID',cur.DOM_ITEM_ID);
ihook.setColumnValue(row,'DOM_VER_NR',cur.DOM_VER_NR);
ihook.setColumnValue(row,'ITEM_PHY_OBJ_NM',cur.ITEM_PHY_OBJ_NM);
ihook.setColumnValue(row,'ITEM_DESC',cur.ITEM_DESC);
ihook.setColumnValue(row,'ME_TYP_ID',2341); -- temporary

     rowsme.extend;
                                            rowsme(rowsme.last) := row;


else
select item_id into v_mdl_elmnt_id from NCI_MDL_ELMNT where upper(item_LONG_nm) = upper(cur.ITEM_LONG_NM) and mdl_item_id = v_mdl_hdr_id and mdl_item_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');

end if;
getModelElementCharAction ( row_ori, rowschar , v_mdl_elmnt_id, cur.item_long_nm);

end loop;
            action := t_actionrowset(rowsme, 'Model Element (No Sequence)', 2,5,'insert');
        actions.extend;
        actions(actions.last) := action;

           action := t_actionrowset(rowschar, 'Model Element Characteristics', 2,10,'insert');
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
  v_mdl_elmnt_id number;
 i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  getModelAction(row_ori,actions, v_mdl_hdr_id);
getModelElementAction ( row_ori ,actions , v_mdl_hdr_id , v_mdl_elmnt_id );
 
 -- raise_application_error(-20000,v_mdl_hdr_id);
 
 
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
    end if;
    
    rows := t_rows();
    ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','CREATED');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','Model created.');
  ihook.setColumnValue(row_ori, 'CREATED_MDL_ITEM_ID',v_mdl_hdr_id);
     rows.extend;   rows(rows.last) := row_ori;
 
   action := t_actionrowset(rows, 'Model Import Header', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
  
 
    
       hookoutput.actions := actions;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --nci_util.debugHook('GENERAL',v_data_out);
end;


   procedure spUpdateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
rowschar t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
 i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  rowschar := t_rows();
  
  
 update nci_stg_mdl_elmnt_char set (val_dom_item_id, val_dom_ver_nr) = (select val_dom_item_id, val_dom_ver_nr from de where 
 item_id = nci_stg_mdl_elmnt_char.cde_item_id and ver_nr = nci_stg_mdl_elmnt_char.cde_ver_nr )
  where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and cde_item_id is not null; 
  commit;

 update nci_stg_mdl_elmnt_char set (de_conc_item_id, de_conc_ver_nr) = (select de_conc_item_id, de_conc_ver_nr from de where 
 item_id = nci_stg_mdl_elmnt_char.cde_item_id and ver_nr = nci_stg_mdl_elmnt_char.cde_ver_nr )
  where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and cde_item_id is not null; 
  commit;
 
 /*
for curelmnt in (Select * from NCI_STG_MDL_ELMNT where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID')) loop
for cur in (select * from NCI_STG_MDL_ELMNT_CHAR where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and upper(me_item_long_nm) = upper(curelmnt.item_long_nm)) loop

for cur1 in (select * from NCI_MDL_ELMNT_CHAR where upper(mec_LONG_nm) = upper(cur.MEC_LONG_NM) and mdl_elmnt_item_id = curelmnt.item_ and mdl_elmnt_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER')) loop
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
row := t_row();
ihook.setColumnValue(row,'MEC_ID',cur1.MEC_ID);
ihook.setColumnValue(row,'CDE_ITEM_ID',cur.CDE_ITEM_ID);
ihook.setColumnValue(row,'CDE_VER_NR',cur.CDE_VER_NR);
ihook.setColumnValue(row,'DE_CONC_ITEM_ID',cur.DE_CONC_ITEM_ID);
ihook.setColumnValue(row,'DE_CONC_VER_NR',cur.DE_CONC_VER_NR);
ihook.setColumnValue(row,'VAL_DOM_ITEM_ID',cur.VAL_DOM_ITEM_ID);
ihook.setColumnValue(row,'VAL_DOM_VER_NR',cur.VAL_DOM_VER_NR);
  rowschar.extend;
                                           rowschar(rowschar.last) := row;

end loop;
end loop;
         action := t_actionrowset(rowschar, 'Model Element Characteristics', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
  */
    
    rows := t_rows();
    ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','UPDATED');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','Model updated - ' || sysdate);
  --ihook.setColumnValue(row_ori, 'CREATED_MDL_ITEM_ID',v_mdl_hdr_id);
     rows.extend;   rows(rows.last) := row_ori;
 
   action := t_actionrowset(rows, 'Model Import Header', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
  
 
    
       hookoutput.actions := actions;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --nci_util.debugHook('GENERAL',v_data_out);
end;

   procedure spValidateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
  v_mdl_elmnt_id number;
  v_valid boolean;
  v_val_stus_msg varchar2(2000);
 i integer;
 v_typ integer;
 v_dflt_typ integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  select obj_key_id into v_dflt_typ from obj_key where obj_typ_id = 41 and upper(obj_key_desc) = 'TABLE';
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_valid := true;
  v_val_stus_msg := '';
  rows := t_rows();
  
 if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'CREATED' or ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'UPDATED') then
  hookoutput.message := 'Created models cannot be validated';
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  return;
  end if;
 -- validate Primary Language and Model Type is set.
 /*if (ihook.getColumnValue(row_ori, 'PRMRY_MDL_LANG_ID') is null) then
    v_valid := false;
    v_val_stus_msg := v_val_stus_msg || 'Model: Primary Modelling Language is missing.' || chr(13);
end if;

 if (ihook.getColumnValue(row_ori, 'MDL_TYP_ID') is null) then
    v_valid := false;
    v_val_stus_msg := v_val_stus_msg || 'Model: Model Type is missing.' || chr(13);
end if;
*/
 -- validate ME type id else default Semantic Model - Class. Physical Model - Table
 
  for cur in (select * from nci_stg_mdl_elmnt where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and ME_TYP_ID is null) loop
     v_typ := v_dflt_typ;
     for cur1 in (select * from obj_key where obj_typ_id = 41 and upper(cur.me_typ_nm) = upper(obj_key_desc)) loop
       v_typ := cur1.obj_key_id;
    end loop;
    update nci_stg_mdl_elmnt set me_typ_id = v_typ where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and ITEM_LONG_NM = cur.ITEM_LONG_NM;
  end loop;
  commit;
 
 -- validate ME type id else default Semantic Model - Class. Physical Model - Table
 
 update nci_stg_mdl_elmnt_char set (val_dom_item_id, val_dom_ver_nr) = (select val_dom_item_id, val_dom_ver_nr from de where 
 item_id = nci_stg_mdl_elmnt_char.cde_item_id and ver_nr = nci_stg_mdl_elmnt_char.cde_ver_nr )
  where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and cde_item_id is not null; 
  commit;

 update nci_stg_mdl_elmnt_char set (de_conc_item_id, de_conc_ver_nr) = (select de_conc_item_id, de_conc_ver_nr from de where 
 item_id = nci_stg_mdl_elmnt_char.cde_item_id and ver_nr = nci_stg_mdl_elmnt_char.cde_ver_nr )
  where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and cde_item_id is not null; 
  commit;
  if (v_valid = false) then 
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','ERROR');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',v_val_stus_msg);
  else
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','VALIDATED');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','Valid');
  end if;
     rows.extend;   rows(rows.last) := row_ori;
 
   action := t_actionrowset(rows, 'Model Import Header', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
        
       hookoutput.actions := actions;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  -- nci_util.debugHook('GENERAL',v_data_out);
end;


 procedure spCreateMapGroup ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
 i integer;
 v_max integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
  row_ori :=  hookInput.originalRowset.rowset(1);
  
 select max(nvl(MEC_GRP_RUL_NBR,0))+1  into v_max from nci_mec_map where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') and MDL_MAP_VER_NR= ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR');
 
 for i in 1..hookinput.originalrowset.rowset.count loop 
  row_ori :=  hookInput.originalRowset.rowset(i);
  update nci_mec_map set MEC_GRP_RUL_NBR= v_max, DIRECT_TYP=119 where MECM_ID = ihook.getColumnValue(row_ori,'MECM_ID');
 end loop;
 commit;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  -- nci_util.debugHook('GENERAL',v_data_out);
end;

   procedure spCompareModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
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
 v_src_hdr_id integer;
 v_tgt_item_id number;
 v_tgt_ver_nr number(4,2);
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  
  v_src_hdr_id := ihook.getColumnValue(row_ori,'MDL_IMP_ID');
  
  v_tgt_item_id := 60006994;
  v_tgt_ver_nr := 5.31;
  
  for cur in (select ime.item_long_nm ME_ITEM_NM, ime.ITEM_PHY_OBJ_NM ME_ITEM_PHY_NM, imec.MEC_LONG_NM MEC_ITEM_NM, imec.MEC_PHY_NM  MEC_ITEM_PHY_NM from nci_stg_mdl_elmnt ime,
                   nci_stg_mdl_elmnt_char imec where ime.mdl_imp_id = imec.mdl_imp_id and ime.item_long_nm = imec.me_item_long_nm
                   and ime.mdl_imp_id = ihook.getColumnValue(row_ori,'MDL_IMP_ID') and
                   (ime.item_long_nm,  imec.MEC_LONG_NM ) not in (select me.item_long_nm, mec.mec_long_nm from NCI_MDL_ELMNT me, NCI_MDL_ELMNT_CHAR mec 
                   where me.item_id = mec.MDL_ELMNT_ITEM_ID 
                   and me.ver_nr = mec.MDL_ELMNT_VER_NR and me.mdl_item_id = v_tgt_item_id  and me.mdl_item_ver_nr = v_tgt_ver_nr) ) loop
                   row := t_row();
                   ihook.setColumnValue(row, 'Source Element', cur.ME_ITEM_NM);
                   ihook.setColumnValue(row, 'Source Element Physical Name', cur.ME_ITEM_PHY_NM);
                   ihook.setColumnValue(row, 'Source Characteristics', cur.MEC_ITEM_NM);
                   ihook.setColumnValue(row, 'Source Characteristics Physical Name', cur.MEC_ITEM_PHY_NM);
                   ihook.setColumnValue(row, 'Target Element', '');
                   ihook.setColumnValue(row, 'Target Element Physical Name', '');
                   ihook.setColumnValue(row, 'Target Characteristics', '');
                   ihook.setColumnValue(row, 'Target Characteristics Physical Name', '');
                     rows.extend;   rows(rows.last) := row;
                   end loop;
  
  for cur in (select me.item_long_nm ME_ITEM_NM, me.ITEM_PHY_OBJ_NM ME_ITEM_PHY_NM, mec.MEC_LONG_NM MEC_ITEM_NM, mec.MEC_PHY_NM  MEC_ITEM_PHY_NM from NCI_MDL_ELMNT me, NCI_MDL_ELMNT_CHAR mec 
                   where me.item_id = mec.MDL_ELMNT_ITEM_ID 
                   and me.ver_nr = mec.MDL_ELMNT_VER_NR and me.mdl_item_id = v_tgt_item_id  and me.mdl_item_ver_nr = v_tgt_ver_nr
                   and (me.item_long_nm, mec.mec_long_nm) not in (select ime.item_long_nm,  imec.MEC_LONG_NM
                   from nci_stg_mdl_elmnt ime,
                   nci_stg_mdl_elmnt_char imec where ime.mdl_imp_id = imec.mdl_imp_id and ime.item_long_nm = imec.me_item_long_nm
                   and ime.mdl_imp_id = ihook.getColumnValue(row_ori,'MDL_IMP_ID') )) loop
                   row := t_row();
                   ihook.setColumnValue(row, 'Target Element', cur.ME_ITEM_NM);
                   ihook.setColumnValue(row, 'Target Element Physical Name', cur.ME_ITEM_PHY_NM);
                   ihook.setColumnValue(row, 'Target Characteristics', cur.MEC_ITEM_NM);
                   ihook.setColumnValue(row, 'Target Characteristics Physical Name', cur.MEC_ITEM_PHY_NM);
                     rows.extend;   rows(rows.last) := row;
                   end loop;
                   
if (rows.count > 0) then
    showRowset := t_showableRowset(rows, 'Model Compare',4, 'unselectable');
    hookOutput.showRowset := showRowset;
else
  hookoutput.message := 'No difference found';
end if;

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


   procedure spVersionModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
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
  
 raise_application_error (-20000,'Work in progress');

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


   procedure spVersionModelMapping ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
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
  
 raise_application_error (-20000,'Work in progress');

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
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mec2.MEC_LONG_NM TGT_MEC_LONG_NM, mec2.mec_id TGT_MEC_ID, me1.mdl_item_id src_mdl_item_id,
    me1.mdl_item_ver_nr src_mdl_ver_nr ,me2.mdl_item_id tgt_mdl_item_id,
    me2.mdl_item_ver_nr tgt_mdl_ver_nr 
from nci_mdl_elmnt me1, nci_mdl_elmnt me2, nci_mdl_elmnt_char mec1, nci_mdl_elmnt_char mec2, NCI_MDL_MAP mm
where 
--nvl(me1.DOM_ITEM_ID,1) = nvl(me2.DOM_ITEM_ID,1)  and nvl(me1.DOM_VER_NR,1) = nvl(me2.DOM_VER_NR,1)
me1.DOM_ITEM_ID = me2.DOM_ITEM_ID (+)  and me1.DOM_VER_NR = me2.DOM_VER_NR (+)
and 
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR and me2.mdl_item_id (+)= mm.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr (+)= mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID (+) and me2.ver_nr = mec2.MDL_ELMNT_VER_NR (+)
and mec1.DE_CONC_ITEM_ID = mec2.DE_CONC_ITEM_ID (+) and mec1.DE_CONC_VER_NR = mec2.DE_CONC_VER_NR (+)
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR')) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.tgt_mec_id);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
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
    
    for cur in (select val_dom_item_id, val_dom_ver_nr from nci_mdl_elmnt_char c, value_dom v where mec_id = ihook.getColumnValue(row_ori,'SRC_MEC_ID') and
    c.val_dom_item_id = v.item_id and c.val_dom_ver_Nr = v.ver_nr and v.val_dom_typ_id = 17) loop
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
      input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;
    
    for cur in (select val_dom_item_id, val_dom_ver_nr from nci_mdl_elmnt_char c, value_dom v where mec_id = ihook.getColumnValue(row_ori,'TGT_MEC_ID')  and
    c.val_dom_item_id = v.item_id and c.val_dom_ver_Nr = v.ver_nr and v.val_dom_typ_id = 17) loop
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
      input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;
    
    if (input_rows.count = 0) then 
       raise_application_error(-20000, 'Source element characteristic is not enumerated.');
   end if;
    if (output_rows.count = 0) then 
       raise_application_error(-20000, 'Target element characteristic is not enumerated.');
   end if;
   
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



PROCEDURE spAddManualMap (v_data_in IN CLOB,    v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    rowmap t_row;
    forms t_forms;
    form1 t_form;
    row t_row;
    rows  t_rows;
    rowset            t_rowset;
    rowsetmap            t_rowset;
  
    actions t_actions := t_actions();
    action t_actionRowset;
   row_ori t_row;
  
 question t_question;
  answer t_answer;
  answers t_answers;

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori := hookInput.originalRowset.rowset(1);
  
    if hookInput.invocationNumber = 0 then

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add New Mapping');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add Manual Mapping', ANSWERS);
HOOKOUTPUT.QUESTION    := question;

          row := t_row();
          rows := t_rows();
         
          ihook.setColumnValue(row, 'MDL_MAP_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
          ihook.setColumnValue(row, 'MDL_MAP_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
          
          for cur in ( select * from nci_mdl_map where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR')) loop
          ihook.setColumnValue(row, 'SRC_MDL_ITEM_ID', cur.src_mdl_item_id);
          ihook.setColumnValue(row, 'SRC_MDL_VER_NR', cur.src_mdl_ver_nr);
          ihook.setColumnValue(row, 'TGT_MDL_ITEM_ID', cur.tgt_mdl_item_id);
          ihook.setColumnValue(row, 'TGT_MDL_VER_NR', cur.tgt_mdl_ver_nr);
            ihook.setColumnValue(row, 'MECM_ID', -1);
          end loop;
          rows.extend;
          rows(rows.last) := row;
          rowsetmap := t_rowset(rows, 'Model Map - Characteristics', 1, 'NCI_MEC_MAP');
        forms                  := t_forms();
    form1                  := t_form('Model Map - Characteristics', 2,1);
    form1.rowset :=rowsetmap;
    forms.extend;    forms(forms.last) := form1;
 
    hookOutput.forms := forms;


  ELSE
      forms              := hookInput.forms;
      form1              := forms(1);
      rowmap := form1.rowset.rowset(1);
      
      ihook.setColumnValue(rowmap, 'MDL_MAP_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
          ihook.setColumnValue(rowmap, 'MDL_MAP_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
    
            rows := t_rows();
            rows.extend;    rows(rows.last) := rowmap;
            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,1,'insert');
            actions.extend;
            actions(actions.last) := action;

            hookoutput.message := 'Manual Map created successfully.';
                hookoutput.actions := actions;
    
 end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--  nci_util.debugHook('GENERAL', v_data_out);
END;

END;
/
