CREATE TABLE SAG_MIGR_LOV_ERR
(
  ERR_ID        NUMBER                          DEFAULT "ONEDATA_WA"."SAG_MIGR_ERR_SEQ"."NEXTVAL",
  LOV_VALUE     VARCHAR2(500 BYTE)              NOT NULL,
  LOV_NAME      VARCHAR2(50 BYTE)               NOT NULL,
  ERROR_TEXT    VARCHAR2(2000 BYTE)             NOT NULL,
  DATE_CREATED  DATE                            DEFAULT sysdate,
  CREATED_BY    VARCHAR2(30 BYTE)               DEFAULT user
)
