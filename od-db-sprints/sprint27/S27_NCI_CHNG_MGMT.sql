create or replace PACKAGE            nci_chng_mgmt AS
v_temp_rep_ver_nr varchar2(10);
v_temp_rep_id VARCHAR2(10);

function getCSICreateQuestion(v_from in number) return t_question;
function getCSCreateQuestion return t_question;
procedure createAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer, actions in out t_actions);
PROCEDURE spDEPrefQuestPost (v_data_in in clob, v_data_out out clob);
PROCEDURE spCreateDE (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2, v_src in varchar2);
PROCEDURE spCreateCS (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
PROCEDURE spDEValCreateImport (rowform in out t_row, v_op in varchar2, actions in out t_actions, v_val_ind in out boolean);
PROCEDURE spDEValCreateImportCons (rowform in out t_row, v_op in varchar2, actions in out t_actions, v_val_ind in out boolean);
PROCEDURE spDECreateFrom ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
--PROCEDURE spDECommon ( v_init_ai in t_rowset, v_init_st in t_rowset, v_op  in varchar2,  v_ori_rep_cls in number, hookInput in t_hookInput, hookOutput in out t_hookOutput);
PROCEDURE spClassification ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spClassificationNMDef ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2, v_typ in varchar2);
PROCEDURE spDesignateNew   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spUndesignate   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spClassifyUnclassify   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spShowClassificationNmDef   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
function getDECreateQuestion(v_from in number,v_first in boolean) return t_question;
function getDECreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
function getCSICreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
function getCSCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
procedure createDE (rowform in t_row, actions in out t_actions, v_id out number);
procedure spAddCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spEditCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDeleteCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);

function get_AI_id(P_ID NUMBER,P_VER in number) RETURN VARCHAR2;
END;
/
create or replace PACKAGE BODY nci_CHNG_MGMT AS
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
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';



PROCEDURE spShowClassificationNmDef   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;

    v_tbl_nm  varchar2(100);
    v_item_id		 number;
    v_ver_nr		 number;
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.Rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_tbl_nm := hookinput.originalRowset.tablename ;

    rows := t_rows();

    if (upper(v_tbl_nm) like '%NAME%') then
    for cur in (select * from alt_nms where item_id = v_item_id and ver_nr = v_ver_nr) loop
        row := t_row();
        ihook.setColumnValue(row,'NM_ID', cur.NM_ID);
        ihook.setColumnValue(row,'ITEM_ID', v_item_id);
        ihook.setColumnValue(row,'VER_NR', v_ver_nr);
        rows.extend; rows(rows.last) := row;
    end loop;
    showRowset := t_showableRowset(rows, 'NCI Alternate Names',2, 'unselectable');
    end if;
    if (upper(v_tbl_nm) like '%DEF%') then
    for cur in (select * from alt_def where item_id = v_item_id and ver_nr = v_ver_nr) loop
        row := t_row();
        ihook.setColumnValue(row,'DEF_ID', cur.DEF_ID);
        ihook.setColumnValue(row,'ITEM_ID', v_item_id);
        ihook.setColumnValue(row,'VER_NR', v_ver_nr);
        rows.extend; rows(rows.last) := row;
    end loop;
    showRowset := t_showableRowset(rows, 'NCI Alternate Definitions',2, 'unselectable');
    end if;

    hookOutput.showRowset := showRowset;

    hookOutput.message := 'Classification Details';
    v_data_out := ihook.getHookOutput(hookOutput);
end;

procedure spAddCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as
 hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  showRowset t_showableRowset;
  rowai t_row;
  rowcsi t_row;
  forms t_forms;
  form1 t_form;

  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowset            t_rowset;
  rowsetde            t_rowset;
 v_id number;
 v_ver_nr number(4,2);
  cnt integer;

    actions t_actions := t_actions();
  action t_actionRowset;
  i integer := 0;
 bEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
     row_ori := hookInput.originalRowset.rowset(1);

   if (ihook.getColumnValue(row_ori,'LVL') = 98) then
   raise_application_error(-20000, 'Cannot create CSI under Context. Please choose CS or CSI.');
   return;
   end if;
    if hookInput.invocationNumber = 0 then
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getCSICreateQuestion(1);
          row := t_row();

          ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
          ihook.setColumnValue(row, 'VER_NR', 1.0);
          ihook.setColumnValue(row, 'ADMIN_STUS_ID', 75);
          ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);
          ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 51);
          ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);

          rows := t_rows(); rows.extend;          rows(rows.last) := row;
          rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
          row := t_row();
           if (ihook.getColumnValue(row_ori,'LVL') = 100) then
                ihook.setColumnValue(row,'P_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
                ihook.setColumnValue(row,'P_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
                for cur1 in (select * from nci_clsfctn_schm_item where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR')) loop
                ihook.setColumnValue(row,'CS_ITEM_ID', cur1.cs_item_id);
                ihook.setColumnValue(row,'CS_ITEM_VER_NR', cur1.cs_item_ver_nr);
                end loop;
            end if;
            if (ihook.getColumnValue(row_ori,'LVL') =99) then
                ihook.setColumnValue(row,'CS_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
                ihook.setColumnValue(row,'CS_ITEM_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
            end if;
            ihook.setColumnValue(row,'ITEM_ID', -1);
            ihook.setColumnValue(row,'VER_NR', 1);

                 rows := t_rows(); rows.extend;          rows(rows.last) := row;
                 rowsetde := t_rowset(rows, 'CSI', 1, 'NCI_CLSFCTN_SCHM_ITEM');
          hookOutput.forms := nci_chng_mgmt.getCSICreateForm(rowset, rowsetde);
  ELSE
            forms              := hookInput.forms;
            form1              := forms(1);
            rowai := form1.rowset.rowset(1);
            form1              := forms(2);
            rowcsi := form1.rowset.rowset(1);

            v_id := nci_11179.getItemId;

            ihook.setColumnValue(rowai,'ITEM_ID', v_id);
            ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 51);
            ihook.setColumnValue(rowai,'ITEM_LONG_NM', v_id || 'v1.00');

            ihook.setColumnValue(rowcsi,'ITEM_ID', v_id);
            ihook.setColumnValue(rowcsi,'VER_NR', 1.0);
            if (ihook.getColumnValue(rowcsi,'P_ITEM_ID') is not null) then
    -- use CS from Parent
                for cur1 in (select * from vw_clsfctn_schm_item where item_id = ihook.getColumnValue(rowcsi,'P_ITEM_ID') and ver_nr = ihook.getColumnValue(rowcsi,'P_ITEM_VER_NR')) loop
                    ihook.setColumnValue(rowcsi,'CS_ITEM_ID', cur1.cs_item_id);
                    ihook.setColumnValue(rowcsi,'CS_ITEM_VER_NR', cur1.cs_item_VER_NR);
                end loop;
            end if;
            -- Context is context of CS
            for cur1 in (select * from admin_item where item_id = ihook.getColumnValue(rowcsi,'CS_ITEM_ID') and ver_nr = ihook.getColumnValue(rowcsi,'CS_ITEM_VER_NR')) loop
                ihook.setColumnValue(rowai, 'CNTXT_ITEM_ID', cur1.CNTXT_ITEM_ID);
                ihook.setColumnValue(rowai, 'CNTXT_VER_NR', cur1.CNTXT_VER_NR);
            end loop;

            rows := t_rows();    rows.extend;    rows(rows.last) := rowai;
            action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
            actions.extend;    actions(actions.last) := action;

            rows := t_rows();    rows.extend;    rows(rows.last) := rowcsi;
            action := t_actionrowset(rows, 'CSI', 2,2,'insert');
            actions.extend;    actions(actions.last) := action;

            hookoutput.message := 'CSI Created Successfully with ID ' || v_id ;
            hookoutput.actions := actions;

    end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

END;


procedure spEditCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as
 hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  showRowset t_showableRowset;
  rowai t_row;
  rowcsi t_row;
  forms t_forms;
  form1 t_form;

  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowset            t_rowset;
  rowsetde            t_rowset;
 v_item_id number;
 v_ver_nr number(4,2);
  cnt integer;

    actions t_actions := t_actions();
  action t_actionRowset;
  i integer := 0;
 bEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
     row_ori := hookInput.originalRowset.rowset(1);
      v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
          v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');

   if (ihook.getColumnValue(row_ori,'LVL') <> 100) then
   raise_application_error(-20000, 'Please select a CSI to edit.');
   return;
   end if;
    if hookInput.invocationNumber = 0 then
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getCSICreateQuestion(2);
          v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
          v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
       --   raise_application_error(-20000, v_item_id);
          row := t_row();
          nci_11179.spReturnAIRow(v_item_id, v_ver_nr, row);
   --   raise_application_error(-20000, ihook.getColumnValue(row, 'ADMIN_STUS_ID'));
   
          rows := t_rows(); rows.extend;          rows(rows.last) := row;
          rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
          row := t_row();
          nci_11179.spReturnSubtypeRow(v_item_id, v_ver_nr,51, row);

                 rows := t_rows(); rows.extend;          rows(rows.last) := row;
                 rowsetde := t_rowset(rows, 'CSI', 1, 'NCI_CLSFCTN_SCHM_ITEM');
          hookOutput.forms := getCSICreateForm(rowset, rowsetde);
  ELSE
            forms              := hookInput.forms;
            form1              := forms(1);
            rowai := form1.rowset.rowset(1);
            form1              := forms(2);
            rowcsi := form1.rowset.rowset(1);

            ihook.setColumnValue(rowai,'ITEM_ID', v_item_id);
             ihook.setColumnValue(rowai,'VER_NR', v_ver_nr);
           ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 51);
            ihook.setColumnValue(rowai,'ITEM_LONG_NM', v_item_id || 'v1.00');

            ihook.setColumnValue(rowcsi,'ITEM_ID', v_item_id);
            ihook.setColumnValue(rowcsi,'VER_NR', v_ver_nr);
            if (ihook.getColumnValue(rowcsi,'P_ITEM_ID') is not null) then
             if (nci_11179_2.isCSParentCSIValid(rowcsi) = false) then
                HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getCSICreateQuestion(2);
                rows := t_rows(); rows.extend;          rows(rows.last) := rowai;
                rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');

                 rows := t_rows(); rows.extend;          rows(rows.last) := rowcsi;
                 rowsetde := t_rowset(rows, 'CSI', 1, 'NCI_CLSFCTN_SCHM_ITEM');
          hookOutput.forms := nci_chng_mgmt.getCSICreateForm(rowset, rowsetde);
         hookoutput.message := 'Parent CSI should belong to the same Classification Scheme as specified.';
             end if;
          /*      for cur1 in (select * from vw_clsfctn_schm_item where item_id = ihook.getColumnValue(rowcsi,'P_ITEM_ID') and ver_nr = ihook.getColumnValue(rowcsi,'P_ITEM_VER_NR')) loop
                    ihook.setColumnValue(rowcsi,'CS_ITEM_ID', cur1.cs_item_id);
                    ihook.setColumnValue(rowcsi,'CS_ITEM_VER_NR', cur1.cs_item_VER_NR);
                end loop; */
            end if;
            -- Context is context of CS
             if (nci_11179_2.isCSParentCSIValid(rowcsi) = true) then
           /* for cur1 in (select * from admin_item where item_id = ihook.getColumnValue(rowcsi,'CS_ITEM_ID') and ver_nr = ihook.getColumnValue(rowcsi,'CS_ITEM_VER_NR')) loop
                ihook.setColumnValue(rowai, 'CNTXT_ITEM_ID', cur1.CNTXT_ITEM_ID);
                ihook.setColumnValue(rowai, 'CNTXT_VER_NR', cur1.CNTXT_VER_NR);
            end loop;
*/
            rows := t_rows();    rows.extend;    rows(rows.last) := rowai;
            action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'update');
            actions.extend;    actions(actions.last) := action;

            rows := t_rows();    rows.extend;    rows(rows.last) := rowcsi;
            action := t_actionrowset(rows, 'CSI', 2,2,'update');
            actions.extend;    actions(actions.last) := action;
            nci_11179_2.updCSIHier (rowcsi,actions);
            hookoutput.message := 'CSI updated Successfully with ID ' || v_item_id ;
            hookoutput.actions := actions;
            end if;
    end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  --nci_util.debugHook('GENERAL', v_data_out);
END;


procedure spDeleteCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
as
 hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  showRowset t_showableRowset;
  rowai t_row;
  rowcsi t_row;
  forms t_forms;
  form1 t_form;
  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowset            t_rowset;
  rowsetde            t_rowset;
 v_item_id number;
 v_ver_nr number(4,2);
  cnt integer;

    actions t_actions := t_actions();
  action t_actionRowset;
  i integer := 0;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
     row_ori := hookInput.originalRowset.rowset(1);

   if (ihook.getColumnValue(row_ori,'LVL') <> 100) then
   raise_application_error(-20000, 'Please select a CSI to delete.');
   return;
   end if;
     v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
          v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');

   for cur in (select ai.* from admin_item ai, nci_clsfctn_schm_item csi where p_item_id= v_item_id and p_item_ver_nr = v_ver_nr and nvl(ai.fld_delete,0) = 0
   and csi.item_id = ai.item_id and csi.ver_nr = ai.ver_nr and upper(ai.admin_stus_nm_dn) not like '%DELETED%') loop
    raise_application_error(-20000, 'Select CSI has children nodes. Please move children before deleting.');
    end loop;

   for cur in (select * from NCI_CSI_ALT_DEFNMS where  NCI_PUB_ID =v_item_id and NCI_VER_NR = v_ver_nr and nvl(fld_delete,0) = 0) loop
        raise_application_error(-20000, 'CSI linked to Alternate Names or Definition classifications. Please delete before CSI can be deleted.');
    end loop;


   for cur in (select * from NCI_ADMIN_ITEM_REL where  P_ITEM_ID= v_item_id and P_ITEM_VER_NR = v_ver_nr and rel_typ_id = 65 and nvl(fld_delete,0) = 0) loop
        raise_application_error(-20000, 'Classifications found for this CSI. Please delete classification before CSI can be deleted.');
    end loop;

   row := t_row();
          nci_11179.spReturnAIRow(v_item_id, v_ver_nr, row);
            ihook.setColumnValue(row,'ADMIN_STUS_ID', 77);
              ihook.setColumnValue(row,'UNTL_DT', to_char(sysdate, DEFAULT_TS_FORMAT) );

            rows := t_rows();    rows.extend;    rows(rows.last) := row;
            action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'update');
            actions.extend;    actions(actions.last) := action;

update nci_clsfctn_schm_item set CS_ITEM_ID = null, CS_ITEM_VER_NR = null, P_ITEM_ID = null, P_ITEM_VER_NR = null where 
item_id = v_item_id and ver_nr = v_ver_nr;
commit;

 --row := t_row();
   --       nci_11179.spReturnSubTypeRow(v_item_id, v_ver_nr, 51, row);
       --    ihook.setColumnValue(row,'CS_ITEM_ID',' ');
        --  ihook.setColumnValue(row,'CS_ITEM_VER_NR', ' ');
         --     ihook.setColumnValue(row,'P_ITEM_ID', '');
         --   ihook.setColumnValue(row,'P_ITEM_VER_NR', '');

           rows := t_rows();    rows.extend;    rows(rows.last) := row;
            action := t_actionrowset(rows, 'CSI', 2,2,'update');
            actions.extend;    actions(actions.last) := action;
            hookoutput.message := 'CSI deleted Successfully with ID ' || v_item_id ;
            hookoutput.actions := actions;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

END;

PROCEDURE spCreateDE (v_data_in IN CLOB,    v_data_out OUT CLOB, v_usr_id  IN varchar2, v_src in varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    showRowset t_showableRowset;
    rowai t_row;
    rowde t_row;
    forms t_forms;
    form1 t_form;
    c_ver_suffix varchar2(5) := 'v1.00';
    row t_row;
    rows  t_rows;
    row_ori t_row;
    rowset            t_rowset;
    rowsetai            t_rowset;
    rowsetde            t_rowset;
         v_item_id  number;
         v_item_type_id  number;

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
    v_unq_id number;
    v_unq_ver number(4,2);
    v_temp_id  number;
    v_temp_ver number(4,2);
    is_valid boolean;
    V_valid boolean;
    v_err_str varchar2(4000);
    v_dup boolean := false;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    if hookInput.invocationNumber = 0 then
    if (v_src = 'C') then -- create new
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion(1,true);
          row := t_row();
          rows := t_rows();
       nci_11179_2.setStdAttr(row);
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
    end if;
    if (v_src = 'E') then -- create from Existing

    row_ori :=  hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_item_type_id := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');


    if (v_item_type_id <> 4) then -- 4 - CDE in table OBJ_KEY
        raise_application_error(-20000,'!!! This functionality is only applicable for CDE !!!');
    end if;

        HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion(2,true);
        row := row_ori;
        rows := t_rows();
       nci_11179_2.setStdAttr(row);
             ihook.setColumnValue(row, 'ITEM_ID', -1);
 ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);

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
  end if;
  ELSE
      forms              := hookInput.forms;
      form1              := forms(1);
      rowai := form1.rowset.rowset(1);
      form1              := forms(2);
      rowde := form1.rowset.rowset(1);
       row := t_row();
      rows := t_rows();

      v_valid := true;

      for cur in (select ai.item_id from  admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and de.de_conc_item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID')
            and de.de_conc_ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and de.val_dom_item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID')
            and de.val_dom_ver_nr =  ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR')) loop
                v_valid := false;
                 hookoutput.message := 'Duplicate CDE found based on DEC/VD/Context: ' ||cur.item_id;
        end loop;

  for cur in (select ai.item_id from  admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and de.de_conc_item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID')
            and de.de_conc_ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and de.val_dom_item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID')
            and de.val_dom_ver_nr =  ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR')) loop
        --    and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
        --    and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR')) loop
                v_dup := true;
 --                hookoutput.message := 'Duplicate CDE found based on DEC/VD/Context: ' ||cur.item_id;
        end loop;


      if (v_valid = true) then
          nci_11179_2.stdAIValidation(rowai, 4,v_valid, v_err_str);
        if (v_valid = false) then
        hookoutput.message := v_err_str;
        end if;
        end if;

-- Derivation rule/Derivation Type
    if (v_valid = true and ( (ihook.getColumnValue (rowde, 'DERV_TYP_ID') is not null and ihook.getColumnValue (rowde, 'DERV_RUL') is null) or
        (ihook.getColumnValue (rowde, 'DERV_TYP_ID') is null and ihook.getColumnValue (rowde, 'DERV_RUL') is not null))) then
                v_valid := false;
                hookoutput.message := 'Derivation Type or Derivation Rule is missing. ';
        end if;

    select substr(dec.item_nm || ' ' || vd.item_nm,1,255) ,substr(dec.item_desc || ':' || vd.item_desc,  1, 4000) into v_item_nm, v_item_def from admin_item dec, admin_item vd
            where dec.item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID') and dec.ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and vd.item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID') and vd.ver_nr = ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR');

   if hookinput.answerid = 1 or v_valid = false then --Validate

        ihook.setColumnValue(rowai,'ITEM_NM', v_item_nm);

        ihook.setColumnValue(rowai,'ITEM_DESC',v_item_def);
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID',4);

        if hookinput.answerid = 1 and v_valid = true and v_dup = false then --Validate
            hookoutput.message := 'Validation Successful';
        end if;


        if hookinput.answerid = 1 and v_valid = true and v_dup = true then --Warning
            hookoutput.message := 'WARNING: Duplicates found in other contexts.';
        end if;

          rows.extend;
          rows(rows.last) := rowai;
          rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
          rows := t_rows();
            rows.extend;
          rows(rows.last) := rowde;
          rowsetde := t_rowset(rows, 'Data Element', 1, 'DE');
           v_valid := false;
          hookOutput.forms := nci_chng_mgmt.getDECreateForm(rowset, rowsetde);
          if (v_src = 'E') then
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion(2,v_valid);
          else
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion(1,v_valid);
          end if;

          --V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

    end if;

    if (hookinput.answerid = 2 and v_valid = true) then

       v_id := nci_11179.getItemId;
       row := t_row();
        ihook.setColumnValue(rowai,'ITEM_ID', v_id);
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 4);

         select substr(dec.item_nm || ' ' || vd.item_nm,1,255) ,substr(dec.item_desc || ':' || vd.item_desc,  1, 4000) into v_item_nm, v_item_def from admin_item dec, admin_item vd
            where dec.item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID') and dec.ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and vd.item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID') and vd.ver_nr = ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR');

        if ( ihook.getColumnValue(rowai,'ITEM_LONG_NM')= v_dflt_txt or ihook.getColumnValue(rowai,'ITEM_LONG_NM') is null or upper(ihook.getColumnValue(rowai,'ITEM_LONG_NM')) = 'SYSGEN') then
        ihook.setColumnValue(rowai,'ITEM_LONG_NM', ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID') || 'v'
        || trim(to_char(ihook.getColumnValue(rowde, 'DE_CONC_VER_NR'), '9999.99')) || ':' || ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID') || 'v' ||
        trim(to_char(ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR'), '9999.99')));
        end if;
        if ( ihook.getColumnValue(rowai,'ITEM_NM')= v_dflt_txt) then
        ihook.setColumnValue(rowai,'ITEM_NM', v_item_nm);
        end if;
        if ( ihook.getColumnValue(rowai,'ITEM_DESC')= v_dflt_txt) then
        ihook.setColumnValue(rowai,'ITEM_DESC',v_item_def);
        end if;
        if (ihook.getColumnValue(rowde, 'PREF_QUEST_TXT') = v_dflt_txt) then
        ihook.setColumnValue(rowde, 'PREF_QUEST_TXT', 'Data Element ' || v_item_nm|| ' does not have Preferred Question Text.'   );
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

    -- Add derivation components if Createe from Existing
    -- if Derivation Type is set and there are components in the original DDE
    if (v_src = 'E') then
        row_ori :=  hookInput.originalRowset.rowset(1);
        v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');

        if (ihook.getColumnValue(rowde, 'DERV_TYP_ID') is not null ) then
          nci_11179_2.copyDDEComponents(v_item_id, v_ver_nr, v_id, 1, actions);
        end if;
    end if;
          hookoutput.message := 'CDE Created Successfully with ID ' || v_id ;
        hookoutput.actions := actions;
 end if;
 end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

END;


PROCEDURE spCreateCS (v_data_in IN CLOB,    v_data_out OUT CLOB, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    showRowset t_showableRowset;
    rowai t_row;
    rowcs t_row;
    forms t_forms;
    form1 t_form;
    c_ver_suffix varchar2(5) := 'v1.00';
    row t_row;
    rows  t_rows;
    rowset            t_rowset;
    rowsetai            t_rowset;
    rowsetcs            t_rowset;
         v_item_id  number;
         v_item_typ_id  number;

    v_str  varchar2(255);
    v_nm  varchar2(255);
    v_id number;
    v_ver_nr number(4,2);

    actions t_actions := t_actions();
    action t_actionRowset;
    v_long_nm varchar2(255);

    v_temp_id  number;
    v_temp_ver number(4,2);
    v_valid boolean;

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  v_item_typ_id := 9;

    if hookInput.invocationNumber = 0 then
           HOOKOUTPUT.QUESTION    := getCSCreateQuestion;
          row := t_row();
          rows := t_rows();
          ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
          ihook.setColumnValue(row, 'VER_NR', 1.0);
          ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
          ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);
          ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', v_item_typ_id);
          ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);
          rows.extend;
          rows(rows.last) := row;
          rowsetai := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
           rows := t_rows();
          row := t_row();
            ihook.setColumnValue(row, 'ITEM_ID', -1);
          ihook.setColumnValue(row, 'VER_NR', 1);
            rows.extend;
          rows(rows.last) := row;

          rowsetcs := t_rowset(rows, 'Classification Scheme', 1, 'CLSFCTN_SCHM');

          hookOutput.forms := nci_chng_mgmt.getCSCreateForm(rowsetai, rowsetcs);


  ELSE
      forms              := hookInput.forms;
      form1              := forms(1);
      rowai := form1.rowset.rowset(1);
      form1              := forms(2);
      rowcs := form1.rowset.rowset(1);
      v_valid := true;
          nci_11179_2.stdAIValidation(rowai, v_item_typ_id ,v_valid, v_err_str);
        if (v_valid = false) then
        hookoutput.message := v_err_str;
        end if;


        if v_valid = false then --Validate
            rows := t_rows();
            rows.extend;          rows(rows.last) := rowai;
            rowset := t_rowset(rows, 'Administered Item', 1, 'ADMIN_ITEM');
            rows := t_rows();
            rows.extend;          rows(rows.last) := rowcs;
            rowsetcs := t_rowset(rows, 'Classification Scheme', 1, 'CLSFCTN_SCHM');
            v_valid := false;
             hookOutput.forms := nci_chng_mgmt.getCSCreateForm(rowset, rowsetcs);
            HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getCSCreateQuestion;
          --V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

        end if;

        if ( v_valid = true) then
            v_id := nci_11179.getItemId;
                ihook.setColumnValue(rowai,'ITEM_ID', v_id);
                ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', v_item_typ_id);

                 if ( ihook.getColumnValue(rowai,'ITEM_LONG_NM')= v_dflt_txt) then
                    ihook.setColumnValue(rowai,'ITEM_LONG_NM', v_id ||'v1.00');
                end if;

            rows := t_rows();
            rows.extend;    rows(rows.last) := rowai;
            action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
            actions.extend;
            actions(actions.last) := action;

             ihook.setColumnValue(rowcs,'ITEM_ID', v_id);
            ihook.setColumnValue(rowcs,'VER_NR', 1.00);
             rows := t_rows();
            rows.extend;    rows(rows.last) := rowcs;

            action := t_actionrowset(rows, 'Classification Scheme', 2,2,'insert');
            actions.extend;
            actions(actions.last) := action;
            hookoutput.message := 'CS Created Successfully with ID ' || v_id ;
                hookoutput.actions := actions;
        end if;
 end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 -- nci_util.debugHook('GENERAL', v_data_out);
END;

PROCEDURE spDEValCreateImport (rowform in out t_row, v_op in varchar2, actions in out t_actions, v_val_ind in out boolean)
AS
    c_ver_suffix varchar2(5) := 'v1.00';
    row t_row;
    rows  t_rows;

    v_dec_item_id number;
    v_dec_ver_nr number(4,2);
    v_vd_item_id number;
    v_vd_ver_nr number(4,2);

    v_nm  varchar2(255);
    v_id number;
    action t_actionRowset;
    v_item_nm varchar2(255);
    v_dec_item_nm varchar2(255);
    v_dec_item_def varchar2(4000);
    v_vd_item_nm varchar2(255);
    v_vd_item_def  varchar2(4000);
    v_item_def varchar2(4000);
    v_err_str varchar2(4000) := ' ';
    v_retired boolean := false;

BEGIN
       row := t_row();
       rows := t_rows();

     v_dec_item_id := ihook.getColumnValue(rowform, 'DE_CONC_ITEM_ID');
        v_dec_ver_nr := ihook.getColumnValue(rowform, 'DE_CONC_VER_NR');
        v_val_ind := true;
        --   raise_application_error(-20000,'Test');
 -- 
-- if DEC specified or found, if VD specified
   if (v_dec_item_id is null) then
 --  raise_application_error(-20000,'TEst');
    for cur in (select * from admin_item where admin_item_typ_id = 2 and item_id = ihook.getColumnValue(rowform, 'ITEM_1_ID')
    and ver_nr =  ihook.getColumnValue(rowform, 'ITEM_1_VER_NR')  and nvl(fld_delete,0) = 0) loop
  
    if (upper(cur.admin_stus_nm_dn) like '%RETIRED%') then
        v_val_ind := false;
         v_err_str :=  'Error: DEC is Retired.' || chr(13);
    else
        ihook.setColumnValue(rowform, 'DE_CONC_ITEM_ID',cur.item_id);
        ihook.setColumnValue(rowform, 'DE_CONC_VER_NR', cur.ver_nr);
        v_dec_item_id := ihook.getColumnValue(rowform, 'DE_CONC_ITEM_ID');
        v_dec_ver_nr := ihook.getColumnValue(rowform, 'DE_CONC_VER_NR');
     --   raise_application_error(-20000, cur.admin_stus_nm_dn);
         if (upper(cur.admin_stus_nm_dn) not like '%RELEASED%') then
     --        v_val_ind := false;
         v_err_str :=  v_err_str || 'Warning: DEC is not Released.' || chr(13);
         end if;
    end if;
    end loop;
    
     if (v_dec_item_id is null and v_val_ind = true) then
        v_val_ind := false;
        v_err_str := v_err_str  || 'Error: DEC not found.'|| chr(13);
        end if;
    end if;
    
      v_vd_item_id := ihook.getColumnValue(rowform, 'VAL_DOM_ITEM_ID') ;
        v_vd_ver_nr := ihook.getColumnValue(rowform, 'VAL_DOM_VER_NR') ;
        v_retired := false;
         if (v_vd_item_id is null) then
      for cur in (select * from admin_item where admin_item_typ_id = 3  and item_id = ihook.getColumnValue(rowform, 'ITEM_2_ID')
    and ver_nr =  ihook.getColumnValue(rowform, 'ITEM_2_VER_NR') and nvl(fld_delete,0) = 0 ) loop
   --  raise_application_error(-20000, 'HErer');
 if (upper(cur.admin_stus_nm_dn) like '%RETIRED%') then
        v_val_ind := false;
          v_err_str :=  v_err_str ||'Error: VD is Retired.' || chr(13);
          v_retired := true;
    else
        ihook.setColumnValue(rowform, 'VAL_DOM_ITEM_ID', cur.item_id);
        ihook.setColumnValue(rowform, 'VAL_DOM_VER_NR', cur.ver_nr);
        v_vd_item_id := ihook.getColumnValue(rowform, 'VAL_DOM_ITEM_ID') ;
        v_vd_ver_nr := ihook.getColumnValue(rowform, 'VAL_DOM_VER_NR') ;
           if (upper(cur.admin_stus_nm_dn) not like '%RELEASED%') then
     --        v_val_ind := false;
         v_err_str :=  v_err_str ||'Warning: VD is not Released.' || chr(13);
         end if;
    end if;
    end loop;
   end if;
    if (v_vd_item_id is null and v_retired = false ) then
        v_val_ind := false;
         v_err_str := v_err_str  || 'Error: VD not found.'|| chr(13);
        end if;
   /* 
Warning: PQT null, default used
*/
   
         if (ihook.getColumnValue(rowform, 'PREF_QUEST_TXT') is null) then
         
           v_err_str := v_err_str  || 'Warning: PQT null, default will be used'|| chr(13);
           end if;
        
         ihook.setColumnValue(rowform, 'CTL_VAL_MSG', v_err_str);
           
        if (v_val_ind = false) then
        
            return;
        end if;
        
   --     raise_application_error(-20000,'Test');
 --       if (v_op = 'V') then  --- check if CDE is a duplicate
            for cur in (select ai.item_id item_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and de.de_conc_item_id = v_dec_item_id
            and de.de_conc_ver_nr =  v_dec_ver_nr
            and de.val_dom_item_id =  v_vd_item_id
            and de.val_dom_ver_nr =  v_vd_ver_nr
            and ai.cntxt_item_id = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowform, 'CNTXT_VER_NR')) loop
                v_val_ind := false;
                ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'Duplicate CDE found : ' || cur.item_id);
                return;
            end loop;
         --end if;

        if (ihook.getColumnValue(rowform, 'CDE_ITEM_LONG_NM') is not null ) then  --- check if CDE short name specirfied
       -- raise_application_Error(-20000, ihook.getColumnValue(rowform, 'CDE_ITEM_LONG_NM'));
            for cur in (select ai.item_id item_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and ai.ITEM_LONG_NM=ihook.getColumnValue(rowform,'CDE_ITEM_LONG_NM')
            and  ai.ver_nr =  1
            and ai.cntxt_item_id = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowform, 'CNTXT_VER_NR')) loop
                v_val_ind := false;
                ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'Duplicate CDE found based on context/short name: ' || cur.item_id || chr(13));
                return;
            end loop;
        end if;

  if (v_val_ind = true) then
                      ihook.setColumnValue(rowform, 'CTL_VAL_STUS', 'VALIDATED');
   
           
        end if;

    if (v_op = 'C') then -- create
        row := t_row();

    -- Item name - DE name if specified; DEC NAme - specified/found/generated; vd name - specified/generated
   --     raise_application_error(-20000, 'Front' || v_dec_item_id);

                select item_nm, item_desc into v_dec_item_nm, v_dec_item_def from admin_item where item_id = v_dec_item_id and ver_nr = v_dec_ver_nr;

                select item_nm, item_desc into v_vd_item_nm, v_vd_item_def from admin_item where item_id = v_vd_item_id and ver_nr = v_vd_ver_nr;

        if (ihook.getColumnValue(rowform, 'CDE_ITEM_NM') is not null) then
            ihook.setColumnValue(row, 'ITEM_NM',ihook.getColumnValue(rowform, 'CDE_ITEM_NM'));
        else
            ihook.setColumnValue(row, 'ITEM_NM',substr(v_dec_item_nm || ' ' || v_vd_item_nm, 1, 255));
        end if;
    -- item def - DEC def - specified/found.genetered; vd def - specified/generated
 --  raise_application_error(-20000, 'Above ' || v_dec_item_def || 'After');
   -- raise_application_error(-20000, 'Above ' );

          ihook.setColumnValue(row, 'ITEM_DESC',substr(v_dec_item_def || ' ' || v_vd_item_def,1,4000));
          if (ihook.getColumnValue(rowform, 'CDE_ITEM_DESC') is not null) then
            ihook.setColumnValue(row, 'ITEM_DESC',ihook.getColumnValue(rowform, 'CDE_ITEM_DESC'));
        else
          ihook.setColumnValue(row, 'ITEM_DESC',v_dec_item_def);
          end if;
            ihook.setColumnValue(row, 'PREF_QUEST_TXT',nvl(ihook.getColumnValue(rowform, 'PREF_QUEST_TXT'),'Data Element ' || ihook.getColumnValue(row, 'ITEM_NM')|| ' does not have Preferred Question Text.'   ));
            ihook.setColumnValue(rowform, 'PREF_QUEST_TXT',nvl(ihook.getColumnValue(rowform, 'PREF_QUEST_TXT'),'Data Element ' || ihook.getColumnValue(row, 'ITEM_NM')|| ' does not have Preferred Question Text.'   ));

       v_id := nci_11179.getItemId;

        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 4);

        ihook.setColumnValue(row,'ITEM_LONG_NM', nvl( ihook.getColumnValue(rowform, 'CDE_ITEM_LONG_NM'), v_id || c_ver_suffix));

        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'ADMIN_STUS_ID',66);
        ihook.setColumnValue(row,'REGSTR_STUS_ID',9);
        ihook.setColumnValue(row,'DE_CONC_ITEM_ID',nvl(v_dec_item_id, ihook.getColumnValue(rowform, 'DE_CONC_ITEM_ID_CREAT') ));
        ihook.setColumnValue(row,'DE_CONC_VER_NR',nvl(v_dec_ver_nr, 1 ));
        ihook.setColumnValue(row,'VAL_DOM_ITEM_ID',nvl(v_vd_item_id, ihook.getColumnValue(rowform, 'VAL_DOM_ITEM_ID_CREAT') ));
        ihook.setColumnValue(row,'VAL_DOM_VER_NR',nvl(v_vd_ver_nr, 1 ));
  --  raise_application_error(-20000, 'Here' || ihook.getColumnValue(row, 'ITEM_DESC') );

        rows.extend;
        rows(rows.last) := row;
        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,10,'insert');
        actions.extend;
        actions(actions.last) := action;

        action := t_actionrowset(rows, 'Data Element', 2,11,'insert');
        actions.extend;
        actions(actions.last) := action;

        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID', v_id);
    ihook.setColumnValue(row,'VER_NR', 1.00);
     ihook.setColumnValue(row,'REF_NM', substr(ihook.getColumnValue(rowform, 'PREF_QUEST_TXT'),1,255));
     ihook.setColumnValue(row,'REF_DESC', ihook.getColumnValue(rowform, 'PREF_QUEST_TXT'));
     ihook.setColumnValue(row,'LANG_ID', 1000);
     ihook.setColumnValue(row,'NCI_CNTXT_ITEM_ID',ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID')  );
     ihook.setColumnValue(row,'NCI_CNTXT_VER_NR',ihook.getColumnValue(rowform, 'CNTXT_VER_NR')  );
     ihook.setColumnValue(row,'REF_TYP_ID', 80);

     ihook.setColumnValue(row,'REF_ID', -1);
     rows := t_rows();
     rows.extend;
    rows(rows.last) := row;
    action := t_actionrowset(rows, 'References (for hook insert)', 2,12,'insert');
    actions.extend;
    actions(actions.last) := action;
  --  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'CDE Created Successfully with ID ' || v_id ||  chr(13)) ;
    ihook.setColumnValue(rowform, 'CTL_VAL_MSG',  'CDE Created Successfully with ID ' || v_id ||  chr(13)) ;
    ihook.setColumnValue(rowform, 'CTL_VAL_STUS', 'PROCESSED') ;


 end if;

END;


PROCEDURE spDEValCreateImportCons (rowform in out t_row, v_op in varchar2, actions in out t_actions, v_val_ind in out boolean)
AS
    c_ver_suffix varchar2(5) := 'v1.00';
    row t_row;
    rows  t_rows;

    v_dec_item_id number;
    v_dec_ver_nr number(4,2);
    v_vd_item_id number;
    v_vd_ver_nr number(4,2);

    v_nm  varchar2(255);
    v_id number;
    action t_actionRowset;
    v_item_nm varchar2(255);
    v_dec_item_nm varchar2(255);
    v_dec_item_def varchar2(4000);
    v_vd_item_nm varchar2(255);
    v_vd_item_def  varchar2(4000);
    v_item_def varchar2(4000);

BEGIN
       row := t_row();
       rows := t_rows();

-- if DEC specified or found, if VD specified
        v_dec_item_id := nvl(ihook.getColumnValue(rowform, 'DE_CONC_ITEM_ID') ,ihook.getColumnValue(rowform, 'DE_CONC_ITEM_ID_FND'));
        v_dec_ver_nr := nvl(ihook.getColumnValue(rowform, 'DE_CONC_VER_NR') ,ihook.getColumnValue(rowform, 'DE_CONC_VER_NR_FND'));
        v_vd_item_id := ihook.getColumnValue(rowform, 'VAL_DOM_ITEM_ID') ;
        v_vd_ver_nr := ihook.getColumnValue(rowform, 'VAL_DOM_VER_NR') ;


        if (v_op = 'V') and v_dec_item_id is not null and v_vd_item_id is not null then  --- check if CDE is a duplicate
            for cur in (select ai.item_id item_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and de.de_conc_item_id = v_dec_item_id
            and de.de_conc_ver_nr =  v_dec_ver_nr
            and de.val_dom_item_id =  v_vd_item_id
            and de.val_dom_ver_nr =  v_vd_ver_nr
            and ai.cntxt_item_id = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowform, 'CNTXT_VER_NR')) loop
                v_val_ind := false;
                ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'Duplicate CDE found : ' || cur.item_id);
                return;
            end loop;
         end if;

        if (v_op = 'V') and ihook.getColumnValue(rowform, 'CDE_ITEM_LONG_NM') is not null then  --- check if CDE short name specirfied
       -- raise_application_Error(-20000, ihook.getColumnValue(rowform, 'CDE_ITEM_LONG_NM'));
            for cur in (select ai.item_id item_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and ai.ITEM_LONG_NM=ihook.getColumnValue(rowform,'CDE_ITEM_LONG_NM')
            and  ai.ver_nr =  1
            and ai.cntxt_item_id = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowform, 'CNTXT_VER_NR')) loop
                v_val_ind := false;
                ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'Duplicate CDE found based on context/short name: ' || cur.item_id || chr(13));
                return;
            end loop;
        end if;



    if (v_op = 'C') then -- create
        row := t_row();

    -- Item name - DE name if specified; DEC NAme - specified/found/generated; vd name - specified/generated
   --     raise_application_error(-20000, 'Front' || v_dec_item_id);

        if (v_dec_item_id is not null) then
                select item_nm, item_desc into v_dec_item_nm, v_dec_item_def from admin_item where item_id = v_dec_item_id and ver_nr = v_dec_ver_nr;
        else
                v_dec_item_nm := ihook.getColumnValue(rowform, 'GEN_DE_CONC_NM');
                v_dec_item_def := substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000);
        end if;

        if (v_vd_item_id is not null) then
                select item_nm, item_desc into v_vd_item_nm, v_vd_item_def from admin_item where item_id = v_vd_item_id and ver_nr = v_vd_ver_nr;
        else
                v_vd_item_nm := ihook.getColumnValue(rowform, 'VAL_DOM_NM')  ;
                v_vd_item_def := ihook.getColumnValue(rowform, 'ITEM_3_DEF');
        end if;

        if (ihook.getColumnValue(rowform, 'CDE_ITEM_NM') is not null) then
            ihook.setColumnValue(row, 'ITEM_NM',ihook.getColumnValue(rowform, 'CDE_ITEM_NM'));
        else
            ihook.setColumnValue(row, 'ITEM_NM',substr(v_dec_item_nm || ' ' || v_vd_item_nm, 1, 255));
        end if;
    -- item def - DEC def - specified/found.genetered; vd def - specified/generated
 --  raise_application_error(-20000, 'Above ' || v_dec_item_def || 'After');
   -- raise_application_error(-20000, 'Above ' );

          ihook.setColumnValue(row, 'ITEM_DESC',substr(v_dec_item_def || ' ' || v_vd_item_def,1,4000));
          ihook.setColumnValue(row, 'ITEM_DESC',v_dec_item_def);
            ihook.setColumnValue(row, 'PREF_QUEST_TXT',nvl(ihook.getColumnValue(rowform, 'PREF_QUEST_TXT'),'Data Element ' || v_item_nm|| ' does not have Preferred Question Text.'   ));
            ihook.setColumnValue(rowform, 'PREF_QUEST_TXT',nvl(ihook.getColumnValue(rowform, 'PREF_QUEST_TXT'),'Data Element ' || v_item_nm|| ' does not have Preferred Question Text.'   ));

       v_id := nci_11179.getItemId;

        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 4);

        ihook.setColumnValue(row,'ITEM_LONG_NM', nvl( ihook.getColumnValue(rowform, 'CDE_ITEM_LONG_NM'), v_id || c_ver_suffix));

        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'ADMIN_STUS_ID',66);
        ihook.setColumnValue(row,'REGSTR_STUS_ID',9);
        ihook.setColumnValue(row,'DE_CONC_ITEM_ID',nvl(v_dec_item_id, ihook.getColumnValue(rowform, 'DE_CONC_ITEM_ID_CREAT') ));
        ihook.setColumnValue(row,'DE_CONC_VER_NR',nvl(v_dec_ver_nr, 1 ));
        ihook.setColumnValue(row,'VAL_DOM_ITEM_ID',nvl(v_vd_item_id, ihook.getColumnValue(rowform, 'VAL_DOM_ITEM_ID_CREAT') ));
        ihook.setColumnValue(row,'VAL_DOM_VER_NR',nvl(v_vd_ver_nr, 1 ));
  --  raise_application_error(-20000, 'Here' || ihook.getColumnValue(row, 'ITEM_DESC') );

        rows.extend;
        rows(rows.last) := row;
        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,10,'insert');
        actions.extend;
        actions(actions.last) := action;

        action := t_actionrowset(rows, 'Data Element', 2,11,'insert');
        actions.extend;
        actions(actions.last) := action;

        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID', v_id);
    ihook.setColumnValue(row,'VER_NR', 1.00);
     ihook.setColumnValue(row,'REF_NM', substr(ihook.getColumnValue(rowform, 'PREF_QUEST_TXT'),1,255));
     ihook.setColumnValue(row,'REF_DESC', ihook.getColumnValue(rowform, 'PREF_QUEST_TXT'));
     ihook.setColumnValue(row,'LANG_ID', 1000);
     ihook.setColumnValue(row,'NCI_CNTXT_ITEM_ID',ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID')  );
     ihook.setColumnValue(row,'NCI_CNTXT_VER_NR',ihook.getColumnValue(rowform, 'CNTXT_VER_NR')  );
     ihook.setColumnValue(row,'REF_TYP_ID', 80);

     ihook.setColumnValue(row,'REF_ID', -1);
     rows := t_rows();
     rows.extend;
    rows(rows.last) := row;
    action := t_actionrowset(rows, 'References (for hook insert)', 2,12,'insert');
    actions.extend;
    actions(actions.last) := action;
    ihook.setColumnValue(rowform, 'CTL_VAL_MSG', ihook.getColumnValue(rowform, 'CTL_VAL_MSG') || 'CDE Created Successfully with ID ' || v_id ||  chr(13)) ;


 end if;

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
        v_unq_id number;
        v_unq_ver number(4,2);
        v_temp_id number;
        v_temp_vr number(4,2);
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


    if (v_item_type_id <> 4) then -- 4 - CDE in table OBJ_KEY
        raise_application_error(-20000,'!!! This functionality is only applicable for CDE !!!');
    end if;
if hookInput.invocationNumber = 0 then
        HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECreateQuestion(2,true);
        row := row_ori;
        rows := t_rows();
      nci_11179_2.setStdAttr(row);
        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);

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
              v_valid := true;

            -- for cur in (

            select count(*) into v_temp_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
           -- and ai.ITEM_LONG_NM=ihook.getColumnValue(rowai,'ITEM_LONG_NM')
           -- and  ai.ver_nr =  ihook.getColumnValue(rowai, 'VER_NR')
            and de.de_conc_item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID')
            and de.de_conc_ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and de.val_dom_item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID')
            and de.val_dom_ver_nr =  ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR');--)

            select count(*) into v_unq_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and ai.ITEM_LONG_NM=ihook.getColumnValue(rowai,'ITEM_LONG_NM')
            and  ai.ver_nr =  ihook.getColumnValue(rowai, 'VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR');


        --loop
        IF v_temp_id>0 or v_unq_id>0 then
        IF v_temp_id>0 then
         select max(ai.item_id),max(ai.ver_nr) into v_temp_id ,v_temp_vr from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
           -- and ai.ITEM_LONG_NM=ihook.getColumnValue(rowai,'ITEM_LONG_NM')
           -- and  ai.ver_nr =  ihook.getColumnValue(rowai, 'VER_NR')
            and de.de_conc_item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID')
            and de.de_conc_ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and de.val_dom_item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID')
            and de.val_dom_ver_nr =  ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR');--)
        --hookoutput.message := 'Duplicate CDE found: ' || v_temp_id;
        hookoutput.message := 'Duplicate CDE found: ' ||get_AI_id(v_temp_id,v_temp_vr);
        END IF;
        IF v_unq_id>0 then
          select max(ai.item_id),max(ai.ver_nr) into v_unq_id ,v_unq_ver  from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and ai.ITEM_LONG_NM=ihook.getColumnValue(rowai,'ITEM_LONG_NM')
            and  ai.ver_nr =  ihook.getColumnValue(rowai, 'VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR');

          hookoutput.message := 'Unique constraint violated. The CDE '||get_AI_id(v_unq_id,v_unq_ver )||' with the same Short Name and Context is found.';

        --hookoutput.message := 'Unique constraint violated. The CDE '||v_unq_id||'v'||ihook.getColumnValue(rowai, 'VER_NR')||' with the same Short Name and Context is found.';
        END IF;
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
          V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
          return;
		 -- exit;
         --end loop;
          end if;


  IF HOOKINPUT.ANSWERID = 1 or hookInput.invocationNumber = 1 then--Validate
        v_item_nm:=ihook.getColumnValue(rowai,'ITEM_NM');
        v_item_desc:=ihook.getColumnValue(rowai,'ITEM_DESC');
        v_valid := true;

         select substr(dec.item_nm || ' ' || vd.item_nm,1,255) ,substr(dec.item_desc || ':' || vd.item_desc,  1, 4000) into v_item_nm, v_item_desc from admin_item dec, admin_item vd
         where dec.item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID') and dec.ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
         and vd.item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID') and vd.ver_nr = ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR');
         ihook.setColumnValue(rowai, 'ITEM_NM', v_item_nm);
         ihook.setColumnValue(rowai, 'ITEM_DESC', v_item_desc);

 for cur in (select ai.item_id,ai.ver_nr from admin_item ai, de de
        where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
        and de.de_conc_item_id = ihook.getColumnValue(rowde, 'DE_CONC_ITEM_ID')
            and de.de_conc_ver_nr =  ihook.getColumnValue(rowde, 'DE_CONC_VER_NR')
            and de.val_dom_item_id =  ihook.getColumnValue(rowde, 'VAL_DOM_ITEM_ID')
            and de.val_dom_ver_nr =  ihook.getColumnValue(rowde, 'VAL_DOM_VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR'))
        loop
        hookoutput.message := 'Duplicate CDE found: ' || get_AI_id(cur.item_id,cur.ver_nr);
        --hookoutput.message := 'Duplicate CDE found: ' ||get_AI_id(v_temp_id,ihook.getColumnValue(rowai, 'VER_NR'));
        v_valid := false;

       rows := t_rows();
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
select count(*) into v_unq_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and ai.ITEM_LONG_NM=ihook.getColumnValue(rowai,'ITEM_LONG_NM')
            and  ai.ver_nr =  ihook.getColumnValue(rowai, 'VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR');
  IF v_unq_id>0 then
            select max(ai.item_id)  into v_unq_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and ai.ITEM_LONG_NM=ihook.getColumnValue(rowai,'ITEM_LONG_NM')
            and  ai.ver_nr =  ihook.getColumnValue(rowai, 'VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(rowai, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(rowai, 'CNTXT_VER_NR');
           hookoutput.message := 'Unique constraint violated. The CDE '||get_AI_id(v_unq_id,ihook.getColumnValue(rowai, 'VER_NR'))||' with the same Short Name and Context is found.';
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
          END IF;
        ihook.setColumnValue(rowai,'ITEM_ID', v_item_id);
        ihook.setColumnValue(rowai,'VER_NR', 1.00);
        ihook.setColumnValue(rowai,'ADMIN_ITEM_TYP_ID', 4);


--        ihook.setColumnValue(rowai,'ITEM_NM', v_item_nm);
--        ihook.setColumnValue(rowai,'ITEM_DESC', v_item_desc);
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


        hookoutput.message := 'CDE Created Successfully with ID ' || v_item_id ;
        hookoutput.actions := actions;
        end if;
 --   raise_application_error(-20000, 'Count ' || actions.count);

  end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


function getCSICreateQuestion(v_from in number) return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
 if (v_from = 1) then -- create
    ANSWER                     := T_ANSWER(1, 1, 'Create CSI');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Create New CSI', ANSWERS);
else
    ANSWER                     := T_ANSWER(1, 1, 'Update CSI');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Edit CSI', ANSWERS);
end if;
return question;
end;


function getCSCreateQuestion return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Create CS');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Create New Classification Scheme', ANSWERS);

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
    QUESTION               := T_QUESTION('Create New CDE', ANSWERS);
    else
    QUESTION               := T_QUESTION('Create CDE from Existing', ANSWERS);
    end IF;
return question;
end;

function getDECreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('Administered Item (Hook Creation)', 2,1);
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
    form1                  := t_form('Administered Item (No Short Name)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    form1                  := t_form('CSI (Hook Creation)', 2,1);

    form1.rowset :=v_rowset2;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;


function getCSCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('Administered Item (Hook Creation)', 2,1);
    form1.rowset :=v_rowset1;
    forms.extend;    forms(forms.last) := form1;
    form1                  := t_form('Classification Scheme (Create Hook)', 2,1);

    form1.rowset :=v_rowset2;
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
        ihook.setColumnValue(row,'ITEM_LONG_NM',  v_id || c_ver_suffix);
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
 -- nci_util.debugHook('GENERAL', v_data_out);
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
  v_cnt integer;
    v_found boolean;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

   select obj_key_id into v_nm_typ_id from obj_key where obj_key_desc = 'USED_BY' and obj_typ_id = 11;
    v_cnt := 0; -- number of designations

  if hookInput.invocationNumber = 0  then
     	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Designate');
         answers.extend;          answers(answers.last) := answer;
  --       answer := t_answer(2, 2, 'Undesignate');
   --      answers.extend;          answers(answers.last) := answer;
      question := t_question('Choose Option', answers);
       	 hookOutput.question := question;
         row := t_row();


        ihook.setColumnValue(row, 'NM_TYP_ID', v_nm_typ_id);
        ihook.setColumnValue(row, 'NM_DESC',v_default_txt); -- Default values
        ihook.setColumnValue(row, 'LANG_ID',1000); -- Default values
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
        rows := t_rows();
        if (hookinput.answerid = 1) then
            ihook.setColumnValue(rowform,'NM_ID', -1);
            for i in 1..hookinput.originalrowset.rowset.count loop
                 v_found := false;
                    row_ori :=  hookInput.originalRowset.rowset(i);
                    if (ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') = 4 and ihook.getColumnValue(row_ori, 'ADMIN_STUS_ID') in (65,75,76)) then
                        row := rowform;
                        ihook.setColumnValue(row,'ITEM_ID',ihook.getColumnValue(row_ori,'ITEM_ID'));
                        ihook.setColumnValue(row,'VER_NR',ihook.getColumnValue(row_ori,'VER_NR'));

                        if ( ihook.getColumnValue(rowform,'NM_DESC') != v_default_txt) then -- Get context name
                            select count(*) into v_temp from alt_nms where
                            cntxt_item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(rowform,'CNTXT_VER_NR')
                            and item_id = ihook.getColumnValue(rowform,'ITEM_ID') and ver_nr = ihook.getColumnValue(rowform,'VER_NR')
                            and nm_typ_id =   ihook.getColumnValue(rowform,'NM_TYP_ID') and nm_desc = ihook.getColumnValue(rowform,'NM_DESC');

                            if (v_temp = 0) then -- Row does not exist
                                    rows.extend;
                                    rows(rows.last) := row;
                                v_found := true;
                            end if;
                        end if;

            -- Default used by row

                select item_nm into v_cntxt_nm from vw_cntxt where item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and ver_nr = ihook.getColumnValue(rowform,'CNTXT_VER_NR');
                    ihook.setColumnValue(row,'NM_DESC', v_cntxt_nm);
                    ihook.setColumnValue(row,'NM_TYP_ID', v_nm_typ_id);


              -- If row already exists
                    select count(*) into v_temp from alt_nms where
                    cntxt_item_id = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(rowform,'CNTXT_VER_NR')
                    and item_id = ihook.getColumnValue(rowform,'ITEM_ID') and ver_nr = ihook.getColumnValue(rowform,'VER_NR')
                    and nm_typ_id =   v_nm_typ_id and nm_desc = ihook.getColumnValue(rowform,'NM_DESC');

                    if (v_temp = 0) then -- Row does not exist
                        rows.extend;
                        rows(rows.last) := row;
                        v_found := true;

                    end if;
                end if;
            if (v_found) then
                    v_cnt := v_cnt + 1;
            end if;
        end loop;

                   if (rows.count > 0) then
                        action := t_actionrowset(rows, 'Alternate Names', 2,1,'insert');
                            actions.extend;
                            actions(actions.last) := action;
                    end if;
                             hookoutput.message := 'Only CDEs with Release/Released Non-Compliant and Draft-Mod have been designated. Total Designated: ' || v_cnt;

       end if;
       end if;
    if (hookinput.answerId = 2) then -- undesignate
       rows := t_rows();
       for i in 1..hookinput.originalrowset.rowset.count loop
                    row_ori :=  hookInput.originalRowset.rowset(i);
                    if (ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') = 4 ) then
                         for cur in (select * from alt_nms where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR')
                        and NM_TYP_ID = v_nm_typ_id and CNTXT_ITEM_ID = ihook.getColumnValue(rowform,'CNTXT_ITEM_ID')
                        and CNTXT_VER_NR = ihook.getColumnValue(rowform,'CNTXT_VER_NR') ) loop
                            row := t_row();
                            ihook.setColumnValue(row, 'NM_ID', cur.NM_ID);
     rows.extend;
                            rows(rows.last) := row;
                        end loop;
                    end if;
        end loop;
        if (rows.count > 0) then

                    action := t_actionrowset(rows, 'Alternate Names', 2,1,'delete');
                    actions.extend;
                    actions(actions.last) := action;
                    action := t_actionrowset(rows, 'Alternate Names', 2,2,'purge');
                    actions.extend;
                    actions(actions.last) := action;
           hookoutput.message := 'Only CDEs have been undesignated. Total Undesignated: ' || rows.count;
        end if;
    end if;

if (actions.count > 0) then
  hookoutput.actions := actions;

end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 -- nci_util.debugHook('GENERAL', v_data_out);
END;

PROCEDURE spUndesignate
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
  v_cnt integer;
    v_found boolean;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

   select obj_key_id into v_nm_typ_id from obj_key where obj_key_desc = 'USED_BY' and obj_typ_id = 11;
    v_cnt := 0; -- number of designations
  if hookInput.invocationNumber = 0  then
     	 answers := t_answers();
  	      answer := t_answer(2, 2, 'Undesignate');
         answers.extend;          answers(answers.last) := answer;
      question := t_question('Choose Option', answers);
       	 hookOutput.question := question;
         row := t_row();




        forms                  := t_forms();
        form1                  := t_form('Designate Context Form', 2,1);
        form1.rowset :=rowset;
        forms.extend;    forms(forms.last) := form1;
        hookoutput.forms := forms;
  	elsif hookInput.invocationNumber = 1 then
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);  -- entered values from user
        rows := t_rows();
    --    raise_application_error(-20000, ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));

        if (hookinput.answerId = 2) then -- undesignate
       rows := t_rows();
       for i in 1..hookinput.originalrowset.rowset.count loop
                    row_ori :=  hookInput.originalRowset.rowset(i);
                    if (ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') = 4 ) then
                         for cur in (select * from alt_nms where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR')
                        and NM_TYP_ID = v_nm_typ_id and CNTXT_ITEM_ID = ihook.getColumnValue(rowform,'ITEM_ID')
                        and CNTXT_VER_NR = ihook.getColumnValue(rowform,'VER_NR') ) loop
                            row := t_row();
                            ihook.setColumnValue(row, 'NM_ID', cur.NM_ID);
     rows.extend;
                            rows(rows.last) := row;
                        end loop;
                    end if;
        end loop;
        if (rows.count > 0) then

                    action := t_actionrowset(rows, 'Alternate Names', 2,1,'delete');
                    actions.extend;
                    actions(actions.last) := action;
                    action := t_actionrowset(rows, 'Alternate Names', 2,2,'purge');
                    actions.extend;
                    actions(actions.last) := action;
           hookoutput.message := 'Only CDEs have been undesignated. Total Undesignated: ' || rows.count;
        else
        hookoutput.message := 'No CDEs have been undesignated.';
        end if;
    end if;

if (actions.count > 0) then
  hookoutput.actions := actions;

end if;
end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 -- nci_util.debugHook('GENERAL', v_data_out);
END;

-- Classify/Unclassify for Super Curators
PROCEDURE spClassifyUnclassify
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
  v_cmp integer;
  v_cnt integer;
  v_default_txt varchar2(30) := 'Default is Context Name.' ;

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

    if hookInput.invocationNumber = 0  then
            answers := t_answers();
            answer := t_answer(1, 1, 'Classify');
            answers.extend;          answers(answers.last) := answer;

            answer := t_answer(2, 2, 'Unclassify');
            answers.extend;          answers(answers.last) := answer;
            question := t_question('Choose Option', answers);

            hookOutput.question := question;

        -- Form only has only pop-up to select Classification
            forms                  := t_forms();
            form1                  := t_form('Unclassify (Hook)', 2,1);
            forms.extend;    forms(forms.last) := form1;

            hookoutput.forms := forms;
  	elsif hookInput.invocationNumber = 1 then
            forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);  -- entered values from user
            rows := t_rows();
            ihook.setColumnValue(rowform, 'REL_TYP_ID', 65);

            v_cnt := 0;   -- Count of total added rows

            v_cmp := hookinput.answerid - 1; -- 0 if classify, 1 if unclassify

            for i in 1..hookinput.originalrowset.rowset.count loop

                row_ori :=  hookInput.originalRowset.rowset(i);
                row := rowform;

                ihook.setColumnValue(row,'C_ITEM_ID',ihook.getColumnValue(row_ori,'ITEM_ID'));
                ihook.setColumnValue(row,'C_ITEM_VER_NR',ihook.getColumnValue(row_ori,'VER_NR'));

            -- check if row exists if unclassify and not exists if classify

                    select count(*) into v_temp from nci_admin_item_rel where
                    p_item_id =  ihook.getColumnValue(rowform,'P_ITEM_ID') and
                    p_item_ver_nr = ihook.getColumnValue(rowform,'P_ITEM_VER_NR') and
                    c_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and
                    c_item_ver_nr = ihook.getColumnValue(row_ori,'VER_NR') and
                    rel_typ_id = 65;

                    if (v_temp = v_cmp) then -- 0 if classify, 1 if unclassify
                        rows.extend;  rows(rows.last) := row;
                        v_cnt := v_cnt + 1;
                    end if;
            end loop;

            if rows.count > 0 then
                if (hookinput.answerid = 1) then -- Classify
                        action := t_actionrowset(rows, 'NCI CSI - DE Relationship', 2,1,'insert');
                        actions.extend; actions(actions.last) := action;
                        hookoutput.message := v_cnt || ' items classified.';

                else
                            action := t_actionrowset(rows, 'NCI CSI - DE Relationship', 2,1,'delete');
                            actions.extend; actions(actions.last) := action;
                            action := t_actionrowset(rows, 'NCI CSI - DE Relationship', 2,2,'purge');
                            actions.extend;  actions(actions.last) := action;
                            hookoutput.message := v_cnt || ' items unclassified.';
                end if;
                hookoutput.actions := actions;
            end if;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

FUNCTION get_AI_id(P_ID NUMBER,P_VER in number) RETURN VARCHAR2
IS
V_DN VARCHAR2(355);
V_LN VARCHAR2(255);
V_type number;
V_VER varchar(10);
BEGIN

V_VER:=to_char(P_VER);

IF instr(V_ver,'.')=0 then
V_DN :=P_ID||'v'||V_ver||'.00';

ELSIF instr(V_ver,'.')>0 and length (substr (V_VER,INSTR(V_VER,'.')+1))<2 then
V_DN :=P_ID||'v'||substr (V_VER,1,INSTR(V_VER,'.')-1)||'.'||substr (V_VER,INSTR(V_VER,'.')+1)||'0';

ELSE
V_DN :=P_ID||'v'||substr (V_VER,1,INSTR(V_VER,'.')-1)||'.'||substr (V_VER,INSTR(V_VER,'.')+1);
end if ;

RETURN V_DN;
END;
END;
/
