 
 -- Tracker 1276
 insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'Form MDF', 105, 'Form MDF', 'Form MDF');
commit;
 
 CREATE OR REPLACE  VIEW VW_NCI_DE_PV_LEAN AS
  SELECT PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT ITEM_NM,
              DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR, 
             NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR,
		PV.CREAT_DT, PV.CREAT_USR_ID, PV.LST_UPD_USR_ID, PV.FLD_DELETE, PV.LST_DEL_DT, PV.S2P_TRN_DT, PV.LST_UPD_DT
       FROM  DE, PERM_VAL PV where
	PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID and
	PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR;
	
alter table 	NCI_DS_HDR add (NUM_CDE_MTCH  integer);
alter table 	NCI_DS_HDR add (NUM_PV  integer);
alter table 	NCI_DS_HDR add (BTCH_NM  varchar2(50));
alter table NCI_DS_HDR add (CDE_ITEM_ID number, CDE_VER_NR number(4,2));


drop table nci_ds_rslt_detl;

truncate table NCI_FORM_TA;

alter table NCI_FORM_TA add (FORM_ITEM_ID number not null, FORM_VER_NR number(4,2) not null, MOD_ITEM_ID number not null, MOD_VER_NR number(4,2) not null);


  CREATE OR REPLACE  VIEW VW_NCI_DE_HORT AS
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
           DE.DE_PREC,
           DE.DE_CONC_ITEM_ID,
           DE.DE_CONC_VER_NR,
           DE.VAL_DOM_VER_NR,
           DE.VAL_DOM_ITEM_ID,
           DE.REP_CLS_VER_NR,
           DE.REP_CLS_ITEM_ID,
           DE.DERV_DE_IND,
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
           ADMIN_ITEM.CREAT_USR_ID                   CREAT_USR_ID_API,
          ADMIN_ITEM.LST_UPD_USR_ID                 LST_UPD_USR_ID_API,
           ADMIN_ITEM.CREAT_DT                       CREAT_DT_API,
           ADMIN_ITEM.LST_UPD_DT                     LST_UPD_DT_API,
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
           ''                                CNTXT_AGG,
             SYSDATE
           - GREATEST (DE.LST_UPD_DT,
                       admin_item.lst_upd_dt,
                       Value_dom.LST_UPD_DT,
                       dec_ai.LST_UPD_DT)    LST_UPD_CHG_DAYS
      FROM ADMIN_ITEM,
           DE,
           VALUE_DOM,
           ADMIN_ITEM          VALUE_DOM_AI,
           ADMIN_ITEM          DEC_AI,
           DE_CONC,
           VW_CONC_DOM         DEC_CD,
           VW_CONC_DOM         CD_AI,
           ADMIN_ITEM          OC,
           ADMIN_ITEM          PROP,
           NCI_ADMIN_ITEM_EXT  CONOC,
           NCI_ADMIN_ITEM_EXT  CONPROP
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
           AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
           AND DE.VER_NR = ADMIN_ITEM.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM_AI.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM_AI.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND DE.DE_CONC_ITEM_ID = DEC_AI.ITEM_ID
           AND DE.DE_CONC_VER_NR = DEC_AI.VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE_CONC.OBJ_CLS_ITEM_ID = OC.ITEM_ID
           AND DE_CONC.OBJ_CLS_VER_NR = OC.VER_NR
           AND DE_CONC.PROP_ITEM_ID = PROP.ITEM_ID
           AND DE_CONC.PROP_VER_NR = PROP.VER_NR
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
           AND DE_CONC.CONC_DOM_ITEM_ID = DEC_CD.ITEM_ID
           AND DE_CONC.CONC_DOM_VER_NR = DEC_CD.VER_NR
           AND VALUE_DOM.CONC_DOM_ITEM_ID = CD_AI.ITEM_ID
           AND VALUE_DOM.CONC_DOM_VER_NR = CD_AI.VER_NR
           AND OC.ITEM_ID = CONOC.ITEM_ID
           AND OC.VER_NR = CONOC.VER_NR
           AND PROP.ITEM_ID = CONPROP.ITEM_ID
           AND PROP.VER_NR = CONPROP.VER_NR;
	   
	   
create or replace view vw_nci_mod_quest_vv as
select                mod.item_id NCI_PUB_id,
           mod.ver_nr nci_ver_nr,
	   mod.ITEM_NM MOD_NM,
	   '-' QUEST_NM, 
	   '-' VALID_VALUE,
           'MODULE' LVL_NM,
	   r.DISP_ORD  MOD_DISP_ORD,
	   0  QUEST_DISP_ORD,
           mod.ITEM_NM ,
           mod.ITEM_DESC, 
           mod.CREAT_USR_ID,
           mod.LST_UPD_USR_ID,
           mod.FLD_DELETE,
           mod.LST_DEL_DT,
           mod.S2P_TRN_DT,
           mod.LST_UPD_DT,
          mod.CREAT_DT
          from ADMIN_ITEM mod, nci_admin_item_rel r where admin_item_typ_id = 52 and mod.item_id = r.c_item_id and mod.ver_nr = r.c_item_ver_nr
	  and r.rel_typ_id = 61
          union
          select                nci_pub_id ,
           nci_ver_nr ,
           mod.ITEM_NM MOD_NM,
	   q.ITEM_LONG_NM QUEST_NM, 
	   '-' VALID_VALUE,
           'QUESTION' LVL_NM,
	      r.DISP_ORD  MOD_DISP_ORD,
	   q.DISP_ORD  QUEST_DISP_ORD,
           q.ITEM_LONG_NM ITEM_NM ,
           q.ITEM_LONG_NM ITEM_DESC, 
           q.CREAT_USR_ID,
           q.LST_UPD_USR_ID,
           q.FLD_DELETE,
           q.LST_DEL_DT,
           q.S2P_TRN_DT,
           q.LST_UPD_DT,
          q.CREAT_DT
          from NCI_ADMIN_ITEM_REL_ALT_KEY q , ADMIN_ITEM mod, nci_admin_item_rel r
	  where q.p_item_id = mod.item_id and q.p_item_ver_nr = mod.ver_nr and mod.admin_item_typ_id = 52
	  and mod.item_id = r.c_item_id and mod.ver_nr = r.c_item_ver_nr and r.rel_typ_id = 61
          union
           select                vv.nci_pub_id ,
           vv.nci_ver_nr ,
           mod.ITEM_NM MOD_NM,
	   q.ITEM_LONG_NM QUEST_NM, 
	   vv.VALUE VALID_VALUE,
           'VALID_VALUE' LVL_NM,
	         r.DISP_ORD  MOD_DISP_ORD,
	   q.DISP_ORD  QUEST_DISP_ORD,
           vv.VALUE ITEM_NM ,
           vv.VALUE || ' ' || MEAN_TXT  ITEM_DESC, 
           vv.CREAT_USR_ID,
           vv.LST_UPD_USR_ID,
           vv.FLD_DELETE,
           vv.LST_DEL_DT,
           vv.S2P_TRN_DT,
           vv.LST_UPD_DT,
          vv.CREAT_DT
          from NCI_QUEST_VALID_VALUE vv,  NCI_ADMIN_ITEM_REL_ALT_KEY q , ADMIN_ITEM mod, nci_admin_item_rel r
	  where vv.q_pub_id = q.nci_pub_id and vv.q_ver_Nr = q.nci_ver_nr and q.p_item_id = mod.item_id and q.p_item_ver_nr = mod.ver_nr and mod.admin_item_typ_id = 52
	   and mod.item_id = r.c_item_id and mod.ver_nr = r.c_item_ver_nr and r.rel_typ_id = 61;
         
alter table NCI_QUEST_VALID_VALUE add (OLD_NCI_PUB_ID number);


  CREATE OR REPLACE  VIEW VW_NCI_FORM_FLAT AS
  select frm.item_long_nm frm_item_long_nm, frm.item_nm frm_item_nm, frm.item_id frm_item_id, frm.ver_nr frm_ver_nr, frm.item_desc  frm_item_def,
  frmst.hdr_instr, frmst.ftr_instr,
air.p_item_id mod_item_id, air.p_item_ver_nr mod_ver_nr, frm_mod.instr MOD_INSTR,
 air.c_item_id de_item_id, air.c_item_ver_nr de_ver_nr, air.disp_ord quest_disp_ord,frm_mod.disp_ord mod_disp_ord, frm_mod.rep_no  mod_rep_no,
aim.item_nm MOD_ITEM_NM, air.instr QUEST_INSTR, air.REQ_IND  QUEST_REQ_IND, air.DEFLT_VAL QUEST_DEFLT_VAL, air.EDIT_IND QUEST_EDIT_IND,
 aim.item_long_nm  mod_item_long_nm, aim.item_desc mod_item_desc,
air.nci_pub_id QUEST_ITEM_ID,air.nci_ver_nr QUEST_VER_NR,
de.CNTXT_NM_DN CDE_CNTXT_NM, de.item_nm CDE_ITEM_NM, de.cntxt_item_id CDE_CNTXT_ITEM_ID, de.cntxt_VER_NR CDE_CNTXT_VER_NR, de.REGSTR_STUS_NM_DN CDE_REGSTR_STUS_NM,
de.ADMIN_STUS_NM_DN CDE_ADMIN_STUS_NM,
air.CREAT_DT, air.CREAT_USR_ID, air.LST_UPD_USR_ID, air.FLD_DELETE, air.LST_DEL_DT, air.S2P_TRN_DT, air.LST_UPD_DT, air.item_long_nm QUEST_LONG_TXT, air.item_nm QUEST_TXT,
vv.VM_NM, vv.VM_LNM, vv.VM_DEF, vv.VALUE VV_VALUE, vv.EDIT_IND VV_EDIT_IND, vv.SEQ_NBR VV_SEQ_NR, vv.MEAN_TXT VV_MEAN_TXT, vv.DESC_TXT VV_DESC_TXT, nvl(vv.nci_pub_id, 1) VV_ITEM_ID,
nvl(vv.nci_ver_nr, 1) VV_VER_NR, vv.INSTR VV_INSTR, vv.DISP_ORD VV_DISP_ORD
from  nci_admin_item_rel_alt_key air, admin_item aim,
admin_item frm, nci_admin_item_rel frm_mod , admin_item de, nci_quest_valid_value vv, nci_form frmst
where  air.rel_typ_id = 63
and aim.item_id = air.p_item_id and aim.ver_nr = air.p_item_ver_nr
and frm.item_id = frm_mod.p_item_id and frm.ver_nr = frm_mod.p_item_ver_nr and aim.item_id = frm_mod.c_item_id and aim.ver_nr = frm_mod.c_item_ver_nr
and frm.item_id = frmst.item_id and frm.ver_nr = frmst.ver_nr
and frm_mod.rel_typ_id in (61,62)
and frm.admin_item_typ_id in ( 54,55)
and air.c_item_id = de.item_id (+)
and air.c_item_ver_nr = de.ver_nr (+)
and air.NCI_PUB_ID = vv.q_pub_id (+)
and air.nci_ver_nr = vv.q_ver_nr (+);


alter table  NCI_STG_PV_VM_BULK add 
	("CNCPT_2_ITEM_ID_1" NUMBER, 
	"CNCPT_2_VER_NR_1" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_2" NUMBER, 
	"CNCPT_2_VER_NR_2" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_3" NUMBER, 
	"CNCPT_2_VER_NR_3" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_4" NUMBER, 
	"CNCPT_2_VER_NR_4" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_5" NUMBER, 
	"CNCPT_2_VER_NR_5" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_6" NUMBER, 
	"CNCPT_2_VER_NR_6" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_7" NUMBER, 
	"CNCPT_2_VER_NR_7" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_8" NUMBER, 
	"CNCPT_2_VER_NR_8" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_9" NUMBER, 
	"CNCPT_2_VER_NR_9" NUMBER(4,2), 
	"CNCPT_2_ITEM_ID_10" NUMBER, 
	"CNCPT_2_VER_NR_10" NUMBER(4,2));
	
	  CREATE OR REPLACE  VIEW VW_NCI_MODULE_DE AS
  select frm.item_long_nm frm_item_long_nm, frm.item_nm frm_item_nm, frm.item_id frm_item_id, frm.ver_nr frm_ver_nr,
air.p_item_id mod_item_id, air.p_item_ver_nr mod_ver_nr,
 air.c_item_id de_item_id, air.c_item_ver_nr de_ver_nr, air.disp_ord quest_disp_ord,frm_mod.disp_ord mod_disp_ord,
aim.item_nm MOD_ITEM_NM, air.instr,
 aim.item_long_nm  mod_item_long_nm, aim.item_desc mod_item_desc,
'QUESTION' admin_item_typ_nm, air.nci_pub_id,air.nci_ver_nr,
de.CNTXT_NM_DN, de.item_nm DE_ITEM_NM, de.cntxt_item_id DE_CNTXT_ITEM_ID, de.cntxt_VER_NR DE_CNTXT_VER_NR, de.ADMIN_STUS_NM_DN DE_ADMIN_STUS_NM_DN, de.REGSTR_STUS_NM_DN DE_REGSTR_STUS_NM_DN,
air.CREAT_DT, air.CREAT_USR_ID, air.LST_UPD_USR_ID, air.FLD_DELETE, air.LST_DEL_DT, air.S2P_TRN_DT, air.LST_UPD_DT, air.item_long_nm QUEST_LONG_TXT, air.item_nm QUEST_TXT
from  nci_admin_item_rel_alt_key air, admin_item aim,
admin_item frm, nci_admin_item_rel frm_mod , admin_item de
where  air.rel_typ_id = 63
and aim.item_id = air.p_item_id and aim.ver_nr = air.p_item_ver_nr
and frm.item_id = frm_mod.p_item_id and frm.ver_nr = frm_mod.p_item_ver_nr and aim.item_id = frm_mod.c_item_id and aim.ver_nr = frm_mod.c_item_ver_nr
and frm_mod.rel_typ_id in (61,62)
and frm.admin_item_typ_id in ( 54,55)
and air.c_item_id = de.item_id
and air.c_item_ver_nr = de.ver_nr;

