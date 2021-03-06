create or replace PROCEDURE spINSREFBLOBPost
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_usr_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  v_action_typ varchar2(30);
  v_ref_doc_id  number;
  v_temp integer;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

    row_ori := hookInput.originalRowset.rowset(1);
    v_ref_doc_id := ihook.getColumnValue(row_ori, 'REF_DOC_ID');
    
    select count(*) into v_temp from  ref_doc cl,ref ai,onedata_md.vw_usr_row_filter v where
       REF_DOC_ID = v_ref_doc_id
       and NCI_REF_ID=REF_ID
       and  ai.NCI_CNTXT_ITEM_ID  = v.CNTXT_ITEM_ID 
       and ai.NCI_CNTXT_VER_NR = v.CNTXT_VER_NR  
       and upper(v.USR_ID) = upper(v_usr_id) and  v.ACTION_TYP = 'I' ;
    if (v_temp = 0) then 
        select count(*) into v_temp from onedata_md.vw_usr_row_filter v where 
         v.CNTXT_ITEM_ID = 100 and upper(v.USR_ID) = upper(v_usr_id) and v.ACTION_TYP = 'I' ;
    end if;
     if (v_temp = 0) then
         raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
     end if;
     
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   
END;
/