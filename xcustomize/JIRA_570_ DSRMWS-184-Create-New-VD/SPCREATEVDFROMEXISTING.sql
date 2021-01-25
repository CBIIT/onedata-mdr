CREATE OR REPLACE PROCEDURE ONEDATA_WA.spCreateVDFromExisting
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    rowai t_row;
    rowvd t_row;
    forms t_forms;
    form1 t_form;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    rowset            t_rowset;
    rowsetvd            t_rowset;
    v_id number;
    v_ver_nr number(4,2);
    actions t_actions := t_actions();
    action t_actionRowset;
    v_msg varchar2(1000);
    i integer := 0;
    v_item_nm varchar2(255);
    v_item_id number;
    v_item_desc varchar2(4000);

 bEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

   -- selected row to copy from
   row_ori := hookInput.originalRowset.rowset (1);
    v_item_id := ihook.getColumnValue (row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue (row_ori, 'VER_NR');


    if hookInput.invocationNumber = 0 then
        HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getVDCreateQuestion();
        row := row_ori;
        rows := t_rows();
        ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row, 'VER_NR', 1.0);
        ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
        ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);
        rows.extend;
        rows(rows.last) := row;
        rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for form
        rows := t_rows();
        row := t_row();
        -- Copy Value Domain specific attributes
        nci_11179.spReturnSubtypeRow (v_item_id, v_ver_nr, 3, row );
        rows.extend;
        rows(rows.last) := row;
        rowsetvd := t_rowset(rows, 'Value Domain', 1, 'VALUE_DOM'); -- Default values for form
        hookOutput.forms := nci_chng_mgmt.getVDCreateForm(rowset, rowsetvd);
  ELSE
        forms              := hookInput.forms;
        form1              := forms(1);
        rowai := form1.rowset.rowset(1);
        form1              := forms(2);
        rowvd := form1.rowset.rowset(1);
        row := t_row();
        rows := t_rows();

        -- rowai has all the AI supertype attribute. RowVD is the sub-type
        v_item_nm:=ihook.getColumnValue(rowai,'ITEM_NM');
        v_item_nm:=ihook.getColumnValue(rowai,'ITEM_DESC');
   if ( ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') is not null) then     
     
            select substr(ihook.getColumnValue(rowai,'ITEM_NM') || ' ' || rc.item_nm,1,255) , 
            substr(ihook.getColumnValue(rowai,'ITEM_DESC') || ' ' || rc.item_desc,1,3999) 
            into v_item_nm , v_item_desc
            from  admin_item rc
            where  rc.ver_nr =  ihook.getColumnValue(rowvd, 'REP_CLS_VER_NR')
            and rc.item_id =  ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') ;
     end IF;  
        v_id := nci_11179.getItemId;
        row := t_row();

        ihook.setColumnValue(rowai,'ITEM_ID', v_id);
        ihook.setColumnValue(rowai,'VER_NR', 1);
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 3);
        ihook.setColumnValue(rowai,'ITEM_NM', v_item_nm);
        ihook.setColumnValue(rowai,'ITEM_DESC', v_item_desc);
        rows := t_rows();
        rows.extend;
        rows(rows.last) := rowai;
        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;


        ihook.setColumnValue(rowvd,'ITEM_ID', v_id);
        ihook.setColumnValue(rowvd,'VER_NR', 1);

        rows := t_rows();
        rows.extend;
        rows(rows.last) := rowvd;

        action := t_actionrowset(rows, 'Value Domain', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;


        hookoutput.message := 'VD Created Successfully with ID ' || v_id ;
        hookoutput.actions := actions;
 --   raise_application_error(-20000, 'Count ' || actions.count);
 
      end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/