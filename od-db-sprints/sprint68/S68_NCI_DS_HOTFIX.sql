create or replace PACKAGE            nci_ds AS
  procedure spDSRun ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spVMMatch ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_typ in varchar2); -- v_typ - R - Restricted, U - Unrestricted, F - Fuzzzzy
  procedure spVMMatch49 ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_typ in varchar2, v_pref in varchar2); -- v_pref - V - VM only, C - Concept only, A - All
  procedure spVMMatchDynmc ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_typ in varchar2, v_pref in varchar2, v_ext in varchar2);
 procedure VMMatchSub ( v_hdr_id in number,  v_entty_nm in varchar2, v_entty_nm_with_space  in varchar2, v_typ in varchar2);
 procedure VMMatchSub49 ( v_hdr_id in number,  v_entty_nm in varchar2, v_entty_nm_with_space  in varchar2, v_typ in varchar2, v_pref in varchar2);
 procedure VMMatchFlow ( v_hdr_id in number,  v_entty_nm in varchar2, v_entty_nm_with_space  in varchar2, v_typ in varchar2, v_pref in varchar2, v_ext in varchar2);
 procedure VMMatchSubDynmcSQL ( v_hdr_id in number,  v_entty_nm in varchar2, v_entty_nm_with_space  in varchar2, v_typ in varchar2, v_pref in varchar2, v_ext in varchar2);
 procedure DECMatchSub ( v_hdr_id in number,  v_entty_nm in varchar2, v_entty_nm_with_space  in varchar2, v_typ in varchar2, row_ori in t_row);
  procedure setPrefCDE ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
    procedure setPrefCDEQuest ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure setPrefVM ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
   procedure spDECMatch ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
   procedure spVMMatchTermVal ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);

procedure spDSMatchNonEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2, v_suffix in varchar2);
procedure setPrefDEC ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spDSMatchEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2, v_suffix in varchar2, v_pv_flt_str in varchar2, v_mode in varchar2);
procedure spPostCDEMatch (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spDSRunPVVM(v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_mode varchar2);
procedure spSetPVExclusion (v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_pv_ind varchar2);
procedure spResetPVExclusion (v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_pv_ind varchar2);
function getPVFilterString (v_hdr_id in number) return varchar2;
function getPVExclusionList (v_hdr_id in number) return varchar2;
procedure spDSHDRPostHook (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spDSPostImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
function getDSSysMsg (v_hdr_id in number, v_op in varchar2) return varchar2;
procedure spDSPVVMPostImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spDSDelete (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
function isUserAuth(v_hdr_id in number, v_user_id in varchar2) return boolean;
function getLastDSRun (v_hdr_id in number) return varchar2;
procedure spDSSubPVVMDynmcSQL(v_hdr_id in number, v_mtch_typ in varchar2, v_entty_nm in varchar2, v_sel_word in varchar2, v_mtch_min_len in number, v_flt_str in varchar2, v_pv_cnt in number, v_src_dtl in varchar2, v_pv_filter in varchar2, v_mtch_pcnt in number);
END;
/
create or replace PACKAGE BODY            nci_ds AS
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
--  v_reg_str varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}';
--  v_reg_str_adv varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}|\s';
v_reg_str_adv varchar2(255) := '[^A-Za-z0-9]';
v_reg_str varchar2(255) := '[^ A-Za-z0-9]' ;
--
v_mtch_min_len integer := 3;
  
procedure spVMMatch ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_typ in varchar2)

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
   
   nci_util.debugHook('GENERAL', v_data_in);
  --  v_reg_str := '\(|\)|\;|\-|\_|\|';
    rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
 
        row_ori := hookInput.originalRowset.rowset(i);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
    --    v_entty_nm := regexp_replace(upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM'))),'\(|\)|\;|\-|\_','');
      v_entty_nm := regexp_replace(upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM'))),v_reg_str_adv,'');
        v_entty_nm_with_space := upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM')));
    --raise_application_error(-20000,v_minlen);
     delete from nci_ds_rslt where hdr_id =v_hdr_id ;
    commit;
--raise_application_error(-20000,'Test' || ihook.getColumnValue(row_ori,'MATCH_TYP'));
  if (ihook.getColumnValue(row_ori,'MTCH_TYP_NM') = 'VM') then
      VMMatchSub(v_hdr_id, v_entty_nm,v_entty_nm_with_space,v_typ);
    elsif (ihook.getColumnValue(row_ori,'MTCH_TYP_NM') = 'DEC') then
      DECMatchSub(v_hdr_id, v_entty_nm,v_entty_nm_with_space,v_typ,row_ori);
    end if;
   select count(*) into v_temp from nci_ds_rslt where hdr_id = v_hdr_id     ;
  if (v_temp = 1) then 
  update nci_ds_hdr set (NUM_CDE_MTCH, CDE_ITEM_ID, CDE_VER_NR, LST_UPD_USR_ID, PREF_CNCPT_CONCAT, PREF_CNCPT_CONCAT_NM, 	VM_MTCH_ITEM_TYP) 
  = (select 1, item_id, ver_nr , v_user_id, item_id,null, 'ID' from nci_ds_rslt where hdr_id = v_hdr_id)
  where hdr_id = v_hdr_id;
  else
  update nci_ds_hdr set NUM_CDE_MTCH = v_temp, num_dec_mtch = v_temp
  where hdr_id = v_hdr_id;
  end if;
  commit;
  
end loop;
  
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  
end;

procedure VMMatchSub ( v_hdr_id in number,  v_entty_nm in varchar2, v_entty_nm_with_space  in varchar2, v_typ in varchar2) AS
v_minlen integer;
v_cnt integer := 0;
v_cur_word  varchar2(4000);
v_sel_word varchar2(4000);
j integer;
v_word_cnt integer;
begin
    
       --  raise_application_error(-20000, v_entty_nm);
         
  v_minlen := nci_11179.getMinWordLen(v_entty_nm_with_space);
  -- sp48 jira 2550
if (v_typ = 'V') then --vm match only, no concepts
    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '1. VM Exact Match' from 
                    MVW_VAL_MEAN where MTCH_TERM_ADV = v_entty_nm ;
                    
                    --and admin_item_typ_id = 53;
          --          commit;
    --
    -- Vm Alt Name Exact Match
    v_cnt := SQL%ROWCOUNT;
    commit;
    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '4. VM Like Match' from 
                    MVW_VAL_MEAN where ((MTCH_TERM_ADV like '%' || v_entty_nm || '%' )  or
                    (v_entty_nm like '%' || MTCH_TERM_ADV || '%' and length(mtch_term) >= v_minlen)) and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt); 
    v_cnt := SQL%ROWCOUNT;
    commit;

    v_word_cnt := nci_11179.getwordcount(v_entty_nm_with_space);
    v_sel_word := 'x';
 
    for j in 1..v_word_cnt loop
        v_cur_word:= nci_11179.getWord(v_entty_nm_with_space,j, v_word_cnt);
        --raise_application_Error(-20000,length(v_sel_word));
        if (length(v_cur_word) > length(v_sel_word)) then
            v_Sel_word := v_cur_Word;
        end if;
    end loop;
 
    v_sel_word := regexp_replace(upper(v_sel_word),v_reg_str_adv,'');
 --raise_application_error(-20000, 'Hre' || v_sel_word);
 
    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '7. VM Like Match Largest word' from 
                    MVW_VAL_MEAN where ((MTCH_TERM_ADV like '%' || v_sel_word || '%' )  or
                    (v_sel_word like '%' || MTCH_TERM_ADV || '%'))  and length(mtch_term_adv) >= length(v_sel_word) and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
     commit;
elsif (v_typ= 'C') then -- concept match only, no vms
    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '2. Concept Exact Match' from 
                    vw_cncpt where MTCH_TERM_ADV = v_entty_nm and CNTXT_NM_DN = 'NCIP'
                    and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         --           commit;
    v_cnt := v_cnt + SQL%ROWCOUNT;
    
                          insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '5. Concept Like Match' from 
                    vw_cncpt where MTCH_TERM_ADV  like '%' ||  v_entty_nm || '%' 
                     and CNTXT_NM_DN = 'NCIP'  and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
    v_cnt := v_cnt + SQL%ROWCOUNT;
    commit;
                       insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '5. Concept Like Match' from 
                    vw_cncpt where 
                     v_entty_nm like '%' || MTCH_TERM_ADV || '%' and length(item_nm) >= v_minlen and CNTXT_NM_DN = 'NCIP' 
                      and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         
    v_cnt := v_cnt + SQL%ROWCOUNT;
         commit;

    v_word_cnt := nci_11179.getwordcount(v_entty_nm_with_space);
 v_sel_word := 'x';
 
 for j in 1..v_word_cnt loop
 v_cur_word:= nci_11179.getWord(v_entty_nm_with_space,j, v_word_cnt);
 --raise_application_Error(-20000,length(v_sel_word));
 if (length(v_cur_word) > length(v_sel_word)) then
    v_Sel_word := v_cur_Word;
    end if;
 end loop;
 
 v_sel_word := regexp_replace(upper(v_sel_word),v_reg_str_adv,'');
 --raise_application_error(-20000, 'Hre' || v_sel_word);
 insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '8. Concept Like Match Largest Word' from 
                    vw_cncpt where MTCH_TERM_ADV  like '%' ||  v_sel_word || '%' 
                     and CNTXT_NM_DN = 'NCIP'  and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    commit;
    v_cnt := v_cnt + SQL%ROWCOUNT;
    
                       insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '8. Concept Like Match Largest Word' from 
                    vw_cncpt where 
                     v_sel_word like '%' || MTCH_TERM_ADV || '%' and length(item_nm) >= v_minlen and CNTXT_NM_DN = 'NCIP' 
                      and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         
         commit;
else

   insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '1. VM Exact Match' from 
                    MVW_VAL_MEAN where MTCH_TERM_ADV = v_entty_nm ;
                    
                    --and admin_item_typ_id = 53;
          --          commit;
    --
    -- Vm Alt Name Exact Match
    v_cnt := SQL%ROWCOUNT;
    commit;
        insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '2. Concept Exact Match' from 
                    vw_cncpt where MTCH_TERM_ADV = v_entty_nm and CNTXT_NM_DN = 'NCIP'
                    and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         --           commit;
    v_cnt := v_cnt + SQL%ROWCOUNT;
    commit;
        insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , c.item_id, c.ver_nr, '3. Synonym Exact Match' from 
                    vw_cncpt c where (SYN_MTCH_TERM like v_entty_nm || ' |%'
                    or SYN_MTCH_TERM like '%| ' ||  v_entty_nm  or SYN_MTCH_TERM like '%| '|| v_entty_nm || ' |%')  and (v_hdr_id, c.item_id, c.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         --           commit; 
    v_cnt := v_cnt + SQL%ROWCOUNT;
  commit;
    if (v_cnt > 0 and v_typ = 'R') then
    return;
    end if;
     
     insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '4. VM Like Match' from 
                    MVW_VAL_MEAN where ((MTCH_TERM_ADV like '%' || v_entty_nm || '%' )  or
                    (v_entty_nm like '%' || MTCH_TERM_ADV || '%' and length(mtch_term) >= v_minlen)) and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt); 
    v_cnt := SQL%ROWCOUNT;
 commit;
                      insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '5. Concept Like Match' from 
                    vw_cncpt where MTCH_TERM_ADV  like '%' ||  v_entty_nm || '%' 
                     and CNTXT_NM_DN = 'NCIP'  and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
    v_cnt := v_cnt + SQL%ROWCOUNT;
    commit;
                       insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '5. Concept Like Match' from 
                    vw_cncpt where 
                     v_entty_nm like '%' || MTCH_TERM_ADV || '%' and length(item_nm) >= v_minlen and CNTXT_NM_DN = 'NCIP' 
                      and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         
    v_cnt := v_cnt + SQL%ROWCOUNT;
         commit;
         
        insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , c.item_id, c.ver_nr, '6. Synonym Like Match' from 
                    vw_cncpt c where SYN_MTCH_TERM like '%' ||  v_entty_nm || '%'   and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
    v_cnt := v_cnt + SQL%ROWCOUNT;
 commit;
    if (v_cnt > 0 and v_typ = 'R') then
    return;
    end if;
 -- Third pass longest word exact match
 
 v_word_cnt := nci_11179.getwordcount(v_entty_nm_with_space);
 v_sel_word := 'x';
 
 for j in 1..v_word_cnt loop
 v_cur_word:= nci_11179.getWord(v_entty_nm_with_space,j, v_word_cnt);
 --raise_application_Error(-20000,length(v_sel_word));
 if (length(v_cur_word) > length(v_sel_word)) then
    v_Sel_word := v_cur_Word;
    end if;
 end loop;
 
 v_sel_word := regexp_replace(upper(v_sel_word),v_reg_str_adv,'');
 --raise_application_error(-20000, 'Hre' || v_sel_word);
 
     insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '7. VM Like Match Largest word' from 
                    MVW_VAL_MEAN where ((MTCH_TERM_ADV like '%' || v_sel_word || '%' )  or
                    (v_sel_word like '%' || MTCH_TERM_ADV || '%'))  and length(mtch_term_adv) >= length(v_sel_word) and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
     commit;               
           insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '8. Concept Like Match Largest Word' from 
                    vw_cncpt where MTCH_TERM_ADV  like '%' ||  v_sel_word || '%' 
                     and CNTXT_NM_DN = 'NCIP'  and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    commit;
    v_cnt := v_cnt + SQL%ROWCOUNT;
    
                       insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '8. Concept Like Match Largest Word' from 
                    vw_cncpt where 
                     v_sel_word like '%' || MTCH_TERM_ADV || '%' and length(item_nm) >= v_minlen and CNTXT_NM_DN = 'NCIP' 
                      and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         
         commit;
    v_cnt := v_cnt + SQL%ROWCOUNT;
         
         
        insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , c.item_id, c.ver_nr, '9. Synonym Like Match Largest Word' from 
                    vw_cncpt c where SYN_MTCH_TERM like '%' ||  v_sel_word || '%' and  length(syn_mtch_term) >= length(v_sel_word)  and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    commit; 
    v_cnt := v_cnt + SQL%ROWCOUNT;

 
    end if;
    end;

  procedure spVMMatchTermVal ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2) as
  hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
     question    t_question;
    answer     t_answer;
    answers     t_answers;
    showrowset	t_showablerowset;
    forms t_forms;
    form1 t_form;
    rowform t_row;
    v_evs_src integer;
    row_ori t_row;
    v_hdr_id number;
      v_entty_nm varchar2(255);
    v_entty_nm_with_space varchar2(255);
    v_ext varchar2(255);
    v_temp integer;
     row t_row;
   rows t_rows;
   row_sel t_row;
  begin
  
    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
     row_ori :=  hookInput.originalRowset.rowset(1);
   v_hdr_id := ihook.getColumNValue(row_ori,'HDR_ID');
    if hookInput.invocationNumber = 0 then  -- If first invocation, prompt for version number

        ANSWERS                    := T_ANSWERS();
        ANSWER                     := T_ANSWER(1, 1, 'Run Match' );
        ANSWERS.EXTEND;
        ANSWERS(ANSWERS.LAST) := ANSWER;
        QUESTION               := T_QUESTION('Select options to run.'  , ANSWERS);
        HOOKOUTPUT.QUESTION    := QUESTION;
        row := t_row();
        rows := t_rows();
        ihook.setColumnValue(row,'OBJ_TYP_ID',23);
         rows.extend;
		   rows (rows.last) := row;
         	 showrowset := t_showablerowset (rows, 'Object Key (Base Object)', 2, 'multi');
       	 hookoutput.showrowset := showrowset;
         
     /*   forms                  := t_forms();
        form1                  := t_form('Front-end for VM Match', 2,1);
        forms.extend;
        forms(forms.last) := form1;
        hookOutput.forms := forms; */
        
        end if;
        
         if hookInput.invocationNumber = 1 then  -- If second invocation
--raise_application_error(-20000,hookInput.selectedRowset.rowset.count);
-- create loop for v_data_in
            for j in 1..hookinput.originalrowset.rowset.count loop
                row_ori :=  hookInput.originalRowset.rowset(j);
                v_hdr_id := ihook.getColumNValue(row_ori,'HDR_ID');
         --   raise_application_error(-20000,hookinput.originalrowset.rowset.count);
                delete from nci_ds_rslt where hdr_id = v_hdr_id;
                commit;
                v_entty_nm := regexp_replace(upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM'))),v_reg_str_adv,'');
                v_entty_nm_with_space := upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM')));
--    
        --        VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'V', v_ext);
      --  VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'C', v_ext);
      --     VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'S', v_ext);
   
       --      VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'V', v_ext);
      --  VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'C', v_ext);
      --     VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'S', v_ext);
   
       -- select count(*) into v_temp from nci_ds_rslt where hdr_id = v_hdr_id;
      --  if (v_temp > 0) then
      
    /*  for i in 1..hookInput.selectedRowset.rowset.count loop
          row_sel := hookInput.selectedRowset.rowset(i);
          v_evs_src := ihook.getColumnValue(row_sel,'OBJ_KEY_ID');
          
        update nci_ds_rslt r set (evs_src_id, xmap_cd, xmap_desc) = (select v_evs_src, max(xmap_cd), max(xmap_desc) from nci_admin_item_xmap x where evs_src_id = v_evs_src and 
        x.item_id = r.item_id and x.ver_nr = r.ver_nr and r.hdr_id = v_hdr_id and x.pref_ind = 1 group by x.item_id,x.ver_nr, x.evs_src_id)
        where hdr_id = v_hdr_id;
        commit;
        end loop; */
     /*       update nci_ds_rslt r set (evs_src_id, xmap_cd, xmap_desc) = (select v_evs_src, max(xmap_cd), max(xmap_desc) from nci_admin_item_xmap x, cncpt_admin_item e where evs_src_id = v_evs_src and 
        e.item_id = r.item_id and e.ver_nr = r.ver_nr and r.hdr_id = v_hdr_id and e.cncpt_concat = x.xmap_cd group by x.item_id,x.ver_nr, x.evs_src_id)
        where hdr_id = v_hdr_id;*/
     --   end if;
       --  if (v_temp = 0) then
        -- raise_application_error(-20000,'here');
              
                    v_entty_nm := upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM')));
   
   
      for i in 1..hookInput.selectedRowset.rowset.count loop

        
          row_sel := hookInput.selectedRowset.rowset(i);
          v_evs_src := ihook.getColumnValue(row_sel,'OBJ_KEY_ID');
          
         insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_desc, evs_src_id, xmap_cd, xmap_desc) 
         select v_hdr_id, item_id, ver_nr, '9. Cross-map Code Match', v_evs_Src, xmap_cd, max(xmap_desc) from nci_admin_item_xmap x 
         where evs_src_id = v_evs_src and (item_id, ver_nr) not in 
         (select item_id, ver_nr from nci_ds_rslt where hdr_id = v_hdr_id)
         and x.xmap_cd = v_entty_nm group by x.item_id,x.ver_nr, x.evs_src_id, xmap_cd;
        commit;
   
         v_entty_nm := nvl(regexp_replace(upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM'))),v_reg_str_adv,''),'BBBBBBBBB');
         
         insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_desc, evs_src_id, xmap_cd, xmap_desc) 
         select v_hdr_id, item_id, ver_nr, '10. Cross-map Name Match', v_evs_Src, xmap_cd, max(xmap_desc) from nci_admin_item_xmap x where evs_src_id = v_evs_src 
         and (nvl(regexp_replace(upper(x.xmap_desc),v_reg_str_adv),'AAAAAAAAAAAA') like '%' || v_entty_nm || '%' or 
         v_entty_nm like '%' ||nvl(regexp_replace(upper(x.xmap_desc),v_reg_str_adv),'AAAAAAAAAA') || '%') and (item_id, ver_nr) not in 
         (select item_id, ver_nr from nci_ds_rslt where hdr_id = v_hdr_id) and length(nvl(regexp_replace(upper(x.xmap_desc),v_reg_str_adv),'AAAAAAAAAAAA')) > 2
         group by x.item_id,x.ver_nr, x.evs_src_id, xmap_cd;
        commit;

   end loop;
        --
     --   end if;
        
  update nci_ds_hdr set NUM_CDE_MTCH = (select count(*) from nci_ds_rslt where hdr_id = v_hdr_id ), 	LST_RUN_TYP = 'Run Unrestricted - Terminology Validation.'
  where hdr_id = v_hdr_id;
  commit;
  end loop;
  end if;
          v_data_out := ihook.getHookOutput(hookOutput);

  end;

procedure DECMatchSub ( v_hdr_id in number,  v_entty_nm in varchar2, v_entty_nm_with_space  in varchar2, v_typ in varchar2, row_ori in t_row) AS
v_minlen integer;
v_cnt integer := 0;
v_cur_word  varchar2(4000);
v_sel_word varchar2(4000);
j integer;
v_word_cnt integer;
v_flt_str  varchar2(1000);
  v_sql varchar2(6000);
  v_cntxt_str varchar2(4000);
begin
       --  raise_application_error(-20000, v_entty_nm);
              v_flt_str := '1=1';
        -- v_usr_tip_ind := 0;
 
 
 v_word_cnt := nci_11179.getwordcount(v_entty_nm_with_space);
 v_sel_word := 'x';
 
 for j in 1..v_word_cnt loop
 v_cur_word:= nci_11179.getWord(v_entty_nm_with_space,j, v_word_cnt);
 --raise_application_Error(-20000,length(v_sel_word));
 if (length(v_cur_word) > length(v_sel_word)) then
    v_Sel_word := v_cur_Word;
    end if;
 end loop;
 
 v_sel_word := regexp_replace(upper(v_sel_word),v_reg_str_adv,'');
 --raise_application_error(-20000, 'Hre' || v_sel_word);
 
    
     if (ihook.getColumnValue(row_ori, 'USR_CMNTS') is not null) then -- Context restriction
     v_cntxt_str := upper(trim(ihook.getColumnValue(row_ori, 'USR_CMNTS')));
     v_cnt := nci_11179.getwordcountDelim(v_cntxt_str,',');
 --    raise_application_Error(-20000,v_cnt);
     v_flt_str := ' upper(cntxt_nm_dn) in (';
     for i in 1..v_cnt loop
        if (i = v_cnt) then
        v_flt_str := v_flt_str || '''' || nci_11179.getWordDelim(v_cntxt_str, i, v_cnt,',') || ''')';
        else
             v_flt_str := v_flt_str || '''' || nci_11179.getWordDelim(v_cntxt_str, i, v_cnt,',') || ''',';
      end if;   
     end loop;
     end if;
     
    -- raise_application_error(-20000,v_flt_str);
     
     if (ihook.getColumnValue(row_ori, 'STUS_FLTR_ID') is not null) then -- Registration Status restriction
       v_flt_str := v_flt_str  ||  ' and regstr_stus_id = ' || ihook.getColumnValue(row_ori, 'STUS_FLTR_ID');
     end if;
  v_minlen := nci_11179.getMinWordLen(v_entty_nm_with_space);
  
  if (ihook.getColumnValue(row_ori,'FLTR_MDL_ITEM_ID') is null) then -- no model selected.
      v_sql := 'insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,   rule_desc) select distinct ' ||  v_hdr_id || ', ''DEC'', item_id, ver_nr,  ''1. DEC Exact Match'' from 
                  ADMIN_ITEM  where ''' ||v_entty_nm || ''' = MTCH_TERM_ADV    and currnt_ver_ind = 1    and admin_item_typ_id = 2         and upper(ADMIN_STUS_NM_DN) not like ''%RETIRED%''      and ' || v_flt_str ;
                  --raise_application_error (-20000,v_sql);
                     execute immediate v_sql;
                        v_cnt := SQL%ROWCOUNT;
 
                    commit;
       
   
        v_sql := 'insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,   rule_desc) select distinct ' ||  v_hdr_id || ', ''DEC'', item_id, ver_nr,  ''2. DEC Like Match'' from 
                  ADMIN_ITEM  where ((MTCH_TERM_ADV  like ''%' ||v_entty_nm || '%'') or  (''' ||  v_entty_nm || ''' like ''%'' || MTCH_TERM_ADV || ''%''  and length(mtch_term) >= ' || v_minlen || ')) 
                  and currnt_ver_ind = 1    and admin_item_typ_id = 2         and upper(ADMIN_STUS_NM_DN) not like ''%RETIRED%''      and (' || v_hdr_id || ', item_id, ver_nr) not in 
                  (select hdr_id, item_id, ver_nr from nci_ds_rslt where hdr_id = ' || v_hdr_id || ') and         ' || v_flt_str ;
            --     raise_application_error (-20000,v_sql);
                     execute immediate v_sql;
                      v_cnt := v_cnt +  SQL%ROWCOUNT;
                    commit;
     
                   
    if (v_cnt > 0 ) then
    return;
    end if;
 -- Third pass longest word exact match
 
   v_sql := 'insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,   rule_desc) select distinct ' ||  v_hdr_id || ', ''DEC'', item_id, ver_nr,  ''3. DEC Like Match Largest word'' from 
                  ADMIN_ITEM  where ((MTCH_TERM_ADV  like ''%' || v_sel_word || '%'') or  (''' ||   v_sel_word || ''' like ''%'' || MTCH_TERM_ADV || ''%'' )) and length(mtch_term_adv) >= length(''' ||  v_sel_word || ''') 
                  and currnt_ver_ind = 1    and admin_item_typ_id = 2         and upper(ADMIN_STUS_NM_DN) not like ''%RETIRED%''      and (' || v_hdr_id || ', item_id, ver_nr) not in 
                  (select hdr_id, item_id, ver_nr from nci_ds_rslt where hdr_id = ' || v_hdr_id || ') and         ' || v_flt_str ;
               -- raise_application_error (-20000,v_sql);
                     execute immediate v_sql;
     commit;               
     
       v_cnt := v_cnt + SQL%ROWCOUNT;
         
    end if; -- not model selected.
       
    if (ihook.getColumnValue(row_ori,'FLTR_MDL_ITEM_ID') is not null) then 
      v_sql := 'insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,   rule_desc) select distinct ' ||  v_hdr_id || ', ''DEC'', item_id, ver_nr,  ''1. DEC Exact Match'' from 
                  ADMIN_ITEM ai, VW_NCI_MEC m  where ''' ||v_entty_nm || ''' = MTCH_TERM_ADV    and currnt_ver_ind = 1    and admin_item_typ_id = 2         
                  and upper(ADMIN_STUS_NM_DN) not like ''%RETIRED%''      and ai.item_id = m.DE_CONC_ITEM_ID and ai.ver_nr = m.DE_CONC_VER_NR and m.MDL_ITEM_ID = ' || ihook.getCOlumnValue(row_ori,'FLTR_MDL_ITEM_ID')
                  || ' and m.MDL_VER_NR = ' || ihook.getColumnValue(row_ori,'FLTR_MDL_VER_NR') || ' and ' || v_flt_str ;
                  --raise_application_error (-20000,v_sql);
                     execute immediate v_sql;
                        v_cnt := SQL%ROWCOUNT;
 
                    commit;
       
   
        v_sql := 'insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,   rule_desc) select distinct ' ||  v_hdr_id || ', ''DEC'', item_id, ver_nr,  ''2. DEC Like Match'' from 
                  ADMIN_ITEM ai, vw_nci_mec m where ((MTCH_TERM_ADV  like ''%' ||v_entty_nm || '%'') or  (''' ||  v_entty_nm || ''' like ''%'' || MTCH_TERM_ADV || ''%''  and length(mtch_term) >= ' || v_minlen || ')) 
                  and currnt_ver_ind = 1    and admin_item_typ_id = 2         and upper(ADMIN_STUS_NM_DN) not like ''%RETIRED%''      and (' || v_hdr_id || ', item_id, ver_nr) not in 
                  (select hdr_id, item_id, ver_nr from nci_ds_rslt where hdr_id = ' || v_hdr_id || ') and    ai.item_id = m.DE_CONC_ITEM_ID and ai.ver_nr = m.DE_CONC_VER_NR and m.MDL_ITEM_ID = ' || ihook.getCOlumnValue(row_ori,'FLTR_MDL_ITEM_ID')
                  || ' and m.MDL_VER_NR = ' || ihook.getColumnValue(row_ori,'FLTR_MDL_VER_NR') || ' and ' || v_flt_str    ;
            --     raise_application_error (-20000,v_sql);
                     execute immediate v_sql;
                      v_cnt := v_cnt +  SQL%ROWCOUNT;
                    commit;
     
                   
    if (v_cnt > 0 ) then
    return;
    end if;
 -- Third pass longest word exact match
 
   v_sql := 'insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,   rule_desc) select distinct ' ||  v_hdr_id || ', ''DEC'', item_id, ver_nr,  ''3. DEC Like Match Largest word'' from 
                  ADMIN_ITEM ai, VW_NCI_MEC m where ((MTCH_TERM_ADV  like ''%' || v_sel_word || '%'') or  (''' ||   v_sel_word || ''' like ''%'' || MTCH_TERM_ADV || ''%'' )) and length(mtch_term_adv) >= length(''' ||  v_sel_word || ''') 
                  and currnt_ver_ind = 1    and admin_item_typ_id = 2         and upper(ADMIN_STUS_NM_DN) not like ''%RETIRED%''      and (' || v_hdr_id || ', item_id, ver_nr) not in 
                  (select hdr_id, item_id, ver_nr from nci_ds_rslt where hdr_id = ' || v_hdr_id || ')  and ai.item_id = m.DE_CONC_ITEM_ID and ai.ver_nr = m.DE_CONC_VER_NR and m.MDL_ITEM_ID = ' || ihook.getCOlumnValue(row_ori,'FLTR_MDL_ITEM_ID')
                  || ' and m.MDL_VER_NR = ' || ihook.getColumnValue(row_ori,'FLTR_MDL_VER_NR') || ' and ' || v_flt_str;
               -- raise_application_error (-20000,v_sql);
                     execute immediate v_sql;
     commit;               
     
       
      
    end if;
    end;

    
procedure spDSRun ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

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
    v_suffix varchar2(100);
    v_str varchar2(128);
    tmp_item_id number;
    tmp_ver_nr number(4,2);
    v_pv varchar2(1000);
    v_sys_msg varchar2(2000);
    v_pv_mtch number;
    v_num_src_pv number;
    v_pv_cde number;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   -- raise_application_error(-20000,v_user_id);

  --  delete from nci_ds_rslt_dtl where user_id = v_user_id;
   -- commit;
    
    rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
         v_flt_str := '1=1';
        -- v_usr_tip_ind := 0;
     if (ihook.getColumnValue(row_ori,'ENTTY_NM_USR') is not null) then
       v_suffix := 'User Tips';
    else
      v_suffix := 'Name';
     end if;
     
     if (ihook.getColumnValue(row_ori, 'USR_CMNTS') is not null) then -- Context restriction
     v_cntxt_str := upper(trim(ihook.getColumnValue(row_ori, 'USR_CMNTS')));
     v_cnt := nci_11179.getwordcountdelim(v_cntxt_str,',');
     v_flt_str := ' upper(de.cntxt_nm_dn) in (';
     for i in 1..v_cnt loop
        if (i = v_cnt) then
        v_flt_str := v_flt_str || '''' || nci_11179.getWordDelim(v_cntxt_str, i, v_cnt,',') || ''')';
        else
             v_flt_str := v_flt_str || '''' || nci_11179.getWordDelim(v_cntxt_str, i, v_cnt,',') || ''',';
      end if;   
     end loop;
     end if;
        select count(*) into v_temp from nci_ds_dtl where hdr_id = v_hdr_id;
        
        if (v_temp = 0) then v_val_dom_typ := 18 ; else v_val_dom_typ := 17; end if; -- enumerated or non-enumerated 18 - non-enumerated
        delete from nci_ds_rslt where hdr_id = v_hdr_id and mtch_typ = 'CDE';
        commit;

            if (v_val_dom_typ = 18) then -- non -enumerated
            
---procedure spDSMatchNonEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2);
            spDSMatchNonEnum(v_hdr_id, v_user_id, v_flt_str,'CDE_MATCH', nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR'), ihook.getColumnValue(row_ori, 'ENTTY_NM')),
           v_suffix);
           
            update nci_ds_hdr set NUM_CDE_MTCH = (select count(*) from nci_ds_rslt where hdr_id = v_hdr_id and mtch_typ = 'CDE'),
                    NUM_PV = 0
                    where hdr_id = v_hdr_id;
                update nci_ds_rslt r set NUM_PV_IN_CDE = (select count(*) from vw_nci_de_pv_lean where de_item_id = r.item_id and de_ver_nr = r.ver_nr)
                    where hdr_id = v_hdr_id;
                    commit;
            end if;
            
            if (v_val_dom_typ = 17) then -- enumerated

            v_pv := getPVExclusionList(v_hdr_id);

---procedure spDSMatchNonEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2);
            spDSMatchEnum(v_hdr_id, v_user_id, v_flt_str,'CDE_MATCH', nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR'), ihook.getColumnValue(row_ori, 'ENTTY_NM')),
              v_suffix, getPVFilterString(v_hdr_id), 'PV');
              
--                select count(*) into v_temp from nci_ds_hdr where hdr_id = v_hdr_id and cde_item_id is not null and cde_ver_nr is not null;
--                if (v_temp > 0) then
--                    select num_pv_mtch, num_pv_in_cde into v_pv_mtch, v_pv_cde from nci_ds_rslt r, nci_ds_hdr d where r.item_id = d.cde_item_id and r.ver_nr = d.cde_ver_nr and d.hdr_id = v_hdr_id and d.hdr_id = r.hdr_id;
--                    select count(*) into v_temp from nci_ds_dtl where hdr_id = v_hdr_id and excl_pv_ind = 0;
--                    v_sys_msg := 'Source PVs ' || v_temp || ' - Matched PVs ' || v_pv_mtch || ' - CDE PVs ' || v_pv_cde;
--                else
--                    select count(*) into v_temp from nci_ds_dtl where hdr_id = v_hdr_id and excl_pv_ind = 0;
--                    v_sys_msg := '';
--                end if;
                
                update nci_ds_hdr set NUM_CDE_MTCH = (select count(*) from nci_ds_rslt where hdr_id = v_hdr_id and mtch_typ = 'CDE'),
                    NUM_PV = v_temp, DYN_PV_SEL = v_pv
                    where hdr_id = v_hdr_id;
                update nci_ds_rslt r set NUM_PV_IN_CDE = (select count(*) from vw_nci_de_pv_lean where de_item_id = r.item_id and de_ver_nr = r.ver_nr)
                    where hdr_id = v_hdr_id;
                    commit;
            end if;
            
  
    --jira 3815: automatically set preferred cde if match is exact and there is only 1
    select NUM_CDE_MTCH into v_temp from nci_ds_hdr where hdr_id = v_hdr_id;
     raise_application_error(-20000, v_temp);
  if (v_temp = 1) then
  raise_application_error(-20000, 'here');
    select rule_desc, item_id, ver_nr, nvl(num_pv_mtch,0), num_pv_in_cde into v_str, tmp_item_id, tmp_ver_nr, v_temp, v_pv_cde from nci_ds_rslt where hdr_id = v_hdr_id;
    if (v_str like '%Exact Match%') then

        --v_sys_msg := 'Preferred CDE set to only match: ' || tmp_item_id || 'v' || tmp_ver_nr;
--        if (v_val_dom_typ = 17) then
--            select count(*) into v_num_src_pv from nci_ds_dtl where hdr_id = v_hdr_id and excl_pv_ind = 0;
--           
--            v_sys_msg := v_sys_msg || '. Source PVs ' || v_num_src_pv || ' - Matched PVs ' || v_temp || ' - CDE PVs ' || v_pv_cde;
--        end if;
        update nci_ds_hdr set CDE_ITEM_ID = tmp_item_id, CDE_VER_NR = tmp_ver_nr, NUM_PV_IN_CDE = v_pv_cde, NUM_PV_MTCH = v_temp where hdr_id = v_hdr_id;
        commit;
    end if;
  end if;
    update nci_ds_hdr set LST_RUN_TYP = 'CDE', LST_RUN_DT = systimestamp where hdr_id = v_hdr_id;
    commit;
    v_sys_msg := getDSSysMsg(v_hdr_id, 'DS');
    update nci_ds_hdr set sys_msg = v_sys_msg where hdr_id = v_hdr_id;
    commit;
  end loop;
  commit;
 -- v_sys_msg := v_sys_msg || '<BR>' || 'Last run: CDE Match';

--  v_sys_msg := 'Last Run: CDE Match ' || to_char(systimestamp, 'YYYY-MM-DD HH12:MI:SS') || ' <BR>' || v_sys_msg;
--  update nci_ds_hdr set SYS_MSG = v_sys_msg, LST_RUN_TYP = 'CDE', LST_RUN_DT = systimestamp where hdr_id = v_hdr_id;
-- commit;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     
END;

procedure spPostCDEMatch (v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_str varchar2(128);
    v_item_id number;
    v_ver_nr number(4,2);
    v_hdr_id number;
BEGIN
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    
    row_ori := hookInput.originalRowset.rowset (1);
    rows := t_rows();
    row := t_row();
    v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
    if (ihook.getColumnValue(row_ori, 'NUM_CDE_MTCH') = 1) then
        select rule_desc, item_id, ver_nr into v_str, v_item_id, v_ver_nr from nci_ds_rslt where hdr_id = v_hdr_id;
        if (v_str like '%Exact Match%') then
   --    raise_application_error(-20000, v_ver_nr);
--        update nci_ds_hdr set CDE_ITEM_ID = v_item_id where hdr_id = v_hdr_id;
--        update nci_ds_hdr set CDE_VER_NR = v_ver_nr where hdr_id = v_hdr_id;
--        commit;
            ihook.setColumnValue(row, 'HDR_ID', v_hdr_id);
            ihook.setColumnValue(row, 'CDE_ITEM_ID', v_item_id);
            ihook.setColumnValue(row, 'CDE_VER_NR', v_ver_nr);

            rows.extend;
            rows(rows.last) := row;
            action             := t_actionrowset(rows, 'DS Entity To Match', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
        end if;
    end if;
    
   hookoutput.actions    := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


    
procedure spDECMatch ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

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
    v_entty_nm_with_space varchar2(255);
    v_cntxt_str varchar2(255);
    v_cnt integer;
    v_suffix varchar2(100);
    v_sys_msg varchar2(4000) := '';
    v_src_pv number;
    v_pv_mtch number;
    v_pv_cde number;
    v_cde_item_id number;
    v_cde_ver_nr number(4,2);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   -- raise_application_error(-20000,v_user_id);

  --  delete from nci_ds_rslt_dtl where user_id = v_user_id;
   -- commit;
    rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
        delete from nci_ds_rslt where hdr_id = v_hdr_id and mtch_typ = 'DEC';
        commit;
  v_entty_nm := regexp_replace(upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM'))),v_reg_str_adv,'');
        v_entty_nm_with_space := upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM')));
    
  DECMatchSub(v_hdr_id, v_entty_nm,v_entty_nm_with_space,'X', row_ori);
 update nci_ds_hdr set LST_RUN_TYP = 'DEC Match', LST_RUN_DT = systimestamp where hdr_id = v_hdr_id;
 commit;
    select count(*) into v_temp from nci_ds_rslt where hdr_id = v_hdr_id  and mtch_typ = 'DEC'    ;

   if (v_temp = 1) then 
  update nci_ds_hdr set (NUM_DEC_MTCH, DE_CONC_ITEM_ID, DE_CONC_VER_NR, LST_UPD_USR_ID) = (select 1, item_id, ver_nr , v_user_id from nci_ds_rslt where hdr_id = v_hdr_id and mtch_typ='DEC')
  where hdr_id = v_hdr_id;
  else
  update nci_ds_hdr set NUM_DEC_MTCH = v_temp
  where hdr_id = v_hdr_id;
  end if;
  commit;
  
--  select count(*) into v_temp from nci_ds_hdr where hdr_id = v_hdr_id and cde_item_id is not null; 
--  if (v_temp = 1) then
--    select num_pv_in_src, num_pv_mtch, num_pv_in_cde, item_id, ver_nr into v_src_pv, v_pv_mtch, v_pv_cde, v_cde_item_id, v_cde_ver_nr from nci_ds_rslt r, nci_ds_hdr d where r.hdr_id = v_hdr_id and d.hdr_id = v_hdr_id and d.cde_item_id = r.item_id and d.cde_ver_nr = r.ver_nr;
--    if (v_src_pv is not null and v_src_pv > 0 and v_pv_mtch is not null) then
--        v_sys_msg := 'Preferred CDE set to ' || v_cde_item_id || 'v' || v_cde_ver_nr || ' <BR>' ||
--        'Source PVs ' || v_src_pv || ' - Matched PVs ' || v_pv_mtch  || ' - CDE PVs ' || v_pv_cde;
--    end if;
--end if;
    v_sys_msg := getDSSysMsg(v_hdr_id, 'DEC');
  --v_sys_msg := 'Last Run: DEC Match ' || to_char(systimestamp, 'YYYY-MM-DD HH12:MI:SS') || ' <BR>' || v_sys_msg;
    update nci_ds_hdr set SYS_MSG = v_sys_msg where hdr_id = v_hdr_id;

  commit;
  end loop;

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     
END;



procedure spDSMatchNonEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2, v_suffix in varchar2)

AS

    v_already integer :=0;
    i integer := 0;
     v_sql varchar2(4000);
    v_entty_nm varchar2(255);
    v_entty_nm_like varchar2(255);
    v_cntxt_str varchar2(255);
    v_cnt integer;

begin
        delete from nci_ds_rslt where hdr_id = v_hdr_id;
        commit;

           select '''' || regexp_replace(upper(v_mtch_nm),v_reg_str,'') || '''' into v_entty_nm from dual;
              select '''' || regexp_replace(upper(v_mtch_nm),v_reg_str,'') || '''' into v_entty_nm_like from dual;
      
                  v_sql := 'insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc, mtch_desc_txt) 
                  select  ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr,  1, 100, ''1. Long Name Exact Match'', max(de.item_nm) from 
                  vw_de de where ' ||v_entty_nm || ' = de.MTCH_TERM    and currnt_ver_ind = 1             and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''        and de.val_dom_typ_id = 18 and ' || v_flt_str 
                  || ' group by de.item_id, de.ver_nr ' ;
                  --raise_application_error (-20000,v_sql);
                     execute immediate v_sql;
                    commit;
                    
                    -- Rule id 2:  Entity alternate question text name exact match
                    
                 
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc, mtch_desc_txt) 
                    select  ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr,  2, 100, ''2. Question Text Exact Match'' ,max(r.ref_nm)
                    from ref r, obj_key ok, vw_de de 
                    where ' || v_entty_nm || ' =  r.MTCH_TERM  and r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt)
                    and de.val_dom_typ_id = 18 and ' || v_flt_str
                     || ' group by r.item_id, r.ver_nr ' ;
                      execute immediate v_sql;
                  
                    commit;
        
                    
                    
                    -- Rule id 3:  Entity alternate  name exact match
                    
                     v_sql := ' insert into nci_ds_rslt (hdr_id,mtch_typ, item_id, ver_nr, rule_id, score, rule_desc, mtch_desc_txt) 
                    select  ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr, 3, 
                    100, ''3. Alternate Name Exact Match'' , max(r.nm_desc) from alt_nms r, vw_de de
                    where ' || v_entty_nm ||  ' = r.MTCH_TERM and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt) and ' || v_flt_str
                     || ' group by r.item_id, r.ver_nr ' ;
                     execute immediate v_sql;
                    commit;
                    
                    
            -- Non enumerated only
            
                       v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc, mtch_desc_txt) 
                    select ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr,  
                    4, 100, ''4. Long Name Like Match'', max(de.item_nm) from vw_de  de 
                    where instr(de.MTCH_TERM , ' || concat(v_entty_nm,' ') || ',1) > 0 
                     and currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                     and (' || v_hdr_id || ',de.item_id, de.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt) and ' || v_flt_str
                      || ' group by de.item_id, de.ver_nr ' ;
                   --  raise_application_error(-20000, v_sql);
                     execute immediate v_sql;
                     commit;
                
                
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc , mtch_desc_txt) 
                    select  ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr, 
                    5, 100, ''5. Question Text Like Match'', max(r.ref_nm) from ref r, obj_key ok, vw_de de
                    where instr(r.MTCH_TERM ,' || concat(v_entty_nm,' ')  || ', 1) > 0                     and
                    r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and r.ref_nm != ''%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select  hdr_id , item_id, ver_nr from nci_ds_rslt) and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%'' and ' || v_flt_str
                     || ' group by r.item_id, r.ver_nr ' ;
                   --  raise_application_error(-20000, v_sql);
                execute immediate v_sql;
                    commit;
                                
                   
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr, rule_id, score, rule_desc , mtch_desc_txt) 
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr,  
                    6, 100, ''6. Alternate Name Like Match'', max(r.nm_desc) from alt_nms r, vw_de de
                    where instr( r.MTCH_TERM, ' || concat(v_entty_nm,' ')  || ',1) > 0
                    and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not  in (select hdr_id ,item_id, ver_nr from nci_ds_rslt) and ' || v_flt_str
                     || ' group by r.item_id, r.ver_nr ' ;
--raise_application_error(-20000,v_sql);
                     execute immediate v_sql;
                     
                         v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc , mtch_desc_txt) 
                    select ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr,  
                    4, 100, ''7. Long Name Reverse Like Match'', max(de.item_nm) from vw_de  de 
                    where instr('|| concat(v_entty_nm,' ')  || ',de.MTCH_TERM , 1) > 0  and length(de.mtch_term) > ' || v_mtch_min_len ||
                    ' and currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                     and (' || v_hdr_id || ',de.item_id, de.ver_nr) not in (select hdr_id ,item_id, ver_nr from nci_ds_rslt) and ' || v_flt_str
                      || ' group by de.item_id, de.ver_nr ' ;
                   --  raise_application_error(-20000, v_sql);
                     execute immediate v_sql;
                     commit;
                
                
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc , mtch_desc_txt) 
                    select  ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr, 
                    5, 100, ''8. Question Text Reverse Like Match'', max(r.ref_nm) from ref r, obj_key ok, vw_de de
                    where instr(' || concat(v_entty_nm,' ')  || ',r.MTCH_TERM , 1) > 0       and length(r.mtch_term) > ' || v_mtch_min_len || '           and
                    r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and r.ref_nm != ''%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select  hdr_id,item_id, ver_nr  from nci_ds_rslt) and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%'' and ' || v_flt_str
                     || ' group by r.item_id, r.ver_nr ' ;
                   --  raise_application_error(-20000, v_sql);
                execute immediate v_sql;
                    commit;
                                
                   
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr, rule_id, score, rule_desc , mtch_desc_txt) 
                    select  ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr,  
                    6, 100, ''9. Alternate Name Reverse Like Match'' , max(r.nm_desc) from alt_nms r, vw_de de
                    where instr( ' || concat(v_entty_nm,' ')  || ', r.MTCH_TERM, 1) > 0 and length(r.mtch_term) > ' || v_mtch_min_len ||
                    ' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not  in (select hdr_id ,item_id, ver_nr  from nci_ds_rslt) and ' || v_flt_str
                     || ' group by r.item_id, r.ver_nr ' ;
--raise_application_error(-20000,v_sql);
                     execute immediate v_sql;
                     
                    commit;
                --    if (usr_tips_ind = 1) then
                    update nci_ds_rslt set rule_desc = rule_desc || ' (' || v_suffix || ')' , MTCH_TYP = 'CDE' where hdr_id = v_hdr_id;
                    commit;
                  --  end if;
     


END;

procedure spSetPVExclusion (v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_pv_ind varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
BEGIN
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    for i in 1..hookinput.originalrowset.rowset.count loop
        row_ori := hookInput.originalrowset.rowset(i);
        if (ihook.getColumnValue(row_ori, 'EXCL_PV_IND') = 0) then
            update nci_ds_dtl set excl_pv_ind = 1 where hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID') and upper(PERM_VAL_NM) = upper(ihook.getColumnValue(row_ori, 'PERM_VAL_NM'));
        else
            update nci_ds_dtl set excl_pv_ind = 0 where hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID') and upper(PERM_VAL_NM) = upper(ihook.getColumnValue(row_ori, 'PERM_VAL_NM'));
        end if;
        --update nci_ds_dtl set excl_pv_ind = 1 where hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID') and upper(PERM_VAL_NM) = upper(ihook.getColumnValue(row_ori, 'PERM_VAL_NM'));
    end loop;
    commit;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spResetPVExclusion (v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_pv_ind varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
BEGIN
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    row_ori := hookInput.originalRowset.rowset(1);
    
    update nci_ds_dtl set excl_pv_ind = 0 where hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
    commit;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spDSRunPVVM (v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_mode varchar2)
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
    v_mtch_str varchar2(4000);
    v_cntxt_str varchar2(255);
    v_cnt integer;
    v_suffix varchar2(100);
    v_str varchar2(128);
    tmp_item_id number;
    tmp_ver_nr number(4,2);
    v_pv varchar2(1000);
    v_sys_msg varchar2(2000);
    v_pv_mtch number;
    v_num_src_pv number;
    v_pv_cde number;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    
    rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
         v_flt_str := '1=1';
        -- v_usr_tip_ind := 0;
     if (ihook.getColumnValue(row_ori,'ENTTY_NM_USR') is not null) then
       v_suffix := 'User Tips';
    else
      v_suffix := 'Name';
     end if;
     --jira 3976: new context filter
     select count(*) into v_temp from nci_ds_cntxt_sel where hdr_id = v_hdr_id;

     if v_temp > 0 then
        for cntxt in (select CNTXT_NM_DN from vw_cntxt_ds where cntxt_id_ver in (select cntxt_id_ver from nci_ds_cntxt_sel where hdr_id = v_hdr_id)) loop
            v_cntxt_str := v_cntxt_str || ', ' || cntxt.CNTXT_NM_DN;
        end loop;
        v_cntxt_str := upper(trim(LTRIM(v_cntxt_str, ', ')));
--     if (ihook.getColumnValue(row_ori, 'USR_CMNTS') is not null) then -- Context restriction
--     v_cntxt_str := upper(trim(ihook.getColumnValue(row_ori, 'USR_CMNTS')));
     v_cnt := nci_11179.getwordcountdelim(v_cntxt_str,',');
     v_flt_str := ' upper(de.cntxt_nm_dn) in (';
        -- raise_application_error(-20000, v_cntxt_str);
     for i in 1..v_cnt loop
        if (i = v_cnt) then
        v_flt_str := v_flt_str || '''' || nci_11179.getWordDelim(v_cntxt_str, i, v_cnt,',') || ''')';
        else
             v_flt_str := v_flt_str || '''' || nci_11179.getWordDelim(v_cntxt_str, i, v_cnt,',') || ''',';
      end if;   
     end loop;
     end if;
   --  raise_application_error(-20000, v_flt_str);
        select count(*) into v_temp from nci_ds_dtl where hdr_id = v_hdr_id;
        
        if (v_temp = 0) then v_val_dom_typ := 18 ; else v_val_dom_typ := 17; end if; -- enumerated or non-enumerated 18 - non-enumerated
        delete from nci_ds_rslt where hdr_id = v_hdr_id and mtch_typ = 'CDE';
        commit;

            if (v_val_dom_typ = 18) then -- non -enumerated
            
---procedure spDSMatchNonEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2);
            spDSMatchNonEnum(v_hdr_id, v_user_id, v_flt_str,'CDE_MATCH', nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR'), ihook.getColumnValue(row_ori, 'ENTTY_NM')),
           v_suffix);
           
            update nci_ds_hdr set NUM_CDE_MTCH = (select count(*) from nci_ds_rslt where hdr_id = v_hdr_id and mtch_typ = 'CDE'),
                    NUM_PV = 0
                    where hdr_id = v_hdr_id;
                update nci_ds_rslt r set NUM_PV_IN_CDE = (select count(*) from vw_nci_de_pv_lean where de_item_id = r.item_id and de_ver_nr = r.ver_nr)
                    where hdr_id = v_hdr_id;
                    commit;
            end if;
            
            if (v_val_dom_typ = 17) then -- enumerated

            v_pv := substr(getPVExclusionList(v_hdr_id),0,1000);

            spDSMatchEnum(v_hdr_id, v_user_id, v_flt_str,'CDE_MATCH', nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR'), ihook.getColumnValue(row_ori, 'ENTTY_NM')),
              v_suffix, getPVFilterString(v_hdr_id), v_mode);
              
                
                update nci_ds_hdr set NUM_CDE_MTCH = (select count(*) from nci_ds_rslt where hdr_id = v_hdr_id and mtch_typ = 'CDE'),
                    NUM_PV = v_temp, DYN_PV_SEL = v_pv
                    where hdr_id = v_hdr_id;
                update nci_ds_rslt r set NUM_PV_IN_CDE = (select count(*) from vw_nci_de_pv_lean where de_item_id = r.item_id and de_ver_nr = r.ver_nr)
                    where hdr_id = v_hdr_id;
                    commit;
            end if;
            
  
    --jira 3815: automatically set preferred cde if match is exact and there is only 1
    select NUM_CDE_MTCH into v_temp from nci_ds_hdr where hdr_id = v_hdr_id;
  if (v_temp = 1) then
    select rule_desc, mtch_desc_txt, item_id, ver_nr, nvl(num_pv_mtch,0), num_pv_in_cde into v_str, v_mtch_str, tmp_item_id, tmp_ver_nr, v_temp, v_pv_cde from nci_ds_rslt where hdr_id = v_hdr_id;
    if (v_str like '%Exact Match%') then
        update nci_ds_hdr set CDE_ITEM_ID = tmp_item_id, CDE_VER_NR = tmp_ver_nr, NUM_PV_IN_CDE = v_pv_cde, NUM_PV_MTCH = v_temp,
        rule_desc = v_str, mtch_desc_txt = v_mtch_str where hdr_id = v_hdr_id;
        commit;
    end if;
  end if;
    update nci_ds_hdr set LST_RUN_TYP = 'CDE Match (' || v_mode || ')', LST_RUN_DT = systimestamp where hdr_id = v_hdr_id;
    commit;
    v_sys_msg := getDSSysMsg(v_hdr_id, v_mode);
    update nci_ds_hdr set sys_msg = v_sys_msg where hdr_id = v_hdr_id;
    commit;
  end loop;
  commit;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

function getLastDSRun (v_hdr_id in number) return varchar2 is
v_out_str varchar2(128);
BEGIN
    SELECT lst_run_typ INTO v_out_str FROM nci_ds_hdr WHERE hdr_id = v_hdr_id;
    return v_out_str;
END;

function getPVFilterString (v_hdr_id in number) return varchar2 is
v_pv_flt_str varchar2(4000);
v_temp number;
v_lst_run_typ varchar2(128);
begin
select count(*) into v_temp from nci_ds_dtl where hdr_id = v_hdr_id and excl_pv_ind = 1;
if (v_temp > 0) then
    v_lst_run_typ := getLastDSRun(v_hdr_id);
    if (v_lst_run_typ like '%(PV)%') then
        for pv in (select perm_val_nm, entty_nm_usr from nci_ds_dtl where hdr_id = v_hdr_id and excl_pv_ind = 1) loop
            if (v_pv_flt_str = '') then
                v_pv_flt_str := '''' || upper(nvl(pv.entty_nm_usr,pv.perm_val_nm)) || '''' || ',';
            else
                v_pv_flt_str := v_pv_flt_str || '''' || upper(nvl(pv.entty_nm_usr,pv.perm_val_nm)) || '''' || ',';
            end if;
        end loop;
--    v_pv_flt_str := trim(TRAILING ',' from v_pv_flt_str);
--    v_pv_flt_str := 'not in (' || v_pv_flt_str || ')';
    ELSE
        for vm in (select val_mean_nm,entty_nm_usr from nci_ds_dtl where hdr_id = v_hdr_id and excl_pv_ind = 1) loop
            if (v_pv_flt_str = '') then
                v_pv_flt_str := '''' || upper(nvl(vm.entty_nm_usr,vm.val_mean_nm)) || '''' || ',';
            else
                v_pv_flt_str := v_pv_flt_str || '''' || upper(nvl(vm.entty_nm_usr,vm.val_mean_nm)) || '''' || ',';
            end if;
        end loop;
    END IF;
    v_pv_flt_str := trim(TRAILING ',' from v_pv_flt_str);
    v_pv_flt_str := 'not in (' || v_pv_flt_str || ')';
else
    v_pv_flt_str := 'N';
end if;

return v_pv_flt_str;
end;

function getPVExclusionList (v_hdr_id in number) return varchar2 is
v_pv_flt_str varchar2(4000);
v_temp number;
v_lst_run_typ varchar2(128);
v_overflow number;
begin
select count(*) into v_temp from nci_ds_dtl where hdr_id = v_hdr_id and excl_pv_ind = 1;
if (v_temp > 0) then
    v_overflow := 0;
    v_lst_run_typ := getLastDSRun(v_hdr_id);
    if (v_lst_run_typ LIKE '%(PV)%') then
        for pv in (select entty_nm_usr,perm_val_nm from nci_ds_dtl where hdr_id = v_hdr_id and excl_pv_ind = 1 and nvl(fld_delete,0) <> 1) loop
            if ((length(nvl(v_pv_flt_str,0)) + length(nvl(pv.entty_nm_usr, pv.perm_val_nm))) < 1970) then
                v_pv_flt_str := nvl(v_pv_flt_str, '') || nvl(pv.entty_nm_usr,pv.perm_val_nm) || ', ';
            else
                v_overflow := v_overflow + 1;
            end if;
--            if (v_pv_flt_str = '') then        
--                v_pv_flt_str := nvl(pv.entty_nm_usr,pv.perm_val_nm) ||  ', ';
--            else
--                v_pv_flt_str := v_pv_flt_str || nvl(pv.entty_nm_usr,pv.perm_val_nm) || ', ';
--            end if;
        end loop;
        --v_pv_flt_str := LTRIM(v_pv_flt_str, ' ');
    else
        for vm in (select entty_nm_usr,val_mean_nm from nci_ds_dtl where hdr_id = v_hdr_id and excl_pv_ind = 1 and nvl(fld_delete,0) <> 1) loop
            if ((length(nvl(v_pv_flt_str,0)) + length(nvl(vm.entty_nm_usr, vm.val_mean_nm))) < 1970) then
                v_pv_flt_str := nvl(v_pv_flt_str, '') || nvl(vm.entty_nm_usr,vm.val_mean_nm) || ', ';
            else
                v_overflow := v_overflow + 1;
            end if;
            
--            if (v_pv_flt_str = '') then        
--                v_pv_flt_str := nvl(vm.entty_nm_usr,vm.val_mean_nm) ||  ', ';
--            else
--                v_pv_flt_str := v_pv_flt_str || nvl(vm.entty_nm_usr,vm.val_mean_nm) || ', ';
--            end if;
        end loop;      
    end if;
    
  --   v_pv_flt_str := LTRIM(v_pv_flt_str, '');
    v_pv_flt_str := trim(TRAILING ' ' from v_pv_flt_str);
    v_pv_flt_str := trim(TRAILING ',' from v_pv_flt_str);
    
    if (v_overflow > 0) then
        v_pv_flt_str := v_pv_flt_str || ', <i>and ' || v_overflow || ' more...</i>';
    end if;
else
    v_pv_flt_str := '';
end if;


return v_pv_flt_str;
end;

procedure spDSMatchEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2, v_suffix in varchar2, v_pv_flt_str in varchar2, v_mode in varchar2)

AS

    v_already integer :=0;
    i integer := 0;
    v_sql varchar2(4000);
    v_entty_nm varchar2(255);
    v_entty_nm_like varchar2(255);
    v_cntxt_str varchar2(255);
    v_cnt integer;
    v_pv_filter varchar2(4000);
    v_pv_cnt integer;
    v_src_dtl varchar2(255);
    v_mtch_pcnt number(4,2);
    v_cur_word  varchar2(4000);
    v_sel_word varchar2(4000);
    v_word_cnt number;
    v_entty_nm_with_space varchar2(4000);

begin

--jira 4236: add variable to set pv match percentage for CDE match
-- set to 20%
v_mtch_pcnt := 0.5;
      
    delete from nci_ds_rslt where hdr_id = v_hdr_id;
    commit;
--            select '''' || regexp_replace(upper(v_mtch_nm),v_reg_str,'') || '''' into v_entty_nm from dual;
--            select '''' || regexp_replace(upper(v_mtch_nm),v_reg_str,'') || '''' into v_entty_nm_like from dual;
            
            --test handling quotes in dynamic query jira 4011
    select '''' || regexp_replace(upper(regexp_replace(v_mtch_nm, '''', '''''' )),v_reg_str,'') || '''' into v_entty_nm from dual;
    select '''' || regexp_replace(upper(regexp_replace(v_mtch_nm, '''', '''''')),v_reg_str,'') || '''' into v_entty_nm_like from dual;           
      
    --  raise_application_error(-20000, v_entty_nm);
         -- nci_ds_rslt_dlt holds the first level run of name matches.
            
    -- Rule id 1:  Entity preferred name exact match
    delete from nci_ds_rslt_dtl where hdr_id = v_hdr_id;
    commit;

    v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc, mtch_desc_txt) select ' ||
    v_hdr_id || ', ''' || v_mtch_typ || ''', de.item_id, de.ver_nr, ''NA'', 1, 100, ''1. Long Name Exact Match'', max(de.item_nm) from   vw_de de where ' || v_entty_nm || '  = de.MTCH_TERM
        and currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%'' and ' || v_flt_str
        || ' group by de.item_id, de.ver_nr ' ;
     -- raise_application_error(-20000, v_sql);
    execute immediate v_sql;
        --commit;
        
    -- Rule id 2:  Entity alternate question text name exact match
    v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc, mtch_desc_txt)
        select distinct ' || v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr, ''NA'', 2, 100, ''2. Question Text Exact Match'',
        max(r.ref_nm) from ref r, obj_key ok, vw_de de  where ' || v_entty_nm || '  = r.MTCH_TERM         and
        r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
        and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str
        || ' group by r.item_id, r.ver_nr';
    
    execute immediate v_sql;
        --commit;
        
        
    -- Rule id 3:  Entity alternate  name exact match
    v_sql := ' insert into nci_ds_rslt_dtl (hdr_id,mtch_typ,  item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc, mtch_desc_txt)
        select distinct ' || v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr, ''NA'', 3, 100, ''3. Alternate Name Exact Match'',
        max(r.nm_desc) from alt_nms r, vw_de de  where 
       ' || v_entty_nm || '  = r.MTCH_TERM
        and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
        and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and ' || v_flt_str
        || ' group by r.item_id, r.ver_nr';
    execute immediate v_sql;
        --commit;
        
    -- Rule id 4; Only for enumerated, Like
    if (length(v_entty_nm) > v_mtch_min_len) then
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc, mtch_desc_txt)
            select ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr, ''NA'', 4, 100, ''4. Long Name Like Match'', max(de.item_nm) from vw_de  de 
            where ((instr(de.MTCH_TERM, ' || v_entty_nm || ',1) > 0 ) or  (instr(' || v_entty_nm || ', de.MTCH_TERM,1) > 0 ))' ||
            ' and currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
            and length(de.mtch_term) > ' || v_mtch_min_len || '
            and (' || v_hdr_id || ' , de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str
            || ' group by de.item_id, de.ver_nr ' ;
      --  raise_application_error(-20000,v_sql);
        execute immediate v_sql;
        commit;
        
        
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm,  rule_id, score, rule_desc, mtch_desc_txt)
                    select distinct ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr,  ''NA'', 5, 100, ''5. Question Text Like Match'' ,
                    max(r.ref_nm) from ref r, obj_key ok, vw_de de
                    where ((instr(r.MTCH_TERM,' || v_entty_nm || ', 1) > 0  )   or (instr(' || v_entty_nm || ',r.MTCH_TERM, 1) > 0  ))  and length(r.mtch_term) > ' || v_mtch_min_len || '   and de.ADMIN_STUS_NM_DN not like ''%RETIRED%'' and
                    r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and r.ref_nm != ''%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (' || v_hdr_id || ', r.item_id, r.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str
                    || ' group by r.item_id, r.ver_nr';
                --      raise_application_error(-20000, v_sql);
        execute immediate v_sql;
              
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr,  perm_val_nm, rule_id, score, rule_desc, mtch_desc_txt)
                    select distinct ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr, ''NA'', 6, 100, ''6. Alternate Name Like Match'', 
                    max(r.nm_Desc) from alt_nms r, vw_de de
                    where ((instr(r.MTCH_TERM, ' || v_entty_nm || ',1) > 0)  or (instr(' || v_entty_nm || ',r.MTCH_TERM,1) > 0)) and length(r.mtch_term) > ' || v_mtch_min_len || '  
                    and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ', r.item_id, r.ver_nr) not  in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and ' || v_flt_str
                    || ' group by r.item_id, r.ver_nr';
        execute immediate v_sql;                       
    end if;
     
commit;
              -- if (usr_tips_ind = 1) then
                    update nci_ds_rslt_dtl set rule_desc = rule_desc || ' (' || v_suffix || ')' where hdr_id = v_hdr_id;
                    commit;
                --    end if;
    
-- Second level run for PV comparisons
-- if called from CDE math
-- jira 3904: set pv filter string if null
-- jira 4104: user tip overrides pv/vm entry
if (v_pv_flt_str is null or v_pv_flt_str = '' or v_pv_flt_str = 'N') then
    v_pv_filter := '1=1';
    v_pv_cnt := 0;
else
    v_pv_cnt := regexp_count(v_pv_flt_str, ',') + 1;
    v_pv_filter := 'upper(perm_val_nm) ' || v_pv_flt_str;
end if;
--raise_application_error(-20000, v_pv_flt_str);
--jira 3973: set source column for PV/VM matching
if (v_mode = 'VM') then
    v_src_dtl := 'nvl(ENTTY_NM_USR,VAL_MEAN_NM)';
else
    v_src_dtl := 'nvl(ENTTY_NM_USR,PERM_VAL_NM)';
end if;

if (v_mtch_typ = 'CDE_MATCH') then
for cur in (select hdr_id,(count(*) - v_pv_cnt) cnt from nci_ds_dtl d where hdr_id = v_hdr_id  group by hdr_id) loop

--jira 3904: change to dynamic queries to allow users to ignore selected PVs

--    v_sql := 'insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP) select ' || cur.hdr_id || ', de_item_id item_id, de_ver_nr ver_nr, ' || cur.cnt || ', count(*), dtl.rule_Desc, ' 
--            || '''' || 'CDE' || '''' || ' from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_nr = ai.ver_nr and ' ||
--            'dtl.hdr_id = ' || cur.hdr_id || ' and dtl.item_id = de_item_id and dtl.ver_nr = de_ver_nr and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id = ' || cur.hdr_id || ' and ' ||
--            v_pv_filter || ') ' ||
--            'group by de_item_id, de_ver_nr, dtl.rule_Desc having count(*) = ' || cur.cnt;
    v_sql := 'insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP, mtch_desc_txt) select ' || cur.hdr_id || ', de_item_id item_id, de_ver_nr ver_nr, ' || cur.cnt || ', count(*), dtl.rule_Desc || ''(PV)'', ' 
            || '''' || 'CDE' || '''' || ', max(dtl.mtch_desc_txt) from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_nr = ai.ver_nr and ' ||
            'dtl.hdr_id = ' || cur.hdr_id || ' and dtl.item_id = de_item_id and dtl.ver_nr = de_ver_nr and upper(v.perm_val_nm) in (select upper(' || v_src_dtl || ') from nci_ds_dtl where hdr_id = ' || cur.hdr_id || ' and ' ||
            v_pv_filter || ') ' ||
            'group by de_item_id, de_ver_nr, dtl.rule_Desc having count(*) = ' || cur.cnt;
    execute immediate v_sql;

if  (sql%rowcount = 0) then
    v_sql := 'insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP, mtch_desc_txt) select ' || cur.hdr_id || ', de_item_id item_id, de_ver_nr ver_nr, ' || cur.cnt || ', count(*), dtl.rule_Desc || ''(VM)'', ' 
            || '''' || 'CDE' || '''' || ', max(dtl.mtch_desc_txt) from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_nr = ai.ver_nr and ' ||
            'dtl.hdr_id = ' || cur.hdr_id || ' and dtl.item_id = de_item_id and dtl.ver_nr = de_ver_nr and upper(v.item_nm) in (select upper(' || v_src_dtl || ') from nci_ds_dtl where hdr_id = ' || cur.hdr_id || ' and ' ||
            v_pv_filter || ') ' ||
            'group by de_item_id, de_ver_nr, dtl.rule_Desc having count(*) = ' || cur.cnt;
    execute immediate v_sql;
end if;
--same queries as above but with percent match
if  (sql%rowcount = 0) then
    v_sql := 'insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP, mtch_desc_txt) select ' || cur.hdr_id || ', de_item_id item_id, de_ver_nr ver_nr, ' || cur.cnt || ', count(*), dtl.rule_Desc || ''(PV)'', ' 
            || '''' || 'CDE' || '''' || ', max(dtl.mtch_desc_txt) from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_nr = ai.ver_nr and ' ||
            'dtl.hdr_id = ' || cur.hdr_id || ' and dtl.item_id = de_item_id and dtl.ver_nr = de_ver_nr and upper(v.perm_val_nm) in (select upper(' || v_src_dtl || ') from nci_ds_dtl where hdr_id = ' || cur.hdr_id || ' and ' ||
            v_pv_filter || ') ' ||
            'group by de_item_id, de_ver_nr, dtl.rule_Desc having count(*) >= ' || cur.cnt * v_mtch_pcnt;
    execute immediate v_sql;
end if;
if  (sql%rowcount = 0) then
    v_sql := 'insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP, mtch_desc_txt) select ' || cur.hdr_id || ', de_item_id item_id, de_ver_nr ver_nr, ' || cur.cnt || ', count(*), dtl.rule_Desc || ''(VM)'', ' 
            || '''' || 'CDE' || '''' || ', max(dtl.mtch_desc_txt) from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_nr = ai.ver_nr and ' ||
            'dtl.hdr_id = ' || cur.hdr_id || ' and dtl.item_id = de_item_id and dtl.ver_nr = de_ver_nr and upper(v.item_nm) in (select upper(' || v_src_dtl || ') from nci_ds_dtl where hdr_id = ' || cur.hdr_id || ' and ' ||
            v_pv_filter || ') ' ||
            'group by de_item_id, de_ver_nr, dtl.rule_Desc having count(*) >= ' || cur.cnt * v_mtch_pcnt;
    execute immediate v_sql;
end if;

--raise_application_error(-20000, to_char(sql%rowcount));
if (sql%rowcount = 0 ) then --longest term like match
    delete from nci_ds_rslt_dtl where hdr_id = v_hdr_id;
    commit;
        v_entty_nm_with_space := v_entty_nm;             
        v_word_cnt := nci_11179.getwordcount(v_entty_nm_with_space);
        v_sel_word := 'x';
 
        for j in 1..v_word_cnt loop
            v_cur_word:= nci_11179.getWord(v_entty_nm_with_space,j, v_word_cnt);
            if (length(v_cur_word) > length(v_sel_word)) then
                v_sel_word := v_cur_Word;
            end if;
        end loop;
 
        v_sel_word := regexp_replace(upper(v_sel_word),v_reg_str_adv,'');

        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc, mtch_desc_txt)
            select ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr, ''NA'', 4, 100, ''7. Longest Term Like Match'' ,
            max(de.item_nm) from vw_de  de 
            where ((MTCH_TERM_ADV  like ''%' || v_sel_word || '%'') or  (''' ||   v_sel_word || ''' like ''%'' || MTCH_TERM_ADV || ''%'' )) and length(mtch_term_adv) >= length(''' ||  v_sel_word || ''') ' ||
            ' and currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
            and length(de.mtch_term_adv) > ' || v_mtch_min_len || '
            and (' || v_hdr_id || ' , de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str
            || ' group by de.item_id, de.ver_nr';
        execute immediate v_sql;

        spDSSubPVVMDynmcSQL(v_hdr_id, v_mtch_typ, v_entty_nm, v_sel_word, v_mtch_min_len, v_flt_str, v_pv_cnt, v_src_dtl, v_pv_filter, v_mtch_pcnt); 
end if;
--END JIRA 3904-----------------
       -- raise_application_error(-20000, 'here3');
--CODE BEFORE 3904----------------------------------------
--insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP)
--select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*), dtl.rule_Desc, 'CDE'  from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl
--where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR
--and dtl.hdr_id = cur.hdr_id and dtl.item_id =  de_item_id and dtl.ver_nr = de_ver_nr 
--and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
--group by de_item_id,  de_ver_nr ,dtl.rule_Desc having count(*) = cur.cnt;
--
----commit;
----jira 3815: do not stop matching pvs
--if  (sql%rowcount = 0) then
--insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP )
--select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*) , dtl.rule_Desc , 'CDE' from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl
--where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR 
--and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
--and dtl.hdr_id = cur.hdr_id and dtl.item_id =  de_item_id and dtl.ver_nr = de_ver_nr group by de_item_id,
--de_ver_nr ,dtl.rule_Desc having count(*) = cur.cnt;
------AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
------commit;
--end if;
--
--if  (sql%rowcount = 0) then
--insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP)
--select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*), dtl.rule_Desc  , 'CDE' from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl
--where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR 
--and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
--and dtl.hdr_id = cur.hdr_id and dtl.item_id =  de_item_id and dtl.ver_nr = de_ver_nr group by de_item_id, de_ver_nr,dtl.rule_Desc  having count(*) >= cur.cnt*0.5;
----AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
----commit;
--end if;
--
--if  (sql%rowcount = 0) then
--insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP)
--select distinct cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*), dtl.rule_Desc, 'CDE'
--from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
--v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
--and dtl.hdr_id = cur.hdr_id and dtl.item_id =  de_item_id and dtl.ver_nr = de_ver_nr
--group by de_item_id, de_ver_nr,dtl.rule_Desc having count(*) > cur.cnt*0.5;
----AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
----commit;
--end if;
commit;
end loop;

end if;
if (v_mtch_typ = 'QUESTION_MATCH') then
for cur in (select quest_imp_id,count(*) cnt from nci_STG_FORM_VV_IMPORT d where quest_imp_id = v_hdr_id  group by quest_imp_id) loop

insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP)
select cur.quest_imp_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*) , dtl.rule_desc, 'CDE' from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR
and dtl.hdr_id = cur.quest_imp_id and dtl.item_id =  de_item_id and dtl.ver_nr =  de_ver_nr
and upper(v.perm_val_nm) in (select upper(src_perm_val) from NCI_STG_FORM_VV_IMPORT where quest_imp_id =cur.quest_imp_id)
group by de_item_id,  de_ver_nr,dtl.rule_desc having count(*) >= cur.cnt*0.5;
--commit;

--if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP)
select cur.quest_imp_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*) , dtl.rule_desc, 'CDE' from vw_nci_de_pv v, admin_item ai, nci_ds_rslt_dtl dtl
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR
and (cur.quest_imp_id, de_item_id, de_ver_nr) not in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.quest_imp_id)
and upper(v.item_nm) in (select upper(SRC_VM_NM) from NCI_STG_FORM_VV_IMPORT where quest_imp_id =cur.quest_imp_id)
and dtl.hdr_id = cur.quest_imp_id and dtl.item_id =  de_item_id and dtl.ver_nr =  de_ver_nr
group by de_item_id,  de_ver_nr,dtl.rule_desc having count(*) >= cur.cnt*0.5;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
--end if;
/*
if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select distinct cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)
from vw_nci_de_pv_lean v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
group by de_item_id, de_ver_nr having count(*) > cur.cnt*0.5;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;*/
commit;
     end loop; 
end if;
  
END;

--only called from spDSMatchEnum-- when no results are found, extend the search to Longest Term like match and re run pv vm queries
procedure spDSSubPVVMDynmcSQL(v_hdr_id in number, v_mtch_typ in varchar2, v_entty_nm in varchar2, v_sel_word in varchar2, v_mtch_min_len in number, v_flt_str in varchar2, v_pv_cnt in number, v_src_dtl in varchar2, v_pv_filter in varchar2, v_mtch_pcnt in number)
AS
v_sql varchar2(4000);

BEGIN

for cur in (select hdr_id,(count(*) - v_pv_cnt) cnt from nci_ds_dtl d where hdr_id = v_hdr_id  group by hdr_id) loop

    v_sql := 'insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP, mtch_desc_txt) select ' || cur.hdr_id || ', de_item_id item_id, de_ver_nr ver_nr, ' || cur.cnt || ', count(*), dtl.rule_Desc || ''(PV)'', ' 
            || '''' || 'CDE' || '''' || ', max(dtl.mtch_desc_txt) from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_nr = ai.ver_nr and ' ||
            'dtl.hdr_id = ' || cur.hdr_id || ' and dtl.item_id = de_item_id and dtl.ver_nr = de_ver_nr and upper(v.perm_val_nm) in (select upper(' || v_src_dtl || ') from nci_ds_dtl where hdr_id = ' || cur.hdr_id || ' and ' ||
            v_pv_filter || ') ' ||
            'group by de_item_id, de_ver_nr, dtl.rule_Desc having count(*) = ' || cur.cnt;
    execute immediate v_sql;

if  (sql%rowcount = 0) then
    v_sql := 'insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP, mtch_desc_txt) select ' || cur.hdr_id || ', de_item_id item_id, de_ver_nr ver_nr, ' || cur.cnt || ', count(*), dtl.rule_Desc || ''(VM)'', ' 
            || '''' || 'CDE' || '''' || ', max(dtl.mtch_desc_txt) from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_nr = ai.ver_nr and ' ||
            'dtl.hdr_id = ' || cur.hdr_id || ' and dtl.item_id = de_item_id and dtl.ver_nr = de_ver_nr and upper(v.item_nm) in (select upper(' || v_src_dtl || ') from nci_ds_dtl where hdr_id = ' || cur.hdr_id || ' and ' ||
            v_pv_filter || ') ' || 
            'group by de_item_id, de_ver_nr, dtl.rule_Desc having count(*) = ' || cur.cnt;
    execute immediate v_sql;
end if;
--same queries as above but with percent match
if  (sql%rowcount = 0) then
    v_sql := 'insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP, mtch_desc_txt) select ' || cur.hdr_id || ', de_item_id item_id, de_ver_nr ver_nr, ' || cur.cnt || ', count(*), dtl.rule_Desc || ''(PV)'', ' 
            || '''' || 'CDE' || '''' || ', max(dtl.mtch_desc_txt) from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_nr = ai.ver_nr and ' ||
            'dtl.hdr_id = ' || cur.hdr_id || ' and dtl.item_id = de_item_id and dtl.ver_nr = de_ver_nr and upper(v.perm_val_nm) in (select upper(' || v_src_dtl || ') from nci_ds_dtl where hdr_id = ' || cur.hdr_id || ' and ' ||
            v_pv_filter || ') ' ||
            'group by de_item_id, de_ver_nr, dtl.rule_Desc having count(*) >= ' || cur.cnt * v_mtch_pcnt;
    execute immediate v_sql;
end if;
if  (sql%rowcount = 0) then
    v_sql := 'insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP, mtch_desc_txt) select ' || cur.hdr_id || ', de_item_id item_id, de_ver_nr ver_nr, ' || cur.cnt || ', count(*), dtl.rule_Desc || ''(VM)'', ' 
            || '''' || 'CDE' || '''' || ', max(dtl.mtch_desc_txt) from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_nr = ai.ver_nr and ' ||
            'dtl.hdr_id = ' || cur.hdr_id || ' and dtl.item_id = de_item_id and dtl.ver_nr = de_ver_nr and upper(v.item_nm) in (select upper(' || v_src_dtl || ') from nci_ds_dtl where hdr_id = ' || cur.hdr_id || ' and ' ||
            v_pv_filter || ') ' ||
            'group by de_item_id, de_ver_nr, dtl.rule_Desc having count(*) >= ' || cur.cnt * v_mtch_pcnt;
    execute immediate v_sql;
end if;
end loop;
commit;
END;


procedure setPrefCDE ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
  v_sys_msg varchar2(2000) := '';
  v_temp number;
  v_run_typ varchar2(32);
  v_run_dt timestamp;
  
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
row := t_row();
--select count(*) into v_temp from nci_ds_hdr where hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID') and LST_RUN_TYP is not null;
/*if v_temp > 0 then
    UPDATE nci_ds_hdr 
    SET cde_item_id = ihook.getColumnValue(row_ori, 'ITEM_ID'), 
        cde_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR'),
        num_pv_in_src = ihook.getColumnValue(row_ori, 'NUM_PV_IN_SRC'),
        num_pv_in_cde = ihook.getColumnValue(row_ori, 'NUM_PV_IN_CDE'),
        num_pv_mtch = ihook.getColumnValue(row_ori, 'NUM_PV_MTCH'),
        rule_desc = ihook.getColumnValue(row_ori, 'RULE_DESC'),
        mtch_desc_txt = ihook.getColumnValue(row_ori, 'MTCH_DESC_TXT'),
        SYS_MSG = getDSSysMsg(ihook.getColumnValue(row_ori, 'HDR_ID'), 'CDE')
    WHERE hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
    COMMIT;
end if;*/
            
       ihook.setColumnValue(row, 'HDR_ID', ihook.getColumnValue(row_ori, 'HDR_ID'));
        ihook.setColumnValue(row, 'CDE_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row, 'CDE_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
        ihook.setColumnValue(row, 'NUM_PV_IN_SRC', ihook.getColumnValue(row_ori, 'NUM_PV_IN_SRC'));
        ihook.setColumnValue(row, 'NUM_PV_IN_CDE', ihook.getColumnValue(row_ori, 'NUM_PV_IN_CDE'));
        ihook.setColumnValue(row, 'NUM_PV_MTCH', ihook.getColumnValue(row_ori, 'NUM_PV_MTCH'));
        ihook.setColumnValue(row, 'RULE_DESC', ihook.getColumnValue(row_ori, 'RULE_DESC'));
        ihook.setColumnValue(row, 'MTCH_DESC_TXT', ihook.getColumnValue(row_ori, 'MTCH_DESC_TXT'));
        ihook.setColumnValue(row, 'SYS_MSG', getDSSysMsg(ihook.getColumnValue(row_ori, 'HDR_ID'), 'CDE'));
--            if (ihook.getColumnValue(row_ori, 'NUM_PV_IN_SRC') is not null) then
--                ihook.setColumnValue(row, 'SYS_MSG', v_sys_msg || 'Preferred CDE set to ' || ihook.getColumnValue(row_ori, 'ITEM_ID')|| 'v' || ihook.getColumnValue(row_ori, 'VER_NR') || ' <BR> Source PVs ' || ihook.getColumnValue(row_ori, 'NUM_PV_IN_SRC') || ' - Matched PVs ' || ihook.getColumnValue(row_ori, 'NUM_PV_MTCH') || ' - CDE PVs ' || ihook.getColumnValue(row_ori, 'NUM_PV_IN_CDE'));
--            else
--                ihook.setColumnValue(row, 'SYS_MSG', v_sys_msg || 'Preferred CDE set to ' || ihook.getColumnValue(row_ori, 'ITEM_ID')|| 'v' || ihook.getColumnValue(row_ori, 'VER_NR') || '.');
--            end if;
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'DS Entity To Match', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;


    hookoutput.actions    := actions;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


 procedure setPrefCDEQuest ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
row := t_row();
 
            ihook.setColumnValue(row, 'QUEST_IMP_ID', ihook.getColumnValue(row_ori, 'HDR_ID'));
            ihook.setColumnValue(row, 'CDE_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
            ihook.setColumnValue(row, 'CDE_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'Form Module-Question Import', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;


    hookoutput.actions    := actions;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

 
 procedure setPrefVM ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
  v_found boolean := false;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
row := t_row();
 
 for cur in (Select * from admin_item where admin_item_typ_id in (53) and item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')) loop
            ihook.setColumnValue(row, 'HDR_ID', ihook.getColumnValue(row_ori, 'HDR_ID'));
            ihook.setColumnValue(row, 'CDE_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
            ihook.setColumnValue(row, 'CDE_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
            ihook.setColumnValue(row, 'PREF_CNCPT_CONCAT', ihook.getColumnValue(row_ori, 'ITEM_ID'));
            ihook.setColumnValue(row, 'PREF_CNCPT_CONCAT_NM', '');
              ihook.setColumnValue(row, 'PREF_CNCPT_CONCAT_DEF', '');
               ihook.setColumnValue(row, 'EVS_SRC_ORI', '');
          ihook.setColumnValue(row, 'VM_MTCH_ITEM_TYP', 'ID');
            
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;
            hookoutput.message := 'Preferred Item Set.';
            action             := t_actionrowset(rows, 'VM Match Header', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
            v_found := true;
                  hookoutput.actions := actions;
end loop;

 for cur in (Select * from admin_item where admin_item_typ_id in (2) and item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')) loop
            ihook.setColumnValue(row, 'HDR_ID', ihook.getColumnValue(row_ori, 'HDR_ID'));
            ihook.setColumnValue(row, 'CDE_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
            ihook.setColumnValue(row, 'CDE_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
            ihook.setColumnValue(row, 'DE_CONC_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
            ihook.setColumnValue(row, 'DE_CONC_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;
            hookoutput.message := 'Preferred Item Set.';
        --    raise_application_error(-20000,cur.item_id);
            action             := t_actionrowset(rows, 'DEC Match Header', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
            v_found := true;
            hookoutput.actions := actions;
end loop;

if (v_found = false) then

 for cur in (Select * from vw_cncpt where   item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')) loop
            update nci_ds_hdr set cde_item_id = null, cde_ver_nr = null, pref_cncpt_concat = trim(nvl(decode(VM_MTCH_ITEM_TYP, 'ID', '',pref_cncpt_concat) ,'')|| ' '  || cur.item_long_nm),
            pref_cncpt_concat_nm = trim(nvl( decode(VM_MTCH_ITEM_TYP, 'ID', '',pref_cncpt_concat_nm) ,'')|| ' '  || cur.item_nm),
            pref_cncpt_concat_def = trim( decode(VM_MTCH_ITEM_TYP, 'ID', '',pref_cncpt_concat_def ) || nvl2(pref_cncpt_concat_def, '_','')  || cur.item_desc),
            evs_src_ori = trim(nvl( decode(VM_MTCH_ITEM_TYP, 'ID', '',evs_src_ori) ,'')|| ' '  || cur.evs_src_ori),
     
            vm_mtch_item_typ = 'Concepts'
            where hdr_id = ihook.getColumnValue(row_ori, 'HDR_ID');
            commit;
            hookoutput.message := 'Appended to preferred concept string.';
            
end loop;
end if;
  

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

 

 procedure setPrefDEC ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
  v_found boolean := false;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
row := t_row();
 
 for cur in (Select * from admin_item where admin_item_typ_id in (2) and item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')) loop
            ihook.setColumnValue(row, 'HDR_ID', ihook.getColumnValue(row_ori, 'HDR_ID'));
            ihook.setColumnValue(row, 'DE_CONC_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
            ihook.setColumnValue(row, 'DE_CONC_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;
            hookoutput.message := 'Preferred DEC Set.';
        --    raise_application_error(-20000,cur.item_id);
            action             := t_actionrowset(rows, 'DS Entity To Match', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;
            v_found := true;
            hookoutput.actions := actions;
end loop;


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

procedure spVMMatch49 ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_typ in varchar2, v_pref in varchar2)

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
    v_code varchar2(255);
    v_rule_desc varchar2(255);
    v_cncpt_nm varchar2(255);
--    v_reg_str varchar2(255);
 -- v_entty_nm varchar2(4000);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   
   nci_util.debugHook('GENERAL', v_data_in);
  --  v_reg_str := '\(|\)|\;|\-|\_|\|';
    rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
 
        row_ori := hookInput.originalRowset.rowset(i);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
    --    v_entty_nm := regexp_replace(upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM'))),'\(|\)|\;|\-|\_','');
      v_entty_nm := regexp_replace(upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM'))),v_reg_str_adv,'');
        v_entty_nm_with_space := upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM')));
    --raise_application_error(-20000,v_minlen);
     delete from nci_ds_rslt where hdr_id =v_hdr_id ;
    commit;
--raise_application_error(-20000,'Test' || ihook.getColumnValue(row_ori,'MATCH_TYP'));
  if (ihook.getColumnValue(row_ori,'MTCH_TYP_NM') = 'VM') then
      VMMatchSub49(v_hdr_id, v_entty_nm,v_entty_nm_with_space,v_typ, v_pref);
    elsif (ihook.getColumnValue(row_ori,'MTCH_TYP_NM') = 'DEC') then
      DECMatchSub(v_hdr_id, v_entty_nm,v_entty_nm_with_space,v_typ,row_ori);
    end if;
   select count(*) into v_temp from nci_ds_rslt where hdr_id = v_hdr_id     ;
  if (v_temp = 1) then
    select rule_desc into v_rule_desc from nci_ds_rslt where hdr_id=v_hdr_id;
    if (v_rule_desc like '%Concept%') then
        select item_long_nm, item_nm into v_code, v_cncpt_nm from vw_cncpt where item_id = (select item_id from nci_ds_rslt where hdr_id=v_hdr_id);
        update nci_ds_hdr set (NUM_CDE_MTCH, CDE_ITEM_ID, CDE_VER_NR, LST_UPD_USR_ID, PREF_CNCPT_CONCAT, PREF_CNCPT_CONCAT_NM, 	VM_MTCH_ITEM_TYP) 
        = (select 1, item_id, ver_nr , v_user_id, v_code,v_cncpt_nm, 'Concepts' from nci_ds_rslt where hdr_id = v_hdr_id)
        where hdr_id = v_hdr_id;
    else
        update nci_ds_hdr set (NUM_CDE_MTCH, CDE_ITEM_ID, CDE_VER_NR, LST_UPD_USR_ID, PREF_CNCPT_CONCAT, PREF_CNCPT_CONCAT_NM, 	VM_MTCH_ITEM_TYP) 
        = (select 1, item_id, ver_nr , v_user_id, item_id,null, 'ID' from nci_ds_rslt where hdr_id = v_hdr_id)
        where hdr_id = v_hdr_id;
    end if;
  else
  update nci_ds_hdr set NUM_CDE_MTCH = v_temp, num_dec_mtch = v_temp
  where hdr_id = v_hdr_id;
  end if;
  commit;
  
end loop;
  
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  
end;

procedure spVMMatchDynmc ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_typ in varchar2, v_pref in varchar2, v_ext in varchar2)

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
    v_code varchar2(255);
    v_rule_desc varchar2(255);
    v_cncpt_nm varchar2(255);
    v_evs_src varchar2(500);
    v_cncpt_def varchar2(8000);
--    v_reg_str varchar2(255);
 -- v_entty_nm varchar2(4000);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   
--   nci_util.debugHook('GENERAL', v_data_in);
  --  v_reg_str := '\(|\)|\;|\-|\_|\|';
    rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
 
        row_ori := hookInput.originalRowset.rowset(i);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
    --    v_entty_nm := regexp_replace(upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM'))),'\(|\)|\;|\-|\_','');
      v_entty_nm := regexp_replace(upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM'))),v_reg_str_adv,'');
        v_entty_nm_with_space := upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM')));
    --raise_application_error(-20000,v_minlen);
     delete from nci_ds_rslt where hdr_id =v_hdr_id;
    commit;
--raise_application_error(-20000,'Test' || ihook.getColumnValue(row_ori,'MATCH_TYP'));
  if (ihook.getColumnValue(row_ori,'MTCH_TYP_NM') = 'VM') then
      VMMatchFlow(v_hdr_id, v_entty_nm,v_entty_nm_with_space,v_typ, v_pref, v_ext);
    elsif (ihook.getColumnValue(row_ori,'MTCH_TYP_NM') = 'DEC') then
      DECMatchSub(v_hdr_id, v_entty_nm,v_entty_nm_with_space,v_typ,row_ori);
    end if;
   select count(*) into v_temp from nci_ds_rslt where hdr_id = v_hdr_id;
  if (v_temp = 1) then
    select rule_desc into v_rule_desc from nci_ds_rslt where hdr_id=v_hdr_id;
  --  raise_application_error(-20000,'Test ' || v_rule_desc);
    if (v_rule_desc like '%Concept%' or v_rule_desc like '%Synonym%') then
        select evs_src_ori into v_evs_src from vw_cncpt where item_id = (select item_id from nci_ds_rslt where hdr_id = v_hdr_id);
        select item_long_nm, item_nm, item_desc into v_code, v_cncpt_nm, v_cncpt_def from vw_cncpt where item_id = (select item_id from nci_ds_rslt where hdr_id=v_hdr_id);
        update nci_ds_hdr set (NUM_CDE_MTCH, CDE_ITEM_ID, CDE_VER_NR, LST_UPD_USR_ID, PREF_CNCPT_CONCAT, PREF_CNCPT_CONCAT_NM, 	VM_MTCH_ITEM_TYP, EVS_SRC_ORI, PREF_CNCPT_CONCAT_DEF) 
        = (select 1, null, null, v_user_id, v_code,v_cncpt_nm, 'Concepts', v_evs_src, v_cncpt_def from nci_ds_rslt where hdr_id = v_hdr_id)
        where hdr_id = v_hdr_id;
    else
        update nci_ds_hdr set (NUM_CDE_MTCH, CDE_ITEM_ID, CDE_VER_NR, LST_UPD_USR_ID, PREF_CNCPT_CONCAT, PREF_CNCPT_CONCAT_NM, 	VM_MTCH_ITEM_TYP, EVS_SRC_ORI, PREF_CNCPT_CONCAT_DEF) 
        = (select 1, item_id, ver_nr , v_user_id, item_id,null, 'ID', v_evs_src, v_cncpt_def from nci_ds_rslt where hdr_id = v_hdr_id)
        where hdr_id = v_hdr_id;
    end if;
  else
  update nci_ds_hdr set NUM_CDE_MTCH = v_temp, num_dec_mtch = v_temp
  where hdr_id = v_hdr_id;
  end if;
  commit;
  
end loop;
  
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  
end;

procedure VMMatchFlow ( v_hdr_id in number,  v_entty_nm in varchar2, v_entty_nm_with_space  in varchar2, v_typ in varchar2, v_pref in varchar2, v_ext in varchar2) AS
v_cnt integer := 0;
v_temp integer;
v_runTyp varchar2(128);
begin
--VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'V');
--VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'C');
--VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'S');
--VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'V');
--VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'C');
--VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'S');
--v_entty_nm := regexp_replace(upper(nvl((select entty_nm_usr from nci_ds_hdr where hdr_id = v_hdr_id),(select entty_nm from nci_ds_hdr where hdr_id = v_hdr_id))),v_reg_str_adv,'');
--v_entty_nm_with_space := upper(nvl((select entty_nm_usr from nci_ds_hdr where hdr_id = v_hdr_id),(select entty_nm from nci_ds_hdr where hdr_id = v_hdr_id))));
    delete from nci_ds_rslt where hdr_id =v_hdr_id;
    commit;
if (v_pref='V') then
    VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'V', v_ext);
    v_runTyp := 'Run Match - VMs Only';
    select count(*) into v_temp from nci_ds_rslt where hdr_id = v_hdr_id;
    if (v_temp < 1 or v_typ='U') then
        VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'V', v_ext);
        if (v_typ = 'U') then
            VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'L', 'V', v_ext);
            v_runTyp := 'Run Unrestricted - VMs Only';
        end if;
    end if;
elsif (v_pref='C') then
    VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'C', v_ext);
    VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'S', v_ext);
    v_runTyp := 'Run Match - Concepts Only';
    select count(*) into v_temp from nci_ds_rslt where hdr_id = v_hdr_id;
    if (v_temp < 1 or v_typ='U') then
        VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'C', v_ext);
        VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'S', v_ext);
        if (v_typ='U') then
            VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'L', 'C', v_ext);
            VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'L', 'S', v_ext);
            v_runTyp := 'Run Unrestricted - Concepts Only';
        end if;
    end if;
else
    VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'V', v_ext);
    VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'C', v_ext);
    VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'R', 'S', v_ext);
    v_runTyp := 'Run Match';
    select count(*) into v_temp from nci_ds_rslt where hdr_id = v_hdr_id;
    if (v_temp < 1 or v_typ='U') then
        VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'V', v_ext);
        VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'C', v_ext);
        VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'U', 'S', v_ext);
        if (v_typ='U') then
            VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'L', 'V', v_ext);
            VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'L', 'C', v_ext);
            VMMatchSubDynmcSQL(v_hdr_id, v_entty_nm, v_entty_nm_with_space, 'L', 'S', v_ext);
            v_runTyp := 'Run Match Unrestricted';
        end if;
    end if;
end if;
update nci_ds_hdr set lst_run_typ = v_runTyp where hdr_id = v_hdr_id;
end;


procedure VMMatchSubDynmcSQL ( v_hdr_id in number,  v_entty_nm in varchar2, v_entty_nm_with_space  in varchar2, v_typ in varchar2, v_pref in varchar2, v_ext in varchar2) AS
v_minlen integer;
v_cur_word  varchar2(4000);
v_sel_word varchar2(4000);
j integer;
v_word_cnt integer;
v_flt_str  varchar2(1000);
v_sql varchar2(4000);
v_tbl varchar2(128);
v_ruleNo integer := 1;
v_ruleTyp varchar2(16);
v_ruleDesc varchar2(128);
v_cnt integer;
v_mtchTerm varchar2(128);
v_length varchar2(64);
v_compLength varchar2(64);
begin
    
       --  raise_application_error(-20000, v_entty_nm);
         
  v_minlen := nci_11179.getMinWordLen(v_entty_nm_with_space);
  -- sp48 jira 2550
v_flt_str := '1=1';
if (v_pref='V' and v_typ='R') then
    v_tbl := 'MVW_VAL_MEAN';
    v_ruleTyp := 'VM';
    v_ruleDesc := '1. VM Exact Match';
    v_mtchTerm := 'MTCH_TERM_ADV';
    v_length := 'mtch_term';
elsif (v_pref='C' and v_typ='R') then
    v_tbl := 'VW_CNCPT';
    v_ruleTyp:= 'Concept';
    v_ruleDesc := '2. Concept Exact Match';
    v_flt_str := 'CNTXT_NM_DN = ''NCIP''';
    v_mtchTerm := 'MTCH_TERM_ADV';
    v_length := 'item_nm';
elsif (v_pref='S' and v_typ='R') then -- Synonym, only called recursively
    v_tbl := 'VW_CNCPT';
    v_ruleTyp:= 'Synonym';
    v_ruleDesc := '3. Synonym Exact Match';
    v_flt_str := '1=1';
    v_mtchTerm := 'SYN_MTCH_TERM';
    v_length := 'mtch_term';
elsif (v_pref='V' and v_typ='U') then
    v_tbl := 'MVW_VAL_MEAN';
    v_ruleDesc := '4. VM Like Match';
    v_mtchTerm := 'MTCH_TERM_ADV';
    v_length := 'mtch_term';
    v_compLength := 'length(v_sel_word)';
elsif (v_pref='C' and v_typ='U') then
    v_tbl := 'VW_CNCPT';
    v_ruleDesc := '5. Concept Like Match';
    v_flt_str := 'CNTXT_NM_DN = ''NCIP''';
    v_mtchTerm := 'MTCH_TERM_ADV';
    v_length := 'item_nm';
    v_compLength := '';
elsif (v_pref='S' and v_typ='U') then
    v_tbl := 'VW_CNCPT';
    v_ruleDesc := '6. Synonym Like Match';
    v_flt_str := '1=1';
    v_mtchTerm := 'SYN_MTCH_TERM';
    v_length := 'mtch_term';
    v_compLength := '';
elsif (v_pref='V' and v_typ='L') then
    v_tbl := 'MVW_VAL_MEAN';
    v_ruleDesc := '7. VM Like Match Largest Word';
    v_mtchTerm := 'MTCH_TERM_ADV';
    v_length := 'mtch_term_adv';
    v_compLength := 'length(v_sel_word)';
elsif (v_pref='C' and v_typ='L') then
    v_tbl := 'VW_CNCPT';
    v_ruleDesc := '8. Concept Like Match Largest Word';
    v_flt_str := 'CNTXT_NM_DN = ''NCIP''';
    v_mtchTerm := 'MTCH_TERM_ADV';
    v_length := 'item_nm';
    v_compLength := to_char(v_minlen);
elsif (v_pref='S' and v_typ='L') then
    v_tbl := 'VW_CNCPT';
    v_ruleDesc := '9. Synonym Like Match Largest Word';
    v_flt_str := '1=1';
    v_mtchTerm := 'SYN_MTCH_TERM';
    v_length := 'syn_mtch_term';
    v_compLength := '';
end if;
    
    if (v_typ = 'R') then
        if  (v_pref in ('V', 'C')) then
                v_sql := 'insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_desc) select distinct ' ||  v_hdr_id || ', t.item_id, t.ver_nr, ''' || v_ruleDesc || ''' from ' 
                || v_tbl || ' t where ''' || v_entty_nm || ''' = t.' || v_mtchTerm ||' and ((' || v_hdr_id || ', item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt))';
               -- raise_application_error (-20000,v_sql);
        else
            v_sql := 'insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_desc) select distinct ' ||  v_hdr_id || ', t.item_id, t.ver_nr, ''' || v_ruleDesc || ''' from ' 
               || v_tbl || ' t where ((t.' || v_mtchTerm || ' like (''' || v_entty_nm || ''' || '' |%'') or t.' || v_mtchTerm || ' like (''%| '' || ''' || v_entty_nm || ''') or t.' || v_mtchTerm || ' like (''%| '' || ''' || v_entty_nm || ''' || '' |%'') or t.' || v_mtchTerm || ' = ''' || v_entty_nm || ''') and ((' || v_hdr_id ||', item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt)))';
        --raise_application_error (-20000,v_sql);
        end if;
        execute immediate v_sql;
        v_cnt := SQL%ROWCOUNT;
        commit;
    elsif (v_typ= 'U') then
        if (v_pref='S') then --unique condition format for Synonym
            v_sql := 'insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_desc) select distinct ' ||  v_hdr_id || ', t.item_id, t.ver_nr, ''' || v_ruleDesc || ''' from ' 
                || v_tbl || ' t where ((t.' || v_mtchTerm || ' like ( ''%'' || '''|| v_entty_nm || ''' || ''%'')) and (' || v_hdr_id ||', item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt))';
                --raise_application_error (-20000,v_sql);
            execute immediate v_sql;
            v_cnt := SQL%ROWCOUNT;
            commit;
        else
            v_sql := 'insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_desc) select distinct ' ||  v_hdr_id || ', t.item_id, t.ver_nr, ''' || v_ruleDesc || ''' from ' 
                || v_tbl || ' t where ((t.' || v_mtchTerm || ' like ( ''%'' || '''|| v_entty_nm || ''' || ''%'')) or (''' || v_entty_nm || ''' like (''%'' || t.' || v_mtchTerm || ' || ''%'') and length(' || v_length || ') >= ' || v_minlen ||')) and (' || v_hdr_id ||', item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt)';
                -- raise_application_error (-20000,v_sql);
        execute immediate v_sql;
        v_cnt := SQL%ROWCOUNT;
        commit;
        end if;
    elsif (v_typ='L') then
        v_word_cnt := nci_11179.getwordcount(v_entty_nm_with_space);
        v_sel_word := 'x';
 
        for j in 1..v_word_cnt loop
            v_cur_word:= nci_11179.getWord(v_entty_nm_with_space,j, v_word_cnt);
            --raise_application_Error(-20000,length(v_sel_word));
            if (length(v_cur_word) > length(v_sel_word)) then
                v_sel_word := v_cur_word;
            end if;
        end loop;
 
        v_sel_word := regexp_replace(upper(v_sel_word),v_reg_str_adv,'');
        --raise_application_error(-20000, 'Hre' || v_sel_word);
        if (v_pref in ('V','S')) then
            v_compLength:=length(v_sel_word);
        end if;
        if (v_pref='S') then
            v_sql := 'insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_desc) select distinct ' ||  v_hdr_id || ', t.item_id, t.ver_nr, ''' || v_ruleDesc || ''' from ' 
                || v_tbl || ' t where ' || v_mtchTerm || ' like ''%'' || ''' || v_sel_word || ''' || ''%'' and length(' || v_length || ') >= ' || nvl(v_compLength, v_minlen) || ' and ' || v_flt_str || ' 
                and (' || v_hdr_id ||', item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt)';
             -- raise_application_error (-20000,v_sql);
        else
            v_sql := 'insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_desc) select distinct ' ||  v_hdr_id || ', t.item_id, t.ver_nr, ''' || v_ruleDesc || ''' from ' 
                || v_tbl || ' t where ((' || v_mtchTerm || ' like ''%'' || ''' || v_sel_word || ''' || ''%'' ) or (''' || v_sel_word || ''' like ''%'' || ' || v_mtchTerm || ' || ''%'' and length(' || v_length || ') >= ' || nvl(v_compLength, v_minlen) || ')) and ' || v_flt_str || ' 
                and (' || v_hdr_id ||', item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt)';
              --  raise_application_error (-20000,v_sql);
        end if;
        execute immediate v_sql;
        v_cnt := SQL%ROWCOUNT;
        commit;
    end if;
    end;
    
procedure VMMatchSub49 ( v_hdr_id in number,  v_entty_nm in varchar2, v_entty_nm_with_space  in varchar2, v_typ in varchar2, v_pref in varchar2) AS
v_minlen integer;
v_cnt integer := 0;
v_cur_word  varchar2(4000);
v_sel_word varchar2(4000);
j integer;
v_word_cnt integer;
begin
    
       --  raise_application_error(-20000, v_entty_nm);
         
  v_minlen := nci_11179.getMinWordLen(v_entty_nm_with_space);
  -- sp48 jira 2550
if (v_pref = 'V') then --vm match only, no concepts
    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '1. VM Exact Match' from 
                    MVW_VAL_MEAN where MTCH_TERM_ADV = v_entty_nm ;
                    
                    --and admin_item_typ_id = 53;
          --          commit;
    --
    -- Vm Alt Name Exact Match
    v_cnt := SQL%ROWCOUNT;
    commit;
    if (v_typ='U' or v_cnt < 1) then 
    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '4. VM Like Match' from 
                    MVW_VAL_MEAN where ((MTCH_TERM_ADV like '%' || v_entty_nm || '%' )  or
                    (v_entty_nm like '%' || MTCH_TERM_ADV || '%' and length(mtch_term) >= v_minlen)) and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt); 
    v_cnt := SQL%ROWCOUNT;
    commit;
   --jira 2851 All VM only unrestricted option
   if (v_typ='U') then 
    v_word_cnt := nci_11179.getwordcount(v_entty_nm_with_space);
    v_sel_word := 'x';
 
    for j in 1..v_word_cnt loop
        v_cur_word:= nci_11179.getWord(v_entty_nm_with_space,j, v_word_cnt);
        --raise_application_Error(-20000,length(v_sel_word));
        if (length(v_cur_word) > length(v_sel_word)) then
            v_Sel_word := v_cur_Word;
        end if;
    end loop;
 
    v_sel_word := regexp_replace(upper(v_sel_word),v_reg_str_adv,'');
 --raise_application_error(-20000, 'Hre' || v_sel_word);
 
    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '7. VM Like Match Largest word' from 
                    MVW_VAL_MEAN where ((MTCH_TERM_ADV like '%' || v_sel_word || '%' )  or
                    (v_sel_word like '%' || MTCH_TERM_ADV || '%'))  and length(mtch_term_adv) >= length(v_sel_word) and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
     commit;
     end if;
     end if;
elsif (v_pref= 'C') then -- concept match only, no vms
    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '2. Concept Exact Match' from 
                    vw_cncpt where MTCH_TERM_ADV = v_entty_nm and CNTXT_NM_DN = 'NCIP'
                    and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    
    v_cnt := SQL%ROWCOUNT;
    commit;
            insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , c.item_id, c.ver_nr, '3. Synonym Exact Match' from 
                    vw_cncpt c where (SYN_MTCH_TERM like v_entty_nm || ' |%' or SYN_MTCH_TERM like '%| ' ||  v_entty_nm  or SYN_MTCH_TERM like '%| '|| v_entty_nm || ' |%')  and (v_hdr_id, c.item_id, c.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    
    v_cnt := v_cnt + SQL%ROWCOUNT;
  commit;
  --if (v_cnt > 0) then
 -- return;
  --end if;
    -- jira 2851 add unrestricted option for concepts
    if (v_typ='U' or v_cnt < 1) then
                          insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '5. Concept Like Match' from 
                    vw_cncpt where MTCH_TERM_ADV  like '%' ||  v_entty_nm || '%' 
                     and CNTXT_NM_DN = 'NCIP'  and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
    v_cnt := v_cnt + SQL%ROWCOUNT;
    commit;
                       insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '5. Concept Like Match' from 
                    vw_cncpt where 
                     v_entty_nm like '%' || MTCH_TERM_ADV || '%' and length(item_nm) >= v_minlen and CNTXT_NM_DN = 'NCIP' 
                      and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         
    v_cnt := v_cnt + SQL%ROWCOUNT;
         commit;
         insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , c.item_id, c.ver_nr, '6. Synonym Like Match' from 
                    vw_cncpt c where SYN_MTCH_TERM like '%' ||  v_entty_nm || '%'   and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
    v_cnt := v_cnt + SQL%ROWCOUNT;
 commit;
    if (v_typ='U') then
    v_word_cnt := nci_11179.getwordcount(v_entty_nm_with_space);
 v_sel_word := 'x';
 
 for j in 1..v_word_cnt loop
 v_cur_word:= nci_11179.getWord(v_entty_nm_with_space,j, v_word_cnt);
 --raise_application_Error(-20000,length(v_sel_word));
 if (length(v_cur_word) > length(v_sel_word)) then
    v_Sel_word := v_cur_Word;
    end if;
 end loop;
 
 v_sel_word := regexp_replace(upper(v_sel_word),v_reg_str_adv,'');
 --raise_application_error(-20000, 'Hre' || v_sel_word);
 insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '8. Concept Like Match Largest Word' from 
                    vw_cncpt where MTCH_TERM_ADV  like '%' ||  v_sel_word || '%' 
                     and CNTXT_NM_DN = 'NCIP'  and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    commit;
    v_cnt := v_cnt + SQL%ROWCOUNT;
    
                       insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '8. Concept Like Match Largest Word' from 
                    vw_cncpt where 
                     v_sel_word like '%' || MTCH_TERM_ADV || '%' and length(item_nm) >= v_minlen and CNTXT_NM_DN = 'NCIP' 
                      and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         
         commit;
                 insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , c.item_id, c.ver_nr, '9. Synonym Like Match Largest Word' from 
                    vw_cncpt c where SYN_MTCH_TERM like '%' ||  v_sel_word || '%' and  length(syn_mtch_term) >= length(v_sel_word)  and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    commit; 
    v_cnt := v_cnt + SQL%ROWCOUNT;
         end if;
         end if;
else -- run match, run match unrestricted

   insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '1. VM Exact Match' from 
                    MVW_VAL_MEAN where MTCH_TERM_ADV = v_entty_nm ;
                    
                    --and admin_item_typ_id = 53;
          --          commit;
    --
    -- Vm Alt Name Exact Match
    v_cnt := SQL%ROWCOUNT;
    commit;
        insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '2. Concept Exact Match' from 
                    vw_cncpt where MTCH_TERM_ADV = v_entty_nm and CNTXT_NM_DN = 'NCIP'
                    and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         --           commit;
    v_cnt := v_cnt + SQL%ROWCOUNT;
    commit;
        insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , c.item_id, c.ver_nr, '3. Synonym Exact Match' from 
                    vw_cncpt c where (SYN_MTCH_TERM like v_entty_nm || ' |%'
                    or SYN_MTCH_TERM like '%| ' ||  v_entty_nm  or SYN_MTCH_TERM like '%| '|| v_entty_nm || ' |%')  and (v_hdr_id, c.item_id, c.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         --           commit; 
    v_cnt := v_cnt + SQL%ROWCOUNT;
  commit;
    if (v_cnt > 0 and v_typ = 'R') then
    return;
    end if;
     if ((v_typ = 'R' and v_cnt < 1) or v_typ ='U') then --run match, no exact matches; run unrestricted
     insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '4. VM Like Match' from 
                    MVW_VAL_MEAN where ((MTCH_TERM_ADV like '%' || v_entty_nm || '%' )  or
                    (v_entty_nm like '%' || MTCH_TERM_ADV || '%' and length(mtch_term) >= v_minlen)) and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt); 
    v_cnt := SQL%ROWCOUNT;
 commit;
                      insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '5. Concept Like Match' from 
                    vw_cncpt where MTCH_TERM_ADV  like '%' ||  v_entty_nm || '%' 
                     and CNTXT_NM_DN = 'NCIP'  and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
    v_cnt := v_cnt + SQL%ROWCOUNT;
    commit;
                       insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '5. Concept Like Match' from 
                    vw_cncpt where 
                     v_entty_nm like '%' || MTCH_TERM_ADV || '%' and length(item_nm) >= v_minlen and CNTXT_NM_DN = 'NCIP' 
                      and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         
    v_cnt := v_cnt + SQL%ROWCOUNT;
         commit;
         
        insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , c.item_id, c.ver_nr, '6. Synonym Like Match' from 
                    vw_cncpt c where SYN_MTCH_TERM like '%' ||  v_entty_nm || '%'   and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
    v_cnt := v_cnt + SQL%ROWCOUNT;
 commit;
   if (v_cnt > 0 and v_typ = 'R') then
   return;
   end if;
 -- Third pass longest word exact match
 if ((v_cnt < 1 and v_typ = 'R') or v_typ = 'U') then
 v_word_cnt := nci_11179.getwordcount(v_entty_nm_with_space);
 v_sel_word := 'x';
 
 for j in 1..v_word_cnt loop
 v_cur_word:= nci_11179.getWord(v_entty_nm_with_space,j, v_word_cnt);
 --raise_application_Error(-20000,length(v_sel_word));
 if (length(v_cur_word) > length(v_sel_word)) then
    v_Sel_word := v_cur_Word;
    end if;
 end loop;
 
 v_sel_word := regexp_replace(upper(v_sel_word),v_reg_str_adv,'');
 --raise_application_error(-20000, 'Hre' || v_sel_word);
 
     insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '7. VM Like Match Largest word' from 
                    MVW_VAL_MEAN where ((MTCH_TERM_ADV like '%' || v_sel_word || '%' )  or
                    (v_sel_word like '%' || MTCH_TERM_ADV || '%'))  and length(mtch_term_adv) >= length(v_sel_word) and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
     commit;               
           insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '8. Concept Like Match Largest Word' from 
                    vw_cncpt where MTCH_TERM_ADV  like '%' ||  v_sel_word || '%' 
                     and CNTXT_NM_DN = 'NCIP'  and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    commit;
    v_cnt := v_cnt + SQL%ROWCOUNT;
    
                       insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, '8. Concept Like Match Largest Word' from 
                    vw_cncpt where 
                     v_sel_word like '%' || MTCH_TERM_ADV || '%' and length(item_nm) >= v_minlen and CNTXT_NM_DN = 'NCIP' 
                      and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
         
         commit;
    v_cnt := v_cnt + SQL%ROWCOUNT;
         
         
        insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , c.item_id, c.ver_nr, '9. Synonym Like Match Largest Word' from 
                    vw_cncpt c where SYN_MTCH_TERM like '%' ||  v_sel_word || '%' and  length(syn_mtch_term) >= length(v_sel_word)  and (v_hdr_id, item_id, ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    commit; 
    v_cnt := v_cnt + SQL%ROWCOUNT;
    end if;

    end if;
    end if;
    end;

procedure spDSHDRPostHook (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2) as
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_hdr_id integer;
    v_pref_cde number;
    v_pref_cde_old number;
    
    v_sys_msg varchar2(2000) := '';
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   
    rows := t_rows();
 --   for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        
        row_ori := hookInput.originalRowset.rowset(1);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
        v_pref_cde := ihook.getColumnValue(row_ori, 'CDE_ITEM_ID');
        v_pref_cde_old := ihook.getColumnOldValue(row_ori, 'CDE_ITEM_ID');
        
        if (v_pref_cde is null and v_pref_cde_old is not null) then --clear system message
            v_sys_msg := getDSSysMsg(v_hdr_id, 'P');
            update nci_ds_hdr set sys_msg = v_sys_msg where hdr_id = v_hdr_id;
            commit;
        end if;
        
 --   end loop;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spDSPostImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2) as
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_hdr_id integer;
    v_cnt integer;
    v_cntxts varchar2(4000);
    v_nxt varchar2(64);
    v_pos number;
    v_cntxt_id_ver varchar2(128);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   
    rows := t_rows();
 --   for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        
        row_ori := hookInput.originalRowset.rowset(1);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
        
    if (ihook.getColumnValue(row_ori, 'USR_CMNTS') is not null) then
        v_cntxts := ihook.getColumnValue(row_ori, 'USR_CMNTS');
        v_cnt := nci_11179.getwordcountdelim(v_cntxts,',');
        if v_cnt > 1 then
            for i in 1..v_cnt loop
                v_pos := INSTR(v_cntxts, ',');
                if (v_pos > 0) then
                    v_nxt := SUBSTR(v_cntxts, 1, v_pos-1);
                else
                    v_nxt := v_cntxts;
                end if;
                select cntxt_id_ver into v_cntxt_id_ver from vw_cntxt_ds where cntxt_nm_dn = v_nxt;
                INSERT INTO nci_ds_cntxt_sel (hdr_id, cntxt_nm_dn, cntxt_id_ver)
                VALUES (v_hdr_id, v_nxt, v_cntxt_id_ver);
                INSERT INTO onedata_ra.nci_ds_cntxt_sel (hdr_id, cntxt_nm_dn, cntxt_id_ver) 
                VALUES (v_hdr_id, v_nxt, v_cntxt_id_ver);
                commit;
                
                v_cntxts := LTRIM(SUBSTR(v_cntxts, v_pos +1));
            end loop;
        else
            select cntxt_id_ver into v_cntxt_id_ver from vw_cntxt_ds where cntxt_nm_dn = v_cntxts;
            INSERT INTO nci_ds_cntxt_sel (hdr_id, cntxt_nm_dn, cntxt_id_ver)
            VALUES (v_hdr_id, v_cntxts, v_cntxt_id_ver); 
            INSERT INTO onedata_ra.nci_ds_cntxt_sel (hdr_id, cntxt_nm_dn, cntxt_id_ver)
            VALUES (v_hdr_id, v_cntxts, v_cntxt_id_ver);
            commit;
        end if;
--        if (ihook.getColumnValue(row_ori, 'PERM_VAL_NM') is null and ihook.getColumnValue(row_ori, 'VAL_MEAN_NM') is not null) then
--            ihook.setColumnValue(row_ori, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'VAL_MEAN_NM'));
--        end if;
        --raise_application_error(-20000, ihook.getColumnValue(row_ori, 'VAL_MEAN_NM'));
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
    end if;
        
        
 --   end loop;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spDSPVVMPostImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2) as
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_hdr_id integer;
    v_cnt integer;
    v_cntxts varchar2(4000);
    v_nxt varchar2(64);
    v_pos number;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   
    rows := t_rows();
       
        row_ori := hookInput.originalRowset.rowset(1);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
        --raise_application_error(-20000, 'test'); 
        if (ihook.getColumnValue(row_ori, 'PERM_VAL_NM') = 'empty1' and ihook.getColumnValue(row_ori, 'VAL_MEAN_NM') is not null) then
            ihook.setColumnValue(row_ori, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'VAL_MEAN_NM'));
        end if;

      
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spDSDelete (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2) AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_hdr_id integer;
    v_is_auth boolean;
    v_err_msg varchar2(512);
BEGIN
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
    
    FOR i IN 1..hookInput.originalRowset.rowset.count LOOP
        row_ori := hookInput.originalRowset.rowset(i);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
        v_is_auth := nci_ds.isUserAuth(v_hdr_id, v_usr_id);
        if v_is_auth then
        --context relation table, results, values table, hdr table
            DELETE FROM nci_ds_cntxt_sel WHERE hdr_id = v_hdr_id;
            DELETE FROM onedata_ra.nci_ds_cntxt_sel WHERE hdr_id = v_hdr_id;
            DELETE FROM nci_ds_rslt_dtl WHERE hdr_id = v_hdr_id;
            DELETE FROM nci_ds_rslt WHERE hdr_id = v_hdr_id;
            DELETE FROM nci_ds_hdr WHERE hdr_id = v_hdr_id;
            commit;
        else
            v_err_msg := '<strong>You are not authorized to delete this record:<br>Batch Name: </strong>' || ihook.getColumnValue(row_ori, 'BTCH_NM') || '  <strong>Seq ID: </strong>' || ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR');
            raise_application_error(-20000, 'You are not authorized to delete this record: ' || v_err_msg);
        end if;


    END LOOP;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

function getDSSysMsg (v_hdr_id in number, v_op in varchar2) return varchar2 
IS
    v_sys_msg varchar2(2000) := '';
    v_item_id number;
    v_ver_nr number(4,2);
    v_pv_src number;
    v_pv_mtch number;
    v_pv_cde number;
    v_lst_run_typ varchar2(32);
    v_lst_run_dt timestamp;
    v_temp number;
    v_dt_fmt varchar2(64) := 'YYYY-MM-DD HH12:MI:SS';
    v_val_dom_typ number;
BEGIN
    --  0. Get enumerated value
    select count(*) into v_temp from nci_ds_dtl where hdr_id = v_hdr_id;
    if (v_temp = 0) then v_val_dom_typ := 18 ; else v_val_dom_typ := 17; end if;
    
    -- 1. System Message returns the last run information
    select count(*) into v_temp from nci_ds_hdr where hdr_id = v_hdr_id and lst_run_typ is not null;
    if (v_temp = 1) then -- match has been run
        select lst_run_typ, lst_run_dt into v_lst_run_typ, v_lst_run_dt from nci_ds_hdr where hdr_id = v_hdr_id;
        v_sys_msg := 'Last Run: ' || v_lst_run_typ || ' ' || to_char(v_lst_run_dt, v_dt_fmt) || '<BR>';
    end if;
    
    -- 2. System Message returns preferred CDE details if set
    select count(*) into v_temp from nci_ds_hdr where hdr_id = v_hdr_id and cde_item_id is not null;
    --raise_application_error(-20000, v_temp);
    if (v_temp = 1 and v_op <> 'P') then -- preferred cde set, not called from post-hook
        --select count(*) into v_temp from nci_ds_hdr where hdr_id = v_hdr_id and cde_item_id in (select item_id from nci_ds_rslt where hdr_id = v_hdr_id);
        --if (v_temp = 1) then
    
            select cde_item_id, cde_ver_nr, d.num_pv, d.num_pv_mtch, d.num_pv_in_cde into v_item_id, v_ver_nr, v_pv_src, v_pv_mtch, v_pv_cde
            from nci_ds_hdr d
            where d.hdr_id = v_hdr_id;
            if (v_val_dom_typ = 18) then -- non-enumerated > no pv information should be returned
                v_sys_msg := v_sys_msg || 'Preferred CDE set to ' || v_item_id || 'v' || v_ver_nr || '<BR>';
            else
                v_sys_msg := v_sys_msg || 'Preferred CDE set to ' || v_item_id || 'v' || v_ver_nr || '<BR>' ||
                    'Source PVs ' || v_pv_src || ' - Matched PVs ' || v_pv_mtch || ' - CDE PVs ' || v_pv_cde;
            end if;
        --end if;
        
    end if;
    
    return v_sys_msg;
END;

function isUserAuth(v_hdr_id in number, v_user_id in varchar2) return boolean is
v_auth boolean := false;
v_usr_id varchar2(255);
begin

select creat_usr_id into v_usr_id from nci_ds_hdr where HDR_ID = v_hdr_id;
 if (upper(v_usr_id) <> upper(v_user_id) and nci_11179_2.isUserAdmin(v_user_id) = false) then return false; else return true; end if;
end;

end;
/

