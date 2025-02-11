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
procedure spDSMatchEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2, v_suffix in varchar2);
procedure spPostCDEMatch (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
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
v_mtch_min_len integer := 4;
  
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
            end if;
            
            if (v_val_dom_typ = 17) then -- non -enumerated
            
---procedure spDSMatchNonEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2);
            spDSMatchEnum(v_hdr_id, v_user_id, v_flt_str,'CDE_MATCH', nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR'), ihook.getColumnValue(row_ori, 'ENTTY_NM')),
              v_suffix);
            end if;
            


  update nci_ds_hdr set NUM_CDE_MTCH = (select count(*) from nci_ds_rslt where hdr_id = v_hdr_id and mtch_typ = 'CDE'),
  NUM_PV = v_temp
  where hdr_id = v_hdr_id;
  update nci_ds_rslt r set NUM_PV_IN_CDE = (select count(*) from vw_nci_de_pv_lean where de_item_id = r.item_id and de_ver_nr = r.ver_nr)
  where hdr_id = v_hdr_id;
  
    --jira 3815: automatically set preferred cde if match is exact and there is only 1
    select NUM_CDE_MTCH into v_temp from nci_ds_hdr where hdr_id = v_hdr_id;
  if (v_temp = 1) then
    select rule_desc, item_id, ver_nr into v_str, tmp_item_id, tmp_ver_nr from nci_ds_rslt where hdr_id = v_hdr_id;
    if (v_str like '%Exact Match%') then
        --raise_application_error(-20000, 'pass if');
        update nci_ds_hdr set CDE_ITEM_ID = tmp_item_id where hdr_id = v_hdr_id;
        update nci_ds_hdr set CDE_VER_NR = tmp_ver_nr where hdr_id = v_hdr_id;
        commit;
    end if;
  end if;
  
  end loop;
  commit;
  

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

    select count(*) into v_temp from nci_ds_rslt where hdr_id = v_hdr_id  and mtch_typ = 'DEC'    ;

   if (v_temp = 1) then 
  update nci_ds_hdr set (NUM_DEC_MTCH, DE_CONC_ITEM_ID, DE_CONC_VER_NR, LST_UPD_USR_ID) = (select 1, item_id, ver_nr , v_user_id from nci_ds_rslt where hdr_id = v_hdr_id and mtch_typ='DEC')
  where hdr_id = v_hdr_id;
  else
  update nci_ds_hdr set NUM_DEC_MTCH = v_temp
  where hdr_id = v_hdr_id;
  end if;
  commit;


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
      
                  v_sql := 'insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc) select ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr,  1, 100, ''1. Long Name Exact Match'' from 
                  vw_de de where ' ||v_entty_nm || ' = de.MTCH_TERM    and currnt_ver_ind = 1             and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''        and de.val_dom_typ_id = 18 and ' || v_flt_str ;
                  --raise_application_error (-20000,v_sql);
                     execute immediate v_sql;
                    commit;
                    
                    -- Rule id 2:  Entity alternate question text name exact match
                    
                 
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr,  2, 100, ''2. Question Text Exact Match'' from ref r, obj_key ok, vw_de de 
                    where ' || v_entty_nm || ' =  r.MTCH_TERM  and r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt)
                    and de.val_dom_typ_id = 18 and ' || v_flt_str;
                      execute immediate v_sql;
                  
                    commit;
        
                    
                    
                    -- Rule id 3:  Entity alternate  name exact match
                    
                     v_sql := ' insert into nci_ds_rslt (hdr_id,mtch_typ, item_id, ver_nr, rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr, 3, 100, ''3. Alternate Name Exact Match'' from alt_nms r, vw_de de
                    where ' || v_entty_nm ||  ' = r.MTCH_TERM and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt) and ' || v_flt_str;
                     execute immediate v_sql;
                    commit;
                    
                    
            -- Non enumerated only
            
                       v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr,  4, 100, ''4. Long Name Like Match'' from vw_de  de 
                    where instr(de.MTCH_TERM , ' || concat(v_entty_nm,' ') || ',1) > 0 
                     and currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                     and (' || v_hdr_id || ') not in (select hdr_id from nci_ds_rslt) and ' || v_flt_str;
                   --  raise_application_error(-20000, v_sql);
                     execute immediate v_sql;
                     commit;
                
                
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr,  5, 100, ''5. Question Text Like Match'' from ref r, obj_key ok, vw_de de
                    where instr(r.MTCH_TERM ,' || concat(v_entty_nm,' ')  || ', 1) > 0                     and
                    r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and r.ref_nm != ''%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (' || v_hdr_id || ') not in (select  hdr_id from nci_ds_rslt) and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%'' and ' || v_flt_str;
                   --  raise_application_error(-20000, v_sql);
                execute immediate v_sql;
                    commit;
                                
                   
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr, rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr,  6, 100, ''6. Alternate Name Like Match'' from alt_nms r, vw_de de
                    where instr( r.MTCH_TERM, ' || concat(v_entty_nm,' ')  || ',1) > 0
                    and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ') not  in (select hdr_id from nci_ds_rslt) and ' || v_flt_str;
--raise_application_error(-20000,v_sql);
                     execute immediate v_sql;
                     
                         v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr,  4, 100, ''7. Long Name Reverse Like Match'' from vw_de  de 
                    where instr('|| concat(v_entty_nm,' ')  || ',de.MTCH_TERM , 1) > 0  and length(de.mtch_term) > ' || v_mtch_min_len ||
                    ' and currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                     and (' || v_hdr_id || ') not in (select hdr_id from nci_ds_rslt) and ' || v_flt_str;
                   --  raise_application_error(-20000, v_sql);
                     execute immediate v_sql;
                     commit;
                
                
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr,  5, 100, ''8. Question Text Reverse Like Match'' from ref r, obj_key ok, vw_de de
                    where instr(' || concat(v_entty_nm,' ')  || ',r.MTCH_TERM , 1) > 0       and length(r.mtch_term) > ' || v_mtch_min_len || '           and
                    r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and r.ref_nm != ''%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (' || v_hdr_id || ') not in (select  hdr_id from nci_ds_rslt) and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%'' and ' || v_flt_str;
                   --  raise_application_error(-20000, v_sql);
                execute immediate v_sql;
                    commit;
                                
                   
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr, rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr,  6, 100, ''9. Alternate Name Reverse Like Match'' from alt_nms r, vw_de de
                    where instr( ' || concat(v_entty_nm,' ')  || ', r.MTCH_TERM, 1) > 0 and length(r.mtch_term) > ' || v_mtch_min_len ||
                    ' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ') not  in (select hdr_id from nci_ds_rslt) and ' || v_flt_str;
--raise_application_error(-20000,v_sql);
                     execute immediate v_sql;
                     
                    commit;
                --    if (usr_tips_ind = 1) then
                    update nci_ds_rslt set rule_desc = rule_desc || ' (' || v_suffix || ')' , MTCH_TYP = 'CDE' where hdr_id = v_hdr_id;
                    commit;
                  --  end if;
     


END;


procedure spDSMatchEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2, v_suffix in varchar2)

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
      
         -- nci_ds_rslt_dlt holds the first level run of name matches.
        
        -- Rule id 1:  Entity preferred name exact match
        delete from nci_ds_rslt_dtl where hdr_id = v_hdr_id;
        commit;

        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc) select ' ||
        v_hdr_id || ', ''' || v_mtch_typ || ''', de.item_id, de.ver_nr, ''NA'', 1, 100, ''1. Long Name Exact Match'' from   vw_de de where ' || v_entty_nm || '  = de.MTCH_TERM
         and currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%'' and ' || v_flt_str;
    --     raise_application_error(-20000, v_sql);
          execute immediate v_sql;
        --commit;
        
        -- Rule id 2:  Entity alternate question text name exact match
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select distinct ' || v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr, ''NA'', 2, 100, ''2. Question Text Exact Match'' from ref r, obj_key ok, vw_de de  where ' || v_entty_nm || '  = r.MTCH_TERM         and
        r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
        and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str;
    
         execute immediate v_sql;
        --commit;
        
        
        -- Rule id 3:  Entity alternate  name exact match
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id,mtch_typ,  item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select distinct ' || v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr, ''NA'', 3, 100, ''3. Alternate Name Exact Match'' from alt_nms r, vw_de de  where 
       ' || v_entty_nm || '  = r.MTCH_TERM
        and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
        and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and ' || v_flt_str;
         execute immediate v_sql;
        --commit;
        
        -- Rule id 4; Only for enumerated, Like
        if (length(v_entty_nm) > v_mtch_min_len) then
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr, ''NA'', 4, 100, ''4. Long Name Like Match'' from vw_de  de 
                    where ((instr(de.MTCH_TERM, ' || v_entty_nm || ',1) > 0 ) or  (instr(' || v_entty_nm || ', de.MTCH_TERM,1) > 0 ))' ||
         ' and currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
         and length(de.mtch_term) > ' || v_mtch_min_len || '
        and (' || v_hdr_id || ' , de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str;
      --  raise_application_error(-20000,v_sql);
         execute immediate v_sql;
        commit;
        
              v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr,  ''NA'', 5, 100, ''5. Question Text Like Match'' from ref r, obj_key ok, vw_de de
                    where ((instr(r.MTCH_TERM,' || v_entty_nm || ', 1) > 0  )   or (instr(' || v_entty_nm || ',r.MTCH_TERM, 1) > 0  ))  and length(r.mtch_term) > ' || v_mtch_min_len || '   and de.ADMIN_STUS_NM_DN not like ''%RETIRED%'' and
                    r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and r.ref_nm != ''%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (' || v_hdr_id || ', r.item_id, r.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str;
                --      raise_application_error(-20000, v_sql);
                execute immediate v_sql;
              
                    v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr,  perm_val_nm, rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr, ''NA'', 6, 100, ''6. Alternate Name Like Match'' from alt_nms r, vw_de de
                    where ((instr(r.MTCH_TERM, ' || v_entty_nm || ',1) > 0)  or (instr(' || v_entty_nm || ',r.MTCH_TERM,1) > 0)) and length(r.mtch_term) > ' || v_mtch_min_len || '  
                    and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ', r.item_id, r.ver_nr) not  in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and ' || v_flt_str;
                     execute immediate v_sql;
                     end if;
     
commit;
              -- if (usr_tips_ind = 1) then
                    update nci_ds_rslt_dtl set rule_desc = rule_desc || ' (' || v_suffix || ')' where hdr_id = v_hdr_id;
                    commit;
                --    end if;
     
-- Second level run for PV comparisons
-- if called from CDE math
if (v_mtch_typ = 'CDE_MATCH') then
for cur in (select hdr_id,count(*) cnt from nci_ds_dtl d where hdr_id = v_hdr_id  group by hdr_id) loop

insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*), dtl.rule_Desc, 'CDE'  from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR
and dtl.hdr_id = cur.hdr_id and dtl.item_id =  de_item_id and dtl.ver_nr = de_ver_nr 
and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
group by de_item_id,  de_ver_nr ,dtl.rule_Desc having count(*) = cur.cnt;
--commit;
--jira 3815: do not stop matching pvs
if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP )
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*) , dtl.rule_Desc , 'CDE' from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and dtl.hdr_id = cur.hdr_id and dtl.item_id =  de_item_id and dtl.ver_nr = de_ver_nr group by de_item_id,
de_ver_nr ,dtl.rule_Desc having count(*) = cur.cnt;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;

if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*), dtl.rule_Desc  , 'CDE' from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and dtl.hdr_id = cur.hdr_id and dtl.item_id =  de_item_id and dtl.ver_nr = de_ver_nr group by de_item_id, de_ver_nr,dtl.rule_Desc  having count(*) >= cur.cnt*0.5;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;

if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC, MTCH_TYP)
select distinct cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*), dtl.rule_Desc, 'CDE'
from vw_nci_de_pv_lean v, admin_item ai, nci_ds_rslt_dtl dtl where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and dtl.hdr_id = cur.hdr_id and dtl.item_id =  de_item_id and dtl.ver_nr = de_ver_nr
group by de_item_id, de_ver_nr,dtl.rule_Desc having count(*) > cur.cnt*0.5;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;
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
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
row := t_row();
 
            ihook.setColumnValue(row, 'HDR_ID', ihook.getColumnValue(row_ori, 'HDR_ID'));
            ihook.setColumnValue(row, 'CDE_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
            ihook.setColumnValue(row, 'CDE_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
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
    

end;
/