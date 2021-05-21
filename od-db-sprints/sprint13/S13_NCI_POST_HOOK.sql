create or replace PACKAGE            nci_post_hook AS

procedure spRefDocInsUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spAISTUpd ( v_data_in in clob, v_data_out out clob, v_usr_id varchar2);
procedure spAISTIns ( v_data_in in clob, v_data_out out clob);
procedure spDervCompIns ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);

END;
/
create or replace PACKAGE BODY            NCI_POST_HOOK AS

procedure spRefDocInsUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;

  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   -- raise_application_error(-20000, ihook.getColumnValue(row_ori,'REF_TYP_ID'));
  if (ihook.getColumnValue(row_ori,'REF_TYP_ID') = 80 or ihook.getColumnOldValue(row_ori,'REF_TYP_ID') = 80) then
    raise_application_error(-20000,'You cannot insert or update Preferred Question Text from Reference Documents. Please use Section 4 - Relational/Representation Attributes.');
 end if;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


-- Can only add Components if Derivation Rule is set
procedure spDervCompIns ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;

  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
    for cur in (select * from de where item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR')
    and DERV_RUL is null) loop
    raise_application_error(-20000,'Please set the Derivation Rule first.');
 end loop;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;



PROCEDURE            spAISTUpd (
    v_data_in    IN     CLOB,
    v_data_out      OUT CLOB,
    v_usr_id in varchar2)
AS
    hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    actions          t_actions := t_actions ();
    action           t_actionRowset;
    row              t_row;
    rows             t_rows;
    row_ori          t_row;
    action_rows      t_rows := t_rows ();
    action_row       t_row;
    rowset           t_rowset;
    v_add            INTEGER := 0;
    v_action_typ     VARCHAR2 (30);
    v_temp           VARCHAR2 (255);
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_nm_id          NUMBER;
    v_cntxt_id       NUMBER;
    v_cntxt_ver_nr   NUMBER (4, 2);
    i                INTEGER := 0;
    column           t_column;
    v_item_nm        VARCHAR2 (255);
    v_item_def       VARCHAR2 (4000);
    v_item_desc       VARCHAR2 (4000);
    msg              VARCHAR2 (4000);
BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;
    rows := t_rows ();

    row_ori := hookInput.originalRowset.rowset (1);
    v_item_id := ihook.getColumnValue (row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue (row_ori, 'VER_NR');

  if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;
    
    -- Tracker 554
  --  raise_application_error(-20000, hookinput.originalRowset.tablename);
    
  if (hookinput.originalRowset.tablename = 'ADMIN_ITEM') then
    if (ihook.getColumnValue (row_ori, 'ITEM_DESC') <>  ihook.getColumnOldValue (row_ori, 'ITEM_DESC')
       and ihook.getColumnValue (row_ori, 'ADMIN_ITEM_TYP_ID') in (2,5,6,7,49,53)) then
        raise_application_error(-20000, 'Definition for this Administered Item cannot be updated. ');
        return;
    end if;
    end if;
    
    
    IF (hookinput.originalRowset.tablename = 'DE')
    THEN
        FOR cur
            IN (SELECT ai.item_id
                  FROM admin_item ai, de de
                 WHERE     ai.item_id = de.item_id
                       AND ai.ver_nr = de.ver_nr
                       AND de.de_conc_item_id =
                           ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID')
                       AND de.de_conc_ver_nr =
                           ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR')
                       AND de.val_dom_item_id =
                           ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID')
                       AND de.val_dom_ver_nr =
                           ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR')
                       AND de.item_id <> v_item_id
                       AND (ai.cntxt_item_id, ai.cntxt_ver_nr) IN
                               (SELECT ai1.cntxt_item_id, ai1.cntxt_ver_nr
                                  FROM admin_item ai1
                                 WHERE     item_id = v_item_id
                                       AND ver_nr = v_ver_nr))
        LOOP
            raise_application_error (-20000,
                                     'Duplicate DE found. ' || cur.item_id);
            RETURN;
        END LOOP;

        IF (   ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'DE_CONC_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'DE_CONC_VER_NR')
            OR ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'VAL_DOM_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'VAL_DOM_VER_NR'))
        THEN
            SELECT SUBSTR (dec.item_nm || ' ' || vd.item_nm, 1, 255),
                   SUBSTR (dec.item_desc || ':' || vd.item_desc, 1, 4000)
              INTO v_item_nm, v_item_def
              FROM admin_item dec, admin_item vd
             WHERE     dec.item_id =
                       ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID')
                   AND dec.ver_nr =
                       ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR')
                   AND vd.item_id =
                       ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID')
                   AND vd.ver_nr =
                       ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR');

            row := t_row ();
            ihook.setColumnValue (row, 'ITEM_ID', v_item_id);
            ihook.setColumnValue (row, 'VER_NR', v_ver_nr);
            ihook.setColumnValue (row, 'ITEM_NM', v_item_nm);
            ihook.setColumnValue (row, 'ITEM_DESC', v_item_def);
            rows.EXTEND;
            rows (rows.LAST) := row;
            action :=
                t_actionrowset (rows,
                                'Administered Item',
                                2,
                                0,
                                'update');
            actions.EXTEND;
            actions (actions.LAST) := action;
        END IF;

        spDEPrefQuestPost2 (row_ori, actions);
        
        -- Tracker 818 - if Derivation Rule is set, then 
        
        if ((ihook.getColumnValue (row_ori, 'DERV_TYP_ID') is not null and ihook.getColumnValue (row_ori, 'DERV_RUL') is null) or 
        (ihook.getColumnValue (row_ori, 'DERV_TYP_ID') is null and ihook.getColumnValue (row_ori, 'DERV_RUL') is not null)) then
            raise_application_error(-20000, 'Derivation Type or Derivation Rule is missing. ');
            return;
        end if;       
    END IF;

    IF (hookinput.originalRowset.tablename = 'DE_CONC')
    THEN
        FOR cur
            IN (SELECT ai.item_id
                  FROM admin_item ai, de_conc dec
                 WHERE     ai.item_id = dec.item_id
                       AND ai.ver_nr = dec.ver_nr
                       AND dec.obj_cls_item_id =
                           ihook.getColumnValue (row_ori, 'OBJ_CLS_ITEM_ID')
                       AND dec.obj_cls_ver_nr =
                           ihook.getColumnValue (row_ori, 'OBJ_CLS_VER_NR')
                       AND dec.prop_item_id =
                           ihook.getColumnValue (row_ori, 'PROP_ITEM_ID')
                       AND dec.prop_ver_nr =
                           ihook.getColumnValue (row_ori, 'PROP_VER_NR')
                       AND dec.item_id <> v_item_id
                       AND (ai.cntxt_item_id, ai.cntxt_ver_nr) IN
                               (SELECT ai1.cntxt_item_id, ai1.cntxt_ver_nr
                                  FROM admin_item ai1
                                 WHERE     item_id = v_item_id
                                       AND ver_nr = v_ver_nr))
        LOOP
            raise_application_error (-20000,
                                     'Duplicate DEC found. ' || cur.item_id);
            RETURN;
        END LOOP;

        IF (   ihook.getColumnValue (row_ori, 'OBJ_CLS_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'OBJ_CLS_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'OBJ_CLS_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'OBJ_CLS_VER_NR')
            OR ihook.getColumnValue (row_ori, 'PROP_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'PROP_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'PROP_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'PROP_VER_NR'))
        THEN
            SELECT SUBSTR (oc.item_nm || ' ' || prop.item_nm, 1, 255),
                   SUBSTR (oc.item_desc || ':' || prop.item_desc, 1, 4000)
              INTO v_item_nm, v_item_def
              FROM admin_item oc, admin_item prop
             WHERE     oc.item_id =
                       ihook.getColumnValue (row_ori, 'OBJ_CLS_ITEM_ID')
                   AND oc.ver_nr =
                       ihook.getColumnValue (row_ori, 'OBJ_CLS_VER_NR')
                   AND prop.item_id =
                       ihook.getColumnValue (row_ori, 'PROP_ITEM_ID')
                   AND prop.ver_nr =
                       ihook.getColumnValue (row_ori, 'PROP_VER_NR');

            row := t_row ();
            ihook.setColumnValue (row, 'ITEM_ID', v_item_id);
            ihook.setColumnValue (row, 'VER_NR', v_ver_nr);
            ihook.setColumnValue (row, 'ITEM_NM', v_item_nm);
            ihook.setColumnValue (row, 'ITEM_DESC', v_item_def);
            rows.EXTEND;
            rows (rows.LAST) := row;
            action :=
                t_actionrowset (rows,
                                'Administered Item',
                                2,
                                0,
                                'update');
            actions.EXTEND;
            actions (actions.LAST) := action;
        END IF;
    END IF;
 if (hookinput.originalRowset.tablename = 'VALUE_DOM') then
 
 select item_nm, cntxt_item_id, cntxt_ver_nr  into v_item_nm, v_cntxt_id, v_cntxt_ver_nr from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR');
            
          FOR cur
            IN (SELECT ai.item_id
                  FROM admin_item ai, VALUE_DOM vd
                 WHERE     ai.item_id = vd.item_id
                       AND ai.ver_nr = vd.ver_nr
                       AND ai.ITEM_NM = v_item_nm
               --        AND ai.VER_NR = ihook.getColumnValue (row_ori, 'VER_NR')
                       AND vd.item_id <> v_item_id
                       AND ai.cntxt_item_id = v_cntxt_id and ai.cntxt_ver_nr = v_cntxt_ver_nr)
        LOOP
            raise_application_error (-20000,
                                     'Duplicate VD found. ' || cur.item_id);
            RETURN;
        END LOOP; 
        
    if ( ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') is not null and 
         ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') <>  ihook.getColumnOldValue(row_ori, 'REP_CLS_ITEM_ID')) then
            
            select item_nm into v_temp from admin_item where item_id = ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') 
            and ver_nr = ihook.getColumnValue(row_ori, 'REP_CLS_VER_NR');
            --if ((trim(substr(v_item_nm, length(v_item_nm)-length(trim(v_temp)))) != v_temp) or
            --length(v_item_nm) < length(v_temp))then
            IF instr(v_item_nm,v_temp)=0 then                
                select substr(v_item_nm || ' ' || rc.item_nm,1,255) , 
                substr(v_item_desc || ' ' || rc.item_desc,1,3999) 
                into v_item_nm , v_item_desc
                from  admin_item rc
                where  rc.ver_nr =  ihook.getColumnValue(row_ori, 'REP_CLS_VER_NR')
                and rc.item_id =  ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') ;
            end if;  
        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID',v_item_id );  
        ihook.setColumnValue(row,'VER_NR',v_ver_nr );  
        ihook.setColumnValue(row,'ITEM_NM',v_item_nm ); 
        ihook.setColumnValue(row,'ITEM_DESC', v_item_desc); 
        rows.extend;
        rows(rows.last) := row;
        action := t_actionrowset(rows, 'Administered Item', 2,0,'update');
        actions.extend;
        actions(actions.last) := action;
     
        end if;
             --  raise_application_error (-20000,     ' VD error ' || v_item_id ||','||v_item_nm );
      
        
    
   END IF;

    IF actions.COUNT > 0
    THEN
        hookoutput.actions := actions;
    END IF;

    -- end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


 PROCEDURE spAISTIns
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
  v_temp int;
  v_dtype_id integer;
  v_item_id  number;
  v_ver_nr  number(4,2);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

    row_ori := hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    
    rows := t_rows();
   if (hookinput.originalRowset.tablename = 'VALUE_DOM') then
    if (ihook.getColumnValue(row_ori, 'DTTYPE_ID') is null and  ihook.getColumnValue(row_ori,'NCI_STD_DTTYPE_ID') is not null) then --- Tracker 667
        select NCI_DFLT_LEGCY_ID into v_dtype_id from data_typ where DTTYPE_ID = ihook.getColumnValue(row_ori,'NCI_STD_DTTYPE_ID');
        
        ihook.setColumnValue(row_ori,'DTTYPE_ID',v_dtype_id );  
        rows.extend;
        rows(rows.last) := row_ori;
        action := t_actionrowset(rows, 'Value Domain', 2,0,'update');
        actions.extend;
        actions(actions.last) := action;
        
    end if;
 end if;
   if actions.count > 0 then      
 --  raise_application_error(-20000, 'Count' || actions.count);
    hookoutput.actions := actions;
  end if;
   -- end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

END;
/
