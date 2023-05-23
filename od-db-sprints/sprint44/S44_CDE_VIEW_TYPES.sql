ALTER TYPE MDSR_749_ALTERNATENAME_ITEM_T modify attribute "AlternateName"  varchar2(4000) CASCADE;
ALTER TYPE CDEBROWSER_ALTNAME_T modify attribute "AlternateName"  varchar2(4000) CASCADE;
ALTER TYPE DATA_ELEMENT_DERIVATION_T modify attribute "PreferredDefinition" varchar2(4000) CASCADE;
ALTER TYPE DE_VALID_VALUE_T modify attribute MeaningDescription varchar2(4000) CASCADE;
DROP VIEW ONEDATA_WA.VW_NCI_DE_EXCEL;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE_EXCEL
(NCI_IDSEQ, ITEM_ID, VER_NR, CDE_ID, LONG_NAME, 
PREFERRED_NAME, PREFERRED_DEFINITION, VERSION, ORIGIN, DE_CONTE_NAME, 
DEC_ID, DEC_PREFERRED_NAME, DEC_VERSION, VD_ID, VD_PREFERRED_NAME, 
VD_LONG_NM, VD_VERSION, VD_CONTE_NAME, VALID_VALUES)
BEQUEATH DEFINER
AS 
        SELECT   DE.NCI_IDSEQ,
        DE.ITEM_ID,
        DE.VER_NR,
        DE.ITEM_ID CDE_ID,
        DE.ITEM_LONG_NM LONG_NAME,
        DE.ITEM_NM PREFERRED_NAME,
        --rd.doc_text,
        DE.ITEM_DESC PREFERRED_DEFINITION,
        DE.VER_NR VERSION,
        DE.ORIGIN,
        --            de.begin_date,
        DE.CNTXT_NM_DN DE_CONTE_NAME,
        --            de_conte.version de_conte_version,
        DE1.DE_CONC_ITEM_ID DEC_ID,
        DEC.ITEM_DESC DEC_PREFERRED_NAME,
        DEC.VER_NR DEC_VERSION,
        --            dec_conte.name dec_conte_name,
        --            dec_conte.version dec_conte_version,
        VD.ITEM_ID VD_ID,
        VD.ITEM_DESC VD_PREFERRED_NAME,
        VD.ITEM_LONG_NM VD_LONG_NM,
        VD.VER_NR  VD_VERSION,
        VD.CNTXT_NM_DN VD_CONTE_NAME,
        CAST (
        MULTISET(SELECT   PV.PERM_VAL_NM,
                         VM.ITEM_NM SHORT_MEANING,
                         VM.ITEM_DESC PREFERRED_DEFINITION,
                         VM.ITEM_ID VM_ID,
                         VM.VER_NR VERSION
                  FROM   PERM_VAL PV,
                         ADMIN_ITEM VM
                 WHERE       PV.VAL_DOM_ITEM_ID = VD.ITEM_ID
                        AND PV.VAL_DOM_VER_NR = VD.VER_NR
                         AND PV.NCI_VAL_MEAN_ITEM_ID = VM.ITEM_ID
        AND PV.NCI_VAL_MEAN_VER_NR = VM.VER_NR
        ) AS DE_VALID_VALUE_LIST_T)    VALID_VALUES
        FROM   ADMIN_ITEM DE,
        ADMIN_ITEM DEC,
        ADMIN_ITEM VD,
        DE  DE1
        WHERE       DE1.DE_CONC_ITEM_ID = DEC.ITEM_ID
        AND DE1.VAL_DOM_ITEM_ID = VD.ITEM_ID
        AND DE1.DE_CONC_VER_NR = DEC.VER_NR
        AND DE1.VAL_DOM_VER_NR = VD.VER_NR
        AND DE1.ITEM_ID = DE.ITEM_ID 
        AND DE1.VER_NR = DE.VER_NR 
        AND UPPER(DE.ITEM_LONG_NM) LIKE '%STOMACH%';
        GRANT SELECT ON ONEDATA_WA.VW_NCI_DE_EXCEL TO ONEDATA_RO;


