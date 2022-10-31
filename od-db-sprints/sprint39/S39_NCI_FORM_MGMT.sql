create or replace PACKAGE            nci_form_mgmt AS
function getFormRetiredCount(v_item_id in number, v_ver_nr in number) return varchar2;
function getAddComponentCreateQuestion return t_question ;
procedure spAddForm (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spAddFormFromExisting (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spAddModule (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spAddSAModule (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spEditModule (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spAddQuestion (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2, v_src in varchar2);
procedure spCopyModule (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2, v_src in varchar2);
function isUserAuth(v_frm_item_id in number, v_frm_ver_nr in number,v_user_id in varchar2) return boolean  ;
procedure spSetModRep (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spChngQuestText (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spChngQuestShortText (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spSetDefltVal (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spSetDefltValNonEnum (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spAddQuestionNoDE (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spChngQuestTextVV (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spChngQuestDefVV (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spAddQuestionRep (rep in integer, row_ori in t_row, rows in out t_rows);
procedure spAddQuestionID (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
procedure spAddQuestionRepNew (rep in integer, v_quest_id in integer, rows in out t_rows);
PROCEDURE spQuestRemoveDE ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDelModRep  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDelModRepNew  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDeleteQuestVV  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDeleteProtRel  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spAddQuestVV  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDelDefltVal (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spReorderModule (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spResetOrderModule (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spReorderQuest (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spResetOrderQuest (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spReorderQuestVV (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
procedure spResetOrderQuestVV (v_data_in in clob, v_data_out out clob,  v_user_id in varchar2);
function getReorderForm  return t_forms ;
function getReorderQuestion (v_cur_disp_ord in integer) return t_question;
procedure updFormModuleQuestion (v_quest_id in number, v_quest_ver_nr in number, v_usr_id in varchar2);
END;
/
create or replace PACKAGE BODY            nci_form_mgmt AS
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
v_deflt_cart_nm  varchar2(255) := 'Default';

function isUserAuth(v_frm_item_id in number, v_frm_ver_nr in number,v_user_id in varchar2) return boolean  iS
v_auth boolean := false;
v_temp integer;
begin
if (v_frm_item_id = -1) then return true; end if;-- Stand Alone module

select count(*) into v_temp from  onedata_md.vw_usr_row_filter  v, admin_item ai
        where ( ( v.CNTXT_ITEM_ID = ai.CNTXT_ITEM_ID and v.cntxt_VER_NR  = ai.CNTXT_VER_NR) or v.CNTXT_ITEM_ID = 100) and upper(v.USR_ID) = upper(v_user_id) and v.ACTION_TYP = 'I'
        and ai.item_id =v_frm_item_id and ai.ver_nr = v_frm_ver_nr;
if (v_temp = 0) then return false; else return true; end if;
end;

function getFormRetiredCount(v_item_id in number, v_ver_nr in number) return varchar2 is
v_retired_cdes varchar2(255);
v_not_latest  varchar2(255);
begin
select nci_cadsr_push.getLongName(nvl(LISTAGG(DE_ITEM_ID || 'v' || DE_VER_NR, ','),'None')) into v_retired_cdes from VW_NCI_MODULE_DE WHERE frm_item_id = v_item_id and frm_ver_nr = v_ver_nr and DE_ITEM_ID is not null
    and DE_ADMIN_STUS_NM_DN like '%RETIRED%';

select nci_cadsr_push.getLongName(nvl(LISTAGG(DE_ITEM_ID || 'v' || DE_VER_NR, ','),'None')) into v_not_latest from VW_NCI_MODULE_DE WHERE frm_item_id = v_item_id and frm_ver_nr = v_ver_nr and DE_ITEM_ID is not null    
    and DE_CURRNT_VER_IND = 0 and DE_ADMIN_STUS_NM_DN not like '%RETIRED%';
    return 'WARNING: CDEs on Form Retired: ' || v_retired_cdes || '  Not Latest Version: ' || v_not_latest; 
end;

-- Generic create question
function getAddComponentCreateQuestion return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;



    QUESTION               := T_QUESTION('Please select Items to Add.', ANSWERS);

return question;
end;


function getReorderForm  return t_forms is
  forms t_forms;
  form1 t_form;
begin

        forms                  := t_forms();
        form1                  := t_form('Display Order Change', 2,1);
        forms.extend;
        forms(forms.last) := form1;
  return forms;
end;


function getReorderQuestion (v_cur_disp_ord in integer)  return t_question is

  question t_question;
  answer t_answer;
  answers t_answers;
begin

        ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(1, 1, 'Change Display Order' );
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION('Current Display Order is: ' || v_cur_disp_ord , ANSWERS);


return question;
end;

Procedure spAddQuestionID (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    row_sel t_row;
    rows  t_rows;
    rowscart  t_rows;
    rowsrep  t_rows;
    rowsvv  t_rows;

    row_ori t_row;
    v_item_id  number;
    v_ver_nr number(4,2);
    v_temp integer;
    v_add integer :=0;
    i integer := 0;
    v_item_typ_id integer;
    v_found boolean;
    v_str varchar2(4000);
    v_disp_ord integer;
    v_vvid number;
    cnt integer;
    rep integer;
    v_id number;
    j integer;
 forms t_forms;
  form1 t_form;
  v_cnt_valid_fmt integer;
  v_cnt_valid_type integer;
  v_cnt_already integer;
  v_invalid_fmt varchar2(50) := '';
  v_invalid_typ varchar2(100) := '';
  v_dup_str  varchar2(50) := '';
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);
        -- 92 - FOrm, 93 - CDE
      -- Depending on the type of collection, show either Forms or CDE's


 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a question to this module.');
 end if;
     v_item_typ_id := 4;

    if (hookinput.invocationnumber = 0) then   -- First invocation
         forms                  := t_forms();
        form1                  := t_form('Add Item to Collection (Hook)', 2,1);
        forms.extend;    forms(forms.last) := form1;
        hookoutput.forms := forms;
       	 hookOutput.question := getAddComponentCreateQuestion;
	end if;

    if hookInput.invocationNumber = 1  then  -- Second invocation
          v_cnt_valid_fmt := 0;
            v_cnt_valid_type := 0;

            forms              := hookInput.forms;
            form1              := forms(1);
            row_sel := form1.rowset.rowset(1);
            v_str := trim(ihook.getColumnValue(row_sel, 'VM_DESC_TXT'));
            cnt := nci_11179.getwordcount(v_str);

     --       Display order and repetitions
            select nvl(max(disp_ord)+1,0) into v_disp_ord from NCI_ADMIN_ITEM_REL_ALT_KEY where P_ITEM_ID =ihook.getColumnValue(row_ori,'C_ITEM_ID')  and
              P_ITEM_VER_NR = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and rel_typ_id = 63;
                            rep := nvl(ihook.getColumnValue(row_ori, 'REP_NO'),0);
            rows := t_rows();
            rowsvv := t_rows();
            rowsrep := t_rows();
            rowscart := t_rows();

            for i in  1..cnt loop
                  IF (VALIDATE_CONVERSION(nci_11179.getWord(v_str, i, cnt) AS NUMBER) = 1) THEN
                            v_item_id := nci_11179.getWord(v_str, i, cnt);
                            v_cnt_valid_fmt := v_cnt_valid_fmt + 1;

                    -- Only add if item is of the right type and not currently in collection.
                           select count(*) into v_temp from admin_item where item_id = v_item_id and currnt_ver_ind = 1 and admin_item_typ_id = v_item_typ_id
                           and (upper(admin_stus_nm_dn) not like '%RETIRED%' and upper(regstr_stus_nm_dn) not like  '%RETIRED%');
                            if (v_temp = 1) then
                                    v_cnt_valid_type := v_cnt_valid_type + 1;
                                    v_found := true;

                                    for cur in (select ai.item_id, ai.ver_nr, ai.cntxt_item_id, ai.cntxt_ver_nr, item_long_nm item_long_nm, de.pref_quest_txt QUEST_TEXT, item_nm
                                    from admin_item ai, de where
                                    ai.item_id =v_item_id and ai.currnt_ver_ind = 1 and ai.item_id = de.item_id  and ai.ver_nr = de.ver_nr )  loop

                                            row := t_row();

                                            v_id := nci_11179.getItemId;
                                            ihook.setColumnValue (row, 'NCI_PUB_ID', v_id);
                                            ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                                            ihook.setColumnValue (row, 'P_ITEM_ID', ihook.getColumnValue(row_ori,'C_ITEM_ID'));
                                            ihook.setColumnValue (row, 'P_ITEM_VER_NR', ihook.getColumnValue(row_ori,'C_ITEM_VER_NR'));
                                            ihook.setColumnValue (row, 'C_ITEM_ID', cur.item_id);
                                            ihook.setColumnValue (row, 'C_ITEM_VER_NR', cur.ver_nr);
                                            ihook.setColumnValue (row, 'CNTXT_CS_ITEM_ID', cur.cntxt_item_id);
                                            ihook.setColumnValue (row, 'CNTXT_CS_VER_NR', cur.cntxt_ver_nr);
                                            ihook.setColumnValue (row, 'ITEM_LONG_NM', cur.QUEST_TEXT );
                                             ihook.setColumnValue (row, 'ITEM_NM', cur.ITEM_LONG_NM );
                                            ihook.setColumnValue (row, 'EDIT_IND', 1 );
                                            ihook.setColumnValue (row, 'REQ_IND', 0 );

                                            ihook.setColumnValue (row, 'REL_TYP_ID', 63);
                                            ihook.setColumnValue (row, 'DISP_ORD', v_disp_ord);
                                                    ihook.setColumnValue (row, 'CNTCT_SECU_ID', v_usr_id);
                                                    ihook.setColumnValue (row, 'GUEST_USR_NM', 'NONE');
                                                    ihook.setColumnValue (row, 'CART_NM', v_deflt_cart_nm);
                                                    ihook.setColumnValue (row, 'ITEM_ID', cur.item_id);
                                                           ihook.setColumnValue (row, 'VER_NR', cur.ver_nr);
                                            v_disp_ord := v_disp_ord + 1;
                                            v_found := false;
                                            rows.extend;
                                            rows(rows.last) := row;

                                             -- Add to user cart as well as per curator.
                                             nci_11179_2.AddItemToCart(cur.item_id, cur.ver_nr, v_usr_id, v_deflt_cart_nm, rowscart);
                                
                                            if nvl(rep,0) > 0 then
                                                spAddQuestionRepNew (rep, v_id, rowsrep);
                                            end if;
                                            j := 0;

                                            for cur1 in (select * from  VW_NCI_DE_PV where de_item_id = cur.item_id and de_ver_nr = cur.ver_nr and nvl(fld_delete,0) = 0 order by PERM_VAL_NM) loop
                                                      row := t_row();
                                                    ihook.setColumnValue (row, 'Q_PUB_ID', v_id);
                                                    ihook.setColumnValue (row, 'Q_VER_NR', 1);
                                                    ihook.setColumnValue (row, 'VM_NM', cur1.item_nm);
                                                    ihook.setColumnValue (row, 'VM_LNM', cur1.item_long_nm);
                                                    ihook.setColumnValue (row, 'VM_DEF', cur1.item_desc);
                                                    ihook.setColumnValue (row, 'VALUE', cur1.perm_val_nm);
                                                    ihook.setColumnValue (row, 'MEAN_TXT', cur1.item_nm);
                                                    ihook.setColumnValue (row, 'DESC_TXT', substr(cur1.item_desc,1,2000));
                                                    ihook.setColumnValue (row, 'VAL_MEAN_ITEM_ID', cur1.NCI_VAL_MEAN_ITEM_ID);
                                                    ihook.setColumnValue (row, 'VAL_MEAN_VER_NR', cur1.NCI_VAL_MEAN_VER_NR);
                                                    ihook.setColumnValue (row, 'CNTCT_SECU_ID', v_usr_id);
                                                    ihook.setColumnValue (row, 'GUEST_USR_NM', 'NONE');
                                                    ihook.setColumnValue (row, 'ITEM_ID', cur.item_id);
                                                           ihook.setColumnValue (row, 'VER_NR', cur.ver_nr);
                                          v_vvid := nci_11179.getItemId;
                                                    ihook.setColumnValue (row, 'NCI_PUB_ID', v_vvid);
                                                    ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                                                    ihook.setColumnValue (row, 'DISP_ORD', j);
                                                     rowsvv.extend;
                                                    rowsvv(rowsvv.last) := row;
                                                    j := j+ 1;
                                            end loop;
                                     end loop;

                                    if (v_found = true) then  --- Duplcicate
                                        v_dup_str := substr(v_dup_str || ' ' || nci_11179.getWord(v_str, i, cnt),1,50);
                                    end if;
                            else -- not the right type
                                v_invalid_typ := substr(v_invalid_typ || ' ' || nci_11179.getWord(v_str, i, cnt),1,50);
                            end if;

            else  -- invalid format
                v_invalid_typ := substr(v_invalid_typ || ' ' || nci_11179.getWord(v_str, i, cnt),1,50);
            end if;
    end loop;

    --DESC_TXT
       -- raise_application_error(-20000, v_add);
            if (rows.count > 0) then
                            action := t_actionrowset(rows, 'Questions (Base Object)', 2,0,'insert');
                            actions.extend;
                            actions(actions.last) := action;
            end if;

        if (rowsvv.count > 0) then
        action := t_actionrowset(rowsvv, 'Question Valid Values (Hook)', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
        end if;

           if (rowsrep.count > 0) then
            action             := t_actionrowset(rowsrep, 'Question Repetition', 2, 4,'insert');
                actions.extend;
                actions(actions.last) := action;
             end if;


                /*  If item not already in cart */
                if (rowscart.count  > 0) then
                    action := t_actionrowset(rowscart, 'User Cart', 2,0,'insert');
                    actions.extend;
                    actions(actions.last) := action;
                end if;
--raise_application_error(-20000,actions.count);
            if (actions.count > 0) then
                hookoutput.actions := actions;

               -- Update form and module audit
               if (ihook.getColumnValue(row_ori,'P_ITEM_ID')>0) then
                update admin_item set  LST_UPD_DT = sysdate, LST_UPD_USR_ID = v_usr_id
                where ITEM_ID = ihook.getColumnValue(row_ori,'P_ITEM_ID') and VER_NR = ihook.getColumnValue(row_ori,'P_ITEM_VER_NR');
                commit;
            end if;
                update NCI_ADMIN_ITEM_REL set LST_UPD_DT = sysdate, LST_UPD_USR_ID = v_usr_id
                where  C_ITEM_ID = ihook.getColumnValue(row_ori,'C_ITEM_ID')
                AND C_ITEM_VER_NR=ihook.getColumnValue(row_ori,'C_ITEM_VER_NR')  and rel_typ_id = 61;
                commit;

            end if;
            v_cnt_already :=  v_cnt_valid_type - nvl(rows.count,0) ;
                 hookoutput.message := 'Total Items: ' || cnt ||  ';    Invalid Format/Type/Status: ' || v_invalid_typ || ';      Items added: ' || nvl(rows.count,0) ;

   end if;  -- if second invocation
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 nci_util.debugHook('GENERAL',v_data_out);
END;

PROCEDURE spAddQuestVV
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
    row_sel t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_add integer;
  i integer := 0;
  j integer;
  v_temp integer;
  rep integer;
  v_item_id number;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();


 select p_item_id, p_item_ver_nr into v_frm_id, v_frm_ver_nr from nci_admin_item_rel where
  c_item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and c_item_ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to add any valid value on this form.');
 end if;

 if (ihook.getColumnValue(row_ori, 'C_ITEM_ID') is null) then
 raise_application_error(-20000,'No CDE attached to this question.');
 end if;

 if hookInput.invocationNumber = 0 then


    rows := t_rows();
    for cur in (select upper(PERM_VAL_NM) PERM_VAL_NM from vw_nci_de_pv where de_item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID') and de_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') minus
                select upper(VALUE) from nci_quest_valid_value where Q_PUB_ID = ihook.getColumnValue(row_ori, 'NCI_PUB_ID') and Q_VER_NR =ihook.getColumnValue(row_ori, 'NCI_VER_NR')) loop
                for cur1 in (select * from vw_nci_de_pv where upper(PERM_VAL_NM) = cur.PERM_VAL_NM and de_item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID') and de_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR')) loop
                     row := t_row();
                    iHook.setcolumnvalue (row, 'DE_ITEM_ID', cur1.DE_ITEM_ID);
                    iHook.setcolumnvalue (row, 'DE_VER_NR', cur1.DE_VER_NR);
                    iHook.setcolumnvalue (row, 'PERM_VAL_NM', cur1.PERM_VAL_NM);
                    rows.extend;
                    rows (rows.last) := row;

                end loop;
    end loop;


	--    end loop;

if (rows.count > 0) then
	   	 showrowset := t_showablerowset (rows, 'NCI DE Permissible Values', 2, 'multi');
       	 hookoutput.showrowset := showrowset;
          ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(1, 1, 'Select');
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION('Add Question Valid Values', ANSWERS);
        HOOKOUTPUT.QUESTION    := QUESTION;
    else
        hookoutput.message := 'All Question Valid Values already present.';
end if;

  ELSE -- hook invocation = 1
       rows := t_rows();

    select nvl(max(disp_ord)+1,0) into j from nci_quest_valid_value where q_pub_id =    ihook.getColumnValue(row_ori, 'NCI_PUB_ID')
    and q_ver_nr = ihook.getColumnValue(row_ori, 'NCI_VER_NR');
 --  raise_application_error(-20000, j);
  for i in 1..hookinput.selectedRowset.rowset.count loop

        row_sel := hookinput.selectedRowset.rowset(i);
        row := t_row();
            ihook.setColumnValue (row, 'Q_PUB_ID',ihook.getColumnValue(row_ori, 'NCI_PUB_ID') );
                ihook.setColumnValue (row, 'Q_VER_NR', ihook.getColumnValue(row_ori, 'NCI_VER_NR'));
                ihook.setColumnValue (row, 'VM_NM', ihook.getColumnValue(row_sel, 'ITEM_NM'));
                ihook.setColumnValue (row, 'VM_LNM', ihook.getColumnValue(row_sel, 'ITEM_LONG_NM'));
                ihook.setColumnValue (row, 'VM_DEF', ihook.getColumnValue(row_sel, 'ITEM_DESC'));
                ihook.setColumnValue (row, 'VALUE', ihook.getColumnValue(row_sel, 'PERM_VAL_NM'));
                ihook.setColumnValue (row, 'MEAN_TXT', ihook.getColumnValue(row_sel, 'ITEM_NM'));
                ihook.setColumnValue (row, 'DESC_TXT', ihook.getColumnValue(row_sel, 'ITEM_DESC'));
                ihook.setColumnValue (row, 'VAL_MEAN_ITEM_ID', ihook.getColumnValue(row_sel, 'NCI_VAL_MEAN_ITEM_ID'));
                ihook.setColumnValue (row, 'VAL_MEAN_VER_NR', ihook.getColumnValue(row_sel, 'NCI_VAL_MEAN_VER_NR'));
                v_item_id := nci_11179.getItemId;
                ihook.setColumnValue (row, 'NCI_PUB_ID', v_item_id);
                ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                ihook.setColumnValue (row, 'DISP_ORD', j);
            j := j + 1;
                    rows.extend;
                    rows (rows.last) := row;

   end loop;

 --raise_application_error(-20000, rows.count);
        if (rows.count > 0) then
        action             := t_actionrowset(rows, 'Question Valid Values (Hook)', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;
           hookoutput.actions    := actions;
            -- update Form. Module, Question

            updFormModuleQuestion (ihook.getColumnValue(row_ori, 'NCI_PUB_ID'), ihook.getColumnValue(row_ori, 'NCI_VER_NR'), v_usr_id);
             end if;

     END IF;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

END;

procedure updFormModuleQuestion (v_quest_id in number, v_quest_ver_nr in number, v_usr_id in varchar2)
as
v_cnt integer;
begin
 -- update Form. Module, Question
            update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = v_usr_id
            where (ITEM_ID, VER_NR) in (select ak.P_ITEM_ID, ak.P_ITEM_VER_NR from NCI_ADMIN_ITEM_REL ak, NCI_ADMIN_ITEM_REL_ALT_KEy q
                                where q.NCI_PUB_ID=v_quest_id
                                and q.NCI_VER_NR=v_quest_ver_nr and q.P_ITEM_ID = ak.C_ITEM_ID
                                and q.P_ITEM_VER_NR = ak.C_ITEM_VER_NR and ak.rel_typ_id = 61);



            update NCI_ADMIN_ITEM_REL_ALT_KEY set LST_UPD_DT = sysdate, LST_UPD_USR_ID = v_usr_id
            where  NCI_PUB_ID = v_quest_id
                   AND NCI_VER_NR=v_quest_ver_nr;

            update NCI_ADMIN_ITEM_REL set LST_UPD_DT = sysdate, LST_UPD_USR_ID = v_usr_id
            where  (C_ITEM_ID, C_ITEM_VER_NR) in (select p_item_id, p_item_ver_nr from nci_admin_item_rel_alt_key where c_item_id = v_quest_id and
                                                  c_item_ver_nr = v_quest_ver_nr)
            and rel_typ_id = 61;

            commit;
end;

procedure spDeleteQuestVV  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;

  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);

 select frm_item_id, frm_ver_nr into v_frm_id, v_frm_ver_nr from vw_nci_module_de where
nci_pub_id = ihook.getColumnValue(row_ori, 'Q_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any valid value on this form.');
 end if;
for i in 1..hookinput.originalrowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);


for cur in (select * from nci_admin_item_rel_alt_key where nci_pub_id =  ihook.getColumnValue(row_ori, 'Q_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR')
and deflt_val_id = ihook.getColumnValue(row_ori, 'NCI_PUB_ID')) loop
 raise_application_error(-20000,'This is used as a default on the question. Please change question default and then delete.');
end loop;

for cur in (select * from nci_quest_vv_rep where quest_pub_id =  ihook.getColumnValue(row_ori, 'Q_PUB_ID') and quest_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR')
and deflt_val_id = ihook.getColumnValue(row_ori, 'NCI_PUB_ID')) loop
 raise_application_error(-20000,'This is used as a default on the question repetition. Please change question default and then delete.');
end loop;

nci_form_curator.DeleteVV(ihook.getColumnValue(row_ori,'NCI_IDSEQ'));
            rows.extend;
            rows(rows.last) := row_ori;
    end loop;
            action             := t_actionrowset(rows, 'Question Valid Values (Hook)', 2, 0,'delete');
            actions.extend;
            actions(actions.last) := action;

  action             := t_actionrowset(rows, 'Question Valid Values (Hook)', 2, 1,'purge');
            actions.extend;
            actions(actions.last) := action;

            hookoutput.actions    := actions;
 updFormModuleQuestion (ihook.getColumnValue(row_ori, 'Q_PUB_ID'), ihook.getColumnValue(row_ori, 'Q_VER_NR'), v_usr_id);


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;



procedure spDeleteProtRel  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;

  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
v_idseq char(36);
v_pidseq char(36);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);

 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'C_ITEM_ID'), ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR'), v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to delete any Protocol from this form.');
 end if;

--nci_form_curator.DeleteVV(ihook.getColumnValue(row_ori,'NCI_IDSEQ'));

select nci_idseq into v_idseq from admin_item where item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR');
select nci_idseq into v_pidseq from admin_item where item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');
delete from sbrext.protocol_qc_ext where qc_idseq = v_idseq and proto_idseq = v_pidseq; 
commit;

            rows.extend;
            rows(rows.last) := row_ori;
  --  end loop;
            action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 0,'delete');
            actions.extend;
            actions(actions.last) := action;

  action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 1,'purge');
            actions.extend;
            actions(actions.last) := action;

            hookoutput.actions    := actions;
 updFormModuleQuestion (ihook.getColumnValue(row_ori, 'C_ITEM_ID'), ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR'), v_usr_id);


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spReorderModule  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  j integer;
 question    t_question;
answer     t_answer;
answers     t_answers;
 forms t_forms;
    form1 t_form;
    v_cur_disp_ord number;
    v_new_disp_ord number;
    v_max_disp_ord number;
     rowform t_row;
     v_sql  varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);
 v_cur_disp_ord := ihook.getColumnValue(row_ori, 'DISP_ORD');
 
if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit module to this form.');
 end if;
   if hookInput.invocationNumber = 0 then  -- If first invocation, prompt for version number

        hookOutput.forms := getReorderForm;
        hookoutput.question := getReorderQuestion(v_cur_disp_ord);
	elsif hookInput.invocationNumber = 1 then  -- Position specified...
            forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);
            v_new_disp_ord := ihook.getColumnValue(rowform,'ITEM_ID');

            select least(max(disp_ord), count(disp_ord)-1)  into v_max_disp_ord from nci_admin_item_rel where rel_typ_id = 61 and p_item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID')
            and p_item_ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') and nvl(fld_Delete,0) = 0;

            if (v_new_disp_ord < 0) then
                raise_application_error(-20000, 'Invalid Display Order.');
                return;
            end if;

            if (v_new_disp_ord > v_max_disp_ord) then
                v_new_disp_ord := v_max_disp_ord;
            end if;

 --  if current position is greater than new position

            rows := t_rows();

            if (v_cur_disp_ord > v_new_disp_ord) then
                j := v_new_disp_ord;
                for i in v_new_disp_ord..v_cur_disp_ord-1 loop
                    row := t_row();
                    v_sql := 'select * from NCI_ADMIN_ITEM_REL where nvl(fld_delete,0) = 0 and p_item_id = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_ID') || ' and p_item_ver_nr = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') || ' and disp_ord = ' || i ;
                    nci_11179.ReturnRow(v_sql, 'NCI_ADMIN_ITEM_REL', row);
                    if (ihook.getColumnValue(row, 'P_ITEM_ID') is not null) then
                        j := j+1;
                        ihook.setColumnValue(row, 'DISP_ORD', j);
                        rows.extend;                    rows(rows.last) := row;
                    end if;
                end loop;
            end if;
 -- if current position is less than new position

            if (v_cur_disp_ord < v_new_disp_ord) then
                j := v_cur_disp_ord + 1;
                for i in v_cur_disp_ord+1..v_new_disp_ord loop
                    row := t_row();
                    v_sql := 'select * from NCI_ADMIN_ITEM_REL where nvl(fld_delete,0) = 0 and p_item_id = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_ID') || ' and p_item_ver_nr = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') || ' and disp_ord = ' || i ;
                    nci_11179.ReturnRow(v_sql, 'NCI_ADMIN_ITEM_REL', row);
                    if (ihook.getColumnValue(row, 'P_ITEM_ID') is not null) then
                        ihook.setColumnValue(row, 'DISP_ORD', j-1);
                        j := j+1;
                        rows.extend;                    rows(rows.last) := row;
                    end if;
                end loop;
            end if;
     -- update current row
            row := t_row();
            v_sql := 'select * from NCI_ADMIN_ITEM_REL where nvl(fld_delete,0) = 0 and p_item_id = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_ID') || ' and p_item_ver_nr = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') || ' and disp_ord = ' || v_cur_disp_ord ;
            nci_11179.ReturnRow(v_sql, 'NCI_ADMIN_ITEM_REL', row);

            ihook.setColumnValue(row, 'DISP_ORD', v_new_disp_ord);
            rows.extend;            rows(rows.last) := row;

            action := t_actionRowset(rows, 'Generic AI Relationship', 2, 1000, 'update');
            actions.extend; actions(actions.last) := action;
            hookoutput.actions:= actions;
    end if;
     v_data_out := ihook.getHookOutput(hookOutput);
--    nci_util.debugHook('FORM',v_data_out);

END;



procedure spResetOrderModule  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
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
    i integer;

     v_sql  varchar2(4000);
BEGIN
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    row_ori :=  hookInput.originalRowset.rowset(1);

    rows := t_rows();
if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit module to this form.');
 end if;
    i := 0;
    for cur in (select * from NCI_ADMIN_ITEM_REL where nvl(fld_delete,0) = 0 and p_item_id =   ihook.getColumnValue(row_ori, 'ITEM_ID') and p_item_ver_nr =
             ihook.getColumnValue(row_ori, 'VER_NR') and rel_typ_id = 61 order by disp_ord) loop
                if (i <> cur.disp_ord) then
                    row := t_row();
                    v_sql := 'select * from NCI_ADMIN_ITEM_REL where  p_item_id = ' ||  cur.p_item_id || ' and p_item_ver_nr = ' || cur.p_item_ver_nr || ' and disp_ord = ' || cur.disp_ord ;
                    nci_11179.ReturnRow(v_sql, 'NCI_ADMIN_ITEM_REL', row);
                    ihook.setColumnValue(row, 'DISP_ORD', i);
                    rows.extend;                    rows(rows.last) := row;
                end if;
                i := i+1;
    end loop;

    action := t_actionRowset(rows, 'Generic AI Relationship', 2, 1000, 'update');
    actions.extend; actions(actions.last) := action;
    hookoutput.actions:= actions;

    v_data_out := ihook.getHookOutput(hookOutput);
    --nci_util.debugHook('FORM',v_data_out);

END;


procedure spReorderQuest  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  j integer;
 forms t_forms;
    form1 t_form;
    v_cur_disp_ord number;
    v_new_disp_ord number;
    v_max_disp_ord number;
     rowform t_row;
     v_sql  varchar2(4000);
     v_frm_id number;
     v_frm_ver_nr number(4,2);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);
 v_cur_disp_ord := ihook.getColumnValue(row_ori, 'DISP_ORD');
 
 select r.P_ITEM_ID, r.P_ITEM_VER_NR into v_frm_id, v_frm_Ver_nr from NCI_ADMIN_ITEM_REL_ALT_KEY k, NCI_ADMIN_ITEM_REL r where k.nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID')
 and k.nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR') and k.P_ITEM_ID = r.C_ITEM_ID and k.P_ITEM_VER_NR = r.C_ITEM_VER_NR and r.rel_typ_id = 61;

 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
   if hookInput.invocationNumber = 0 then  -- If first invocation, prompt for version number
              hookOutput.forms := getReorderForm;
        hookoutput.question := getReorderQuestion(v_cur_disp_ord);

	elsif hookInput.invocationNumber = 1 then  -- Position specified...
            forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);
            v_new_disp_ord := ihook.getColumnValue(rowform,'ITEM_ID');

            select least(max(disp_ord), count(disp_ord)-1)  into v_max_disp_ord from nci_admin_item_rel_alt_key where rel_typ_id = 63 and p_item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID')
            and p_item_ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') and nvl(fld_Delete,0) = 0;

            if (v_new_disp_ord < 0) then
                raise_application_error(-20000, 'Invalid Display Order.');
                return;
            end if;

            if (v_new_disp_ord > v_max_disp_ord) then
                v_new_disp_ord := v_max_disp_ord;
            end if;

 --  if current position is greater than new position

            rows := t_rows();

            if (v_cur_disp_ord > v_new_disp_ord) then
                j := v_new_disp_ord;
                for i in v_new_disp_ord..v_cur_disp_ord-1 loop
                    row := t_row();
                    v_sql := 'select * from NCI_ADMIN_ITEM_REL_ALT_KEY where nvl(fld_delete,0) = 0 and p_item_id = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_ID') || ' and p_item_ver_nr = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') || ' and disp_ord = ' || i ;
                    nci_11179.ReturnRow(v_sql, 'NCI_ADMIN_ITEM_REL_ALT_KEY', row);
                    if (ihook.getColumnValue(row, 'P_ITEM_ID') is not null) then
                        j := j+1;
                        ihook.setColumnValue(row, 'DISP_ORD', j);
                        rows.extend;                    rows(rows.last) := row;
                    end if;
                end loop;
            end if;
 -- if current position is less than new position

            if (v_cur_disp_ord < v_new_disp_ord) then
                j := v_cur_disp_ord + 1;
                for i in v_cur_disp_ord+1..v_new_disp_ord loop
                    row := t_row();
                    v_sql := 'select * from NCI_ADMIN_ITEM_REL_ALT_KEY where nvl(fld_delete,0) = 0 and p_item_id = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_ID') || ' and p_item_ver_nr = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') || ' and disp_ord = ' || i ;
                    nci_11179.ReturnRow(v_sql, 'NCI_ADMIN_ITEM_REL_ALT_KEY', row);
                    if (ihook.getColumnValue(row, 'P_ITEM_ID') is not null) then
                        ihook.setColumnValue(row, 'DISP_ORD', j-1);
                        j := j+1;
                        rows.extend;                    rows(rows.last) := row;
                    end if;
                end loop;
            end if;
     -- update current row
            row := t_row();
            v_sql := 'select * from NCI_ADMIN_ITEM_REL_ALT_KEY where nvl(fld_delete,0) = 0 and p_item_id = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_ID') || ' and p_item_ver_nr = ' ||  ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') || ' and disp_ord = ' || v_cur_disp_ord ;
            nci_11179.ReturnRow(v_sql, 'NCI_ADMIN_ITEM_REL_ALT_KEY', row);

            ihook.setColumnValue(row, 'DISP_ORD', v_new_disp_ord);
            rows.extend;            rows(rows.last) := row;

            action := t_actionRowset(rows, 'Questions (Base Object)', 2, 1000, 'update');
            actions.extend; actions(actions.last) := action;
            hookoutput.actions:= actions;
    end if;
     v_data_out := ihook.getHookOutput(hookOutput);
--    nci_util.debugHook('FORM',v_data_out);

END;

procedure spResetOrderQuest  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
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
    i integer;

     v_sql  varchar2(4000);
BEGIN
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    row_ori :=  hookInput.originalRowset.rowset(1);

    rows := t_rows();

 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
    i := 0;
    for cur in (select * from NCI_ADMIN_ITEM_REL_ALT_KEY where nvl(fld_delete,0) = 0 and p_item_id =   ihook.getColumnValue(row_ori, 'C_ITEM_ID') and p_item_ver_nr =
             ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') and rel_typ_id = 63 order by disp_ord) loop
                if (i <> cur.disp_ord) then
                    row := t_row();
                    v_sql := 'select * from NCI_ADMIN_ITEM_REL_ALT_KEY where  p_item_id = ' ||  cur.p_item_id || ' and p_item_ver_nr = ' || cur.p_item_ver_nr || ' and disp_ord = ' || cur.disp_ord ;
                    nci_11179.ReturnRow(v_sql, 'NCI_ADMIN_ITEM_REL_ALT_KEY', row);
                    ihook.setColumnValue(row, 'DISP_ORD', i);
                    rows.extend;                    rows(rows.last) := row;
                end if;
                i := i+1;
    end loop;

    action := t_actionRowset(rows, 'Questions (Base Object)', 2, 1000, 'update');
    actions.extend; actions(actions.last) := action;
    hookoutput.actions:= actions;

    v_data_out := ihook.getHookOutput(hookOutput);
    --nci_util.debugHook('FORM',v_data_out);

END;


procedure spReorderQuestVV  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  j integer;
 question    t_question;
answer     t_answer;
answers     t_answers;
 forms t_forms;
    form1 t_form;
    v_cur_disp_ord number;
    v_new_disp_ord number;
    v_max_disp_ord number;
     rowform t_row;
     v_sql  varchar2(4000);
     v_frm_id number; 
     v_frm_ver_nr number(4,2);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  rows := t_rows();

 row_ori :=  hookInput.originalRowset.rowset(1);
 v_cur_disp_ord := ihook.getColumnValue(row_ori, 'DISP_ORD');

 select frm_item_id, frm_ver_nr into v_frm_id, v_frm_ver_nr from vw_nci_module_de where
nci_pub_id = ihook.getColumnValue(row_ori, 'Q_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any valid value on this form.');
 end if;
   if hookInput.invocationNumber = 0 then  -- If first invocation, prompt for version number
             hookOutput.forms := getReorderForm;
        hookoutput.question := getReorderQuestion(v_cur_disp_ord);

	elsif hookInput.invocationNumber = 1 then  -- Position specified...
            forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);
            v_new_disp_ord := ihook.getColumnValue(rowform,'ITEM_ID');

            select least(max(disp_ord), count(disp_ord)-1)  into v_max_disp_ord from NCI_QUEST_VALID_VALUE where  q_pub_id = ihook.getColumnValue(row_ori, 'Q_PUB_ID')
            and q_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR') and nvl(fld_Delete,0) = 0;

            if (v_new_disp_ord < 0) then
                raise_application_error(-20000, 'Invalid Display Order.');
                return;
            end if;

            if (v_new_disp_ord > v_max_disp_ord) then
                v_new_disp_ord := v_max_disp_ord;
            end if;

 --  if current position is greater than new position

            rows := t_rows();

            if (v_cur_disp_ord > v_new_disp_ord) then
                j := v_new_disp_ord;
                for i in v_new_disp_ord..v_cur_disp_ord-1 loop
                    row := t_row();
                    v_sql := 'select * from NCI_QUEST_VALID_VALUE where nvl(fld_delete,0) = 0 and q_pub_id = ' ||  ihook.getColumnValue(row_ori, 'Q_PUB_ID') || ' and q_ver_nr = ' ||  ihook.getColumnValue(row_ori, 'Q_VER_NR') || ' and disp_ord = ' || i ;
                    nci_11179.ReturnRow(v_sql, 'NCI_QUEST_VALID_VALUE', row);
                    if (ihook.getColumnValue(row, 'NCI_PUB_ID') is not null) then
                        j := j+1;
                        ihook.setColumnValue(row, 'DISP_ORD', j);
                        rows.extend;                    rows(rows.last) := row;
                    end if;
                end loop;
            end if;
 -- if current position is less than new position

            if (v_cur_disp_ord < v_new_disp_ord) then
                j := v_cur_disp_ord + 1;
                for i in v_cur_disp_ord+1..v_new_disp_ord loop
                    row := t_row();
                    v_sql := 'select * from NCI_QUEST_VALID_VALUE where nvl(fld_delete,0) = 0 and q_pub_id = ' ||  ihook.getColumnValue(row_ori, 'Q_PUB_ID') || ' and q_ver_nr = ' ||  ihook.getColumnValue(row_ori, 'Q_VER_NR') || ' and disp_ord = ' || i ;
                    nci_11179.ReturnRow(v_sql, 'NCI_QUEST_VALID_VALUE', row);
                    if (ihook.getColumnValue(row, 'NCI_PUB_ID') is not null) then
                        ihook.setColumnValue(row, 'DISP_ORD', j-1);
                        j := j+1;
                        rows.extend;                    rows(rows.last) := row;
                    end if;
                end loop;
            end if;
     -- update current row
            row := t_row();
                    v_sql := 'select * from NCI_QUEST_VALID_VALUE where nvl(fld_delete,0) = 0 and q_pub_id = ' ||  ihook.getColumnValue(row_ori, 'Q_PUB_ID') || ' and q_ver_nr = ' ||  ihook.getColumnValue(row_ori, 'Q_VER_NR') || ' and disp_ord = ' || v_cur_disp_ord ;
                    nci_11179.ReturnRow(v_sql, 'NCI_QUEST_VALID_VALUE', row);

            ihook.setColumnValue(row, 'DISP_ORD', v_new_disp_ord);
            rows.extend;            rows(rows.last) := row;

            action := t_actionRowset(rows, 'Question Valid Values (Hook)', 2, 1000, 'update');
            actions.extend; actions(actions.last) := action;
            hookoutput.actions:= actions;
    end if;
     v_data_out := ihook.getHookOutput(hookOutput);
--    nci_util.debugHook('FORM',v_data_out);

END;



procedure spResetOrderQuestVV  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
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
    i integer;
   v_frm_id number;
   v_frm_ver_nr number(4,2);
     v_sql  varchar2(4000);
BEGIN
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    row_ori :=  hookInput.originalRowset.rowset(1);

    rows := t_rows();

 select r.P_ITEM_ID, r.P_ITEM_VER_NR into v_frm_id, v_frm_Ver_nr from NCI_ADMIN_ITEM_REL_ALT_KEY k, NCI_ADMIN_ITEM_REL r where k.nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID')
 and k.nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR') and k.P_ITEM_ID = r.C_ITEM_ID and k.P_ITEM_VER_NR = r.C_ITEM_VER_NR and r.rel_typ_id = 61;

 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
    i := 0;
    for cur in (select * from NCI_QUEST_VALID_VALUE where nvl(fld_delete,0) = 0 and q_pub_id =   ihook.getColumnValue(row_ori, 'NCI_PUB_ID') and q_ver_nr =
             ihook.getColumnValue(row_ori, 'NCI_VER_NR')  order by disp_ord) loop
                if (i <> cur.disp_ord) then
                    row := t_row();
                    v_sql := 'select * from NCI_QUEST_VALID_VALUE where  NCI_pub_id = '||  cur.NCI_PUB_ID || 'and nci_ver_nr = ' ||   cur.nci_ver_nr ;
                    nci_11179.ReturnRow(v_sql, 'NCI_QUEST_VALID_VALUE', row);
                    ihook.setColumnValue(row, 'DISP_ORD', i);
                    rows.extend;                    rows(rows.last) := row;
                end if;
                i := i+1;
    end loop;

    action := t_actionRowset(rows, 'Question Valid Values (Hook)', 2, 1000, 'update');
    actions.extend; actions(actions.last) := action;
    hookoutput.actions:= actions;

    v_data_out := ihook.getHookOutput(hookOutput);
 --   nci_util.debugHook('FORM',v_data_out);

END;



PROCEDURE spAddForm  ( v_data_in IN CLOB,    v_data_out OUT CLOB, v_user_id in varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    rows  t_rows;
    row_ori t_row;
    action_rows       t_rows := t_rows();
    action_row		    t_row;
    rowset            t_rowset;
    question    t_question;
    answer     t_answer;
    answers     t_answers;
    showrowset	t_showablerowset;
    forms t_forms;
    form1 t_form;
    rowform t_row;
    v_found boolean;
    v_form_id integer;
    i integer := 0;
BEGIN
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    -- First invocation - show the Add Form
    if hookInput.invocationNumber = 0 then
        ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(1, 1, 'Create Form');
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION('Create New Form', ANSWERS);
        HOOKOUTPUT.QUESTION    := QUESTION;

        forms                  := t_forms();
        form1                  := t_form('Forms (Hook)', 2,1);  -- Forms (Hook) is a custom object for this purpose.
        action_row := t_row();

        -- Set the default workflow status and Form Type; attach to Add Form.

        ihook.setColumnValue(action_row, 'ADMIN_STUS_ID', 66);
         ihook.setColumnValue(action_row, 'REGSTR_STUS_ID', 9);
        ihook.setColumnValue(action_row, 'FORM_TYP_ID', 70);
        action_rows.extend; action_rows(action_rows.last) := action_row;
        rowset := t_rowset(action_rows, 'Form (Hook)', 1,'NCI_FORM');

        form1.rowset :=rowset;
        forms.extend;
        forms(forms.last) := form1;
        hookOutput.forms := forms;
  ELSE -- Second invocation
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);

        v_form_id :=  nci_11179.getItemId;
        row := t_row();
        row := rowform;

        ihook.setColumnValue(row, 'ITEM_ID', v_form_id);
        ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row, 'VER_NR', 1);
        ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 54);
        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_form_id || c_ver_suffix);

        rows:= t_rows();
        rows.extend;
        rows(rows.last) := row;

        -- Insert super-type
        action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'insert');
        actions.extend;
        actions(actions.last) := action;
        -- Insert sub-type
        action             := t_actionrowset(rows, 'Form AI', 2, 1,'insert');
        actions.extend;
        actions(actions.last) := action;

        -- Insert form-protocol relationship if protocol specified
        if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(rowform, 'P_ITEM_ID'), ihook.getColumnValue(rowform,'P_ITEM_VER_NR'), v_user_id) = true) then
        if (ihook.getColumnValue(rowform,'P_ITEM_ID') > 0) then
            rows:= t_rows();
            rowrel := t_row();
            ihook.setColumnValue(rowrel, 'P_ITEM_ID', ihook.getColumnValue(rowform,'P_ITEM_ID'));
            ihook.setColumnValue(rowrel, 'P_ITEM_VER_NR', ihook.getColumnValue(rowform,'P_ITEM_VER_NR'));
            ihook.setColumnValue(rowrel, 'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
            ihook.setColumnValue(rowrel, 'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
            ihook.setColumnValue(rowrel, 'C_ITEM_ID', v_form_id);
            ihook.setColumnValue(rowrel, 'C_ITEM_VER_NR', 1);
            ihook.setColumnValue(rowrel, 'REL_TYP_ID', 60);
   ihook.setColumnValue(rowrel, 'REP_NO', 0);
         
            rows.extend;
            rows(rows.last) := rowrel;
            action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 2,'insert');
            actions.extend;
            actions(actions.last) := action;
        end if;
        else
        if (ihook.getColumnValue(rowform,'P_ITEM_ID') > 0) then
        hookoutput.message := 'Protocol not in your authorized Context and was not added. ' || chr(13);
        end if;
        end if;
        hookoutput.actions    := actions;
        hookoutput.message := hookoutput.message || 'Form Created Successfully with ID ' || v_form_id;
    END IF;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spAddFormFromExisting  ( v_data_in IN CLOB,    v_data_out OUT CLOB, v_user_id in varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    rows  t_rows;
    row_ori t_row;
    action_rows       t_rows := t_rows();
    action_row		    t_row;
    rowset            t_rowset;
    question    t_question;
    answer     t_answer;
    answers     t_answers;
    showrowset	t_showablerowset;
    forms t_forms;
    form1 t_form;
    rowform t_row;
    v_from_item_id number;
    v_from_Ver_nr number(4,2);
    v_found boolean;
    v_form_id integer;
    i integer := 0;
    v_retired_cde integer :=0;

BEGIN
    hookinput                    := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
     row_ori :=  hookInput.originalRowset.rowset(1);
     v_from_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
        v_from_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');

    -- First invocation - show the Add Form
    if hookInput.invocationNumber = 0 then
        ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(1, 1, 'Create Form');
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION('Create New Form', ANSWERS);
        HOOKOUTPUT.QUESTION    := QUESTION;

    select count(*) into v_retired_cde from VW_NCI_MODULE_DE WHERE frm_item_id = v_from_item_id and frm_ver_nr = v_from_ver_nr and DE_ITEM_ID is not null
    and (DE_ADMIN_STUS_NM_DN like '%RETIRED%' or DE_CURRNT_VER_IND = 0);
    if (v_retired_cde >0) then
      hookoutput.message := getFormRetiredCount(v_from_item_id, v_from_ver_nr);
      end if;
        forms                  := t_forms();
        form1                  := t_form('Forms (Hook From Existing)', 2,1);  -- Forms (Hook) is a custom object for this purpose.
        action_row := row_ori;
        nci_11179.spReturnSubtypeRow (v_from_item_id, v_from_ver_nr, 54, action_row);
         ihook.setColumnValue(action_row, 'ADMIN_STUS_ID', 66);
         ihook.setColumnValue(action_row, 'REGSTR_STUS_ID', 9);
    --    ihook.setColumnValue(action_row, 'P_ITEM_ID', '');
     --            ihook.setColumnValue(action_row, 'P_ITEM_VER_NR', '');
----
        ihook.setColumnValue(action_row, 'FORM_TYP_ID', 70);
        ihook.setColumnValue(action_row, 'ITEM_NM', 'Copied from ' || ihook.getColumnValue(row_ori, 'ITEM_NM'));
  
        action_rows.extend; action_rows(action_rows.last) := action_row;
        rowset := t_rowset(action_rows, 'Forms (Hook From Existing)', 1,'VW_NCI_FORM');

        form1.rowset :=rowset;
        forms.extend;
        forms(forms.last) := form1;
        hookOutput.forms := forms;
      
  ELSE -- Second invocation
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);

   --    raise_application_error(-20000, 'yyy' || nvl(ihook.getColumnValue(rowform, 'P_ITEM_VER_NR'),'1') || 'kkk');
    /*   if (nvl(ihook.getColumnValue(rowform, 'P_ITEM_VER_NR'),0) = 0) then
                ihook.setColumnValue(rowform, 'P_ITEM_ID', 1);
                ihook.setColumnValue(rowform, 'P_ITEM_VER_NR', 1);
            end if;*/
        v_form_id :=  nci_11179.getItemId;
        row := t_row();
        row := rowform;

        ihook.setColumnValue(row, 'ITEM_ID', v_form_id);
        ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row, 'VER_NR', 1);
        ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 54);
        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_form_id || c_ver_suffix);
        ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
         ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);

        rows:= t_rows();
        rows.extend;
        rows(rows.last) := row;

        -- Insert super-type
        action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'insert');
        actions.extend;
        actions(actions.last) := action;
        -- Insert sub-type
        action             := t_actionrowset(rows, 'Form AI', 2, 1,'insert');
        actions.extend;
        actions(actions.last) := action;

    
        --Copy all modules
        for cur2 in (select c_item_id, c_item_ver_nr, disp_ord from nci_admin_item_rel where p_item_id = v_from_item_id and p_item_ver_nr = v_from_ver_nr
     and nvl(fld_delete,0) = 0) loop
     nci_11179.spCopyModuleNCI (actions, cur2.c_item_id,cur2.c_item_ver_nr,    v_from_item_id, v_from_ver_nr,v_form_id, 1, cur2.disp_ord,'V', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'),
     ihook.getColumnValue(rowform,'CNTXT_VER_NR'), v_user_id);
    end loop;
 --           nci_11179.spCreateCommonChildrenNCI(actions, v_from_item_id,v_from_ver_nr, v_form_id, 1);
 --- Only copy classification
 rows := t_rows();
 
  for cur in (select P_ITEM_ID,P_ITEM_VER_NR, REL_TYP_ID from NCI_ADMIN_ITEM_REL where
    c_item_id = v_from_item_id and c_item_ver_nr = v_from_ver_nr and rel_typ_id = 65 and nvl(fld_Delete,0) = 0) loop
  row :=t_row();  
  ihook.setColumnValue(row, 'P_ITEM_ID', cur.p_item_id);
            ihook.setColumnValue(row, 'P_ITEM_VER_NR', cur.p_item_ver_nr);
          --  ihook.setColumnValue(rowrel, 'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
          --  ihook.setColumnValue(rowrel, 'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
            ihook.setColumnValue(row, 'C_ITEM_ID', v_form_id);
            ihook.setColumnValue(row, 'C_ITEM_VER_NR', 1);
            ihook.setColumnValue(row, 'REL_TYP_ID', 65);
               ihook.setColumnValue(row, 'REP_NO', 0);
         
  rows.extend;
            rows(rows.last) := row;
  end loop;
       
       if (rows.count > 0) then
            action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 7,'insert');
            actions.extend;
            actions(actions.last) := action;
        end if;
         -- Insert form-protocol relationship if protocol specified
  for cur in (select item_id, ver_nr from admin_item where item_id = nvl(ihook.getColumnValue(rowform,'P_ITEM_ID'),0) and ver_nr = nvl(ihook.getColumnValue(rowform,'P_ITEM_VER_NR'),0)) loop
       if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(rowform, 'P_ITEM_ID'), ihook.getColumnValue(rowform,'P_ITEM_VER_NR'), v_user_id) = true) then
   
            rows:= t_rows();
            rowrel := t_row();
            ihook.setColumnValue(rowrel, 'P_ITEM_ID', ihook.getColumnValue(rowform,'P_ITEM_ID'));
            ihook.setColumnValue(rowrel, 'P_ITEM_VER_NR', ihook.getColumnValue(rowform,'P_ITEM_VER_NR'));
          --  ihook.setColumnValue(rowrel, 'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
          --  ihook.setColumnValue(rowrel, 'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
            ihook.setColumnValue(rowrel, 'C_ITEM_ID', v_form_id);
            ihook.setColumnValue(rowrel, 'C_ITEM_VER_NR', 1);
            ihook.setColumnValue(rowrel, 'REL_TYP_ID', 60);
   ihook.setColumnValue(rowrel, 'REP_NO', 0);
         
            rows.extend;
            rows(rows.last) := rowrel;
            action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 7,'insert');
            actions.extend;
            actions(actions.last) := action;
        else
          hookoutput.message := 'Protocol not in your authorized Context and was not added. ' || chr(13);
 
        end if;
        end loop;
   
        hookoutput.actions    := actions;
        
        hookoutput.message :=  hookoutput.message || 'Form Created Successfully with ID ' || v_form_id;
    END IF;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  nci_util.debugHook('GENERAL',v_data_out);
  
END;

PROCEDURE spAddModule  (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowrel t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
  v_form_id number;
  v_form_ver_nr number(4,2);
  v_form_nm varchar2(255);
  v_obj_nm varchar2(100);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
--raise_application_error(-20000,hookinput.originalrowset.tablename);
if (hookinput.originalrowset.tablename = 'ADMIN_ITEM' or hookinput.originalrowset.tablename='Form/Template' ) then
 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a module to this form.');
 end if;
 v_form_id :=ihook.getColumnValue(row_ori, 'ITEM_ID');
 v_form_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
 v_form_nm := ihook.getColumnValue(row_ori, 'ITEM_NM');
 select nvl(max(disp_ord)+ 1,0) into v_disp_ord from nci_admin_item_rel where p_item_id = v_form_id 
 and p_item_ver_nr = v_form_ver_nr;
 v_obj_nm := 'Modules (Hook)';
else -- Stand alone module
v_form_id :=-1;
 v_form_ver_nr := 1;
 v_form_nm := 'No Form Relationship';
 v_disp_ord := 0;
 v_obj_nm :=  'SA Modules (Hook)';
end if;
 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Create Module');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add New Module', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

    rows := t_rows();
    row := t_row();
        ihook.setColumnValue(row, 'P_ITEM_ID', v_form_id);
        ihook.setColumnValue(row, 'P_ITEM_VER_NR', v_form_ver_nr);
        ihook.setColumnValue(row, 'FORM_NM',v_form_nm );
        -- get default context from Form
    /*    for cur in (select cntxt_item_id, cntxt_ver_nr from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')) loop
           ihook.setColumnValue(row, 'CNTXT_ITEM_ID', cur.CNTXT_ITEM_ID);
            ihook.setColumnValue(row, 'CNTXT_VER_NR', cur.CNTXT_VER_NR);
        end loop;
        ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
        ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);*/
   --      ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);

        rows.extend; rows(rows.last) := row;
        rowset := t_rowset(rows, 'SA Module (Hook)', 1,'NCI_ADMIN_ITEM_REL');

    forms                  := t_forms();
    form1                  := t_form(v_obj_nm, 2,1);
    form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
 ELSE
    IF HOOKINPUT.ANSWERID = 1 THEN
        forms              := hookInput.forms;
        form1              := forms(1);

        rowform := form1.rowset.rowset(1);

        v_module_id :=  nci_11179.getItemId;
        row := rowform;


   -- raise_application_error(-20000, ihook.getColumnValue(rowform,'INSTR'));

             ihook.setColumnValue(row, 'ITEM_ID', v_module_id);
            ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
            ihook.setColumnValue(row, 'VER_NR',v_form_ver_Nr );
            ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 52);

              for cur in (select cntxt_item_id, cntxt_ver_nr from admin_item where item_id = v_form_id and ver_nr = v_form_ver_nr) loop
           ihook.setColumnValue(row, 'CNTXT_ITEM_ID', cur.CNTXT_ITEM_ID);
            ihook.setColumnValue(row, 'CNTXT_VER_NR', cur.CNTXT_VER_NR);
        end loop;
       /* if (v_form_id = -1) then -- Stand Alone Module - NCIP
               ihook.setColumnValue(row, 'CNTXT_ITEM_ID', 	20000000024);
            ihook.setColumnValue(row, 'CNTXT_VER_NR', 1);
    
        end if;*/
        ihook.setColumnValue(row, 'ADMIN_STUS_ID', 66);
        ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);

       --     if ( ihook.getColumnValue(rowform,'ITEM_LONG_NM')= v_dflt_txt) then
                   ihook.setColumnValue(row, 'ITEM_LONG_NM', v_module_id ||  c_ver_suffix);
        --    else
        --                ihook.setColumnValue(row, 'ITEM_LONG_NM', ihook.getColumnValue(rowform,'ITEM_LONG_NM'));

          --  end if;
           ihook.setColumnValue(row, 'ITEM_DESC', ihook.getColumnValue(row, 'ITEM_NM'));

            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;

            --action             := t_actionrowset(rows, 'Module', 2, 0,'insert');
            --actions.extend;
            --actions(actions.last) := action;

            rows:= t_rows();
      --   raise_application_error(-20000, v_disp_ord);

            rowrel := t_row();
            ihook.setColumnValue(rowrel, 'P_ITEM_ID', v_form_id);
            ihook.setColumnValue(rowrel, 'P_ITEM_VER_NR', v_form_ver_nr);
            ihook.setColumnValue(rowrel, 'C_ITEM_ID', v_module_id);
            ihook.setColumnValue(rowrel, 'C_ITEM_VER_NR', v_form_ver_nr);
            ihook.setColumnValue(rowrel, 'CNTXT_ITEM_ID',ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
            ihook.setColumnValue(rowrel, 'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
            ihook.setColumnValue(rowrel, 'DISP_ORD', v_disp_ord);
            ihook.setColumnValue(rowrel, 'REL_TYP_ID', 61);
            ihook.setColumnValue(rowrel, 'REP_NO', nvl(ihook.getColumnValue(rowform,'REP_NO'),0));
            ihook.setColumnValue(rowrel, 'INSTR', ihook.getColumnValue(rowform,'INSTR'));

            rows.extend;
            rows(rows.last) := rowrel;
     -- raise_application_error(-20000,  ihook.getColumnValue(row_ori,'ITEM_ID'));
            action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 2,'insert');
            actions.extend;
            actions(actions.last) := action;
    hookoutput.actions    := actions;
    hookoutput.message := 'Module Created Successfully with ID ' || v_module_id;

if (v_form_id>0) then
    update admin_item set  LST_UPD_DT = sysdate, LST_UPD_USR_ID = v_user_id
    where ITEM_ID = v_form_id and VER_NR = v_form_ver_nr;
    commit;
end if;
    END IF;
  END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --  nci_util.debugHook('GENERAL',v_data_out);
END;


PROCEDURE spAddSAModule  (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowrel t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_module_id integer;

  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Create Module');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add New Module', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

    rows := t_rows();
    row := t_row();
        ihook.setColumnValue(row, 'P_ITEM_ID',-1);
        ihook.setColumnValue(row, 'P_ITEM_VER_NR', 1);
        ihook.setColumnValue(row, 'FORM_NM', 'Not Applicable');
        ihook.setColumnValue(row, 'ITEM_LONG_NM', v_dflt_txt);
        ihook.setColumnValue(row, 'ADMIN_STUS_ID', 65);
        ihook.setColumnValue(row, 'REGSTR_STUS_ID', 9);
        rows.extend; rows(rows.last) := row;
        rowset := t_rowset(rows, 'Module (Hook)', 1,'NCI_ADMIN_ITEM_REL');

    forms                  := t_forms();
    form1                  := t_form('Modules (Hook)', 2,1);
    form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
 ELSE
    IF HOOKINPUT.ANSWERID = 1 THEN
        forms              := hookInput.forms;
        form1              := forms(1);

        rowform := form1.rowset.rowset(1);

        v_module_id :=  nci_11179.getItemId;
        row := rowform;


   -- raise_application_error(-20000, ihook.getColumnValue(rowform,'INSTR'));

           ihook.setColumnValue(row, 'ITEM_ID', v_module_id);
            ihook.setColumnValue(row, 'CURRNT_VER_IND', 1);
            ihook.setColumnValue(row, 'VER_NR',1 );
            ihook.setColumnValue(row, 'ADMIN_ITEM_TYP_ID', 52);
            if ( ihook.getColumnValue(rowform,'ITEM_LONG_NM')= v_dflt_txt) then
                   ihook.setColumnValue(row, 'ITEM_LONG_NM', v_module_id ||  c_ver_suffix);
            else
                        ihook.setColumnValue(row, 'ITEM_LONG_NM', ihook.getColumnValue(rowform,'ITEM_LONG_NM'));

            end if;

            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;

            rows:= t_rows();

            rowrel := t_row();
            ihook.setColumnValue(rowrel, 'P_ITEM_ID', v_module_id);
            ihook.setColumnValue(rowrel, 'P_ITEM_VER_NR', 1);
            ihook.setColumnValue(rowrel, 'C_ITEM_ID', v_module_id);
            ihook.setColumnValue(rowrel, 'C_ITEM_VER_NR', 1);
            ihook.setColumnValue(rowrel, 'CNTXT_ITEM_ID', ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID'));
            ihook.setColumnValue(rowrel, 'CNTXT_VER_NR',  ihook.getColumnValue(rowform, 'CNTXT_VER_NR'));
            ihook.setColumnValue(rowrel, 'DISP_ORD', 0);
            ihook.setColumnValue(rowrel, 'REL_TYP_ID', 67);
            ihook.setColumnValue(rowrel, 'REP_NO', 0);
            ihook.setColumnValue(rowrel, 'INSTR', ihook.getColumnValue(rowform,'INSTR'));

            rows.extend;
            rows(rows.last) := rowrel;
     -- raise_application_error(-20000,  ihook.getColumnValue(row_ori,'ITEM_ID'));
            action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 2,'insert');
            actions.extend;
            actions(actions.last) := action;
    hookoutput.actions    := actions;
    hookoutput.message := 'Module Created Successfully with ID ' || v_module_id;

    END IF;
  END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  --  nci_util.debugHook('GENERAL',v_data_out);
END;

PROCEDURE spEditModule  (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowrel t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit module to this form.');
 end if;

 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Update');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Edit Module', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
    rows := t_rows();
    row := row_ori;

    nci_11179.spReturnAIRow( ihook.getColumnValue(row_ori, 'C_ITEM_ID'),ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR'), row);
  --   Form name
    for cur in (select item_nm from admin_item where item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR')) loop
  --  and  ihook.getColumnValue(row_ori, 'P_ITEM_ID') <>  ihook.getColumnValue(row_ori, 'C_ITEM_ID')) loop
     ihook.setColumnValue(row, 'FORM_NM', cur.item_nm);
     end loop;
       rows.extend; rows(rows.last) := row;
        rowset := t_rowset(rows, 'Modules (Hook)', 1,'ADMIN_ITEM');

--

    forms                  := t_forms();
    form1                  := t_form('Modules (Hook)', 2,1);
    form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
 ELSE
    IF HOOKINPUT.ANSWERID = 1 THEN
        forms              := hookInput.forms;
        form1              := forms(1);

        rowform := form1.rowset.rowset(1);

       row := t_row();
       -- Get original row
       nci_11179.spReturnAIRow( ihook.getColumnValue(row_ori, 'C_ITEM_ID'),ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR'), row);
               --         ihook.setColumnValue(row, 'ITEM_LONG_NM', ihook.getColumnValue(rowform,'ITEM_LONG_NM'));
                        ihook.setColumnValue(row, 'ITEM_NM', ihook.getColumnValue(rowform,'ITEM_NM'));
            --            ihook.setColumnValue(row, 'ADMIN_STUS_ID', ihook.getColumnValue(rowform,'ADMIN_STUS_ID'));
          --              ihook.setColumnValue(row, 'REGSTR_STUS_ID', ihook.getColumnValue(rowform,'REGSTR_STUS_ID'));
          --  ihook.setColumnValue(row, 'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
         --   ihook.setColumnValue(row, 'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));

            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Administered Item (No Sequence)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;

            rows:= t_rows();

          row := row_ori;
            ihook.setColumnValue(row, 'INSTR', ihook.getColumnValue(rowform,'INSTR'));
            ihook.setColumnValue(row, 'REP_NO', nvl(ihook.getColumnValue(row,'REP_NO'),0));

            rows.extend;
            rows(rows.last) := row;
     -- raise_application_error(-20000,  ihook.getColumnValue(row_ori,'ITEM_ID'));
            action             := t_actionrowset(rows, 'Generic AI Relationship', 2, 2,'update');
            actions.extend;
            actions(actions.last) := action;
    hookoutput.actions    := actions;
    hookoutput.message := 'Module updated Successfully.';



    END IF;
  END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spAddQuestionRep (rep in integer, row_ori in t_row, rows in out t_rows)
AS
  i integer;
  v_temp integer;
  row t_row;
  v_ori_rep integer;

begin
        v_ori_rep := nvl(ihook.getColumnValue(row_ori, 'REP_NO'),0);
        for cur in (select nci_pub_id, nci_ver_nr, edit_ind, req_ind from nci_admin_item_rel_alt_key where p_item_id =ihook.getColumnValue(row_ori,'C_ITEM_ID') and
        P_item_ver_nr =  ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and nvl(fld_delete,0) = 0) loop
        for i in v_ori_rep+1..rep loop
        select count(*) into v_temp from nci_quest_vv_rep where quest_pub_id =cur.nci_pub_id and quest_ver_nr = cur.nci_ver_nr and rep_seq = i;

            if v_temp = 0 then
            row := t_row();
            ihook.setColumnValue(row, 'QUEST_PUB_ID', cur.nci_pub_id);
            ihook.setColumnValue(row, 'QUEST_VER_NR', cur.nci_ver_nr);
            ihook.setColumnValue(row, 'REP_SEQ', i);
            ihook.setColumnValue(row, 'EDIT_IND', nvl(cur.edit_ind,1));
            ihook.setColumnValue(row, 'REQ_IND', nvl(cur.req_ind,0));
         ihook.setColumnValue(row, 'QUEST_VV_REP_ID',-1);
        --    raise_application_error(-20000,i);
            rows.extend;
            rows(rows.last) := row;
          end if;
       end loop;
       end loop;
end;


procedure spAddQuestionRepNew (rep in integer, v_quest_id in integer, rows in out t_rows)
AS
  i integer;
  v_temp integer;
  row t_row;

begin
        for i in 1..rep loop
            row := t_row();
            ihook.setColumnValue(row, 'QUEST_PUB_ID',v_quest_id );
            ihook.setColumnValue(row, 'QUEST_VER_NR', 1);
            ihook.setColumnValue(row, 'REP_SEQ', i);
           ihook.setColumnValue(row, 'EDIT_IND',1);
            ihook.setColumnValue(row, 'QUEST_VV_REP_ID',-1);
        --    raise_application_error(-20000,i);
            rows.extend;
            rows(rows.last) := row;

       end loop;
end;

PROCEDURE spSetModRep
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
    AS
forms t_forms;
  form1 t_form;
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
showrowset	t_showablerowset;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  v_temp integer;
  v_ori_rep integer;
  rep integer;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit module to this form.');
 end if;

v_ori_rep := nvl(ihook.getColumnValue(row_ori, 'REP_NO'),0);

 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Set Repetition');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Set Module Repetition, Current Repetitions: ' || v_ori_rep, ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
	  /*  for i in 1..20 loop

		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'Repetition', i);
		   rows.extend;
		   rows (rows.last) := row;

	    end loop;

	   	 showrowset := t_showablerowset (rows, 'Repetition', 4, 'single');
       	 hookoutput.showrowset := showrowset;
*/

    forms                  := t_forms();
    form1                  := t_form('Question Repetition Set (Hook)', 2,1);
    forms.extend;    forms(forms.last) := form1;
    hookoutput.forms :=     forms;

  ELSE -- hook invocation = 1
     forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);

        rows := t_rows();
        rep := nvl(ihook.getColumnValue(rowform, 'VER_NR'),0);
        
          if (rep <= 0 ) then
            hookoutput.message := 'Specify a repetition number greater than 0.';
            V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
            return;
      end if;
        if (rep < v_ori_rep   ) then
            hookoutput.message := 'Specify a number larger than the current number of repetition  - ' || v_ori_rep;
            V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
            return;
      end if;
      
     
    --    raise_application_error(-20000,rep);
        spAddQuestionRep (rep, row_ori, rows);
        if (rows.count > 0) then
        action             := t_actionrowset(rows, 'Question Repetition', 2, 0,'insert');
            actions.extend;
            actions(actions.last) := action;
         end if;
            rows := t_rows();
            row := t_row();
             ihook.setColumnValue(row_ori, 'REP_NO', rep);

     rows.extend;
            rows(rows.last) := row_ori;
            action             := t_actionrowset(rows, 'Form-Module Relationship', 2, 1,'update');
            actions.extend;
            actions(actions.last) := action;

    hookoutput.actions    := actions;
    END IF;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--  nci_util.debugHook('GENERAL',v_data_out);
--  insert into junk_debug values (sysdate, v_data_out);
 -- commit;

END;


PROCEDURE spDelModRep
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
    row_sel t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  v_temp integer;
  v_rep integer;
  v_rep_sel integer;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit module to this form.');
 end if;

  v_rep :=  nvl(ihook.getColumnValue(row_ori, 'REP_NO'),0);
 if (v_rep = 0) then
 raise_application_error(-20000,'This module does not have any repetitions.');
 end if;
 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select Repetition');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Delete Repetition', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

	    for i in 1..v_rep loop

		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'Repetition', i);
		   rows.extend;
		   rows (rows.last) := row;

	    end loop;

	   	 showrowset := t_showablerowset (rows, 'Repetition', 4, 'single');
       	 hookoutput.showrowset := showrowset;


  ELSE
        row_sel := hookinput.selectedRowset.rowset(1);
        rows := t_rows();
        v_rep_sel := ihook.getColumnValue(row_sel, 'Repetition');
        rows := t_rows();
        for cur in (select r.quest_vv_rep_id from nci_admin_item_rel_alt_key ak, nci_quest_vv_rep r
        where ak.p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
        ak.p_item_ver_nr = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and
        r.quest_pub_id = ak.nci_pub_id and r.quest_ver_nr = ak.nci_ver_nr and r.rep_seq = v_rep_sel) loop
        row := t_row();
        ihook.setColumnValue(row,'QUEST_VV_REP_ID', cur.QUEST_VV_REP_ID);
        rows.extend;            rows(rows.last) := row;
        end loop;

        if (rows.count > 0) then
        action             := t_actionrowset(rows, 'Question Repetition', 2, 0,'delete');
            actions.extend;
            actions(actions.last) := action;
        action             := t_actionrowset(rows, 'Question Repetition', 2, 1,'purge');
            actions.extend;
            actions(actions.last) := action;
         end if;
         rows := t_rows();
         for i in v_rep_sel+1..v_rep loop
            for cur in (select r.* from nci_admin_item_rel_alt_key ak, nci_quest_vv_rep r
            where ak.p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
            ak.p_item_ver_nr = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and
            r.quest_pub_id = ak.nci_pub_id and r.quest_ver_nr = ak.nci_ver_nr and r.rep_seq = i) loop
                row := t_row();
                ihook.setColumnValue(row,'QUEST_VV_REP_ID', cur.QUEST_VV_REP_ID);
                           ihook.setColumnValue(row, 'QUEST_PUB_ID', cur.quest_pub_id);
            ihook.setColumnValue(row, 'QUEST_VER_NR', cur.quest_ver_nr);
            ihook.setColumnValue(row, 'REP_SEQ', i-1);
            ihook.setColumnValue(row, 'EDIT_IND', cur.edit_ind);

                rows.extend;            rows(rows.last) := row;
            end loop;
        end loop;
        if (rows.count > 0) then
        action             := t_actionrowset(rows, 'Question Repetition', 2, 3,'update');
            actions.extend;
            actions(actions.last) := action;
         end if;
         rows := t_rows();

           ihook.setColumnValue(row_ori, 'REP_NO', v_rep-1);

     rows.extend;
            rows(rows.last) := row_ori;
            action             := t_actionrowset(rows, 'Form-Module Relationship', 2, 4,'update');
            actions.extend;
            actions(actions.last) := action;

    hookoutput.actions    := actions;
    END IF;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

END;


PROCEDURE spDelModRepNew
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
    row_sel t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  v_disp_ord integer;
  v_add integer;
  i integer := 0;
  v_temp integer;
  v_rep integer;
  v_start_rep integer;
  v_end_rep integer;
  v_rep_sel integer;
  column  t_column;
  msg varchar2(4000);
  forms t_forms;
  form1 t_form;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_usr_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit module to this form.');
 end if;

  v_rep :=  nvl(ihook.getColumnValue(row_ori, 'REP_NO'),0);
 if (v_rep = 0) then
 raise_application_error(-20000,'This module does not have any repetitions.');
 end if;
 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Delete Range of Repetitions');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Delete Repetitions.  Current repetitions:' || v_rep || '. This operation can take time. Do not click again.', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
-- Form instead of rows
 forms                  := t_forms();
    form1                  := t_form('Delete Repetition (Hook)', 2,1);
    form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
  ELSE
    forms              := hookInput.forms;
        form1              := forms(1);

        row_sel := form1.rowset.rowset(1);

        v_start_rep := ihook.getColumnValue(row_sel, 'ITEM_ID');
        v_end_rep := ihook.getColumnValue(row_sel, 'VER_NR');

        if (v_start_rep > v_rep or v_end_rep > v_rep) then
        hookoutput.message :='From or To Repetition Number outside the total number of repetitions: '|| v_rep;
         V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
        return;
        end if;

        if (v_start_rep <= 0 or v_end_rep <= 0 or v_end_rep < v_start_rep) then
        hookoutput.message := 'From or To Repetition Number have to be positive. From Repetition Number has to be less than or equal to End Repetition Number '|| v_rep;
         V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
        return;
        end if;

        rows := t_rows();
     --   v_rep_sel := ihook.getColumnValue(row_sel, 'Repetition');
        rows := t_rows();
        for v_rep_sel in v_start_rep..v_end_rep loop
        for cur in (select r.quest_vv_rep_id from nci_admin_item_rel_alt_key ak, nci_quest_vv_rep r
        where ak.p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
        ak.p_item_ver_nr = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and
        r.quest_pub_id = ak.nci_pub_id and r.quest_ver_nr = ak.nci_ver_nr and r.rep_seq = v_rep_sel
        and nvl(ak.fld_delete,0) = 0 and nvl(r.fld_delete,0) = 0) loop
        row := t_row();
        ihook.setColumnValue(row,'QUEST_VV_REP_ID', cur.QUEST_VV_REP_ID);
        rows.extend;            rows(rows.last) := row;
        end loop;
        end loop;

        if (rows.count > 0) then
        action             := t_actionrowset(rows, 'Question Repetition', 2, 0,'delete');
            actions.extend;
            actions(actions.last) := action;
        action             := t_actionrowset(rows, 'Question Repetition', 2, 1,'purge');
            actions.extend;
            actions(actions.last) := action;
         end if;
         rows := t_rows();
         for i in v_end_rep+1..v_rep loop
            for cur in (select r.* from nci_admin_item_rel_alt_key ak, nci_quest_vv_rep r
            where ak.p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
            ak.p_item_ver_nr = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and
            r.quest_pub_id = ak.nci_pub_id and r.quest_ver_nr = ak.nci_ver_nr and r.rep_seq = i
             and nvl(ak.fld_delete,0) = 0 and nvl(r.fld_delete,0) = 0) loop
                row := t_row();
                ihook.setColumnValue(row,'QUEST_VV_REP_ID', cur.QUEST_VV_REP_ID);
                           ihook.setColumnValue(row, 'QUEST_PUB_ID', cur.quest_pub_id);
            ihook.setColumnValue(row, 'QUEST_VER_NR', cur.quest_ver_nr);
            ihook.setColumnValue(row, 'REP_SEQ', i-(v_end_rep-v_start_rep)-1);
            ihook.setColumnValue(row, 'EDIT_IND', cur.edit_ind);

                rows.extend;            rows(rows.last) := row;
            end loop;
        end loop;
        if (rows.count > 0) then
        action             := t_actionrowset(rows, 'Question Repetition', 2, 3,'update');
            actions.extend;
            actions(actions.last) := action;
         end if;
         rows := t_rows();

           ihook.setColumnValue(row_ori, 'REP_NO', v_rep-(v_end_rep-v_start_rep)-1);

     rows.extend;
            rows(rows.last) := row_ori;
            action             := t_actionrowset(rows, 'Form-Module Relationship', 2, 4,'update');
            actions.extend;
            actions(actions.last) := action;

    hookoutput.actions    := actions;
    hookoutput.message := 'Repetitions deleted successfully.';
    END IF;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

END;

PROCEDURE spSetDefltVal
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
  rowrel t_row;
  rows  t_rows;
  rows0 t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
 row_sel t_row;
 rep integer;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_mod_id number;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_mod_ver_nr number(4,2);
  v_disp_ord integer;
  v_add integer;
  v_rep integer;
  i integer := 0;
  v_temp number;
  column  t_column;
  msg varchar2(4000);
  v_cur_dflt  varchar2(4000) := null;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 -- Get form and module ID


 select r.P_ITEM_ID, r.P_ITEM_VER_NR into v_frm_id, v_frm_Ver_nr from NCI_ADMIN_ITEM_REL_ALT_KEY k, NCI_ADMIN_ITEM_REL r where k.nci_pub_id = ihook.getColumNValue(row_ori, 'Q_PUB_ID')
 and k.nci_ver_nr = ihook.getColumNValue(row_ori, 'Q_VER_NR') and k.P_ITEM_ID = r.C_ITEM_ID and k.P_ITEM_VER_NR = r.C_ITEM_VER_NR and r.rel_typ_id = 61;

 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;


 if hookInput.invocationNumber = 0 then

   v_found := false;
   rows := t_rows();
   row := t_row();


    for cur in (select value from nci_quest_valid_value vv, nci_admin_item_rel_alt_key q where q.nci_pub_id = ihook.getColumnValue(row_ori,'Q_PUB_ID') and q.nci_ver_nr = ihook.getColumnValue(row_ori,'Q_VER_NR')
    and vv.nci_pub_id = q.deflt_val_id) loop
        v_cur_dflt := cur.value;
    end loop;

   ihook.setColumnValue(row, 'Repetition', 'Question');
   ihook.setColumnValue(row, 'DO', 0);
    ihook.setColumnValue(row, 'Current Default',v_cur_dflt);
    ihook.setColumnValue(row, 'New Default', ihook.getColumnValue(row_ori, 'VALUE'));

            rows.extend;
            rows(rows.last) := row;
   for cur in (Select rep_seq ,DEFLT_VAL_ID  from nci_quest_vv_rep where QUEST_PUB_ID=ihook.getColumNValue(row_ori, 'Q_PUB_ID')  and quest_ver_nr = ihook.getColumNValue(row_ori, 'Q_VER_NR')) loop
   row := t_row();
   v_cur_dflt := null;
    for cur1 in (select value from nci_quest_valid_value vv where vv.nci_pub_id = cur.deflt_val_id) loop
        v_cur_dflt := cur1.value;
    end loop;


    ihook.setColumnValue(row, 'Repetition', 'Repetition');
   ihook.setColumnValue(row, 'DO', cur.rep_seq);
 ihook.setColumnValue(row, 'Current Default',v_cur_dflt);
   ihook.setColumnValue(row, 'New Default', ihook.getColumnValue(row_ori, 'VALUE'));

            rows.extend;
            rows(rows.last) := row;
  -- raise_application_error (-20000, 'In here');

      v_found := true;
   end loop;

  -- if (v_found) then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Set Default');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Set', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
          	 showrowset := t_showablerowset (rows, 'Repetition', 4, 'multi');
       	 hookoutput.showrowset := showrowset;

 ELSE


        rows := t_rows();

      for i in 1..hookinput.selectedRowset.rowset.count loop

       row_sel := hookinput.selectedRowset.rowset(i);

        rep := ihook.getColumnValue(row_sel, 'DO');

        if (rep = 0) then -- main question default


          row := t_row();
          rows0 := t_rows();
           ihook.setColumnValue(row, 'NCI_PUB_ID', ihook.getColumnValue(row_ori,'Q_PUB_ID'));
           ihook.setColumnValue(row, 'NCI_VER_NR', ihook.getColumnValue(row_ori,'Q_VER_NR'));
           ihook.setColumnValue(row, 'DEFLT_VAL_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
     ihook.setColumnValue(row, 'QUEST_REF_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));


    rows0.extend;
            rows0(rows0.last) := row;
     -- raise_application_error(-20000,  ihook.getColumnValue(row_ori,'ITEM_ID'));
            action             := t_actionrowset(rows0, 'Questions (Base Object)', 2, 2,'update');
            actions.extend;
            actions(actions.last) := action;
        end if;
        if (rep>0) then
        select 	QUEST_VV_REP_ID into v_temp from nci_quest_vv_rep where quest_pub_id = ihook.getColumnValue(row_ori,'Q_PUB_ID')
        and quest_ver_nr = ihook.getColumnValue(row_ori,'Q_VER_NR') and rep_seq = rep;
          row := t_row();
            ihook.setColumnValue(row, 'QUEST_VV_REP_ID', v_temp);
            ihook.setColumnValue(row, 'DEFLT_VAL_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Question Repetition', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;

          end if;
  end loop;
    hookoutput.actions    := actions;

  END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 -- insert into junk_debug values (sysdate, v_data_out);
 -- commit;
END;


PROCEDURE spSetDefltValNonEnum
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
  rowrel t_row;
  rows  t_rows;
  rows0 t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
 row_sel t_row;
 rep integer;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;
v_found boolean;
  v_mod_id number;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_mod_ver_nr number(4,2);
  v_disp_ord integer;
  v_add integer;
  v_rep integer;
  i integer := 0;
  v_temp number;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
 -- Get form and module ID


 select r.P_ITEM_ID, r.P_ITEM_VER_NR into v_frm_id, v_frm_Ver_nr from NCI_ADMIN_ITEM_REL_ALT_KEY k, NCI_ADMIN_ITEM_REL r where k.nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID')
 and k.nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR') and k.P_ITEM_ID = r.C_ITEM_ID and k.P_ITEM_VER_NR = r.C_ITEM_VER_NR and r.rel_typ_id = 61;

 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;

-- Tracker 1526 - do not allow to set non-enumerated default for enumerated questions
for cur in (select de.* from de, value_dom vd where de.item_id = ihook.getColumNValue(row_ori, 'C_ITEM_ID') and 
de.ver_nr =  ihook.getColumNValue(row_ori, 'C_ITEM_VER_NR') and vd.VAL_DOM_TYP_ID <> 18 and de.val_dom_item_id = vd.item_id
and de.val_dom_ver_nr = vd.ver_nr) loop
 raise_application_error(-20000,'You cannot set non-enumerated default for enumerated questions.');
end loop;


 if hookInput.invocationNumber = 0 then

   v_found := false;
   rows := t_rows();
   row := t_row();
      ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Next');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Set Default', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

     forms                  := t_forms();
    form1                  := t_form('Question Non-Enumerated Default Set (Hook)', 2,1);
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;
end if;
 if hookInput.invocationNumber = 1 then

forms              := hookInput.forms;
        form1              := forms(1);

        row_sel := form1.rowset.rowset(1);

   v_found := false;
   rows := t_rows();
   row := t_row();


   ihook.setColumnValue(row, 'Repetition', 'Question');
   ihook.setColumnValue(row, 'DO', 0);
ihook.setColumnValue(row, 'Current Default', ihook.getColumnValue(row_ori, 'DEFLT_VAL'));
ihook.setColumnValue(row, 'New Default', ihook.getColumnValue(row_sel, 'VAL'));

            rows.extend;
            rows(rows.last) := row;
   for cur in (Select rep_seq, val  from nci_quest_vv_rep where QUEST_PUB_ID=ihook.getColumNValue(row_ori, 'NCI_PUB_ID')  and quest_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR')) loop
   row := t_row();

    ihook.setColumnValue(row, 'Repetition', 'Repetition');
   ihook.setColumnValue(row, 'DO', cur.rep_seq);
 ihook.setColumnValue(row, 'Current Default', cur.val);
ihook.setColumnValue(row, 'New Default', ihook.getColumnValue(row_sel, 'VAL'));

            rows.extend;
            rows(rows.last) := row;
  -- raise_application_error (-20000, 'In here');

      v_found := true;
   end loop;

  -- if (v_found) then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Set Default');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Set', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
          	 showrowset := t_showablerowset (rows, 'Repetition', 4, 'multi');
       	 hookoutput.showrowset := showrowset;

 --  hookoutput.message := 'No repetition for this module';
 end if;
 if hookInput.invocationNumber = 2 then


        rows := t_rows();

      for i in 1..hookinput.selectedRowset.rowset.count loop

       row_sel := hookinput.selectedRowset.rowset(i);

        rep := ihook.getColumnValue(row_sel, 'DO');

        if (rep = 0) then -- main question default


          row := t_row();
          rows0 := t_rows();
           ihook.setColumnValue(row, 'NCI_PUB_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
           ihook.setColumnValue(row, 'NCI_VER_NR', ihook.getColumnValue(row_ori,'NCI_VER_NR'));
           ihook.setColumnValue(row, 'DEFLT_VAL', ihook.getColumnValue(row_sel,'New Default'));
  --   ihook.setColumnValue(row, 'QUEST_REF_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));


    rows0.extend;
            rows0(rows0.last) := row;
     -- raise_application_error(-20000,  ihook.getColumnValue(row_ori,'ITEM_ID'));
            action             := t_actionrowset(rows0, 'Questions (Base Object)', 2, 2,'update');
            actions.extend;
            actions(actions.last) := action;
        end if;
        if (rep>0) then
        select 	QUEST_VV_REP_ID into v_temp from nci_quest_vv_rep where quest_pub_id = ihook.getColumnValue(row_ori,'NCI_PUB_ID')
        and quest_ver_nr = ihook.getColumnValue(row_ori,'NCI_VER_NR') and rep_seq = rep;
          row := t_row();
            ihook.setColumnValue(row, 'QUEST_VV_REP_ID', v_temp);
            ihook.setColumnValue(row, 'VAL', ihook.getColumnValue(row_sel,'New Default'));
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Question Repetition', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;

          end if;
  end loop;
    hookoutput.actions    := actions;

  END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 -- insert into junk_debug values (sysdate, v_data_out);
 -- commit;
END;

PROCEDURE spDelDefltVal
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
   rowset            t_rowset;

 i integer;
v_found boolean;
  v_mod_id number;
  v_disp_ord integer;
  v_rep integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

            row_ori :=  hookInput.originalRowset.rowset(1);
 
  if (upper(hookinput.originalrowset.tablename) like '%REP%') then
 select r.P_ITEM_ID, r.P_ITEM_VER_NR into v_frm_id, v_frm_Ver_nr from NCI_ADMIN_ITEM_REL_ALT_KEY k, NCI_ADMIN_ITEM_REL r where k.nci_pub_id = ihook.getColumNValue(row_ori, 'QUEST_PUB_ID')
 and k.nci_ver_nr = ihook.getColumNValue(row_ori, 'QUEST_VER_NR') and k.P_ITEM_ID = r.C_ITEM_ID and k.P_ITEM_VER_NR = r.C_ITEM_VER_NR and r.rel_typ_id = 61;

 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
 else
 select r.P_ITEM_ID, r.P_ITEM_VER_NR into v_frm_id, v_frm_Ver_nr from NCI_ADMIN_ITEM_REL_ALT_KEY k, NCI_ADMIN_ITEM_REL r where k.nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID')
 and k.nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR') and k.P_ITEM_ID = r.C_ITEM_ID and k.P_ITEM_VER_NR = r.C_ITEM_VER_NR and r.rel_typ_id = 61;

 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
 end if;
 
        rows := t_rows();

        for i in 1..hookinput.originalRowset.rowset.count loop
            row_ori :=  hookInput.originalRowset.rowset(i);
           ihook.setColumnValue(row_ori, 'DEFLT_VAL_ID', '');
             ihook.setColumnValue(row_ori, 'DEFLT_VAL', '');
               ihook.setColumnValue(row_ori, 'VAL', '');
            rows.extend;
            rows(rows.last) := row_ori;
        end loop;

         if (upper(hookinput.originalrowset.tablename) like '%REP%') then
            action             := t_actionrowset(rows, 'Question Repetition', 2, 0,'update');
         else
            action             := t_actionrowset(rows, 'Questions (Base Object)', 2, 0,'update');
         end if;
         actions.extend;
         actions(actions.last) := action;

        hookoutput.actions    := actions;
        V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 END;

PROCEDURE spChngQuestText
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
  rowrel t_row;
  row_sel t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(4000);
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();

 select frm_item_id, frm_ver_nr into v_frm_id, v_frm_Ver_nr from VW_NCI_MODULE_DE where nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;

 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select Question Text');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Question Text', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

	    for cur in (select ref_id from ref r, obj_key ok where r.fld_delete= 0 and item_id = ihook.getColumNValue(row_ori, 'C_ITEM_ID')  and
        ver_nr = ihook.getColumNValue(row_ori, 'C_ITEM_VER_NR' ) and r.ref_typ_id = ok.obj_key_id and ok.obj_typ_id = 1 and upper(ok.obj_key_desc) like '%QUESTION TEXT%') loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'REF_ID', cur.ref_id);
		   rows.extend;
		   rows (rows.last) := row;

 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'References (for hook insert)', 2, 'single');
       	 hookoutput.showrowset := showrowset;
     end if;
 ELSE
            row_sel := hookinput.selectedRowset.rowset(1);

            select ref_desc into v_ref from ref where ref_id = ihook.getColumnValue(row_sel, 'REF_ID');

            ihook.setColumnValue(row_ori, 'ITEM_LONG_NM', v_ref);
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row_ori;

            action             := t_actionrowset(rows, 'Questions (Edit)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;


    hookoutput.actions    := actions;
    END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spChngQuestShortText
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
  rowrel t_row;
  row_sel t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(255);
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();

 select frm_item_id, frm_ver_nr into v_frm_id, v_frm_Ver_nr from VW_NCI_MODULE_DE where nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;

 if ( ihook.getColumNValue(row_ori, 'C_ITEM_ID') is null) then
 raise_application_error(-20000,'No CDE attached to this question.');
 end if;
 if hookInput.invocationNumber = 0 then
    ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select Question Short Name');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
      ANSWER                     := T_ANSWER(2, 2, 'Set to Default CDE Short Name');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
     QUESTION               := T_QUESTION('Question Short Name', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

	    for cur in (select nm_id from alt_nms a where a.fld_delete= 0 and item_id = ihook.getColumNValue(row_ori, 'C_ITEM_ID')  and
        ver_nr = ihook.getColumNValue(row_ori, 'C_ITEM_VER_NR' ) and upper(cntxt_nm_dn) <> upper(nm_desc) and nm_typ_id not in (select obj_key_id from obj_key where upper(obj_key_desc) = 'HISTORICAL_CDE_ID')
        order by cntxt_nm_dn, nm_typ_id) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'NM_ID', cur.nm_id);
		   rows.extend;
		   rows (rows.last) := row;

 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'Alternate Names', 2, 'single');
       	 hookoutput.showrowset := showrowset;
     end if;
 ELSE
 if (hookinput.answerid = 1 and hookinput.selectedRowset is not null) then

            row_sel := hookinput.selectedRowset.rowset(1);

            select nm_desc into v_ref from alt_nms where nm_id = ihook.getColumnValue(row_sel, 'NM_ID');
 elsif (hookinput.answerid = 2) then
        select item_long_nm into v_ref from admin_item where item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID') and ver_nr =ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR')  ;
 end if;

 if (v_ref is not null) then
            ihook.setColumnValue(row_ori, 'ITEM_NM', substr(v_ref,1,30));
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row_ori;

            action             := t_actionrowset(rows, 'Questions (Edit)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
               hookoutput.actions    := actions;

end if;

    END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spAddQuestion
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2,
    v_src in varchar2) -- v_src - D - Default cart, N - Named Cart
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
  rowsvv t_rows;
  rowsrep  t_rows;
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
  v_add integer := 0;
  i integer := 0;
  j integer;
  v_cart_nm varchar2(255);
  v_disp_ord integer;
  column  t_column;
  msg varchar2(4000);
    type t_item_id is table of admin_item.item_id%type;
    type t_ver_nr is table of admin_item.ver_nr%type;

    v_tab_item_id  t_item_id := t_item_id();
    v_tab_ver_nr  t_ver_nr := t_ver_nr();
rep integer;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori :=  hookInput.originalRowset.rowset(1);

    rows := t_rows();


 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a question to this module.');
 end if;

   if (hookinput.invocationNumber = 0 and v_src = 'N') then 
      nci_11179.getCartNameSelectionForm (hookOutput, v_user_id);
	end if; -- First invocation

    if (hookInput.invocationNumber = 0 and v_src = 'D')  then
        v_cart_nm := v_deflt_cart_nm;
    end if;
    if (hookinput.invocationnumber = 1 and v_src = 'N') then
        rows := t_rows();
          row_sel := hookInput.selectedRowset.rowset(1);
          v_cart_nm := ihook.getColumnValue(row_sel, 'CART_NM');
    end if;

    if ((hookInput.invocationNumber = 0 and v_src = 'D') or (hookinput.invocationnumber = 1 and v_src = 'N')) then
	    rows :=         t_rows();
		v_found := false;

	    for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id = 4 and cart_nm = v_cart_nm) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   iHook.setcolumnvalue (ROW, 'CNTCT_SECU_ID', v_user_id);
            iHook.setcolumnvalue (ROW, 'CART_NM', v_cart_nm);
	   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'User Cart', 2, 'multi');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Add');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 answer := t_answer(2, 2, 'Add All');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Add Question to Module', answers);
       	 hookOutput.question := question;
            hookOutput.message := 'Number of items in your cart: ' || rows.count;
      else
        hookoutput.message := 'Please add Data Elements to your cart.';
	   end if;
    end if;
 if ((hookInput.invocationNumber = 1 and v_src = 'D') or (hookinput.invocationnumber = 2 and v_src = 'N')) then

          select nvl(max(disp_ord)+1,0) into v_disp_ord from NCI_ADMIN_ITEM_REL_ALT_KEY where P_ITEM_ID =ihook.getColumnValue(row_ori,'C_ITEM_ID')  and
          P_ITEM_VER_NR = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and rel_typ_id = 63;
                        rep := ihook.getColumnValue(row_ori, 'REP_NO');

        if (hookinput.answerid = 1) then -- Selected CDEs
            for i in 1..hookInput.selectedRowset.rowset.count loop
                    row_sel := hookInput.selectedRowset.rowset(i);
                v_tab_item_id.extend();
                v_tab_ver_nr.extend();
                v_tab_item_id(v_tab_item_id.count) := ihook.getColumnValue(row_sel,'ITEM_ID');
                v_tab_ver_nr(v_tab_ver_nr.count) := ihook.getColumnValue(row_sel,'VER_NR');
                -- Add component Item id
                    for cur in (select c_item_id, c_item_ver_nr from nci_admin_item_rel where rel_typ_id = 65 and p_item_id = ihook.getColumnValue(row_sel,'ITEM_ID')
                    and p_item_ver_nr = ihook.getColumnValue(row_sel,'VER_NR') order by disp_ord) loop
                        v_tab_item_id.extend();
                        v_tab_ver_nr.extend();
                        v_tab_item_id(v_tab_item_id.count) := cur.c_item_id;
                        v_tab_ver_nr(v_tab_ver_nr.count) := cur.c_item_ver_nr;
                    end loop;
            end loop;
        end if;

        if (hookinput.answerid = 2) then -- Add CDEs from Cart
        for cur1 in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id = 4 ) loop
		        v_tab_item_id.extend();
                v_tab_ver_nr.extend();
                v_tab_item_id(v_tab_item_id.count) := cur1.item_id;
                v_tab_ver_nr(v_tab_ver_nr.count) := cur1.ver_nr;
                -- Add component Item id
                    for cur in (select c_item_id, c_item_ver_nr from nci_admin_item_rel where rel_typ_id = 65 and p_item_id = cur1.item_id
                    and p_item_ver_nr = cur1.ver_nr order by disp_ord) loop
                        v_tab_item_id.extend();
                        v_tab_ver_nr.extend();
                        v_tab_item_id(v_tab_item_id.count) := cur.c_item_id;
                        v_tab_ver_nr(v_tab_ver_nr.count) := cur.c_item_ver_nr;
                    end loop;
            end loop;
        end if;



          rows := t_rows();
          rowsvv := t_rows();
                        rowsrep := t_rows();
        --      for i in 1..hookInput.selectedRowset.rowset.count loop
          --          row_sel := hookInput.selectedRowset.rowset(i);
    --      raise_application_error(-20000, 'herere ' || v_tab_item_id.count);
              for i in 1..v_tab_item_id.count loop

                    for cur in (select ai.item_id, ai.ver_nr, ai.cntxt_item_id, ai.cntxt_ver_nr, item_long_nm item_long_nm, nvl(r.ref_desc, item_long_nm) QUEST_TEXT, item_nm
                    from admin_item ai, ref r where
                    ai.item_id = v_tab_item_id(i) and ai.ver_nr = v_tab_ver_nr(i) and ai.item_id = r.item_id (+) and ai.ver_nr = r.ver_nr (+)
                    and (upper(ai.admin_stus_nm_dn) not like '%RETIRED%' and upper(ai.regstr_stus_nm_dn) not like '%RETIRED%')
                    and r.ref_typ_id (+) = 80 ) loop
              --      and (ai.item_id, ai.ver_nr) not in (select c_item_id, c_item_ver_nr from nci_admin_item_rel_alt_key where p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
               --             p_item_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') and rel_typ_id = 63 )) loop
                        row := t_row();
             --   raise_application_error(-20000, 'herere ' || cur.item_id);

                        v_id := nci_11179.getItemId;
                        ihook.setColumnValue (row, 'NCI_PUB_ID', v_id);
                        ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                        ihook.setColumnValue (row, 'P_ITEM_ID', ihook.getColumnValue(row_ori,'C_ITEM_ID'));
                        ihook.setColumnValue (row, 'P_ITEM_VER_NR', ihook.getColumnValue(row_ori,'C_ITEM_VER_NR'));
                        ihook.setColumnValue (row, 'C_ITEM_ID', cur.item_id);
                        ihook.setColumnValue (row, 'C_ITEM_VER_NR', cur.ver_nr);
                        ihook.setColumnValue (row, 'CNTXT_CS_ITEM_ID', cur.cntxt_item_id);
                        ihook.setColumnValue (row, 'CNTXT_CS_VER_NR', cur.cntxt_ver_nr);
                        ihook.setColumnValue (row, 'ITEM_LONG_NM', cur.QUEST_TEXT );
                         ihook.setColumnValue (row, 'ITEM_NM', cur.ITEM_LONG_NM );
                        ihook.setColumnValue (row, 'EDIT_IND', 1 );
                        ihook.setColumnValue (row, 'REQ_IND', 0 );
                        ihook.setColumnValue (row, 'REL_TYP_ID', 63);
                        ihook.setColumnValue (row, 'DISP_ORD', v_disp_ord);
                        v_disp_ord := v_disp_ord + 1;

                        v_add := v_add + 1;
                        rows.extend;
                        rows(rows.last) := row;


                        if nvl(rep,0) > 0 then
                            spAddQuestionRepNew (rep, v_id, rowsrep);
                        end if;
                        j := 0;
                for cur1 in (select * from  VW_NCI_DE_PV where de_item_id = cur.item_id and de_ver_nr = cur.ver_nr and nvl(fld_delete,0) = 0 order by PERM_VAL_NM) loop
                  row := t_row();
                ihook.setColumnValue (row, 'Q_PUB_ID', v_id);
                ihook.setColumnValue (row, 'Q_VER_NR', 1);
                ihook.setColumnValue (row, 'VM_NM', cur1.item_nm);
                ihook.setColumnValue (row, 'VM_LNM', cur1.item_long_nm);
                ihook.setColumnValue (row, 'VM_DEF', cur1.item_desc);
                ihook.setColumnValue (row, 'VALUE', cur1.perm_val_nm);
                ihook.setColumnValue (row, 'MEAN_TXT', cur1.item_nm);
                ihook.setColumnValue (row, 'DESC_TXT', substr(cur1.item_desc,1,2000));
                ihook.setColumnValue (row, 'VAL_MEAN_ITEM_ID', cur1.NCI_VAL_MEAN_ITEM_ID);
                ihook.setColumnValue (row, 'VAL_MEAN_VER_NR', cur1.NCI_VAL_MEAN_VER_NR);
                v_itemid := nci_11179.getItemId;
                ihook.setColumnValue (row, 'NCI_PUB_ID', v_itemid);
                ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                ihook.setColumnValue (row, 'DISP_ORD', j);
                 rowsvv.extend;
                rowsvv(rowsvv.last) := row;
                j := j+ 1;
                end loop;
                 end loop;
   end loop;

--DESC_TXT
   -- raise_application_error(-20000, v_add);
        if (rows.count > 0) then
                        action := t_actionrowset(rows, 'Questions (Base Object)', 2,0,'insert');
                        actions.extend;
                        actions(actions.last) := action;
        end if;

    if (rowsvv.count > 0) then
    action := t_actionrowset(rowsvv, 'Question Valid Values (Hook)', 2,2,'insert');
    actions.extend;
    actions(actions.last) := action;
    end if;

       if (rowsrep.count > 0) then
        action             := t_actionrowset(rowsrep, 'Question Repetition', 2, 4,'insert');
            actions.extend;
            actions(actions.last) := action;
         end if;

  if ( rows.count > 0 ) then  hookoutput.actions := actions;

  -- Update form and module audit
    update admin_item set  LST_UPD_DT = sysdate, LST_UPD_USR_ID = v_user_id
    where ITEM_ID = ihook.getColumnValue(row_ori,'P_ITEM_ID') and VER_NR = ihook.getColumnValue(row_ori,'P_ITEM_VER_NR');
    commit;

     update NCI_ADMIN_ITEM_REL set LST_UPD_DT = sysdate, LST_UPD_USR_ID = v_user_id
                        where  C_ITEM_ID = ihook.getColumnValue(row_ori,'C_ITEM_ID')
                        AND C_ITEM_VER_NR=ihook.getColumnValue(row_ori,'C_ITEM_VER_NR')  and rel_typ_id = 61;
                        commit;
  end if;
    hookoutput.message := v_add || ' questions added.  CDE with Retired status are excluded from selection.';

--raise_application_error(-20000,hookoutput.message);
    end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 -- insert into junk_debug values (sysdate, v_data_out);
 -- commit;
END;

PROCEDURE spCopyModule
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2,
    v_src in varchar2) ---D Default cart ; N - Named cart
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

    rows := t_rows();
if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a module to this form.');
 end if;

   if (hookinput.invocationNumber = 0 and v_src = 'N') then 
      nci_11179.getCartNameSelectionForm (hookOutput, v_user_id);
	end if; -- First invocation

    if (hookInput.invocationNumber = 0 and v_src = 'D')  then
        v_cart_nm := v_deflt_cart_nm;
    end if;
    if (hookinput.invocationnumber = 1 and v_src = 'N') then
          row_sel := hookInput.selectedRowset.rowset(1);
          v_cart_nm := ihook.getColumnValue(row_sel, 'CART_NM');
    end if;

    if ((hookInput.invocationNumber = 0 and v_src = 'D') or (hookinput.invocationnumber = 1 and v_src = 'N')) then
	    rows :=         t_rows();
		v_found := false;

	    for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
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

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'User Cart', 2, 'single');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select Module');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select Module to Copy', answers);
       	 hookOutput.question := question;
     else
               hookoutput.message := 'Please add forms or modules to your cart.';

	   end if;

	end if;

 if ((hookInput.invocationNumber = 1 and v_src = 'D') or (hookinput.invocationnumber = 2 and v_src = 'N')) then
         v_mod_specified := false;
          row_sel := hookInput.selectedRowset.rowset(1);
          select admin_item_typ_id into v_item_typ from admin_item where  item_id = ihook.getColumnValue(row_sel,'ITEM_ID')
          and ver_nr = ihook.getColumnValue(row_sel,'VER_NR');
          if (v_item_typ = 54) then--- Form
            rows :=         t_rows();
		v_found := false;
	    for cur in (select c.item_id, c.ver_nr from VW_NCI_FORM_MODULE c where c.fld_delete= 0  and c.p_item_id = ihook.getColumnValue(row_sel,'ITEM_ID') and c.p_item_ver_nr =  ihook.getColumnValue(row_sel,'VER_NR') ) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
--raise_application_error(-20000, ihook.getColumnValue(row_sel,'ITEM_ID'));
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'Modules', 2, 'single');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select Module');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select Module to Copy', answers);
       	 hookOutput.question := question;
	   end if;
    else
        v_mod_specified := true;
    end if;
    end if;
   -- if (hookInput.invocationNumber = 2 or v_mod_specified = true) then -- copy module
 if (((hookInput.invocationNumber = 2 and v_src = 'D') or (hookinput.invocationnumber = 3 and v_src = 'N')) or v_mod_specified = true) then

	row_sel := hookInput.selectedRowset.rowset(1);
    nci_11179.spCopyModuleNCI (actions, ihook.getColumnValue(row_sel,'ITEM_ID'),ihook.getColumnValue(row_sel,'VER_NR'),
    ihook.getColumnValue(row_sel,'P_ITEM_ID'), ihook.getColumnValue(row_sel,'P_ITEM_VER_NR'), ihook.getColumnValue(row_ori,'ITEM_ID'), ihook.getColumnValue(row_ori,'VER_NR'), -1,'C',
    ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID'),ihook.getColumnValue(row_ori, 'CNTXT_VER_NR'), v_user_id);


    hookoutput.actions := actions;
    hookoutput.message := 'Module copied successfully.';
    --hookoutput.message := v_add || ' concepts added.';
    end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--  nci_util.debugHook('GENERAL',v_data_out);

END;


PROCEDURE spAddQuestionNoDE
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
  rowsvv t_rows;
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
  v_add integer := 0;
  i integer := 0;
  v_disp_ord integer;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);

    rows := t_rows();


 if (nci_form_mgmt.isUserAuth(ihook.getColumnValue(row_ori, 'P_ITEM_ID'), ihook.getColumnValue(row_ori,'P_ITEM_VER_NR'), v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to add a question to this module.');
 end if;

    if hookInput.invocationNumber = 0 then

	    rows :=         t_rows();
		v_found := false;

	    for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id = 4 ) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, 'User Cart', 2, 'multi');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select CDE to Add');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Add Question to Module', answers);
       	 hookOutput.question := question;
	   end if;

	elsif hookInput.invocationNumber = 1 then
		  if hookInput.answerId = 1 then -- Add Question

          select nvl(max(disp_ord)+1,0) into v_disp_ord from NCI_ADMIN_ITEM_REL_ALT_KEY where P_ITEM_ID =ihook.getColumnValue(row_ori,'C_ITEM_ID')  and
          P_ITEM_VER_NR = ihook.getColumnValue(row_ori,'C_ITEM_VER_NR') and rel_typ_id = 63;

          rows := t_rows();
          rowsvv := t_rows();
              for i in 1..hookInput.selectedRowset.rowset.count loop
                    row_sel := hookInput.selectedRowset.rowset(i);
                    for cur in (select ai.item_id, ai.ver_nr, ai.cntxt_item_id, ai.cntxt_ver_nr, item_long_nm item_long_nm, nvl(r.ref_desc, item_long_nm) QUEST_TEXT from admin_item ai, ref r where
                    ai.item_id = ihook.getColumnValue(row_sel,'ITEM_ID') and ai.ver_nr = ihook.getColumnValue(row_sel,'VER_NR') and ai.item_id = r.item_id (+) and ai.ver_nr = r.ver_nr (+)
                    and r.ref_typ_id (+) = 80
                    and (ai.item_id, ai.ver_nr) not in (select c_item_id, c_item_ver_nr from nci_admin_item_rel_alt_key where p_item_id = ihook.getColumnValue(row_ori,'C_ITEM_ID') and
                            p_item_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') and rel_typ_id = 63 )) loop
                        row := t_row();

                        v_id := nci_11179.getItemId;
                        ihook.setColumnValue (row, 'NCI_PUB_ID', v_id);
                        ihook.setColumnValue (row, 'NCI_VER_NR', 1);
                        ihook.setColumnValue (row, 'P_ITEM_ID', ihook.getColumnValue(row_ori,'C_ITEM_ID'));
                        ihook.setColumnValue (row, 'P_ITEM_VER_NR', ihook.getColumnValue(row_ori,'C_ITEM_VER_NR'));
                        ihook.setColumnValue (row, 'C_ITEM_ID', cur.item_id);
                        ihook.setColumnValue (row, 'C_ITEM_VER_NR', cur.ver_nr);
                        ihook.setColumnValue (row, 'CNTXT_CS_ITEM_ID', cur.cntxt_item_id);
                        ihook.setColumnValue (row, 'CNTXT_CS_VER_NR', cur.cntxt_ver_nr);
                        ihook.setColumnValue (row, 'ITEM_LONG_NM', cur.QUEST_TEXT );
                        ihook.setColumnValue (row, 'EDIT_IND', 1 );
                        ihook.setColumnValue (row, 'REQ_IND', 0 );

                        ihook.setColumnValue (row, 'REL_TYP_ID', 63);
                        ihook.setColumnValue (row, 'DISP_ORD', v_disp_ord);
                        v_disp_ord := v_disp_ord + 1;

                        v_add := v_add + 1;
                        rows.extend;
                        rows(rows.last) := row;


                for cur1 in (select PERM_VAL_NM, PERM_VAL_DESC_TXT, item_nm, item_long_nm from  VW_NCI_DE_PV where de_item_id = cur.item_id and de_ver_nr = cur.ver_nr) loop
                  row := t_row();
                ihook.setColumnValue (row, 'Q_PUB_ID', v_id);
                ihook.setColumnValue (row, 'Q_VER_NR', 1);
                ihook.setColumnValue (row, 'VM_NM', cur1.item_nm);
                ihook.setColumnValue (row, 'VM_LNM', cur1.item_long_nm);
                ihook.setColumnValue (row, 'VM_DEF', cur1.item_nm);
                ihook.setColumnValue (row, 'VALUE', cur1.perm_val_nm);
                ihook.setColumnValue (row, 'MEAN_TXT', cur1.item_long_nm);
                v_itemid := nci_11179.getItemId;
                ihook.setColumnValue (row, 'NCI_PUB_ID', v_itemid);
                ihook.setColumnValue (row, 'NCI_VER_NR', 1);

                 rowsvv.extend;
                rowsvv(rowsvv.last) := row;
                v_found := true;
              --  raise_application_error(-20000, 'Inside');
                end loop;
                 end loop;
   end loop;

--DESC_TXT
   -- raise_application_error(-20000, v_add);
        if (v_add > 0) then
                        action := t_actionrowset(rows, 'Questions (Base Object)', 2,0,'insert');
                        actions.extend;
                        actions(actions.last) := action;

                        -- Update form and module audit
                        update admin_item set  LST_UPD_DT = sysdate, LST_UPD_USR_ID = v_user_id
                        where ITEM_ID = ihook.getColumnValue(row_ori,'P_ITEM_ID') and VER_NR = ihook.getColumnValue(row_ori,'P_ITEM_VER_NR');
                        commit;

                        update NCI_ADMIN_ITEM_REL set LST_UPD_DT = sysdate, LST_UPD_USR_ID = v_user_id
                        where  C_ITEM_ID = ihook.getColumnValue(row_ori,'C_ITEM_ID')
                        AND C_ITEM_VER_NR=ihook.getColumnValue(row_ori,'C_ITEM_VER_NR')  and rel_typ_id = 61;
                        commit;

        end if;

    if (v_found) then
    action := t_actionrowset(rowsvv, 'Question Valid Values (Hook)', 2,2,'insert');
    actions.extend;
    actions(actions.last) := action;
    end if;

    hookoutput.actions := actions;
    hookoutput.message := v_add || ' questions added.';
    end if;
end if;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  --insert into junk_debug values (sysdate, v_data_out);
  --commit;
END;



PROCEDURE spChngQuestTextVV (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(255);
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
  v_vm_id  number;
  v_vm_ver_nr number(4,2);
  v_vm_cncpts  varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();

 /*select frm_item_id, frm_ver_nr into v_frm_id, v_frm_Ver_nr from VW_NCI_MODULE_DE where nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
 */
 select frm_item_id, frm_ver_nr into v_frm_id, v_frm_ver_nr from vw_nci_module_de where
nci_pub_id = ihook.getColumnValue(row_ori, 'Q_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any valid value on this form.');
 end if;

 if hookInput.invocationNumber = 0 then

select NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR, CNCPT_CONCAT into v_vm_id, v_vm_ver_nr , v_vm_cncpts from VW_NCI_DE_PV pv,
        NCI_ADMIN_ITEM_REL_ALT_KEY q where pv.DE_ITEM_ID = q.C_ITEM_id and pv.DE_VER_NR = q.c_ITEM_VER_NR and q.NCI_PUB_ID = ihook.getColumnValue(row_ori,'Q_PUB_ID')
        and q.NCI_VER_NR= ihook.getColumnValue(row_ori, 'Q_VER_NR') and pv.PERM_VAL_NM = ihook.getColumnValue(row_ori, 'VALUE');
        
	    for cur in (select r.*, ok.obj_key_desc from alt_nms r, obj_key ok where r.fld_delete= 0 and ok.obj_key_id = r.nm_typ_id and
        item_id = v_vm_id and ver_nr = v_vm_ver_nr) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'Type', 'Alternate Name');
           iHook.setcolumnvalue (ROW, 'Name', cur.NM_DESC);
           iHook.setcolumnvalue (ROW, 'Context', cur.CNTXT_NM_DN);
           iHook.setcolumnvalue (ROW, 'Name Type', cur.OBJ_KEY_DESC);
           
		   rows.extend;
		   rows (rows.last) := row;

 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;
        /*
        for cur in (select r.*, ok.obj_key_desc from alt_nms r, obj_key ok where r.fld_delete= 0 and ok.obj_key_id = r.nm_typ_id and
        (item_id, ver_nr) in (select item_id, ver_nr from admin_item where admin_item_typ_id = 49 and item_long_nm = v_vm_cncpts)) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'Type', 'Concept Alternate Name');
           iHook.setcolumnvalue (ROW, 'Name', cur.NM_DESC);
           iHook.setcolumnvalue (ROW, 'Context', cur.CNTXT_NM_DN);
           iHook.setcolumnvalue (ROW, 'Name Type', cur.OBJ_KEY_DESC);
           
		   rows.extend;
		   rows (rows.last) := row;

 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;
        
*/
	  if (v_found) then
      ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select as Form Value Meaning Text');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
   --  ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(2, 2, 'Reset to Default Form Value Meaning Text');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Modify Form Value Meaning Text', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
       	 showrowset := t_showablerowset (rows, 'Alternate Names To Select', 4, 'single');
       	 hookoutput.showrowset := showrowset;
        else
        hookoutput.message := 'No alternate names found.';
     end if;
 ELSE

            if (hookinput.answerId = 1) then
            row_sel := hookinput.selectedRowset.rowset(1);
            v_ref := ihook.getColumnValue(row_sel, 'Name');
        --    select nm_desc into v_ref from alt_nms where nm_id = ihook.getColumnValue(row_sel, 'NM_ID');
            else   -- 2 means set default

         select item_nm into v_ref from admin_item where item_id = ihook.getColumnValue(row_ori, 'VAL_MEAN_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VAL_MEAN_VER_NR');
/*
           select pv.item_nm into v_ref from VW_NCI_DE_PV pv,
        NCI_ADMIN_ITEM_REL_ALT_KEY q where pv.DE_ITEM_ID = q.C_ITEM_id and pv.DE_VER_NR = q.c_ITEM_VER_NR and q.NCI_PUB_ID = ihook.getColumnValue(row_ori,'Q_PUB_ID')
        and q.NCI_VER_NR= ihook.getColumnValue(row_ori, 'Q_VER_NR') and pv.PERM_VAL_NM = ihook.getColumnValue(row_ori, 'VALUE');*/
           -- select nm_desc into v_ref from alt_nms where nm_id = ihook.getColumnValue(row_sel, 'NM_ID');

            end if;
            row := t_row();
            
            ihook.setColumnValue(row, 'NCI_PUB_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
            ihook.setColumnValue(row, 'NCI_VER_NR', ihook.getColumnValue(row_ori,'NCI_VER_NR'));

            ihook.setColumnValue(row, 'MEAN_TXT', v_ref);

            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Question Valid Values (Hook)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
     hookoutput.actions    := actions;
    END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spChngQuestDefVV (    v_data_in IN CLOB,    v_data_out OUT CLOB,    v_user_id in varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  rowform t_row;
v_found boolean;
  v_module_id integer;
  v_disp_ord integer;
  v_frm_id number;
  v_frm_ver_nr number(4,2);
  v_ref varchar2(255);
  v_add integer;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();

 /*select frm_item_id, frm_ver_nr into v_frm_id, v_frm_Ver_nr from VW_NCI_MODULE_DE where nci_pub_id = ihook.getColumNValue(row_ori, 'NCI_PUB_ID') and nci_ver_nr = ihook.getColumNValue(row_ori, 'NCI_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any question in this form.');
 end if;
 */
  select frm_item_id, frm_ver_nr into v_frm_id, v_frm_ver_nr from vw_nci_module_de where
nci_pub_id = ihook.getColumnValue(row_ori, 'Q_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR');
 if (nci_form_mgmt.isUserAuth(v_frm_id, v_frm_ver_nr, v_user_id) = false) then
 raise_application_error(-20000,'You are not authorized to edit any valid value on this form.');
 end if;
 if hookInput.invocationNumber = 0 then


	    for cur in (select def_id from alt_def r where r.fld_delete= 0 and
        (item_id, ver_nr) in (select NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR from VW_NCI_DE_PV pv,
        NCI_ADMIN_ITEM_REL_ALT_KEY q where pv.DE_ITEM_ID = q.C_ITEM_id and pv.DE_VER_NR = q.c_ITEM_VER_NR and q.NCI_PUB_ID = ihook.getColumnValue(row_ori,'Q_PUB_ID')
        and q.NCI_VER_NR= ihook.getColumnValue(row_ori, 'Q_VER_NR') and pv.PERM_VAL_NM = ihook.getColumnValue(row_ori, 'VALUE'))) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'DEF_ID', cur.DEF_id);
		   rows.extend;
		   rows (rows.last) := row;

 --raise_application_error(-20000,ihook.getColumNValue(row_ori, 'C_ITEM_ID'));
   v_found := true;
	    end loop;

	  if (v_found) then
      ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select as Form Value Meaning Desc.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
     ANSWER                     := T_ANSWER(2, 2, 'Reset to Default Form Value Meaning Desc.');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Modify Form Value Meaning Desc.', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
       	 showrowset := t_showablerowset (rows, 'Alternate Definitions (All Types for Hook)', 2, 'single');
       	 hookoutput.showrowset := showrowset;
        else
        hookoutput.message := 'No alternate definitions found.';
     end if;
 ELSE

        if (hookinput.answerId = 1) then
             row_sel := hookinput.selectedRowset.rowset(1);
        select def_desc into v_ref from alt_def where def_id = ihook.getColumnValue(row_sel, 'DEF_ID');

        else -- if 2 then
         select item_desc into v_ref from admin_item where item_id = ihook.getColumnValue(row_ori, 'VAL_MEAN_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VAL_MEAN_VER_NR');

        end if;
        row := t_row();
           ihook.setColumnValue(row, 'NCI_PUB_ID', ihook.getColumnValue(row_ori,'NCI_PUB_ID'));
            ihook.setColumnValue(row, 'NCI_VER_NR', ihook.getColumnValue(row_ori,'NCI_VER_NR'));

           
            ihook.setColumnValue(row, 'DESC_TXT', v_ref);
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Question Valid Values (Hook)', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;


    hookoutput.actions    := actions;
    END IF;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spQuestRemoveDE ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2) as
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row_ori  t_row;
    row  t_row;
    rows t_rows;
    v_item_id  number;
    v_ver_nr  number(4,2);
begin
    -- Standard header
    hookInput                    := Ihook.gethookinput (v_data_in);
    hookOutput.invocationnumber  := hookInput.invocationnumber;
    hookOutput.originalrowset    := hookInput.originalrowset;

    -- Get the selected row
    row_ori :=  hookInput.originalRowset.rowset(1);

    -- if no DE already, give an error message
    if (ihook.getColumnValue(row_ori, 'C_ITEM_ID') is null) then
        raise_application_error(-20000,'No CDE attached..');
        return;
    end if;

      select p_item_id, p_item_ver_nr into v_item_id, v_ver_nr from nci_admin_item_rel where rel_typ_id = 61 and
       c_item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and c_item_ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');
--  raise_application_error(-20000, v_ver_nr);
      
    -- Check if user is authorized to edit
    if (isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;

   ihook.setColumnValue(row_ori,'C_ITEM_ID','');
   ihook.setColumnValue(row_ori,'C_ITEM_VER_NR','');

    rows := t_rows();    rows.extend;    rows(rows.last) := row_ori;
    action := t_actionrowset(rows, 'Questions (Base Object)', 2,2,'update');
        actions.extend;
        actions(actions.last) := action;


        hookoutput.message := 'CDE removed.' ;
        hookoutput.actions := actions;
            V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

--insert into junk_debug (id, test) values (sysdate, v_data_out);
--commit;

end;

end;
/
