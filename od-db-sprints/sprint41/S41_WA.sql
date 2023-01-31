
       insert into nci_mdr_cntrl (id, PARAM_NM, PARAM_VAL)
values (12, 'MEDDRA', 'V 25.1');
commit;

-- Tracker 2288
alter table nci_stg_alt_nms disable all triggers;
begin
for cur in (select * from nci_stg_alt_nms) loop
    if (cur.dt_last_modified != null) then
        update nci_stg_alt_nms 
        set dt_sort = to_date(dt_last_modified);
    end if;
end loop;
end;
/
alter table nci_stg_alt_nms enable all triggers;



insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('X',36,'Manual Insert','Manual Insert','X' );
commit;

CREATE OR REPLACE TRIGGER TRG_NCI_QVV_POST
  AFTER  UPDATE
  on NCI_QUEST_VALID_VALUE
  for each row
BEGIN   

    update ADMIN_ITEM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID     
    where (ITEM_ID, VER_NR) in (select ak.P_ITEM_ID, ak.P_ITEM_VER_NR from NCI_ADMIN_ITEM_REL ak, NCI_ADMIN_ITEM_REL_ALT_KEy q
                                where q.NCI_PUB_ID=:NEW.Q_PUB_ID and q.NCI_VER_NR= :NEW.Q_VER_NR and q.P_ITEM_ID = ak.C_ITEM_ID
                                and q.P_ITEM_VER_NR = ak.C_ITEM_VER_NR and ak.rel_typ_id = 61);



    update NCI_ADMIN_ITEM_REL_ALT_KEY set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID     
    where  NCI_PUB_ID = :new.Q_PUB_ID
           AND NCI_VER_NR=:new.Q_VER_NR;

    update NCI_ADMIN_ITEM_REL set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID     
    where  (C_ITEM_ID, C_ITEM_VER_NR) in (select p_item_id, p_item_ver_nr from nci_admin_item_rel_alt_key where c_item_id = :new.q_pub_id and 
                                          c_item_ver_nr = :new.q_ver_nr)
    and rel_typ_id = 61;

END;

/
create or replace TRIGGER OD_TR_ALT_NMS_UPD 
BEFORE UPDATE ON NCI_STG_ALT_NMS 
for each row
BEGIN
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
:new.DT_SORT := systimestamp();
END;
/
create or replace TRIGGER OD_TR_STG_ALT_NMS  BEFORE INSERT  on NCI_STG_ALT_NMS  for each row
     BEGIN    IF (:NEW.STG_AI_ID = -1  or :NEW.STG_AI_ID is null)  THEN select od_seq_CDE_IMPORT.nextval
 into :new.STG_AI_ID  from  dual ; 
 END IF;
 :new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
 :new.DT_SORT := systimestamp();
 END;
 /
