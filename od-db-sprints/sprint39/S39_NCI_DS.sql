create or replace PACKAGE            nci_ds AS
  procedure spDSRun ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spVMMatch ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 
  procedure setPrefCDE ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
    procedure setPrefCDEQuest ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure setPrefVM ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  
procedure spDSMatchNonEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2);

procedure spDSMatchEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2);

END;
/
create or replace PACKAGE BODY            nci_ds AS
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
  v_reg_str varchar2(255) := '\(|\)|\;|\-|\_|\|';
  
procedure spVMMatch ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

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
--    v_reg_str varchar2(255);
 -- v_entty_nm varchar2(4000);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   -- raise_application_error(-20000,v_user_id);

   
  --  v_reg_str := '\(|\)|\;|\-|\_|\|';
    rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
    --    v_entty_nm := regexp_replace(upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM'))),'\(|\)|\;|\-|\_','');
      v_entty_nm := regexp_replace(upper(nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR') ,ihook.getColumnValue(row_ori,'ENTTY_NM'))),v_reg_str,'');
  
     delete from nci_ds_rslt where hdr_id =v_hdr_id ;
    commit;

     insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, 'VM Exact Match' from 
                    admin_item where MTCH_TERM = v_entty_nm and admin_item_typ_id = 53;
                    commit;
    
    -- Vm Alt Name Exact Match
   /* insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , r.item_id, r.ver_nr, 'VM Alternate Name Exact Match' from 
                    vw_cncpt c, alt_nms r where regexp_replace(upper(nm_desc),'\(|\)|\;|\-|\_',' ') = v_entty_nm
                    and c.item_id = r.item_id and c.ver_nr = r.ver_nr and 
                    v_hdr_id not in (select hdr_id from nci_ds_rslt);
                    commit; 
        */            
     insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, 'Concept Exact Match' from 
                    vw_cncpt where regexp_replace(upper(item_nm),v_reg_str,'') = v_entty_nm and CNTXT_NM_DN = 'NCIP'
                    and v_hdr_id not in (select hdr_id from nci_ds_rslt);
                    commit;
   
     insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , r.item_id, r.ver_nr, 'Synonym Exact Match' from 
                    vw_cncpt c, alt_nms r where MTCH_TERM = v_entty_nm
                    and c.item_id = r.item_id and c.ver_nr = r.ver_nr and 
                    v_hdr_id not in (select hdr_id from nci_ds_rslt);
                    commit; 
     insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, 'VM Like Match' from 
                    admin_item where MTCH_TERM like '%' || v_entty_nm || '%'  and admin_item_typ_id = 53
                    and v_hdr_id not in (select hdr_id from nci_ds_rslt);
                    commit;
                    
                    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , item_id, ver_nr, 'Concept Like Match' from 
                    vw_cncpt where regexp_replace(upper(item_nm),v_reg_str,'') like '%' ||  v_entty_nm || '%' and CNTXT_NM_DN = 'NCIP'
                    and v_hdr_id not in (select hdr_id from nci_ds_rslt);
                    commit;
   

    /*
    
    v_str :=   v_entty_nm || ' |';
     insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , c.item_id, c.ver_nr, 'Synonym Exact Match' from 
                    vw_cncpt c where v_str = regexp_replace(substr(upper(syn),1,length(v_str)),'\(|\)|\;','') and CNTXT_NM_DN = 'NCIP'
                    and (v_hdr_id, c.item_id, c.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    commit;
                    
    v_str := '| ' ||  upper(ihook.getColumnValue(row_ori,'ENTTY_NM')) || ' |';
     insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_desc)
                    select distinct  v_hdr_id , c.item_id, c.ver_nr, 'Synonym Exact Match' from 
                    vw_cncpt c where instr(regexp_replace(upper(syn),'\(|\)|\;',''), v_Str,1,1) > 0 and CNTXT_NM_DN = 'NCIP'
                    and (v_hdr_id, c.item_id, c.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    commit;
      */              
                    
  select count(*) into v_temp from nci_ds_rslt where hdr_id = v_hdr_id     ;
  if (v_temp = 1) then 
  update nci_ds_hdr set (NUM_CDE_MTCH, CDE_ITEM_ID, CDE_VER_NR) = (select 1, item_id, ver_nr from nci_ds_rslt where hdr_id = v_hdr_id)
  where hdr_id = v_hdr_id;
  else
  update nci_ds_hdr set NUM_CDE_MTCH = v_temp
  where hdr_id = v_hdr_id;
  end if;
  commit;
  
end loop;
  
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  
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
   
     if (ihook.getColumnValue(row_ori, 'USR_CMNTS') is not null) then -- Context restriction
     v_cntxt_str := upper(trim(ihook.getColumnValue(row_ori, 'USR_CMNTS')));
     v_cnt := nci_11179.getwordcount(v_cntxt_str);
     v_flt_str := ' de.cntxt_nm_dn in (';
     for i in 1..v_cnt loop
        if (i = v_cnt) then
        v_flt_str := v_flt_str || '''' || nci_11179.getWord(v_cntxt_str, i, v_cnt) || ''')';
        else
             v_flt_str := v_flt_str || '''' || nci_11179.getWord(v_cntxt_str, i, v_cnt) || ''',';
      end if;   
     end loop;
     end if;
        select count(*) into v_temp from nci_ds_dtl where hdr_id = v_hdr_id;
        
        if (v_temp = 0) then v_val_dom_typ := 18 ; else v_val_dom_typ := 17; end if; -- enumerated or non-enumerated 18 - non-enumerated
        delete from nci_ds_rslt where hdr_id = v_hdr_id;
        commit;

            if (v_val_dom_typ = 18) then -- non -enumerated
            
---procedure spDSMatchNonEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2);
            spDSMatchNonEnum(v_hdr_id, v_user_id, v_flt_str,'CDE_MATCH', nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR'), ihook.getColumnValue(row_ori, 'ENTTY_NM')));
            end if;
            
            if (v_val_dom_typ = 17) then -- non -enumerated
            
---procedure spDSMatchNonEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2);
            spDSMatchEnum(v_hdr_id, v_user_id, v_flt_str,'CDE_MATCH', nvl(ihook.getColumnValue(row_ori,'ENTTY_NM_USR'), ihook.getColumnValue(row_ori, 'ENTTY_NM')));
            end if;
            


  update nci_ds_hdr set NUM_CDE_MTCH = (select count(*) from nci_ds_rslt where hdr_id = v_hdr_id),
  NUM_PV = v_temp
  where hdr_id = v_hdr_id;
  update nci_ds_rslt r set NUM_PV_IN_CDE = (select count(*) from vw_nci_de_pv_lean where de_item_id = r.item_id and de_ver_nr = r.ver_nr)
  where hdr_id = v_hdr_id;
  
  end loop;
  commit;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     
END;



procedure spDSMatchNonEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2)

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
      
                  v_sql := 'insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc) select ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr,  1, 100, ''Preferred Name Exact Match'' from 
                  vw_de de where ' ||v_entty_nm || ' = de.MTCH_TERM    and currnt_ver_ind = 1             and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''        and de.val_dom_typ_id = 18 and ' || v_flt_str ;
                  --raise_application_error (-20000,v_sql);
                     execute immediate v_sql;
                    commit;
                    
                    -- Rule id 2:  Entity alternate question text name exact match
                    
                 
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr,  2, 100, ''Question Text Exact Match'' from ref r, obj_key ok, vw_de de 
                    where ' || v_entty_nm || ' =  r.MTCH_TERM  and r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt)
                    and de.val_dom_typ_id = 18 and ' || v_flt_str;
                      execute immediate v_sql;
                  
                    commit;
        
                    
                    
                    -- Rule id 3:  Entity alternate  name exact match
                    
                     v_sql := ' insert into nci_ds_rslt (hdr_id,mtch_typ, item_id, ver_nr, rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr, 3, 100, ''Alternate Name Exact Match'' from alt_nms r, vw_de de
                    where ' || v_entty_nm ||  ' = r.MTCH_TERM and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt) and ' || v_flt_str;
                     execute immediate v_sql;
                    commit;
                    
                    
            -- Non enumerated only
            
                       v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr,  4, 100, ''Preferred Name Like Match'' from vw_de  de 
                    where ((instr(de.MTCH_TERM , ' || v_entty_nm || ',1) > 0 ) or (instr('|| v_entty_nm || ',de.MTCH_TERM , 1) > 0 ))
                     and currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                     and (' || v_hdr_id || ') not in (select hdr_id from nci_ds_rslt) and ' || v_flt_str;
                   --  raise_application_error(-20000, v_sql);
                     execute immediate v_sql;
                     commit;
                        -- Rule id 5:  Entity alternate question text name like match for non-enumerated
                    /*
                    v_sql := ' insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc, mtch_desc_txt)
                    select distinct ' ||  v_hdr_id || ', r.item_id, r.ver_nr,  5, 100, ''Question Text Like Match'', r.ref_desc from ref r, obj_key ok, vw_de de
                    where (instr(upper(r.ref_desc),' || v_entty_nm || ', 1) > 0  
                    or instr(' || v_entty_nm || ',  upper(r.ref_desc),1) > 0) and
                    r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%PREFERRED QUESTION%'' and r.ref_nm != ''%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (' || v_hdr_id || ', r.item_id, r.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt) and de.val_dom_typ_id = 18 and ' || v_flt_str;
                    --  raise_application_error(-20000, v_sql);
                execute immediate v_sql;
                    commit;
                   */
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr,  5, 100, ''Question Text Like Match'' from ref r, obj_key ok, vw_de de
                    where ((instr(r.MTCH_TERM ,' || v_entty_nm || ', 1) > 0  ) or (instr(' || v_entty_nm || ',r.MTCH_TERM , 1) > 0  ))                    and
                    r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and r.ref_nm != ''%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (' || v_hdr_id || ') not in (select  hdr_id from nci_ds_rslt) and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%'' and ' || v_flt_str;
                   --  raise_application_error(-20000, v_sql);
                execute immediate v_sql;
                    commit;
                                
                    -- Rule id 6:  Entity alternate  name like match for non-enumerated
                    /*
                    v_sql := ' insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id || ', r.item_id, r.ver_nr,  6, 100, ''Alternate Name Like Match'' from alt_nms r, vw_de de
                    where (instr(upper(r.nm_desc), ' || v_entty_nm || ',1) > 0 or instr(' || v_entty_nm || ', upper(r.nm_desc),1) > 0)
                    and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not  in (select hdr_id, item_id,Ver_nr from nci_ds_rslt) and ' || v_flt_str;
                    */
                    v_sql := ' insert into nci_ds_rslt (hdr_id, mtch_typ, item_id, ver_nr, rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id ||  ', ''' || v_mtch_typ || ''' , r.item_id, r.ver_nr,  6, 100, ''Alternate Name Like Match'' from alt_nms r, vw_de de
                    where ((instr( r.MTCH_TERM, ' || v_entty_nm || ',1) > 0) or (instr( ' || v_entty_nm || ', r.MTCH_TERM, 1) > 0))
                    and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ') not  in (select hdr_id from nci_ds_rslt) and ' || v_flt_str;
--                     execute immediate v_sql;
                    commit;
     


END;


procedure spDSMatchEnum ( v_hdr_id in number, v_usr_id in varchar2,v_flt_str in varchar2, v_mtch_typ in varchar2, v_mtch_nm in varchar2)

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
        v_hdr_id || ', ''' || v_mtch_typ || ''', de.item_id, de.ver_nr, ''NA'', 1, 100, ''Preferred Name Exact Match'' from   vw_de de where ' || v_entty_nm || '  = de.MTCH_TERM
         and currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%'' and ' || v_flt_str;
    --     raise_application_error(-20000, v_sql);
          execute immediate v_sql;
        --commit;
        
        -- Rule id 2:  Entity alternate question text name exact match
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select distinct ' || v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr, ''NA'', 2, 100, ''Question Text Exact Match'' from ref r, obj_key ok, vw_de de  where ' || v_entty_nm || '  = r.MTCH_TERM         and
        r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
        and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str;
    
         execute immediate v_sql;
        --commit;
        
        
        -- Rule id 3:  Entity alternate  name exact match
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id,mtch_typ,  item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select distinct ' || v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr, ''NA'', 3, 100, ''Alternate Name Exact Match'' from alt_nms r, vw_de de  where 
       ' || v_entty_nm || '  = r.MTCH_TERM
        and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
        and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and ' || v_flt_str;
         execute immediate v_sql;
        --commit;
        
        -- Rule id 4; Only for enumerated, Like
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''' , de.item_id, de.ver_nr, ''NA'', 4, 100, ''Preferred Name Like Match'' from vw_de  de 
                    where ((instr(de.MTCH_TERM, ' || v_entty_nm || ',1) > 0 ) or (instr(' || v_entty_nm || ', de.MTCH_TERM,1) > 0 ))' ||
         ' and currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
        and (' || v_hdr_id || ' , de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str;
         execute immediate v_sql;
        commit;
        
              v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr, perm_val_nm,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr,  ''NA'', 5, 100, ''Question Text Like Match'' from ref r, obj_key ok, vw_de de
                    where ((instr(r.MTCH_TERM,' || v_entty_nm || ', 1) > 0  ) or (instr(' || v_entty_nm || ',r.MTCH_TERM, 1) > 0  ))  and de.ADMIN_STUS_NM_DN not like ''%RETIRED%'' and
                    r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and r.ref_nm != ''%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (' || v_hdr_id || ', r.item_id, r.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str;
                --      raise_application_error(-20000, v_sql);
                execute immediate v_sql;
              
                    v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, mtch_typ, item_id, ver_nr,  perm_val_nm, rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id || ', ''' || v_mtch_typ || ''', r.item_id, r.ver_nr, ''NA'', 6, 100, ''Alternate Name Like Match'' from alt_nms r, vw_de de
                    where ((instr(r.MTCH_TERM, ' || v_entty_nm || ',1) > 0) or (instr(' || v_entty_nm || ',r.MTCH_TERM,1) > 0))
                    and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and de.ADMIN_STUS_NM_DN not like ''%RETIRED%''
                    and (' || v_hdr_id || ', r.item_id, r.ver_nr) not  in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and ' || v_flt_str;
                     execute immediate v_sql;
     

-- Second level run for PV comparisons
-- if called from CDE math
if (v_mtch_typ = 'CDE_MATCH') then
for cur in (select hdr_id,count(*) cnt from nci_ds_dtl d where hdr_id = v_hdr_id  group by hdr_id) loop
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv_lean v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
group by de_item_id,  de_ver_nr having count(*) = cur.cnt;
--commit;

if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH )
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*)  from vw_nci_de_pv_lean v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
group by de_item_id,
de_ver_nr having count(*) = cur.cnt;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;

if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*)  from vw_nci_de_pv_lean v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
group by de_item_id, de_ver_nr having count(*) >= cur.cnt*0.5;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;

if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select distinct cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)
from vw_nci_de_pv_lean v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
group by de_item_id, de_ver_nr having count(*) > cur.cnt*0.5;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;
end loop;

commit;
end if;
if (v_mtch_typ = 'QUESTION_MATCH') then
for cur in (select quest_imp_id,count(*) cnt from nci_STG_FORM_VV_IMPORT d where quest_imp_id = v_hdr_id  group by quest_imp_id) loop

insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC)
select cur.quest_imp_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*) , 'PV Match' from vw_nci_de_pv_lean v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR
and (cur.quest_imp_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.quest_imp_id)
and upper(v.perm_val_nm) in (select upper(src_perm_val) from NCI_STG_FORM_VV_IMPORT where quest_imp_id =cur.quest_imp_id)
group by de_item_id,  de_ver_nr having count(*) >= cur.cnt*0.5;
--commit;

--if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH, RULE_DESC)
select cur.quest_imp_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*) , 'VM Name Match' from vw_nci_de_pv v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR
and (cur.quest_imp_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.quest_imp_id)
and upper(v.item_nm) in (select upper(SRC_VM_NM) from NCI_STG_FORM_VV_IMPORT where quest_imp_id =cur.quest_imp_id)
and (cur.quest_imp_id, de_item_id, de_ver_nr) not in (Select hdr_id, item_id, ver_nr from nci_ds_rslt where hdr_id = cur.quest_imp_id)
group by de_item_id,  de_ver_nr having count(*) >= cur.cnt*0.5;
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

            action             := t_actionrowset(rows, 'VM Match Header', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;


    hookoutput.actions    := actions;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

 

END;
/
