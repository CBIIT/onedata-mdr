create or replace PACKAGE            nci_codemap_vm AS
 procedure spCopyVM ( v_src_mm_id in number, v_src_mm_ver_nr in number, v_tgt_mm_id in number, v_tgt_mm_ver_nr in number,v_user_id in varchar2, v_chk_ind in integer);

  procedure spGenerateValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
   procedure spGenerateValueMapAll ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);


procedure spDeleteValueMapping  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
--procedure dervTgtMECTemp; 

procedure spValidateValueMapImport ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spUpdateValueMapImport( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spAddValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spEditValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_mode in char);
 procedure spCopyValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure getPVSelection (v_vd_id in number, v_vd_ver in number, v_alt_nm_typ in integer, v_vd_typ in integer,  hookoutput in out t_hookOutput ) ;
 procedure spPostHookUpdVM( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure updValueMapRuleStr (v_mm_id number, v_mm_Ver number);
END;
/
create or replace PACKAGE BODY            nci_codemap_vm AS
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
--v_reg_str varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}';
--  v_reg_str_adv varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}|\s';
  v_reg_str_adv varchar2(255) := '[^A-Za-z0-9]';
v_reg_str varchar2(255) := '[^ A-Za-z0-9]';

procedure spGenerateValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    input_rows t_rows;
    output_rows t_rows;
    v_src_alt_nm_typ integer;
    v_tgt_alt_nm_typ integer;
    v_temp integer;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);

        if (ihook.getColumnValue(row_ori,'SRC_MEC_ID') is null or ihook.getColumnValue(row_ori,'TGT_MEC_ID') is null) then
          raise_application_error(-20000,'Both Source Characteristics and Target Characteristics have to be specified for Value Mapping Generation.');
        end if;

    for cur in (select * from nci_mdl_elmnt_char where mec_id in ( ihook.getColumnValue(row_ori,'SRC_MEC_ID'),
     ihook.getColumnValue(row_ori,'TGT_MEC_ID')) and CDE_ITEM_ID is null ) loop
           raise_application_error(-20000,'Both Source and Target Characteristics should have CDE specified for Value Mapping Generation.');
     end loop;

    for cur in (Select m.* from nci_mdl m, nci_mdl_map mm where mm.item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mm.ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') and mm.SRC_MDL_ITEM_ID = m.item_id and mm.SRC_MDL_VER_NR = m.VER_NR) loop

    v_src_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
    end loop;
    for cur in (Select m.* from nci_mdl m, nci_mdl_map mm where mm.item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mm.ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') and mm.TGT_MDL_ITEM_ID = m.item_id and mm.TGT_MDL_VER_NR = m.VER_NR) loop

    v_tgt_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
    end loop;
  --  raise_application_error(-20000, v_src_alt_nm_typ);

    input_rows := t_rows();
    output_rows := t_rows();

    for cur in (select val_dom_item_id, val_dom_ver_nr, cde_item_id, cde_ver_nr from nci_mdl_elmnt_char c, value_dom v where mec_id = ihook.getColumnValue(row_ori,'SRC_MEC_ID') and
    c.val_dom_item_id = v.item_id and c.val_dom_ver_Nr = v.ver_nr) loop
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
        ihook.setColumnValue (row, 'CDE_ITEM_ID', cur.cde_item_id);
      ihook.setColumnValue (row, 'CDE_VER_NR', cur.cde_ver_nr);
     input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;


    for cur in (select val_dom_item_id, val_dom_ver_nr, cde_item_id, cde_ver_nr  from nci_mdl_elmnt_char c, value_dom v where mec_id = ihook.getColumnValue(row_ori,'TGT_MEC_ID')  and
    c.val_dom_item_id = v.item_id and c.val_dom_ver_Nr = v.ver_nr ) loop
    --and v.val_dom_typ_id = 17) loop
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
        ihook.setColumnValue (row, 'CDE_ITEM_ID', cur.cde_item_id);
      ihook.setColumnValue (row, 'CDE_VER_NR', cur.cde_ver_nr);
     input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;

    if (input_rows.count < 2) then
      raise_application_error(-20000, 'Error in generation. Please contact Administrator.');
    end if;
   --   raise_application_error(-20000, input_rows.count);


    nci_11179_2.spCreateValueMap(input_rows, output_rows, v_src_alt_nm_typ, v_tgt_alt_nm_typ);

    delete from NCI_MEC_VAL_MAP where src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID') and 
 mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') and map_deg not in (120,131);-- and mecm_id = ihook.getColumnValue(row_ori,'MECM_ID');
    commit;
    delete from onedata_ra.NCI_MEC_VAL_MAP where 
    src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') 
    and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID') and mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') ;--and mecm_id = ihook.getColumnValue(row_ori,'MECM_ID');
    commit;

    rows := t_rows();
    for i in 1..output_rows.count loop
        row := row_ori;
 --   raise_application_error(-20000,output_rows.count);

       /* select count(*) into v_temp from nci_mec_val_map where src_mec_id =ihook.getColumnValue(row_ori, 'SRC_MEC_ID')
        and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID')
        and nvl(src_pv,0) = nvl(ihook.getColumnValue(output_rows(i),'1'),0)
        and nvl(tgt_pv,0) = nvl(ihook.getColumnValue(output_rows(i),'2'),0)
        and mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') ;*/
    v_temp := 0;
        if (v_temp = 0) then -- insert
        insert into nci_mec_val_map (SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
        SRC_LBL, TGT_LBL, MAP_DEG, MECM_ID,SRC_VM_CNCPT_CD, SRC_VM_CNCPT_NM, TGT_VM_CNCPT_CD, TGT_VM_CNCPT_NM,
        SRC_VD_ITEM_ID,SRC_VD_VER_NR,SRC_CDE_ITEM_ID,SRC_CDE_VER_NR,
        TGT_VD_ITEM_ID,TGT_VD_VER_NR,TGT_CDE_ITEM_ID,TGT_CDE_VER_NR)
        select ihook.getColumnValue(row_ori, 'SRC_MEC_ID'),ihook.getColumnValue(row_ori, 'TGT_MEC_ID'),ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID'),
        ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR'),ihook.getColumnValue(output_rows(i),'1'),ihook.getColumnValue(output_rows(i),'2'),
        ihook.getColumnValue(output_rows(i),'VM Concept Codes'),ihook.getColumnValue(output_rows(i),'VM Name'),
        ihook.getColumnValue(output_rows(i),'LBL_1'),ihook.getColumnValue(output_rows(i),'LBL_2'),
        decode(ihook.getColumnValue(output_rows(i),'1'),null,130,decode(ihook.getColumnValue(output_rows(i),'2'),null,130,86)),
        ihook.getColumnValue(row_ori, 'MECM_ID'), ihook.getColumnValue(output_rows(i),'Source Concept Code'),
        ihook.getColumnValue(output_rows(i),'Source Concept Name'),ihook.getColumnValue(output_rows(i),'Target Concept Code'),
        ihook.getColumnValue(output_rows(i),'Target Concept Name'),
        ihook.getColumnValue(output_rows(i),'SRC_VD_ITEM_ID'),
        ihook.getColumnValue(output_rows(i),'SRC_VD_VER_NR'),
         ihook.getColumnValue(output_rows(i),'SRC_CDE_ITEM_ID'),
         ihook.getColumnValue(output_rows(i),'SRC_CDE_VER_NR'),
       ihook.getColumnValue(output_rows(i),'TGT_VD_ITEM_ID'),
        ihook.getColumnValue(output_rows(i),'TGT_VD_VER_NR'),
         ihook.getColumnValue(output_rows(i),'TGT_CDE_ITEM_ID'),
         ihook.getColumnValue(output_rows(i),'TGT_CDE_VER_NR')
        from dual;


       /*
        ihook.setColumnValue(row,'SRC_PV',ihook.getColumnValue(output_rows(i),'1'));
        ihook.setColumnValue(row,'TGT_PV',ihook.getColumnValue(output_rows(i),'2'));
        ihook.setColumnValue(row,'SRC_LBL',ihook.getColumnValue(output_rows(i),'LBL_1'));
        ihook.setColumnValue(row,'TGT_LBL',ihook.getColumnValue(output_rows(i),'LBL_2'));
        ihook.setColumnValue(row,'VM_CNCPT_CD',ihook.getColumnValue(output_rows(i),'VM Concept Codes'));
        ihook.setColumnValue(row,'VM_CNCPT_NM',ihook.getColumnValue(output_rows(i),'VM Name'));
        -- Semantic map if both source and target pv present.
        if (ihook.getColumnValue(row,'SRC_PV') is not null and ihook.getColumnValue(row,'TGT_PV') is not null) then 
            ihook.setColumnValue(row,'MAP_DEG',86);
        else
                ihook.setColumnValue(row,'MAP_DEG',130);-- not mapped yet.
        end if;
        ihook.setColumnValue(row,'MECVM_ID',-1); 
        rows.extend;     rows(rows.last) := row;*/

        end if;

    end loop;
    commit;
      delete from nci_mec_val_map where map_deg not in (120,131) and mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') and src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID')
    and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID') and src_pv is not null and (   src_pv) in
    (select  src_pv from nci_mec_val_map where map_deg in ( 120,131) and mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') and src_pv is not null and src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID')
    and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID') );
    commit;

    insert into  onedata_ra.NCI_MEC_VAL_MAP 
    select * from nci_mec_val_map where  
    src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') 
    and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID') and mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR');
    commit;


   -- raise_application_Error(-20000,rows.count);
      --      action := t_actionrowset(rows, 'Model Map Characteristic Values', 2,2,'insert');
       -- actions.extend;
        --actions(actions.last) := action;
/*
        row:= t_row();
        ihook.setColumnValue(row, 'MECM_ID',ihook.getColumnValue(row_ori, 'MECM_ID'));
        ihook.setColumnValue(row,'VAL_MAP_CREATE_IND',1);
        rows := t_rows();
        rows.extend;     rows(rows.last) := row;

            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,3,'update');
        actions.extend;
        actions(actions.last) := action; 
*/
  --hookoutput.actions := actions;

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL', v_data_out);

end;


 procedure spPostHookUpdVM( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
 as 
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    row   t_row;
    v_item_id number;
    v_ver_nr number(4,2);
    action t_actionRowset;
   actions t_actions := t_actions();
      rows      t_rows;
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   if ( ihook.getColumnValue(row_ori, 'MAP_DEG')  in (86,87) and ihook.getColumnValue(row_ori, 'MAP_DEG') <> ihook.getColumnOldValue(row_ori, 'MAP_DEG') ) then
      raise_application_error(-20000, 'Mapping type cannot be manually set to Semantically Equivalent.');
    return;
    end if;
    
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


procedure spGenerateValueMapAll ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    input_rows t_rows;
    output_rows t_rows;
    v_src_alt_nm_typ integer;
    v_tgt_alt_nm_typ integer;
    rows_v t_rows := t_rows();
    rows_x t_rows := t_rows();
    v_temp integer;
    v_id number;
    v_ver_nr number(4,2);

begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);

  v_id := ihook.getColumnValue(row_ori,'ITEM_ID') ;
  v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR') ;
  
 if (hookinput.invocationNUmber = 0) then
 hookoutput.question := nci_form_curator.getProceedQuestion ('Proceed', 'Please confirm value map generation for: ' || v_id || 'v' || v_ver_nr);
 else

     delete from NCI_MEC_VAL_MAP where map_deg not in ( 120,131) and mdl_map_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'VER_NR');
    commit;
    delete from onedata_ra.NCI_MEC_VAL_MAP where  mdl_map_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'VER_NR');
    commit;

         for cur in (Select m.* from nci_mdl m, nci_mdl_map mm where mm.item_id = ihook.getColumnValue(row_ori,'ITEM_ID') 
    and mm.ver_nr = ihook.getColumnValue(row_ori,'VER_NR') and mm.SRC_MDL_ITEM_ID = m.item_id and mm.SRC_MDL_VER_NR = m.VER_NR) loop

    v_src_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
    end loop;
    for cur in (Select m.* from nci_mdl m, nci_mdl_map mm where mm.item_id = ihook.getColumnValue(row_ori,'ITEM_ID') 
    and mm.ver_nr = ihook.getColumnValue(row_ori,'VER_NR') and mm.TGT_MDL_ITEM_ID = m.item_id and mm.TGT_MDL_VER_NR = m.VER_NR) loop

    v_tgt_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
    end loop;
    -- Semantically similar
    for outercur in (select  src_mec_id, tgt_mec_id, substr(','||listagg(mecm_id, ',') WITHIN GROUP (ORDER by mecm_ID)||',',1,4000) mecm_id_desc from VW_MDL_MAP_IMP_TEMPLATE where MODEL_MAP_ID=ihook.getColumnValue(row_ori,'ITEM_ID')  and MODEL_MAP_VERSION=ihook.getColumnValue(row_ori,'VER_NR')
  --  and (upper(SOURCE_DOMAIN_TYPE)= 'ENUMERATED' or upper(TARGET_DOMAIN_TYPE)='ENUMERATED')and src_mec_id is not null and tgt_mec_id is not null) loop
    and (upper(SOURCE_DOMAIN_TYPE)= 'ENUMERATED' or upper(TARGET_DOMAIN_TYPE) = 'ENUMERATED')
   -- and upper(TARGET_DOMAIN_TYPE)='ENUMERATED')
    and src_mec_id is not null and tgt_mec_id is not null
    group by src_mec_id, tgt_mec_id) loop
    --and upper(MAPPING_DEGREE)='SEMANTIC SIMILAR') loop

  --  raise_application_error(-20000, v_src_alt_nm_typ);

    input_rows := t_rows();
    output_rows := t_rows();

    for cur in (select val_dom_item_id, val_dom_ver_nr, cde_item_id, cde_ver_nr from nci_mdl_elmnt_char c, value_dom v where mec_id = outercur.SRC_MEC_ID and
    c.val_dom_item_id = v.item_id and c.val_dom_ver_Nr = v.ver_nr ) loop
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
    ihook.setColumnValue (row, 'CDE_ITEM_ID', cur.cde_item_id);
      ihook.setColumnValue (row, 'CDE_VER_NR', cur.cde_ver_nr);
         ihook.setColumnValue(row,'MECM_ID_desc', outercur.MECM_ID_desc);
      input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;

    for cur in (select val_dom_item_id, val_dom_ver_nr , cde_item_id, cde_ver_nr from nci_mdl_elmnt_char c, value_dom v where mec_id = outercur.TGT_MEC_ID  and
    c.val_dom_item_id = v.item_id and c.val_dom_ver_Nr = v.ver_nr ) loop
      if(input_rows.count = 0) then
      -- insert dummy row

      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', 1);
      ihook.setColumnValue (row, 'VER_NR', 1);
       ihook.setColumnValue (row, 'CDE_ITEM_ID', cur.cde_item_id);
      ihook.setColumnValue (row, 'CDE_VER_NR', cur.cde_ver_nr);
      input_rows.extend;  input_rows(input_rows.last) := row;
      end if;
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
         ihook.setColumnValue (row, 'CDE_ITEM_ID', cur.cde_item_id);
      ihook.setColumnValue (row, 'CDE_VER_NR', cur.cde_ver_nr);
    input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;



    nci_11179_2.spCreateValueMap(input_rows, output_rows, v_src_alt_nm_typ, v_tgt_alt_nm_typ);



    rows := t_rows();
    for i in 1..output_rows.count loop
         /*    select count(*) into v_temp from nci_mec_val_map where src_mec_id =ihook.getColumnValue(row_ori, 'SRC_MEC_ID')
        and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID')
        and nvl(src_pv,0) = nvl(ihook.getColumnValue(output_rows(i),'1'),0)
        and nvl(tgt_pv,0) = nvl(ihook.getColumnValue(output_rows(i),'2'),0)
        and mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') ;*/
    v_temp := 0;
        if (v_temp = 0) then -- insert
        insert into nci_mec_val_map (SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
           SRC_LBL, TGT_LBL, MAP_DEG, MECM_ID_desc,SRC_VM_CNCPT_CD, SRC_VM_CNCPT_NM, TGT_VM_CNCPT_CD, TGT_VM_CNCPT_NM,
              SRC_VD_ITEM_ID,SRC_VD_VER_NR,SRC_CDE_ITEM_ID,SRC_CDE_VER_NR,
        TGT_VD_ITEM_ID,TGT_VD_VER_NR,TGT_CDE_ITEM_ID,TGT_CDE_VER_NR)
        select outercur.SRC_MEC_ID,outercur.TGT_MEC_ID,ihook.getColumnValue(row_ori, 'ITEM_ID'),
        ihook.getColumnValue(row_ori, 'VER_NR'),ihook.getColumnValue(output_rows(i),'1'),ihook.getColumnValue(output_rows(i),'2'),
        ihook.getColumnValue(output_rows(i),'VM Concept Codes'),ihook.getColumnValue(output_rows(i),'VM Name'),
        ihook.getColumnValue(output_rows(i),'LBL_1'),ihook.getColumnValue(output_rows(i),'LBL_2'), 
        decode(ihook.getColumnValue(output_rows(i),'1'),null,130,decode(ihook.getColumnValue(output_rows(i),'2'),null,130,86)),
        outercur.MECM_ID_desc , 
        
        ihook.getColumnValue(output_rows(i),'Source Concept Code'),
        ihook.getColumnValue(output_rows(i),'Source Concept Name'),ihook.getColumnValue(output_rows(i),'Target Concept Code'),
        ihook.getColumnValue(output_rows(i),'Target Concept Name'), ihook.getColumnValue(output_rows(i),'SRC_VD_ITEM_ID'),
        ihook.getColumnValue(output_rows(i),'SRC_VD_VER_NR'),
         ihook.getColumnValue(output_rows(i),'SRC_CDE_ITEM_ID'),
         ihook.getColumnValue(output_rows(i),'SRC_CDE_VER_NR'),
       ihook.getColumnValue(output_rows(i),'TGT_VD_ITEM_ID'),
        ihook.getColumnValue(output_rows(i),'TGT_VD_VER_NR'),
         ihook.getColumnValue(output_rows(i),'TGT_CDE_ITEM_ID'),
         ihook.getColumnValue(output_rows(i),'TGT_CDE_VER_NR') from dual;

/*    row := t_row();
         ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori,'ITEM_ID'));
      ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue(row_ori,'VER_NR'));

        ihook.setColumnValue(row,'SRC_MEC_ID',outercur.src_mec_id);
        ihook.setColumnValue(row,'TGT_MEC_ID',outercur.TGT_mec_id);

       ihook.setColumnValue(row,'MECM_ID',ihook.getColumnValue(output_rows(i),'MECM_ID'));

        ihook.setColumnValue(row,'SRC_PV',ihook.getColumnValue(output_rows(i),'1'));
        ihook.setColumnValue(row,'TGT_PV',ihook.getColumnValue(output_rows(i),'2'));
        ihook.setColumnValue(row,'SRC_LBL',ihook.getColumnValue(output_rows(i),'LBL_1'));
        ihook.setColumnValue(row,'TGT_LBL',ihook.getColumnValue(output_rows(i),'LBL_2'));
        ihook.setColumnValue(row,'VM_CNCPT_CD',ihook.getColumnValue(output_rows(i),'VM Concept Codes'));
        ihook.setColumnValue(row,'VM_CNCPT_NM',ihook.getColumnValue(output_rows(i),'VM Name'));
        -- source pv and target pv are both present then mapping - sematic else not yet mapped
        if (ihook.getColumnValue(row,'SRC_PV') is not null and ihook.getColumnValue(row,'TGT_PV') is not null) then 
         ihook.setColumnValue(row,'MAP_DEG',86);
        else
                ihook.setColumnValue(row,'MAP_DEG',130);
        end if;
        ihook.setColumnValue(row,'MECVM_ID',-1);

                                     rows_v.extend;
                                            rows_v(rows_v.last) := row;*/
                    end if;

    end loop;
   -- raise_application_Error(-20000,rows.count);
     commit;
     -- delete where mapping degree is Derived From
     delete from nci_mec_val_map where map_deg not in ( 120,131) and mdl_map_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'VER_NR') and src_pv is not null and (src_mec_id, tgt_mec_id ,   src_pv) in
    (select src_mec_id, tgt_mec_id ,   src_pv from nci_mec_val_map where map_deg in ( 120,131) and mdl_map_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'VER_NR') and src_pv is not null);
    commit;
        row:= t_row();
    --    ihook.setColumnValue(row, 'MECM_ID',outercur.MECM_ID);
    --    ihook.setColumnValue(row,'VAL_MAP_CREATE_IND',1);
      --  rows_x.extend;     rows_x(rows_x.last) := row;


    end loop;
     --action := t_actionrowset(rows_v, 'Model Map Characteristic Values', 2,2,'insert');
     --   actions.extend;
      ---  actions(actions.last) := action;
        --   action := t_actionrowset(rows_x, 'Model Map - Characteristics', 2,3,'update');
        --actions.extend;
       -- actions(actions.last) := action; 
 -- hookoutput.actions := actions;

    insert into  onedata_ra.NCI_MEC_VAL_MAP 
    select * from nci_mec_val_map where  
     mdl_map_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'VER_NR');
    commit;
end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL', v_data_out);

end;


  procedure spCopyVM ( v_src_mm_id in number, v_src_mm_ver_nr in number, v_tgt_mm_id in number, v_tgt_mm_ver_nr in number, v_user_id in varchar2,v_chk_ind in integer)
  as
i integer;
begin
if (v_chk_ind = 0) then -- no check
insert into nci_mec_val_Map (SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, 
SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
PROV_ORG_ID, PROV_CNTCT_ID, PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, SRC_LBL, TGT_LBL, PROV_NOTES, MAP_DEG,CREAT_USR_ID, LST_UPD_USR_ID,
SRC_VM_CNCPT_CD, TGT_VM_CNCPT_CD, SRC_VM_CNCPT_NM, TGT_VM_CNCPT_NM)
select SRC_MEC_ID, TGT_MEC_ID, v_tgt_mm_id, v_tgt_mm_ver_nr, 
SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
PROV_ORG_ID, PROV_CNTCT_ID, PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, SRC_LBL, TGT_LBL, PROV_NOTES, MAP_DEg, v_user_id, v_user_id,
SRC_VM_CNCPT_CD, TGT_VM_CNCPT_CD, SRC_VM_CNCPT_NM, TGT_VM_CNCPT_NM
from nci_mec_val_map where mdl_map_item_id = v_src_mm_id and mdl_map_ver_nr = v_src_mm_ver_nr;
commit;

insert into onedata_Ra.nci_mec_val_map (MECVM_ID,
SRC_MEC_ID,
TGT_MEC_ID,
MDL_MAP_ITEM_ID,
MDL_MAP_VER_NR) select MECVM_ID,
SRC_MEC_ID,
TGT_MEC_ID,
MDL_MAP_ITEM_ID,
MDL_MAP_VER_NR from onedata_wa.nci_mec_val_map where  mdl_map_item_id = v_tgt_mm_id and mdl_map_ver_nr = v_tgt_mm_ver_nr;
commit;
end if;
end;

procedure spDeleteValueMapping  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
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

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;


 for i in 1..hookInput.originalRowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);
 delete from nci_mec_val_map where mecvm_id = ihook.getColumnValue(row_ori,'MECVM_ID');
 delete from onedata_ra.nci_mec_val_map where mecvm_id = ihook.getColumnValue(row_ori,'MECVM_ID');

end loop;
commit;
hookoutput.message := hookInput.originalRowset.rowset.count ||  ' Value Mapping(s) deleted.';
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;



   procedure spUpdateValueMapImport( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowsadd  t_rows;
  rowsupd  t_rows;
  rows t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
  v_add boolean;
  v_temp integer;
  i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  rowsadd := t_rows();
  rowsupd := t_rows();
  rows := t_rows();
 
  for i in 1..hookinput.originalRowset.rowset.count loop
  row_ori :=  hookInput.originalRowset.rowset(i);

    if ( nvl(ihook.getColumnValue(row_ori, 'CTL_VAL_STUS'),'IMPORTED') = 'VALIDATED') then

        ihook.setcolumnValue(row_ori, 'MECVM_ID', nvl(ihook.getColumnValue(row_ori,'MECVM_ID'),ihook.getColumnValue(row_ori,'STG_MECVM_ID')));
        Select count(*) into v_temp  from nci_mec_VAL_map where mecvm_id = ihook.getcolumnValue(row_ori,'MECVM_ID');

        if (v_temp= 0) then
            rowsadd.extend;   rowsadd(rowsadd.last) := row_ori;
 --   raise_application_error(-20000,' Add');
        else
        row := t_row();
        ihook.setColumnValue(row, 'MECVM_ID',ihook.getColumnValue(row_ori, 'MECVM_ID'));
        ihook.setColumnValue(row, 'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID'));
        ihook.setColumnValue(row, 'MDL_MAP_VER_NR',ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR'));
        ihook.setColumnValue(row, 'SRC_MEC_ID', ihook.getColumnValue(row_ori, 'SRC_MEC_ID'));
        ihook.setColumnValue(row, 'TGT_MEC_ID', ihook.getColumnValue(row_ori, 'TGT_MEC_ID'));
        ihook.setColumnValue(row, 'SRC_PV', ihook.getColumnValue(row_ori, 'SRC_PV'));
        ihook.setColumnValue(row, 'TGT_PV', ihook.getColumnValue(row_ori, 'TGT_PV'));
        ihook.setColumnValue(row, 'MAP_DEG', 120);


        rowsupd.extend;   rowsupd(rowsupd.last) := row;
     --   raise_application_error(-20000,' Update');
    end if;

    ihook.setColumnValue(row_ori,'CTL_VAL_STUS','UPDATED');
     rows.extend;   rows(rows.last) := row_ori;

    end if; 
 end loop;

  if (rowsadd.count>0) then
   action := t_actionrowset(rowsadd, 'Value Map (Hook)', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;
    end if;

 if (rowsupd.count>0) then
   action := t_actionrowset(rowsupd, 'Value Map (Hook)', 2,1,'update');
        actions.extend;
        actions(actions.last) := action;
    end if;

  if (rows.count>0) then
   action := t_actionrowset(rows, 'Value Map Import', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
  --  raise_application_error(-20000,' Actions');
        hookoutput.actions := actions;
    end if;

 hookoutput.message:= 'New mapping inserted: ' || rowsadd.count || ' Mapping updated: ' || rowsupd.count;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 nci_util.debugHook('GENERAL',v_data_out);
end;

   procedure spValidateValueMapImport ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
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
  v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
  v_valid boolean;
  v_val_stus_msg varchar2(2000);
 i integer;
 j integer;
 k integer;
 v_nm varchar2(4000);
 v_typ integer;
 v_dflt_typ integer;
 v_temp integer;
 v_found boolean;
 v_mm_id number;
 v_mm_ver number(4,2);
 v_st_ts timestamp;
 v_end_ts timestamp;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  rows := t_rows();
 row_ori :=  hookInput.originalRowset.rowset(1);
 v_mm_id := ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID');
v_mm_ver:= ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR');
 v_st_ts := systimestamp();
  for cur1 in (Select * from nci_stg_mec_val_map where mdl_map_item_id = v_mm_id and mdl_map_ver_nr = v_mm_ver 
  and BTCH_NM = ihook.getColumnValue(row_ori, 'BTCH_NM') and BTCH_USR_NM =  ihook.getColumnValue(row_ori, 'BTCH_USR_NM')
  and CTL_VAL_STUS in ( 'IMPORTED','ERROR','VALIDATED')) loop
      v_valid := true;
      v_val_stus_msg := '';


-- Validate that the source elemnt/char and target element/char belong to the current source and target model
-- validate that both ME and MEC are specified. May be blank.
    if (cur1.SRC_ME_PHY_NM is null or  cur1.SRC_MEC_PHY_NM is  null )  then
        v_valid := false;
        v_val_stus_msg := 'Both Source Element and Characteristics have to be specified; ';
    end if;
    
    if (cur1.TGT_ME_PHY_NM is null or  cur1.TGT_MEC_PHY_NM is  null )  then
        v_valid := false;
        v_val_stus_msg := 'Both Target Element and Characteristics have to be specified; ';
    end if;

    if ( cur1.SRC_ME_PHY_NM is not null and  cur1.SRC_MEC_PHY_NM is not null) then 
        ihook.setColumnValue(row_ori, 'SRC_MEC_ID','');
        for cur in (
            select mec.mec_id from  nci_mdl_elmnt me, nci_mdl_elmnt_char mec, nci_mdl_map mm where me.MDL_ITEM_ID = mm.src_mdl_item_id 
            and me.MDL_ITEM_VER_NR = mm.src_mdl_ver_Nr
            and mm.item_id  = v_mm_id
            and mm.ver_nr = v_mm_ver and  me.ITEM_PHY_OBJ_NM =cur1.SRC_ME_PHY_NM
            and MEC.MEC_PHY_NM=cur1.SRC_MEC_PHY_NM and me.ITEM_ID = mec.MDL_ELMNT_ITEM_ID and me.ver_nr = mec.MDL_ELMNT_VER_NR) loop
              ihook.setColumnValue(row_ori, 'SRC_MEC_ID', cur.mec_id);
        end loop;
    
        if (ihook.getColumnValue(row_ori, 'SRC_MEC_ID') is null) then 
            v_valid := false;
            v_val_stus_msg := v_val_stus_msg || 'Invalid Source Characteristics; '|| chr(13);
        end if;
    end if;    

    if ( cur1.TGT_ME_PHY_NM is not null and cur1.TGT_MEC_PHY_NM is not null) then 
        for cur in (
        select mec.mec_id from  nci_mdl_elmnt me, nci_mdl_elmnt_char mec, nci_mdl_map mm where me.MDL_ITEM_ID = mm.tgt_mdl_item_id 
        and me.MDL_ITEM_VER_NR = mm.tgt_mdl_ver_Nr
        and mm.item_id  = v_mm_id
        and mm.ver_nr =v_mm_ver and  me.ITEM_PHY_OBJ_NM =cur1.TGT_ME_PHY_NM
        and MEC.MEC_PHY_NM=cur1.TGT_MEC_PHY_NM and me.ITEM_ID = mec.MDL_ELMNT_ITEM_ID and me.ver_nr = mec.MDL_ELMNT_VER_NR) loop
          ihook.setColumnValue(row_ori, 'TGT_MEC_ID', cur.mec_id);
        end loop;
        if (ihook.getColumnValue(row_ori, 'TGT_MEC_ID') is null) then 
            v_valid := false;
            v_val_stus_msg := v_val_stus_msg || 'Invalid Target Characteristics; '|| chr(13);
        end if;
    end if;    

    if (cur1.IMP_PROV_ORG is not null and cur1.PROV_ORG_ID is null ) then
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'Imported Provenance Organization is incorrect; '|| chr(13);
    end if;

    
    if (cur1.IMP_PROV_CNTCT is not null and  cur1.PROV_CNTCT_ID is null ) then
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'Imported Provenance Contact is incorrect; '|| chr(13);
    end if;

 -- Rules id provided is incorrect.
    
    if (cur1.MECVM_ID is not null) then
        select count(*) into v_temp from NCI_MEC_VAL_MAP where  MDL_MAP_ITEM_ID  = v_mm_id
        and MDL_MAP_VER_NR = v_mm_ver and MECVM_ID=cur1.mecvm_id and nvl(fld_Delete,0) = 0
        and src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID');
        if (v_temp = 0) then
            v_valid := false;
            v_val_stus_msg := v_val_stus_msg ||'Imported VM Rule ID or Source/Target element/characteristic information is incorrect or does not exist. '|| chr(13);
    
        end if;    
    end if;
    
     -- duplicate based on src/tgt/op/src func/tgt func/condition/operator
     if (v_valid = true) then -- check for duplicate
        for cur in (select * from nci_mec_val_map where mdl_map_item_id = v_mm_id
        and mdl_map_ver_nr =  v_mm_ver and nvl(src_mec_id,0) = nvl( ihook.getColumnValue(row_ori, 'SRC_MEC_ID'),0)
        and  cur1.mecvm_id is null and src_pv = cur1.SRC_PV 
        ) loop
           v_valid := false;
            v_val_stus_msg := v_val_stus_msg ||'Duplicate found with Value Map Rule ID: '|| cur.MECVM_ID ||  chr(13);
       end loop;
     end if;

    -- if enumerated, then check PV values
  if (v_Valid = true) then 
      v_found := false;
      if (cur1.src_pv is not null) then
      for cur in (Select * from vw_nci_mec where mec_id = ihook.getColumnValue(row_ori,'SRC_MEC_ID') and  val_dom_typ_desc= 'Enumerated' and ihook.getColumnValue(row_ori,'SRC_PV') is not null) loop
      j := nci_11179.getWordCountDelim(cur1.SRC_PV,'\|');
      for k in 1..j loop
      v_nm :=upper(nci_11179.getWordDelim(cur1.SRC_PV,k,j,'|'));
      select count(*) into v_temp from perm_Val where val_dom_item_id = cur.val_dom_item_id and val_dom_Ver_nr = cur.val_dom_ver_nr and 
      upper(perm_val_nm) = v_nm;
      if (v_temp = 0) then
           v_valid := false;
      End if;
      -- check if value already in the value map table if enumerated
      /*select count(*) into v_temp from nci_mec_val_map where src_mec_id =  and upper(v_nm) = upper(SRc_PV);
       if (v_temp = 0) then
           v_found := true;
      End if;*/
      end loop;
     
    if (v_valid = false) then
        v_val_stus_msg := v_val_stus_msg ||'Source PV specified is not valid.' ||  chr(13);
    end if;
    if (v_found = true) then
        v_val_stus_msg := v_val_stus_msg ||'Source PV for enumerated Value Domain found. Duplicates cannot be inserted.' ||  chr(13);
        v_valid := false;
    end if;
      end loop;
      end if;
  
 -- v_valid := true;
  if cur1.tgt_pv is not null and v_Valid = true then
  for cur in (Select * from vw_nci_mec where mec_id = ihook.getColumnValue(row_ori,'TGT_MEC_ID') and val_dom_typ_desc = 'Enumerated' and ihook.getColumnValue(row_ori,'TGT_PV') is not null) loop
  j := nci_11179.getWordCountDelim(cur1.TGT_PV,'\|');
   for k in 1..j Loop
  v_nm :=upper(nci_11179.getWordDelim(cur1.TGT_PV,k,j,'|'));
  --raise_application_error(-20000,  j || '- ' || ihook.getColumnValue(row_ori,'TGT_PV') || '- ' || v_nm);
 select count(*) into v_temp from perm_Val where val_dom_item_id = cur.val_dom_item_id and val_dom_Ver_nr = cur.val_dom_ver_nr and 
  upper(perm_val_nm) = v_nm;
  if (v_temp = 0) then
       v_valid := false;

  End if;
  end loop;
  if (v_valid = false) then
        v_val_stus_msg := v_val_stus_msg ||'Target PV specified is not valid.' ||  chr(13);
        end if;
  end loop;
  end if;
  end if;-- v_valid is tru

  if (v_valid = false) then 
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','ERROR');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',v_val_stus_msg);
  else
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','VALIDATED');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','Valid');
  end if;
  
  

update nci_stg_mec_val_map set CTL_VAL_STUS= ihook.getColumnValue(row_ori,'CTL_VAL_STUS'),
   CTL_VAL_MSG= ihook.getColumnValue(row_ori,'CTL_VAL_MSG'),
   SRC_MEC_ID = ihook.getColumnValue(row_ori, 'SRC_MEC_ID'), 
   TGT_MEC_ID = ihook.getColumnValue(row_ori, 'TGT_MEC_ID')
    where STG_MECVM_ID = cur1.STG_MECVM_ID;


--     rows.extend;   rows(rows.last) := row_ori;
 end loop;
  commit;  

   --action := t_actionrowset(rows, 'Value Map Import', 2,6,'update');
     --   actions.extend;
       -- actions(actions.last) := action;

       --hookoutput.actions := actions;
updValueMapRuleStr (v_mm_id, v_mm_ver);

 v_end_ts := systimestamp();
 
 hookoutput.message:= 'Validation completed. Execution time in seconds: ' ||  extract( day from(v_end_ts - v_st_ts)*24*60*60);
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  -- nci_util.debugHook('GENERAL',v_data_out);
end;

procedure updValueMapRuleStr (v_mm_id number, v_mm_Ver number) as
i integer;
begin
 execute immediate 'ALTER trigger TR_NCI_MEC_VAL_MAP_TS disable';
update nci_stg_mec_val_map svm set mecm_id_Desc =  
(select substr(','||listagg(mecm_id, ',') WITHIN GROUP (ORDER by mecm_ID)||',',1,4000) mecm_id_desc 
from nci_mec_map m where MDL_MAP_ITEM_ID=v_mm_id and MDL_MAP_VER_NR=v_mm_ver
  and m.src_mec_id = svm.src_mec_id and m.tgt_mec_id = svm.tgt_mec_id and m.src_mec_id is not null and m.tgt_mec_id is not null)
where mdl_map_item_id = v_mm_id and mdl_map_ver_nr =v_mm_ver;
commit;
execute immediate 'ALTER trigger TR_NCI_MEC_VAL_MAP_TS enable';
end;

function getPVForm (v_cur_text in varchar2)  return t_forms is
  forms t_forms;
  form1 t_form;
  rowset t_rowset;
  rows t_rows;
  row t_row;
begin
    rows := t_rows();
    row := t_row();
    ihook.setColumnValue(row,'CUR_PV','.');
    rows.extend;     rows(rows.last) := row;
    rowset := t_rowset(rows,'Value Map (Edit Hook)',1,'VW_VAL_MAP_EDIT');

    forms                  := t_forms();
    form1                  := t_form('Value Map (Edit Hook)', 2,1);
    form1.rowset :=rowset;

   forms.extend;    forms(forms.last) := form1;

  return forms;
end;


-- assuming v_Valid is true and v_err_Str is null when called.  
procedure validateValMapAddEdit (row_ori in t_row, v_vd_typ in integer, v_end_point_ind in char, v_mode in char, v_valid in out boolean, v_err_str in out varchar2 ) 
as
  i integer;
begin
--raise_application_error(-20000, v_vd_typ || v_end_point_ind || v_mode);
if (v_mode ='U') and ihook.getColumnValue(row_ori,'MAP_DEG') not in (130,120)  then
  v_valid := false;
  v_err_str := 'Cannot update PV for Semantically Equivalent.';
end if;
  if (v_vd_typ = 17 and v_end_point_ind = 'S' and v_mode = 'I') then -- Enuerated cannot Insert or update
  v_valid := false;
  --jira 3788
  v_err_str := 'Cannot insert new Value Map Rule for a Mapping where the Source PV is Enumerated.';
  --v_err_str := 'Cannot insert new Value Map Rule for a Mapping where the Source PV is Enumerated. Please generate Value Mapping first';
  end if;
   if (v_vd_typ = 17 and v_end_point_ind = 'S' and v_mode = 'U') then
  v_valid := false;
  v_err_str := 'Cannot update Source PV for Enumerated Value Domains.';
  end if;

end;

procedure getPVSelection (v_vd_id in number, v_vd_ver in number, v_alt_nm_typ in integer, v_vd_typ in integer,  hookoutput in out t_hookOutput ) 
as
    row t_row;
    rows  t_rows;

    showrowset	t_showablerowset;
    
begin
    rows := t_rows();
    
    
-- enumerated vd 
    if (v_vd_typ = 17) then 
     
        for cur in (select 	VAL_ID , pv.perm_val_nm, pv.nci_val_mean_item_id, pv.nci_val_mean_ver_nr, vm.item_nm, vm.item_desc, vm.cncpt_concat ,
        vm.cncpt_concat_nm
        from perm_val pv, VW_VAL_MEAN  vm where 
        val_dom_item_id = v_vd_id and val_dom_ver_nr = v_vd_ver and pv.nci_val_mean_item_id = vm.item_id and pv.nci_val_mean_ver_nr = vm.ver_nr) loop
            row := t_row();
            ihook.setColumnValue(row, 'Permissible Value', cur.PERM_VAL_NM);
            ihook.setColumnValue(row, 'VM Long Name', cur.item_nm);
          
       for rec in   (select listagg(nm_desc, '|') nm_desc from  alt_nms an
            where item_id=cur.nci_val_mean_item_id  and ver_nr = cur.nci_val_mean_ver_nr and nm_typ_id = v_alt_nm_typ
            --order by an.lst_upd_dt desc fetch  first 1 rows only
            ) loop
            ihook.setColumnValue(row, 'Model Owner Label' , rec.nm_desc);
         --      raise_application_error(-20000,rec.nm_desc);
             end loop;
               ihook.setColumnValue(row, 'Concept Codes', cur.cncpt_concat);
            ihook.setColumnValue(row, 'VM Description', cur.Item_Desc);
              ihook.setColumnValue(row, 'Concept Name', cur.cncpt_concat_nm);
             ihook.setColumnValue(row, 'VAL_ID', cur.val_id);
            rows.extend;     rows(rows.last) := row;
        end loop;
        showrowset := t_showablerowset (rows, 'Permissible Values Selection', 4, 'single');
         hookoutput.showrowset := showrowset;
    end if;
      --  
-- non-enum or enum by ref
    if (v_vd_typ in (16,18)) then 
     hookoutput.forms := getPVForm ('Test');
    end if;

end;

 procedure spEditValueMAp ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2, v_mode in char)
   as
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
  v_cur_pv varchar2(255);
  v_new_pv varchar2(255);
  v_vd_typ integer;
  v_valid boolean := true;
  v_str varchar2(1000) := '';
  showrowset	t_showablerowset;
v_item_id number;
v_ver_nr number(4,2);
  forms     t_forms;
  form1  t_form;
rowform t_row;
v_msg_str varchar2(1000);
    v_tgt_alt_nm_typ integer;
v_alt_nm_typ integer;

 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori :=  hookInput.originalRowset.rowset(1);
   if (v_mode = 'S') then -- Source
  v_item_id := ihook.getColumnValue(row_ori,'SRC_VD_ITEM_ID');
  v_ver_nr := ihook.getColumnValue(row_ori,'SRC_VD_VER_NR');
     v_cur_pv := ihook.getColumnValue(row_ori, 'SRC_PV');
      for cur in (Select m.* from nci_mdl m, nci_mdl_map mm where mm.item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mm.ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') and mm.SRC_MDL_ITEM_ID = m.item_id and mm.SRC_MDL_VER_NR = m.VER_NR) loop
       v_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
    end loop;
    v_msg_str := 'Source PV';
   else
  v_item_id := ihook.getColumnValue(row_ori,'TGT_VD_ITEM_ID');
  v_ver_nr := ihook.getColumnValue(row_ori,'TGT_VD_VER_NR');
     for cur in (Select m.* from nci_mdl m, nci_mdl_map mm where mm.item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mm.ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') and mm.TGT_MDL_ITEM_ID = m.item_id and mm.TGT_MDL_VER_NR = m.VER_NR) loop
       v_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
    end loop;
    v_cur_pv := ihook.getColumnValue(row_ori, 'TGT_PV');
      v_msg_str := 'Target PV';

   end if;
  select val_dom_typ_id into v_vd_typ from value_dom where item_id = v_item_id and ver_nr= v_ver_nr;

  if (hookinput.invocationnumber = 0) then -- source PV
      validateValMapAddEdit(row_ori, v_vd_typ, v_mode,'U',v_valid, v_str);
      if (v_valid= true) then
            hookoutput.question := nci_11179_2.getGenericQuestion(v_msg_str, 'Save',1);
            getPVSelection(v_item_id, v_ver_nr, v_alt_nm_typ, v_vd_typ, hookoutput);
            hookoutput.message := 'Please specify ' || v_msg_str || ' Current PV is:' || v_cur_pv ;
      else
       hookoutput.message := v_str;
      end if;
  end if;

    if (hookinput.invocationnumber =1 ) then 
        rows := t_rows();
        row := t_row();       
        ihook.setColumnValue(row,'MECVM_ID', ihook.getColumnValue(row_ori,'MECVM_ID'));
        ihook.setColumnValue(row,'MAP_DEG', 120); -- derived from

      -- forms
        if (v_vd_typ <> 17) then
            forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);  -- entered values from user
            if (ihook.getColumnValue(rowform, 'NEW_PV') is not null) then
                v_new_pv := ihook.getColumnValue(rowform, 'NEW_PV') ;
            end if;
        end if;
        if(v_vd_typ = 17) then
            row_sel := hookInput.selectedRowset.rowset(1);
            v_new_pv := ihook.getColumnValue(row_sel,'Permissible Value');
            if (v_mode = 'S') then
                ihook.setColumnValue(row,'SRC_LBL',ihook.getColumnValue(row_sel,'Model Owner Label'));
                ihook.setColumnValue(row,'SRC_VM_CNCPT_CD',ihook.getColumnValue(row_sel,'Concept Codes'));
                ihook.setColumnValue(row,'SRC_VM_CNCPT_NM',ihook.getColumnValue(row_sel,'Concept Name'));
               
            else
                ihook.setColumnValue(row,'TGT_LBL',ihook.getColumnValue(row_sel,'Model Owner Label'));
                ihook.setColumnValue(row,'TGT_VM_CNCPT_CD',ihook.getColumnValue(row_sel,'Concept Codes'));
                ihook.setColumnValue(row,'TGT_VM_CNCPT_NM',ihook.getColumnValue(row_sel,'Concept Name'));
            end if;
         
        end if;

        if (v_mode = 'S') then
        ihook.setColumnValue(row,'SRC_PV',v_new_pv);
        
        else
        ihook.setColumnValue(row,'TGT_PV',v_new_pv);
        end if;
        rows.extend;     rows(rows.last) := row;
         action             := t_actionrowset(rows, 'Model Map Characteristic Values', 2, 10,'update');
            actions.extend;
            actions(actions.last) := action;
            hookoutput.actions := actions;
            hookoutput.message := 'Update Successful.';
     end if;

   V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  end;

  /*
 procedure spEditValueMAp ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
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
  v_cur_pv varchar2(255);
  v_src_vd_typ integer;
  v_tgt_vd_typ integer;
  v_valid boolean := true;
  v_str varchar2(1000) := '';
  showrowset	t_showablerowset;

  forms     t_forms;
  form1  t_form;
rowform t_row;

 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori :=  hookInput.originalRowset.rowset(1);
  select val_dom_typ_id into v_src_vd_typ from value_dom where item_id = ihook.getColumnValue(row_ori,'SRC_VD_ITEM_ID') and ver_nr= ihook.getColumnValue(row_ori,'SRC_VD_VER_NR');
  select val_dom_typ_id into v_tgt_vd_typ from value_dom where item_id = ihook.getColumnValue(row_ori,'TGT_VD_ITEM_ID') and ver_nr= ihook.getColumnValue(row_ori,'TGT_VD_VER_NR');

  if (hookinput.invocationnumber = 0) then -- source PV
      v_cur_pv := ihook.getColumnValue(row_ori, 'SRC_PV');
      validateValMapAddEdit(v_src_vd_typ, 'S','U',v_valid, v_str);
      if (v_valid= true) then
            hookoutput.question := nci_11179_2.getGenericQuestion('Source PV', 'Next',1);
            getPVSelection(ihook.getColumnValue(row_ori,'SRC_VD_ITEM_ID'), ihook.getColumnValue(row_ori,'SRC_VD_VER_NR'),v_src_vd_typ, hookoutput);
            hookoutput.message := 'Please select source pv. Current PV is:' || v_cur_pv ;

      end if;
  end if;

    if (hookinput.invocationnumber =1 and hookinput.answerid = 1) then --  save source pv - always non-enum
      -- forms
        forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);  -- entered values from user
        if (ihook.getColumnValue(rowform, 'NEW_PV') is not null) then
        update nci_mec_val_map set src_pv = ihook.getColumnValue(rowform,'NEW_PV') where mecvm_id = ihook.getColumnValue(row_ori,'MECVM_ID');
        commit;
        end if;

    end if;
    if ((hookinput.invocationnumber =1 and hookinput.answerid = 2) or hookinput.invocationnumber = 2) then -- save target pv, end
      if(v_tgt_vd_typ = 17) then
         row_sel := hookInput.selectedRowset.rowset(1);
      --   raise_application_error(-20000,ihook.getColumnValue(row_sel,'PERM_VAL_NM'));
        --update nci_mec_val_map set tgt_pv =  where mecvm_id = ihook.getColumnValue(row_ori,'MECVM_ID');
       -- commit;
      end if;
      if(v_tgt_vd_typ <> 17) then
      forms              := hookInput.forms;
        form1              := forms(1);
        rowform := form1.rowset.rowset(1);  -- entered values from user
      if (ihook.getColumnValue(rowform, 'NEW_PV') is not null) then
        update nci_mec_val_map set tgt_pv = ihook.getColumnValue(rowform,'NEW_PV') where mecvm_id = ihook.getColumnValue(row_ori,'MECVM_ID');
        commit;
        end if;
        end if;
    end if;

if (hookinput.invocationnumber = 1 or (hookinput.invocationnumber = 0 and v_valid = false)) then -- target PV 
     v_valid := true;
      validateValMapAddEdit(v_tgt_vd_typ, 'T','U',v_valid, v_str);
      if (v_valid = true) then
      v_cur_pv := ihook.getColumnValue(row_ori, 'TGT_PV');
      hookoutput.question := nci_11179_2.getGenericQuestion('Target PV', 'Save',2);
      getPVSelection(ihook.getColumnValue(row_ori,'TGT_VD_ITEM_ID'), ihook.getColumnValue(row_ori,'TGT_VD_VER_NR'), v_tgt_vd_typ, hookoutput);
      hookoutput.message := 'Please specify Target PV. Current PV is:' || v_cur_pv ;
       else 
        hookoutput.message := v_str;
      end if;
  end if;


   V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  end;

*/
 procedure spAddValueMAp ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    rowform t_row;
    v_vd_id number;
    v_vd_ver number(4,2);
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_new_pv varchar2(255);
  v_src_vd_typ integer;
  v_tgt_vd_typ integer;
  v_valid boolean := true;
  v_str varchar2(1000) := '';
forms     t_forms;
  form1  t_form;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori :=  hookInput.originalRowset.rowset(1); -- MOdel Map

  if (ihook.getColumnValue(row_ori, 'SRC_MEC_ID') is null or ihook.getColumnValue(row_ori, 'TGT_MEC_ID') is null) then
    raise_application_error(-20000,'Both Source and Target Characteristics have to be populated to add a Value Mapping.');
    return;
  end if;


  if (ihook.getColumnValue(row_ori, 'SRC_CDE_ITEM_ID') is null or ihook.getColumnValue(row_ori, 'TGT_CDE_ITEM_ID') is null) then
    raise_application_error(-20000,'Both Source and Target CDEs have to be associated.');
    return;
  end if;

  select val_dom_item_id , val_dom_ver_nr into v_vd_id,v_vd_ver from de where item_id =ihook.getColumnValue(row_ori, 'SRC_CDE_ITEM_ID')
  and ver_nr = ihook.getColumnValue(row_ori, 'SRC_CDE_VER_NR');

    select val_dom_typ_id into v_src_vd_typ from value_dom where item_id = v_vd_id and ver_nr= v_vd_ver;
  if (v_src_vd_typ = 17) then
  -- jira 3788
    raise_application_error(-20000, 'Cannot insert new Value Map Rule for a Mapping where the Source PV is Enumerated.');
    --raise_application_error(-20000,'Cannot insert new Value Map Rule for a Mapping where the Source PV is Enumerated. Please generate Value Mapping first');
    return;
  end if;


  select val_dom_item_id , val_dom_ver_nr into v_vd_id,v_vd_ver from de where item_id =ihook.getColumnValue(row_ori, 'TGT_CDE_ITEM_ID')
  and ver_nr = ihook.getColumnValue(row_ori, 'TGT_CDE_VER_NR');

    select val_dom_typ_id into v_tgt_vd_typ from value_dom where item_id = v_vd_id and ver_nr= v_vd_ver;
  if (v_tgt_vd_typ = 17) then
    raise_application_error(-20000,'Cannot insert new Value Map Rule for a Mapping where the Target PV is Enumerated using this command. Please use Generate for Rule and then use Copy Value Mapping.');
    return;
  end if;
  if (hookinput.invocationnumber = 0 and v_tgt_vd_typ = 18) then -- Target PV is non-enumerated
            hookoutput.question := nci_11179_2.getGenericQuestion('Source and Target PV', 'Add',1);
           hookoutput.forms := nci_11179_2.getGenericForm('Value Map (Insert Hook)'); 
            hookoutput.message := 'Please specify Source and Target PV. ' ;

  end if;
   
    if (hookinput.invocationnumber = 1) then -- insert row
      forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);  -- entered values from user
         --   if (ihook.getColumnValue(rowform, 'NEW_PV') is not null) then
                v_new_pv := ihook.getColumnValue(rowform, 'CUR_PV') ;
           -- end if;
      --v_new_pv := ihook.getColumnValue(row_sel, 'NEW_PV');  
     -- raise_application_error(-20000,v_new_pv);
      for cur in (select * from nci_mec_val_map where MECM_ID = ihook.getColumnValue(row_ori,'MECM_ID') and upper(src_pv) = upper(v_new_pv)) loop
        hookoutput.message := 'Duplicate Source PV found.';
        V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
        return;
      end loop;

     rows := t_rows();
     row := t_row();
        ihook.setColumnValue(row,'MDL_MAP_VER_NR', ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR'));
        ihook.setColumnValue(row,'MDL_MAP_ITEM_ID', ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID'));

        ihook.setColumnValue(row, 'MECM_ID', ihook.getColumnValue(row_ori, 'MECM_ID'));
        ihook.setColumnValue(row, 'SRC_MEC_ID', ihook.getColumnValue(row_ori, 'SRC_MEC_ID'));
        ihook.setColumnValue(row, 'TGT_MEC_ID', ihook.getColumnValue(row_ori, 'TGT_MEC_ID'));

        ihook.setColumnValue(row, 'SRC_VD_ITEM_ID', v_vd_id);
        ihook.setColumnValue(row, 'SRC_VD_VER_NR', v_vd_ver);
        ihook.setColumnValue(row,'SRC_CDE_ITEM_ID', ihook.getColumnValue(row_ori, 'SRC_CDE_ITEM_ID'));
        ihook.setColumnValue(row,'SRC_CDE_VER_NR', ihook.getColumnValue(row_ori, 'SRC_CDE_VER_NR'));
        ihook.setColumnValue(row,'TGT_CDE_ITEM_ID', ihook.getColumnValue(row_ori, 'TGT_CDE_ITEM_ID'));
        ihook.setColumnValue(row,'TGT_CDE_VER_NR', ihook.getColumnValue(row_ori, 'TGT_CDE_VER_NR'));

        for cur in (select * from de where item_id = ihook.getColumnValue(row_ori, 'TGT_CDE_ITEM_ID')
        and ver_nr = ihook.getColumnValue(row_ori, 'TGT_CDE_VER_NR')) loop
        ihook.setColumnValue(row, 'TGT_VD_ITEM_ID', cur.val_dom_item_id);
        ihook.setColumnValue(row, 'TGT_VD_VER_NR', cur.val_dom_ver_nr);

        end loop;


        ihook.setColumnValue(row,'SRC_PV',v_new_pv);
        ihook.setColumnValue(row,'TGT_PV',ihook.getColumnValue(rowform, 'NEW_PV') );

                ihook.setColumnValue(row,'MAP_DEG',120);-- not mapped yet.
        ihook.setColumnValue(row,'MECVM_ID',-1); 
        rows.extend;     rows(rows.last) := row;
       action             := t_actionrowset(rows, 'Model Map Characteristic Values', 2, 10,'insert');
            actions.extend;
            actions(actions.last) := action;
            hookoutput.actions := actions;
            hookoutput.message := 'Value Map Rule inserted successfully.';
  end if;


   V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--nci_util.debugHook('GENERAL', v_data_out);
  end;

 procedure spCopyValueMAp ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    rowform t_row;
    v_vd_id number;
    v_vd_ver number(4,2);
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_new_pv varchar2(255);
  v_src_vd_typ integer;
  v_tgt_vd_typ integer;
  v_valid boolean := true;
  v_str varchar2(1000) := '';
  v_mecm_id number;
forms     t_forms;
  form1  t_form;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori :=  hookInput.originalRowset.rowset(1); -- value Map
v_mecm_id := ihook.getCOlumnValue(row_ori, 'MECM_ID');
/*
for cur in (select * from nci_mec_map where (SRC_MEC_ID is null or TGT_MEC_ID is null) and mecm_id = v_mecm_id) loop
    raise_application_error(-20000,'Both Source and Target Characteristics have to be populated to add a Value Mapping.');
    return;
  end loop


  for cur in select * from nci_mec_map where (SRC_CDE_ITEM_ID is null or TGT_CDE_ITEM_ID is null) and mecm_id = v_mecm_id) ) 
  raise_application_error(-20000,'Both Source and Target CDEs have to be associated.');
    return;
  end loop;
*/
 
    select val_dom_typ_id into v_src_vd_typ from value_dom vd where vd.item_id = ihook.getColumnValue(row_ori,'SRC_VD_ITEM_ID')
    and ver_nr= ihook.getColumnValue(row_ori,'SRC_VD_VER_NR');
  if (v_src_vd_typ = 17) then
  -- jira 3788
    raise_application_error(-20000, 'Cannot copy Value Map Rule for a Mapping where the Source PV is Enumerated.');
    --raise_application_error(-20000,'Cannot insert new Value Map Rule for a Mapping where the Source PV is Enumerated. Please generate Value Mapping first');
    return;
  end if;


    select val_dom_typ_id into v_tgt_vd_typ from value_dom vd where vd.item_id = ihook.getColumnValue(row_ori,'TGT_VD_ITEM_ID')
    and ver_nr= ihook.getColumnValue(row_ori,'TGT_VD_VER_NR');
    
  if (v_tgt_vd_typ <> 17) then
    raise_application_error(-20000,'Cannot insert new Value Map Rule for a Mapping where the Target PV is non-enumerated using this command. Please use Add Value Map.');
    return;
  end if;
  
  if (hookinput.invocationnumber = 0 and v_tgt_vd_typ = 17) then -- Target PV is non-enumerated
            hookoutput.question := nci_11179_2.getGenericQuestion('Target PV selected is: ' || ihook.getColumnValue(row_ori,'TGT_PV'), 'Add',1);
           hookoutput.forms := nci_11179_2.getGenericForm('Value Map (Copy Hook)'); 
            hookoutput.message := 'Please specify Source PV. ' ;

  end if;
   
    if (hookinput.invocationnumber = 1) then -- insert row
      forms              := hookInput.forms;
            form1              := forms(1);
            rowform := form1.rowset.rowset(1);  -- entered values from user
         --   if (ihook.getColumnValue(rowform, 'NEW_PV') is not null) then
                v_new_pv := ihook.getColumnValue(rowform, 'CUR_PV') ;
           -- end if;
      --v_new_pv := ihook.getColumnValue(row_sel, 'NEW_PV');  
     -- raise_application_error(-20000,v_new_pv);
    /*  for cur in (select * from nci_mec_val_map where MECM_ID = ihook.getColumnValue(row_ori,'MECM_ID') and upper(src_pv) = upper(v_new_pv)) loop
        hookoutput.message := 'Duplicate Source PV found.';
        V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
        return;
      end loop;
*/
     rows := t_rows();
     row := row_ori;
       

        ihook.setColumnValue(row,'SRC_PV',v_new_pv);
      --  ihook.setColumnValue(row,'TGT_PV',ihook.getColumnValue(rowform, 'NEW_PV') );

                ihook.setColumnValue(row,'MAP_DEG',120);-- derived
        ihook.setColumnValue(row,'MECVM_ID',-1); 
        rows.extend;     rows(rows.last) := row;
       action             := t_actionrowset(rows, 'Model Map Characteristic Values', 2, 10,'insert');
            actions.extend;
            actions(actions.last) := action;
            hookoutput.actions := actions;
            hookoutput.message := 'Value Map Rule inserted successfully.';
  end if;


   V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--nci_util.debugHook('GENERAL', v_data_out);
  end;

END;
/
