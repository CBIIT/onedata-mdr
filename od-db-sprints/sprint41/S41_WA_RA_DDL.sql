-- update legacy PV origin


alter table perm_val disable all triggers;

update perm_val pv set nci_origin = (select max(SRC_NAME) from  sbrext.vd_pvs_sources_ext e where e.vp_idseq =  pv.nci_idseq and date_created < sysdate - 365 group by vp_idseq
)
where nci_idseq in (Select vp_idseq from  sbrext.vd_pvs_sources_ext);
commit;
update perm_val pv set nci_origin_id = (select obj_key_id from obj_key where nci_cd = pv.nci_origin and obj_typ_id = 18)
where nci_origin is not null and nci_origin_id is null;
commit;


alter table perm_val enable all triggers;

alter table NCI_STG_FORM_QUEST_IMPORT add SRC_LOGIC_INSTR varchar2(4000);

-- Tracker 2306

alter table NCI_ADMIN_ITEM_REL add (CPY_MIG_UPD_DT date, CPY_MIG_TYP varchar2(50));

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (39, 'Concept Relationships');
commit;

update obj_key set obj_typ_id = 39 where obj_key_id in (68,69,74);
commit;


insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (39, 'Item Components',75 , 'Item Components', 
											'Item Components');
commit;


  CREATE OR REPLACE  VIEW VW_NCI_DE
  AS
  SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
          CAST('.' || ADMIN_ITEM.ITEM_ID || '.' AS VARCHAR2(4000))    ITEM_ID_STR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.ADMIN_NOTES,
           ADMIN_ITEM.CHNG_DESC_TXT,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNRSLVD_ISSUE,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           -- ADMIN_ITEM.REGSTR_STUS_NM_DN,
           -- ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.CREAT_USR_ID             CREAT_USR_ID_X,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID           LST_UPD_USR_ID_X,
           rs.NCI_DISP_ORDR                    REGSTR_STUS_DISP_ORD,
           ws.NCI_DISP_ORDR                    ADMIN_STUS_DISP_ORD,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.NCI_IDSEQ,
	   ext.csi_concat,
           CNTXT.NCI_PRG_AREA_ID,
           ADMIN_ITEM_TYP_ID,
	   ADMIN_ITEM.ITEM_DEEP_LINK,
       replace (ADMIN_ITEM.ITEM_NM_ID_VER,'|Data Element','') ITEM_NM_ID_VER,
           ext.USED_BY                         CNTXT_AGG,
           REF.ref_desc                        PREF_QUEST_TXT,
	   vd.VAL_DOM_TYP_ID	,
        trim(SUBSTR (
                 trim(ADMIN_ITEM.ITEM_LONG_NM)
              || '||'
              || trim(ADMIN_ITEM.ITEM_NM) ,1,
              4290))
              || '||'
              ||
              SUBSTR ( trim(ref_desc.REF_DESC),
             1,
              30000)                          SEARCH_STR
      FROM ADMIN_ITEM,
           VW_CNTXT            CNTXT,
       --    VALUE_DOM vd,
           NCI_ADMIN_ITEM_EXT  ext,
	   de, VALUE_DOM vd,
           (SELECT item_id, ver_nr, ref_desc
              FROM REF
             WHERE ref_typ_id = 80) REF,
           (  SELECT item_id,
                     ver_nr,
                     LISTAGG (ref_desc, '||' ON OVERFLOW TRUNCATE ) WITHIN GROUP (ORDER BY OBJ_KEY_DESC desc)    ref_desc
                FROM REF, OBJ_KEY
               WHERE     REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                     AND LOWER (OBJ_KEY_DESC) LIKE '%question%'
            GROUP BY item_id, ver_nr) ref_desc,
           VW_REGSTR_STUS      rs,
           VW_ADMIN_STUS       ws
     WHERE     ADMIN_ITEM_TYP_ID = 4
           and ADMIN_ITEM.ITEM_Id = de.item_id
           and ADMIN_ITEM.VER_NR = DE.VER_NR
           and de.VAL_DOM_ITEM_ID = vd.ITEM_ID
	   and de.VAL_DOM_VER_NR = vd.VER_NR
	   AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
           AND ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = REF.VER_NR(+)
           AND ADMIN_ITEM.ITEM_ID = ref_desc.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = ref_desc.VER_NR(+)
           AND ADMIN_ITEM.REGSTR_STUS_ID = rs.STUS_ID(+)
           AND ADMIN_ITEM.ADMIN_STUS_ID = ws.STUS_ID(+)
           AND ADMIN_ITEM.CNTXT_ITEM_ID = CNTXT.ITEM_ID
           AND ADMIN_ITEM.CNTXT_VER_NR = CNTXT.VER_NR;



  CREATE OR REPLACE VIEW VW_NCI_AI_CNCPT as
  SELECT  '5. Object Class' ALT_NMS_LVL, DE.ITEM_ID  ITEM_ID,
		DE.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where
	a.ITEM_ID = DE_CONC.OBJ_CLS_ITEM_ID and
	a.VER_NR = DE_CONC.OBJ_CLS_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '4. Property' ALT_NMS_LVL, DE.ITEM_ID  ITEM_ID,
		DE.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND,  NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where
	a.ITEM_ID = DE_CONC.PROP_ITEM_ID and
	a.VER_NR = DE_CONC.PROP_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '3. Representation Term' ALT_NMS_LVL, DE.ITEM_ID  ITEM_ID,
		DE.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, VALUE_DOM VD where
	a.ITEM_ID = VD.REP_CLS_ITEM_ID and
	a.VER_NR = VD.REP_CLS_VER_NR and
	DE.VAL_DOM_ITEM_ID = VD.ITEM_ID and
	DE.VAL_DOM_VER_NR = VD.VER_NR
	union
         SELECT '1. Value Meaning' ALT_NMS_LVL, DE.ITEM_ID  ITEM_ID,
		DE.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, PERM_VAL PV where
	a.ITEM_ID = PV.NCI_VAL_MEAN_ITEM_ID and
	a.VER_NR = PV.NCI_VAL_MEAN_VER_NR and
	DE.VAL_DOM_ITEM_ID = PV.VAL_DOM_ITEM_ID and
	DE.VAL_DOM_VER_NR = PV.VAL_DOM_VER_NR
	union
         SELECT '2. Value Domain' ALT_NMS_LVL, DE.ITEM_ID  ITEM_ID,
		DE.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE where
	DE.VAL_DOM_ITEM_ID = a.ITEM_ID and
	DE.VAL_DOM_VER_NR = a.VER_NR
  union
    SELECT  '2. Object Class' ALT_NMS_LVL, DEC.ITEM_ID  ITEM_ID,
		DEC.VER_NR VER_NR,
	a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,0 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE_CONC DEC where
	a.ITEM_ID = DEC.OBJ_CLS_ITEM_ID and
	a.VER_NR = DEC.OBJ_CLS_VER_NR
	union
         SELECT '1. Property' ALT_NMS_LVL, DEC.ITEM_ID  ITEM_ID,
		DEC.VER_NR VER_NR,
	a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
			a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE_CONC DEC where
	a.ITEM_ID = DEC.PROP_ITEM_ID and
	a.VER_NR = DEC.PROP_VER_NR
  union
  SELECT  'Component Concept' ALT_NMS_LVL, a.ITEM_ID, a.VER_NR,
	a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a
   union
      SELECT 'Representation Term' ALT_NMS_LVL, VD.ITEM_ID  ITEM_ID,
	VD.VER_NR VER_NR,
		a.ITEM_ID CORE_ITEM_ID, a.VER_NR CORE_VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL,
		decode(a.nci_prmry_ind, 1, 'Yes', 'Qualifier') NCI_PRMRY_IND_TXT,75 REL_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, VALUE_DOM VD where
	a.ITEM_ID = VD.REP_CLS_ITEM_ID and
	a.VER_NR = VD.REP_CLS_VER_NR
	union
	SELECT  'Concept Relationship' ALT_NMS_LVL, 
		a.P_ITEM_ID ITEM_ID, a.P_ITEM_VER_NR VER_NR,
        a.P_ITEM_ID CORE_ITEM_ID, a.P_ITEM_VER_NR CORE_VER_NR,
		a.C_ITEM_ID CNCPT_ITEM_ID, a.C_ITEM_VER_NR CNCPT_VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, 1 NCI_ORD, 1 NCI_PRMRY_IND , '1' NCI_CNCPT_VAL,
		'1' NCI_PRMRY_IND_TXT, REL_TYP_ID
       FROM NCI_CNCPT_REL a;
       

alter table NCI_STG_FORM_VV_IMPORT add (VAL_MEAN_ITEM_ID number, val_mean_ver_nr number(4,2));

alter table NCI_ADMIN_ITEM_EXT add (CS_CONCAT varchar2(4000), CSI_CONCAT varchar2(4000));

  CREATE OR REPLACE VIEW VW_NCI_DEC_OC_PROP as
  SELECT  'OC' LVL, DEC.ITEM_ID  DEC_ITEM_ID,
		DEC.VER_NR DEC_VER_NR,
		DEC.OBJ_CLS_ITEM_ID ITEM_ID, DEC.OBJ_CLS_VER_NR VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT,
		a.ITEM_LONG_NM,
		a.ITEM_NM,
		a.CNTXT_NM_DN,
		a.REGSTR_STUS_NM_DN,
		a.ADMIN_STUS_NM_DN
       FROM admin_item a, DE_CONC DEC where
	a.ITEM_ID = DEC.ITEM_ID and
	a.VER_NR = DEC.VER_NR 
	union
  SELECT  'PROP' LVL, DEC.ITEM_ID  DEC_ITEM_ID,
		DEC.VER_NR DEC_VER_NR,
		DEC.PROP_ITEM_ID ITEM_ID, DEC.PROP_VER_NR VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT,
		a.ITEM_LONG_NM,
		a.ITEM_NM,
		a.CNTXT_NM_DN,
		a.REGSTR_STUS_NM_DN,
		a.ADMIN_STUS_NM_DN
       FROM admin_item a, DE_CONC DEC where
	a.ITEM_ID = DEC.ITEM_ID and
	a.VER_NR = DEC.VER_NR ;


  CREATE TABLE NCI_PROC_EXEC 
   (	"LOG_ID" INTEGER NOT NULL ENABLE, 
	"START_DT" TIMESTAMP (6) DEFAULT sysdate, 
	"JOB_STEP_DESC" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"JOB_STEP_SP" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE,     
	"RUN_PARAM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"END_DT" TIMESTAMP (6), 
	"EXEC_BY" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP", 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	 PRIMARY KEY ("LOG_ID"));
	 
