CREATE OR REPLACE PROCEDURE ONEDATA_WA.spCreateVDNEW
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
showRowset t_showableRowset;
row t_row;
rows  t_rows;
row_ori t_row;
rowset            t_rowset;
rowsetvd            t_rowset;
v_item_nm        VARCHAR2 (255);
v_item_desc        VARCHAR2 (4000);
v_id number;
v_ver_nr number(4,2);
v_rep_id number;
actions t_actions := t_actions();
action t_actionRowset;
v_msg varchar2(1000);
i integer := 0;
v_item_id number;
v_count number;
v_valid boolean;
 BEGIN
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
 
     
IF hookInput.invocationNumber = 0 then
    HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getVDCreateQuestion();
    row := t_row();   
    rows := t_rows();
    ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
    ihook.setColumnValue(row, 'VER_NR', 1.0);
    ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
    ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);
    -- ihook.setColumnValue(row, 'ITEM_NM', v_item_nm);
    rows.extend;
    rows(rows.last) := row;
    rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for form
    rows := t_rows();
    row := t_row();
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
        
     /*if ( ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') is not null)and 
     (hookInput.invocationNumber=1 or   hookInput.answerId = 1 ) then
        select substr(ihook.getColumnValue(rowai, 'ITEM_NM') || ' ' || rc.item_nm,1,255)  ,
        substr(ihook.getColumnValue(rowai, 'ITEM_DESC') || ' ' || rc.item_desc,1,4000)
        into v_item_nm ,v_item_desc from  admin_item rc
        where  rc.ver_nr =  ihook.getColumnValue(rowvd , 'REP_CLS_VER_NR')
        and rc.item_id =  ihook.getColumnValue(rowvd , 'REP_CLS_ITEM_ID') ;*/
     if ( ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') is not null and 
     (hookInput.invocationNumber=1 or   hookInput.answerId = 1 )) then    
     
     
        ---IF ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID')<>ihook.getColumnOldValue(rowvd, 'REP_CLS_ITEM_ID') then
            select substr(ihook.getColumnValue(rowai,'ITEM_NM') || ' ' || rc.item_nm,1,255) , 
            substr(ihook.getColumnValue(rowai,'ITEM_DESC') || ' ' || rc.item_desc,1,3999) 
            into v_item_nm , v_item_desc
            from  admin_item rc
            where  rc.ver_nr =  ihook.getColumnValue(rowvd, 'REP_CLS_VER_NR')
            and rc.item_id =  ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') ;
            --end IF;
    
        else
        v_item_nm:=ihook.getColumnValue(rowai, 'ITEM_NM');
     end if;
     IF HOOKINPUT.ANSWERID = 1 then --Validate
        IF ( ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') is not null) then
            SELECT count(*) into v_count
              FROM admin_item ai, VALUE_DOM vd
             WHERE ai.item_id = vd.item_id
                   AND ai.ver_nr = vd.ver_nr
                   AND ai.ITEM_NM = ihook.getColumnValue (rowai, 'ITEM_NM')
                   AND ai.VER_NR = 1                      
                   AND ai.cntxt_item_id=ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
                   AND ai.cntxt_ver_nr=ihook.getColumnValue(rowai, 'CNTXT_VER_NR');  
        END IF;  
        IF V_count>0 then
        hookoutput.message := '****** Duplicate VD found. ******';
        
        ELSIF ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') is not null then               
 
        hookoutput.message :='Please review VD Long name and Definition.';

        END IF;
           
        rows := t_rows();
         --rowai := form1.rowset.rowset(1);
        ihook.setColumnValue(rowai, 'ITEM_NM', v_item_nm);
        ihook.setColumnValue(rowai, 'ITEM_DESC', v_item_desc);       
        rows.extend;
        rows(rows.last) := rowai;
        rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for form
        rows := t_rows();
        row := t_row();
        -- Copy Value Domain specific attributes
      --  nci_11179.spReturnSubtypeRow (v_item_id, v_ver_nr, 3, row );
               rows := t_rows();
        rows.extend;
        rows(rows.last) := rowvd;
        rowsetvd := t_rowset(rows, 'Value Domain', 1, 'VALUE_DOM'); -- Default values for form
      
        hookOutput.forms := nci_chng_mgmt.getVDCreateForm(rowset, rowsetvd);
        HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getVDCreateQuestion();
     
  ELSE --- create VD
        v_valid := true;
        IF ( ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') is not null) then
            SELECT count(*) into v_count
              FROM admin_item ai, VALUE_DOM vd
             WHERE ai.item_id = vd.item_id
                   AND ai.ver_nr = vd.ver_nr
                   AND ai.ITEM_NM = ihook.getColumnValue (rowai, 'ITEM_NM')
                   AND ai.VER_NR = 1                      
                   AND ai.cntxt_item_id=ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
                   AND ai.cntxt_ver_nr=ihook.getColumnValue(rowai, 'CNTXT_VER_NR');  
        END IF;  
        IF V_count>0 then
          v_valid := false;
        hookoutput.message := '****** Duplicate VD found. ******';
        rows := t_rows();
     
        --rowai := form1.rowset.rowset(1);
         ihook.setColumnValue(rowai, 'ITEM_NM', v_item_nm);
         ihook.setColumnValue(rowai, 'ITEM_DESC', v_item_desc);
       
        rows.extend;
        rows(rows.last) := rowai;
        rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for form
        rows := t_rows();
        row := t_row();
        -- Copy Value Domain specific attributes
      --  nci_11179.spReturnSubtypeRow (v_item_id, v_ver_nr, 3, row );
               rows := t_rows();
        rows.extend;
        rows(rows.last) := rowvd;
        rowsetvd := t_rowset(rows, 'Value Domain', 1, 'VALUE_DOM'); -- Default values for form
      
        hookOutput.forms := nci_chng_mgmt.getVDCreateForm(rowset, rowsetvd);
        HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getVDCreateQuestion();
        END IF;
        IF v_valid = true then
        v_id := nci_11179.getItemId;
        
        row := t_row();
          
        ihook.setColumnValue(rowai,'ITEM_NM',v_item_nm);
        ihook.setColumnValue(rowai,'ITEM_DESC',v_item_desc);
        ihook.setColumnValue(rowai,'ITEM_ID', v_id);
        ihook.setColumnValue(rowai,'VER_NR', 1);
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 3);
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
  END IF;
  END IF;

END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/
