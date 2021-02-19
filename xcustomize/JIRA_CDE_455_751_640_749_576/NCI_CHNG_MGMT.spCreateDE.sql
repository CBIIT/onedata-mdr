PROCEDURE            spCreateDE
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  showRowset t_showableRowset;
  rowai t_row;
  rowde t_row;
  forms t_forms;
  form1 t_form;

v_dflt_txt    varchar2(100) := 'Enter text, or will be auto-generated.';

  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowset            t_rowset;
  rowsetde            t_rowset;
  v_prop_long_nm varchar2(255);
  v_prop_def  varchar2(2000);
  v_dec_item_id number;
 v_str  varchar2(255);
 v_nm  varchar2(255);
 v_id number;
 v_ver_nr number(4,2);
  cnt integer;

    actions t_actions := t_actions();
  action t_actionRowset;
  v_msg varchar2(1000);
  i integer := 0;
  v_err  integer;
  column  t_column;
  v_item_nm varchar2(255);
  v_cncpt_nm varchar2(255);
  v_long_nm varchar2(255);
  v_item_def varchar2(4000);
  v_oc_id number;
  v_prop_id number;
  v_temp_id  number;
  v_temp_ver number(4,2);
  is_valid boolean;
 bEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    if hookInput.invocationNumber = 0 then
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion();
          row := t_row();
          rows := t_rows();
          ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
          ihook.setColumnValue(row, 'VER_NR', 1.0);
          ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
          ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);
          ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 4);
          ihook.setColumnValue(row, 'ITEM_NM', v_dflt_txt);
          ihook.setColumnValue(row, 'ITEM_DESC', v_dflt_txt);
          ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);
                   rows.extend;
          rows(rows.last) := row;
          rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
          rows := t_rows();
          row := t_row();
--          ihook.setColumnValue(row, 'DE_CONC_ITEM_ID',2013960 );
 --         ihook.setColumnValue(row, 'DE_CONC_VER_NR', 3);
  --        ihook.setColumnValue(row, 'VAL_DOM_ITEM_ID', 6547946);
          ihook.setColumnValue(row, 'PREF_QUEST_TXT', v_dflt_txt);
                   rows.extend;
          rows(rows.last) := row;
       rowsetde := t_rowset(rows, 'Data Element', 1, 'DE');
          hookOutput.forms := nci_chng_mgmt.getDECreateForm(rowset, rowsetde);
  ELSE
      forms              := hookInput.forms;
      form1              := forms(1);
      rowai := form1.rowset.rowset(1);
      form1              := forms(2);
      rowde := form1.rowset.rowset(1);
       row := t_row();
      rows := t_rows();


            for cur in (select ai.item_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr and de.de_conc_item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID') and de.de_conc_ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and de.val_dom_item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID') and de.val_dom_ver_nr =  ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR')
                and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID') and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR')) loop
               hookoutput.message := 'Duplicate CDE found: ' || cur.item_id;
                     rows.extend;
          rows(rows.last) := rowai;
          rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
          rows := t_rows();
            rows.extend;
          rows(rows.last) := rowde;
          rowsetde := t_rowset(rows, 'Data Element', 1, 'DE');

          hookOutput.forms := nci_chng_mgmt.getDECreateForm(rowset, rowsetde);
                HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion();
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
               return;
            end loop;

                   select substr(dec.item_nm || ' ' || vd.item_nm,1,255) ,substr(dec.item_desc || ':' || vd.item_desc,  1, 4000) into v_item_nm, v_item_def from admin_item dec, admin_item vd
            where dec.item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID') and dec.ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and vd.item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID') and vd.ver_nr = ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR');

       v_id := nci_11179.getItemId;
       row := t_row();
       --row := rowai;

        ihook.setColumnValue(rowai,'ITEM_ID', v_id);
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 4);
  
        --
        if ( ihook.getColumnValue(rowai,'ITEM_LONG_NM')= v_dflt_txt) then
        ihook.setColumnValue(rowai,'ITEM_LONG_NM', v_id || 'v1.0');
        end if;
        if ( ihook.getColumnValue(rowai,'ITEM_NM')= v_dflt_txt) then
        ihook.setColumnValue(rowai,'ITEM_NM', v_item_nm);
        end if;
        if ( ihook.getColumnValue(rowai,'ITEM_DESC')= v_dflt_txt) then
        ihook.setColumnValue(rowai,'ITEM_DESC',v_item_def);
        end if;
        if ( ihook.getColumnValue(rowde, 'PREF_QUEST_TXT')= v_dflt_txt) then 
        ihook.setColumnValue(rowde,'PREF_QUEST_TXT','Data Element' || v_item_nm||' does not have Preferred Question Text');
        end if;
       /* ihook.setColumnValue(row,'CNTXT_ITEM_ID',ihook.getColumnValue(rowai,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR',ihook.getColumnValue(rowai,'CNTXT_VER_NR'));
       ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
       ihook.setColumnValue(row, 'VER_NR', 1);
       ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
       ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);
        ihook.setColumnValue(row,'DE_CONC_ITEM_ID',ihook.getColumnValue(rowde,'DE_CONC_ITEM_ID'));
        ihook.setColumnValue(row,'VAL_DOM_ITEM_ID',ihook.getColumnValue(rowde,'VAL_DOM_ITEM_ID'));
        ihook.setColumnValue(row,'DE_CONC_VER_NR',ihook.getColumnValue(rowde,'DE_CONC_VER_NR'));
        ihook.setColumnValue(row,'VAL_DOM_VER_NR',ihook.getColumnValue(rowde,'VAL_DOM_VER_NR'));
        ihook.setColumnValue(row,'PREF_QUEST_TXT',ihook.getColumnValue(rowai,'PREF_QUEST_TXT'));
           ihook.setColumnValue(row,'LST_UPD_DT',sysdate );
      */

            rows := t_rows();
    rows.extend;
    rows(rows.last) := rowai;
   action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
    actions.extend;
    actions(actions.last) := action;


ihook.setColumnValue(rowde,'ITEM_ID', v_id);
    ihook.setColumnValue(rowde,'VER_NR', 1.0);

             rows := t_rows();
    rows.extend;
    rows(rows.last) := rowde;

    action := t_actionrowset(rows, 'Data Element', 2,2,'insert');
    actions.extend;
    actions(actions.last) := action;

   if (ihook.getColumnValue(rowde, 'PREF_QUEST_TXT')=v_dflt_txt) then
   ihook.setColumnValue(rowde, 'PREF_QUEST_TXT', 'Data Element ' || v_item_nm|| ' does not have Preferred Question Text.'   );
   end if;
   
   
    
    if (ihook.getColumnValue(rowde, 'PREF_QUEST_TXT') is not null) then
        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID', v_id);
    ihook.setColumnValue(row,'VER_NR', 1.0);
     ihook.setColumnValue(row,'REF_NM', substr(ihook.getColumnValue(rowde, 'PREF_QUEST_TXT'),1,255));
     ihook.setColumnValue(row,'REF_DESC', ihook.getColumnValue(rowde, 'PREF_QUEST_TXT'));
     ihook.setColumnValue(row,'LANG_ID', 1000);
     ihook.setColumnValue(row,'NCI_CNTXT_ITEM_ID',ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')  );
     ihook.setColumnValue(row,'NCI_CNTXT_VER_NR',ihook.getColumnValue(rowai, 'CNTXT_VER_NR')  );
     ihook.setColumnValue(row,'REF_TYP_ID', 80);

     ihook.setColumnValue(row,'REF_ID', -1);
     rows := t_rows();
     rows.extend;
    rows(rows.last) := row;
    action := t_actionrowset(rows, 'References (for hook insert)', 2,3,'insert');
    actions.extend;
    actions(actions.last) := action;
    end if;
        hookoutput.message := 'CDE Created Successfully with ID ' || v_id||c_ver_suffix ;
        hookoutput.actions := actions;
 --   raise_application_error(-20000, 'Count ' || actions.count);

    end if;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 
END;
