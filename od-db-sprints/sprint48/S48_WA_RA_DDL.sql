alter table NCI_STG_MDL_ELMNT add ME_TYP_ID integer;

alter table NCI_MEC_MAP add (SRC_MDL_ITEM_ID number, SRC_MDL_VER_NR number(4,2),TGT_MDL_ITEM_ID number, TGT_MDL_VER_NR number(4,2));

