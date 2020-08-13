alter table DE_CONC modify (LST_UPD_DT default sysdate);

create unique index UX_PERM_VAL on PERM_VAL (VAL_DOM_ITEM_ID, VAL_DOM_VER_NR, PERM_VAL_NM);

update obj_key set obj_key_desc = 'Representation Term' where obj_key_id = 7;
commit;

alter table NCI_USR_CART add (GUEST_USR_NM  varchar2(255));

truncate table nci_usr_cart;

alter table nci_usr_cart drop primary key;

alter table nci_usr_cart modify (GUEST_USR_NM default 'NONE');

alter table nci_usr_cart add primary key (ITEM_ID, VER_NR, CNTCT_SECU_ID, GUEST_USR_NM);



CREATE OR REPLACE  VIEW VW_NCI_USR_CART AS
  SELECT AI.ITEM_ID, AI.VER_NR, AI.ITEM_LONG_NM, AI.CNTXT_NM_DN, AI.ITEM_NM, AI.REGSTR_STUS_NM_DN, AI.ADMIN_STUS_NM_DN, DECODE(AI.ADMIN_ITEM_TYP_ID, 4, 'Data Element', 54, 'Form') ADMIN_ITEM_TYP_NM,
UC.CNTCT_SECU_ID, UC.CREAT_DT, UC.CREAT_USR_ID, UC.LST_UPD_USR_ID, UC.FLD_DELETE, UC.LST_DEL_DT, UC.S2P_TRN_DT, UC.LST_UPD_DT, UC.NCI_GUEST_USR_NM
FROM NCI_USR_CART UC, ADMIN_ITEM AI WHERE AI.ITEM_ID = UC.ITEM_ID AND AI.VER_NR = UC.VER_NR;



  CREATE OR REPLACE  VIEW VW_NCI_DE_PV AS
  SELECT PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT, 
              DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR, VM.ITEM_NM, VM.ITEM_LONG_NM, 
                VM.ITEM_DESC, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR, e.CNCPT_CONCAT, e.CNCPT_CONCAT_NM,
		PV.CREAT_DT, PV.CREAT_USR_ID, PV.LST_UPD_USR_ID, PV.FLD_DELETE, PV.LST_DEL_DT, PV.S2P_TRN_DT, PV.LST_UPD_DT,
                PV.PRNT_CNCPT_ITEM_ID, PV.PRNT_CNCPT_VER_NR, VM.ITEM_NM || ' ' || VM.ITEM_DESC  VM_SEARCH_STR
       FROM  DE, PERM_VAL PV, ADMIN_ITEM VM, NCI_ADMIN_ITEM_EXT e where 
	PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID and
	PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR and
	PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID and
	PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR and
        VM.ITEM_ID = e.ITEM_ID and
        VM.VER_NR = e.VER_NR;


create or replace view VW_REF as 
select REF_ID,
REF_NM,
ITEM_ID,
CREAT_DT,
VER_NR,
CREAT_USR_ID,
LST_UPD_USR_ID,
FLD_DELETE,
LST_DEL_DT,
S2P_TRN_DT,
LST_UPD_DT,
REF_DESC,
REF_TYP_ID,
DISP_ORD,
LANG_ID,
NCI_CNTXT_ITEM_ID,
NCI_CNTXT_VER_NR,
URL,
NCI_IDSEQ,
REF_NM || ' ' || REF_DESC  REF_SEARCH_STR
from REF;


  CREATE OR REPLACE VIEW VW_NCI_CSI_DE AS
  select  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, ai.item_id csi_item_id, ai.ver_nr csi_ver_nr, 
  ai.item_nm csi_ITEM_NM, air.cntxt_cs_item_id CS_ITEM_ID, air.CNTXT_CS_VER_NR CS_VER_NR, aim.rel_typ_id,
 ai.item_long_nm  csi_item_long_nm, ai.item_desc csi_item_desc, air.p_item_Id p_CS_ITEM_ID, air.P_ITEM_VER_NR p_CS_VER_NR,
ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.item_nm || ' ' || cs.ITEM_NM CSI_SEARCH_STR, cs.ITEM_NM  CS_ITEM_NM, cs.ITEM_LONG_NM CS_ITEM_LONG_NM
from admin_item ai, nci_admin_item_rel_alt_key air, nci_alt_key_admin_item_rel aim, admin_item cs 
where ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr 
and air.rel_typ_id = 64
and aim.nci_pub_id = air.nci_pub_id and aim.nci_ver_nr = air.nci_ver_nr
and air.cntxt_cs_item_id = cs.item_id and air.cntxt_cs_ver_nr = cs.ver_nr and cs.admin_item_typ_id = 9 ;



  CREATE OR REPLACE  VIEW VW_NCI_DE_CNCPT AS
  SELECT  '4. Object Class' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR, 
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR, 
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID, 
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT, 
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where 
	a.ITEM_ID = DE_CONC.OBJ_CLS_ITEM_ID and
	a.VER_NR = DE_CONC.OBJ_CLS_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '3. Property' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR, 
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR, 
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID, 
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT, 
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where 
	a.ITEM_ID = DE_CONC.PROP_ITEM_ID and
	a.VER_NR = DE_CONC.PROP_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '2. Representation Term' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR, 
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR, 
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID, 
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT, 
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, VALUE_DOM VD where 
	a.ITEM_ID = VD.REP_CLS_ITEM_ID and
	a.VER_NR = VD.REP_CLS_VER_NR and
	DE.VAL_DOM_ITEM_ID = VD.ITEM_ID and
	DE.VAL_DOM_VER_NR = VD.VER_NR
	union
         SELECT '1. Value Meaning' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR, 
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR, 
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID, 
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT, 
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL
       FROM CNCPT_ADMIN_ITEM a, DE, PERM_VAL PV where 
	a.ITEM_ID = PV.NCI_VAL_MEAN_ITEM_ID and
	a.VER_NR = PV.NCI_VAL_MEAN_VER_NR and
	DE.VAL_DOM_ITEM_ID = PV.VAL_DOM_ITEM_ID and
	DE.VAL_DOM_VER_NR = PV.VAL_DOM_VER_NR
;



  CREATE OR REPLACE  VIEW VW_NCI_DE_HORT AS
  SELECT 
	ADMIN_ITEM.ITEM_ID ITEM_ID, 
	ADMIN_ITEM.VER_NR, 
	ADMIN_ITEM.ITEM_NM, 
	ADMIN_ITEM.ITEM_LONG_NM, 
	ADMIN_ITEM.ITEM_DESC, 
	ADMIN_ITEM.CNTXT_NM_DN, 
	ADMIN_ITEM.ORIGIN, 
	ADMIN_ITEM.UNTL_DT, 
	ADMIN_ITEM.CURRNT_VER_IND, 
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
	DE.CREAT_USR_ID, 
	DE.LST_UPD_USR_ID, 
	DE.FLD_DELETE, 
	DE.LST_DEL_DT, 
	DE.S2P_TRN_DT, 
	DE.LST_UPD_DT, 
	DE.CREAT_DT, 
	DE.CREAT_USR_ID CREAT_USR_ID_API, 
	DE.LST_UPD_USR_ID LST_UPD_USR_ID_API, 
	DE.CREAT_DT CREAT_DT_API, 
	DE.LST_UPD_DT LST_UPD_DT_API, 
	VALUE_DOM.CONC_DOM_VER_NR, 
	VALUE_DOM.CONC_DOM_ITEM_ID, 
	VALUE_DOM.NON_ENUM_VAL_DOM_DESC, 
	VALUE_DOM.UOM_ID, 
	VALUE_DOM.VAL_DOM_TYP_ID VAL_DOM_TYP_ID, 
	VALUE_DOM.VAL_DOM_MIN_CHAR, 
	VALUE_DOM.VAL_DOM_MAX_CHAR, 
	VALUE_DOM.VAL_DOM_FMT_ID, 
	VALUE_DOM.CHAR_SET_ID, 
	VALUE_DOM.CREAT_DT VALUE_DOM_CREAT_DT, 
	VALUE_DOM.CREAT_USR_ID VALUE_DOM_USR_ID, 
	VALUE_DOM.LST_UPD_USR_ID VALUE_DOM_LST_UPD_USR_ID, 
	VALUE_DOM.LST_UPD_DT VALUE_DOM_LST_UPD_DT,
	VALUE_DOM_AI.ITEM_NM VALUE_DOM_ITEM_NM, 
	VALUE_DOM_AI.ITEM_LONG_NM VALUE_DOM_ITEM_LONG_NM, 
	VALUE_DOM_AI.ITEM_DESC  VALUE_DOM_ITEM_DESC, 
	VALUE_DOM_AI.CNTXT_NM_DN VALUE_DOM_CNTXT_NM, 
	VALUE_DOM_AI.CURRNT_VER_IND VALUE_DOM_CURRNT_VER_IND, 
	VALUE_DOM_AI.REGSTR_STUS_NM_DN VALUE_DOM_REGSTR_STUS_NM, 
	VALUE_DOM_AI.ADMIN_STUS_NM_DN VALUE_DOM_ADMIN_STUS_NM, 
	VALUE_DOM.NCI_STD_DTTYPE_ID,
    VALUE_DOM.DTTYPE_ID,
	ADMIN_ITEM.REGSTR_AUTH_ID,
	DEC_AI.ITEM_NM DEC_ITEM_NM, 
	DEC_AI.ITEM_LONG_NM DEC_ITEM_LONG_NM, 
	DEC_AI.ITEM_DESC  DEC_ITEM_DESC, 
	DEC_AI.CNTXT_NM_DN DEC_CNTXT_NM, 
	DEC_AI.CURRNT_VER_IND DEC_CURRNT_VER_IND, 
	DEC_AI.REGSTR_STUS_NM_DN DEC_REGSTR_STUS_NM, 
	DEC_AI.ADMIN_STUS_NM_DN DEC_ADMIN_STUS_NM, 
	DEC_AI.CREAT_DT DEC_CREAT_DT, 
	DEC_AI.CREAT_USR_ID DEC_USR_ID, 
	DEC_AI.LST_UPD_USR_ID DEC_LST_UPD_USR_ID, 
	DEC_AI.LST_UPD_DT DEC_LST_UPD_DT,
	DE_CONC.OBJ_CLS_ITEM_ID,
	DE_CONC.OBJ_CLS_VER_NR,
        OC.ITEM_NM OBJ_CLS_ITEM_NM,
        OC.ITEM_LONG_NM OBJ_CLS_ITEM_LONG_NM,
        PROP.ITEM_NM PROP_ITEM_NM,
        PROP.ITEM_LONG_NM PROP_ITEM_LONG_NM,
	DE_CONC.PROP_ITEM_ID,
	DE_CONC.PROP_VER_NR,
	DE_CONC.CONC_DOM_ITEM_ID DEC_CD_ITEM_ID,
	DE_CONC.CONC_DOM_VER_NR DEC_CD_VER_NR,
	DEC_CD.ITEM_NM DEC_CD_ITEM_NM, 
	DEC_CD.ITEM_LONG_NM DEC_CD_ITEM_LONG_NM, 
	DEC_CD.ITEM_DESC  DEC_CD_ITEM_DESC, 
	DEC_CD.CNTXT_NM_DN DEC_CD_CNTXT_NM, 
	DEC_CD.CURRNT_VER_IND DEC_CD_CURRNT_VER_IND, 
	DEC_CD.REGSTR_STUS_NM_DN DEC_CD_REGSTR_STUS_NM, 
	DEC_CD.ADMIN_STUS_NM_DN DEC_CD_ADMIN_STUS_NM, 
	CD_AI.ITEM_NM CD_ITEM_NM, 
	CD_AI.ITEM_LONG_NM CD_ITEM_LONG_NM, 
	CD_AI.ITEM_DESC  CD_ITEM_DESC, 
	CD_AI.CNTXT_NM_DN CD_CNTXT_NM, 
	CD_AI.CURRNT_VER_IND CD_CURRNT_VER_IND, 
	CD_AI.REGSTR_STUS_NM_DN CD_REGSTR_STUS_NM, 
	CD_AI.ADMIN_STUS_NM_DN CD_ADMIN_STUS_NM, 
	       ADMIN_ITEM.ADMIN_ITEM_TYP_ID ,
        '' CNTXT_AGG,
        SYSDATE - greatest(DE.LST_UPD_DT, admin_item.lst_upd_dt, Value_dom.LST_UPD_DT, dec_ai.LST_UPD_DT) LST_UPD_CHG_DAYS
       FROM ADMIN_ITEM, DE,  VALUE_DOM, ADMIN_ITEM VALUE_DOM_AI, 
	ADMIN_ITEM DEC_AI, DE_CONC, ADMIN_ITEM DEC_CD,
	ADMIN_ITEM CD_AI, ADMIN_ITEM OC, ADMIN_ITEM PROP
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
and DE.VER_NR = ADMIN_ITEM.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM_AI.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM_AI.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
and DE.DE_CONC_ITEM_ID = DEC_AI.ITEM_ID
and DE.DE_CONC_VER_NR = DEC_AI.VER_NR
and DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
and DE_CONC.OBJ_CLS_ITEM_ID = OC.ITEM_ID
and DE_CONC.OBJ_CLS_VER_NR = OC.VER_NR
and DE_CONC.PROP_ITEM_ID = PROP.ITEM_ID
and DE_CONC.PROP_VER_NR = PROP.VER_NR
and DE.DE_CONC_VER_NR = DE_CONC.VER_NR
and DE_CONC.CONC_DOM_ITEM_ID = DEC_CD.ITEM_ID
and DE_CONC.CONC_DOM_VER_NR = DEC_CD.VER_NR
and VALUE_DOM.CONC_DOM_ITEM_ID = CD_AI.ITEM_ID
and VALUE_DOM.CONC_DOM_VER_NR = CD_AI.VER_NR
;



  CREATE OR REPLACE  view VW_NCI_CSI_NODE AS 
  SELECT NODE.NCI_PUB_ID, NODE.NCI_VER_NR, CSI.ITEM_ID, CSI.VER_NR, CSI.ITEM_NM, CSI.ITEM_LONG_NM, CSI.ITEM_DESC, 
CSI.CNTXT_NM_DN, CSI.CURRNT_VER_IND, CSI.REGSTR_STUS_NM_DN, CSI.ADMIN_STUS_NM_DN, NODE.CREAT_DT, 
NODE.CREAT_USR_ID, NODE.LST_UPD_USR_ID, NODE.FLD_DELETE, NODE.LST_DEL_DT, NODE.S2P_TRN_DT, 
NODE.LST_UPD_DT,
cs.item_id cs_item_id, cs.ver_nr cs_ver_nr , cs.item_long_nm cs_long_nm, cs.item_nm cs_item_nm, cs.item_desc cs_item_desc,
pcsi.item_id pcsi_item_id, pcsi.ver_nr pcsi_ver_nr, pcsi.item_long_nm pcsi_long_nm, pcsi.item_nm pcsi_item_nm, cs.admin_stus_nm_dn cs_admin_stus_nm_dn
FROM ADMIN_ITEM CSI, NCI_ADMIN_ITEM_REL_ALT_KEY NODE, ADMIN_ITEM CS, ADMIN_ITEM PCSI
       WHERE csi.ADMIN_ITEM_TYP_ID = 51 and node.c_item_id = csi.item_id and node.c_item_ver_nr = csi.ver_nr
       and node.cntxt_cs_item_id = cs.item_id and node.cntxt_cs_Ver_nr = cs.ver_nr
       and node.rel_typ_id = 64
       and node.p_item_id = pcsi.item_id (+)
       and node.p_item_ver_nr = pcsi.ver_nr (+)
       and pcsi.admin_item_typ_id (+) = 51
       and cs.admin_item_typ_id = 9;

  CREATE OR REPLACE  VIEW VW_NCI_CSI_DE AS
  select  aim.NCI_PUB_ID, AIM.NCI_VER_NR,  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, ai.item_id csi_item_id, ai.ver_nr csi_ver_nr, 
  ai.item_nm csi_ITEM_NM, air.cntxt_cs_item_id CS_ITEM_ID, air.CNTXT_CS_VER_NR CS_VER_NR, aim.rel_typ_id,
 ai.item_long_nm  csi_item_long_nm, ai.item_desc csi_item_desc, air.p_item_Id p_CS_ITEM_ID, air.P_ITEM_VER_NR p_CS_VER_NR,
ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.item_nm || ' ' || cs.ITEM_NM CSI_SEARCH_STR, cs.ITEM_NM  CS_ITEM_NM, cs.ITEM_LONG_NM CS_ITEM_LONG_NM
from admin_item ai, nci_admin_item_rel_alt_key air, nci_alt_key_admin_item_rel aim, admin_item cs 
where ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr 
and air.rel_typ_id = 64
and aim.nci_pub_id = air.nci_pub_id and aim.nci_ver_nr = air.nci_ver_nr
and air.cntxt_cs_item_id = cs.item_id and air.cntxt_cs_ver_nr = cs.ver_nr and cs.admin_item_typ_id = 9;


