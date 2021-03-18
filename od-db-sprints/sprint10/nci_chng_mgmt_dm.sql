create or replace PACKAGE            nci_chng_mgmt AS
v_temp_rep_ver_nr varchar2(10);
v_temp_rep_id VARCHAR2(10);

function getCSICreateQuestion return t_question;
function getVDCreateQuestion (v_first in boolean) return t_question;
function getVDEditQuestion return t_question;
procedure createAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer, actions in out t_actions);
PROCEDURE spDEPrefQuestPost (v_data_in in clob, v_data_out out clob);
PROCEDURE spCreateDE (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
PROCEDURE spDECreateFrom ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
--PROCEDURE spDECommon ( v_init_ai in t_rowset, v_init_st in t_rowset, v_op  in varchar2,  v_ori_rep_cls in number, hookInput in t_hookInput, hookOutput in out t_hookOutput);
PROCEDURE spClassification ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spClassificationNMDef ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2, v_typ in varchar2);
PROCEDURE spDesignateNew   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
function getDECreateQuestion(v_from in number,v_first in boolean) return t_question;
function getDECreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
function getCSICreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
function getVDCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
procedure createDE (rowform in t_row, actions in out t_actions, v_id out number);
PROCEDURE spVDCreateNew ( v_data_in IN CLOB, v_data_out OUT CLOB);
PROCEDURE spVDCreateFrom ( v_data_in IN CLOB, v_data_out OUT CLOB);
PROCEDURE spVDEdit ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spVDCommon ( v_init_ai in t_rowset, v_init_st in t_rowset, v_op  in varchar2,  v_ori_rep_cls in number, hookInput in t_hookInput, hookOutput in out t_hookOutput);
procedure spAddCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
END;
/
create or replace PACKAGE BODY            nci_CHNG_MGMT AS
v_temp_rep_ver_nr varchar2(10):='0';
v_temp_rep_id VARCHAR2(10):='0';
v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
type       t_orgs is table of org_cntct.org_id%type;
type t_cncpt_id is table of admin_item.item_id%type;
v_t_cncpt_id  t_cncpt_id := t_cncpt_id();
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';


procedure spAddCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as
 hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  showRowset t_showableRowset;
  rowai t_row;
  rowcsi t_row;
  forms t_forms;
  form1 t_form;
v_dflt_txt    varchar2(100) := 'Enter text or will be auto-generated.';

  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowset            t_rowset;
  rowsetde            t_rowset;
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
  v_temp_id  number;
  v_temp_ver number(4,2);
  is_valid boolean;
 bEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
     row_ori := hookInput.originalRowset.rowset(1);

   if (ihook.getColumnValue(row_ori,'LVL') = 'CONTEXT') then
   raise_application_error(-20000, 'Cannot create CSI under Context. Please choose CS or CSI.');
   return;
   end if;
    if hookInput.invocationNumber = 0 then
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getCSICreateQuestion();
          row := t_row();
          rows := t_rows();
          ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
          ihook.setColumnValue(row, 'VER_NR', 1.0);
          ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
          ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);
          ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 4);
          ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);
                   rows.extend;
          rows(rows.last) := row;
          rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
          rows := t_rows();
          row := t_row();
                 rows.extend;
          rows(rows.last) := row;
       rowsetde := t_rowset(rows, 'CSI', 1, 'NCI_CLSFCTN_SCHM_ITEM');
          hookOutput.forms := nci_chng_mgmt.getCSICreateForm(rowset, rowsetde);
  ELSE
      forms              := hookInput.forms;
      form1              := forms(1);
      rowai := form1.rowset.rowset(1);
      form1              := forms(2);
      rowcsi := form1.rowset.rowset(1);
       row := t_row();
      rows := t_rows();

       v_id := nci_11179.getItemId;
       row := t_row();
       --row := rowai;

        ihook.setColumnValue(rowai,'ITEM_ID', v_id);
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 51);

        --
        if ( ihook.getColumnValue(rowai,'ITEM_LONG_NM')= v_dflt_txt) then
        ihook.setColumnValue(rowai,'ITEM_LONG_NM', v_id || 'v1.0');
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


ihook.setColumnValue(rowcsi,'ITEM_ID', v_id);
    ihook.setColumnValue(rowcsi,'VER_NR', 1.0);
    if (ihook.getColumnValue(row_ori,'LVL') = 'CSI') then
        ihook.setColumnValue(rowcsi,'P_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
        ihook.setColumnValue(rowcsi,'P_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
        ihook.setColumnValue(rowcsi,'CS_ITEM_ID', ihook.getColumnValue(row_ori,'P_ITEM_ID'));
        ihook.setColumnValue(rowcsi,'CS_ITEM_VER_NR', ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'));
    end if;
    if (ihook.getColumnValue(row_ori,'LVL') = 'CLASSIFICATION SCHEME') then
       ihook.setColumnValue(rowcsi,'CS_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
        ihook.setColumnValue(rowcsi,'CS_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
    end if;

             rows := t_rows();
    rows.extend;
    rows(rows.last) := rowcsi;

    action := t_actionrowset(rows, 'CSI', 2,2,'insert');
    actions.extend;
    actions(actions.last) := action;
     hookoutput.message := 'CSI Created Successfully with ID ' || v_id||c_ver_suffix ;
        hookoutput.actions := actions;
 --   raise_application_error(-20000, 'Count ' || actions.count);

    end if;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

END;


PROCEDURE   spCreateDE (v_data_in IN CLOB,    v_data_out OUT CLOB, v_usr_id  IN varchar2) 
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  showRowset t_showableRowset;
  rowai t_row;
  rowde t_row;
  forms t_forms;
  form1 t_form;

v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';

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
  V_valid boolean;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    if hookInput.invocationNumber = 0 then
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion(1,true);
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

      v_valid := true;
            for cur in (select ai.item_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr 
           -- and ai.ITEM_LONG_NM=ihook.getColumnValue(rowai,'ITEM_LONG_NM')
           -- and  ai.ver_nr =  ihook.getColumnValue(rowai, 'VER_NR')
            and de.de_conc_item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID') 
            and de.de_conc_ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and de.val_dom_item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID') 
            and de.val_dom_ver_nr =  ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID') 
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR')) 


        loop
        hookoutput.message := 'Duplicate CDE found: ' || cur.item_id;

         rows.extend;
          rows(rows.last) := rowai;
          rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
          rows := t_rows();
            rows.extend;
          rows(rows.last) := rowde;
          rowsetde := t_rowset(rows, 'Data Element', 1, 'DE');
           v_valid := false;
          hookOutput.forms := nci_chng_mgmt.getDECreateForm(rowset, rowsetde);
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion(1,v_valid);
           V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
            return;
            end loop;
            
    select substr(dec.item_nm || ' ' || vd.item_nm,1,255) ,substr(dec.item_desc || ':' || vd.item_desc,  1, 4000) into v_item_nm, v_item_def from admin_item dec, admin_item vd
            where dec.item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID') and dec.ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and vd.item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID') and vd.ver_nr = ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR');
   if (ihook.getColumnValue(rowde, 'PREF_QUEST_TXT')=v_dflt_txt) then
   ihook.setColumnValue(rowde, 'PREF_QUEST_TXT', 'Data Element ' || v_item_nm|| ' does not have Preferred Question Text.'   );
   end if;
   if hookinput.answerid = 1 or v_valid = false then --Validate

        ihook.setColumnValue(rowai, 'ITEM_NM', v_item_nm);
        ihook.setColumnValue(rowai, 'ITEM_DESC', v_item_def);

          rows.extend;
          rows(rows.last) := rowai;
          rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
          rows := t_rows();
            rows.extend;
          rows(rows.last) := rowde;
          rowsetde := t_rowset(rows, 'Data Element', 1, 'DE');
           v_valid := false;
          hookOutput.forms := nci_chng_mgmt.getDECreateForm(rowset, rowsetde);
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion(1,v_valid);
          --V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

    end if; 			
			
 if (hookinput.answerid = 2 and v_valid = true) then
         
       v_id := nci_11179.getItemId;
       row := t_row();
       --row := rowai;

        ihook.setColumnValue(rowai,'ITEM_ID', v_id);
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 4);

        --
        if ( ihook.getColumnValue(rowai,'ITEM_LONG_NM')= v_dflt_txt) then
        ihook.setColumnValue(rowai,'ITEM_LONG_NM', v_id ||'v1.00');
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

    rows := t_rows();
    rows.extend;
    rows(rows.last) := rowai;
    action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
    actions.extend;
    actions(actions.last) := action;


    ihook.setColumnValue(rowde,'ITEM_ID', v_id);
    ihook.setColumnValue(rowde,'VER_NR', 1.00);

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
    ihook.setColumnValue(row,'VER_NR', 1.00);
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
 end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

END;

PROCEDURE spDECreateFrom ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2) as
        hookInput t_hookInput;
        hookOutput t_hookOutput := t_hookOutput();
        row_ori  t_row;
        row  t_row;
        rowai  t_row;
        rowde  t_row;
        rows t_rows;
        forms t_forms;
        form1 t_form;
        v_item_id  number;
        v_ver_nr  number(4,2);
        v_ori_rep_cls number;
        rowset            t_rowset;  
        rowsetai  t_rowset;
        rowsetde  t_rowset;
        v_item_nm varchar2(255);
        v_cncpt_nm varchar2(255);
        v_long_nm varchar2(255);
        v_item_desc varchar2(4000);
        v_count  number;
        v_valid boolean;
        v_item_type_id number;
        actions t_actions := t_actions();
        action t_actionRowset;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    -- Get the selected row
    row_ori :=  hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_item_type_id := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');

    -- Check if user is authorized to edit
--   if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
--        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
--        return;
--  end if;
-- check that a selected AI is CDE typeF

    if (v_item_type_id <> 4) then -- 4 - CDE in table OBJ_KEY
        raise_application_error(-20000,'!!! This functionality is only applicable for CDE !!!');
    end if;
if hookInput.invocationNumber = 0 then
        HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion(2,true);
        row := row_ori;
        rows := t_rows();
        ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row, 'VER_NR', 1.00);
        ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
        ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);
        ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);
        rows.extend;
        rows(rows.last) := row;
        rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for form
        rows := t_rows();
        row := t_row();
        -- Copy DE specific attributes
        nci_11179.spReturnSubtypeRow (v_item_id, v_ver_nr, 4, row );
        rows.extend;
        rows(rows.last) := row;
        rowsetde := t_rowset(rows, 'Data Element', 1, 'DE'); -- Default values for form
        hookOutput.forms := nci_chng_mgmt.getDECreateForm(rowsetai, rowsetde);

--      raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. 2');
--        return;
    --spDECommon(rowsetai,rowsetst, 'insert', hookinput, hookoutput);
  ELSE
        forms              := hookInput.forms;
        form1              := forms(1);
        rowai := form1.rowset.rowset(1);
        form1              := forms(2);
        rowde := form1.rowset.rowset(1);
        row := t_row();
        rows := t_rows();
        v_valid := true;


        v_item_nm:=ihook.getColumnValue(rowai,'ITEM_NM');
        v_item_desc:=ihook.getColumnValue(rowai,'ITEM_DESC');
        


  IF HOOKINPUT.ANSWERID = 1 or hookInput.invocationNumber = 1 then--Validate
        v_item_nm:=ihook.getColumnValue(rowai,'ITEM_NM');
        v_item_desc:=ihook.getColumnValue(rowai,'ITEM_DESC');
        v_valid := true;

         select substr(dec.item_nm || ' ' || vd.item_nm,1,255) ,substr(dec.item_desc || ':' || vd.item_desc,  1, 4000) into v_item_nm, v_item_desc from admin_item dec, admin_item vd
         where dec.item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID') and dec.ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
         and vd.item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID') and vd.ver_nr = ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR');

        for cur in (select ai.item_id from admin_item ai, de de
        where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr 
        and de.de_conc_item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID') 
            and de.de_conc_ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and de.val_dom_item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID') 
            and de.val_dom_ver_nr =  ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID') 
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR')) 
        loop
        hookoutput.message := 'Duplicate CDE found: ' || cur.item_id;
        v_valid := false;
     
       rows := t_rows();
         If ihook.getColumnValue(rowai, 'ITEM_LONG_NM') is null then
         ihook.setColumnValue(rowai, 'ITEM_LONG_NM', ihook.getColumnValue(rowai, 'ITEM_id'||'v1.00'));
         end if ;
         ihook.setColumnValue(rowai, 'ITEM_NM', v_item_nm);
         ihook.setColumnValue(rowai, 'ITEM_DESC', v_item_desc);

        rows.extend;
        rows(rows.last) := rowai;
        rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for form
        rows := t_rows();
        row := t_row();       
        rows := t_rows();
        rows.extend;
        rows(rows.last) := rowde;
        rowsetde := t_rowset(rows, 'Data Element', 1, 'DE'); -- Default values for form

        hookOutput.forms := nci_chng_mgmt.getDECreateForm(rowsetai, rowsetde);
        HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion(2,v_valid);
               V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
       return;
       END LOOP;
	   if (ihook.getColumnValue(rowde, 'PREF_QUEST_TXT') is null) then
       ihook.setColumnValue(rowde, 'PREF_QUEST_TXT', 'Data Element ' || v_item_nm|| ' does not have Preferred Question Text.'   );
       end if;
       if hookinput.answerid = 1 or v_valid = false then --Validate

        ihook.setColumnValue(rowai, 'ITEM_NM', v_item_nm);
        ihook.setColumnValue(rowai, 'ITEM_DESC', v_item_desc);

          rows.extend;
          rows(rows.last) := rowai;
          rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
          rows := t_rows();
            rows.extend;
          rows(rows.last) := rowde;
          rowsetde := t_rowset(rows, 'Data Element', 1, 'DE');
           v_valid := false;
          hookOutput.forms := nci_chng_mgmt.getDECreateForm(rowset, rowsetde);
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion(2,v_valid);
          --V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

    end if; 			

end if;


  if (hookinput.answerid = 2 and v_valid = true) then
        row := t_row();
        v_item_id := nci_11179.getItemId;
         select substr(dec.item_nm || ' ' || vd.item_nm,1,255) ,substr(dec.item_desc || ':' || vd.item_desc,  1, 4000) into v_item_nm, v_item_desc from admin_item dec, admin_item vd
         where dec.item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID') and dec.ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
         and vd.item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID') and vd.ver_nr = ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR');

        ihook.setColumnValue(rowai,'ITEM_ID', v_item_id);
        ihook.setColumnValue(rowai,'VER_NR', 1.00);
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 4);
        ihook.setColumnValue(rowai,'ITEM_NM', v_item_nm);
        ihook.setColumnValue(rowai,'ITEM_DESC', v_item_desc);
		if (ihook.getColumnValue(rowde, 'PREF_QUEST_TXT') is null) then
        ihook.setColumnValue(rowde, 'PREF_QUEST_TXT', 'Data Element ' || v_item_nm|| ' does not have Preferred Question Text.'   );
        end if;
        rows := t_rows();
        rows.extend;
        rows(rows.last) := rowai;
        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;


        ihook.setColumnValue(rowde,'ITEM_ID', v_item_id);
        ihook.setColumnValue(rowde,'VER_NR', 1.00);

        rows := t_rows();
        rows.extend;
        rows(rows.last) := rowde;

        action := t_actionrowset(rows, 'Data Element', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;


        hookoutput.message := 'DE Created Successfully with ID ' || v_item_id||'v1.00' ;
        hookoutput.actions := actions;
        end if;
 --   raise_application_error(-20000, 'Count ' || actions.count);
   
  end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

function getCSICreateQuestion return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Create CSI Node');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Create new CSI.', ANSWERS);

return question;
end;


function getVDCreateQuestion (v_first in Boolean) return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();

    ANSWER                     := T_ANSWER(1, 1, 'Review and Validate');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;

     if (v_first = false) then
    ANSWER                     := T_ANSWER(2, 2, 'Create Rep Term');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    end if;
      if (v_first = false) then
        ANSWER                     := T_ANSWER(3, 3, 'Create/Save');
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
    end if;
    QUESTION               := T_QUESTION('Create/Edit', ANSWERS);

return question;
end;

function getVDEditQuestion return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();

    ANSWER                     := T_ANSWER(1, 1, 'Review and Validate VD');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
 ANSWER                     := T_ANSWER(2, 2, 'Save VD');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Edit VD.', ANSWERS);

return question;
end;



function getDECreateQuestion(v_from in number,v_first in boolean) return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin 
    ANSWERS                    := T_ANSWERS();
    
    ANSWER                     := T_ANSWER(1, 1, 'Review and Validate');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
 
    if (v_first = false) then
    ANSWER                     := T_ANSWER(2, 2, 'Create');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    end if;
    If v_from=1 then
    QUESTION               := T_QUESTION('Create new CDE.', ANSWERS);
    else
    QUESTION               := T_QUESTION('Create CDE From Existing.', ANSWERS);
    end IF;
return question;
end;

function getDECreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('Administered Item (Data Element CO)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    form1                  := t_form('Data Element(hook creation)', 2,1);

    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;


function getCSICreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('Administered Item (Data Element CO)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    form1                  := t_form('CSI (Hook Creation)', 2,1);

    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;


function getVDCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    -- v_temp_rep_ver_nr :='0';
    -- v_temp_rep_id:='0';
    forms                  := t_forms();
    form1                  := t_form('Administered Item (Data Element CO)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    form1                  := t_form('Value Domain (Create Hook)', 2,1);
    forms.extend;    forms(forms.last) := form1;

    form1.rowset :=v_rowset2;
    form1                  := t_form('Rep Term (Hook Creation)', 2,1);
    forms.extend;    forms(forms.last) := form1;

  return forms; 

end;

procedure createAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer, actions in out t_actions) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
row t_row;
rows t_rows;
 action t_actionRowset;
 v_cncpt_id  number;
 v_cncpt_ver_nr number(4,2);
 v_id integer;
 j integer;
i integer;
v_obj_nm  varchar2(100);
v_temp varchar2(4000);
begin
        v_id := nci_11179.getItemId;

       rows := t_rows();
   --     raise_application_error(-20000,'OC');
       v_nm := '';
       v_long_nm := '';
       v_def := '';
          j := 0;
          for i in reverse 0..10 loop

     --  raise_application_error(-20000, 'Test'  ||ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || 4));

          v_cncpt_id := ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i);
             v_cncpt_ver_nr :=  ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i);
          if( v_cncpt_id is not null) then
    --   raise_application_error(-20000, 'Test'  || i || v_cncpt_id);
           for cur in (select item_nm, item_long_nm, item_desc from admin_item where item_id = v_cncpt_id and ver_nr = v_cncpt_ver_nr) loop
            row := t_row();
            ihook.setColumnValue(row,'ITEM_ID', v_id);
            ihook.setColumnValue(row,'VER_NR', 1);
            ihook.setColumnValue(row,'CNCPT_ITEM_ID',v_cncpt_id);
            ihook.setColumnValue(row,'CNCPT_VER_NR', v_cncpt_ver_nr);
            ihook.setColumnValue(row,'NCI_ORD', j);
            v_temp := v_temp || i || ':' ||  v_cncpt_id;
            if j = 0 then
            ihook.setColumnValue(row,'NCI_PRMRY_IND', 1);
            else ihook.setColumnValue(row,'NCI_PRMRY_IND', 0);
            end if;
            rows.extend;
            rows(rows.last) := row;
            v_nm := trim(cur.item_nm) || ' ' || v_nm ;
            v_long_nm := cur.item_long_nm || ':' || v_long_nm   ;
            v_def := substr( cur.item_desc || '_' || v_def,1,4000);
            j := j+ 1;
        end loop;
        end if;
        end loop;
       action := t_actionrowset(rows, 'CNCPT_ADMIN_ITEM', 1,6,'insert');
        actions.extend;
        actions(actions.last) := action;

        rows := t_rows();
        row := t_row();
        v_long_nm := substr(v_long_nm,1, length(v_long_nm)-1);
        v_nm := substr(trim(v_nm),1, c_nm_len);
        -- if lenght of short name is greater than 30, then use IDv1.00
        if (length(v_long_nm) > 30) then
            v_long_nm := v_id || c_ver_suffix;
        end if;

    -- raise_application_error (-20000, v_nm || '$$$' || v_long_nm);
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', v_item_typ_id);
        ihook.setColumnValue(row,'ADMIN_STUS_ID',66 );
        ihook.setColumnValue(row,'ITEM_LONG_NM', v_long_nm);
        ihook.setColumnValue(row,'ITEM_DESC', substr(v_def, 1, length(v_def)-1));
        ihook.setColumnValue(row,'ITEM_NM', v_nm);
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        rows.extend;
        rows(rows.last) := row;
    -- raise_application_error(-20000, 'HEre ' || v_nm || v_long_nm || v_def);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM', v_long_nm);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_DEF', substr(v_def, 1, length(v_def)-1));
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_NM', v_nm);
        ihook.setColumnValue(rowform, 'ITEM_' || idx || '_ID', v_id);
         ihook.setColumnValue(rowform, 'ITEM_' || idx || '_VER_NR', 1);

        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;

       case v_item_typ_id
       when 5 then v_obj_nm := 'Object Class';
       when 6 then v_obj_nm := 'Property';
        end case;
        action := t_actionrowset(rows, v_obj_nm, 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;


end;


procedure createDE (rowform in t_row, actions in out t_actions, v_id out  number) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
row t_row;
rows t_rows;
 action t_actionRowset;
 --v_id number;
begin
   rows := t_rows();
   row := t_row();
     v_id := nci_11179.getItemId;
        ihook.setColumnValue(row,'ITEM_ID', v_id);
      --  raise_application_error (-20000, ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID')  || ihook.getColumnValue(rowform, 'ITEM_1_ID') || ihook.getColumnValue(rowform, 'ITEM_2_ID'));
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 2);
   --     ihook.setColumnValue(row,'ITEM_LONG_NM', ihook.getColumnValue(rowform, 'ITEM_1_LONG_NM')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_LONG_NM'));
        ihook.setColumnValue(row,'ITEM_LONG_NM', v_id || c_ver_suffix);
        ihook.setColumnValue(row,'ITEM_NM',  ihook.getColumnValue(rowform, 'ITEM_1_NM')  || ' ' || ihook.getColumnValue(rowform, 'ITEM_2_NM'));
        ihook.setColumnValue(row,'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000));
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'ADMIN_STUS_ID',66);
        ihook.setColumnValue(row,'CONC_DOM_ITEM_ID',nvl(ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID'),1) );
        ihook.setColumnValue(row,'CONC_DOM_VER_NR',nvl(ihook.getColumnValue(rowform,'CONC_DOM_VER_NR'),1) );
        ihook.setColumnValue(row,'OBJ_CLS_ITEM_ID',nvl(ihook.getColumnValue(rowform, 'ITEM_1_ID'),1) );
        ihook.setColumnValue(row,'OBJ_CLS_VER_NR',nvl(ihook.getColumnValue(rowform, 'ITEM_1_VER_NR'),1) );
        ihook.setColumnValue(row,'PROP_ITEM_ID',nvl(ihook.getColumnValue(rowform, 'ITEM_2_ID'),1));
        ihook.setColumnValue(row,'PROP_VER_NR',nvl(ihook.getColumnValue(rowform, 'ITEM_2_VER_NR'),1));
        ihook.setColumnValue(row,'LST_UPD_DT',sysdate );
        rows.extend;
        rows(rows.last) := row;
--raise_application_error(-20000, 'Deep' || ihook.getColumnValue(row,'CNTXT_ITEM_ID') || 'ggg'|| ihook.getColumnValue(row,'ADMIN_STUS_ID') || 'GGGG' || ihook.getColumnValue(row,'ITEM_ID'));

        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,7,'insert');
        actions.extend;
        actions(actions.last) := action;

      action := t_actionrowset(rows, 'Data Element Concept', 2,8,'insert');
       actions.extend;
        actions(actions.last) := action;

--r
end;

PROCEDURE spDEPrefQuestPost
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
  v_item_id  number;
  v_ver_nr  number(4,2);
  v_nm_id number;
  v_cntxt_id number;
  v_cntxt_ver_nr number(4,2);
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();

    row_ori := hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');

    if (ihook.getColumnValue(row_ori, 'PREF_QUEST_TXT') is not null) then
    select cntxt_item_id, cntxt_ver_nr into v_cntxt_id, v_cntxt_ver_nr from admin_item where item_id = v_item_id and ver_nr = v_ver_nr;

        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID', v_item_id);
    ihook.setColumnValue(row,'VER_NR', v_ver_nr);
     ihook.setColumnValue(row,'REF_NM', substr(ihook.getColumnValue(row_ori, 'PREF_QUEST_TXT'),1,255));
     ihook.setColumnValue(row,'REF_DESC', ihook.getColumnValue(row_ori, 'PREF_QUEST_TXT'));
     ihook.setColumnValue(row,'LANG_ID', 1000);
     ihook.setColumnValue(row,'NCI_CNTXT_ITEM_ID',v_cntxt_id );
     ihook.setColumnValue(row,'NCI_CNTXT_VER_NR', v_cntxt_ver_nr );
     ihook.setColumnValue(row,'REF_TYP_ID', 80);

     ihook.setColumnValue(row,'REF_ID', -1);
     v_action_typ := 'insert';
     for cur in (select REF_id from  REF where item_id = v_item_id and ver_nr = v_ver_nr and ref_typ_id = 80) loop
     ihook.setColumnValue(row,'REF_ID', cur.ref_id);
     v_action_typ := 'update';

     end loop;

     rows.extend;
    rows(rows.last) := row;
    action := t_actionrowset(rows, 'References (for Edit)', 2,0,v_action_typ);
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;

    end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spClassificationNMDef ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2, v_typ in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_obj  varchar2(100);
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
forms     t_forms;
formGroup    t_form;
form1  t_form;
rowform t_row;
v_itemid     ADMIN_ITEM.ITEM_ID%TYPE;
v_vernr  ADMIN_ITEM.VER_NR%TYPE;
v_tbl_nm  varchar2(255);
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  v_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_itemid := ihook.getColumnValue(row_ori, 'ITEM_ID');
  v_VERNR := ihook.getColumnValue(row_ori, 'VER_NR');
    if (v_typ = 'DESIGNATION') then
         v_id := ihook.getColumnValue(row_ori, 'NM_ID');
         v_obj := 'Classification level Name/Definition';
    else
         v_id := ihook.getColumnValue(row_ori, 'DEF_ID');
         v_obj := 'Classification level Definition';
   end if;
    rows := t_rows();


    if hookInput.invocationNumber = 0  then

    rows := t_rows();

        for cur in (select ITEM_ID, VER_NR from NCI_CLSFCTN_SCHM_ITEM  where (CS_ITEM_ID, CS_ITEM_VER_NR) in ( select item_id, ver_nr from admin_item ai, onedata_md.vw_usr_row_filter v
        where nvl(ai.fld_delete,0)= 0  and ai.cntxt_item_id = v.CNTXT_ITEM_ID and ai.CNTXT_VER_NR = v.cntxt_VER_NR and ai.admin_item_typ_id = 9 and  upper(v.USR_ID) = upper(v_usr_id) and v.ACTION_TYP = 'I') )loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
      	   v_found := true;
	    end loop;



        if (v_found) then
             showrowset := t_showablerowset (rows, 'CSI Node', 2, 'single');
            hookoutput.showrowset := showrowset;
       	 answers := t_answers();
        answer := t_answer(1, 1, 'Add Classification');
        answers.extend;          answers(answers.last) := answer;
        answer := t_answer(2, 2, 'Delete Classification');
        answers.extend;          answers(answers.last) := answer;

	   	 question := t_question('Choose Option', answers);
       	 hookOutput.question := question;
        else
            hookoutput.message := 'No classification scheme found in your authorized context.';
         end if;

    end if;

  	if hookInput.invocationNumber = 1 then
      rows := t_rows();

      row_sel := hookInput.selectedRowset.rowset(1);
            row := t_row();
            select count(*) into v_temp from NCI_CSI_ALT_DEFNMS where NMDEF_id = v_id
            and NCI_VER_NR = ihook.getColumnValue(row_sel,'VER_NR') and NCI_PUB_ID = ihook.getColumnValue(row_sel,'ITEM_ID') ;
            if ((v_temp = 0 and hookinput.answerid =1) or (v_temp=1 and hookinput.answerid = 2) ) then
                ihook.setcolumnvalue(row,'NCI_VER_NR', ihook.getColumnValue(row_sel,'VER_NR'));
                ihook.setcolumnvalue(row,'NCI_PUB_ID', ihook.getColumnValue(row_sel,'ITEM_ID'));
                ihook.setcolumnvalue(row,'NMDEF_ID', v_id);
                ihook.setcolumnvalue(row,'TYP_NM', v_typ);
                rows.extend;
                rows(rows.last) := row;
                if (hookinput.answerid = 1) then -- Add
                    action := t_actionrowset(rows, v_obj, 2,1,'insert');
                    actions.extend;
                    actions(actions.last) := action;
                else
                    action := t_actionrowset(rows, v_obj, 2,2,'delete');
                    actions.extend;
                    actions(actions.last) := action;
                    action := t_actionrowset(rows, v_obj, 2,3,'purge');
                    actions.extend;
                    actions(actions.last) := action;
                end if;
                hookoutput.actions := actions;
            end if;
    end if; -- invocation number
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spClassification
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_usr_id  IN varchar2)
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
form1  t_form;
rowform t_row;
v_itemid     ADMIN_ITEM.ITEM_ID%TYPE;
v_vernr  ADMIN_ITEM.VER_NR%TYPE;
v_tbl_nm  varchar2(255);
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_itemid := ihook.getColumnValue(row_ori, 'ITEM_ID');
  v_VERNR := ihook.getColumnValue(row_ori, 'VER_NR');


    -- Initial invocation
    if hookInput.invocationNumber = 0  then

        rows := t_rows();
        for cur in (select ITEM_ID, VER_NR from NCI_CLSFCTN_SCHM_ITEM where (CS_ITEM_ID, CS_ITEM_VER_NR) in ( select item_id, ver_nr from admin_item ai, onedata_md.vw_usr_row_filter v
        where nvl(ai.fld_delete,0)= 0  and ai.cntxt_item_id = v.CNTXT_ITEM_ID and ai.CNTXT_VER_NR = v.cntxt_VER_NR and ai.admin_item_typ_id = 9 and  upper(v.USR_ID) = upper(v_usr_id) and v.ACTION_TYP = 'I') )loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
      	   v_found := true;
	    end loop;

        if (v_found) then
             showrowset := t_showablerowset (rows, 'CSI Node', 2, 'single');
            hookoutput.showrowset := showrowset;
       	 answers := t_answers();
        answer := t_answer(1, 1, 'Add Classification');
        answers.extend;          answers(answers.last) := answer;
        answer := t_answer(2, 2, 'Delete Classification');
        answers.extend;          answers(answers.last) := answer;

	   	 question := t_question('Choose Option', answers);
       	 hookOutput.question := question;
        else
            hookoutput.message := 'No classification scheme found in your authorized context.';
         end if;
    end if;

   if hookInput.invocationNumber = 1  then

        row_sel := hookInput.selectedRowset.rowset(1);
        v_found := false;
        rows := t_rows();

                for i in 1..hookinput.originalrowset.rowset.count loop
                    row := t_row();
                    row_ori := hookInput.originalRowset.rowset(i);

                    select count(*) into v_temp from NCI_ADMIN_ITEM_REL where c_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and c_item_ver_nr = ihook.getColumnValue(row_ori,'VER_NR')
                    and P_ITEM_VER_NR = ihook.getColumnValue(row_sel,'VER_NR') and P_ITEM_ID = ihook.getColumnValue(row_sel,'ITEM_ID') and rel_typ_id = 65;

                    if ((v_temp = 0 and hookinput.answerid = 1) or (v_temp=1 and hookinput.answerid=2)) then
                        row := t_row();
                        ihook.setcolumnvalue(row,'C_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
                        ihook.setcolumnvalue(row,'C_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
                        ihook.setcolumnvalue(row,'P_ITEM_VER_NR', ihook.getColumnValue(row_sel,'VER_NR'));
                        ihook.setcolumnvalue(row,'P_ITEM_ID', ihook.getColumnValue(row_sel,'ITEM_ID'));
                        ihook.setcolumnvalue(row,'REL_TYP_ID', 65);
                        rows.extend;
                        rows(rows.last) := row;
                        v_found := true;
                    end if;
                end loop;

                v_tbl_nm := 'Classifications (Insert)';

                if (v_found= true and hookinput.answerid = 1) then 
                        action := t_actionrowset(rows, v_tbl_nm, 2,1,'insert');
                        actions.extend;        actions(actions.last) := action;
                        hookoutput.actions := actions;
         --               raise_application_error(-20000,'In here');
                end if;

                if (v_found= true and hookinput.answerid = 2) then 
                        action := t_actionrowset(rows, v_tbl_nm, 2,2,'delete');
                        actions.extend;                    actions(actions.last) := action;
                        action := t_actionrowset(rows, v_tbl_nm, 2,3,'purge');
                        actions.extend;                    actions(actions.last) := action;
                        hookoutput.actions := actions;
                end if;

         end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  nci_util.debugHook('GENERAL', v_data_out);
END;

PROCEDURE spDesignateNew
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_usr_id  IN varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  
  actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowform t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  
  question    t_question;
  answer     t_answer;
  answers     t_answers;
  
  forms     t_forms;
  form1  t_form;

  v_temp integer;
  v_nm_typ_id integer;
  v_default_txt varchar2(30) := 'Default is Context Name.' ;
  v_cntxt_nm  varchar2(255);
  
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);

  if hookInput.invocationNumber = 0  then
     	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select');
         answers.extend;          answers(answers.last) := answer;
         question := t_question('Choose Option', answers);
       	 hookOutput.question := question;
         row := t_row();

        select obj_key_id into v_nm_typ_id from obj_key where obj_key_desc = 'USED_BY' and obj_typ_id = 11;
      
        ihook.setColumnValue(row, 'NM_TYP_ID', v_nm_typ_id);
        ihook.setColumnValue(row, 'NM_DESC',v_default_txt); -- Default values
        ihook.setColumnValue(row,'ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
        ihook.setColumnValue(row,'VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
        rows := t_rows(); rows.extend;    rows(rows.last) := row;
        rowset := t_rowset(rows, 'Alternate Names', 1, 'ALT_NMS'); -- Default values for form
        
        forms                  := t_forms();
        form1                  := t_form('Alternate Names', 2,1);
        form1.rowset :=rowset;
        forms.extend;    forms(forms.last) := form1;
        hookoutput.forms := forms;
  	elsif hookInput.invocationNumber = 1 then
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);  -- entered values from user
        ihook.setColumnValue(rowform,'ITEM_ID',ihook.getColumnValue(row_ori,'ITEM_ID'));
        ihook.setColumnValue(rowform,'VER_NR',ihook.getColumnValue(row_ori,'VER_NR'));
        
        rows := t_rows();
     
        if ( ihook.getColumnValue(rowform,'NM_DESC') = v_default_txt) then -- Get context name
            select item_nm into v_cntxt_nm from vw_cntxt where item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and ver_nr = ihook.getColumnValue(rowform,'CNTXT_VER_NR');
            ihook.setColumnValue(rowform,'NM_DESC', v_cntxt_nm);
        end if;
      
      -- If row already exists
      select count(*) into v_temp from alt_nms where 
      cntxt_item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(rowform,'CNTXT_VER_NR')
      and item_id = ihook.getColumnValue(rowform,'ITEM_ID') and ver_nr = ihook.getColumnValue(rowform,'VER_NR')
      and nm_typ_id =   ihook.getColumnValue(rowform,'NM_TYP_ID') and nm_desc = ihook.getColumnValue(rowform,'NM_DESC');
      
   --   raise_application_error(-20000, v_temp  || ' ' ||  ihook.getColumnValue(rowform,'NM_TYP_ID') || ' ' || ihook.getColumnValue(rowform,'NM_DESC') || ' ' || ihook.getColumnValue(rowform,'ITEM_ID'));
      
      if (v_temp = 0) then -- Row does not exist
        ihook.setColumnValue(rowform,'NM_ID', -1);  
        
        rows.extend;
        rows(rows.last) := rowform;
        action := t_actionrowset(rows, 'Alternate Names', 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;
       
     end if;
       end if;

if (actions.count > 0) then
  hookoutput.actions := actions;
end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spVDCreateNew ( v_data_in IN CLOB, v_data_out OUT CLOB)
as
  hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_item_id  number;
    v_ver_nr  number(4,2);
    v_ori_rep_cls number;
    v_dflt_txt    varchar2(100) := 'Enter textor auto-generated.';
    rowsetai  t_rowset;
    rowsetst  t_rowset;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;


    row := t_row();   
    ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
    ihook.setColumnValue(row, 'VER_NR', 1.0);
    ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
    ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);  
    ihook.setColumnValue(row, 'ITEM_DESC',v_dflt_txt); -- Default values
    ihook.setColumnValue(row, 'ITEM_NM', v_dflt_txt); -- Default values
    rows := t_rows(); rows.extend;    rows(rows.last) := row;
    rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for form
    rowsetst := t_rowset(rows, 'Value Domain', 1, 'VALUE_DOM'); -- Default values for form

    spVDCommon(rowsetai,rowsetst, 'insert',null, hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;

PROCEDURE spVDCreateFrom ( v_data_in IN CLOB, v_data_out OUT CLOB) as
  hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_item_id  number;
    v_ver_nr  number(4,2);
    v_ori_rep_cls number;
    v_item_type_id number;

    rowsetai  t_rowset;
    rowsetst  t_rowset;
begin
    -- Standard header
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    -- Get the selected row
    row_ori :=  hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_item_type_id := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');

    -- check that a selected AI is VD type
    if (v_item_type_id <> 3) then -- 3 - VALUE DOMAIN in table OBJ_KEY
        raise_application_error(-20000,'!!! This functionality is only applicable for VD !!!');
    end if;

    -- Get original Representation Class
    select rep_cls_item_id into v_ori_rep_cls from value_dom 
                where item_id=v_item_id
                and ver_nr=v_ver_nr;

    row := row_ori;
    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for form

    row := t_row();

     -- Copy Value Domain specific attributes
    nci_11179.spReturnSubtypeRow (v_item_id, v_ver_nr, 3, row );
    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowsetst := t_rowset(rows, 'Value Domain', 1, 'VALUE_DOM'); -- Default values for form
    spVDCommon(rowsetai,rowsetst, 'insert',v_ori_rep_cls, hookinput, hookoutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;

PROCEDURE spVDEdit ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_item_id  number;
    v_ver_nr  number(4,2);
    v_ori_rep_cls number;
    v_item_type_id number;
    rowsetai  t_rowset;
    rowsetst  t_rowset;
begin
    -- Standard header
    hookInput                    := Ihook.gethookinput (v_data_in);
    hookOutput.invocationnumber  := hookInput.invocationnumber;
    hookOutput.originalrowset    := hookInput.originalrowset;

    -- Get the selected row
    row_ori :=  hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_item_type_id := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');

        -- check that a selected AI is VD type
    if (v_item_type_id <> 3) then -- 3 - VALUE DOMAIN in table OBJ_KEY
        raise_application_error(-20000,'!!! This functionality is only applicable for VD !!!');
    end if;

    -- Check if user is authorized to edit
    if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;


    -- Get original Representation Class
    select rep_cls_item_id into v_ori_rep_cls from value_dom 
                where item_id=v_item_id
                and ver_nr=v_ver_nr;

    row := row_ori;
    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for form

    row := t_row();

     -- Copy Value Domain specific attributes
    nci_11179.spReturnSubtypeRow (v_item_id, v_ver_nr, 3, row );
    rows := t_rows();    rows.extend;    rows(rows.last) := row;
    rowsetst := t_rowset(rows, 'Value Domain', 1, 'VALUE_DOM'); -- Default values for form

        spVDCommon(rowsetai,rowsetst, 'update',v_ori_rep_cls, hookInput, hookOutput);

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;

PROCEDURE spVDCommon ( v_init_ai in t_rowset, v_init_st in t_rowset, v_op  in varchar2, v_ori_rep_cls in number, hookInput in t_hookInput, hookOutput in out t_hookOutput)
as 
    rowai t_row;
    rowvd t_row;
    forms t_forms;
    form1 t_form;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_id number;
    v_ver_nr number(4,2);
    actions t_actions := t_actions();
    action t_actionRowset;
    v_msg varchar2(1000);
    i integer := 0;
    v_item_nm varchar2(255);
    v_item_id number;
    v_rep_id number;
    v_item_desc varchar2(4000);
    v_count number;
    v_valid boolean;
    v_temp varchar2(100);
    v_substr  varchar2(100);
    rowsetst t_rowset;
    rowsetai t_rowset;
    v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
 BEGIN


    if hookInput.invocationNumber = 0 then  
        hookOutput.question    := nci_chng_mgmt.getVDCreateQuestion(true);
        hookOutput.forms := nci_chng_mgmt.getVDCreateForm(v_init_ai, v_init_st);
    else -- 
        forms              := hookInput.forms;
        form1              := forms(1);
        rowai := form1.rowset.rowset(1);
        form1              := forms(2);
        rowvd := form1.rowset.rowset(1);
        row := t_row();
        rows := t_rows();

        -- rowai has all the AI supertype attribute. RowVD is the sub-type
        v_item_nm:=ihook.getColumnValue(rowai,'ITEM_NM');
        v_item_desc:=ihook.getColumnValue(rowai,'ITEM_DESC');
    --   raise_application_error(-20000, 'Description. '||ihook.getColumnValue(rowai,'ITEM_DESC'));

       --  Get the new name and desc if different
        if ( ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') is not null and hookInput.answerId = 1 ) then     
                select item_nm into v_temp from admin_item where item_id = ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') 
                and ver_nr = ihook.getColumnValue(rowvd, 'REP_CLS_VER_NR');
          IF v_item_nm=v_temp and (ihook.getColumnValue(rowai,'ITEM_DESC')= v_dflt_txt or ihook.getColumnValue(rowai,'ITEM_DESC') is null)Then	
                select substr(rc.item_desc,1,3999) 
                into v_item_desc
                from  admin_item rc
                where  rc.ver_nr =  ihook.getColumnValue(rowvd, 'REP_CLS_VER_NR')
                and rc.item_id =  ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') ;
            ELSIF ihook.getColumnValue(rowai,'ITEM_NM')= v_dflt_txt   then	
          --if ((trim(substr(v_item_nm, length(v_item_nm)-length(trim(v_temp)))) != v_temp) or
          --length(v_item_nm) < length(v_temp))then                       
                select substr( rc.item_nm,1,255) , 
                substr(rc.item_desc,1,3999) 
                into v_item_nm , v_item_desc
                from  admin_item rc
                where  rc.ver_nr =  ihook.getColumnValue(rowvd, 'REP_CLS_VER_NR')
                and rc.item_id =  ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') ;      
          ELSIF instr(v_item_nm,v_temp)=0 or v_temp= v_dflt_txt   then	
          --if ((trim(substr(v_item_nm, length(v_item_nm)-length(trim(v_temp)))) != v_temp) or
          --length(v_item_nm) < length(v_temp))then                       
                select substr(v_item_nm || ' ' || rc.item_nm,1,255) , 
                substr(v_item_desc || ' ' || rc.item_desc,1,3999) 
                into v_item_nm , v_item_desc
                from  admin_item rc
                where  rc.ver_nr =  ihook.getColumnValue(rowvd, 'REP_CLS_VER_NR')
                and rc.item_id =  ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') ;
            end if;  

        end if;

       v_valid := true;

        if ( ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') is not null) then
            SELECT count(*) into v_count
              FROM admin_item ai, VALUE_DOM vd
             WHERE ai.item_id = vd.item_id
                   AND ai.ver_nr = vd.ver_nr
                   AND ai.ITEM_LONG_NM = ihook.getColumnValue (rowai, 'ITEM_LONG_NM')
                   AND ai.VER_NR =ihook.getColumnValue(rowai, 'VER_NR') 
                   AND ai.ITEM_ID <>ihook.getColumnValue (rowai, 'ITEM_ID')                    
                   AND ai.cntxt_item_id=ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
                   AND ai.cntxt_ver_nr=ihook.getColumnValue(rowai, 'CNTXT_VER_NR');  
        END IF;

        if ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') is not null and v_count>0 then 
          hookoutput.message :=  '****** Duplicate VD found.Please pick other Short Name or Owned By ******';
          v_valid := false;
        elsif v_ori_rep_cls is not null and ihook.getColumnValue(rowvd, 'REP_CLS_ITEM_ID') is null then
         /*when  Rep Term is not Valid and set by application validaion to null*/
          hookoutput.message :='Original Rep Term is not Valid.'||ihook.getColumnValue(rowai,'ITEM_ID')||','||v_rep_id||' Pleas pick one from pop-up.';
       elsif 
        /*when  Rep Term wa taken from 33 or original was null and Rep Term is not choosen to null*/
        (ihook.getColumnValue (rowvd, 'REP_CLS_ITEM_ID') is null and v_ori_rep_cls is null) or ihook.getColumnValue (rowvd, 'REP_CLS_ITEM_ID')  is not null then
         hookoutput.message :='Please review VD Long name and Definition.';

       end if;

        if hookinput.answerid = 1 or v_valid = false then --Validate

        ihook.setColumnValue(rowai, 'ITEM_NM', v_item_nm);
        ihook.setColumnValue(rowai, 'ITEM_DESC', v_item_desc);

        rows := t_rows();      rows.extend;        rows(rows.last) := rowai;
        rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM'); -- Default values for AI

        rows := t_rows();        rows.extend;        rows(rows.last) := rowvd;
        rowsetst := t_rowset(rows, 'Value Domain', 1, 'VALUE_DOM'); -- Default values for Value Doamin

        hookOutput.forms := nci_chng_mgmt.getVDCreateForm(rowsetai, rowsetst);
        hookoutput.question    := nci_chng_mgmt.getVDCreateQuestion(false);

    end if; 

    if (hookinput.answerid = 2 and v_valid = true) then

        row := t_row();
        if (v_op = 'insert') then
                v_id := nci_11179.getItemId;
                ihook.setColumnValue(rowai,'ITEM_ID', v_id);
                ihook.setColumnValue(rowai,'VER_NR', 1);
        end if;
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 3);
        ihook.setColumnValue(rowai,'ITEM_NM', v_item_nm);
        ihook.setColumnValue(rowai,'ITEM_DESC', v_item_desc);

        rows := t_rows();        rows.extend;        rows(rows.last) := rowai;
        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,v_op);
        actions.extend;
        actions(actions.last) := action;

        ihook.setColumnValue(rowvd,'ITEM_ID',  ihook.getColumnValue(rowai,'ITEM_ID'));
       ihook.setColumnValue(rowvd,'VER_NR', ihook.getColumnValue(rowai,'VER_NR'));

        rows := t_rows();        rows.extend;        rows(rows.last) := rowvd;

        action := t_actionrowset(rows, 'Value Domain', 2,2,v_op);
        actions.extend;
        actions(actions.last) := action;


        hookoutput.message := 'VD Created/Updated Successfully. Item Id: ' || ihook.getColumnValue(rowai,'ITEM_ID')  ;
        hookoutput.actions := actions;
        end if;
  end if;

  --  insert into junk_debug(id, test) values (sysdate, v_data_out);
-- 
end;



END;
 /
								 
