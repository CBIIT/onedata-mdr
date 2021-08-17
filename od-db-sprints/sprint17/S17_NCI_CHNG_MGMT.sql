create or replace PACKAGE            nci_chng_mgmt AS
v_temp_rep_ver_nr varchar2(10);
v_temp_rep_id VARCHAR2(10);

function getCSICreateQuestion(v_from in number) return t_question;
function getCSCreateQuestion return t_question;
procedure createAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer, actions in out t_actions);
PROCEDURE spDEPrefQuestPost (v_data_in in clob, v_data_out out clob);
PROCEDURE spCreateDE (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2, v_src in varchar2);
PROCEDURE spCreateCS (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
PROCEDURE spDEValCreateImport (rowform in out t_row, v_op in varchar2, actions in out t_actions, v_val_ind in out boolean);
PROCEDURE spDECreateFrom ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
--PROCEDURE spDECommon ( v_init_ai in t_rowset, v_init_st in t_rowset, v_op  in varchar2,  v_ori_rep_cls in number, hookInput in t_hookInput, hookOutput in out t_hookOutput);
PROCEDURE spClassification ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spClassificationNMDef ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2, v_typ in varchar2);
PROCEDURE spDesignateNew   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spUndesignate   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spClassifyUnclassify   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spShowClassificationNmDef   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
function getDECreateQuestion(v_from in number,v_first in boolean) return t_question;
function getDECreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
function getCSICreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
function getCSCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
procedure createDE (rowform in t_row, actions in out t_actions, v_id out number);
procedure spAddCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spEditCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDeleteCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);

function get_AI_id(P_ID NUMBER,P_VER in number) RETURN VARCHAR2;
END;
/
create or replace PACKAGE            nci_chng_mgmt AS
v_temp_rep_ver_nr varchar2(10);
v_temp_rep_id VARCHAR2(10);

function getCSICreateQuestion(v_from in number) return t_question;
function getCSCreateQuestion return t_question;
procedure createAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer, actions in out t_actions);
PROCEDURE spDEPrefQuestPost (v_data_in in clob, v_data_out out clob);
PROCEDURE spCreateDE (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2, v_src in varchar2);
PROCEDURE spCreateCS (v_data_in in clob, v_data_out out clob, v_usr_id  IN varchar2);
PROCEDURE spDEValCreateImport (rowform in out t_row, v_op in varchar2, actions in out t_actions, v_val_ind in out boolean);
PROCEDURE spDECreateFrom ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
--PROCEDURE spDECommon ( v_init_ai in t_rowset, v_init_st in t_rowset, v_op  in varchar2,  v_ori_rep_cls in number, hookInput in t_hookInput, hookOutput in out t_hookOutput);
PROCEDURE spClassification ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spClassificationNMDef ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2, v_typ in varchar2);
PROCEDURE spDesignateNew   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spUndesignate   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spClassifyUnclassify   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
PROCEDURE spShowClassificationNmDef   ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
function getDECreateQuestion(v_from in number,v_first in boolean) return t_question;
function getDECreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
function getCSICreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
function getCSCreateForm (v_rowset1 in t_rowset, v_rowset2 in t_rowset) return t_forms;
procedure createDE (rowform in t_row, actions in out t_actions, v_id out number);
procedure spAddCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spEditCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
procedure spDeleteCSI ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);

function get_AI_id(P_ID NUMBER,P_VER in number) RETURN VARCHAR2;
END;
/
