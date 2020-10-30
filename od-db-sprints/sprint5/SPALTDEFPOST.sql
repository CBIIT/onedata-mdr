DROP PROCEDURE ONEDATA_WA.SPAIUPDPOST;

CREATE OR REPLACE PROCEDURE ONEDATA_WA.spAIUpdPost
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
  v_temp  int;
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
    
    if (ihook.getColumnValue(row_ori,'ADMIN_ITEM_TYP_ID') = 4) then -- DE
    
    
            for cur in (select ai.item_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr and de.de_conc_item_id = ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') and de.de_conc_ver_nr =  ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR')
            and de.val_dom_item_id =  ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and de.val_dom_ver_nr =  ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') and de.item_id <> v_item_id 
                and (ai.cntxt_item_id, ai.cntxt_ver_nr) in (Select ai1.cntxt_item_id, ai1.cntxt_ver_nr from admin_item ai1 where item_id = v_item_id and ver_nr = v_ver_nr)) loop
               raise_application_error(-20000, 'Duplicate DE found. ' || cur.item_id);
               return;
            end loop;
            
   end if;
   
    if (ihook.getColumnValue(row_ori,'ADMIN_ITEM_TYP_ID') = 2) then -- DEC
    --           raise_application_error(-20000, 'Duplicate DEC found. ');
    
            for cur in (select ai1.item_id from admin_item ai1, de_conc dec1 where ai1.item_id = dec1.item_id and ai1.ver_nr = dec1.ver_nr and
            ai1.item_id <> v_item_id and ai1.cntxt_item_id = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') and  ai1.cntxt_ver_nr = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR') and
            (dec1.obj_cls_item_id, dec1.obj_cls_ver_nr, dec1.prop_item_id, dec1.prop_ver_nr) in 
            (Select  dec.obj_cls_item_id, dec.obj_cls_ver_nr, dec.prop_item_id, dec.prop_ver_nr from  de_conc dec
            where dec.item_id = v_item_id and dec.ver_nr = v_ver_nr)) loop
               raise_application_error(-20000, 'Duplicate DEC found. ' || cur.item_id);
               return;
            end loop;
    
    end if;
  
   
   --if actions.count > 0 then      
    --hookoutput.actions := actions;
  --end if;
   -- end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/
