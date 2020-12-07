create or replace PROCEDURE            spDEPrefQuestPost2 (
    row_ori   IN     t_row,
    actions   IN OUT t_actions)
AS
    action           t_actionRowset;
    row              t_row;
    rows             t_rows;
    action_rows      t_rows := t_rows ();
    action_row       t_row;
    rowset           t_rowset;
    v_add            INTEGER := 0;
    v_action_typ     VARCHAR2 (30);
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_nm_id          NUMBER;
    v_cntxt_id       NUMBER;
    v_cntxt_ver_nr   NUMBER (4, 2);
    i                INTEGER := 0;
    column           t_column;
    msg              VARCHAR2 (4000);
BEGIN
    v_item_id := ihook.getColumnValue (row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue (row_ori, 'VER_NR');
    rows := t_rows ();

    IF (ihook.getColumnValue (row_ori, 'PREF_QUEST_TXT') IS NOT NULL)
    THEN
        SELECT cntxt_item_id, cntxt_ver_nr
          INTO v_cntxt_id, v_cntxt_ver_nr
          FROM admin_item
         WHERE item_id = v_item_id AND ver_nr = v_ver_nr;

        row := t_row ();
        ihook.setColumnValue (row, 'ITEM_ID', v_item_id);
        ihook.setColumnValue (row, 'VER_NR', v_ver_nr);
        ihook.setColumnValue (
            row,
            'REF_NM',
            SUBSTR (ihook.getColumnValue (row_ori, 'PREF_QUEST_TXT'), 1, 255));
        ihook.setColumnValue (
            row,
            'REF_DESC',
            ihook.getColumnValue (row_ori, 'PREF_QUEST_TXT'));
        ihook.setColumnValue (row, 'LANG_ID', 1000);
        ihook.setColumnValue (row, 'NCI_CNTXT_ITEM_ID', v_cntxt_id);
        ihook.setColumnValue (row, 'NCI_CNTXT_VER_NR', v_cntxt_ver_nr);
        ihook.setColumnValue (row, 'REF_TYP_ID', 80);

        ihook.setColumnValue (row, 'REF_ID', -1);
        v_action_typ := 'insert';

        FOR cur
            IN (SELECT REF_ID
                  FROM REF
                 WHERE     item_id = v_item_id
                       AND ver_nr = v_ver_nr
                       AND ref_typ_id = 80)
        LOOP
            ihook.setColumnValue (row, 'REF_ID', cur.ref_id);
            v_action_typ := 'update';
        END LOOP;

        rows.EXTEND;
        rows (rows.LAST) := row;
        action :=
            t_actionrowset (rows,
                            'References (for Edit)',
                            2,
                            0,
                            v_action_typ);
        actions.EXTEND;
        actions (actions.LAST) := action;
        END IF;
END;
