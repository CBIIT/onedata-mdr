
--drop materialized view VW_NCI_DE_HORT_EXPANDED;

CREATE materialized VIEW VW_NCI_DE_HORT_EXPANDED as
  SELECT DE.ITEM_ID, DE.VER_NR,   
        DE.DE_CONC_ITEM_ID,
           DE.DE_CONC_VER_NR,
           DE.VAL_DOM_VER_NR,
           DE.VAL_DOM_ITEM_ID,
           DE.REP_CLS_VER_NR,
           DE.REP_CLS_ITEM_ID,
           nvl(DE.DERV_DE_IND,0) DERV_DE_IND,
           DE.DERV_MTHD,
           DE.DERV_RUL,
           DE.DERV_TYP_ID,
           DE.CONCAT_CHAR,
          DE.CREAT_USR_ID,
           DE.LST_UPD_USR_ID,
           DE.FLD_DELETE,
           DE.LST_DEL_DT,
           DE.S2P_TRN_DT,
           DE.LST_UPD_DT,
           DE.CREAT_DT,
           DE_CONC.OBJ_CLS_ITEM_ID,
           DE_CONC.OBJ_CLS_VER_NR,
           DE_CONC.PROP_ITEM_ID,
           DE_CONC.PROP_VER_NR,
          alt.altnm,
	      refdoc.refdesc,
	  pvvm.pv,
	  pvvm.vm,
	  pvvm.vm_cncpt
	  FROM --ADMIN_ITEM,
           DE,
           DE_CONC,
          (select distinct item_id, ver_nr, substr(LISTAGG(nm_desc, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by ITEM_ID),1,16000) as altnm from alt_nms group by item_id, ver_nr)  alt,
	      (select  item_id, ver_nr, substr(LISTAGG(ref_desc, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by ITEM_ID),1,16000) as refdesc from ref group by item_id, ver_nr) refdoc,
		(select  de_item_id,de_ver_nr, substr(LISTAGG(PERM_VAL_NM, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by de_ITEM_ID),1,16000) as PV,
	   substr( LISTAGG(ITEM_NM, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by de_ITEM_ID),1,16000) as VM ,
	  substr(LISTAGG(CNCPT_CONCAT, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by de_ITEM_ID),1,16000) as VM_CNCPT  from VW_NCI_DE_PV group by de_item_id, de_ver_nr) PVVM
     WHERE   DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
            AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	  and de.item_id = alt.item_id (+)
	  and de.ver_nr = alt.ver_nr (+)
	    and de.item_id = refdoc.item_id (+)
	  and de.ver_nr = refdoc.ver_nr (+)
	    and de.item_id = pvvm.de_item_id (+)
	  and de.ver_nr = pvvm.de_ver_nr (+)
	  


alter table NCI_DS_HDR add CMP_TO_AI varchar2(4000);


/*

  CREATE OR REPLACE  VIEW VW_NCI_DE_HORT_EXPANDED as
  SELECT ADMIN_ITEM.ITEM_ID                ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGISTRR_CNTCT_ID,
           ADMIN_ITEM.SUBMT_CNTCT_ID,
           ADMIN_ITEM.STEWRD_CNTCT_ID,
           ADMIN_ITEM.SUBMT_ORG_ID,
           ADMIN_ITEM.STEWRD_ORG_ID,
           ADMIN_ITEM.REGSTR_AUTH_ID,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           DE.PREF_QUEST_TXT ,
           VALUE_DOM.NCI_DEC_PREC DE_PREC,
           DE.DE_CONC_ITEM_ID,
           DE.DE_CONC_VER_NR,
           DE.VAL_DOM_VER_NR,
           DE.VAL_DOM_ITEM_ID,
           DE.REP_CLS_VER_NR,
           DE.REP_CLS_ITEM_ID,
           nvl(DE.DERV_DE_IND,0) DERV_DE_IND,
           DE.DERV_MTHD,
           DE.DERV_RUL,
           DE.DERV_TYP_ID,
           DE.CONCAT_CHAR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           DE.FLD_DELETE,
           DE.LST_DEL_DT,
           DE.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID                   CREAT_USR_ID_X,
          ADMIN_ITEM.LST_UPD_USR_ID                 LST_UPD_USR_ID_X,
           ADMIN_ITEM.CREAT_DT                       CREAT_DT_X,
           ADMIN_ITEM.LST_UPD_DT                     LST_UPD_DT_X,
           VALUE_DOM.CONC_DOM_VER_NR,
           VALUE_DOM.CONC_DOM_ITEM_ID,
           VALUE_DOM.NON_ENUM_VAL_DOM_DESC,
           VALUE_DOM.UOM_ID,
           VALUE_DOM.VAL_DOM_TYP_ID          VAL_DOM_TYP_ID,
           VALUE_DOM.VAL_DOM_MIN_CHAR,
           VALUE_DOM.VAL_DOM_MAX_CHAR,
           VALUE_DOM.VAL_DOM_HIGH_VAL_NUM,
           VALUE_DOM.VAL_DOM_LOW_VAL_NUM,
           VALUE_DOM.VAL_DOM_FMT_ID,
           VALUE_DOM.CHAR_SET_ID,
           VALUE_DOM_AI.CREAT_DT                VALUE_DOM_CREAT_DT,
           VALUE_DOM_AI.CREAT_USR_ID            VALUE_DOM_USR_ID,
           VALUE_DOM_AI.LST_UPD_USR_ID          VALUE_DOM_LST_UPD_USR_ID,
           VALUE_DOM_AI.LST_UPD_DT              VALUE_DOM_LST_UPD_DT,
           VALUE_DOM_AI.ITEM_NM              VALUE_DOM_ITEM_NM,
           VALUE_DOM_AI.ITEM_LONG_NM         VALUE_DOM_ITEM_LONG_NM,
           VALUE_DOM_AI.ITEM_DESC            VALUE_DOM_ITEM_DESC,
           VALUE_DOM_AI.CNTXT_NM_DN          VALUE_DOM_CNTXT_NM,
           VALUE_DOM_AI.CURRNT_VER_IND       VALUE_DOM_CURRNT_VER_IND,
           VALUE_DOM_AI.REGSTR_STUS_NM_DN    VALUE_DOM_REGSTR_STUS_NM,
           VALUE_DOM_AI.ADMIN_STUS_NM_DN     VALUE_DOM_ADMIN_STUS_NM,
           VALUE_DOM.NCI_STD_DTTYPE_ID,
           VALUE_DOM.DTTYPE_ID,
           VALUE_DOM.NCI_DEC_PREC,
	  VALUE_DOM.TERM_CNCPT_ITEM_ID,
	  VALUE_DOM.TERM_CNCPT_VER_NR,
	  VALUE_DOM.TERM_USE_TYP,
           DEC_AI.ITEM_NM                    DEC_ITEM_NM,
           DEC_AI.ITEM_LONG_NM               DEC_ITEM_LONG_NM,
           DEC_AI.ITEM_DESC                  DEC_ITEM_DESC,
           DEC_AI.CNTXT_NM_DN                DEC_CNTXT_NM,
           DEC_AI.CURRNT_VER_IND             DEC_CURRNT_VER_IND,
           DEC_AI.REGSTR_STUS_NM_DN          DEC_REGSTR_STUS_NM,
           DEC_AI.ADMIN_STUS_NM_DN           DEC_ADMIN_STUS_NM,
           DEC_AI.CREAT_DT                   DEC_CREAT_DT,
           DEC_AI.CREAT_USR_ID               DEC_USR_ID,
           DEC_AI.LST_UPD_USR_ID             DEC_LST_UPD_USR_ID,
           DEC_AI.LST_UPD_DT                 DEC_LST_UPD_DT,
           DE_CONC.OBJ_CLS_ITEM_ID,
           DE_CONC.OBJ_CLS_VER_NR,
           OC.ITEM_NM                        OBJ_CLS_ITEM_NM,
           OC.ITEM_LONG_NM                   OBJ_CLS_ITEM_LONG_NM,
           CONOC.CNCPT_CONCAT 			OC_CNCPT_CONCAT,
           CONOC.CNCPT_CONCAT_NM			OC_CNCPT_CONCAT_NM,
           PROP.ITEM_NM                      PROP_ITEM_NM,
           PROP.ITEM_LONG_NM                 PROP_ITEM_LONG_NM,
           DE_CONC.PROP_ITEM_ID,
           DE_CONC.PROP_VER_NR,
           CONPROP.CNCPT_CONCAT			PROP_CNCPT_CONCAT,
           CONPROP.CNCPT_CONCAT_NM			PROP_CNCPT_CONCAT_NM	,
           DE_CONC.CONC_DOM_ITEM_ID          DEC_CD_ITEM_ID,
           DE_CONC.CONC_DOM_VER_NR           DEC_CD_VER_NR,
           DEC_CD.ITEM_NM                    DEC_CD_ITEM_NM,
           DEC_CD.ITEM_LONG_NM               DEC_CD_ITEM_LONG_NM,
           DEC_CD.ITEM_DESC                  DEC_CD_ITEM_DESC,
           DEC_CD.CNTXT_NM_DN                DEC_CD_CNTXT_NM,
           DEC_CD.CURRNT_VER_IND             DEC_CD_CURRNT_VER_IND,
           DEC_CD.REGSTR_STUS_NM_DN          DEC_CD_REGSTR_STUS_NM,
           DEC_CD.ADMIN_STUS_NM_DN           DEC_CD_ADMIN_STUS_NM,
           CD_AI.ITEM_NM                     CD_ITEM_NM,
           CD_AI.ITEM_LONG_NM                CD_ITEM_LONG_NM,
           CD_AI.ITEM_DESC                   CD_ITEM_DESC,
           CD_AI.CNTXT_NM_DN                 CD_CNTXT_NM,
           CD_AI.CURRNT_VER_IND              CD_CURRNT_VER_IND,
           CD_AI.REGSTR_STUS_NM_DN           CD_REGSTR_STUS_NM,
           CD_AI.ADMIN_STUS_NM_DN            CD_ADMIN_STUS_NM,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
      FROM --ADMIN_ITEM,
           DE,
           --VALUE_DOM,
           --ADMIN_ITEM          VALUE_DOM_AI,
           --ADMIN_ITEM          DEC_AI,
           DE_CONC,
           --VW_CONC_DOM         DEC_CD,
           --VW_CONC_DOM         CD_AI,
           --ADMIN_ITEM          OC,
           --ADMIN_ITEM          PROP,
           --NCI_ADMIN_ITEM_EXT  CONOC,
           --NCI_ADMIN_ITEM_EXT  CONPROP,
	       (select listagg(
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
           AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
           AND DE.VER_NR = ADMIN_ITEM.VER_NR
          -- AND DE.VAL_DOM_ITEM_ID = VALUE_DOM_AI.ITEM_ID
           --AND DE.VAL_DOM_VER_NR = VALUE_DOM_AI.VER_NR
           --AND DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
          -- AND DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           --AND DE.DE_CONC_ITEM_ID = DEC_AI.ITEM_ID
           --AND DE.DE_CONC_VER_NR = DEC_AI.VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           --AND DE_CONC.OBJ_CLS_ITEM_ID = OC.ITEM_ID
           --AND DE_CONC.OBJ_CLS_VER_NR = OC.VER_NR
           --AND DE_CONC.PROP_ITEM_ID = PROP.ITEM_ID
           --AND DE_CONC.PROP_VER_NR = PROP.VER_NR
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
           --AND DE_CONC.CONC_DOM_ITEM_ID = DEC_CD.ITEM_ID
           --AND DE_CONC.CONC_DOM_VER_NR = DEC_CD.VER_NR
           --AND VALUE_DOM.CONC_DOM_ITEM_ID = CD_AI.ITEM_ID
           --AND VALUE_DOM.CONC_DOM_VER_NR = CD_AI.VER_NR
           --AND OC.ITEM_ID = CONOC.ITEM_ID
           --AND OC.VER_NR = CONOC.VER_NR
           --AND PROP.ITEM_ID = CONPROP.ITEM_ID
           --AND PROP.VER_NR = CONPROP.VER_NR;


  GRANT SELECT ON "ONEDATA_WA"."VW_NCI_DE_HORT" TO "ONEDATA_RO";
  GRANT READ ON "ONEDATA_WA"."VW_NCI_DE_HORT" TO "ONEDATA_RO";


*/

alter table nci_mdl_elmnt_char add (CMNTS_DESC_TXT varchar2(4000));


  CREATE OR REPLACE VIEW VW_MDL_IMP_TEMPLATE AS
  SELECT ' '                DO_NOT_USE,
       ' '                  BATCH_USER,
       ' '                  BATCH_NAME,
       ROWNUM               SEQ_ID,
       ai.item_nm           MDL_NM, 
       ai.item_id           MDL_ID, 
       ai.ver_nr            MDL_VER_NR, 
       me.item_long_nm      ME_LONG_NM, 
       me.item_phy_obj_nm   ME_PHY_NM, 
       me.item_desc         ME_DESC, 
       me_typ.obj_key_desc ME_TYP_DESC,   
       mec.mec_long_nm      MEC_LONG_NM, 
       mec.MEC_PHY_NM       MEC_PHY_NM, 
       mec.CHAR_ORD         MEC_CHAR_ORD, 
       mec.                 MEC_DESC, 
       mec_typ.obj_key_Desc MEC_TYP_DESC,  
       mec.src_min_char     MEC_MIN_CHAR, 
       mec.src_max_char     MEC_MAX_CHAR, 
       SRC_DTTYPE         MEC_DT_TYP_DESC, 
       SRC_UOM             UOM_DESC,  
       mec_req.obj_key_Desc          MEC_MNDTRY,  
       decode(mec.pk_ind,1,'Yes','No')           MEC_PK_IND,    
       decode(mec.mdl_pk_ind,1,'Yes','No')           MEC_MDL_PK_IND,    
       mec.src_deflt_val    MEC_DEFLT_VAL, 
       mec.cde_item_id      CDE_ID, 
       mec.cde_ver_nr       CDE_vERSION, 
       decode(mec.FK_IND,1,'Yes','No')           MEC_FK_IND, 
       mec.                 FK_ELMNT_PHY_NM, 
       mec.                 FK_ELMNT_CHAR_PHY_NM, 
       mec.cmnts_desc_txt                  COMMENTS            
FROM admin_item            ai,
     nci_mdl               mdl,
     nci_mdl_elmnt         me,
     nci_mdl_elmnt_char    mec,
     obj_key               mec_typ,
     obj_key               me_typ,
     obj_key               mec_req
WHERE ai.item_id                  = mdl.item_id
  AND ai.ver_nr                   = mdl.ver_nr
  AND ai.admin_item_typ_id        = 57
  AND mdl.item_id                 = me.mdl_item_id
  AND mdl.ver_nr                  = me.mdl_item_ver_nr
  AND me.item_id                  = mec.mdl_elmnt_item_id
  AND me.ver_nr                   = mec.mdl_elmnt_ver_nr
  AND mec.mdl_elmnt_char_typ_id   = mec_typ.obj_key_id (+)
  AND mec.req_ind  = mec_req.obj_key_id (+)
  AND me.ME_TYP_ID  = me_typ.obj_key_id (+);



  CREATE OR REPLACE  VIEW VW_MDL_FLAT_VB AS
  select ai.item_id MDL_ITEM_ID, 
	ai.ver_nr  MDL_VER_NR, 
	ai.item_nm  MDL_NM, 
        ai.cntxt_nm_dn  MDL_CNTXT_NM, 
	ai.admin_stus_nm_dn  MDL_ADMIN_STUS_NM, 
	ai.regstr_stus_nm_dn  MDL_REGSTR_STUS_NM,
	mdl_lang.obj_key_desc MDL_LANG_DESC ,
	mdl_typ.obj_key_desc MDL_TYP_DESC,
	ai.currnt_ver_ind MDL_CURRNT_VER_IND, 
	me.item_long_nm  ME_LONG_NM, 
	me.item_phy_obj_nm ME_PHY_NM ,
	me_typ.obj_key_desc ME_TYP_DESC,
	me.item_desc ME_DESC,
	me_grp.obj_key_desc ME_MAP_GRP_DESC,
	me.item_id ME_ITEM_ID, 
	me.ver_nr ME_VER_NR, 
	mec.creat_dt, 
	mec.creat_usr_id, 
	mec.lst_upd_dt, 
	mec.lst_upd_usr_id, 
	mec.s2p_trn_dt, 
	mec.fld_delete, 
	mec.lst_del_dt,
	mec.src_dttype MEC_DTTYP, 
	mec.CHAR_ORD MEC_CHAR_ORD, 
	mec.src_max_char MEC_MAX_CHAR, 
	mec.src_min_char MEC_MIN_CHAR, 
	mec.src_uom MEC_UOM, 
	mec.src_deflt_val MEC_DEFLT_VAL, 
	  mec.cmnts_desc_txt,
	mec.de_conc_item_id, 
	mec.de_conc_ver_nr,
	dec.item_nm DEC_NM,
	dec.cntxt_nm_dn DEC_CNTXT_NM,
--	mec.val_dom_item_id,
--	mec.val_dom_ver_nr, 
	mec.mec_long_nm , 
	mec.mec_phy_nm , 
	mec.mec_desc , 
	mec.cde_item_id , 
	  mec.val_dom_item_id, 
	  mec.val_dom_ver_nr,
decode(vdst.VAL_DOM_TYP_ID,16, 'Enumerated by Reference', 17, 'Enumerated',18, 'Non-enumerated') VAL_DOM_TYP,
	  vdrt.TERM_NAME,
	  vdrt.USE_NAME,
	  vdst.VAL_DOM_MIN_CHAR, 
	  vdst.VAL_DOM_MAX_CHAR, 
	  vd.item_nm vd_item_nm,
	  dt.dttype_nm DT_TYP_DESC,
	  uom.uom_nm uom_DESC,
      mec_typ.obj_key_Desc MEC_TYP_DESC,
	mec.cde_ver_nr ,
	cde.Item_nm CDE_NM,
	cde.cntxt_nm_dn CDE_CNTXT_NM,
	  mec.mec_id,
	  mec.req_ind,
	  mec.pk_ind,
	  mec.fk_ind,
	  mec.mdl_pk_ind,
	  mec.FK_ELMNT_PHY_NM,
	  mec.FK_ELMNT_CHAR_PHY_NM,
      vdst.VAL_DOM_TYP_ID
from admin_item ai, nci_mdl mdl, nci_mdl_elmnt me, nci_mdl_elmnt_char mec,admin_item dec, admin_item cde, obj_key me_grp, obj_key mdl_typ, obj_key mdl_lang, obj_key me_typ, 
obj_key mec_typ, data_typ dt, uom uom,
	  admin_item vd, value_dom vdst, VW_VAL_DOM_REF_TERM vdrt
where ai.item_id = mdl.item_id and ai.ver_nr = mdl.ver_nr and ai.admin_item_typ_id = 57 and mdl.item_id = me.mdl_item_id
and mdl.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr
	and mec.cde_item_id = cde.item_id (+)
	and mec.cde_ver_nr = cde.ver_nr (+)
	and mec.val_dom_item_id = vd.item_id (+)
	and mec.val_dom_ver_nr = vd.ver_nr (+)	  
	and mec.val_dom_item_id = vdst.item_id (+)
	and mec.val_dom_ver_nr = vdst.ver_nr (+)	  
	and mec.val_dom_item_id = vdrt.item_id (+)
	and mec.val_dom_ver_nr = vdrt.ver_nr (+)	  
	and cde.admin_item_typ_id (+)= 4
	and mec.de_conc_item_id = dec.item_id (+)
	and mec.de_conc_ver_nr = dec.ver_nr (+)
	and dec.admin_item_typ_id (+)= 2
	and mdl.mdl_typ_id =mdl_typ.obj_key_id (+)
	and mdl.prmry_mdl_lang_id =mdl_lang.obj_key_id (+)
	and me.me_typ_id = me_typ.obj_key_id (+)
	and mec.MDL_ELMNT_CHAR_TYP_ID = mec_typ.obj_key_id (+)
	and me.me_grp_id = me_grp.obj_key_id (+)
	and vdst.NCI_STD_DTTYPE_ID = dt.dttype_id (+)
	  and vdst.uom_id = uom.uom_id (+);


-- Update missing languages due to bug in 67.
update alt_nms set lang_id = 1000 where creat_dt >= sysdate - 30 and lang_id is null;
commit;


update alt_def set lang_id = 1000 where creat_dt >= sysdate - 30 and lang_id is null;
commit;

alter table nci_mdl_elmnt_char add (VD_TYP_ID integer);

alter table nci_mdl_elmnt_char disable all triggers;

update nci_mdl_elmnt_char  c set vd_typ_id = (Select val_dom_typ_id from value_dom vd where vd.item_id = c.val_dom_item_id and vd.ver_nr = c.val_dom_ver_nr)
where c.val_dom_item_id is not null;
commit;

alter table nci_mdl_elmnt_char enable all triggers;

CREATE TABLE NCI_DS_PRMTR 
   (	"BTCH_USR_NM" VARCHAR2(100 BYTE) COLLATE "USING_NLS_COMP", 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"CREATED_DT" DATE DEFAULT sysdate, 
	"CREATED_BY" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP", 
	"REG_STUS_ID" NUMBER, 
	"ADMIN_STUS_ID" NUMBER, 
	"SRC_VAL_ID" NUMBER, 
	"CS_ID" NUMBER, 
	"CS_VER_NR" NUMBER(4,2), 
	"CNTXT_ID" NUMBER, 
	"CNTXT_VER_NR" NUMBER, 
	"VAL_DOM_TYP_ID" NUMBER, 
	"PRMTR_ID" NUMBER, 
	"HDR_ID" NUMBER, 
	"NUM_CDE_MTCH" NUMBER, 
	"NUM_PV" NUMBER, 
	"DT_SORT" TIMESTAMP (9), 
	"DT_LST_MODIFIED" VARCHAR2(32 BYTE) COLLATE "USING_NLS_COMP", 
	"MTCH_TYP" VARCHAR2(32 BYTE) COLLATE "USING_NLS_COMP", 
	"MTCH_LMT" NUMBER, 
	"ENTTY_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"ENTTY_NM_USR" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	 PRIMARY KEY ("PRMTR_ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP" SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;

    insert into obj_typ(obj_typ_id, obj_typ_desc) values (63, 'DS Source Value Parameter');
    commit;
    insert into obj_key(obj_key_id, obj_key_desc, obj_typ_id, obj_key_def) values (247, 'PV', 63, 'Sets the source value column to PV for CDE Match');
    insert into obj_key(obj_key_id, obj_key_desc, obj_typ_id, obj_key_def) values (248, 'VM', 63, 'Sets the source value column to VM for CDE Match');
    commit;
    
alter table nci_ds_rslt add PERM_VAL_NM varchar2(64);

alter table nci_ds_rslt_dtl add NUM_PV_MTCH number;


--jira 4241

  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_MDL_MAP_RSLT ("MDL_MAP_ITEM_ID", "MDL_MAP_VER_NR", "MEC_MAP_NM", "MEC_PHY_NM", "MEC_LONG_NM", "VAL_DOM_TYP", "PCODE_SYSGEN", "MEC_MAP_NOTES", "TRNS_DESC_TXT", "PROV_ORG_ID", "PROV_CNTCT_ID", "PROV_RSN_TXT", "PROV_TYP_RVW_TXT", "PROV_RVW_DT", "PROV_APRV_DT", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_DT", "LST_UPD_USR_ID", "CREAT_DT_X", "CREAT_USR_ID_X", "LST_UPD_DT_X", "LST_UPD_USR_ID_X", "FLD_DELETE", "S2P_TRN_DT", "LST_DEL_DT", "TRNS_RUL_NOT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select   map.MDL_MAP_ITEM_ID ,
         map.mdl_map_ver_nr ,
         map.MEC_MAP_NM,
          tmed.ITEM_PHY_OBJ_NM ||  '.'  || tmecd."MEC_PHY_NM"  MEC_PHY_NM,
        --    tmecd."MEC_PHY_NM",
	   --       tmecd.MEC_LONG_NM,
	          tmed.	ITEM_LONG_NM || '.' ||        tmecd.MEC_LONG_NM MEC_LONG_NM,
	  decode(vd.val_dom_typ_id, 16, 'Enumerated by Reference', 17, 'Enumerated', 18, 'Non-enumerated', '') VAL_DOM_TYP,
            map.PCODE_SYSGEN,
	  MEC_MAP_NOTES,
	  TRNS_DESC_TXT,
	  PROV_ORG_ID,
	  PROV_CNTCT_ID,
	  PROV_RSN_TXT,
	  	PROV_TYP_RVW_TXT,
	  PROV_RVW_DT,
	  PROV_APRV_DT,
        sysdate creat_dt,
	  'ONEDATA' creat_usr_id,	  
	   sysdate lst_upd_dt,
	  'ONEDATA' lst_upd_usr_id,
        map.creat_dt creat_dt_x,
	 map.creat_usr_id creat_usr_id_x,	  
	  map.lst_upd_dt lst_upd_dt_x,
	  map.lst_upd_usr_id lst_upd_usr_id_x,
      0 FLD_DELETE,
      sysdate S2P_TRN_DT,
      sysdate LST_DEL_DT,
      decode(map.TRANS_RUL_NOT, 122, 'Text', 124, 'SQL', 123, 'Pseudocode') TRNS_RUL_NOT
	from
     nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd, VALUE_DOM vd
	where  	 tmed.item_id = tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr = tmecd.MDL_ELMNT_VER_NR  
	  and tmecd.mec_id = map.TGT_MEC_ID_DERV
      and map.map_deg in (86,87,120,129,130)
and tmecd.VAL_DOM_ITEM_ID = vd.ITEM_ID (+)
	  and tmecd.VAL_DOM_VER_NR = vd.VER_NR (+)
      and (pcode_sysgen is not null or mec_map_notes is not null);

create sequence SEQ_DS_PRMTR_ID
increment by 1
start with 1;

--jia 4239

  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_MDL_MAP_IMP_TEMPLATE ("DO_NOT_USE", "BATCH_USER", "BATCH_NAME", "SEQ_ID", "MODEL_MAP_ID", "MODEL_MAP_VERSION", "MECM_ID", "SRC_CHAR_ORD", "SRC_ELMNT_PHY_NAME", "SRC_ELMNT_NAME", "SRC_PHY_NAME", "SRC_MEC_NAME", "TGT_ELMNT_PHY_NAME", "TGT_ELMNT_NAME", "TGT_PHY_NAME", "TGT_MEC_NAME", "TGT_CHAR_ORD", "MAPPING_GROUP_NAME", "TARGET_FUNCTION_ID", "TRANS_RULE_NOTATION", "DERIVATION_GROUP_ORDER", "SET_TARGET_DEFAULT", "TARGET_FUNCTION_PARAM", "OPERATOR", "OPERAND_TYPE", "FLOW_CONTROL", "PARENTHESIS", "RIGHT_OPERAND", "LEFT_OPERAND", "VALIDATION_PLATFORM", "TRANSFORMATION_NOTES", "TRANSFORMATION_RULE", "PROV_ORG", "PROV_CONTACT", "PROV_REVIEW_REASON", "PROV_TYPE_OF_REVIEW", "PROV_REVIEW_DATE", "PROV_APPROVAL_DATE", "PCODE_SYSGEN", "MAP_DEG", "VALUE_MAP_GENERATED_IND", "SOURCE_DOMAIN_TYPE", "TARGET_DOMAIN_TYPE", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "SRC_MEC_ID", "SOURCE_CDE_ITEM_ID", "SOURCE_CDE_VER", "TARGET_CDE_ITEM_ID", "TARGET_CDE_VER", "SOURCE_VD_ITEM_ID", "SOURCE_VD_VER_NR", "TARGET_VD_ITEM_ID", "TARGET_VD_VER_NR", "SRC_MDL_ITEM_ID", "SRC_MDL_VER_NR", "TGT_MDL_ITEM_ID", "TGT_MDL_VER_NR", "TGT_MEC_ID", "TGT_PK_IND", "SRC_PK_IND", "SOURCE_REF_TERM_SOURCE", "TARGET_REF_TERM_SOURCE", "TGT_ELMNT_PHY_NAME_DERV", "CMNTS_DESC_TXT", "CREAT_USR_ID_X", "LST_UPD_USR_ID_X", "CREAT_DT_X", "LST_UPD_DT_X", "SORT_ORD", "TRNS_RUL_NOT_ID", "SOURCE_DEC_ITEM_ID", "SOURCE_DEC_VER", "TARGET_DEC_ITEM_ID", "TARGET_DEC_VER") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select  ' ' "DO_NOT_USE",
       ' ' "BATCH_USER",
       ' ' "BATCH_NAME",
       rownum "SEQ_ID",
       map.mdl_map_item_id "MODEL_MAP_ID",
       map.mdl_map_ver_nr "MODEL_MAP_VERSION",
        map.mecm_id "MECM_ID", 
        smec.char_ord SRC_CHAR_ORD,
	sme.ITEM_PHY_OBJ_NM "SRC_ELMNT_PHY_NAME", 
	sme.ITEM_LONG_NM "SRC_ELMNT_NAME", 
  smec."MEC_PHY_NM" "SRC_PHY_NAME", 
	smec.MEC_LONG_NM "SRC_MEC_NAME", 
	  tme.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME", 
	 tme.ITEM_LONG_NM "TGT_ELMNT_NAME", 
	  tmec."MEC_PHY_NM" "TGT_PHY_NAME", 
   	tmec.MEC_LONG_NM "TGT_MEC_NAME", 
       tmec.char_ord TGT_CHAR_ORD,
          map.MEC_MAP_NM "MAPPING_GROUP_NAME",
    map.tgt_func_id "TARGET_FUNCTION_ID",
          ' ' "TRANS_RULE_NOTATION",
map.mec_sub_grp_nbr	"DERIVATION_GROUP_ORDER",
	map.TGT_VAL "SET_TARGET_DEFAULT"	,
map.TGT_FUNC_PARAM "TARGET_FUNCTION_PARAM"	,
	op.obj_key_desc "OPERATOR",
	op_typ.obj_key_desc "OPERAND_TYPE",
	flow_cntrl.obj_key_desc "FLOW_CONTROL",
	paren.obj_key_desc "PARENTHESIS",
	map.right_op "RIGHT_OPERAND",
	map.left_op "LEFT_OPERAND",
  map.valid_pltform	   "VALIDATION_PLATFORM",
	map.mec_map_notes "TRANSFORMATION_NOTES",
	map.TRNS_DESC_TXT "TRANSFORMATION_RULE",
	org.org_nm "PROV_ORG",
cnt.PRSN_FULL_NM_DERV	"PROV_CONTACT",
	map.prov_rsn_txt "PROV_REVIEW_REASON",
	map.prov_typ_rvw_txt "PROV_TYPE_OF_REVIEW",
	map.PROV_RVW_DT "PROV_REVIEW_DATE",
	map.prov_APRV_DT "PROV_APPROVAL_DATE",
	  map.pcode_sysgen,
	  map.map_deg,
decode(nvl(map.VAL_MAP_CREATE_IND,0),1, 'Yes','No') "VALUE_MAP_GENERATED_IND",
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "SOURCE_DOMAIN_TYPE",
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "TARGET_DOMAIN_TYPE",
	   map."CREAT_DT",
	  map."CREAT_USR_ID",
	  map."LST_UPD_USR_ID",
	  map."FLD_DELETE",
	  map."LST_DEL_DT",
	  map."S2P_TRN_DT",
	  map."LST_UPD_DT",
      smec.MEC_ID SRC_MEC_ID,
      smec.CDE_ITEM_ID  "SOURCE_CDE_ITEM_ID",
      smec.CDE_VER_NR  "SOURCE_CDE_VER",
      tmec.CDE_ITEM_ID  "TARGET_CDE_ITEM_ID",
      tmec.CDE_VER_NR  "TARGET_CDE_VER",
	  smec.val_dom_item_id "SOURCE_VD_ITEM_ID",
	  smec.val_dom_ver_nr "SOURCE_VD_VER_NR",
	    tmec.val_dom_item_id "TARGET_VD_ITEM_ID",
	  tmec.val_dom_ver_nr "TARGET_VD_VER_NR",
	  sme.MDL_ITEM_ID SRC_MDL_ITEM_ID,
	  sme.MDL_item_ver_nr src_mdl_ver_nr,
	  tme.MDL_ITEM_ID TGT_MDL_ITEM_ID,
	  tme.MDL_item_ver_nr TGT_mdl_ver_nr,
tmec.MEC_ID TGT_MEC_ID,
tmec.pk_ind TGT_PK_IND,
smec.pk_ind SRC_PK_IND,
svdrt.TERM_USE_NAME "SOURCE_REF_TERM_SOURCE",
tvdrt.TERM_USE_NAME "TARGET_REF_TERM_SOURCE"
	, tmed.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME_DERV",
    ' ' "CMNTS_DESC_TXT",
	  map.creat_usr_id creat_usr_id_x,
	  map.lst_upd_usr_id lst_upd_usr_id_x,
	  map.creat_dt creat_dt_x,
	  map.lst_upd_dt lst_upd_dt_x,
	  map.sort_ord,
      map.TRANS_RUL_NOT TRNS_RUL_NOT_ID,
      sdec.de_conc_item_id "SOURCE_DEC_ITEM_ID",
      sdec.de_conc_ver_nr "SOURCE_DEC_VER",
      tdec.de_conc_item_id "TARGET_DEC_ITEM_ID",
      tdec.de_conc_ver_nr "TARGET_DEC_VER"
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd,
	  obj_key op,
	  obj_key op_typ,
	  obj_key flow_cntrl,
	  obj_key paren,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd,
vw_val_dom_ref_term svdrt,
vw_val_dom_ref_term tvdrt,
	  NCI_PRSN cnt,
      vw_de sdec,
      vw_de tdec
	where  sme.item_id (+)= smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr (+)= smec.MDL_ELMNT_VER_NR and
	 tme.item_id (+)= tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr (+)= tmec.MDL_ELMNT_VER_NR  and
	 tmed.item_id (+)= tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr (+)= tmecd.MDL_ELMNT_VER_NR  and
	   smec.MEC_ID (+)= map.SRC_MEC_ID and tmec.mec_id (+)= map.TGT_MEC_ID
	  and tmecd.mec_id (+)= map.TGT_MEC_ID_DERV
	  and map.PROV_CNTCT_ID = cnt.entty_id (+)
	  and map.prov_org_id = org.entty_id (+)
	  and map.op_id = op.obj_key_id (+)
	  and map.paren = paren.obj_key_id (+)
	  and map.op_typ = op_typ.obj_key_id (+)
	  and map.flow_cntrl = flow_cntrl.obj_key_id (+)
          and smec.val_dom_item_id = svd.item_id (+)
	  and smec.val_dom_ver_nr = svd.ver_nr (+)
	  and tmec.val_dom_item_id = tvd.item_id (+)
 	  and tmec.val_dom_ver_nr = tvd.ver_nr (+)
          and svd.item_id = svdrt.item_id (+)
          and svd.ver_nr = svdrt.ver_nr (+)
          and tvd.item_id = tvdrt.item_id (+)
          and tvd.ver_nr = tvdrt.ver_nr (+)
          and sdec.item_id (+)= smec.cde_item_id
          and sdec.ver_nr (+)= smec.cde_ver_nr
          and tdec.item_id (+)= tmec.cde_item_id
          and tdec.ver_nr (+)= tmec.cde_ver_nr;

alter table nci_ds_hdr add PRMTR_ID number default 0;
alter table nci_ds_rslt_dtl add NUM_PV_MTCH number;



