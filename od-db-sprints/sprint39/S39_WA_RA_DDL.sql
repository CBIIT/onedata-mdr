alter table CNCPT add (PRNT_ITEM_ID number, PRNT_ITEM_VER_NR number);

alter table NCI_USR_CART add RETAIN_IND number(1);


  CREATE OR REPLACE VIEW VW_LIST_USR_CART_NM AS
  SELECT distinct CART_NM, CART_NM CART_NM_SPEC, CNTCT_SECU_ID, CART_NM || ' : ' || CNTCT_SECU_ID CART_USR_NM, 0 RETAIN_IND, 
           user CREAT_USR_ID,
            user LST_UPD_USR_ID,
            0 FLD_DELETE,
           sysdate LST_DEL_DT,
           sysdate S2P_TRN_DT,
           sysdate LST_UPD_DT,
           sysdate CREAT_DT
           from NCI_USR_CART where nvl(fld_delete,0)  =0;
