DROP PACKAGE ONEDATA_WA.NCI_CURRENT;

CREATE OR REPLACE PACKAGE ONEDATA_WA.nci_current AS
PROCEDURE spCreatePVVM (v_data_in in clob, v_data_out out clob);
PROCEDURE spCreateVM (v_data_in in clob, v_data_out out clob);
   procedure            sp_create_form_vv_inst_new;
      procedure sp_append_quest_pv;
      procedure sp_quest_rep_new;
      procedure valUsingStr (rowform in out t_row, k in integer, v_item_typ in integer) ;
END;
/

DROP PACKAGE BODY ONEDATA_WA.NCI_CURRENT;

CREATE OR REPLACE PACKAGE BODY ONEDATA_WA.nci_current AS

procedure sp_quest_rep_new as
i integer;
v_found boolean;
v_max_rep integer;
begin



delete from temp_import;
commit;

insert into temp_import(item_id, ver_nr, rep_no)
select c_item_id, c_item_ver_nr, rep_no from nci_admin_item_rel r where rel_typ_id = 61 and nvl(rep_no ,0) > 0 ;
commit;


select max(rep_no) into v_max_rep from temp_import;

for i in 1..v_max_rep  loop
--for i in 1..1  loop
insert into /* APPEND */ nci_quest_vv_rep (quest_pub_id, quest_ver_nr, rep_seq)
select nci_pub_id, nci_ver_nr, i from nci_admin_item_rel_alt_key ak where (p_item_id, p_item_ver_nr) in (select item_id, ver_nr from temp_import where rep_no <= i)
minus
select quest_pub_id, quest_ver_nr, rep_seq from nci_quest_vv_rep ak where rep_seq = i;
commit;
delete from temp_import where rep_no = i;
commit;
end loop;

/*for curq in (Select nci_pub_id, nci_ver_nr from nci_admin_item_rel_alt_key where p_item_id = cur.item_id and p_item_ver_nr = cur.ver_nr) loop
for i in 1..cur.rep_no loop
v_found := false;
for currep in (select * from nci_quest_vv_rep where quest_pub_id = curq.nci_pub_id and quest_ver_nr = curq.nci_ver_nr and rep_seq = i) loop
 v_found := true;
end loop;
if v_found = false then
insert into nci_quest_vv_rep (quest_pub_id, quest_ver_nr, rep_seq) values (curq.nci_pub_id, curq.nci_ver_nr, i);
end if;
end loop;
end loop;
commit;
end loop; */

end;

procedure valUsingStr (rowform in out t_row, k in integer, v_item_typ in integer) as
i integer;
v_str varchar2(255);
cnt integer;
v_nm varchar2(255);
v_cncpt_nm varchar2(255);
v_def varchar2(255);
v_dec_nm varchar2(255);
v_item_id number;
v_ver_nr number;
v_long_nm varchar2(255);
begin

           for i in  1..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                end loop;
            if (ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_' || k) is not null) then
                v_str := trim(ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_'|| k));
                cnt := nci_11179.getwordcount(v_str);
                v_nm := '';
                for i in  1..cnt loop
                        v_cncpt_nm := nci_11179.getWord(v_str, i, cnt);
                        ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                        for cur in(select item_id, item_nm , item_long_nm from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
                                ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,cur.item_id);
                                ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, 1);
                                v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                                v_nm := trim(v_nm || ':' || cur.item_long_nm);
                        end loop;
                end loop;
                for i in  cnt+1..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                end loop;
     
                nci_11179.CncptCombExists(substr(v_nm,2),v_item_typ,v_item_id, v_ver_nr,v_long_nm, v_def);
                ihook.setColumnValue(rowform, 'ITEM_' || k  ||'_ID',v_item_id);
                ihook.setColumnValue(rowform, 'ITEM_' || k || '_VER_NR', v_ver_nr);
                ihook.setColumnValue(rowform,'ITEM_' || k || '_LONG_NM', trim(substr(v_nm,2)));
                ihook.setColumnValue(rowform,'ITEM_' || k || '_DEF', v_def);
                ihook.setColumnValue(rowform,'ITEM_' || k || '_NM', v_long_nm);
            end if;
            
            end;

PROCEDURE spCreatePVVM
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  showRowset t_showableRowset;
  rowform t_row;
    forms t_forms;
  form1 t_form;

  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowset            t_rowset;
  v_oc_item_id number;
  v_oc_ver_nr number;
  v_oc_long_nm varchar2(255);
  v_oc_nm varchar2(255);
  v_prop_nm varchar2(255);
  v_oc_def  varchar2(2000);
  type t_cncpt_id is table of admin_item.item_id%type;
v_t_cncpt_id  t_cncpt_id := t_cncpt_id();

  v_prop_item_id number;
  v_prop_ver_nr number;
  v_prop_long_nm varchar2(255);
  v_prop_def  varchar2(2000);
  v_dec_item_id number;
 v_str  varchar2(255);
 v_nm  varchar2(255);
 v_item_id number;
 v_ver_nr number(4,2);
  cnt integer;
  
    actions t_actions := t_actions();
  action t_actionRowset;
  v_msg varchar2(1000);
  i integer := 0;
  v_err  integer;
  column  t_column;
  v_dec_nm varchar2(255);
  v_cncpt_nm varchar2(255);
  v_long_nm varchar2(255);
  v_def varchar2(4000);
  k integer;
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
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECCreateQuestion();
          row := t_row();      
          rows := t_rows();
          ihook.setColumnValue(row, 'STG_AI_ID',1);
          ihook.setColumnValue(row, 'ADMIN_STUS_ID',66);
          ihook.setColumnValue(row, 'REGSTR_STUS_ID',9);
          rows.extend;
          rows(rows.last) := row;
          rowset := t_rowset(rows, 'VM-PV Creation', 1, 'NCI_STG_AI_CNCPT_CREAT');
          hookOutput.forms := nci_chng_mgmt.getDECCreateForm(rowset);
  ELSE
      forms              := hookInput.forms;
      form1              := forms(1);
      rowform := form1.rowset.rowset(1);
       row := t_row();
      rows := t_rows();
     is_valid := true;
     k := 1;
    IF HOOKINPUT.ANSWERID = 1 or Hookinput.answerid = 3 THEN  -- Validate using string
                for i in  1..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                end loop;
            if (ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_' || k) is not null) then
                v_str := trim(ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_'|| k));
                cnt := nci_11179.getwordcount(v_str);
                v_nm := '';
                for i in  1..cnt loop
                        v_cncpt_nm := nci_11179.getWord(v_str, i, cnt);
                        ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                        for cur in(select item_id, item_nm , item_long_nm from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
                                ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,cur.item_id);
                                ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, 1);
                                v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                                v_nm := trim(v_nm || ':' || cur.item_long_nm);
                        end loop;
                end loop;
                for i in  cnt+1..10 loop
                        ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, '');
                end loop;
     
                nci_11179.CncptCombExists(substr(v_nm,2),49,v_item_id, v_ver_nr,v_long_nm, v_def);
                ihook.setColumnValue(rowform, 'ITEM_' || k  ||'_ID',v_item_id);
                ihook.setColumnValue(rowform, 'ITEM_' || k || '_VER_NR', v_ver_nr);
                ihook.setColumnValue(rowform,'ITEM_' || k || '_LONG_NM', trim(substr(v_nm,2)));
                ihook.setColumnValue(rowform,'ITEM_' || k || '_DEF', v_def);
                ihook.setColumnValue(rowform,'ITEM_' || k || '_NM', v_long_nm);
            end if;
    end if;
    
    IF HOOKINPUT.ANSWERID = 2 or Hookinput.answerid = 4 THEN  -- Validate using drop-down
                v_nm := '';
                for i in 1..10 loop
                        v_temp_id := ihook.getColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i);
                        v_temp_ver := ihook.getColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i);
                        if (v_temp_id is not null) then
                        for cur in(select item_id, item_nm , item_long_nm from admin_item where admin_item_typ_id = 49 and item_id = v_temp_id and ver_nr = v_temp_ver) loop
                                 v_dec_nm := trim(v_dec_nm || ' ' || cur.item_nm) ;
                                v_nm := trim(v_nm || ':' || cur.item_long_nm);
                        end loop;
                        end if;
                end loop;
          
                nci_11179.CncptCombExists(substr(v_nm,2),4+k,v_item_id, v_ver_nr,v_long_nm, v_def);
                ihook.setColumnValue(rowform, 'ITEM_' || k  ||'_ID',v_item_id);
                ihook.setColumnValue(rowform, 'ITEM_' || k || '_VER_NR', v_ver_nr);
                ihook.setColumnValue(rowform,'ITEM_' || k || '_LONG_NM', trim(substr(v_nm,2)));
                ihook.setColumnValue(rowform,'ITEM_' || k || '_DEF', v_def);
                ihook.setColumnValue(rowform,'ITEM_' || k || '_NM', v_long_nm);
    end if;
    
      ihook.setColumnValue(rowform, 'GEN_STR',v_dec_nm ) ;
       ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'VALIDATED');
       if (   ihook.getColumnValue(rowform, 'ITEM_1_ID') is not null and ihook.getColumnValue(rowform, 'ITEM_2_ID') is not null) then
              for cur in (select de_conc.* from de_conc, admin_item ai where obj_cls_item_id =  ihook.getColumnValue(rowform, 'ITEM_1_ID') and obj_cls_ver_nr =  ihook.getColumnValue(rowform, 'ITEM_1_VER_NR') and
               prop_item_id = ihook.getColumnValue(rowform, 'ITEM_2_ID') and prop_ver_nr =  ihook.getColumnValue(rowform, 'ITEM_2_VER_NR') and
              de_conc.item_id = ai.item_id and de_conc.ver_nr = ai.ver_nr and ai.cntxt_item_id = ihook.getColumnValue(rowform, 'CNTXT_ITEM_ID')
              and ai.cntxt_ver_nr = ihook.getColumnValue(rowform, 'CNTXT_VER_NR')) loop
                    ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'DUPLICATE DEC');
                    is_valid := false;
              end loop;
        end if;
        if (   ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is null or ihook.getColumnValue(rowform, 'CNCPT_2_ITEM_ID_1') is null) then
                  ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'OC or PROP missing.');
                  is_valid := false;
        end if;
     
         rows := t_rows();
        if (is_valid=false or hookinput.answerid = 1 or hookinput.answerid = 2) then
                rows.extend;
                rows(rows.last) := rowform;
                rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
                hookOutput.forms := nci_chng_mgmt.getDECCreateForm(rowset);
                HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECCreateQuestion();
        end if;
    
    IF HOOKINPUT.ANSWERID in ( 3,4)  and is_valid = true THEN  -- Create
        v_oc_id := ihook.getColumnValue(rowform, 'ITEM_1_ID');
        v_oc_ver_nr := ihook.getColumnValue(rowform, 'ITEM_1_VER_NR');
  
        if v_oc_id is null then
            nci_chng_mgmt.createAIWithConcept(rowform, 1,5, actions);
            v_oc_id := ihook.getColumnValue(rowform, 'ITEM_1_ID');
        end if;
        v_prop_id := ihook.getColumnValue(rowform, 'ITEM_2_ID');
        v_prop_ver_nr := ihook.getColumnValue(rowform, 'ITEM_2_VER_NR');
        if v_prop_id is null then
            nci_chng_mgmt.createAIWithConcept(rowform, 2,6,  actions);
            v_prop_id := ihook.getColumnValue(rowform, 'ITEM_2_ID');
        end if;
--    raise_application_error(-20000, v_oc_id || 'Test' || v_prop_id);
        nci_chng_mgmt.createDEC(rowform, actions, v_item_id);
        hookoutput.message := 'DEC Created Successfully with ID ' || v_item_id ;
        hookoutput.actions := actions;
    
    end if;
  
end if;
   
/*  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  delete from junk_debug;
  commit;
  insert into junk_debug values (1, v_data_out);
  commit;*/

END;

PROCEDURE spCreateVM
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


 procedure            sp_create_form_vv_inst_new
as
v_cnt integer;
begin

/*
update nci_form f set HDR_INSTR = (select qc.preferred_definition from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'FORM_INSTR' and 
ai.item_id = f.item_id and ai.ver_nr = f.ver_nr and ai.nci_idseq = qc.dn_crf_idseq and qc.qc_id in 
(select min(qc_id)  from sbrext.quest_contents_ext qc1 where qc1.qtl_name = 'FORM_INSTR' group by dn_crf_idseq));
commit;

update nci_form f set FTR_INSTR = (select qc.preferred_definition from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'FOOTER' and 
ai.item_id = f.item_id and ai.ver_nr = f.ver_nr and ai.nci_idseq = qc.dn_crf_idseq and qc.qc_id in 
(select min(qc_id)  from sbrext.quest_contents_ext qc1 where qc1.qtl_name = 'FOOTER' group by dn_crf_idseq));
commit;
*/

for cur in (select distinct c_item_id, c_item_ver_nr from nci_admin_item_rel where rel_typ_id = 61) loop
update nci_admin_item_rel m set INSTR = (select qc.preferred_definition from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'MODULE_INSTR' and 
ai.item_id = cur.c_item_id and ai.ver_nr = cur.c_item_ver_nr and ai.nci_idseq = qc.p_mod_idseq and qc.qc_id in 
(select min(qc_id)  from sbrext.quest_contents_ext qc1 where qc1.qtl_name = 'MODULE_INSTR' and p_mod_idseq=ai.nci_idseq))
where m.c_item_id = cur.c_item_id and m.c_item_ver_nr = cur.c_item_ver_nr;
end loop;
commit;

/*
insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'MODULE', 'INSTRUCTION',ai.VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
    nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr)
        from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'MODULE_INSTR' and 
qc.p_mod_idseq = ai.nci_idseq;

commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.nci_pub_id, 'QUESTION', 'INSTRUCTION',ai.NCI_VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
    nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr)
        from sbrext.quest_contents_ext qc, Nci_admin_item_rel_alt_key ai where qc.qtl_name = 'QUESTION_INSTR' and ai.rel_typ_id = 63 and
qc.p_qst_idseq = ai.nci_idseq;

commit;


insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, nci_ver_nr, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF, NCI_TYP, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.nci_pub_id, 'VALUE',1, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition, 'INSTRUCTION',
    nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr)
        from sbrext.quest_contents_ext qc, Nci_QUEST_VALID_VALUE ai where qc.qtl_name = 'VALUE_INSTR' and
qc.p_val_idseq = ai.nci_idseq ;
commit;

*/

end;


procedure sp_append_quest_pv
as
v_item_id number;
i integer;
begin

--drop table temp2;

/*
--create temporary table temp2 as 
(select q_pub_id, q_ver_nr, cnt_quest, cnt_value from 
(select q_pub_id, q_ver_nr, count(*) cnt_quest from nci_quest_valid_value group by q_pub_id, q_ver_nr) a,
(select nci_pub_id, nci_ver_nr, count(*) cnt_value from nci_admin_item_rel_alt_key ak, VW_NCI_DE_PV pv where ak.c_item_id = pv.de_item_id 
and ak.c_item_ver_nr = pv.de_ver_nr group by nci_pub_id, nci_ver_nr) b
where a.q_pub_id = b.nci_pub_id and a.q_ver_nr = b.nci_ver_nr and cnt_quest < cnt_value)
*/

i := 0;

/* for cur in (select q_pub_id, q_ver_nr, cnt_quest, cnt_value from 
(select q_pub_id, q_ver_nr, count(*) cnt_quest from nci_quest_valid_value group by q_pub_id, q_ver_nr) a,
(select nci_pub_id, nci_ver_nr, count(*) cnt_value from nci_admin_item_rel_alt_key ak, VW_NCI_DE_PV pv where ak.c_item_id = pv.de_item_id 
and ak.c_item_ver_nr = pv.de_ver_nr group by nci_pub_id, nci_ver_nr) b
where a.q_pub_id = b.nci_pub_id and a.q_ver_nr = b.nci_ver_nr and cnt_quest < cnt_value )  */

/*
 for cur in (select q_pub_id, q_ver_nr from temp2 )
loop
for cur2 in (select PERM_VAL_NM from  VW_NCI_DE_PV pv, nci_admin_item_rel_alt_key a where de_item_id = a.C_item_id and de_ver_nr = a.c_item_ver_nr
  and a.nci_pub_id = cur.q_pub_id and a.nci_ver_nr = cur.q_ver_nr and perm_val_nm not in (
  select value PERM_VAL_NM from nci_quest_valid_value where q_pub_id = cur.q_pub_id and q_ver_nr = cur.q_ver_nr) ) loop
  
  for cur1 in (
  select PERM_VAL_NM,  pv.item_nm, pv.item_long_nm , pv.item_desc from  VW_NCI_DE_PV pv, nci_admin_item_rel_alt_key a 
  where de_item_id = a.C_item_id and de_ver_nr = a.c_item_ver_nr
  and a.nci_pub_id = cur.q_pub_id and a.nci_ver_nr = cur.q_ver_nr and pv.perm_val_nm = cur2.perm_val_nm) loop
                v_item_id := nci_11179.getItemId;
             --   insert into nci_quest_valid_value (Q_PUB_ID, Q_VER_NR, VM_NM, VM_LNM, VM_DEF, VALUE, MEAN_TXT, DESC_TXT, NCI_PUB_ID, NCI_VER_NR, DISP_ORD, FLD_DELETE)
              --  values (cur.q_pub_id, cur.q_ver_nr, cur1.item_nm, cur1.item_long_nm, cur1.item_desc, cur1.perm_val_nm, cur1.item_nm, cur1.item_desc, v_item_id, cur.q_ver_nr, 0,1);
                
    
                /*ihook.setColumnValue (row, 'Q_PUB_ID', cur.q_pub_id);
                ihook.setColumnValue (row, 'Q_VER_NR', cur.q_ver_nr);
                ihook.setColumnValue (row, 'VM_NM', cur1.item_nm);
                ihook.setColumnValue (row, 'VM_LNM', cur1.item_long_nm);
                ihook.setColumnValue (row, 'VM_DEF', cur1.item_desc);
                ihook.setColumnValue (row, 'VALUE', cur1.perm_val_nm);
                ihook.setColumnValue (row, 'MEAN_TXT', cur1.item_nm);
                ihook.setColumnValue (row, 'DESC_TXT', cur1.item_desc);
                
                ihook.setColumnValue (row, 'NCI_PUB_ID', v_item_id);
                ihook.setColumnValue (row, 'NCI_VER_NR', cur.q_ver_nr);
                ihook.setColumnValue (row, 'DISP_ORD', 0);
                ihook.setColumnValue (row, 'FLD_DELETE', 1);
                 rowsvv.extend;
                rowsvv(rowsvv.last) := row;
                j := j+ 1; 
                
                end loop;   
                 end loop;
              -- commit;
               i := i+1;
               if (i = 1000) then 
               commit;
               exit; end if;
 end loop;
 */
end;


END;
/
