alter table nci_admin_item_rel add (CPY_MOD_ITEM_ID number, CPY_MOD_VER_NR number(4,2));

--Tracker 2129
alter table NCI_ADMIN_ITEM_REL_ALT_KEY modify (EDIT_IND default 0, REQ_IND default 0);
                                    
alter table NCI_QUEST_VV_REP modify (EDIT_IND default 0 );

-- Tracker 2114
CREATE OR REPLACE VIEW VW_CONC_DOM_FOR_IMPORT
   AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT, 
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT
FROM ADMIN_ITEM
       WHERE ADMIN_ITEM_TYP_ID = 1 and upper(CNTXT_NM_DN) not in ('TEST','TRAINING', 'CACORE') and nvl(CURRNT_VER_IND,0) = 1 and 
       ADMIN_STUS_NM_DN = 'RELEASED';



insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'Printer Friendly Form', 114, 'Legacy Prior CDE Excel', 
											'Legacy Prior CDE Excel');
commit;

-- Tracker 2147
alter table NCI_STG_CDE_CREAT add PROCESS_DT_CHAR varchar2(20);

update NCI_STG_CDE_CREAT set PROCESS_DT_CHAR = TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS') where PROCESS_DT is not null;
commit;

