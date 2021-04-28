DROP VIEW ONEDATA_WA.VW_ALS_CDE_VD_RAW_DATA;

/* Formatted on 4/28/2021 12:54:32 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_CDE_VD_RAW_DATA
(
    DE_PUB_ID,
    DE_VERSION,
    DE_LONG_NAME,
    PREFERRED_QUESTION,
    VD_LONG_NAME,
    VD_ID,
    VD_VERSION,
    VAL_DOM_TYP_ID,
    VAL_DOM_MAX_CHAR,
    VD_MAXIMUM_LENGTH,
    VD_DISPLAY_FORMAT
)
BEQUEATH DEFINER
AS
      SELECT DE.ITEM_ID                                      DE_PUB_ID,
             DE.VER_NR                                       DE_VERSION,
             CDE.ITEM_NM                                     DE_Long_Name,
             REF.ref_desc                                    Preferred_Question,
             VD.ITEM_NM                                      VD_Long_Name,
             VALUE_DOM.ITEM_ID                               VD_ID,
             VALUE_DOM.VER_NR                                VD_VERSION,
             DECODE (VAL_DOM_TYP_ID,  17, 'E',  18, 'N')     VAL_DOM_TYP_ID,
             VALUE_DOM.VAL_DOM_MAX_CHAR,
             VALUE_DOM.VAL_DOM_HIGH_VAL_NUM                  VD_Maximum_Length,
             FMT.FMT_NM                                      VD_Display_Format
        FROM de        DE,
             ADMIN_ITEM CDE,
             VALUE_DOM,
             ADMIN_ITEM VD,
             FMT,
             (SELECT item_id, ver_nr, ref_desc
                FROM REF
               WHERE ref_typ_id = 80) REF
       WHERE     VD.ADMIN_ITEM_TYP_ID = 3
             AND CDE.ADMIN_ITEM_TYP_ID = 4
             AND CDE.ITEM_ID = DE.ITEM_ID
             AND CDE.VER_NR = DE.VER_NR
             AND de.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
             AND de.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
             AND VD.ITEM_ID = VALUE_DOM.ITEM_ID
             AND VD.VER_NR = VALUE_DOM.VER_NR
             AND CDE.ITEM_ID = REF.ITEM_ID(+)
             AND CDE.VER_NR = REF.VER_NR(+)
             AND VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
    ORDER BY DE_PUB_ID, DE_VERSION;
