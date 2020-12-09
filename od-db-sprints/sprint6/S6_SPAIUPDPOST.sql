create or replace PROCEDURE            spAIUpdPost (v_data_in    IN     CLOB,
                                                    v_data_out      OUT CLOB)
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
    v_temp           INT;
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_nm_id          NUMBER;
    v_cntxt_id       NUMBER;
    v_cntxt_ver_nr   NUMBER (4, 2);
    i                INTEGER := 0;
    column           t_column;
    v_item_nm        VARCHAR2 (255);
    v_item_def       VARCHAR2 (4000);
    msg              VARCHAR2 (4000);
BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;
    rows := t_rows ();

    row_ori := hookInput.originalRowset.rowset (1);
    v_item_id := ihook.getColumnValue (row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue (row_ori, 'VER_NR');

    IF (ihook.getColumnValue (row_ori, 'ADMIN_ITEM_TYP_ID') = 4)
    THEN                                                                 -- DE
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
    END IF;

    IF (ihook.getColumnValue (row_ori, 'ADMIN_ITEM_TYP_ID') = 2)
    THEN                                                                -- DEC
        --           raise_application_error(-20000, 'Duplicate DEC found. ');

        FOR cur
            IN (SELECT ai1.item_id
                  FROM admin_item ai1, de_conc dec1
                 WHERE     ai1.item_id = dec1.item_id
                       AND ai1.ver_nr = dec1.ver_nr
                       AND ai1.item_id <> v_item_id
                       AND ai1.cntxt_item_id =
                           ihook.getColumnValue (row_ori, 'CNTXT_ITEM_ID')
                       AND ai1.cntxt_ver_nr =
                           ihook.getColumnValue (row_ori, 'CNTXT_VER_NR')
                       AND (dec1.obj_cls_item_id,
                            dec1.obj_cls_ver_nr,
                            dec1.prop_item_id,
                            dec1.prop_ver_nr) IN
                               (SELECT dec.obj_cls_item_id,
                                       dec.obj_cls_ver_nr,
                                       dec.prop_item_id,
                                       dec.prop_ver_nr
                                  FROM de_conc dec
                                 WHERE     dec.item_id = v_item_id
                                       AND dec.ver_nr = v_ver_nr))
        LOOP
            raise_application_error (-20000,
                                     'Duplicate DEC found. ' || cur.item_id);
            RETURN;
        END LOOP;
    END IF;


    --if actions.count > 0 then
    --hookoutput.actions := actions;
    --end if;
    -- end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/