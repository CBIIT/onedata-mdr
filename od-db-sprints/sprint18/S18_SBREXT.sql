drop index CSI2_UK;
drop index CSI_CSI_2_UK;

alter trigger SBREXT.CC_BIU_ROW enable;
alter trigger SBR.AR_BIU_ROW_ASSIGN_VALUES enable;
alter trigger SBR.ACCSI_BIU_ROW_ASSIGN_VALUES enable;
