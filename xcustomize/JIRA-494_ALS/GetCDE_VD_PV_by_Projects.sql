 
---To get CD PV details for the project based on HDR_ID
    select ALS.HDR_ID,
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
    VD_DISPLAY_FORMAT,
    PV_VALUE,
    VM_LONG_NAME,
    VM_ID,
    VM_VERSION
    FROM
    VW_ALS_CDE_VD_PV_RAW_DATA vw,
    NCI_DLOAD_DTL ALS,
    NCI_DLOAD_HDR H
    where vw.DE_PUB_ID=ALS.ITEM_ID
    AND vw.DE_VERSION=ALS.VER_NR
    and h.HDR_ID=ALS.HDR_ID
    and h.DLOAD_TYP_ID=93
    --and HDR_ID=1000
order by HDR_ID, DE_PUB_ID,DE_VERSION,VD_ID,
    VD_VERSION,VM_ID,
    VM_VERSION;