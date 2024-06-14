
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ONEDATA_WA"."VALUE_DOMAINS_VIEW" ("VD_IDSEQ", "VERSION", "PREFERRED_NAME", "CONTE_IDSEQ", "PREFERRED_DEFINITION", "BEGIN_DATE", "CONTE_NAME", "REGISTRATION_STATUS", "CONTE_ITEM_ID", "CONTE_VER_NR", "DTL_NAME", "CD_IDSEQ", "CONC_DOM_ITEM_ID", "CONC_DOM_VER_NR", "END_DATE", "VD_TYPE", "ASL_NAME", "ADMIN_NOTES", "CHANGE_NOTE", "UOML_NAME", "LONG_NAME", "FORML_NAME", "MAX_LENGTH_NUM", "MIN_LENGTH_NUM", "HIGH_VALUE_NUM", "LOW_VALUE_NUM", "DECIMAL_PLACE", "LATEST_VERSION_IND", "DELETED_IND", "CREATED_BY", "MODIFIED_BY", "DATE_MODIFIED", "DATE_CREATED", "CHAR_SET_NAME", "REP_IDSEQ", "ORIGIN", "VD_ID", "VD_TYPE_FLAG") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT ai.NCI_IDSEQ
               VD_IDSEQ,
           ai.ver_nr
               VERSION,
           ai.ITEM_LONG_NM
               PREFERRED_NAME,
           con.nci_idseq
               CONTE_IDSEQ,
           translate(ai.ITEM_DESC,chr(10)||chr(11)||chr(13),' ')  PREFERRED_DEFINITION,
            AI.EFF_DT
               BEGIN_DATE,
           AI.CNTXT_NM_DN
               CONTE_NAME,
	   ai.REGSTR_STUS_NM_DN
               REGISTRATION_STATUS,
           AI.CNTXT_ITEM_ID
               CONTE_ITEM_ID,
           AI.CNTXT_VER_NR
               CONTE_VER_NR,
           data_typ.nci_cd
               DTL_NAME,
           cd.nci_idseq
               CD_IDSEQ,
           CONC_DOM_ITEM_ID,
           CONC_DOM_VER_NR,
           ai.UNTL_DT
               END_DATE,
           VAL_DOM_TYP_ID
               VD_TYPE,
           ai.ADMIN_STUS_NM_DN
               ASL_NAME,
	       translate(ai.ADMIN_NOTES,chr(10)||chr(11)||chr(13),' ') ADMIN_NOTES,
       translate(ai.CHNG_DESC_TXT,chr(10)||chr(11)||chr(13),' ')          CHANGE_NOTE,
           uom.nci_cd
               UOML_NAME,
           ai.ITEM_NM
               LONG_NAME,
           fmt.nci_cd
               FORML_NAME,
           VAL_DOM_HIGH_VAL_NUM
               MAX_LENGTH_NUM,
           VAL_DOM_LOW_VAL_NUM
               MIN_LENGTH_NUM,
           VAL_DOM_MAX_CHAR
               HIGH_VALUE_NUM,
           VAL_DOM_MIN_CHAR
               LOW_VALUE_NUM,
           NCI_DEC_PREC
               DECIMAL_PLACE,
           DECODE (ai.CURRNT_VER_IND,  1, 'Yes',  0, 'No')
               LATEST_VERSION_IND,
           DECODE (ai.FLD_DELETE,  1, 'Yes',  0, 'No')
               DELETED_IND,
           ai.CREAT_USR_ID
               CREATED_BY,
           ai.LST_UPD_USR_ID
               MODIFIED_BY,
           ai.LST_UPD_DT
               DATE_MODIFIED,
           ai.CREAT_DT
               DATE_CREATED,
           --ai.LST_DEL_DT                                 END_DATE,
           CHAR_SET_ID
               CHAR_SET_NAME,
           rep.NCI_IDSEQ
               REP_IDSEQ,
           --QUALIFIER_NAME,
           NVL (AI.ORIGIN, AI.ORIGIN_ID_DN)
               ORIGIN,
           ai.item_id
               VD_ID,
           DECODE (vd.VAL_DOM_TYP_ID,  16,'ER', 17, 'E',  18, 'N')
               VD_TYPE_FLAG
      FROM ONEDATA_WA.VALUE_DOM   vd,
           ONEDATA_WA.admin_item  ai,
           ONEDATA_WA.admin_item  cd,
           ONEDATA_WA.fmt,
           ONEDATA_WA.admin_item  con,
           ONEDATA_WA.admin_item  rep,
           ONEDATA_WA.uom,
           ONEDATA_WA.data_typ
     WHERE     vd.item_id = ai.item_id
           AND vd.ver_nr = ai.ver_nr
           AND ai.ADMIN_ITEM_TYP_ID = 3
           AND ai.CNTXT_ITEM_ID = con.ITEM_ID
           AND AI.CNTXT_VER_NR = con.VER_NR
           AND REP_CLS_ITEM_ID = rep.item_id(+)
           AND vd.REP_CLS_VER_NR = rep.ver_nr(+)
           AND fmt.fmt_id(+) = vd.VAL_DOM_FMT_ID
           AND vd.uom_id = uom.uom_id(+)
           AND vd.DTTYPE_ID = data_typ.DTTYPE_ID
           AND cd.item_id = vd.CONC_DOM_ITEM_ID
           AND cd.ver_nr = vd.CONC_DOM_VER_NR;


  GRANT SELECT ON "ONEDATA_WA"."VALUE_DOMAINS_VIEW" TO "ONEDATA_RO";
