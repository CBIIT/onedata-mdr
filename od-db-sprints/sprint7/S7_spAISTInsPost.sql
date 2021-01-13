CREATE OR REPLACE PROCEDURE ONEDATA_WA.spAISTInsPost
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
  v_add integer :=0;
  v_action_typ varchar2(30);
  v_temp int;
  v_item_id  number;
  v_ver_nr  number(4,2);
  v_nm_id number;
  v_cntxt_id number;
  v_cntxt_ver_nr number(4,2);
  i integer := 0;
  column  t_column;
  v_item_nm   varchar2(255);
  v_item_def varchar2(4000);
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

    row_ori := hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    
    if (hookinput.originalRowset.tablename = 'DE') then
    
    
            for cur in (select  ai.item_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr and de.de_conc_item_id = ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') and de.de_conc_ver_nr =  ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR')
            and de.val_dom_item_id =  ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and de.val_dom_ver_nr =  ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') and de.item_id <> v_item_id 
                and (ai.cntxt_item_id, ai.cntxt_ver_nr) in (Select ai1.cntxt_item_id, ai1.cntxt_ver_nr from admin_item ai1 where item_id = v_item_id and ver_nr = v_ver_nr)) loop
               raise_application_error(-20000, 'Duplicate DE found. ' || cur.item_id);
                return;
            end loop;
    
            select substr(dec.item_nm || ' ' || vd.item_nm,1,255) ,substr(dec.item_desc || ' ' || vd.item_desc,  1, 4000) into v_item_nm, v_item_def from admin_item dec, admin_item vd
            where dec.item_id = ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') and dec.ver_nr =  ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR')
            and vd.item_id =  ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and vd.ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR');
        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID',v_item_id );  
        ihook.setColumnValue(row,'VER_NR',v_ver_nr );  
        ihook.setColumnValue(row,'ITEM_NM',v_item_nm );  
        ihook.setColumnValue(row,'ITEM_DESC',v_item_def );                                 
        rows.extend;
        rows(rows.last) := row;
        action := t_actionrowset(rows, 'Administered Item', 2,4,'update');
        actions.extend;
        actions(actions.last) := action;
       -- raise_application_error (-20000, 'Count 1 ' || v_item_id || '-' || actions.count);
    end if;
   
   if (hookinput.originalRowset.tablename = 'VALUE_DOM') then
       if ( ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') is not null) then
            select substr(vd.item_nm || ' ' || rc.item_nm,1,255)  into v_item_nm from admin_item vd, admin_item rc
            where vd.item_id = v_item_id and rc.ver_nr =  ihook.getColumnValue(row_ori, 'REP_CLS_VER_NR')
            and rc.item_id =  ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') and vd.ver_nr = v_ver_nr;
        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID',v_item_id );  
        ihook.setColumnValue(row,'VER_NR',v_ver_nr );  
        ihook.setColumnValue(row,'ITEM_NM',v_item_nm );  
        rows.extend;
        rows(rows.last) := row;
        action := t_actionrowset(rows, 'Administered Item', 2,0,'update');
        actions.extend;
        actions(actions.last) := action;
         end if;
        
    end if;
   if actions.count > 0 then      
 --  raise_application_error(-20000, 'Count' || actions.count);
    hookoutput.actions := actions;
  end if;
   -- end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/
