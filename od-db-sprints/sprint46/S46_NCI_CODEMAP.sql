create or replace PACKAGE            nci_codemap AS
  procedure spGenerateMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spGenerateValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  

END;
/
create or replace PACKAGE BODY            nci_codemap AS
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
  v_reg_str varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}';
  v_reg_str_adv varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}|\s';
  
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
me1.CONC_DOM_ITEM_ID = me2.CONC_DOM_ITEM_ID and me1.CONC_DOM_VER_NR = me2.CONC_DOM_VER_NR
and 
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
